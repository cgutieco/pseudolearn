# pseudolearn_check_model

## 1. Qué es y qué no es

Capa model del verificador; no implementa el motor PseudoLearn.

## 2. Guía operativa y ciclo de vida

Desde el workspace: `cargo test -p pseudolearn_check_model` y `cargo xtask verify`.
Rust se fija en el archivo de cadena del workspace. No se publica.

## 3. Arquitectura y modelo del sistema

`src/` contiene esta capa; `tests/` refleja módulos públicos. Dependencias permitidas en
`architecture.yaml` del workspace. Ningún import hacia capas externas no declaradas.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: separar contratos de infraestructura. Elección: crate independiente para model.
Alternativa descartada: crate monolítico que permita saltarse las fronteras al importar módulos.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés, cero comentarios, sin unsafe ni pánicos explícitos. Límites en las reglas del workspace.

## 6. Decisiones de producto que condicionan el código

La fase R0 habilita verificadores, sin código del motor ni del sistema see.

## 7. Verificación, testing y aseguramiento de calidad

Tests válidos e inválidos, formato, Clippy y verificadores mediante `cargo xtask verify`.

## 8. Fuentes consultadas y genealogía conceptual

Cargo define la frontera de compilación; la política de capas pertenece a PseudoLearn.
