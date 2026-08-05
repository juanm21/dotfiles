{ pkgs, user, ... }:
{
  # ===========================================================================
  # configuration.nix — macOS a nivel sistema: defaults + Homebrew.
  # La config de usuario vive en home.nix.
  # ===========================================================================

  # ===== Nix / plataforma =====
  nix.enable = false; # el daemon lo gestiona el instalador de Determinate
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.stateVersion = 6; # contrato de nix-darwin; no subirla a la ligera
  system.primaryUser = user; # Homebrew corre como él (brew no corre como root)
  users.users.${user}.home = "/Users/${user}";

  # ===== Preferencias de macOS =====
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      _HIHideMenuBar = false;
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv"; # vista de lista
    finder.CreateDesktop = false; # escritorio sin iconos
    trackpad.Clicking = true; # tap para click
  };

  # ===== Fuentes =====
  # Mismo release de Nerd Fonts que traían los casks font-*, pero declarativo:
  # se instalan en "/Library/Fonts/Nix Fonts" y no chocan con las del usuario.
  fonts.packages = with pkgs; [
    nerd-fonts.meslo-lg # "MesloLGS Nerd Font Mono" para p10k / ghostty
    nerd-fonts.jetbrains-mono
  ];

  # ===== Homebrew =====
  # nix-homebrew instala y es dueño de /opt/homebrew (autoMigrate adopta el
  # existente). Las listas de abajo son la fuente de verdad: con cleanup="zap",
  # todo brew/cask/tap que NO esté acá se desinstala en el próximo switch.
  nix-homebrew = {
    enable = true;
    inherit user;
    autoMigrate = true;
    mutableTaps = true; # los taps se declaran en homebrew.taps
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap"; # esta lista es la fuente de verdad: lo que no esté acá se desinstala
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ]; # zap sin prompt interactivo

    # trusted=true agrega `trusted: true` a la línea del Brewfile. brew 6.x se
    # niega a cargar formulae de taps no oficiales sin eso, y ese estado vive
    # normalmente fuera de Nix (trust.json). Declarándolo acá, un mac nuevo no
    # necesita ningún `brew trust` manual.
    taps = [
      { name = "jundot/omlx"; trusted = true; }
      { name = "microsoft/mssql-release"; trusted = true; }
    ];

    # REGLA: las CLI son de Nix (home.nix). Acá va SOLO lo que no está en
    # nixpkgs o lo que depende de Homebrew a propósito. Antes de agregar algo,
    # buscarlo en https://search.nixos.org/packages
    #
    # Instaladas a pedido (`brew leaves --installed-on-request`). Sus
    # dependencias transitivas NO van acá: brew bundle las resuelve solas.
    brews = [
      # su completado es el script BASH que carga home.nix desde $HOMEBREW_PREFIX
      "azure-cli"
      "bash" # bash 5.x; macOS trae el 3.2
      "chrome-cli" # no está en nixpkgs
      "herdr"
      # Dependencia de mssql-tools18, declarada aparte para que zap no dependa
      # de resolverla sola.
      "microsoft/mssql-release/msodbcsql18"
      # Aporta `bcp`, que no está en Nix. link=false porque su `sqlcmd` chocaría
      # con el de la formula sqlcmd (go-sqlcmd); home.nix agrega su bin al FINAL
      # del PATH, así que `bcp` se ve y `sqlcmd` sigue siendo el go-sqlcmd.
      {
        name = "microsoft/mssql-release/mssql-tools18";
        link = false;
      }
      "jundot/omlx/omlx" # tap propio; no está en nixpkgs
      "rust" # toolchain gestionada por brew, no por Nix
      "xsv" # no está en nixpkgs 26.05 (solo el sucesor `qsv`)
    ];

    # Apps GUI y toolchains que instalan en la ruta oficial que esperan otras
    # herramientas. Lo que sí está en nixpkgs y es CLI, va en home.nix.
    casks = [
      "claude-code" # el .app nativo, se autoactualiza
      "docker-desktop"
      "dotnet-sdk" # ruta oficial de Microsoft; la esperan Rider/VS
      "ghostty"
      "mono-mdk" # MDK completo; reemplaza a la formula `mono`
      "opensuperwhisper"
    ];
  };
}
