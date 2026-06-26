# Tiers de Disponibilidade

## Classificação oficial Uptime Institute (existe até Tier IV)

| Tier | Disponibilidade | Redundância | Manutenção    |
|------|----------------|-------------|---------------|
| I    | 99.671%        | Sem         | Exige downtime|
| II   | 99.741%        | Componentes | Exige downtime|
| III  | 99.982%        | Concorrente | Sem downtime  |
| IV   | 99.995%        | 2N / falha  | Tolerante     |

## "Tier V" — não é certificação oficial
Quando cliente pede "Tier 5", mapear para:
- Tier IV (elétrico/térmico) + redundância geográfica entre 2+ sites HB800
- SLA contratual customizado com cliente
- Cláusula de soberania de dados se exigido

**Não gastar CAPEX perseguindo Tier V sem definição contratual.**

## Posição HelioBus800
- Fase 1-2: qualificação Tier III (mínimo viável)
- Fase 3+: qualificação Tier IV (pré-requisito hyperscaler)
- "Tier V": oferecer como SLA contratual multi-site, não certificação técnica

## Referências normativas
- ANSI/TIA-942-B (data center infrastructure)
- IEC 62040-3 (UPS classification)
- ISO/IEC 22237 (data center facilities)
- Uptime Institute Tier Certification Process
