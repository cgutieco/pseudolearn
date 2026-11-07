# reference_engine

## 1. Qué es y qué no es

Adaptador del puerto `CodeEngine` sobre `pseudolearn_api`: tokeniza con `execute_analyze`, traduce con `translate_source`, ejecuta con `execute_program` y semilla fija 42, baja a representación intermedia con `compile_source_to_ir` y rinde cada diagnóstico en español e inglés con `render_diagnostic`.

## 2. Guía operativa y ciclo de vida

`cargo test -p reference_engine` y `cargo clippy -p reference_engine --all-targets -- -D warnings` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Importa `reference_model` y, por ruta, `pseudolearn_api` con la característica `test-host`. La dirección de dependencias está en `architecture.yaml` del miembro. `src/` implementa la capa; `tests/` refleja sus módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: los ejemplos de archivos, red y tiempo necesitan un anfitrión determinista. Elección: `test-host` sustituye el anfitrión real por el de memoria del motor, configurable con el bloque `anfitrion`; el compilador es una herramienta de construcción y nunca se distribuye, por eso no entra en la regla de aislamiento de productos. Las columnas del motor son escalares Unicode y se convierten a desplazamientos de carácter.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml`; código en inglés sin comentarios ni `unsafe`.

## 6. Decisiones de producto que condicionan el código

La persona lectora nunca ve identificadores del corpus; ver el README del miembro.

## 7. Verificación, testing y aseguramiento de calidad

Tests espejo con camino feliz, camino infeliz y casos límite; los casos negativos de cada verificador viven en `tests/`.

## 8. Fuentes consultadas y genealogía conceptual

Plan del miembro y contrato del paquete descritos en el README del miembro.
