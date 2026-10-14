# pseudolearn_syntax

## 1. Qué es y qué no es

Construye un árbol sintáctico sin pérdida para cualquier texto. Contrato documentado, sin implementación ni manifiesto Cargo.

Fuera de alcance: otras responsabilidades del motor, UI, I/O libre y construcciones nuevas.

| Pendiente | Dependencia | Fase |
|---|---|---|
| Implementación y tests del crate | Corpus validado y capas inferiores | R4 |

## 2. Guía operativa y ciclo de vida

Rust exacto del miembro, rustfmt y Clippy. No hay binario, build ni despliegue disponible.
La implementación se verifica desde el workspace con `cargo xtask verify` y conformidad del sujeto engine.
La comprobación disponible usa, desde la raíz del monorepo,
`cargo run --manifest-path packages/pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command -- layers packages/pseudolearn_engine`.

## 3. Arquitectura y modelo del sistema

Nivel 2. Dependencias internas permitidas: pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon. Externas: biblioteca estándar.
Prohibido importar capas superiores, paquetes de UI o internos de otros miembros.

Estructuras y algoritmos: Lexer por tabla de 256 clases de byte; tokens en columnas (`kinds: Vec<TokenKind>`, `starts: Vec<u32>`) con la trivia como tokens; parser de descenso recursivo con recuperación por conjuntos de sincronización; **árbol postorden** `Node { kind: u16, first_token: u32, subtree_size: u32 }`; vistas tipadas generadas de `LANG.SYNTAX.GRAMMAR`.

Invariantes: Reimprimir los tokens da el texto exacto; todo texto produce árbol; recursión del parser acotada por la profundidad de anidación, con diagnóstico, sin agotar la pila.

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: construye un árbol sintáctico sin pérdida para cualquier texto respetando los observables del corpus.
Elección: Lexer por tabla de 256 clases de byte; tokens en columnas (`kinds: Vec<TokenKind>`, `starts: Vec<u32>`) con la trivia como tokens; parser de descenso recursivo con recuperación por conjuntos de sincronización; **árbol postorden** `Node { kind: u16, first_token: u32, subtree_size: u32 }`; vistas tipadas generadas de `LANG.SYNTAX.GRAMMAR`.
Alternativas descartadas y fundamento: Carbon y Zig inspiran tokens en columnas y postorden; se rechaza el árbol verde/rojo rowan por asignaciones e indirecciones. El descenso recursivo facilita recuperación explícita; se descartan LALR y PEG para mantener sus decisiones visibles.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.
Las fuentes generadas se producen desde la exportación del corpus en OUT_DIR; nunca se copian manualmente.

## 6. Decisiones de producto que condicionan el código

Contratos: `LANG.LEXICAL.*`, `LANG.SYNTAX.*`, `TOOL.SERVICE.LOSSLESS-TREE`.
La ejecución y la observación conservan la misma semántica; idioma de interfaz y vocabulario son independientes.
Los identificadores del usuario, el texto original y la salida del programa se conservan.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, texto vacío, Unicode, tamaño cero, profundidad extrema y bordes numéricos.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos;
formato, Clippy, auditoría de dependencias y pruebas diferenciales según los contratos de este crate.

## 8. Fuentes consultadas y genealogía conceptual

Carbon y Zig inspiran tokens en columnas y postorden; se rechaza el árbol verde/rojo rowan por asignaciones e indirecciones. El descenso recursivo facilita recuperación explícita; se descartan LALR y PEG para mantener sus decisiones visibles.
