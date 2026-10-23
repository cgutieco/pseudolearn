# pseudolearn_project

## 1. Qué es y qué no es

Modela un proyecto en memoria: paquetes con raíz lógica, módulos (un archivo es un módulo), dependencias
por alias y la selección de una sola entrada por aplicación. Produce un catálogo inmutable de módulos con
sus fuentes identificadas y errores de proyecto tipados. Implementación disponible en el workspace.

Además valida que las dependencias entre paquetes y las importaciones entre módulos formen un grafo acíclico
(rechazo determinista con la cadena completa) y lee el manifiesto declarativo de cada paquete, del que calcula la
configuración resuelta con procedencia y la autoridad efectiva de los límites que concede el anfitrión.

Fuera de alcance: leer disco, locks (`PG-1.06`), perfiles por archivo aplicados al análisis (`PG-1.07`),
colisiones de caja y NFC en rutas (`PG-1.09`), resolver imports o visibilidad (son de `pseudolearn_semantic`) y
ejecutar nada.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Lock canónico como origen de dependencias fijadas | Esquema versionado | `PG-1.06` |
| Aplicar las excepciones de perfil del manifiesto al análisis por archivo | Perfil por unidad | `PG-1.07` |
| Rutas portables y confinamiento | Adaptador del anfitrión | `PG-1.09` |
| Lectura del manifiesto desde disco y concesiones del anfitrión | CLI | `PG-1.12` |

## 2. Guía operativa y ciclo de vida

Rust exacto del miembro, rustfmt y Clippy. Biblioteca del workspace; no se despliega por separado.
La implementación se verifica desde el workspace con `cargo xtask verify` y conformidad del sujeto engine.
Las pruebas de estrés de grafos grandes están excluidas de la suite corta y se ejecutan aparte desde el miembro
`packages/pseudolearn_engine`:

```bash
cargo test -p pseudolearn_project -- --ignored
```

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

Grafos: `find_cycles` recibe las claves de orden de los vértices y las aristas y devuelve, por cada componente
cíclico, una cadena cerrada de índices. `ProjectCatalog::build` aplica `find_cycles` a las dependencias de paquetes
y produce el error `packageCycle` con `path` igual al paquete menor y `chain` con los nombres. `module_cycles`
recibe las aristas de importación que descubre `pseudolearn_semantic` (`ImportEdge`: módulo que declara, módulo
nombrado y nodo de la declaración) y devuelve los ciclos de módulos con la arista de cada paso.

Manifiesto: `Configuration::resolve` es una función pura de texto, ubicación, concesiones y presupuesto de bytes.
Encadena el analizador sintáctico del subconjunto TOML (`manifest_cursor`, `manifest_scalars`, `manifest_values`,
`manifest_parser`), la validación del esquema (`manifest_schema`, `manifest_sections`, con `manifest_checker`
como utilidad de comprobación) y la autoridad (`authority`). `resolve_all` resuelve varios manifiestos y ordena los
fallos por ubicación; `Configuration::package_input` convierte la configuración en un paquete del proyecto.

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

### Ciclos

Problema: un grafo de importaciones con ciclos no tiene orden de enlace ni de inicialización, y el mensaje debe ser
el mismo sin importar el orden de los archivos. Elección: todo ciclo se rechaza; ningún componente fuertemente
conexo se admite como excepción semántica. La recursión mutua entre subprogramas de un mismo módulo no forma
aristas y sigue siendo válida.

Orden de recorrido: los vértices se ordenan por clave (segmentos de la ruta lógica del módulo; nombre del paquete).
El algoritmo de Tarjan se ejecuta de forma iterativa con una pila explícita y visita las adyacencias por rango, de
modo que un grafo de millones de vértices no agota la pila del anfitrión. Por cada componente cíclico se toma su
vértice menor `s` y una búsqueda en anchura iterativa restringida al componente, con vecinos en orden ascendente,
devuelve el ciclo más corto desde `s` hasta `s`; la primera arista descubierta hacia cada vértice es la de menor
secuencia de claves, de modo que el empate entre ciclos de igual longitud lo decide la menor secuencia. Los ciclos se
emiten ordenados por `s`. Una arista repetida se reduce a una; su sitio es el menor, es decir, la primera
declaración por orden de fuente.

Coste: ordenar claves O(V log V), ordenar y deduplicar aristas O(E log E), componentes O(V + E) y búsquedas de ciclos
O(V + E) en total porque los componentes son disjuntos. No se afirma coste lineal para toda la compilación.

Propiedad de aristas: `pseudolearn_project` es dueño del algoritmo, del orden y de la cadena. La decisión de qué
declaración crea una arista es de `pseudolearn_semantic`: un `Importar` o `Exportar` crea la arista hacia el módulo
que su ruta nombra aunque el símbolo no exista, porque el ciclo es una propiedad del grafo de módulos y no de la
resolución de nombres. Los ciclos de paquetes se detectan al construir el catálogo, antes de cualquier análisis; los de
módulos, después de resolver los enlaces y antes de analizar cuerpos, y con ellos no se produce programa.

### Manifiesto y autoridad

Problema: el contenido de un proyecto no puede conceder nada a sí mismo ni ejecutar nada al abrirse. Elección: el
manifiesto `pseudolearn.toml` es solo datos; el anfitrión entrega las concesiones y la configuración efectiva es
`min(solicitud, concesión)` por límite. Una solicitud sin concesión es un error y no se aplica; una concesión sin
solicitud no se aplica. El vocabulario de permisos está cerrado y vacío: ningún efecto de PG-3 ni PG-5 existe todavía.

Formato: subconjunto estricto de TOML con comentarios, tablas `[a.b]`, claves desnudas o entre comillas, cadenas con
escapes `\"`, `\\`, `\n`, `\t` y `\uXXXX`, enteros decimales sin signo, arreglos y tablas en línea de valores
simples. Quedan fuera booleanos, flotantes, fechas, arreglos de tablas, claves con punto y anidamiento de valores,
por lo que el analizador no recurre y no puede agotar la pila. Las columnas se cuentan en caracteres desde 1 y un BOM
inicial no cuenta.

Por qué un analizador propio: se rechaza la dependencia `toml` porque añadiría `serde`, `winnow` y otras
dependencias a un crate de nivel 1 que entra en el artefacto Wasm y en el móvil, y porque el esquema necesita la
línea y la columna exactas de cada campo, que su API no entrega para errores de significado. Se rechaza JSON porque
no admite comentarios y es un formato incómodo para quien escribe un proyecto a mano.

De TOML se toma la sintaxis de tablas y la gramática de valores; de Cargo, la separación entre `[package]` y
`[dependencies]` y el nombre local de una dependencia. Se rechazan `edition`, los scripts de construcción, las
características opcionales, las versiones por rango y todo origen de red: la edición es una sola y la resolución es
local. El manifiesto no tiene campo de idioma de interfaz.

Errores: los de sintaxis, duplicados, vacío y tamaño se informan solos, porque sin un manifiesto bien formado no se
valida el esquema; los de esquema y autoridad se acumulan y se ordenan por línea, columna y código. Un campo
obligatorio ausente se ubica en la cabecera de su tabla.

Precedencia y valores heredados: manifiesto, luego valor por defecto (`profile = "es"`, `entries = []`). La raíz del
paquete es siempre la ubicación del manifiesto. El presupuesto de bytes del manifiesto se inyecta como parámetro; el
valor del transporte público es candidato y se calibrará con cargas representativas.

Perfiles: las excepciones por archivo se resuelven y se conservan como datos con su procedencia; aplicarlas al análisis
de cada unidad es `PG-1.07`.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.

## 6. Decisiones de producto que condicionan el código

Contratos: `LANG.MODULE.MODEL`, `LANG.MODULE.IMPORT`, `API.PROJECT`, `API.PROJECT.MANIFEST`.
El idioma de interfaz y el vocabulario son independientes; los nombres de paquete y módulo no se traducen.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, proyecto vacío, módulo vacío, entradas repetidas y rutas mal formadas.
Los grafos se prueban contra un oráculo de fuerza bruta en todos los grafos dirigidos de hasta cuatro vértices,
con grafos sembrados que permutan vértices y aristas, y con cadenas profundas de diez mil vértices; los de un millón
son pruebas de estrés ignoradas por defecto. El manifiesto se prueba por campo, con posición exacta de cada error,
presupuesto justo debajo, en el límite y por encima, y la autoridad con una propiedad sembrada de no amplificación.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos.

## 8. Fuentes consultadas y genealogía conceptual

Gleam: un archivo es un módulo. Rust: paquetes con raíz y rutas calificadas. Se toma la idea de módulo
por archivo y de nombre derivado de la ruta; se rechazan la búsqueda en disco y los atributos de módulo.
