# pseudolearn_wasm

## 1. Qué es y qué no es

Expone `pseudolearn_api` como módulo WebAssembly para navegadores. El crate convierte cadenas JSON en operaciones de `ApiSession` y devuelve cadenas JSON con la respuesta completa.

Responsabilidades: crear sesiones aisladas, reenviar operaciones y conservar la codificación exacta de enteros JSON de 64 bits.

Fuera de alcance de producto: interfaz Flutter web, almacenamiento, autenticación y presentación. El
transporte de una aplicación de producto queda fuera; `browser/` contiene el adaptador Fetch de
referencia para comprobar la frontera de red de la API.

Fuera de alcance técnico: AOT, Cranelift, memoria compartida, punteros prestados entre llamadas y buffers de bytes visibles al consumidor.

Casos soportados: análisis, ejecución por lotes, entrada, cancelación, consultas, servicio de lenguaje, negociación y liberación de recursos a través de la API existente.

| Pendiente | Dependencia | Estado |
|---|---|---|
| Integración del módulo en una aplicación web de producto | Decisión de producto y adaptadores de anfitrión | Fuera de alcance de R8 |

## 2. Guía operativa y ciclo de vida

Requisitos: Rust `1.99.0`, objetivo `wasm32-unknown-unknown`, `wasm-bindgen-cli` `0.2.129`, Node.js `22.12.0` o posterior, pnpm `12.8.1`, Google Chrome estable y Playwright Core `1.64.0`.

Preparación:

```bash
rustup target add wasm32-unknown-unknown --toolchain 1.99.0
cargo install wasm-bindgen-cli --version 0.2.129 --locked
pnpm --dir packages/pseudolearn_engine/crates/pseudolearn_wasm/browser install --frozen-lockfile
```

Generación reproducible del módulo y sus enlaces JavaScript:

```bash
bash packages/pseudolearn_engine/tool/wasm.sh build
```

Pruebas del artefacto final en Chrome, incluida la comparación con la API nativa:

```bash
bash packages/pseudolearn_engine/tool/wasm.sh test
```

Los archivos generados quedan en `packages/pseudolearn_engine/target/wasm-browser/pkg/`. No se versionan.

## 3. Arquitectura y modelo del sistema

El crate es la capa exterior del motor y solo importa `pseudolearn_api`. La feature `native` permanece desactivada. `wasm-bindgen` genera la frontera JavaScript y `serde_json` conserva el protocolo JSON de la API.

| Carpeta | Responsabilidad | Puede importar | Prohibido |
|---|---|---|---|
| `src/` | Enlace Wasm y sonda nativa para comparación | API, `serde_json`, `wasm-bindgen` | Cranelift, Flutter, app, I/O dentro del módulo Wasm |
| `browser/` | Página mínima, adaptador Fetch y pruebas del paquete generado | Paquete Wasm, Fetch, Node.js, Playwright Core | Lógica de motor duplicada, datos generados editados a mano |

`WasmSession.call(operation, argumentsJson)` analiza el objeto de argumentos en Rust, llama `ApiSession.call` y serializa su sobre de éxito o fallo. Los enteros de 64 bits viajan como tokens JSON, no como `Number` de JavaScript. La memoria es privada al módulo; cada llamada intercambia cadenas dueñas.

La ejecución es síncrona. El anfitrión divide el trabajo en lotes, devuelve el control al navegador y solicita cancelación entre llamadas. El archivo de salida limita la memoria lineal a 256 MiB. Cualquier `Uint8Array` creado por un consumidor sobre la memoria del módulo queda invalidado cuando `memory.grow` reemplaza su `ArrayBuffer`; este crate no expone tales vistas.

`browser/fetch_host.mjs` adapta `network_send` al `fetch` del navegador. `declareFetchHost(session)` comunica
el descriptor A4 mediante `negotiate`; `performFetch(effect, { allowedOrigins, fetchImplementation })`
permite inyectar el transporte y concede solo los orígenes incluidos explícitamente. Envía con
`credentials: omit`, `cache: no-store` y `redirect: manual`; aborta al vencer el plazo y corta el flujo
al superar el límite de bytes decodificados. El navegador valida TLS, aplica su política SSRF y
descomprime contenido; el adaptador declara que no puede medir bytes de cable, distinguir errores de
certificado ni leer de forma portable la ubicación de una redirección.

La sonda `wasm_native_probe` usa el mismo protocolo de registros tabulados y mantiene una sesión nativa para comparar, operación por operación, las mismas solicitudes y respuestas que ejecuta Playwright.

## 4. Decisiones de diseño y fundamentos técnicos

**Problema:** el transporte JavaScript de números puede redondear enteros superiores a `2^53 - 1`.

**Elección:** la frontera recibe y devuelve texto JSON; Rust analiza y serializa directamente con `serde_json`, y JavaScript no convierte los argumentos numéricos antes de enviarlos.

**Alternativas descartadas:** pasar mapas JavaScript o números tipados pierde exactitud de enteros de 64 bits; exponer la API Rust directamente duplica su protocolo en el consumidor.

**Problema:** una biblioteca compilada para navegador no debe incorporar backend nativo ni crecer sin límite explícito.

**Elección:** `pseudolearn_api` se declara con `default-features = false`; el enlazador limita la memoria Wasm a 256 MiB durante la generación canónica. El consumidor usa memoria solo durante una llamada y no conserva vistas.

**Alternativas descartadas:** activar `native` incorpora Cranelift; compartir buffers entre llamadas requiere reglas de vida incompatibles con el crecimiento de memoria; dejar el límite al navegador vuelve no reproducible el comportamiento de agotamiento.

**Problema:** las macroexpansiones de `wasm-bindgen` pueden generar `unsafe` aunque el adaptador escrito a mano no lo use.

**Elección:** `unsafe` queda permitido únicamente en el crate declarado; el código propio no contiene bloques `unsafe` y los enlaces generados solo viven bajo `target/`.

**Alternativas descartadas:** permitir `unsafe` globalmente debilita todos los crates; mantener a mano los enlaces generados hace no reproducible la frontera.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, sin comentarios, `TODO`, `unwrap`, `expect`, pánicos explícitos ni conversiones numéricas con pérdida. El adaptador no contiene código `unsafe`. Los límites del crate se declaran en `architecture.yaml` del miembro.

La salida de `wasm-bindgen` no se edita ni versiona. El paquete se genera con el CLI y el lockfile fijados; una segunda generación se compara byte por byte con la primera.

## 6. Decisiones de producto que condicionan el código

El navegador consume las mismas operaciones y observables que la API. El anfitrión controla los puntos de cesión y cancelación sin cambiar la semántica de la VM. Los errores de operación permanecen en el sobre JSON; JSON sintácticamente inválido produce una excepción JavaScript explícita.

## 7. Verificación, testing y aseguramiento de calidad

`cargo xtask verify` ejecuta formato, Clippy, pruebas del workspace, verificadores Rust y auditoría de dependencias. `bash tool/wasm.sh test` compila el artefacto release, comprueba que no aparece `native` ni Cranelift, valida reproducibilidad y ejecuta Playwright en Chrome.

La comprobación ligera del adaptador Fetch usa `node --test browser/fetch_host.test.mjs`; no necesita
servidor ni navegador. Sus casos cubren negociación A4, concesión de origen, opciones Fetch, fallos de
conexión, redirecciones opacas, tope de cuerpo decodificado, plazo y petición mal formada.

Para comprobar transporte en navegador, iniciar `cargo xtask http-test-server` desde la CLI. El
proceso publica `http_address`, `https_address` y `root_certificate` en su línea JSON inicial; el
harness de Playwright puede usar las direcciones como destinos de Fetch y la raíz PEM para confiar en
TLS dentro de su perfil de prueba, sin desactivar la validación. `browser/server.mjs` sigue sirviendo
solo la página y los archivos Wasm. Los tests unitarios del adaptador mantienen `fetch` falso y no
abren sockets.

La prueba de navegador compara respuestas byte por byte con `wasm_native_probe` para completado, análisis, entrada, extremos de enteros, cancelación entre lotes y liberación. Otros casos rechazan JSON inválido, fuerzan crecimiento de memoria, comprueban la invalidación de vistas y verifican que superar el límite falla sin alterar la instancia.

## 8. Fuentes consultadas y genealogía conceptual

`wasm-bindgen` aporta la generación de enlaces JavaScript desde Rust. Se fija la misma versión para el crate y el CLI para mantener compatible el formato de enlace. WebAssembly define la memoria lineal y el reemplazo del `ArrayBuffer` al crecer; el contrato de este paquete evita compartir vistas entre llamadas.
