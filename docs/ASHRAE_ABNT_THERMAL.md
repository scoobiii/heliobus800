# Normas Térmicas — ASHRAE + ABNT para HelioBus800

## Referências normativas

| Norma | Escopo |
|---|---|
| ASHRAE TC 9.9 — Thermal Guidelines for Data Processing Environments (2021) | Classes de ambiente A1-A4, limites de temperatura e umidade |
| ASHRAE 55-2020 | Conforto térmico (aplicável a salas de operação) |
| ASHRAE 62.1-2022 | Qualidade do ar interior |
| ABNT NBR 16665:2017 | Centros de processamento de dados — requisitos para infraestrutura física |
| ABNT NBR 16401 | Instalações de ar condicionado — sistemas centrais |
| IEC 62040-1 | UPS — requisitos de segurança |
| ANSI/TIA-942-B | Infraestrutura de telecomunicações para data centers |

## Classes ASHRAE TC 9.9 — HelioBus800 adota A1

### Tabela comparativa de classes

| Classe | Temp. seca (°C) | Dew point máx (°C) | UR máx (%) | Aplicação típica |
|---|---|---|---|---|
| **A1** (adotada) | **15–32** | **17** | **50%** | DC enterprise, servidores de missão crítica |
| A2 | 10–35 | 21 | 80% | DC comercial geral |
| A3 | 5–40 | 24 | 85% | Ambientes menos controlados |
| A4 | 5–45 | 24 | 90% | Extremo — uso industrial |

## Ambiente FECHADO e SELADO — impacto no dew point

Num DC com envelope selado e HVAC interno:
- O ar externo (dew point SP verão: 22-24°C) **não entra diretamente**
- O dew point interno é controlado pelo sistema HVAC de precisão
- **Meta interna ASHRAE A1**: dew point interno ≤ 17°C (UR ≤ 50% a 24°C)
- **Na prática com controle ativo**: dew point interno de 8-14°C é rotineiro

### Consequência para o loop de liquid cooling

| Parâmetro | Sem norma (stub incorreto) | Com ASHRAE A1 (correto) |
|---|---|---|
| Dew point referência | 22°C (externo SP) | 8-14°C (interno controlado) |
| Supply mínimo CDU | 25°C | **15-17°C** (margem 3°C sobre dp interno) |
| Margem de segurança | 3°C | 3°C (mesmo critério, dew point diferente) |
| Risco de condensação | Alto (supply 20 < dp 22) | **Baixo** (supply 18-20 >> dp 8-14) |

## Conclusão para o projeto

Supply de 18-22°C **é seguro** em ambiente fechado com HVAC de precisão
controlando UR interna ≤ 50%, pois o dew point interno ficará em 8-13°C —
margem de 5-12°C acima do mínimo de 3°C exigido.

O monitoramento deve medir o **dew point interno** (sensor dentro do DC),
não o dew point externo (dados INMET/climatológicos).

## Requisitos de instrumentação (ABNT NBR 16665 + ASHRAE)

| Sensor | Localização | Frequência de leitura | Alerta |
|---|---|---|---|
| Temperatura de bulbo seco | Entrada e saída de cada rack | 1 min | > 32°C (ASHRAE A1) |
| Temperatura de supply CDU | Manifold de distribuição | 30 s | < 15°C ou > 22°C |
| Umidade relativa | 4 pontos no ambiente | 5 min | > 50% UR |
| Dew point calculado | Derivado de T + UR | 5 min | > 17°C interno |
| Tensão barramento 800VDC | PDU principal | 1 s | < 600V ou > 850V |
| Temperatura de return CDU | Manifold de retorno | 30 s | > 45°C |

## Fórmula de cálculo de dew point (Magnus aproximado)

```python
def dew_point(temp_c: float, rh_pct: float) -> float:
    """
    Fórmula de Magnus aproximada — precisão ±0.35°C para 0-60°C, UR 1-100%
    Referência: ASHRAE Fundamentals Handbook 2021, Cap. 1
    """
    import math
    a, b = 17.625, 243.04  # coeficientes Magnus para água
    gamma = math.log(rh_pct / 100) + (a * temp_c) / (b + temp_c)
    return (b * gamma) / (a - gamma)

# Exemplo: ambiente DC a 24°C com UR 45%
# dew_point(24, 45) → ~11.6°C → supply mínimo: 14.6°C → supply 18°C tem 6.4°C de margem ✅
```
