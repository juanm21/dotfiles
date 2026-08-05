#!/usr/bin/env bash
# Aplica los cambios de flake.nix / configuration.nix / home.nix (el "switch").
# Los configs de home/ son enlaces EN VIVO y no necesitan esto.
# Para la primera instalación usá ./bootstrap.sh.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# home.nix resuelve sus mkOutOfStoreSymlink por ~/.dotfiles, así que el repo
# puede vivir en cualquier ruta mientras ese symlink apunte acá.
[ "$DIR" = "$HOME/.dotfiles" ] || ln -sfn "$DIR" ~/.dotfiles

# sudo resetea el PATH a uno seguro, así que se resuelve la ruta absoluta ANTES
# (mismo motivo que en bootstrap.sh).
DR="$(command -v darwin-rebuild)" \
  || { echo "✗ darwin-rebuild no está. Corré ./bootstrap.sh la primera vez." >&2; exit 1; }

exec sudo "$DR" switch --flake ~/.dotfiles#mac
