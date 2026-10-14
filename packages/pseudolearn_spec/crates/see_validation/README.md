# see_validation

## 1. Qué es y qué no es

Aplica esquema, identidad, referencias, ciclo de vida, clasificación, hashes y vínculos. El esquema JSON versionado usa únicamente type, required, properties, additionalProperties, enum, const, minLength, minimum, minItems, uniqueItems, items, $ref, anyOf y oneOf; el evaluador limita su profundidad. No anuncia soporte general de JSON Schema.

## 2. Guía operativa y ciclo de vida

`cargo test -p see_validation`; `cargo check -p see_validation` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Imports internos permitidos: model, graph, change. Prohibidas las capas superiores y los sujetos. `src/` implementa la capa; `tests/` refleja módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Las definiciones admiten valor como objeto normativo. Los casos admiten semilla opcional de entero; las fichas bilingües y las firmas se verifican estructuralmente, sin presentar esta revisión como ejecución de reference.

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
