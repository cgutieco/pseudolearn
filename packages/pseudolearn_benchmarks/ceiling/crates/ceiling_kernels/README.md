# ceiling_kernels

## 1. Qué es y qué no es

Algoritmos experimentales parametrizados por representación. Sin consumidores fuera del experimento.

## 2. Guía operativa y ciclo de vida

Desde el workspace: `cargo test -p ceiling_kernels` y `cargo xtask verify`. Sin despliegue.

## 3. Arquitectura y modelo del sistema

Capa ceiling_kernels; dependencias: biblioteca estándar. Sin acceso al motor ni al núcleo Dart. Reglas en architecture.yaml del workspace.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: aislar semántica de representación. Elección: V1–V3 comparten algoritmos monomorfizados; V0 usa estructuras idiomáticas. Se descarta comparar algoritmos diferentes. Problema: congelar memoria sin copiar todo. Elección: asas u32, barrera de época, Rc por página, bancos separados y trampas diferidas hasta efectos; V3 conserva puntos cada milisegundo aproximado. Se descarta atribuir a la futura VM los tiempos de estos núcleos compilados. Problema: ruido entre procesos. Elección: diez procesos, treinta muestras, bootstrap emparejado al 95 %, sin descartar muestras; procedencia previa a compilación.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, unsafe, índices que puedan entrar en pánico ni conversiones numéricas con pérdida. Fallos como Result; límites leídos de architecture.yaml. Tests externos en tests/ espejo de src/.

## 6. Decisiones de producto que condicionan el código

La salida esperada procede de PERF.SUITE.AWFY-CORE exportado. No se captura desde una variante. V2/V1 superior a 1,30 en una familia impone revisión del diseño de memoria antes de R5; el resultado desfavorable se conserva.

## 7. Verificación, testing y aseguramiento de calidad

cargo xtask verify ejecuta formato, Clippy, tests, cargo-deny y los verificadores del monorepo. Tests de resultados de los diez algoritmos y tamaños contra el corpus, desbordamiento, división por cero, índice inválido, tamaño cero, memoria compartida y puntos de control. El recolector rechaza muestras incompletas y salidas incorrectas.

## 8. Fuentes consultadas y genealogía conceptual

PERF.PROTOCOL define la metodología; PERF.SUITE.AWFY-CORE define algoritmos y controles. AWFY aporta los algoritmos bajo MIT, con aviso en el README del paquete padre. Se descarta adoptar resultados de rendimiento de otras máquinas o lenguajes.
