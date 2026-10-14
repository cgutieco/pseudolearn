# pseudolearn_vm

## 1. Qué es y qué no es

Ejecuta bytecode verificado emitiendo eventos observables. Contrato documentado, sin implementación ni manifiesto Cargo.

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

Nivel 6. Dependencias internas permitidas: pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_diagnostics. Externas: biblioteca estándar y serde_json exclusivamente para generación durante el build.
Prohibido importar capas superiores, paquetes de UI o internos de otros miembros.

Estructuras y algoritmos: Bancos escalar (`u64`) y de referencias (`u32`) de tamaño fijo potencia de dos (2²⁰ ranuras en escritorio, 2¹⁸ en móvil y Wasm), con acceso `bank.get(index & MASK)`; ventanas solapadas para los argumentos; una comprobación por llamada que es también la de profundidad; **combustible por bloque** con caída exacta al gemelo sondeado; cambio de gemelo en O(1); trampas como `Result` de manejadores pequeños `#[inline(always)]`.

Invariantes: Ningún acceso puede salir de un banco; el gemelo rápido no contiene ninguna instrucción de observación.

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: ejecuta bytecode verificado emitiendo eventos observables respetando los observables del corpus.
Elección: Bancos escalar (`u64`) y de referencias (`u32`) de tamaño fijo potencia de dos (2²⁰ ranuras en escritorio, 2¹⁸ en móvil y Wasm), con acceso `bank.get(index & MASK)`; ventanas solapadas para los argumentos; una comprobación por llamada que es también la de profundidad; **combustible por bloque** con caída exacta al gemelo sondeado; cambio de gemelo en O(1); trampas como `Result` de manejadores pequeños `#[inline(always)]`.
Alternativas descartadas y fundamento: Lua 5 inspira ventanas de registros; Ertl y Gregg inspiran superinstrucciones; Rohou, Swamy y Seznec apoyan medir match con tabla de saltos. Se descartan computed goto y ensamblador. La seguridad sale de máscaras y verificación previa.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.
Las fuentes generadas se producen desde la exportación del corpus en OUT_DIR; nunca se copian manualmente.

## 6. Decisiones de producto que condicionan el código

Contratos: `ENG.EXEC.*`, `ENG.TRACE.*`, `ENG.LIMITS`, `ENG.INPUT`.
La ejecución y la observación conservan la misma semántica; idioma de interfaz y vocabulario son independientes.
Los identificadores del usuario, el texto original y la salida del programa se conservan.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, texto vacío, Unicode, tamaño cero, profundidad extrema y bordes numéricos.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos;
formato, Clippy, auditoría de dependencias y pruebas diferenciales según los contratos de este crate.

## 8. Fuentes consultadas y genealogía conceptual

Lua 5 inspira ventanas de registros; Ertl y Gregg inspiran superinstrucciones; Rohou, Swamy y Seznec apoyan medir match con tabla de saltos. Se descartan computed goto y ensamblador. La seguridad sale de máscaras y verificación previa.
