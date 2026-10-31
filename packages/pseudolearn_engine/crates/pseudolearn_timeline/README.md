# pseudolearn_timeline

## 1. Qué es y qué no es

Conserva una línea temporal consultable de la ejecución, con vistas inmutables de estado, deltas incrementales, puntos de control diferenciales (imagen de la punta y segmentos de deshacer por bloques de 64 ranuras), raleo exponencial con fusión de segmentos y retroceso determinista mediante máquina de reproducción.
No añade construcciones del lenguaje, UI ni efectos libres del anfitrión.

Pendientes técnicos: ninguno propio de este crate; los resultados de coste y memoria se generan localmente desde el trabajador de medición.

## 2. Guía operativa y ciclo de vida

Versión exacta de rust-toolchain.toml del miembro. Manifiesto y código incorporados al workspace de pseudolearn_engine; pendiente retirado de architecture.yaml. Comprobación: `cargo xtask verify` y `cargo test -p pseudolearn_timeline`. No se despliega por separado.

## 3. Arquitectura y modelo del sistema

Nivel 8. Importa vm, runtime, bytecode y diagnostics; solo biblioteca estándar externa. Prohibido importar capas superiores, UI, Dart o el sistema de especificaciones como código.

`CheckpointStore` conserva una única imagen completa, la punta, y por cada punto anterior un segmento de deshacer (`MachineDelta` de `pseudolearn_vm`) que lleva la punta a ese punto. Cada segmento guarda solo los bloques de 64 ranuras que difieren en bancos, marcos, celdas y palabras del montón, los bloques vivos del runtime y la longitud previa de la salida, los literales, las entradas y los diagnósticos. La historia de eventos no se retiene: la imagen solo recuerda cuántos eventos precedieron al punto. Los checkpoints guardan el número de sentencias ejecutadas para orientar la reproducción. La superficie de vistas contiene marcos, variables, valores de celdas locales o administradas y cortes de arreglos; la API resuelve nombres de campos de objetos desde el esquema del programa.

Invariantes: Restaurar un punto reproduce sus bits (imagen ligera, sin eventos). Fusionar segmentos conserva la reconstrucción de los puntos que sobreviven. Consultar el pasado no altera la continuación presente. El horizonte retenido se declara y las vistas entregadas son inmutables.

Cinta de efectos y reproducción aislada (`effect_tape`, `tape_replay`, `tape_privacy`): estos tres módulos solo reexportan desde `pseudolearn_runtime`, donde viven el formato, los hashes y el reproductor para que VM y AOT compartan la misma implementación; las pruebas de formato, cadena de hashes y códigos de rechazo están por eso en `pseudolearn_runtime/tests/` (`effect_tape_tests`, `tape_replay_tests`, `tape_replay_host_isolation_tests`) y en `pseudolearn_api/tests/` (`tape_execution_tests`, `tape_rejection_tests`, `tape_identity`). `EffectTape` implementa el esquema `pseudolearn.tape/v1`. Registra `ExecutionIdentity` y una secuencia monotónica de `TapeEntry` con hash SHA-256 encadenado criptográficamente (`entry_hash`). Modela tres modos mutuamente excluyentes (`ExecutionMode`: `LiveRecord`, `ReplayFromTape`, `HistorySeek`). En modos de reproducción y búsqueda histórica, el anfitrión permanece totalmente desconectado (`allows_external_host() == false`). `TapeReplayProvider` valida identidad, secuencia y hashes; ante cualquier discrepancia emite un error de la familia `replay_*` (`ReplayError`: `IdentityMismatch`, `Divergence`, `TruncatedTape`, `CorruptedTape`, `NonReproducible`) sin intentar reintentos ni recurrir a llamadas vivas al anfitrión.

Retroceso con efectos (`effect_replay`): `replay_machine_with_effects` reconstruye un evento pasado reanudando desde el punto de control con la sesión de efectos restaurada del `EffectCheckpoint`; cada efecto pendiente se resuelve contra la cinta mediante `perform_host_effect` con un `DisconnectedHost` que cuenta sus llamadas, y cualquier llamada (contador distinto de cero) o discrepancia aborta con `ReplayFailure`. `pseudolearn_api/tests/history_seek_isolation_tests.rs` recorre una sesión con efectos hacia adelante y hacia atrás, comprueba estados idénticos y que `host_observation.calls` no cambia.

Privacidad y presupuesto de cinta (`tape_privacy`): reexporta `SecretHandle` y `TapeBudget` de `pseudolearn_runtime`. `SecretHandle::authenticate` calcula `value_hmac` como HMAC-SHA-256 ligado a la clave y al valor; `to_reference_string` produce la referencia `secret:<key_id>:<value_hmac>` que sustituye al argumento en la cinta. `TapeBudget` solo guarda `max_tape_bytes` (16 MiB por omisión, `ENG.LIMITS#D1`) y los bytes acumulados; el corte lo decide `EffectTape::append`, que admite una entrada si la cinta serializada resultante no supera el límite y, si no, sella `NonReproducibleTruncated` y descarta lo posterior. Un secreto redactado sella `NonReproducibleRedacted`. Se retiraron `SecretHandle::verifies`, `parse_reference`, `new` y `TapeBudget::can_admit`/`record_admitted` porque ningún código de producción los usaba (la reproducción rechaza toda cinta redactada, de modo que no hay nada que verificar).

## 4. Decisiones de diseño y fundamentos técnicos

Problema: la cinta debe distinguir un efecto que cruzó al anfitrión y quedó incierto de uno rechazado antes de mutar. Elección: cada efecto abre una entrada `requested` con su `effect_seq` y la cierra con `committed`, `failed` o `uncertain`; solo `uncertain` marca la cinta `UncertainExternalState` y un corte del anfitrión la sella `Incomplete`, de modo que ninguna de las dos se reproduce de forma autónoma. Mientras la entrada `requested` está abierta la cinta es `Incomplete`; al resolverse se sustituye por la entrada cerrada y se restaura el estado previo, y si el anfitrión corta antes la entrada permanece y la cinta sigue `Incomplete`. Los tipos `EffectPhase`, `CommitOutcome` y `ReproducibilityStatus` viven en `pseudolearn_runtime`; este paquete solo reproduce y valida contra ellos.

Problema: una reproducción necesita descriptores del montón y estado de texto, entrada y observación además de palabras. Elección: la punta es la única imagen completa y cada punto anterior es un segmento de deshacer; restaurar clona la punta y aplica los segmentos desde el más reciente hasta el punto pedido, y la máquina independiente avanza desde ahí hasta el evento. Las consultas rechazan eventos inalcanzables y las parciales leen solo la vista pedida. Se descarta conservar snapshots completos por evento y conservar la historia de eventos en las imágenes: clonarla costaba más de 40 ms con siete millones de eventos y la línea temporal solo necesita su cuenta. Los segmentos son inversos (deshacer) porque crecer no cuesta nada: el área nueva no guarda contenido previo. `CheckpointStore` puede pertenecer a la sesión de ejecución de la API; la API registra la máquina persistente y consulta una máquina temporal restaurada. El índice de sentencias delimita el trabajo de reproducción y las imágenes ligeras omiten la historia de eventos durante cada paso.

El siguiente punto se programa a max(Q_min, min(κ·S, T_max)) en masa de sentencia: κ·S mantiene proporcional el coste de grabar frente al de ejecutar, y T_max (262 144 sentencias) acota la distancia de reproducción cuando el montón es grande, de modo que el retroceso no crece sin límite con el estado. No se usa reloj para decidir puntos. El raleo, activado por número de puntos o por ranuras retenidas, retira el punto interior cuyo hueco resultante sea menor respecto a su antigüedad, de modo que el espaciado queda exponencial, y compone su segmento con el del punto anterior; la composición conserva el contenido más antiguo por bloque. Cuando solo quedan dos puntos y aun así se supera el presupuesto, se retira el más antiguo y el horizonte declarado avanza. Una VM independiente restaura sombra y segmentos, avanza rápido por masa de evento y cambia al sondeado en el bloque objetivo; densifica cerca del evento consultado. La salida se suprime y las entradas se releen de la cinta. La compactación de texto fuerza copia en el siguiente punto. Se rechaza barrera por escritura y copiar un estado completo por evento.

Problema: Una celda puede apuntar a un registro local o a una celda de arreglo u objeto administrado, y mostrar el asa sin interpretar no representa el valor observado. Elección: La vista lee la celda según su representación, obtiene el `ValueKind` del registro o del descriptor del montón, muestra `Undefined` para enteros sin definir y decodifica los valores definidos al modelo de vista; el alias se conserva cuando hay un propietario con nombre distinto. Se descarta exponer el índice interno de la celda o su palabra cruda porque no describe el valor del programa.

Problema: Dos candidatos de raleo pueden tener la misma densidad de eventos y antigüedad, pero la fusión de sus deltas puede retener cantidades distintas de estado. Elección: Se compara el producto saturado de hueco por antigüedad; ante igualdad se elige la fusión compuesta con menos ranuras copiadas, y un empate completo conserva el primer candidato recorrido. Se descarta elegir siempre el último candidato empatado porque puede retener más ranuras y hacer avanzar antes el horizonte.

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


### Funciones como valores y ámbitos de ejecución

La inspección recibe el mapa de nombres que la VM filtra por intervalo léxico, incluido el punto de continuación de los marcos suspendidos. Un vínculo cerrado deja de mostrarse aunque su ranura física siga reservada; no se reutilizan ranuras entre bloques.

## Colecciones, interfaces e iteración con limpieza

La inspección distingue cabeceras de colección de objetos ordinarios y conserva identidad y tipo declarado a través del crecimiento. Los bancos y metadatos viven en el heap existente: snapshots y deltas capturan su estado sin un registro paralelo. Las referencias eliminadas se borran antes de registrar el estado siguiente.

Los tests de estas capacidades se ejecutaron en selecciones acotadas, incluida la comparación de gemelos con recolección forzada. La conformidad del corpus sigue pendiente de la revisión editorial independiente de los contratos nuevos, y la medición de tamaño excede el presupuesto de Wasm.


Los tipos de cinta y su verificación se reexportan desde runtime. Esta capa no mantiene otra
implementación de formato, presupuesto ni hashes; la misma implementación es consumible por AOT.

## Ventanas reconstruidas de eventos

replay_event_window comparte la misma reproducción aislada de efectos que la consulta de estado.
Recibe un rango y devuelve únicamente sus eventos; descarta los anteriores entre instrucciones.
CheckpointStore conserva el evento de frontera de cada checkpoint para que una ventana pueda
incluir exactamente el primer evento disponible aunque su imagen ya represente el estado posterior.
El raleo retira esas fronteras junto con sus checkpoints: no se conserva una traza ilimitada.

La reproducción de estado conserva los eventos de la instrucción objetivo hasta que el consumidor
los drena; esto permite registrar otra frontera al reducir la retención sin perder su identidad.
La continuación viva no participa en estas reconstrucciones y ningún fallo permite consultar un
anfitrión físico como alternativa. Las ventanas del borde público se limitan a 4096 eventos.
