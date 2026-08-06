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
      AppleIconAppearanceTheme = "RegularDark";
      AppleMeasurementUnits = "Centimeters";
      AppleTemperatureUnit = "Celsius";
      _HIHideMenuBar = false;
      AppleShowAllExtensions = true;
    };
    controlcenter = {
      BatteryShowPercentage = true;
    };
    dock = {
      autohide = true;
      magnification = true;
      largesize = 128;
      wvous-tl-corner = 13;
      wvous-tr-corner = 12;
      wvous-bl-corner = 2;
      wvous-br-corner = 3;
    };
    finder = {
      FXPreferredViewStyle = "Nlsv"; # vista de lista
      CreateDesktop = false; # escritorio sin iconos
      AppleShowAllExtensions = true;
      ShowPathbar = true; # Show path breadcrumbs in finder windows
      ShowStatusBar = true; # Show status bar at bottom of finder windows with item/disk space stats
    };
    menuExtraClock.Show24Hour = true;
    trackpad.Clicking = true; # tap para click
  };
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  # ===== Fuentes =====
  # Mismo release de Nerd Fonts que traían los casks font-*, pero declarativo:
  # se instalan en "/Library/Fonts/Nix Fonts" y no chocan con las del usuario.
  fonts.packages = with pkgs; [
    nerd-fonts.meslo-lg # "MesloLGS Nerd Font Mono" para p10k / ghostty
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
    nerd-fonts.fira-code
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
    ];

    # REGLA: las CLI son de Nix (home.nix). Acá va SOLO lo que no está en
    # nixpkgs o lo que depende de Homebrew a propósito. Antes de agregar algo,
    # buscarlo en https://search.nixos.org/packages

    brews = [
    ];

    # Apps GUI y toolchains que instalan en la ruta oficial que esperan otras
    # herramientas. Lo que sí está en nixpkgs y es CLI, va en home.nix.
    casks = [
      "google-chrome"
      "visual-studio-code"
      "docker-desktop"
      "dotnet-sdk" # ruta oficial de Microsoft; la esperan Rider/VS
      "ghostty"
    ];
  };
}
