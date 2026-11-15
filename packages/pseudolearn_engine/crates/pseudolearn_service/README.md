# pseudolearn_service

Herramientas de edición del lenguaje: sesión de documento con edición por rango y análisis incremental, sesión
persistente de proyecto con superposiciones, autocompletado (incluidas plantillas con paradas navegables), hover y ayuda
de firma, navegación (definición, referencias, símbolos, resaltado), renombrado, formateador, escritura asistida,
traducción del código entre los perfiles `es` y `en`, ayuda del lenguaje y un servidor LSP (`LspServer`) que las expone
por mensajes JSON. Todo resultado se deriva de la gramática, el vocabulario y el análisis semántico, sin heurísticas
externas.

**No hace:** ejecutar programas, leer el disco (recibe documentos y manifiestos ya cargados) ni dibujar interfaz.

## Dónde encaja

```mermaid
flowchart BT
    SPEC["Corpus exportado<br/>packages/pseudolearn_spec"]
    SRC["source<br/>crates/pseudolearn_source"]
    DIA["diagnostics<br/>crates/pseudolearn_diagnostics"]
    LEX["lexicon<br/>crates/pseudolearn_lexicon"]
    SYN["syntax<br/>crates/pseudolearn_syntax"]
    SEM["semantic<br/>crates/pseudolearn_semantic"]
    PRJ["project<br/>crates/pseudolearn_project"]
    SVC["<b>pseudolearn_service</b><br/>crates/pseudolearn_service"]

    subgraph USERS["Lo usan"]
        CONF["conformance"]
        API["api"]
    end

    SPEC -->|" build.rs (ayuda) "| SVC
    SRC & DIA & LEX & SYN & SEM & PRJ --> SVC
    SVC --> CONF & API
```

## Arquitectura

Importa `source`, `diagnostics`, `lexicon`, `syntax`, `semantic` y `project`; las externas son `serde` y `serde_json`.
`build.rs` genera las fichas de ayuda (`generated_help_cards.rs`) desde `helpCatalog` del corpus, incluidas desde
`help_catalog.rs`.

| Grupo                   | Archivos                                                                            | Responsabilidad                                                                                             |
|-------------------------|-------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| Documento               | `document_session`, `edit_session`, `edit_probe`, `unit_partition`, `node_identity` | `DocumentSession`, edición por rango, huellas por unidad e identidad de nodos                               |
| Proyecto                | `workspace_*`                                                                       | `WorkspaceSession`, snapshot, invalidación e índice del proyecto                                            |
| Completado y plantillas | `completion*`, `template_*`, `insertion`                                            | `complete_at_position`, plantillas con paradas y su inserción                                               |
| Consultas               | `hover`, `navigation`, `symbol_*`, `cursor_context`, `query_context`                | Hover, ayuda de firma, símbolos, resaltado y contexto de cursor                                             |
| Escritura               | `formatter`, `on_type*`, `typing_*`, `block_*`, `translator`                        | `format_source`, `on_type` y `translate_source`                                                             |
| Ayuda                   | `help_*`                                                                            | `help_content`, `resolve_help_at_position` y `render_help`                                                  |
| LSP                     | `lsp_*`, `request_cancellation`                                                     | `LspServer::handle_message`, configuración, renombrado, tokens semánticos y símbolos del espacio de trabajo |

## Flujo principal

Flujo de datos, no dependencias.

```mermaid
flowchart LR
    MSG["mensaje LSP (JSON)"] --> SRV["LspServer"]
    SRV --> DOC["DocumentSession"]
    SRV --> WS["WorkspaceSession"]
    DOC & WS --> ANA["syntax + semantic"]
    ANA --> Q["completado, hover, navegación, diagnósticos"]
    Q --> REP["respuesta LSP (JSON)"]
```

## Reglas que conviene saber

- Solo importa las capas de análisis (`source` a `project`); no depende de `lowering`, de la VM ni de `api`.
- No lee el disco: quien la llama entrega el snapshot completo y el contenido de manifiestos y bloqueos.
- Una solicitud LSP puede cancelarse (`handle_cancellable_message`, `RequestCancellation`).
- La traducción entre perfiles falla con `TranslationError::Collision` si un nombre del usuario coincide con una
  palabra reservada o con una producida por la propia traducción, en lugar de renombrarlo.
- Sin `unsafe`; la salida es determinista.

## Comandos útiles

| Para qué                        | Comando                                                                                        |
|---------------------------------|------------------------------------------------------------------------------------------------|
| Tests del crate                 | `cargo test -p pseudolearn_service`                                                            |
| Conformidad de las herramientas | `cargo run -p see_cli --bin see -- conform --subject service` (en `packages/pseudolearn_spec`) |
| Verificación completa           | `cargo xtask verify`                                                                           |

Se ejecutan desde `packages/pseudolearn_engine`, salvo la conformidad.
