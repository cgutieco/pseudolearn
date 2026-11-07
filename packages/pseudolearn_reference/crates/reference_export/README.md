# reference_export

## 1. Qué es y qué no es

Arma el paquete por edición: `toc.json`, `sections/<id>.json`, `search.json`, `links.json` y `manifest.json` con la huella de cada archivo. La serialización es determinista para que el paquete sea reproducible bit a bit.

## 2. Guía operativa y ciclo de vida

`cargo test -p reference_export` y `cargo clippy -p reference_export --all-targets -- -D warnings` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Importa `reference_model`; usa `serde_json` y `sha2`. La dirección de dependencias está en `architecture.yaml` del miembro. `src/` implementa la capa; `tests/` refleja sus módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: la app y la web no deben interpretar el corpus. Elección: `links.json` resuelve de antemano qué sección explica cada ficha de ayuda y cada diagnóstico; las anclas del corpus nunca viajan.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml`; código en inglés sin comentarios ni `unsafe`.

## 6. Decisiones de producto que condicionan el código

La persona lectora nunca ve identificadores del corpus; ver el README del miembro.

## 7. Verificación, testing y aseguramiento de calidad

Tests espejo con camino feliz, camino infeliz y casos límite; los casos negativos de cada verificador viven en `tests/`.

## 8. Fuentes consultadas y genealogía conceptual

Plan del miembro y contrato del paquete descritos en el README del miembro.
