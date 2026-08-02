{ config, pkgs, lib, ... }:
{
  # ============================================================================
  # home/shell.nix — Zsh + Powerlevel10k + fzf + zoxide + bat.
  # Reemplaza a ~/.zshrc y ~/.zprofile (y a oh-my-zsh/p10k clonados a mano).
  # ============================================================================

  # Rutas extra al PATH (antes en .zshrc/.zprofile).
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.dotnet/tools"
  ];

  # Herramientas que se auto-integran con el shell: Home Manager escribe el
  # `eval "$(... init)"` por ti, así que ya no van en initContent.
  programs.fzf.enable = true;
  programs.zoxide.enable = true;
  programs.bat.enable = true;

  programs.zsh = {
    enable = true;
    # Mantener ~/.zshrc en $HOME (comportamiento clásico; el default cambiará
    # a ~/.config/zsh en versiones futuras de Home Manager).
    dotDir = config.home.homeDirectory;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true; # hace el compinit por ti

    # oh-my-zsh solo por el plugin `git` (sus alias). El prompt lo pone p10k.
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = ""; # sin tema de omz: usamos Powerlevel10k más abajo
    };

    # Powerlevel10k cargado como plugin (paquete de nixpkgs).
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    # Alias (antes dispersos en .zshrc).
    shellAliases = {
      cat = "bat";
      ls = "eza";
      ll = "eza -lh";
      la = "eza -lah";
      tree = "eza --tree";
      e = "eza";
      ea = "eza -la --header";
      eg = "eza -l --git --git-repos --header";
      python = "python3";
      pip = "pip3";
      nvim_tutor = "nvim --clean -c Tutor";
      g4 = ''echo "g4_26_xl - g4_26_m - g4_26_xxs"'';
      # $HOME se expande al ejecutar el alias (no al definirlo).
      g4_26_xl = "llama-cli -m $HOME/IA/Models/gemma-4-26B-A4B-it-UD-Q8_K_XL.gguf";
      g4_26_m = "llama-cli -m $HOME/IA/Models/gemma-4-26B-A4B-it-UD-Q4_K_M.gguf";
      g4_26_xxs = "llama-cli -m $HOME/IA/Models/gemma-4-26B-A4B-it-UD-IQ2_XXS.gguf";
      check_ssl = "~/DEV/RevisarCertificadoSSL/ConsoleApp/bin/Release/net10.0/osx-arm64/publish/ConsoleApp";
    };

    # Lo que no tiene opción nativa va aquí, como texto de zsh literal.
    # mkBefore = va arriba del todo (lo pide el instant prompt de p10k).
    initContent = lib.mkMerge [
      (lib.mkBefore ''
        # Powerlevel10k instant prompt. Debe quedar arriba del .zshrc.
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')
      ''
        # Editor: vim por SSH, si no Helix.
        if [[ -n $SSH_CONNECTION ]]; then
          export EDITOR='vim'
        else
          export EDITOR='hx'
        fi

        # Tema de colores GitHub-dark para fzf.
        export FZF_DEFAULT_OPTS=$'--info=right
          --highlight-line
          --header-first
          --color=fg:#c9d1d9,bg:#0d1117,hl:#79c0ff,fg+:#c9d1d9,bg+:#161b22
          --color=hl+:#a5d6ff,info:#8b949e,prompt:#58a6ff,pointer:#f85149
          --color=marker:#ff7b72,spinner:#3fb950,header:#79c0ff,border:#30363d
          --color=label:#8b949e,gutter:#161b22,footer:#8b949e'

        # Checkout de rama con fzf (preview del commit).
        # El plugin git de oh-my-zsh define `gco` como alias; hay que quitarlo
        # antes de definir la función (si no, error de parseo).
        unalias gco 2>/dev/null || true
        gco() {
          git branch | fzf --preview 'git show --color=always {-1}' \
            --bind 'enter:become(git checkout {-1})' \
            --height 40% --layout reverse
        }

        # Cursor en forma de barra (compat. con Helix/tmux).
        precmd() { print -rn -- $'\e[1 q'; }
        echo -ne '\e[1 q'

        # Config del prompt (generada con `p10k configure`).
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      ''
    ];
  };
}
