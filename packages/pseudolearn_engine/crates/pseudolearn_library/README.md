# pseudolearn_library

## 1. Qué es y qué no es

Implementa conversiones, redondeo e intrínsecos matemáticos sobre valores del runtime: raíz cuadrada,
valor absoluto, `ln`, `exp`, seno, coseno, arcotangente y potencia real, todos con el binario64 más
cercano al valor exacto. Mantiene dominios y errores explícitos para que la VM atribuya las trampas al
span de la instrucción. No añade construcciones del lenguaje, UI ni efectos libres del anfitrión.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Texto, conversiones de texto, formato de valores y `Copiar` | Montón y arena de texto | B4 |
| Paridad bit a bit nativa/Wasm | Puente Wasm | E-17 |

## 2. Guía operativa y ciclo de vida

Usa la versión exacta de rust-toolchain.toml del miembro. El crate está activo en el workspace.
Comprobación: `cargo xtask verify` y `rust-checks layers` del miembro. El contraste masivo contra el
oráculo de SEE se ejecuta con el flujo documentado en `crates/pseudolearn_math_probe/README.md` y deja su
resumen en `packages/pseudolearn_spec/results/r5-math-contrast.json`.

## 3. Arquitectura y modelo del sistema

Nivel 6. Importa runtime y diagnostics; solo biblioteca estándar externa. Prohibido importar capas superiores, UI, Dart o el sistema de especificaciones como código.

Funciones puras sobre representaciones del runtime, sin estado global.

| Módulo | Responsabilidad |
|---|---|
| `precision/natural.rs`, `natural/division.rs` | Naturales de precisión arbitraria sobre palabras de 64 bits, con división larga de Knuth |
| `precision/integer.rs` | Enteros con signo y desplazamientos y divisiones dirigidas hacia −∞ o +∞ |
| `precision/interval.rs` | Intervalos de coma fija a escala `2^-p` con redondeo hacia fuera en cada operación |
| `transcendental/binary64.rs` | Descomposición exacta de un binario64 y redondeo al más cercano con empates al par |
| `transcendental/series.rs`, `constants.rs` | Series con cota del resto; `ln 2` por `atanh(1/3)` y π por Machin |
| `transcendental/ziv.rs` | Escalada de precisión hasta que los dos extremos del intervalo redondean igual |
| `transcendental/{exponential,logarithm,trigonometric,arctangent,power}.rs` | Reducción de argumento y evaluación de cada función |
| `transcendental/power_exact.rs` | Resultados exactos de la potencia antes de la escalada |

Cada función calcula un intervalo que contiene con certeza el valor exacto: todas las operaciones
redondean el extremo inferior hacia −∞ y el superior hacia +∞, y el resto de cada serie se suma como
ensanchamiento. Si los dos extremos redondean al mismo binario64, ese es el resultado correctamente
redondeado; si no, se repite con el doble de precisión (128, 256… hasta 16 384 bits) y agotar la escalera
es `PrecisionExhausted`, un defecto interno. La reducción es exacta: `exp` resta `k·ln 2` con `k` elegido
en binario64; `ln` normaliza la mantisa a `[√½, √2)` y usa `2·atanh((m−1)/(m+1))`; seno y coseno
multiplican el argumento exacto por `2/π` calculado con tantos bits como su exponente exige, de modo que
`sen(1e22)` y `sen(f64::MAX)` reducen sin error; `atan` invierte por encima de uno y divide dos veces el
ángulo con `y/(1+√(1+y²))`; la potencia evalúa `exp(y·ln x)` con la precisión de `ln x` ampliada por la
magnitud de `y`.

La escalada solo termina si el valor exacto no cae en un punto medio entre binarios64. Las trascendentes
de argumento algebraico no nulo no lo hacen; los casos triviales (`exp 0`, `ln 1`, argumentos menores que
`2^-30` en seno y arcotangente y que `2^-60` en la exponencial, donde el resultado redondeado es el propio
argumento o uno) se resuelven antes. La potencia sí puede ser exacta o caer en un punto medio (`9^1,5 = 27`,
`4^-537,5 = 2^-1075`): `power_exact.rs` resuelve primero las potencias de dos por aritmética de exponentes,
las potencias enteras de hasta 34 de una base impar y las raíces perfectas `2^k`-ésimas con `k ≤ 5`, y
demuestra que fuera de esos casos el resultado no es representable ni punto medio.

No se agrega una dependencia matemática externa. El formato decimal mínimo de ida y vuelta y la copia
superficial pertenecen a bloques posteriores.

Invariantes: Mismo resultado binario64 y mismo texto en todas las plataformas. Los dominios inválidos y resultados no finitos atrapan antes de guardar un valor.

## 4. Decisiones de diseño y fundamentos técnicos

La libm del anfitrión puede diferir en el último bit, que el formato hace visible: en el contraste piloto la
libm de macOS discrepó del oráculo en alrededor del 4 % de senos y cosenos y del 8 % de arcotangentes de
argumentos ordinarios, mientras esta biblioteca coincidió en todos. El redondeo correcto es derivable por
un oráculo racional independiente. Se usa sqrt correctamente redondeada y se rechazan las trascendentes
del anfitrión.

- **Problema:** la primera etapa de Ziv suele ser una aproximación doble-doble con una cota de error
  demostrada a mano para cada función. **Elección:** la primera etapa es la misma aritmética de intervalos
  a 128 bits, cuya cota se obtiene por construcción. **Descartado:** doble-doble, porque cada cota exigiría
  un análisis de error propio que ningún verificador comprueba, y un error en la cota rompería el
  redondeo sin que ningún test lo detectara. Coste medido: entre 20 y 70 µs por llamada en argumentos
  ordinarios y alrededor de 300 µs en senos de argumentos cercanos a `f64::MAX`.
- **Problema:** el coste dominante era asignar memoria y dividir con `u128`. **Elección:** división por
  divisores de 32 bits con instrucciones de 64 bits y redondeos dirigidos sin copias. **Descartado:** una
  aritmética de tamaño fijo, que impondría un tope de precisión a la escalada. Display aporta dígitos mínimos posicionales y se añade .0 cuando hace falta; el cero negativo se conserva. Copiar conserva ausencia, comparte referencias y no ejecuta constructor.

La raíz cuadrada normaliza el significando binario y calcula la raíz entera inferior de un radicando escalado. Compara el radicando con el cuadrado del punto medio entre significandos consecutivos para decidir el redondeo, sin consultar la libm ni perder el cero negativo. El valor absoluto real borra solo el bit de signo y conserva el payload de NaN.

La implementación permanece secuencial y determinista. La exportación del corpus es una dependencia
de datos. Las técnicas que requieren medición se aceptan solo tras conservar resultados y criterios.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, doc, allow, expect, pánicos ni unsafe. Datos con índices tipados,
funciones pequeñas y fallos como Result. Límites y dependencias en architecture.yaml del miembro.
Las salidas generadas se producen en OUT_DIR y no se copian a consumidores.

## 6. Decisiones de producto que condicionan el código

LIB.*, LANG.TYPES.REAL, LANG.OPS.POWER y LANG.IO.VALUE-FORMAT. Ejecutar y observar conservan la misma semántica. Los identificadores, el contenido de
literales y los efectos del programa se preservan; idioma de interfaz y vocabulario son independientes.

## 7. Verificación, testing y aseguramiento de calidad

Oráculo racional de SEE en un millón de argumentos por función (aleatorios, bordes, subnormales, cercanía
a múltiplos de π/2 y a uno, potencias exactas y puntos medios). Tests internos de naturales, enteros,
intervalos, redondeo binario64 (empates, subnormales, desbordamiento, cero con signo) y potencias exactas;
tests de caja negra con constantes correctamente redondeadas (`e`, `ln 2`, `π/4`, `√2`), `sen(1e22)`,
límites de rango de `exp`, dominios inválidos y reglas de ceros con signo de la potencia. Tests espejo, caminos felices, infelices y límites explícitos. Cada verificador tiene un negativo
con violación deliberada. No se cierran pendientes hasta tener cargo xtask verify y conformidad en verde.

## 8. Fuentes consultadas y genealogía conceptual

Ziv, CRlibm y CORE-MATH inspiran aproximación rápida y reevaluación adaptativa; no se adopta dependencia de libm ni código inseguro.
