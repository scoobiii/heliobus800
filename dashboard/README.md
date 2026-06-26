# Dashboard de Monitoramento — HelioBus800

## Config
- `config.production.json` — KPIs, telemetria, thresholds e fontes de dados

## Apps do ecossistema MEx a fundir (não construir do zero)
| App | Módulo HelioBus800 |
|---|---|
| MEX BioDataCloud / MEX Place | Painel principal do site |
| Global DC Sentinel | Módulo redundância elétrica (BESS/UPS/cabine) |
| VoltWise | Gestão de cabine primária e carga reativa |
| ANEEL 1000/2021 Dashboard | Qualidade de energia e regulatório |
| Solar Potential Dashboard | Geração solar em tempo real por site |

## Painel adicional a construir
- View por site (telhado): geração solar vs. consumo do galpão hospedeiro
- Status de cada módulo HB800: tensão de barramento, temperatura de loop,
  margem de dew point, alertas de arco DC
- KPIs consolidados: PUE, CUE, eficiência 800VDC por site e agregada

## Integração com agente de monitoramento
Ver `src/monitoring/agent.py` — publica JSON por intervalo configurável,
consumir via WebSocket ou polling REST no frontend.
