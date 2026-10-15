# pseudolearn_ir

## 1. Qué es y qué no es

Define la representación intermedia verificada. Diseño aprobado; pendiente de implementación del motor de ejecución.
No añade construcciones del lenguaje, UI ni efectos libres del anfitrión.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Implementación y pruebas del diseño descrito | Contratos y puertas previas verificadas | Motor de ejecución |

## 2. Guía operativa y ciclo de vida

Versión exacta de rust-toolchain.toml del miembro. La carpeta aún no contiene manifiesto ni código.
Al implementarla se incorpora al workspace y se retira pending de architecture.yaml. Comprobación
actual: `cargo xtask verify` y `rust-checks layers` del miembro. No se despliega por separado.

## 3. Arquitectura y modelo del sistema

Nivel 3. Importa source y abi; serde_json solo para generación. Prohibido importar capas superiores, UI, Dart o el sistema de especificaciones como código.

Módulo con clases, funciones y tabla lateral de orígenes; funciones con bloques SSA parametrizados. Instrucciones en columnas de operación, operandos, rangos, resultado y tramo. Operation, firmas, efectos y trampas se generan desde IR.INSTRUCTIONS. Lector y escritor del texto canónico. Verificador de R1–R9 con dominadores iterativos de Cooper–Harvey–Kennedy.

Invariantes: Toda RI traducida pasa el verificador y toda instrucción que puede atrapar u observar conserva tramo. Se informa la primera violación en orden textual.

## 4. Decisiones de diseño y fundamentos técnicos

La tabla de orígenes vincula valores SSA con variables declaradas para observación y no pertenece al formato textual normativo. La pureza se deriva del catálogo de efectos; no se materializan regiones que duplicarían información. Se rechazan catálogos manuales y comprobaciones tardías por instrucción.

La implementación permanece secuencial y determinista. La exportación del corpus es una dependencia
de datos. Las técnicas que requieren medición se aceptan solo tras conservar resultados y criterios.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, doc, allow, expect, pánicos ni unsafe. Datos con índices tipados,
funciones pequeñas y fallos como Result. Límites y dependencias en architecture.yaml del miembro.
Las salidas generadas se producen en OUT_DIR y no se copian a consumidores.

## 6. Decisiones de producto que condicionan el código

IR.MODEL, IR.INSTRUCTIONS, IR.WELL-FORMEDNESS, IR.TEXT-FORMAT, IR.SOURCE-MAP e IR.OBSERVATION-POINTS. Ejecutar y observar conservan la misma semántica. Los identificadores, el contenido de
literales y los efectos del programa se preservan; idioma de interfaz y vocabulario son independientes.

## 7. Verificación, testing y aseguramiento de calidad

Un negativo por R1–R9, casos ir, ida y vuelta canónica, generación determinista y mutación de textos sin pánicos. Tests espejo, caminos felices, infelices y límites explícitos. Cada verificador tiene un negativo
con violación deliberada. No se cierran pendientes hasta tener cargo xtask verify y conformidad en verde.

## 8. Fuentes consultadas y genealogía conceptual

SSA con parámetros de bloque permite compartir semántica con futuros consumidores nativos. El verificador concentra las obligaciones antes de ejecutar.
