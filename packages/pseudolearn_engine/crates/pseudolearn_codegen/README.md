# pseudolearn_codegen

## 1. Qué es y qué no es

Generador de código máquina del sujeto `aot`. Traduce un `pseudolearn_ir::Module` verificado a un archivo objeto
relocalizable del objetivo anfitrión (Mach-O, ELF o COFF) con Cranelift. El objeto exporta una función `__pl_fn_<n>` por
función de la RI y deja sin resolver únicamente los símbolos `rt_aot_*` de `pseudolearn_aot_rt`. Lo consumen el
enlazador del ejecutable y el adaptador de conformidad `aot`.

Responsabilidades exclusivas: bajada de bloques SSA con parámetros a CLIF, prólogo y epílogo de marco, contabilidad de
`block.mass`, aritmética entera y real comprobada, comparaciones, lógicos y caracteres escalares, llamadas directas con
propagación inmediata de fallo, bloques fríos de trampa por sitio y tabla de sitios de fallo.

Fuera de alcance de producto: trazas, instantáneas y observación paso a paso (`aot` está exento de `ENG.TRACE.*` y
`ENG.STATE.*`); desoptimización hacia la VM.

Fuera de alcance técnico: enlace y empaquetado del ejecutable; la biblioteca estática del runtime; `unsafe`
(`#![forbid(unsafe_code)]`); `cranelift-jit`; dependencias de LLVM o de un compilador C.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Familias `O5` (`const.str`), `text.*`, `math.sqrt/abs/ln/exp/sin/cos/atan`, `array.*`, `object.*`, `ref.cmp`, `cell.*`, `call.virtual`, `out.write`, `in.read`, `host.random` devuelven `CodegenError::Unsupported` con el nombre de la operación | Acceso en línea a memoria, pila de raíces y tablas de clases | Memoria, clases, celdas, biblioteca y E/S |
| `value.undefined` de `i64` y de referencias, y `value.require` de referencias | Indicador de definición para enteros y representación del asa sin valor | Memoria, clases, celdas, biblioteca y E/S |
| Cabecera `main`, metadatos de literales y de clases en el objeto | Formato de metadatos y punto de entrada del ejecutable | Enlace nativo |
| Nivel de optimización de Cranelift fijado en `none` | Medición de rendimiento sobre `PERF.SUITE.AWFY-CORE` | Experimento de rendimiento |

## 2. Guía operativa y ciclo de vida

Desde `packages/pseudolearn_engine`, con la cadena `cargo` fijada por `rust-toolchain.toml`:

- Compilar: `cargo build -p pseudolearn_codegen`.
- Probar: `cargo test -p pseudolearn_codegen -- --test-threads=1`.
- Verificar todo el motor: `cargo xtask verify`.

Los tests de ejecución enlazan el objeto emitido con un arnés de `rustc` y las `rlib` de `pseudolearn_aot_rt` y
`pseudolearn_diagnostics` de `target/<perfil>/deps`, y ejecutan el binario resultante. Requieren `rustc` y un
enlazador del sistema en el `PATH`. Los artefactos de cada ejecución se escriben bajo `CARGO_TARGET_TMPDIR`.

## 3. Arquitectura y modelo del sistema

Nivel 7. Importa `pseudolearn_ir` (modelo y verificador), `pseudolearn_diagnostics` (`DiagnosticCode`) y
`pseudolearn_aot_rt` (desplazamientos del contexto, tipos `FaultSite` y `SourceRange`, selectores `MATH_*`). Ningún
crate del motor lo importa salvo el enlazador y el adaptador `aot`.

Fachada: `compile_module_to_object(&Module, &TargetConfig) -> Result<CompiledObject, CodegenError>`. Verifica el módulo
con `verify_module` antes de emitir. `CompiledObject` contiene los bytes del objeto, la tabla `fault_sites` que la sesión
de `pseudolearn_aot_rt` recibe tal cual y la lista `function_symbols` (nombre en la RI y símbolo).

Convención de las funciones generadas: `extern "C"`, primer parámetro `*mut AotRuntimeContext`, luego un parámetro por
parámetro de la RI. Tipos: `i64`→`I64`, `f64`→`F64`, `bool`→`I8` (0 o 1), `char`→`I32`, `str`, `array`, `obj` y `cell`→`I32`
(asa); `unit` no ocupa parámetro ni retorno.

| Módulo | Responsabilidad |
|---|---|
| `object_emitter` | Declara, define y serializa las funciones con `cranelift-object` |
| `function_compiler` | Entrada Cranelift con prólogo, bloques de la RI en orden inverso de postorden |
| `block_order` | Orden inverso de postorden desde el bloque de entrada; los bloques inalcanzables no se emiten |
| `block_accounting` | Resta `block.mass` de `instruction_remaining` en la cabecera de cada bloque |
| `lowering` | Estado de una función, sitios de trampa fríos, propagación de fallo y retorno de cero |
| `instruction_dispatch` | Despacho de cada `Operation` a su familia |
| `lower_scalars`, `lower_arithmetic`, `lower_real`, `lower_control`, `lower_calls` | Bajada por familia |
| `runtime_calls`, `abi_signatures` | Firmas e invocación de las entradas `rt_aot_*` |
| `fault_table` | Tabla de sitios (`DiagnosticCode` y tramo fuente) |
| `context_layout` | Desplazamientos del contexto como `i32` |
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
`stmt.enter`, `stmt.exit` y `decide.*` no emiten código.

Aritmética: suma, resta, producto y opuesto con `sadd_overflow`, `ssub_overflow` y `smul_overflow`; el opuesto es
`0 - x`. División: divisor cero (`divisionByZero`) antes que mínimo entre menos uno (`integerOverflow`). Módulo: divisor
cero atrapa; con divisor `-1` se sustituye por `1`, de modo que el resto es cero sin ejecutar `srem` sobre
`i64::MIN / -1`. Reales: `fadd`, `fsub`, `fmul`, `fdiv`; el resultado no finito se detecta con `|x| < +inf` (falso para
NaN) y atrapa `nonFiniteRealResult`; el divisor real cero, incluido `-0.0`, atrapa `divisionByZero` antes de dividir;
`real.neg` es `fneg`. `int.pow`, `real.pow`, `real.trunc` y `real.round` llaman a `rt_aot_integer_power`,
`rt_aot_real_power` y `rt_aot_math_unary`, cuyo resultado se lee de `result_word`.

Estados sin valor escalares: `bool` usa el centinela 2, `char` el centinela `0xFFFF_FFFF` y `f64` un NaN, igual que la VM;
`value.require` atrapa `uninitializedVariableRead` al encontrarlos.

## 4. Decisiones de diseño y fundamentos técnicos

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

Problema: los enteros sin valor requieren un indicador de definición. Elección: se rechazan con
`CodegenError::Unsupported` hasta que exista el análisis de definición, en lugar de aproximarlos.

Problema: `cranelift-object` activa siempre `gimli`, que arrastra una segunda versión de `hashbrown`, y Cranelift usa `Apache-2.0 WITH LLVM-exception`. Elección: la política de `deny.toml` admite esa licencia y `Zlib` y exime únicamente `hashbrown@0.16.1` de la regla de versiones duplicadas.

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

`tests/execution/` contiene un único binario de tests: `support.rs` genera, enlaza y ejecuta un arnés por módulo de RI;
`integer_tests.rs`, `real_tests.rs`, `scalar_tests.rs`, `control_tests.rs` y `call_tests.rs` cubren cada familia con
camino feliz e infeliz y con los bordes `i64::MAX + 1`, `i64::MIN - 1`, `i64::MIN * -1`, `i64::MIN / -1`, `x / 0`, divisor
real cero con signo, exponentes negativos, truncamiento fuera de rango, límites de escalares Unicode, presupuesto
exacto y agotado, paso cero, función sin retorno, código inalcanzable, recursión hasta el límite exacto de marcos y
propagación del fallo de la función llamada. `tests/object_emitter_tests.rs` comprueba que todo símbolo indefinido es una
entrada `rt_aot_*`, que toda relocalización apunta a un símbolo del objeto, los sitios de fallo con su tramo, el orden de
símbolos, el determinismo, el módulo vacío y el rechazo de operaciones no soportadas y de módulos mal formados.

Aceptación de un cambio: `cargo xtask verify` desde la raíz del motor.

## 8. Fuentes consultadas y genealogía conceptual

Cranelift (`cranelift-codegen`, `cranelift-frontend`, `cranelift-module`, `cranelift-object`): se toman el modelo de
bloques con parámetros, las instrucciones de desbordamiento y el escritor de objetos; se rechazan `cranelift-jit` y el
mecanismo de trampas de CLIF. El contrato de bajada pertenece a PseudoLearn.
