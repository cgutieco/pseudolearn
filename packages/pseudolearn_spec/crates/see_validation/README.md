# see_validation

## 1. Qué es y qué no es

Aplica esquema, identidad, referencias, ciclo de vida, clasificación, hashes y vínculos. El ciclo de vida mantiene congelados estado y versión, salvo la promoción inicial de contratos estables a 1.0.0; las ediciones oficiales de igual versión se reanclan durante este régimen. El esquema JSON versionado usa únicamente type, required, properties, additionalProperties, enum, const, minLength, minimum, minItems, uniqueItems, items, $ref, anyOf y oneOf; el evaluador limita su profundidad. No anuncia soporte general de JSON Schema.

## 2. Guía operativa y ciclo de vida

`cargo test -p see_validation`; `cargo check -p see_validation` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Imports internos permitidos: model, graph, change. Prohibidas las capas superiores y los sujetos. `src/` implementa la capa; `tests/` refleja módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Las definiciones admiten valor como objeto normativo. Los casos admiten semilla opcional de entero; las fichas bilingües y las firmas se verifican estructuralmente, sin presentar esta revisión como ejecución de reference.

Problema: responsabilidades independientes. Elección: crate por capa con contratos tipados.
Se descarta importar sujetos o capas superiores para preservar la dirección.

Problema: el límite portable de análisis debe llegar a los consumidores como dato validado.
Elección: `analysisLimits` contiene un único campo `nesting`, entero positivo representable en u32.
La exportación conserva el recurso y los generadores lo consumen. Se rechaza fijarlo otra vez en el parser
y se rechazan campos desconocidos o valores cero, negativos, fraccionarios y fuera de rango.

El recurso `unsupportedConstructs` valida aperturas, cierres, diagnóstico y forma de apertura.
Son datos no reservados; el parser solo reconoce su posición estructural.

La conformidad de propiedades se valida contra su esquema propio y el corpus: referencia exacta a una
propiedad vigente, unicidad, semilla u64 y muestras positivas. Los contraejemplos no se convierten en
casos esperados. Una propiedad sin ejecutor no se declara cumplida.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml` del miembro; código inglés sin comentarios ni unsafe.

## 6. Decisiones de producto que condicionan el código

El sistema especifica y contrasta el lenguaje vigente. Ninguna lógica del motor vive aquí.

## 7. Verificación, testing y aseguramiento de calidad

`cargo xtask verify` desde el miembro; casos felices, infelices y límites en tests espejo.

## 8. Fuentes consultadas y genealogía conceptual

Plan aprobado del sistema SEE. Las bibliotecas externas son infraestructura, nunca autoridad sobre el comportamiento de PseudoLearn.

El esquema admite `cancelacion_prueba` como ordinal entero no negativo de un sondeo.
El campo no se interpreta como un presupuesto de sentencias y se rechazan tipos y signos inválidos.
