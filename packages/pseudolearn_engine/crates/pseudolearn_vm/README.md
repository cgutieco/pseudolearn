# pseudolearn_vm

## 1. Qué es y qué no es

Ejecuta bytecode verificado mediante bancos de registros. La interfaz distingue terminación, salida de
servicio y trampa tipada con span; la VM no importa la API ni la línea temporal.
No añade construcciones del lenguaje, UI ni efectos libres del anfitrión.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Familias restantes de operaciones y cobertura completa de ejecución de B3 | Bytecode y contratos de ejecución | B3.2 |

## 2. Guía operativa y ciclo de vida

Usa la versión exacta de rust-toolchain.toml del miembro. El crate ya está activo en el workspace y
ejecuta el subconjunto escalar y recursivo usado por la trazadora. Entrada, referencias, texto, arreglos
y objetos siguen pendientes de sus bloques. Comprobación: `cargo xtask verify` y `rust-checks layers` del
miembro.

## 3. Arquitectura y modelo del sistema

Nivel 7. Importa bytecode, runtime, library y diagnostics; serde_json solo para generación. Prohibido importar capas superiores, UI, Dart o el sistema de especificaciones como código.

Despacho generado con pc, bases, combustible, eventos, marca de agua y máscaras en locales. Bancos escalares y de referencias crecen a potencias de dos. Control y retornos usan identidades de continuación compartidas por ambos gemelos. Trampas inmediatas devuelven un valor tipado y el span original. La VM recibe solo bytecode verificado y no llama a `API.EXECUTE`.

Invariantes: Ningún acceso sale de su banco. El rápido nunca observa. Ningún límite agota la pila del anfitrión. La profundidad no depende de una capacidad fija elegida por plataforma.

## 4. Decisiones de diseño y fundamentos técnicos

La VM sale hacia su llamador con `Exit::Service` y no importa timeline ni API. El combustible limita el
avance; los retrocesos sin sentencias tienen un contador de sondeo propio para conservar cancelabilidad.
La ejecución devuelve `Completed`, `Service` o `Trap`; el llamador interpreta la salida de servicio. La
medición interna construye y valida el programa antes de iniciar el intervalo cronometrado. Se rechazan
bancos fijos que alterarían límites y banderas de trampa escritas en cada operación.
El bucle conserva una referencia a la instrucción verificada y mantiene la construcción del trap en una
ruta fría; cada paso evita clonar el vector de operandos.
La superinstrucción comparación-salto usa los perfiles de B3.3; conserva la escritura SSA intermedia,
el PC del salto y su cargo de retroceso, y el modo perfilado cuenta las dos instrucciones originales.
Las operaciones escalares leen y escriben palabras directamente en su banco; `RuntimeValue` queda en las
fronteras de llamada y retorno, fuera de la ruta aritmética caliente.
El salto instala en el marco la masa del bloque destino; el cobro de combustible no vuelve a buscar el
descriptor por PC.

La implementación permanece secuencial y determinista. La exportación del corpus es una dependencia
de datos. Las técnicas que requieren medición se aceptan solo tras conservar resultados y criterios.

La salida del programa se acumula en el resultado de ejecución, sin escribir en el anfitrión. La primera ruta implementada formatea enteros escalares; la salida de los demás valores depende de sus representaciones del runtime.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, doc, allow, expect, pánicos ni unsafe. Datos con índices tipados,
funciones pequeñas y fallos como Result. Límites y dependencias en architecture.yaml del miembro.
Las salidas generadas se producen en OUT_DIR y no se copian a consumidores.

## 6. Decisiones de producto que condicionan el código

ENG.EXEC.*, ENG.TRACE.*, ENG.INPUT y ENG.LIMITS. Ejecutar y observar conservan la misma semántica. Los identificadores, el contenido de
literales y los efectos del programa se preservan; idioma de interfaz y vocabulario son independientes.

## 7. Verificación, testing y aseguramiento de calidad

Trazadora numérica y recursiva antes del runtime completo; gemelos y cambios arbitrarios; límites exactos, cancelación de bucle vacío, entrada inválida, ausencia y robustez generada. Tests espejo, caminos felices, infelices y límites explícitos. Cada verificador tiene un negativo
con violación deliberada. No se cierran pendientes hasta tener cargo xtask verify y conformidad en verde.

## 8. Fuentes consultadas y genealogía conceptual

Lua inspira ventanas, JVM verificación y Self cambio de código; se preserva Rust seguro y se mide el despacho antes de optimizar.
