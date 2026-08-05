# Notas para agentes

Decisiones deliberadas de este repo. **No revertirlas en silencio**: si algo de
esto parece un error, es porque resuelve un problema que no se ve en el archivo.

- **`homebrew.onActivation.cleanup = "zap"`** (`configuration.nix`) es
  intencional: obliga a declarar cada paquete de Homebrew en Nix en vez de
  instalarlo a mano, que es lo que mantiene la máquina reproducible. No
  suavizarlo a `uninstall` ni a `none`. El README ya advierte al usuario sobre
  su efecto; esta nota es para quien esté tentado de cambiar la opción.

- **`homebrew.taps` usa `{ name = "..."; trusted = true; }`**, no strings
  pelados. Sin `trusted`, brew 6.x se niega a cargar formulae de taps no
  oficiales y la activación aborta. Declararlo acá evita tener que tocar
  `trust.json` a mano en cada mac nuevo.

- **El reordenamiento de PATH en `brewInit`** (`home.nix`) es la razón de que
  Nix le gane a Homebrew. Corre en `.zprofile` **y** en `.zshrc` a propósito:
  nix-homebrew inyecta su propio `eval "$(brew shellenv)"` en `/etc/zshrc`, que
  se ejecuta **después** de `.zprofile` y vuelve a anteponer `/opt/homebrew`.

- **`mssql-tools18` va con `link = false`** y su `bin` se agrega al **final** del
  PATH en `initContent`. Trae un `sqlcmd` clásico (sobre ODBC) que chocaría con
  el `sqlcmd` de Nix (go-sqlcmd); lo único que queremos de esa formula es `bcp`.
  Ese bloque tiene que ir **después** de `brewInit`, que también reordena el PATH.

- **Mono lo aporta el cask `mono-mdk`, no una formula ni un paquete de Nix.** El
  cask instala el framework en `/Library/Frameworks` pero **no enlaza nada a
  `/usr/local/bin`**, así que `monoInit` (`home.nix`) agrega su `bin` al final
  del PATH. Si se borra ese bloque, `mono`, `mcs`, `csc` y `msbuild` desaparecen
  del PATH aunque el cask siga instalado. Va al final a propósito: son ~290
  binarios que taparían a los del SDK de .NET y a los de Nix.

- **El orden de los bloques de `programs.zsh.initContent`** es lógica, no
  estética: `mkBefore`=500 (instant prompt de p10k), `mkOrder 550` (fpath, antes
  del compinit), oh-my-zsh y su compinit=800, bloques sin envolver=1000 (el
  completado de `az` necesita `bashcompinit`, que exige el compinit hecho),
  `mkAfter`=1500 (`~/.zshrc.local`, que pisa a Nix).

- **Homebrew es solo para lo que no está en nixpkgs o son apps GUI.** Las CLI son
  de Nix. Antes de agregar una formula, buscar el paquete en
  <https://search.nixos.org/packages>.

- **`~/.zshrc.local` NO se gestiona con Home Manager** a propósito: es el escape
  hatch escribible del usuario y vive fuera del repo. `home.nix` solo lo sourcea
  si existe.

## Mantener este archivo

Solo conocimiento útil para casi cualquier sesión futura en este repo. No
repetir lo que el código ya muestra; apuntar al archivo o comando autoritativo.
Preferir reescribir o podar entradas antes que acumular nuevas.
