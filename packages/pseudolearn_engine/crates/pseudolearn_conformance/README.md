# pseudolearn_conformance

## 1. Qué es y qué no es

Adapta la API al protocolo de conformidad por procesos. Implementa análisis JSONL sobre la API pública. Ejecución, observación y RI siguen pendientes de sus capas.

Fuera de alcance: otras responsabilidades del motor, UI, I/O libre y construcciones nuevas.

| Pendiente | Dependencia | Fase |
|---|---|---|
| execute, observe, seek, ir y gc_stress | Capas de ejecución | R5 |

## 2. Guía operativa y ciclo de vida

Rust exacto del miembro, rustfmt y Clippy. El binario `conformance_adapter` procesa JSONL; no se despliega por separado.
La implementación se verifica desde el workspace con `cargo xtask verify` y conformidad del sujeto engine.
La comprobación disponible usa, desde la raíz del monorepo,
`cargo run --manifest-path packages/pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command -- layers packages/pseudolearn_engine`.

## 3. Arquitectura y modelo del sistema

Nivel 9. Dependencias internas permitidas: pseudolearn_api. Externas: serde, serde_json.
Prohibido importar capas superiores, paquetes de UI o internos de otros miembros.

Estructuras y algoritmos: Binario del protocolo `see-protocol/1` sobre la API, con las capacidades `analyze`, `execute`, `observe`, `ir` y `cli` (esta última a través del binario `pseudo`).

Invariantes: Solo API pública.

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: adapta la api al protocolo de conformidad por procesos respetando los observables del corpus.
Elección: Binario del protocolo `see-protocol/1` sobre la API, con las capacidades `analyze`, `execute`, `observe`, `ir` y `cli` (esta última a través del binario `pseudo`).
Alternativas descartadas y fundamento: SEE.ADAPTER.PROTOCOL define JSONL y negociación. Se rechaza importar internos del motor o declarar observe sin soportar eventos.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.
Las fuentes generadas se producen desde la exportación del corpus en OUT_DIR; nunca se copian manualmente.

## 6. Decisiones de producto que condicionan el código

Contratos: `SEE.ADAPTER.PROTOCOL`.
La ejecución y la observación conservan la misma semántica; idioma de interfaz y vocabulario son independientes.
Los identificadores del usuario, el texto original y la salida del programa se conservan.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, texto vacío, Unicode, tamaño cero, profundidad extrema y bordes numéricos.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos;
formato, Clippy, auditoría de dependencias y pruebas diferenciales según los contratos de este crate.

## 8. Fuentes consultadas y genealogía conceptual

SEE.ADAPTER.PROTOCOL define JSONL y negociación. Se rechaza importar internos del motor o declarar observe sin soportar eventos.

La robustez se ejecuta en procesos aislados por entrada, con semilla 42 y ambos perfiles y rigores.
Incluye texto vacío, trivia, NFD, Unicode arbitrario, UTF-8 inválido y anidaciones de hasta 100.000
operadores o paréntesis. Se exige proceso exitoso, stderr vacío, árbol y ausencia de fallo interno.
