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

Estructuras y algoritmos: Lexer con avance UTF-8; tokens en columnas (`kinds: Vec<TokenKind>`, `starts: Vec<u32>`) con la trivia como tokens; parser de descenso recursivo con recuperación por conjuntos de sincronización; **árbol postorden** `Node { kind: u16, first_token: u32, subtree_size: u32 }`; vistas tipadas generadas de `LANG.SYNTAX.GRAMMAR`. El lexer consume el identificador Unicode completo y delega a `pseudolearn_source` la validación del alfabeto tras NFC.

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
Las dos consultas de `contextualVocabulary` usan tablas ordenadas generadas y búsqueda binaria para
mantener pequeño el cuerpo de consulta cuando crece el vocabulario.
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
y clases. En texto suelto, las grafías de directiva del perfil activo se reconocen contextualmente en
posición de unidad superior y producen `moduleSyntaxOutsideProject`; dentro de un programa, los cuatro
lexemas `Importar`, `Exportar`, `import` y `export` permanecen disponibles como nombres. El texto vacío
conserva `expectedAlgorithmStart`, y los prefijos de visibilidad mantienen su diagnóstico. El nodo de una
unidad con prefijo empieza en el prefijo, de forma que semantic lee la visibilidad del primer token sin
recorrer los miembros de la clase. Se rechaza un segundo analizador de módulos, porque duplicaría la
recuperación de errores, y los comodines: tras un punto de la ruta se exige un nombre (`expectedModuleName`).

### Segmentos de ruta de importación

Problema: un símbolo declarado con el vocabulario de otro perfil puede coincidir con una palabra reservada del perfil del
archivo que lo importa (`while` en inglés, `Mientras` en español). Elección: los segmentos de la ruta de `Importar` y
`Exportar` aceptan cualquier palabra reservada, salvo el conector de alias, porque nombran símbolos y no introducen nombres;
el alias de `Como` sigue exigiendo un nombre legal. La obligación de alias para el nombre local reservado se comprueba al
enlazar (`pseudolearn_semantic`), no al analizar la sintaxis.

### Constantes, enumerados y registros

`Constante nombre Como tipo <- expresión;`, `Enumerado nombre … FinEnumerado` y `Registro nombre … FinRegistro` son
unidades superiores (la constante también es sentencia). Cada una tiene su analizador (`constant_parser`,
`enum_parser`, `record_parser`) para no crecer `unit_parser`, y la recuperación reconoce sus cierres. Un enumerado lleva
una sola línea de miembros; un registro solo admite declaraciones `Definir`, y cualquier otra forma, incluida
`Dimension`, es `expectedRecordField`. Los prefijos `Publico` y `Privado` siguen limitados a subprogramas y clases. Una
etiqueta de `Segun` que empieza por identificador (`Color.Rojo:`) cierra el cuerpo anterior igual que un literal. Las
construcciones de registro y el acceso a miembros de enumerado no tienen sintaxis propia: son llamada y punto, que
resuelve semantic. Las palabras nuevas son reservadas y se registran como aperturas de perfil.

El acceso a `Codigo`/`code` de los errores de entrada/salida y JSON admite el lexema reservado después del punto;
el selector se convierte en un nombre de miembro para que semantic resuelva el campo del tipo correcto.

Los vínculos locales usan un analizador distinto de los campos: `Definir [Mutable] nombre Como tipo <- expresión` exige un inicializador; los campos conservan listas y ausencia de inicializador. Se conserva `Declaration` en ambos árboles para no duplicar la extracción de campos.

Los tipos incorporados aceptan argumentos concretos entre ángulos con la misma cota de anidación del parser. `variant_parser` reconoce construcciones, patrones de carga útil, propagación y descarte; los genéricos de usuario no reservan palabras nuevas. La construcción y el patrón tienen nodos distintos: el patrón solo declara un nombre y no evalúa una llamada. Una rama de variante contiene un patrón; De Otro Modo es el comodín.

Los parámetros de tipo (`<T, U>`) solo se aceptan tras el nombre de un registro o de un subprograma, y los argumentos de tipo (`<Entero, T>`) tras un nombre de tipo. `generic_parser` produce los nodos `TypeParameters` y `TypeArguments`; un tipo con argumentos conserva el nodo `Type` de su nombre como padre. No hay ambigüedad con la comparación porque los tipos solo se leen en posición de tipo: tras `Como`, en parámetros, retornos y argumentos de otro tipo. Las listas vacías, sin cierre o con coma final recuperan sin pánico. Las clases siguen rechazando `<` tras su nombre.

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


### Funciones como valores y ámbitos de ejecución

`function_parser` distingue el tipo estructural `SubProceso(Entero) Como Entero` del literal con parámetros nombrados y cuerpo terminado en `FinSubProceso`. Ambos reutilizan el vocabulario bilingüe existente. Los nodos de firma y literal proceden de la gramática generada; no existe un segundo catálogo de sintaxis.

## Colecciones, interfaces e iteración con limpieza

Las palabras de interfaces, colecciones, iteración y limpieza son contextuales y provienen del recurso contextualVocabulary generado. No se incorporan al vocabulario reservado: un nombre interface fuera de una apertura sigue siendo identificador. Los nodos InterfaceUnit, InterfaceSignature, Realization y TypeParameter conservan las identidades nominales; IterationBindings separa los vínculos de la expresión recorrida. ForEachLoop, BreakStatement y DeferStatement conservan sus límites léxicos.

Los tests de estas capacidades se ejecutaron en selecciones acotadas, incluida la comparación de gemelos con recolección forzada. La conformidad del corpus sigue pendiente de la revisión editorial independiente de los contratos nuevos, y la medición de tamaño excede el presupuesto de Wasm.

## Elección de recepciones

`select_parser` reconoce `Elegir … FinElegir` y ramas `Recibir nombre Desde canal:`. El cuerpo
termina ante la siguiente recepción o el cierre, conservando los bloques interiores. Los nodos
`SelectStatement` y `ReceiveBranch` se generan desde la gramática. La cantidad mínima de ramas
se comprueba en semántica para producir el diagnóstico específico en lugar de perder el árbol.

## Entrada de expresión para inspección

`expression_entry::parse_expression_source` consume exclusivamente la expresión original mediante el parser existente y exige EOF, sin generar ni concatenar un algoritmo envolvente. Conserva tokens, spans y diagnósticos del texto recibido. La validación del subconjunto admisible corresponde a semántica y no cambia el parser del lenguaje.
