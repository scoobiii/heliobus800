# Engineering Prompt Mestre — HelioBus800

## Brief para engenheiros, parceiros e modelos de IA

```
Projeto: HelioBus800 (HB800 + HVAC800VDC)
Produto: Inverter/compressor 800VDC nativo + CDU integrado para liquid cooling
         de racks AI/HPC (600kW-1MW), alimentado por solar + BESS, zero diesel,
         instalado em telhados de galpões logísticos de baixa densidade energética.

Plataformas atendidas:
  1. Clássico GPU/CPU (carga primária, centenas de kW/rack)
  2. Óptico/fotônico (co-processador no mesmo rack, carga menor)
  3. Quântico Si-28 spin qubit (eletrônica de controle 800VDC;
     criostato em skid dedicado separado, 0.3K-1.5K)

Requisitos elétricos:
  - Entrada: 800VDC, faixa 600-850VDC (Diablo OCP ou NVIDIA monopolar)
  - Topologia: GaN/SiC, LLC ressonante single-stage
  - Eficiência: >96% por estágio, >92% ponta-a-ponta
  - Proteção: detecção de arco DC + desconexão <10ms
  - Capacidade: dimensionado para até 1MW por módulo/site

Requisitos térmicos:
  - Loop secundário: supply 18-22°C
  - Margem anti-orvalho: mínimo 3°C acima do dew point local
  - Dew point SP verão: ~22-24°C → temperature supply mínima: 25°C
  - Referência CDU: Deschutes (OCP), ~2MW térmico, ~500GPM a 80-90psi

Tier:
  - Mínimo viável: Tier III
  - Contrato hyperscaler: Tier IV
  - "Tier V": SLA contratual multi-site, não certificação técnica

Decisão pendente (BLOCKER até mês 2):
  Escolher topologia de barramento: Diablo vs NVIDIA monopolar.
  Esta decisão define conectores, bus bar, proteção e certificação.

Entregáveis esperados por sprint:
  1. Spec eletromecânica documentada em docs/ARCHITECTURE.md
  2. Plano de testes e critério de aceite
  3. Rastreamento de custo atualizado em docs/CAPEX.md
  4. Issue correspondente aberta no GitHub com label de fase
```

## Sprints planejadas

### Sprint 1 (mês 1-2) — Decisão de topologia
- Mapear specs completas Diablo e NVIDIA monopolar
- Avaliar disponibilidade de componentes no Brasil
- Decidir e documentar em ARCHITECTURE.md
- Abrir issues de BLOCKER resolvidas

### Sprint 2 (mês 2-4) — Spec do inverter
- BOM do inverter 800VDC (GaN/SiC, LLC ressonante)
- Plano de testes elétricos de bancada
- Parceria ST/TI para boards de referência

### Sprint 3 (mês 4-6) — Spec do CDU + anti-orvalho
- Dimensionamento do loop de liquid cooling por site
- Modelo de controle de temperatura (18-22°C supply)
- Dados meteorológicos INMET/SP para dew point histórico

### Sprint 4 (mês 6-8) — Integração solar + BESS
- Dimensionamento solar por site piloto (PVGIS)
- Spec do BESS (LFP, autonomia noturna, integração 800VDC sem AC)
- Diagrama unifilar completo solar → BESS → 800VDC → CDU → rack

### Sprint 5 (mês 8-12) — Due diligence de sites + piloto
- Avaliar 3-5 galpões logísticos candidatos
- Contrato de locação de telhado (cláusula de portabilidade)
- Instalação do 1º módulo piloto e coleta de dados reais
