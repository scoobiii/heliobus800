#!/usr/bin/env bash
# heliobus800-bootstrap.sh
# Roda direto no Termux (~) ou no proot-distro Ubuntu
# Uso: bash heliobus800-bootstrap.sh
set -euo pipefail

REPO_DIR="$HOME/heliobus800"
TAR="$HOME/downloads/heliobus800-repo-init.tar.gz"

echo "=== HelioBus800 Bootstrap ==="

# 1. detecta ambiente
if [ -d /data/data/com.termux ]; then
  ENV=termux
else
  ENV=linux
fi
echo "→ Ambiente: $ENV"

# 2. instala dependências
if [ "$ENV" = "termux" ]; then
  pkg update -y
  pkg install -y git make gh curl tar python nodejs-lts
else
  apt-get update -y
  apt-get install -y git make gh curl tar python3 nodejs
fi

# 3. cria o diretório do repo se não existir
mkdir -p "$REPO_DIR"
echo "→ Repo dir: $REPO_DIR"

# 4. descompacta o tar.gz se existir, senão clona do zero
if [ -f "$TAR" ]; then
  echo "→ Descompactando $TAR"
  tar xzf "$TAR" -C "$REPO_DIR" --strip-components=1
else
  echo "→ tar.gz não encontrado em $TAR"
  echo "   Coloque o arquivo em ~/downloads/ e rode novamente"
  echo "   OU defina REPO_URL e o script clona direto:"
  echo "   REPO_URL=https://github.com/scoobiii/heliobus800.git bash $0"
  if [ -n "${REPO_URL:-}" ]; then
    git clone "$REPO_URL" "$REPO_DIR"
  else
    exit 1
  fi
fi

# 5. entra no repo
cd "$REPO_DIR"

# 6. git init se ainda não for um repo
if [ ! -d .git ]; then
  git init
  git add -A
  git commit -m "chore: init HelioBus800 repo"
fi

# 7. gh auth check (não bloqueia se não autenticado ainda)
if gh auth status >/dev/null 2>&1; then
  echo "→ gh autenticado"
else
  echo "⚠ gh não autenticado — rode 'gh auth login' depois para habilitar PR"
fi

# 8. rodar o pipeline (sem make, usa bash direto)
echo "→ Rodando pipeline (build + test)"
if [ -f requirements.txt ]; then
  python3 -m pip install --break-system-packages -r requirements.txt || true
  python3 -m pytest || true
fi
if [ -f package.json ]; then
  npm install && npm test --if-present || true
fi

# 9. resumo final
echo ""
echo "=== Pronto ==="
find "$REPO_DIR" -not -path '*/.git/*' -type f | sort
echo ""
echo "Próximos passos:"
echo "  gh auth login                   # autenticar GitHub CLI"
echo "  cd ~/heliobus800"
echo "  bash heliobus800-automation.sh run   # commit + PR automático"
