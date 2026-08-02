{ pkgs, ... }:
{
  # ============================================================================
  # home/git.nix — configuración de git. Reemplaza a ~/.gitconfig.
  #
  # user.name / user.email NO van aquí: viven en ~/.gitconfig.local (privado,
  # fuera del repo). Lo mismo ~/.gitignore_global.
  # ============================================================================
  programs.git = {
    enable = true;
    # gitFull incluye git-gui y gitk (el `git` normal de nixpkgs no los trae).
    package = pkgs.gitFull;

    settings = {
      core = {
        autocrlf = false;
        whitespace = "cr-at-eol";
        excludesfile = "~/.gitignore_global";
        editor = "hx";
      };
      pull.rebase = false;
      init.defaultBranch = "main";
    };

    # Incluye tu config privada de la máquina (user, credenciales, etc.).
    includes = [ { path = "~/.gitconfig.local"; } ];
  };
}
