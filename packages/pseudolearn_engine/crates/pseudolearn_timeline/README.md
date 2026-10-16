# pseudolearn_timeline

## 1. Qué es y qué no es

Conserva una línea temporal consultable de la ejecución, con vistas inmutables de estado, deltas incrementales, puntos de control con sombra del montón y segmentos de deshacer de 64 palabras, raleo exponencial con fusión y retroceso determinista mediante máquina de reproducción.
No añade construcciones del lenguaje, UI ni efectos libres del anfitrión.

Pendientes técnicos: medición integrada de coste y memoria de puntos, deltas y reproducción; las consultas exactas no sustituyen la evidencia de rendimiento.

## 2. Guía operativa y ciclo de vida

Versión exacta de rust-toolchain.toml del miembro. Manifiesto y código incorporados al workspace de pseudolearn_engine; pendiente retirado de architecture.yaml. Comprobación: `cargo xtask verify` y `cargo test -p pseudolearn_timeline`. No se despliega por separado.

## 3. Arquitectura y modelo del sistema

Nivel 8. Importa vm, runtime, bytecode y diagnostics; solo biblioteca estándar externa. Prohibido importar capas superiores, UI, Dart o el sistema de especificaciones como código.

Sombra del montón y segmentos de deshacer por bloques de 64 palabras, longitud de la arena de texto y segmentos de bancos desde la marca de agua. Puntos con pila, azar, salida, entradas, evento, sentencias, identidad y contadores de recolección. Vistas propias, deltas por evento y tabla ordinal→asa de exposición.

Invariantes: Restaurar un punto reproduce sus bits. Consultar el pasado no altera la continuación presente. El horizonte retenido se declara y las vistas entregadas son inmutables.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: una reproducción necesita descriptores del montón y estado de texto, entrada y observación además de palabras. Elección: los puntos conservan una imagen completa restaurable; las consultas usan una máquina independiente y rechazan eventos inalcanzables. Las consultas parciales leen solo la vista pedida. Se descarta conservar snapshots completos por evento. La reducción diferencial de imágenes y la reproducción rápida requieren validación de coste antes de declarar cumplimiento de rendimiento.

El siguiente punto se programa a max(Q_min, κ·S) en masa de sentencia, con parámetros calibrados por coste y presupuesto. No se usa reloj para decidir puntos. Raleo exponencial fusiona segmentos conservando la imagen más antigua por bloque. Una VM independiente restaura sombra y segmentos, avanza rápido por masa de evento y cambia al sondeado en el bloque objetivo; densifica cerca del evento consultado. La salida se suprime y las entradas se releen de la cinta. La compactación de texto fuerza copia en el siguiente punto. Se rechaza barrera por escritura y copiar un estado completo por evento.

La implementación permanece secuencial y determinista. La exportación del corpus es una dependencia
de datos. Las técnicas que requieren medición se aceptan solo tras conservar resultados y criterios.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, doc, allow, expect, pánicos ni unsafe. Datos con índices tipados,
funciones pequeñas y fallos como Result. Límites y dependencias en architecture.yaml del miembro.
Las salidas generadas se producen en OUT_DIR y no se copian a consumidores.

## 6. Decisiones de producto que condicionan el código

ENG.STATE.*, API.STATE.QUERY, API.EXECUTE#R4 y PERF.VM.*. Ejecutar y observar conservan la misma semántica. Los identificadores, el contenido de
literales y los efectos del programa se preservan; idioma de interfaz y vocabulario son independientes.

## 7. Verificación, testing y aseguramiento de calidad

Restauración bit a bit, consultas repetidas al pasado, deltas reconstruidos, horizonte exacto y mediciones con estado grande y escrituras escasas. Tests espejo, caminos felices, infelices y límites explícitos. Cada verificador tiene un negativo
con violación deliberada. No se cierran pendientes hasta tener cargo xtask verify y conformidad en verde.

## 8. Fuentes consultadas y genealogía conceptual

Young y Daly inspiran programar por coste, rechazando reloj como unidad. La comparación incremental de HPC inspira la sombra; se rechazan hashes con falsos negativos y protección de páginas del sistema. rr inspira grabar no determinismo, sin grabar el proceso completo.
