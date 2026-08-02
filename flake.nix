{
  # ============================================================================
  # flake.nix — punto de entrada de toda la configuración.
  #
  # Un "flake" es un proyecto Nix con entradas (inputs) versionadas en flake.lock
  # y salidas (outputs) que otras herramientas consumen. Aquí las salidas son
  # "homeConfigurations": una configuración de Home Manager por máquina.
  #
  # Para aplicar:   home-manager switch --flake .#juanm@mac   (o .#juanm@linux)
  # ============================================================================
  description = "Dotfiles de juanm — Home Manager, cross-platform (macOS + Linux)";

  inputs = {
    # nixpkgs: el repositorio de paquetes. Rama rolling "unstable".
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # home-manager: gestiona el $HOME (paquetes de usuario + dotfiles).
    home-manager = {
      url = "github:nix-community/home-manager";
      # Fuerza a home-manager a usar EXACTAMENTE el mismo nixpkgs de arriba
      # (evita descargar/compilar dos versiones distintas).
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      # Helper para no repetir el mismo bloque por cada máquina.
      # Recibe el sistema y los datos del usuario, y devuelve una config de HM.
      mkHome = { system, username, homeDirectory }:
        home-manager.lib.homeManagerConfiguration {
          # Importamos nixpkgs con config propia para permitir paquetes
          # "unfree" (p.ej. claude-code, dotnet-sdk).
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          # Datos que viajan hasta los módulos vía `extraSpecialArgs`.
          extraSpecialArgs = { inherit username homeDirectory; };
          # Toda la configuración vive en ./home (ver home/default.nix).
          modules = [ ./home ];
        };
    in
    {
      homeConfigurations = {
        # --- macOS (Apple Silicon) ---
        "juanm@mac" = mkHome {
          system = "aarch64-darwin";
          username = "juanm";
          homeDirectory = "/Users/juanm";
        };

        # --- Linux (x86_64) ---
        "juanm@linux" = mkHome {
          system = "x86_64-linux";
          username = "juanm";
          homeDirectory = "/home/juanm";
        };
      };
    };
}
