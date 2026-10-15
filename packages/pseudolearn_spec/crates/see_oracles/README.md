# see_oracles

## 1. Qué es y qué no es

Calcula sumas y cantidad de iteraciones con i128 a partir de operandos i64. Decide límites sin ejecutar sujetos; rechaza paso cero y cantidades que no caben en u64. Expone también un evaluador independiente de expresiones enteras y un contador nocional de celdas para las propiedades. El oráculo real encierra resultados en intervalos racionales exactos y decide el redondeo binario64 por cociente y resto. No ejecuta el motor.

## 2. Guía operativa y ciclo de vida

`cargo test -p see_oracles`; `cargo check -p see_oracles` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Imports internos permitidos: ninguno. num-bigint, num-rational, num-integer y num-traits aportan enteros y fracciones de precisión arbitraria escritos en Rust, sin GMP ni biblioteca matemática nativa. Prohibidas las capas superiores y los sujetos. `src/` implementa la capa; `tests/` refleja módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: responsabilidades independientes. Elección: crate por capa con contratos tipados.
Se descarta importar sujetos o capas superiores para preservar la dirección.

El evaluador entero recorre un árbol de expresiones en postorden con pila explícita y usa i128 antes de
comprobar el dominio i64 en cada operación. Conserva el origen de la primera trampa en orden izquierdo
a derecho. El módulo `cells` marca identidades mediante una pila y un conjunto ordenado: los alias
cuentan una vez, los ciclos terminan y el coste se deriva de campos, elementos o puntos de código.
Se rechazan aritmética i64 idéntica al sujeto, recursión del anfitrión y contar bytes físicos como celdas.

El oráculo matemático usa series racionales con cotas explícitas del resto, reducción de argumento y refinamiento hasta que ambos extremos del intervalo redondean al mismo binario64. La representación del argumento se deriva de sus bits; no usa resultados trascendentales del anfitrión ni código del sujeto. Las dependencias solo implementan aritmética exacta: no deciden la función matemática ni su redondeo. Se rechaza reutilizar el algoritmo doble-doble de la biblioteca de ejecución porque correlacionaría sus errores con el oráculo.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml` del miembro; código inglés sin comentarios ni unsafe.

## 6. Decisiones de producto que condicionan el código

Las propiedades de ejecución contrastan resultados derivados por reglas. Ningún código del sujeto ni captura de su resultado vive aquí.

## 7. Verificación, testing y aseguramiento de calidad

`cargo xtask verify` desde el miembro; casos felices, infelices y límites en tests espejo.

## 8. Fuentes consultadas y genealogía conceptual

[rust-num](https://github.com/rust-num/num-rational) aporta BigRational sobre BigInt bajo MIT/Apache-2.0. Se toma la aritmética racional exacta y se rechazan sus conversiones flotantes como criterio de redondeo del oráculo. Las bibliotecas externas son infraestructura, nunca autoridad sobre el comportamiento de PseudoLearn.
