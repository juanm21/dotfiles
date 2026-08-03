#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# apply.sh — aplica cambios de los archivos .nix (el "switch"), SIN el bootstrap.
#
# Úsalo tras editar home/*.nix, darwin.nix o flake.nix.
# Los configs crudos de config/ (nvim, helix, ghostty, p10k) son enlaces EN VIVO
# y NO necesitan esto.
# Para la PRIMERA instalación (instala Nix/Homebrew) usa ./setup.sh.
# ============================================================================

cd "$(dirname "$0")"

export NIX_CONFIG="experimental-features = nix-command flakes"
# Usuario/HOME reales, para que la config los lea (y sobrevivan a sudo en mac).
export DOTFILES_USER="$USER"
export DOTFILES_HOME="$HOME"

case "$(uname -s)" in
  Darwin)
    if ! command -v darwin-rebuild >/dev/null 2>&1; then
      echo "✗ darwin-rebuild no está instalado. Corre ./setup.sh la primera vez." >&2
      exit 1
    fi
    echo "→ Aplicando (macOS)…"
    sudo --preserve-env=DOTFILES_USER,DOTFILES_HOME \
      darwin-rebuild switch --impure --flake ".#mac"
    ;;

  Linux)
    CFG="linux-$(uname -m)" # linux-x86_64 | linux-aarch64
    echo "-> Aplicando (Linux, $CFG)..."
    if command -v home-manager >/dev/null 2>&1; then
      home-manager switch --impure -b backup --flake ".#${CFG}"
    else
      nix run home-manager/master -- switch --impure -b backup --flake ".#${CFG}"
    fi
    ;;

  *) echo "Sistema no soportado: $(uname -s)"; exit 1 ;;
esac

echo "✅ Config aplicada."
