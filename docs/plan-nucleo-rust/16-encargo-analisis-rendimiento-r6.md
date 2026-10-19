# 16 — Encargo de análisis: brecha de rendimiento del backend nativo (R6)

**Estado:** abierto. R6 no está cerrada. Este documento describe un problema; no contiene una solución propuesta.
**Quién lo lee:** una IA o persona que hará un análisis independiente y propondrá una solución.
**Fecha de los datos:** 2026-10-18, rama `feature/agregar-ruta-de-especificacion`, commit `f1308b6`.

---

## 1. El problema en una frase

El backend nativo AOT de PseudoLearn (`pseudolearn_codegen`, que emite código máquina con Cranelift y lo enlaza con el runtime `pseudolearn_aot_rt`) es entre 10 y 27 veces más rápido que la máquina virtual, pero sigue siendo entre 1,3 y 7 veces más lento que un «techo» escrito a mano en Rust, mientras que la regla `PERF.AOT.LEVEL#R1` exige como máximo 1,30× por familia de cargas. Se necesita entender por qué existe esa brecha y qué cambio, de cualquier naturaleza, la cierra sin romper las demás reglas del proyecto.

## 2. La regla que no se cumple

`PERF.AOT.LEVEL` (corpus: `packages/pseudolearn_spec/specifications/perf/perf.aot.level.md`):

- **R1.** La media geométrica de la razón entre el tiempo mediano del código nativo generado y el del *techo nativo con marcos* es como máximo 1,30 en cada familia de `PERF.SUITE.AWFY-CORE`: numérica, recursiva, de objetos y de arreglos.
- **R2.** Antes de medir, cada carga verifica que el ejecutable produce exactamente la salida esperada, y el código nativo supera en rendimiento a la máquina virtual en las diez cargas. (Hoy se cumple.)
- **R3.** La emisión del objeto en memoria, sin contar el enlazador del sistema, tarda como máximo 15 ms de mediana para cada carga. (Oscila alrededor del umbral: 15,99 ms, 15,79 ms, 14,57 ms, 14,14 ms y 15,30 ms según la campaña; hoy incumple.)

El «techo» (`V1F`, variante 4 de `packages/pseudolearn_benchmarks/ceiling/`) es una implementación manual en Rust de las diez cargas, con la **misma semántica comprobada** (desbordamientos, límites de arreglos, valores indefinidos, combustible de sentencias, marcos de llamada), pero escrita a mano y especializada por carga, con montón contiguo, asignación en bloques puestos a cero y trampas inmediatas. No es un compilador: es el límite inferior que PseudoLearn se fijó como meta para un compilador.

## 3. Medidas actuales

Máquina: Apple M2 (Mac14,3), macOS, Rust 1.99.0, Cranelift 0.136.3 con `opt_level = speed`, sin control de frecuencia, afinidad ni carga externa (hay otros procesos activos). Protocolo: diez procesos por carga y treinta parejas por proceso, orden alternado, estado nuevo antes del reloj, salida validada en cada muestra, ninguna muestra descartada, medianas agrupadas, media geométrica por familia. Crudos y procedencia en `packages/pseudolearn_benchmarks/results/`.

Campaña más reciente (`r6-paired-inline-allocator`; capturada con el árbol sucio sobre `59426a9`, el contenido equivale a `f1308b6`):

| Familia | Razón mediana | Meta |
|---|---|---|
| arreglos | 2,124× | ≤ 1,30× |
| numérica | 2,393× | ≤ 1,30× |
| objetos | 2,566× | ≤ 1,30× |
| recursiva | 2,253× | ≤ 1,30× |

Por carga (tiempos medianos de una ejecución completa; la carga es muy corta, entre 6 µs y 250 µs):

| Carga | Familia | Techo (ns) | Nativo (ns) | Razón | Emisión (ms) | Razón en la primera campaña comparable |
|---|---|---|---|---|---|---|
| sieve | arreglos | 6 375 | 10 708 | 1,68 | 0,44 | 1,92 |
| queens | arreglos | 9 000 | 24 167 | 2,69 | 2,03 | 4,37 |
| mandelbrot | numérica | 160 875 | 254 667 | 1,58 | 1,24 | 1,59 |
| nbody | numérica | 9 875 | 35 708 | 3,62 | 7,11 | 4,11 |
| permute | recursiva | 38 500 | 86 750 | 2,25 | 1,78 | 3,77 |
| bounce | objetos | 31 000 | 69 458 | 2,24 | 3,43 | 2,34 |
| list | objetos | 27 084 | 53 542 | 1,98 | 1,99 | 2,08 |
| richards | objetos | 90 125 | 241 375 | 2,68 | 15,30 | 2,55 |
| storage | objetos | 9 042 | 64 417 | 7,12 | 1,82 | 29,63 |
| towers | objetos | 13 041 | 17 166 | 1,32 | 2,23 | 1,86 |

Aceleración sobre la API de la máquina virtual: entre 5× (Storage) y 27× (Sieve); la latencia de la VM incluye la construcción de la máquina, de modo que no es un intervalo puro de ejecución.

Cómo leer los números: la comparación incluye entrada y salida en memoria dentro del intervalo medido, en ambos lados; el tiempo de creación y destrucción de la sesión AOT queda fuera; V1F crea bancos nuevos antes de cada intervalo.

## 4. Qué se ha intentado y qué resultó

Cada punto es una variante aislada medida con la sonda (`pseudolearn_native_probe`) y, si mejoró, con una campaña formal. Los números son razones nativo/techo.

1. **Reutilizar diseños de clase, construir raíces solo si puede haber recolección, un solo recorrido de marcado.** Mejora el tiempo de Storage de ≈288 µs a ≈170 µs; no mueve las demás cargas.
2. **Plegado de constantes enteras y comprobación de finitud real sin materializar el booleano.** Sieve 1,92 → 1,68; NBody 4,11 → 3,6. El resto, dentro del ruido.
3. **Lectura en línea de celdas locales** (cabecera `word`/`readable`/`local` por celda en una tabla accesible desde el contexto). Permute 3,86 → 2,28; Queens 4,91 → 2,68; Towers 1,84 → 1,36.
4. **Crecimiento amortizado del vector de palabras del montón** (antes: un realojo exacto por asignación). Storage 17,1 → 12,9.
5. **Asignación de objetos en línea y escritura en línea de celdas locales.** El código generado reserva en el montón sin llamar al runtime cuando no hay recolección próxima, no hay bloques libres de ese tamaño y hay espacio; anota un registro en un búfer plano que el runtime concilia al entrar. Storage 12,9 → 7,1. A cambio, la emisión de Richards sube a 15,30 ms.

Hallazgos descartados o matizados:

- Los contadores de celdas contradicen la hipótesis histórica de que las celdas explicaban Sieve y NBody: ambas tienen cero cargas de celda.
- El cuerpo caliente de Sieve ya no llama al runtime; aun así está a 1,68×.
- NBody hace 7 asignaciones y su brecha (≈26 µs) no se explica por asignación.
- Con la asignación en línea, Storage hace 0 asignaciones por el runtime en escalas 3–5 y una (la que dispara la recolección) en la escala 6; el tiempo restante no es asignación ni escritura de celdas.
- El perfil de muestreo del proceso completo mezcla AOT, V1F, VM y preparación; no atribuye la brecha por sí solo.

## 5. Observaciones sobre el código generado (hechos, sin diagnóstico)

Se conservan RI, CLIF y ensamblado de cada carga en `results/r6-paired-inline-allocator/<carga>/` (`program.ir`, `program.clif`, `program.asm`) y el motor completo en `packages/pseudolearn_engine/crates/`.

- Sieve, bucle caliente (ensamblado AArch64): cada suma comprobada se compila como `adds` + `cset vs` + `tst` + `b.ne`; cada acceso a arreglo recarga la base del montón, comprueba asa no nula, lee la longitud, compara el índice y lee una etiqueta de «indefinido» antes de usar el elemento; los bucles `Para` comparan el signo del paso en cada iteración.
- NBody: tras cada operación real hay una comprobación de finitud; hay muchas cargas y almacenamientos de pila (`ldr q… [sp, …]`) alrededor de las operaciones de coma flotante; la función principal tiene más de 5 000 líneas de CLIF y emite en ≈7 ms.
- Permute (recursión con una celda pasada por referencia): el cuerpo ya no llama al runtime salvo en la recursión; la razón sigue en 2,25×.
- El código por función incluye contabilidad de profundidad de marcos y de bloques (combustible) en cada entrada y salida.
- Cada operación que puede fallar tiene un bloque frío que llama a `rt_aot_fault` con un identificador de sitio.

## 6. Lo que no se sabe

- Qué fracción de la brecha de cada carga se debe a: instrucciones comprobatorias, presión de registros y derrames, contabilidad de marcos y combustible, representación de datos (palabras de 64 bits con etiquetas frente a representaciones especializadas del techo), diseño del código (bloques fríos, orden de bloques), o costos fijos por ejecución (entrada, salida, sesión).
- Si el techo hace menos trabajo semántico del que el compilador debe conservar o simplemente lo organiza mejor. Las diferencias de representación entre V1F y el código generado no están catalogadas.
- Si 1,30× es alcanzable con Cranelift, o si exige otro backend o una estrategia de generación distinta. No hay medición de una alternativa.
- Si las cargas, de entre 6 µs y 250 µs, tienen una parte relevante de costo fijo por ejecución que enmascara el costo por operación.
- La estacionariedad de las mediciones: la frecuencia, la afinidad y la carga externa no se controlan.

## 7. Restricciones que la solución debe respetar

Del `AGENTS.md` del monorepo y los READMEs de los paquetes:

- **Comportamiento observable intacto.** El corpus de especificaciones (`packages/pseudolearn_spec`) es la verdad del comportamiento: salidas, diagnósticos con argumentos y posiciones, terminación. Conformidad `aot`: 1 207 observaciones sin divergencias; diferencial nativo: 808 comparaciones sin diferencias. La solución no puede cambiarlas ni usar exenciones.
- **No se elimina semántica comprobada** (desbordamientos, límites de arreglos, valores indefinidos, límites de profundidad y de celdas, combustible), salvo que se demuestre por regla que es inobservable.
- **No se modifica la línea base ni el techo para facilitar el umbral.** Las campañas anteriores se conservan, incluidos los resultados desfavorables. Una campaña formal nueva usa un directorio nuevo, diez procesos × treinta iteraciones y procedencia completa.
- **Arquitectura por capas** declarada en `packages/pseudolearn_engine/architecture.yaml`; `unsafe` solo en los crates que ese archivo declara.
- **Reglas de código:** cero comentarios, nombres semánticos, límites de tamaño por archivo y función, sin pánicos, tests de camino feliz y de camino infeliz, README del paquete actualizado con el porqué (`DOC-README-TRUTH`).
- **Construcciones móviles y Wasm no incluyen Cranelift** (feature `native` opcional en la API); presupuestos de tamaño de 3 MiB por ABI y 600 KiB Brotli, sin certificación todavía.
- **El runtime compartido (`pseudolearn_runtime`) lo usa también la máquina virtual**, cuyo comportamiento está congelado por conformidad.
- Una sola rama de trabajo; las fases se cierran con verificadores en verde y autorización explícita (`PHASE-STOP`).
- Se descarta toda corrección que dependa de una carga concreta (detectar un programa del banco). La mejora debe ser general.

## 8. Dónde mirar

| Qué | Dónde |
|---|---|
| Regla y suite | `packages/pseudolearn_spec/specifications/perf/perf.aot.level.md`, `perf.suite.awfy-core.md`, `perf.protocol.md` |
| Generador de código | `packages/pseudolearn_engine/crates/pseudolearn_codegen/` (README §3–4 con decisiones y descartes) |
| Runtime nativo y contexto | `packages/pseudolearn_engine/crates/pseudolearn_aot_rt/` |
| Montón compartido | `packages/pseudolearn_engine/crates/pseudolearn_runtime/` |
| Representación intermedia | `packages/pseudolearn_engine/crates/pseudolearn_ir/` |
| Techo manual | `packages/pseudolearn_benchmarks/ceiling/` (`ceiling_kernels`) |
| Arnés y sonda | `packages/pseudolearn_engine/crates/pseudolearn_bench_worker/`, `pseudolearn_native_probe/` |
| Resultados | `packages/pseudolearn_benchmarks/results/r6-*` (RI, CLIF, ensamblado, crudos, resúmenes) |
| Historia y relevo | `docs/plan-nucleo-rust/15-plan-r6-backend-nativo.md` (§11 en adelante), `relevo-r6-2026-10-18.md`, `07-fases.md` (R6) |

Cómo reproducir: desde `packages/pseudolearn_engine`, `cargo run --release -p pseudolearn_bench_worker -- paired <directorio-nuevo>`; entorno: `export PATH=$HOME/.cargo/bin:$PATH CARGO_INCREMENTAL=0 CARGO_BUILD_JOBS=1`. No ejecutar compilaciones mientras se mide.

## 9. Qué se espera del análisis

Un informe en español que, como mínimo:

1. **Explique la brecha con evidencia**, por carga y por familia: qué parte corresponde a qué mecanismo, con mediciones propias o reproducibles, no con hipótesis.
2. **Indique qué hipótesis históricas son falsas** y cuáles no se pueden decidir con los datos disponibles.
3. **Proponga una o varias soluciones** con su costo esperado, riesgo, impacto en las restricciones de §7, orden de ejecución y criterio de éxito medible. Una solución puede ser de cualquier nivel (generación de código, representación de datos, runtime, backend, protocolo de medición si hay un defecto demostrable de método).
4. **Declare el nivel de confianza** de cada afirmación y lo que habría que medir para aumentarlo.
5. **Diga con franqueza si 1,30× no es alcanzable** con el diseño actual y qué habría que cambiar de la regla o de la arquitectura, reportándolo en vez de resolverlo en silencio (`CONFLICT-REPORT`).

No hace falta implementar. Si se mide, usar directorios de resultados nuevos y no tocar `results/r6-aot*`.
