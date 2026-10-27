# pseudolearn_bench_worker

## 1. Qué es y qué no es

Mide cargas de la API pública en proceso. Herramienta local; no es una capa del producto ni un sujeto de conformidad.
El comando `execute` prepara las diez cargas AWFY de medición desde la exportación y emite treinta muestras por carga; valida salida y terminación fuera del intervalo. El comando `e06` mide las ocho métricas de la línea temporal (observador en pausa, coste de los deltas por evento, independencia de la profundidad, coste de un punto con pila profunda, latencia de paso observado, latencia de retroceso, memoria retenida y memoria residente con grabación) y emite un único documento JSON con muestras crudas, veredicto por métrica y `all_passed` calculado. Pendiente: la orquestación en diez procesos del arnés Dart; hoy cada métrica se toma en un único proceso con treinta iteraciones.

El comando `aot <directorio> <techo-raw.json> <resumen-vm.json>` mide el código nativo generado con `pseudolearn_codegen` sobre las mismas diez cargas: por cada carga emite el objeto sin punto de entrada con `build_benchmark_object` (treinta emisiones cronometradas), enlaza un lanzador propio con el objeto y la biblioteca del runtime, y ejecuta diez procesos de treinta iteraciones cada uno. Cada iteración crea una sesión nueva fuera del intervalo, cronometra solo la llamada a la función principal y verifica salida y estado después; una salida distinta aborta el proceso. Lee las dos líneas base de los archivos locales indicados y escribe `raw.json` y `summary.json` en el directorio de salida.

El comando `paired <directorio-nuevo>` enlaza un trabajador con el mismo objeto AOT y V1F. Conserva parejas reales, medianas por carga y bootstrap de medias por proceso identificado separadamente. Rechaza sobrescribir evidencias. `paired-summary <directorio>` recalcula el resumen sin ejecutar cargas ni modificar los crudos.

`paired-probe <directorio-nuevo>` ejecuta las seis cargas de diagnóstico con contadores separados, escala Storage en profundidades 3–6 y conserva un perfil del proceso de Storage. Sus tiempos instrumentados no sirven para declarar N3.

El comando `service` mide las herramientas de edición: `service e09 <salida> [mediciones]` evalúa el autocompletado sobre los programas de referencia (cada identificador, palabra clave o función estándar de al menos tres caracteres se consulta con prefijo de cero y de dos caracteres sobre el documento truncado), calcula precisión en 1 y en 5, ahorro de pulsaciones y validez de plantillas, y mide la latencia del completado en un documento de diez mil líneas y, aparte y sin umbral, la de una sesión de edición sobre el mismo documento (aplicar una edición, completar y asistir al teclear); `service incremental <salida> [mediciones]` mide la latencia de una edición de cuerpo en documentos de mil y de diez mil líneas; `service e20 <binario pseudo> <salida>` mide el arranque y la latencia de `comprobar`, `ejecutar`, `compilar`, `formatear`, `traducir` y `lsp`. Los umbrales se leen de los contratos exportados, el resultado de umbral incumplido termina con error y las mediciones se registran en el directorio local ignorado `results/`.

El comando `service help` mide la consulta de ayuda: `functional <directorio>` recorre los programas de referencia (recortados y completos, con ambos rigores e idiomas) por la API y por LSP contra un oráculo derivado del corpus, `latency hot|cold <directorio> <proceso>` toma treinta muestras por documento (uno pequeño real y uno generado de diez mil líneas) y `summary` y `verify` recalculan y comprueban el resumen. `tool/e_pg_11.sh <directorio-nuevo>` orquesta la campaña: procedencia antes de compilar, diez procesos independientes por serie, y verificación final; nunca sobrescribe un directorio.

El comando `service project` mide perfiles por archivo, proyectos multiarchivo y resolución con el protocolo `e-pg-13/1`; solo usa la API pública (`analyze_project`, `execute_project`, `build_lock`, `resolve_lock`). `functional <directorio>` ejecuta cada conjunto una vez y compara la salida con un oráculo que es una fórmula cerrada sobre las constantes sembradas (semilla 42): cadena, estrella, diamante y biblioteca (los tres primeros en un paquete y el último con las hojas en una biblioteca local), 100 módulos sintéticos con perfiles alternados y 20 pares es/en con cinco colisiones de palabra reservada que exigen alias; cada conjunto mixto tiene un control de un solo perfil con la misma salida esperada (los nombres colisionantes del control son neutros, porque una palabra reservada no puede declararse en su propio perfil), y los conjuntos editados (cuerpo y firma) se ejecutan también. `run profiles|project|resolution <directorio> <proceso>` toma treinta muestras por documento y por métrica (`analyze_ms`, `execute_ms`, `build_ms`, `resolve_ms`), valida cada respuesta y escribe `<serie>-process-NN.json` con protocolo, máquina (sistema, arquitectura y procesadores) y huella del conjunto. Los casos de proyecto son frío, misma revisión, edición de cuerpo y edición de firma sobre 10, 100 y 1000 archivos con unas 10 000 líneas en total repartidas por archivo, más una serie de volumen creciente (100 líneas por archivo). `summary` calcula mediana, p95 agrupado, intervalo bootstrap de 95 % (10 000 remuestreos por proceso, semilla 42) del p95 y de la media de medias por proceso, candidatos a punto de cambio y la razón mixto/control por proceso con su intervalo; el p95 es el percentil por rango sobre todas las muestras de todos los procesos del documento. `verify` rechaza menos de diez procesos, muestras distintas de treinta o no positivas, resolución de reloj nula, semilla o protocolo ajenos, mezcla de máquinas, conjunto distinto del funcional, campaña funcional vacía o con fallos, crudos distintos de las huellas del resumen y un resumen que no coincide con su recálculo. Como no existe una API incremental de proyecto, los casos de edición miden un reanálisis completo y el resumen declara la latencia incremental «no medible»; los presupuestos candidatos son valores observados, no contratos. Las asignaciones de memoria no se miden. En la serie de resolución, `lines` es el tamaño en bytes de los paquetes de la petición. `tool/e_pg_13.sh <directorio-nuevo>` orquesta la campaña (procedencia antes de compilar, diez procesos por serie, resumen y verificación) y nunca sobrescribe un directorio.

El comando `pg-verify <campaña.json>` valida una campaña de E-PG-03 o E-PG-04 con el protocolo `e-pg-2/1` antes de calcular nada: al menos diez procesos con identidad única, treinta muestras por proceso, resolución de reloj positiva, duraciones del candidato y del control distintas de cero, salida del candidato igual a la del control, una sola máquina y un experimento conocido. Una campaña con muestras ausentes, salida incorrecta o máquinas mezcladas no produce un resultado verde, y una salida distinta invalida la muestra aunque el candidato sea más rápido.

`pg-collect <E-PG-03|E-PG-04> <directorio> <proceso> <máquina>` mide un proceso independiente: por cada carga compila candidato y control (fuentes en `pg_workloads.rs`), toma treinta muestras ejecutando ambos en orden alternado, compara la salida textual y repite la ejecución del candidato con recolección forzada; guarda `<directorio>/<carga>/process-NN.json` con tiempos, resolución del reloj y la forma determinista (bytes de RI, bytes de objeto nativo, instancias y tiempo de compilación) y nunca sobrescribe. El proceso 0 de E-PG-03 también registra que la recursión polimórfica expansiva es rechazada por el límite tipado. `pg-summary <E-PG-03|E-PG-04> <directorio>` valida cada carga con las reglas de `pg-verify`, calcula la razón de medias por proceso con intervalo bootstrap del 95 % (2000 remuestreos, semilla 42) y escribe `summary.json` con el cumplimiento de cada umbral (recorrido ≤1,10×, llamada indirecta ≤1,25×, crecimiento del objeto como máximo proporcional al número de instancias); un umbral incumplido se informa, nunca se ajusta. `tool/e_pg_campaign.sh <experimento> <directorio-nuevo> <máquina>` orquesta la campaña con procedencia previa, compilación release y diez procesos. La carga de 100 combinaciones del protocolo no cabe en el límite de 64 instancias de una edición, por lo que las cargas genéricas son de 1, 10 y 60 combinaciones.

## 2. Guía operativa y ciclo de vida

Rust exacto del workspace. `cargo run --release -p pseudolearn_bench_worker -- frontend` emite treinta muestras
por configuración como JSONL, incluidas cargas independientes `unicode-identifiers-{es,en}-{strict,flexible}`
con alfabeto español y usos NFC compuestos y descompuestos. Miden el análisis completo del API sobre el
caso Unicode; sus tiempos incluyen escaneo, parser y análisis semántico. `cargo run --release -p pseudolearn_bench_worker -- aot <directorio-nuevo> <techo-raw.json> <resumen-vm.json>` recoge el experimento del código nativo; requiere `rustc` y un enlazador del sistema, y compila un lanzador por carga contra la biblioteca `pseudolearn_aot_rt` del mismo perfil. `cargo xtask verify` comprueba la herramienta con el motor. No se despliega.

La orden `bridge` lee por stdin una configuración de escenarios de API y treinta iteraciones. Cada
iteración crea una sesión nueva; `setup` y `verify` quedan fuera del reloj y `timed` publica una latencia
por llamada. Los vínculos `$nombre.campo` conservan identidades reales y las repeticiones tienen límite.
Las expectativas son datos independientes y una discrepancia aborta el trabajador. No hay FFI en este
trabajador: permite contrastarlo con el trabajador Dart que consume el transporte generado.

## 3. Arquitectura y modelo del sistema

Tooling. Importa `pseudolearn_api`, `pseudolearn_bytecode`, `pseudolearn_vm`, `pseudolearn_timeline`, serde_json y estándar: `e06` necesita crear máquinas y líneas temporales para medirlas, y el resto de órdenes solo usa la API. Prohibido importar otros internos del motor.
`src/workloads.rs` prepara fuentes desde la exportación; `src/frontend.rs` mide; `src/main.rs` presenta resultados. `src/corpus.rs` lee las diez cargas AWFY de medición; `src/aot/` contiene el experimento del código nativo: `emission` (tiempo de emisión), `launcher` y `launcher.template` (lanzador enlazado con el objeto), `measurement` (proceso y muestras), `baseline` (techo nativo y máquina virtual), `summary` (razones por familia, intervalos y criterios) y `statistics`; `src/e06/` contiene un módulo por métrica, estadística (percentil, media geométrica, pendiente con intervalo al 95 %) y el informe.
El análisis crea estado nuevo por muestra. Ninguna entrada o salida ocurre dentro del intervalo.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: excluir la conciliación final oculta trabajo de las asignaciones nativas. Elección: el intervalo versión 2 incluye entrada y `settle_session`; el tiempo de entrada se conserva por separado. El resumen identifica versión, nivel Cranelift, denominador V1F y umbral 1,70. Los registros sin versión conservan el intervalo histórico y umbral 1,30; mezclar versiones se rechaza. Se descarta reinterpretar resultados históricos o quitar la muestra VM entre parejas.

Problema: una captura histórica no permite emparejar variantes por proceso. Elección: `paired/` prepara y enlaza el trabajador `pseudolearn_native_probe`, alterna el orden y conserva la configuración, el objeto y el lanzador por carga. Captura hashes antes de compilar el runtime y los objetos medidos, conserva treinta tiempos de emisión por carga, resolución observada y candidatos de cambio. Se descarta reemplazar las capturas E-NR1 o interpretar el intervalo de medias como intervalo de medianas. La latencia VM se toma sobre la API preparada y conserva dentro del intervalo su creación de máquina.

Problema: el arranque de una CLI y la serialización no son coste de análisis. Elección: llamadas directas
a la API en un proceso trabajador. Fuentes generadas por vocabulario del corpus, con terminadores y
validación previa de su análisis. Se descartan programas con lexemas manuales o sin comprobar el resultado.

E-06 se mide con la máquina real, sin constantes: el gemelo rápido se avanza en bloques de 1 024 instrucciones y el anfitrión consulta al planificador solo entre bloques, para no atribuir a la línea temporal el coste de sondear en cada paso. Los deltas por evento son el consumo incremental del búfer de cambios del gemelo sondeado (solo las entradas nuevas desde el evento anterior), y el criterio de independencia de la profundidad regresa la diferencia pareada con y sin deltas, que aísla el coste de los deltas del efecto de caché de una pila mayor. El criterio de memoria compara los bytes residentes añadidos por la grabación con la huella residente del montón vivo (palabras y descriptores), medida en dos procesos hijos; la razón respecto a las palabras solas se publica aparte. El coste de un punto con pila profunda se verifica con el número de ranuras copiadas para un mismo intervalo ejecutado a 1 000 y a 100 000 marcos. Las cargas AWFY de medición son cortas: en ellas solo se toma el punto inicial, de modo que la media geométrica del observador en pausa acota el coste del punto base y no el de una grabación sostenida; la grabación sostenida se ejercita en la métrica de memoria retenida (10⁹ sentencias).
La captura de procedencia y la orquestación externa preceden a compilar el trabajador final; el trabajador
solo produce tiempos crudos y conteos para validar muestras. Un perfil del sistema se realiza en una sesión
separada de la captura normativa para no contaminar las muestras.

Problema: un ejecutable compilado ejecuta el programa una sola vez y el arranque del proceso es mayor que la carga. Elección: el lanzador enlaza el mismo objeto que produce el generador y llama a su función principal repetidamente dentro de un proceso, con estado nuevo creado antes del cronómetro; la medición no incluye arranque, entrada ni salida. Descartado: cronometrar el proceso completo, que mide el sistema operativo, y enlazar el punto de entrada de producto, que no permite repetir la ejecución. El intervalo de confianza remuestrea las medias por proceso de ambos lados de forma independiente (semilla fija, 2 000 remuestreos), porque el techo nativo y el código generado no comparten proceso; la comparación no está emparejada y así se declara.

Problema: una campaña de ayuda no puede juzgarse con el mismo código que se mide. Elección: el oráculo (`oracle.rs`, `scanner.rs`) toma lexemas e identidades de la exportación del corpus y recorre cada programa con un escáner de palabras propio, sin lexer del motor; solo cubre palabras reservadas y funciones de una sola palabra (compuestas, operadores simbólicos y literales textuales quedan fuera y se declaran), y trata los programas cuyo nombre declara un nombre no reservado como sombreado de incorporadas. Las consultas se validan fuera del reloj; la serie caliente prepara sesión nueva por muestra y mide la API, el núcleo y el render por separado; la serie fría incluye apertura, consulta y liberación. El resumen usa semilla 42, bootstrap sobre procesos, candidatos de cambio con los umbrales del protocolo y resolución del reloj; `verify` invalida la campaña ante una respuesta incorrecta, una muestra o un proceso faltante, un reloj sin resolución, un resumen alterado o un crudo modificado (huella FNV-1a de 64 bits: detecta alteraciones accidentales, no manipulaciones adversarias). La campaña funcional no incluye la aplicación: esa consulta la cubre el sujeto `app`.

### E-PG-05: sobrecoste de la infraestructura de capacidades y cinta inactiva (2026-10-27)

Método. Control: el árbol de `5f6b4b9` extraído con `git archive` a un directorio temporal (sin tocar el árbol de
trabajo), con la exportación del corpus actual sin la instrucción `effect_call` (la exportación de ese commit no se
regenera aislada) y compilado con `cargo build --release --offline`. Candidato: el árbol de trabajo
(`cf4fd3a` más cambios sin confirmar), compilado con `cargo build --release --locked`. Ambos ejecutan `execute` sobre
`PERF.SUITE.CORE` (10 cargas), 30 iteraciones por proceso, 10 procesos por lado alternando el orden (control primero en
los procesos pares). Estadística: razón de medias candidato/control por carga con bootstrap jerárquico (procesos y luego
muestras, 2000 remuestras, semilla 20261027, intervalo del 95 %). Se conservan binarios, sumas SHA-256, plataforma
(Apple M2, macOS 27.0.1, `rustc 1.99.0`), muestras y resumen en `packages/pseudolearn_spec/results/pg-3-campaign-2026-10-27/`.

Resultado. Media geométrica de las razones: 1,0001 (cumple el umbral de 1,02). Por carga: bounce 1,027 [1,020; 1,034],
list 1,025 [1,015; 1,033], richards 1,060 [1,041; 1,076], sieve 0,991 [0,874; 1,124], nbody 1,004, queens 0,997,
towers 0,998, mandelbrot 0,986, storage 0,985, permute 0,935. El límite superior del intervalo supera 1,02 en cuatro cargas
(bounce, list, richards y sieve; esta última con un intervalo muy ancho), de modo que el umbral inicial por carga **no se cumplió**;
no se investigó la causa. Se publica el resultado aunque refute. Decisión (2026-10-27, autorizada por la persona): la
estimación inicial era especulativa, así que el presupuesto por carga se sube a razón puntual `≤ 1,08` y límite superior
del IC 95 % `≤ 1,15`; la media geométrica conserva `≤ 1,02`. Con ese presupuesto la medición cumple (máximos: richards
1,060 y sieve 1,124). Las microoptimizaciones, empezando por richards, se hacen al final del lenguaje.

Crecimiento de artefactos. `pseudolearn_bench_worker` release: 8 634 144 → 9 218 480 bytes (+6,8 %). No se midió
el crecimiento de la biblioteca estática nativa ni del puente por falta de control compilado.

Cargas de efectos (caracterización, no protocolo completo: 1 proceso, 5 repeticiones, mediana y rango). Reloj: 61–62 µs por
efecto, 552 B de cinta por entrada (100, 1 000 y 10 000 efectos). Archivo de 64 B: 62–69 µs por efecto, 920 B por entrada.
Archivo de 4 KiB: 24–25 KB por entrada (la carga se serializa como lista decimal de octetos, unas seis veces su tamaño), por
lo que con 1 000 y 10 000 lecturas el presupuesto de 16 MiB se agota a las 669 entradas y la cinta se sella como truncada
sin interrumpir la ejecución. Pendiente declarado: una codificación compacta de la carga reduciría seis veces la cinta.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, unsafe ni pánicos explícitos. Límites del workspace. Fallos como Result.

## 6. Decisiones de producto que condicionan el código

PERF.PROTOCOL define muestras y criterios. Las mediciones no relajan umbrales.

## 7. Verificación, testing y aseguramiento de calidad

Tests espejo: el experimento nativo se prueba con un lanzador real (enlace, treinta iteraciones y aborto ante una salida incorrecta), con el análisis del techo y de la máquina virtual (incluida la ausencia de línea base), con los informes de muestras (cortos o malformados) y con el resumen (familia sobre el umbral, emisión lenta, máquina más rápida, intervalo reproducible, entradas ausentes); cargas válidas e incompletas, salida incorrecta rechazada y corpus ausente o malformado. La estadística de E-06 y el veredicto del informe tienen casos negativos: un informe con una métrica fallida, ausente o sin veredicto no es verde.
La conformidad del motor se ejecuta aparte; el trabajador no convierte sus resultados en esperados del lenguaje.

## 8. Fuentes consultadas y genealogía conceptual

Corpus de rendimiento del monorepo. Se conserva la separación entre procesos independientes y rondas internas.
