"""
rag_loader.py — Carrega e injeta contexto RAG nos agentes
Fontes: docs/ do repo + dados ao vivo (ANEEL, INMET, BCB)
ARM64 compatível (Termux/proot), sem dependências pesadas
"""
import os
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent.parent

RAG_SOURCES = [
    "docs/ARCHITECTURE.md", "docs/OCP_REFERENCE.md", "docs/KPI.md",
    "docs/BUSINESS_RULES.md", "docs/CAPEX.md", "docs/ROADMAP.md",
    "src/inverter/spec.md", "src/cdu/spec.md", "src/solar_bess/spec.md",
]

def load_context(agent_id: str = None, max_chars: int = 4000) -> str:
    """Carrega contexto RAG do repo para injetar no system instruction."""
    chunks = []
    for src in RAG_SOURCES:
        path = REPO_ROOT / src
        if path.exists():
            text = path.read_text(encoding="utf-8")[:max_chars // len(RAG_SOURCES)]
            chunks.append(f"### {src}\n{text}")
    return "\n\n".join(chunks)
