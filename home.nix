{ config, pkgs, lib, user, ... }:

let
  # Enlaces EN VIVO al repo: ~/<rel> apunta a ~/.dotfiles/home/<rel>, no a una
  # copia en el store → editás el archivo y el cambio se ve sin reconstruir, y
  # el destino queda escribible (LazyVim escribe su lazy-lock.json).
  # home/ espeja $HOME, así que cada ruta se escribe UNA sola vez.
  linked = paths: lib.genAttrs paths (rel: {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/home/${rel}";
  });

  # `brew shellenv` pone /opt/homebrew al FRENTE del PATH y taparía las
  # herramientas de Nix; por eso se reordena al final. Nix manda, brew completa.
  # Se usa en .zprofile Y en .zshrc (login shells e interactivos sueltos).
  #
  # El eval va guardado para no repetir el fork si ya corrió en .zprofile, pero
  # el REORDENAMIENTO no puede estarlo: nix-homebrew inyecta su propio
  # `eval "$(brew shellenv)"` en /etc/zshrc, que corre DESPUÉS de .zprofile y
  # vuelve a anteponer Homebrew. Sin esto, brew le gana a Nix.
  brewInit = ''
    if [[ -z $HOMEBREW_PREFIX && -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    if [[ -n $HOMEBREW_PREFIX ]]; then
      path=(''${path:#/opt/homebrew/bin} /opt/homebrew/bin)
      path=(''${path:#/opt/homebrew/sbin} /opt/homebrew/sbin)
    fi
  '';

in

{
  # ===========================================================================
  # home.nix — config de usuario (Home Manager). Reemplaza a ~/.zshrc,
  # ~/.zprofile, ~/.gitconfig y ~/.tmux.conf.
  # ===========================================================================

  # ===== Base =====
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "25.05"; # contrato de HM; dejarla en la original
  programs.home-manager.enable = true;

  # ===== Configs enlazadas en vivo =====
  # Archivos que NO se reescriben en Nix, solo se enlazan al repo.
  xdg.enable = true; # define las variables XDG_*
  home.file = linked [
    ".config/nvim" # configs
    ".config/helix" # config.toml, languages.toml, themes/
    ".config/ghostty/config"
    ".p10k.zsh" # prompt, generado con `p10k configure`
  ];

  # ===== Paquetes =====
  # Buscar en https://search.nixos.org/packages (o `nix search nixpkgs <x>`).
  # OJO: bat, fzf y zoxide NO van acá — los instalan sus `programs.*.enable`
  # más abajo. Y powerlevel10k lo instala `programs.zsh.plugins`.
  home.packages = with pkgs; [

    # --- CLI base ---
    eza # ls moderno
    fd # find moderno
    ripgrep # grep moderno (rg)
    jq # procesar JSON
    wget
    tree-sitter # tree-sitter-cli
    glow # markdown en la terminal

    # --- Git / dev ---  (git lo instala programs.git más abajo)
    gh # GitHub CLI
    lazygit
    cmake

    # --- Editores ---  (zsh lo instala programs.zsh)
    vim
    neovim
    helix

    # --- Lenguajes / runtimes ---
    nodejs
    bun
    python3
    python3Packages.huggingface-hub # CLI `huggingface-cli` / `hf`

    # --- tooling ---
    llama-cpp # llama-cli, llama-server
    netcoredbg # debugger .NET (lo usa Helix)
    azure-cli
    
  ];

  # ===== Zsh =====
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.dotnet/tools"
  ];

  # Estas escriben su propio `eval "$(... init)"` en el .zshrc.
  programs.bash.enable = true;

  programs.htop.enable = true;

  programs.zoxide.enable = true;

  programs.direnv.enable = true;

  programs.fzf = {
    enable = true;

    # Agrega tus opciones de interfaz y colores aquí:
    defaultOptions = [
      "--info=right"
      "--highlight-line"
      "--header-first"
      "--color=fg:#c9d1d9,bg:#0d1117,hl:#79c0ff,fg+:#c9d1d9,bg+:#161b22"
      "--color=hl+:#a5d6ff,info:#8b949e,prompt:#58a6ff,pointer:#f85149"
      "--color=marker:#ff7b72,spinner:#3fb950,header:#79c0ff,border:#30363d"
      "--color=label:#8b949e,gutter:#161b22,footer:#8b949e"
    ];
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Visual Sutio Dark+";
    };
  };

  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory; # ~/.zshrc clásico, no ~/.config/zsh
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true; # hace el compinit

    profileExtra = brewInit; # Homebrew en login shells

    # Solo por los alias del plugin git; el prompt lo pone p10k.
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "";
    };

    plugins = [{
      name = "powerlevel10k";
      src = pkgs.zsh-powerlevel10k;
      file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    }];

    shellAliases = {

      cat = "bat";

      ls = "eza";
      ll = "eza -lh";
      la = "eza -lah";
      tree = "eza --tree";
      lg = "eza -lah --git --git-repos --header";

      # Switch git branch
      lgg = "git branch | fzf --preview 'git show --color=always {-1}' \
            --bind 'enter:become(git checkout {-1})' \
            --height 40% --layout reverse";


      python = "python3";
      pip = "pip3";

      nvim_tutor = "nvim --clean -c Tutor";

      g4 = ''echo "g4_26_xl - g4_26_m - g4_26_xxs"'';
      # $HOME se expande al ejecutar el alias, no al definirlo.
      g4_26_xl = "llama-cli -m $HOME/IA/Models/gemma-4-26B-A4B-it-UD-Q8_K_XL.gguf";
      g4_26_m = "llama-cli -m $HOME/IA/Models/gemma-4-26B-A4B-it-UD-Q4_K_M.gguf";
      g4_26_xxs = "llama-cli -m $HOME/IA/Models/gemma-4-26B-A4B-it-UD-IQ2_XXS.gguf";

      check_ssl = "~/DEV/RevisarCertificadoSSL/ConsoleApp/bin/Release/net10.0/osx-arm64/publish/ConsoleApp";
    };

    # El ORDEN de estos bloques es lógica, no estética: mkBefore=500,
    # oh-my-zsh (y su compinit)=800, bloque sin envolver=1000, mkAfter=1500.
    initContent = lib.mkMerge [
      (lib.mkBefore ''
        # Instant prompt de p10k: tiene que quedar arriba de todo.
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')

      # 550: agregar a fpath tiene que pasar ANTES del compinit de oh-my-zsh.
      (lib.mkOrder 550 ''
        if [[ -d $HOME/.docker/completions ]]; then
          fpath=($HOME/.docker/completions $fpath)
        fi
      '')

      brewInit # también en shells interactivos no-login

      ''
        # Editor: vim por SSH, si no Helix.
        if [[ -n $SSH_CONNECTION ]]; then
          export EDITOR='vim'
        else
          export EDITOR='hx'
        fi

        # Cursor en barra (compat. con Helix/tmux).
        precmd() { print -rn -- $'\e[1 q'; }
        echo -ne '\e[1 q'

        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      ''

      # El completado de az es un script de BASH: necesita bashcompinit, que a
      # su vez exige el compinit ya hecho (de ahí que vaya después de 800).
      ''
        if [[ -r $HOMEBREW_PREFIX/etc/bash_completion.d/az ]]; then
          autoload -Uz bashcompinit && bashcompinit
          source $HOMEBREW_PREFIX/etc/bash_completion.d/az
        fi
      ''

      # Último de todo: lo que esté en ~/.zshrc.local pisa a Nix.
      (lib.mkAfter ''
        [[ ! -r ~/.zshrc.local ]] || source ~/.zshrc.local
      '')
    ];
  };

  # ===== Git =====
  # user.name / user.email viven en ~/.gitconfig.local (privado, fuera del repo).
  programs.git = {
    enable = true;
    package = pkgs.gitFull; # trae git-gui y gitk

    settings = {
      core = {
        autocrlf = "input";
        whitespace = "cr-at-eol";
        excludesfile = "~/.gitignore_global";
        editor = "hx";
      };
      pull.rebase = false;
      init.defaultBranch = "main";
    };

    includes = [{ path = "~/.gitconfig.local"; }];
  };

  # ===== Tmux =====
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      {
        plugin = dracula;
        # Estas opciones deben fijarse ANTES de cargar el plugin.
        extraConfig = ''
          set -g @dracula-colors "
          # simple tomorrow night color palette
          pink='#cc6666'
          orange='#de935f'
          yellow='#f0c574'
          green='#b5bd68'
          cyan='#8abdb6'
          blue='#81a2be'
          light_purple='#b294ba'
          white='#c4c8c5'
          dark_gray='#363a41'
          red='#cc6666'
          gray='#1d1f21'
          dark_purple='#373b41'
          "
          set -g @dracula-show-powerline true
          set -g @dracula-transparent-powerline-bg true
          set -g @dracula-show-empty-plugins false
          set -g @dracula-show-left-icon "  #S"
          set -g @dracula-plugins "network-vpn time"
          set -g @dracula-show-fahrenheit false
          set -g @dracula-show-location true
          set -g @dracula-weather-hide-errors true
          set -g @dracula-show-timezone false
          set -g @dracula-military-time true
          set -g @dracula-time-format "%F %R"
          set -g @dracula-network-vpn-verbose true
          set -g @dracula-network-vpn-label "󰌘 "
        '';
      }
    ];

    extraConfig = ''
      set-option -g status-position top

      # Splits con teclas lógicas
      unbind '"'
      unbind %
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind h split-window -hb -c "#{pane_current_path}"
      bind j split-window -v  -c "#{pane_current_path}"
      bind k split-window -vb -c "#{pane_current_path}"
      bind l split-window -h  -c "#{pane_current_path}"

      # Mover foco entre panes sin prefijo (Ctrl+Shift+hjkl)
      bind -n C-S-h select-pane -L
      bind -n C-S-j select-pane -D
      bind -n C-S-k select-pane -U
      bind -n C-S-l select-pane -R

      # Redimensionar sin prefijo (Ctrl+Alt+Shift+hjkl)
      bind -n C-M-S-h resize-pane -L 1
      bind -n C-M-S-j resize-pane -D 1
      bind -n C-M-S-k resize-pane -U 1
      bind -n C-M-S-l resize-pane -R 1

      bind r source-file ~/.config/tmux/tmux.conf \; display "¡Configuración recargada!"

      # Dejar que los programas cambien la forma del cursor
      set -ga terminal-overrides ',*:Ss=\E[%p1%d q:Se=\E[6 q'

      # True color + features de Ghostty
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -ag terminal-features ",xterm-ghostty:mouse:extkeys"

      set -s set-clipboard on # portapapeles de macOS (OSC 52)
      setw -g pane-base-index 1
    '';
  };
}
