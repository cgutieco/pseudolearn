# pseudolearn_codegen

## 1. Qué es y qué no es

Generador de código máquina del sujeto `aot`. Traduce un `pseudolearn_ir::Module` verificado a un archivo objeto
relocalizable del objetivo anfitrión (Mach-O, ELF o COFF) con Cranelift. El objeto exporta una función `__pl_fn_<n>` por
función de la RI y deja sin resolver únicamente los símbolos `rt_aot_*` de `pseudolearn_aot_rt`. Lo consumen el
enlazador del ejecutable y el adaptador de conformidad `aot`.

Responsabilidades exclusivas: bajada de bloques SSA con parámetros a CLIF, prólogo y epílogo de marco, contabilidad de
`block.mass`, aritmética entera y real comprobada, comparaciones, lógicos y caracteres escalares, llamadas directas y
virtuales con propagación inmediata de fallo, bloques fríos de trampa por sitio y tabla de sitios de fallo, acceso a
arreglos y objetos con camino rápido en línea, celdas, texto, matemática, entrada, salida y azar mediante las entradas
del runtime, pila de raíces para el recolector, seguimiento de definición de enteros y tabla de clases.

Fuera de alcance de producto: trazas, instantáneas y observación paso a paso (`aot` está exento de `ENG.TRACE.*` y
`ENG.STATE.*`); desoptimización hacia la VM.

Fuera de alcance técnico: enlace y empaquetado del ejecutable; la biblioteca estática del runtime; `unsafe`
(`#![forbid(unsafe_code)]`); `cranelift-jit`; dependencias de LLVM o de un compilador C.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Las campañas emparejadas siguen por encima de 1,30× en las cuatro familias y Richards supera 15 ms de emisión. Los contadores separan celdas (Permute y Queens), acceso a arreglos sin celdas (Sieve y NBody), código escalar (Mandelbrot) y asignación/GC (Storage). La atribución histórica de celdas a Sieve y NBody y el porcentaje del 2 % no están acreditados | Diagnosticar RI, CLIF y ensamblado conservados; comparar eliminación o especialización de celdas, análisis de límites y definición, asignador y backend mediante variantes aisladas | Cierre de PERF.AOT.LEVEL con evidencia comparable; ninguna técnica se considera suficiente antes de medir |

## 2. Guía operativa y ciclo de vida

Desde `packages/pseudolearn_engine`, con la cadena `cargo` fijada por `rust-toolchain.toml`:

- Compilar: `cargo build -p pseudolearn_codegen`.
- Probar: `cargo test -p pseudolearn_codegen -- --test-threads=1`.
- Verificar todo el motor: `cargo xtask verify`.

Los tests de ejecución (`tests/execution/executable_tests.rs` para el modo ejecutable: salida, fallo con sitio y código 3,
entrada estándar, entrada agotada con código 4 y módulo sin `main`) enlazan el objeto emitido con un arnés de `rustc` y las `rlib` de `pseudolearn_aot_rt` y
`pseudolearn_diagnostics` de `target/<perfil>/deps`, y ejecutan el binario resultante. Requieren `rustc` y un
enlazador del sistema en el `PATH`. Los artefactos de cada ejecución se escriben bajo `CARGO_TARGET_TMPDIR`.

## 3. Arquitectura y modelo del sistema

Nivel 7. Importa `pseudolearn_ir` (modelo y verificador), `pseudolearn_diagnostics` (`DiagnosticCode`) y
`pseudolearn_aot_rt` (desplazamientos del contexto, tipos `FaultSite` y `SourceRange`, selectores `MATH_*`). Ningún
crate del motor lo importa salvo el enlazador y el adaptador `aot`.

Fachada: `compile_module_to_object(&Module, &TargetConfig) -> Result<CompiledObject, CodegenError>`. Verifica el módulo
con `verify_module` antes de emitir. `CompiledObject` contiene los bytes del objeto, la tabla `fault_sites` que la sesión
de `pseudolearn_aot_rt` recibe tal cual y la lista `function_symbols` (nombre en la RI y símbolo).

Modo ejecutable: `compile_module_to_executable_object(&Module, &TargetConfig, &ExecutableSettings)` emite además un
`main` de C que llama a `pseudolearn_aot_main(@main, __pl_metadata, longitud)` y devuelve su resultado, y guarda como dato
local los metadatos que `pseudolearn_aot_rt::encode_metadata` produce con los ajustes, la tabla de sitios y los diseños de
clase. La función de entrada es la de nombre `main` de la RI; un módulo sin ella es un `InvalidModule`. El objeto sigue
sin resolver únicamente `rt_aot_*` y `pseudolearn_aot_main`. El modo objeto (`compile_module_to_object`) no define `main`,
que es lo que usa el arnés de pruebas.

Convención de las funciones generadas: `extern "C"`, primer parámetro `*mut AotRuntimeContext`, luego un parámetro por
parámetro de la RI. `CompiledObject.classes` entrega un `ClassDescriptor` por clase, en el orden de `Module.classes`, con los
campos heredados primero; el índice de la clase es el que `rt_aot_object_new` recibe y el que el montón guarda en la cabecera. Tipos: `i64`→`I64`, `f64`→`F64`, `bool`→`I8` (0 o 1), `char`→`I32`, `str`, `array`, `obj` y `cell`→`I32`
(asa); `unit` no ocupa parámetro ni retorno.

| Módulo | Responsabilidad |
|---|---|
| `object_emitter` | Declara, define y serializa las funciones con `cranelift-object` |
| `function_compiler` | Entrada Cranelift con prólogo, bloques de la RI en orden inverso de postorden |
| `block_order` | Orden inverso de postorden desde el bloque de entrada; los bloques inalcanzables no se emiten |
| `block_accounting` | Descuenta unidades de `instruction_remaining`: la masa del bloque en su cabecera o una unidad en cada `stmt.enter` |
| `lowering` | Estado de una función, sitios de trampa fríos, propagación de fallo y retorno de cero |
| `instruction_dispatch` | Tabla de familias: asigna cada `Operation` a su bajada; un test exige cobertura de las 74 y que ninguna tenga dos dueños |
| `lower_scalars`, `lower_arithmetic`, `lower_real`, `lower_math`, `lower_control` | Bajada de escalares, aritmética, matemática y control |
| `lower_text`, `lower_io` | Literales, texto, entrada, salida y azar por las entradas del runtime |
| `lower_arrays`, `lower_objects`, `lower_cells` | Memoria: arreglos y objetos con camino rápido en línea y camino lento por el runtime; lectura de celdas locales en línea con camino lento por el runtime |
| `array_fast_path`, `object_fast_path`, `inline_memory` | Comprobaciones y accesos en línea sobre las palabras del montón |
| `lower_calls`, `lower_virtual`, `class_table` | Llamadas directas, despacho virtual por clase real y tabla de clases y métodos |
| `value_types`, `liveness`, `shadow_stack`, `definition` | Tipo de cada valor, valores de referencia vivos por punto seguro, pila de raíces y definición de enteros |
| `word_conversion` | Paso entre valores nativos y palabras de 64 bits del montón |
| `runtime_calls`, `abi_signatures` | Tabla de entradas `rt_aot_*` e invocación con propagación de fallo |
| `fault_table` | Tabla de sitios (`DiagnosticCode` y tramo fuente) |
| `context_layout` | Desplazamientos del contexto como `i32` |
| `entry_point` | En modo ejecutable, define `main` y el dato local `__pl_metadata` |
| `type_mapping`, `target` | Tipos CLIF y configuración del ISA |

Protocolo de fallo: toda trampa en línea salta a un bloque frío propio que llama a `rt_aot_fault(contexto, sitio)` y
retorna cero del tipo de la función. Tras toda entrada del runtime y toda llamada a otra función se lee
`fault_status`; si es distinto de cero se salta a un único bloque frío por función que retorna cero sin ejecutar más
efectos. El marco no se restituye en el fallo porque la ejecución termina.

Marcos: el prólogo incrementa `frame_depth`; todo `return` lo decrementa; antes de cada `call` se compara
`frame_depth >= frame_limit` y se traduce en `recursionDepthExceeded` con el tramo de la llamada, lo que reproduce
`frames.len() + 1 >= depth` de la VM.

Presupuesto: en la cabecera de todo bloque con `mass > 0` se carga `instruction_remaining`, se resta la masa, se
almacena y, si es negativo, se salta a `statementBudgetExhausted` con el tramo de la primera `stmt.enter` del bloque.
`stmt.exit` y `decide.*` no emiten código. Con un presupuesto de sentencias configurado en los metadatos del ejecutable
(`StatementCharging::PerStatement`) no se descuenta en la cabecera: cada `stmt.enter` resta una unidad y, si el resultado
es negativo, salta a `statementBudgetExhausted` con su propio tramo, de modo que el efecto de las sentencias anteriores
del bloque ya es visible y ninguno posterior lo es, como exige `ENG.LIMITS`. Sin presupuesto (o al emitir un objeto sin
metadatos) se conserva el descuento por bloque, que no puede distinguirse desde fuera.

Aritmética: suma, resta, producto y opuesto con `sadd_overflow`, `ssub_overflow` y `smul_overflow`; el opuesto es
`0 - x`. División: divisor cero (`divisionByZero`) antes que mínimo entre menos uno (`integerOverflow`). Módulo: divisor
cero atrapa; con divisor `-1` se sustituye por `1`, de modo que el resto es cero sin ejecutar `srem` sobre
`i64::MIN / -1`. Reales: `fadd`, `fsub`, `fmul`, `fdiv`; el resultado no finito se detecta con `|x| < +inf` (falso para
NaN) y atrapa `nonFiniteRealResult`; el divisor real cero, incluido `-0.0`, atrapa `divisionByZero` antes de dividir;
`real.neg` es `fneg`. `int.pow`, `real.pow`, `real.trunc` y `real.round` llaman a `rt_aot_integer_power`,
`rt_aot_real_power` y `rt_aot_math_unary`, cuyo resultado se lee de `result_word`.

Estados sin valor: `bool` usa el centinela 2, `char` el centinela `0xFFFF_FFFF`, `f64` un NaN y toda referencia el asa 0,
igual que la VM; `value.require` atrapa `uninitializedVariableRead` al encontrarlos. Un `i64` no tiene centinela: cada valor
entero lleva un estado estático (definido, sin valor o con indicador) y todo parámetro de bloque `i64` recibe un parámetro
`i8` adicional, tras los demás, que los saltos rellenan con 1, 0 o el indicador del argumento. `value.require` sobre un
entero sin valor estático atrapa sin comprobar, y sobre uno con indicador comprueba el indicador.

Raíces: los puntos seguros son `call`, `call.virtual`, `array.new`, `object.new`, `object.copy`, `text.concat`,
`text.format`, `const.str` e `in.read`. `liveness` calcula por flujo hacia atrás qué valores `str`, `array` y `obj` siguen
vivos al entrar en cada uno, incluidos sus operandos, y el generador los copia en `roots[root_top..]`, avanza `root_top`
(comprueba `root_capacity`) y lo restaura al volver. Las celdas no son asas del montón; el runtime enraíza el contenido de las celdas locales de referencia y el propietario de las celdas de campo o elemento.

Memoria en línea: `array.load`, `array.store`, `object.load` y `object.store` leen `heap_words_pointer` en cada acceso (el
puntero cambia en cualquier asignación), comprueban asa presente, extensiones sin signo y centinela de definición, y ante
cualquier condición que no sea el éxito saltan a un bloque frío que llama a la entrada equivalente del runtime, que
produce la trampa exacta o el valor. Los enteros de arreglo usan el límite denso y, si no se alcanzó, el mapa de
definición con bit encendido igual a definido; los de objeto usan la carga útil de la cabecera: 2 es denso y, si no, el
bit apagado de la máscara es definido. Las escrituras de enteros actualizan esos mapas en línea.

Despacho virtual: `call.virtual` atrapa el receptor ausente, lee la clase real de la cabecera (`forma - 3`), salta por
`Switch` a un bloque por función destino distinta y llama con el mismo protocolo de marcos y fallo que `call`; una clase
sin implementación es un `internalFault`. La tabla resuelve cada método con la herencia.

Entrada, salida y texto: cada valor de `out.write` es una llamada a `rt_aot_write` y solo el último lleva el salto de
línea; `text.concat` marca con `CHARACTER_OPERAND_FLAG` los operandos de tipo `char`; `const.str` apunta al literal que el
objeto guarda como dato local, uno por contenido distinto, y la entrada lo copia al montón en cada ejecución.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: las celdas de funciones terminadas no deben conservar objetos ni crecer durante toda la sesión. Elección: solo una función que crea celdas toma una marca de la tabla al entrar y libera su sufijo al retornar; las celdas del llamador mantienen sus identificadores. Una celda de elemento o campo enraíza también su propietario. Se descarta conservar referencias locales de marcos terminados o depender de un uso SSA posterior del propietario.

Problema: el diagnóstico nativo debe conservar los argumentos del motor. Elección: los sitios de fallo incluyen el lexema de variable, campo o subprograma; los accesos conservan índice, extensión, longitud, posición y texto de conversión. El código Unicode inválido se transmite solo en el bloque frío. Los metadatos internos usan la magia PLM2 para distinguir el lexema añadido. Se descarta reconstruir argumentos en la CLI o incluir mensajes traducidos en el generador.

Problema: la emisión debe medirse sin análisis ni lowering. Elección: `PreparedNativeBenchmark` prepara una RI inmutable antes del reloj; `emit_benchmark_object` emite el objeto y sus metadatos. La inspección explícita captura CLIF sin modificar las funciones emitidas; permanece fuera de la medición. El módulo `literals` es dueño de los datos de texto del objeto. Se descarta mezclar las cadenas CLIF con el intervalo de emisión.

Problema: detectar el desbordamiento sin señales del sistema. Elección: instrucciones `*_overflow` de CLIF y salto a
bloque frío por sitio, que conserva `DiagnosticCode` y tramo. Descartado: `trap` de CLIF y `SIGFPE`, porque no
transportan el sitio ni el diagnóstico.

Problema: `srem` y `sdiv` sobre `i64::MIN` y `-1` terminan el proceso en x86_64. Elección: la división comprueba el par
antes de dividir y el módulo sustituye el divisor. Descartado: comprobar tras el hecho.

Problema: el contexto y las entradas del runtime viven en otro crate y los desplazamientos no pueden copiarse a mano
(`GEN-NO-HAND-COPY`). Elección: `pseudolearn_codegen` importa las constantes `CONTEXT_*_OFFSET` de `pseudolearn_aot_rt`;
solo los nombres de símbolo se repiten como constantes públicas y los tests de ejecución enlazan contra el runtime real,
de modo que una divergencia falla en el enlace.

Problema: los identificadores de bloque de la RI pueden no seguir un orden compatible con la dominancia. Elección:
emisión en orden inverso de postorden, de modo que todo valor se defina antes de sus usos; la entrada Cranelift es un
bloque aparte del primer bloque de la RI para que el prólogo no se repita si un bucle vuelve a él.

Problema: un fallo debe detener la ejecución sin efectos posteriores y sin una tabla de desenrollado. Elección:
`fault_status` en el contexto, comprobado tras cada llamada con dos instrucciones, y retorno inmediato de cero. Descartado:
códigos de error devueltos por valor, porque duplican el registro de retorno de las funciones con resultado.

Problema: los enteros sin valor requieren un indicador de definición y un parámetro adicional en la firma de cada función
cambiaría el contrato `extern "C"` que el arnés y el enlazador comparten. Elección: el indicador viaja solo por los
parámetros de bloque, donde la RI lo exige para que `value.require` decida; el límite de llamada rechaza un argumento
entero sin valor en el sitio de la llamada con `uninitializedVariableRead`, mientras la VM lo propaga y lo atrapa en la
primera lectura de la función llamada. Divergencia conocida: ningún programa lowering la produce porque toda lectura de
variable emite `value.require` antes de pasar el valor; si el corpus la exigiera, el indicador pasaría a ser un parámetro
de función. Descartado: aproximar el entero sin valor con un centinela, porque todo `i64` es un valor legal.

Problema: el recolector no mueve objetos, pero libera lo que no alcanza desde las raíces, y los valores nativos viven en
registros que él no ve. Elección: pila de raíces explícita alimentada por un análisis de vivacidad propio, que reproduce
el mapa de raíces de la VM (valores vivos al entrar, con sus operandos). Descartado: enraizar todos los valores de
referencia definidos, porque retrasaría la recolección y cambiaría cuándo se alcanza `cellLimitExceeded`.

Problema: la representación del montón (cabeceras, mapas de definición, carga útil) pertenece a `pseudolearn_abi` y
`pseudolearn_runtime`, y copiar sus constantes a mano falla en silencio. Elección: el camino rápido solo aprueba el caso de
éxito y todo lo demás lo decide el runtime, de modo que un desplazamiento incorrecto se manifiesta como un fallo de los
tests de ejecución, nunca como una trampa distinta. Descartado: duplicar las trampas en línea.

Problema: una celda de variable local pasa a otra función, pero un asa de 32 bits no puede apuntar a un marco nativo.
Elección: las celdas son índices a una tabla del motor (`Local` con palabra y definición, o `Managed` con propietario e
índice), como en la VM; se crean por `rt_aot_cell_*` y no se liberan. Descartado: punteros a la pila.

Problema: `sqrt` y `abs` no tienen selector en la biblioteca de `pseudolearn_aot_rt`. Elección: `sqrt` comprueba el
argumento negativo y usa la instrucción IEEE de Cranelift, que está correctamente redondeada como la biblioteca y conserva
`-0.0`; `abs` borra el signo. `ln`, `exp`, `sin`, `cos` y `atan` llaman a la biblioteca.

Problema: `cranelift-object` activa siempre `gimli`, que arrastra una segunda versión de `hashbrown`, y Cranelift usa `Apache-2.0 WITH LLVM-exception`. Elección: la política de `deny.toml` admite esa licencia y `Zlib` y exime únicamente `hashbrown@0.16.1` de la regla de versiones duplicadas.

Problema: el ejecutable necesita arrancar el runtime sin que codegen conozca su estado. Elección: codegen solo emite el
`main` de C y los bytes de metadatos, y el runtime los decodifica; el único acoplamiento es el formato de
`pseudolearn_aot_rt`, que codifica y decodifica. Descartado: emitir en Cranelift el registro de clases y literales al
arrancar, porque duplicaría en código generado lo que el decodificador hace una vez en Rust seguro.

Problema: el descuento de unidades por bloque cuesta una carga y un almacenamiento por bloque, y es invisible sin
presupuesto. Elección: tres modos de descuento según los metadatos del ejecutable: sin presupuesto no se emite nada
(`Disabled`); con presupuesto se descuenta una unidad en cada `stmt.enter` (`PerStatement`), que corta exactamente en la
sentencia que lo supera; la emisión como biblioteca, sin metadatos, conserva el descuento por bloque (`PerBlock`). Descartado:
descontar por bloque con presupuesto, porque el efecto visible de las sentencias anteriores del bloque se perdería, y
fijar `instruction_remaining` en un registro, que solo ahorraría la carga cuando el presupuesto sí existe.

Problema: con `opt_level = none` el código generado carga y almacena cada valor local en memoria. Elección:
`opt_level = speed`, que aplica numeración de valores y movimiento de código de Cranelift sobre valores puros; las
trampas son ramas explícitas a bloques fríos con llamadas, de modo que ninguna comprobación ni efecto cambia de orden.
La conformidad y la propiedad de primera trampa sobre el corpus verifican el orden. Medido: mejora la razón geométrica
frente al techo de 7,8 a 5,8 sin cambiar ninguna observación.

Problema: la brecha frente a V1F mezcla código generado, runtime y diferencias de representación del techo manual. Elección: conservar Cranelift mientras se miden variantes aisladas, sin condicionar un backend alternativo a una optimización particular. Los contadores no muestran cargas de celda en Sieve ni NBody. Las funciones sin asas vivas ya omiten la ventana de raíces y `opt_level = speed` ya está activo. Se descarta tratar estas medidas existentes como trabajo pendiente o prometer que celdas y asignación bastarán para cerrar el nivel.

Problema: el objeto debe ser reproducible. Elección: `is_pic`, sin información dependiente del anfitrión más allá del
`Triple`; dos compilaciones del mismo módulo producen los mismos bytes.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés, sin comentarios ni atributos de supresión; límites de `architecture.yaml`. Una familia de instrucciones por
archivo, funciones libres sobre `Lowering` en lugar de métodos para mantener el estado en un único tipo sin superficie
pública. `unsafe` prohibido.

## 6. Decisiones de producto que condicionan el código

El binario compilado debe reproducir el comportamiento observable del motor `engine`: mismas trampas, mismo primer fallo,
mismo orden de efectos. La primera trampa en orden de programa es la informada porque cada instrucción comprueba antes
de continuar.

## 7. Verificación, testing y aseguramiento de calidad

`tests/execution/` contiene un único binario de tests: `support.rs` genera, enlaza y ejecuta un arnés por módulo de RI
(con entrada por variable de entorno, salida capturada, límite de celdas y clases registradas desde `CompiledObject.classes`);
`integer_tests.rs`, `real_tests.rs`, `scalar_tests.rs`, `control_tests.rs` y `call_tests.rs` cubren cada familia con
camino feliz e infeliz y con los bordes `i64::MAX + 1`, `i64::MIN - 1`, `i64::MIN * -1`, `i64::MIN / -1`, `x / 0`, divisor
real cero con signo, exponentes negativos, truncamiento fuera de rango, límites de escalares Unicode, presupuesto
exacto y agotado (incluido el corte exacto en la sentencia que lo supera dentro de un bloque), paso cero, función sin retorno, código inalcanzable, recursión hasta el límite exacto de marcos y
propagación del fallo de la función llamada. `definition_tests.rs` cubre el estado sin valor de enteros en
fusiones, bucles y llamadas; `text_tests.rs`, `math_tests.rs` y `io_tests.rs` cubren texto, matemática, lectura, escritura
y azar; `array_tests.rs` cubre rangos, dimensiones, centinelas por tipo, máscaras de más de una palabra, tamaños
inválidos y supervivencia de un arreglo vivo bajo recolección; `object_tests.rs` cubre campos de cada tipo, clases densas y
no densas, copia, identidad, herencia y una lista enlazada bajo recolección; `cell_tests.rs` cubre celdas locales, de
elemento y de campo; `virtual_tests.rs` cubre despacho por clase, receptor ausente, recursión y raíces a través de la
llamada. Dos mutaciones deliberadas (sin pila de raíces y sin raíces de celdas) hacen fallar los tests de supervivencia.
`tests/object_emitter_tests.rs` comprueba que todo símbolo indefinido es una
entrada `rt_aot_*`, que toda relocalización apunta a un símbolo del objeto, los sitios de fallo con su tramo, el orden de
símbolos, el determinismo, el módulo vacío y los literales como símbolos locales, los diseños de clase, el rechazo de módulos mal formados, de métodos sin función y de jerarquías cíclicas.

Aceptación de un cambio: `cargo xtask verify` desde la raíz del motor.

## 8. Fuentes consultadas y genealogía conceptual

Cranelift (`cranelift-codegen`, `cranelift-frontend`, `cranelift-module`, `cranelift-object`): se toman el modelo de
bloques con parámetros, las instrucciones de desbordamiento y el escritor de objetos; se rechazan `cranelift-jit` y el
mecanismo de trampas de CLIF. El contrato de bajada pertenece a PseudoLearn.

Problema: las operaciones enteras con operandos constantes y las comprobaciones de finitud reales emitían comparaciones y bloques que el optimizador no eliminaba. Elección: `constant_folding` pliega suma, resta, multiplicación y negación cuando ambos operandos son constantes y no desbordan, y devuelve el otro operando cuando uno es la identidad; si el resultado desbordaría, se conserva el camino con trampa en tiempo de ejecución. La comprobación de finitud real compara `r - r` con cero (falso solo para finitos) y se fusiona con el salto. Las medidas aisladas muestran mejoras de NBody (3,96 a 3,55) y Sieve (1,92 a 1,68), no suficientes por sí solas. Se descarta plegar sin conservar la trampa, que cambiaría los diagnósticos de desbordamiento constante.
