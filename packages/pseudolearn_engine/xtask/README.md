# xtask

## 1. Qué es y qué no es

Tooling de verificación del motor; no implementa el evaluador ni la máquina virtual de PseudoLearn.

## 2. Guía operativa y ciclo de vida

Desde el workspace: `cargo test -p xtask` y `cargo xtask verify`.
Rust se fija en el archivo de cadena del workspace. No se publica.

## 3. Arquitectura y modelo del sistema

`src/` contiene las tareas operativas del motor; dependencias permitidas en `architecture.yaml` del workspace.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: automatizar la verificación integral de formato, linter, tests y conformidad.
Elección: subcomando `cargo xtask verify`.
Alternativa descartada: scripts de shell no portables entre plataformas.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin unsafe ni pánicos explícitos. Límites en las reglas del workspace.

## 6. Decisiones de producto que condicionan el código

Habilita el front-end del motor y sus verificadores asociados.

## 7. Verificación, testing y aseguramiento de calidad

Formato, Clippy estricto, tests unitarios, verificadores mecánicos y chequeo de dependencias mediante `cargo xtask verify`.

## 8. Fuentes consultadas y genealogía conceptual

Patrón `xtask` estándar de la comunidad de Rust para automatización sin dependencias externas.
