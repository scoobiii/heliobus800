#!/usr/bin/env bash
# heliobus800-gitsetup.sh
# 1. Configura identidade git
# 2. Gera chave SSH se não existir
# 3. Faz commit local e testa
# 4. Instrui como adicionar a chave no GitHub antes do push
set -euo pipefail

REPO_DIR="$HOME/heliobus800"
GIT_NAME="${GIT_NAME:-scoobiii}"
GIT_EMAIL="${GIT_EMAIL:-seu@email.com}"  # altere aqui ou exporte GIT_EMAIL=

echo "=== HelioBus800 — Git Setup + Teste Local ==="

# ── 1. Identidade global
git config --global user.name  "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main
echo "→ Identidade: $GIT_NAME <$GIT_EMAIL>"

# ── 2. Chave SSH — gera só se não existir
KEY="$HOME/.ssh/id_ed25519"
if [ ! -f "$KEY" ]; then
  mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$KEY" -N ""
  echo "→ Chave SSH gerada: $KEY"
else
  echo "→ Chave SSH já existe: $KEY"
fi

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║  CHAVE PÚBLICA — copie e adicione no GitHub         ║"
echo "║  https://github.com/settings/keys  → New SSH key   ║"
echo "╚══════════════════════════════════════════════════════╝"
cat "$KEY.pub"
echo ""

# ── 3. Verifica se GitHub já aceita a chave (não bloqueia)
echo "→ Testando conexão SSH com GitHub..."
ssh -T git@github.com -o StrictHostKeyChecking=accept-new 2>&1 || true

# ── 4. Entra no repo e faz commit inicial local
cd "$REPO_DIR"

# garante branch main
git checkout -b main 2>/dev/null || git checkout main

# commita tudo localmente
git add -A
if git diff --cached --quiet; then
  echo "→ Nada novo para commitar (working tree limpo)"
else
  git commit -m "chore: init HelioBus800 — bootstrap via heliobus800-gitsetup.sh"
  echo "→ Commit local feito"
fi

# ── 5. Teste local: valida estrutura mínima
echo ""
echo "=== Teste local da árvore ==="
REQUIRED=(
  "docs/ENGINEERING_PROMPT.md"
  "docs/ARCHITECTURE.md"
  "docs/OCP_REFERENCE.md"
  "docs/BUSINESS_PLAN.md"
  "docs/CAPEX.md"
  "docs/ROADMAP.md"
  "docs/SITING_MODEL.md"
  "docs/TIER_CERTIFICATION.md"
  "docs/KPI.md"
  "dashboard/config.production.json"
  "Makefile"
)
ALL_OK=true
for f in "${REQUIRED[@]}"; do
  if [ -f "$f" ]; then
    echo "  ✓ $f"
  else
    echo "  ✗ FALTA: $f"
    ALL_OK=false
  fi
done

echo ""
if $ALL_OK; then
  echo "✓ Todos os arquivos presentes — repo local OK"
else
  echo "✗ Arquivos faltando — rode heliobus800-init-tree.sh primeiro"
  exit 1
fi

# ── 6. Log local
echo ""
echo "=== Git log local ==="
git log --oneline -5

# ── 7. Instruções de push via SSH
echo ""
echo "=== Próximos passos para subir no GitHub ==="
echo ""
echo "1. Crie o repo VAZIO em: https://github.com/new"
echo "   Nome: heliobus800   Visibilidade: Public   SEM README/gitignore"
echo ""
echo "2. Adicione o remote SSH:"
echo "   git remote add origin git@github.com:scoobiii/heliobus800.git"
echo ""
echo "3. Push:"
echo "   git push -u origin main"
echo ""
echo "4. Para PRs automáticos depois:"
echo "   gh auth login --git-protocol ssh"
echo "   bash heliobus800-automation.sh watch"
