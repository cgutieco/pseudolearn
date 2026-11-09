# reference_figures

## 1. Qué es y qué no es

Contrato y producción de figuras SVG: elementos y atributos permitidos, colores solo por rol con centinelas, familias `sans`/`mono`, textos solo desde cadenas, lexemas o fragmentos de código, `viewBox` de 340 de ancho y letra de 12 o más. Expande las piezas del kit (`caja`, `flecha`) y separa los grupos por paso en capas.

## 2. Guía operativa y ciclo de vida

`cargo test -p reference_figures` y `cargo clippy -p reference_figures --all-targets -- -D warnings` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Importa `reference_model`; usa `roxmltree`. La dirección de dependencias está en `architecture.yaml` del miembro. `src/` implementa la capa; `tests/` refleja sus módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: Flutter (`flutter_svg`) no admite `marker`, CSS ni `dominant-baseline`. Elección: el contrato los prohíbe y el kit dibuja las puntas de flecha como polígonos. Las capas por paso viajan aparte y el consumidor las añade antes de `</svg>`; publicar un SVG completo por paso multiplicaba el paquete por cinco.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml`; código en inglés sin comentarios ni `unsafe`.

## 6. Decisiones de producto que condicionan el código

La persona lectora nunca ve identificadores del corpus; ver el README del miembro.

## 7. Verificación, testing y aseguramiento de calidad

Tests espejo con camino feliz, camino infeliz y casos límite; los casos negativos de cada verificador viven en `tests/`.

## 8. Fuentes consultadas y genealogía conceptual

Plan del miembro y contrato del paquete descritos en el README del miembro.
