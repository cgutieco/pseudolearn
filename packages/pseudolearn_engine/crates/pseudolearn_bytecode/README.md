# pseudolearn_bytecode

## 1. Qué es y qué no es

Traduce una RI verificada a bytecode gemelo con asignación de registros por clase, depósitos de constantes,
verificación estructural y selección perfilada de superinstrucciones.
No añade construcciones del lenguaje, UI ni efectos libres del anfitrión.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Acolchado del código a potencia de dos y comprobación de límites de PC resultantes | Formato de bytecode y verificador | B3.1 |

## 2. Guía operativa y ciclo de vida

Usa la versión exacta de rust-toolchain.toml del miembro. El crate ya está activo en el workspace;
el acolchado a potencia de dos mantiene B3.1 abierto. Comprobación: `cargo xtask verify` y
`rust-checks layers` del miembro. No se despliega por separado.

## 3. Arquitectura y modelo del sistema

Nivel 5. Importa ir y source; serde_json solo para generación. Prohibido importar capas superiores, UI, Dart o el sistema de especificaciones como código.

El catálogo de opcodes y sus identidades se generan desde la exportación de `IR.INSTRUCTIONS`. Cada función
conserva descriptores de bloque, tablas de constantes, tipos de registro y spans laterales. Las ranuras se
asignan en orden estable y se separan por clase de valor. La salida SSA transporta argumentos de bloque
como copias paralelas; los gemelos rápido y sondeado comparten registros, constantes, descriptores y puntos
de retorno.

Invariantes: Los gemelos comparten el mapa de registros, depósitos de constantes y descriptores de bloque. Cada operando cabe en su ventana; cada salto pertenece a su función; cada superinstrucción contiene un par compatible del mismo bloque; cada punto de retorno existe en ambos gemelos con PC propio.

## 4. Decisiones de diseño y fundamentos técnicos

Una única generación parametrizada produce Fast y Probed. El rápido omite observación y registro de escrituras. Descriptores de bloque contienen masas de sentencia y evento; los cargos se fusionan en saltos. Los puntos de retorno tienen identidad independiente del gemelo y PC propio para cada variante. El verificador rechaza registros fuera de ventana, saltos inválidos, incompatibilidades de clase, continuaciones sin identidad y fusiones de opcode incompatibles. El compilador recibe las superinstrucciones elegidas a partir de perfiles de entrenamiento; la fusión de comparación y salto se valida con una carga reservada. Una expresión pura fusionada reejecuta sus componentes en orden ante una marca de fallo para atribuir la primera trampa.
Los literales escalares usados por operaciones aritméticas, comparaciones y escritura pasan como
operandos constantes directos; se mantienen registros solo cuando una transferencia de bloque,
llamada o instrucción sin forma inmediata necesita el valor.
Fast elimina marcadores de observación antes del despacho; Probed los conserva. Las tablas de retorno
comparten identidad y mantienen sus contadores de programa por gemelo.

La implementación permanece secuencial y determinista. La exportación del corpus es una dependencia
de datos. Las técnicas que requieren medición se aceptan solo tras conservar resultados y criterios.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, doc, allow, expect, pánicos ni unsafe. Datos con índices tipados,
funciones pequeñas y fallos como Result. Límites y dependencias en architecture.yaml del miembro.
Las salidas generadas se producen en OUT_DIR y no se copian a consumidores.

## 6. Decisiones de producto que condicionan el código

No introduce observables; conserva los de la RI y habilita ENG.EXEC y ENG.TRACE. Ejecutar y observar conservan la misma semántica. Los identificadores, el contenido de
literales y los efectos del programa se preservan; idioma de interfaz y vocabulario son independientes.

## 7. Verificación, testing y aseguramiento de calidad

Negativos del verificador, ciclos de copias paralelas, diferencial entre gemelos, cambio arbitrario de gemelo y validación de superinstrucciones fuera de muestra. Tests espejo, caminos felices, infelices y límites explícitos. Cada verificador tiene un negativo
con violación deliberada. No se cierran pendientes hasta tener cargo xtask verify y conformidad en verde.

## 8. Fuentes consultadas y genealogía conceptual

Lua inspira registros, JVM verificación y Self cambio de código. Ertl y Gregg inspiran superinstrucciones por perfil; se rechaza elegirlas por intuición o solo por entrenamiento.
