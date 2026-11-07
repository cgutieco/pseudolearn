# xtask

## 1. Qué es y qué no es

Puerta `cargo xtask verify` del miembro. No contiene lógica del compilador.

## 2. Guía operativa y ciclo de vida

`cargo xtask verify` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Sin imports de crates del producto: ejecuta órdenes por proceso con la biblioteca estándar.

## 4. Decisiones de diseño y fundamentos técnicos

Regenera la exportación del corpus antes de verificar porque `export.json` no se versiona; después ejecuta formato, Clippy, tests, cargo-deny, los verificadores Rust del monorepo y `reference check`.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml` del miembro.

## 6. Decisiones de producto que condicionan el código

Ninguna.

## 7. Verificación, testing y aseguramiento de calidad

Tests de la lista de órdenes en `src/main_tests.rs`.

## 8. Fuentes consultadas y genealogía conceptual

Convención xtask de Cargo, igual que el resto de miembros Rust.
