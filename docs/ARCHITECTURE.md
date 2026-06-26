# Arquitetura Técnica — HelioBus800

## Stack por camada

```
[Painel Solar FV 1-5MWp] ──MPPT──► [BESS LFP] ──► Barramento 800VDC (600-850V, 5kA)
                                                           │
                              ┌────────────────────────────┘
                              ▼
                    [Inverter/Compressor 800VDC]
                    GaN/SiC · LLC ressonante single-stage
                    >96% eficiência · arc-fault <10ms
                              │
                              ▼
                    [CDU liquid cooling]
                    supply 18-22°C · ~2MW · 500GPM · 80-90psi
                              │
              ┌───────────────┼──────────────────┐
              ▼               ▼                  ▼
        [GPU/CPU rack]  [Fotônico rack]   [Quântico skid]
        600kW-1MW       co-processador    Si-28 spin qubit
        800VDC ✅       800VDC ✅         800VDC ✅ (ctrl)
        loop ✅         loop ✅           loop ❌ criostato
```

## Decisão BLOCKER — mês 2 do PIPE

| Critério            | Diablo (OCP)          | NVIDIA Monopolar     |
|---------------------|-----------------------|----------------------|
| Tensão              | ±400 ou 800VDC        | 800VDC               |
| Potência máx/rack   | 1MW                   | 660kW (→MW em 2027)  |
| Cadeia suprimentos  | Automotiva EV (madura)| Própria NVIDIA       |
| Deploy em massa     | Já em produção        | Kyber 2027           |
| Lock-in             | Menor (consórcio OCP) | Maior (vendor único) |

Recomendação preliminar: **Diablo** para Fase 1.

## Componentes de referência

| Subsistema | Players |
|---|---|
| GaN/SiC inverter | ST Micro, TI, Wolfspeed, Infineon |
| CDU/Liquid cooling | Vertiv (H2/2026), Eaton, Schneider, Hitachi |
| Proteção DC | ABB, Eaton, Mersen, Littelfuse |
| BESS/Solar | CATL LFP, BYD, Sungrow, Huawei FusionSolar |

## Módulo quântico Si-28

- Controle à temperatura ambiente → 800VDC normal
- Criostato dedicado: Si-28 spin → 1-1.5K (He-4 bombeado)
- Referência: Equal1 RacQ, rack 19", 1600W, lançado mai/2026
- **Não** compartilha loop de liquid cooling 18-22°C
