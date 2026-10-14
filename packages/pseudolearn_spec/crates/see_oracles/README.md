# see_oracles

## 1. Qué es y qué no es

Calcula sumas y cantidad de iteraciones con i128 a partir de operandos i64. Decide límites sin ejecutar sujetos; rechaza paso cero y cantidades que no caben en u64. No proporciona generación de propiedades en R1.

## 2. Guía operativa y ciclo de vida

`cargo test -p see_oracles`; `cargo check -p see_oracles` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Imports internos permitidos: ninguno. Prohibidas las capas superiores y los sujetos. `src/` implementa la capa; `tests/` refleja módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: responsabilidades independientes. Elección: crate por capa con contratos tipados.
Se descarta importar sujetos o capas superiores para preservar la dirección.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml` del miembro; código inglés sin comentarios ni unsafe.

## 6. Decisiones de producto que condicionan el código

R1 autoriza solo el sistema de especificaciones. Ninguna lógica del motor vive aquí.

## 7. Verificación, testing y aseguramiento de calidad

`cargo xtask verify` desde el miembro; casos felices, infelices y límites en tests espejo.

## 8. Fuentes consultadas y genealogía conceptual

Plan aprobado del sistema SEE. Las bibliotecas externas son infraestructura, nunca autoridad sobre el comportamiento de PseudoLearn.
