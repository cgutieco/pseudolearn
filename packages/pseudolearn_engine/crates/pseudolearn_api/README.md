# pseudolearn_api

## 1. Qué es y qué no es

Ofrece operaciones públicas totales sobre recursos del núcleo. Implementación disponible en el workspace.

Fuera de alcance: otras responsabilidades del motor, UI, I/O libre y construcciones nuevas.

Sin pendientes locales declarados.

## 2. Guía operativa y ciclo de vida

Rust exacto del miembro, rustfmt y Clippy. Biblioteca del workspace; no se despliega por separado.
La implementación se verifica desde el workspace con `cargo xtask verify` y conformidad del sujeto engine.
La comprobación disponible usa, desde la raíz del monorepo,
`cargo run --manifest-path packages/pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command -- layers packages/pseudolearn_engine`.

## 3. Arquitectura y modelo del sistema

Construcción nativa: `build_native_object(&NativeBuildRequest)` analiza y baja el programa con el mismo camino que la
ejecución, genera el objeto ejecutable con `pseudolearn_codegen` y devuelve sus bytes con los avisos del análisis, o
`Rejected` con los diagnósticos si hay errores y `Backend` si el generador falla. `NativeBuildRequest.target` (`None` =
anfitrión) lleva el triplete del destino; un triplete que `target-lexicon` no reconoce es `Backend`, y la lista cerrada
de destinos la valida la CLI antes de llamar. Fija en los metadatos del ejecutable
la semilla y los límites de ejecución; `ExecutionIdentity` conserva `max_json_depth` y los límites HTTP para el canal
de efectos. También fija el idioma, el nombre de la fuente, las plantillas de línea
de diagnóstico y de entrada agotada que la CLI entrega, y las palabras lógicas del perfil que
`pseudolearn_vm::boolean_words` expone desde la misma tabla generada que usa la VM. La API no enlaza ni toca el disco:
el enlace es una capacidad del adaptador.

Ejecución nativa observada: `conformance_build_request` fija las plantillas de línea en campos separados por tabulador y
`native_execute_response` convierte la ejecución de un ejecutable (código de salida, salida estándar y salida de error)
en un `ExecuteResponse`: `0` completado, `3` fallo con el código del último diagnóstico de error, `4` entrada agotada
(`awaiting_input`) o límite de sentencias (`limit_reached`) y cualquier otro código o señal fallo interno. Los
diagnósticos
de la salida de error conservan código, severidad, tramo y argumentos tipados; las líneas ilegibles se ignoran y un
fallo
sin diagnóstico legible es `internalFault`. `rejected_native_response` da la forma de un programa que el análisis
rechaza.
`build_benchmark_object` entrega el objeto sin punto de entrada, sus metadatos codificados y el símbolo de la función
principal, que es lo que el trabajador de rendimiento enlaza con un lanzador propio para medir dentro del proceso.

La compilación a módulo conserva metadatos laterales de origen que la representación textual no
transporta. Los tests de integración compilan el corpus exportado y llaman directamente al bytecode y
la VM; el arnés reenvía los límites declarados por cada caso, incluidos profundidad, celdas, tareas y
capacidad de canal. `runtime_edges` cubre ventanas, índices con efectos, subtipos, despacho virtual,
copia y ausencia bajo las tres políticas de recolección. Esta vía de pruebas no implementa otro
protocolo. `RunOptions` y los envoltorios existentes se mantienen junto con los recursos públicos de
ejecución, entrada, cancelación y consultas.

Nivel 8. Dependencias internas permitidas: pseudolearn_source, pseudolearn_abi, pseudolearn_diagnostics,
pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_ir, pseudolearn_lowering,
pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_vm, pseudolearn_timeline,
pseudolearn_codegen, pseudolearn_aot_rt. Externas: serde, serde_json.
Prohibido importar capas superiores, paquetes de UI o internos de otros miembros.

Estructuras y algoritmos: Recursos con identificador; operaciones totales que devuelven `Result`; captura de defectos
internos como `DIAG.ENGINE.INTERNAL-FAULT`; codificaciones JSON canónica y binaria columnar; negociación de capacidades;
renderizado en el idioma de interfaz pedido. `help_query` consulta una sesión de edición viva mediante su revisión y una
posición de línea/columna en unidades `unicode_scalar` o `utf16`. La revisión viaja como cadena decimal; la posición se
valida en un límite exacto y se convierte a la coordenada interna del servicio. La respuesta conserva idioma de interfaz
y detalle solicitados, y expone la identidad o símbolo resuelto, la certeza y los rangos léxico y contextual en
coordenadas de escalares Unicode de la fuente original. La ayuda editorial puede ser nula aunque exista una identidad
resuelta. No se exponen índices del árbol.

Invariantes: Ningún pánico cruza la frontera.

Anfitrión simulado y resultados de efectos (`fake_host`, `execution_resource`): `FakeHostProvider` provee un árbol
virtual en memoria con archivos, argumentos y reloj lógico para aislar pruebas normativas. La terminación
`awaiting_effect` comunica la petición pendiente en JSON; `pending_effects` incluye los argumentos completos de cada
solicitud concurrente. `effect_result` acepta cualquier secuencia del lote externo pendiente, registra el resultado en
el orden en que llega y ordena a la VM seleccionar la tarea correspondiente. La VM estaciona la tarea que estaba activa
y la reanuda cuando le toca según la finalización externa. La operación conserva exclusión mutua estricta con `input`
(rechazando entradas si se espera un efecto y viceversa).

La terminación `awaiting_input` expone `pending_input` con `resource_id`, `task_id` y `request_id`. `resource_id` es la
identidad del recurso de ejecución API; `task_id` es la tarea que la VM dejó esperando; `request_id` aumenta dentro del
recurso cada vez que `Leer` vuelve a pedir texto. La operación `input` exige esos tres campos y `text`, y solo acepta la
identidad que sigue pendiente mientras la terminación es `AwaitingInput`. Una respuesta de otra ejecución, tarea o
solicitud, una duplicada, una tardía, una respuesta durante cancelación y una respuesta a una espera de efecto son
errores de uso antes de suministrar texto a la VM. Si el texto no puede convertirse al tipo de la variable, la VM vuelve
a pedir entrada y la API emite un nuevo `request_id`. La VM expone una sola espera global `AwaitingInput`; la identidad
de tarea permite validar el destinatario, no habilita lecturas simultáneas. La entrada viva se rechaza en
`ReplayFromTape` y `HistorySeek`: la reproducción obtiene el texto de la cinta y no consulta el anfitrión.

La identidad de entrada es independiente de `effect_seq`. Los efectos conservan su secuencia y sus destinatarios por
tarea; varios efectos pendientes pueden resolverse en cualquier orden admitido por la cinta. `input` y `effect_result`
no comparten un contador ni se aceptan durante la espera contraria. Liberar el recurso de ejecución elimina su anfitrión
y las capacidades vivas asociadas.

La negociación de red acepta `network_capabilities` con seis garantías exactas: validación TLS, disponibilidad del
límite de cable, distinción de errores de certificado, visibilidad de ubicación de redirección, `ssrf_policy` (`none` en
nativo: sin filtro de rangos de direcciones) y compresión. Devuelve el descriptor sin alterarlo; no concede permisos ni
orígenes. El perfil nativo declara límite de cable, errores de certificado distinguibles, destino validado por adaptador
y gzip. El perfil Fetch declara A4: límite de cable no disponible, errores de certificado y ubicación de redirección no
distinguibles, `ssrf_policy` `browser` (política de plataforma) y descompresión del navegador.

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

Cinta de efectos, modos de ejecución y errores de reproducción (`tape_wire`): `record` serializa la cinta `effect_tape`
con esquema `pseudolearn.tape/v1`, conteniendo `ExecutionIdentity` y entradas encadenadas con SHA-256 (`TapeEntry`). La
API distingue tres modos de ejecución en `ExecuteRequest` (`LiveRecord`, `ReplayFromTape`, `HistorySeek`). En
`ReplayFromTape` y `HistorySeek`, el aislamiento del anfitrión es total (no se permite entrada viva ni consultas a disco
o reloj). Ante discrepancia, fin prematuro, adulteración o no reproducibilidad de la cinta, la API emite el error de uso
correspondiente (`replay_identity_mismatch`, `replay_divergence`, `replay_truncated_tape`, `replay_corrupted_tape`,
`replay_non_reproducible`) de forma inmediata, sin reintentos ni recurrir al anfitrión vivo (`API.EXECUTE#R5`,
`API.STATE.QUERY#R5`, `API.ERRORS#R3`).

La creación de un documento admite `previous_document` cuando representa una revisión sucesora. Valida la fuente y el
recurso previo antes de crear el nuevo; solo después libera la revisión anterior y sus recursos dependientes. Un destino
previo inválido conserva todos los documentos. El identificador nuevo cambia las identidades de nodos aunque el texto
sea idéntico; las vistas retenidas del anterior no se pueden consultar. Los documentos ajenos permanecen vivos.

Las peticiones de análisis, RI, ejecución y construcción nativa admiten `source` opcional con `project_id` y
`revision_id` como cadenas decimales u64 y `source_id` como u32 positivo. El ID cero permanece reservado al documento
suelto. Diagnósticos, tokens y vistas devuelven esa identidad en cada tramo; una petición de documento suelto conserva
las formas anteriores sin el campo. `AnalyzeRequest` de texto único sigue siendo la entrada pública: conserva su perfil
y diagnóstico, tokens y tramos, sin requerir manifiesto, imports ni conversión a un proyecto. API y servicio comparten
en semantic la precedencia de perfiles y manifiestos de los módulos de proyecto.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: un fallo de E/S, una trampa del programa y un corte del anfitrión necesitan consecuencias distintas sobre la
cinta y los recursos. Elección: el fallo controlado de un efecto vuelve al programa como `Resultado::Error(ErrorES)` y
recorre `Diferir` con normalidad; la trampa termina `failed`; la cancelación y el agotamiento de límite (`cancelled`,
`limit_reached`) detienen la ejecución sin ejecutar efectos nuevos en `Diferir`. Ante un corte del anfitrión
(`cancelled`, `limit_reached`) `handle_exit` llama a `EffectSession::abort` (cinta `incomplete`, tabla de capacidades
cerrada). Ante una trampa cierra la cinta como al completar (`seal_abandoned_effects` y `EffectSession::finish`, que
también cierra la tabla de capacidades sin cambiar el estado de la cinta). En todos los casos llama a
`HostEffectProvider::close_all`, de modo que `host_observation.open_resources` queda en cero;
`tests/host_release_tests.rs` lo comprueba para las tres terminaciones no exitosas, comprueba que la trampa y la
ejecución completada conservan la cinta `reproducible` y que el corte la sella `incomplete`. La trampa conserva la
reproducibilidad porque es determinista: con la misma identidad y las mismas entradas la reproducción vuelve a producir
la misma salida y la misma trampa, y así una persona puede repetir el error que quiere entender; antes se sellaba
`incomplete` igual que un corte, lo que ninguna regla pedía. Los efectos que otras tareas esperaban se sellan como
abandonados y, si escribían, dejan la cinta `uncertain_external_state`, igual que al completar. Se descarta un estado
`AbortedByHost` aparte: el motivo ya lo expresa la terminación y la cinta `incomplete` ya impide su reproducción.
Cancelar durante `awaiting_effect` no espera la respuesta del anfitrión: la siguiente `advance` o `effect_result` llama
a `settle_cancelled_suspension`, que descarta el efecto pendiente, sella la cinta `incomplete`, cierra la tabla de
capacidades y termina con `cancelled`; un `effect_result` posterior es un error de uso.
`tests/effect_suspension_session_tests.rs` lo comprueba junto con la alternancia `awaiting_input`/`awaiting_effect`, la
respuesta `failed`, la respuesta duplicada, el límite de sentencias tras reanudar y que `replay_from_tape` y
`history_seek` nunca suspenden aunque el anfitrión sea `detached`. Pendiente declarado: ninguna de estas pruebas está en
el corpus porque el esquema de casos no expresa `awaiting_effect` como terminación esperada, no acciona `effect_result`
ni altera la cinta; `ENG.EXEC.MODEL` C11 ejerce solo la distinción con `awaiting_input` (un efecto resuelto por el
anfitrión síncrono no suspende; `Leer` sí). Ocho binarios de prueba (`execution`, `native_access`, `probes`,
`reference_vocabulary`, `runtime_corpus`, `runtime_edges`, `state_pages`, `stepping`; 22 pruebas) fallan en la línea
base con `cargo test -p pseudolearn_api --features native`; sus fixtures declaran variables sin `Mutable` y asignan, y
son ajenos a este contrato.

Problema: configurar el montón desde la API debe preservar el calendario de la VM. Elección: las ejecuciones del sujeto
engine conservan el mínimo automático de 4096 celdas. Se descarta heredar la configuración específica de AOT.

Problema: la emisión debe medirse sin análisis ni lowering. Elección: `PreparedNativeBenchmark` prepara una RI inmutable
antes del reloj; `emit_benchmark_object` emite el objeto y sus metadatos. La inspección explícita captura CLIF sin
modificar las funciones emitidas; permanece fuera de la medición. El módulo `literals` es dueño de los datos de texto
del objeto. Se descarta mezclar las cadenas CLIF con el intervalo de emisión.

Problema: los consumidores móviles y Wasm no compilan programas nativos. Elección: la API desactiva AOT por omisión y
expone sus módulos y dependencias nativas solo con la feature `native`; la CLI y el trabajador AOT la activan
explícitamente. Se descarta confiar en la eliminación de símbolos del enlazador, porque no elimina Cranelift del grafo
de compilación.

Problema: el sujeto `aot` debe contrastarse con el corpus ejecutando el binario real, y el proceso solo ofrece texto.
Elección: el adaptador compila con plantillas máquina-legibles y esta capa reconstruye la respuesta de ejecución a
partir
del código de salida y la salida de error. Descartado: ejecutar en proceso código generado (exige `unsafe` y no prueba
el
enlace ni el protocolo del proceso) y ejecutar la VM como respaldo, que ocultaría defectos del sujeto.

Problema: medir ejecución no debe incluir compilación. Elección: `PreparedProgram` conserva un programa cargado
inmutable; `prepare_program` compila y `execute_prepared` crea una ejecución nueva con semilla, límites y entradas
explícitos. Se descarta medir el arranque del adaptador o la serialización. El trabajador valida cada salida fuera del
intervalo.

Problema: una ejecución por lotes no debe copiar ni suspender la máquina al final de cada lote. Elección:
`ExecutionResource` conserva una `Machine` viva, `LoadedProgram` comparte sus datos inmutables mediante `Arc`, y
`CheckpointStore` recibe checkpoints diferenciales. Una consulta restaura desde el punto más cercano y reproduce en una
máquina temporal. La API elimina sus snapshots completos paralelos y conserva los límites de retención mediante un
checkpoint base. El adaptador y la CLI solo consumen esta frontera. Se descartan implementaciones de ejecución
independientes en consumidores.

Problema: ofrece operaciones públicas totales sobre recursos del núcleo respetando los observables del corpus.
Elección: Recursos con identificador; operaciones totales que devuelven `Result`; captura de defectos internos como
`DIAG.ENGINE.INTERNAL-FAULT`; codificaciones JSON canónica y binaria columnar; negociación de capacidades; renderizado
en el idioma de interfaz pedido.
Alternativas descartadas y fundamento: El corpus API define recursos y codificaciones; se rechaza un objeto por evento
en FFI y copiar todo el estado en cada paso.

Problema: la codificación binaria debe conservar la misma referencia de fuente que la respuesta JSON sin
añadir identidad de documento al modelo de eventos de la VM. Elección: el codec de la API pone `data` y
`source` en el registro JSON canónico de cada evento PLEV; el decodificador valida ambos y reconstruye la
respuesta completa. El codec JSON valida y conserva los objetos recibidos. Los eventos sintéticos llevan
`source: null`. `event_shape` concentra la forma estricta: rechaza claves de evento desconocidas, claves de datos
ajenas a la clase, ramas fuera del alfabeto e `indice` no entero, y un registro del pool que no coincide byte a byte
con su forma canónica (espacios, otro orden, claves repetidas o extra). Se descarta conservar claves desconocidas: el
pool binario solo tiene `data` y `source`, y la ida y vuelta dejaría de ser la identidad que pide
`API.WIRE-FORMAT#R2`. `tests/event_codec_strictness.rs` cubre los rechazos y la ida y vuelta de eventos reales. Se descarta resolver la fuente después de decodificar, porque la revisión y el nodo no se
pueden recuperar solo desde el tramo.

La versión PLEV 2 añade identidad compuesta al registro `source`; PLEV 1 sigue decodificándose y solo puede escribirse
si ningún evento contiene esa identidad. `negotiate` elige la versión de escritura entre las versiones anunciadas y
expone por separado las versiones de lectura. Los enteros u64 de la identidad usan cadenas decimales canónicas;
`source_id` sigue siendo u32. El binario nunca asigna significado nuevo a bytes PLEV 1.

Problema: los emisores, diagramas y comprobaciones estructurales consumían árboles internos del núcleo Dart. Elección:
la API publicará una vista inmutable por revisión con unidades, nodos, relaciones, tramos y eventos enlazados por
identificador opaco. La vista no revela índices del CST, HIR ni bytecode y el consumidor no vuelve a analizar el texto.

Problema: posiciones públicas y unidades recuperadas deben describir el texto, no desplazamientos internos.
Elección: la API convierte cada tramo UTF-8 a pares línea/columna y expone el esquema de unidades
recuperadas en orden de fuente. El análisis pasa el perfil al front-end; solo solicita HIR sin
errores léxicos o sintácticos. El idioma de presentación se resuelve al renderizar un diagnóstico
mediante su código y argumentos, sin modificar códigos, tramos ni salida del programa.
Se rechaza que la CLI tenga que reconstruir posiciones o traducir un mensaje ya presentado.

La respuesta de análisis incluye todos los tokens léxicos en orden de fuente, incluso trivia,
caracteres inválidos y fin de archivo. Cada token conserva su identidad pública y tramo en
línea/columna; el consumidor obtiene resaltado sin volver a analizar el texto y puede mantenerlo
cuando el árbol incluye errores recuperables.

Los nombres del alfabeto latino español se aceptan en ambos perfiles. La comparación usa NFC
sin alterar el texto ni los rangos que reciben y devuelven las peticiones de documento único.

La vista pública del programa (`program_view`) se proyecta desde el árbol sintáctico del documento: unidades en
orden, nodos de declaración, sentencia y expresión con identificadores opacos por revisión, tramos con
desplazamientos UTF-8 como cadenas decimales, herencia y sobrescrituras. Cada evento de una ejecución con sesión
lleva `source` (revisión, nodo y tramo): la máquina registra el tramo de la instrucción que lo emite y la API lo
resuelve contra la vista por coincidencia exacta de línea y columna de inicio y fin, con preferencia de expresión
para decisiones, llamadas y retornos y de sentencia para el resto; si no hay coincidencia exacta usa el nodo más
interno que lo contiene. Se descarta resolver por línea, que confunde sentencias de una misma línea. `state_pages`
añade `query_page` (`array_cells`, `frame_variables`, `object_fields`) con cursores de la forma «huella.desplazamiento»
cuya huella cubre sesión, ejecución, revisión, consulta, destino, evento y tamaño de página; cualquier discrepancia es
un error de uso que no altera la ejecución. Las páginas de arreglo incluyen las dimensiones, las consultas de marco
etiquetan los valores escalares con su tipo (`entero`, `real`, `booleano`, `caracter`, `texto`) sin alterar el estado
capturado por la conformidad, y `create_analysis` acepta un `locale` que renderiza los mensajes de diagnóstico y de
ejecución con independencia del perfil sintáctico.

La extensión de ejecución usa recursos con identificador para iniciar, avanzar, entregar
entrada, cancelar y posicionarse. Las consultas se refieren a un instante y al horizonte retenido;
la reproducción no altera la continuación presente. JSON canónico y binario columnar comparten datos.
Solo se anuncian capacidades implementadas. El borde convierte defectos imposibles a internalFault,
pero las pruebas exigen ausencia de pánicos, no solamente captura. Los recursos inválidos o liberados
producen errores de uso. La API importa todas las capas públicas permitidas y no expone sus estructuras
mutables. Los tests cubren negociación, recursos, fronteras, lotes, entrada y consultas repetidas.

Los argumentos conservan su clase: lexema, token, tipo, término o número. El catálogo genera la ficha
de argumentos requeridos; el borde valida que no falten claves ni se sustituyan números por cadenas.
Los tokens y tipos primitivos se resuelven con el vocabulario del programa antes de presentar prosa.
La sustitución recorre la plantilla una sola vez y no reinterpreta llaves dentro de un lexema del usuario.

`help_query` consulta el hover estructurado de la sesión de edición y no modifica el recurso. `summary`
devuelve categoría e identificador y, cuando existe ficha, `card` con identidad, título y resumen; `full`
añade tipo, carácter intrínseco, firma, la descripción del token y el resto de la ficha (categoría, plantilla `form` en
líneas con sangría y segmentos `word`, `symbol`, `slot` o `ellipsis` marcados con
`joined`, partes en el orden de la plantilla con su clase `word` o `slot`, `result`, reglas, errores comunes
con programa opcional y ejemplos con referencia, clase, nota, programa y salida esperada). `language` queda
separado del perfil de sintaxis: selecciona la prosa en `es` o `en`, mientras que lexemas, tipos, firmas,
plantilla y programas de ejemplo están en el perfil de la sesión. La ficha se elige por la identidad léxica
del token y, si varias la comparten, por el contexto resuelto (operador unario o binario, construcción que
lo contiene); los programas y salidas proceden de los casos del corpus y la consulta nunca los ejecuta. Los
tipos de la ficha viven en `help_card_model.rs` para mantener `model.rs` dentro de su límite de tamaño. Un
símbolo del usuario, una posición sin token o una identidad sin ficha devuelven `card: null`. Un recurso
liberado, de otra clase o una revisión obsoleta no produce contenido de ayuda.

Problema: el análisis y la ejecución de un proyecto necesitan operaciones públicas totales. Elección:
`analyze_project` y `execute_project` son operaciones de la sesión (sin recurso) que reciben el proyecto como
datos (`project_resource` los valida y convierte), construyen el catálogo, analizan cada módulo con el modo de
proyecto, enlazan un único HIR y, al ejecutar, un único RI que va a la VM por el mismo camino que un programa
suelto. Una petición mal formada es un fallo de uso; un proyecto bien formado pero inconsistente devuelve
`project_errors` y ninguna ejecución. Cada diagnóstico se convierte con la fuente que su tramo identifica, de
modo que lleva la identidad de su propio archivo. No se añaden recursos de proyecto a la sesión ni se concatenan
textos. `project_compile` es el paso común de análisis, enlace y bajada a un RI verificado: lo consumen
`execute_project`
(VM) y `build_native_project_object` (feature `native`), de modo que ambos ejecutan el mismo módulo. Un rechazo del
proyecto (errores de proyecto, de manifiesto o diagnósticos) se devuelve como `NativeBuildFailure::ProjectRejected` con
el
mismo JSON que `execute_project`, sin objeto. Los límites del manifiesto se aplican salvo que la petición nativa los
fije.
`prepare_native_project` (feature `native`) prepara la ejecución nativa de `execute_project` para el sujeto `aot`:
compila el
objeto con la tabla de nombres de los archivos del proyecto y devuelve la petición de ejecución equivalente; un rechazo
del
proyecto vuelve como el mismo valor que `execute_project`. `NativeProjectRun::complete` añade `project_errors` y, si
hubo
manifiestos, `manifest_errors`, de modo que la respuesta nativa tiene la forma de la del motor. Se descartó reconstruir
esa
forma en la CLI, porque duplicaría el contrato del recurso de proyecto.
`start_project` recibe los mismos argumentos que `execute_project` y, si el proyecto compila sin errores, devuelve un
recurso de ejecución con el contrato de `start` de archivo suelto: `advance`, `input`, `cancel` y `release` conservan un
único
dueño. Comparte con `execute_project` el paso `project_compile` y la carga a la VM (`execution_request` y
`load_compiled` en
`project_operations`), de modo que no hay un segundo compilador de proyectos. Un rechazo devuelve el mismo JSON de
errores que
`execute_project` y no crea recurso. El recurso no lleva análisis ni vista del programa (`analysis` 0), por lo que las
consultas de nodos no están disponibles para proyectos. El módulo `project_start` aloja únicamente esta operación.
`execute_project` marca su identidad de fuente con `source_id` 0, que significa «cualquier archivo del proyecto»: cada
diagnóstico de ejecución toma el `source_id` del tramo del fallo, de modo que un fallo dentro de un módulo importado
nombra su archivo (el cero sigue reservado al documento suelto en las peticiones de documento).

Los errores de paquetes en ciclo llevan además `chain`. Los diagnósticos de ciclo de importación relacionan tramos
de otros archivos: cada tramo relacionado se convierte con la fuente que su propia identidad señala
(`project_diagnostics`),
nunca con la del diagnóstico principal. La proyección construye una sola vez el índice de fuentes, conserva los
relacionados en su secuencia original y usa las claves canónicas del catálogo para ordenar todos los diagnósticos.
Una fuente ausente queda después de las fuentes conocidas y no se sustituye por el primer módulo. Una identidad
desconocida es un fallo interno controlado. La clave de orden no cambia los IDs opacos que devuelve el contrato,
y el idioma de interfaz no modifica el orden.

Los errores de manifiestos múltiples conservan la ubicación documental en NFC y se ordenan por su clave portable;
dentro de cada documento usan línea, columna, código y campo. Los errores de un lock conservan la posición y el
campo del propio documento.

Problema: el contenido fijado de las dependencias debe verificarse antes de compilar, sin red. Elección: `build_lock`
recibe los paquetes (nombre, origen lógico, tipo, dependencias y, para los fijados, archivos con ruta y texto), calcula
los digests SHA-256 con `lock_digest` (dominios y orden descritos en el README de project) y devuelve el texto canónico
del lock; `resolve_lock` compara un lock con los paquetes entregados y devuelve `verified` y `lock_errors` con línea y
columna. Ambas son puras: no leen ni escriben disco, no usan red y no ejecutan nada. Los bytes que se hashean son los
que el anfitrión pasa después al análisis, de modo que lo verificado es lo compilado. El presupuesto de bytes del lock
es
una constante candidata (`lock_wire`). Un hash verifica integridad, no autenticidad del origen.

Problema: el manifiesto de un paquete es una entrada declarativa cuya autoridad concede el anfitrión. Elección:
`resolve_manifest` (texto, ubicación y concesiones opcionales) devuelve la configuración con la procedencia de cada
campo o los errores con línea y columna, y `analyze_project`/`execute_project` aceptan `manifests` en lugar de
`packages` (exactamente uno de los dos; lo contrario es un fallo de uso) y un argumento `grants` con los techos de
`limits` (`depth`, `statements`, `cells`). Los errores de manifiesto se devuelven en
`manifest_errors` con su ubicación y bloquean el análisis; `execute_project` aplica a la ejecución solo los límites
efectivos, que nunca superan la solicitud ni la concesión, del paquete que contiene la entrada. El presupuesto de
bytes del manifiesto es una constante candidata del transporte (`manifest_wire`), pendiente de calibrar. Abrir,
analizar o ejecutar un proyecto no ejecuta scripts ni concede permisos por su contenido, y el idioma de interfaz no
interviene. La lectura de manifiestos desde disco y la fuente de las concesiones son de la CLI.

Perfil por archivo: cada archivo de una petición de proyecto admite `profile` (`es` o `en`; otro valor es un fallo de
uso). La
resolución sigue el README de project y usa la apertura que detecta `detect_vocabulary_profile`. El argumento `profile`
de la
petición es solo el respaldo de los archivos sin otra procedencia y el idioma de los mensajes; los lexemas de los
argumentos
de un diagnóstico (fichas y tipos) usan el perfil del archivo que lo contiene (`convert_in_profile`). `profileMismatch`
se
añade al archivo contradictorio y bloquea la ejecución. Al bajar a RI, el vocabulario del módulo es el de la entrada y
se
registra la tabla `source_id → perfil` de todos los archivos; la ejecución y la compilación nativa formatean los lógicos
con el perfil del archivo que contiene cada operación. `native_build` rellena `site_boolean_words` solo si el módulo
tiene
tabla de perfiles, por lo que el archivo suelto no cambia. El adaptador AOT de conformance aún no acepta proyectos; la
construcción nativa de proyectos se prueba con `tests/native_project_build.rs` y desde la CLI.

La vista pública conserva nodos explícitos de construcción y patrón de variante, propagación y descarte. Expone
identidades canónicas de alternativa y constructor de tipo, mutabilidad e inicialización del vínculo, y roles de carga
útil, vínculo, tipo e inicializador. No expone los registros sintéticos ni sus ranuras de almacenamiento.

### Identidad del grafo de paquetes, rechazo nativo y reproducción de entrada

- `package_graph_digest` de la identidad de ejecución es un SHA-256 real: se calcula sobre el encabezado
  `pseudolearn.package-graph/v1`, el número de unidades (una, en archivo suelto), el resumen de la fuente y, si la
  petición trae identidad de fuente válida, proyecto, revisión e identificador de fuente. Antes era la cadena `none`,
  que no distinguía grafos. Un cambio de programa o de revisión cambia el resumen y la reproducción lo rechaza con
  `replay_identity_mismatch`.
- La identidad de la cinta solo lista los presupuestos configurados: `statements` no figura cuando la
  petición no lo fija, y ningún entero de la cinta excede `i64::MAX`. Antes un presupuesto ausente se escribía como
  `u64::MAX`; un consumidor que decodifica JSON con enteros de 64 bits con signo (la app Dart) reenviaba la cinta con
  un número decimal distinto y la reproducción la rechazaba como `replay_corrupted_tape`.
  `tests/replay_transport_tests.rs`
  verifica la ausencia de esos presupuestos y la cota de los enteros, el rechazo de inicio sin cinta (`usage`) y con un
  esquema desconocido (`version`), que `advance` con anfitrión incluye `effect_tape` y que un segundo `advance` durante
  una
  espera repite la misma solicitud sin eventos nuevos (propiedad sobre la que la app acota el drenado de efectos).
- `native_effect_input` rechaza con error de uso toda petición nativa con `observe` distinto de `none`, con `state_at` o
  con modo `history_seek`: el sujeto nativo no ofrece observación ni retroceso y no los simula.
- En `ReplayFromTape` y `HistorySeek`, cuando la máquina espera entrada (`awaiting_input`), el recurso de ejecución
  resuelve la siguiente entrada de lectura de consola de la cinta y entrega su carga como línea; la reproducción es
  autónoma y la API sigue rechazando `input` externo. Una cinta sin más lecturas produce `replay_truncated_tape`.
- Verificación del modo desacoplado: `tests/effect_suspension.rs` cubre suspensión con `awaiting_effect`, resolución
  manual, rechazo de `input` durante la espera, secuencia y tipo de resultado incorrectos, resultado sin espera,
  cancelación durante la espera, incertidumbre rechazada en efectos de solo lectura y escritura incierta que el programa
  observa y que marca la cinta `uncertain_external_state`.
- Pruebas que compilan programas completos hasta la VM: `tests/vm_awaiting_effect_tests.rs` (salida
  `RunExit::AwaitingEffect` con su carga útil y distinta de `AwaitingInput`), `tests/cleanup_effect_edges_tests.rs` (el
  `effect_call` de un `Diferir` aparece en las aristas de retorno y de propagación posteriores al registro, tras guardar
  el resultado) y `tests/tape_privacy_budget_tests.rs` (secretos por referencia y corte exacto de `max_tape_bytes` de
  extremo a extremo).

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.
Las fuentes generadas se producen desde la exportación del corpus en OUT_DIR; nunca se copian manualmente.

## 6. Decisiones de producto que condicionan el código

Contratos: `API.*`, `DIAG.ENGINE.INTERNAL-FAULT`.
La ejecución y la observación conservan la misma semántica; idioma de interfaz y vocabulario son independientes.
Los identificadores del usuario, el texto original y la salida del programa se conservan.

El registro opcional `summarize_events` con `capture_states: false` calcula SHA-256 incremental de todos los eventos y
su cantidad, sin devolver la lista. Normaliza únicamente las identidades opacas por primera aparición, conservando las
relaciones de alias y todos los demás datos. Evita respuestas mayores al límite del transporte sin truncar la ejecución
ni modificar sus límites. `sha2` queda confinado a esta frontera de serialización; los registros ordinarios conservan
los eventos completos.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, texto vacío, Unicode, tamaño cero, profundidad extrema y bordes numéricos.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos;
formato, Clippy, auditoría de dependencias y pruebas diferenciales según los contratos de este crate.

## 8. Fuentes consultadas y genealogía conceptual

El corpus API define recursos y codificaciones; se rechaza un objeto por evento en FFI y copiar todo el estado en cada
paso.

### Funciones como valores y ámbitos de ejecución

La prueba `function_execution` consume los programas normativos del corpus de funciones, sin mantener copias locales.
Contrasta ambos perfiles y gemelos, recolección ordinaria y forzada, salida, terminación, diagnósticos y eventos. Con
`native`, enlaza y ejecuta los objetos emitidos y los contrasta con la VM. Las bibliotecas del arnés se localizan en el
directorio de dependencias del ejecutable de prueba.

## Colecciones, interfaces e iteración con limpieza

La vista pública expone nodos de interfaces, realizaciones, parámetros restringidos, Para Cada, Salir y Diferir, con
papeles de hijos. interface_identity, realized_interfaces y constraint_interface usan identidades opacas de nodos de la
revisión, sin representar la interfaz como valor. La consulta de estado presenta longitud y elementos de Vector, y
entradas ordenadas con clave y valor de Diccionario; conserva identidades compartidas y hojas de registros. Los
metadatos sintéticos de disposición son internos y no se interpretan como campos ordinarios de objetos.

`program_view_static_inherited.rs` calcula el estado heredado recorriendo la cadena entre la clase que se dibuja y la
que declaró el contrato. Conserva los diagnósticos propios del ancestro y enlaza `incompatibleMethodOverride` solo
cuando el análisis aporta el tramo relacionado de una firma de ese contrato. El origen de esa realización pasa a ser el
nodo del método incompatible; la realización heredada válida mantiene su estado. El nodo `method_member` del origen
incluye `method_signature_span`, derivado de sus hijos sintácticos hasta el cuerpo, para que la app seleccione el
encabezado exacto al navegar.

La vista también proyecta enumerados (`enum_unit` con `enum_identity` y `enum_members`), registros (`record_unit` con
`record_identity` y `record_fields` hacia sus nodos `record_field`) y literales de función (`function_literal` con
`closure_identity` y `captured_bindings` hacia las declaraciones capturadas). Los datos salen de
`program_view_values.rs` a partir del análisis semántico, y las relaciones usan únicamente identificadores de nodos de
la misma vista, que ya codifican proyecto, revisión y fuente: una relación hacia otra procedencia no se emite. Son
atributos aditivos de solo lectura; el dibujo de diagramas con ellos pertenece a una fase posterior.

Las variantes declaradas también son nodos públicos: `variant_unit` (papeles `name`, `type_parameters` y `alternative`),
`variant_alternative` (`name` y `field`) y `alternative_field` (`name` y `type`), clasificados en `program_view_kind.rs`
como declaraciones. Antes de proyectarlas, sus identificadores quedaban huérfanos en la vista y el diagrama no podía
dibujar la variante. Como el análisis las modela con la disposición de los registros, un nodo de variante o de
alternativa con campos puede llevar `record_identity`/`record_fields`; el consumidor no debe leerlos como registro. Una
plantilla de clase no figura entre las clases concretas del análisis, así que `program_view_static_templates.rs` añade
sus realizaciones explícitas: resuelve el contrato por nombre dentro del módulo entre las plantillas de interfaz y las
interfaces concretas, y emite la fila con identidades de nodos, igual que una realización ordinaria; un contrato
desconocido sigue el camino de realización sin resolver. Una plantilla que ya tiene fila no se duplica. Descartado:
dejar que la app reconstruyera la realización desde el texto, porque usaría el nombre como identidad.

`program_view_exits.rs` añade los datos de salida y limpieza de `API.PROGRAM.VIEW#R10` recorriendo solo la composición
de la vista, después de las anotaciones nominales. Cada `break_statement`, `return_statement` y `propagation` recibe
`control_exit` con `kind`, `target_node_id` y `cleanups`: se sube por los padres hasta el bucle interior (Salir) o
hasta la unidad o `function_literal` (Retornar y Propagar), y en cada `body` atravesado se toman, en orden inverso, las
`defer_statement` hermanas que preceden a la rama de la salida, primero el ámbito interior. Cruzar un
`defer_statement` deja la salida sin destino ni limpiezas, igual que un Salir fuera de bucle: el análisis ya los
rechaza y la vista no inventa un destino. Cada `body` con limpiezas recibe `normal_cleanups` y cada `defer_statement`
su `cleanup_scope_node_id`. Es la misma noción de ámbito que usa el descenso a RI, que abre un ámbito de limpieza por
lista de sentencias; se descarta leer los bloques de limpieza de la RI porque la vista no expone índices internos. El
cuerpo diferido conserva el papel `cleanup_body` que ya publicaba la vista. Cubre `tests/program_view_exits.rs`
(ruptura de bucle interior, retorno y propagación con limpiezas anidadas, fin normal, función literal, salida huérfana
y salida dentro de un cuerpo diferido).

Los tests de estas capacidades se ejecutaron en selecciones acotadas, incluida la comparación de gemelos con recolección
forzada. La conformidad del corpus sigue pendiente de la revisión editorial independiente de los contratos nuevos, y la
medición de tamaño excede el presupuesto de Wasm.

La grabación exporta la cinta de la sesión viva. La frontera de ejecución comprueba cada operación
de consola frente al reproductor antes de entregar el lote al consumidor; una cinta inválida nunca
se normaliza ni se repara al leerla. El formato y sus hashes pertenecen al runtime compartido.

### Rechazo de reproducción y aislamiento verificados

- Los cinco códigos `replay_*` se disparan en `tests/tape_rejection_tests.rs` sobre `replay_from_tape` y `history_seek`:
  identidad (fuente, semilla), fin prematuro (última entrada recortada y cinta vacía, con la cadena de hashes re-sellada
  para que solo la secuencia delate el corte), divergencia (resumen de petición, orden permutado y entrada sobrante),
  adulteración (hash, carga, secuencia contigua y campo desconocido) y cinta incompleta o truncada por presupuesto. Una
  versión de esquema desconocida es `UnsupportedVersion`, no un error de reproducción. Ningún rechazo devuelve salida
  parcial.
- `pseudolearn_runtime/tests/tape_replay_host_isolation_tests.rs` demuestra con un proveedor espía que, en cada rechazo
  de secuencia, el contador de llamadas al anfitrión vale `0`; la reproducción íntegra de control también lo deja en `0`
  mientras la grabación viva lo deja en `1`.
- El esquema de casos del corpus no puede alterar una cinta ni observar `effect_seq`, de modo que los casos de
  `ENG.EFFECT.TAPE`, `API.EXECUTE` y `API.STATE.QUERY` ejercen la grabación y la reproducción aislada con
  `grabar_y_reproducir` (salida y terminación iguales, cero llamadas al anfitrión) y la rama de rechazo la cubren estas
  pruebas de Rust.
- Se eliminó `compute_entry_hash`: era una función pública con una fórmula distinta de la cadena real
  (`tape_entry_hash`) que solo usaba una prueba, de modo que la prueba no comprobaba la cinta que se serializa. La
  prueba `recorded_entry_hashes_chain_the_previous_hash` verifica ahora la cadena de la cinta grabada.
- Los programas de `recording_options.rs` y `resources.rs` declaraban `Definir x Como Entero;` y asignaban; desde la
  mutabilidad explícita el análisis los rechaza, de modo que cinco pruebas de grabación y de recurso de ejecución
  fallaban sin que nadie lo viera. Declaran ahora `Definir … <- 0`.
- `recording.rs` exporta la cinta de la sesión; `recording_digest.rs` resume eventos y no participa en la cadena de la
  cinta, que tiene su propio `entry_hash`. La implementación del formato vive en `pseudolearn_runtime`.

### Dependencias pegadas sin enlazar en la vista del programa (`API.PROGRAM.VIEW#R15`)

Problema: un documento que se analiza solo no tiene proyecto, de modo que `Importar` y `Exportar` no tienen contra qué
resolverse, pero la estructura útil del resto del archivo no debe perderse. Elección: el análisis autónomo conserva su
diagnóstico `moduleSyntaxOutsideProject` (no se creó un código nuevo) y la operación `program_view` usa
`ProgramView::build_with_pending_links`. Cuando ese diagnóstico es el único error del documento,
`program_view_source.rs`
vuelve a leer el mismo texto con el analizador de módulos, que sí produce los nodos de la directiva, y la vista se
construye sobre ese árbol. `program_view_dependencies.rs` añade la clave `dependencies`: una fila por directiva en orden
de
fuente con `dependency_id` (prefijo `d`, estable para la revisión y la fuente), `kind`, `visibility` (`local` para
`Importar`, `exported` para `Exportar`, derivada de la regla y no de un prefijo), `path`, `alias`, `status`
(`unlinked`), `diagnostic` y `span`. Los segmentos de la ruta no se emiten como nodos del árbol, para que ningún
consumidor los trate como expresiones huérfanas. Una ruta vacía, incompleta, con `..` o absoluta es un error sintáctico
distinto y la vista no existe; igual ocurre si junto a la directiva hay otro error. La ejecución, la grabación y la
vista de eventos siguen usando `ProgramView::build`, que rechaza cualquier error: un documento con un enlace pendiente
no se ejecuta. Nada de este camino abre disco ni red; la API no tiene anfitrión durante el análisis. Se descartó
resolver el nombre contra el directorio de trabajo porque haría depender el resultado del entorno. Cubre
`tests/program_view_dependencies.rs` (12) y los casos C48–C52 de `API.PROGRAM.VIEW` por el sujeto app.

### Proyección de tipos y operaciones de capacidad en la vista del programa

`program_view_effects.rs` añade a los nodos de la vista pública tres atributos: `builtin_type` (`bytes`, `io_error`) y
`capability_type` (`console`, `arguments`, `directory`, `file`, `clock`, `timer`) en los nodos de tipo, reconocidos por
su lexema en ambos perfiles con `pseudolearn_semantic::capability_types::find_capability_kind`, y `effect_operation`
(identidad de `LIB.MODEL`, por ejemplo `file_open`) en los nodos postfijos, tomado de las expresiones
`HirExpression::Effect` del análisis. La anotación reutiliza el análisis único de
`program_view_annotations::call_names`, que ya resolvía `builtin`. Un programa sin capacidades no proyecta ninguno de
los tres. Cubre `tests/program_view_effects.rs` y el caso `API.PROGRAM.VIEW` C11.

El anfitrión en memoria acepta `cancel_on_awaiting_effect` y `alterar_cinta` (ver `pseudolearn_runtime`), de modo que el
corredor de conformidad de `aot` ya no rechaza esos casos con `ruta_invalida`.

## Integración de tareas y canales

Las pruebas `task_failure_tests`, `task_channel_tests` y `task_deadlock_tests` atraviesan análisis,
RI, bytecode y VM, incluido el avance con anfitrión desacoplado. Cubren resultados falibles,
limpiezas cooperativas, contrapresión, elección por orden textual y ubicaciones relacionadas
del bloqueo. `task_lowering_tests` localiza los rechazos en la frontera de RI o bytecode.
Estos tests se ejecutan por archivo desde la raíz del motor; no sustituyen la conformidad de
los sujetos ni las pruebas de reconstrucción histórica o de cinta concurrente.

## Historia de una ejecución con entregas reales de efectos

Problema: con un anfitrión desacoplado los resultados de varias esperas llegan en el orden en que terminan, agrupados
entre
dos `advance`, y el planificador vivo elige la tarea a reanudar antes de saber qué resultado llegará. Reconstruir un
evento
repitiendo la cinta sola (`replay_machine_with_effects`) resuelve cada espera en el orden de petición y no puede
reproducir
esas agrupaciones, así que respondía «evento inalcanzable». Elección: `ShadowLog` (`execution_shadow.rs`) guarda las
operaciones que modifican la ejecución (`advance` con su tamaño, `effect_result` e `input`) y la petición original; si
hubo
al menos una entrega externa, `machine_at` y `history_window` repiten ese registro en un gemelo, un `ExecutionResource`
nuevo construido con el mismo código, y toman de él la máquina o los eventos. El gemelo recoge los eventos de cada
instrucción con su tarea. Si la instrucción que cruza el evento pedido emite varios, se devuelve el estado anterior a
ella,
no el posterior, para que una tarea que termina en esa instrucción siga siendo inspeccionable antes de su
`task_completed`.
Se descartan guardar una imagen por evento (coste proporcional a la ejecución) y enseñar a la reproducción de cinta las
agrupaciones de entrega (la cinta no registra en qué lote llegó cada resultado). El camino anterior queda para
ejecuciones
sin entregas externas, con depurador configurado o cancelación, donde el registro no es completo. El coste de una
consulta
es el de repetir la ejecución hasta ese evento. Pruebas: `live_host_history_tests`.

## HTTP en el anfitrión de prueba

`FakeHostProvider` usa el mapa `http` del anfitrión de memoria, indexado por método explícito y URL;
no contiene un cliente de red real. Los estados HTTP completos se entregan al programa como
`RespuestaHttp`, incluso cuando son 4xx o 5xx. La grabación y reproducción de respuestas no
secretas atraviesa la API y la reproducción no llama al anfitrión. Las pruebas del API verifican esta
frontera de integración; validación de URL, autorización y representación permanecen en runtime.

## Evaluación de inspección sin efectos

`inspect_expression` reconstruye el evento y la tarea solicitados sobre una copia, toma únicamente los nombres visibles
del marco y deriva sus tipos de los metadatos públicos de ejecución. La entrada de expresión del parser exige EOF;
semántica valida un subconjunto sin llamadas y utiliza la resolución ordinaria. Lowering emite una función temporal con
parámetros de captura, y el bytecode y los operadores de la VM calculan el resultado sobre un heap copiado sin
anfitrión. No se concatena fuente ni se introduce otro evaluador.

Los literales y capturas de texto se materializan en el heap temporal como valores explícitos. Las identidades y alias
de arreglos y objetos se conservan dentro de la copia. El presupuesto incluye el heap capturado: una captura que ya
excede 65536 celdas o el límite menor configurado falla antes de duplicarla. La evaluación limita texto a 8192 bytes,
nodos a 1024, profundidad sintáctica y marcos a 64, sentencias a 4096 y bombeo a 65536 instrucciones. Las entradas y
señales de cancelación del programa se desconectan del temporal; nunca recibe capacidades físicas.

El resultado contiene `type`, `value` textual canónico y `reference` cuando representa una asignación retenida. Los
rechazos sintácticos, de pureza, de tipos, dominio o presupuesto son errores de uso. La continuación, variables, salida,
semilla, agenda y cinta de la ejecución viva permanecen intactas.

## Control persistente e inspección de depuración

El control de depuración pertenece a la API porque todos los consumidores deben detenerse con los
mismos predicados del núcleo. `debug_configure` resuelve breakpoints por fuente y posición exacta;
`debug_control` configura continuación, pasos, pausa o retroceso y `advance` bombea el mismo recurso
vivo. Se descarta usar `step`, cuya responsabilidad anterior recompila una ejecución distinta.
Las paradas ocurren en eventos de entrada a sentencia antes de sus efectos; salir usa el retorno
que cierra el marco. La pausa conserva entradas y efectos pendientes y no cancela la ejecución.
Salir desde el marco base de una tarea no tiene llamante al que volver: la tarea termina y la parada
se informa como `task_terminated`. Un breakpoint solo se verifica sobre una entrada a sentencia cuyo
tramo coincide exactamente con la línea y columna pedidas; nunca se desliza a otra sentencia.

`debug_state` proyecta tareas, fuentes inmutables y ventanas de marcos (`start_frame`, `frame_count`,
máximo 4096), con identidad y generación de parada. Los consumidores asignan sus handles de
transporte; el núcleo conserva identidades lógicas. Las fuentes de proyecto tienen vistas por
source_id y revisión, se analizan como módulos y conservan su texto inicial. El arranque de proyecto
propaga semilla, entradas, observación, anfitrión, modo, cinta y límites efectivos; el manifiesto
solo puede reducir límites del pedido. La identidad de la cinta usa una representación JSON
canónica de todos los archivos del proyecto, no un programa concatenado para compilar.

Punta viva y cursor de inspección son posiciones distintas. `history_events` reconstruye ventanas
hacia adelante o atrás de hasta 4096 eventos; los controles históricos avanzan por ventanas con
cesión al consumidor entre lotes. No reenvían salida ni efectos al anfitrión, no reemplazan la
continuación y fallan exactamente fuera del horizonte. El control en la punta requiere otra orden
para continuar el programa vivo después de recorrer el pasado. La terminación siempre cancela
la punta aunque se inspeccione historia.

Cada evento devuelto por `history_events` lleva `task_id` de la cinta completa, también los eventos
ordinarios de sentencia y salida. La identidad no se infiere de la tarea seleccionada al consultar:
un evento conserva quién lo emitió aunque otra tarea sea la punta al leer la ventana. El horizonte
define el único rango consultable; la API rechaza ventanas mayores de 4096 sin leer y recortar una
colección completa.

Las consultas `query_frame`, `query_variables` y `query_page` admiten `task_id`; la VM ofrece una copia de inspección
del contexto seleccionado sin cambiar la agenda original. `task` no es alias y se rechaza, igual que un `task_id` con
tipo distinto de entero sin signo. `query_page` admite offset directo o cursor exclusivo, y liga sus cursores también a
tarea y generación de parada. Solo decodifica los valores de la ventana: metadatos léxicos pueden recorrerse para contar
o resolver sombreado. `object_fields` reconoce
objetos, arreglos, vectores y diccionarios; indexed distingue sus índices de campos con nombre.
Los registros de lectura y las imágenes temporales no se confunden con el estado vivo.

`debug_state` admite `event` y `task_id` juntos para leer la máquina de esa tarea en un evento retenido.
Exige ambos datos para una lectura histórica, rechaza identidades y posiciones ajenas, y devuelve
`source: null` porque la fuente viva corresponde a la parada, no a ese evento pasado. La inspección
restaura una copia temporal y no cambia cursor, agenda ni continuación. `start_frame` y `frame_count`
acotan los marcos; las páginas de variables de `query_page` siguen ligadas a ejecución, revisión,
evento, tarea, consulta, destino y tamaño. La API no expone contenido de colas de canales; los eventos
solo identifican operaciones, canal y tarea.

Verificación dirigida adicional: `cargo test --locked -p pseudolearn_api --test debug_control`,
`--test history_events`, `--test state_pages`, `--test inspection_expression` y `--test lsp_operations`
en invocaciones separadas. Estas órdenes son los targets disponibles; su aprobación depende de la
evidencia de cada campaña y no se deduce de haberlas documentado.

## Separación del anfitrión

La API produce efectos pendientes por omisión y no distribuye el doble de memoria. `test-host`
activa ese doble solo para conformidad y pruebas. Sus pruebas propias lo habilitan mediante una
dependencia de desarrollo sobre el mismo crate, declarada en la matriz. La configuración de proyecto
rechaza requests.permissions y grants.permissions como campos desconocidos; límites voluntarios se
conservan. La identidad de cinta incluye semilla, fuentes, perfil y límites, sin permisos.
El descriptor de red declara ssrf_policy none en nativo o browser en navegador; no concede autoridad.

Cancelar una espera de Leer limpia la solicitud pendiente y devuelve cancelled en el siguiente
avance, igual que una espera de efecto. No exige ni acepta una entrada inventada para desbloquear
la cancelación; una respuesta tardía se rechaza y no incrementa entradas consumidas.

Antes de entregar efectos al host, la API comprueba derechos, atenuación y límites sobre una copia
pequeña de autoridad, sin copiar la cinta. Un rechazo se resuelve internamente y nunca provoca E/S.
Las creaciones de capacidades se preparan individualmente para asignar tokens definitivos; las
operaciones independientes ya preparadas se pueden atender en paralelo. La respuesta de una
operación independiente que llegue mientras se está preparando una capacidad se conserva hasta
cerrar esa preparación. La entrega queda serializada y grabada por el motor, sin repetir solicitudes.
Los lotes públicos conservan receptor, límites efectivos y token de resultado; no son solicitudes
incompletas reconstruidas por el consumidor.

## Ampliación numérica y de colecciones

La vista pública añade collection_operation para vectorSort, vectorReverse, vectorIndexOf, vectorContains y
dictionaryKeys. Los consumidores leen esta identidad del análisis semántico y no la deducen del texto.

## Contratos adicionales de verificación

Las pruebas de ordenación contrastan estabilidad y multiconjunto con una semilla fija sobre entradas vacías, unitarias y
con claves repetidas. La prueba de 100 000 elementos verifica cada posición, además de los extremos; las pruebas de
error conservan el tramo de la llamada de usuario.

## Código de salida

La respuesta de `advance` (y la instantánea de punta) añade el campo `exit_code` (entero 0–255, 0 por omisión). Es un
campo aditivo: los consumidores que no lo conocen lo ignoran. `error_ranges` lista los tramos `[inicio, fin)` de bytes
de `output` que escribió `Consola.EscribirError`; `output` conserva
ambos flujos en orden, así que un consumidor que no lo conoce muestra todo sin pérdida.

## Vista del programa sin mutabilidad

Las declaraciones locales con valor inicial exponen `initialized` verdadero; el atributo `mutable` desapareció con la
palabra `Mutable`, porque toda variable de `Definir` se puede reasignar.

## Fallo interno tras un análisis limpio

Si el análisis no informa errores pero la bajada a RI o su verificación fallan, la compilación devuelve el diagnóstico
`internalFault` (`DIAG.ENGINE.INTERNAL-FAULT`) en lugar de una lista vacía. Antes el resultado era `analysisFailed` sin
ningún diagnóstico, que fue lo que ocultó el defecto del paso de registros por valor y por referencia.
