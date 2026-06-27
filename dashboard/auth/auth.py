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
