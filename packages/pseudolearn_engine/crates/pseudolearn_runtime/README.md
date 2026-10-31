# pseudolearn_runtime

## 1. Qué es y qué no es

`pseudolearn_runtime` proporciona las operaciones comprobadas de memoria y valores que comparten la VM y los consumidores del motor. Incluye aritmética primitiva, montón, objetos, arreglos, texto, valores JSON y estado aleatorio determinista.

No ejecuta bytecode, no conoce el lenguaje fuente y no traduce errores a mensajes localizados. Las fallas esperables se expresan con `Result` y `MemoryError` o `ArithmeticError`.

## 2. Guía operativa y ciclo de vida

El crate forma parte del workspace de `pseudolearn_engine`. Sus dependencias de código son `pseudolearn_abi` y `pseudolearn_diagnostics`; no necesita servicios externos ni archivos generados.

Desde `packages/pseudolearn_engine`:

- Compilar: `cargo check -p pseudolearn_runtime`.
- Ejecutar sus pruebas de integración: `cargo test -p pseudolearn_runtime`.
- Ejecutar todas las verificaciones del motor: `cargo xtask verify`.

La API pública existente se consume mediante los tipos y funciones exportados por `src/lib.rs`. Los límites de memoria y la política de recolección se entregan en `MemoryOptions` al crear `Heap`.

## 3. Arquitectura y modelo del sistema

El montón guarda palabras `u64` en un vector plano. Cada asignación comienza con una cabecera `CommonHeader` de dos palabras: la primera empaqueta forma y banderas, y la segunda guarda el ordinal o la cantidad de puntos de código. Un vector ordenado de `BlockRecord` conserva solo dirección, tamaño físico y celdas lógicas para recolección y diferenciales. El valor cero representa una referencia ausente; las asas son desplazamientos de 32 bits dentro del vector y las asignaciones de objetos y arreglos reciben una identidad ordinal que no depende de su dirección física. Una dirección reutilizada recibe un ordinal nuevo, así que igualdad de asa no implica identidad de objeto.

Los objetos conservan sus diseños en `Heap.layouts`, indexados por clase, y llevan el desplazamiento de campos en la cabecera. Los arreglos codifican tipo de elemento, rango y literal en las banderas; guardan el total, la cantidad de enteros definidos y la dirección del mapa de definición en sus primeras palabras. El arreglo de rango uno reutiliza el total como su dimensión; los de mayor rango guardan sus dimensiones antes de los datos. El mapa de definición distingue una celda sin inicializar de un entero cuyo valor sea cero. Las celdas auxiliares permiten representar ese mapa sin añadir etiquetas a los valores.

`ValorJson` usa una vista de dos palabras útiles: asa del bloque de nodos e índice de nodo. El bloque conserva una tabla plana con ocho palabras por nodo y bytes UTF-8 empaquetados para claves y escalares. Un wrapper de forma propia guarda la vista; el recolector sigue su referencia al bloque. `Elemento` y `Campo` crean wrappers nuevos para nodos del mismo bloque. Como ambos son inmutables, `Copiar` y los snapshots comparten sus asas. El costo lógico del bloque suma nodos y palabras de texto; cada vista suma una celda.

La recolección es no móvil y marca desde las asas raíz recibidas por la operación. Los bloques liberados se agrupan por tamaño físico para reutilizar direcciones. El texto usa un arena propio con migas de caracteres y una operación explícita de compactación que devuelve los desplazamientos movidos. La recolección compacta el arena automáticamente y, al descartar los índices de migas, libera solo los auxiliares que un texto referencia (una vez cada uno, porque los prefijos compartidos comparten índice): los búferes de `Vector` y `Diccionario` también son bloques auxiliares y no deben liberarse con ellos. El generador pseudoaleatorio recibe una semilla y mantiene su estado dentro de `RandomState`.

Agenda de tareas (`task_agenda`): cada tarea distingue si espera una respuesta de efecto, un canal, otra tarea o la unión de un ámbito. La cola FIFO reanuda listas y las finalizaciones despiertan sus dependientes. Cancelar una espera de efecto abandona su secuencia; cancelar una espera de canal solo quita esa causa de espera. El fallo de una tarea solicita cancelar sus hermanas y descendientes por identidad. La VM despacha las continuaciones de limpieza cooperativa registradas antes de cada espera y despierta las uniones tras finalizar la cancelación.

Tabla de capacidades y efectos (`capability_table`): `CapabilityTable` gestiona las ranuras activas del anfitrión mediante `CapabilityToken` (índice y generación `u32`). Implementa la invalidación generacional en el cierre (`close`), de forma que cualquier intento de invocar un descriptor cerrado produce `CapacidadCerrada` (`CapabilityError::Closed`). Controla máscaras de derechos (`RightsMask`) para impedir amplificaciones no autorizadas. Modela el ciclo formal de compromiso de efectos en dos tipos separados, conforme a `CF-07` y `ENG.EXEC.EFFECT-COMMIT`: `EffectPhase` (`Requested` → `Resolved`, con `resolve()` que rechaza con `ReplayError::Divergence` una segunda resolución) y `CommitOutcome` (`Committed`, `Failed`, `Uncertain`, derivado de `HostReply::commit_outcome`). `host_session` guarda la fase en el efecto pendiente: `begin_host_effect` lo abre en `Requested` y asigna `effect_seq`, y `resolve_host_effect` exige exactamente una resolución con la misma secuencia; una resolución sin solicitud o repetida es un rechazo, nunca un efecto silencioso. Una respuesta `Uncertain` solo es válida para operaciones con potencial de mutación (`host_validation`), así que un fallo de lectura se clasifica siempre como `Failed`. Un corte o fallo externo incierto transiciona el estado a `ReproducibilityStatus::UncertainExternalState`. La operación `close_all` garantiza la liberación inmediata de todos los recursos del host ante corte o cancelación del anfitrión (`CF-11`).

Búfer de bytes y errores de E/S (`bytes_buffer`, `io_error`): `BytesBuffer` encapsula secuencias binarias contiguas, calculando sus celdas lógicas con `bytes_cell_count`. `IoError` empareja un `IoErrorKind` con la bandera `uncertain` para distinguir fallos reproducibles de incertidumbre en el estado externo del host (`uncertain_external_state`).

## 4. Decisiones de diseño y fundamentos técnicos

Problema: una política única obliga al nativo a recolectar árboles vivos con demasiada frecuencia. Elección: `MemoryOptions.collection_minimum` configura el mínimo de celdas asignadas antes de recolección automática; el valor predeterminado es 4096. La asignación, la consulta previa y la ventana en línea usan el mismo umbral, máximo entre mínimo y celdas vivas. La presión del límite y la recolección forzada conservan prioridad. La holgura se repone por debajo de 8192 palabras libres y reserva al menos 16384. Se descarta cambiar la política predeterminada de la VM.

Problema: la consulta de límite y el recolector repetían el mismo recorrido. Elección: la preparación construye una sola marca, calcula sus celdas antes de liberar y entrega esa marca al recolector. La compactación solo elimina auxiliares de texto de costo lógico cero; el conteo de celdas alcanzables no cambia. Una asignación que excede el límite falla antes de recolectar, como exige su contrato. Se descarta ocultar recorridos: el mínimo automático se configura explícitamente por consumidor y se mide con el mismo contrato de celdas vivas.

Problema: copiar vectores de campos y referencias por objeto repite metadatos inmutables. Elección: la asignación valida el diseño contra el registrado y solo copia el diseño si la clase aún no lo tiene. La reserva y la inicialización del objeto siguen el mismo contrato de identidad y definición. Se descarta cambiar la representación de objetos o el recolector para eliminar esta copia.

Problema: los perfiles agregados no distinguen mecanismos de memoria. Elección: la feature `telemetry`, desactivada por omisión, cuenta asignaciones, crecimiento de palabras, recolecciones, recorridos, copias de diseño y accesos o raíces de celdas según la responsabilidad del crate. Sus resultados pertenecen a sesiones diagnósticas separadas; el código de producto y la campaña normativa no contienen estos incrementos. Se descarta atribuir los tiempos instrumentados al rendimiento de producción.

Problema: consultar un mapa de descriptores en cada lectura y escritura añade una búsqueda y conserva descripciones duplicadas fuera de las palabras vivas. Elección: las cabeceras en banda contienen forma, tipo, rango, desplazamiento de campos, literal y ordinal; `ObjectLayout` se registra una vez en un vector indexado por clase. Lecturas y escrituras de arreglos, campos y celdas derivan sus metadatos de la cabecera y de ese diseño. `BlockRecord` mantiene solo `Handle`, tamaño físico y celdas; el recolector lo recorre para marcar/liberar bloques y los snapshots enumeran sus asas. Se descarta una tabla de asignaciones consultada en el camino de acceso.

Problema: diferenciar la capacidad reservada del vector de palabras retiene datos no usados en cada punto de control. Elección: `Heap.used` delimita las palabras lógicas; la ventana nativa puede extender `Heap.words.len()` con holgura inicializada, excluida del estado observable. La capacidad interna de `Vec` tampoco forma parte del estado. `HeapDelta` compara solo el prefijo usado, aplica deltas por bloques a palabras y `BlockRecord`, y conserva el sufijo de diseños registrados junto con las listas libres y el estado del arena de texto. `advance_heap` actualiza la imagen de la punta y devuelve el segmento inverso; `revert_heap` lo aplica y `compose_heap_deltas` fusiona segmentos contiguos. Se descarta capturar palabras reservadas fuera del montón lógico.

`BlockDelta::advance_from` recibe el primer índice modificado para omitir los bloques anteriores al cambio. El propietario registra ese índice al escribir y lo restablece después de capturar; el crecimiento y el truncado siguen detectando el borde común entre el estado anterior y el nuevo.

`compact_text` devuelve un `TextCompaction` con los rangos movidos. La compactación disparada por una recolección automática no conserva ni publica ese mapa: el runtime actual no tiene un consumidor de los desplazamientos del arena. Un consumidor que necesite observarlos debe añadir su contrato de notificación junto con su integración; el runtime no acumula mapas sin lector.

El montón no mueve objetos: así, una recolección no altera identidades ni asas visibles. El ordinal identifica la asignación lógica, mientras el asa permite llegar a su almacenamiento actual. Los errores de capacidad, tamaño negativo, límite de celdas, índice, valor no inicializado e invariantes internos son variantes tipadas, no pánicos.

El parser construye el bloque JSON desde un valor temporal de `serde_json`, con `max_json_depth` configurable y valor predeterminado 64. La VM recibe el límite en `RunOptions`; AOT lo obtiene de la identidad de ejecución. Cada arreglo u objeto cuenta un nivel, incluido el contenedor raíz. Serializar una vista recorre sus nodos y vuelve a escapar claves y cadenas; las operaciones que cruzan `HostValue` materializan temporalmente el texto del subárbol. Esos cruces cuestan O(n) en el tamaño recorrido, mientras las vistas retenidas evitan copiar subárboles en `Elemento` y `Campo`.

Las dimensiones se convierten y multiplican con comprobación de rango; una dimensión cero produce un arreglo de cero elementos, mientras el rango vacío no representa un arreglo válido. El límite de celdas cuenta el costo lógico exacto y se comprueba con las celdas vivas antes de aceptar la asignación.

### Consulta del modo de reproducción

`EffectSession::is_replaying` informa si la sesión resuelve contra una cinta. El tiempo de ejecución nativo lo usa para
decidir si una lectura de consola viene de la cinta o de la entrada estándar; no añade ramas al camino de los opcodes
puros.

## 5. Reglas de legibilidad, estilo y estructura de código

El código y sus identificadores están en inglés. No se permiten comentarios, documentación Rust ni atributos de supresión. Los errores esperables se devuelven como valores tipados; el crate declara `#![forbid(unsafe_code)]`.

Los módulos de `src/` separan aritmética, arreglos, celdas, heap, objetos, azar y texto. Las pruebas de caja negra están en `tests/` y reflejan estas responsabilidades.

## 6. Decisiones de producto que condicionan el código

El runtime conserva valores sin etiquetas dinámicas: `ValueKind` y los mapas de definición describen cómo interpretar cada palabra. Las representaciones compartidas se declaran en `pseudolearn_abi` para mantener iguales los contratos de VM y AOT.

La colección automática puede activarse por presión de límite o asignaciones acumuladas; `Forced` permite solicitarla al asignar y `Disabled` impide recolectar. La semilla explícita hace reproducible el azar. La asignación de texto y la memoria de observación se mantienen fuera de las garantías de identidad de objetos.

## 7. Verificación, testing y aseguramiento de calidad

Las pruebas de `tests/heap_tests.rs` y `tests/array_tests.rs` cubren asignación, acceso directo a metadatos en banda, rangos de arreglos, límites, errores, identidades, recolección, definición de enteros y crecimiento del almacenamiento. `tests/json_document_tests.rs` cubre el bloque plano, vistas hijas compartidas, supervivencia a GC, lexemas numéricos, escapes y profundidad. La regresión de reutilización verifica que una misma asa conserva una identidad ordinal distinta tras recolectar y reasignar. `tests/delta_tests.rs` cubre restauración y composición tras asignar, modificar y liberar bloques. Las pruebas de consumo en `pseudolearn_api` contrastan las operaciones con los casos del corpus bajo recolección automática, forzada y desactivada.

Para aceptar un cambio, se ejecutan las pruebas dirigidas del crate afectado y `cargo xtask verify` desde la raíz del motor. La conformidad observable del lenguaje se mantiene en el corpus y se contrasta desde `packages/pseudolearn_spec`.

## 8. Fuentes consultadas y genealogía conceptual

La representación de asas comprimidas toma como referencia los diseños de V8 y la JVM. La compactación de texto y sus migas se inspiran en técnicas de arenas de texto empleadas por Swift. Estas referencias orientan alternativas de implementación; el contrato del runtime pertenece a PseudoLearn.

El contraste E-12 fue una medición histórica local. La decisión de usar consultas ordenadas en los descriptores y el estado de rendimiento se documentan junto con la arquitectura del motor.

Problema: reservar el vector de palabras con la capacidad exacta de cada asignación hacía un realojo por objeto, y el código nativo no puede crecer un vector de Rust. Elección: la reserva usa crecimiento amortizado y `Heap::inline_window` extiende además la longitud con una holgura de ceros (mínimo 16 384 palabras) que `shrink_to_fit` recorta al uso real. La ventana publica el uso, el límite, el ordinal, el margen de celdas y de umbral de recolección (las dos condiciones de `prepare`, expresadas como contadores que el código nativo decrementa), y una máscara de tamaños con bloques libres (el bit 63 agrupa los tamaños desde 63). `Heap::adopt_inline` incorpora los bloques que el código nativo asignó sin pasar por Rust y rechaza regresiones de uso u ordinal, rangos fuera del vector y bloques duplicados. Se descarta registrar bloques desde el código nativo en el vector ordenado del montón: se difiere a un búfer plano que se concilia al entrar en el runtime.

## Colecciones, interfaces e iteración con limpieza

Vector y Diccionario mantienen cabeceras estables y bancos separados de escalares y referencias. Crecer sustituye bancos conservando asa e identidad; Vector duplica capacidad mediante aritmética comprobada. Diccionario conserva entradas en inserción, usa FNV-1a de 64 bits con bytes enteros en orden little endian o UTF-8 exacto para cadenas, índice abierto con sondeo lineal y ocupación máxima de tres cuartos. Compacta establemente cuando los huecos superan un cuarto de las posiciones usadas. No hay tabla lateral de Rust que quede fuera de snapshots. Los bloques auxiliares pertenecen al heap y las referencias activas se recorren desde la cabecera; eliminar borra los enlaces y permite recolectar objetos. Solo las mutaciones estructurales exitosas incrementan la versión u32, cuyo agotamiento falla antes de modificar. Los límites de elementos y palabras variables derivan de cells y del espacio u32; las celdas lógicas dependen de longitud, no de capacidad. Las reservas y el cambio de cabecera se separan para que un fallo no publique almacenamiento parcial.

Los tests de estas capacidades se ejecutaron en selecciones acotadas, incluida la comparación de gemelos con recolección forzada. La conformidad del corpus sigue pendiente de la revisión editorial independiente de los contratos nuevos, y la medición de tamaño excede el presupuesto de Wasm.


## Sesión compartida de efectos y cinta

El núcleo de cinta, confirmación y reproducción vive en runtime para que VM y AOT compartan los mismos
invariantes sin importar API ni timeline. Timeline reexporta los tipos y conserva únicamente
checkpoints y reconstrucción. El formato canónico usa serde y serde_json, y SHA-256 encadena todos los
campos de cada entrada con la identidad inicial; ningún adaptador puede omitir esta comprobación.
El presupuesto cuenta la representación serializada completa. Agotarlo detiene el almacenamiento,
marca la cinta como no reproducible y permite continuar la ejecución viva sin crecimiento ilimitado.


La autenticación de secretos usa HMAC-SHA-256 de RustCrypto hmac 0.12 y sha2 0.10, según su API de
Mac (https://docs.rs/hmac/0.12.1/hmac/). Se toma la construcción y verificación en tiempo constante;
se rechazan hashes sin clave y claves almacenadas en la cinta. La clave y el valor resuelto pertenecen
al proveedor externo; la cinta solo conserva identidad de clave y autenticador.


Bytes se aloja empaquetado en bloques del montón con longitud explícita y etiqueta propia; sus
octetos no se interpretan como referencias ni como texto. Las capacidades también tienen etiqueta
propia y solo guardan tokens generacionales; los recursos del host permanecen en su proveedor.
MemoryHostProvider implementa únicamente datos en memoria, reloj declarado y fallos inyectados,
y comparte la frontera de solicitudes con los proveedores físicos. Los métodos de archivo operan
sobre contenido completo; cada escritura sustituye el contenido y cada lectura devuelve el contenido.

### Pruebas de cinta y aislamiento del anfitrión

`tests/effect_tape_tests.rs` cubre formato, estado de reproducibilidad y presupuesto; `tests/tape_replay_tests.rs` cubre cada código de `ReplayError` sobre `TapeReplayProvider`; `tests/tape_replay_host_isolation_tests.rs` ejerce `perform_host_effect` con un proveedor espía y comprueba que identidad, divergencia, fin prematuro, adulteración y cinta no reproducible se rechazan con el contador de llamadas en `0`. `ExecutionMode::as_str` y `TapeReplayProvider::cursor` se eliminaron por no tener consumidores.

### Privacidad y presupuesto de la cinta

`tests/tape_privacy_tests.rs` comprueba la forma de la referencia de secreto, que el HMAC depende de la clave y del valor y que la referencia no contiene el valor; `tests/tape_budget_boundary_tests.rs` comprueba el corte exacto de `max_tape_bytes` sobre el registrador real (`EffectTape::append`): un byte menos que el presupuesto mínimo que admite la entrada trunca, el presupuesto exacto la admite y la cinta serializada mide exactamente ese presupuesto, un byte más también la admite, la segunda entrada tiene su propio borde y una cinta truncada ignora lo posterior. En `pseudolearn_api`, `tests/tape_privacy_budget_tests.rs` ejerce lo mismo de extremo a extremo con `host.max_tape_bytes` y `host.secrets`: la ejecución en vivo continúa y termina con normalidad aunque se agote el presupuesto, la cinta truncada o redactada se rechaza con `replay_non_reproducible`, y el secreto no aparece en la cinta serializada en forma textual, decimal ni hexadecimal ni por consola ni por entrada. Pendiente declarado: el esquema de casos no observa el estado de la cinta ni puede alterarla, por lo que el corpus solo prueba que la ejecución continúa (`ENG.EFFECT.TAPE` C8, `ENG.LIMITS` C19) y que no hay fuga (`ENG.EFFECT.TAPE` C6 y C9, con la comprobación de fuga del arnés); el sellado y el rechazo de la reproducción se prueban con Rust.

### Vocabulario de la cinta, presupuesto y configuración del anfitrión (`PG-3`)

- `capability_kind` de cada entrada de cinta sale de `EffectOperation::capability_family` (`pseudolearn_abi`); como forma parte del hash de la entrada, una cinta grabada con nombres anteriores no verifica contra el formato actual.
- `tape_codec::validate` no aplica el tope de bytes a una cinta sellada `NonReproducibleTruncated`: el presupuesto gobierna la admisión de entradas, y una cinta truncada puede ser más pequeña que su propia identidad. Así se decodifica y su reproducción se rechaza con `replay_non_reproducible`, no con `replay_corrupted_tape`. Una cinta reproducible que excede su presupuesto sigue siendo adulterada. Cubre `tests/tape_budget_boundary_tests.rs`.
- La configuración del anfitrión en memoria acepta las directivas del corpus `cancel_on_awaiting_effect` y `alterar_cinta`; ambas las consumen el corredor de la API y el de conformidad, no el proveedor. Se mantiene `deny_unknown_fields` para cualquier otra clave. Cubre `tests/memory_host_config_tests.rs`.

## Fallos, canales y progreso de tareas

`task_failure` agrega errores como datos puros: el primero es el primer suceso registrado, aunque su
tarea tenga identidad mayor; los asociados conservan orden de terminación. Una identidad terminal se
cuenta una vez y las cancelaciones no pueden convertirse después en fallos. La condición de errores
asociados se prueba directamente como una secuencia de sucesos; con una única tarea ejecutando y
cancelación aplicada antes de reanudar, dos retornos inmediatos no producen dos fallos: la segunda
hija termina cancelada. No se introduce ejecución simultánea para fabricar ese escenario.

`task_channel` mantiene canales genéricos, capacidad positiva, colas FIFO y resultados de operaciones
por tarea. `wait_queue` es dueño del orden de espera. La entrega directa precede al almacenamiento;
recibir libera un hueco para el primer emisor. Cerrar es idempotente, conserva el búfer y despierta
receptores con ausencia y emisores con falso. `channel_selection` evalúa disponibilidad en orden textual
y retira todas las inscripciones de una selección en el mismo suceso de entrega o cierre. Cancelar
retira también resultados aún no recogidos. `channel_values` expone las referencias retenidas al dueño
del GC sin interpretar sus valores. `channel_storage` reserva en el montón las celdas declaradas por
la disposición única; las colas y sus valores forman parte del estado de la agenda.

`task_deadlock` distingue trabajo ejecutable, efectos pendientes, finalización y bloqueo. Solo los
efectos asociados a tareas vivas en espera impiden el bloqueo; los abandonados se excluyen. Finalizar
una cancelación despierta las uniones dependientes, y la limpieza se selecciona primero entre tareas
cuyas hijas ya terminaron. Interrumpir el cuerpo dueño abandona su efecto si lo esperaba.

Verificación dirigida: `cargo test -p pseudolearn_runtime --lib task_`,
`cargo test -p pseudolearn_runtime --lib wait_queue` y
`cargo test -p pseudolearn_runtime --test channel_storage_tests`. La persistencia completa de la agenda
y las colas en las imágenes históricas sigue pendiente; los resultados de estas pruebas no certifican
reconstrucción ni ejecución nativa de tareas.

## Copia de grafos y cuanto cooperativo

`snapshot_graph` enumera las referencias de arreglos y colecciones antes de copiar. El recorrido
iterativo usa identidad de asa y conserva alias y ciclos; omite ranuras no ocupadas de diccionario y
capacidad no usada de los bancos. `snapshot_copy_many` copia conjuntamente todas las referencias de
un agregado, de modo que dos campos que compartían una colección siguen compartiendo su copia.
Texto, capacidades y canales mantienen su identidad. La copia conserva máscaras de definición y
reubica el puntero interno de la máscara de un arreglo entero. Cada bloque nuevo conserva el coste
lógico del original y pasa por el presupuesto de creación; los auxiliares conservan coste cero.
Se descartan copias por cada campo, que romperían alias, y recorridos recursivos del grafo.

`TaskQuantum` comparte con los ejecutores el cuanto 1024 y la acumulación saturada de masa. Como solo
ejecuta una tarea y cada reanudación reinicia la masa, basta un acumulador sin mapa ni asignaciones.
Las vueltas inferiores al cuanto conservan la masa. Al consumirlo se reinicia, haya o no otra tarea
lista; solo con otra lista se cede. No intervienen reloj físico ni semilla.

## Cliente HTTP con anfitrión controlado

`network_url`, `network_headers` y `network_policy` comprueban URL, origen, cabeceras y cuerpo antes
de invocar al proveedor. La capacidad conserva la concesión de orígenes del anfitrión y `Limitar`
solo puede reducirla. El runtime no abre sockets: `MemoryHostProvider` resuelve guiones locales por
método y URL, lo que hace deterministas las pruebas y evita depender de Internet. Un estado HTTP
completo entre 100 y 599 salvo 101 es una respuesta comprometida; los códigos 4xx y 5xx quedan en
`HttpResponse`. El cargador del anfitrión falso conserva incluso un estado 101 guionado para que la
validación del runtime lo convierta en `RespuestaInvalida` al enviar; validar al cargarlo ocultaría
el fallo de protocolo que debe observar el programa. `HEAD` conserva estado y cabeceras y entrega
cuerpo vacío.

`Redirigida` acepta solo 301, 302, 303, 307 y 308 con una sola cabecera `location`, resuelve la
referencia contra la URL final y quita el fragmento. No envía ni sigue la petición. Convierte 303 y
301/302 sobre `POST` en `GET` sin cuerpo; 307/308 conservan método y cuerpo. Cambiar el origen retira
cabeceras de credenciales, y `Enviar` comprueba el permiso del origen de destino. Las URL validan
hosts ASCII y normalizan el origen por esquema, host y puerto efectivo; IPv6 se compara en su forma
canónica y se rechazan las formas numéricas alternativas de IPv4.

El anfitrión declara orígenes mediante `network_origins`, una lista de orígenes concedidos que se
normaliza con las mismas reglas de URL que las peticiones. Los guiones de `http` conservan su
comportamiento de pruebas y también aportan sus orígenes; un consumidor con transporte propio usa
`network_origins` sin añadir respuestas ficticias. En reproducción desde cinta el anfitrión solo aporta
su identidad, sin orígenes ni guiones, así que `begin_host_effect` no aplica el rechazo
`DestinoDenegado`: el resultado de cada envío sale de la cinta, que ya registró si el destino se
concedió o se denegó. Aplicarlo convertía en fallo un envío grabado como exitoso y la reproducción
divergía.

La comprobación de orígenes por receptor solo se aplica a capacidades de red. Los receptores de archivo,
directorio, reloj, temporizador y consola no tienen concesión de orígenes, y exigirla convertía toda
operación sobre ellos en `permiso_denegado`.

`NetworkLimits` fija los valores mínimos garantizados: 1 MiB para cuerpo decodificado y bytes de
solicitud, 16 KiB para cabeceras, 64 cabeceras, cuatro peticiones de red pendientes y 30 segundos
por petición. El anfitrión puede elevar sus límites de producto. El runtime recorta el cuerpo de
respuesta y el plazo solicitados al valor del anfitrión; un exceso de cuerpo o cabeceras devuelve
`LimiteExcedido` como error de efecto y no termina el programa. El tamaño de cabeceras suma bytes
UTF-8 del nombre y valor más cuatro bytes de delimitadores por campo. Una solicitud que supera el
límite de bytes o de cabeceras se rechaza antes de invocar al anfitrión.

Las operaciones que pueden mutar conservan los fallos externos inciertos; `GET` y `HEAD` no pueden
devolver incertidumbre. La cinta usa la clasificación de efecto existente. Si una petición contiene
credenciales redactadas, la cinta queda marcada como no reproducible y no expone el secreto; no se
añade una ruta HTTP de reproducción que revele credenciales.

## Heap temporal de inspección

`clone_heap_bounded` conserva asas, alias, datos y ordinales en una copia independiente; limita sus celdas al menor presupuesto del origen y el solicitado antes de copiar. Rechaza una captura que ya excede ese máximo. La copia desactiva recolección para que la evaluación temporal no recolecte referencias capturadas y respeta el límite en toda asignación posterior. No cambia opciones ni estado del heap vivo.

Las consultas paginadas usan `dictionary_window`, que recorre únicamente ocupación para omitir entradas y carga claves/valores solo dentro de la ventana solicitada. `allocation_handle` busca el ordinal sin crear una lista intermedia y `object_field_kind` lee un único tipo sin copiar el diseño. Estos accesos conservan el orden de inserción y permiten páginas acotadas de objetos y diccionarios.
