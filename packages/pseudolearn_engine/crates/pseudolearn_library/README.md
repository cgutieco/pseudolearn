# pseudolearn_library

## 1. Qué es y qué no es

Implementa operaciones puras de texto, bytes y JSON, además de conversiones, redondeo e intrínsecos
matemáticos sobre valores del runtime. Mantiene dominios y errores explícitos para que la VM atribuya
las trampas al span de la instrucción. No añade construcciones del lenguaje, UI ni efectos libres del
anfitrión.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Paridad bit a bit nativa/Wasm | Puente Wasm | E-17 |

## 2. Guía operativa y ciclo de vida

Usa la versión exacta de rust-toolchain.toml del miembro. El crate está activo en el workspace.
Comprobación: `cargo xtask verify` y `rust-checks layers` del miembro. El contraste masivo contra el
oráculo de SEE se ejecuta con el flujo documentado en `crates/pseudolearn_math_probe/README.md` y deja su
resumen local ignorado bajo los resultados de SEE.

## 3. Arquitectura y modelo del sistema

El formato de valores primitivos recibe los lexemas lógicos canónicos como datos del consumidor.
`ATexto` y la salida comparten exactamente ese formateador; ningún literal de vocabulario se copia aquí.
Las conversiones decimales validan gramática, rango y finitud antes de devolver una palabra.

Nivel 6. Importa runtime y diagnostics; usa serde y serde_json para parsing y representación temporal. Prohibido importar capas superiores, UI, Dart o el sistema de especificaciones como código.

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
| `text_search.rs`, `text_split.rs`, `text_replace.rs` | Búsqueda Unicode, segmentación, unión, reemplazo y recorte de texto |
| `text_case.rs` | Conversión a mayúsculas y minúsculas con las tablas Unicode completas de la biblioteca estándar de Rust |
| `bytes_operations.rs` | Conversión UTF-8, segmentos comprobados y unión binaria |
| `json_parse.rs`, `json_parse_strings.rs` | Parsing JSON, duplicados, límite de profundidad y ubicación de errores; las posiciones empiezan en línea 1, columna 1, también para el texto vacío |
| `json_text.rs`, `json_query.rs`, `json_build.rs` | Texto compacto, consultas, constructores y actualización inmutable |
| `json_source.rs`, `json_source_scan.rs` | Conserva lexemas JSON no modificados al reemplazar valores y añadir miembros |
| `json_local_views.rs` | Devuelve vistas del runtime para resultados de `Elemento` y `Campo` |
| `local_operations.rs` | Despacha operaciones puras desde identidades de `LIB.MODEL` |

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

No se agrega una dependencia matemática externa. `Copiar` está implementado como copia superficial con
nueva identidad: comparte las referencias, conserva ciclos y valores ausentes y no vuelve a ejecutar el
constructor. El runtime suministra los descriptores que determinan el contenido copiable.

Invariantes: Mismo resultado binario64 y mismo texto en todas las plataformas. Los dominios inválidos y resultados no finitos atrapan antes de guardar un valor.

## 4. Decisiones de diseño y fundamentos técnicos

El parser valida antes de guardar el resultado y conserva números de precisión arbitraria y el orden
de las claves. El runtime representa cada `ValorJson` como una vista de un bloque plano inmutable. Las
consultas de `Elemento` y `Campo` entregan una vista al nodo hijo sin copiar su subárbol; la consulta de
claves y las operaciones que atraviesan `HostValue` materializan temporalmente texto JSON. Las
actualizaciones construyen un bloque nuevo, conservan el orden original al reemplazar un campo y
mantienen los lexemas numéricos originales de los valores que no cambian.
Las operaciones se generan como datos desde `LIB.MODEL` y comparten `EffectCall` con VM y AOT, sin
instrucciones de RI nuevas.

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

`AMayusculas` y `AMinusculas` son operaciones locales de familia `text` sin receptor, declaradas en `capabilityLibrary`
y despachadas por `local_operation`, igual que `BytesDesdeTexto`: no añaden instrucciones de RI. Usan las
correspondencias Unicode completas e independientes de la configuración regional de `str::to_uppercase` y
`str::to_lowercase` (`ß` produce `SS`, U+0130 produce `i` más U+0307 y la sigma final se decide por contexto de palabra).
Las tablas son las de la versión de Unicode de la cadena exacta de `rust-toolchain.toml`; la igualdad entre
plataformas se apoya en que todas compilan con esa misma cadena. El resultado puede tener más puntos de código que
la entrada y cuenta celdas como cualquier cadena creada en ejecución. No se acredita todavía en el sujeto nativo:
su vínculo queda pendiente hasta la paridad nativa de la biblioteca.

`Decimales`, `RellenarIzquierda` y `RellenarDerecha` (`PG-S.08`, DS-23) son operaciones locales de familia `text` sin
receptor, despachadas desde `text_format_operations.rs`. `decimal_format.rs` descompone el binario64 en significando y
exponente, multiplica el significando por 10^cantidad con los naturales de precisión arbitraria de `precision/natural.rs`
y desplaza por el exponente: el resultado es la expansión decimal exacta, no una aproximación de coma flotante. El
redondeo es medio-alejado-de-cero y se decide con un solo bit (el primero descartado), porque un resto igual o mayor que
la mitad sube y el empate exacto también. `format_value` no se reutiliza: es el formato de salida de dígitos mínimos, otro
concepto. La cantidad válida va de 0 a 100 (`decimalPlacesOutOfRange`); con 100 decimales el mayor binario64 produce unos
410 caracteres, muy por debajo de cualquier presupuesto. Un real no finito se escribe con su forma de salida habitual
(`NaN`, `inf`) porque las operaciones del lenguaje no los producen salvo desde datos externos. `text_padding.rs` cuenta
puntos de código (no bytes), exige un relleno de exactamente un punto de código (`invalidPaddingText`), rechaza un ancho
negativo (`paddingWidthOutOfRange`) y trata como `cellLimitExceeded` un ancho mayor que 16 777 216 antes de construir la
cadena, para que una petición enorme no agote la memoria del anfitrión antes de que el presupuesto de celdas la rechace.
Sin configuración regional ni separadores de miles. Sin equivalente nativo todavía: vínculo `pendiente` (`PG-N.08`).

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

`json_parse_tests.rs`, `json_local_views_tests.rs`, `json_query_tests.rs` y `json_text_tests.rs` cubren
casos válidos e inválidos, profundidad, orden de claves, vistas compartidas y valores no representables.
Oráculo racional de SEE en un millón de argumentos por función (aleatorios, bordes, subnormales, cercanía
a múltiplos de π/2 y a uno, potencias exactas y puntos medios). Tests internos de naturales, enteros,
intervalos, redondeo binario64 (empates, subnormales, desbordamiento, cero con signo) y potencias exactas;
tests de caja negra con constantes correctamente redondeadas (`e`, `ln 2`, `π/4`, `√2`), `sen(1e22)`,
límites de rango de `exp`, dominios inválidos y reglas de ceros con signo de la potencia. Tests espejo, caminos felices, infelices y límites explícitos. Cada verificador tiene un negativo
con violación deliberada. No se cierran pendientes hasta tener cargo xtask verify y conformidad en verde.

## 8. Fuentes consultadas y genealogía conceptual

Ziv, CRlibm y CORE-MATH inspiran aproximación rápida y reevaluación adaptativa; no se adopta dependencia de libm ni código inseguro.

## Colecciones, interfaces e iteración con limpieza

collection_operation es la fachada compartida por VM y AOT. Recibe una disposición estática y argumentos canónicos separados de sus raíces; deriva las operaciones de heap sin tablas persistentes de tipos dinámicos. quote_text conserva Unicode y escapa delimitadores, saltos y controles; la salida de una colección no normaliza cadenas.

Los tests de estas capacidades se ejecutaron en selecciones acotadas, incluida la comparación de gemelos con recolección forzada. La conformidad del corpus sigue pendiente de la revisión editorial independiente de los contratos nuevos, y la medición de tamaño excede el presupuesto de Wasm.

## Operaciones locales de HTTP

Los constructores, las transformaciones inmutables de petición y los accesores de respuesta viven en
`http_operations`, separados de la lógica de efectos. Esta capa forma valores mediante las funciones
de `pseudolearn_runtime`; solo `Enviar`, `SolicitarRed`, `Limitar` y `Cerrar` pasan por el anfitrión.
La separación conserva una sola implementación de las operaciones puras para VM y AOT y evita que la
biblioteca local adquiera autoridad de red.

`ConLimiteRespuesta` y `ConTiempoMaximo` guardan valores inmutables en la petición. El runtime aplica
el mínimo entre cada valor positivo y el límite del anfitrión; los valores no positivos producen
`PeticionInvalida`. La biblioteca mantiene la petición como dato y no realiza I/O ni administra el
plazo externo.

`Redirigida` también construye una petición inmutable, pero puede fallar por política de seguridad.
El despacho pasa esa operación local y fallible al runtime para devolver `Resultado<PeticionHttp,
ErrorES>` sin conceder autoridad de red ni enviar la petición.

## Ampliación numérica y de colecciones

tan, asin, acos, atan2, log2 y log10 usan intervalos arbitrarios y escalada de Ziv. Los dominios y resultados exactos se resuelven explícitamente; atan2 conserva cuadrantes y ceros con signo. Piso y techo devuelven i64 comprobado. La copia y confirmación de colecciones se delegan al runtime.

## Fecha y hora de calendario (`PG-S.05`)

`FechaHora` es un valor opaco de dos componentes: un instante en nanosegundos desde la época Unix (`i64`, la misma
escala que `Reloj.Ahora`) y un desplazamiento UTC en segundos (`i32`). Rango: de 1677-09-21T00:12:43.145224192Z a
2262-04-11T23:47:16.854775807Z; lo que no cabe en el `i64` es `Nada`, nunca un error. Se descartó `i128`
porque nada del lenguaje entrega nanosegundos fuera de ese rango y obligaría a un tipo de entero nuevo.

Reparto por responsabilidad, todo puro y sin dependencia de zonas horarias: `civil_calendar.rs` (días civiles con el
algoritmo de Hinnant, bisiestos y día de la semana ISO), `date_time_construction.rs` (validación de componentes y
componentes locales), `date_time_format.rs` (ISO 8601 con y sin fracción), `date_time_parse.rs` (análisis estricto con
cursor de bytes) y `date_time_operations.rs` (despacho de las operaciones de la familia `time`). El despacho local de
`local_operation_dispatch.rs` solo reconoce las identidades `date_time_*`; `clock_now` y `clock_local_now` son
operaciones de efecto y no pasan por aquí.

Decisiones: la hora sin zona se interpreta como UTC; `T` y `Z` solo valen en mayúscula; los desplazamientos van de
-12:00 a +14:00 en minutos enteros; el segundo 60 se rechaza (sin segundos intercalares); `FormatoIso` descarta los
nanosegundos y `FormatoIsoPreciso` imprime siempre nueve dígitos, que es la forma que cumple `analizar(formato(x)) = x`.
Los días civiles se verifican en `civil_calendar_tests.rs` contra constantes derivadas de la definición del calendario
(1970-01-01 = día 0, 2000-01-01 = día 10 957) y recorriendo cuatro siglos de ida y vuelta; no contra otra biblioteca.
Las operaciones aritméticas usan métodos saturantes porque el verificador de Clippy prohíbe el operador implícito.

Límites declarados: sin zonas con nombre (solo desplazamientos fijos), sin segundos intercalares, año de cuatro dígitos.

## Biblioteca clásica: un nombre, una semántica

Problema: el pseudocódigo clásico usa `Azar(n)`, `Aleatorio(a, b)`, `Subcadena(c, desde, hasta)`, `Concatenar`, `Mayusculas`, `Minusculas` y `ConvertirANumero`, y una forma conocida no puede existir con otro significado. Elección: cada nombre clásico designa una sola identidad con su semántica clásica. `Subcadena` usa posiciones desde cero incluidas en ambos extremos (válida si `0 ≤ desde ≤ hasta + 1 ≤ Longitud(c)`, vacía cuando `desde = hasta + 1`); `Concatenar` es la concatenación de dos cadenas; `ConvertirANumero` es alias de `AReal` y `Mayusculas`/`Minusculas` de `AMayusculas`/`AMinusculas`. Los enteros aleatorios salen de la fuente sembrada del runtime (`RandomState::next_below`, `next_between`): se descartan las palabras de 64 bits que caen en el resto final del rango y las demás se reducen por módulo, de modo que ningún entero tiene más probabilidad; `AzarReal()` conserva el real en `[0, 1)`. Alternativas descartadas: reducir `AzarReal() * n`, que introduce sesgo, y conservar `Subcadena` con cantidad junto a una forma clásica con otro nombre.

## Posición de los errores de JSON

`serde_json` informa columnas en bytes y, al llegar al final del texto, la del último carácter leído. `json_positions`
traduce ambas a la regla `LIB.JSON#J4`: la columna cuenta puntos de código y `FinInesperado` se informa en el final del
texto, justo después de su último carácter (1:1 para el texto vacío, 1:17 para un texto de 16 caracteres). Antes el
texto vacío daba 1:1 y uno de 16 caracteres daba 1:16, y una `ñ` desplazaba la columna un lugar. Se descartó corregir
solo el caso de fin de texto: la columna en bytes también contradecía `LANG.SOURCE.POSITION`.
