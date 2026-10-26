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
`Rejected` con los diagnósticos si hay errores y `Backend` si el generador falla. Fija en los metadatos del ejecutable
la semilla, los límites (profundidad, sentencias, celdas), el idioma, el nombre de la fuente, las plantillas de línea
de diagnóstico y de entrada agotada que la CLI entrega, y las palabras lógicas del perfil que
`pseudolearn_vm::boolean_words` expone desde la misma tabla generada que usa la VM. La API no enlaza ni toca el disco:
el enlace es una capacidad del adaptador.

Ejecución nativa observada: `conformance_build_request` fija las plantillas de línea en campos separados por tabulador y
`native_execute_response` convierte la ejecución de un ejecutable (código de salida, salida estándar y salida de error)
en un `ExecuteResponse`: `0` completado, `3` fallo con el código del último diagnóstico de error, `4` entrada agotada
(`awaiting_input`) o límite de sentencias (`limit_reached`) y cualquier otro código o señal fallo interno. Los diagnósticos
de la salida de error conservan código, severidad, tramo y argumentos tipados; las líneas ilegibles se ignoran y un fallo
sin diagnóstico legible es `internalFault`. `rejected_native_response` da la forma de un programa que el análisis rechaza.
`build_benchmark_object` entrega el objeto sin punto de entrada, sus metadatos codificados y el símbolo de la función
principal, que es lo que el trabajador de rendimiento enlaza con un lanzador propio para medir dentro del proceso.

La compilación a módulo conserva metadatos laterales de origen que la representación textual no
transporta. Los tests de integración compilan el corpus exportado y llaman directamente al bytecode y
la VM; `runtime_edges` cubre ventanas, índices con efectos, subtipos, despacho virtual, copia y ausencia
bajo las tres políticas de recolección. Esta vía de pruebas no implementa otro protocolo. `RunOptions` y los envoltorios existentes se mantienen junto con los recursos públicos de ejecución, entrada, cancelación y consultas.

Nivel 8. Dependencias internas permitidas: pseudolearn_source, pseudolearn_abi, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_ir, pseudolearn_lowering, pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_vm, pseudolearn_timeline, pseudolearn_codegen, pseudolearn_aot_rt. Externas: serde, serde_json.
Prohibido importar capas superiores, paquetes de UI o internos de otros miembros.

Estructuras y algoritmos: Recursos con identificador; operaciones totales que devuelven `Result`; captura de defectos internos como `DIAG.ENGINE.INTERNAL-FAULT`; codificaciones JSON canónica y binaria columnar; negociación de capacidades; renderizado en el idioma de interfaz pedido. `help_query` consulta una sesión de edición viva mediante su revisión y una posición de línea/columna en unidades `unicode_scalar` o `utf16`. La revisión viaja como cadena decimal; la posición se valida en un límite exacto y se convierte a la coordenada interna del servicio. La respuesta conserva idioma de interfaz y detalle solicitados, y expone la identidad o símbolo resuelto, la certeza y los rangos léxico y contextual en coordenadas de escalares Unicode de la fuente original. La ayuda editorial puede ser nula aunque exista una identidad resuelta. No se exponen índices del árbol.

Invariantes: Ningún pánico cruza la frontera.

Anfitrión simulado y resultados de efectos (`fake_host`, `execution_resource`): `FakeHostProvider` provee un árbol virtual en memoria con archivos, argumentos y reloj lógico para aislar pruebas normativas. La terminación `awaiting_effect` comunica la petición pendiente en JSON; la operación `effect_result` valida exclusión mutua estricta con `input` (rechazando entradas si se espera un efecto y viceversa) antes de suministrar el resultado y reanudar la máquina.

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

Cinta de efectos, modos de ejecución y errores de reproducción (`tape_wire`): `record` serializa la cinta `effect_tape` con esquema `pseudolearn.tape/v1`, conteniendo `ExecutionIdentity` y entradas encadenadas con SHA-256 (`TapeEntry`). La API distingue tres modos de ejecución en `ExecuteRequest` (`LiveRecord`, `ReplayFromTape`, `HistorySeek`). En `ReplayFromTape` y `HistorySeek`, el aislamiento del anfitrión es total (no se permite entrada viva ni consultas a disco o reloj). Ante discrepancia, fin prematuro, adulteración o no reproducibilidad de la cinta, la API emite el error de uso correspondiente (`replay_identity_mismatch`, `replay_divergence`, `replay_truncated_tape`, `replay_corrupted_tape`, `replay_non_reproducible`) de forma inmediata, sin reintentos ni recurrir al anfitrión vivo (`API.EXECUTE#R5`, `API.STATE.QUERY#R5`, `API.ERRORS#R3`).

La creación de un documento admite `previous_document` cuando representa una revisión sucesora. Valida la fuente y el recurso previo antes de crear el nuevo; solo después libera la revisión anterior y sus recursos dependientes. Un destino previo inválido conserva todos los documentos. El identificador nuevo cambia las identidades de nodos aunque el texto sea idéntico; las vistas retenidas del anterior no se pueden consultar. Los documentos ajenos permanecen vivos.

Las peticiones de análisis, RI, ejecución y construcción nativa admiten `source` opcional con `project_id` y `revision_id` como cadenas decimales u64 y `source_id` como u32 positivo. El ID cero permanece reservado al documento suelto. Diagnósticos, tokens y vistas devuelven esa identidad en cada tramo; una petición de documento suelto conserva las formas anteriores sin el campo. `AnalyzeRequest` de texto único sigue siendo la entrada pública: conserva su perfil, rigor, diagnóstico, tokens y tramos, sin requerir manifiesto, imports ni conversión a un proyecto.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: configurar el montón desde la API debe preservar el calendario de la VM. Elección: las ejecuciones del sujeto engine conservan el mínimo automático de 4096 celdas. Se descarta heredar la configuración específica de AOT.

Problema: la emisión debe medirse sin análisis ni lowering. Elección: `PreparedNativeBenchmark` prepara una RI inmutable antes del reloj; `emit_benchmark_object` emite el objeto y sus metadatos. La inspección explícita captura CLIF sin modificar las funciones emitidas; permanece fuera de la medición. El módulo `literals` es dueño de los datos de texto del objeto. Se descarta mezclar las cadenas CLIF con el intervalo de emisión.

Problema: los consumidores móviles y Wasm no compilan programas nativos. Elección: la API desactiva AOT por omisión y expone sus módulos y dependencias nativas solo con la feature `native`; la CLI y el trabajador AOT la activan explícitamente. Se descarta confiar en la eliminación de símbolos del enlazador, porque no elimina Cranelift del grafo de compilación.


Problema: el sujeto `aot` debe contrastarse con el corpus ejecutando el binario real, y el proceso solo ofrece texto.
Elección: el adaptador compila con plantillas máquina-legibles y esta capa reconstruye la respuesta de ejecución a partir
del código de salida y la salida de error. Descartado: ejecutar en proceso código generado (exige `unsafe` y no prueba el
enlace ni el protocolo del proceso) y ejecutar la VM como respaldo, que ocultaría defectos del sujeto.

Problema: medir ejecución no debe incluir compilación. Elección: `PreparedProgram` conserva un programa cargado inmutable; `prepare_program` compila y `execute_prepared` crea una ejecución nueva con semilla, límites y entradas explícitos. Se descarta medir el arranque del adaptador o la serialización. El trabajador valida cada salida fuera del intervalo.

Problema: una ejecución por lotes no debe copiar ni suspender la máquina al final de cada lote. Elección: `ExecutionResource` conserva una `Machine` viva, `LoadedProgram` comparte sus datos inmutables mediante `Arc`, y `CheckpointStore` recibe checkpoints diferenciales. Una consulta restaura desde el punto más cercano y reproduce en una máquina temporal. La API elimina sus snapshots completos paralelos y conserva los límites de retención mediante un checkpoint base. El adaptador y la CLI solo consumen esta frontera. Se descartan implementaciones de ejecución independientes en consumidores.

Problema: ofrece operaciones públicas totales sobre recursos del núcleo respetando los observables del corpus.
Elección: Recursos con identificador; operaciones totales que devuelven `Result`; captura de defectos internos como `DIAG.ENGINE.INTERNAL-FAULT`; codificaciones JSON canónica y binaria columnar; negociación de capacidades; renderizado en el idioma de interfaz pedido.
Alternativas descartadas y fundamento: El corpus API define recursos y codificaciones; se rechaza un objeto por evento en FFI y copiar todo el estado en cada paso.

Problema: la codificación binaria debe conservar la misma referencia de fuente que la respuesta JSON sin
añadir identidad de documento al modelo de eventos de la VM. Elección: el codec de la API pone `data` y
`source` en el registro JSON canónico de cada evento PLEV; el decodificador valida ambos y reconstruye la
respuesta completa. El codec JSON valida y conserva los objetos recibidos. Los eventos sintéticos llevan
`source: null`. Se descarta resolver la fuente después de decodificar, porque la revisión y el nodo no se
pueden recuperar solo desde el tramo.

La versión PLEV 2 añade identidad compuesta al registro `source`; PLEV 1 sigue decodificándose y solo puede escribirse si ningún evento contiene esa identidad. `negotiate` elige la versión de escritura entre las versiones anunciadas y expone por separado las versiones de lectura. Los enteros u64 de la identidad usan cadenas decimales canónicas; `source_id` sigue siendo u32. El binario nunca asigna significado nuevo a bytes PLEV 1.

Problema: los emisores, diagramas y comprobaciones estructurales consumían árboles internos del núcleo Dart. Elección: la API publicará una vista inmutable por revisión con unidades, nodos, relaciones, tramos y eventos enlazados por identificador opaco. La vista no revela índices del CST, HIR ni bytecode y el consumidor no vuelve a analizar el texto.

Problema: posiciones públicas y unidades recuperadas deben describir el texto, no desplazamientos internos.
Elección: la API convierte cada tramo UTF-8 a pares línea/columna y expone el esquema de unidades
recuperadas en orden de fuente. El análisis pasa perfil y rigor al front-end; solo solicita HIR sin
errores léxicos o sintácticos. El idioma de presentación se resuelve al renderizar un diagnóstico
mediante su código y argumentos, sin modificar códigos, tramos ni salida del programa.
Se rechaza que la CLI tenga que reconstruir posiciones o traducir un mensaje ya presentado.

La respuesta de análisis incluye todos los tokens léxicos en orden de fuente, incluso trivia,
caracteres inválidos y fin de archivo. Cada token conserva su identidad pública y tramo en
línea/columna; el consumidor obtiene resaltado sin volver a analizar el texto y puede mantenerlo
cuando el árbol incluye errores recuperables.

Los nombres del alfabeto latino español se aceptan en ambos rigores y perfiles. La comparación usa NFC
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
un error de uso que no altera la ejecución. Las páginas de arreglo incluyen las dimensiones, las consultas de marco etiquetan los valores escalares con su tipo (`entero`, `real`, `booleano`, `caracter`, `texto`) sin alterar el estado capturado por la conformidad, y `create_analysis` acepta un `locale` que renderiza los mensajes de diagnóstico y de ejecución con independencia del perfil sintáctico.

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
añade tipo, inferencia, carácter intrínseco, firma, la descripción del token y el resto de la ficha
(propósito, partes, restricciones, errores comunes y referencias a ejemplos). `language` queda separado del
perfil de sintaxis: selecciona la ficha editorial en `es` o `en`, mientras que lexemas, tipos y firmas
describen el perfil de la sesión. La ficha se elige por la identidad léxica del token y, si varias la
comparten, por el contexto resuelto (operador unario o binario, construcción que lo contiene); la respuesta
no incluye programas ni esperados, solo la referencia a los casos, y la consulta nunca los ejecuta. Un
símbolo del usuario, una posición sin token o una identidad sin ficha devuelven `card: null`. Un recurso
liberado, de otra clase o una revisión obsoleta no produce contenido de ayuda.

Problema: el análisis y la ejecución de un proyecto necesitan operaciones públicas totales. Elección:
`analyze_project` y `execute_project` son operaciones de la sesión (sin recurso) que reciben el proyecto como
datos (`project_resource` los valida y convierte), construyen el catálogo, analizan cada módulo con el modo de
proyecto, enlazan un único HIR y, al ejecutar, un único RI que va a la VM por el mismo camino que un programa
suelto. Una petición mal formada es un fallo de uso; un proyecto bien formado pero inconsistente devuelve
`project_errors` y ninguna ejecución. Cada diagnóstico se convierte con la fuente que su tramo identifica, de
modo que lleva la identidad de su propio archivo. No se añaden recursos de proyecto a la sesión ni se concatenan
textos. `project_compile` es el paso común de análisis, enlace y bajada a un RI verificado: lo consumen `execute_project`
(VM) y `build_native_project_object` (feature `native`), de modo que ambos ejecutan el mismo módulo. Un rechazo del
proyecto (errores de proyecto, de manifiesto o diagnósticos) se devuelve como `NativeBuildFailure::ProjectRejected` con el
mismo JSON que `execute_project`, sin objeto. Los límites del manifiesto se aplican salvo que la petición nativa los fije.
`execute_project` marca su identidad de fuente con `source_id` 0, que significa «cualquier archivo del proyecto»: cada
diagnóstico de ejecución toma el `source_id` del tramo del fallo, de modo que un fallo dentro de un módulo importado
nombra su archivo (el cero sigue reservado al documento suelto en las peticiones de documento).

Los errores de paquetes en ciclo llevan además `chain`. Los diagnósticos de ciclo de importación relacionan tramos
de otros archivos: cada tramo relacionado se convierte con la fuente que su propia identidad señala (`project_diagnostics`),
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
que el anfitrión pasa después al análisis, de modo que lo verificado es lo compilado. El presupuesto de bytes del lock es
una constante candidata (`lock_wire`). Un hash verifica integridad, no autenticidad del origen.

Problema: el manifiesto de un paquete es una entrada declarativa cuya autoridad concede el anfitrión. Elección:
`resolve_manifest` (texto, ubicación y concesiones opcionales) devuelve la configuración con la procedencia de cada
campo o los errores con línea y columna, y `analyze_project`/`execute_project` aceptan `manifests` en lugar de
`packages` (exactamente uno de los dos; lo contrario es un fallo de uso) y un argumento `grants` con los techos de
`limits` (`depth`, `statements`, `cells`, `micro_steps`). Los errores de manifiesto se devuelven en
`manifest_errors` con su ubicación y bloquean el análisis; `execute_project` aplica a la ejecución solo los límites
efectivos, que nunca superan la solicitud ni la concesión, del paquete que contiene la entrada. El presupuesto de
bytes del manifiesto es una constante candidata del transporte (`manifest_wire`), pendiente de calibrar. Abrir,
analizar o ejecutar un proyecto no ejecuta scripts ni concede permisos por su contenido, y el idioma de interfaz no
interviene. La lectura de manifiestos desde disco y la fuente de las concesiones son de la CLI.

Perfil por archivo: cada archivo de una petición de proyecto admite `profile` (`es` o `en`; otro valor es un fallo de uso). La
resolución sigue el README de project y usa la apertura que detecta `detect_vocabulary_profile`. El argumento `profile` de la
petición es solo el respaldo de los archivos sin otra procedencia y el idioma de los mensajes; los lexemas de los argumentos
de un diagnóstico (fichas y tipos) usan el perfil del archivo que lo contiene (`convert_in_profile`). `profileMismatch` se
añade al archivo contradictorio y bloquea la ejecución. Al bajar a RI, el vocabulario del módulo es el de la entrada y se
registra la tabla `source_id → perfil` de todos los archivos; la ejecución y la compilación nativa formatean los lógicos
con el perfil del archivo que contiene cada operación. `native_build` rellena `site_boolean_words` solo si el módulo tiene
tabla de perfiles, por lo que el archivo suelto no cambia. El adaptador AOT de conformance aún no acepta proyectos; la construcción nativa de proyectos se prueba con `tests/native_project_build.rs` y desde la CLI.

La vista pública conserva nodos explícitos de construcción y patrón de variante, propagación y descarte. Expone identidades canónicas de alternativa y constructor de tipo, mutabilidad e inicialización del vínculo, y roles de carga útil, vínculo, tipo e inicializador. No expone los registros sintéticos ni sus ranuras de almacenamiento.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.
Las fuentes generadas se producen desde la exportación del corpus en OUT_DIR; nunca se copian manualmente.

## 6. Decisiones de producto que condicionan el código

Contratos: `API.*`, `DIAG.ENGINE.INTERNAL-FAULT`.
La ejecución y la observación conservan la misma semántica; idioma de interfaz y vocabulario son independientes.
Los identificadores del usuario, el texto original y la salida del programa se conservan.


El registro opcional `summarize_events` con `capture_states: false` calcula SHA-256 incremental de todos los eventos y su cantidad, sin devolver la lista. Normaliza únicamente las identidades opacas por primera aparición, conservando las relaciones de alias y todos los demás datos. Evita respuestas mayores al límite del transporte sin truncar la ejecución ni modificar sus límites. `sha2` queda confinado a esta frontera de serialización; los registros ordinarios conservan los eventos completos.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, texto vacío, Unicode, tamaño cero, profundidad extrema y bordes numéricos.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos;
formato, Clippy, auditoría de dependencias y pruebas diferenciales según los contratos de este crate.

## 8. Fuentes consultadas y genealogía conceptual

El corpus API define recursos y codificaciones; se rechaza un objeto por evento en FFI y copiar todo el estado en cada paso.


### Funciones como valores y ámbitos de ejecución

La prueba `function_execution` consume los programas normativos del corpus de funciones, sin mantener copias locales. Contrasta ambos perfiles y gemelos, recolección ordinaria y forzada, salida, terminación, diagnósticos y eventos. Con `native`, enlaza y ejecuta los objetos emitidos y los contrasta con la VM. Las bibliotecas del arnés se localizan en el directorio de dependencias del ejecutable de prueba.

## Colecciones, interfaces e iteración con limpieza

La vista pública expone nodos de interfaces, realizaciones, parámetros restringidos, Para Cada, Salir y Diferir, con papeles de hijos. interface_identity, realized_interfaces y constraint_interface usan identidades opacas de nodos de la revisión, sin representar la interfaz como valor. La consulta de estado presenta longitud y elementos de Vector, y entradas ordenadas con clave y valor de Diccionario; conserva identidades compartidas y hojas de registros. Los metadatos sintéticos de disposición son internos y no se interpretan como campos ordinarios de objetos.

La vista también proyecta enumerados (`enum_unit` con `enum_identity` y `enum_members`), registros (`record_unit` con `record_identity` y `record_fields` hacia sus nodos `record_field`) y literales de función (`function_literal` con `closure_identity` y `captured_bindings` hacia las declaraciones capturadas). Los datos salen de `program_view_values.rs` a partir del análisis semántico, y las relaciones usan únicamente identificadores de nodos de la misma vista, que ya codifican proyecto, revisión y fuente: una relación hacia otra procedencia no se emite. Son atributos aditivos de solo lectura; el dibujo de diagramas con ellos pertenece a una fase posterior.

Los tests de estas capacidades se ejecutaron en selecciones acotadas, incluida la comparación de gemelos con recolección forzada. La conformidad del corpus sigue pendiente de la revisión editorial independiente de los contratos nuevos, y la medición de tamaño excede el presupuesto de Wasm.
