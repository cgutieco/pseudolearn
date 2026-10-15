# xtask

## 1. Qué es y qué no es

Tooling de verificación de pseudolearn_cli; no implementa la lógica de la CLI.

## 2. Guía operativa y ciclo de vida

Desde el workspace: `cargo test -p xtask` y `cargo xtask verify`.
Rust se fija en el archivo de cadena del workspace. No se publica.

## 3. Arquitectura y modelo del sistema

`src/` contiene las tareas operativas de la CLI; dependencias permitidas en `architecture.yaml` del workspace.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: automatizar la verificación integral de formato, linter, tests y conformidad.
Elección: subcomando `cargo xtask verify`.
Alternativa descartada: scripts de shell no portables entre plataformas.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin unsafe ni pánicos explícitos. Límites en las reglas del workspace.

## 6. Decisiones de producto que condicionan el código

La fase R4 habilita el front-end de la CLI y sus verificadores asociados.

## 7. Verificación, testing y aseguramiento de calidad

Formato, Clippy estricto, tests unitarios, verificadores mecánicos y chequeo de dependencias mediante `cargo xtask verify`.

## 8. Fuentes consultadas y genealogía conceptual

Patrón `xtask` estándar de la comunidad de Rust para automatización sin dependencias externas.
