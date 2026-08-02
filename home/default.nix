{ config, pkgs, lib, ... }:
{
  # ============================================================================
  # home/default.nix — módulo raíz. Importa los demás y fija los datos básicos.
  #
  # username/homeDirectory NO se fijan aquí: los pone el entrypoint
  #   - macOS: nix-darwin (desde el usuario del sistema)   → flake.nix + darwin.nix
  #   - Linux: módulo inline en flake.nix (desde $USER/$HOME, con --impure)
  # ============================================================================

  imports = [
    ./packages.nix # lista de programas (home.packages)
    ./shell.nix    # zsh + p10k + fzf + zoxide + bat  (reemplaza .zshrc)
    ./git.nix      # git                              (reemplaza .gitconfig)
    ./tmux.nix     # tmux + plugins                   (reemplaza .tmux.conf + TPM)
  ];

  # Versión del "contrato" de Home Manager. NO la subas a la ligera: fija el
  # comportamiento de defaults. Déjala en la que instalaste por primera vez.
  home.stateVersion = "25.05";

  # Deja que Home Manager se gestione a sí mismo (comando `home-manager`).
  programs.home-manager.enable = true;

  # --------------------------------------------------------------------------
  # Configs "crudas": archivos que NO reescribimos en Nix, solo enlazamos tal
  # cual desde ./config. Ideal para configs grandes o generadas por su app
  # (LazyVim, temas de Helix, ghostty). Editas el archivo y aplicas `switch`.
  #
  # `xdg.configFile."X"` enlaza a ~/.config/X ; `home.file."X"` enlaza a ~/X.
  # --------------------------------------------------------------------------
  xdg.enable = true;

  xdg.configFile = {
    # Neovim (LazyVim completo, tal cual).
    "nvim".source = ../config/nvim;

    # Helix: config.toml + languages.toml + themes/ (incluye el tema "jm").
    "helix".source = ../config/helix;

    # Ghostty (en macOS la app es manual; el config sirve igual, ver README).
    "ghostty/config".source = ../config/ghostty/config;
  };

  # Prompt Powerlevel10k: su archivo de config generado con `p10k configure`.
  home.file.".p10k.zsh".source = ../config/p10k.zsh;
}
