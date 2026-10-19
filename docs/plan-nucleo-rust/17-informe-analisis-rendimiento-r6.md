# 17 — Informe de análisis independiente: brecha del backend nativo (R6)

**Responde a:** [16-encargo-analisis-rendimiento-r6.md](16-encargo-analisis-rendimiento-r6.md).
**Fecha y estado:** 2026-10-18, rama `feature/agregar-ruta-de-especificacion`, HEAD `e9c0253` (contenido de código igual a `f1308b6`). Análisis sin cambios de producto ni commits.
**Evidencia:** `packages/pseudolearn_benchmarks/results/r6-independent-analysis/` (`measurements.json`, parches de los experimentos, núcleos en C, arnés, perfiles). Ningún archivo de `results/r6-aot*` ni de las campañas anteriores fue modificado.

---

## 0. Resumen

1. **La brecha no tiene una causa única, pero casi toda está en el código que emite Cranelift, no en la semántica comprobada.** Escribí en C cuatro cargas con *exactamente* el mismo contrato que el código generado (mismo contexto, mismas entradas del runtime, mismas comprobaciones de desbordamiento, finitud, límites, indefinidos y marcos) y las compilé con clang -O2: Mandelbrot queda en **1,06×** (Cranelift 1,58×), Permute en **1,00–1,16×** (2,29×), Sieve en **1,37×** (1,69×) y NBody en **1,57×** (3,61×).
2. **Con el propio Cranelift, nueve cambios generales en el generador y dos en el runtime** —todos prototipados y medidos, y siete de ellos semánticamente inobservables sin más trabajo— bajan las cuatro familias de **2,22 / 2,40 / 2,24 / 2,66** a **1,72 / 1,54 / 1,68 / 1,58** (arreglos / numérica / recursiva / objetos; 10 procesos × 30 parejas, misma sonda). La emisión máxima baja de **16,1 ms a 10,1 ms**, con lo que `PERF.AOT.LEVEL#R3` queda resuelta con margen.
3. **1,30× por familia no es alcanzable con Cranelift y el diseño actual mediante cambios incrementales.** Lo mejor medido con Cranelift está entre 1,5× y 1,7× por familia. Cerrar el resto exige a la vez optimización de nivel LLVM (un optimizador intermedio propio o un backend LLVM), un rediseño del asignador y de la contabilidad del montón, y eliminar comprobaciones de indefinido con un análisis estático. Incluso con LLVM, NBody no baja de 1,30× con el contrato actual (1,57×; 1,33× sin las comprobaciones de indefinido).
4. **El techo no tiene «la misma semántica comprobada»** que afirma el encargo: V1F no rastrea valores indefinidos, no recolecta memoria (su límite de celdas cuenta asignaciones acumuladas, no celdas vivas) y no tiene combustible. Lo reporto como conflicto (§6) porque cambia lo que significa 1,30×.

---

## 1. Método

### 1.1 Herramientas que construí (todas fuera del producto)

| Herramienta | Qué hace | Validación |
|---|---|---|
| Extracción de objetos | Ejecuté el trabajador ya compilado con `TMPDIR` en el *scratchpad* hasta que construyó los diez lanzadores, los copié y lo detuve | El desensamblado de los objetos extraídos es idéntico al de `r6-paired-inline-allocator/*/program.asm` |
| Conductor de generación | Programa Rust enlazado con las `rlib` del motor ya compiladas: fuente → `compile_source_to_module` → copia del generador → objeto + metadatos | Con la copia sin cambios, los diez objetos son **idénticos byte a byte** a los del producto |
| Generador experimental | Copia de `pseudolearn_codegen` con pasadas activables por la variable `PL_EXPERIMENTS` (enganche único tras `compile_function`) | Sin variables activas, salida idéntica |
| Núcleos en C con el contrato AOT | `aot_contract.h` replica el contexto y las firmas `rt_aot_*`; cada núcleo reproduce las comprobaciones de la RI | La sonda valida la salida en cada muestra |
| Sonda mínima | Mismo protocolo que `pseudolearn_native_probe` (estado nuevo antes del reloj, orden alternado, validación) sin la muestra de VM; runtime, biblioteca y `aot_rt` compilados desde copias | Reproduce la base con ±5 %, salvo el techo de Richards (−10 %) y Bounce: **solo se compara contra su propia base** |

Ninguna compilación se ejecutó durante una medición. Las corridas exploratorias usan 3–8 procesos × 30 parejas; las dos corridas consolidadas, 10 × 30. Se conservaron las medianas, no los crudos de cada muestra: **son evidencia exploratoria, no una campaña formal**.

### 1.2 Ruido observado

- Durante la primera mitad de la sesión, un proceso de JetBrains (`code-provenance/chatter`) ocupó un núcleo al ~100 %; además, el renderizador de Claude y WindowServer consumían entre el 20 y el 40 %. Frecuencia, afinidad y carga no están controladas.
- Valores atípicos aislados: el techo de Queens midió 17,5 µs en lugar de 9 µs en una tanda, y el de Sieve 8,0 µs en lugar de 6,5 µs en otra. La razón emparejada los amortigua, pero no del todo.
- La resolución del reloj es de 41,67 ns (24 MHz): un 0,7 % de Sieve.
- **Sensibilidad microarquitectónica:** dos variantes de Permute que solo difieren en quitar el apilado de raíces (código más corto) miden 1,42× y 2,20× de forma reproducible. Con una sola carga en la familia recursiva, un efecto así decide la familia (§5).

### 1.3 Reproducción de la línea base

Con la sonda original y los objetos extraídos: Sieve 1,69; Queens 2,78; Mandelbrot 1,58; NBody 3,61; Permute 2,29; Bounce 2,15; List 1,96; Richards 2,67; Storage 6,83; Towers 1,32. Coincide con `r6-paired-inline-allocator` dentro de ±5 %.

---

## 2. Diagnóstico

### 2.1 Dónde se gasta el tiempo nativo (perfil restringido al subárbol de la entrada AOT)

Medido con `sample` a 1 ms y contando solo el tiempo propio bajo la función de entrada AOT, lo que aísla el intervalo medido de V1F, de la VM y de la preparación:

| Carga | Código generado | Runtime |
|---|---|---|
| Queens, Mandelbrot, NBody, Permute, Bounce, List, Richards, Towers | > 90 % | < 10 % |
| Sieve | 83 % | 14 % (`Heap::allocate` + `bzero`) |
| Storage (n=6) | 21 % | 17 % `adopt_inline`, ~32 % recolección y su `malloc/free`, 5 % `Heap::allocate` (un 20 % adicional es un artefacto del muestreador en `mach_absolute_time`) |
| Storage (n=7) | 18 % | ~50 % recolección, 11 % `adopt_inline`, 8 % `Heap::allocate` |

**Medido:** salvo en Storage, la brecha está en el código generado. **Inferido:** el perfil de proceso completo del encargo mezclaba sujetos; restringirlo al subárbol de la entrada sí atribuye.

### 2.2 Costo fijo por ejecución

| Medida | Nativo | Techo |
|---|---|---|
| Sieve con n=1 | 2,0 µs | 0,5 µs |
| Entrada mínima: leer y escribir | 0,17 µs | — |
| + primera asignación de un arreglo de **1** elemento | +0,83 µs | — |
| + primera asignación de 5 001 elementos | +1,04 µs más | — |
| Cada asignación adicional de arreglo por el runtime | ~0,13 µs | — |

Causa (leída en el código y confirmada al corregirla): `Heap::ensure_slack` exige 16 384 palabras libres por encima de `used`. La sesión nace con exactamente `1 + 16 384` palabras, así que **la primera asignación de cada ejecución siempre provoca, dentro del intervalo, un realojo con copia de 128 KB y un relleno a cero de 64 KB**. Con histéresis (crecer solo cuando quedan menos de 8 192 palabras y reservar el doble), Sieve baja de 1,70× a 1,57× (−1,3 µs) y Towers y Queens unos 0,8 µs.

Escalado del tamaño de entrada (razón nativo/techo):

| Carga | Tamaños → razón | Lectura |
|---|---|---|
| Sieve | n = 1 → 4,00; 500 → 2,15; 2 000 → 1,70; 5 000 → 1,61 | Pendiente de Cranelift 1,55×; pendiente de C con el mismo contrato **1,11×** |
| Permute | 6 → 2,27; 7 → 2,28 | Costo por operación puro |
| Towers | 10 → 1,32; 13 → 1,27 | Costo fijo de ~4 % |
| Queens | 7 → 2,68; 8 → 1,92 | El costo fijo pesa a tamaño nominal |
| Storage | 6 → 7,2; 7 → **12,0** | Superlineal: la recolección, no el código |

### 2.3 Mecanismos del código generado, con su peso medido

Cada fila es una pasada experimental activada sola o sobre las anteriores, medida con la sonda original. Las cifras son razones nativo/techo.

| Mecanismo (hecho observado en CLIF y ensamblado) | Corrección prototipada | Efecto medido |
|---|---|---|
| **Parámetros de bloque muertos.** La RI pasa todas las variables de la función por cada cabecera de bucle (el bucle de filas de Mandelbrot lleva 21 parámetros: 6 `f64` y 8 indicadores `i8`). Viven a través de llamadas y obligan a derramar 6 registros `q` por iteración del bucle interno | Eliminar los parámetros de bloque sin uso real (punto fijo sobre el flujo de argumentos) | Mandelbrot 1,58 → **1,22**; NBody 3,61 → 2,75; el resto, neutro |
| **Caminos lentos que se reúnen.** Cada acceso a arreglo, objeto o celda tiene un bloque frío que llama al runtime y vuelve al camino rápido. La unión tras la llamada invalida el análisis de alias de Cranelift y aumenta la presión de registros. Con el camino rápido completo, en una ejecución correcta ese bloque solo puede fallar | Si el estado tras la llamada es 0, saltar igualmente al bloque de propagación (el camino lento pasa a ser terminal) | List 1,97 → 1,48; Towers 1,31 → 1,07; NBody 3,56 → 2,28; Richards 2,63 → 2,19; Permute 2,23 → 1,94; Queens 2,68 → 2,30 |
| **Sin regiones de alias.** Toda carga y almacenamiento usa `MemFlagsData::trusted()`; un almacenamiento en el montón invalida las cargas del contexto | Regiones `context`, `heap`, `cells` y `roots`, clasificadas por la base de la dirección | Sola: **objeto idéntico** (la bloquean los caminos que se reúnen). Sobre la anterior: Towers 1,07 → 0,96; Bounce 1,91 → 1,81 |
| **Desplazamiento de campo dinámico.** Cada lectura de campo lee la carga útil de la cabecera (`lsr #32; and #0xffff; add; lsl`) aunque la clase estática no tenga subclases | Análisis de jerarquía con el programa completo: si la clase y todas sus subclases comparten el desplazamiento, se usa como constante | Bounce 1,89 → 1,52; List 1,48 → **1,11**; Richards 2,15 → 1,85; emisión de Richards −2 ms |
| **Desbordamiento como `adds; cset vs; tst; b.ne`.** Cranelift no fusiona la marca de desbordamiento con el salto | Con un operando constante, comparación de rango (`a > MAX − c`) fusionada en `cmp; b.gt` | Permute 2,29 → 2,09; Queens 2,71 → 2,58; Bounce 2,13 → 1,97; Richards 2,63 → 2,52 |
| **Celda por cada parámetro arreglo.** Los arreglos se pasan como `cell<array>`; cada uso hace un `cell.load` de ~9 instrucciones (longitud de la tabla, puntero, ranura de 48 bytes, legibilidad) más su camino lento | Representar `cell<array>` directamente por el asa | Permute 2,29 → **1,60** con el conjunto válido (1,42 si además el camino lento de celdas fuera terminal); Queens empeora a 2,05 (las asas pasan a apilarse como raíces en cada llamada) |
| **NaN redundante.** `value.require` sobre un real ya comprobado finito repite `fcmp d,d; b.ne` | Omitirlo cuando el productor es una operación que no puede dar el centinela (aritmética real comprobada, constantes, comparaciones, `new`) | Mandelbrot 1,21 → 1,17; NBody 2,17 → 2,07 |
| **Raíces de parámetros.** El llamador ya enraíza los operandos durante toda la llamada; el llamado los vuelve a apilar | No enraizar el valor original de un parámetro ni sus copias por `value.require` | Bounce 1,55 → 1,43; List 1,12 → 1,06; Permute: anomalía reproducible a 2,20 (§1.2) |
| Bloque de fallo por sitio con epílogo propio | Un bloque de fallo compartido por función | Emisión −3 a −8 %; Richards 1,88 → 1,80 |

**Descartados por medida:** base del montón como variable SSA redefinida tras cada llamada (ayuda a Sieve, Queens, Bounce y Storage, pero empeora Permute); ramas sobre constantes y fusión de parámetros con un solo predecesor (neutro).

**Defectos de Cranelift que quedan y que no ataqué:** rematerialización de constantes en cada uso (`movi` del cero en cada comprobación de finitud, `mov x, #0x7ff…fe` en cada comprobación de desbordamiento), movimientos redundantes del contexto (`mov x0, x28` antes de cada acceso), ausencia de LICM para cargas y de *inlining*, y la condición de `Para` materializada como booleano en un parámetro de bloque (`cset; tst; b.ne`).

### 2.4 Runtime

| Mecanismo | Corrección prototipada | Efecto medido (sonda mínima) |
|---|---|---|
| Recolección periódica: `allocated ≥ max(live, 4096)` provoca recolecciones que marcan todo el árbol vivo de Storage | Umbral mínimo de 262 144 celdas (sigue recolectando antes de superar el límite) | Storage 7,44 → **3,10** |
| Holgura sin histéresis (§2.2) | Histéresis | Sieve 1,70 → 1,57; Queens 1,73 → 1,67; Towers 0,98 → 0,93 |
| Contabilidad por bloque: `blocks` ordenado, conciliación de las asignaciones en línea, `Shape` con `Vec` de dimensiones, `roots()` construido en cada `array_new` | No prototipado | Storage conserva un 15–25 % del tiempo en `adopt_inline` y `allocate` |

### 2.5 Qué parte de la brecha es semántica y qué parte es backend

Núcleos en C con el contrato completo, compilados con clang -O2:

| Carga | Cranelift actual | Cranelift + pasadas válidas | C, mismo contrato | Ablaciones en C |
|---|---|---|---|---|
| Mandelbrot | 1,58 | 1,17 | **1,06** | Sin NaN: 1,06 · sin finitud: 0,80 (el techo también la paga) |
| Permute | 2,29 | 1,60–1,68 | **1,00** (asa directa) / 1,16 (raíces por llamada) | — |
| Sieve | 1,69 | 1,53 | **1,37** (pendiente 1,11) | Sin definición: 1,37 · sin desbordamiento: 1,15 (se vectoriza) |
| NBody | 3,61 | 2,04 | **1,57** | Sin comprobaciones de indefinido: **1,33** |

**Medido:** con un buen backend, las comprobaciones semánticas cuestan poco, salvo dos: la finitud real (también la paga el techo) y el indefinido en lecturas de elementos (~11 % en NBody, que el techo no paga). **Inferido:** el residuo de Cranelift sobre C (1,1× en Mandelbrot, 1,4–1,7× en Permute, 1,3× en NBody) se debe a la calidad de asignación de registros, a la rematerialización de constantes, a la falta de LICM de cargas y a la de *inlining*.

### 2.6 Por carga y por familia, tras las mejoras válidas (10 × 30, sonda mínima)

| Familia | Base | Válido | Cargas (válido) | Lo que queda |
|---|---|---|---|---|
| Arreglos | 2,22 | **1,72** | Sieve 1,53 · Queens 1,95 | Sieve: bucle de Cranelift (pendiente 1,55 frente a 1,11) y costo fijo. Queens: raíces por llamada de los arreglos (con la celda cargada una vez quedaba en 1,63–1,73) |
| Numérica | 2,40 | **1,54** | Mandelbrot 1,17 · NBody 2,04 | NBody: calidad de Cranelift (2,04 frente a 1,57 en C) e indefinidos (~11 %) |
| Recursiva | 2,24 | **1,68** | Permute 1,68 (1,42 en la mejor variante, que no es válida hoy) | Calidad de Cranelift y raíces; muy sensible a la disposición del código |
| Objetos | 2,66 | **1,58** | Storage 3,06 · Richards 1,91 · Bounce 1,67 · List 1,10 · Towers 0,93 | Storage: asignador y contabilidad. Richards y Bounce: llamadas sin *inlining*, despacho virtual, indefinidos en campos |

Emisión máxima: 16,07 ms → **10,07 ms** (Richards). Por pasadas, el verificador de CLIF consumía 5 de los 16,5 ms; la asignación de registros, 5; el egraph, 3.

---

## 3. Hipótesis previas

| Hipótesis | Veredicto | Evidencia | Confianza |
|---|---|---|---|
| Las celdas explican Sieve y NBody | **Falsa** (ya refutada; se confirma) | Cero celdas; NBody lo explican los parámetros muertos y los caminos que se reúnen | Alta |
| El techo hace el mismo trabajo semántico | **Falsa** | V1F (`FramedDirect` → `DirectMachine`): arreglos `Vec<Vec<i64>>` puestos a cero sin rastreo de indefinidos, objetos `[i64; 16]`, `tick()` vacío, sin recolección y con límite de celdas acumulado | Alta (código) |
| La brecha la causan las instrucciones comprobatorias | **Mayormente falsa** | En C cuestan ≤ 3 % salvo la finitud (compartida) y los indefinidos (~11 % en NBody). Lo caro es cómo las emite Cranelift | Alta |
| Hay costo fijo relevante por ejecución | **Verdadera** | 0,8–1,5 µs por ejecución; ~14 % de Sieve; causa: la política de holgura | Alta |
| Mandelbrot es un problema de código escalar | **Verdadera, con causa precisa** | Parámetros muertos y derrames (1,58 → 1,22) | Alta |
| Storage es asignación o recolección residual | **Verdadera** | Recolección periódica (7,4 → 3,1) más contabilidad por bloque | Alta |
| Presión de registros y derrames | **Verdadera en numérica** | Derrames de `q` en el bucle interno de Mandelbrot | Alta |
| Contabilidad de marcos y combustible | **Menor** | El combustible está desactivado en el modo de banco; los marcos cuestan ~6 instrucciones por llamada y el techo también los tiene | Media |
| 1,30× es alcanzable con Cranelift | **Indecidible, improbable** | Mejor medido 1,5–1,7 por familia; el residuo frente a C es del backend | Media |
| La asignación en línea resolvió Storage | **Parcial** | El costo pasó de la asignación a `adopt_inline` (11–17 %) | Media |
| El estimador y el protocolo son neutrales | **Matizar** | §5 | Media |

---

## 4. Soluciones propuestas

Las «válidas» no cambian ninguna observación del corpus por construcción; aun así, cada una debe pasar `see conform --subject aot`, el diferencial nativo (808 comparaciones) y los tests de ejecución antes de aceptarse.

| # | Cambio | Dónde | Costo | Riesgo | Restricciones (§7 del encargo) | Mejora esperada (medida) | Criterio de éxito |
|---|---|---|---|---|---|---|---|
| **S1** | Higiene de CLIF: eliminar parámetros de bloque muertos; desbordamiento con constante por rango; omitir `value.require` tras productores que no dan centinela; bloque de fallo compartido | `pseudolearn_codegen` | S | Bajo | Ninguna; general | Numérica 2,40 → ~1,8; Permute −0,2 | Mandelbrot ≤ 1,25 y NBody ≤ 2,6 en campaña; diferencial sin diferencias |
| **S2** | `enable_verifier=false` en la emisión de producto; verificador activo en tests y depuración | `target.rs` | XS | Bajo: se pierde la red de seguridad en producción (la RI ya se verifica con `verify_module`) | Ninguna | Emisión de Richards 16 → 11 ms | `PERF.AOT.LEVEL#R3` con margen ≥ 3 ms en tres campañas |
| **S3** | Caminos lentos terminales para arreglos de rango 1 y campos, más regiones de alias | `lower_arrays`, `lower_objects`, `inline_memory` | M | Medio: exige demostrar que el camino rápido acepta **todo** acceso válido; si no, se conserva la unión | Ninguna si se demuestra; ante el éxito inesperado del runtime, `internalFault` | Objetos y recursiva −15 a −25 % | Test que fuerce cada camino lento y obtenga la misma trampa que la VM |
| **S4** | Desplazamiento de campo constante por análisis de jerarquía | `class_table`, `lower_objects` | S | Bajo | Ninguna (programa cerrado) | List 1,48 → 1,11; Bounce −20 %; Richards −14 % | Ídem |
| **S5** | Arreglos por asa, no por celda (justificado por `LANG.TYPES.ARRAY`: «un arreglo no es un valor asignable», y `LANG.STMT.ASSIGNMENT`: «un arreglo completo no se asigna»), más la regla de raíces prestadas | En el generador; mejor aún en `pseudolearn_lowering` si el sujeto `engine` lo admite | M | Medio: enraizado y celdas de elemento | Si se toca la RI compartida, la VM debe seguir pasando conformidad | Permute 2,29 → 1,60–1,68; Queens 1,63–1,73 si la celda se carga una vez por función | Recursiva ≤ 1,5 en campaña; pruebas de recolección forzada |
| **S6** | Runtime: histéresis de holgura; política de recolección diferida **solo para AOT** (nuevo valor en `MemoryOptions`; la VM conserva la suya); raíces de `array_new` solo si hace falta recolectar | `pseudolearn_runtime`, `pseudolearn_aot_rt` | S | Bajo-medio: más memoria antes de la primera recolección (≤ 262 144 celdas) | `MEM.MANAGED.UNOBSERVABLE` lo permite; la VM no cambia | Storage 7,4 → 3,1; −0,8 a −1,3 µs fijos | Storage ≤ 3,3; ningún cambio en `engine` |
| **S7** | Asignador sin registro por bloque: cabeceras con tamaño, recorrido lineal y listas libres en el propio montón; se elimina la conciliación | Runtime compartido | L | Alto (lo usa la VM) | Hay que preservar la conformidad de la VM | Storage 3,1 → ~1,5–2 (inferido) | Storage ≤ 1,5 |
| **S8** | Análisis de asignación definida para arreglos y campos: elimina comprobaciones de indefinido demostradas | Nueva pasada sobre la RI | M-L | Medio: debe coincidir exactamente con la VM | Válido solo donde se demuestre | NBody −11 % (C: 1,57 → 1,33) | NBody ≤ 1,8 con Cranelift |
| **S9** | Optimizador intermedio propio sobre la RI (*inlining* de subprogramas pequeños, LICM de cargas, hoisting de límites y celdas) **o** backend LLVM de *release* (RN-11) | Nuevo crate o backend | XL | Alto | LLVM contradice el README de codegen («fuera de alcance: dependencias de LLVM») y el tamaño móvil y Wasm (feature opcional) → **CONFLICT-REPORT** | Hacia el techo de C: Mandelbrot 1,06, Permute 1,0–1,16 | Medido antes de adoptarlo |
| **S10** | Revisar la regla y el techo (§6) | Corpus `PERF.*` | S | — | Decisión de la persona (D-07) | — | — |

---

## 5. Defectos de método detectados

1. **La conciliación de las asignaciones en línea queda fuera del intervalo**: `settle_session` se ejecuta después del reloj y favorece ligeramente al nativo. Hay que medirla dentro o justificar su exclusión.
2. **La muestra de VM dentro de cada pareja perturba el estado microarquitectónico** de la pareja siguiente. Sin ella, el techo de Richards mide un 10 % menos: la razón depende de la composición del arnés.
3. **Una sola carga decide la familia recursiva**, y Permute varía de 1,42× a 2,20× con cambios mínimos de código. Una puerta por familia con un único núcleo es frágil.
4. **Cargas muy cortas (6–250 µs)**: el costo fijo pesa entre el 5 y el 15 % en las pequeñas. No es un error del protocolo, pero conviene publicar la razón por pendiente (dos tamaños) junto a la de tamaño nominal.
5. **Ruido de fondo no controlado** (§1.2).

---

## 6. Conflictos que reporto (`CONFLICT-REPORT`)

1. **Descripción del techo.** El encargo (§2) dice que V1F, la variante 4, tiene «montón contiguo, asignación en bloques puestos a cero y trampas inmediatas» y «la misma semántica comprobada (… valores indefinidos, combustible …)». El código (`variant.rs`, `framed_direct.rs`, `direct.rs`) y el plan 11 («V1 con los mismos bancos y marcos que V2») muestran otra cosa: V1F usa `Vec<Vec<i64>>`, no rastrea indefinidos, tiene `tick()` vacío y no recolecta. Lo descrito corresponde a V2R, la variante 5, que también carece de rastreo de indefinidos. **Consecuencia:** el umbral compara el compilador con un núcleo que hace menos trabajo semántico observable-equivalente solo en estos programas; su límite de celdas es incluso semánticamente distinto (cuenta asignaciones, no celdas vivas).
2. **Origen del umbral.** 1,30× nació en R5 como cota de *representación* entre dos núcleos escritos a mano (V2R/V1F). Aplicarlo a código generado frente a un núcleo especializado por carga y optimizado por LLVM es una exigencia de otra naturaleza. Las mediciones de `PERF.AOT.LEVEL` están marcadas `"provisional": true` y D-07 sigue abierta: decidirlo es de la persona.
3. **LLVM.** Si se quiere 1,30× en todas las familias, la vía con evidencia (S9) choca con el README de `pseudolearn_codegen` («fuera de alcance técnico: … dependencias de LLVM o de un compilador C») y con D-P02 y RN-11, que lo dejan a E-NR1. Requiere decisión explícita.
4. **Camino lento terminal de celdas.** Mi prototipo `terminalcells` mejora Towers y Permute, pero **no es válido hoy**: las celdas gestionadas (de elemento o de campo) pasan legítimamente por el camino lento. Solo serviría si el camino rápido también las cubre. No lo incluyo entre los cambios válidos.

---

## 7. Orden recomendado y experimentos de bajo costo primero

1. **S2 + S1** (días): una campaña formal nueva tras implementarlos en el producto. Valida R3 y la familia numérica. *Experimento previo:* ninguno; ya están medidos con el generador real.
2. **S6** (días): histéresis y política de recolección solo para AOT. *Experimento:* el prototipo de §2.4; antes de implementar, medir la RSS máxima de Storage n=7 con y sin el cambio.
3. **S4** y luego **S3** (1–2 semanas): primero la carga útil constante (riesgo bajo), luego los caminos terminales con su test de completitud. *Experimento:* un test que enumere cada sitio lento de arreglo y campo y compruebe que el runtime solo devuelve fallo allí.
4. **S5** (1–2 semanas), decidiendo si se hace en el generador o en el lowering. *Experimento:* aislar la anomalía de Permute (contadores de rendimiento con Instruments, alineación de funciones) antes de fijar la regla de raíces prestadas.
5. **Decisión de la persona sobre §6** antes de invertir en S7, S8 o S9. *Experimento barato que la informa:* añadir a V1F, solo como experimento, el rastreo de indefinidos y la recolección del motor (una V1F-S) y medir cuánto se mueve el denominador.
6. **Si se mantiene 1,30×:** prototipo de S9 en su forma más barata, un optimizador intermedio con *inlining* y LICM sobre la RI, medido contra los núcleos en C de este informe como techo de backend.

Criterio global para cada paso: campaña formal en un directorio nuevo, 10 × 30, con procedencia; conformidad `aot` y diferencial sin divergencias; ninguna regresión de familia superior al 3 %.

---

## 8. Confianza y cómo aumentarla

| Afirmación | Confianza | Para aumentarla |
|---|---|---|
| El residuo, salvo en Storage, está en el código generado | Alta | — |
| Efectos de S1, S2, S4 y S6 | Alta (medidos con el generador real; diferencias ≥ 10 %, por encima del ruido) | Campaña formal |
| Efectos de S3 y S5 | Media-alta | Campaña formal y test de completitud |
| Techo de C como límite del backend | Media: es una traducción manual y clang ve el programa completo | Añadir Queens y Richards en C; comparar con un prototipo LLVM real |
| 1,30× no es alcanzable con Cranelift de forma incremental | Media | Prototipo de optimizador intermedio (S9 barato); probar `regalloc_algorithm` y otras opciones de Cranelift |
| La anomalía de Permute es microarquitectónica | Baja | Contadores de Instruments (`cycles`, `l1i`, `branch-mispredicts`) y relleno de alineación |
| El costo fijo lo explica la holgura | Media-alta (leído en el código y confirmado al corregirlo) | Perfil a nivel de instrucción de la primera asignación |

---

## 9. Conclusión

- **Con lo que ya está medido** (S1–S6, sin cambiar el backend ni la regla), PseudoLearn pasa de 2,2–2,7× a **≈1,5–1,7× por familia** y cumple R2 y R3. Es un progreso real y de riesgo bajo.
- **1,30× por familia no es alcanzable con Cranelift y el diseño actual sin cambios estructurales.** La evidencia más fuerte: aun con todas las mejoras, NBody queda en 2,04 y Permute en 1,6–1,7 con Cranelift, cuando el mismo contrato compilado con LLVM da 1,57 y 1,00–1,16. Además, NBody no baja de 1,30 ni siquiera con LLVM mientras se paguen las comprobaciones de indefinido que el techo no hace.
- **Para cumplir 1,30× haría falta, a la vez:** (a) optimización de nivel LLVM, sea un optimizador intermedio propio sobre la RI o un backend LLVM de *release*, lo que es un conflicto con decisiones vigentes; (b) S7 (asignador) para Storage; (c) S8 (asignación definida) para NBody; y (d) resolver las fragilidades de método de §5.
- **La alternativa que recomiendo decidir primero:** redefinir el techo para que haga el mismo trabajo semántico (V1F-S) o fijar un umbral por niveles (por ejemplo, ≤ 1,7× para el nivel Cranelift y ≤ 1,30× para un futuro nivel optimizado), dejando constancia en el corpus como cambio clasificado. Esta decisión corresponde a la persona (D-07) y no la tomo aquí.

---

## 10. Decisión adoptada

El 2026-10-18 la persona aprobó la alternativa del §9, registrada como D-R6-01 y D-R6-02 en [08](08-decisiones-riesgos-y-cambios-de-reglas.md) §1.7: umbral por niveles (≤ 1,70× frente a V1F para Cranelift; ≤ 1,30× frente a V1F-S para un nivel optimizado futuro), cambio clasificado en el corpus e implementación de S1–S6 en una iteración.
