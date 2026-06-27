# Regras de Negócio — MEx Energy / HelioBus800

## Camada Estratégica (Board + C-Level)

### BR-S01: Aprovação de site
- Nenhum módulo HB800 é instalado sem aprovação simultânea de:
  CFO (payback < 70% do prazo do contrato de locação) +
  CLO (contrato de locação revisado) +
  COO (due diligence estrutural aprovada)

### BR-S02: Decisão de topologia de barramento
- Diablo vs NVIDIA monopolar: aprovada pelo CTO com parecer técnico de
  victor_hvdc e sofia_power. Irreversível após spec de conectores.

### BR-S03: IPO readiness gate
- B3 Novo Mercado exige: 3+ anos de receita recorrente, board independente,
  auditoria Big Four, free float mínimo 25%. Gate revisado pelo CFO e CLO
  anualmente a partir do ano 6.

### BR-S04: Compliance de certificação
- Qualquer claim de "Tier V" só pode ser feito após definição contratual
  com o cliente e validação do CLO. Comunicações de marketing (CMO)
  devem ter aprovação do CLO para uso de termos de certificação.

## Camada Tática (Management)

### BR-T01: Sprint de engenharia
- Toda sprint começa com Engineering Prompt atualizado (ver docs/ENGINEERING_PROMPT.md)
- Definition of Done obrigatório: spec documentada + plano de teste +
  rastreamento de CAPEX atualizado + issue fechada no GitHub

### BR-T02: Auditoria ISO
- Auditoria interna ISO 9001/14001/50001 a cada 6 meses (andre_audit)
- Não conformidades classificadas P0/P1/P2 com prazo de resolução

### BR-T03: Controle de KPIs
- laura_ee publica relatório semanal de PUE/CUE/DCiE por site
- Alerta automático se PUE > 1,15 ou CUE > 0 (qualquer uso de diesel)

### BR-T04: Gestão financeira
- gabriela_cfo valida todo CAPEX > R$50k antes de compromisso
- OPEX mensal consolidado por site reportado ao Board mensalmente

## Camada Operacional

### BR-O01: Manutenção preventiva
- PMOC (Plano de Manutenção Operação e Controle) por módulo
- Frequência: mensal para CDU, trimestral para inverter, semestral para BESS
- Responsável: bruno_manut

### BR-O02: Segurança da informação
- Todas as API keys em Secret Manager (nunca hardcoded)
- Auth dashboard: JWT + RBAC por perfil (ver dashboard/auth/)
- LGPD: dados de clientes nunca expostos a agentes de outras camadas
  sem consentimento explícito (julio_sec valida)

### BR-O03: Onboarding de usuário/agente
- Novo usuário: isabela_hr cria perfil + julio_sec define permissões
- Novo agente: bruno_cto aprova system instruction + fine-tuning dataset

### BR-O04: Controle de alucinação de agentes
- Todo agente opera com RAG sobre base de conhecimento curada (ver src/rag/)
- Fallback obrigatório: se confiança < threshold, agente responde
  "não tenho dados suficientes — consultar [agente responsável]"
- Proibido: agentes inventarem KPIs, normas, valores financeiros ou
  especificações técnicas não documentadas no repo

## Processos Free Odoo (módulos recomendados)

| Processo | Módulo Odoo | Agente responsável |
|---|---|---|
| CRM / Clientes | CRM | amanda_ir, ana_rodrigues |
| Projetos / Sprints | Project + Timesheet | ernesto_pm |
| Financeiro | Accounting | gabriela_cfo |
| RH / Agentes | Employees + Recruitment | isabela_hr |
| Qualidade / ISO | Quality | andre_audit |
| Manutenção | Maintenance (PMOC) | bruno_manut |
| Compras / BOM | Purchase + Inventory | rafaela_coo |
| Assinatura de documentos | Sign | pedro_clo |
