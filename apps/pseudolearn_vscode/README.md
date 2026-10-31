# pseudolearn_vscode

## 1. Qué es y qué no es

Extensión privada de escritorio que integra PseudoLearn con VS Code. Se distribuye para uso local mediante F5 durante el desarrollo y archivos VSIX instalados manualmente. El primer artefacto calificado es para macOS Apple silicon (`darwin-arm64`). El paquete incluye el ejecutable `pseudo` para ese destino; no busca ejecutables en el workspace ni descarga binarios al activar.

El código propio está reservado para uso local y no se concede una licencia abierta. El empaquetado genera `third-party-notices.md` desde el grafo Cargo específico del binario incluido y conserva los textos de licencia disponibles junto a la lista SPDX de dependencias. La extensión no se publica en Marketplace ni Open VSX.

El servidor LSP de proyecto expone navegación, diagnósticos relacionados, símbolos, `prepareRename`/`rename` y tokens semánticos `full` solo bajo las garantías negociadas. Para renombrar en varias fuentes, el cliente materializa y sincroniza los documentos cerrados, recalcula la selección y las referencias y aplica una edición versionada en una sola transacción. El transporte limita cabeceras a 8 KiB y cuerpos a 8 MiB. La configuración declarativa permite perfil y rigor de workspace, idioma de interfaz personal y una ruta absoluta de desarrollo para el servidor; el workspace no selecciona ejecutables ni concede permisos. Los recursos TextMate y de lenguaje se generan desde la exportación SEE.

Fuera de alcance de este incremento: depuración, plataformas no calificadas, workspace remoto, workspace virtual, actualizaciones automáticas, telemetría y publicación. No se incluye migrador ni selector de compatibilidad: cada edición se ofrece como la oficial aunque introduzca cambios incompatibles. VS Code y el cliente LSP completo siguen siendo una verificación de host separada.

## 2. Guía operativa y ciclo de vida

Usa Node.js 22.23.3, pnpm 12.8.1, TypeScript 6.0.3, VS Code API 1.144.0 y `@vscode/vsce` 4.0.0. TextMate 9.3.2 y Oniguruma 1.7.0 tokenizan la gramática en pruebas. `vscode-languageclient` se fija en 10.1.2 para el cliente LSP fino de la siguiente etapa. El mínimo de VS Code es `^1.144.0`. La versión `0.1.0` identifica este artefacto de extensión, no una versión del lenguaje.

La activación valida `pseudolearn.profile` y `pseudolearn.strictness` desde workspace, y `pseudolearn.interfaceLanguage` desde el usuario. `pseudolearn.server.path` acepta únicamente una ruta absoluta de usuario en desarrollo confiable; Restricted Mode y cualquier valor de workspace la rechazan. El binario incluido es la ruta predeterminada. La activación inicia el cliente LSP (`vscode-languageclient/node`) con el ejecutable resuelto y el argumento `lsp`, con entorno vacío; el ciclo es acotado (tres arranques fallidos consecutivos y parada con plazo de 2 s) y `PseudoLearn: Restart Language Server` lo reinicia con el presupuesto restablecido. El cliente entrega `profile`, `strictness` y el idioma como `initializationOptions`; la CLI carga el workspace por su cuenta (ver README de la CLI). El ejecutable se lanza como `Executable` simple (`pseudo lsp`): el modo `TransportKind.stdio` del SDK añade `--stdio`, que `pseudo` rechaza. El servidor anuncia el comando `pseudolearn.explain` y el SDK lo registra en el host; por eso el comando propio de la extensión se llama `pseudolearn.explainAtCursor` y no colisiona. Para empaquetado de desarrollo, `PSEUDOLEARN_PSEUDO_PATH` selecciona el archivo de entrada del empaquetador y no es una configuración de workspace ni una opción de ejecución. El empaquetado ordinario compila e incluye el binario `darwin-arm64`. El VSIX usa el binario incluido, sin red ni toolchains en tiempo de ejecución.

F5 requiere el checkout y la cadena de construcción; una instalación VSIX coincidente requiere VS Code Stable para macOS Apple silicon y no requiere Cargo, Rust, Node ni pnpm. En otra plataforma el artefacto no está calificado. La instalación y actualización son manuales: conservar el VSIX anterior permite revertir reinstalándolo. No hay actualización automática.

## 3. Arquitectura y modelo del sistema

Las capas son `contracts`, `application`, `adapters` y `activation`. `contracts` declara puertos y datos; `application` implementa casos de uso sobre esos puertos; `adapters` integra VS Code, Node y el proceso Rust; `activation` compone las capas y registra sus recursos. La dirección de imports está declarada en `architecture.json` y se verifica localmente.

TypeScript no implementa parser, resolución semántica, gramática ni políticas de proyecto. Los contratos observables pertenecen al corpus; Rust es el único analizador y servicio semántico. La activación compone los puertos y registra los comandos; la lógica de ejecución, entrada, cancelación y traducción vive en `application` y se prueba con procesos y documentos falsos.

El bundle de producción reúne el código JavaScript y sus dependencias runtime. El VSIX incluye solo el bundle, recursos generados, el binario del target declarado, metadata, README, aviso de derechos y avisos de licencias del binario; excluye fuentes, tests, fixtures, scripts de verificación, secretos, mapas y `node_modules`.

## 4. Decisiones de diseño y fundamentos técnicos

La extensión vive en `apps/` porque es un producto distribuible y no una biblioteca. Node/pnpm son una cadena declarada para este miembro; no se importan reglas ni verificadores del frontend. TypeScript no puede elegir rutas de proyecto, leer fuera de raíces autorizadas ni ejecutar un shell.

La activación y desactivación son idempotentes. Los recursos se registran en un `Disposable` de composición y los errores esperables salen por resultados tipados. El proceso y los puertos son dependencias inyectadas para que las pruebas no necesiten VS Code ni el binario. La resolución distingue la configuración de workspace de las preferencias globales: solo perfil y rigor aceptan valores del workspace; idioma de interfaz y ruta del ejecutable se leen del usuario. La ruta del servidor solo se habilita en desarrollo confiable, debe ser absoluta y nunca procede de `.vscode/settings.json`.

TextMate se genera desde las definiciones léxicas, la política de plegado español y el vocabulario exportado por SEE. El hash de la exportación queda dentro de la gramática generada. Sus patrones son deliberadamente tolerantes; no identifican símbolos ni deciden validez. El parser y el servicio Rust deciden ambas cosas. `pnpm generate:grammar` actualiza los recursos y `pnpm check:grammar` detecta diferencias sin escribirlas. Las pruebas ejecutan los patrones con `vscode-textmate` y `vscode-oniguruma`.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés y sin comentarios. README y documentación en español. Cada archivo tiene una responsabilidad y reside en una capa declarada. Límites: 300 líneas por archivo, 40 por función, cuatro parámetros posicionales, anidación de tres niveles y siete métodos públicos por clase. Los verificadores propios rechazan imports inversos, capas no declaradas, comentarios fuera de cadenas, tamaños excedidos, secretos y contenido de paquete excluido.

## 6. Verificación y testing

Desde este directorio:

- `pnpm install --frozen-lockfile`
- `pnpm check:types`
- `pnpm check:architecture`
- `pnpm check:comments`
- `pnpm check:size`
- `pnpm check:package`
- `pnpm test`
- `pnpm build`
- `pnpm build:cli`
- `pnpm package`
- `node tests/host/run-host.mjs trusted [vsix]` y `node tests/host/run-host.mjs restricted [vsix]` (host real)
- `node tests/host/replay-transcript.mjs <directorio-transcripción> <pseudo>`

Los tests reflejan `src/` bajo `tests/`. Los verificadores tienen fixtures positivos y negativos; los tests de activación usan puertos falsos. `pnpm package` crea un VSIX local para macOS Apple silicon, genera los avisos del binario desde `cargo metadata` y valida su lista de contenidos. F5 y la instalación local del VSIX en VS Code Stable 1.144.0 son verificaciones del host, no publicación. `tests/host/run-host.mjs` instala el VSIX en directorios de usuario y extensiones aislados (ruta con espacios y acentos, `PATH` reducido a `/usr/bin:/bin`, sin Cargo, Node ni checkout en el entorno) y abre VS Code con `--extensionTestsPath`. El modo `restricted` no desactiva Workspace Trust. El modo `trusted` usa `--disable-workspace-trust`, el mecanismo de VS Code para automatización: sembrar la confianza en `state.vscdb` no surtió efecto en 1.144.0 y la única forma de ejecutar programas en el host de pruebas es que el workspace sea de confianza. Con `PSEUDOLEARN_HOST_TRANSCRIPT=<dir>` el servidor configurado es un envoltorio que copia el tráfico LSP, y `replay-transcript.mjs` reenvía los mensajes del cliente A a un `pseudo lsp` nuevo, esperando cada respuesta, y exige respuestas y diagnósticos finales idénticos. Límites: el cuadro de entrada de `Leer` y el selector de entrada se accionan solo con comandos del workbench; escribir un valor concreto en el cuadro de entrada es una comprobación manual.

## 7. Comandos, ejecución interactiva y ayuda

Todos los comandos están bajo la categoría `PseudoLearn` en la paleta. Los IDs son estables.

| ID | Qué hace |
|---|---|
| `pseudolearn.runFile` | Ejecuta el archivo `.pseudo` activo guardado con `pseudo ejecutar --editor` |
| `pseudolearn.runProject` | Ejecuta el proyecto de la primera carpeta del workspace con la entrada elegida |
| `pseudolearn.selectEntry` | Elige el punto de entrada entre los módulos que informa `pseudo comprobar --json --proyecto`; se guarda en el estado del workspace |
| `pseudolearn.stopRun` | Solicita cancelación a la sesión activa |
| `pseudolearn.explainAtCursor` | Muestra la ayuda de la posición del cursor; teclado `Cmd+K Cmd+E` (`Ctrl+K Ctrl+E`) y paleta |
| `pseudolearn.translate` | Traduce el vocabulario del archivo guardado a `es` o `en` como una sola edición deshacible |
| `pseudolearn.restartServer` | Reinicia el cliente LSP |

**Ejecución.** Se lanza `pseudo ejecutar --editor` sin shell, con argumentos como lista (rutas con espacios o metacaracteres
llegan intactas) y con entorno vacío; los idiomas, el perfil y el rigor salen de la configuración resuelta. Solo hay una sesión
activa: una segunda ejecución se rechaza con un mensaje hasta que termine o se detenga. Ejecutar exige el snapshot guardado
de la raíz o del archivo; con cambios sin guardar se rechaza y no se ejecuta una versión distinta de la que se ve. Comprobar y
la navegación usan el overlay del editor a través del LSP. La salida de `Escribir` permanece intacta en el canal `PseudoLearn`.
Los diagnósticos se agrupan y ordenan por archivo, línea y columna; en proyectos la ruta es relativa a la raíz. Cada error muestra
el mensaje original del catálogo y, cuando se puede leer el archivo, su línea y un subrayado. Se muestran hasta 20 errores y una
línea indica cuántos quedan ocultos. Los errores, advertencias e información también se publican en «Problemas» con sus rangos.
Los campos JSON de cada diagnóstico van solo a `PseudoLearn (technical)`, con un límite de 40 registros, 2 KiB por registro y
32 KiB por evento. Un archivo borrado, binario, ilegible o mayor a 1 MiB conserva línea y columna, pero no el fragmento.

Las posiciones `line` y `column` del evento son base 1 y cuentan escalares Unicode, como define `LANG.SOURCE.POSITION`.
La comprobación con `pseudo run --editor` y `missingBindingInitializer` en `    Definir nombre Como Cadena;` informó línea 2,
columna 31, sobre el punto y coma. El marco separa CRLF, expande tabuladores según `editor.tabSize`
y adapta escalares suplementarios a unidades UTF-16 al publicar rangos en VS Code.

El resumen usa el evento `finished`: con errores informa que el programa no se ejecutó; solo `completed` sin errores dice
«Ejecución completada». Cancelación, cierre de entrada, aborto del anfitrión y fallo del anfitrión tienen mensajes separados.
Las líneas no reconocidas permanecen en el canal técnico; las líneas de salida no se interpretan como eventos. El JSON de
diagnósticos nunca se presenta como salida del estudiante. La barra de estado muestra el estado de la sesión.

**Entrada.** `awaiting_input` abre un cuadro de entrada: aceptar con texto vacío envía una línea vacía, mientras que cancelar
el cuadro envía `cancel` y no una cadena vacía. El canal se muestra conservando el foco y `showInputBox` recibe el texto; la
recepción de texto se verifica manualmente en el Extension Development Host. **Detener** envía `cancel` y, si el proceso no responde en 5 s, lo termina
(`SIGKILL`) y lo presenta como «abortado por el anfitrión», sin inventar limpieza del lenguaje. Cerrar la ventana o desactivar
la extensión envía `close` y termina el proceso propio; ningún proceso ajeno se toca. Las líneas de una sesión anterior que
llegan tarde se ignoran. Un `hello` con otro `schema` aborta la sesión. No se concede ningún archivo ni red.

**Ayuda.** El hover estándar lo contesta el servidor LSP y `pseudolearn.explainAtCursor` envía `workspace/executeCommand` con la
versión del documento y formato `plaintext`: el resultado es el mismo contenido y rango que el hover, y un documento cambiado
responde `ContentModified`, que se presenta como «repite la consulta». La prosa de la ficha viene siempre del catálogo
(`TOOL.SERVICE.CATALOG`); la extensión solo localiza sus propias etiquetas de interfaz (es/en) y no guarda ninguna tabla de
fichas, lo que verifica la auditoría de fuente única, que recorre `src/` de este miembro. El hover se muestra como Markdown
no confiable que gestiona el cliente LSP (sin HTML, enlaces de comando ni ejecución de ejemplos) y `explain` se muestra como
texto plano en el canal `PseudoLearn Help`. Sin ayuda en la posición se informa «No hay ayuda en esta posición».

**Límites y pendientes declarados.** `pseudolearn.translate` usa la CLI sobre el archivo guardado y reemplaza el documento
completo solo si su versión no cambió; una colisión de traducción no escribe nada. El formato usa el proveedor LSP estándar.
La verificación en host real (completar, diagnosticar, navegar, renombrar, ejecutar con entrada, detener y limpieza tras
cierre) y la ayuda desde un segundo cliente quedan para las verificaciones pesadas `PG-6A.07.07` y `PG-6A.08.07`.

## 8. Contrato del artefacto local

`artifact.contract.json` es el único dato que fija el artefacto: identidad `pseudolearn.pseudolearn-vscode` versión `0.1.0`
(identifica el paquete, no una versión del lenguaje), VS Code mínimo `^1.144.0` (Stable), target `darwin-arm64`
(`aarch64-apple-darwin` en Cargo), ejecutable `bin/darwin-arm64/pseudo`, gramática y configuración de lenguaje generadas,
bundle `dist/extension.js`, licencia reservada (`LICENSE.md`) y SHA-256 como algoritmo de hash. Solo se afirma la plataforma
de la que se dispone para ensayo real; ninguna otra tiene soporte declarado.

- **Construcción por scripts, cada paso con un dueño.** `pnpm build:cli` (`scripts/build-cli.mjs`) ejecuta
  `cargo build --locked --release --target aarch64-apple-darwin` en `apps/pseudolearn_cli`, copia el binario y escribe
  `.artifacts/provenance.json` (revisión Git y si el árbol estaba sucio, `rustc`, `cargo`, `node`, target y hashes del binario y
  de la gramática). Cargo se ejecuta en la CLI y nunca como toolchain interna de TypeScript. `pnpm build` comprueba que la
  gramática esté vigente y genera el bundle. `pnpm package` encadena ambos y `scripts/package.mjs` empaqueta con `vsce`.
- **El empaquetado falla** si el binario no tiene registro de procedencia o no coincide con él, si la gramática cambió después de
  compilar el binario o necesita regenerarse, si el host no es `darwin-arm64`, si el bundle deja fuera una dependencia runtime
  (`vscode-languageclient`) o `require`a un módulo que no contiene (solo `vscode` y módulos nativos de Node), si la identidad o el
  mínimo de VS Code difieren del contrato, si `extension.vsixmanifest` declara otra plataforma, o si el contenido no es
  exactamente el declarado: faltan archivos requeridos, hay un recurso no declarado o uno excluido (`src`, `tests`, `scripts`,
  `examples`, `node_modules`, `.git`, `.artifacts`, `*.map`, `.env*`).
- **Salida.** `.artifacts/pseudolearn-0.1.0-darwin-arm64.vsix`, más `<nombre>.vsix.json` (ruta, bytes, SHA-256 del VSIX, del
  binario, de la gramática y del bundle, revisión, versiones de `rustc`, `cargo` y `node`) y `<nombre>.vsix.sha256`. Esos archivos
  no se versionan. Un hash detecta una diferencia respecto del registro local; no es una firma ni prueba la autenticidad.
- **Ejemplos mínimos reproducibles**, fuera del VSIX, en `examples/`: `file/saludo.pseudo` (entrada y salida),
  `file/con-error.pseudo`, `project/` (paquetes `app` y `geo`, importado, `Leer` y `Escribir`) y `project-con-error/` (error en el
  módulo importado).

## 9. Uso antes del lanzamiento

Estado: software previo a producción para uso privado. Plataforma ensayada: macOS Apple silicon con VS Code Stable 1.144.0 o
superior. Que el VSIX se instale y funcione no certifica el lenguaje ni lo declara listo para producción. No hay Marketplace,
Open VSX, telemetría ni actualización automática.

**Con F5 (desde el checkout).** Requiere Node 22.23.3, pnpm 12.8.1 y la cadena Rust del repositorio.

```bash
pnpm install --frozen-lockfile
pnpm build:cli
pnpm build
```

Abre esta carpeta en VS Code y pulsa F5 con la configuración de extensión: se abre un Extension Development Host. Abre
`examples/file/saludo.pseudo`: no se ejecuta al abrirlo.

**Con el VSIX (sin checkout ni toolchains).**

```bash
pnpm package
code --install-extension .artifacts/pseudolearn-0.1.0-darwin-arm64.vsix
```

También sirve «Extensions: Install from VSIX…» de la paleta. Comprueba el hash con `shasum -a 256` contra el
archivo `.sha256` generado. Para un ensayo aislado que no toque el perfil habitual:
`code --user-data-dir <dir-usuario> --extensions-dir <dir-extensiones> --install-extension <archivo.vsix>`. El VSIX usa el
binario incluido y no necesita Cargo, Rust, Node ni pnpm. Las políticas de la organización se comprueban en el equipo de destino;
no se desactiva ningún control de VS Code.

**Seleccionar entrada, ejecutar, leer y detener.** Abre la carpeta `examples/project`. `PseudoLearn: Select Project Entry`
elige `app/main` entre los módulos con algoritmo; `PseudoLearn: Run Project` la ejecuta y, cuando el programa espera, abre un
cuadro de entrada (acepta vacío; cancelar el cuadro envía cancelación). `PseudoLearn: Run File` ejecuta el archivo activo
guardado y `PseudoLearn: Stop Run` lo detiene. Con cambios sin guardar no se ejecuta. En Restricted Mode solo hay resaltado
declarativo.

**Actualizar, revertir y desinstalar.** Instalar un VSIX con la misma identidad sustituye al anterior. Para volver atrás se
conserva el VSIX previo compatible, se desinstala la extensión (`code --uninstall-extension pseudolearn.pseudolearn-vscode`) y se
instala ese archivo; volver a un VSIX anterior no restaura sintaxis anterior del lenguaje. Desinstalar cierra los procesos de la
extensión y no borra los programas del usuario.

**Logs y versión.** El canal `PseudoLearn (technical)` guarda los registros técnicos locales; la versión instalada aparece en la
vista de extensiones y en `code --list-extensions --show-versions`. La identidad del binario incluido se comprueba con su SHA-256, que
consta en el registro `.vsix.json` del paquete. No se registra la entrada del estudiante ni el entorno completo.
