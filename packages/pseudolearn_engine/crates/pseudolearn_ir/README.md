# pseudolearn_ir

## 1. Qué es y qué no es

Define la representación intermedia verificada. Contrato documentado, sin implementación ni manifiesto Cargo.

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

Nivel 3. Dependencias internas permitidas: pseudolearn_source, pseudolearn_abi. Externas: biblioteca estándar.
Prohibido importar capas superiores, paquetes de UI o internos de otros miembros.

Estructuras y algoritmos: CFG SSA con parámetros de bloque; clases de valor; celdas; `observe` con masa de sentencia; regiones puras; verificador; formato textual con ida y vuelta; catálogo generado de la exportación de `IR.INSTRUCTIONS`.

Invariantes: Toda RI que sale de `lowering` pasa el verificador; ninguna instrucción sin nodo fuente si puede atrapar u observar.

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: define la representación intermedia verificada respetando los observables del corpus.
Elección: CFG SSA con parámetros de bloque; clases de valor; celdas; `observe` con masa de sentencia; regiones puras; verificador; formato textual con ida y vuelta; catálogo generado de la exportación de `IR.INSTRUCTIONS`.
Alternativas descartadas y fundamento: SSA con parámetros de bloque permite compartir semántica con Cranelift. Las banderas pegajosas de IEEE 754 inspiran acumulación de trampas; se rechaza perder la primera trampa o hacer visible un efecto posterior.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.
Las fuentes generadas se producen desde la exportación del corpus en OUT_DIR; nunca se copian manualmente.

## 6. Decisiones de producto que condicionan el código

Contratos: `IR.*`.
La ejecución y la observación conservan la misma semántica; idioma de interfaz y vocabulario son independientes.
Los identificadores del usuario, el texto original y la salida del programa se conservan.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, texto vacío, Unicode, tamaño cero, profundidad extrema y bordes numéricos.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos;
formato, Clippy, auditoría de dependencias y pruebas diferenciales según los contratos de este crate.

## 8. Fuentes consultadas y genealogía conceptual

SSA con parámetros de bloque permite compartir semántica con Cranelift. Las banderas pegajosas de IEEE 754 inspiran acumulación de trampas; se rechaza perder la primera trampa o hacer visible un efecto posterior.
