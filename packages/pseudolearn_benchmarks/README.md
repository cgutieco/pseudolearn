# pseudolearn_benchmarks

## 1. Qué es y qué no es

Arnés E-01 de la API pública del núcleo Dart congelado como `reference`. Mide ejecución y coste de
observación sin modificar semántica. El corpus define los contratos y los umbrales; el arnés publica la evidencia.
Carga suma, Fibonacci, burbuja, objetos del anexo, Sieve y Permute de Are We Fast Yet.
La suite AWFY-core lee los diez programas, entradas y controles de la exportación del corpus: Sieve,
Permute, Queens, Towers, List, Storage, Bounce, Mandelbrot, NBody y Richards.
Se excluyen CD, DeltaBlue, Havlak y Json, fuera del subconjunto vigente.
La suite usa tamaños reducidos declarados para permitir repeticiones, no reproduce los tiempos del anexo.

El rendimiento de ejecución Rust se recoge con `dart run tool/collect_execution.dart`, usando el trabajador de la API pública y la línea base `results/macos-r3-awfy/summary.json`. La preparación precede al cronómetro; cada muestra crea estado nuevo, conserva su duración cruda y valida salida y terminación. No mide la CLI ni serialización de eventos.

La herramienta `node --no-warnings --no-incremental-marking tool/run_wasi.cjs <módulo.wasm> <directorio-preabierto> [argumentos...]` ejecuta adaptadores, sondas matemáticas y trabajadores WASI con un solo directorio preabierto y entorno vacío. El marcado incremental se desactiva para evitar el fallo reproducido del anfitrión local durante E/S de módulos con memoria grande; no altera el módulo ni los algoritmos medidos.

## 2. Guía operativa y ciclo de vida

Flutter 3.47.5 aporta Dart 3.13.4; Node se fija en `node-version` para JS y Wasm.
Preparación: `dart pub get`. Verificación: `dart test`, `dart analyze --fatal-infos --fatal-warnings`
y `dart run tool/check.dart`. Ejecución: `dart run tool/collect.dart --output results/local`.
Compila ejecutable nativo, JavaScript optimizado y Wasm en `build/`; ejecuta Node con soporte Wasm GC.
Resultados crudos y resumen en la ruta indicada. Recalcular estadísticas sin repetir mediciones:
`dart run tool/summarize.dart results/local`. CI conserva artefactos por sistema operativo;
`results/` contiene solamente evidencias seleccionadas y no es salida del build del motor.
La línea base AWFY nativa se recoge con `dart run tool/collect_awfy.dart`; evidencia en
`results/macos-r3-awfy/`. `dart run bin/awfy_worker.dart --verify` comprueba todas las cargas.
El análisis Rust se mide con `dart run tool/collect_frontend.dart`: captura procedencia antes del build,
ejecuta diez procesos del trabajador público y conserva treinta rondas de 28 configuraciones. Incluye
1.000, 10.000 y 50.000 líneas, ambos perfiles, ambos rigores, entradas incompletas y el corpus.
`tool/frontend_statistics.dart` rechaza muestras incompletas o duplicadas, calcula IC 95 % sobre medias
por proceso y p95 sobre las 300 latencias; no elimina muestras ni relaja umbrales.
La comparación temprana de R5 se recoge con `dart run tool/r5_vm_tracer.dart`. Las tres cargas
emparejadas viven en `tool/data/r5-vm-workloads.json`; el worker Rust compila RI verificada a bytecode
y lo carga en la forma de despacho de la VM antes del cronómetro, y dentro del intervalo solo ejecuta. Cada worker de `reference` analiza el mismo texto
antes del cronómetro y crea un intérprete nuevo por iteración. Los crudos se guardan en
`results/r5-vm-tracer/` y el resumen en `packages/pseudolearn_spec/results/r5-vm-tracer.json`.
Los perfiles de Mandelbrot y Fibonacci eligen comparación-salto; el bucle entero queda reservado para
la validación fuera de muestra. Los perfiles y el archivo de selección forman parte de la procedencia.
La captura incluye hashes del motor, del código Dart `reference`, de ambos manifiestos y de la versión
exacta de Rust antes de compilar; los archivos borrados del árbol de trabajo se omiten de los hashes
porque ya no forman parte de lo medido. La repetición para cerrar B4 se hizo sin PGO con diez procesos y
treinta iteraciones por backend y carga: 1.800 muestras emparejadas, cero descartadas y una media
geométrica de 63,44× frente al umbral de 30×. Mandelbrot obtuvo 69,79× (IC 95 %: 60,94–76,79), el bucle
entero 80,78× (78,38–84,56) y Fibonacci 45,28× (44,87–45,69). Se cumple el umbral y no fue necesario
repetir RR-01. Los crudos y el resumen están en `results/r5-vm-tracer/`; la captura B3 anterior, con
76,72× y la escalera RR-01 completa, se conserva separada en `results/r5-vm-tracer-b3/`. En ambas
capturas la estacionariedad queda sin demostrar y se conservan todas las muestras.
El nivel del código nativo (E-NR1) se recoge con `cargo run --release -p pseudolearn_bench_worker -- aot ../pseudolearn_benchmarks/results/r6-aot` desde `packages/pseudolearn_engine`: diez procesos de treinta iteraciones por carga, cada una con estado nuevo fuera del intervalo y salida verificada, comparadas con el techo nativo con marcos de `results/e02r` y con la máquina virtual de `results/macos-r5-vm`. `results/r6-aot-initial/` conserva la primera captura (Cranelift sin optimizar, descuento de unidades por bloque) y `results/r6-aot/` la captura tras eliminar el descuento sin presupuesto y activar `opt_level = speed`. La razón geométrica por familia frente al techo es 5,6 (arreglos), 3,7 (numérica), 6,9 (objetos) y 6,4 (recursiva) frente al umbral de 1,30, de modo que el criterio de `PERF.AOT.LEVEL` no se cumple; sí se cumplen la aceleración mínima sobre la máquina virtual (1,2×) y la emisión (máximo 14,8 ms de mediana). La comparación no está emparejada: el techo y el código nativo no comparten proceso, y el intervalo remuestrea las medias por proceso de cada lado. La estacionariedad no se evalúa y se conservan todas las muestras.
El workspace Rust anidado `ceiling` contiene el experimento E-02 V0–V3, no es el motor.
Desde ceiling: `cargo xtask verify` y `cargo run -p ceiling_runner -- collect`; resultados en
`results/e02/` de este paquete. Usa la misma versión exacta de Rust del monorepo.
No requiere secretos ni despliegue. macOS, Linux y Windows son plataformas del recolector.

## 3. Arquitectura y modelo del sistema

| Capa | Responsabilidad | Puede importar | Prohibido |
|---|---|---|---|
| model | Contratos de cargas y resultados | Dart SDK | suite, execution |
| suite | Programas con resultados esperados | model | execution |
| execution | Análisis y ejecución mediante API pública | model, pseudolearn_core | suite, imports internos del núcleo |
| bin | Ejecutar suite y emitir JSON | model, suite, execution | internals del núcleo |
| tooling | Compilar, recolectar y verificar | API del paquete, SDK, analyzer, yaml; worker interno de VM | modificar el núcleo |

Las reglas están en `architecture.yaml`; tests reflejan `lib/src` y `tool`.
El cargador de corpus devuelve un fallo como valor ante exportación inválida y no copia programas.
Cada proceso analiza las cargas con el perfil español flexible antes de medir; cada repetición crea un intérprete nuevo.
La observación recibe instantáneas y cuenta eventos sin conservarlos. Se valida terminación y salida
en ambas configuraciones antes de aceptar la muestra. Un fallo retorna un resultado, no escapa.
El worker es secuencial, con semilla fija, sin I/O dentro del intervalo medido.
La guarda de resultado forma parte del programa y fuerza una trampa si el valor calculado diverge del
control independiente; las muestras aceptadas deben terminar normalmente y validar la salida vacía.

## 4. Decisiones de diseño y fundamentos técnicos

- **Problema:** la captura puede consagrar un error del intérprete. **Elección:** resultados esperados
  calculados por la definición de cada carga y validados antes de guardar tiempos.
  **Descartado:** usar la primera ejecución como resultado normativo.
- **Problema:** JIT y calentamiento sesgan una ejecución. **Elección:** diez procesos por objetivo,
  treinta iteraciones por carga y modo. Conservar todas; detectar candidatos de puntos de cambio con segmentos de al menos cinco muestras,
  diferencia relativa superior al 5 % y diferencia superior a 3,3 errores estándar. No se declara
  estado estable demostrado; se conservan candidatos y datos completos para el protocolo de R3.
  **Descartado:** borrar calentamientos o muestras desfavorables. JavaScript produce duraciones
  observadas en múltiplos de 1 ms; un cero se conserva como dato inferior a esa resolución, no como
  ejecución de coste nulo. Los intervalos se calculan con todas las muestras.
- **Problema:** memoria y CPU no tienen API web portátil. **Elección:** muestreo del proceso anfitrión
  con `ps` en Unix y `Get-Process` en Windows. RSS máxima muestreada es cota inferior del pico;
  CPU es la última lectura acumulada, incluyendo arranque. La memoria no se atribuye a cada carga.
  **Descartado:** reportar una estimación como pico exacto o mezclar CPU con tiempo de pared.
- **Problema:** repeticiones del mismo proceso no son independientes. **Elección:** bootstrap de medias
  por proceso, semilla reproducible e intervalo 95 %; cocientes observado/no observado emparejados
  por proceso y media geométrica por familia. **Descartado:** tratar 300 iteraciones como 300 procesos.
- **Problema:** runners compartidos no fijan frecuencia ni carga externa. **Elección:** publicar
  hardware, versiones y limitaciones. **Descartado:** comparar máquinas diferentes como mismo hardware.

Problema: duplicar programas permite medir otra carga. Elección: el arnés AWFY lee la exportación del
corpus y sus controles; se descarta mantener una segunda copia. El arnés histórico E-01 conserva sus
cargas para reproducir la evidencia original.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés, sin comentarios, imports relativos internos y API pública exportada por un único punto.
Límites en `architecture.yaml`; herramientas y tests exentos de tamaño, no de comentarios.
El verificador usa AST de Dart y sus tokens para evitar falsos comentarios dentro de pseudocódigo.

## 6. Decisiones de producto que condicionan el código

El núcleo se congela como `reference`; E-01 mide defectos existentes sin repararlos en Dart.
`PERF.BASELINE.REFERENCE`, `PERF.SUITE.AWFY-CORE` y `PERF.PROTOCOL` definen la línea base y su protocolo. E-01 publica evidencia inicial
con sus amenazas a la validez; no afirma rendimiento del futuro motor Rust.

## 7. Verificación, testing y aseguramiento de calidad

Tests de cargas, análisis inválido, programa vacío, entrada requerida, límite de pasos y salida
incorrecta. El recolector rechaza falta de muestras, objetivos fallidos y métricas ausentes.
`tool/check.dart` verifica comentarios, capas y límites; cada regla tiene caso negativo.
El workflow manual autorizado ejecuta tests y mediciones en macOS arm64, Linux x64 y Windows x64,
sin umbral de tiempo. `collect_metrics=false` permite verificar las mismas fuentes sin repetir una
medición ya conservada; la verificación habitual se ejecuta en local.
Evidencia de R0: `results/ci-r0-complete/` conserva 32.400 muestras, 90 procesos y 108 grupos
validados en macOS, Linux y Windows. Los datos parciales se conservan por separado. La suite AWFY verifica entradas suministradas, rechaza entradas ausentes y compara salidas en ambos modos.
Los tests del cargador rechazan corpus inválido o incompleto. No hay pendientes operativos del arnés.

## 8. Fuentes consultadas y genealogía conceptual

El anexo aporta las cuatro cargas básicas y la API de micro-pasos; no se adoptan sus tiempos como
línea base estadística. Are We Fast Yet aporta Sieve y Permute: se portan sus algoritmos y sus
resultados de control (669 y 8660). La suite completa usa adaptaciones normativas de PERF.SUITE.AWFY-CORE; se rechazan cargas sin representación en el lenguaje vigente.
ceiling conserva cuatro variantes de cada algoritmo y usa su propio README y architecture.yaml.
La metodología conserva repeticiones independientes y resultados desfavorables del protocolo E-01.

### Aviso de licencia de las cargas derivadas de Are We Fast Yet

Copyright (c) 2015-2016 Stefan Marr <git@stefan-marr.de>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the 'Software'), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

El recolector guarda revisión, hashes de cada fuente y configuración antes de compilar y medir; dirty se refiere solo a fuentes y configuración
del arnés, no a sus salidas. El resumen puede recalcularse sobre los mismos datos crudos sin cambiar
las mediciones, conservando su entorno original.
