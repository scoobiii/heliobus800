"""
tests/test_kpi.py — KPIs com ASHRAE A1 / ABNT NBR 16665
Ambiente: DC fechado e selado — dew point INTERNO como referência
"""
import sys, os, math
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src', 'monitoring'))
from agent import check_alerts, calc_dew_point

CFG = {
    "telemetry": {"bus_voltage_range_v": [600, 850]},
    "alert_thresholds": {"dew_point_margin_c_min": 3}
}

# ── dew point Magnus ──────────────────────────────────────────────────────────
def test_dew_point_ashrae_a1_normal():
    """24°C, UR 45% → dp ~11.6°C (bem abaixo do limite A1 de 17°C)"""
    dp = calc_dew_point(24, 45)
    assert 10 < dp < 14, f"dp={dp}"

def test_dew_point_ashrae_a1_limit():
    """Para dp ≤ 17°C, UR deve ser < ~62% a 24°C"""
    dp = calc_dew_point(24, 62)
    assert dp <= 17, f"dp={dp} > 17°C limite ASHRAE A1"

# ── check_alerts com ambiente interno ─────────────────────────────────────────
def test_supply_18_ok_ambiente_fechado():
    """Supply 18°C, dp interno ~11.6°C → margem 6.4°C > 3°C mínimo ✅"""
    alerts = check_alerts(CFG, 800.0, 18.0, 24.0, 45.0, 35.0)
    dew_alerts = [a for a in alerts if 'orvalho' in a]
    assert dew_alerts == [], f"Não deveria ter alerta: {dew_alerts}"

def test_supply_20_ok_ambiente_fechado():
    """Supply 20°C, dp interno ~11.6°C → margem 8.4°C ✅"""
    alerts = check_alerts(CFG, 800.0, 20.0, 24.0, 45.0, 35.0)
    dew_alerts = [a for a in alerts if 'orvalho' in a]
    assert dew_alerts == [], f"Não deveria ter alerta: {dew_alerts}"

def test_rh_alta_gera_alerta():
    """UR 60% → dp ~15.2°C → supply 18°C dá margem 2.8°C < 3°C → ALERTA"""
    alerts = check_alerts(CFG, 800.0, 18.0, 24.0, 60.0, 35.0)
    assert any('orvalho' in a or 'UR' in a for a in alerts), f"Esperava alerta: {alerts}"

def test_ashrae_a1_temp_alta():
    """Temp interna 34°C > 32°C limite A1 → ALERTA"""
    alerts = check_alerts(CFG, 800.0, 18.0, 34.0, 45.0, 35.0)
    assert any('ASHRAE A1' in a for a in alerts), f"Esperava alerta ASHRAE: {alerts}"

def test_bus_voltage_ok():
    alerts = check_alerts(CFG, 800.0, 18.0, 24.0, 45.0, 35.0)
    assert not any('barramento' in a for a in alerts)

def test_bus_voltage_low():
    alerts = check_alerts(CFG, 590.0, 18.0, 24.0, 45.0, 35.0)
    assert any('barramento' in a for a in alerts)

def test_all_ok_ambiente_fechado():
    """Cenário ideal: 800V, supply 18°C, int 24°C, UR 45% → zero alertas"""
    alerts = check_alerts(CFG, 800.0, 18.0, 24.0, 45.0, 35.0)
    assert alerts == [], f"Esperava zero alertas: {alerts}"
