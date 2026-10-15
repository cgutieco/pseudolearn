# see_generators

## 1. Qué es y qué no es

Construye programas bien tipados reproducibles para propiedades. No ejecuta sujetos ni obtiene esperados de ellos.

## 2. Guía operativa y ciclo de vida

`cargo test -p see_generators` y `cargo xtask verify` desde el miembro. Biblioteca sin despliegue. `cargo run -p see_generators --example program -- 42 0 es`
reproduce una muestra; acepta semilla, índice y perfil. El ejemplo lee el vocabulario del corpus.
`cargo run -p see_generators --example program -- suite 42 100 > results/r5-generator-programs.json`
regenera las fuentes consumidas por la auditoría del HIR de Rust; se versionan porque otro miembro las consume.
El test del generador rechaza fuentes desactualizadas. No contienen resultados capturados del sujeto.

## 3. Arquitectura y modelo del sistema

Importa model y translation; serde_json solo en tests y el ejemplo de reproducción. Prohibidos los sujetos, oráculos y capas de ejecución. `src/program.rs`
instancia la gramática de pruebas; `src/random.rs` produce decisiones por semilla. Tests espejo.

## 4. Decisiones de diseño y fundamentos técnicos

La gramática genera declaraciones, arreglos, ciclos contados, llamadas por referencia, objetos con
ciclos de referencias, copia superficial, concatenación y lectura. Los terminales se resuelven desde el
vocabulario exportado, incluidos los nombres de incorporadas; no se mantienen traducciones paralelas.
La misma semilla e índice producen la misma estructura y datos en ambos vocabularios. El generador
entrega los operandos y tamaños originales; un oráculo separado deriva los esperados para evitar
reproducir el mismo fallo en generación y comparación. La cantidad cero genera un bucle vacío sobre
un arreglo de una celda, manteniendo bien tipado el programa. No se generan construcciones nuevas.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios ni unsafe. Límites y nombres del miembro. Fallos como Result.

## 6. Decisiones de producto que condicionan el código

Generación de propiedades de ejecución, identidad, estado y recursos. No define semántica del lenguaje.

## 7. Verificación, testing y aseguramiento de calidad

Repetibilidad por semilla, perfiles equivalentes, tamaños cero y vocabulario ausente rechazado. Los
programas se contrastan después contra el análisis del sujeto; generar no implica que el sujeto cumpla.

## 8. Fuentes consultadas y genealogía conceptual

Corpus bilingüe y sus producciones. Se rechazan captura de resultados y dependencia de internos del motor.
