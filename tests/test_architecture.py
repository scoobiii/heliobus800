"""
tests/test_architecture.py — smoke test da árvore completa v2
"""
import os
ROOT = os.path.join(os.path.dirname(__file__), '..')
REQUIRED = [
    "README.md", "Makefile", "requirements.txt",
    "docs/ENGINEERING_PROMPT.md", "docs/ARCHITECTURE.md",
    "docs/OCP_REFERENCE.md", "docs/SITING_MODEL.md",
    "docs/TIER_CERTIFICATION.md", "docs/KPI.md",
    "docs/CAPEX.md", "docs/ROADMAP.md", "docs/BUSINESS_PLAN.md",
    "docs/BUSINESS_RULES.md", "docs/TEAM_AGENTS.md", "docs/SWOT_STATUS.md",
    "dashboard/config.production.json",
    "dashboard/auth/rbac.yaml", "dashboard/auth/auth.py",
    "src/inverter/spec.md", "src/cdu/spec.md",
    "src/solar_bess/spec.md", "src/monitoring/agent.py",
    "src/agents/agents_config.yaml",
    "src/llm/llm_router.py",
    "src/rag/rag_engine.py",
    "infra/Dockerfile",
    "infra/colab/train_finetune.py",
]
def test_required_files_exist():
    missing = [f for f in REQUIRED if not os.path.exists(os.path.join(ROOT, f))]
    assert missing == [], f"Arquivos faltando: {missing}"
