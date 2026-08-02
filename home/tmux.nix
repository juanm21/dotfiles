{ pkgs, ... }:
{
  # ============================================================================
  # home/tmux.nix — tmux + plugins. Reemplaza a ~/.tmux.conf y a TPM.
  # Los plugins los instala Nix (ya no se clona TPM ni se corre install_plugins).
  # ============================================================================
  programs.tmux = {
    enable = true;
    prefix = "C-a"; # genera el unbind C-b + set prefix + send-prefix
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

    # El resto de ~/.tmux.conf (lo que no cubre una opción de arriba).
    extraConfig = ''
      # Barra de estado arriba
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

      # Redimensionar panes sin prefijo (Ctrl+Alt+Shift+hjkl)
      bind -n C-M-S-h resize-pane -L 1
      bind -n C-M-S-j resize-pane -D 1
      bind -n C-M-S-k resize-pane -U 1
      bind -n C-M-S-l resize-pane -R 1

      # Recargar config: prefix + r
      bind r source-file ~/.config/tmux/tmux.conf \; display "¡Configuración recargada!"

      # Cursor: permitir que los programas cambien su forma
      set -ga terminal-overrides ',*:Ss=\E[%p1%d q:Se=\E[6 q'

      # True color + features de Ghostty
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -ag terminal-features ",xterm-ghostty:mouse:extkeys"

      # Portapapeles de macOS (OSC 52)
      set -s set-clipboard on

      # Numerar panes desde 1
      setw -g pane-base-index 1
    '';
  };
}
