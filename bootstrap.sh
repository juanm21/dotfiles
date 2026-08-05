#!/usr/bin/env bash
# Lleva un Mac de cero a un nix-darwin funcionando. Se corre UNA vez;
# después usá ./rebuild.sh para cada cambio.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

echo "==> Paso 1: Nix (instalador de Determinate)"
if command -v nix >/dev/null 2>&1; then
  echo "    ya instalado, se omite"
else
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
NIX_CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nix"
mkdir -p "$NIX_CONF_DIR"
grep -qs flakes "$NIX_CONF_DIR/nix.conf" 2>/dev/null \
  || echo "experimental-features = nix-command flakes" >> "$NIX_CONF_DIR/nix.conf"

echo "==> Paso 2: enlazar el repo a ~/.dotfiles"
# home.nix resuelve sus mkOutOfStoreSymlink por esta ruta: tiene que existir
# antes del primer switch o el build no encuentra los archivos.
[ "$DIR" = "$HOME/.dotfiles" ] || ln -sfn "$DIR" ~/.dotfiles

echo "==> Paso 3: usuario configurado"
# Antes de cualquier sudo: bajo sudo, \$USER pasa a ser root.
REAL_USER="$(whoami)"
FLAKE_USER="$(sed -nE 's/^[[:space:]]*user = "([^"]+)";.*/\1/p' "$DIR/flake.nix" | head -n1)"
if [ -z "$FLAKE_USER" ]; then
  echo "    ✗ No encuentro la línea 'user = ' en flake.nix. Editala a mano." >&2
  exit 1
elif [ "$FLAKE_USER" = "$REAL_USER" ]; then
  echo "    flake.nix ya usa \"$REAL_USER\", nada que hacer"
else
  echo "    flake.nix está configurado para \"$FLAKE_USER\", pero vos sos \"$REAL_USER\"."
  read -r -p "    ¿Reescribir la línea 'user = ' a \"$REAL_USER\"? [s/N] " REPLY
  case "$REPLY" in
    s|S|y|Y)
      sed -i '' -E "s/^([[:space:]]*user = \")[^\"]+(\";.*)/\1${REAL_USER}\2/" "$DIR/flake.nix"
      echo "    Listo. Revisalo con: git diff flake.nix"
      ;;
    *)
      echo "    Cancelado. Editá la línea 'user = ' de flake.nix antes de seguir." >&2
      exit 1
      ;;
  esac
fi

echo "==> Paso 4: liberar /etc/bashrc y /etc/zshrc"
# nix-darwin los gestiona él; en un mac de fábrica ya existen y la activación
# aborta pidiendo moverlos. El backup hace el paso idempotente.
for f in /etc/bashrc /etc/zshrc; do
  if [ -e "$f" ] && [ ! -e "$f.before-nix-darwin" ]; then
    echo "    moviendo $f → $f.before-nix-darwin"
    sudo mv "$f" "$f.before-nix-darwin"
  fi
done

echo "==> Paso 5: primer darwin-rebuild switch"
# darwin-rebuild todavía no existe: se corre directo desde el flake esta vez.
# sudo resetea el PATH a uno seguro sin /nix/.../bin, así que hay que resolver
# la ruta absoluta de nix ANTES.
#
# La confianza de los taps de terceros NO hace falta manejarla acá: los taps se
# declaran con `trusted = true` en configuration.nix, y nix-darwin la emite en
# el propio Brewfile.
NIX_BIN="$(command -v nix)"
sudo "$NIX_BIN" \
  run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake ~/.dotfiles#mac

echo "==> Listo. Abrí una terminal nueva. Para futuros cambios: ./rebuild.sh"
