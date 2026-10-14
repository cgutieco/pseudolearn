# pseudolearn_lowering

## 1. Qué es y qué no es

Traduce el HIR a representación intermedia observable. Contrato documentado, sin implementación ni manifiesto Cargo.

Fuera de alcance: otras responsabilidades del motor, UI, I/O libre y construcciones nuevas.

| Pendiente | Dependencia | Fase |
|---|---|---|
| Implementación y tests del crate | Corpus validado y capas inferiores | R5 |

## 2. Guía operativa y ciclo de vida

Rust exacto del miembro, rustfmt y Clippy. No hay binario, build ni despliegue disponible.
La implementación se verifica desde el workspace con `cargo xtask verify` y conformidad del sujeto engine.
La comprobación disponible usa, desde la raíz del monorepo,
`cargo run --manifest-path packages/pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command -- layers packages/pseudolearn_engine`.

## 3. Arquitectura y modelo del sistema

Nivel 4. Dependencias internas permitidas: pseudolearn_semantic, pseudolearn_ir, pseudolearn_diagnostics. Externas: biblioteca estándar.
Prohibido importar capas superiores, paquetes de UI o internos de otros miembros.

Estructuras y algoritmos: HIR → RI; orden de evaluación normativo; inserción de puntos de observación y cálculo de masa por bloque; paso por referencia como celda.

Invariantes: La masa de sentencia de cada bloque coincide con las entradas a sentencia que contiene.

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: traduce el hir a representación intermedia observable respetando los observables del corpus.
Elección: HIR → RI; orden de evaluación normativo; inserción de puntos de observación y cálculo de masa por bloque; paso por referencia como celda.
Alternativas descartadas y fundamento: La RI tipada deriva del orden de evaluación del corpus; se rechaza optimizar antes de conservar los observables y sus nodos fuente.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.
Las fuentes generadas se producen desde la exportación del corpus en OUT_DIR; nunca se copian manualmente.

## 6. Decisiones de producto que condicionan el código

Contratos: `IR.LOWERING`, `IR.OBSERVATION-POINTS`.
La ejecución y la observación conservan la misma semántica; idioma de interfaz y vocabulario son independientes.
Los identificadores del usuario, el texto original y la salida del programa se conservan.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, texto vacío, Unicode, tamaño cero, profundidad extrema y bordes numéricos.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos;
formato, Clippy, auditoría de dependencias y pruebas diferenciales según los contratos de este crate.

## 8. Fuentes consultadas y genealogía conceptual

La RI tipada deriva del orden de evaluación del corpus; se rechaza optimizar antes de conservar los observables y sus nodos fuente.
