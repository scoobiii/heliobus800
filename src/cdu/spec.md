# Especificação do CDU — Cooling Distribution Unit

## Referência de mercado
- Deschutes (OCP): ~2MW térmico, ~500GPM a 80-90psi
- Vertiv portfólio 800VDC: H2/2026
- Eaton arquitetura de referência: desde out/2025

## Parâmetros do loop secundário (anti-orvalho tropical)
- Temperatura de supply: 18-22°C
  (margem mínima de 3°C acima do dew point local)
- Dew point SP verão: ~22-24°C → supply MÍNIMO: 25°C
  (ajustar conforme dados INMET históricos do site)
- Temperatura de return: a determinar por carga térmica do rack
- Fluido: água glicolada (proteção contra corrosão + inibidor)

## Dimensionamento por módulo/site
- Carga térmica por rack: até 1MW (GPU/CPU) + margem
- Rack quântico (Si-28): NÃO incluso no loop — criostato separado
- Rack fotônico: incluso, carga menor (a caracterizar)

## Parâmetros hidráulicos (a validar por site)
- Vazão: dimensionar para carga térmica máxima do site
- Pressão: mínimo 80psi no manifold de distribuição
- Perda de carga: a mapear por layout de rack e comprimento de tubulação

## Itens de projeto a detalhar (Fase 1-2)
- [ ] Seleção de chiller (scroll ou centrífugo nativo 800VDC?)
- [ ] Manifold de distribuição por rack (quick-connect qualificado)
- [ ] Sensores de temperatura + pressão + vazão (4-20mA ou Modbus)
- [ ] Integração com dashboard de monitoramento (ver dashboard/)
- [ ] Plano de prevenção de condensação (sensor de dew point por rack)
