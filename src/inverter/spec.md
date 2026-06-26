# Especificação do Inverter/Compressor 800VDC

## Status: RASCUNHO — aguardando decisão Diablo vs NVIDIA (BLOCKER)

## Topologia candidata
- GaN/SiC half-bridge LLC ressonante, single-stage
- Entrada: 600-850VDC (barramento 800VDC)
- Saída: tensão e corrente adequadas para acionamento do compressor de loop
- Eficiência alvo: >96% no ponto de operação nominal

## Proteções obrigatórias
- Detecção de arco DC: algoritmo de detecção + hardware de desconexão <10ms
- Sobretensão / subtensão no barramento (faixa 600-850V)
- Sobrecorrente e curto-circuito DC
- Proteção térmica do inverter (IGBT/GaN junction temp)

## Parâmetros de projeto a definir (Fase 1)
- [ ] Potência nominal do compressor de loop por rack
- [ ] Tensão de saída do inverter para o motor do compressor
- [ ] Frequência de chaveamento (GaN permite >100kHz)
- [ ] Dimensionamento do bus capacitor (impacto em ripple do barramento 800VDC)
- [ ] Esquema de controle: gate driver + DSP (ex: TI C2000 ou STM32)

## Componentes de referência (a validar com BOM real)
- GaN: GaN Systems GS66516B ou TI LMG3522R030
- SiC (alternativo): Wolfspeed C3M0065090K
- Gate driver: Silicon Labs SI8271
- DSP: TI TMS320F28379D (C2000)
- Capacitor DC bus: TDK B25655 (film, rated 900VDC)
