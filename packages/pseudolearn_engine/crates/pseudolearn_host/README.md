# pseudolearn_host

## Responsabilidad y arquitectura

Atiende efectos reales del formato público JSON de ejecución, sin importar el motor ni interpretar
el lenguaje. Es una capa hoja compartida por la CLI y el puente de la app. Importa únicamente
bibliotecas de transporte, serialización y sistema declaradas en las reglas del miembro.

La autoridad inicial es plena: rutas absolutas o relativas a la carpeta de trabajo, red HTTP/HTTPS
a cualquier destino, argumentos explícitos, reloj del sistema y temporizadores reales. La derivación
de directorios es voluntaria y confinada mediante descriptores de cap-std, con derechos no amplificables.
TLS usa el verificador de plataforma; no hay modo inseguro, cookies añadidas, proxies ni reintentos.
El programa recibe las redirecciones para decidir si las sigue. Los errores son resultados JSON tipados.

Cada ejecución posee sus recursos; al destruir el anfitrión se cierran sus archivos y directorios.
Los consumidores no copian implementaciones de transporte. El runtime conserva validación normativa,
agenda y cinta: este crate solamente atiende solicitudes ya identificadas.

## Verificación

### Operaciones de directorio y de archivo

`physical_directory_ops.rs` atiende `directory_exists`, `directory_is_directory`, `directory_list`,
`directory_delete`, `directory_rename` y `directory_create`; `physical_file_append.rs` atiende
`file_append_text` y `file_append_bytes`. Ambas ramas de `DirectoryResource` (`Ambient` y `Confined`) tienen la
misma semántica: las rutas de la rama `Confined` pasan por `checked_path` y por los descriptores de cap-std, de modo
que ni `..`, ni rutas absolutas, ni enlaces simbólicos salen del directorio atenuado.

Decisiones: `Listar` devuelve nombres ordenados por puntos de código (el orden del disco no puede ser observable) y
rechaza un nombre que no es UTF-8 con `utf8_invalido`; `Borrar` elimina un archivo o un directorio vacío y nunca es
recursivo; `Renombrar` nunca sobrescribe porque comprueba el destino antes de mover; `CrearDirectorio` crea un único
nivel. Los fallos del sistema operativo se mapean a las variantes existentes de `ErrorES`: directorio no vacío a
`peticion_invalida`, y es-directorio o no-es-directorio a `ruta_invalida`; no se añadieron variantes. Las consultas
exigen el derecho de lectura de la capacidad y las mutaciones el de escritura.

Límites declarados: comprobar-y-renombrar y comprobar-y-crear no son atómicos entre procesos (otro proceso puede ganar
la carrera; el resultado sigue siendo un error tipado y nunca una salida del confinamiento). `AgregarTexto` y
`AgregarBytes` escriben al final del contenido actual del archivo abierto; los modos de `Abrir` no cambian, así que
abrir en escritura sigue vaciando el archivo y añadir sobre contenido previo exigiría un modo de apertura nuevo, que
ampliaría el modelo de derechos y no forma parte de esta fase. Una escritura interrumpida se informa como incierta.
En macOS (APFS) no se prueba el nombre no UTF-8 porque el sistema de archivos lo rechaza al crearlo; esa prueba corre
solo en Linux, y los nombres que solo difieren en mayúsculas no se prueban porque APFS los unifica.

Desde el miembro: `cargo test -p pseudolearn_host`, `cargo clippy -p pseudolearn_host --all-targets -- -D warnings`
y las reglas mecánicas del motor. Las pruebas físicas usan loopback y carpetas temporales; no Internet.
`tests/physical_directory_ops.rs` cubre cada operación en su camino feliz e infeliz, mil rutas con `..` aleatorias sin escapes del confinamiento y el enlace simbólico que apunta fuera.
La medición ios-arm64 usa Release con opt-level z, LTO fat, una unidad y símbolos separados.

## Fuentes

Hyper se usa para protocolo HTTP/1 sobre conexiones explícitas, Tokio para esperas cancelables y
Rustls con rustls-platform-verifier para validar contra el almacén del sistema, incluido iOS.
Se descarta un cliente que siga redirecciones o herede proxies ambientales.

## Entorno y zona horaria del sistema (`PG-S.05`, `PG-S.06`)

`physical_environment.rs` lee con `std::env::var_os` solo el nombre pedido: no enumera ni hereda nada más. Un nombre
vacío, con `=` o con NUL es `peticion_invalida` sin consultar al sistema (en Rust esas llamadas harían `panic`); un
valor que no es UTF-8 es `utf8_invalido`. Unix distingue mayúsculas en los nombres y Windows no: el corpus declara que
el anfitrión decide.

`physical_local_zone.rs` implementa `AhoraLocal`: lee el reloj y pregunta a `jiff` el desplazamiento vigente en ese
instante en la zona del sistema, que incluye el horario de verano, y lo trunca hacia cero a minutos enteros. Los
tests inyectan la zona (`TimeZone::get("America/New_York")` en enero y julio, y zonas fijas); el producto nunca
modifica `TZ`.

### `PS-E01`: origen del desplazamiento (DS-18)

| Alternativa | Resultado |
|---|---|
| (a) `jiff` 0.2.37 con `default-features = false` y `std`, `tz-system`, `tzdb-zoneinfo` | **Elegida.** Añade 2 cajas nativas (`jiff`, `jiff-core`) y `windows-link` solo en Windows; `cargo deny check licenses bans sources` en verde (licencia `Unlicense OR MIT`, sin duplicados nuevos) |
| (b) `unsafe` o FFI propio | Descartada: este miembro declara `unsafe_allowed: false` |
| (c) el consumidor inyecta el desplazamiento | No hace falta; duplicaría la lógica en CLI, app y web |

Plataformas: compila y pasa sus pruebas en macOS; la compilación para `aarch64-apple-ios-sim`, `aarch64-apple-ios` y
`x86_64-pc-windows-msvc` se comprueba con `cargo check --target`. No se afirma ejecución en Windows ni en un iPhone
físico. En un sistema sin base de zonas o sin `/etc/localtime` legible, `jiff` informa UTC y el desplazamiento es cero;
es un límite declarado. La extensión web usa `Date#getTimezoneOffset`, que no tiene precisión de segundos ni conoce las
reglas históricas de la zona.

## Consola: error y código de salida (`PG-S.07`)

`physical_console.rs` confirma `console_write_error` con la cantidad de bytes UTF-8 (el texto lo separa el consumidor
según `error_ranges`, no el anfitrión); valida `console_set_exit_code` (0–255, si no `peticion_invalida`). Un solo búfer de salida conserva el orden relativo entre ambos flujos.

## Descarga verificable para herramientas (`physical_download.rs`)

`download_to_file(DownloadRequest, destino, TlsConfiguration)` descarga una URL HTTP/HTTPS a un archivo en flujo, sin
cargarla en memoria: la CLI la usa para obtener el enlazador incluido. A diferencia de las peticiones del programa (que
reciben las redirecciones para decidir), sigue hasta `redirect_limit` redirecciones, porque las publicaciones de GitHub
redirigen a su almacén; nunca pasa de HTTPS a HTTP. Usa el mismo resolutor, la misma validación de anfitrión y el mismo
verificador TLS de plataforma que la red del programa, envía `User-Agent` y `Connection: close`, y corta con
`TooLarge` al superar `byte_limit` y con `TimedOut` al agotar `timeout`. Los errores son valores de `DownloadError`
(`InvalidAddress`, `Unreachable`, `Status`, `TooLarge`, `TooManyRedirects`, `TimedOut`, `Storage`); la integridad (suma
SHA-256) la comprueba quien llama. `physical_download_tests.rs` cubre, con un servidor en `127.0.0.1`, respuesta
completa, redirección relativa, 404, límite de tamaño, cadena de redirecciones excesiva, puerto cerrado y esquema no HTTP.
Descartado: un cliente HTTP en la CLI, que duplicaría el transporte que este crate ya posee.

## Plazos de las pruebas TLS

Las pruebas de `physical_network_tls_send_tests` usan un plazo de petición de 60 s y esperan al servidor 90 s. Con 2 s y
3 s fallaban de forma intermitente: el verificador de la plataforma (en macOS, `trustd`) serializa las evaluaciones y,
con varias pruebas en paralelo o la máquina cargada, el apretón TLS superaba los 2 s y la respuesta era `tiempo_agotado`.
Con 16 procesos concurrentes fallaban todas; con los plazos nuevos pasan todas y tardan 12–14 s. Las pruebas comprueban
la validación de certificados y que se ignore `HTTPS_PROXY`, no el plazo; el plazo se prueba en
`physical_network_send_tests` con una resolución de nombres más lenta que el plazo declarado.
