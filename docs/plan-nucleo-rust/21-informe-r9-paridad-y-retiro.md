# R9 · Paridad y retiro del núcleo Dart

Estado: **abierta**. No se certifican puertas pendientes ni se inicia la evolución del lenguaje.
La autorización incluye las correcciones de C4: evento 1, destino 1 y dos celdas sin valor.

## Qué se construyó

- El arranque inicializa el puente generado y compone exclusivamente servicios Rust mediante los puertos existentes. Los fallos de inicialización y liberación se comunican explícitamente.
- Se retiraron `packages/pseudolearn_core`, la composición Dart, sus adaptadores y pruebas de implementación, sus dependencias y ejecutores de rendimiento exclusivos. Los componentes compartidos independientes del motor se conservan. No se trasladó su parser, evaluador, AST ni tablas a otro consumidor.
- Verificadores de contenido, ejemplos bilingües, inicialización estricta, equivalencia estructural, diagramas y exportadores consumen la API Rust y `program_view`. Las pruebas vigentes ejercitan los adaptadores Rust.
- SEE acepta `estado: activo|retirado`, con activo por defecto. El archivo histórico de reference conserva manifiesto y resultados originales; su lanzamiento produce `SEE-SUBJECT-RETIRED`, su matriz vigente indica no aplicable y no cuenta como sujeto activo para estabilidad.
- Se actualizaron validación, matriz, diferencial entre sujetos activos, xtask y workflows de publicación. Una puerta con negativos rechaza dependencias operativas del núcleo retirado en la app y CI.
- C9 alcanza una división real por cero; conserva y consulta un estado anterior al fallo. C4 consulta el arreglo que realmente existe. C5 aísla el cursor inválido y C6/C7 cubren destino y evento inválidos.
- El registro de propiedades compara todos los eventos mediante SHA-256 incremental, cantidad e identidades normalizadas biyectivamente, además de salida, terminación, diagnósticos y consumo de entrada. No recorta programas ni sustituye límites. La navegación histórica también se ejecuta sin capturar snapshots.
- El ejecutor de `CLI.IR/P1` usa el proceso real de la CLI para emitir RI, validarla y reimprimirla. El contrato de revisión sucesora invalida recursos del documento anterior y conserva documentos independientes.
- El ejecutor reproducible de E-NR2 genera escenarios desde el corpus, valida cada operación, alterna variantes, conserva registros y procedencia, calcula intervalos por proceso y razones pareadas. Se conservan los recolectores Rust y las herramientas estadísticas. No se lanzó su campaña de plataforma.
- Se actualizaron AGENTS, el README raíz, los README afectados y la skill de documentación. Lock y exportación se regeneran con SEE; las versiones numéricas se conservan por autorización.

## Resultado de los tests

| Miembro | Resultado local ejecutado |
|---|---|
| Motor Rust | 871 tests; puerta completa `cargo xtask verify` en verde |
| SEE | 188 tests; formato, Clippy y verificadores en verde |
| CLI | 41 tests; formato, Clippy y verificadores en verde; auditoría posterior satisfactoria con la base local |
| Puente nativo | 11 tests; formato y Clippy en verde; auditoría posterior satisfactoria con la base local |
| Verificadores Rust | 47 tests; puerta completa en verde |
| Experimento de techos | 30 tests; puerta completa en verde |
| Benchmarks | 29 tests, análisis y verificador en verde |
| Marca | 88 tests y verificadores en verde |
| Backend | 71 tests y verificación Deno en verde |
| Frontend | 198 tests en 24 archivos, análisis, build y presupuesto en verde |
| App Flutter | 2152 tests de la suite completa en verde antes de la última mejora de cierre; sus dos tests nuevos requieren una nueva ejecución |

La suite Flutter cubre análisis, ejecución, entrada, cancelación, ritmos, paginación, diagramas, exportadores y contenido bilingüe; incluye programa vacío, sintaxis inválida, división por cero y consultas fuera de rango. Las pruebas locales del puente y los goldens no certifican macOS ni iOS.

El smoke funcional directo verificó seis escenarios y diez solicitudes; el smoke del modelo de la app reduce Fib(20) a Fib(4), explícitamente. No es una medición física ni demuestra el rendimiento de Fib(20) en la interfaz. El escenario reproducible completo de Fib(20) queda en el ejecutor de campaña.

### Conformidad y matriz

Los archivos en `packages/pseudolearn_spec/results/` son las evidencias generadas. Se distingue la evidencia previa de la regenerada tras C4; una evidencia obsoleta no se acepta actualizando sus huellas a mano.

| Sujeto | Situación |
|---|---|
| engine | 1551 observaciones sin divergencias; 30 propiedades completas cumplidas, cero pendientes |
| service | 36 observaciones sin divergencias; 7 propiedades cumplidas, cero pendientes |
| cli | 64 observaciones sin divergencias; 1 propiedad cumplida, cero pendientes |
| app | Evidencia previa: 205 observaciones cumplidas, una no aplicable y 2 propiedades cumplidas; regeneración final pendiente por bloqueo de aprobación automática |
| aot | 1224 observaciones sin divergencias; 13 propiedades cumplidas y 3 pendientes por capacidades exceptuadas; deuda aceptada explícita |
| reference | Retirado; matriz vigente no aplicable, sin aportar evidencia activa de estabilidad |

El diferencial activo comparó 811 observaciones entre engine y AOT, sin exenciones ni diferencias pendientes. No compara ni requiere reference.

Se promovieron 68 contratos con evidencia vigente y aval explícito de revisión independiente automatizada: 56 de los sujetos activos con adaptador y 12 del propio SEE. Las promociones, vínculos y evidencia de tests de SEE se registran en [promociones.json](evidencias-r9/promociones.json), sin inventar ejecución de un adaptador see. Las promociones restantes de app requieren sus evidencias finales. Se mantienen experimentales los contratos de rendimiento, transporte Wasm real y las obligaciones AOT exceptuadas; no se modifica su versión numérica para simular un cumplimiento.

Los registros de comandos y el manifiesto de verificación están en [evidencias-r9](evidencias-r9/verification.json).

## Resultado de los verificadores

Se ejecutaron formato, Clippy estricto, tests, verificadores Rust de arquitectura, comentarios, nombres, límites, seguridad, atributos y toolchain; verificación de contenido, diseño y límites de la app; validación de 161 especificaciones; generación oficial de enlaces; lock y exportación oficiales.

La auditoría completa del motor pasó. Las auditorías finales de SEE, CLI y puente pasaron en modo offline usando una copia escribible de la misma base RustSec (`999ec89d5d3f10f20be14750ec8c2d8b44e0ac9b`) y sus configuraciones originales. Esta copia evita escribir el bloqueo en una caché protegida; no cambia reglas de auditoría ni omite categorías.

Hubo una interrupción de compilación por falta de espacio; se eliminaron únicamente directorios incrementales regenerables y se repitieron las comprobaciones afectadas. La actualización de RustSec de CLI falló temporalmente por red; la auditoría posterior con la base ya disponible pasó. Estos fallos operativos no se presentan como resultados de código.

El análisis final adicional de app tampoco pudo completarse por la escritura protegida de telemetría. El análisis anterior está en verde; no se declara satisfecho el nuevo intento.

La nueva conformidad de app no se ejecutó: la revisión automática no pudo completarse por límite de uso de la cuenta. El intento de ejecutar los nuevos tests de cierre sin privilegios tampoco pudo abrir el socket local del ejecutor Flutter. Estas puertas permanecen pendientes; no se elude la aprobación ni se declara cierre.

## Decisiones que conviene conocer o cuestionar

### Revisión independiente automatizada

El revisor autorizado trabajó en modo lectura. Se resolvieron sus hallazgos sobre prefijos incompletos, preservación de límites, identidad de eventos, revisión sucesora, navegación sin snapshots, negativos vacuos, captura anterior al fallo y completitud de operaciones del arnés. Avala esas correcciones, condicionando cualquier promoción y el cierre a los resultados nuevos. No emitió una certificación final sin la evidencia de app pendiente.

### Métricas históricas y excepciones autorizadas

- Los resultados originales de reference, la medición de artefactos y la campaña del servicio se conservan idénticos a sus blobs anteriores. Reference es historia, no un oráculo operativo ni un segundo sujeto activo.
- La captura histórica de artefactos del 19 de octubre registra iOS arm64 de 2 802 880 bytes y Wasm Brotli de 493 755 bytes. Es evidencia de esa captura y sus hashes, no del árbol final de esta iteración.
- El resultado histórico AOT de R6, incluido el incumplimiento de rendimiento, permanece disponible sin reinterpretarlo como favorable. La deuda aceptada de límites, identidad y observación no obtiene estabilidad.
- No se ejecutaron campañas físicas, validaciones de distribución ni workflows remotos. Las pruebas posteriores de plataforma se limitan inicialmente a macOS e iOS. Las obligaciones dependientes de esas mediciones conservan su estado y su pendiente.
- E-NR2 queda preparado pero su campaña permanece abierta. Desde `packages/pseudolearn_benchmarks`, `dart run tool/create_bridge_campaign.dart <campaña-nueva.json>` prepara la configuración y `dart run tool/collect_bridge.dart <campaña.json> <directorio-nuevo>` ejecutará la campaña posterior; `dart run tool/summarize_bridge.dart <raw.json>` recalcula estadísticas sin medir. No se atribuyen latencias, frames ni estacionariedad a sus smokes funcionales.

### Publicación y pendientes de cierre

Rama de trabajo: `feature/agregar-ruta-de-especificacion`. Los cambios preparados aún no se han publicado. Antes de cerrar faltan la conformidad y suite final de app, la revisión de la evidencia nueva, la promoción de los contratos de app respaldados, la puerta SEE completa, commits coherentes en inglés, push ordinario e igualdad comprobada entre HEAD local y remoto. La limitación de aprobación automática es operativa; no determina que estas acciones sean inseguras.
