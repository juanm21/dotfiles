{
  # ============================================================================
  # flake.nix — punto de entrada de toda la configuración.
  #
  # Las salidas son "homeConfigurations": una por sistema (mac / linux). El
  # usuario y su HOME NO van en duro: se leen del entorno ($USER/$HOME) en
  # home/default.nix, por eso hay que aplicar con --impure (ver README/setup.sh).
  #
  # Para aplicar:   home-manager switch --impure --flake .#mac   (o .#linux)
  # ============================================================================
  description = "Dotfiles personales — Home Manager, cross-platform (macOS + Linux)";

  inputs = {
    # nixpkgs: el repositorio de paquetes. Rama rolling "unstable".
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # home-manager: gestiona el $HOME (paquetes de usuario + dotfiles).
    home-manager = {
      url = "github:nix-community/home-manager";
      # Fuerza a home-manager a usar EXACTAMENTE el mismo nixpkgs de arriba.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      # Helper: recibe el sistema y devuelve una config de Home Manager.
      mkHome = system:
        home-manager.lib.homeManagerConfiguration {
          # Importamos nixpkgs con config propia para permitir paquetes
          # "unfree" (p.ej. claude-code, dotnet-sdk).
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          # Toda la configuración vive en ./home (ver home/default.nix).
          modules = [ ./home ];
        };
    in
    {
      homeConfigurations = {
        mac = mkHome "aarch64-darwin"; # macOS (Apple Silicon)
        linux = mkHome "x86_64-linux"; # Linux (x86_64)
      };
    };
}
