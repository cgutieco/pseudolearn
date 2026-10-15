# pseudolearn_bytecode

## 1. Qué es y qué no es

Traduce la RI verificada a bytecode gemelo. Diseño aprobado; implementación pendiente en R5.
No añade construcciones del lenguaje, UI ni efectos libres del anfitrión.

| Pendiente | Dependencia | Fase |
|---|---|---|
| Implementación y pruebas del diseño descrito | Contratos y puertas previas verificadas | R5 |

## 2. Guía operativa y ciclo de vida

Versión exacta de rust-toolchain.toml del miembro. La carpeta aún no contiene manifiesto ni código.
Al implementarla se incorpora al workspace y se retira pending de architecture.yaml. Comprobación
actual: `cargo xtask verify` y `rust-checks layers` del miembro. No se despliega por separado.

## 3. Arquitectura y modelo del sistema

Nivel 5. Importa ir y source; serde_json solo para generación. Prohibido importar capas superiores, UI, Dart o el sistema de especificaciones como código.

Instrucciones de ocho bytes con opcode u8 y hasta tres operandos u16; constantes por función y texto por módulo. Ranuras de origen por variable y temporales por exploración lineal, separados en escalar y referencia. Salida de SSA con copias paralelas y temporal para ciclos. Código acolchado a potencia de dos con Unreachable.

Invariantes: Los gemelos comparten el mapa de registros. Cada operando cabe en su ventana; cada salto pertenece a su función; cada punto seguro tiene mapas y cada punto de retorno existe en ambos gemelos.

## 4. Decisiones de diseño y fundamentos técnicos

Una única generación parametrizada produce Fast y Probed. El rápido omite observación y registro de escrituras. Descriptores de bloque contienen masas de sentencia y evento; los cargos se fusionan en saltos. Los puntos de retorno tienen identidad independiente del gemelo. Mapas nocionales de raíces, definición y variable→ranura distinguen el estado del programa de temporales muertos. Superinstrucciones se seleccionan por perfil y se validan fuera de muestra. Una expresión pura fusionada reejecuta sus componentes en orden ante una marca de fallo para atribuir la primera trampa.

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
