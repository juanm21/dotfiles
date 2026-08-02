{ config, pkgs, lib, ... }:
let
  # Usuario y HOME del que ejecuta, leídos del entorno. Requiere --impure
  # (los flakes son "puros" y no ven variables de entorno por defecto).
  envUser = builtins.getEnv "USER";
  envHome = builtins.getEnv "HOME";
in
{
  # ============================================================================
  # home/default.nix — módulo raíz. Importa los demás y fija los datos básicos.
  # ============================================================================

  imports = [
    ./packages.nix # lista de programas (home.packages)
    ./shell.nix    # zsh + p10k + fzf + zoxide + bat  (reemplaza .zshrc)
    ./git.nix      # git                              (reemplaza .gitconfig)
    ./tmux.nix     # tmux + plugins                   (reemplaza .tmux.conf + TPM)
  ];

  # Quién y dónde: se adaptan a quien corra `home-manager switch`.
  # Si están vacíos, faltó --impure → mensaje claro en vez de "expected juanm".
  home.username =
    if envUser != "" then envUser
    else throw "USER vacío: aplica con --impure (usa ./setup.sh o home-manager switch --impure --flake .#mac).";
  home.homeDirectory =
    if envHome != "" then envHome
    else throw "HOME vacío: aplica con --impure (usa ./setup.sh o home-manager switch --impure --flake .#mac).";

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
