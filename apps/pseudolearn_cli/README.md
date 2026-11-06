# pseudolearn_cli

## 1. Qué es y qué no es

Binario pseudo para comprobar, ejecutar, compilar, formatear, traducir e inspeccionar programas, e interactuar mediante un servidor de lenguaje (LSP) o un adaptador de depuración VM (DAP). Análisis, preferencias, ejecución, compilación nativa, formateo, traducción, depuración e inspección de RI implementados sobre la API pública.
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
- Adaptador del protocolo SEE para pruebas automatizadas: `pseudo --see-adapter`; con `pseudo --see-adapter aot` el mismo binario responde como el sujeto `aot` (conformidad: `see conform --subject aot` desde `packages/pseudolearn_spec`). El sujeto `aot` anuncia `execute`, `gc_stress` y `project_api`: en los casos `api` de proyecto, `execute_project` compila el proyecto completo a un ejecutable real (`prepare_native_project`) y lo ejecuta; `analyze_project` usa el mismo analizador de proyectos que alimenta a `pseudo build`; cualquier otra operación de sesión (las de ejecución observable paso a paso) responde un fallo de uso, porque el sujeto nativo no ofrece observación.
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

`cargo build` construye antes, desde `build.rs`, la biblioteca estática del runtime de cada destino nativo (`cargo rustc --release --crate-type staticlib --target <triplete> -p pseudolearn_aot_rt` sobre el motor, con su propio directorio de destino bajo `OUT_DIR`) y genera `runtime_archives.rs`, la tabla que `runtime_archive.rs` incrusta con `include_bytes!`. Requiere `cargo`; en Linux, el destino `x86_64-unknown-linux-musl` instalado y `musl-gcc` (paquete `musl-tools`). El enlace usa el enlazador incluido (sección «Enlazador incluido y destinos nativos»): no hace falta Xcode, un compilador C ni un SDK en la máquina que ejecuta `pseudo compilar`.

La feature `test-host` de la CLI, apagada por omisión, solo cambia esa biblioteca: `build.rs` la compila con `--features test-host` y el runtime nativo usa el anfitrión de memoria con el que la conformidad simula reloj, archivos y red (`anfitrion` de cada caso). Sin ella el runtime usa el anfitrión físico de `pseudolearn_host` con autoridad plena: archivos, red, reloj, temporizador, argumentos y entorno reales; un documento de anfitrión simulado se rechaza con `peticion_invalida`. `see` lanza el sujeto `aot` con `cargo run --features test-host`; `cargo xtask verify` ejecuta `aot_adapter_tests` y `aot_effect_parity` con y sin la feature. La clave `isolation` prohíbe `pseudolearn_cli/test-host` en los grafos de distribución, de modo que un binario distribuido nunca embebe dobles de prueba. Se descartó enlazar los dos runtimes en el mismo binario y elegir en ejecución, porque distribuiría los dobles, y delegar los efectos del ejecutable al proceso padre, porque el anfitrión físico vive dentro del propio ejecutable.

`run --native` lanza el ejecutable desde el directorio de trabajo con el entorno heredado, `--semilla` con la semilla de la ejecución (la indicada o una de entropía) y, tras `--`, los argumentos del programa; la conformidad lo lanza con entorno vacío desde su caché. Como `pseudo ejecutar` en la VM, termina con el código que el programa pidió con la operación de consola si la ejecución se completó, y con 1 si no: el ejecutable lo escribe como `exit_code` en su documento de efectos (que el lanzador siempre pide) y `native_run::requested_exit` lo lee. El archivo estático del runtime pasa de unos 3,1 MB a 5,6 MB depurado con el anfitrión físico y un ejecutable mínimo ocupa unos 3,5 MB.

## 3. Arquitectura y modelo del sistema

Adaptador de borde → API pública de pseudolearn_engine con la feature `native` explícita. Prohibido importar sus crates internos.
Flujo: argumentos y entorno → configuración explícita → API → presentación o JSON.
Sin estado global de ejecución. I/O solo en el adaptador; el núcleo recibe capacidades inyectadas.
La CLI conserva la lectura confinada de archivos y manifiestos y entrega los textos como `ProjectInput`.
`WorkspaceSession` recibe snapshots completos como datos y no abre rutas; esta etapa añade la sesión al servicio,
sin añadir un comando CLI ni mover la responsabilidad de E/S fuera del adaptador.
`ejecutar/run` admite `--grabar-cinta <RUTA>` / `--record-tape <PATH>` para persistir la cinta de efectos canónica (`pseudolearn.tape/v1`) y `--reproducir-cinta <RUTA>` / `--replay-tape <PATH>` para reproducir ejecuciones deterministas en aislamiento absoluto del anfitrión (`ENG.EFFECT.TAPE`).

El adaptador de conformidad CLI anuncia `cli` e `ir`. La propiedad de RI obtiene primero la salida de un proceso real `pseudo ri`, y la entrega al verificador público de la API para exigir aceptación y reimpresión idéntica. El verificador también delimita los programas válidos del corpus; las fuentes no compilables no pertenecen al dominio de esa propiedad. Se recorren casos de análisis, ejecución y traza, además de las muestras generadas, en ambos perfiles. No se declara pendiente una propiedad que el sujeto ya puede ejecutar.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: separar idioma de lector y autor. Elección: vocabulario por primera apertura significativa después de BOM y trivia; API.ANALYZE recibe perfil explícito.
Las aperturas no colisionan entre perfiles; --vocabulario/--vocabulary fuerza es o en cuando no se puede deducir. Texto vacío usa español con diagnóstico si no se fuerza.
El idioma de interfaz sigue --idioma/--language > PSEUDO_IDIOMA/PSEUDO_LANGUAGE > preferencias declarativas de usuario > sistema (LC_ALL, LC_MESSAGES, LANG o preferencia nativa) > español.
Preferencias: pseudo preferencias idioma en, alias pseudo preferences language en; archivo de datos idioma = "en" en configuración de usuario de la plataforma.
La grafía de la orden, el archivo y su vocabulario nunca deciden el idioma de interfaz.
Alternativas descartadas: comentarios mágicos, configuración ejecutable y manifiesto de proyecto para una preferencia personal.
El manifiesto de paquete (datos, sin idioma de interfaz ni edición) lo define la API pública; la CLI solo le entregará sus textos y las concesiones del anfitrión, que nunca provienen del contenido del proyecto.
Los alias ingleses siempre se aceptan y conservan idénticos efectos y salida.
Opciones: --traza/--trace, --json. La ayuda muestra forma del idioma de interfaz y la otra como alias.

`build.rs` genera el catálogo de mensajes desde la exportación de `TOOL.CLI.MESSAGES`.
La sustitución de argumentos recorre la plantilla una sola vez, preservando llaves en lexemas del usuario.
Los tramos públicos ya contienen línea y columna; la CLI los presenta sin convertir offsets.
La prosa de diagnóstico se renderiza por código y argumentos en el idioma de interfaz.
El marcador de línea (`diagnostic_excerpt.rs`) añade bajo cada diagnóstico de texto la línea de fuente con su número y una
marca `^` bajo la columna de inicio, para que un `;` olvidado se vea sin abrir el editor. Solo se muestra la primera línea
del tramo, los tabuladores se expanden a cuatro columnas y una línea de más de 80 columnas se recorta a una ventana de 80
centrada en la marca con `…` en cada extremo recortado. Es estructura sin prosa, así que no vive en el catálogo de
mensajes; `--json` no cambia porque ya lleva línea, columna y tramo. Si la fuente no está disponible (un diagnóstico sin archivo, o un fallo
en tiempo de ejecución de un ejecutable nativo, que no lleva la fuente) solo se escribe la línea de plantilla. El lenguaje es único: la CLI no tiene opciones que cambien sus
reglas, y cualquier opción de ese tipo es una opción desconocida.

formatear/format: aplica el estilo canónico al programa mediante el servicio de lenguaje de la API. Con `--verificar` (`--check`) no emite código ni modifica el disco: retorna 0 si el archivo ya está en forma canónica y 1 con mensaje en stderr si requiere formateo. Con `--escribir` (`--write`, `-w`) actualiza el archivo en disco e informa su ruta. Si el archivo contiene errores sintácticos o no existe, retorna código 1 o 2 respectivamente sin tocar el disco.

traducir/translate: realiza traducción bilingüe del código fuente hacia el perfil indicado por la opción requerida `--hacia` (`--to`). Detecta colisiones de identificadores con palabras reservadas del perfil destino (o con la traducción de una función estándar usada) y emite el diagnóstico `reservedLexemeUsedAsName` en la línea y columna del nombre, con código de salida 1 y sin escribir salida. El texto traducido conserva blancos, comentarios y literales. `--salida`/`-o` escribe el resultado en un archivo. Falta de opción o perfil no válido emite error de uso con código 2.

lsp: ejecuta el servidor JSON-RPC 2.0 sobre stdio y reserva stdout para respuestas y notificaciones con framing `Content-Length`. Limita el bloque de cabeceras a 8 KiB y el cuerpo a 8 MiB; una longitud ausente, duplicada, mal formada o excesiva termina el transporte con error. El lector puede procesar `$/cancelRequest` mientras el worker analiza, y mantiene hasta ocho consultas pendientes; una cola llena responde con error JSON-RPC `-32802`. Las notificaciones comparten la cola del worker con un límite de 256 mensajes pendientes, independiente del de consultas; superarlo termina el transporte con error, porque descartar una notificación dejaría al servidor con un estado distinto del cliente. La extensión materializa archivos en lotes de 64 y espera entre lotes. La prueba de proceso abre 1000 documentos con ese ritmo y confirma que el servidor sigue respondiendo; por eso se conserva el límite acotado de 256.

**Carga del workspace por el anfitrión (`lsp_workspace_loader.rs`).** El servicio recibe datos y no lee disco; quien lee es la CLI. Al recibir `initialized` y tras cada `textDocument/didSave`, el transporte toma la primera raíz de `workspaceFolders` (o `rootUri`, solo esquema `file`), la carga con el mismo lector confinado de `project_files`, resuelve cada manifiesto con la operación pública `resolve_manifest` y entrega al servicio un `pseudolearn/workspaceSnapshot` con revisión creciente y el mapa módulo → URI (percent-encoding de bytes UTF-8, igual que VS Code). La CLI conserva únicamente la resolución de cada manifiesto vigente, indexada por ubicación y texto exacto; al cambiar el texto vuelve a llamar a `resolve_manifest`, y al retirar el manifiesto lo retira de la caché. Cada resincronización todavía recorre y lee los archivos para no depender de marcas de tiempo como prueba de igualdad; el servicio compara el snapshot y salta el análisis cuando todo el contenido ya coincide. Una raíz ilegible, sin manifiestos o con un manifiesto inválido no produce snapshot y los documentos se analizan sueltos; no se reintenta en silencio. Solo se atiende la primera raíz y no se observan cambios de disco fuera de `didSave`: un archivo cerrado que cambia sin que el editor guarde nada se reconcilia en el siguiente guardado o al reiniciar el servidor. Descartado: que el cliente de editor lea y envíe el snapshot, porque duplicaría el confinamiento en TypeScript.
El servidor atiende sincronización incremental, diagnósticos, compleción, información emergente, ayuda de firma, navegación, resaltado, símbolos de documento/workspace, `prepareRename`, `rename`, `semanticTokens/full`, formato y ayuda. Las capacidades de workspace, rename transaccional, diagnósticos relacionados y tokens semánticos se anuncian solo según la negociación del cliente. Antes de pedir rename, el cliente materializa documentos cerrados encontrados por referencias, los sincroniza con sus versiones vigentes y recalcula `prepareRename` y referencias; las ediciones llevan esas versiones y el servidor rechaza la propuesta completa si falta una fuente sincronizada. Termina con código 0 tras `shutdown` y `exit`, y con 1 si la entrada se cierra antes de completar el ciclo de vida.
Las respuestas a cancelación, consultas en cola y el worker serializan escrituras mediante el mismo bloqueo de salida para que los bytes del protocolo no se mezclen. El cliente LSP no recibe logs por stdout; los errores de framing y E/S terminan el proceso y se informan por stderr del anfitrión.

compilar/build: valida `--destino`/`--target` antes de analizar, lee y analiza la fuente con la API (`build_native_object`,
que recibe el triplete en `NativeBuildRequest.target`), y solo si no hay errores enlaza el objeto con la biblioteca del
runtime de ese destino incrustada en `pseudo`, con el enlazador incluido, en un directorio temporal que se elimina siempre.
El resultado se copia junto al destino con un nombre provisional y se renombra, de modo que un fallo nunca crea ni
sobrescribe la salida. Informa `buildSucceeded` con la ruta tal como se pidió. Sin `-o`/`--salida`/`--output` la salida
es el nombre del archivo sin `.pseudo` (más `.exe` si el destino es Windows, en cualquier anfitrión) en el directorio
actual; si eso coincidiera con la fuente se usa `.out` para no sobrescribirla. `--profundidad`, `--sentencias`,
`--celdas`, `--tareas`, `--vocabulario` e `--idioma` se fijan en el ejecutable al compilar: el idioma de interfaz elige el
idioma de los diagnósticos del ejecutable y sus plantillas de línea. Errores del programa: diagnósticos y código 1; fuente
ausente o destino fuera de la lista cerrada: 2; ilegible, destino sin runtime incluido, enlazador no obtenible o enlace
fallido: 3, cada causa con su mensaje (`nativeTargetUnavailable`, `nativeTargetRuntimeMissing`, `linkerCacheUnavailable`,
`linkerDownloadFailed`, `linkerChecksumMismatch`, `linkerFailed`). Tras `linkerFailed` se copia la salida del enlazador,
porque es la única pista para diagnosticar un enlace roto. El código del ejecutable es 0, 3, 4 o 5 según su propio
protocolo. Los fallos del generador de código (sin diagnóstico de usuario) se informan con `linkerFailed`, porque
`TOOL.CLI.MESSAGES` no define un mensaje propio.

Adaptador `aot`: ejecuta programas compilados de verdad, con efectos de capacidad: escribe en el directorio de la caché el archivo de entrada de efectos (anfitrión, identidad, cinta para reproducir), lanza el ejecutable con `--effects-in` y `--effects-out`, y lo devuelve a la API para proyectar `effect_tape` y `host_observation`. Por cada petición `execute` compila con `build_native_object`
(plantillas de diagnóstico de campos separados por tabulador, `gc_stress` como recolección forzada), enlaza con el mismo
enlazador que `compilar` y lanza el ejecutable con entorno vacío y desde otro directorio, con las entradas en la entrada
estándar; `pseudolearn_api` convierte código de salida, salida y salida de error en la respuesta del protocolo. Una caché
en memoria, con tope de 32 ejecutables en un directorio temporal propio, reutiliza el ejecutable de un objeto idéntico
(perfiles distintos producen el mismo objeto); la clave es el contenido completo del objeto, no un resumen, de modo
que una colisión no puede devolver un ejecutable ajeno. El directorio se elimina al terminar, también si el protocolo se
cierra sin `shutdown`. Anuncia `execute` y `gc_stress`; no anuncia `observe`, `analyze`, `ir` ni `api`, porque el
sujeto está exento de observación y solo ejecuta.

La ejecución de ejecutar/run usa únicamente la API pública con entrada estándar, semilla, límites
de profundidad, sentencias, celdas y tareas vivas (`--tareas`/`--tasks`; omisión 4 096). La CLI fija además `max_json_depth` en 64, cuerpo HTTP decodificado y cable en 8 MiB, cabeceras en 16 KiB y 64 campos, ocho peticiones pendientes y 30 segundos por petición. La traza se narra con las plantillas trace* del catálogo generado;
la salida del programa se conserva literalmente. ri/ir imprime la RI canónica de la API o el diagnóstico
de la primera violación. No se introduce semántica propia ni se accede a capas internas. Los casos cli
verifican ambos idiomas, opciones equivalentes, códigos de salida y errores operativos.

`ejecutar`/`run` conserva la entrada pública de archivo suelto con el perfil existente. No exige
manifiesto ni imports para abrir un programa; las directivas de módulo siguen reservadas a la forma
contextual de unidad superior y sus grafías se pueden usar como nombres dentro de un programa suelto. La CLI entrega el texto leído y la configuración seleccionada sin transformarlos a `AnalyzeRequest`; la ejecución no consulta manifiestos, directorio de trabajo ni entorno para determinar edición o símbolos. La auditoría confirmó que no hace falta una opción nueva. Un archivo suelto que pega `Importar` o `Exportar` conserva el diagnóstico `moduleSyntaxOutsideProject` y no se ejecuta: la CLI no resuelve esas rutas contra el directorio de trabajo ni crea un manifiesto implícito. La proyección de dependencias sin enlazar (`API.PROGRAM.VIEW#R15`) pertenece a la API y no cambió la superficie de la CLI.

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

El transporte físico vive en `pseudolearn_host`, compartido con la app: la CLI no posee código de red. Acepta
`http` y `https` a cualquier host y dirección (loopback y privadas incluidas) porque el programa dueño de la ejecución es
quien decide a dónde habla. No se siguen redirecciones: el programa recibe la respuesta 3xx.

La elección nativa es una conexión HTTP/1 directa con Hyper 1.11.1
([API de handshake HTTP/1](https://docs.rs/hyper/1.11.1/hyper/client/conn/http1/fn.handshake.html)),
Tokio 1.54.1 y `tokio-rustls` 0.26.6 con Rustls 0.23.46. Hyper se usa como capa de protocolo y
conexión, no como cliente de alto nivel; el crate de anfitrión controla DNS, proxy, redirecciones, certificados y
límite de bytes. No se leen proxies del entorno, no se cargan cookies, no se reintenta y el TLS no
admite modo inseguro. Se descartó `reqwest` 0.13.5 porque su cliente de alto nivel habilita proxies
del sistema por defecto y sigue redirecciones por defecto; `ureq` 3.4.2 también toma proxies del
entorno y su interfaz de resolvedor/transport está bajo `unversioned`. La conexión de Hyper recibe
un `TcpStream` decidido por el resolvedor del adaptador y no crea un cliente que interprete esas
variables. `flate2` 1.1.10 con backend Rust descodifica gzip en flujo; `wire_limit` mide el cuerpo
recibido antes de descodificar y `effective_response_limit` corta los bytes decodificados.
La conexión se cierra al terminar la respuesta o al cancelar la espera. El plazo cubre resolución,
conexión, TLS y respuesta. DNS se resuelve una vez y se conecta a una sola dirección de esa instantánea, sin probar
direcciones alternativas.
La petición completa (método, destino en forma de origen, cabeceras, límites) se construye y valida
antes de resolver o conectar: una cabecera reservada (`host`, `connection`, `content-length`,
`transfer-encoding`, `upgrade`, `te`, `trailer`, `keep-alive`, `cookie`, `set-cookie`,
`accept-encoding`, `proxy-*`) o un valor con CR/LF nunca abre un socket. La línea de petición usa
la ruta y la consulta, no la URL absoluta, y `Host` lo fija el adaptador.

`TlsConfiguration` exige validación de certificados y admite raíces PEM añadidas por el anfitrión;
la configuración de producción carga además las raíces del sistema
([Rustls native certs](https://docs.rs/rustls-native-certs/0.8.5/rustls_native_certs/fn.load_native_certs.html))
y usa el parser PEM de `rustls-pki-types` ([PemObject 1.15.1](https://docs.rs/rustls-pki-types/1.15.1/rustls_pki_types/pem/trait.PemObject.html));
se descartó `rustls-pemfile`, cuyo mantenimiento terminó ([RUSTSEC-2025-0134](https://rustsec.org/advisories/RUSTSEC-2025-0134.html)).
No hay modo inseguro. Un fallo antes del primer byte HTTP se informa como `Failed`; después de empezar
a enviar un método con potencial de mutación, hasta completar la respuesta, se informa como
`Uncertain`. `GET` y `HEAD` permanecen en `Failed`. La biblioteca no aplica reintentos. `deny.toml`
añade únicamente `ISC`, autorizada para esta evaluación, junto a las licencias ya permitidas.
Rustls conserva una categoría distinta para certificados inválidos; los demás fallos del handshake
TLS se informan como fallos de conexión.
`ring`, usado por Rustls, incorpora `windows-sys 0.52.0`; `cargo-deny` omite solo esa versión exacta
en la regla existente de versiones múltiples, que sigue rechazando el resto de duplicados.
Los certificados y claves de `tests/fixtures/tls` son material sintético para las pruebas loopback de
certificado válido, expirado, host incorrecto y autofirmado; el proxy de prueba se inicia en un proceso
hijo para aislar las variables `HTTPS_PROXY` del resto de los tests.

#### Servidor HTTP de pruebas local

`cargo xtask http-test-server` inicia el servidor de integración en puertos efímeros de loopback y
publica en una línea JSON `http_address`, `https_address`, `certificate_directory`, `root_certificate`
y `tls_certificate`. El proceso queda en primer plano hasta que se detiene. `--bind` acepta solo una
dirección loopback (`127.0.0.1` o `::1`); `--tls-certificate` selecciona `valid`, `expired`,
`wrong-host` o `self-signed`. Por omisión se usa `127.0.0.1` y el certificado válido.

El servidor crea sus certificados PEM bajo `target/http-test-server/<pid>/` al arrancar; no se
versionan ni se reutilizan como certificados de producto. `root.pem` firma las variantes válida,
expirada y de host incorrecto; `self-signed.pem` no depende de esa raíz. El código genera los
certificados con [`rcgen` 0.14.10](https://docs.rs/rcgen/0.14.10/rcgen/struct.CertificateParams.html),
sin invocar herramientas del sistema.

| Ruta | Respuesta de prueba |
|---|---|
| `/texto`, `/binario`, `/vacio` | Cuerpo UTF-8, bytes no UTF-8 y respuesta vacía |
| `/estado/404`, `/estado/500` | Estados HTTP completos 404 y 500 |
| `/eco` | Método, ruta, cabeceras recibidas y cuerpo |
| `/redireccion/mismo`, `/redireccion/otro-origen`, `/redireccion/http` | Respuesta 302 relativa, con otro origen y con bajada a HTTP |
| `/grande`, `/infinito`, `/bomba-gzip` | 8 MiB + 1, flujo chunked sin fin (un byte por milisegundo, para que un navegador que cancela no sature la conexión siguiente) y gzip que se expande a 8 MiB + 1 |
| `/lento`, `/cerrar-a-mitad` | Espera de 60 segundos y cierre sin respuesta después de recibir el cuerpo |
| `/json-profundo`, `/cabeceras-muchas`, `/contador` | JSON con 65 niveles, 65 cabeceras y contador de solicitudes por ruta |

Todas las respuestas llevan `Content-Type: application/octet-stream` y `X-Content-Type-Options: nosniff`.
Todas las rutas responden también por TLS. El servidor no resuelve dominios externos ni sigue
redirecciones; CORS permite que una página local use las direcciones impresas. Las pruebas de
transporte con Playwright pueden tomar esas direcciones como destino de Fetch; `fetch_host.test.mjs`
mantiene su transporte falso para las verificaciones unitarias.

Cada ejecución en vivo arranca la API en modo `detached` y atiende cada `awaiting_effect` como consumidor de la API
pública: `physical_session.rs` abre el anfitrión y recorre el ciclo `effect_result`; `pseudolearn_host` despacha las
operaciones. La carpeta de trabajo es el directorio actual; las rutas absolutas, relativas y `..` se resuelven contra el
sistema de archivos, y solo las capacidades derivadas con `Subdirectorio` quedan confinadas con `cap-std` (derechos no
amplificables, enlaces simbólicos salientes rechazados dentro de esa subcapacidad). Cerrar una capacidad la retira de la
tabla y su uso posterior devuelve `capacidad_cerrada`; escribir reemplaza el contenido y un fallo tras mutar se informa
como `Uncertain`. La reproducción (`--reproducir-cinta`) no abre anfitrión ni toca disco. El reloj es el del sistema en
cada lectura y el temporizador espera tiempo real de forma cancelable. `--test-root` carga raíces PEM adicionales sin
retirar las del sistema y existe solo para las pruebas TLS locales. `--native` no ofrece anfitrión físico (pendiente
declarado en la sección 2). El anfitrión nativo declara sus garantías mediante `negotiate`. La API entrega la lista
completa de efectos de red pendientes; el anfitrión ejecuta hasta ocho solicitudes en paralelo y devuelve sus resultados
según finalizan. La VM pausa y reanuda la tarea asociada a cada secuencia, y la cinta registra ese orden de entrega.

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

### Modo editor de `ejecutar` (`--editor`)

`pseudo ejecutar --editor` (archivo suelto, o `--proyecto <directorio> --entrada <ruta lógica>`) es el borde con el que un
cliente de editor ejecuta un programa interactivo sin depurador ni DAP. Problema: `Leer` necesita entrada incremental, la
salida del programa no puede confundirse con el protocolo y una ejecución en bucle debe poder cancelarse. Elección: líneas
JSON en ambos sentidos, con una sesión por proceso; la identidad de sesión es el propio proceso y no hay multiplexación.
Se descartó reutilizar el protocolo de observación SEE como API de producto y crear un protocolo de depuración paralelo.

- **Salida estándar, solo eventos** (una línea JSON, claves en este orden): `hello` (`schema` 1, `capabilities`, `limits`),
  `output` (`text`), `awaiting_input`, `diagnostics` (`diagnostics`, `project_errors`, `sources`), `protocol_error`
  (`reason`) y `finished` (`status`, `termination`, `exit_code`). `hello` abre siempre y `finished` cierra siempre.
  La salida del programa viaja como texto dentro de `output`: un programa que imprime JSON no fabrica eventos. La salida de
  error queda reservada a fallos técnicos del proceso.
- **Entrada estándar, una orden por línea:** `{"command":"input","text":…}` (la cadena vacía es una línea válida),
  `{"command":"cancel"}` y `{"command":"close"}`. Un hilo lector aparte entrega las órdenes por un canal, de modo que
  `cancel` se atiende entre lotes de 4096 pasos de VM y mientras se espera entrada. Las líneas de entrada que llegan antes
  de que `Leer` las espere se encolan (hasta 1024). EOF con el programa en marcha no lo detiene; EOF con `Leer` esperando
  termina con `input_closed`. Una entrada de tipo inválido sigue esperando, igual que en la ejecución normal.
- **Estados de `finished.status`:** `completed` (código 0), `failed`, `cancelled`, `input_closed`, `output_limit` y
  `protocol_error` (todos código 1). Un uso incorrecto (sin `--entrada`, archivo ausente) se reporta con el código de uso
  u operativo habitual antes de emitir cualquier evento.
- **Límites:** órdenes de hasta 65 536 bytes (`command_bytes`), salida acumulada de hasta 1 048 576 bytes (`output_bytes`;
  la respuesta de la API acumula la salida, por lo que un tope mayor costaría memoria cuadrática en bucles que imprimen).
  Cancelar, cerrar o superar un límite libera el recurso de ejecución; la API no tiene cancelación de espera de entrada, por
  lo que cancelar una espera es dejar de alimentar y liberar el recurso.
- **Autoridad:** la ejecución usa el anfitrión físico completo con la carpeta del archivo o del workspace; no existe
  concesión alguna ni el workspace puede ampliarla o recortarla.

El proyecto se carga con el mismo lector confinado que `comprobar`, se arranca con la operación `start_project` de la API y
la CLI no duplica el compilador de proyectos. `src/editor_protocol.rs` define mensajes y límites, `src/editor_session.rs` el
bombeo de lotes, entrada y cancelación sobre puertos (canal y escritor) y `src/editor_command.rs` el arranque y el hilo lector.
Los tests unitarios usan canal y escritor falsos; `tests/editor_process.rs` ejercita el proceso real con archivo y proyecto.

### Interoperabilidad con dos clientes LSP (PG-6A.09)

Problema: que `pseudo lsp` responda bien a un solo cliente no demuestra que el protocolo esté bien dicho; un cliente puede
tolerar un rango, una revisión o un orden que otro no. Elección: una **secuencia única** de pasos (`tests/fixtures/lsp_interop/sequence.json`)
que ambos clientes ejecutan contra el proceso `pseudo lsp`, y un **comparador exacto** de las transcripciones resultantes.
Cliente A: la extensión de VS Code (`vscode-languageclient`). Cliente B: el cliente stdio mínimo de `tests/lsp_interop/`
(framing y JSON propios, sin `vscode-languageclient` ni `LspServer` en memoria). Ambos comparten el mismo motor: la
interoperabilidad prueba que el transporte, las capacidades negociadas y la forma de los mensajes no dependen del cliente;
**no** es un oráculo independiente de semántica, que sigue siendo del corpus.

- **Superficie común:** `initialize`, `definition`, `references`, `hover`, `semanticTokens/full`, `documentSymbol`,
  `prepareRename`, `rename`, más las notificaciones `didOpen`/`didChange`, `workspace/didChangeConfiguration`,
  `pseudolearn/workspaceSnapshot` (resincronización con revisión nueva), `shutdown` y `exit`. Se compara la respuesta de cada
  petición y el último `publishDiagnostics` por URI.
- **Normalización permitida, y solo esta:** el id de transporte (se sustituye por el número del paso) y el prefijo de raíz de
  los URI temporales (se sustituye por `file:///ROOT/`). No se normalizan códigos de error, mensajes, rangos UTF-16,
  revisiones de documento, símbolos ni ediciones: un rango corrido una unidad, una `version` distinta, un archivo sin
  diagnósticos publicados o un paso perdido producen una diferencia con su puntero JSON aunque el texto visible coincida.
- **Fixture bilingüe:** proyecto `app`/`geo` con perfil `es` (importado cerrado, alias `Como V`, cadena con carácter no BMP
  que cambia de longitud en una edición), documentos abiertos fuera del snapshot para el error de importación privada, la
  sombra de un importado y la declaración repetida (con información relacionada), y un documento en perfil `en` detectado por
  su texto. Los archivos adicionales con errores no entran en el snapshot porque un proyecto inválido no responde consultas.
- **Secuencia:** initialize → snapshot → open (principal, errores, biblioteca cerrada abierta después) → consultas → cambio
  v2 y cambio obsoleto v1 (debe ignorarse) → consultas y rename válido y rename a palabra reservada → configuración →
  open en `en` → resync (revisión 2) → consultas → shutdown → exit.
- **Versiones:** LSP 3.17, `pseudo` de esta revisión, `vscode-languageclient` el fijado en `apps/pseudolearn_vscode`.
- **Qué cubren las pruebas ligeras:** `tests/lsp_interop/` prueba normalizador y comparador con negativos, valida la secuencia
  y ejecuta el cliente B dos veces con raíces distintas exigiendo igualdad exacta. La transcripción del cliente A y la
  comparación A↔B se obtienen en la verificación pesada con host real; no se lanzan en las iteraciones ligeras.

### Adaptador de depuración VM

`pseudo dap` reserva stdout para DAP con `Content-Length` UTF-8. Reutiliza el lector acotado del
transporte LSP: cabeceras de hasta 8 KiB, cuerpo de hasta 8 MiB y rechazo de longitud ausente,
duplicada, negativa o excesiva antes de reservar. Hay ocho requests pendientes como máximo; el
desbordamiento o EOF sin `disconnect` termina como cierre anormal. El lector y el bombeo del recurso
son independientes, por lo que `pause` se atiende entre lotes de 64 eventos sin cancelar la ejecución.

El adaptador pertenece al borde CLI y consume únicamente operaciones de la API pública. No importa
VM ni timeline y no modifica el servicio LSP. Las capas y el presupuesto de retención siguen siendo
los del motor. Se descartó un crate DAP separado porque este transporte no tiene otro consumidor.
Continuar y pasar usan el recurso vivo; la operación histórica `step`, que recompila, no se utiliza.

La secuencia es `initialize`, `launch`, evento `initialized`, breakpoints y `configurationDone`.
`launch` acepta `program` o `project` con `entry`, `workspaceRoot`, `profile`, semilla
decimal i64 y `stopOnEntry` (por omisión verdadero). Solo se admite backend `vm`. La configuración
no recibe entorno ni ejecutables; acepta `args` (lista de cadenas) y `cwd` (carpeta existente, por omisión la del
workspace o la del archivo). No existen claves de permiso ni opciones de concesión. La extensión exige
confianza y rechaza fuentes sin guardar antes de crear el proceso.

Las fuentes provienen de un snapshot inmutable. `sourceReference` devuelve su texto y `adapterData`
conserva fuente/revisión; líneas y columnas se convierten una sola vez entre escalares del núcleo y
UTF-16/base negociada del cliente. Un breakpoint reemplaza el conjunto de su fuente y solo se verifica
si corresponde a una sentencia ejecutable exacta. No hay condiciones, logpoints ni traslado a otra
línea. Las tareas son hilos lógicos: la raíz 0 obtiene un ID DAP positivo y los IDs no se reutilizan.
Pila y variables aceptan páginas de hasta 4096; los handles opacos quedan ligados al stop y la tabla
se limita a 65 536 referencias. Continuar, pasar o retroceder invalida los handles anteriores.

`evaluate` admite `hover`, `watch` y `repl` como contextos de inspección equivalentes, nunca entrada
del programa. Reutiliza el compilador/VM y la copia aislada de API: literales, nombres, campos, índices
y operadores admitidos, sin llamadas, asignación, espera, tareas ni capacidades. Sus presupuestos y
errores pertenecen a la API; no hay evaluador de expresiones en el adaptador. La entrada de programa
se solicita con `pseudolearn/awaitingInput` y un token por espera; `pseudolearn/input` acepta acciones
`line` o `cancel`. Una línea vacía es válida y un token ajeno, consumido o tardío se rechaza.

`stepBack` mueve el cursor de inspección, conserva la punta y usa ventanas reconstruidas de la API.
Continuar desde el pasado recorre historia sin repetir salida ni efectos. El proveedor físico nunca
se entrega a replay. El bombeo de efectos vive en un worker acotado; la red reutiliza el transporte
canónico con cancelación externa comprobada cada 5 ms y conserva `Uncertain` tras enviar un método
mutante. La resolución de una respuesta no reanuda una VM pausada. Terminar invalida entrada,
referencias, transportes y recursos propios una sola vez.

El esquema de integración es
[DAP de Microsoft, revisión `1248685afb6b5d08c45d1c1a1d157db277f63b07`](https://github.com/microsoft/debug-adapter-protocol/blob/1248685afb6b5d08c45d1c1a1d157db277f63b07/debugAdapterProtocol.json),
SHA-256 `ff8ae4c6cfd588a050e9346c35fd104748a27ef4518d1c3268529ca6f8ff5818`.
Se toman framing, nombres de mensajes, negociación de coordenadas y lifecycle; no se toman semánticas
ajenas de pasos, tareas, efectos ni lenguaje. No se anuncian attach, modificación de variables,
condiciones, reverseContinue, reinicio, memoria ni depuración AOT.

### Enlazador incluido y destinos nativos

`pseudo compilar` enlaza con LLD 23.1.5, un único binario multisabor (`-flavor darwin`, `gnu` o `link`) que enlaza
Mach-O, ELF y COFF desde cualquier anfitrión. No se distribuye dentro de `pseudo` ni del VSIX: `pseudo` lo descarga la
primera vez que compila a nativo y lo guarda en la caché del usuario; `pseudo ejecutar` sin `--nativo` nunca lo necesita.

Orden de búsqueda (`native_linker.rs`): un `lld` junto al propio `pseudo` (ruta relativa al binario, para distribuciones
que lo traigan), después la caché (`linker_cache.rs`) y, si falta, la descarga (`linker_download.rs`). Un anfitrión sin
recurso publicado conserva el comportamiento anterior como respaldo: `rust-lld` junto a `pseudo` y, si no está, el driver
`cc` del `PATH` (que exige compilador C y, en macOS, Xcode). Los cuatro anfitriones admitidos tienen recurso, así que el
respaldo solo alcanza a otros sistemas.

| Anfitrión | Caché (variable de entorno, sin rutas absolutas en el código) |
|---|---|
| macOS | `$HOME/Library/Caches/pseudolearn/linker/lld-23.1.5/` |
| Linux | `$XDG_CACHE_HOME/pseudolearn/linker/lld-23.1.5/` o `$HOME/.cache/...` |
| Windows | `%LOCALAPPDATA%\pseudolearn\linker\lld-23.1.5\` |

Sin ninguna de esas variables (o vacías) el enlazador no se puede obtener: `linkerCacheUnavailable`, código 3. El adaptador
de conformidad `cli` hereda `PATH`, `HOME`, `XDG_CACHE_HOME` y `LOCALAPPDATA` salvo que el caso las fije, de modo que los
casos que vacían esas variables (`RT.LINKING#R5`, `TOOL.CLI.BUILD#R4`) prueban la causa sin depender del equipo.

Descarga: `pseudolearn_host::download_to_file` (GET con `User-Agent`, hasta cinco redirecciones HTTPS, sin bajar de HTTPS a
HTTP, límite de 512 MiB y 15 minutos) a un nombre provisional dentro de la carpeta de caché; `linker_assets.rs` fija como
datos, por anfitrión, la URL de la publicación `linker-lld-23.1.5` del repositorio, la suma SHA-256 del `.gz` y el tamaño
del binario. Solo si la suma coincide se descomprime (`flate2`), se comprueba el tamaño, se marca ejecutable y se renombra;
cualquier fallo borra los provisionales y no deja nada en la caché. Errores tipados: `DownloadFailed` (sin red, estado HTTP,
límite) → `linkerDownloadFailed`; `ChecksumMismatch` (suma o tamaño) → `linkerChecksumMismatch`. Un binario en caché con el
tamaño fijado se reutiliza sin volver a descargar ni a calcular la suma; uno de otro tamaño se reemplaza. Descartado:
verificar la suma completa en cada compilación, que añade medio segundo por proceso a cada enlace de la conformidad.

Origen de cada recurso (decisión de la persona: primero publicaciones oficiales de LLVM, y solo si faltan, compilación
estática reproducible):

| Recurso | Origen | Tamaño (binario / `.gz`) | Dependencias dinámicas comprobadas |
|---|---|---|---|
| `aarch64-apple-darwin` | `bin/lld` de `LLVM-23.1.5-macOS-ARM64.tar.zst` (oficial) | 146,2 MB / 45,3 MB | `otool -L`: libSystem, libc++, libz, libxml2 de `/usr/lib` |
| `x86_64-unknown-linux-gnu` | `bin/lld` de `LLVM-23.1.5-Linux-X64.tar.zst` (oficial) | 213,1 MB / 60,1 MB | `NEEDED`: libz, libm, libstdc++, libgcc_s, libc (glibc ≥ 2.29) |
| `x86_64-pc-windows-msvc` | `bin/lld.exe` de `clang+llvm-23.1.5-x86_64-pc-windows-msvc.tar.zst` (oficial) | 76,3 MB / 28,8 MB | importa KERNEL32, ADVAPI32, ntdll, OLEAUT32 |
| `x86_64-apple-darwin` | `tool/build_static_lld.sh` (LLVM no publica macOS x86_64) | 65,0 MB / 25,2 MB | `otool -L`: libSystem y libc++ de `/usr/lib` |

Ninguno depende de bibliotecas dinámicas de LLVM. `tool/build_static_lld.sh` descarga `llvm-project-23.1.5.src.tar.xz`,
lo verifica con su SHA-256 fijada y configura un LLVM sin bibliotecas compartidas, sin zlib, zstd ni libxml2 y con los
destinos X86 y AArch64, compila solo `lld` para la arquitectura pedida (`CMAKE_OSX_ARCHITECTURES`, objetivo macOS 11.0) y
lo depura con `strip -x`; el procedimiento es reproducible, aunque el binario depende del Xcode usado. Licencia de LLD:
Apache-2.0 WITH LLVM-exception; la publicación incluye `LICENSE.TXT` y `SHA256SUMS`. `cargo deny` no la evalúa porque LLD no
es una dependencia Rust.

Destinos (lista cerrada, `native_link_targets.rs`; `--destino` fuera de ella es `nativeTargetUnavailable`, código 2):

| Destino | Enlace (argumentos como datos) | Apoyos generados | Ejecución verificada |
|---|---|---|---|
| `aarch64-apple-darwin` | `-flavor darwin -arch arm64 -platform_version macos 11.0 11.0 -dead_strip` | *stubs* `.tbd` de libSystem, CoreFoundation y Security desde los símbolos indefinidos (`native_link_stubs.rs`) | macOS arm64 local y workflow |
| `x86_64-apple-darwin` | ídem con `-arch x86_64` | ídem | macOS x86_64 con Rosetta en local y workflow |
| `x86_64-unknown-linux-musl` | `-flavor gnu -m elf_x86_64 -static --gc-sections`, `crt1.o crti.o crtbegin.o` antes y `libunwind.a libc.a` en grupo y `crtend.o crtn.o` después | objetos musl autocontenidos del toolchain de Rust, incrustados con el runtime | workflow (ejecutable estático, `ldd`: «not a dynamic executable») |
| `x86_64-pc-windows-msvc` | `-flavor link /subsystem:console /entry:mainCRTStartup /nodefaultlib /opt:ref /machine:x64` | bibliotecas de importación generadas al enlazar con `lld -flavor link /lib /def:` a partir de la tabla símbolo→DLL | workflow (Windows Server 2025; importa solo DLL de System32) |

Windows no usa el CRT de MSVC: el objeto del programa trae su propio `mainCRTStartup` y el directorio TLS (ver README de
`pseudolearn_codegen`), y las importaciones salen de una tabla `dll\tsímbolo` que `build_windows_imports.rs` calcula al
compilar el runtime en un anfitrión Windows: toma los símbolos indefinidos del runtime y los resuelve contra las tablas de
exportación de las DLL de `%SystemRoot%\System32` en un orden fijo (kernel32, kernelbase, ntdll, … msvcrt, ucrtbase).
No se copia ninguna biblioteca del SDK de Windows; un símbolo sin DLL hace fallar la compilación de ese runtime. Por eso el
runtime de Windows solo se construye en Windows, y el de musl donde hay `musl-gcc` (ring compila C): `build.rs` construye
siempre el del anfitrión (obligatorio) y, sin la feature `test-host`, los demás destinos instalados en el toolchain; un
destino opcional que falla queda fuera con un aviso de Cargo y `--destino` lo rechaza con `nativeTargetRuntimeMissing`.

El archivo del runtime ya no se depura con `strip` en macOS: el `strip` de Xcode 27 (también con `-S`) quita el sufijo
`.llvm.<hash>` de los símbolos que ThinLTO promueve a `private extern`, y LLD 23 los rechaza como duplicados. En Linux se
usa `strip --strip-debug` de GNU, que no renombra. Coste: cada runtime de macOS ocupa unos 13 MB incrustados en `pseudo`
(antes 5,6 MB depurado). Descartado: depurar con `llvm-strip`, que no forma parte del perfil mínimo del toolchain.

Verificación remota: el trabajo `native-target` de `.github/workflows/verify-monorepo.yml`, que se ejecuta solo a mano
(`workflow_dispatch`; `tests/native_targets_workflow.rs` falla si el workflow declara otro disparador o pierde ese trabajo, y
prueba el verificador con disparadores automáticos deliberados). Se aloja en ese workflow y no en uno propio porque GitHub
solo despacha workflows ya registrados en el repositorio y registrar uno nuevo exige publicarlo en `master`; la entrada
`native_targets_only` omite los demás trabajos. Matriz: `ubuntu-latest` (musl), `macos-15-intel` (x86_64; la imagen `macos-13` ya no recibe runners), `macos-latest` (arm64) y `windows-latest`. Como `packages/pseudolearn_engine` y `packages/pseudolearn_spec` no versionan su `Cargo.lock`, el trabajo los resuelve con `cargo generate-lockfile` antes de compilar con `--locked`.
Cada runner compila `pseudo`, obtiene el enlazador por el mismo camino que el usuario y ejecuta
`tool/verify_native_target.py`, que compila con `pseudo build --target` los programas de
`examples/native-acceptance/manifest.json` (el caso C19 de `LANG.PROGRAM.CLASSIC` leído de `export.json`, las aceptaciones de
biblioteca y consola, un programa con tareas, canal y HTTP a un servidor en `127.0.0.1`, y el de la API de Rick y Morty),
los ejecuta desde otro directorio con entorno vacío (en Windows solo `SystemRoot`/`windir`) y compara salida, salida de
error y código de salida con los esperados derivados de las reglas; registra las dependencias de cada ejecutable y del
enlazador descargado y sube los registros como artefacto.

## 5. Reglas de legibilidad, estilo y estructura de código

Problema: la CLI debe producir ejecutables autónomos sin que el usuario instale el runtime. Elección: incrustar en `pseudo`
la biblioteca estática del runtime de cada destino construido (unos 13 MB por destino de macOS sin depurar; ver
«Enlazador incluido y destinos nativos»). Descartado: buscar
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

Para la elección HTTP se consultaron las versiones exactas: la guía de [`reqwest` 0.13.5](https://docs.rs/reqwest/0.13.5/reqwest/)
documenta que el cliente sigue redirecciones y usa proxies del sistema por omisión; [`ureq` 3.4.2](https://docs.rs/ureq/3.4.2/ureq/)
también toma proxies del entorno y declara inestables sus interfaces de resolución/transporte. Se tomó de
[`hyper` 1.11.1](https://docs.rs/hyper/1.11.1/hyper/client/conn/http1/fn.handshake.html) solo el protocolo HTTP/1
de bajo nivel, dejando resolución, conexión, plazo, TLS, redirección y corte de flujo bajo el adaptador.
[`flate2` 1.1.10](https://docs.rs/flate2/1.1.10/flate2/write/struct.MultiGzDecoder.html) aporta el decodificador
gzip incremental de miembros concatenados; se fija el backend Rust para no incorporar compilación C.


La cinta se obtiene de la sesión ejecutada y se publica mediante archivo provisional y renombrado;
un error de lectura, formato o escritura es operativo y no se oculta como análisis fallido. La
reproducción inválida no inicia una ejecución viva alternativa. Las pruebas de procesos comprueban
que el archivo existe, contiene efectos y permite repetir la salida, además del rechazo de corrupción.

### Registro de vectores de ataque de `E-PG-09`

`tests/security_vector_registry.rs` declara la lista cerrada de ocho vectores (`..`, ruta absoluta, enlace simbólico saliente, NUL interior, amplificación de derechos, uso tras cierre, adulteración de un bit de la cinta y truncamiento) y la prueba que bloquea cada uno, en `tests/security_vectors.rs` y `src/physical_host_tests.rs`. La batería falla si un vector requerido no está registrado o si su prueba no existe, de modo que un vector nuevo sin prueba o una prueba borrada no pasan en verde. Tiene casos negativos para cada una de esas dos condiciones y para un archivo ilegible.

`tests/network_vector_registry.rs` conserva el registro cerrado de E-PG-09: formas numéricas
alternativas, direcciones locales y especiales, normalización y autoridad del host, DNS mixto y
repetición de resolución, redirecciones, proxies, cabeceras, TLS, límites de cuerpo y plazo. Cada
identidad apunta a la prueba que la bloquea en `tests/network_security_vectors.rs` o en los módulos
unitarios de política y transporte. El registro exige tanto cada vector como su prueba e incluye
negativos para un vector sin prueba y una prueba sin vector.

`tests/network_adapter_contract.rs` usa `cargo xtask http-test-server` solo en loopback para comparar
el contrato físico con las respuestas del protocolo común. La cobertura del proceso real y la
batería adversaria pertenecen a la verificación pesada de P6; no forman parte de los filtros ligeros.

Un programa con tareas o canales se compila a código nativo como cualquier otro. `--tareas` limita las tareas vivas de la ejecución
virtual (omisión 4 096) y excede con `taskLimitExceeded`.

## Ejecución con anfitrión completo

run y run --editor, proyectos y DAP atienden efectos con `pseudolearn_host`, compartido con la app.
La carpeta inicial es el directorio actual; DAP admite cwd existente y args de cadenas. Los argumentos
de run se escriben tras -- y conservan vacíos, espacios y Unicode. No se requieren opciones de
concesión; las retiradas se rechazan como uso inválido. --seed conserva la semilla explícita y su
omisión usa entropía del SO. --test-root añade raíces TLS únicamente para pruebas locales.

Los archivos admiten rutas absolutas y .. desde la raíz inicial. Derivar un directorio confina esa
capacidad con cap-std y derechos no amplificables. HTTP admite todos los destinos HTTP/HTTPS sin
filtro de rangos; valida TLS mediante el sistema, devuelve redirecciones y no hereda cookies ni
proxies. Se admiten cabeceras de credenciales explícitas; solo se reservan las del transporte.
La cola física acotada y sus hilos independientes permiten que temporizadores y red esperen sin
bloquear otras tareas. La entrada interactiva devuelve identidad completa de la solicitud.

El transporte y sus pruebas TLS, gzip, cancelación y plazos viven en el crate compartido. Los vectores
de confinamiento se aplican a subcapacidades voluntarias; los antiguos vetos SSRF dejan de ser reglas.
AOT conserva el alcance de su backend y su ampliación física se verifica separadamente de la VM.

El transporte reutiliza getrandom 0.2.17, ya presente por ring, para evitar una segunda versión del
proveedor de entropía. Las licencias de transporte permiten BSD-3-Clause (subtle), ISC (ring y WebPKI)
y CDLA-Permissive-2.0 para los datos de raíces de respaldo del verificador de plataforma. La puerta
de dependencias mantiene el rechazo de duplicados y omite versiones exactas inevitables de
io-lifetimes y bindings Windows heredadas de cap-std. El puente también omite hashbrown 0.14.5
(oslog de FRB) y miniz_oxide 0.8.9 (backtrace de FRB), manteniendo las versiones actuales usadas por
indexmap y flate2. Estas excepciones son de compatibilidad de dependencias, sin cambiar validación TLS.

## Código de salida y salida de error (`PG-S.07`)

`pseudo ejecutar` termina con el campo `exit_code` de la respuesta final cuando la ejecución completó, y con 1 en
cualquier otro final (`run_command.rs::process_exit_code`). El texto de `Consola.EscribirError` llega en `output` y sus
tramos en `error_ranges`; `output_streams.rs` los reparte entre la salida estándar y la de error en el orden del
programa, y la sesión DAP los informa con la categoría `stderr`. El protocolo de editor lleva `error_ranges` sin
interpretarlo; la ejecución nativa (`--native`) y el AOT no lo implementan todavía (`PG-N.08`).

### Aceptación de la biblioteca de propósito general

`examples/general-purpose/acceptance/` contiene un programa por área, con salida determinista: `pure-library.es.pseudo`
(texto, números, formato, colecciones y calendario puro), `files.es.pseudo` (crea y borra su propio subdirectorio de la
carpeta de trabajo) y `console-environment.es.pseudo` (entorno, zona del sistema, flujo de error y código de salida).
`tests/general_purpose_acceptance.rs` los ejecuta con el binario real en una carpeta temporal y exige salida estándar,
salida de error, código de proceso y carpeta de trabajo vacía al terminar. Verificado solo en macOS arm64; Windows y
Linux no se ejecutaron.

### Aceptación de las construcciones del lenguaje

`examples/language-constructs/acceptance/` reúne el programa único de aceptación de registros, genéricos, variantes y
liberación por ámbito: `constructs.es.pseudo` (arreglo de registros, registro por referencia, campo y firma de método
de tipo registro, clase e interfaz genéricas, variante declarada con `Segun` y objetos de bloque en un bucle),
`scope.es.pseudo` (objetos de bloque bajo `--celdas`) y `project/` (constante, enumerado, registro, interfaz,
subprograma y clase genéricos importados de otro paquete). `tests/language_constructs_acceptance.rs` ejecuta el binario
real y exige la salida derivada de las reglas; la extensión de escritorio, la extensión web y la app reutilizan los
mismos programas. La ejecución nativa no se incluye porque la paridad nativa de estas construcciones es de `PG-N.08`.
