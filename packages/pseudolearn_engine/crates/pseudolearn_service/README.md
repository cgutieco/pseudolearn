# pseudolearn_service

## 1. Qué es y qué no es

Proporciona las herramientas de edición del lenguaje: sesiones de documento con edición por rango, identidad estable de nodos, autocompletado bilingüe, navegación (definición, referencias, resaltado, símbolos), información emergente y ayuda de firma, formateador canónico, traductor entre perfiles y servidor de Language Server Protocol.

Fuera de alcance: ejecución del motor, máquinas virtuales, interfaz de línea de comandos y interfaces gráficas. Tampoco hay inteligencia generativa: todo resultado se deriva de la gramática, del vocabulario bilingüe y del análisis semántico, y es determinista.

| Pendiente | Motivo | Condición de resolución |
|---|---|---|
| Consulta contextual de `helpCatalog` por identidad y papel | El servicio aún no carga las fichas editoriales; la resolución de identidad y papel por posición ya está disponible | Cargar fichas exportadas y consultarlas por identidad y papel sobre la revisión vigente, sin reconocer lexemas en el cliente |
| Reutilizar resultados semánticos entre ediciones | Cada edición reconstruye árbol, análisis e índice del documento completo; las huellas por unidad solo informan qué unidades cambiaron. El costo medido cumple el presupuesto de latencia hasta diez mil líneas | Un presupuesto de latencia que el reanálisis completo deje de cumplir, o documentos de decenas de miles de líneas |
| Extensión mínima para VS Code | Opcional; el servidor LSP ya sirve a cualquier editor compatible | Decisión de producto sobre distribución de extensiones |

## 2. Guía operativa y ciclo de vida

Rust exacto del miembro, rustfmt y Clippy. Biblioteca del workspace; no se despliega por separado. Se verifica con `cargo xtask verify` desde `packages/pseudolearn_engine` y con la conformidad de los sujetos `service` y `cli`:

- `cargo run -p see_cli --bin see -- conform --subject service` (casos) y `conform --subject service --operation properties` (propiedades), desde `packages/pseudolearn_spec`.
- Mediciones: `cargo run --release -p pseudolearn_bench_worker -- service e09 <salida>` (calidad y latencia del autocompletado), `service incremental <salida>` (latencia de edición) y `service e20 <binario pseudo> <salida>` (arranque y latencia de las herramientas), desde `packages/pseudolearn_engine`.

## 3. Arquitectura y modelo del sistema

Nivel 6. Importa `pseudolearn_source`, `pseudolearn_diagnostics`, `pseudolearn_lexicon`, `pseudolearn_syntax` y `pseudolearn_semantic`; externas: biblioteca estándar, `serde` y `serde_json`. Prohibido importar ejecución, máquina virtual, AOT o CLI.

| Módulo | Responsabilidad |
|---|---|
| `document_session` | Sesión de un documento: texto, árbol, diagnósticos, análisis, índice de símbolos y huellas; edición por rango; consultas mediante `SessionQueries` |
| `unit_partition` | Huellas de firma y de cuerpo por unidad de nivel superior; informe de unidades sin cambios o afectadas |
| `node_identity` | Identidad estable de nodos anclada a la unidad (nombre, tipo y ordinal entre homónimas) |
| `symbol_index` | Nombres de símbolos ubicados por token: declaraciones, usos y escrituras |
| `help_resolution` | Identidad, papel, certeza y rangos de la entidad resuelta en una posición; contexto de construcción desde CST y símbolos desde semántica |
| `cursor_context` | Contexto léxico del cursor: prefijo, comentario o literal, bloques abiertos, miembro, posición de tipo |
| `completion*` | Fuentes de candidatos (palabras clave, símbolos, miembros, tipos, funciones estándar), pistas bilingües, plantillas y ordenación |
| `hover`, `keyword_help`, `type_names` | Información emergente y ayuda de firma en el idioma del perfil |
| `navigation` | Definición, referencias, resaltado y símbolos del documento |
| `formatter`, `block_layout`, `line_renderer`, `source_lines`, `spelling`, `identifier_roles` | Formateador canónico sobre tokens |
| `translator` | Traducción entre perfiles sobre tokens y análisis semántico |
| `lsp_session`, `lsp_documents`, `lsp_queries`, `lsp_protocol`, `lsp_changes` | Servidor LSP sin entrada ni salida propias: recibe y devuelve mensajes JSON-RPC |
| `edit_probe`, `completion_probes`, `marked_text`, `template_validity` | Sondas deterministas para conformidad, mediciones y pruebas |

Invariantes: el formateador es idempotente y devuelve el texto original ante errores sintácticos; la doble traducción de un programa canónico es la identidad; ninguna consulta entra en pánico con posiciones fuera de rango; los resultados no dependen del orden de inserción ni del reloj.

La resolución por posición selecciona solo tokens reales: el comienzo pertenece al token que inicia allí y un final exacto pertenece al token anterior cuando no comienza otro token. Los espacios, comentarios, saltos de línea, literales y EOF no heredan una entidad cercana. Una palabra compuesta conserva un único rango léxico completo, incluidos sus espacios o tabuladores; el símbolo semántico prevalece sobre una función estándar con el mismo nombre. Construcciones y papeles provienen del CST, operadores de su token y contexto sintáctico, y nombres de símbolos del análisis semántico. Si el árbol tiene errores, una identidad resoluble se marca con certeza parcial; no se infiere el papel a partir de texto vecino. Los rangos se calculan sobre la fuente original.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: mantener un documento editable con latencia baja. Elección: la sesión aplica ediciones por rango (posiciones en caracteres; en el protocolo, unidades UTF-16), reconstruye árbol, análisis e índice y calcula las huellas de firma y de cuerpo de cada unidad para informar qué unidades cambiaron y si alguna firma se invalidó. Las huellas emparejan unidades por nombre, tipo y ordinal, de modo que homónimas y renombrados no falsean el informe. La equivalencia con el análisis desde cero es verificable (`matches_cold_analysis`) y se somete a secuencias de ediciones aleatorias. Alternativas descartadas: dependencias de cómputo incremental (`salsa`, `rowan`), que duplican el árbol plano existente, y una caché de resultados semánticos por unidad, que exige desplazar todos los intervalos posteriores a la edición y no se justifica con las latencias medidas.

Problema: formatear sin destruir código ni comentarios. Elección: el formateador trabaja sobre los tokens del analizador sin pérdida; la sangría sale de una pila de bloques abiertos (con las ramas de selección en un nivel propio), el espaciado de reglas por tipo de token, y la ortografía canónica de cada palabra clave y función estándar sale del vocabulario generado del perfil (con tres preferencias explícitas en español: `Algoritmo`, `FinAlgoritmo` y `Sino`). Los comentarios conservan orden y posición relativa; los de línea se normalizan a `// texto` y los de bloque se emiten tal cual. Si el texto tiene errores léxicos o sintácticos, se devuelve sin cambios. Las líneas en blanco se colapsan a una, no se conservan tras un comentario y se garantiza una entre unidades de nivel superior. Los identificadores nunca se renombran: la semántica distingue mayúsculas de minúsculas, de modo que un uso resuelto ya comparte grafía con su declaración. Alternativas descartadas: formateo por líneas de texto, que no distingue cadenas, comentarios ni sombreado.

Problema: traducir entre perfiles sin cambiar el significado. Elección: cada token se sustituye por su ortografía canónica en el perfil de destino y el resto del texto, incluidos blancos, comentarios y literales, se conserva byte a byte. Una función estándar solo se traduce si ninguna declaración del usuario la sombrea (según las ocurrencias del análisis semántico) y si no es un miembro tras un punto. Un nombre de usuario que coincide con una palabra clave, un prefijo compuesto reservado o la traducción de una función estándar usada produce `reservedLexemeUsedAsName` con su posición exacta; nunca se renombra en silencio. Un programa con errores sintácticos no se traduce.

Problema: sugerir candidatos útiles en programas incompletos. Elección: el contexto del cursor sale de los tokens anteriores (comentario o literal, miembro, posición de tipo, inicio de sentencia, expresión) y de la pila de bloques abiertos; los candidatos salen del análisis semántico (variables visibles, campos, métodos y superclases, funciones del usuario y estándar) y del vocabulario. Se ordenan por nivel (cierre del bloque abierto, símbolos locales y miembros, estructuras y subprogramas, funciones estándar, operadores, pistas bilingües), coincidencia exacta y etiqueta. Con tres o más letras que coinciden con una palabra clave del otro idioma se propone la equivalente del perfil activo indicando el origen. Las plantillas se construyen con el vocabulario del perfil y marcadores localizados, y cada una se comprueba analizándola en su posición válida.

Problema: priorizar un cierre no expresa intención de cerrar y mirar solo hacia atrás duplica bloques ya cerrados. Elección: las líneas vacías no reciben texto fantasma; un prefijo directo de al menos dos caracteres solo lo recibe con un candidato contextual único y no exacto. Las iniciales y pistas bilingües quedan en la lista. El mapa compartido de bloques empareja por tipo y anidamiento, también a la derecha del cursor; solo un cierre realmente pendiente puede marcarse inline. Las plantillas reutilizan un cierre posterior disponible o perteneciente a la apertura reemplazada, conservan las paradas de cabecera y cuerpo, y preservan las ramas existentes. Nunca toman el cierre de un bloque exterior. Se descarta interpretar la primera etiqueta ordenada como certeza de intención.

Problema: escribir el operador de asignación después de un nombre completo conserva trabajo mecánico evitable. Elección: `completion_assignment` reconoce un único identificador simple en una línea de sentencia sin código ni comentarios a su derecha; exige una variable o parámetro declarado previamente en ese ámbito, tipo conocido asignable como unidad y ausencia de error en la declaración o colisión de nombres. Un nombre completo ofrece `nombre <- ` con acción plana y el mismo rango de reemplazo, incluidos sus espacios posteriores. La aceptación deja el cursor después del espacio final, no inventa el valor ni un terminador; los nombres de un carácter y referencias a objetos son válidos, los arreglos completos e inferencias implícitas no. Los candidatos ordinarios conservan su orden y completar un nombre no acepta también el operador. Se descarta reconocer identificadores desde Flutter, usar el enunciado como fuente de intención o añadir miembros e índices sin una fase que los pida.

Problema: nombres de símbolos exactos para navegación. Elección: un índice por token que ubica el identificador de cada declaración, uso y escritura (la asignación, la lectura y la declaración se distinguen por el contexto del token); la definición, las referencias y el resaltado salen de ese índice y no de búsquedas de texto.

Problema: servidor LSP interoperable. Elección: sesión sin E/S con ciclo de vida completo (`initialize`, `shutdown`, `exit` con código 0 solo tras `shutdown`, errores estándar antes de inicializar, tras apagar o ante métodos desconocidos), sincronización incremental, diagnósticos sintácticos y semánticos localizados según el idioma negociado, perfil del documento detectado por su primera palabra clave y posiciones convertidas entre caracteres y UTF-16.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos `doc`, `allow` ni `expect` ni `unsafe`. Los errores son valores `Result`, `Option` o diagnósticos. Los límites físicos, nombres y dependencias se leen de `architecture.yaml` del miembro.

## 6. Decisiones de producto que condicionan el código

Contratos: `TOOL.SERVICE.*`, `TOOL.FORMAT.STYLE`, `TOOL.TRANSLATE.ROUND-TRIP` y `TOOL.LSP.CAPABILITIES`. Bilingüismo estricto con idéntica fidelidad en español e inglés. Los textos de ayuda y los marcadores de plantilla se emiten solo en el idioma del perfil activo.

## 7. Verificación, testing y aseguramiento de calidad

Tests en `tests/` espejo de `src/`. Camino feliz e infeliz, entradas vacías, posiciones fuera de rango, Unicode (acentos, `ñ`, caracteres fuera del plano básico) y ambos idiomas. `tests/corpus.rs` ejecuta sobre los 172 programas de referencia: formateo idempotente que conserva estructura y comentarios, doble traducción idéntica en forma canónica, y estabilidad ante programas dañados con ediciones aleatorias. La conformidad ejecuta los casos y propiedades de los contratos contra el binario adaptador; los ejecutores de propiedades tienen casos negativos con sujetos simulados.

Las mediciones locales de calidad y latencia las genera `pseudolearn_bench_worker`; los umbrales se leen de los contratos, no del arnés.

## 8. Fuentes consultadas y genealogía conceptual

Language Server Protocol 3.17 (ciclo de vida, sincronización, posiciones UTF-16) y principios de servicios de lenguaje basados en árboles sin pérdida. De las fuentes consultadas se tomó el protocolo y la separación entre árbol sin pérdida y consultas; se rechazó el cómputo incremental por consultas por su costo en dependencias frente a la latencia medida.
