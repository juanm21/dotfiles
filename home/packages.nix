{ pkgs, lib, ... }:
{
  # ============================================================================
  # home/packages.nix — programas instalados en tu usuario.
  #
  # Para AGREGAR un programa: búscalo en https://search.nixos.org/packages
  # (o `nix search nixpkgs <nombre>`) y añádelo a la lista. Luego `switch`.
  # Para QUITARLO: borra la línea y `switch`.
  # ============================================================================
  home.packages = with pkgs; [
    # --- CLI base ---
    bat # cat con colores
    eza # ls moderno
    fd # find moderno
    ripgrep # grep moderno (rg)
    fzf # fuzzy finder
    zoxide # cd inteligente (z)
    jq # procesar JSON
    wget
    htop
    tree-sitter # tree-sitter-cli
    figlet
    glow # markdown en la terminal

    # --- Git / dev ---
    git
    gh # GitHub CLI
    lazygit
    cmake
    mise # gestor de runtimes (reemplaza a nvm)

    # --- Editores ---
    neovim
    helix
    vim

    # --- Shell / prompt ---
    zsh
    zsh-powerlevel10k # tema del prompt (antes se clonaba a mano)

    # --- Lenguajes / runtimes ---
    nodejs
    pnpm
    bun
    python3
    ruby
    dotnet-sdk
    mono
    python3Packages.huggingface-hub # CLI `huggingface-cli` / `hf`

    # --- IA / .NET tooling ---
    llama-cpp # inferencia LLM local (llama-cli, llama-server)
    netcoredbg # debugger .NET (lo usa Helix; antes se bajaba a mano)
    sqlcmd # cliente SQL Server
    claude-code # asistente de código en la terminal

    # --- Fuentes ---
    nerd-fonts.meslo-lg # "MesloLGS NF" (la que pide Powerlevel10k)
    nerd-fonts.jetbrains-mono

  ]
  # --------------------------------------------------------------------------
  # Solo en Linux: apps que en macOS se instalan como app nativa (ver README).
  # --------------------------------------------------------------------------
  ++ lib.optionals pkgs.stdenv.isLinux [
    ghostty # en macOS: app oficial (manual)
    docker # en macOS: Docker Desktop (manual)
  ];
}
