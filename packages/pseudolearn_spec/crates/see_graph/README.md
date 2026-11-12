# see_graph

El grafo de dependencias entre especificaciones: comprueba que las referencias, los rangos de versión y los tipos de
arista sean válidos, detecta ciclos, calcula qué especificaciones se ven afectadas por una y dibuja el grafo.

**No hace:** leer el corpus ni decidir qué cambió. Recibe un `Corpus` ya leído.

## Dónde encaja

```mermaid
flowchart BT
    model["crates/see_model"] --> graph["crates/see_graph"]
    semver["semver"] --> graph
    graph --> validation["crates/see_validation"]
    graph --> cli["crates/see_cli"]
    format["crates/see_format"] -.-> graph
```

La línea punteada es una `dev-dependency`: `see_format` solo se usa en los tests.

## Piezas

| Función                      | Qué hace                                                                                                                                                   |
|------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `validate(corpus)`           | Devuelve errores `SEE-REFERENCE` (identidad inexistente), `SEE-RANGE` (la versión no cumple el rango), `SEE-GRAPH` (tipo de arista inválido) y `SEE-CYCLE` |
| `impact(corpus, id)`         | Cierre de las especificaciones que dependen, directa o indirectamente, de `id`, incluida ella                                                              |
| `render(corpus, focus, dot)` | Lista de aristas en texto o en DOT; con `focus`, solo el cierre de impacto de esa especificación                                                           |

Los tipos de arista válidos son `usa`, `refina`, `restringe`, `requiere`, `verifica` y `reemplaza`. El cierre y la
detección de ciclos son iterativos, sin recursión.

## Reglas que conviene saber

- Solo importa `see_model` (`may_import` en `architecture.yaml`); su única dependencia externa es `semver`.
- Los errores salen como texto con un código estable al principio; `see_validation` los reúne con los demás.
- Sin comentarios, sin `unsafe`; 300 líneas por archivo, 40 por función, 4 parámetros posicionales y 3 niveles de
  anidación.

## Comandos útiles

Desde `packages/pseudolearn_spec`.

| Para qué                             | Comando                                                        |
|--------------------------------------|----------------------------------------------------------------|
| Tests de este crate                  | `cargo test -p see_graph`                                      |
| Ver el grafo del corpus              | `cargo run -p see_cli --bin see -- graph [--focus ID] [--dot]` |
| Ver el impacto de una especificación | `cargo run -p see_cli --bin see -- impact ID`                  |
| Verificación completa del paquete    | `cargo xtask verify`                                           |

Requisitos: Rust `1.99.0` con rustfmt y Clippy (`rust-toolchain.toml`).
