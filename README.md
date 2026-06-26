# HelioBus800 (HB800 + HVAC800VDC)

> Barramento 800VDC para liquid cooling de racks AI/HPC (600kW–1MW),
> suprido por solar + BESS, zero diesel, instalado em telhados de
> galpões logísticos de baixa densidade energética.
> Projeto-filho de [ET-CCNFT/DeepEnergy](https://github.com/scoobiii/ET-CCNFT).

## Ecossistema

```
ET-CCNFT           → macro: visão, KPIs, sites globais, certificações
      ↑
heliobus800        → produto: inverter 800VDC + CDU solar+BESS, zero diesel
      ↑
selixIA            → agente: specs OCP/NVIDIA, editais FAPESP/FINEP, KPIs
```

## Plataformas suportadas simultaneamente

| Plataforma | 800VDC | Loop 18-22°C | Observação |
|---|---|---|---|
| Clássico GPU/CPU | ✅ | ✅ | Carga primária (centenas de kW/rack) |
| Óptico/fotônico | ✅ | ✅ | Co-processador no mesmo rack |
| Quântico Si-28 | ✅ (controle) | ❌ | Criostato em skid dedicado separado |

## Estrutura do repo

```
heliobus800/
├── README.md
├── Makefile
├── heliobus800-bootstrap.sh      ← setup Termux/proot (1x)
├── heliobus800-automation.sh     ← pipeline CI: update→build→test→PR
├── heliobus800-gitsetup.sh       ← configura git + SSH key
├── heliobus800-init-tree.sh      ← recria árvore de docs
├── docs/
│   ├── ENGINEERING_PROMPT.md    ← sprint mestre de engenharia
│   ├── ARCHITECTURE.md          ← diagrama stack + decisões
│   ├── OCP_REFERENCE.md         ← Diablo vs NVIDIA, players, CDU ref
│   ├── SITING_MODEL.md          ← modelo telhado galpão logístico
│   ├── TIER_CERTIFICATION.md    ← Tier III/IV real vs "Tier V"
│   ├── KPI.md                   ← PUE/CUE/DCiE/ERE herdados ET-CCNFT
│   ├── CAPEX.md                 ← 5 fases + fontes financiamento
│   ├── ROADMAP.md               ← 5W2H por fase + IPO anos 9-10
│   └── BUSINESS_PLAN.md        ← BP 5/10 anos incluindo IPO
├── src/
│   ├── inverter/                ← firmware/spec inverter 800VDC
│   ├── cdu/                     ← spec CDU liquid cooling
│   ├── solar_bess/              ← integração solar + BESS
│   └── monitoring/              ← agentes de monitoramento
├── dashboard/
│   ├── config.production.json
│   └── README.md
├── tests/
│   ├── test_kpi.py
│   └── test_architecture.py
├── infra/
│   └── Dockerfile
└── .github/
    ├── workflows/ci.yml
    └── ISSUE_TEMPLATE/
        ├── blocker.yml
        └── engineering_task.yml
```

## Início rápido (Termux)

```bash
GIT_EMAIL="seu@email.com" bash heliobus800-gitsetup.sh
bash heliobus800-bootstrap.sh
make run
```

## KPIs herdados

| KPI | Meta |
|---|---|
| PUE | < 1,15 |
| CUE | 0 (zero diesel) |
| DCiE | > 87% |
| Eficiência 800VDC ponta-a-ponta | > 92% |
