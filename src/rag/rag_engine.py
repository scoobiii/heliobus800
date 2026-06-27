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
