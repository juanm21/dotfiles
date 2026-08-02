{
  # ============================================================================
  # flake.nix — punto de entrada.
  #
  #   macOS → darwinConfigurations.mac  (nix-darwin: sistema + casks Homebrew +
  #           Home Manager, todo con `darwin-rebuild switch`).
  #   Linux → homeConfigurations.linux  (Home Manager standalone).
  #
  # El usuario/HOME NO van en duro: se leen del entorno (con --impure). Bajo
  # `sudo` (darwin-rebuild) $USER se pierde, por eso setup.sh exporta también
  # DOTFILES_USER/DOTFILES_HOME y aquí se prefieren esas.
  # ============================================================================
  description = "Dotfiles personales — nix-darwin + Home Manager (macOS + Linux)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nix-darwin, ... }:
    let
      # Primer valor no vacío entre varias variables de entorno.
      firstEnv = names:
        let vals = builtins.filter (s: s != "") (map builtins.getEnv names);
        in if vals == [ ] then "" else builtins.head vals;

      user =
        let v = firstEnv [ "DOTFILES_USER" "USER" ];
        in if v != "" then v
        else throw "Falta el usuario: aplica con --impure (usa ./setup.sh).";
      home =
        let v = firstEnv [ "DOTFILES_HOME" "HOME" ];
        in if v != "" then v
        else throw "Falta el HOME: aplica con --impure (usa ./setup.sh).";
    in
    {
      # --- macOS ---
      darwinConfigurations.mac = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit user home; };
        modules = [
          home-manager.darwinModules.home-manager
          ./darwin.nix
        ];
      };

      # --- Linux ---
      homeConfigurations.linux = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [
          ./home
          {
            home.username = user;
            home.homeDirectory = home;
          }
        ];
      };
    };
}
