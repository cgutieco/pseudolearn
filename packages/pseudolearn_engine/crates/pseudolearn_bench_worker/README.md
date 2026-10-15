# pseudolearn_bench_worker

## 1. Qué es y qué no es

Mide cargas de la API pública en proceso. Herramienta local; no es una capa del producto ni un sujeto de conformidad.
Pendiente: mediciones de ejecución, eventos y estado cuando la API correspondiente esté implementada.

## 2. Guía operativa y ciclo de vida

Rust exacto del workspace. `cargo run --release -p pseudolearn_bench_worker -- frontend` emite treinta muestras
por configuración como JSONL. `cargo xtask verify` comprueba la herramienta con el motor. No se despliega.

## 3. Arquitectura y modelo del sistema

Tooling. Solo importa `pseudolearn_api`, serde_json y estándar. Prohibido importar internos del motor.
`src/workloads.rs` prepara fuentes desde la exportación; `src/frontend.rs` mide; `src/main.rs` presenta resultados.
El análisis crea estado nuevo por muestra. Ninguna entrada o salida ocurre dentro del intervalo.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: el arranque de una CLI y la serialización no son coste de análisis. Elección: llamadas directas
a la API en un proceso trabajador. Fuentes generadas por vocabulario del corpus, con terminadores y
validación previa de su análisis. Se descartan programas con lexemas manuales o sin comprobar el resultado.
La captura de procedencia y la orquestación externa preceden a compilar el trabajador final; el trabajador
solo produce tiempos crudos y conteos para validar muestras. Un perfil del sistema se realiza en una sesión
separada de la captura normativa para no contaminar las muestras.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, unsafe ni pánicos explícitos. Límites del workspace. Fallos como Result.

## 6. Decisiones de producto que condicionan el código

PERF.PROTOCOL y PERF.FRONTEND.THROUGHPUT definen muestras y criterios. Las mediciones no relajan umbrales.

## 7. Verificación, testing y aseguramiento de calidad

Tests espejo: cargas válidas e incompletas, salida incorrecta rechazada y corpus ausente o malformado.
La conformidad del motor se ejecuta aparte; el trabajador no convierte sus resultados en esperados del lenguaje.

## 8. Fuentes consultadas y genealogía conceptual

Corpus de rendimiento del monorepo. Se conserva la separación entre procesos independientes y rondas internas.
