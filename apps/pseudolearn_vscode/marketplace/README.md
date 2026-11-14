# PseudoLearn para VS Code · PseudoLearn for VS Code

[Español](#español) · [English](#english)

## Español

Escribe, comprueba, ejecuta y depura programas de PseudoLearn (archivos `.pseudo`) sin salir del editor: resaltado de
sintaxis, errores mientras escribes, ayuda en el cursor, ejecución con entrada por teclado y depuración.

> No envía telemetría. Se actualiza como cualquier extensión de la tienda de tu editor.

### Qué incluye

- **Resaltado y edición** de archivos `.pseudo`, con el vocabulario en español o en inglés.
- **Ícono en el explorador**: elige *PseudoLearn Icons* en «Tema de íconos de archivo» (`Cmd+K Cmd+M`).
- **Errores y advertencias** a medida que escribes, también en el panel «Problemas».
- **Navegación y renombrado**: ir a la definición, buscar referencias, símbolos y renombrar en todos los módulos.
- **Ayuda en el cursor**: pasa el ratón sobre una palabra o pulsa `Cmd+K Cmd+E` (`Ctrl+K Ctrl+E` en Windows y Linux).
- **Ejecución** de un archivo suelto o de un proyecto con varios módulos; `Leer` abre un cuadro de entrada.
- **Depuración** con puntos de parada, pasos, tareas como hilos y paso atrás, en escritorio y en el navegador.
- **Traducción del vocabulario** de un archivo entre español e inglés, como una sola edición que se puede deshacer.
- **Asistentes de código** (solo escritorio): herramientas para que Copilot y el chat comprueben y ejecuten programas.

### Requisitos e instalación

Busca **PseudoLearn** en la vista «Extensiones» e instálala. VS Code la descarga del Visual Studio Marketplace; Cursor,
VSCodium y otros editores compatibles, de Open VSX. También puedes instalarla desde la terminal:

```bash
code --install-extension pseudolearn.pseudolearn-vscode
```

Requiere VS Code Stable 1.144.0 o superior. El editor elige solo el paquete de tu plataforma:

| Plataforma                         | Herramientas extra                        |
|------------------------------------|-------------------------------------------|
| macOS con Apple silicon            | Ninguna: el paquete trae `pseudo`         |
| Windows x64                        | Ninguna: el paquete trae `pseudo.exe`     |
| Linux x64                          | Ninguna: el paquete trae `pseudo` estático |
| VS Code para la Web                | Ninguna: la VM corre como Wasm            |

macOS con procesador Intel y Linux ARM aún no tienen paquete de escritorio.

### Primeros pasos

1. Crea `saludo.pseudo`:

   ```
   Algoritmo Saludo
    Definir nombre Como Cadena;
    Escribir "Como te llamas?";
    Leer nombre;
    Escribir "Hola " + nombre;
   FinAlgoritmo
   ```

2. Guárdalo y pulsa ▷ en la barra del editor (o `PseudoLearn: Run File`). Escribe tu nombre en el cuadro que aparece.
3. La salida aparece en el canal `PseudoLearn` de la vista «Salida». Para depurar, usa `Debug File`.

El programa debe estar guardado: con cambios sin guardar no se ejecuta ni se depura.

### Comandos

| Comando                        | Qué hace                                                                     |
|--------------------------------|------------------------------------------------------------------------------|
| `Run File` / `Run Project`     | Ejecuta el archivo activo o el proyecto de la primera carpeta                |
| `Debug File` / `Debug Project` | Depura el archivo o el proyecto                                              |
| `Select Project Entry`         | Elige qué módulo arranca el proyecto                                         |
| `Stop Run`                     | Detiene la ejecución en curso                                                |
| `Explain at Cursor`            | Muestra la ayuda de la posición del cursor                                   |
| `Translate Vocabulary`         | Pasa el vocabulario del archivo a español o a inglés                         |
| `Create Agent Instructions`    | Crea instrucciones para asistentes de código, sin sobrescribir (escritorio)  |
| `Restart Language Server`      | Reinicia el servidor de lenguaje                                             |

### Ajustes

| Ajuste                          | Valores                  | Para qué sirve                                       |
|---------------------------------|--------------------------|------------------------------------------------------|
| `pseudolearn.profile`           | `es` (por omisión), `en` | Vocabulario con el que se analizan los archivos      |
| `pseudolearn.interfaceLanguage` | `es` (por omisión), `en` | Idioma de los mensajes y diagnósticos                |

### Límites reales por plataforma

Los programas tienen autoridad plena: archivos, red a cualquier destino `http`/`https` con TLS validado, reloj,
temporizador, argumentos y entorno. Lo que no se puede es lo que la propia plataforma impide:

| Plataforma                     | Estado                                   | Límite de la plataforma                                                                                         |
|--------------------------------|------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| Escritorio macOS (Apple silicon) | Verificada                             | Un espacio de trabajo no confiable (Modo restringido) solo resalta; no ejecuta                                  |
| Escritorio Windows x64         | Empaquetada y `pseudo.exe` ejecutado en Windows; la extensión dentro de VS Code no se ha verificado | Igual que macOS; rutas con letra de unidad, `\` y `\\?\`                    |
| Navegador (Chromium, WebKit)   | Verificada                               | CORS; contenido mixto; cabeceras prohibidas; las redirecciones las sigue el navegador; solo archivos del espacio de trabajo; sin variables de entorno (`permiso_denegado`); sin compilación nativa |
| Navegador Firefox y teléfonos  | No verificada                            | Mismos límites que el navegador; uso en teléfono no garantizado                                                 |

### Seguridad

- Los programas se ejecutan con los permisos de tu usuario: pueden leer y escribir archivos y usar la red. Ejecuta solo
  código en el que confíes.
- La entrada que escribes no se registra.

### Licencia

Apache-2.0. Los avisos de las dependencias incluidas están en `third-party-notices.md`, dentro del paquete.

## English

Write, check, run and debug PseudoLearn programs (`.pseudo` files) without leaving the editor: syntax highlighting,
errors as you type, help at the cursor, runs with keyboard input and debugging.

> It sends no telemetry. It updates like any other extension from your editor's store.

### What it includes

- **Highlighting and editing** of `.pseudo` files, with Spanish or English vocabulary.
- **Explorer icon**: pick *PseudoLearn Icons* under “File Icon Theme” (`Cmd+K Cmd+M`).
- **Errors and warnings** as you type, also in the “Problems” panel.
- **Navigation and rename**: go to definition, find references, symbols and rename across every module.
- **Help at the cursor**: hover a word or press `Cmd+K Cmd+E` (`Ctrl+K Ctrl+E` on Windows and Linux).
- **Runs** of a single file or a multi-module project; `Read` opens an input box.
- **Debugging** with breakpoints, steps, tasks as threads and step back, on the desktop and in the browser.
- **Vocabulary translation** of a file between Spanish and English, as one undoable edit.
- **Coding assistants** (desktop only): tools that let Copilot and chat check and run programs.

### Requirements and installation

Search for **PseudoLearn** in the Extensions view and install it. VS Code downloads it from the Visual Studio
Marketplace; Cursor, VSCodium and other compatible editors, from Open VSX. You can also install it from a terminal:

```bash
code --install-extension pseudolearn.pseudolearn-vscode
```

Requires VS Code Stable 1.144.0 or later. The editor picks the package for your platform:

| Platform                           | Extra tools                               |
|------------------------------------|-------------------------------------------|
| macOS on Apple silicon             | None: the package ships `pseudo`          |
| Windows x64                        | None: the package ships `pseudo.exe`      |
| Linux x64                          | None: the package ships a static `pseudo` |
| VS Code for the Web                | None: the VM runs as Wasm                 |

Intel macOS and Linux ARM have no desktop package yet.

### First steps

1. Create `hello.pseudo`:

   ```
   algorithm Hello
    define name as string;
    write "What is your name?";
    read name;
    write "Hello " + name;
   endAlgorithm
   ```

2. Save it and press ▷ in the editor bar (or `PseudoLearn: Run File`). Type your name in the box that appears.
3. Output goes to the `PseudoLearn` channel of the “Output” view. To debug, use `Debug File`.

The program must be saved: with unsaved changes it neither runs nor debugs.

### Commands

| Command                        | What it does                                                                 |
|--------------------------------|------------------------------------------------------------------------------|
| `Run File` / `Run Project`     | Runs the active file or the project of the first folder                      |
| `Debug File` / `Debug Project` | Debugs the file or the project                                               |
| `Select Project Entry`         | Chooses which module starts the project                                      |
| `Stop Run`                     | Stops the current run                                                        |
| `Explain at Cursor`            | Shows the help for the cursor position                                       |
| `Translate Vocabulary`         | Converts the file vocabulary to Spanish or English                           |
| `Create Agent Instructions`    | Creates instructions for coding assistants, never overwriting (desktop)      |
| `Restart Language Server`      | Restarts the language server                                                 |

### Settings

| Setting                         | Values                  | Purpose                                              |
|---------------------------------|-------------------------|------------------------------------------------------|
| `pseudolearn.profile`           | `es` (default), `en`    | Vocabulary used to analyse the files                 |
| `pseudolearn.interfaceLanguage` | `es` (default), `en`    | Language of messages and diagnostics                 |

### Real limits per platform

Programs have full authority: files, network to any `http`/`https` destination with validated TLS, clock, timer,
arguments and environment. What they cannot do is what the platform itself forbids:

| Platform                       | Status                                   | Platform limit                                                                                                  |
|--------------------------------|------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| macOS desktop (Apple silicon)  | Verified                                 | An untrusted workspace (Restricted Mode) only highlights; it never runs code                                    |
| Windows x64 desktop            | Packaged and `pseudo.exe` run on Windows; the extension inside VS Code is not verified | Same as macOS; drive-letter, `\` and `\\?\` paths                                |
| Browser (Chromium, WebKit)     | Verified                                 | CORS; mixed content; forbidden headers; the browser follows redirects; workspace files only; no environment variables (`permiso_denegado`); no native build |
| Firefox and phones             | Not verified                             | Same limits as the browser; phone use is not guaranteed                                                         |

### Security

- Programs run with your user's permissions: they can read and write files and use the network. Only run code you
  trust.
- The input you type is never logged.

### License

Apache-2.0. Notices for the bundled dependencies are in `third-party-notices.md`, inside the package.
