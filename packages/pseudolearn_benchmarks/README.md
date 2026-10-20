# pseudolearn_benchmarks

## 1. Qué es y qué no es

Recolectores de rendimiento del núcleo Rust, herramientas estadísticas y archivo de líneas base.
El corpus define programas, resultados esperados y presupuestos. Los recolectores verifican resultados;
no convierten salidas del motor en oráculos. Los ejecutores del sujeto histórico están retirados.
Las capturas de `results/` conservan procedencia y crudos, incluidos resultados desfavorables.

## 2. Guía operativa y ciclo de vida

Requisitos: Dart aportado por Flutter fijado en la app; Node fijado en `node-version`; Rust exacto de
cada miembro. Desde este directorio: `dart pub get`, `dart test`,
`dart analyze --fatal-infos --fatal-warnings` y `dart run tool/check.dart`.
Formato: `dart format --output=none --set-exit-if-changed lib tool test`.

- `dart run tool/collect_frontend.dart <directorio>` mide análisis mediante el trabajador público Rust.
- `dart run tool/collect_execution.dart <directorio>` mide ejecución preparada con la línea base archivada.
- `dart run tool/summarize.dart <directorio>` recalcula estadísticas históricas sin ejecutar sujetos retirados.
- `dart run tool/capture_bridge_artifacts.dart` inspecciona artefactos previamente construidos; no los genera.
- Desde `ceiling/`: `cargo xtask verify` y `cargo run -p ceiling_runner -- collect`.
- Desde el motor: `cargo run --release -p pseudolearn_bench_worker -- paired <directorio-nuevo>` compara
  AOT y el techo Rust; `paired-summary <directorio>` recalcula sus estadísticas.

Las campañas de plataforma y del puente se ejecutan separadamente cuando exista autorización para
medir macOS e iOS. Las comprobaciones de artefactos y la generación de informes no son un despliegue.

El ejecutor del puente se prepara con `dart run tool/create_bridge_campaign.dart <campaña-nueva.json>`
y se ejecuta con `dart run tool/collect_bridge.dart <campaña.json> <directorio-nuevo>`. La configuración
incluye preparación de binarios, trabajador de API directa y trabajador Dart con FFI generado y modelo
visible. Captura procedencia antes de compilar, alterna orden por proceso, exige diez procesos y treinta
iteraciones, conserva errores y rechaza muestras incompletas o duplicadas. Las expectativas se evalúan
fuera del reloj. La suite consume AWFY del corpus, Fibonacci de veinte, alias, ciclos, arreglos, entrada,
cancelación, salida abundante, consulta retenida y completado de diez mil líneas. El modelo visible mide
un paso preparado y comprueba fuera del reloj que Fibonacci termina con el resultado normativo.

Cada escenario declara `setup`, `timed`, `verify` y expectativas independientes por ruta. Los resultados
se pueden enlazar mediante `$nombre.campo`; las repeticiones son acotadas y solo terminan al satisfacer
su condición. Cada iteración crea sesión nueva. El informe publica p50/p95, MAD/IQR e intervalo del 95 %
de medias por proceso con semilla fija, sin descartar muestras ni afirmar estacionariedad. La captura
de fotogramas se incorpora desde la prueba de plataforma: su ausencia impide certificar el experimento.
No se confunde el resultado del modelo preparado con tiempo de renderizado ni con latencia por evento.

## 3. Arquitectura y modelo del sistema

| Capa | Responsabilidad | Puede importar |
|---|---|---|
| model | Cargas y muestras | SDK Dart |
| suite | Cargas y controles independientes | model |
| tooling | Recolectar, verificar y resumir | model, suite, SDK, analyzer y yaml |

`architecture.yaml` declara capas y límites. No existe una capa de ejecución del lenguaje en Dart.
`measurement_environment.dart` captura procedencia y muestrea procesos; los trabajadores Rust o del
puente realizan las operaciones medidas. `ceiling/` es un workspace experimental independiente.

## 4. Decisiones de diseño y fundamentos técnicos

**Medir dentro del trabajador.** El arranque del proceso y la preparación no representan el coste del
motor. El trabajador prepara estado antes del reloj, mide operaciones declaradas y verifica después.
El recolector captura procedencia antes del build y conserva muestras crudas. Se descarta cronometrar
una CLI completa para atribuir su latencia al análisis o a la VM.

**Conservar líneas base.** El retiro de un ejecutor no invalida sus observaciones históricas, pero estas
no certifican fuentes nuevas. Los datos y resúmenes permanecen disponibles sin reconstruir el sujeto.
Se descarta sobrescribir resultados desfavorables o presentar una comparación histórica como campaña actual.

**Estadística explícita.** Los procesos son las unidades independientes. Se informa el estimador del
intervalo, p95, resolución y candidatos de cambio; todas las muestras se conservan. Un intervalo de
medias no certifica una razón de medianas. El experimento AOT alterna el orden de las parejas, crea
estado nuevo y comprueba salidas antes y durante la captura.

**Fronteras diferentes.** La API directa, la transferencia FFI, el modelo visible y el fotograma son
intervalos distintos. Dividir tiempo de lote entre eventos no mide la latencia de una pulsación.
Las pruebas locales de protocolo no sustituyen mediciones físicas ni de distribución.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés sin comentarios; documentación en español. Máximos: 300 líneas por archivo,
40 por función, cuatro parámetros posicionales, tres niveles de anidación y siete métodos públicos.
Los imports respetan las capas y las herramientas no modifican el motor medido.

## 6. Decisiones de producto que condicionan el código

Los presupuestos pertenecen a `PERF.*`. Un resultado incumplido se conserva como tal; no se ajusta el
umbral desde el arnés. Las muestras proceden de estado nuevo, semillas fijadas y resultados derivados
del contrato. Las mediciones futuras no mezclan máquinas ni capturas independientes para atribuir coste FFI.

## 7. Verificación, testing y aseguramiento de calidad

Las pruebas espejo cubren lectura del corpus, entradas inválidas, estadísticas, campañas incompletas,
artefactos y verificadores negativos. Las cargas de lenguaje se prueban por conformidad en Rust;
no se mantiene una segunda suite de interpretación en Dart.
Los informes distinguen pruebas automatizadas, métricas históricas y mediciones todavía no realizadas.

`dart run tool/summarize_bridge.dart <raw.json>` recalcula percentiles, dispersión, candidatos de cambio y cocientes desde los crudos, sin ejecutar procesos de medición.

El resumen empareja puente y directo por escenario, operación y ordinal de proceso, y reutiliza el estimador geométrico por familia con bootstrap reproducible. El modelo de app se informa aparte porque no tiene una operación directa equivalente. Una media no positiva impide calcular un cociente para esa familia y se conserva señalada, sin eliminar sus crudos ni inventar un coste nulo.

La procedencia identifica fuentes antes del build y artefactos release después del build mediante tamaño y SHA-256, junto con `rustc -vV` y los comandos exactos. Los trabajadores publican el menor incremento positivo observado del reloj, medido fuera del intervalo; no se presenta como garantía física de precisión. Los datos de fotogramas se mantienen ausentes hasta su captura en plataforma.

El escenario de modelo Fibonacci configura explícitamente un presupuesto de un millón de pasos en `StepBatchRunner`; el límite interactivo predeterminado de la app sigue siendo diez mil. Esto permite comprobar la finalización en el arnés, sin certificar la experiencia física ni ocultar esa configuración.

Los trabajadores admiten `mode: "smoke"` con una única iteración funcional. El smoke automatizado de la app reduce solo la recursión del modelo a Fib(4), con resultado matemático 3, para verificar sus claves y flujo sin ejecutar la campaña Fib(20). Estas pruebas comprueban claves y expectativas de los escenarios; sus duraciones no integran mediciones ni certificaciones de plataforma. El recolector exige todas las operaciones previstas y rechaza una salida que omita consultas completas.

## 8. Fuentes consultadas y genealogía conceptual

La suite AWFY-core selecciona diez algoritmos compatibles con el lenguaje vigente. Sus programas y
controles se consumen desde la exportación del corpus. Los estimadores y presupuestos proceden de
`PERF.PROTOCOL`; la variabilidad de hardware y la estacionariedad no demostrada se declaran en cada captura.
