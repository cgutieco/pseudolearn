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
