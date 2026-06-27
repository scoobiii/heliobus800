"""
monitoring/agent.py — Agente de monitoramento HelioBus800
Lê KPIs do barramento 800VDC, CDU e solar/BESS via Modbus/API
e alimenta o dashboard de produção.

Status: STUB — implementar com dados reais do site piloto
"""

import time
import json
import os

# Thresholds de config (ler do dashboard/config.production.json)
CONFIG_PATH = os.path.join(os.path.dirname(__file__), '..', '..', 'dashboard', 'config.production.json')

def load_config():
    with open(CONFIG_PATH) as f:
        return json.load(f)

def read_bus_voltage() -> float:
    """Lê tensão do barramento 800VDC via Modbus TCP (stub)."""
    # TODO: implementar com pymodbus
    # from pymodbus.client import ModbusTcpClient
    # client = ModbusTcpClient(host, port=502)
    return 800.0  # stub

def read_loop_temp() -> float:
    """Lê temperatura de supply do loop de liquid cooling (stub)."""
    # TODO: integrar com sensor 4-20mA ou Modbus
    return 20.0  # stub — alvo: 18-22°C

def read_dew_point() -> float:
    """Lê dew point local (sensor de umidade no site) (stub)."""
    # TODO: integrar com sensor de umidade relativa + cálculo dew point
    return 22.0  # stub — SP verão típico

def check_alerts(cfg, bus_v, loop_temp, dew_point):
    alerts = []
    lo, hi = cfg['telemetry']['bus_voltage_range_v']
    if not (lo <= bus_v <= hi):
        alerts.append(f"ALERT: bus voltage {bus_v}V fora da faixa {lo}-{hi}V")
    margin = loop_temp - dew_point
    min_margin = cfg['alert_thresholds']['dew_point_margin_c_min']
    if margin < min_margin:
        alerts.append(f"ALERT: margem anti-orvalho {margin:.1f}°C abaixo do mínimo {min_margin}°C")
    return alerts

def run(interval: int = 60):
    cfg = load_config()
    print(f"HelioBus800 monitoring agent iniciado (intervalo: {interval}s)")
    while True:
        bus_v = read_bus_voltage()
        loop_temp = read_loop_temp()
        dew_point = read_dew_point()
        alerts = check_alerts(cfg, bus_v, loop_temp, dew_point)
        status = {
            'ts': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
            'bus_voltage_v': bus_v,
            'loop_supply_temp_c': loop_temp,
            'dew_point_c': dew_point,
            'dew_point_margin_c': round(loop_temp - dew_point, 1),
            'alerts': alerts,
        }
        print(json.dumps(status))
        time.sleep(interval)

if __name__ == '__main__':
    run()

# ── endpoint REST para ThermoFlex bridge ─────────────────────────────────────
def serve_telemetry(port: int = 8080):
    """
    Expõe /telemetry como endpoint HTTP simples (sem framework).
    ThermoFlex-Dashboard faz polling neste endpoint via hb800_data_bridge.ts
    """
    import json
    from http.server import HTTPServer, BaseHTTPRequestHandler

    agent_ref = {'bus_v': 800.0, 'loop_temp': 20.0, 'dew_point': 22.0}

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            if self.path == '/telemetry':
                cfg = load_config()
                bus_v = read_bus_voltage()
                loop_temp = read_loop_temp()
                dew_point = read_dew_point()
                alerts = check_alerts(cfg, bus_v, loop_temp, dew_point)
                payload = {
                    'ts': __import__('time').strftime('%Y-%m-%dT%H:%M:%SZ',
                                    __import__('time').gmtime()),
                    'bus_voltage_v': bus_v,
                    'loop_supply_temp_c': loop_temp,
                    'dew_point_c': dew_point,
                    'dew_point_margin_c': round(loop_temp - dew_point, 1),
                    'pue': 1.12,          # stub — substituir por leitura real
                    'cue': 0.0,
                    'solar_gen_kw': 850.0, # stub
                    'bess_soc_pct': 78.0,  # stub
                    'alerts': alerts,
                }
                body = json.dumps(payload).encode()
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')  # CORS para ThermoFlex
                self.end_headers()
                self.wfile.write(body)
            else:
                self.send_response(404)
                self.end_headers()
        def log_message(self, *args): pass  # silencia logs de request

    print(f"HB800 telemetry server em http://localhost:{port}/telemetry")
    HTTPServer(('0.0.0.0', port), Handler).serve_forever()

if __name__ == '__main__':
    import threading
    t = threading.Thread(target=serve_telemetry, daemon=True)
    t.start()
    run()
