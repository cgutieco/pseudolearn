# pseudolearn_native_probe

## 1. Qué es y qué no es

Trabajador experimental que compara el objeto AOT con V1F dentro del mismo proceso. No pertenece al producto ni certifica conformidad del lenguaje por sí solo. No implementa otro techo ni modifica los algoritmos de ceiling.

## 2. Guía operativa y ciclo de vida

Se construye como biblioteca estática mediante el trabajador `pseudolearn_bench_worker paired <directorio>`. El lanzador C enlaza el objeto AOT con esta biblioteca. `cargo test -p pseudolearn_native_probe` comprueba los contratos de entrada y salida. La verificación completa pertenece al motor.

## 3. Arquitectura y modelo del sistema

Tooling independiente de las capas del producto. Importa `pseudolearn_aot_rt`, `pseudolearn_api`, `ceiling_kernels`, serde y serde_json. No importa generador, CLI ni fuentes de los sujetos. La frontera C recibe una función AOT y un documento de configuración; el resto es Rust seguro.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: excluir la conciliación final oculta trabajo de las asignaciones nativas. Elección: el intervalo versión 2 incluye entrada y `settle_session`; el tiempo de entrada se conserva por separado. El resumen identifica versión, nivel Cranelift, denominador V1F y umbral 1,70. Los registros sin versión conservan el intervalo histórico y umbral 1,30; mezclar versiones se rechaza. Se descarta reinterpretar resultados históricos o quitar la muestra VM entre parejas.

Problema: los perfiles agregados no distinguen mecanismos de memoria. Elección: la feature `telemetry`, desactivada por omisión, cuenta asignaciones, crecimiento de palabras, recolecciones, recorridos, copias de diseño y accesos o raíces de celdas según la responsabilidad del crate. Sus resultados pertenecen a sesiones diagnósticas separadas; el código de producto y la campaña normativa no contienen estos incrementos. Se descarta atribuir los tiempos instrumentados al rendimiento de producción.

Problema: procesos históricos no forman parejas experimentales. Elección: cada proceso ejecuta ambas variantes de cada iteración con orden alternado por proceso e iteración. Cada lado crea estado nuevo antes del reloj y valida su salida después. La variante 4 de ceiling sigue siendo el denominador V1F. Se descarta emparejar índices de capturas históricas.

Problema: la entrada y salida del sistema contaminan la ejecución. Elección: el AOT recibe un Cursor de entrada y un búfer de salida en memoria; la salida JSON del trabajador se escribe después de todas las muestras. El tiempo de cada variante incluye su cálculo y presentación del resultado en memoria. La VM se mide mediante `execute_prepared`, con compilación previa y creación de máquina dentro del intervalo, igual que su línea base de API; esta latencia se identifica separadamente del núcleo AOT/V1F. La creación y destrucción de sesión AOT quedan fuera; V1F crea bancos nuevos antes de cada intervalo. Se descarta reutilizar capacidad entre muestras de una variante solamente.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios. `bridge` recibe bytes de C; `measurement` administra parejas; `execution` prepara sesiones; `output` captura salida. Fallos como Result y rechazo del documento inválido con código distinto de cero.

### Invariantes de `unsafe`

| Función | Invariante | Garantía |
|---|---|---|
| `configuration_bytes` | El puntero es nulo o apunta a `count` bytes inicializados e inmutables durante la llamada | Rechaza nulo o tamaño cero y construye una vista de solo lectura |

## 6. Decisiones de producto que condicionan el código

La prueba conserva el cuerpo generado, sus trampas y el runtime del producto. No compila con matemática aproximada ni elimina límites. Una salida incorrecta invalida la pareja y aborta el proceso.

## 7. Verificación, testing y aseguramiento de calidad

Pruebas de configuración inválida, carga desconocida, resultado incorrecto, ejecución AOT fallida, salida capturada y alternancia de orden. El arnés exige conjuntos completos y finitos de muestras. La comparación normativa publica medianas y bootstrap emparejado de medias por proceso por separado.

## 8. Fuentes consultadas y genealogía conceptual

PERF.PROTOCOL y PERF.AOT.LEVEL fijan el contrato; ceiling_kernels conserva los algoritmos V1F. Se descarta alterar la línea base para facilitar el umbral.
