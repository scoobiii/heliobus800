"""
tests/test_kpi.py — Testa thresholds dos KPIs definidos em docs/KPI.md
"""
import json, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src', 'monitoring'))
from agent import check_alerts

CONFIG = {
    "telemetry": {"bus_voltage_range_v": [600, 850]},
    "alert_thresholds": {"dew_point_margin_c_min": 3}
}

def test_bus_voltage_ok():
    alerts = check_alerts(CONFIG, 800.0, 20.0, 22.0)
    assert not any("bus voltage" in a for a in alerts)

def test_bus_voltage_low():
    alerts = check_alerts(CONFIG, 590.0, 20.0, 15.0)
    assert any("bus voltage" in a for a in alerts)

def test_bus_voltage_high():
    alerts = check_alerts(CONFIG, 860.0, 20.0, 15.0)
    assert any("bus voltage" in a for a in alerts)

def test_dew_point_margin_ok():
    # loop 25°C, dew 22°C → margem 3°C = exatamente no limite
    alerts = check_alerts(CONFIG, 800.0, 25.0, 22.0)
    assert not any("orvalho" in a for a in alerts)

def test_dew_point_margin_fail():
    # loop 23°C, dew 22°C → margem 1°C < 3°C mínimo
    alerts = check_alerts(CONFIG, 800.0, 23.0, 22.0)
    assert any("orvalho" in a for a in alerts)

def test_all_ok():
    alerts = check_alerts(CONFIG, 800.0, 20.0, 15.0)
    assert alerts == []
