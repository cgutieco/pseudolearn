# ceiling

## 1. Qué es y qué no es

Arnés desechable E-02 del techo semántico de diez algoritmos AWFY-core. Compara Rust idiomático V0, semántica comprobada V1, representación paginada V2 y puntos de control activos V3. No implementa el motor ni ofrece una biblioteca para consumidores. Los diez núcleos, sus cuatro variantes, la recolección y sus tests están implementados; la evidencia se conserva junto al arnés Dart. No hay pendientes de implementación.

## 2. Guía operativa y ciclo de vida

Rust exacto de rust-toolchain.toml, rustfmt, Clippy y cargo-deny. Desde esta carpeta: `cargo xtask verify`; `cargo run --release -p ceiling_runner -- collect`. El recolector captura procedencia antes de compilar el trabajador release. Resultados en ../results/e02. Recolección local en macOS Apple M2; los núcleos y sus verificadores no dependen de ese hardware. Sin despliegue ni secretos.

## 3. Arquitectura y modelo del sistema

| Capa | Responsabilidad | Imports permitidos | Prohibido |
|---|---|---|---|
| ceiling_kernels | Algoritmos experimentales | estándar | estadísticas, runner, motor |
| ceiling_statistics | Estadística independiente | estándar | núcleos, procesos |
| ceiling_runner | Recolección por procesos | kernels, statistics, serde_json | motor |
| xtask | Verificaciones | estándar, verificadores por proceso | lógica de cargas |

Las dependencias y límites viven en architecture.yaml. Una máquina nueva por muestra, sin concurrencia durante las mediciones. checked contiene algoritmos parametrizados por Arithmetic, Heap y Calls. direct representa V1; clepsydra y clepsydra_memory representan V2/V3; paged_heap contiene páginas de 4096 palabras; timeline retiene puntos de control.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: aislar semántica de representación. Elección: V1–V3 comparten algoritmos monomorfizados; V0 usa estructuras idiomáticas. Se descarta comparar algoritmos diferentes. Problema: congelar memoria sin copiar todo. Elección: asas u32, barrera de época, Rc por página, bancos separados y trampas diferidas hasta efectos; V3 conserva puntos cada milisegundo aproximado. Se descarta atribuir a la futura VM los tiempos de estos núcleos compilados. Los bancos se reservan antes de cronometrar; cada repetición reinicia el estado lógico y su montón.
El intervalo medido incluye el núcleo y su salida en memoria; la comparación y toda I/O ocurren fuera.
Se acumulan repeticiones completas hasta 5 ms para superar la resolución del reloj.
V3 exige además al menos un punto real por muestra; sin él tras un segundo devuelve error.
El reloj se consulta tras 4096 pasos o llamadas; la resolución mínima observada se publica en la captura.
V3 guarda páginas, porción activa de ambos bancos, profundidad y ordinal; retiene hasta 64 puntos.
El código nativo experimental no serializa una continuación de la CPU ni implementa reproducción de la VM.
Problema: ruido entre procesos. Elección: diez procesos, treinta muestras, bootstrap emparejado al 95 %, sin descartar muestras; procedencia previa a compilación.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, unsafe, índices que puedan entrar en pánico ni conversiones numéricas con pérdida. Fallos como Result; límites leídos de architecture.yaml. Tests externos en tests/ espejo de src/.

## 6. Decisiones de producto que condicionan el código

La salida esperada procede de PERF.SUITE.AWFY-CORE exportado. No se captura desde una variante. V2/V1 superior a 1,30 en una familia impone revisión del diseño de memoria antes de R5; el resultado desfavorable se conserva.

## 7. Verificación, testing y aseguramiento de calidad

cargo xtask verify ejecuta formato, Clippy, tests, cargo-deny y los verificadores del monorepo. Tests de resultados de los diez algoritmos y tamaños contra el corpus, desbordamiento, división por cero, índice inválido, tamaño cero, memoria compartida y puntos de control. El recolector rechaza muestras incompletas y salidas incorrectas.

## 8. Fuentes consultadas y genealogía conceptual

PERF.PROTOCOL define la metodología; PERF.SUITE.AWFY-CORE define algoritmos y controles. AWFY aporta los algoritmos bajo MIT, con aviso en el README del paquete padre. Se descarta adoptar resultados de rendimiento de otras máquinas o lenguajes.
