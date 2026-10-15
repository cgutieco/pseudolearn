# pseudolearn_api

## 1. Qué es y qué no es

Ofrece operaciones públicas totales sobre recursos del núcleo. Implementación disponible en el workspace.

Fuera de alcance: otras responsabilidades del motor, UI, I/O libre y construcciones nuevas.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Implementación y tests del crate | Corpus validado y capas inferiores | Front-end y motor de ejecución |

## 2. Guía operativa y ciclo de vida

Rust exacto del miembro, rustfmt y Clippy. Biblioteca del workspace; no se despliega por separado.
La implementación se verifica desde el workspace con `cargo xtask verify` y conformidad del sujeto engine.
La comprobación disponible usa, desde la raíz del monorepo,
`cargo run --manifest-path packages/pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command -- layers packages/pseudolearn_engine`.

## 3. Arquitectura y modelo del sistema

Nivel 8. Dependencias internas permitidas: pseudolearn_source, pseudolearn_abi, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_ir, pseudolearn_lowering, pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_vm, pseudolearn_timeline. Externas: serde, serde_json.
Prohibido importar capas superiores, paquetes de UI o internos de otros miembros.

Estructuras y algoritmos: Recursos con identificador; operaciones totales que devuelven `Result`; captura de defectos internos como `DIAG.ENGINE.INTERNAL-FAULT`; codificaciones JSON canónica y binaria columnar; negociación de capacidades; renderizado en el idioma de interfaz pedido.

Invariantes: Ningún pánico cruza la frontera.

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: ofrece operaciones públicas totales sobre recursos del núcleo respetando los observables del corpus.
Elección: Recursos con identificador; operaciones totales que devuelven `Result`; captura de defectos internos como `DIAG.ENGINE.INTERNAL-FAULT`; codificaciones JSON canónica y binaria columnar; negociación de capacidades; renderizado en el idioma de interfaz pedido.
Alternativas descartadas y fundamento: El corpus API define recursos y codificaciones; se rechaza un objeto por evento en FFI y copiar todo el estado en cada paso.

Problema: posiciones públicas y unidades recuperadas deben describir el texto, no desplazamientos internos.
Elección: la API convierte cada tramo UTF-8 a pares línea/columna y expone el esquema de unidades
recuperadas en orden de fuente. El análisis pasa perfil y rigor al front-end; solo solicita HIR sin
errores léxicos o sintácticos. El idioma de presentación se resuelve al renderizar un diagnóstico
mediante su código y argumentos, sin modificar códigos, tramos ni salida del programa.
Se rechaza que la CLI tenga que reconstruir posiciones o traducir un mensaje ya presentado.

La extensión de ejecución pendiente usa recursos con identificador para iniciar, avanzar, entregar
entrada, cancelar y posicionarse. Las consultas se refieren a un instante y al horizonte retenido;
la reproducción no altera la continuación presente. JSON canónico y binario columnar comparten datos.
Solo se anuncian capacidades implementadas. El borde convierte defectos imposibles a internalFault,
pero las pruebas exigen ausencia de pánicos, no solamente captura. Los recursos inválidos o liberados
producen errores de uso. La API importa todas las capas públicas permitidas y no expone sus estructuras
mutables. Los tests cubren negociación, recursos, fronteras, lotes, entrada y consultas repetidas.

Los argumentos conservan su clase: lexema, token, tipo, término o número. El catálogo genera la ficha
de argumentos requeridos; el borde valida que no falten claves ni se sustituyan números por cadenas.
Los tokens y tipos primitivos se resuelven con el vocabulario del programa antes de presentar prosa.
La sustitución recorre la plantilla una sola vez y no reinterpreta llaves dentro de un lexema del usuario.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.
Las fuentes generadas se producen desde la exportación del corpus en OUT_DIR; nunca se copian manualmente.

## 6. Decisiones de producto que condicionan el código

Contratos: `API.*`, `DIAG.ENGINE.INTERNAL-FAULT`.
La ejecución y la observación conservan la misma semántica; idioma de interfaz y vocabulario son independientes.
Los identificadores del usuario, el texto original y la salida del programa se conservan.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, texto vacío, Unicode, tamaño cero, profundidad extrema y bordes numéricos.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos;
formato, Clippy, auditoría de dependencias y pruebas diferenciales según los contratos de este crate.

## 8. Fuentes consultadas y genealogía conceptual

El corpus API define recursos y codificaciones; se rechaza un objeto por evento en FFI y copiar todo el estado en cada paso.
