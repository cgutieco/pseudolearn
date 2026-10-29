# pseudolearn_ir

## 1. Qué es y qué no es

Define la representación intermedia verificada.
No añade construcciones del lenguaje, UI ni efectos libres del anfitrión.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Ninguno | — | B2 de R5 |

## 2. Guía operativa y ciclo de vida

Versión exacta de rust-toolchain.toml del miembro.
Comprobación: `cargo test -p pseudolearn_ir`, `cargo xtask verify` y `rust-checks layers` del miembro. No se despliega por separado.

## 3. Arquitectura y modelo del sistema

Los orígenes de variable se identifican por función, variable y valor SSA; un valor numérico aislado
no identifica un origen entre funciones. Los metadatos laterales conservan el receptor y las firmas
de métodos necesarios para especializar llamadas sin volver a resolver nombres de fuente.

Nivel 3. Importa source y abi; serde_json solo para generación en build.rs. Prohibido importar capas superiores, UI, Dart o el sistema de especificaciones como código.

Módulo con clases, funciones y tabla lateral de orígenes; funciones con bloques SSA parametrizados. Instrucciones en columnas de operación, operandos, rangos, resultado y tramo. El tramo añade un ID de fuente compacto; el documento suelto conserva el ID cero. Operation (con la lista `Operation::ALL` de todas las operaciones), firmas, efectos y trampas se generan desde IR.INSTRUCTIONS. Lector y escritor del texto canónico. Verificador de R1–R11 con dominadores iterativos de Cooper–Harvey–Kennedy.

Registros, variantes y tuplas se aplanan a valores SSA con `value.reinterpret`, de modo que no existen campos ni cargas útiles que verificar en la RI; las disposiciones de esas construcciones las declara `pseudolearn_abi` y las consumen VM y AOT. El verificador solo valida lo que la RI expresa: R10 (campos únicos y almacenables, y orden creciente de `capture<N>` en las clases `$environment`) y R11 (conteos de 16 bits, el máximo de un operando). Una variante cuya etiqueta se prueba con `switch` hereda los ordinales de 16 bits de R3.

Invariantes: Toda RI traducida pasa el verificador y toda instrucción que puede atrapar u observar conserva tramo. Se informa la primera violación en orden textual.

## 4. Decisiones de diseño y fundamentos técnicos

La tabla de orígenes vincula valores SSA con variables declaradas para observación y no pertenece al formato textual normativo. La pureza se deriva del catálogo de efectos; no se materializan regiones que duplicarían información. Las llamadas directas infieren el tipo del resultado desde la firma de la función destino; `value.undefined` usa su operando explícito de tipo y `value.require` conserva el tipo del valor comprobado. Los intrínsecos `math.*` exigen y producen `f64`, `char.code` va de `char` a `i64` y `char.from_code` de `i64` a `char`; sin esa inferencia sus resultados quedaban sin tipo y el bytecode no podía asignarles registro. El verificador comprueba argumentos y usa asignabilidad nominal para permitir subtipos en argumentos de bloque y escrituras a celdas tipadas con una superclase. El chequeador hace disponibles los tipos inferidos a las instrucciones siguientes. El escritor conserva el tipo `f64` añadiendo `.0` a los literales que de otro modo se reanalizarían como enteros. Se rechazan catálogos manuales y comprobaciones tardías por instrucción.

La ejecución conserva determinismo cooperativo: `task.scope_open`, `task.spawn`, `task.await` y
`task.scope_join` son operaciones verificadas de la RI. `task.yield_check` y `call.suspendible`
conservan identidad en la RI para sus consumidores. La exportación del corpus es una dependencia de
datos. Las técnicas que requieren medición se aceptan solo tras conservar resultados y criterios.

Problema: dos rangos locales iguales pueden pertenecer a archivos distintos. Elección: `IrSpan` conserva `SourceId` junto con línea y columna; el formato canónico escribe `@f<ID>:` para IDs no nulos y mantiene la forma anterior `@` para el documento suelto. El verificador rechaza coordenadas vacías o invertidas. Se rechaza inferir el archivo por nombre o por orden de carga. Medición del registro en el host: 20 bytes por tramo frente a los 16 bytes del diseño previo, un incremento fijo de 4 bytes (25 %) por tramo; el ID evita almacenar rutas o identidades compuestas repetidas en cada entrada.

### Perfiles por fuente

Problema: el vocabulario de un módulo es único, pero un proyecto mezcla perfiles y un lógico debe imprimirse con el
vocabulario del archivo que contiene la operación. Elección: la cabecera conserva el vocabulario del módulo y, a
continuación, líneas `profile <identidad de fuente> <vocabulario>` ordenadas por identidad (`SourceProfile`).
`Module::vocabulary_for(fuente)` devuelve el de la fuente o el del módulo; `vocabularies()` los lista ordenados y sin
repetir, y `vocabulary_index_of(tramo)` da el índice que usa el AOT. El verificador rechaza dos entradas para una fuente
(`IR.MODEL#R1`). Un módulo sin tabla se imprime igual que antes. Descartado: un operando de vocabulario en cada `text.format`
y `out.write`, que cambiaría instrucciones calientes y la gramática de cada operación.

`value.reinterpret` conserva bits dentro de un banco y exige un portador canónico i64 o str; no admite unit ni celdas. `cell.load_raw` transporta palabras de celdas locales de salida, incluidas referencias inactivas nulas, sin cambiar la lectura comprobada de celdas administradas. El terminador switch recibe selector i64, destino por defecto y pares ordinal/destino ordenados, distintos y acotados a 16 bits. El verificador comprueba forma, tipos y las aristas con el mismo contrato de argumentos de bloque.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, doc, allow, expect, pánicos ni unsafe. Datos con índices tipados,
funciones pequeñas y fallos como Result. Límites y dependencias en architecture.yaml del miembro.
Las salidas generadas se producen en OUT_DIR y no se copian a consumidores.

## 6. Decisiones de producto que condicionan el código

IR.MODEL, IR.INSTRUCTIONS, IR.WELL-FORMEDNESS, IR.TEXT-FORMAT, IR.SOURCE-MAP e IR.OBSERVATION-POINTS. Ejecutar y observar conservan la misma semántica. Los identificadores, el contenido de
literales y los efectos del programa se preservan; idioma de interfaz y vocabulario son independientes.

## 7. Verificación, testing y aseguramiento de calidad

Un negativo por R1–R11, casos ir, ida y vuelta canónica, generación determinista y mutación de textos sin pánicos. Tests espejo, caminos felices, infelices y límites explícitos. Cada verificador tiene un negativo
con violación deliberada. No se cierran pendientes hasta tener cargo xtask verify y conformidad en verde.

## 8. Fuentes consultadas y genealogía conceptual

SSA con parámetros de bloque permite compartir semántica con futuros consumidores nativos. El verificador concentra las obligaciones antes de ejecutar.


### Funciones como valores y ámbitos de ejecución

Los orígenes de valores pueden conservar un intervalo léxico adicional sin cambiar la representación textual de instrucciones. `call.indirect` referencia un prototipo verificable y recibe una identidad escalar de código; la identidad nunca es una dirección. `object.load_raw` exige receptor y campo tipados y permite leer palabras cero de un entorno, incluidas referencias inactivas de agregados. La lectura ordinaria conserva su comprobación de inicialización.

## Colecciones, interfaces e iteración con limpieza

Las instrucciones collection.* mantienen la identidad de tipo de la colección y su disposición canónica en las declaraciones sintéticas. El verificador exige claves, hojas y ordinales exactos; rechaza bancos intercalados, claves reales y operaciones de objetos sobre cabeceras de colección. array.length se limita a arreglos unidimensionales. text.quote produce texto delimitado y escapado para la representación de contenidos, sin reinterpretar cadenas como identificadores.

Los tests de estas capacidades se ejecutaron en selecciones acotadas, incluida la comparación de gemelos con recolección forzada. La conformidad del corpus sigue pendiente de la revisión editorial independiente de los contratos nuevos, y la medición de tamaño excede el presupuesto de Wasm.

La RI textual delimita con comillas las identidades internas de tipos de colección y sus hojas cuando no pertenecen al alfabeto de nombres simples. Parser, tipos y printer comparten esa representación reversible; el contenido de una cadena literal de programa permanece distinto de un nombre dentro de la declaración o del tipo.


effect_call conserva receptor, identidad normativa de operación y argumentos evaluados de izquierda
a derecha, seguidos por celdas de resultado. Resultado usa tres hojas canónicas: discriminante,
palabra escalar y referencia; ErrorES superpone código textual e incertidumbre. Las operaciones
puras de Bytes usan una celda del tipo de resultado. El verificador valida aridad, bancos y celdas
antes del bytecode; ninguna respuesta de host se convierte silenciosamente en cero.

La familia de tareas ocupa `O94`–`O100`. El chequeador verifica clases, tipos de asa y destinos de
`task.scope_open`, `task.spawn`, `task.await`, `task.scope_join`, `call.suspendible`, `effect.await` y
`task.yield_check`; los consumidores de VM y bytecode conservan sus identidades de operación.

## Unidades suspendibles y puntos de cesión

La función conserva `suspendible`; el formato canónico lo expresa mediante `func suspendible` y
permite comprobar la restricción antes de bytecode. El verificador de suspensión rechaza cesiones
fuera de estas unidades y cesiones que no preceden inmediatamente a un salto hacia un dominador.
El parser separa las instrucciones de tarea sin operandos para no consumir la operación siguiente.
`snapshot.copy` recibe cantidad, fuentes referenciales y celdas destino con tipos exactos; copia el
grafo conjunto sin añadir sentencias ni convertir errores de tipos en comprobaciones dinámicas.

## Métodos HTTP en llamadas de efecto

`HttpMethod` es un enumerado contextual representado como escalar `i64`. El verificador de
`effect_call` reconoce ese valor en la firma de las operaciones HTTP; antes el chequeo genérico lo
trataba como referencia, aunque la ABI ya lo clasificaba como escalar, y rechazaba programas válidos
al pasar de semántica a RI. Se conserva la tabla existente de operaciones y no se añaden instrucciones
ni tipos a la RI.

Las operaciones JSON guardan referencias de `JsonValue` en celdas de banco de referencia, cuyo tipo
de transporte es `str`; el encabezado del efecto conserva el tipo semántico `$effect:JsonValue`. El
verificador valida ambas fronteras por separado para `JsonResult` y `OptionalJsonValue`.

Los resultados `OptionalBoolean`, `OptionalInteger` y `OptionalReal` guardan etiqueta y carga en celdas `i64`: los
variantes del motor almacenan todo escalar como palabra (los reales como sus bits), y el verificador exige esa
representación en ambas celdas.
