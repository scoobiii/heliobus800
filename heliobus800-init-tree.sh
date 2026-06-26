#!/usr/bin/env bash
# heliobus800-init-tree.sh
# Cria a árvore completa de diretórios + documentação do repo HelioBus800 (HB800 + HVAC800VDC)
# Rodar dentro do diretório do repo já clonado (ex: ~/heliobus800)

set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

mkdir -p docs dashboard scripts .github

# ─────────────────────────────────────────────────────────────
# docs/ENGINEERING_PROMPT.md — sprint mestre de engenharia
# ─────────────────────────────────────────────────────────────
cat > docs/ENGINEERING_PROMPT.md << 'EOF'
# Engineering Prompt — HelioBus800 (HB800 + HVAC800VDC)

## Missão
Inverter/compressor e CDU nativos 800VDC para liquid cooling de racks de IA/HPC
(600kW-1MW), supridos por solar + BESS (zero diesel), instalados via locação de
telhado de galpões logísticos de baixa densidade energética.

## Plataformas atendidas simultaneamente
| Plataforma | Compartilha barramento 800VDC | Compartilha loop liquid cooling 18-22°C |
|---|---|---|
| Clássico (GPU/CPU) | Sim — carga primária | Sim |
| Óptico/fotônico (co-processador) | Sim | Sim |
| Quântico (Si-28 spin / supercondutor) | Sim (eletrônica de controle à temp. ambiente) | Não — criostato em skid dedicado |

## Requisitos eletromecânicos
- Entrada: 800VDC, faixa operacional 600-850VDC
- Conversão: estágio único LLC ressonante, GaN/SiC, eficiência alvo >96% por estágio,
  >92% ponta-a-ponta (referência: arquitetura NVIDIA elimina UPS/PDU intermediários)
- Proteção: detecção de arco DC e desconexão <10ms (arco DC não se auto-extingue em zero-cross)
- Loop secundário de liquid cooling: supply 18-22°C (margem de 3-5°C sobre ponto de
  orvalho local — clima tropical Brasil)
- Hidráulica de referência: CDU classe ~2MW térmico, ~500GPM a 80-90psi
- Topologia de origem: escolher entre Diablo (OCP, 400/800VDC) ou referência
  monopolar NVIDIA (800V) — ver docs/OCP_REFERENCE.md — e travar antes de
  especificar conectores/proteção/bus bar

## Sites
- Locação de telhado de galpões logísticos de baixa densidade energética
  (ver docs/SITING_MODEL.md) — não é greenfield de DC tradicional
- Cada site é um módulo: solar no telhado → BESS → 800VDC → CDU+rack
- Escala horizontal (múltiplos sites pequenos), não vertical (um DC gigante)

## Tier
- Mínimo viável: Tier III
- Contrato hyperscaler: Tier IV
- "Tier V": não é certificação oficial Uptime Institute — ver docs/TIER_CERTIFICATION.md
  para definição interna proposta antes de prometer isso a qualquer cliente

## Backlog de sprint (próximos 4 ciclos)
1. Especificação do barramento 800VDC (topologia, proteção, bus bar) — travar Diablo vs NVIDIA
2. Diagrama unifilar solar → BESS → 800VDC → CDU → rack, por módulo de telhado
3. Protótipo de bancada do inverter/compressor 800VDC anti-orvalho
4. Dashboard de monitoramento de produção (ver dashboard/) integrado aos sites piloto
5. Due diligence de 3-5 galpões logísticos candidatos (área de telhado, carga elétrica
   atual, estrutura de cobertura, contrato de locação)
6. Qualificação térmica em câmara (ciclagem, dew point) do protótipo

## Critério de pronto (definition of done) por item
- Tem spec eletromecânica documentada em docs/ARCHITECTURE.md
- Tem plano de teste e critério de aceite
- Tem rastreamento de custo (CAPEX/OPEX) atualizado em docs/BUSINESS_PLAN.md
- Tem issue correspondente aberta no GitHub com label de fase
EOF

# ─────────────────────────────────────────────────────────────
# docs/OCP_REFERENCE.md — material OCP/NVIDIA 800VDC consolidado
# ─────────────────────────────────────────────────────────────
cat > docs/OCP_REFERENCE.md << 'EOF'
# Referência técnica — OCP 800VDC e ecossistema NVIDIA (jun/2026)

## Não existe uma spec única — dois sabores principais

### 1. Diablo (OCP — Google/Meta/Microsoft)
- Rack de potência desagregado ("sidecar"), movendo a distribuição de energia
  dentro do rack de 48VDC para ±400VDC ou 800VDC
- Suporta racks de 100kW a 1MW
- 400VDC nominal escolhido para aproveitar cadeia de suprimentos automotiva (EV)
- Divergência entre hyperscalers:
  - Meta: 600-800kW, cabos HVDC de 50kW + whips AC de 200A
  - Google: empurrando para 900kW realocando espaço de BBU/supercap para PSUs
  - Amazon: 800kW a ±400V
  - Microsoft: adoção mais lenta

### 2. Referência monopolar NVIDIA (fora do Diablo)
- Design de referência 800V a 660kW, amostras refrigeradas a ar e produção
  prevista para meados de 2026
- Variante refrigerada a líquido (VR Ultra) amostrando fim de 2026
- Deploy em massa do 800V HVDC com rack Rubin Ultra Kyber previsto para 2027
- Bloco conceitual de 17,5MW: 5 retificadores MV de 3,5MW em redundância
  "5-para-fazer-4", convertendo 35kVAC → 800VDC, alimentando barramento DC
  centralizado de 5000A
- No rack: estágio único de conversão LLC ressonante 64:1 entrega 800VDC
  direto no nível do chip, eliminando UPS/PDU intermediários — corte de ~45%
  do cobre, eficiência ponta-a-ponta de ~83% para 92%+

## CDU de referência
- "Deschutes": ~2MW de carga térmica, capacidade hidráulica ~500GPM a 80-90psi

## Players de ecossistema confirmados
- Vertiv (portfólio 800VDC no H2 2026), Eaton (arquitetura de referência
  desde out/2025), Foxconn, CoreWeave, Lambda, Nebius, Flex, Hitachi,
  Schneider Electric, Siemens
- Componentes de potência: ST Microelectronics, Texas Instruments (boards de
  referência 800VDC validados com NVIDIA)
- Startups de nicho: Heron Power (trabalhando com NVIDIA e Crusoe)

## Decisão obrigatória do HelioBus800
Escolher Diablo ou referência NVIDIA monopolar ANTES de especificar conectores,
topologia de bus bar e proteção de arco DC — as três coisas mudam entre os
dois sabores e não são retrofitáveis sem redesenho.
EOF

# ─────────────────────────────────────────────────────────────
# docs/SITING_MODEL.md — modelo de telhado de galpão logístico
# ─────────────────────────────────────────────────────────────
cat > docs/SITING_MODEL.md << 'EOF'
# Modelo de siting — telhado de galpão logístico de baixa densidade energética

## Lógica do modelo
Galpões logísticos (CDs de varejo/e-commerce) têm grande área de telhado e
consumo elétrico modesto (iluminação, esteiras, alguma refrigeração) —
diferença entre potencial de geração solar do telhado e consumo do galpão é
"capacidade ociosa" que pode hospedar um módulo HelioBus800.

## Por que isso muda o desenho do produto
- Não é um data center monolítico — é uma rede de módulos pequenos (DC pods),
  cada um dimensionado pela geração solar disponível naquele telhado específico
- Escala é horizontal (mais sites) e não vertical (rack maior por site)
- Reduz CAPEX de terreno/obra civil — você aluga telhado já construído, não
  compra terreno e constrói prédio
- Cada módulo precisa ser plug-and-play: container/skid com 800VDC + CDU +
  rack, conectado ao solar+BESS do telhado

## Dimensionamento (ordem de grandeza, validar por site)
| Item | Faixa típica |
|---|---|
| Área de telhado disponível (galpão logístico médio-grande) | 20.000-50.000 m² |
| Potencial solar instalável | ~1-5 MWp, dependendo de estrutura e sombreamento |
| Consumo elétrico típico do galpão (baixa densidade) | Fração pequena do potencial solar — sobra de capacidade |
| Tamanho de módulo HelioBus800 por site | Dimensionado pela sobra, não pelo teto técnico do produto |

## Due diligence por candidato a site
- Capacidade estrutural do telhado (carga adicional de painéis + skid, se houver)
- Contrato de locação (prazo mínimo viável para retorno do CAPEX do módulo)
- Distância até ponto de conexão de rede/backbone de fibra (latência para
  workload de IA distribuída)
- Carga elétrica atual do galpão (para calcular sobra real, não só área de telhado)

## Sinergia com portfólio existente
Os ativos já mapeados — Solar & BESS Pitch Deck e GPA CD1 Solar Deck (GPA,
distribuição de varejo) — são candidatos naturais de piloto: já há relação
comercial e dados de consumo elétrico real do galpão.

## Risco a monitorar
Modelo de locação de telhado depende de contrato de longo prazo com o
proprietário do galpão — isso é um risco contratual/jurídico distinto do
risco técnico, e precisa de cláusula de saída/portabilidade do módulo caso
o contrato de locação não seja renovado.
EOF

# ─────────────────────────────────────────────────────────────
# docs/TIER_CERTIFICATION.md
# ─────────────────────────────────────────────────────────────
cat > docs/TIER_CERTIFICATION.md << 'EOF'
# Tiers de disponibilidade — definição e uso correto

## O que existe oficialmente (Uptime Institute)
- Tier I: capacidade básica, sem redundância
- Tier II: componentes redundantes
- Tier III: manutenção concorrente (sem desligar operação)
- Tier IV: tolerante a falha, 2N ou superior, é o teto oficial da certificação

## Sobre "Tier V"
Não existe Tier V como certificação oficial do Uptime Institute. Quando um
cliente pede "Tier 5", isso normalmente significa um requisito proprietário
dele (ex: soberania de dados, redundância geográfica entre sites, SLA
contratual acima de Tier IV) — não é um patamar técnico adicional de
engenharia térmica/elétrica definido por norma.

## Posição do HelioBus800
- Não vender "Tier V" como certificação — vender como SLA contratual
  customizado, definido caso a caso com o cliente
- Definição interna proposta para uso comercial, se necessário:
  "HelioBus800 Tier IV+" = Tier IV (2N, tolerante a falha) + redundância
  geográfica entre no mínimo 2 módulos/sites + cláusula de soberania de
  dados quando exigido
- Não gastar CAPEX de engenharia térmica perseguindo um "Tier 5" sem o
  cliente definir contratualmente o que isso significa
EOF

# ─────────────────────────────────────────────────────────────
# docs/KPI.md — herdado do ET-CCNFT
# ─────────────────────────────────────────────────────────────
cat > docs/KPI.md << 'EOF'
# KPIs — herdados do ET-CCNFT/DeepEnergy

| KPI | Descrição | Meta HelioBus800 |
|---|---|---|
| PUE | Power Usage Effectiveness | < 1,15 |
| CUE | Carbon Usage Effectiveness | 0 (solar+BESS, zero diesel) |
| DCiE | Data Center infrastructure Efficiency | > 87% |
| ERE | Energy Reuse Effectiveness | a mapear por site (calor residual) |
| Eficiência ponta-a-ponta da conversão 800VDC | single-stage | > 92% |
| GFLOPS/Watt (referência Green500) | benchmark HPL | acompanhar contra top 10 Green500 vigente |

KPIs específicos de siting (novos, não herdados):
| KPI | Descrição |
|---|---|
| Razão geração solar / consumo do galpão hospedeiro | sobra de capacidade disponível para o módulo |
| Tempo de retorno do CAPEX do módulo vs. prazo do contrato de locação | risco contratual quantificado |
EOF

# ─────────────────────────────────────────────────────────────
# docs/BUSINESS_PLAN.md — cenário 5/10 anos incluindo IPO
# ─────────────────────────────────────────────────────────────
cat > docs/BUSINESS_PLAN.md << 'EOF'
# Business Plan — HelioBus800 (cenário 5/10 anos)

> Aviso: números abaixo são ordem de grandeza ilustrativa para planejamento
> interno, não projeção financeira garantida. Não constitui aconselhamento
> de investimento.

## Modelo de receita
- Locação de capacidade de processamento (compute-as-a-service) por módulo
  de telhado, faturada por kW térmico/elétrico entregue
- Licenciamento de tecnologia do inverter/CDU 800VDC para terceiros (Vertiv,
  Schneider, integradores) na fase de maturidade
- Possível receita de venda de excedente energético à rede, onde regulação
  permitir

## Linha do tempo

### Anos 1-2 — Pesquisa e protótipo
- FAPESP PIPE Fase 1 → Fase 2 Indireta
- CAPEX: R$ 20-35M (conforme detalhado em conversas anteriores)
- Marco: protótipo qualificado termicamente, 1º site piloto (telhado parceiro,
  ex. ecossistema GPA) operando

### Anos 3-4 — Primeiros sites comerciais
- 3-8 módulos instalados em telhados de galpões logísticos
- Funding: FINEP/EMBRAPII para qualificação Tier III/IV + capital
  semente/Series A privado
- Marco: primeiro contrato com hyperscaler ou cliente âncora de IA/HPC

### Ano 5 — Series A/B
- Replicação do modelo em múltiplos sites/regiões
- Receita recorrente comprovada por módulo (compute-as-a-service)
- Marco: 15-30 sites ativos, início de padronização de fabricação do módulo

### Anos 6-8 — Escala e Series C
- Expansão nacional/regional (América Latina)
- Licenciamento de tecnologia para integradores
- Marco: receita recorrente em escala suficiente para sustentar expansão
  sem diluição agressiva adicional

### Anos 9-10 — IPO (cenário, não compromisso)
- Pré-requisito: receita recorrente estável, múltiplos anos de track record
  operacional, governança corporativa madura (board independente, auditoria
  externa, compliance)
- Praça: avaliar B3 (Novo Mercado) e/ou listagem dupla, dependendo do porte
  e apetite de capital internacional no momento
- Este é o horizonte mais incerto do plano — depende de condição de mercado
  de capitais na época, não apenas de execução interna

## Estrutura societária recomendada (recapitulando)
- Fundador técnico + sócio de BD/comercial + pesquisador responsável
  (vínculo acadêmico exigido pelo PIPE)
- Cap table deve reservar pool de equity para Series A/B antes de qualquer
  decisão de IPO

## Riscos principais a monitorar no BP
- Risco contratual de locação de telhado (ver docs/SITING_MODEL.md)
- Risco tecnológico: qual sabor 800VDC (Diablo vs NVIDIA) vence adoção de
  mercado — travar tarde demais atrasa certificação
- Risco regulatório: revenda de excedente energético depende de regulação
  ANEEL vigente em cada momento, sujeita a mudança
EOF

# ─────────────────────────────────────────────────────────────
# dashboard/config.production.json — config base do dashboard
# ─────────────────────────────────────────────────────────────
cat > dashboard/config.production.json << 'EOF'
{
  "environment": "production",
  "sites": [],
  "kpis_tracked": [
    "PUE", "CUE", "DCiE", "ERE",
    "conversion_efficiency_800vdc",
    "gflops_per_watt",
    "solar_generation_vs_warehouse_load",
    "capex_payback_vs_lease_term"
  ],
  "telemetry": {
    "bus_voltage_range_v": [600, 850],
    "secondary_loop_supply_temp_c": [18, 22],
    "arc_fault_detection_ms_max": 10
  },
  "alert_thresholds": {
    "dew_point_margin_c_min": 3,
    "bus_voltage_deviation_pct_max": 5
  },
  "data_sources_to_integrate": [
    "MEX BioDataCloud",
    "Global DC Sentinel",
    "VoltWise"
  ]
}
EOF

cat > dashboard/README.md << 'EOF'
# Dashboard de monitoramento — HelioBus800

Config de produção em `config.production.json`. Fundir com os apps já
existentes no ecossistema MEx antes de construir do zero:
- MEX BioDataCloud / MEX Place → base do painel principal
- Global DC Sentinel → módulo de redundância elétrica (BESS/UPS/cabine primária)
- VoltWise → módulo de gestão de cabine primária e carga reativa

Adicionar: painel por site (telhado), com geração solar em tempo real vs.
consumo do galpão hospedeiro, e status de cada módulo HelioBus800.
EOF

echo "Árvore criada com sucesso em $(pwd)"
find docs dashboard -type f | sort
