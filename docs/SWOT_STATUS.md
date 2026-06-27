# SWOT + Status — HelioBus800

## Forças (nota 1-3)
| Nota | Item |
|------|------|
| 3 | Nicho sem concorrente direto: inverter 800VDC nativo + anti-orvalho tropical |
| 3 | Modelo telhado: zero CAPEX de terreno/obra civil |
| 3 | ESG zero diesel — pré-requisito de hyperscalers |
| 2 | Ecossistema MEx existente (ET-CCNFT, apps, time documentado) |
| 2 | Repo + CI/CD + 7 testes passando |

## Fraquezas
| Nota | Item |
|------|------|
| 1 | Zero hardware — bancada não iniciada |
| 1 | BLOCKER topologia (Diablo vs NVIDIA) pendente |
| 1 | Time físico não contratado — agentes são IA ainda |
| 1 | PIPE FAPESP não submetido |
| 2 | Risco contratual de locação de telhado |
| 2 | ARM/Termux limita compute pesado |

## Oportunidades
| Nota | Item |
|------|------|
| 3 | Mercado 800VDC explodindo — Vertiv/Eaton/NVIDIA todos chegando 2026-27 |
| 3 | Hyperscalers expandindo no Brasil (CoreWeave, Lambda, Oracle) |
| 3 | FAPESP PIPE + FINEP + EMBRAPII disponíveis e alinhados |
| 2 | GPA CD1 e galpões logísticos mapeados como sites piloto |
| 2 | Si-28 quântico abrindo nova plataforma de hospedagem |

## Ameaças
| Nota | Item |
|------|------|
| 2 | Vertiv/Eaton chegam antes com produto 800VDC |
| 2 | Mudança regulatória ANEEL (excedente solar) |
| 2 | Selic alta eleva custo de capital e payback |
| 2 | NVIDIA monopolar pode tornar Diablo obsoleto |
| 1 | Mercado pode não estar maduro ainda |

## Onde estamos (% real)

```
Fase 1 Pesquisa/PoC        ████░░░░░░  35%
  ✅ Spec documentada
  ✅ Repo + CI/CD + testes
  ✅ Agentes configurados
  ❌ BLOCKER topologia
  ❌ Bancada física
  ❌ PIPE submetido
  ❌ Time físico

Fase 2 Protótipo           ░░░░░░░░░░   0%
Fase 3 Qualificação        ░░░░░░░░░░   0%
Fase 4 Escala              ░░░░░░░░░░   0%
Fase 5 IPO                 ░░░░░░░░░░   0%

OVERALL ██░░░░░░░░  ~7%
```

## Onde vamos e quando

| Marco | Prazo | Pré-requisito |
|-------|-------|---------------|
| BLOCKER topologia resolvida | Mês 2 | Reunião CTO + HVDC |
| PIPE Fase 1 submetido | Mês 3 | PI acadêmico + âncora R$100k |
| Bancada inverter funcionando | Mês 8 | PIPE aprovado + lab |
| 1º site piloto (telhado) | Mês 18 | Contrato de locação |
| Tier III completo | Mês 30 | 3-5 sites com dados |
| 1º contrato hyperscaler | Mês 36 | Tier IV + BD ativo |
| Series A | Ano 4 | Receita recorrente |
| IPO B3 Novo Mercado | Ano 9-10 | Board + auditoria + 3yr track |

## Os próximos 90 dias decidem
Sem resolver os 4 itens abaixo, a janela fecha antes do protótipo existir:
1. ❌ Travar topologia (Diablo vs NVIDIA) — BLOCKER
2. ❌ Submeter PIPE Fase 1 — funding
3. ❌ Negociar 1º telhado (due diligence GPA CD1) — site
4. ❌ Formalizar ao menos 2 pessoas físicas no time técnico — execução
