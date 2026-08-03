#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# setup.sh — bootstrap (PRIMERA instalación): instala Nix, Homebrew y flakes,
# y luego aplica la config delegando en ./apply.sh.
#   macOS → nix-darwin (sistema + casks Homebrew + Home Manager) con darwin-rebuild.
#   Linux → Home Manager standalone.
# Idempotente. Para SOLO aplicar cambios de .nix en el día a día, usa ./apply.sh.
# ============================================================================

REPO_URL="https://github.com/juanm21/dotfiles"
DOTFILES_DIR="$HOME/.dotfiles"

# --- Bootstrap: si se ejecuta SIN el repo (p.ej. vía `bash -c "$(curl …)"`),
#     clona el repo en ~/.dotfiles y re-ejecuta desde ahí. ---
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
if [ -z "$SELF_DIR" ] || [ ! -f "$SELF_DIR/flake.nix" ]; then
  if [ ! -d "$DOTFILES_DIR/.git" ]; then
    command -v git >/dev/null 2>&1 || { echo "✗ Necesitas git instalado (o clónalo a mano)."; exit 1; }
    echo "→ Descargando el repo en $DOTFILES_DIR…"
    git clone "$REPO_URL" "$DOTFILES_DIR"
  fi
  exec bash "$DOTFILES_DIR/setup.sh"
fi
cd "$SELF_DIR"

FLAKES="experimental-features = nix-command flakes"

# 1. Instalar Nix si no está (instalador de Determinate Systems: trae flakes).
if ! command -v nix >/dev/null 2>&1; then
  echo "→ Instalando Nix…"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
fi

# 2. Habilitar flakes para tu usuario (por si el instalador no lo dejó global).
NIX_CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nix"
mkdir -p "$NIX_CONF_DIR"
grep -qs "flakes" "$NIX_CONF_DIR/nix.conf" 2>/dev/null || echo "$FLAKES" >> "$NIX_CONF_DIR/nix.conf"
export NIX_CONFIG="$FLAKES"

# El usuario/HOME reales: se pasan a la config (sobreviven a `sudo`).
export DOTFILES_USER="$USER"
export DOTFILES_HOME="$HOME"

case "$(uname -s)" in
  Darwin)
    echo "→ macOS: nix-darwin  (usuario: $USER)"

    # 3a. Homebrew (nix-darwin gestiona los casks pero NO instala brew).
    if ! command -v brew >/dev/null 2>&1; then
      echo "→ Instalando Homebrew…"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    # 3b. Aplicar. Si darwin-rebuild aún no existe (primer arranque), se hace el
    #     bootstrap con `nix run`; si ya existe, se delega en ./apply.sh.
    if command -v darwin-rebuild >/dev/null 2>&1; then
      ./apply.sh
    else
      echo "→ Primer arranque de nix-darwin…"
      sudo --preserve-env=DOTFILES_USER,DOTFILES_HOME \
        nix --extra-experimental-features "nix-command flakes" \
        run nix-darwin#darwin-rebuild -- switch --impure --flake ".#mac"
    fi
    ;;

  Linux)
    echo "→ Linux: Home Manager standalone  (usuario: $USER)"
    ./apply.sh
    ;;

  *) echo "Sistema no soportado: $(uname -s)"; exit 1 ;;
esac

echo "✅ Listo. Abre una terminal nueva para cargar la configuración."
