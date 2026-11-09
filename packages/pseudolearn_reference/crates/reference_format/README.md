# reference_format

## 1. Qué es y qué no es

Lector del Markdown con directivas: cabecera YAML, encabezados con identificador, párrafos, listas, tablas, recuadros `:::` y bloques cercados (`forma`, `anatomia`, `programa`, `salida`, `diagnosticos`, `entrada`, `anfitrion`, `figura`, `ri`, `traza`, `generado`). Devuelve un `SourceDocument` o una violación `REF-FORMAT`.

Lee también las lecciones y los ejercicios de la ruta: encabezados de fase, recuadros con atributos, definiciones de término, enlaces `especificacion:` y `ruta:` y las cercas de datos de ejercicio.

## 2. Guía operativa y ciclo de vida

`cargo test -p reference_format` y `cargo clippy -p reference_format --all-targets -- -D warnings` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Importa `reference_model`; usa `serde-saphyr` para la cabecera. La dirección de dependencias está en `architecture.yaml` del miembro. `src/` implementa la capa; `tests/` refleja sus módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: un analizador CommonMark completo acepta construcciones que el paquete no sabe publicar. Elección: un lector propio y cerrado que rechaza lo desconocido con `REF-FORMAT`. Las promesas (`salida`, `diagnosticos`, `entrada`, `anfitrion`) se pegan al programa anterior del mismo recuadro. Los opcionales de una forma se marcan con `⟦…⟧` porque `[` es sintaxis real de arreglos. Se descartó `pulldown-cmark` porque obligaría a reinterpretar su árbol y a mantener una lista de exclusiones.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml`; código en inglés sin comentarios ni `unsafe`.

## 6. Decisiones de producto que condicionan el código

La persona lectora nunca ve identificadores del corpus; ver el README del miembro.

## 7. Verificación, testing y aseguramiento de calidad

Tests espejo con camino feliz, camino infeliz y casos límite; los casos negativos de cada verificador viven en `tests/`.

## 8. Fuentes consultadas y genealogía conceptual

Plan del miembro y contrato del paquete descritos en el README del miembro.
