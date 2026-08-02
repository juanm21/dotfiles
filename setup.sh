#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# setup.sh — bootstrap de los dotfiles con Nix + Home Manager.
# Instala Nix (si falta), habilita flakes y aplica la configuración.
# Idempotente: puedes correrlo las veces que quieras.
# ============================================================================

cd "$(dirname "$0")"

# 1. Instalar Nix si no está (instalador de Determinate Systems: trae flakes).
if ! command -v nix >/dev/null 2>&1; then
  echo "→ Instalando Nix…"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # Cargar Nix en esta misma sesión.
  if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
fi

# 2. Habilitar flakes de forma permanente para tu usuario.
NIX_CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nix"
mkdir -p "$NIX_CONF_DIR"
if ! grep -qs "experimental-features.*flakes" "$NIX_CONF_DIR/nix.conf" 2>/dev/null; then
  echo "experimental-features = nix-command flakes" >> "$NIX_CONF_DIR/nix.conf"
fi
export NIX_CONFIG="experimental-features = nix-command flakes"

# 3. Elegir la configuración según el sistema operativo.
case "$(uname -s)" in
  Darwin) CONFIG="mac" ;;
  Linux)  CONFIG="linux" ;;
  *) echo "Sistema no soportado: $(uname -s)"; exit 1 ;;
esac
echo "→ Aplicando configuración: $CONFIG  (usuario: ${USER:-?})"

# 4. Aplicar Home Manager.
#    --impure: deja que la config lea $USER/$HOME → se adapta a quien ejecute.
#    -b backup: si ya existe un archivo (p.ej. symlinks viejos de stow), lo
#      respalda como <archivo>.backup en vez de fallar. Inofensivo en runs futuros.
#    La primera vez aún no existe el comando `home-manager` → usamos `nix run`.
if command -v home-manager >/dev/null 2>&1; then
  home-manager switch --impure -b backup --flake ".#$CONFIG"
else
  nix run home-manager/master -- switch --impure -b backup --flake ".#$CONFIG"
fi

echo "✅ Listo. Abre una terminal nueva para cargar la configuración."
echo "   Apps GUI que en macOS se instalan aparte (Ghostty, Docker Desktop, etc.): ver README."
