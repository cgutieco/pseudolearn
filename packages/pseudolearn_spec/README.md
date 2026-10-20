# pseudolearn_spec

## 1. Qué es y qué no es

Sistema de Especificaciones Ejecutables: corpus `see/1`, validación, anclaje, impacto y conformidad
por procesos. Sirve a quienes redactan contratos y a consumidores de la exportación JSON.
Responsabilidades: identidad del corpus, integridad de reglas y casos, evidencia por sujeto.
Fuera de alcance de producto: motor Rust y API integrada del motor. El paquete sí incluye conformidad
generativa con oráculos independientes; no implementa la API de observación de memoria del sujeto.
Fuera de alcance técnico: imports del núcleo Dart, red durante conformidad y shell para el protocolo de sujetos. La prueba de permisos Unix usa un shell aislado únicamente para fijar `umask 077` antes de lanzar el compilador.
Casos de uso: crear un borrador, validar, bloquear versiones, comparar revisiones, contrastar un sujeto.

## 2. Guía operativa y ciclo de vida

Rust exacto según `rust-toolchain.toml`, rustfmt, Clippy y cargo-deny 0.20.2. macOS, Linux y Windows.
Dart y la biblioteca nativa de la app se requieren únicamente para verificar el sujeto activo `app`.
`reference` conserva un manifiesto retirado en `subjects/reference/` y resultados históricos; no tiene lanzador.
Preparación: `cargo fetch`. Para el sujeto app, `flutter pub get` y el build de su biblioteca nativa desde `apps/pseudolearn_app`.
Desarrollo: `cargo run -p see_cli --bin see -- validate`.
Compilación: `cargo build --release`; binario `target/release/see`.
Todas las órdenes admiten `--root <directorio>` para seleccionar otro miembro de corpus.
Órdenes: `budget` (E-10 reproducible), `new <ID> --domain <dominio>`, `validate`, `graph [--focus ID] [--dot]`,
`lock [--check | --refresh ID,ID]`, `diff <rev>`, `impact <ID>`, `conform --subject <engine|aot|service|cli|app> [--only ID]`,
`matrix [--subject reference]`, `feature <nombre>`, `export [--check]`. Solicitar conformidad de reference produce `SEE-SUBJECT-RETIRED`; su matriz solo presenta evidencia histórica como no aplicable.
`matrix` imprime un objeto con `conformance` (regla × sujeto), `ir_coverage` (tabla regla → instrucciones
de los bloques `cobertura`) y `states` (especificaciones por dominio y estado).
`diff` lee la revisión con Git, sin cambiar el checkout. `lock` conserva versiones históricas y actualiza el estado de
los anclajes activos. La promoción de estado, el revisor y los bloques de clasificación no alteran el hash normativo;
una modificación normativa con versión conservada solo se reancla cuando está autorizada: se retira la clave exacta
`ID@versión` de `history` y `see lock` la regenera. Código 0: éxito; 1: error o regresión exigible.
Conformidad conserva divergencias de reglas exentas sin ocultar los resultados crudos.
La comparación admite `tokens_include` para exigir identidades y tramos de tokens concretos sin fijar
la secuencia completa ni excluir la trivia que la API devuelve. El esquema valida la forma de cada
identidad y tramo antes de abrir un sujeto.
E-10 se reproduce con `cargo run -p see_cli --bin see -- budget`; la evidencia está en results/e10.json. E-14 registra el estudio humano diferido en results/e14.json. La correspondencia completa usa specifications/cases/migration.json y el índice educativo archivado en `subjects/reference/language-spec.md`.
Verificación: `cargo xtask verify`; incluye el corpus, anclaje y exportación actualizados.
La evidencia de E-15 vive en `results/e15.json`: ventana bruta de autoría automatizada por regla,
resultados y límites de interpretación. No mide autoría humana ni declara descubrimiento ciego.
No se despliega ni publica a un registro. La rama del monorepo contiene corpus y artefactos revisables.

## 3. Arquitectura y modelo del sistema

Workspace por capas, con listas cerradas en `architecture.yaml`. Ningún crate importa un miembro
ajeno; el tooling ejecuta los verificadores compartidos por proceso.

| Carpeta | Responsabilidad | Imports permitidos | Prohibido |
|---|---|---|---|
| see_model | Entidades de contratos | serde, serde_json | capas superiores, sujetos |
| see_format | Lectura de Markdown y YAML | model, serde-saphyr, serde_json | validación, procesos |
| see_oracles | Oráculos independientes enteros, racionales y de celdas | biblioteca estándar, num-bigint, num-rational, num-integer, num-traits | sujetos |
| see_graph | Dependencias e impacto | model, semver | procesos, CLI |
| see_change | Hash canónico y clasificación | model, serde_json, sha2 | sujetos, CLI |
| see_validation | Integridad del corpus: esquema, referencias, ciclo de vida, recursos, alfabeto de traza, convenciones de CLI, aperturas, mensajes, cobertura de RI y mediciones | model, graph, change, semver, serde_json | procesos |
| see_translation | Reimpresión léxica | model | sujeto, parser |
| see_generators | Programas bien tipados por semilla e índice | model, translation | sujetos, oráculos |
| see_conformance | Protocolo, peticiones por operación y comparación | model, translation, serde_json | internos de sujetos |
| see_export | Exportación de contratos | model, change, serde_json | sujetos |
| see_report | Matriz, cobertura de RI, estados y características | model, serde_json | ejecución de sujetos |
| see_cli | Orquestación CLI | capas del producto, serde_json, serde-saphyr | otros miembros |
| xtask | Puertas locales | biblioteca estándar | lógica del producto |
| specifications | Contratos y recursos de casos | datos | implementación |
| schemas | Esquemas versionados | datos | implementación |
| fixtures | Violaciones deliberadas | datos | recorrido ordinario |
| results | Evidencia de conformidad | datos generados | oráculos capturados sin revisión |

Flujo: archivos → modelo → validación/grafo/hash → adaptador → comparación → matriz/exportación.
Ejecución síncrona y determinista. Un proceso por sesión negocia capacidades y procesa JSON por línea.
Cada petición y respuesta admite hasta un MiB; las sesiones de conformidad usan tiempos límite explícitos por operación.
La escritura se ejecuta en un hilo con confirmación y la lectura usa una cola acotada. El cierre exige
salida satisfactoria y conserva stderr. Un sujeto bloqueado es error operativo, nunca cumplimiento.

## 4. Decisiones de diseño y fundamentos técnicos

Las peticiones de ejecución del corpus fijan explícitamente 1 000 marcos cuando el caso no declara profundidad, para comparar los sujetos bajo el mismo límite. Un límite declarado prevalece. Los valores por omisión de cada producto se verifican en sus pruebas de anfitrión; no se infieren de esta configuración experimental.

Problema: una regla estructural no produce un caso de ejecución. Elección: los vínculos con verificación `estructural` registran una observación del validador con hash del contrato, después de ejecutar `see validate`; se rechaza aplicarla a una regla que no declara verificación estructural. El esquema de límites y la cobertura de RI usan esta evidencia. Una revisión humana no se convierte en evidencia estructural automática.

Problema: las propiedades nativas necesitan un oráculo independiente y artefactos de proceso. Elección: `native_equivalence`, `native_diagnostics` y `native_roots` contrastan engine con aot sobre casos del corpus y grafos de memoria sembrados, con GC forzado para raíces; conserva códigos, argumentos y tramos de errores. Los ejecutores nativos de enlace, limpieza, permisos, códigos de salida y entorno compilan casos RT del corpus, borran la fuente y verifica dependencias, limpieza, permisos y ejecución desde otro directorio con entorno vacío. Se descarta declarar conformidad a partir del nombre de un test o de una exención del ejecutor.

- El corpus y sus recursos son autosustentables. La investigación transitoria de la raíz no es una dependencia; una puerta local comprueba referencias externas y tiene casos negativos.
- La migración cubre la edición 2026, español e inglés y rigores estricto/flexible. Las palabras reservadas y restricciones de identificadores son las vigentes. NFC se aplica a nombres y reconocimiento léxico; literales, comentarios y posiciones originales se conservan.
- El índice documental del núcleo conserva la proyección educativa y una tabla completa de secciones hacia contratos existentes; la comprobación rechaza huecos, duplicados y destinos inexistentes.
- Los recursos de vocabulario, funciones y diagnósticos se extraen del corpus y se verifican contra la exportación. Ningún consumidor mantiene una copia manual.
- Los casos admiten semilla explícita; la ausencia conserva 42. La comparación preserva resultados desfavorables y exenciones específicas de reglas con resolución declarada.
- E-10 mide colisiones sobre programas locales con procedencia explícita. El estudio humano de E-14 requiere participantes y construcciones de la evolución del lenguaje; no se atribuyen resultados humanos a comprobaciones técnicas.

- Problema: el corpus del motor necesita observar trazas, RI, CLI, casos de app y mediciones sin crear otro formato.
  Elección: `see/1` crece de forma compatible con los bloques `medicion` (prefijo M), `instruccion` (O) y
  `cobertura` (V), y con las operaciones de caso `trace`, `ir`, `cli`, `service` y `app`. Los casos `app`
  conservan `scenario` e `input`, se comparan bajo `espera.aplicacion` y no se ejecutan con el sujeto
  `engine`. Los casos que consultan la vista pública piden `program_view`; las consultas paginadas llevan
  `paginacion` y requieren `state_pages`; `target` opcional identifica el objeto consultado, con entero no negativo. La validación rechaza escenarios, entradas, cursores y operaciones
  mal formados. Las tablas que deciden la validez
  (alfabeto `traceEvents`, `cliConventions` con códigos de salida y aperturas, catálogo `cliMessages`,
  `diagnostics`, `vocabulary`) se leen de bloques `definicion`; ningún alfabeto vive en el código.
  `instruccion` lleva `nombre` además de `firma` porque las coberturas citan instrucciones por nombre
  estable y no por elemento. Se descarta un esquema `see/2`: ningún corpus anterior cambia de significado.
- Problema: un sujeto sin observación no debe aparentar cumplir ni ocultar casos. Elección: cada
  operación declara sus capacidades (`trace` exige `execute` y `observe`, `ir` exige `ir`, `cli` exige
  `cli`). Sin `observe` un caso `trace` es `pendiente`; sin otra capacidad es `no aplicable`; un sujeto que
  emite eventos sin haberlos pedido es error operativo. La matriz antepone incumple, pendiente y no
  aplicable a cumple. Las reglas verificadas solo por mediciones se informan no aplicables con la
  procedencia de cada medición: `see conform` no mide rendimiento. Se descarta tratar `pendiente` como
  `no aplicable`, porque ocultaría trabajo exigible al motor.
- Problema: los casos de app declaran colecciones y cursores cuyo orden o codificación no son parte de su
  contrato. Elección: `candidates_include` compara pertenencia sin imponer orden y `next_cursor: "opaque"`
  exige un valor no vacío sin fijar su representación. Se descarta comparar el marcador literalmente,
  porque exigiría que cada transporte compartiera la misma codificación interna.
- Problema: el autocompletado agresivo (plantillas con paradas, asistencia al teclear, tipo esperado) necesita casos de
  servicio y de app que `see/1` no nombraba. Elección: las suboperaciones de servicio `completion_stops`,
  `completion_accept` y `on_type` y los escenarios de app `edit_assistance`, `accept_candidate` y `template_navigation`
  se añaden de forma compatible, sin esquema nuevo. Los contratos `TOOL.SERVICE.COMPLETION`, `TOOL.LSP.CAPABILITIES` y
  `APP.EDITOR.COMPLETION` crecen dentro de `0.1.0` con reanclaje autorizado de su hash; lo que no tenía dueño nace como
  `TOOL.SERVICE.ON-TYPE@0.1.0`. Se descarta abrir `0.2.0`: las versiones están congeladas por decisión de la persona.
- Problema: la prioridad del cierre se confundía con intención inequívoca y no cubría la continuación de asignación.
  Elección: `TOOL.SERVICE.COMPLETION#R13` exige intención escrita, elimina cierres inline en líneas vacías y contempla
  `nombre <- ` únicamente para un destino simple declarado y asignable. `R8` reutiliza cierres existentes sin tomar los
  de otros bloques; `APP.EDITOR.COMPLETION#R6` verifica la aceptación por el puente. Es una corrección observable de la
  asistencia, sin modificación de la gramática ni de la asignación. Por instrucción de la persona se mantienen las
  versiones oficiales `0.1.0`, sin campo `cambio`, y se reanclan solo ambos contratos mediante `lock --refresh`.
  La evidencia `results/inline-completion-e09.json` registra el arnés general de completado: 172 programas,
  2730 consultas, 51.228 % de ahorro de pulsaciones y p95 de consulta de 1.997 ms en diez mil líneas; cumple los
  umbrales vigentes. No mide velocidad humana ni aísla el ahorro de la nueva continuación de asignación.
- Problema: la asistencia anclada duplicaba la banda táctil y las etiquetas no mostraban continuaciones como `area <-`.
  Elección: `APP.EDITOR.COMPLETION#R5` declara una sola superficie según disponibilidad, vista previa de la primera línea
  insertable y alineación tipográfica del fantasma, conservando `0.1.0` sin campo `cambio`. Los casos de presentación usan
  el escenario existente `edit_assistance` con `query: presentation`: consultan candidatos reales y la política pura del
  estado. La geometría se verifica con widgets y cajas de texto reales; el adaptador sin interfaz no inventa medidas.
- Problema: la cobertura de la RI debe comprobarse sin interpretar la prosa de las reglas. Elección:
  cuando el corpus contiene instrucciones, cada regla de `LANG` o `LIB` de clase `semantica`, `ejecucion` o
  `ampliacion` tiene exactamente una `cobertura` con instrucciones existentes o un motivo `sin_ri`; las
  trampas citadas existen en el catálogo de diagnósticos. Se descarta inferir instrucciones del texto.
- Problema: deducir el vocabulario por la palabra de apertura exige que ninguna apertura sea ambigua.
  Elección: `SEE-PROFILE-OPENERS` pliega caja, tildes, diéresis y `ñ` y compara cada lexema o alias de
  apertura con todos los lexemas y alias del otro perfil.
- Problema: la prosa de la CLI cita mensajes ya presentados sin traducirlos dos veces. Elección: los
  catálogos admiten el tipo de argumento `texto`, prosa ya presentada en el idioma de interfaz, además de
  lexema, token, tipo, término y número. Se descarta reutilizar `lexema`, que significa texto del usuario. El pliegue es deliberadamente más agresivo que
  la normalización de cada perfil: solo puede producir rechazos de más, nunca aceptar una ambigüedad.
- Problema: prosa legible y datos verificables. Elección: Markdown con YAML y bloques tipados;
  serde-saphyr conserva la cadena segura usada en el monorepo. Se descarta DSL propio por coste.
- Problema: versión mutable por edición silenciosa. Elección: SHA-256 del JSON canónico ordenado del
  encabezado contractual y bloques, excluyendo títulos, resumen y prosa; historial en lock.
  Se descarta hashear bytes Markdown porque espacio y presentación no cambian obligaciones.
- Problema: estados y elementos persistentes. Elección: lock retiene identidades/versiones,
  valida transiciones y lápidas. Se descarta borrar historia al regenerar.
- Problema: oráculo circular. Elección: casos derivados de reglas, sujeto por JSONL, comparación de
  multiconjuntos completos y tramos declarados. El campo `arbol` permite contrastar recuperación.
  Se descarta deduplicar diagnósticos o completar árboles nulos, porque ocultaría defectos.
- Problema: reimprimir sin cambiar identidades. Elección: recursos bilingües normativos independientes
  del adaptador, incluidos alias y nombres de funciones; reemplaza tokens fuera de cadenas/comentarios, conserva trivia y detecta colisiones.
  Casos pueden dar programas explícitos por perfil. Se descarta pedir traducción al sujeto.
- Problema: divergencias conocidas de un sujeto congelado. Elección: vínculos `exento` con hallazgo;
  resultados conservan `incumple` y la matriz muestra ambas cosas. Se descarta corregir Dart.
- Problema: verificación humana y N3 no se pueden fingir como ejecución. Elección: justificación
  obligatoria para revisión humana, propiedades sin ejecutor marcadas no aplicables. Se descarta
  declarar cumplimiento por ausencia de casos. El arranque SEE queda en borrador tras revisión
  estructural manual; los contratos restantes entran en experimental bajo la autorización de R1.
- Problema: clasificar significado requiere juicio. Elección: diff propone clases y exige registro
  de clasificación e impacto; cambios de texto quedan para revisión. No infiere aprobación humana.

### Hallazgos del sujeto reference

Identidades permanentes de evidencia, independientes de la investigación transitoria. Los esperados son normativos; las exenciones solo afectan al sujeto congelado y se resuelven en la fase indicada: R4 para el análisis y R5 para la observación de la ejecución. La evidencia del primer contraste de R3 está en results/r3-first-reference.json y su clasificación en results/r3-findings.json. La matriz mide los casos declarados, no una demostración universal del contrato.

| Hallazgo | Diferencia observable | Resolución |
|---|---|---|
| H-05 | Devuelve árbol nulo ante texto vacío aunque debe conservar estructura recuperable. | R4 |
| H-06 | El literal negativo fuera de rango provoca expectedExpression duplicado después del error léxico. La recuperación emite expectedExpression duplicado para una sentencia malformada. | R4 |
| H-37 | No emite controlVariableModified sobre la modificación directa del control de un bucle. | R4 |
| REF-FLEXIBLE-INITIALIZATION | No emite la advertencia estática de lectura sin inicializar en flexible, aunque la política la declara. | R4 |
| REF-INVALID-SYMBOL-CASCADE | El chequeo agrega inicialización o aridad sobre símbolos con resolución inválida; se conserva el error original sin añadir consecuencias del símbolo sintético. El parámetro duplicado reduce artificialmente la aridad y provoca argumentCountMismatch en una llamada con dos argumentos para dos parámetros declarados. Informa inicialización sobre un identificador cuya resolución ya falló por ausencia de declaración. | R4 |
| REF-OBJECT-CONTEXT | Acepta Este y Super fuera de métodos sin los diagnósticos sintácticos requeridos. | R4 |
| REF-SOURCE-BOM | El lexer reconoce el BOM inicial como carácter inválido en vez de excluirlo de los tokens. | R4 |
| REF-SOURCE-NFC | No reconoce como el mismo nombre la grafía compuesta y la descompuesta por ausencia de NFC. | R4 |
| REF-STATEMENT-CASCADE | Tras rechazar un inicializador en declaración agrega missingStatementTerminator sobre la misma sentencia. | R4 |
| REF-STATIC-MEMBER-CHECK | No informa acceso privado durante análisis aunque el receptor tiene tipo de clase declarado. No informa el miembro inexistente durante análisis sobre un receptor de clase conocido. | R4 |
| REF-STRICT-INFERENCE | Emite inferredVariableType en estricto después del error de declaración; la inferencia informativa pertenece al modo flexible. | R4 |
| REF-STRUCTURAL-RECOVERY | Agrega unexpectedTokenInExpression después de classInsideAlgorithm en el mismo bloque inválido. Agrega unexpectedTokenInExpression tras methodOutsideClass en el mismo bloque inválido. La recuperación agrega unexpectedStatement al cierre de una construcción estructural ya diagnosticada. Agrega un diagnóstico del cierre tras rechazar la construcción ajena a la edición. | R4 |
| REF-UNCLOSED-BLOCK-CASCADE | Al llegar a EOF informa cada bloque exterior sin cerrar además del bloque más interno. | R4 |
| REF-EMPTY-LOOP-CANCELLATION | No atiende cancelación durante la evaluación de condiciones de bucles vacíos; termina por el presupuesto de micro pasos del adaptador. | R5 |
| REF-NEGATIVE-ZERO | Presenta el real negativo cero como 0.0 y pierde su signo. | R5 |
| REF-OUTPUT-FRAGMENTS | Emite un evento de salida por fragmento, uno por valor y otro por el salto de línea, en vez de uno por sentencia Escribir con el texto completo. | R5 |
| REF-INPUT-REQUEST-EVENT | No emite la petición de entrada como evento: solo suspende y luego informa el valor aceptado. | R5 |
| REF-SWITCH-NO-BRANCH | Informa rama negativa cuando Segun no ejecuta ninguna rama, en vez de ninguna. | R5 |
| REF-RETURN-EXIT | La sentencia Retornar no produce statement_exited antes del evento return de su llamada. | R5 |
| REF-UNICODE-CHARACTER | Clasifica el literal suplementario como cadena por su longitud UTF-16; un escalar debe ser carácter. El carácter suplementario se tipa como cadena y se rechaza al consultar su código Unicode. CodigoDe rechaza el literal suplementario que debe ser un carácter, impidiendo la ejecución del caso Unicode. | R4 |

Problema: el límite portable de análisis debe llegar a los consumidores como dato validado.
Elección: `analysisLimits` contiene un único campo `nesting`, entero positivo representable en u32.
La exportación conserva el recurso y los generadores lo consumen. Se rechaza fijarlo otra vez en el parser
y se rechazan campos desconocidos o valores cero, negativos, fraccionarios y fuera de rango.

Cada sujeto lee su manifiesto de vínculos en una ruta fija (`bindings::manifest_path`) y se lanza con una descripción de
datos (`subject_adapters`): `reference` como archivo histórico sin lanzador, `engine` con el adaptador del motor, `cli` y `aot` con el binario `pseudo`
(`--see-adapter` y `--see-adapter aot`), y `app` con `dart run tool/see_app_adapter.dart` desde la raíz de
`apps/pseudolearn_app`. El adaptador app inicializa el transporte FRB generado y ejecuta análisis, ejecución,
consulta de estado, completado y llamadas de propiedades API por esa frontera. `aot` ejecuta los casos `execute` contra ejecutables reales; los casos de análisis,
representación intermedia y traza quedan `no aplicable` o `pendiente` por capacidad. Las propiedades se ejecutan con
`conform --subject <sujeto> --operation properties`; una propiedad cuya capacidad el sujeto no anuncia queda `pendiente` y no
cuenta como fallo, y un escenario que exige observación (cancelación, consulta de estado o eventos) no se envía a un
sujeto sin `observe`. `differential` compara además `engine` con `aot` (salida, terminación, códigos, argumentos y tramos de errores, sin
exenciones) cuando existe `results/aot.json` y guarda `results/differential-active.json`.

El hash normativo incluye identidad, edición, sujetos, dependencias, reemplazos y bloques de contrato; excluye estado,
versión, revisor, títulos, resumen y prosa. Una edición normativa autorizada que conserva versión sustituye solo la clave
`ID@versión` de `history`, y la orden `lock` genera los anclajes actualizados. Los cambios de estado y revisión
actualizan el anclaje activo sin reemplazar el hash histórico.

La conformidad de propiedades usa `property-conformance.json`: identidad versionada, algoritmo,
semilla y cantidad de muestras. Incluye las treinta propiedades del motor y la CLI, también las de
API y reimpresión heredadas; omitir una propiedad del sujeto es un error de vínculo. El archivo de datos conserva los vínculos regla–código y la validación
rechaza duplicados, referencias retiradas y cantidades cero. Registrar un vínculo no es evidencia de ejecución.
Las propiedades de las herramientas de edición (`service_format`, `service_translate`, `service_incremental`,
`service_node_identity`, `service_completion_templates`) se ejecutan contra el sujeto `service` sobre cada programa de
ejecución del corpus: verifican idempotencia del formateo, identidad de la doble traducción, equivalencia de la edición
incremental con el análisis desde cero, estabilidad de la identidad de nodos ante ediciones locales y validez sintáctica de
las plantillas. Un ejecutor que no encuentra contraejemplo en un sujeto sin la capacidad `service` queda `pendiente`, nunca `cumple`.
Las propiedades de reimpresión y recuperación sin pérdida también las ejecuta el sujeto `service`.


El manifiesto admite `estado: activo` o `estado: retirado`; omitirlo mantiene compatibilidad con
manifiestos activos. Un sujeto retirado conserva identidad, vínculos y resultados sin requerir rutas
instaladas, aparece como no aplicable en la matriz y no cuenta para la estabilidad del lenguaje.
Solicitar su ejecución produce `SEE-SUBJECT-RETIRED`. La revisión independiente es un requisito adicional:
la existencia de un vínculo no demuestra por sí sola conformidad ni estabilidad.

La actualización `see lock --refresh ID,ID` reancla exclusivamente los identificadores autorizados,
sin cambiar versiones durante el desarrollo. Los demás cambios siguen rechazándose y las identidades
terminales no admiten actualización. La comprobación ordinaria conserva la inmutabilidad del anclaje.
El diferencial activo compara engine y aot; no lee ni exige hashes actuales del archivo histórico.
La puerta local incluye rechazo de dependencias operativas retiradas y sus casos negativos.

Las cargas sin traza declarada se ejecutan completas con sus límites originales. Para evitar exceder el MiB del protocolo, el registro devuelve un resumen SHA-256 incremental y la cantidad de eventos, con identidades de revisión y nodo normalizadas biyectivamente por primera aparición; conserva tramos, alias, orden y datos de cada evento. Las variantes comparan ese resumen junto con salida, terminación, diagnósticos y consumo de entrada. No se sustituye la ejecución por un prefijo.

Las propiedades que comparan particiones de eventos solicitan registros sin snapshots completos; conservan eventos, tramos y cinta. Las propiedades de estado solicitan sus snapshots de forma explícita. Así una prueba de lotes no introduce copias cuadráticas ni supera el límite de transporte al transportar estados que no consulta.

La propiedad CLI de RI recorre las fuentes de casos de análisis, ejecución y traza. Obtiene la RI mediante un proceso real y exige aceptación y reimpresión idéntica mediante la API pública; los fallos y las salidas alteradas tienen negativos del ejecutor.

Las páginas consultadas comparan los campos declarados y reconocen `next_cursor: "opaque"` como una cadena no vacía; los estados completos siguen comparándose exactamente. Los negativos conservan el rechazo de elementos distintos, cursor vacío y estado completo con datos adicionales.

Las comparaciones entre ejecuciones renombran identidades opacas de forma biyectiva, conservando alias, revisiones y tramos. La propiedad de no interferencia de observación compara la ejecución sin consultas de estado auxiliares; estas conservan sus casos de conformidad propios.

Un caso de frontera que solicita transporte Wasm exige la capacidad `wasm`; el adaptador nativo de app no la anuncia. La retención local de respuestas no acredita crecimiento de memoria Wasm.

Los casos pueden restringir `sujetos` a un subconjunto explícito de los declarados; la ausencia conserva la aplicación a todos. Así se separan fronteras de app y CLI sin convertir capacidades ausentes en aprobaciones. La propiedad de revisión de `program_view` usa pares de documentos mínimos idénticos para detectar reutilización incorrecta de identidades entre revisiones y después del cierre.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés sin comentarios, doc/allow/expect, unsafe ni pánicos explícitos. Fallos esperables
son `Result`; las fronteras de CLI y adaptador los convierten en respuesta/código de salida.
Límites y nombres se leen exclusivamente de `architecture.yaml`. Tests espejo de módulos;
no se duplican casos del corpus en tests del núcleo.

## 6. Decisiones de producto que condicionan el código

La resolución inválida de un símbolo impide diagnosticar inicialización o aridad derivadas de ese símbolo: se conserva el error original y cualquier error independiente. Una firma con nombres duplicados no reduce aridad para generar una cascada sobre llamadas compatibles. Estas obligaciones viven en DIAG.CLASSES y se contrastan con reference sin alterar el sujeto.

`SEE.FORMAT`, `SEE.IDENTITY` y `SEE.LIFECYCLE` definen el arranque.
`SEE.VALIDATION`, `SEE.ORACLE.POLICY` y `SEE.CONFORMANCE.MATRIX` separan validez, origen y evidencia.
Los contratos del lenguaje conservan expectativas normativas aunque `reference` discrepe. El motor Rust
implementa los contratos del corpus mediante la API integrada; los incumplimientos AOT y las mediciones de plataforma conservan su estado y su evidencia separados. El corpus es la fuente de comportamiento; este README explica
arquitectura y operación.

## 7. Verificación, testing y aseguramiento de calidad

`cargo xtask verify`: formato, Clippy estricto, tests, seis verificadores Rust, versión de cadena,
cargo-deny (avisos, licencias, duplicados y fuentes), `see validate`, `see lock --check`, `see export --check` y conformidad engine.
Los casos negativos prueban duplicados, regla huérfana, captura sin revisor, hash/version,
ciclos y perfil faltante; otros prueban esquema, referencias, rango, estados y clasificación.
Cada rechazo del motor y sus fronteras tiene fixture propio comprobado por su identificador:
`trace-class` → SEE-TRACE-CLASS, `ir-expectation` → SEE-IR-EXPECTATION, `cli-exit` → SEE-CLI-EXIT,
`limit-kind` → SEE-LIMIT-KIND, `measurement-protocol` → SEE-MEASUREMENT-PROTOCOL, `ir-coverage` →
SEE-IR-COVERAGE, `ir-unknown` → SEE-IR-UNKNOWN, `profile-openers` → SEE-PROFILE-OPENERS,
`message-parity` → SEE-MESSAGE-PARITY y `message-arguments` → SEE-MESSAGE-ARGUMENTS.
Las pruebas de protocolo incluyen negociación inválida, JSON corrupto, EOF, timeout y capacidad ausente;
el adaptador de prueba cubre además observación anunciada, eventos no anunciados, RI y CLI.
Las pruebas de traducción incluyen cadenas, comentarios, ida/vuelta y colisión.
Las dependencias internas declaran versión y ruta; no hay excepciones de auditoría. Los fallos esperados del piloto se conservan como evidencia,
con exenciones justificadas; cualquier vínculo cumple que falle impide verificar.

## 8. Fuentes consultadas y genealogía conceptual

Los contratos SEE definen see/1, identidad, fases de ciclo de vida y protocolo. Cargo aporta workspaces,
metadatos y xtask; serde aporta contratos de datos; semver rangos; SHA-256 anclaje canónico.
Se toma el modelo de versión semántica para cambios declarados; se rechaza equiparar cambio
textual con clasificación semántica definitiva. No se consultan fuentes externas para decidir
comportamiento del lenguaje.

Las aclaraciones de ejecución fijan redondeo binario64 al más cercano con empates al par, formato mínimo
de ida y vuelta, raíces nocionales que incluyen temporales vivos y sondeos de cancelación en condiciones.
Los esperados matemáticos añadidos se justifican por intervalos racionales en
`results/r5-rounding-case-oracle.json`; ninguna captura del sujeto define esos resultados.

Los adaptadores engine y service se compilan en Release para ejecutar las propiedades completas sobre cargas grandes; el plazo máximo por solicitud de propiedades es de 300 segundos. Esto es una puerta funcional y no una medición de rendimiento. El corpus conserva los límites semánticos de cada solicitud.
