{ config, pkgs, lib, ... }:
let
  # Enlace EN VIVO a un archivo/carpeta del repo (~/.dotfiles/<rel>): el symlink
  # apunta al repo, no a una copia en el store → editable sin reconstruir.
  live = rel: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/${rel}";
in
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
  # Configs "crudas": archivos que NO reescribimos en Nix, solo enlazamos.
  # Se usan enlaces EN VIVO con `mkOutOfStoreSymlink`: ~/.config/X apunta
  # directo a ~/.dotfiles/config/X (no a una copia en el store). Así:
  #   - editas el archivo y el cambio se ve al instante, sin reconstruir;
  #   - el directorio es escribible (p.ej. nvim/LazyVim escribe lazy-lock.json).
  # Asume que el repo está en ~/.dotfiles.
  # --------------------------------------------------------------------------
  xdg.enable = true;

  xdg.configFile = {
    # Neovim (LazyVim completo).
    "nvim".source = live "config/nvim";

    # Helix: config.toml + languages.toml + themes/ (incluye el tema "jm").
    "helix".source = live "config/helix";

    # Ghostty.
    "ghostty/config".source = live "config/ghostty/config";
  };

  # Prompt Powerlevel10k: su archivo de config generado con `p10k configure`.
  home.file.".p10k.zsh".source = live "config/p10k.zsh";
}
