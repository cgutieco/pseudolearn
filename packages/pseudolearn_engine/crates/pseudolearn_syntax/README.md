# pseudolearn_syntax

## 1. Qué es y qué no es

Construye un árbol sintáctico sin pérdida para cualquier texto. La implementación conserva tokens y nodos en columnas.

Fuera de alcance: otras responsabilidades del motor, UI, I/O libre y construcciones nuevas.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Extensiones de ejecución ajenas a sintaxis | Consumidores superiores | Motor de ejecución |

## 2. Guía operativa y ciclo de vida

Rust exacto del miembro, rustfmt y Clippy. Biblioteca del workspace; no se despliega por separado.
La implementación se verifica desde el workspace con `cargo xtask verify` y conformidad del sujeto engine.
La comprobación disponible usa, desde la raíz del monorepo,
`cargo run --manifest-path packages/pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command -- layers packages/pseudolearn_engine`.

## 3. Arquitectura y modelo del sistema

Nivel 2. Dependencias internas permitidas: pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon. Externas: biblioteca estándar y serde_json exclusivamente para generación durante el build.
Prohibido importar capas superiores, paquetes de UI o internos de otros miembros.

Estructuras y algoritmos: Lexer con avance UTF-8 y reconocimiento ASCII; tokens en columnas (`kinds: Vec<TokenKind>`, `starts: Vec<u32>`) con la trivia como tokens; parser de descenso recursivo con recuperación por conjuntos de sincronización; **árbol postorden** `Node { kind: u16, first_token: u32, subtree_size: u32 }`; vistas tipadas generadas de `LANG.SYNTAX.GRAMMAR`.

Invariantes: Reimprimir los tokens da el texto exacto; todo texto produce árbol; recursión del parser acotada por la profundidad de anidación, con diagnóstico, sin agotar la pila.

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: construye un árbol sintáctico sin pérdida para cualquier texto respetando los observables del corpus.
Elección: Lexer con avance UTF-8 y reconocimiento ASCII; tokens en columnas (`kinds: Vec<TokenKind>`, `starts: Vec<u32>`) con la trivia como tokens; parser de descenso recursivo con recuperación por conjuntos de sincronización; **árbol postorden** `Node { kind: u16, first_token: u32, subtree_size: u32 }`; vistas tipadas generadas de `LANG.SYNTAX.GRAMMAR`.
Alternativas descartadas y fundamento: Carbon y Zig inspiran tokens en columnas y postorden; se rechaza el árbol verde/rojo rowan por asignaciones e indirecciones. El descenso recursivo facilita recuperación explícita; se descartan LALR y PEG para mantener sus decisiones visibles.


Problema: los consumidores necesitan distinguir producciones sin mantener un segundo catálogo manual.
Elección: `build.rs` valida el subconjunto EBNF del recurso `grammar` y genera `NodeKind`, vistas
inmutables tipadas y acceso a las producciones hijas; las identidades se derivan de las producciones
y de los terminales. El generador rechaza referencias sin resolver, delimitadores sin pareja y
producciones vacías. `ErrorNode` es el único nodo sintético de recuperación. `analysisLimits` aporta
la cota del análisis, sin una segunda constante escrita a mano.
El recurso `unsupportedConstructs` genera las formas pedagógicas no reservadas; se reconocen solo
en cabeceras estructurales, nunca al asignar o llamar un identificador homónimo.
El árbol postorden mantiene `SyntaxNode { kind, first_token, subtree_size }`; las columnas laterales
conservan el último token, el token de operador y los intervalos de hijos directos. El recorrido de
hijos conserva el orden de fuente sin reservar memoria por recorrido. El nodo es un dato sin métodos.
El parser es dueño exclusivo de la estructura; semántica recibe vistas y no reinterpreta texto como gramática.
Cada contexto conserva apertura, cierre y sincronización. Un fallo se recupera una vez por sentencia;
se informa solo el cierre interior pendiente, con su apertura relacionada. El lexer conserva el fragmento
inválido como trivia de error y la semántica no corre cuando léxico o sintaxis contienen errores.
Alternativas descartadas: enum manual, árboles enlazados, recorridos que reconstruyen hijos en cada visita
y constantes de límites duplicadas.

El reconocimiento estructural de construcciones excluidas se aplica también fuera de unidades y en miembros de clase. Una lista de superclases produce el diagnóstico específico en la coma, sin aceptar herencia múltiple ni reservar nombres nuevos.

Problema: un archivo de proyecto es un módulo y no exige un algoritmo, mientras que el texto suelto conserva
su contrato. Elección: el analizador tiene un modo de proyecto (`parse_module_source`) que acepta cero
algoritmos, `Importar` y `Exportar` antes de las unidades y los prefijos `Publico`/`Privado` en subprogramas
y clases; en el modo suelto esas formas se analizan igual pero producen `moduleSyntaxOutsideProject`, de modo
que ningún programa válido existente cambia de resultado. El nodo de una unidad con prefijo empieza en el
prefijo, de forma que semantic lee la visibilidad del primer token sin recorrer los miembros de la clase.
Se rechaza un segundo analizador de módulos, porque duplicaría la recuperación de errores, y los comodines:
tras un punto de la ruta se exige un nombre (`expectedModuleName`).

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

El esquema de unidades se extrae de los hijos directos de la raíz y centraliza nombres, tipos de retorno,
parámetros, modo de paso y tramos completos. La API convierte ese esquema sin repetir la extracción.
El reconocimiento de palabras compuestas pertenece a `compound_scanner.rs`; nunca cruza una línea.
