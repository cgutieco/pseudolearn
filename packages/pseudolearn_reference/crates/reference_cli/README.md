# reference_cli

## 1. Qué es y qué no es

Binario `reference` con las órdenes `build`, `check`, `coverage` y `lock`.

## 2. Guía operativa y ciclo de vida

`cargo test -p reference_cli` y `cargo clippy -p reference_cli --all-targets -- -D warnings` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Importa todas las capas; es la única que lee y escribe archivos. La dirección de dependencias está en `architecture.yaml` del miembro. `src/` implementa la capa; `tests/` refleja sus módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: una construcción que publica contenido sin verificar repite el estado anterior. Elección: `build` solo escribe si no hay violaciones; `--borrador` existe para redactar y nunca se usa en verificación.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml`; código en inglés sin comentarios ni `unsafe`.

## 6. Decisiones de producto que condicionan el código

La persona lectora nunca ve identificadores del corpus; ver el README del miembro.

## 7. Verificación, testing y aseguramiento de calidad

Tests espejo con camino feliz, camino infeliz y casos límite; los casos negativos de cada verificador viven en `tests/`.

## 8. Fuentes consultadas y genealogía conceptual

Plan del miembro y contrato del paquete descritos en el README del miembro.
