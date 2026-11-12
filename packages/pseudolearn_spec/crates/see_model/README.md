# see_model

Las entidades de datos del sistema SEE: la especificación y sus bloques, el anclaje del corpus, la evidencia de
conformidad y las propiedades. Son estructuras serializables con `serde`; todos los demás crates las comparten.

**No hace:** leer archivos, validar reglas ni ejecutar sujetos. Solo describe la forma de los datos.

## Dónde encaja

```mermaid
flowchart BT
    serde["serde y serde_json"] --> model["crates/see_model"]
    model --> format["crates/see_format"]
    model --> graph["crates/see_graph"]
    model --> change["crates/see_change"]
    model --> validation["crates/see_validation"]
    model --> translation["crates/see_translation"]
    model --> generators["crates/see_generators"]
    model --> conformance["crates/see_conformance"]
    model --> export["crates/see_export"]
    model --> report["crates/see_report"]
    model --> cli["crates/see_cli"]
```

`see_oracles` y `xtask` no la importan.

## Arquitectura

| Módulo       | Contiene                                                                                                   |
|--------------|------------------------------------------------------------------------------------------------------------|
| `lib.rs`     | `Metadata`, `Dependency`, `Change`, `Block`, `Specification`, `Corpus`, y los lectores `field` y `strings` |
| `contract`   | `Lock` y `Anchor` (el anclaje), `Manifest` de una característica, `Vocabulary` y el prefijo `contextual:`  |
| `evidence`   | `Conformance`, `Binding`, `Observation` y `Evidence`                                                       |
| `properties` | `PropertyRun`, `Counterexample`, `PropertyRegistry`, `PropertyBinding` y `PropertyExecutor`                |

Un `Block` guarda sus campos como JSON (`BTreeMap<String, Value>`): el crate dueño de cada recurso es quien lo valida.

## Reglas que conviene saber

- No importa ningún otro crate del paquete (`may_import: []`); sus únicas dependencias externas son `serde` y
  `serde_json`.
- `Metadata`, `Dependency`, `Change`, `Lock`, `Anchor` y `Manifest` rechazan campos desconocidos al leer
  (`deny_unknown_fields`).
- `Metadata.cambio` se omite al serializar cuando no hay clasificación: bajo el congelamiento de versiones su
  presencia sería una declaración de cambio.
- La evidencia de propiedades vive en `PropertyRun`; el vínculo entre una propiedad y su algoritmo, en
  `PropertyRegistry`, que se carga de `property-conformance.json`, nunca de código.
- Sin comentarios, sin `unsafe`; 300 líneas por archivo, 40 por función, 4 parámetros posicionales y 3 niveles de
  anidación.

## Comandos útiles

Desde `packages/pseudolearn_spec`.

| Para qué                          | Comando                   |
|-----------------------------------|---------------------------|
| Tests de este crate               | `cargo test -p see_model` |
| Verificación completa del paquete | `cargo xtask verify`      |

Requisitos: Rust `1.99.0` con rustfmt y Clippy (`rust-toolchain.toml`).
