# pseudolearn_bytecode

## 1. Qué es y qué no es

Traduce la RI verificada a bytecode gemelo con asignación bicameral de registros. Contrato documentado, sin implementación ni manifiesto Cargo.

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

Nivel 4. Dependencias internas permitidas: pseudolearn_ir, pseudolearn_source. Externas: biblioteca estándar y serde_json exclusivamente para generación durante el build.
Prohibido importar capas superiores, paquetes de UI o internos de otros miembros.

Estructuras y algoritmos: Salida de SSA con copias paralelas; asignación de registros **por clase** sobre dos ventanas; generación **gemela** (rápida y sondeada) con una sola función parametrizada; tabla de correspondencia de puntos de observación; superinstrucciones elegidas por frecuencia de bigramas; `enum Instruction` de 8 bytes con operandos de 16 bits; código acolchado a potencia de dos; verificador de bytecode; despacho generado en `build.rs`.

Invariantes: Los dos gemelos comparten el mapa de registros; todo operando es menor que el tamaño de su ventana; todo salto está dentro de la función.

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: traduce la ri verificada a bytecode gemelo con asignación bicameral de registros respetando los observables del corpus.
Elección: Salida de SSA con copias paralelas; asignación de registros **por clase** sobre dos ventanas; generación **gemela** (rápida y sondeada) con una sola función parametrizada; tabla de correspondencia de puntos de observación; superinstrucciones elegidas por frecuencia de bigramas; `enum Instruction` de 8 bytes con operandos de 16 bits; código acolchado a potencia de dos; verificador de bytecode; despacho generado en `build.rs`.
Alternativas descartadas y fundamento: Lua 5 y SPARC inspiran ventanas solapadas; el verificador de la JVM inspira verificar una vez. CPython inspira generar el catálogo. Self inspira el cambio de código en punto seguro; se descartan JIT, desoptimización y selección manual de superinstrucciones.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.
Las fuentes generadas se producen desde la exportación del corpus en OUT_DIR; nunca se copian manualmente.

## 6. Decisiones de producto que condicionan el código

Contratos: Ninguno observable; lo cubre la conformidad diferencial entre gemelos.
La ejecución y la observación conservan la misma semántica; idioma de interfaz y vocabulario son independientes.
Los identificadores del usuario, el texto original y la salida del programa se conservan.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, texto vacío, Unicode, tamaño cero, profundidad extrema y bordes numéricos.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos;
formato, Clippy, auditoría de dependencias y pruebas diferenciales según los contratos de este crate.

## 8. Fuentes consultadas y genealogía conceptual

Lua 5 y SPARC inspiran ventanas solapadas; el verificador de la JVM inspira verificar una vez. CPython inspira generar el catálogo. Self inspira el cambio de código en punto seguro; se descartan JIT, desoptimización y selección manual de superinstrucciones.
