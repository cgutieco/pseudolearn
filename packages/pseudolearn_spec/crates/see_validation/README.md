# see_validation

La integridad del corpus: comprueba que las especificaciones respeten el esquema, que sus referencias, estados y
versiones sean coherentes, que cada regla tenga cobertura y que los recursos normativos (vocabulario, gramática,
catálogos) estén bien formados. Todo error sale como texto con un código `SEE-*`.

**No hace:** leer archivos ni ejecutar sujetos. Recibe el `Corpus` y el anclaje (`Lock`) ya cargados.

## Dónde encaja

```mermaid
flowchart BT
    model["crates/see_model"] --> validation["crates/see_validation"]
    graph["crates/see_graph"] --> validation
    change["crates/see_change"] --> validation
    semver["semver y serde_json"] --> validation
    validation --> cli["crates/see_cli"]
    format["crates/see_format"] -.-> validation
```

La línea punteada es una `dev-dependency`: `see_format` solo se usa en los tests.

## Arquitectura

```mermaid
flowchart BT
    identity & schema & references --> validate
    lifecycle --> validate
    coverage & measurement & expectations --> validate
    trace & cli & resources --> validate
    graph["see_graph"] --> validate
    change["see_change"] --> validate
```

`validate(corpus, lock)` reúne los errores de todas esas piezas, los ordena y quita duplicados. `see_cli` invoca
además, fuera de `validate`, las comprobaciones de `bindings`, `migration`, `property_registry` y `schema_engine`.

| Módulo                                | Qué comprueba                                                                                                                                                       |
|---------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `identity`                            | Formato de la identidad y duplicados (`SEE-IDENTITY`, `SEE-DUPLICATE`)                                                                                              |
| `schema`                              | Metadatos completos, versión semántica, dominio y campos de cada tipo de bloque (`SEE-SCHEMA`, `SEE-VERSION`, `SEE-PROFILE`, `SEE-FORCE`, `SEE-ORIGIN`)             |
| `schema_engine`                       | Validador de JSON Schema; `see_cli` lo usa para `property-conformance.json`                                                                                         |
| `references`                          | Referencias entre bloques, huérfanos y cobertura de errores (`SEE-REFERENCE`, `SEE-ORPHAN`, `SEE-ERROR-COVERAGE`) y revisión de capturas (`SEE-CAPTURE`)            |
| `lifecycle`                           | Estados, transiciones, versión, edición y clasificación (`SEE-STATE`, `SEE-VERSION`, `SEE-EDITION`, `SEE-CLASSIFICATION`)                                           |
| `coverage`                            | Una entrada de cobertura de RI por regla que la exige (`SEE-IR-COVERAGE`, `SEE-IR-UNKNOWN`)                                                                         |
| `measurement`, `expectations`         | Protocolo de mediciones (`SEE-MEASUREMENT-*`) y expectativas de los casos (`SEE-IR-EXPECTATION`, `SEE-LIMIT-KIND`)                                                  |
| `trace`, `cli`, `messages`, `openers` | Alfabeto de trazas, convenciones y mensajes de la CLI, y aperturas de bloque por perfil (`SEE-TRACE-CLASS`, `SEE-CLI-EXIT`, `SEE-MESSAGE-*`, `SEE-PROFILE-OPENERS`) |
| `resources/*`                         | Gramática, léxico, gramática TextMate, límites de análisis, términos de diagnóstico, catálogo de ayuda, biblioteca y neutralidad del español                        |
| `bindings`                            | Vínculos regla–código de un sujeto contra el corpus (`SEE-BINDING`, `SEE-SUBJECT-STATE`)                                                                            |
| `migration`                           | Correspondencia entre las secciones del manifiesto de migración, su índice y el corpus (`SEE-COVERAGE`)                                                             |
| `property_registry`                   | Registro de propiedades contra el corpus (`SEE-PROPERTY`)                                                                                                           |
| `host_cases`                          | Casos de anfitrión dentro de `schema` (`SEE-HOST`)                                                                                                                  |

## Reglas que conviene saber

- Importa `see_model`, `see_graph` y `see_change`; `see_format` solo en tests. Dependencias externas: `semver` y
  `serde_json`.
- Todo error lleva un código `SEE-*` estable al principio del mensaje.
- Los datos de los recursos viven en el corpus; este crate solo los valida.
- Sin comentarios, sin `unsafe`; 300 líneas por archivo, 40 por función, 4 parámetros posicionales y 3 niveles de
  anidación.

## Comandos útiles

Desde `packages/pseudolearn_spec`.

| Para qué                          | Comando                                      |
|-----------------------------------|----------------------------------------------|
| Tests de este crate               | `cargo test -p see_validation`               |
| Validar el corpus                 | `cargo run -p see_cli --bin see -- validate` |
| Verificación completa del paquete | `cargo xtask verify`                         |

Requisitos: Rust `1.99.1` con rustfmt y Clippy (`rust-toolchain.toml`).
