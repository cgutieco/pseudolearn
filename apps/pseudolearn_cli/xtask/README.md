# xtask

## 1. Qué es y qué no es

Tooling de verificación de pseudolearn_cli; no implementa la lógica de la CLI.

## 2. Guía operativa y ciclo de vida

Desde el workspace: `cargo test -p xtask`, `cargo test -p xtask http_test_server` y `cargo xtask verify`.
Rust se fija en el archivo de cadena del workspace. No se publica.

El servidor de integración se ejecuta con `cargo xtask http-test-server`. Escucha en loopback y
puertos efímeros, genera certificados bajo `target/http-test-server/<pid>/` y escribe sus direcciones
y la raíz PEM como JSON en stdout. `--bind` solo acepta loopback; `--tls-certificate` permite
seleccionar `valid`, `expired`, `wrong-host` o `self-signed`. El proceso permanece en primer plano.

## 3. Arquitectura y modelo del sistema

`src/` contiene las tareas operativas de la CLI. `http_test_server` inicia los listeners y coordina
el estado compartido; los módulos `http_test_server_certificates`, `http_test_server_listener` y
`http_test_server_routes` generan certificados, atienden conexiones y describen rutas. Sus
dependencias están declaradas en `architecture.yaml` del workspace y no se enlazan al ejecutable
`pseudo`.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: automatizar la verificación integral de formato, linter, tests y conformidad.
Elección: subcomando `cargo xtask verify`.
Alternativa descartada: scripts de shell no portables entre plataformas.

Problema: las pruebas de transporte necesitan respuestas reproducibles sin acceder a Internet.
Elección: un servidor HTTP/1 y TLS en Rust, limitado a direcciones loopback y con puertos efímeros;
`rcgen` crea certificados sintéticos al arrancar. El servidor declara las rutas, los fallos y los
cuerpos de límite; no sigue redirecciones ni depende de proxies ambientales.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin unsafe ni pánicos explícitos. Límites en las reglas del workspace.

## 6. Decisiones de producto que condicionan el código

Habilita el front-end de la CLI y sus verificadores asociados.

## 7. Verificación, testing y aseguramiento de calidad

El test `cargo test -p xtask http_test_server` verifica la matriz de rutas, loopback, certificados y
rechazo de otras interfaces. El modo de prueba requiere poder abrir sockets en loopback. Formato,
Clippy estricto, verificadores mecánicos y chequeo de dependencias siguen disponibles mediante
`cargo xtask verify`.

## 8. Fuentes consultadas y genealogía conceptual

Patrón `xtask` estándar de Rust para automatización. La generación de certificados usa
[`rcgen` 0.14.10](https://docs.rs/rcgen/0.14.10/rcgen/struct.CertificateParams.html): se toma su
generación y firma de certificados X.509 en Rust, y se descarta invocar `openssl` o guardar claves
de prueba versionadas.
