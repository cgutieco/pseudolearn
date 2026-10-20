# pseudolearn_api

## 1. Qué es y qué no es

Ofrece operaciones públicas totales sobre recursos del núcleo. Implementación disponible en el workspace.

Fuera de alcance: otras responsabilidades del motor, UI, I/O libre y construcciones nuevas.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Conformidad integrada de `API.EXECUTE` | Recursos de ejecución, entrada y observación | B7.3 |
| Reglas `API.PROGRAM.VIEW#R3` y `API.STATE.QUERY#R4` en conformidad | La primera depende del sujeto app; en la segunda el caso C4 espera un cursor literal que ningún cursor ligado a su consulta puede producir | pendiente |

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
bajo las tres políticas de recolección. Esta vía de pruebas no anuncia una capacidad pública de ejecución
ni implementa otro protocolo. `RunOptions` y los envoltorios existentes se mantienen; `API.EXECUTE` y su
conformidad integrada pertenecen a B7.3.

Nivel 8. Dependencias internas permitidas: pseudolearn_source, pseudolearn_abi, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_ir, pseudolearn_lowering, pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_vm, pseudolearn_timeline, pseudolearn_codegen, pseudolearn_aot_rt. Externas: serde, serde_json.
Prohibido importar capas superiores, paquetes de UI o internos de otros miembros.

Estructuras y algoritmos: Recursos con identificador; operaciones totales que devuelven `Result`; captura de defectos internos como `DIAG.ENGINE.INTERNAL-FAULT`; codificaciones JSON canónica y binaria columnar; negociación de capacidades; renderizado en el idioma de interfaz pedido.

Invariantes: Ningún pánico cruza la frontera.

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

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

Problema: los emisores, diagramas y comprobaciones estructurales consumían árboles internos del núcleo Dart. Elección: la API publicará una vista inmutable por revisión con unidades, nodos, relaciones, tramos y eventos enlazados por identificador opaco. La vista no revela índices del CST, HIR ni bytecode y el consumidor no vuelve a analizar el texto.

Problema: posiciones públicas y unidades recuperadas deben describir el texto, no desplazamientos internos.
Elección: la API convierte cada tramo UTF-8 a pares línea/columna y expone el esquema de unidades
recuperadas en orden de fuente. El análisis pasa perfil y rigor al front-end; solo solicita HIR sin
errores léxicos o sintácticos. El idioma de presentación se resuelve al renderizar un diagnóstico
mediante su código y argumentos, sin modificar códigos, tramos ni salida del programa.
Se rechaza que la CLI tenga que reconstruir posiciones o traducir un mensaje ya presentado.

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

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.
Las fuentes generadas se producen desde la exportación del corpus en OUT_DIR; nunca se copian manualmente.

## 6. Decisiones de producto que condicionan el código

Contratos: `API.*`, `DIAG.ENGINE.INTERNAL-FAULT`.
La ejecución y la observación conservan la misma semántica; idioma de interfaz y vocabulario son independientes.
Los identificadores del usuario, el texto original y la salida del programa se conservan.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, texto vacío, Unicode, tamaño cero, profundidad extrema y bordes numéricos.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos;
formato, Clippy, auditoría de dependencias y pruebas diferenciales según los contratos de este crate.

## 8. Fuentes consultadas y genealogía conceptual

El corpus API define recursos y codificaciones; se rechaza un objeto por evento en FFI y copiar todo el estado en cada paso.
