# ceiling_kernels

## 1. Qué es y qué no es

Algoritmos experimentales parametrizados por representación. Sin consumidores fuera del experimento.

## 2. Guía operativa y ciclo de vida

Desde el workspace: `cargo test -p ceiling_kernels` y `cargo xtask verify`. Sin despliegue.

## 3. Arquitectura y modelo del sistema

`collection` contiene prototipos de gestión sobre palabras planas: listas por tamaño, líneas no móviles
y conteo de referencias diferido con borrado de prueba. Los tres ejecutan los mismos algoritmos y reciben
las mismas raíces de marco. Cada asignación conserva su resultado como local del marco; al retornar se
retiran esas raíces. Un resultado conservado por el llamador se registra explícitamente antes de otra
asignación. Las raíces no dependen del candidato. La recolección usa un calendario común por celdas
asignadas y los puntos diferenciales uno por cantidad fija de operaciones.

Capa ceiling_kernels; dependencias: biblioteca estándar. Sin acceso al motor ni al núcleo Dart. Reglas en architecture.yaml del workspace.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: elegir una política de recuperación requiere medir también la perturbación de la sombra.
Elección: cada candidato registra pausas en tiempo y palabras, memoria pico y bloques cambiados por
punto de 64 palabras. La ejecución ordinaria y la forzada deben conservar resultados independientes.
Los experimentos son propietarios de sus prototipos; el motor implementa solo la política seleccionada.
Se descarta usar estos tiempos como evidencia de velocidad de la VM.

Problema: aislar semántica de representación. Elección: V1–V3 comparten algoritmos monomorfizados; V0 usa estructuras idiomáticas. Se descarta comparar algoritmos diferentes. Problema: congelar memoria sin copiar todo. Elección: asas u32, barrera de época, Rc por página, bancos separados y trampas diferidas hasta efectos; V3 conserva puntos cada milisegundo aproximado. Se descarta atribuir a la futura VM los tiempos de estos núcleos compilados. Problema: ruido entre procesos. Elección: diez procesos, treinta muestras, bootstrap emparejado al 95 %, sin descartar muestras; procedencia previa a compilación.


Problema: comparar acceso paginado con acceso plano requiere el mismo coste de llamadas.
Elección: el experimento de revalidación conserva V0–V3 e incorpora V1F con los bancos de V2,
V2R con montón contiguo, asignación en bloques puestos a cero, trampas inmediatas y combustible,
V2R sin comprobación de índice del lenguaje como cota experimental, V3R con sombra diferencial
sin barrera y V3R con tarjetas. Ninguna variante se usa como implementación del motor.
Las políticas de observación se monomorfizan: la diferencial no ejecuta código por escritura;
la de tarjetas marca el bloque modificado. Los puntos comparan bloques de 64 palabras,
retienen contenido antiguo y copian los bancos activos; la captura queda acotada a 64 puntos.
El combustible persiste entre repeticiones de una muestra y se exige al menos un punto real
por muestra observada. Reiniciar una repetición borra el estado lógico, no el contador de muestras.
El asignador avanza sobre bloques de 4096 palabras inicializados de una vez, sin reservar por objeto.
Alternativas descartadas: V1 sin marcos como denominador de llamadas, muestras sin puntos reales,
reemplazar resultados antiguos o atribuir rendimiento de estos núcleos nativos a la VM.
La revalidación se ejecuta con `cargo run --release -p ceiling_runner -- collect-remanso`;
los resultados se conservan en `../results/e02r/`, con diez procesos y treinta iteraciones.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, unsafe, índices que puedan entrar en pánico ni conversiones numéricas con pérdida. Fallos como Result; límites leídos de architecture.yaml. Tests externos en tests/ espejo de src/.

## 6. Decisiones de producto que condicionan el código

La salida esperada procede de PERF.SUITE.AWFY-CORE exportado. No se captura desde una variante. V2/V1 superior a 1,30 en una familia impone revisión del diseño de memoria antes de R5; el resultado desfavorable se conserva.

## 7. Verificación, testing y aseguramiento de calidad

cargo xtask verify ejecuta formato, Clippy, tests, cargo-deny y los verificadores del monorepo. Tests de resultados de los diez algoritmos y tamaños contra el corpus, desbordamiento, división por cero, índice inválido, tamaño cero, memoria compartida y puntos de control. El recolector rechaza muestras incompletas y salidas incorrectas.

## 8. Fuentes consultadas y genealogía conceptual

PERF.PROTOCOL define la metodología; PERF.SUITE.AWFY-CORE define algoritmos y controles. AWFY aporta los algoritmos bajo MIT, con aviso en el README del paquete padre. Se descarta adoptar resultados de rendimiento de otras máquinas o lenguajes.
