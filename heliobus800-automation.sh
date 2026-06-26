#!/usr/bin/env bash
# heliobus800-automation.sh
# Pipeline para Termux ou proot-distro (Ubuntu/Debian dentro do Termux)
# Projeto: HelioBus800 — DC liquid cooling 800VDC + HVAC solar+BESS, zero diesel
#
# Uso:
#   ./heliobus800-automation.sh setup     -> instala dependências (1x)
#   ./heliobus800-automation.sh run       -> roda o pipeline completo 1x
#   ./heliobus800-automation.sh watch     -> roda em loop (daemon simples)
#
# Requer: gh CLI autenticado (gh auth login) e o repo já clonado em $REPO_DIR

set -euo pipefail

REPO_DIR="${REPO_DIR:-$HOME/heliobus800}"
REPO_URL="${REPO_URL:-}"          # ex: https://github.com/seu-usuario/heliobus800.git
BRANCH_PREFIX="${BRANCH_PREFIX:-auto}"
DEFAULT_BASE_BRANCH="${DEFAULT_BASE_BRANCH:-main}"
LOG_FILE="$HOME/heliobus800-automation.log"
INTERVAL_SECONDS="${INTERVAL_SECONDS:-3600}"   # 1h entre ciclos no modo watch

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

detect_env() {
  if command -v proot-distro >/dev/null 2>&1; then
    echo "termux-with-proot"
  elif [ -d /data/data/com.termux ]; then
    echo "termux"
  else
    echo "linux"
  fi
}

setup() {
  ENV_TYPE=$(detect_env)
  log "Ambiente detectado: $ENV_TYPE"

  if [ "$ENV_TYPE" = "termux" ] || [ "$ENV_TYPE" = "termux-with-proot" ]; then
    pkg update -y && pkg upgrade -y
    pkg install -y git gh curl python nodejs-lts build-essential proot-distro openssh
    # Opcional: ambiente proot Ubuntu para builds que exigem glibc completo
    if ! proot-distro list | grep -q "ubuntu.*installed"; then
      proot-distro install ubuntu
    fi
  else
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y git gh curl python3 nodejs build-essential
  fi

  gh auth status || { log "Rode 'gh auth login' antes de continuar."; exit 1; }

  if [ ! -d "$REPO_DIR/.git" ]; then
    [ -z "$REPO_URL" ] && { log "Defina REPO_URL para clonar o repo."; exit 1; }
    git clone "$REPO_URL" "$REPO_DIR"
  fi

  log "Setup concluído."
}

update_distro() {
  ENV_TYPE=$(detect_env)
  log "Atualizando pacotes da distro ($ENV_TYPE)..."
  if [ "$ENV_TYPE" = "termux" ] || [ "$ENV_TYPE" = "termux-with-proot" ]; then
    pkg update -y && pkg upgrade -y
    if command -v proot-distro >/dev/null 2>&1; then
      proot-distro login ubuntu -- bash -c "apt update && apt upgrade -y" || true
    fi
  else
    sudo apt update && sudo apt upgrade -y
  fi
}

build_and_test() {
  cd "$REPO_DIR"
  log "Build/test iniciado."

  if [ -f package.json ]; then
    npm install
    npm run build --if-present
    npm test --if-present
  elif [ -f requirements.txt ]; then
    python3 -m pip install --break-system-packages -r requirements.txt
    python3 -m pytest || true
  else
    log "Nenhum build system reconhecido (package.json/requirements.txt). Pulando."
  fi
}

open_pr() {
  cd "$REPO_DIR"
  git fetch origin
  CURRENT_BRANCH="${BRANCH_PREFIX}-$(date '+%Y%m%d-%H%M%S')"

  if git diff --quiet && git diff --cached --quiet; then
    log "Sem alterações para commit. PR não será aberto."
    return 0
  fi

  git checkout -b "$CURRENT_BRANCH"
  git add -A
  git commit -m "auto: atualização automática $(date '+%Y-%m-%d %H:%M')"
  git push -u origin "$CURRENT_BRANCH"

  gh pr create \
    --base "$DEFAULT_BASE_BRANCH" \
    --head "$CURRENT_BRANCH" \
    --title "Auto-update: $(date '+%Y-%m-%d %H:%M')" \
    --body "PR gerado automaticamente pelo pipeline heliobus800-automation.sh"

  log "PR aberto para a branch $CURRENT_BRANCH."
}

run_once() {
  update_distro
  cd "$REPO_DIR"
  git checkout "$DEFAULT_BASE_BRANCH"
  git pull origin "$DEFAULT_BASE_BRANCH"
  build_and_test
  open_pr
}

watch_loop() {
  log "Iniciando modo watch (intervalo: ${INTERVAL_SECONDS}s). Ctrl+C para parar."
  while true; do
    run_once || log "Ciclo falhou, seguindo para o próximo."
    sleep "$INTERVAL_SECONDS"
  done
}

case "${1:-}" in
  setup) setup ;;
  run) run_once ;;
  watch) watch_loop ;;
  *)
    echo "Uso: $0 {setup|run|watch}"
    exit 1
    ;;
esac
