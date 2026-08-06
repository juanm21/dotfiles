# dotfiles

Configuración personal de **macOS (Apple Silicon)** gestionada de forma
**declarativa** con [nix-darwin](https://github.com/nix-darwin/nix-darwin) +
[Home Manager](https://nix-community.github.io/home-manager/) +
[nix-homebrew](https://github.com/zhaofengli/nix-homebrew).

Un solo comando instala programas, apps GUI y deja los dotfiles (zsh, tmux, git,
helix, ghostty) en su sitio.

## Instalación

```sh
git clone https://github.com/juanm21/dotfiles ~/.dotfiles && ~/.dotfiles/bootstrap.sh
```

`bootstrap.sh` instala Nix (Determinate), enlaza el repo a `~/.dotfiles`,
**te pregunta si el usuario configurado es el tuyo** (y reescribe la única línea
`user = ` de `flake.nix` si no lo es), libera `/etc/bashrc` y `/etc/zshrc`, y
hace el primer `darwin-rebuild switch`. Pedirá tu contraseña (`sudo`).

El repo puede vivir en cualquier ruta: los scripts crean el symlink
`~/.dotfiles`, que es por donde se resuelven los enlaces en vivo.

### Si no es tu mac

Tres cosas a revisar antes del primer `./bootstrap.sh`:

- **Usuario**: la única línea `user = "juanm"` de `flake.nix`. `bootstrap.sh`
  detecta tu usuario de macOS y ofrece reescribirla.
- **Arquitectura**: `nixpkgs.hostPlatform` en `configuration.nix`
  (`x86_64-darwin` en un Mac Intel).
- **Label del host** `mac`: vive en **tres** lugares que tienen que coincidir —
  `darwinConfigurations.mac` en `flake.nix`, el `#mac` de `rebuild.sh` y el
  `#mac` del switch de `bootstrap.sh`.

Y leé la advertencia de `cleanup = "zap"` más abajo antes de aplicar nada.

## Validar sin aplicar

Una vez que Nix está instalado, se puede comprobar que la config compila sin
tocar el sistema:

```sh
nix flake check --no-build
nix build .#darwinConfigurations.mac.system --dry-run
```

## Uso diario

Hay dos tipos de cambio:

- **Configs crudas** (`home/`: nvim, helix, ghostty, p10k) → están enlazadas
  **en vivo** al repo. Editás el archivo y el cambio se aplica al instante,
  **sin reconstruir**.
- **Módulos Nix** (`flake.nix`, `configuration.nix`, `home.nix`) → hay que
  re-aplicar:

```sh
cd ~/.dotfiles && ./rebuild.sh     # sudo darwin-rebuild switch --flake ~/.dotfiles#mac
```

Actualizar todo a las últimas versiones:

```sh
cd ~/.dotfiles && nix flake update && ./rebuild.sh
```

## Estructura

```
flake.nix              Inputs (pinneados a 26.05) + la única línea `user = `.
configuration.nix      macOS: defaults del sistema + Homebrew (brews/casks/taps).
home.nix               Usuario: paquetes, zsh, git, tmux y los enlaces en vivo.
home/                  Configs que NO se reescriben en Nix, solo se enlazan.
                       la ruta acá ES la ruta destino.
  .config/nvim/        configuraciones nvim.
  .config/helix/       config.toml, languages.toml, themes/.
  .config/ghostty/config
bootstrap.sh           Primera instalación.
rebuild.sh             Aplica cambios de .nix (uso diario).
```

## ⚠️ Homebrew: `cleanup = "zap"`

`configuration.nix` es la **fuente de verdad** de Homebrew: cada switch
desinstala todo brew, cask o tap que **no** esté declarado ahí. Antes de correr
`./rebuild.sh` después de instalar algo con `brew`, agregalo a la lista o lo vas
a perder.

Para auditar antes de un switch, **no alcanza con `brew leaves`**: se saltea
formulae de taps de terceros. Hay que comparar contra todo lo instalado, menos
la clausura de dependencias de lo declarado:

```sh
nix build .#darwinConfigurations.mac.system   # crea ./result
BF=$(nix-store -qR ./result | grep -- '-Brewfile$' | head -1)
grep -E '^brew ' "$BF" | sed 's/^brew "//;s/".*//' > /tmp/d.txt
brew deps --union $(tr '\n' ' ' < /tmp/d.txt) | sed 's|.*/||' | sort -u > /tmp/dp.txt
comm -23 <(brew list --formula | sed 's|.*/||' | sort -u) \
         <(sed 's|.*/||' /tmp/d.txt | sort -u) | comm -23 - /tmp/dp.txt
```

Si eso imprime algo, `zap` lo va a desinstalar. Repetir con
`brew list --cask` y `brew tap`.

### Taps de terceros

brew 6.x se niega a cargar formulae de taps no oficiales hasta marcarlos
confiables. Eso se declara **acá mismo**, no con `brew trust` a mano:

```nix
taps = [
  { name = "usuario/tap"; trusted = true; }
];
```

nix-darwin emite `tap "usuario/tap", trusted: true` en el Brewfile, así que un
mac nuevo no necesita ningún paso manual. Si un tap se declara como string
pelado, `./rebuild.sh` falla con `Refusing to load formula ... from untrusted
tap`.

## Cómo agregar o quitar una app

Primero busca el paquete: <https://search.nixos.org/packages> o
`nix search nixpkgs <nombre>`. Luego, según el caso:

**1. Programa CLI simple** (ej. `ripgrep`, `htop`)
Añade/quita una línea en `home.nix` → `home.packages`, y `./rebuild.sh`.

**2. App con configuración propia** (ej. git, tmux)
Añade su bloque `programs.<app>` en `home.nix` con su comentario-título. Los
programas con módulo propio están en
<https://nix-community.github.io/home-manager/options.xhtml>.

**3. Dotfile crudo** (config que permite editar como archivo normal)
Deja el archivo en `home/` **en la misma ruta que tendría dentro de `$HOME`**, y
agrega esa ruta a la lista `home.file = linked [ ... ]` de `home.nix`:

```
home/.config/miapp/config   →  ~/.config/miapp/config
home/.miapprc               →  ~/.miapprc
```

```nix
home.file = linked [
  ".config/miapp/config"
  ".miapprc"
];
```

Corre `./rebuild.sh` una vez para crear el symlink; después las ediciones son en
vivo.

**4. App GUI o formula de Homebrew**
Añade a `homebrew.casks` / `homebrew.brews` en `configuration.nix` y
`./rebuild.sh`. Nombres en <https://formulae.brew.sh/>.

**Para quitar** cualquiera: borra su línea/bloque/archivo y aplica.

> Consejo: cambia una cosa a la vez y aplica. Si algo falla, Nix no aplica nada
> (no rompe tu setup actual) y te dice el error.

## Reparto Nix ↔ Homebrew

La regla, para que cada binario tenga un solo dueño:

- **Nix (`home.nix`) es el dueño de las CLI.** Busca primero en
  <https://search.nixos.org/packages>.
- **Homebrew (`configuration.nix`) solo para** lo que no está en nixpkgs
  (`chrome-cli`, `herdr`, `xsv`, el tap propio), lo que
  depende de Homebrew a propósito (`azure-cli` por su script de completado,
  `bash`, `rust`) y las **apps GUI / toolchains** que tienen que instalar en su
  ruta oficial (`dotnet-sdk`, `ghostty`, `docker-desktop`,
  `claude-code`).
- **Fuentes**: `fonts.packages` en `configuration.nix`, no casks `font-*`.

Igual `home.nix` reordena el PATH para dejar `/opt/homebrew` al final, así que
si algún día se cuela un duplicado, gana el de Nix.

## Archivos privados (no versionados)

Creálos a mano en tu `$HOME`; git los referencia pero no van al repo:

- `~/.gitconfig.local` — tu `user.name` / `user.email` y credenciales.
- `~/.gitignore_global` — ignores globales de git.
- `~/.zshrc.local` — escape hatch de zsh. `~/.zshrc` lo genera Home Manager en
  el store y es **read-only**; este archivo es tuyo, escribible, y se sourcea al
  **final** del `.zshrc`, así que lo que pongas acá pisa a Nix. Cuando algo se
  vuelve permanente, muevelo a `home.nix`: alias → `shellAliases`, PATH →
  `home.sessionPath`, resto → `initContent`.
