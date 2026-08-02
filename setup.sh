#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# setup.sh — bootstrap de los dotfiles.
#   macOS → nix-darwin (sistema + casks Homebrew + Home Manager) con darwin-rebuild.
#   Linux → Home Manager standalone.
# Idempotente: puedes correrlo las veces que quieras.
# ============================================================================

cd "$(dirname "$0")"

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

    # 3b. Aplicar. Con sudo (darwin-rebuild toca el sistema); --preserve-env
    #     mantiene DOTFILES_USER/HOME; --impure deja leer esas variables.
    if command -v darwin-rebuild >/dev/null 2>&1; then
      sudo --preserve-env=DOTFILES_USER,DOTFILES_HOME \
        darwin-rebuild switch --impure --flake ".#mac"
    else
      # Primer arranque: aún no existe darwin-rebuild → usar `nix run`.
      sudo --preserve-env=DOTFILES_USER,DOTFILES_HOME \
        nix --extra-experimental-features "nix-command flakes" \
        run nix-darwin#darwin-rebuild -- switch --impure --flake ".#mac"
    fi
    ;;

  Linux)
    echo "→ Linux: Home Manager standalone  (usuario: $USER)"
    if command -v home-manager >/dev/null 2>&1; then
      home-manager switch --impure -b backup --flake ".#linux"
    else
      nix run home-manager/master -- switch --impure -b backup --flake ".#linux"
    fi
    ;;

  *) echo "Sistema no soportado: $(uname -s)"; exit 1 ;;
esac

echo "✅ Listo. Abre una terminal nueva para cargar la configuración."
