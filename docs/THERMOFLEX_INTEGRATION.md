# Integração ThermoFlex-Dashboard ↔ HelioBus800

## Arquitetura

```
[monitoring/agent.py]
  └── serve_telemetry() → http://localhost:8080/telemetry (JSON)
                                    ↑ polling 5s
[dashboard/thermoflex/]  ← submodule scoobiii/ThermoFlex-Dashboard
  └── hb800_data_bridge.ts → fetchHB800Telemetry() → mapToThermoFlex()
        └── injeta em: PowerPlant, DataCenter, Utilities, Chiller, Financials
```

## Páginas ThermoFlex → Dados HB800

| Página | Dados consumidos |
|---|---|
| PowerPlant | solar_gen_kw, bess_soc_pct, plantStatus |
| DataCenter | activeRackCount, pue, bus_voltage_v |
| Utilities | loop_supply_temp_c, dew_point_margin_c |
| Chiller | loop_supply_temp_c, dew_point_c (CDU 800VDC) |
| Financials | pue, cue, solar_gen_kw → CAPEX/OPEX dinâmico |

## Como rodar

```bash
# 1. monitoring agent com endpoint REST
cd ~/heliobus800
python3 src/monitoring/agent.py

# 2. ThermoFlex frontend
cd dashboard/thermoflex
npm install
GEMINI_API_KEY=sua_key npm run dev

# 3. acessar
# http://localhost:5173  → ThermoFlex com dados reais do HB800
# http://localhost:8080/telemetry → JSON de telemetria
```

## Variáveis de ambiente

```bash
GEMINI_API_KEY=     # para MexInteligencia/AI Studio
ANTHROPIC_API_KEY=  # para agentes HB800 (llm_router.py)
JWT_SECRET=         # auth dashboard
```
