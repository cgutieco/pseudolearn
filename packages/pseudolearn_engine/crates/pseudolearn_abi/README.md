# pseudolearn_abi

## 1. Qué es y qué no es

Declara la disposición compartida de los valores de ejecución. Contrato documentado, sin implementación ni manifiesto Cargo.

Fuera de alcance: otras responsabilidades del motor, UI, I/O libre y construcciones nuevas.

| Pendiente | Dependencia | Fase |
|---|---|---|
| Implementación y tests del crate | Corpus validado y capas inferiores | R5 lo común, R6 el resto |

## 2. Guía operativa y ciclo de vida

Rust exacto del miembro, rustfmt y Clippy. No hay binario, build ni despliegue disponible.
La implementación se verifica desde el workspace con `cargo xtask verify` y conformidad del sujeto engine.
La comprobación disponible usa, desde la raíz del monorepo,
`cargo run --manifest-path packages/pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command -- layers packages/pseudolearn_engine`.

## 3. Arquitectura y modelo del sistema

Nivel 0. Dependencias internas permitidas: ninguna capa interna. Externas: biblioteca estándar.
Prohibido importar capas superiores, paquetes de UI o internos de otros miembros.

Estructuras y algoritmos: Disposición de valores, cabeceras de objeto (clase o tipo de arreglo, ordinal), prefijo de referencias, tamaño de página y forma del marco bicameral, como constantes y tipos compartidos.

Invariantes: Una sola definición para VM, runtime y codegen.

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: declara la disposición compartida de los valores de ejecución respetando los observables del corpus.
Elección: Disposición de valores, cabeceras de objeto (clase o tipo de arreglo, ordinal), prefijo de referencias, tamaño de página y forma del marco bicameral, como constantes y tipos compartidos.
Alternativas descartadas y fundamento: V8 y JVM inspiran referencias comprimidas. La disposición canónica permite banco de referencias como pila sombra; se rechazan marcos distintos por motor.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.
Las fuentes generadas se producen desde la exportación del corpus en OUT_DIR; nunca se copian manualmente.

## 6. Decisiones de producto que condicionan el código

Contratos: `RT.ABI` (R6).
La ejecución y la observación conservan la misma semántica; idioma de interfaz y vocabulario son independientes.
Los identificadores del usuario, el texto original y la salida del programa se conservan.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, texto vacío, Unicode, tamaño cero, profundidad extrema y bordes numéricos.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos;
formato, Clippy, auditoría de dependencias y pruebas diferenciales según los contratos de este crate.

## 8. Fuentes consultadas y genealogía conceptual

V8 y JVM inspiran referencias comprimidas. La disposición canónica permite banco de referencias como pila sombra; se rechazan marcos distintos por motor.
