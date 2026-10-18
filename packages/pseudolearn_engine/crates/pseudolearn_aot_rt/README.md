# pseudolearn_aot_rt

## 1. Qué es y qué no es

Frontera binaria entre el código máquina que genera `pseudolearn_codegen` y el motor Rust. Define el contexto de
ejecución `#[repr(C)]` que recibe como primer argumento toda función nativa y los puntos de entrada `extern "C"`
`rt_aot_*` que el código generado invoca para lo que no se emite en línea: asignación de arreglos y objetos,
operaciones de texto, matemática correctamente redondeada, azar determinista, entrada, salida y registro de fallos
con su sitio de origen. Toda la lógica vive en funciones seguras de `pseudolearn_runtime` y `pseudolearn_library`;
este crate solo convierte punteros en referencias y traduce errores tipados a diagnósticos.

Responsabilidades exclusivas: layout del contexto y sus desplazamientos, códigos de retorno, pila de raíces, tabla
de sitios de fallo, formateo de fallos, flujos de entrada y salida del programa.

Fuera de alcance de producto: trazas, instantáneas e inspección paso a paso (el sujeto `aot` está exento de
`ENG.TRACE.*` y `ENG.STATE.*`); desoptimización hacia la VM; límite de caracteres de salida (`ENG.LIMITS` no lo
define).

Fuera de alcance técnico: generación de código máquina, enlace, formato de metadatos y función `main` del
ejecutable (viven en `pseudolearn_codegen` y en el enlazador); acceso en línea a memoria y aritmética entera
(las emite el código generado); dependencias externas; `unsafe` fuera de las dos funciones de la tabla de la
sección 5.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Punto de entrada `pseudolearn_aot_main` y decodificación de metadatos (literales, clases, tabla de sitios) | Formato de metadatos emitido por codegen | Enlace nativo (`RT.LINKING`) |
| Celdas por referencia (`cell.local`, `cell.element`, `cell.field`, `cell.load`, `cell.store`) | Lowering de memoria del backend | Memoria y clases del backend |
| Salida a `stdout` con vaciado previo al fallo y proyección de estado a códigos de salida 0, 3, 4 y 5 | Proceso del ejecutable | `RT.PROCESS` |

## 2. Guía operativa y ciclo de vida

Desde `packages/pseudolearn_engine`:

- Compilar: `cargo check -p pseudolearn_aot_rt`.
- Probar: `cargo test -p pseudolearn_aot_rt -- --test-threads=1`.
- Verificar todo el motor: `cargo xtask verify`.
- Verificar `unsafe`: `cargo run --manifest-path ../pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command --bin rust-checks -- unsafe .`.

El crate es una biblioteca Rust (`rlib`). Los símbolos `rt_aot_*` llevan `#[unsafe(no_mangle)]` y quedan disponibles
para el enlazador cuando el crate se empaquete como biblioteca estática. Una `AotSession` crea el motor y el contexto
y los mantiene en cajas de dirección estable; `context_pointer()` entrega el puntero que recibe el código nativo.
Los flujos de entrada y salida y la tabla de sitios se inyectan al crear la sesión.

## 3. Arquitectura y modelo del sistema

Nivel 6, hoja del grafo. Importa `pseudolearn_source` (tramo vacío para renderizar), `pseudolearn_abi` (`Handle`),
`pseudolearn_diagnostics`, `pseudolearn_runtime` y `pseudolearn_library`. Ningún otro crate del motor lo importa
salvo el enlazador del ejecutable.

Contexto `AotRuntimeContext` (`#[repr(C)]`, 64 bytes; el código generado conoce los desplazamientos exportados como
`CONTEXT_*_OFFSET`):

| Desplazamiento | Campo | Tipo | Contenido |
|---|---|---|---|
| 0 | `heap_words_pointer` | `*mut u64` | Base actual de las palabras del montón; se refresca tras toda entrada que pueda reubicar el vector |
| 8 | `instruction_remaining` | `i64` | Unidades de bloque restantes; `i64::MAX` sin presupuesto |
| 16 | `frame_depth` | `u32` | Marcos activos, mantenido por el código generado |
| 20 | `frame_limit` | `u32` | Máximo de marcos (por omisión 1 000) |
| 24 | `root_top` | `u32` | Tope de la pila de raíces |
| 28 | `root_capacity` | `u32` | Capacidad de la pila de raíces |
| 32 | `roots_pointer` | `*mut u32` | Base de la pila de raíces (`Handle` de 32 bits) |
| 40 | `fault_site` | `u32` | Sitio del primer fallo observado por la última entrada que falló |
| 44 | `fault_status` | `u32` | `0` continúa, `1` fallo del programa, `2` límite |
| 48 | `result_word` | `u64` | Resultado de la última entrada con estado `0` |
| 56 | `engine_state` | `*mut AotEngine` | Estado propietario: montón, azar, diseños, sitios, flujos, fallo y avisos |

Protocolo de toda entrada: `rt_aot_*(context, site, operandos…) -> u32`. `site` indexa la tabla de sitios de fallo.
El retorno es `0` si el cómputo continúa (el valor queda en `result_word`), `1` si el programa falló y `2` si se agotó
un límite o la entrada. Ante un retorno distinto de 0 el código generado propaga el estado sin ejecutar más efectos.
Las entradas con asignación publican `heap_words_pointer` antes de volver; el código generado no conserva ese puntero
a través de ninguna llamada.

| Entrada | Operandos | Resultado en `result_word` |
|---|---|---|
| `rt_aot_array_new` | `descriptor = tipo \| rango << 8`, puntero a `rango` extensiones `i64` | asa del arreglo |
| `rt_aot_object_new` | clase | asa del objeto |
| `rt_aot_object_copy` | asa | asa de la copia |
| `rt_aot_text_literal` | puntero y longitud UTF-8 | asa del literal |
| `rt_aot_text_concat` | dos operandos; el bit 32 marca un carácter | asa del texto |
| `rt_aot_text_format` | palabra, tipo | asa del texto formateado |
| `rt_aot_text_query` | `TEXT_LENGTH`, `TEXT_TO_INTEGER` o `TEXT_TO_REAL`, asa | longitud, entero o binario64 |
| `rt_aot_text_character` | asa, posición `i64` tal como la entrega la RI | punto de código |
| `rt_aot_text_compare` | dos asas | `-1`, `0` o `1` como `i64` |
| `rt_aot_math_unary` | `MATH_*`, binario64 | binario64 o entero con signo |
| `rt_aot_real_power` | base, exponente | binario64 |
| `rt_aot_random_real` | — | binario64 en `[0, 1)` |
| `rt_aot_write` | palabra, `tipo \| NEWLINE_FLAG` | 0 |
| `rt_aot_read` | tipo | palabra leída |
| `rt_aot_fault` | — | el código del sitio decide el estado |

Códigos de tipo: `KIND_INTEGER` 0, `KIND_REAL` 1, `KIND_BOOLEAN` 2, `KIND_CHARACTER` 3, `KIND_REFERENCE` 4.

Fallos: el primer fallo queda en `AotEngine::fault()` con sitio, código y rango fuente; los siguientes solo actualizan
`fault_site` y `fault_status`. `status_of` clasifica `statementBudgetExhausted` y el agotamiento de entrada como
límite (`2`) y todo lo demás como fallo del programa (`1`). El agotamiento de entrada no tiene diagnóstico:
`FaultRecord.code` es `None` y `render_fault` devuelve `None`. Las lecturas con tipo incorrecto consumen la línea,
registran un aviso `readValueTypeMismatch` (`AotEngine::notices()`) y repiten la lectura. Los fallos de escritura y los
códigos sin entrada en el catálogo de diagnósticos se informan como `internalFault`.

Raíces: la pila de raíces se lee como `roots[0..root_top]`. El generador mantiene en ella las asas vivas a través de
cada punto de asignación; la entrada las pasa al recolector, de modo que un objeto sin raíz ni alcanzable puede
reclamarse y uno enraizado conserva su asa.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: la frontera necesita llamar a la biblioteca matemática, pero `pseudolearn_library` importa
`pseudolearn_runtime`, de modo que un módulo de frontera dentro del runtime crearía un ciclo. Elección: crate hoja
propio con `unsafe` permitido solo aquí; el runtime y la biblioteca conservan `#![forbid(unsafe_code)]`. Descartado:
invertir la dependencia entre runtime y biblioteca, por el refactor que exige a ambos.

Problema: `[workspace.lints.rust] unsafe_code = "forbid"` no puede relajarse por crate. Elección: el crate declara su
tabla `[lints]` con `unsafe_code = "allow"` y repite los lints de Clippy del workspace. Descartado: bajar el workspace
a `deny`, porque obliga a un `allow` en código, prohibido por el verificador de atributos.

Problema: la superficie `unsafe` debe ser mínima y auditable. Elección: los puntos de entrada son funciones
`extern "C"` sin bloque `unsafe`; la única desreferencia de punteros crudos ocurre en `open_entry`, que convierte el
contexto y el estado del motor en referencias, y en `borrow_slice`, que construye segmentos de extensiones y bytes.
Las dos son las únicas filas de la tabla de invariantes. Descartado: una fila por entrada, que multiplica filas sin
añadir superficie desreferenciada.

Problema: `ENG.LIMITS` define profundidad (mínimo 1 000 marcos), celdas (2^22 por omisión) y presupuesto de sentencias
opcional, y no define límite de salida. Elección: `AotLimits` configura marcos, celdas, unidades de instrucción
opcionales y capacidad de raíces; no hay contador de caracteres de salida. La profundidad y las unidades se
comprueban en línea en el código generado, que invoca `rt_aot_fault` con el sitio correspondiente; las celdas las
comprueba el montón en cada asignación.

Problema: el estado de definición de un entero de arreglo vive en un mapa en banda del montón, no en un banco paralelo
de bytes. Elección: el contexto expone solo `heap_words_pointer`; el código generado lee el mapa de definición desde
las mismas palabras. Descartado: un banco `defined` paralelo, que duplicaría el estado que el montón ya mantiene.

Problema: las entradas necesitan identificar su sitio sin ampliar la aridad más allá del límite de cuatro parámetros.
Elección: `site` es siempre el segundo parámetro; descriptores y banderas se empaquetan en las palabras de operando
(`tipo | rango << 8`, `NEWLINE_FLAG`, `CHARACTER_OPERAND_FLAG`).

Problema: una entrada nunca debe propagar un pánico a través de la frontera `extern "C"`. Elección: ninguna ruta
usa `unwrap`, indexación ni aritmética sin comprobar (lo exige Clippy); un puntero de contexto nulo devuelve el estado
de fallo sin escribir nada.

Las trampas son inmediatas: el código generado comprueba en registros y salta a un bloque frío por sitio que invoca
`rt_aot_fault`. Se descarta el indicador de trampa diferida en memoria, que penaliza el código nativo.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés, sin comentarios ni atributos de supresión. Los puntos de entrada de un mismo dominio comparten
archivo con sus implementaciones seguras: `memory.rs`, `text.rs`, `math.rs`, `random.rs`, `output.rs`, `input.rs` y
`trap.rs`. `guard.rs` aloja la conversión de punteros y el protocolo común de entrada y salida de estado; `engine.rs`
y `session.rs` alojan el estado propietario; `fault.rs` el registro y el renderizado de fallos.

### Invariantes de `unsafe`

| Función | Invariante | Garantía |
|---|---|---|
| `open_entry` | El puntero de contexto es nulo o apunta a un `AotRuntimeContext` vivo creado por `AotSession`, sin otra referencia activa; `engine_state` es nulo o apunta al `AotEngine` de la misma sesión | Convierte ambos en referencias exclusivas solo si no son nulos; si alguno lo es, no se toca memoria y la entrada devuelve el estado de fallo |
| `borrow_slice` | Con `count > 0`, el puntero es nulo o apunta a `count` elementos inicializados que no se modifican durante la llamada | Con `count == 0` devuelve el segmento vacío sin leer; con puntero nulo devuelve `None`; en otro caso construye el segmento de solo lectura |

## 6. Decisiones de producto que condicionan el código

El binario compilado reproduce el comportamiento observable de `pseudo ejecutar`: mismo formato de valores
(`format_value`), mismas palabras lógicas del perfil (`BooleanWords`), mismas reglas de conversión y de lectura,
mismo generador pseudoaleatorio sembrado y mismos diagnósticos. Los textos de diagnóstico se renderizan con la
plantilla del catálogo en la configuración regional solicitada.

## 7. Verificación, testing y aseguramiento de calidad

`tests/context_tests.rs` fija los desplazamientos y el tamaño del contexto, los valores iniciales y la pila de raíces.
`tests/memory_tests.rs` cubre asignación, extensiones negativas y cero, extensiones ausentes, tipo desconocido,
agotamiento de celdas con todo enraizado, recolección con raíces, diseños y copia, y contexto nulo. `tests/text_tests.rs`,
`tests/math_tests.rs`, `tests/random_tests.rs`, `tests/output_tests.rs`, `tests/input_tests.rs`, `tests/trap_tests.rs` y
`tests/fault_tests.rs` cubren camino feliz e infeliz de cada familia: literales inválidos, conversiones fallidas,
posiciones fuera de rango, dominios matemáticos, flujo de salida cerrado, lecturas con tipo incorrecto, entrada
agotada, sitios inexistentes, conservación del primer fallo y renderizado por idioma.

Los casos del corpus no se duplican aquí; la equivalencia con `engine` se contrasta en la conformidad del sujeto
`aot`. Aceptación de un cambio: `cargo xtask verify` desde la raíz del motor, incluido `rust-checks unsafe`.

## 8. Fuentes consultadas y genealogía conceptual

El patrón de contexto con campos de desplazamiento fijo, pila de raíces explícita y bloques fríos por sitio de fallo se
inspira en los puntos seguros de las máquinas virtuales gestionadas y en los helpers fuera de línea de Cranelift y
Wasmtime. Se rechaza el mecanismo de señales del sistema para trampas aritméticas, porque no transporta el sitio ni el
diagnóstico de PseudoLearn. El contrato del crate pertenece a PseudoLearn.
