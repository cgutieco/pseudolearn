# see_export

## 1. Qué es y qué no es

Emite see-export/1 con contratos, hashes e índices por área. La exportación contiene estado y versión para que cada consumidor seleccione los contratos aplicables.

## 2. Guía operativa y ciclo de vida

`cargo test -p see_export`; `cargo check -p see_export` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Imports internos permitidos: model, change. Prohibidas las capas superiores y los sujetos. `src/` implementa la capa; `tests/` refleja módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Extrae recursos normativos del campo valor de definiciones: vocabulario, firmas, fichas de diagnósticos, gramática y `helpCatalog`. Los incorpora a see-export/1; la CLI materializa el vocabulario consumidor y los catálogos derivados. Rechaza recursos duplicados. El vocabulario consumidor incluye alias por idioma; function: distingue nombres de funciones de tokens reservados, para preservar variables homónimas. El catálogo mantiene sus identidades, anclajes y contenido bilingüe en un único recurso; sus referencias a formas y esperados no copian el vocabulario ni los casos.

Problema: responsabilidades independientes. Elección: crate por capa con contratos tipados.
Se descarta importar sujetos o capas superiores para preservar la dirección.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml` del miembro; código inglés sin comentarios ni unsafe.

## 6. Decisiones de producto que condicionan el código

El sistema especifica y contrasta el lenguaje vigente. Ninguna lógica del motor vive aquí.

## 7. Verificación, testing y aseguramiento de calidad

`cargo xtask verify` desde el miembro; casos felices, infelices y límites en tests espejo.

## 8. Fuentes consultadas y genealogía conceptual

Plan aprobado del sistema SEE. Las bibliotecas externas son infraestructura, nunca autoridad sobre el comportamiento de PseudoLearn.
