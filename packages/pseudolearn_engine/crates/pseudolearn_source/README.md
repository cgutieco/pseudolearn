# pseudolearn_source

## 1. Qué es y qué no es

Representa el texto fuente original con posiciones verificadas. Implementación disponible en el workspace.

Fuera de alcance: otras responsabilidades del motor, UI, I/O libre y construcciones nuevas.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Ninguno en el contrato de análisis implementado | — | — |

## 2. Guía operativa y ciclo de vida

Rust exacto del miembro, rustfmt y Clippy. Biblioteca del workspace; no se despliega por separado.
La implementación se verifica desde el workspace con `cargo xtask verify` y conformidad del sujeto engine.
La comprobación disponible usa, desde la raíz del monorepo,
`cargo run --manifest-path packages/pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command -- layers packages/pseudolearn_engine`.

## 3. Arquitectura y modelo del sistema

Nivel 0. Dependencias internas permitidas: ninguna capa interna. Externas: unicode-normalization, unicode-ident.
Prohibido importar capas superiores, paquetes de UI o internos de otros miembros.

Estructuras y algoritmos: `SourceText` con los bytes originales e índice de inicios de línea; funciones del módulo convierten desplazamientos UTF-8 a puntos de código Unicode o unidades UTF-16 y validan tramos. La identidad se consulta con funciones separadas para mantener pequeña la interfaz del texto. BOM; NFC solo para comparar nombres, con camino rápido ASCII. `SourceIdentity` combina proyecto, revisión y archivo; `SourceTable` ordena fuentes por ID y valida nodos y tramos antes de resolver una localización.

Invariantes: Los desplazamientos son siempre límites de carácter UTF-8; el texto original nunca se modifica. La identidad de fuente es distinta del nombre visible; el ID cero se reserva al documento suelto. Una tabla representa una revisión inmutable: una localización de otro proyecto o revisión no se resuelve y un ID no se reutiliza dentro de la tabla.

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: representa el texto fuente original con posiciones verificadas respetando los observables del corpus.
Elección: `SourceText` con los bytes originales; índice de inicios de línea; conversión perezosa de desplazamiento de byte a columna en puntos de código; detección de BOM; NFC solo para comparar nombres, con camino rápido ASCII.
Alternativas descartadas y fundamento: Unicode aporta UTF-8 y NFC para comparar identificadores; se rechaza normalizar el texto almacenado porque perdería posiciones originales.

Problema: dos archivos pueden tener el mismo nombre y rango local. Elección: offsets UTF-8 compactos con `SourceId` y una identidad compuesta de proyecto/revisión/archivo; las búsquedas usan ID, no el nombre. `SourceTable` valida la revisión antes de devolver una fuente. Se rechaza repetir URI o ruta en cada tramo y combinar tramos de fuentes distintas.

Problema: los consumidores usan unidades de coordenadas distintas. Elección: el núcleo conserva offsets de byte; funciones públicas del módulo convierten a línea/columna en escalares Unicode o UTF-16 solo en límites válidos, y rechazan los interiores de un par sustituto. Estas funciones reciben `SourceText` por referencia y mantienen sus métodos centrados en el contenido original. CRLF cuenta como un salto de línea y el BOM permanece en el texto original.

Problema: NFC debe aplicarse después de consumir el nombre completo. Elección: el scanner consulta
`IdentifierNormalizer::is_continuation` para conservar las marcas combinantes dentro del mismo token.
La admisibilidad del alfabeto por rigor se comprueba sobre el nombre normalizado. Se rechaza cortar
el token ante una marca combinante, porque produciría un falso carácter inválido.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.
Las fuentes generadas se producen desde la exportación del corpus en OUT_DIR; nunca se copian manualmente.

## 6. Decisiones de producto que condicionan el código

Contratos: `LANG.SOURCE.*`.
La ejecución y la observación conservan la misma semántica; idioma de interfaz y vocabulario son independientes.
Los identificadores del usuario, el texto original y la salida del programa se conservan.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, texto vacío, Unicode, tamaño cero, profundidad extrema y bordes numéricos.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos;
formato, Clippy, auditoría de dependencias y pruebas diferenciales según los contratos de este crate.

## 8. Fuentes consultadas y genealogía conceptual

Unicode aporta UTF-8 y NFC para comparar identificadores; se rechaza normalizar el texto almacenado porque perdería posiciones originales.
