# pseudolearn_cli

## 1. Qué es y qué no es

Binario pseudo para comprobar, ejecutar, compilar, formatear, traducir e inspeccionar programas, e interactuar mediante un servidor de lenguaje (LSP). Análisis, preferencias, ejecución, compilación nativa, formateo, traducción e inspección de RI implementados sobre la API pública.
Fuera de alcance: semántica propia del lenguaje, UI gráfica y configuración ejecutable.

Declarado fuera de esta entrega: la ayuda (`--ayuda`) todavía no lista `bloquear`, `--proyecto` ni `--entrada`, porque el caso de ayuda vigente fija su texto exacto; se actualizará con una decisión de la persona sobre ese esperado. Las dependencias `locked` (con digest) no se leen desde disco: el lock que escribe `bloquear` registra solo paquetes locales.

## 2. Guía operativa y ciclo de vida

Binario de línea de comandos implementado en Rust.
Comandos de compilación y verificación:
- Verificación completa del miembro: `cargo xtask verify`.
- Antes de una compilación directa, genera la exportación ignorada: `(cd ../../packages/pseudolearn_spec && cargo run --locked -p see_cli --bin see -- export --root .)`.
- Compilación de producción: `cargo build --release` (salida en `target/release/pseudo`).
- Pruebas unitarias y funcionales: `cargo test`.
- Conformidad desde `packages/pseudolearn_spec`: `cargo run -p see_cli --bin see -- conform --subject cli --operation cli`.
- Adaptador del protocolo SEE para pruebas automatizadas: `pseudo --see-adapter`; con `pseudo --see-adapter aot` el mismo binario responde como el sujeto `aot` (conformidad: `see conform --subject aot` desde `packages/pseudolearn_spec`).
Distribución nativa en macOS, Linux y Windows. Sin secretos.

`comprobar/check` abre cada raíz solicitada con una capacidad de directorio de `cap-std` y lee sus
archivos relativos a ese descriptor. Un archivo fuente se abre una vez; los bytes de ese descriptor
se conservan hasta el análisis. Los symlinks se siguen solo dentro de la raíz concedida; escapes,
ciclos, colisiones de ruta portable, nombres no UTF-8 y errores de recorrido abortan antes de imprimir
resultados. Cada ruta externa requiere su propia raíz indicada en los argumentos. `cap-std` aporta
operaciones relativas al descriptor y confinamiento seguro del anfitrión; se descartan comprobaciones
de prefijo sobre rutas absolutas, que no cierran carreras entre validación y apertura. El comando
`check` entrega los bytes conservados a la API de análisis y presenta resultados por fuente; un
proyecto se carga con `--proyecto` (sección 4). El recorrido confinado se verificó en macOS; no se certifican otras
plataformas por analogía.

`cargo build` construye antes, desde `build.rs`, la biblioteca estática del runtime (`cargo rustc --release --crate-type staticlib -p pseudolearn_aot_rt` sobre el motor, con su propio directorio de destino bajo `OUT_DIR`) y la depura con `strip`. Requiere `cargo` y `strip`. Compilar un programa requiere además el driver `cc` del sistema en el `PATH`.

## 3. Arquitectura y modelo del sistema

Adaptador de borde → API pública de pseudolearn_engine con la feature `native` explícita. Prohibido importar sus crates internos.
Flujo: argumentos y entorno → configuración explícita → API → presentación o JSON.
Sin estado global de ejecución. I/O solo en el adaptador; el núcleo recibe capacidades inyectadas.
`ejecutar/run` admite `--grabar-cinta <RUTA>` / `--record-tape <PATH>` para persistir la cinta de efectos canónica (`pseudolearn.tape/v1`) y `--reproducir-cinta <RUTA>` / `--replay-tape <PATH>` para reproducir ejecuciones deterministas en aislamiento absoluto del anfitrión (`ENG.EFFECT.TAPE`).

El adaptador de conformidad CLI anuncia `cli` e `ir`. La propiedad de RI obtiene primero la salida de un proceso real `pseudo ri`, y la entrega al verificador público de la API para exigir aceptación y reimpresión idéntica. El verificador también delimita los programas válidos del corpus; las fuentes no compilables no pertenecen al dominio de esa propiedad. Se recorren casos de análisis, ejecución y traza, además de las muestras generadas, en ambos perfiles y rigores. No se declara pendiente una propiedad que el sujeto ya puede ejecutar.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: separar idioma de lector y autor. Elección: vocabulario por primera apertura significativa después de BOM y trivia; API.ANALYZE recibe perfil explícito.
Las aperturas no colisionan entre perfiles; --vocabulario/--vocabulary fuerza es o en cuando no se puede deducir. Texto vacío usa español con diagnóstico si no se fuerza.
El idioma de interfaz sigue --idioma/--language > PSEUDO_IDIOMA/PSEUDO_LANGUAGE > preferencias declarativas de usuario > sistema (LC_ALL, LC_MESSAGES, LANG o preferencia nativa) > español.
Preferencias: pseudo preferencias idioma en, alias pseudo preferences language en; archivo de datos idioma = "en" en configuración de usuario de la plataforma.
La grafía de la orden, el archivo y su vocabulario nunca deciden el idioma de interfaz.
Alternativas descartadas: comentarios mágicos, configuración ejecutable y manifiesto de proyecto para una preferencia personal.
El manifiesto de paquete (datos, sin idioma de interfaz ni edición) lo define la API pública; la CLI solo le entregará sus textos y las concesiones del anfitrión, que nunca provienen del contenido del proyecto.
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
fuente se usa `.out` para no sobrescribirla. `--semilla`, `--profundidad`, `--sentencias`, `--celdas`, `--tareas`, `--rigor`,
`--vocabulario` e `--idioma` se fijan en el ejecutable al compilar: el idioma de interfaz elige el idioma de los
diagnósticos del ejecutable y sus plantillas de línea. Errores del programa: diagnósticos y código 1; fuente ausente: 2;
ilegible, enlazador ausente o fallido: 3. El código del ejecutable es 0, 3, 4 o 5 según su propio protocolo.
Los fallos del generador de código (sin diagnóstico de usuario) se informan con `linkerFailed`, porque
`TOOL.CLI.MESSAGES` no define un mensaje propio.

Adaptador `aot`: ejecuta programas compilados de verdad, con efectos de capacidad: escribe en el directorio de la caché el archivo de entrada de efectos (anfitrión, identidad, cinta para reproducir), lanza el ejecutable con `--effects-in` y `--effects-out`, y lo devuelve a la API para proyectar `effect_tape` y `host_observation`. Por cada petición `execute` compila con `build_native_object`
(plantillas de diagnóstico de campos separados por tabulador, `gc_stress` como recolección forzada), enlaza con el mismo
enlazador que `compilar` y lanza el ejecutable con entorno vacío y desde otro directorio, con las entradas en la entrada
estándar; `pseudolearn_api` convierte código de salida, salida y salida de error en la respuesta del protocolo. Una caché
en memoria, con tope de 32 ejecutables en un directorio temporal propio, reutiliza el ejecutable de un objeto idéntico
(perfil y rigor distintos producen el mismo objeto); la clave es el contenido completo del objeto, no un resumen, de modo
que una colisión no puede devolver un ejecutable ajeno. El directorio se elimina al terminar, también si el protocolo se
cierra sin `shutdown`. Anuncia `execute` y `gc_stress`; no anuncia `observe`, `analyze`, `ir` ni `api`, porque el
sujeto está exento de observación y solo ejecuta.

La ejecución de ejecutar/run usa únicamente la API pública con entrada estándar, semilla, límites
de profundidad, sentencias, celdas y tareas vivas (`--tareas`/`--tasks`; omisión 4 096). La CLI fija además `max_json_depth` en 64, cuerpo HTTP decodificado y cable en 8 MiB, cabeceras en 16 KiB y 64 campos, ocho peticiones pendientes y 30 segundos por petición. La traza se narra con las plantillas trace* del catálogo generado;
la salida del programa se conserva literalmente. ri/ir imprime la RI canónica de la API o el diagnóstico
de la primera violación. No se introduce semántica propia ni se accede a capas internas. Los casos cli
verifican ambos idiomas, opciones equivalentes, códigos de salida y errores operativos.

`ejecutar`/`run` conserva la entrada pública de archivo suelto con perfil y rigor existentes. No exige
manifiesto ni imports para abrir un programa; las directivas de módulo siguen reservadas a la forma
contextual de unidad superior y sus grafías se pueden usar como nombres dentro de un programa suelto.

Perfil por archivo: `--vocabulario` equivale al argumento `profile` de la petición de proyecto; las excepciones por archivo
las aporta el manifiesto y el idioma de interfaz no cambia el programa ni el lock.

### Efectos, cinta y proveedor físico

`ejecutar/run` admite `--nativo` (`--native`): compila el programa con el mismo camino que `compilar`, lo enlaza en un
directorio temporal y lo lanza con el canal de efectos `--effects-in` / `--effects-out` del runtime nativo. Con
`--grabar-cinta` el ejecutable nativo produce la cinta `pseudolearn.tape/v1` y con `--reproducir-cinta` la reproduce sin
consultar a ningún anfitrión; el mismo archivo de cinta sirve en ambos sentidos (máquina virtual → nativo y nativo →
máquina virtual). `--nativo` rechaza `--traza` con error de uso (código 2): el sujeto nativo no ofrece observación ni
retroceso (`observe`/`seek`), y la API rechaza esas peticiones con `native_effect_input`.

La reproducción de `Leer` es autónoma: la cinta guarda cada línea leída y la reproducción la entrega sin leer la entrada
estándar. Decisión: la entrada leída se resuelve contra la entrada de cinta siguiente en ambos motores; si la cinta se
agota, la reproducción termina con `replay_truncated_tape`.

La política física de red está separada en `physical_network_address`, `physical_network_resolver` y
`physical_network_tls`. El validador rechaza hosts inválidos y formas numéricas alternativas de IPv4;
el resolvedor del sistema se puede sustituir por uno falso y `resolve_checked` examina toda la
respuesta DNS una sola vez antes de entregar la instantánea comprobada de direcciones. Deniega los
rangos locales, privados y especiales; una concesión local de prueba solo permite loopback.
`TlsConfiguration` exige validación de certificados y solo admite raíces añadidas por el anfitrión.
Esta iteración no conecta aún esa configuración a un transporte HTTP real. La biblioteca cliente
continúa sin elegir: `PG-5.06.01` debe evaluar las opciones aprobadas antes de integrarla. No se usan
proxies del entorno ni del sistema como configuración implícita.

Proveedor físico: `--conceder <lista>` (`--grant`) declara los permisos concedidos (`consola`, `argumentos`,
`archivos_lectura`, `archivos_escritura`, `reloj`, `temporizador`; cualquier otro nombre es error de uso) y
`--archivos <DIR>` (`--files`) la única raíz de archivos. Sin `--conceder` el comportamiento no cambia y toda
capacidad se deniega. Con `--conceder` la CLI arranca la ejecución en modo `detached` y atiende cada
`awaiting_effect` como consumidor de la API pública: `physical_host.rs` despacha las operaciones, `physical_files.rs`
las operaciones de archivo y `physical_session.rs` el ciclo `effect_result`. La raíz se abre una sola vez con
`cap_std::fs::Dir::open_ambient_dir` en la frontera de la CLI y toda ruta posterior se resuelve relativa a un `Dir`;
nunca se concatenan rutas. Defensas: la ruta debe ser relativa, sin `.`/`..`, sin vacío, `\`, `:` ni NUL
(`ruta_invalida`); `cap-std` rechaza además enlaces simbólicos salientes (`permiso_denegado`); los derechos de una
capacidad derivada deben ser subconjunto de los del padre; cerrar una capacidad la retira de la tabla y su uso posterior
devuelve `capacidad_cerrada`; escribir reemplaza el contenido y un fallo tras mutar se informa como `Uncertain`.
La reproducción (`--reproducir-cinta`) no abre la raíz ni toca disco. El reloj es el del sistema en la primera lectura
y el temporizador es lógico (suma la duración sin dormir). No se declaran pendientes de esta decisión salvo que el
proveedor físico solo ofrece una raíz y no modela argumentos de la línea de órdenes del programa.

`deny.toml` autoriza `BSD-3-Clause`, licencia de `subtle`, dependencia transitiva de `hmac` que el runtime usa para las
referencias de secretos de la cinta; es la misma decisión que ya rige en el motor.

#### Vectores adversarios de archivos y cinta (E-PG-09, parte de PG-3)

La batería `tests/security_vectors.rs` ejecuta el binario real con una raíz concedida y un archivo canario fuera de ella.
Cada vector debe terminar con el código de error portable esperado, sin que la salida contenga el canario y sin que el
archivo exterior cambie. Vectores cubiertos (7 de 7 bloqueados, 2026-10-27): `..` (`ruta_invalida`), ruta absoluta
(`ruta_invalida`), enlace simbólico saliente (`permiso_denegado`), escritura desde una concesión de solo lectura
(`permiso_denegado`), uso tras cierre (`capacidad_cerrada`), un bit alterado en la carga de una entrada de cinta y cinta
truncada (ambas rechazadas en la reproducción sin escribir salida). El vector de NUL interior y la atenuación a solo
lectura se cubren con las pruebas unitarias de `physical_host_tests.rs`, no con un programa de la batería. Esta batería es de caracterización de seguridad: acredita que cada vector se bloquea, no que no existan otros.

### Proyectos

Invocaciones reproducibles (el directorio actual no interviene; el proyecto puede estar en cualquier ruta):

```bash
pseudo bloquear --proyecto ruta/proyecto
pseudo comprobar --proyecto ruta/proyecto
pseudo ejecutar --proyecto ruta/proyecto --entrada app/main
pseudo compilar --proyecto ruta/proyecto --entrada app/main -o salida
```

Alias: `lock`, `check`, `run`, `build`, `--project`, `--entry`. El directorio contiene un `pseudolearn.toml` por paquete
(en el subdirectorio raíz de cada paquete) y un `pseudolearn.lock` opcional en su raíz.

Decisiones:

- La lectura confinada (`project_files.rs`) recorre el directorio una sola vez con `cap-std`, asigna `source_id` consecutivos
  por clave portable de ruta y entrega a la API los mismos bytes que se verifican y compilan. Un manifiesto en la raíz del
  directorio se rechaza porque su ubicación lógica sería vacía. Se descartó descubrir el proyecto subiendo por directorios
  padre, porque haría el resultado dependiente del directorio actual.
- `bloquear` es el único escritor del lock: compone `.pseudolearn.lock.partial` en el mismo directorio y lo renombra; ante
  un fallo lo elimina y conserva el lock anterior. `comprobar`, `ejecutar` y `compilar` solo lo verifican (`resolve_lock`
  antes de analizar) y una discrepancia es error operativo sin salida parcial.
- `ejecutar` usa `execute_project`: no admite entrada estándar ni `--traza`, `--semilla` o límites propios; los límites
  proceden del manifiesto. Las órdenes de proyecto presentan cada diagnóstico con la ruta del archivo real obtenida por su
  `source_id`, también los fallos de ejecución (VM y binario nativo).
- `compilar` genera un único objeto del grafo cerrado (`build_native_project_object`) con la tabla de nombres de fuente
  incrustada en el ejecutable; el código de salida de un fallo de ejecución del binario sigue siendo 3, como en archivo suelto.
- `--json` de `comprobar` imprime la respuesta de `analyze_project`; en `ejecutar`, la de `execute_project`.

## 5. Reglas de legibilidad, estilo y estructura de código

Problema: la CLI debe producir ejecutables autónomos sin que el usuario instale el runtime. Elección: incrustar la biblioteca
estática depurada (~1,2 MiB) en `pseudo`, que queda en 7,2 MiB en `release` frente al objetivo de 8 MiB. Descartado: buscar
la biblioteca junto al binario o en una variable de entorno, que rompe la distribución de un solo archivo; invocar
`rustc` o `clang` sobre código fuente generado, que exige un compilador completo en la máquina de la persona.

Problema: `build.rs` necesita compilar el runtime para la plataforma anfitriona sin disputar el bloqueo del directorio de
destino del `cargo build` en curso. Elección: un directorio de destino propio bajo `OUT_DIR` y `--locked`, de modo que
el motor no cambia su `Cargo.lock`. Descartado: añadir `staticlib` a los tipos de crate de `pseudolearn_aot_rt`, que
generaría la biblioteca en cada compilación del motor.

Problema: el recorrido debe confinar aperturas aunque cambie un enlace simbólico. Elección: directorios `cap-std` abiertos
una vez y operaciones relativas a esa capacidad; se toma su API segura de directorio ([`cap_std::fs::Dir`](https://docs.rs/cap-std/latest/cap_std/fs/struct.Dir.html)) y se descarta resolver nombres con `std::fs` después de comprobar su prefijo. No se añade `unsafe` propio.
La dependencia introduce versiones paralelas de `io-lifetimes` y enlaces de Windows en su grafo de host; la regla de dependencias omite solo esas versiones exactas, dejando activo el rechazo general de versiones múltiples.

Código inglés sin comentarios. Mensajes desde TOOL.CLI.MESSAGES y DIAG.MESSAGES generados; sin copias ni prosa en la lógica.
Errores como valores y códigos de salida de TOOL.CLI.CONVENTIONS; ningún pánico cruza la frontera.
Las reglas del miembro se declaran antes de escribir código.

## 6. Decisiones de producto que condicionan el código

La salida del programa y los valores siguen su vocabulario. Narración de traza, diagnósticos, ayuda y progreso siguen idioma de interfaz.
Códigos, claves JSON y formato de intercambio son independientes del idioma.
Contratos TOOL.CLI.CONVENTIONS, MESSAGES, CHECK, RUN, BUILD e IR; límites por defecto según ENG.LIMITS.

## 7. Verificación, testing y aseguramiento de calidad

`tests/build_tests.rs` cubre compilar y ejecutar con entrada estándar en un entorno vacío y otro directorio, la salida por
omisión, la fuente sin extensión, el permiso de ejecución, el fallo de ejecución del binario generado (código 3, salida previa
y posición), el programa inválido sin salida, entrada ausente e ilegible, `-o` sin valor, enlazador ausente (`PATH` vacío) sin
salida ni temporales propios (`pseudo_link_*`; `TMPDIR` se redirige y se ignora la caché del toolchain `xcrun_db`) y una salida previa que un fallo no sustituye.
`tests/aot_effect_parity.rs` contrasta el sujeto nativo con el motor: la misma cinta grabada por ambos, cinta del motor reproducida en nativo con cero llamadas al anfitrión, cinta nativa reproducida en el motor, cinta adulterada rechazada con `replay_corrupted_tape`, permiso denegado idéntico y `history_seek` rechazado.
`tests/aot_adapter_tests.rs` cubre el adaptador `aot` con procesos reales: identidad y capacidades, ejecución con entradas, fallo con salida previa y tramo, entrada agotada, presupuesto de sentencias, programa rechazado, petición no admitida, reutilización de un ejecutable y ausencia de temporales propios (`pseudo_aot_*` y `pseudo_link_*`) con y sin `shutdown`. La caché temporal `xcrun_db` pertenece al toolchain del sistema.
`tests/service_cli_tests.rs` cubre las órdenes formatear/format, traducir/translate y el loop LSP en modo stdio, incluyendo opciones de verificación, escritura in-place, reporte de colisiones, argumentos obligatorios e inicialización y apagado JSON-RPC.
`tests/project_tests.rs` cubre con procesos reales desde otro directorio y con entorno vacío: proyecto reubicado, igualdad de salida entre VM y binario nativo, fallo en un módulo importado con la misma línea en ambos, lock escrito y verificado, lock alterado que bloquea las tres órdenes, escritura denegada que conserva el lock previo sin temporal, compilación fallida que conserva la salida previa sin temporales y códigos de salida de entrada ausente, inexistente y directorio ilegible.
Tests de precedencia de cada fuente de idioma, alias equivalentes, aperturas bilingües, BOM, trivia, texto vacío, argumentos inválidos y error operativo.
Conformidad contra casos cli del corpus en ambos idiomas; --json estable al cambiar idioma.
Verificadores, formato, Clippy, dependencias y tests mediante cargo xtask verify al implementar.

## 8. Fuentes consultadas y genealogía conceptual

El corpus TOOL.CLI es normativo. Las convenciones de CLI y gettext inspiran precedencia de preferencias; se rechaza que una forma de orden traduzca implícitamente la salida. LSP aporta locale para el idioma del cliente.


La cinta se obtiene de la sesión ejecutada y se publica mediante archivo provisional y renombrado;
un error de lectura, formato o escritura es operativo y no se oculta como análisis fallido. La
reproducción inválida no inicia una ejecución viva alternativa. Las pruebas de procesos comprueban
que el archivo existe, contiene efectos y permite repetir la salida, además del rechazo de corrupción.

### Registro de vectores de ataque de `E-PG-09`

`tests/security_vector_registry.rs` declara la lista cerrada de ocho vectores (`..`, ruta absoluta, enlace simbólico saliente, NUL interior, amplificación de derechos, uso tras cierre, adulteración de un bit de la cinta y truncamiento) y la prueba que bloquea cada uno, en `tests/security_vectors.rs` y `src/physical_host_tests.rs`. La batería falla si un vector requerido no está registrado o si su prueba no existe, de modo que un vector nuevo sin prueba o una prueba borrada no pasan en verde. Tiene casos negativos para cada una de esas dos condiciones y para un archivo ilegible.

Un programa con tareas o canales no se compila a código nativo todavía: `build` y `run --nativo`
muestran el diagnóstico `nativeTasksUnsupported` (salida 1) en vez de un fallo de enlazado, y el
programa se ejecuta con el motor virtual. `--tareas` limita las tareas vivas de la ejecución
virtual (omisión 4 096) y excede con `taskLimitExceeded`.
