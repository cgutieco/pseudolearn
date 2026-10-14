# pseudolearn_runtime

## 1. Qué es y qué no es

Gestiona los valores de ejecución mediante memoria persistente determinista. Contrato documentado, sin implementación ni manifiesto Cargo.

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

Nivel 4. Dependencias internas permitidas: pseudolearn_abi, pseudolearn_diagnostics. Externas: biblioteca estándar.
Prohibido importar capas superiores, paquetes de UI o internos de otros miembros.

Estructuras y algoritmos: Espacio de palabras paginado (páginas de 4 096 palabras en `Rc`, tabla con época por página, copia en escritura); asas `u32`; asignación por avance más listas libres por clase de tamaño; recolector preciso sin movimiento con **marcas laterales** y **disparo determinista** por celdas; límite de celdas exacto (cota superior = vivas tras la última recolección + asignadas desde entonces; si la cota supera el límite, se recolecta y se decide con el valor exacto); texto UTF-8 con indicador ASCII y migas cada 64 puntos de código; aritmética comprobada; azar xoshiro256\*\* con SplitMix64; `#![forbid(unsafe_code)]`.

Invariantes: La recolección nunca cambia un observable; el estado interno se repite bit a bit en una reproducción; la identidad es el ordinal.

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: gestiona los valores de ejecución mediante memoria persistente determinista respetando los observables del corpus.
Elección: Espacio de palabras paginado (páginas de 4 096 palabras en `Rc`, tabla con época por página, copia en escritura); asas `u32`; asignación por avance más listas libres por clase de tamaño; recolector preciso sin movimiento con **marcas laterales** y **disparo determinista** por celdas; límite de celdas exacto (cota superior = vivas tras la última recolección + asignadas desde entonces; si la cota supera el límite, se recolecta y se decide con el valor exacto); texto UTF-8 con indicador ASCII y migas cada 64 puntos de código; aritmética comprobada; azar xoshiro256\*\* con SplitMix64; `#![forbid(unsafe_code)]`.
Alternativas descartadas y fundamento: V8 y JVM inspiran asas comprimidas; Swift inspira migas para texto UTF-8. Se rechaza conteo de referencias por ciclos, movimiento por identidad e unsafe en el runtime. Immix, LXR y Perceus son alternativas medibles sin adopción técnica.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.
Las fuentes generadas se producen desde la exportación del corpus en OUT_DIR; nunca se copian manualmente.

## 6. Decisiones de producto que condicionan el código

Contratos: `MEM.*`, `RT.HOST.INTERFACE`, la ejecución de `LANG.TYPES.*` y `LANG.OPS.*`, `ENG.LIMITS` (celdas).
La ejecución y la observación conservan la misma semántica; idioma de interfaz y vocabulario son independientes.
Los identificadores del usuario, el texto original y la salida del programa se conservan.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, texto vacío, Unicode, tamaño cero, profundidad extrema y bordes numéricos.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos;
formato, Clippy, auditoría de dependencias y pruebas diferenciales según los contratos de este crate.

## 8. Fuentes consultadas y genealogía conceptual

V8 y JVM inspiran asas comprimidas; Swift inspira migas para texto UTF-8. Se rechaza conteo de referencias por ciclos, movimiento por identidad e unsafe en el runtime. Immix, LXR y Perceus son alternativas medibles sin adopción técnica.
