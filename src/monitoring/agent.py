"""
monitoring/agent.py — Agente de monitoramento HelioBus800
Normas: ASHRAE TC 9.9 (2021) Classe A1 + ABNT NBR 16665:2017

Ambiente: DC FECHADO e SELADO com HVAC de precisão
Dew point de referência: INTERNO (sensor no DC), não externo (INMET)
Meta UR interna: ≤ 50% → dew point interno típico 8-14°C
"""

import time, json, math, os
from pathlib import Path

CONFIG_PATH = Path(__file__).parent.parent.parent / "dashboard" / "config.production.json"

def load_config() -> dict:
    with open(CONFIG_PATH) as f:
        return json.load(f)

# ── Fórmula Magnus (ASHRAE Fundamentals 2021, Cap. 1) ────────────────────────
def calc_dew_point(temp_c: float, rh_pct: float) -> float:
    """Dew point por Magnus aproximado. Precisão ±0.35°C para 0-60°C."""
    if rh_pct <= 0:
        return -99.0
    a, b = 17.625, 243.04
    gamma = math.log(rh_pct / 100.0) + (a * temp_c) / (b + temp_c)
    return round((b * gamma) / (a - gamma), 1)

# ── Leituras de sensores (STUBS — substituir por Modbus/4-20mA reais) ────────
def read_bus_voltage() -> float:
    """Tensão barramento 800VDC via Modbus TCP."""
    # TODO: from pymodbus.client import ModbusTcpClient
    return 800.0

def read_loop_supply_temp() -> float:
    """Temperatura de supply do CDU (manifold de distribuição)."""
    # TODO: sensor PT100 ou NTC no manifold
    return 18.0  # °C — dentro da faixa 15-22°C ASHRAE A1

def read_internal_temp() -> float:
    """Temperatura de bulbo seco interna do DC (ASHRAE A1: 15-32°C)."""
    return 24.0  # °C típico para DC controlado

def read_internal_rh() -> float:
    """Umidade relativa interna (ASHRAE A1: ≤ 50%)."""
    return 45.0  # % — ambiente fechado e selado com HVAC de precisão

def read_return_temp() -> float:
    """Temperatura de return do CDU."""
    return 35.0  # °C típico

# ── Verificação de alertas (ASHRAE A1 + config.production.json) ──────────────
def check_alerts(cfg: dict, bus_v: float, supply_temp: float,
                 internal_temp: float, internal_rh: float,
                 return_temp: float) -> list[str]:
    alerts = []
    tel = cfg.get("telemetry", {})
    thr = cfg.get("alert_thresholds", {})

    # barramento 800VDC
    lo, hi = tel.get("bus_voltage_range_v", [600, 850])
    if not (lo <= bus_v <= hi):
        alerts.append(f"ALERT: barramento {bus_v}V fora de {lo}-{hi}V")

    # supply CDU (ASHRAE A1: não condensar — depende do dp interno)
    dp_internal = calc_dew_point(internal_temp, internal_rh)
    min_margin = thr.get("dew_point_margin_c_min", 3)
    margin = supply_temp - dp_internal
    if margin < min_margin:
        alerts.append(
            f"ALERT: margem anti-orvalho {margin:.1f}°C < mínimo {min_margin}°C "
            f"(supply {supply_temp}°C, dp_interno {dp_internal}°C) "
            f"[ASHRAE A1 / ABNT NBR 16665]"
        )

    # temperatura interna ASHRAE A1: 15-32°C
    if not (15 <= internal_temp <= 32):
        alerts.append(f"ALERT: temp interna {internal_temp}°C fora da faixa ASHRAE A1 (15-32°C)")

    # UR interna ASHRAE A1: ≤ 50%
    if internal_rh > 50:
        alerts.append(f"ALERT: UR interna {internal_rh}% acima do limite ASHRAE A1 (50%)")

    # dew point interno ASHRAE A1: ≤ 17°C
    if dp_internal > 17:
        alerts.append(f"ALERT: dew point interno {dp_internal}°C acima do limite ASHRAE A1 (17°C)")

    # return CDU: limite operacional
    if return_temp > 45:
        alerts.append(f"ALERT: return CDU {return_temp}°C > 45°C — carga térmica excessiva")

    return alerts

def run(interval: int = 60):
    cfg = load_config()
    print("HelioBus800 monitoring agent — ASHRAE A1 / ABNT NBR 16665")
    print(f"Intervalo: {interval}s | Ambiente: DC fechado e selado")
    while True:
        bus_v       = read_bus_voltage()
        supply_temp = read_loop_supply_temp()
        int_temp    = read_internal_temp()
        int_rh      = read_internal_rh()
        ret_temp    = read_return_temp()
        dp_internal = calc_dew_point(int_temp, int_rh)
        alerts      = check_alerts(cfg, bus_v, supply_temp,
                                   int_temp, int_rh, ret_temp)

        status = {
            "ts": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "norma": "ASHRAE TC9.9 A1 / ABNT NBR 16665",
            "ambiente": "fechado_selado",
            "bus_voltage_v": bus_v,
            "loop_supply_temp_c": supply_temp,
            "loop_return_temp_c": ret_temp,
            "internal_temp_c": int_temp,
            "internal_rh_pct": int_rh,
            "dew_point_interno_c": dp_internal,
            "dew_point_margin_c": round(supply_temp - dp_internal, 1),
            "ashrae_a1_ok": len(alerts) == 0,
            "pue": 1.12,
            "cue": 0.0,
            "solar_gen_kw": 850.0,
            "bess_soc_pct": 78.0,
            "alerts": alerts,
        }
        print(json.dumps(status, ensure_ascii=False))
        time.sleep(interval)

# ── endpoint REST para ThermoFlex bridge ──────────────────────────────────────
def serve_telemetry(port: int = 8080):
    import json as _json
    from http.server import HTTPServer, BaseHTTPRequestHandler
    cfg = load_config()

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            if self.path == "/telemetry":
                bus_v       = read_bus_voltage()
                supply_temp = read_loop_supply_temp()
                int_temp    = read_internal_temp()
                int_rh      = read_internal_rh()
                ret_temp    = read_return_temp()
                dp_internal = calc_dew_point(int_temp, int_rh)
                alerts      = check_alerts(cfg, bus_v, supply_temp,
                                           int_temp, int_rh, ret_temp)
                payload = {
                    "ts": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                    "norma": "ASHRAE TC9.9 A1 / ABNT NBR 16665",
                    "bus_voltage_v": bus_v,
                    "loop_supply_temp_c": supply_temp,
                    "loop_return_temp_c": ret_temp,
                    "internal_temp_c": int_temp,
                    "internal_rh_pct": int_rh,
                    "dew_point_interno_c": dp_internal,
                    "dew_point_margin_c": round(supply_temp - dp_internal, 1),
                    "ashrae_a1_ok": len(alerts) == 0,
                    "pue": 1.12,
                    "cue": 0.0,
                    "solar_gen_kw": 850.0,
                    "bess_soc_pct": 78.0,
                    "alerts": alerts,
                }
                body = _json.dumps(payload, ensure_ascii=False).encode()
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.send_header("Access-Control-Allow-Origin", "*")
                self.end_headers()
                self.wfile.write(body)
            else:
                self.send_response(404)
                self.end_headers()
        def log_message(self, *a): pass

    print(f"HB800 telemetry REST em http://localhost:{port}/telemetry")
    HTTPServer(("0.0.0.0", port), Handler).serve_forever()

if __name__ == "__main__":
    import threading
    threading.Thread(target=serve_telemetry, daemon=True).start()
    run()
