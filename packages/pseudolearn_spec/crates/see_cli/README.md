# see_cli

## 1. Qué es y qué no es

Orquesta archivos y procesos para new, validate, graph, lock, diff, impact, conform, matrix, feature y export. Lee revisiones Git sin modificar el checkout, rechaza sobrescrituras y comprueba artefactos generados. El único adaptador ejecutable en R1 es reference.

## 2. Guía operativa y ciclo de vida

`cargo test -p see_cli`; `cargo check -p see_cli` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Imports internos permitidos: model, format, graph, change, validation, conformance, report, export, translation. Prohibidas las capas superiores y los sujetos. `src/` implementa la capa; `tests/` refleja módulos.

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
