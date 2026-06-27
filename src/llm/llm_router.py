"""
llm_router.py — Roteador de LLM configurável por agente
Suporta: Claude API (Anthropic) | Ollama local (qwen2.5-coder:0.5b)
Configurado pelo admin via env vars ou agents_config.yaml
Zero alucinação: temperature baixa + RAG obrigatório
"""

import os
import json
import yaml
import requests
from pathlib import Path

CONFIG_PATH = Path(__file__).parent.parent / "agents" / "agents_config.yaml"

def load_config() -> dict:
    with open(CONFIG_PATH) as f:
        return yaml.safe_load(f)

def query_claude(prompt: str, system: str, model: str = "claude-sonnet-4-6",
                 max_tokens: int = 1000, temperature: float = 0.1) -> str:
    """Chama Claude API via Anthropic."""
    api_key = os.environ.get("ANTHROPIC_API_KEY", "")
    if not api_key:
        raise ValueError("ANTHROPIC_API_KEY não configurada — use Ollama local ou configure a key")
    headers = {
        "x-api-key": api_key,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json"
    }
    body = {
        "model": model,
        "max_tokens": max_tokens,
        "temperature": temperature,
        "system": system,
        "messages": [{"role": "user", "content": prompt}]
    }
    r = requests.post("https://api.anthropic.com/v1/messages",
                      headers=headers, json=body, timeout=30)
    r.raise_for_status()
    return r.json()["content"][0]["text"]

def query_ollama(prompt: str, system: str,
                 model: str = "qwen2.5-coder:0.5b",
                 host: str = "http://localhost:11434",
                 temperature: float = 0.1) -> str:
    """Chama Ollama local — ARM64 compatível (Termux/proot)."""
    body = {
        "model": model,
        "prompt": f"{system}\n\n{prompt}",
        "stream": False,
        "options": {"temperature": temperature}
    }
    r = requests.post(f"{host}/api/generate", json=body, timeout=60)
    r.raise_for_status()
    return r.json()["response"]

def query_agent(agent_id: str, prompt: str, rag_context: str = "") -> str:
    """
    Consulta um agente pelo ID definido em agents_config.yaml.
    Injeta contexto RAG no system instruction automaticamente.
    """
    cfg = load_config()
    defaults = cfg.get("defaults", {})
    agent = cfg["agents"].get(agent_id)
    if not agent:
        raise ValueError(f"Agente '{agent_id}' não encontrado em agents_config.yaml")

    backend = agent.get("llm_backend", defaults.get("llm_backend", "local"))
    system = agent["system_instruction"].strip()

    # injeta contexto RAG se disponível
    if rag_context:
        system += f"\n\n## Contexto técnico (RAG)\n{rag_context}"

    # anti-alucinação: adiciona instrução padrão de incerteza
    system += (
        "\n\n## Regra de ouro\n"
        "Se não tiver dado suficiente para responder com certeza, diga exatamente: "
        "'Dado não disponível — fonte: [especificar]. Encaminhando para [agente].' "
        "NUNCA invente valores, normas, KPIs ou especificações técnicas."
    )

    temperature = agent.get("temperature", defaults.get("temperature", 0.1))
    max_tokens = agent.get("max_tokens", defaults.get("max_tokens", 1000))

    if backend == "api":
        model = agent.get("api_model", defaults.get("api_model", "claude-sonnet-4-6"))
        return query_claude(prompt, system, model=model,
                            max_tokens=max_tokens, temperature=temperature)
    else:
        model = agent.get("local_model", defaults.get("local_model", "qwen2.5-coder:0.5b"))
        host = agent.get("local_host", defaults.get("local_host", "http://localhost:11434"))
        return query_ollama(prompt, system, model=model,
                            host=host, temperature=temperature)

if __name__ == "__main__":
    # Teste rápido — não precisa de API key se usar local
    print("Testando agente selix_monitor (local)...")
    try:
        r = query_agent(
            "selix_monitor",
            "Qual é o status atual do barramento 800VDC no projeto HelioBus800?",
            rag_context="PUE atual: 1.12. Tensão barramento: 800V. Temp supply: 20°C."
        )
        print(r)
    except Exception as e:
        print(f"Erro (esperado se Ollama não estiver rodando): {e}")
