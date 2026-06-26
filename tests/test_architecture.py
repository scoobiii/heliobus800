"""
tests/test_architecture.py — Valida que todos os arquivos obrigatórios
do repo estão presentes (smoke test da árvore).
"""
import os

ROOT = os.path.join(os.path.dirname(__file__), '..')

REQUIRED = [
    "README.md",
    "Makefile",
    "docs/ENGINEERING_PROMPT.md",
    "docs/ARCHITECTURE.md",
    "docs/OCP_REFERENCE.md",
    "docs/SITING_MODEL.md",
    "docs/TIER_CERTIFICATION.md",
    "docs/KPI.md",
    "docs/CAPEX.md",
    "docs/ROADMAP.md",
    "docs/BUSINESS_PLAN.md",
    "dashboard/config.production.json",
    "src/inverter/spec.md",
    "src/cdu/spec.md",
    "src/solar_bess/spec.md",
    "src/monitoring/agent.py",
    "infra/Dockerfile",
]

def test_required_files_exist():
    missing = []
    for f in REQUIRED:
        path = os.path.join(ROOT, f)
        if not os.path.exists(path):
            missing.append(f)
    assert missing == [], f"Arquivos faltando: {missing}"
