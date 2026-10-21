# see_change

## 1. Qué es y qué no es

Calcula SHA-256 de contratos canónicos, conserva anclajes históricos y propone clases de cambio. No decide por una persona el significado de una diferencia. Mientras el versionado esté congelado, los cambios oficiales de contenido conservan versión y requieren `lock --refresh` de sus identidades; al reabrirse el versionado, vuelve la inmutabilidad estricta por versión.

## 2. Guía operativa y ciclo de vida

`cargo test -p see_change`; `cargo check -p see_change` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Imports internos permitidos: model. Prohibidas las capas superiores y los sujetos. `src/` implementa la capa; `tests/` refleja módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: mantener el texto oficial sin publicar aún una versión del lenguaje. Elección: el modo congelado permite reanclar una edición explícita bajo la misma identidad y versión; conserva el historial de las demás versiones.
Se descarta abrir versiones nuevas antes de la autorización de publicación.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml` del miembro; código inglés sin comentarios ni unsafe.

## 6. Decisiones de producto que condicionan el código

R1 autoriza solo el sistema de especificaciones. Ninguna lógica del motor vive aquí.

## 7. Verificación, testing y aseguramiento de calidad

`cargo xtask verify` desde el miembro; casos felices, infelices y límites en tests espejo.

## 8. Fuentes consultadas y genealogía conceptual

Plan aprobado del sistema SEE. Las bibliotecas externas son infraestructura, nunca autoridad sobre el comportamiento de PseudoLearn.
