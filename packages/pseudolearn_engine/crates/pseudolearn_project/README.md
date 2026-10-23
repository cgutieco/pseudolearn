# pseudolearn_project

## 1. Qué es y qué no es

Modela un proyecto en memoria: paquetes con raíz lógica, módulos (un archivo es un módulo), dependencias
por alias y la selección de una sola entrada por aplicación. Produce un catálogo inmutable de módulos con
sus fuentes identificadas y errores de proyecto tipados. Implementación disponible en el workspace.

Fuera de alcance: leer disco, manifiestos y locks (`PG-1.05`, `PG-1.06`), ciclos entre módulos (`PG-1.04`),
perfiles por archivo (`PG-1.07`), colisiones de caja y NFC en rutas (`PG-1.09`), resolver imports o
visibilidad (son de `pseudolearn_semantic`) y ejecutar nada.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Manifiesto y lock declarativos como origen del modelo | Esquema versionado | `PG-1.05`, `PG-1.06` |
| Rechazo de ciclos con la cadena completa | Grafo de importaciones del catálogo | `PG-1.04` |
| Rutas portables y confinamiento | Adaptador del anfitrión | `PG-1.09` |

## 2. Guía operativa y ciclo de vida

Rust exacto del miembro, rustfmt y Clippy. Biblioteca del workspace; no se despliega por separado.
La implementación se verifica desde el workspace con `cargo xtask verify` y conformidad del sujeto engine.
No hay E/S ambiental: el anfitrión entrega los bytes de cada archivo ya leídos.

## 3. Arquitectura y modelo del sistema

Nivel 1. Dependencias internas permitidas: `pseudolearn_source`. Externas: ninguna.
Prohibido importar syntax, semantic, API o consumidores.

Estructuras: `ProjectInput` (paquetes y archivos como datos), `ProjectCatalog` (módulos ordenados por ruta,
índices tipados `PackageId` y `ModuleId`, un `SourceText` con identidad por módulo) y `ProjectError`
(código estable y ruta afectada). `ProjectCatalog::build` valida la forma de la entrada, asigna cada archivo
al paquete cuya raíz es prefijo de segmentos de su ruta y valida las entradas declaradas.
`select_entry` elige la entrada de una petición.

Invariantes: un módulo pertenece exactamente a un paquete; los módulos están ordenados por ruta lógica;
los errores de proyecto salen ordenados por código y ruta, sin depender del orden de los archivos; la
identidad de fuente de cada módulo es la del `source_id` de entrada y no se reutiliza.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: el modelo de proyecto no puede depender del sistema de archivos ni de la sintaxis.
Elección: el catálogo recibe rutas lógicas y textos ya leídos; la resolución de nombres vive en semantic,
que consume el catálogo. Se rechaza un crate que parsee, porque cada petición de proyecto necesita el
mismo perfil y rigor que el resto del análisis y esa política pertenece a la API.

Problema: un módulo debe tener una sola raíz. Elección: la pertenencia se calcula por prefijo de segmentos
y un archivo bajo dos raíces o bajo ninguna es un error de proyecto, nunca una elección silenciosa.
Se rechaza elegir la raíz más larga porque haría depender el significado del orden de declaración.

Problema: errores de forma frente a errores de proyecto. Elección: una entrada mal formada (segmento
vacío, `.` o `..`, `source_id` cero o repetido, nombres de paquete repetidos, alias de dependencia
repetido) es un fallo de uso (`MalformedProject`); un proyecto bien formado pero inconsistente produce
`ProjectError`. Así la API distingue el mal uso del contrato de los errores que el usuario puede corregir.

Problema: cada módulo necesita un nombre calificado único para el enlace. Elección: paquete y segmentos
unidos por puntos (`geo.vectores`). Se rechazan rutas de disco porque no son portables.

Fuentes consultadas: Gleam (módulo por archivo, nombre derivado de la ruta) y Rust (árbol de módulos por
paquete); se rechazan sus convenciones de archivo `mod.rs` y la declaración de módulos dentro del código.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.

## 6. Decisiones de producto que condicionan el código

Contratos: `LANG.MODULE.MODEL`, `API.PROJECT`.
El idioma de interfaz y el vocabulario son independientes; los nombres de paquete y módulo no se traducen.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, proyecto vacío, módulo vacío, entradas repetidas y rutas mal formadas.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos.

## 8. Fuentes consultadas y genealogía conceptual

Gleam: un archivo es un módulo. Rust: paquetes con raíz y rutas calificadas. Se toma la idea de módulo
por archivo y de nombre derivado de la ruta; se rechazan la búsqueda en disco y los atributos de módulo.
