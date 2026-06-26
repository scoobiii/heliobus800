# Especificação Solar + BESS

## Objetivo
Suprir 100% da demanda do módulo HelioBus800 por energia solar + BESS,
sem gerador diesel e sem depender integralmente da rede elétrica.

## Solar (por site de telhado)
- Tecnologia: painel bifacial PERC ou HJT, inclinação otimizada por site
- Ferramenta de dimensionamento: PVGIS (já temos Solar Potential Dashboard)
- MPPT: Huawei FusionSolar, SMA ou Fronius (a avaliar disponibilidade e preço BR)
- Integração ao barramento 800VDC:
  [ ] verificar se MPPT já entrega 800VDC ou precisa de boost DC-DC adicional

## BESS (Battery Energy Storage System)
- Química: LFP (LiFeO4) — melhor ciclo de vida, menor risco térmico
- Fornecedores de referência: CATL, BYD, Sungrow
- Autonomia mínima: cobrir demanda noturna do rack + margem para dias nublados
  (definir por site — variável por carga do rack e perfil solar local)
- Integração ao barramento:
  [ ] BESS nativo 800VDC sem conversão AC intermediária (ponto de inovação)
  [ ] BMS (Battery Management System) com comunicação CAN/Modbus para o dashboard

## Diagrama unifilar (a criar em Fase 1)
```
[Painel FV] ──MPPT──► [800VDC barramento]
[BESS LFP] ──BMS────► [800VDC barramento]
[Rede elétrica] ──retificador (backup)──► [800VDC barramento]
                                                  │
                                    [Inverter/Compressor HB800]
                                                  │
                                             [CDU + Racks]
```

## Itens a detalhar (Fase 1)
- [ ] Dimensionamento solar por site piloto (PVGIS + dados INMET)
- [ ] Capacidade BESS por site (kWh, ciclos/ano, temperatura de operação)
- [ ] Protocolo de integração BESS → barramento 800VDC (CAN/Modbus/TCP)
- [ ] Retificador MV de backup (35kVAC → 800VDC) e capacidade nominal
- [ ] Plano de proteção e seccionamento do barramento DC
