# reference_verify

## 1. Qué es y qué no es

Verificadores del libro: ejemplos prometidos frente a ejecutados, anclas válidas y candado, anatomía por tipo de sección, paridad entre idiomas, palabras reservadas fuera de código, identificadores internos publicados, enlaces y cobertura del corpus.

Incluye los verificadores `RUTA-*` de la ruta de aprendizaje, en módulos `route_*`, y la normalización de salidas que comparte con la app.

## 2. Guía operativa y ciclo de vida

`cargo test -p reference_verify` y `cargo clippy -p reference_verify --all-targets -- -D warnings` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Importa `reference_model`, `reference_corpus` y, solo en pruebas, `reference_format`. La dirección de dependencias está en `architecture.yaml` del miembro. `src/` implementa la capa; `tests/` refleja sus módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: sin medición la especificación vuelve a desactualizarse. Elección: cada regla tiene un ID estable y un caso negativo. La paridad compara la estructura (encabezados, programas, figuras, formas, raíles y recuadros), no el texto. La regla de código en línea solo marca palabras con mayúscula fuera del inicio de frase o con mayúscula interna, para no confundir el «Si» de una oración con la palabra reservada.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml`; código en inglés sin comentarios ni `unsafe`.

## 6. Decisiones de producto que condicionan el código

La persona lectora nunca ve identificadores del corpus; ver el README del miembro.

## 7. Verificación, testing y aseguramiento de calidad

Tests espejo con camino feliz, camino infeliz y casos límite; los casos negativos de cada verificador viven en `tests/`.

## 8. Fuentes consultadas y genealogía conceptual

Plan del miembro y contrato del paquete descritos en el README del miembro.
