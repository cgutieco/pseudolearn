# pseudolearn_timeline

## 1. Qué es y qué no es

Reconstruye el estado observable de cualquier instante mediante puntos de control. Contrato documentado, sin implementación ni manifiesto Cargo.

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

Nivel 7. Dependencias internas permitidas: pseudolearn_vm, pseudolearn_runtime, pseudolearn_bytecode, pseudolearn_diagnostics. Externas: biblioteca estándar.
Prohibido importar capas superiores, paquetes de UI o internos de otros miembros.

Estructuras y algoritmos: Cinta de entradas; puntos de control (copia de la tabla de páginas, región activa de los bancos, registros de la VM, estado del azar, cursor de salida) por masa de sentencia ejecutada, con **raleo exponencial** y presupuesto; consulta por instante = restaurar + reproducir con el gemelo sondeado; caché de vistas; deltas desde las páginas copiadas.

Invariantes: El estado reconstruido es igual al observado en su momento; el horizonte retenido se declara.

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: reconstruye el estado observable de cualquier instante mediante puntos de control respetando los observables del corpus.
Elección: Cinta de entradas; puntos de control (copia de la tabla de páginas, región activa de los bancos, registros de la VM, estado del azar, cursor de salida) por masa de sentencia ejecutada, con **raleo exponencial** y presupuesto; consulta por instante = restaurar + reproducir con el gemelo sondeado; caché de vistas; deltas desde las páginas copiadas.
Alternativas descartadas y fundamento: rr inspira grabar solo el no determinismo y reproducir; Python Tutor y Sorva inspiran la máquina nocional observable. Se rechazan grabación del sistema operativo, copia completa por evento y tope fijo de pasos.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.
Las fuentes generadas se producen desde la exportación del corpus en OUT_DIR; nunca se copian manualmente.

## 6. Decisiones de producto que condicionan el código

Contratos: `ENG.STATE.*`, `API.STATE.QUERY` (por instante).
La ejecución y la observación conservan la misma semántica; idioma de interfaz y vocabulario son independientes.
Los identificadores del usuario, el texto original y la salida del programa se conservan.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, texto vacío, Unicode, tamaño cero, profundidad extrema y bordes numéricos.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos;
formato, Clippy, auditoría de dependencias y pruebas diferenciales según los contratos de este crate.

## 8. Fuentes consultadas y genealogía conceptual

rr inspira grabar solo el no determinismo y reproducir; Python Tutor y Sorva inspiran la máquina nocional observable. Se rechazan grabación del sistema operativo, copia completa por evento y tope fijo de pasos.
