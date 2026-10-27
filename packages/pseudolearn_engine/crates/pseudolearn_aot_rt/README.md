# pseudolearn_aot_rt

## 1. Qué es y qué no es

Frontera binaria entre el código máquina que genera `pseudolearn_codegen` y el motor Rust. Define el contexto de
ejecución `#[repr(C)]` que recibe como primer argumento toda función nativa y los puntos de entrada `extern "C"`
`rt_aot_*` que el código generado invoca para lo que no se emite en línea: asignación de arreglos y objetos,
operaciones de texto, matemática correctamente redondeada, azar determinista, entrada, salida y registro de fallos
con su sitio de origen. Toda la lógica vive en funciones seguras de `pseudolearn_runtime` y `pseudolearn_library`;
este crate solo convierte punteros en referencias y traduce errores tipados a diagnósticos.

Responsabilidades exclusivas: layout del contexto y sus desplazamientos, códigos de retorno, pila de raíces, tabla
de sitios de fallo, formateo de fallos, flujos de entrada y salida del programa, formato binario de los metadatos del
ejecutable y proceso del ejecutable (arranque, vaciado de salida, informe de fallo y código de salida).

Fuera de alcance de producto: trazas, instantáneas e inspección paso a paso (el sujeto `aot` está exento de
`ENG.TRACE.*` y `ENG.STATE.*`); desoptimización hacia la VM; límite de caracteres de salida (`ENG.LIMITS` no lo
define).

Fuera de alcance técnico: generación de código máquina, enlace y la función `main` del ejecutable (la emite
`pseudolearn_codegen`; el enlazador vive en la CLI); acceso en línea a memoria y aritmética entera
(las emite el código generado); dependencias externas; `unsafe` fuera de las dos funciones de la tabla de la
sección 5.

## 2. Guía operativa y ciclo de vida

Desde `packages/pseudolearn_engine`:

- Compilar: `cargo check -p pseudolearn_aot_rt`.
- Probar: `cargo test -p pseudolearn_aot_rt -- --test-threads=1`.
- Verificar todo el motor: `cargo xtask verify`.
- Verificar `unsafe`: `cargo run --manifest-path ../pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command --bin rust-checks -- unsafe .`.

El crate es una biblioteca Rust (`rlib`). Los símbolos `rt_aot_*` llevan `#[unsafe(no_mangle)]` y quedan disponibles
para el enlazador cuando el crate se empaquete como biblioteca estática. Una `AotSession` crea el motor y el contexto
y los mantiene en cajas de dirección estable; `context_pointer()` entrega el puntero que recibe el código nativo.
Los flujos de entrada y salida y la tabla de sitios se inyectan al crear la sesión. El crate reexporta `DiagnosticCode`, tipo del campo `FaultSite.code`.

## 3. Arquitectura y modelo del sistema

Nivel 6, hoja del grafo. Importa `pseudolearn_source` (tramo vacío para renderizar), `pseudolearn_abi` (`Handle`),
`pseudolearn_diagnostics`, `pseudolearn_runtime` y `pseudolearn_library`. Solo `pseudolearn_codegen` (desplazamientos, tipos de sitio y selectores) y el enlazador del ejecutable lo importan.

Contexto `AotRuntimeContext` (`#[repr(C)]`, 152 bytes; el código generado conoce los desplazamientos exportados como
`CONTEXT_*_OFFSET`):

| Desplazamiento | Campo | Tipo | Contenido |
|---|---|---|---|
| 0 | `heap_words_pointer` | `*mut u64` | Base actual de las palabras del montón; se refresca tras toda entrada que pueda reubicar el vector |
| 8 | `instruction_remaining` | `i64` | Unidades de bloque restantes; `i64::MAX` sin presupuesto |
| 16 | `frame_depth` | `u32` | Marcos activos, mantenido por el código generado |
| 20 | `frame_limit` | `u32` | Máximo de marcos (por omisión 1 000) |
| 24 | `root_top` | `u32` | Tope de la pila de raíces |
| 28 | `root_capacity` | `u32` | Capacidad de la pila de raíces; el código generado comprueba `root_top + n <= root_capacity` antes de apilar |
| 32 | `roots_pointer` | `*mut u32` | Base de la pila de raíces (`Handle` de 32 bits) |
| 40 | `fault_site` | `u32` | Sitio del primer fallo observado por la última entrada que falló |
| 44 | `fault_status` | `u32` | `0` continúa, `1` fallo del programa, `2` límite |
| 48 | `result_word` | `u64` | Resultado de la última entrada con estado `0` |
| 56 | `engine_state` | `*mut AotEngine` | Estado propietario: montón, azar, diseños, sitios, flujos, fallo y avisos |
| 64 | `cells_pointer` | `*const u8` | Base de la tabla de celdas; se refresca tras toda entrada junto con `cells_length` |
| 72 | `cells_length` | `u64` | Número de celdas vivas; el código generado trata como inválido todo identificador fuera de rango |
| 80 | `heap_used` | `u64` | Primera palabra libre del montón; la avanza el código generado al asignar en línea |
| 88 | `heap_limit` | `u64` | Palabras utilizables antes de pedir crecimiento al runtime |
| 96 | `heap_ordinal` | `u64` | Último ordinal de identidad entregado |
| 104 | `room_cells` | `i64` | Celdas que caben antes del límite de `ENG.LIMITS` |
| 112 | `room_threshold` | `i64` | Celdas asignables antes del próximo umbral de recolección; 0 con recolección forzada |
| 120 | `free_size_mask` | `u64` | Bit por tamaño físico con bloques libres (el 63 agrupa los mayores) |
| 128 | `pending_pointer` | `*mut u64` | Búfer de registros de asignación aún no conciliados |
| 136 | `pending_length` | `u64` | Registros pendientes |
| 144 | `pending_capacity` | `u64` | Capacidad del búfer (256 registros de dos palabras) |

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
| `rt_aot_text_compare` | dos operandos; el bit 32 marca un carácter | `-1`, `0` o `1` como `i64` |
| `rt_aot_array_load` | asa, puntero a `rango` índices `i64` | palabra del elemento |
| `rt_aot_array_store` | asa, puntero a `rango` índices y el valor como última palabra | 0 |
| `rt_aot_object_load` | asa, campo | palabra del campo |
| `rt_aot_object_store` | asa, puntero a `[campo, valor]` | 0 |
| `rt_aot_cell_local` | tipo | identificador de celda (`1` en adelante; `0` no es celda) |
| `rt_aot_cell_element` | asa, puntero a índices | identificador de celda |
| `rt_aot_cell_field` | asa, campo | identificador de celda |
| `rt_aot_cell_load` | celda | palabra de la ubicación |
| `rt_aot_cell_store` | celda, palabra | 0 |
| `rt_aot_math_unary` | `MATH_*`, binario64 | binario64 o entero con signo |
| `rt_aot_real_power` | base, exponente | binario64 |
| `rt_aot_integer_power` | base, exponente (`i64`) | entero con signo; traps `negativeIntegerExponent` o `integerOverflow` |
| `rt_aot_random_real` | — | binario64 en `[0, 1)` |
| `rt_aot_write` | palabra, `tipo \| NEWLINE_FLAG` | 0 |
| `rt_aot_read` | tipo | palabra leída |
| `rt_aot_effect_call` | descriptor de operación, búfer de palabras `[capacidad, nodo fuente, clase de resultado, argumentos…, celdas de resultado…]` | 0; las respuestas se escriben en las celdas |
| `rt_aot_fault` | — | el código del sitio decide el estado |

Los accesos a arreglos y objetos son el camino lento de los accesos en línea del código generado: reproducen la
comprobación completa (asa ausente, rango, definición) y producen el diagnóstico exacto. Las celdas locales guardan su
palabra y, para enteros, un indicador de definición; las de elemento y de campo apuntan al propietario y a la posición.
Ninguna celda se libera y el propietario de una celda administrada no se enraíza (igual que en la VM); las celdas locales
de referencia sí se añaden a las raíces de cada asignación. `AotEngine::register_class` registra el diseño de una clase a
partir de un `ClassDescriptor` (códigos de tipo por campo y densidad), que es lo que `CompiledObject.classes` entrega.

Códigos de tipo: `KIND_INTEGER` 0, `KIND_REAL` 1, `KIND_BOOLEAN` 2, `KIND_CHARACTER` 3, `KIND_REFERENCE` 4.

Proceso del ejecutable: `pseudolearn_aot_main(entrada, metadatos, longitud) -> i32` es el único símbolo que enlaza el
`main` generado. Decodifica los metadatos (`decode_metadata`), crea la `AotSession` con entrada estándar con búfer, salida
estándar con búfer y los límites y la semilla fijados al compilar, registra las clases, llama a la función de entrada,
vacía la salida y proyecta el estado: `0` completado, `3` fallo del programa, `4` límite (`statementBudgetExhausted` o
entrada agotada) y `5` fallo interno (`internalFault`, clases inválidas, metadatos corruptos o fallo sin registro). Ante
un fallo, la salida del programa ya está vaciada y el diagnóstico se escribe en la salida de error con la plantilla de
línea que trae el metadato; la entrada agotada usa su propia plantilla. Los avisos del programa (por ejemplo, una lectura
con tipo incorrecto que se recupera) se escriben antes que el fallo y también en ejecuciones que terminan con código `0`.
Cada diagnóstico elige su plantilla por severidad (`error`, `warning` o `information`) y las plantillas admiten
`{path}`, `{line}`, `{column}`, `{end_line}`, `{end_column}`, `{message}`, `{code}` y `{arguments}` (objeto JSON con los
argumentos del diagnóstico, y con `limit` numérico para `cellLimitExceeded`, `recursionDepthExceeded` y
`statementBudgetExhausted`). `run_executable` es la misma lógica con flujos
inyectados, que es lo que prueban los tests sin lanzar procesos.

Metadatos (`ExecutableMetadata`, magia `PLM5`): nombre de la fuente, idioma, semilla, límites (marcos, unidades opcionales,
celdas, capacidad de raíces), recolección forzada, palabras lógicas, las cuatro plantillas (error, aviso, información y
entrada agotada), la tabla de sitios (código por nombre, ID de fuente y rango) y los
diseños de clase. Codificación little-endian con prefijos de longitud; el decodificador rechaza prefijos truncados, bytes
sobrantes, magia ajena y nombres de diagnóstico desconocidos. El ID de fuente de cada sitio se incorporó sin
alterar los offsets de línea y columna. La magia `PLM5` añade la tabla opcional de nombres de fuente (ID y nombre) que sustituye a `{path}` en el diagnóstico de un sitio cuyo ID figura en ella; sin tabla, todos usan el nombre único de la fuente. Codegen codifica con `encode_metadata`, de modo que el
formato vive en un solo lugar (`GEN-NO-HAND-COPY`).

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

Problema: un receptor ausente no tiene clase real desde la que recuperar el nombre de campo que la VM informa. Elección: la entrada conserva por separado el sitio del fallo y el sitio que aporta contexto de lexema; una lectura de campo con receptor ausente omite este último. Una lectura de campo sin valor en un objeto existente conserva su nombre. Se descarta inventar un argumento estático que la VM no puede producir.

Problema: la recolección periódica y las raíces temporales penalizan asignaciones sin presión. Elección: AOT fija `collection_minimum` en 262144 celdas y construye raíces de arreglos solo cuando el costo lógico exacto requiere recorrido. La presión de límite y el modo forzado mantienen raíces completas. Se descarta alterar la política de la VM.

Problema: construir raíces por cada objeto asigna y recorre celdas aunque no haya recolección. Elección: las asignaciones y copias de objeto consultan el costo lógico exacto que publica el runtime y materializan raíces solo si `needs_collection` puede activar recorrido o presión de límite. La recolección forzada y la presión de celdas mantienen el camino completo. Se descarta conservar un vector paralelo de raíces que pueda quedar obsoleto.

Problema: las celdas de funciones terminadas no deben conservar objetos ni crecer durante toda la sesión. Elección: solo una función que crea celdas toma una marca de la tabla al entrar y libera su sufijo al retornar; las celdas del llamador mantienen sus identificadores. Una celda de elemento o campo enraíza también su propietario. Se descarta conservar referencias locales de marcos terminados o depender de un uso SSA posterior del propietario.

Problema: los perfiles agregados no distinguen mecanismos de memoria. Elección: la feature `telemetry`, desactivada por omisión, cuenta asignaciones, crecimiento de palabras, recolecciones, recorridos, copias de diseño y accesos o raíces de celdas según la responsabilidad del crate. Sus resultados pertenecen a sesiones diagnósticas separadas; el código de producto y la campaña normativa no contienen estos incrementos. Se descarta atribuir los tiempos instrumentados al rendimiento de producción.

Problema: el diagnóstico nativo debe conservar los argumentos del motor. Elección: los sitios de fallo incluyen el lexema de variable, campo o subprograma; los accesos conservan índice, extensión, longitud, posición y texto de conversión. El código Unicode inválido se transmite solo en el bloque frío. Los metadatos internos usan la magia PLM2 para distinguir el lexema añadido. Se descarta reconstruir argumentos en la CLI o incluir mensajes traducidos en el generador.

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

Problema: el ejecutable no puede depender del entorno (`RT.PROCESS`) y debe informar en el idioma elegido al compilar.
Elección: la CLI fija idioma, semilla, límites, palabras lógicas y plantillas al compilar y el runtime solo las lee de los
metadatos; ningún texto de interfaz vive aquí. Descartado: leer variables de entorno o la configuración de usuario al
arrancar, porque el comportamiento dejaría de depender solo de la entrada estándar.

Problema: `std` solo vacía la salida estándar al volver de su propio `main`, y el `main` generado es el de C. Elección:
`run_executable` vacía explícitamente el flujo de salida antes de informar el fallo y de devolver el código.

Problema: el sujeto `aot` se contrasta con el corpus a través de procesos reales y el proceso solo expone texto. Elección:
las plantillas admiten marcadores para el tramo completo y los argumentos, y la CLI de producto usa las del catálogo
mientras que el adaptador de conformidad compila con plantillas de campos separados por tabulador que `pseudolearn_api`
interpreta; el diagnóstico conserva así código, severidad, tramo y argumentos del programa compilado. Descartado: un
segundo canal de salida o un formato binario para diagnósticos, que añadiría un contrato que ningún usuario consume.

Problema: la propiedad de transparencia de la recolección exige ejecutar con recolección forzada en cada asignación.
Elección: `ExecutableSettings.forced_collection` se fija al compilar y `run_executable` lo aplica al montón antes de
ejecutar; sin él, el comportamiento es el automático. Descartado: una variable de entorno, que incumpliría la
independencia del entorno del ejecutable.

Problema: una entrada nunca debe propagar un pánico a través de la frontera `extern "C"`. Elección: ninguna ruta
usa `unwrap`, indexación ni aritmética sin comprobar (lo exige Clippy); un puntero de contexto nulo devuelve el estado
de fallo sin escribir nada.

Las trampas son inmediatas: el código generado comprueba en registros y salta a un bloque frío por sitio que invoca
`rt_aot_fault`. Se descarta el indicador de trampa diferida en memoria, que penaliza el código nativo.

Perfil por sitio: `ExecutableSettings::site_boolean_words` lista las palabras lógicas por vocabulario en el orden de
`Module::vocabularies()` y el descriptor de formato indica cuál usar (`profile_index`). Con la lista vacía rige
`boolean_words`. La magia de los metadatos pasa a `PLM4` y los de `PLM3` se rechazan sin reinterpretarse, porque el
significado del bloque de configuración cambió.

### Efectos de capacidad en el sujeto nativo

Problema: el proceso nativo debe realizar los mismos efectos, con la misma cinta y la misma autoridad, que la VM, sin
depender de `pseudolearn_api` ni de `pseudolearn_timeline` y sin leer el entorno desde las instrucciones. Elección:
`rt_aot_effect_call` reutiliza el núcleo de `pseudolearn_runtime` (`decode_host_value`, `perform_host_effect`,
`host_reply_words`, `local_effect`) sobre el montón del motor nativo; los argumentos y las celdas de resultado viajan en un
único búfer de palabras con tres de cabecera, porque el límite de parámetros posicionales es cuatro. Las respuestas se
escriben en las celdas con la misma ruta que `rt_aot_cell_store`. La salida y la lectura de consola también se anotan
en la cinta con `console_record`, como hace el recolector de consola de la API, de modo que una cinta grabada por un motor
la reproduce el otro. Canal de configuración: el ejecutable acepta `--effects-in <archivo>` y `--effects-out <archivo>`,
rutas explícitas que entrega quien lo lanza; el archivo de entrada lleva anfitrión, identidad de ejecución, presupuesto de
cinta y, para reproducir, la cinta; el de salida devuelve la cinta, las llamadas al anfitrión y el código de rechazo de
reproducción. Sin esas banderas el proceso se comporta como antes. Una entrada ilegible o con identidad distinta se rechaza
antes de ejecutar y el proceso termina con el código 6. Se descarta una variable de entorno (el lanzador usa entorno
vacío) y se descarta la entrada estándar (ya transporta las entradas del programa). El adaptador solo ofrece
`execute`; `history_seek` se rechaza en la API antes de lanzar.

### Reproducción autónoma de `Leer` y observación del anfitrión

Decisión: cuando el canal de efectos trae una cinta para reproducir, `rt_aot_read` no lee la entrada estándar; resuelve
la siguiente entrada de cinta de lectura de consola (`EffectChannel::replay_console`) y usa su carga como línea. Sin
cinta de reproducción conserva el camino vivo: lee la línea, la anota con `record_console` y la convierte. Así la misma
cinta grabada por la máquina virtual o por el ejecutable nativo se reproduce en cualquiera de los dos sin entrada
estándar, y una cinta agotada termina con `replay_truncated_tape` en vez de esperar entrada.

El documento de salida del canal añade `open_resources` junto a `host_calls`; ambos salen de una sola consulta
(`EffectChannel::host_observation`) para no ampliar la superficie pública. La API los proyecta como
`host_observation.calls` y `host_observation.open_resources`, que es lo que compara la clave `anfitrion_observado` de
los casos de conformidad. Tras terminar, el proveedor en memoria ya cerró sus recursos, de modo que
`open_resources` mide fugas posteriores al cierre final y `calls` demuestra qué operaciones llegaron al anfitrión
(por ejemplo, que un uso tras cierre nunca lo alcanza).

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
`tests/access_tests.rs` y `tests/cell_tests.rs` cubren lectura y escritura de elementos y campos (rangos, dimensiones,
arreglos vacíos, asa ausente, buffers nulos, campos sin valor, clases con tipos desconocidos) y las celdas locales, de
elemento y de campo, incluido el enraizamiento del texto que solo una celda conserva.
`tests/memory_tests.rs` cubre asignación, extensiones negativas y cero, extensiones ausentes, tipo desconocido,
agotamiento de celdas con todo enraizado, recolección con raíces, diseños y copia, y contexto nulo. `tests/text_tests.rs`,
`tests/math_tests.rs`, `tests/random_tests.rs`, `tests/output_tests.rs`, `tests/input_tests.rs`, `tests/trap_tests.rs`,
`tests/metadata_tests.rs` (ida y vuelta, con recolección forzada y las cuatro plantillas, rechazo de cada prefijo truncado, magia y nombres corruptos, `pseudolearn_aot_main` con
metadatos nulos o basura), `tests/process_tests.rs` (códigos 0, 3, 4 y 5, salida previa al fallo, entrada agotada, clases
inválidas, plantillas, avisos en ejecuciones completadas, límites numéricos, escape de argumentos y recolección forzada) y
`tests/effect_document_tests.rs` (entrada viva, entrada malformada, identidad distinta, permiso desconocido y salida de rechazo) y
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

Problema: cada lectura de una celda local cuesta una llamada protegida al runtime, y Permute, Queens y Towers leen celdas decenas de miles de veces. Elección: cada entrada de la tabla es un `CellSlot` `#[repr(C)]` con una cabecera de dos palabras (`word`, `readable`) seguida del destino original; `readable` vale 1 solo cuando la celda es local y su lectura tendría éxito. El código generado lee la palabra en línea cuando `readable` vale 1 y llama a `rt_aot_cell_load` en cualquier otro caso (celda administrada, indefinida o fuera de rango), de modo que los diagnósticos no cambian. Las escrituras siguen pasando por el runtime, que recalcula la cabecera. Se descarta inlinear la escritura, porque decidir si un valor es legible depende del tipo y mezclaría reglas de presencia en el generador.

Problema: la asignación de objetos y la escritura en celdas locales llamaban al runtime una vez por operación, y Storage gasta casi todo su tiempo ahí. Elección: el contexto publica una ventana de asignación (`heap_used`, `heap_limit`, `heap_ordinal`, `room_cells`, `room_threshold`, `free_size_mask`) y un búfer plano de 256 registros pendientes (`pending_*`; 152 bytes en total). El código generado asigna en línea una clase de hasta 64 palabras solo cuando no hay bloques libres de ese tamaño, caben sus celdas antes de la próxima recolección y del límite, queda espacio en el vector y en el búfer, y la pila de raíces no se desbordaría; escribe la cabecera, la identidad y la imagen de campos (constantes que `inline_object_image` calcula con las mismas funciones que el asignador) y anota un registro. Cualquier otro caso llama a `rt_aot_object_new`. Cada entrada al runtime concilia primero los registros (`AotEngine::settle_inline`) y publica al terminar una ventana nueva; `settle_session` hace lo mismo al volver del código generado. La cabecera `local`/`word`/`readable` de cada `CellSlot` pasa a ser la fuente de verdad de las celdas locales, de modo que su escritura también se hace en línea. Se descarta asignar tras la primera recolección con bloques libres de ese tamaño, que conserva el camino lento, y asignar arreglos o copias en línea.

## Colecciones, interfaces e iteración con limpieza

rt_aot_collection transporta un paquete estático de seis palabras de cabecera seguido de los argumentos canónicos. El envoltorio usa la frontera de préstamo existente y traduce errores de memoria a diagnósticos con sitio; no añade bloques unsafe. Las raíces proceden de la pila explícita antes de una reserva. rt_aot_text_quote comparte el escape de biblioteca con VM.

Los tests de estas capacidades se ejecutaron en selecciones acotadas, incluida la comparación de gemelos con recolección forzada. La conformidad del corpus sigue pendiente de la revisión editorial independiente de los contratos nuevos, y la medición de tamaño excede el presupuesto de Wasm.
