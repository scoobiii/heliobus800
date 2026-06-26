# Modelo de Siting — Telhado de Galpão Logístico

## Lógica
Galpões logísticos têm grande área de telhado e baixo consumo elétrico
(iluminação, esteiras, pequena refrigeração). A diferença entre potencial
de geração solar e consumo do galpão é "capacidade ociosa" para o módulo HB800.

## Dimensionamento por site

| Parâmetro                    | Faixa típica            |
|------------------------------|-------------------------|
| Área de telhado disponível   | 20.000–50.000 m²        |
| Potencial solar instalável   | 1–5 MWp                 |
| Consumo elétrico do galpão   | 200–800 kW (baixo)      |
| Sobra disponível para HB800  | 500kW–4MW (por site)    |
| Tamanho módulo HB800 piloto  | dimensionado pela sobra |

## Vantagens vs. DC tradicional
- Zero custo de terreno/obra civil de data center
- CAPEX de infraestrutura civil já amortizado pelo galpão
- Escala horizontal (mais sites) vs. vertical (rack maior)
- Módulo plug-and-play: skid/container com 800VDC+CDU+rack

## Due diligence por candidato a site
- [ ] Capacidade estrutural do telhado (carga painéis + skid)
- [ ] Contrato de locação: prazo mínimo para payback do módulo
- [ ] Distância até backbone de fibra (latência para workload AI)
- [ ] Carga elétrica atual real do galpão (não só área de telhado)
- [ ] Acesso para manutenção do skid e CDU
- [ ] Restrições do IPTU/AVCB (uso misto no galpão)

## Sites candidatos prioritários (ecossistema MEx)
- GPA CD1 — relação comercial existente, dados de consumo disponíveis
- Outros CDs mapeados no Solar & BESS Pitch Deck existente

## Risco principal
Locação de telhado = risco contratual: exigir cláusula de portabilidade
do módulo (skid transportável) e prazo mínimo alinhado ao payback do CAPEX.
