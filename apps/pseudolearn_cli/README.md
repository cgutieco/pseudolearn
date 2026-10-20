# pseudolearn_cli

## 1. Qué es y qué no es

Binario pseudo para comprobar, ejecutar, compilar, formatear, traducir e inspeccionar programas, e interactuar mediante un servidor de lenguaje (LSP). Análisis, preferencias, ejecución, compilación nativa, formateo, traducción e inspección de RI implementados sobre la API pública.
Fuera de alcance: semántica propia del lenguaje, UI gráfica y configuración ejecutable.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Ninguno declarado | | |

## 2. Guía operativa y ciclo de vida

Binario de línea de comandos implementado en Rust.
Comandos de compilación y verificación:
- Verificación completa del miembro: `cargo xtask verify`.
- Compilación de producción: `cargo build --release` (salida en `target/release/pseudo`).
- Pruebas unitarias y funcionales: `cargo test`.
- Conformidad desde `packages/pseudolearn_spec`: `cargo run -p see_cli --bin see -- conform --subject cli --operation cli`.
- Adaptador del protocolo SEE para pruebas automatizadas: `pseudo --see-adapter`; con `pseudo --see-adapter aot` el mismo binario responde como el sujeto `aot` (conformidad: `see conform --subject aot` desde `packages/pseudolearn_spec`).
Distribución nativa en macOS, Linux y Windows. Sin secretos.

`cargo build` construye antes, desde `build.rs`, la biblioteca estática del runtime (`cargo rustc --release --crate-type staticlib -p pseudolearn_aot_rt` sobre el motor, con su propio directorio de destino bajo `OUT_DIR`) y la depura con `strip`. Requiere `cargo` y `strip`. Compilar un programa requiere además el driver `cc` del sistema en el `PATH`.

## 3. Arquitectura y modelo del sistema

Adaptador de borde → API pública de pseudolearn_engine con la feature `native` explícita. Prohibido importar sus crates internos.
Flujo: argumentos y entorno → configuración explícita → API → presentación o JSON.
Sin estado global de ejecución. I/O solo en el adaptador; el núcleo recibe capacidades inyectadas.

El adaptador de conformidad CLI anuncia `cli` e `ir`. La propiedad de RI obtiene primero la salida de un proceso real `pseudo ri`, y la entrega al verificador público de la API para exigir aceptación y reimpresión idéntica. El verificador también delimita los programas válidos del corpus; las fuentes no compilables no pertenecen al dominio de esa propiedad. Se recorren casos de análisis, ejecución y traza, además de las muestras generadas, en ambos perfiles y rigores. No se declara pendiente una propiedad que el sujeto ya puede ejecutar.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: separar idioma de lector y autor. Elección: vocabulario por primera apertura significativa después de BOM y trivia; API.ANALYZE recibe perfil explícito.
Las aperturas no colisionan entre perfiles; --vocabulario/--vocabulary fuerza es o en cuando no se puede deducir. Texto vacío usa español con diagnóstico si no se fuerza.
El idioma de interfaz sigue --idioma/--language > PSEUDO_IDIOMA/PSEUDO_LANGUAGE > preferencias declarativas de usuario > sistema (LC_ALL, LC_MESSAGES, LANG o preferencia nativa) > español.
Preferencias: pseudo preferencias idioma en, alias pseudo preferences language en; archivo de datos idioma = "en" en configuración de usuario de la plataforma.
La grafía de la orden, el archivo y su vocabulario nunca deciden el idioma de interfaz.
Alternativas descartadas: comentarios mágicos, configuración ejecutable y manifiesto de proyecto para una preferencia personal.
Los alias ingleses siempre se aceptan y conservan idénticos efectos y salida.
Opciones: --rigor/--strictness, --traza/--trace, --json. La ayuda muestra forma del idioma de interfaz y la otra como alias.

`build.rs` genera el catálogo de mensajes desde la exportación de `TOOL.CLI.MESSAGES`.
La sustitución de argumentos recorre la plantilla una sola vez, preservando llaves en lexemas del usuario.
Los tramos públicos ya contienen línea y columna; la CLI los presenta sin convertir offsets.
La prosa de diagnóstico se renderiza por código y argumentos en el idioma de interfaz.

formatear/format: aplica el estilo canónico al programa mediante el servicio de lenguaje de la API. Con `--verificar` (`--check`) no emite código ni modifica el disco: retorna 0 si el archivo ya está en forma canónica y 1 con mensaje en stderr si requiere formateo. Con `--escribir` (`--write`, `-w`) actualiza el archivo en disco e informa su ruta. Si el archivo contiene errores sintácticos o no existe, retorna código 1 o 2 respectivamente sin tocar el disco.

traducir/translate: realiza traducción bilingüe del código fuente hacia el perfil indicado por la opción requerida `--hacia` (`--to`). Detecta colisiones de identificadores con palabras reservadas del perfil destino (o con la traducción de una función estándar usada) y emite el diagnóstico `reservedLexemeUsedAsName` en la línea y columna del nombre, con código de salida 1 y sin escribir salida. El texto traducido conserva blancos, comentarios y literales. `--salida`/`-o` escribe el resultado en un archivo. Falta de opción o perfil no válido emite error de uso con código 2.

lsp: ejecuta el servidor de lenguaje sobre entrada y salida estándar bajo el protocolo JSON-RPC 2.0 y framing `Content-Length`. Atiende el ciclo de vida completo (`initialize`, `shutdown`, `exit`) y los métodos de sincronización incremental, diagnósticos, compleción, información emergente, ayuda de firma, definición, referencias, resaltado, símbolos del documento y formateo. Termina con código 0 tras `shutdown` y `exit`, y con 1 si el cliente cierra la conexión o sale sin apagar.

compilar/build: lee y analiza la fuente con la API (`build_native_object`), y solo si no hay errores enlaza el objeto con
la biblioteca del runtime incrustada en `pseudo` (`include_bytes!`) usando el driver `cc`, en un directorio temporal que se
elimina siempre. El resultado se copia junto al destino con un nombre provisional y se renombra, de modo que un fallo
nunca crea ni sobrescribe la salida. Informa `buildSucceeded` con la ruta tal como se pidió. Sin `-o`/`--salida`/`--output`
la salida es el nombre del archivo sin `.pseudo` (más `.exe` en Windows) en el directorio actual; si eso coincidiera con la
fuente se usa `.out` para no sobrescribirla. `--semilla`, `--profundidad`, `--sentencias`, `--celdas`, `--rigor`,
`--vocabulario` e `--idioma` se fijan en el ejecutable al compilar: el idioma de interfaz elige el idioma de los
diagnósticos del ejecutable y sus plantillas de línea. Errores del programa: diagnósticos y código 1; fuente ausente: 2;
ilegible, enlazador ausente o fallido: 3. El código del ejecutable es 0, 3, 4 o 5 según su propio protocolo.
Los fallos del generador de código (sin diagnóstico de usuario) se informan con `linkerFailed`, porque
`TOOL.CLI.MESSAGES` no define un mensaje propio.

Adaptador `aot`: ejecuta programas compilados de verdad. Por cada petición `execute` compila con `build_native_object`
(plantillas de diagnóstico de campos separados por tabulador, `gc_stress` como recolección forzada), enlaza con el mismo
enlazador que `compilar` y lanza el ejecutable con entorno vacío y desde otro directorio, con las entradas en la entrada
estándar; `pseudolearn_api` convierte código de salida, salida y salida de error en la respuesta del protocolo. Una caché
en memoria, con tope de 32 ejecutables en un directorio temporal propio, reutiliza el ejecutable de un objeto idéntico
(perfil y rigor distintos producen el mismo objeto); la clave es el contenido completo del objeto, no un resumen, de modo
que una colisión no puede devolver un ejecutable ajeno. El directorio se elimina al terminar, también si el protocolo se
cierra sin `shutdown`. Anuncia `execute` y `gc_stress`; no anuncia `observe`, `analyze`, `ir` ni `api`, porque el
sujeto está exento de observación y solo ejecuta.

La ejecución de ejecutar/run usa únicamente la API pública con entrada estándar, semilla, límites
de profundidad, sentencias y celdas. La traza se narra con las plantillas trace* del catálogo generado;
la salida del programa se conserva literalmente. ri/ir imprime la RI canónica de la API o el diagnóstico
de la primera violación. No se introduce semántica propia ni se accede a capas internas. Los casos cli
verifican ambos idiomas, opciones equivalentes, códigos de salida y errores operativos.

## 5. Reglas de legibilidad, estilo y estructura de código

Problema: la CLI debe producir ejecutables autónomos sin que el usuario instale el runtime. Elección: incrustar la biblioteca
estática depurada (~1,2 MiB) en `pseudo`, que queda en 7,2 MiB en `release` frente al objetivo de 8 MiB. Descartado: buscar
la biblioteca junto al binario o en una variable de entorno, que rompe la distribución de un solo archivo; invocar
`rustc` o `clang` sobre código fuente generado, que exige un compilador completo en la máquina de la persona.

Problema: `build.rs` necesita compilar el runtime para la plataforma anfitriona sin disputar el bloqueo del directorio de
destino del `cargo build` en curso. Elección: un directorio de destino propio bajo `OUT_DIR` y `--locked`, de modo que
el motor no cambia su `Cargo.lock`. Descartado: añadir `staticlib` a los tipos de crate de `pseudolearn_aot_rt`, que
generaría la biblioteca en cada compilación del motor.

Código inglés sin comentarios. Mensajes desde TOOL.CLI.MESSAGES y DIAG.MESSAGES generados; sin copias ni prosa en la lógica.
Errores como valores y códigos de salida de TOOL.CLI.CONVENTIONS; ningún pánico cruza la frontera.
Las reglas del miembro se declaran antes de escribir código.

## 6. Decisiones de producto que condicionan el código

La salida del programa y los valores siguen su vocabulario. Narración de traza, diagnósticos, ayuda y progreso siguen idioma de interfaz.
Códigos, claves JSON y formato de intercambio son independientes del idioma.
Contratos TOOL.CLI.CONVENTIONS, MESSAGES, CHECK, RUN e IR; límites por defecto según ENG.LIMITS.

## 7. Verificación, testing y aseguramiento de calidad

`tests/build_tests.rs` cubre compilar y ejecutar con entrada estándar en un entorno vacío y otro directorio, la salida por
omisión, la fuente sin extensión, el permiso de ejecución, el fallo de ejecución del binario generado (código 3, salida previa
y posición), el programa inválido sin salida, entrada ausente e ilegible, `-o` sin valor, enlazador ausente (`PATH` vacío) sin
salida ni temporales propios (`pseudo_link_*`; `TMPDIR` se redirige y se ignora la caché del toolchain `xcrun_db`) y una salida previa que un fallo no sustituye.
`tests/aot_adapter_tests.rs` cubre el adaptador `aot` con procesos reales: identidad y capacidades, ejecución con entradas, fallo con salida previa y tramo, entrada agotada, presupuesto de sentencias, programa rechazado, petición no admitida, reutilización de un ejecutable y ausencia de temporales propios (`pseudo_aot_*` y `pseudo_link_*`) con y sin `shutdown`. La caché temporal `xcrun_db` pertenece al toolchain del sistema.
`tests/service_cli_tests.rs` cubre las órdenes formatear/format, traducir/translate y el loop LSP en modo stdio, incluyendo opciones de verificación, escritura in-place, reporte de colisiones, argumentos obligatorios e inicialización y apagado JSON-RPC.
Tests de precedencia de cada fuente de idioma, alias equivalentes, aperturas bilingües, BOM, trivia, texto vacío, argumentos inválidos y error operativo.
Conformidad contra casos cli del corpus en ambos idiomas; --json estable al cambiar idioma.
Verificadores, formato, Clippy, dependencias y tests mediante cargo xtask verify al implementar.

## 8. Fuentes consultadas y genealogía conceptual

El corpus TOOL.CLI es normativo. Las convenciones de CLI y gettext inspiran precedencia de preferencias; se rechaza que una forma de orden traduzca implícitamente la salida. LSP aporta locale para el idioma del cliente.
