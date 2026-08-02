{ pkgs, user, home, ... }:
{
  # ============================================================================
  # darwin.nix — configuración de macOS con nix-darwin.
  # Gestiona: casks GUI de Homebrew + integración de Home Manager.
  # ============================================================================
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # Nix lo instala/gestiona el instalador de Determinate → que nix-darwin no
  # toque el daemon (si no, chocan).
  nix.enable = false;

  # Versión de estado de nix-darwin (no la subas a la ligera).
  system.stateVersion = 6;
  # Usuario "principal": nix-darwin corre Homebrew como él (brew NO corre como root).
  system.primaryUser = user;
  users.users.${user}.home = home;

  # --------------------------------------------------------------------------
  # Homebrew: SOLO para apps GUI que no están en nixpkgs para macOS.
  # nix-darwin no instala Homebrew; setup.sh lo instala antes (bootstrap).
  # Para AGREGAR un cask GUI: añádelo aquí y corre `darwin-rebuild switch`.
  # --------------------------------------------------------------------------
  homebrew = {
    enable = true;
    onActivation.cleanup = "none"; # no desinstalar lo que tengas puesto a mano
    onActivation.autoUpdate = false;
    casks = [
      "ghostty"
      "docker-desktop"
      # Fuentes (antes se instalaban con brew; en macOS es lo más fiable).
      "font-jetbrains-mono"
      "font-meslo-lg-nerd-font" # "MesloLGS NF" para Powerlevel10k / ghostty
    ];
  };

  # --------------------------------------------------------------------------
  # Home Manager corre como parte de `darwin-rebuild switch`.
  # Toda tu config de usuario sigue viviendo en ./home (compartida con Linux).
  # --------------------------------------------------------------------------
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.${user} = import ./home;
}
