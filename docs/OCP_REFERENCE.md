# Referência OCP 800VDC + NVIDIA (jun/2026)

## Diablo (OCP — Google/Meta/Microsoft/Amazon)
- Rack sidecar desagregado, distribuição 48VDC → ±400VDC ou 800VDC
- Suporta 100kW a 1MW por rack
- Meta: 600-800kW, cabos HVDC 50kW + whips AC 200A
- Google: 900kW realocando espaço de BBU/supercap para PSUs
- Amazon: 800kW a ±400V | Microsoft: adoção mais lenta

## NVIDIA Monopolar 800V
- 660kW/rack, amostras mid-2026, VR Ultra (líquido) fim/2026
- Deploy em massa Rubin Ultra Kyber: 2027
- Bloco de 17.5MW: 5x retificadores MV 3.5MW em 5-para-fazer-4
- 35kVAC → 800VDC → barramento DC centralizado 5000A
- Estágio único LLC ressonante 64:1 → chip direto
- Corte ~45% de cobre vs. arquitetura AC tradicional
- Eficiência: ~83% → 92%+ ponta-a-ponta

## CDU Deschutes (referência)
- ~2MW de carga térmica
- Capacidade hidráulica: ~500GPM a 80-90psi

## Players de ecossistema
Vertiv, Eaton, Foxconn, CoreWeave, Lambda, Nebius, Flex,
Hitachi, Schneider, Siemens, ST Micro, TI, Heron Power

## Especificação técnica do barramento (a detalhar por fase)
- [ ] Topologia de bus bar (bipolar vs. monopolar)
- [ ] Seção transversal dos condutores (A para 5000A DC)
- [ ] Conectores qualificados para 800VDC DC (não AC!)
- [ ] Proteção de arco DC: detecção algoritmo + hardware <10ms
- [ ] Aterramento e isolamento (IEC 61439, UL 508A adaptado DC)
- [ ] Certificação OCP: processo de submissão de especificação
