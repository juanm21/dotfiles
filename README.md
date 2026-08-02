# dotfiles

Configuración personal gestionada de forma **declarativa** con
[Nix](https://nixos.org) + [Home Manager](https://nix-community.github.io/home-manager/).
Cross-platform: **macOS (Apple Silicon)** y **Linux (x86_64)**.

Un solo comando instala programas y deja los dotfiles (zsh, tmux, git, helix,
neovim, ghostty) en su sitio. Nada de symlinks a mano ni de Homebrew.

## Instalación

```sh
git clone <este-repo> ~/.dotfiles && cd ~/.dotfiles
./setup.sh
```

`setup.sh` instala Nix si falta, habilita flakes y aplica la configuración
(`mac` o `linux` según el sistema). Se adapta al usuario que ejecuta —no hay
nombres en duro—. Abre una terminal nueva al final.

## Uso diario

Después de editar cualquier archivo `.nix`, aplica los cambios:

```sh
home-manager switch --impure --flake ~/.dotfiles#mac    # macOS
home-manager switch --impure --flake ~/.dotfiles#linux  # Linux
```

> `--impure` es necesario: la config lee `$USER` y `$HOME` del entorno para
> adaptarse a cualquier usuario. Sin él verás un error pidiéndolo.

Actualizar todo a las últimas versiones:

```sh
cd ~/.dotfiles
nix flake update          # actualiza nixpkgs (flake.lock)
home-manager switch --impure --flake .#mac
```

## Estructura

```
flake.nix          Punto de entrada: inputs (nixpkgs, home-manager) + máquinas.
home/
  default.nix      Módulo raíz: importa el resto y enlaza los configs crudos.
  packages.nix     Lista de programas instalados.
  shell.nix        Zsh + Powerlevel10k + fzf + zoxide + bat.
  git.nix          git.
  tmux.nix         tmux + plugins.
config/            Configs que NO se reescriben en Nix, solo se enlazan:
  nvim/            LazyVim.
  helix/           config.toml, languages.toml, themes/.
  ghostty/config
  p10k.zsh         Prompt (generado con `p10k configure`).
setup.sh           Bootstrap.
```

## Cómo agregar o quitar una app

Primero busca el paquete: <https://search.nixos.org/packages> o
`nix search nixpkgs <nombre>`. Luego, según el caso:

**1. Programa CLI simple** (ej. `ripgrep`, `htop`)
Añade/quita una línea en `home/packages.nix` → `home.packages`, y `switch`.

**2. App con configuración propia** (ej. git, tmux)
Crea `home/<app>.nix` con su módulo `programs.<app>`, impórtalo en la lista
`imports` de `home/default.nix`, y `switch`. Los programas con módulo propio en
Home Manager están en <https://nix-community.github.io/home-manager/options.xhtml>.

**3. Dotfile crudo** (config que prefieres editar como archivo normal)
Pon el archivo en `config/` y enlázalo en `home/default.nix`:

```nix
xdg.configFile."miapp/config".source = ../config/miapp/config;  # → ~/.config/miapp/config
home.file.".miapprc".source = ../config/miapprc;                # → ~/.miapprc
```

**Para quitar** cualquiera: borra su línea/módulo/archivo y `switch`.

> Consejo: cambia una cosa a la vez y corre `switch`. Si algo falla, Nix no
> aplica nada (no rompe tu setup actual) y te dice el error.

## Apps que van aparte (no por Nix)

- **macOS — Ghostty y Docker Desktop**: se instalan como app nativa
  ([ghostty.org](https://ghostty.org), Docker Desktop). En Linux sí van por Nix
  (`home/packages.nix`).
- **No están en nixpkgs**: `chrome-cli` (macOS), `omlx` (tap propio),
  `mono-mdk` (usa `mono`, ya incluido). Instálalos a mano si los necesitas.
- **Fuentes en macOS**: si "MesloLGS NF" / JetBrains Mono no aparecen tras el
  `switch`, instálalas desde `~/.nix-profile/share/fonts` o descárgalas.

## Archivos privados (no versionados)

Créalos a mano en tu `$HOME`; git los referencia pero no van al repo:

- `~/.gitconfig.local` — tu `user.name` / `user.email` y credenciales.
- `~/.gitignore_global` — ignores globales de git.
