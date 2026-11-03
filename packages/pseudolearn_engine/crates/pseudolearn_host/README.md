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

Desde el miembro: `cargo test -p pseudolearn_host`, `cargo clippy -p pseudolearn_host --all-targets -- -D warnings`
y las reglas mecánicas del motor. Las pruebas físicas usan loopback y carpetas temporales; no Internet.
La medición ios-arm64 usa Release con opt-level z, LTO fat, una unidad y símbolos separados.

## Fuentes

Hyper se usa para protocolo HTTP/1 sobre conexiones explícitas, Tokio para esperas cancelables y
Rustls con rustls-platform-verifier para validar contra el almacén del sistema, incluido iOS.
Se descarta un cliente que siga redirecciones o herede proxies ambientales.
