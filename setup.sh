#!/bin/bash
set -e

# Ejecutar siempre desde ~/.dotfiles (stow lo requiere)
cd "$(dirname "$0")"

# 1. Homebrew (instala también las Xcode Command Line Tools si faltan)
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Confiar en los taps de terceros que usa el Brewfile
brew trust microsoft/mssql-release
brew trust oven-sh/bun
brew trust jundot/omlx

# 3. Instalar aplicaciones
brew bundle install --file=Brewfile

# 4. Configurar dotfiles con stow (-R = restow, idempotente)
stow -R ghostty git helix nvim stow tmux zsh

# 5. oh-my-zsh (sin lanzar zsh ni cambiar shell; respeta el .zshrc stowed)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 6. Tema powerlevel10k (lo usa .zshrc, se configura con .p10k.zsh stowed)
P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# 7. TPM (gestor de plugins de tmux) + instalar plugins de .tmux.conf
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
  "$TPM_DIR/bin/install_plugins"
fi


# 8. netcoredbg (debugger .NET, binario oficial de Samsung → ~/.local/tools/netcoredbg)
NETCOREDBG_DIR="$HOME/.local/tools/netcoredbg"
if [ ! -x "$NETCOREDBG_DIR/netcoredbg" ]; then
  mkdir -p "$HOME/.local/tools"
  NETCOREDBG_ZIP="$(mktemp -d)/netcoredbg.zip"
  curl -fsSL -o "$NETCOREDBG_ZIP" \
    "https://github.com/Samsung/netcoredbg/releases/latest/download/netcoredbg-osx-arm64.zip"
  unzip -qo "$NETCOREDBG_ZIP" -d "$HOME/.local/tools" -x "__MACOSX/*"
  chmod +x "$NETCOREDBG_DIR/netcoredbg"
  rm "$NETCOREDBG_ZIP"
fi

echo "✅ Setup completo. Abre una nueva terminal para cargar la configuración."
