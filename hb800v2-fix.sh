#!/usr/bin/env bash
# Adiciona arquivos faltantes ao repo heliobus800 existente
set -euo pipefail
REPO="${1:-$HOME/heliobus800}"
cd "$REPO"

echo "→ Criando arquivos faltantes em $REPO"

# ── src/agents/agents_config.yaml ────────────────────────────────────────────
cat > src/agents/agents_config.yaml << 'EOF'
defaults:
  llm_backend: local
  local_model: qwen2.5-coder:0.5b
  local_host: http://localhost:11434
  api_model: claude-sonnet-4-6
  temperature: 0.1
  max_tokens: 1000
  rag_enabled: true
  rag_sources:
    - docs/ARCHITECTURE.md
    - docs/OCP_REFERENCE.md
    - docs/KPI.md
    - docs/BUSINESS_RULES.md

agents:
  jose_ceo:
    name: "José S Sobrinho"
    title: "CEO"
    layer: strategic
    llm_backend: api
    system_instruction: |
      Você é José S Sobrinho, CEO da MEx Energy e sponsor do HelioBus800.
      Foco: parcerias estratégicas, IPO B3 2030, representação institucional.
      Regra: nunca aprove investimento sem parecer do CFO.
      Se não tiver dado: "Aguardo análise do CFO/CTO antes de decidir."
    escalation_to: conselho_board
    approves: [site_investment, partnership, ipo_gate]

  gabriela_cfo:
    name: "Gabriela Santos"
    title: "CFO"
    layer: strategic
    llm_backend: api
    system_instruction: |
      Você é Gabriela Santos, CFO da MEx Energy.
      Avalia viabilidade financeira: payback < 70% do prazo de locação.
      Regra: cite docs/CAPEX.md. Se número não estiver lá: "Solicitar orçamento formal."
      Zero invenção de valores.
    escalation_to: jose_ceo
    approves: [capex_over_50k, site_go_nogo]

  bruno_cto:
    name: "Bruno Souza"
    title: "CTO"
    layer: strategic
    llm_backend: api
    system_instruction: |
      Você é Bruno Souza, CTO da MEx Energy.
      Decide arquitetura 800VDC, valida specs de inverter e CDU.
      Regra: cite docs/OCP_REFERENCE.md. Decisões de topologia são irreversíveis.
      Se spec não documentada: "Aguardar dados de bancada."
    escalation_to: jose_ceo
    approves: [topology_decision, agent_system_instruction]

  victor_hvdc:
    name: "Victor Fernandes"
    title: "Engenheiro HVDC"
    layer: tactical
    llm_backend: local
    system_instruction: |
      Você é Victor Fernandes, especialista em barramento 800VDC.
      Responde sobre proteção de arco DC, conectores, bus bar.
      Regra: cite IEC/UL/OCP. Se não souber: "Necessário teste de bancada."
    escalation_to: bruno_cto
    rag_sources: [docs/OCP_REFERENCE.md, docs/ARCHITECTURE.md, src/inverter/spec.md]

  sofia_power:
    name: "Sofia Oliveira"
    title: "Eletrônica de Potência"
    layer: tactical
    llm_backend: local
    system_instruction: |
      Você é Sofia Oliveira, especialista em GaN/SiC e LLC ressonante.
      Responde sobre topologia do inverter 800VDC e componentes de potência.
      Regra: cite datasheet. Se eficiência não medida: "Confirmar com bancada."
    escalation_to: bruno_cto
    rag_sources: [src/inverter/spec.md, docs/OCP_REFERENCE.md]

  joana_dc:
    name: "Joana Shultz"
    title: "Eng. DC Distribuída"
    layer: tactical
    llm_backend: local
    system_instruction: |
      Você é Joana Shultz, especialista em liquid cooling e CDU 800VDC.
      Regra: sempre pergunte o dew point local antes de recomendar supply temp.
      Mínimo 3°C de margem sobre o dew point medido.
    escalation_to: bruno_cto
    rag_sources: [src/cdu/spec.md, docs/KPI.md]

  laura_ee:
    name: "Laura Santos"
    title: "Eficiência Energética"
    layer: operational
    llm_backend: local
    system_instruction: |
      Você é Laura Santos, monitora KPIs de eficiência de todos os módulos HB800.
      Alerte se PUE > 1.15 ou CUE > 0. Nunca invente medições — cite timestamp e fonte.
    escalation_to: rafaela_coo
    rag_sources: [docs/KPI.md, dashboard/config.production.json]

  julio_sec:
    name: "Júlio César"
    title: "Segurança da Informação"
    layer: operational
    llm_backend: api
    system_instruction: |
      Você é Júlio César, responsável por segurança e autenticação do dashboard HB800.
      Regra: nunca aceite API key hardcoded. Nunca exponha dados de clientes entre perfis.
      Cite LGPD Art. quando aplicável.
    escalation_to: pedro_clo
    approves: [new_user_permissions, api_key_rotation]

  selix_monitor:
    name: "SelixIA Monitor"
    title: "Agente Autônomo de Monitoramento"
    layer: operational
    llm_backend: local
    system_instruction: |
      Você é o SelixIA Monitor, agente autônomo do HelioBus800.
      Rastreie specs OCP/NVIDIA, alertas de KPI e editais FAPESP/FINEP.
      Regra: só cite fontes verificáveis. Se dado indisponível: "fonte não verificada."
    escalation_to: bruno_cto
    runs_every: 3600
EOF

# ── src/rag/rag_engine.py ─────────────────────────────────────────────────────
cat > src/rag/rag_engine.py << 'EOF'
"""
rag_engine.py — RAG leve sobre docs do repo (ARM64 safe, sem embeddings)
Busca por palavras-chave nos docs configurados por agente.
"""
import re
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent.parent

def load_docs(sources: list) -> str:
    chunks = []
    for s in sources:
        p = REPO_ROOT / s
        if p.exists():
            chunks.append(f"### {s}\n{p.read_text()[:2000]}")
    return "\n\n".join(chunks)

def retrieve(query: str, agent_sources: list) -> str:
    corpus = load_docs(agent_sources)
    lines = corpus.split("\n")
    keywords = set(re.findall(r'\w+', query.lower()))
    scored = [(sum(1 for k in keywords if k in l.lower()), l)
              for l in lines if l.strip()]
    scored = [(s, l) for s, l in scored if s > 0]
    scored.sort(reverse=True)
    top = [l for _, l in scored[:20]]
    return "\n".join(top) if top else "Sem contexto relevante encontrado."
EOF

# ── dashboard/auth/rbac.yaml ──────────────────────────────────────────────────
cat > dashboard/auth/rbac.yaml << 'EOF'
profiles:
  admin:
    label: "Administrador MEx"
    access: [all]
    agents_available: all
    llm_config_editable: true

  board:
    label: "Conselho / Board"
    access: [kpis_all, financial_summary, compliance_status, ipo_metrics]
    agents_available: [jose_ceo, gabriela_cfo, pedro_clo]

  ceo:
    label: "CEO"
    access: [kpis_all, financial_summary, partnerships, strategic_roadmap]
    agents_available: [jose_ceo, gabriela_cfo, pedro_clo, bruno_cto, rafaela_coo]

  cfo:
    label: "CFO"
    access: [capex_opex, payback_per_site, financial_summary, investor_dashboard]
    agents_available: [gabriela_cfo, amanda_ir]

  cto:
    label: "CTO"
    access: [technical_specs, kpis_all, ci_cd_status, agent_config]
    agents_available: [bruno_cto, victor_hvdc, sofia_power, joana_dc, selix_monitor]
    llm_config_editable: true

  coo:
    label: "COO"
    access: [operations_per_site, maintenance_schedule, iso_compliance, supply_chain]
    agents_available: [rafaela_coo, ernesto_pm, bruno_manut, laura_ee, andre_audit]

  engineer:
    label: "Engenheiro"
    access: [technical_specs, kpis_site, maintenance_schedule, ci_cd_status]
    agents_available: [victor_hvdc, sofia_power, joana_dc, laura_ee, selix_monitor]

  investor:
    label: "Investidor"
    access: [financial_summary, kpi_summary, roadmap_public, ipo_metrics]
    agents_available: [amanda_ir]
    read_only: true

  client:
    label: "Cliente / Locador de Telhado"
    access: [site_kpis_own, energy_generation_own, contract_status_own]
    agents_available: []
    read_only: true
    scope: own_site_only

  public:
    label: "Público / Visitante"
    access: [project_overview, sustainability_metrics]
    agents_available: []
    read_only: true
EOF

# ── dashboard/auth/auth.py ────────────────────────────────────────────────────
cat > dashboard/auth/auth.py << 'EOF'
"""
auth.py — JWT + RBAC para dashboard HelioBus800
Produção: integrar com Keycloak ou Auth0
"""
import os, json, hashlib, time
from pathlib import Path

RBAC_PATH = Path(__file__).parent / "rbac.yaml"
USERS_PATH = Path(__file__).parent / "users.json"
SECRET = os.environ.get("JWT_SECRET", "dev-secret-CHANGE-IN-PROD")

def hash_pw(pw: str) -> str:
    return hashlib.sha256(f"{pw}{SECRET}".encode()).hexdigest()

def load_rbac() -> dict:
    import yaml
    with open(RBAC_PATH) as f:
        return yaml.safe_load(f)

def login(username: str, password: str) -> dict | None:
    if not USERS_PATH.exists():
        return None
    users = json.loads(USERS_PATH.read_text())
    user = users.get(username)
    if not user or user["password_hash"] != hash_pw(password):
        return None
    rbac = load_rbac()
    profile = user.get("profile", "public")
    perms = rbac["profiles"].get(profile, {})
    return {
        "username": username,
        "profile": profile,
        "name": user.get("name", username),
        "agent_id": user.get("agent_id", ""),
        "access": perms.get("access", []),
        "agents_available": perms.get("agents_available", []),
        "read_only": perms.get("read_only", False),
        "llm_config_editable": perms.get("llm_config_editable", False),
        "ts": int(time.time())
    }

def create_user(username: str, password: str, profile: str,
                name: str = "", agent_id: str = "") -> bool:
    users = json.loads(USERS_PATH.read_text()) if USERS_PATH.exists() else {}
    users[username] = {"password_hash": hash_pw(password),
                       "profile": profile, "name": name, "agent_id": agent_id}
    USERS_PATH.write_text(json.dumps(users, indent=2))
    return True

if __name__ == "__main__":
    create_user("admin",    "TROQUE123", "admin",    "Administrador", "")
    create_user("jose",     "TROQUE123", "ceo",      "José S Sobrinho", "jose_ceo")
    create_user("gabriela", "TROQUE123", "cfo",      "Gabriela Santos", "gabriela_cfo")
    create_user("bruno_t",  "TROQUE123", "cto",      "Bruno Souza", "bruno_cto")
    create_user("investor1","TROQUE123", "investor", "Investidor Externo", "")
    create_user("cliente1", "TROQUE123", "client",   "GPA CD1", "")
    print("Seed criado. TROQUE AS SENHAS antes de produção!")
EOF

# ── docs/SWOT_STATUS.md ───────────────────────────────────────────────────────
cat > docs/SWOT_STATUS.md << 'EOF'
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
EOF

# ── infra/colab/train_finetune.py ─────────────────────────────────────────────
cat > infra/colab/train_finetune.py << 'EOF'
"""
Fine-tuning qwen2.5-coder:0.5b para agentes HelioBus800
Roda no Google Colab T4 (gratuito)
Após treino: baixe o .gguf e registre no Ollama do Termux

Passos:
  1. Colab > Runtime > Change runtime type > T4 GPU
  2. Cole e execute cada bloco abaixo
  3. Baixe hb800-agent-gguf/model.gguf
  4. No Termux:
       mkdir -p ~/heliobus800/models
       mv ~/downloads/model.gguf ~/heliobus800/models/
       ollama create hb800-agent -f ~/heliobus800/models/Modelfile
       ollama run hb800-agent "Qual é o PUE alvo?"
"""

INSTALL = "!pip install unsloth datasets trl -q"

LOAD = """
from unsloth import FastLanguageModel
import torch
model, tokenizer = FastLanguageModel.from_pretrained(
    "Qwen/Qwen2.5-Coder-0.5B-Instruct",
    max_seq_length=2048, dtype=torch.float16, load_in_4bit=True)
model = FastLanguageModel.get_peft_model(model, r=16,
    target_modules=["q_proj","v_proj"], lora_alpha=16,
    use_gradient_checkpointing=True)
"""

DATASET = """
from datasets import Dataset
examples = [
  {"text": "### Instrução:\\nQual é a temperatura de supply do loop?\\n### Input:\\nDew point SP verão 24°C\\n### Resposta:\\nMínimo 27°C (margem 3°C sobre dew point 24°C). Fonte: docs/KPI.md"},
  {"text": "### Instrução:\\nPUE está em 1.20. O que fazer?\\n### Input:\\nSite GPA CD1\\n### Resposta:\\nALERTA: PUE 1.20 acima do limite 1.15 (docs/KPI.md). Ação: verificar inverter, checar loop 18-22°C, auditar cargas parasitas. Escalando laura_ee."},
  {"text": "### Instrução:\\nQual topologia 800VDC escolher?\\n### Input:\\n\\n### Resposta:\\nDado não disponível — decisão BLOCKER pendente (mês 2). Opções: Diablo (OCP) vs NVIDIA monopolar. Encaminhando para bruno_cto. Fonte: docs/OCP_REFERENCE.md"},
]
dataset = Dataset.from_list(examples)
"""

TRAIN = """
from trl import SFTTrainer
from transformers import TrainingArguments
trainer = SFTTrainer(model=model, tokenizer=tokenizer,
    train_dataset=dataset, dataset_text_field="text",
    args=TrainingArguments(output_dir="./out", num_train_epochs=3,
        per_device_train_batch_size=2, fp16=True))
trainer.train()
"""

EXPORT = """
model.save_pretrained_gguf("hb800-agent-gguf", tokenizer, quantization_method="q4_k_m")
from google.colab import files
import glob
for f in glob.glob("hb800-agent-gguf/*.gguf"):
    files.download(f)
"""

MODELFILE = """
FROM ./model.gguf
SYSTEM "Agente HelioBus800 — zero alucinação, cite fontes docs/. Se incerto: 'Dado não disponível.'"
PARAMETER temperature 0.1
PARAMETER num_ctx 2048
"""
EOF

# ── .gitignore: adicionar users.json ─────────────────────────────────────────
grep -q "users.json" .gitignore 2>/dev/null || echo "dashboard/auth/users.json" >> .gitignore
grep -q "models/" .gitignore 2>/dev/null || echo "models/" >> .gitignore

# ── requirements.txt: adicionar yaml ─────────────────────────────────────────
grep -q "pyyaml" requirements.txt 2>/dev/null || echo "pyyaml>=6.0" >> requirements.txt

# ── git commit ────────────────────────────────────────────────────────────────
git add -A
git commit -m "feat(v2): agentes humanizados, RAG, RBAC auth, SWOT, Colab fine-tuning"
git push

echo ""
echo "=== ÁRVORE FINAL ==="
tree --noreport 2>/dev/null || find . -not -path './.git/*' -not -path './__pycache__/*' -type f | sort
