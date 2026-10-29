# pseudolearn_lexicon

## 1. Qué es y qué no es

Expone vocabularios bilingües y firmas generados desde el corpus. Implementación síncrona sin estado mutable.

Fuera de alcance: otras responsabilidades del motor, UI, I/O libre y construcciones nuevas.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Ninguno en el contrato implementado | — | — |

## 2. Guía operativa y ciclo de vida

Rust exacto del miembro, rustfmt y Clippy. El build genera tablas en OUT_DIR; no se despliega.
La implementación se verifica desde el workspace con `cargo xtask verify` y conformidad del sujeto engine.
La comprobación disponible usa, desde la raíz del monorepo,
`cargo run --manifest-path packages/pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command -- layers packages/pseudolearn_engine`.

## 3. Arquitectura y modelo del sistema

Nivel 1. Dependencias internas permitidas: pseudolearn_source. Externas: biblioteca estándar y serde_json exclusivamente para generación durante el build.
Prohibido importar capas superiores, paquetes de UI o internos de otros miembros.

Estructuras y algoritmos: Tablas generadas de vocabulario y funciones por perfil; **hash perfecto** generado en `build.rs`; normalización de caja y acentos por perfil; identidades de apertura de nivel superior para autodeclarar el vocabulario.

Invariantes: Ningún lexema escrito a mano en el código; ninguna apertura compartida entre perfiles (`SEE-PROFILE-OPENERS`).

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: expone vocabularios bilingües generados desde el corpus respetando los observables del corpus.
Elección: Tablas generadas de vocabulario y funciones por perfil; **hash perfecto** generado en `build.rs`; normalización de caja y acentos por perfil; identidades de apertura de nivel superior para autodeclarar el vocabulario.
Alternativas descartadas y fundamento: El hash perfecto generado reconoce palabras sin búsquedas con asignaciones. Se rechaza copiar el vocabulario o usar la grafía de la orden para inferir idioma.

Problema: las firmas copiadas divergen del catálogo. Elección: `build.rs` genera parámetros y retorno
de cada incorporada desde `LIB.MODEL`, además de los lexemas y alias. Los prefijos de palabras compuestas
se generan para evitar construir cadenas candidatas en cada identificador. Se rechaza la tabla de firmas manual.

El catálogo genera también la consulta inversa de identidad y perfil a lexema canónico. Se usa al
presentar argumentos tipados de diagnóstico; no se mantiene un segundo diccionario de nombres de tipo.
`KeywordKind::lexeme` y `BuiltinKind::lexeme` exponen el lexema canónico por perfil. `all` devuelve
tablas estáticas de identidades y `as_str` resuelve desde el discriminante compacto del enumerado; el
tamaño del vocabulario aumenta los datos generados, no el cuerpo de esos métodos. Las herramientas de
edición (autocompletado, formateo y traducción) consumen las tablas sin copiar listas de palabras.

### Palabras reservadas por perfil

Problema: la resolución de imports necesita saber si un nombre importado choca con el vocabulario del archivo que
importa. Elección: `is_reserved(palabra, perfil)` consulta `find_keyword` con el plegado del perfil. Una palabra
reservada solo en otro perfil no lo es aquí y es un nombre legal; el vocabulario de cada perfil se consulta con su propia
tabla generada, sin tablas cruzadas. Descartado: una lista aparte de palabras prohibidas, que podría divergir del corpus.

### Aperturas de perfil

La primera palabra de un archivo decide el perfil cuando es una apertura de unidad. Además de `Algoritmo`, `Clase` y
`SubProceso`, lo son `Constante`, `Enumerado` y `Registro` (y sus equivalentes en inglés), de modo que un archivo que
empieza por una declaración de tipo o de constante conserva la detección automática.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.
Las fuentes generadas se producen desde la exportación del corpus en OUT_DIR; nunca se copian manualmente.

## 6. Decisiones de producto que condicionan el código

Contratos: `LANG.PROFILE.*`, `LIB.MODEL`.
La ejecución y la observación conservan la misma semántica; idioma de interfaz y vocabulario son independientes.
Los identificadores del usuario, el texto original y la salida del programa se conservan.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, texto vacío, Unicode, tamaño cero, profundidad extrema y bordes numéricos.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos;
formato, Clippy, auditoría de dependencias y pruebas diferenciales según los contratos de este crate.

## 8. Fuentes consultadas y genealogía conceptual

El hash perfecto generado reconoce palabras sin búsquedas con asignaciones. Se rechaza copiar el vocabulario o usar la grafía de la orden para inferir idioma.

Problema medido: el plegado asignaba dos cadenas por cada identificador ASCII. Elección: hash perfecto
generado sin colisiones, consulta y comparación de caja ASCII sin reservar; NFC y plegado español solo
para entradas Unicode. El inglés conserva acentos. La detección de apertura prueba cada perfil con su propio plegado. El prefijo compuesto se consulta sin reservar.
Se descarta normalizar literales o identificadores del usuario como palabras reservadas.
