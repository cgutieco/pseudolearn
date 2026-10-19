# pseudolearn_service

## 1. Qué es y qué no es

Proporciona los servicios de lenguaje, sesiones de documentos, análisis incremental, autocompletado, navegación, información contextual, formateador canónico, traductor bidireccional de código y servidor LSP.

Fuera de alcance: ejecución del motor, máquinas virtuales, interfaz de línea de comandos de usuario final o interfaces gráficas.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Extensiones de refactorización semántica avanzada | HIR completo | Herramientas avanzadas |

## 2. Guía operativa y ciclo de vida

Rust exacto del miembro, rustfmt y Clippy. Biblioteca del workspace; no se despliega por separado.
La implementación se verifica desde el workspace con `cargo xtask verify` y conformidad de los sujetos service y cli.
La comprobación disponible usa, desde la raíz del monorepo,
`cargo run --manifest-path packages/pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command -- layers packages/pseudolearn_engine`.

## 3. Arquitectura y modelo del sistema

Nivel 4. Dependencias internas permitidas: pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic. Externas: biblioteca estándar, serde y serde_json.
Prohibido importar capas de ejecución, máquina virtual, AOT o CLI.

Estructuras y algoritmos: Identidades estables de nodos sintácticos (`SyntaxNodeId`), partición en huellas de unidad (`UnitFingerprint`) para reutilización incremental de AST y análisis semántico, motor de autocompletado con clasificación contextual de cursor, formateador canónico preservando comentarios y espacios en blanco originales, traductor bidireccional con tabla de equivalencias y detección de colisiones, y bucle de mensajes JSON-RPC 2.0 para LSP.

Invariantes: El formateador es idempotente sobre código ya formateado; el traductor preserva la semántica exacta del algoritmo y reporta colisiones sin emitir código ambiguo; las consultas de navegación y completado nunca entran en pánico ante posiciones fuera de rango.

Ejecución síncrona determinista para todas las operaciones de lenguaje y formato.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: proveer servicios de lenguaje reactivos y con baja latencia sin reanalizar el documento completo ante ediciones locales.
Elección: partición de unidades en firmas y cuerpos. Si la edición sólo altera el cuerpo de una función o subprograma sin cambiar su firma, se reutilizan las firmas de las demás unidades y se actualiza únicamente el cuerpo editado.
Alternativas descartadas: reanálisis completo en cada pulsación de tecla o árboles sintácticos con punteros mutables.

Problema: formateo canónico uniforme sin pérdida de comentarios.
Elección: recorrido estructurado del árbol sintáctico asociando comentarios y trivia a los nodos correspondientes, aplicando sangrías fijas de dos espacios y normalizando operadores y palabras clave.
Alternativas descartadas: formateo puramente léxico que descompone expresiones complejas o reescritura que descarta comentarios.

Problema: traducción bidireccional precisa entre español e inglés.
Elección: mapeo de palabras clave y funciones incorporadas con detección previa de colisiones de identificadores. Si un identificador de usuario coincide con una palabra clave en el idioma de destino, se rechaza la traducción para prevenir ambigüedad semántica.
Alternativas descartadas: sustitución ciega de texto mediante expresiones regulares.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result o estructuras de diagnóstico. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.

## 6. Decisiones de producto que condicionan el código

Contratos: `TOOL.SERVICE.*`, `TOOL.FORMAT.*`, `TOOL.TRANSLATE.*`, `TOOL.LSP.*`.
Bilingüismo estricto: soporte de perfiles español e inglés con idéntica fidelidad.
Preservación de comentarios y estructura en transformaciones de código fuente.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, entradas vacías, posiciones límite, Unicode y scripts bilingües.
Conformidad ejecuta los casos del corpus correspondientes a herramientas y servicios.

## 8. Fuentes consultadas y genealogía conceptual

Protocolo Language Server Protocol (LSP) 3.17 y principios de diseño incremental de compiladores modernos basados en consultas.
