# pseudolearn_vm

## 1. Qué es y qué no es

Ejecuta bytecode verificado mediante bancos de registros. La interfaz distingue terminación, salida de
servicio y trampa tipada con span; la VM no importa la API ni la línea temporal.
No añade construcciones del lenguaje, UI ni efectos libres del anfitrión.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Gemelo sondeado en ejecución, eventos, cambio de gemelo y entrada | Línea de eventos y API | B5 |

## 2. Guía operativa y ciclo de vida

Usa la versión exacta de `rust-toolchain.toml` del miembro. El crate está activo en el workspace y
ejecuta las familias escalares y de referencia de `IR.INSTRUCTIONS`, texto, arreglos, celdas, objetos,
llamadas recursivas y virtuales, copia superficial, salida formateada y azar sembrado. B5 conserva la
entrada, los eventos y el cambio al gemelo sondeado. Comprobación: `cargo xtask verify` del motor, que
incluye tests, Clippy y `rust-checks all`.

La API pública tiene dos pasos: `load(&VerifiedBytecode) -> LoadedProgram` construye la forma de
despacho y `run_loaded(&LoadedProgram, Fuel)` la ejecuta con estado nuevo. `run` y `run_profiled` cargan y
ejecutan en una sola llamada. Una carga se puede ejecutar cualquier número de veces.

## 3. Arquitectura y modelo del sistema

La ejecución configurable recibe semilla, límites de profundidad y celdas, política de recolección y
lexemas de formato. Las entradas existentes delegan con valores predeterminados. El montón pertenece
a una ejecución; el programa cargado es inmutable y reutilizable. Las instrucciones de memoria se
decodifican en carga y usan los mapas de raíces del bytecode, sin consultar tipos de fuente al ejecutar.
Los destinos de celdas son índices estables de banco o pares asa-desplazamiento. Una escritura indirecta
actualiza el banco propietario sin depender de su capacidad física.

Nivel 7. Importa bytecode, runtime, library y diagnostics; en compilación usa `pseudolearn_vm_dispatch`.
Prohibido importar capas superiores, UI, Dart o el sistema de especificaciones como código.

| Módulo | Responsabilidad |
|---|---|
| `dispatch.rs` | Incluye el código generado: familias de opcode, `enum Op`, selección de forma y paso |
| `load/` | Traduce el gemelo rápido verificado a la forma de despacho de cada función |
| `load/definedness.rs` | Decide qué registros enteros necesitan bit de definición en ejecución |
| `load/edges.rs`, `load/parallel_copy.rs` | Aristas con destino, masa, sondeo y copias de parámetros secuenciadas |
| `load/instructions/` | Decodificación de operaciones escalares, de valor, salida y control |
| `evaluate/` | Evaluadores puros palabra a palabra por familia, con trampas como `Fault` |
| `machine/` | Estado de ejecución, registros, control, llamadas, salida y perfil de opcodes |

**Forma de despacho.** Cada función cargada tiene un `Vec<Op>` de longitud potencia de dos (el bytecode ya
llega acolchado con `unreachable`), una tabla lateral de spans, otra de opcodes de origen para el perfil,
aristas, movimientos, sitios de llamada y la tabla `identidad de retorno → pc`. `Op` es `Copy`: lleva los
índices de registro y los inmediatos en la propia operación. Los predicados de comparación se resuelven
en carga a operaciones distintas (`IntLess`, `RealGreaterOrEqual`…), y cada operación escalar tiene formas
registro/registro, registro/inmediato, inmediato/registro e inmediato/inmediato. Las parejas
comparación-salto que elige el perfil de superinstrucciones se convierten en una sola operación fusionada
que conserva la escritura del lógico intermedio.

**Despacho generado.** `build.rs` llama a `pseudolearn_vm_dispatch` con la exportación de `IR.INSTRUCTIONS` y
`data/dispatch_forms.json`, y escribe en `OUT_DIR` el `enum Op`, la selección de forma y la función `step`,
un `match` con un brazo por forma que llama a un evaluador o manejador `#[inline]`. El bucle
(`machine/mod.rs`) toma `Op` por `pc & mask`, avanza el `pc` y llama a `step`; una trampa se convierte en
`VmTrap` con el span de la posición ejecutada. La tabla de formas es la única lista de operaciones: una
operación nueva es una fila nueva.

**Estado caliente.** La máquina guarda la función actual, el cursor (`pc`, base escalar, base de
referencias), el combustible y la salida. Hay una sola pila escalar `Vec<u64>`, una pila de bits de
definición alineada con ella, una pila de referencias `Vec<u32>` y una pila de control
`Vec<ControlFrame>` de valores `Copy`. Una llamada coloca la ventana del llamado tras la del llamador,
crece las pilas por duplicación con `try_reserve` (fallo → `resourceLimit`, nunca pánico), copia los
argumentos y salta al pc 0. El retorno restaura el cursor del marco y obtiene el pc de continuación por la
identidad del punto de retorno con una carga indexada. Ninguna llamada asigna salvo cuando la pila crece.

**Ausencia.** Reales, lógicos y caracteres guardan un centinela al quedar sin valor (NaN, `2`,
`0xFFFF_FFFF`) y `value.require` lo comprueba. Los enteros no tienen centinela: el cargador clasifica cada
registro entero como definido, indefinido o dinámico. Solo los parámetros (de bloque o de función) son
dinámicos, y de ellos solo los que alcanza un `value.require` o un argumento de llamada, cerrando la
relación por las copias de parámetros de bloque, llevan bit en ejecución. Una lectura de un entero
estáticamente definido es una copia; de uno estáticamente indefinido, una trampa directa; de uno dinámico,
la comprobación del bit. Las operaciones aritméticas nunca tocan bits.

**Combustible.** Cada arista lleva la masa de sentencias del bloque destino; tomarla resta la masa o sale
con `Service(Statements)` sin ejecutar el bloque. Las aristas de retroceso hacia bloques sin masa son de
sondeo y consumen el contador propio de sondeo. La entrada a una función cobra la masa de su bloque
inicial.

Invariantes: ningún acceso sale de su banco (todos los accesos usan `get` y una ruta de fallo fría). El
rápido nunca observa. Ningún límite agota la pila del anfitrión: la recursión del lenguaje vive en
pilas propias. La profundidad no depende de una capacidad fija elegida por plataforma.

## 4. Decisiones de diseño y fundamentos técnicos

- **Problema:** la primera VM interpretaba directamente el modelo estructural del bytecode: buscaba la
  función y la superinstrucción en un `BTreeMap` en cada paso, leía operandos de un `Vec` de enums,
  comparaba predicados como cadenas, buscaba y clonaba el descriptor de bloque en cada salto, consultaba
  el tipo del registro en cada escritura y asignaba cuatro vectores por llamada. Con esa representación la
  trazadora no superó 16,6× ni con PGO. **Elección:** forma de despacho compacta construida una vez por
  carga, fuera del intervalo medido, sobre la que sí rinden los peldaños de la escalera de rendimiento
  (manejadores pequeños con rutas frías, formas registro-inmediato, estado caliente y bancos por
  ventana). Con ella la trazadora supera el umbral de 30× sin PGO; la cifra y su procedencia están en
  `packages/pseudolearn_spec/results/r5-vm-tracer.json`. **Descartado:** PGO, que añade `llvm-tools` a la
  cadena y hace al binario depender de un perfil, y seguir afinando la representación estructural.
- **Problema:** las comprobaciones de definición de enteros costaban una escritura de bit en cada
  operación. **Elección:** análisis estático en carga; solo los parámetros dinámicos consultados pagan.
  **Descartado:** bits de definición en todas las escrituras y un centinela entero, que reduciría el rango.
- **Problema:** una arista con varios parámetros es una copia paralela. **Elección:** secuenciación en
  carga, rompiendo ciclos con un registro auxiliar por clase al final de cada ventana; el bit de
  definición viaja con la palabra. **Descartado:** copiar todo a temporales en cada salto.
- **Problema:** una instrucción no soportada todavía no debe impedir ejecutar programas que no la
  alcanzan. **Elección:** la carga la convierte en `Unsupported`, que atrapa al ejecutarse.
- Una raíz cuadrada negativa, como cualquier resultado matemático indefinido o no finito, atrapa con
  `nonFiniteRealResult` (`LIB.CORE.MATH#R1`); un defecto interno de precisión de la biblioteca atrapa con
  `internalFault`.
- La VM sale hacia su llamador con `Exit::Service` y no importa timeline ni API. La ejecución devuelve
  `Completed`, `Service` o `Trap`; el llamador interpreta la salida de servicio. La salida del programa se
  acumula en el resultado de ejecución, sin escribir en el anfitrión; B4 incorpora el formato de valores
  primitivos y texto. La entrada del anfitrión permanece en B5.

La implementación permanece secuencial y determinista. La exportación del corpus es una dependencia
de datos. Las técnicas que requieren medición se aceptan solo tras conservar resultados y criterios.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, doc, allow, expect, pánicos ni unsafe. Datos con índices tipados,
funciones pequeñas y fallos como Result. Límites y dependencias en architecture.yaml del miembro.
Las salidas generadas se producen en OUT_DIR y no se copian a consumidores; el texto generado es
compacto y no se edita.

## 6. Decisiones de producto que condicionan el código

ENG.EXEC.*, ENG.TRACE.*, ENG.INPUT y ENG.LIMITS. Ejecutar y observar conservan la misma semántica. Los identificadores, el contenido de
literales y los efectos del programa se preservan; idioma de interfaz y vocabulario son independientes.

## 7. Verificación, testing y aseguramiento de calidad

Tests espejo con caminos felices, infelices y límites explícitos: `execute_tests` (aritmética, trampas con
su código y span, `i64::MIN mod -1`, ceros con signo, intrínsecos matemáticos), `control_tests`
(continuaciones, combustible exacto en el borde y uno por debajo, sondeo de bucles vacíos),
`registers_tests` (definición por parámetros de bloque, centinelas, copias cruzadas), `calls_tests`
(recursión de 20 000 marcos con crecimiento de bancos, argumentos sin valor, trampas en el llamado),
`load_tests` (carga reutilizable, entrada ausente, operación no soportada no alcanzada),
`profile_tests` y `output_tests`; `load/parallel_copy_tests.rs` cubre la secuenciación de copias. La
trazadora de `pseudolearn_vm_tracer` mide la aceleración frente a `reference`. No se cierran pendientes
hasta tener `cargo xtask verify` y conformidad en verde.

## 8. Fuentes consultadas y genealogía conceptual

Lua inspira ventanas de registros y operandos registro-constante; Ertl y Gregg, la especialización de
operandos y las superinstrucciones por perfil; la JVM, la verificación previa; Self, el cambio de código.
Se toma la especialización estática en carga y se rechaza la generación de código máquina en ejecución,
que pertenece a R6. Se preserva Rust seguro y se mide el despacho antes de optimizar.
