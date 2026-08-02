# dotfiles

Configuración personal gestionada de forma **declarativa** con Nix.
Cross-platform: **macOS (Apple Silicon)** y **Linux (x86_64)**.

- **macOS** → [nix-darwin](https://github.com/nix-darwin/nix-darwin): sistema +
  apps GUI (casks de Homebrew) + [Home Manager](https://nix-community.github.io/home-manager/).
- **Linux** → Home Manager standalone.

Un solo comando instala programas, apps GUI y deja los dotfiles (zsh, tmux, git,
helix, neovim, ghostty) en su sitio.

## Instalación

```sh
git clone https://github.com/juanm21/dotfiles ~/.dotfiles && cd ~/.dotfiles
./setup.sh
```

`setup.sh` instala Nix (y Homebrew en mac) si faltan, y aplica la configuración
(`mac` o `linux` según el sistema). Se adapta al usuario que ejecuta —no hay
nombres en duro—. En macOS pedirá tu contraseña (`sudo`). Abre una terminal
nueva al final.

## Uso diario

Después de editar cualquier `.nix`, la forma más simple de aplicar es re-correr
el bootstrap (es idempotente y maneja plataforma + sudo + usuario por ti):

```sh
cd ~/.dotfiles && ./setup.sh
```

Equivale, por debajo, a:

```sh
# macOS (sudo preservando tu usuario a través de sudo):
sudo --preserve-env=DOTFILES_USER,DOTFILES_HOME \
  darwin-rebuild switch --impure --flake ~/.dotfiles#mac
# Linux:
home-manager switch --impure --flake ~/.dotfiles#linux
```

> `--impure` es necesario: la config lee tu usuario/HOME del entorno para
> adaptarse a cualquiera. `setup.sh` exporta `DOTFILES_USER`/`DOTFILES_HOME`
> para que sobrevivan a `sudo`.

Actualizar todo a las últimas versiones:

```sh
cd ~/.dotfiles
nix flake update          # actualiza nixpkgs/nix-darwin/home-manager (flake.lock)
./setup.sh
```

## Estructura

```
flake.nix          Punto de entrada: inputs + salidas mac (darwin) / linux.
darwin.nix         macOS: casks GUI (Homebrew) + integración de Home Manager.
home/              Config de usuario (compartida mac + Linux):
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

**4. App GUI de macOS** (cask de Homebrew, ej. una app que no está en nixpkgs)
Añade el cask a `homebrew.casks` en `darwin.nix` y `./setup.sh`. Busca el nombre
en <https://formulae.brew.sh/cask/>. (En Linux, las apps GUI que sí están en
nixpkgs van en `home/packages.nix` con guard `isLinux`.)

**Para quitar** cualquiera: borra su línea/módulo/archivo/cask y aplica.

> Consejo: cambia una cosa a la vez y aplica. Si algo falla, Nix no aplica nada
> (no rompe tu setup actual) y te dice el error.

## Apps GUI y casos especiales

- **macOS — Ghostty y Docker Desktop**: se instalan por `darwin.nix`
  (`homebrew.casks`). En Linux van por Nix (`home/packages.nix`).
- **No están en nixpkgs ni como cask aquí**: `chrome-cli` (macOS), `omlx`
  (tap propio), `mono-mdk` (usa `mono`, ya incluido). Instálalos a mano o agrega
  el cask/formula si los necesitas.
- **Fuentes en macOS**: JetBrains Mono y MesloLGS NF (Powerlevel10k) se instalan
  como casks de Homebrew en `darwin.nix` (`font-jetbrains-mono`,
  `font-meslo-lg-nerd-font`). En Linux van por Nix (`home/packages.nix`).

## Archivos privados (no versionados)

Créalos a mano en tu `$HOME`; git los referencia pero no van al repo:

- `~/.gitconfig.local` — tu `user.name` / `user.email` y credenciales.
- `~/.gitignore_global` — ignores globales de git.
