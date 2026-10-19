# pseudolearn_bench_worker

## 1. Qué es y qué no es

Mide cargas de la API pública en proceso. Herramienta local; no es una capa del producto ni un sujeto de conformidad.
El comando `execute` prepara las diez cargas AWFY de medición desde la exportación y emite treinta muestras por carga; valida salida y terminación fuera del intervalo. El comando `e06` mide las ocho métricas de la línea temporal (observador en pausa, coste de los deltas por evento, independencia de la profundidad, coste de un punto con pila profunda, latencia de paso observado, latencia de retroceso, memoria retenida y memoria residente con grabación) y emite un único documento JSON con muestras crudas, veredicto por métrica y `all_passed` calculado. Pendiente: la orquestación en diez procesos del arnés Dart; hoy cada métrica se toma en un único proceso con treinta iteraciones.

El comando `aot <directorio>` mide el código nativo generado con `pseudolearn_codegen` sobre las mismas diez cargas: por cada carga emite el objeto sin punto de entrada con `build_benchmark_object` (treinta emisiones cronometradas), enlaza un lanzador propio con el objeto y la biblioteca del runtime, y ejecuta diez procesos de treinta iteraciones cada uno. Cada iteración crea una sesión nueva fuera del intervalo, cronometra solo la llamada a la función principal y verifica salida y estado después; una salida distinta aborta el proceso. Compara con el techo nativo con marcos de la captura `results/e02r` y con la máquina virtual de `results/macos-r5-vm`, y escribe `raw.json` y `summary.json`.

El comando `paired <directorio-nuevo>` enlaza un trabajador con el mismo objeto AOT y V1F. Conserva parejas reales, medianas por carga y bootstrap de medias por proceso identificado separadamente. Rechaza sobrescribir evidencias. `paired-summary <directorio>` recalcula el resumen sin ejecutar cargas ni modificar los crudos.

`paired-probe <directorio-nuevo>` ejecuta las seis cargas de diagnóstico con contadores separados, escala Storage en profundidades 3–6 y conserva un perfil del proceso de Storage. Sus tiempos instrumentados no sirven para declarar N3.

El comando `service` mide las herramientas de edición: `service e09 <salida> [mediciones]` evalúa el autocompletado sobre los programas de referencia (cada identificador, palabra clave o función estándar de al menos tres caracteres se consulta con prefijo de cero y de dos caracteres sobre el documento truncado), calcula precisión en 1 y en 5, ahorro de pulsaciones y validez de plantillas, y mide la latencia en un documento de diez mil líneas; `service incremental <salida> [mediciones]` mide la latencia de una edición de cuerpo en documentos de mil y de diez mil líneas; `service e20 <binario pseudo> <salida>` mide el arranque y la latencia de `comprobar`, `ejecutar`, `compilar`, `formatear`, `traducir` y `lsp`. Los umbrales se leen de los contratos exportados, el resultado de umbral incumplido termina con error y las mediciones se registran en `results/measurement-conformance.json`.

## 2. Guía operativa y ciclo de vida

Rust exacto del workspace. `cargo run --release -p pseudolearn_bench_worker -- frontend` emite treinta muestras
por configuración como JSONL. `cargo run --release -p pseudolearn_bench_worker -- aot ../../../pseudolearn_benchmarks/results/r6-aot` recoge el experimento del código nativo; requiere `rustc` y un enlazador del sistema, y compila un lanzador por carga contra la biblioteca `pseudolearn_aot_rt` del mismo perfil. `cargo xtask verify` comprueba la herramienta con el motor. No se despliega.

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

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, unsafe ni pánicos explícitos. Límites del workspace. Fallos como Result.

## 6. Decisiones de producto que condicionan el código

PERF.PROTOCOL y PERF.FRONTEND.THROUGHPUT definen muestras y criterios. Las mediciones no relajan umbrales.

## 7. Verificación, testing y aseguramiento de calidad

Tests espejo: el experimento nativo se prueba con un lanzador real (enlace, treinta iteraciones y aborto ante una salida incorrecta), con el análisis del techo y de la máquina virtual (incluida la ausencia de línea base), con los informes de muestras (cortos o malformados) y con el resumen (familia sobre el umbral, emisión lenta, máquina más rápida, intervalo reproducible, entradas ausentes); cargas válidas e incompletas, salida incorrecta rechazada y corpus ausente o malformado. La estadística de E-06 y el veredicto del informe tienen casos negativos: un informe con una métrica fallida, ausente o sin veredicto no es verde.
La conformidad del motor se ejecuta aparte; el trabajador no convierte sus resultados en esperados del lenguaje.

## 8. Fuentes consultadas y genealogía conceptual

Corpus de rendimiento del monorepo. Se conserva la separación entre procesos independientes y rondas internas.
