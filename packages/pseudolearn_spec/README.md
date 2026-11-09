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
`reference` conserva un manifiesto retirado en `subjects/reference/`; no tiene lanzador ni captura local de evidencia.
Preparación: `cargo fetch`. Para el sujeto app, `flutter pub get` y el build de su biblioteca nativa desde `apps/pseudolearn_app`.
Desarrollo: `cargo run -p see_cli --bin see -- validate`.
Compilación: `cargo build --release`; binario `target/release/see`.
Todas las órdenes admiten `--root <directorio>` para seleccionar otro miembro de corpus.
Órdenes: `budget` (E-10 reproducible), `new <ID> --domain <dominio>`, `validate`, `graph [--focus ID] [--dot]`,
`lock [--check | --refresh ID,ID]`, `diff <rev>`, `impact <ID>`, `conform --subject <engine|aot|service|cli|app> [--only ID]`,
`matrix [--subject reference]`, `feature <nombre>`, `export [--check]`, `agent-sheet [--check]`. Solicitar conformidad de reference produce `SEE-SUBJECT-RETIRED`; su matriz lo presenta como no aplicable sin cargar resultados retirados.
`matrix` imprime un objeto con `conformance` (regla × sujeto), `ir_coverage` (tabla regla → instrucciones
de los bloques `cobertura`) y `states` (especificaciones por dominio y estado).
La edición vigente del lenguaje es 2027: se escoge el año siguiente al de la redacción para que el corpus no parezca
anticuado al publicarse, y `introducida_en` de los contratos de lenguaje y de biblioteca la declara. En `revisado_por`
figura un único valor en todo el corpus, el nombre completo y con tildes de la persona responsable, `César Antonio
Gutiérrez Contreras`; no se admiten identificadores de revisión automatizada ni variantes de escritura.

En los archivos de conformidad, `resuelve_en` de un vínculo `pendiente` es una clave autosustentable que nombra el
trabajo que lo cerrará (por ejemplo `eventos-de-tarea-para-app`). El validador solo exige que no figure en
`fases_cerradas`; la convención del corpus prohíbe usar identificadores de fase o rutas a documentos.

`new` crea una plantilla estable `1.0.0` sin `cambio`; deja `revisado_por` vacío para que no se atribuya una
revisión inexistente. La plantilla de lenguaje declara engine y aot como sujetos candidatos. El contrato queda
incompleto hasta que tenga reglas, casos, evidencia y una revisión independiente, por lo que `validate` puede
rechazarlo inmediatamente después de crearlo.

`diff` lee la revisión con Git, sin cambiar el checkout, y puede describir cambios aunque aún falte subir su versión;
`validate` aplica la puerta de anclajes. `lock` genera una caché local ignorada. La validación deriva el estado anterior
de la revisión Git base. Mientras el versionado está congelado, las identidades existentes conservan estado, identidad
y versión; ninguna transición de estado está permitida. Las ediciones oficiales conservan esa misma identidad, omiten
`cambio` y requieren reanclar la misma versión. Las identidades nuevas empiezan en estable `1.0.0` y sin `cambio`.
La publicación de una versión solo se inicia con autorización explícita. Al reabrir el versionado se aplican los
incrementos y clasificaciones de SEE.VERSIONING y SEE.CHANGE.CLASSIFICATION. Código 0: éxito; 1: error
o regresión exigible.
Conformidad conserva divergencias de reglas exentas sin ocultar los resultados crudos.
La comparación admite `tokens_include` para exigir identidades y tramos de tokens concretos sin fijar
la secuencia completa ni excluir la trivia que la API devuelve. El esquema valida la forma de cada
identidad y tramo antes de abrir un sujeto.
E-10 se reproduce con `cargo run -p see_cli --bin see -- budget`; sus resultados se guardan localmente. E-14 registra el estudio humano diferido. La correspondencia completa usa specifications/cases/migration.json y el índice educativo archivado en `subjects/reference/language-spec.md`.
Verificación: `cargo xtask verify`; incluye el corpus, anclaje y exportación actualizados.
La evidencia local de E-15 registra la ventana bruta de autoría automatizada por regla, sus resultados y
límites de interpretación. No mide autoría humana ni declara descubrimiento ciego.
No se despliega ni publica a un registro. La rama del monorepo contiene fuentes revisables; exportaciones y resultados
se generan bajo rutas locales ignoradas.

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

`TOOL.SERVICE.CATALOG` conserva `helpCatalog` como recurso normativo en el campo `valor` de una
definición. Sus fichas guardan identidad y papel, alcance, anclajes, una categoría pedagógica, una
plantilla de escritura y prosa editorial bilingüe dirigida a quien nunca ha programado; las formas y
firmas permanecen en vocabulario, gramática y biblioteca. La plantilla (`form`) es una lista de líneas
con nivel de sangría y segmentos que nombran una identidad léxica, un hueco o una marca de repetición:
el texto de cada palabra se toma del perfil del documento al presentarse, de modo que la ficha nunca
copia un lexema. Cada idioma explica cada palabra (`parts`, que siguen siendo la única fuente de la
descripción del hover) y cada hueco (`slots`, con etiqueta corta y explicación), y añade lo que
devuelve (`result`, opcional), reglas, errores comunes con caso opcional y ejemplos con nota. Se
descartó guardar la plantilla como texto con marcadores: obligaba a copiar lexemas por perfil y a
admitir en la prosa los signos que el validador prohíbe. `see_validation` valida el
esquema del recurso y sus referencias versionadas; `see_export` lo extrae sin convertirlo en una
dependencia de documentación transitoria.

El inventario 2027 deriva palabras reservadas de `vocabulary`, operadores de las producciones de
expresión y asignación, e incorporadas de `functions` y `capabilityLibrary`. Las 41 agrupaciones
pedagógicas se declaran como datos con sus producciones fuente; no se infieren de la EBNF. Las 143
identidades de palabras reservadas, 17 operadores y las identidades incorporadas se explican en el
contexto de una ficha mediante partes es/en. La matriz contiene 556 filas identidad/rol: 166 de
keyword, 26 de operador, 136 de incorporada, 19 de token no alfabético y 209 de rol. Los alias
conservan la identidad de su entrada fuente y no generan filas adicionales. Las fichas se
redactan en ambos idiomas desde sus reglas ancladas; antes de mantener el inventario se revisan
texto, identidades, disponibilidad, anclajes y la matriz completa. Cada elemento activo debe llegar
a una ficha específica o a una exclusión tipada; una ficha genérica no cubre elementos sin asociar.

El texto suelto de la edición 2027 tiene una sola entrada algorítmica y no requiere manifiesto. `LANG.PROGRAM.STRUCTURE` admite como declaraciones hermanas los tipos nominales, subprogramas y constantes de módulo; `LANG.MODULE.MODEL` conserva los diagnósticos de importación y exportación fuera de proyecto. El preludio fijo usa exclusivamente el catálogo exportado de `LIB.MODEL` y los tipos intrínsecos del lenguaje. Los contratos dueños determinan disponibilidad y colisiones; el preludio no concede capacidades ni lee el entorno. Los casos vigentes de estructura, edición, módulo, codificación, posiciones y capacidades cubren ambos perfiles, entrada vacía, colisiones, símbolos ausentes, BOM y efectos denegados.

Los ejemplos de una ficha no contienen programas ni resultados: referencian casos vigentes del corpus por
especificación, versión e identidad, con la misma secuencia en ambos idiomas y una nota por idioma que
explica qué ocurre. Cada ficha lleva al menos uno y declara su clase: `executable` (el caso ejecuta el
programa y termina sin fallo ni diagnósticos), `accepted` (se analiza sin diagnósticos) o `diagnostic`
(diagnóstico o fallo deliberado). El validador deriva la clase de la operación y del esperado del caso y
rechaza la discrepancia, así que una ficha no puede presentar como correcto lo que el caso declara
fallido. El caso referenciado declara todos los perfiles de la ficha y un programa para cada uno, porque
la ayuda muestra el programa del perfil del documento, con la salida esperada del caso cuando es
ejecutable. El primer ejemplo de cada ficha es un caso pedagógico propio: un programa corto, con nombres
claros y salida visible, escrito como lo escribiría un estudiante y anclado en la regla que explica la
ficha. Sus esperados se calculan a mano desde esa regla y los ejecutan los sujetos de conformidad; la
ayuda nunca los ejecuta. Se descartó mostrar los casos de prueba de reglas existentes, porque ilustran
bordes de la regla (`Escribir 1;`) y no enseñan a usar la construcción.

El generador de `IR.LOWERING` P3 excluye los programas que usan Propagar buscando su lexema sin distinguir
mayúsculas, igual que el analizador léxico: la forma canónica inglesa es `Propagate` y una comparación exacta
dejaba pasar esos programas, cuya traducción añade salidas anticipadas que la propiedad no modela.

Todo programa que la ayuda presenta, de ejemplo o de error común, está en la forma canónica del
formateador: dos espacios por nivel y sin tabuladores. Los casos antiguos enlazados como errores comunes
se reescribieron en esa forma sin cambiar sus esperados, que no dependen de posiciones. El motor lo
comprueba con el formateador real en `pseudolearn_service/tests/help_examples.rs`; un programa con error
sintáctico deliberado, que el formateador no acepta, solo debe respetar la sangría.

Cada caso declara los perfiles para los que se ejecuta y valida una sola semántica por perfil. Las referencias de `helpCatalog/1`
se validan dentro de la disponibilidad del perfil del caso.

Las peticiones de ejecución del corpus fijan explícitamente 1 000 marcos cuando el caso no declara profundidad, para comparar los sujetos bajo el mismo límite. Un límite declarado prevalece. La propiedad `limites` admite topes positivos de JSON y red y se reenvía al anfitrión simulado. Los valores por omisión de cada producto se verifican en sus pruebas de anfitrión; no se infieren de esta configuración experimental.

Problema: una regla estructural no produce un caso de ejecución. Elección: los vínculos con verificación `estructural` registran una observación del validador con hash del contrato, después de ejecutar `see validate`; se rechaza aplicarla a una regla que no declara verificación estructural. El esquema de límites y la cobertura de RI usan esta evidencia. Una revisión humana no se convierte en evidencia estructural automática.

Problema: las propiedades nativas necesitan un oráculo independiente y artefactos de proceso. Elección: `native_equivalence`, `native_diagnostics` y `native_roots` contrastan engine con aot sobre casos del corpus y grafos de memoria sembrados, con GC forzado para raíces; conserva códigos, argumentos y tramos de errores. Los ejecutores nativos de enlace, limpieza, permisos, códigos de salida y entorno compilan casos RT del corpus, borran la fuente y verifica dependencias, limpieza, permisos y ejecución desde otro directorio con entorno vacío. La sonda de limpieza con fallo de enlace vacía `PATH` y retira `HOME`, `XDG_CACHE_HOME` y `LOCALAPPDATA`, porque `pseudo compilar` ya no usa un enlazador del sistema sino el enlazador incluido de su caché de usuario: sin carpeta de caché el enlazador no se puede obtener y la compilación termina con código 3 sin tocar la salida. Se descarta declarar conformidad a partir del nombre de un test o de una exención del ejecutor.

- El corpus y sus recursos son autosustentables. La investigación transitoria de la raíz no es una dependencia; una puerta local comprueba referencias externas y tiene casos negativos.
- El corpus cubre una sola edición en español e inglés. Las palabras reservadas y restricciones de identificadores son las vigentes. NFC se aplica a nombres y reconocimiento léxico; literales, comentarios y posiciones originales se conservan.
- El índice documental del núcleo conserva la proyección educativa y una tabla completa de secciones hacia contratos existentes; la comprobación rechaza huecos, duplicados y destinos inexistentes.
- Los recursos de vocabulario, funciones y diagnósticos se extraen del corpus y se verifican contra la exportación. Ningún consumidor mantiene una copia manual. `LIB.MODEL` también valida facetas es/en, familias y fichas de ayuda de sus funciones y operaciones: las identidades y firmas no se duplican, las formas no colisionan dentro del perfil y cada símbolo tiene contenido bilingüe. Cada regla del validador tiene un fixture negativo.
- La prosa y los mensajes en español mostrados a personas (diagnósticos, mensajes de CLI y tarjetas de ayuda) se redactan en español neutro, sin voseo ni modismos regionales; `see_validation` verifica mecánicamente su neutralidad mediante `SEE-SPANISH-NEUTRALITY` y cuenta con un fixture negativo con violación deliberada.
- Los casos admiten semilla explícita; la ausencia conserva 42. La comparación preserva resultados desfavorables y exenciones específicas de reglas con resolución declarada.
- E-10 mide colisiones sobre programas locales con procedencia explícita. El estudio humano de E-14 requiere participantes y construcciones de la evolución del lenguaje; no se atribuyen resultados humanos a comprobaciones técnicas.

- Problema: el corpus del motor necesita observar trazas, RI, CLI, casos de app y mediciones sin crear otro formato.
  Elección: `see/1` crece de forma compatible con los bloques `medicion` (prefijo M), `instruccion` (O) y
  `cobertura` (V), y con las operaciones de caso `trace`, `ir`, `cli`, `service`, `api` y `app`. Los casos `app`
  conservan `scenario` e `input`, se comparan bajo `espera.aplicacion` y no se ejecutan con el sujeto
  `engine`. Los casos que consultan la vista pública piden `program_view`; las consultas paginadas llevan
  `paginacion` y requieren `state_pages`; `target` opcional identifica el objeto consultado, con entero no negativo. Los casos `api` conservan llamadas secuenciales sobre una sesión y `resource_from` enlaza el identificador opaco devuelto por una llamada anterior; sus argumentos contienen el programa y el perfil explícitos y no pasan por reimpresión automática. La validación rechaza escenarios, entradas, cursores y operaciones
  mal formados. Las tablas que deciden la validez
  (alfabeto `traceEvents`, `cliConventions` con códigos de salida y aperturas, catálogo `cliMessages`,
  `diagnostics`, `vocabulary`) se leen de bloques `definicion`; ningún alfabeto vive en el código.
  `instruccion` lleva `nombre` además de `firma` porque las coberturas citan instrucciones por nombre
  estable y no por elemento. Se descarta un esquema `see/2`: ningún corpus anterior cambia de significado.
- Problema: un sujeto sin observación no debe aparentar cumplir ni ocultar casos. Elección: cada
  operación declara sus capacidades (`trace` exige `execute` y `observe`, `ir` exige `ir`, `cli` exige
  `cli`, `api` exige `api` y las llamadas `help_query` también exigen `service_help`). Sin `observe` un caso `trace` es `pendiente`; sin otra capacidad es `no aplicable`; un sujeto que
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
- Problema: el análisis único y la reproducción de una ejecución en la app no tenían contrato propio; solo los
  cubría la prueba de widgets. Elección: `APP.EXEC.CONFIGURATION@1.0.0` con el escenario de app `configuration` (se añade
  al enumerado de `schemas/see-1.schema.json`), que ejecuta por `ExecutionCubit` programas aceptados y rechazados por el análisis y una
  reproducción con cinta válida y con fuente cambiada. El esperado sale de `LANG.PROFILE.STRICTNESS` y de `ENG.EFFECT.TAPE`.
  Un programa que el análisis rechaza termina como `failed`, igual que en la ejecución directa del adaptador. Se descarta
  medir llamadas al anfitrión en el escenario: los programas del corpus no declaran efectos, y el espía de cero llamadas
  vive en la prueba de widgets de la app.
- Problema: la representación de la vista en diagramas y la matriz de cobertura del consumidor necesitaban casos
  observables por el sujeto `app`. Elección: los escenarios `class_diagram`, `control_flow` y `syntax_coverage` se
  añaden al enumerado de `aplicacion.scenario` de forma compatible. Resumen la escena real (cajas, filas,
  relaciones, nodos, aristas de salida, formas no soportadas) o los códigos del verificador tras una mutación
  declarada; no aceptan respuestas precalculadas. Las reglas `API.PROGRAM.VIEW#R6`–`R18` se redactaron sobre la
  versión congelada sin `cambio` y quedan sin reanclar hasta su revisión independiente. Los escenarios `dependencies` (`R15`, `R16`, casos C48–C52) y `export_support` (`R17`, `R18`, casos C53–C60) se añaden al enumerado de `aplicacion.scenario`: el primero resume las dependencias sin enlazar, el bloqueo de ejecución y exportación y las operaciones distintas de analizar y leer la vista; el segundo, la clasificación de código equivalente por destino sobre el cubit real.
- Problema: la prioridad del cierre se confundía con intención inequívoca y no cubría la continuación de asignación.
  Elección: `TOOL.SERVICE.COMPLETION#R13` exige intención escrita, elimina cierres inline en líneas vacías y contempla
  `nombre <- ` únicamente para un destino simple declarado y asignable. `R8` reutiliza cierres existentes sin tomar los
  de otros bloques; `APP.EDITOR.COMPLETION#R6` verifica la aceptación por el puente. Es una corrección observable de la
  asistencia, sin modificación de la gramática ni de la asignación. Por instrucción de la persona se mantienen las
  versiones oficiales `0.1.0`, sin campo `cambio`, y se reanclan solo ambos contratos mediante `lock --refresh`.
  La medición local del arnés general de completado registró 172 programas,
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
- Problema: los editores necesitan resaltar candidatos léxicos sin implementar otro scanner ni decidir
  validez. Elección: `LANG.LEXICAL.IDENTIFIER`, `LANG.LEXICAL.NUMBER-LITERAL`,
  `LANG.LEXICAL.COMMENT`, `LANG.LEXICAL.TEXT-LITERAL` y `LANG.LEXICAL.KEYWORD` declaran los datos
  de proyección TextMate; `see_validation` comprueba su forma y `see_export` los entrega como recursos.
  La gramática derivada es tolerante; tokens semánticos y diagnóstico siguen perteneciendo al motor.
  Se rechaza una tabla léxica mantenida por cada consumidor.
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
  declarar cumplimiento por ausencia de casos. El arranque SEE recorrió borrador, propuesta y
  experimental tras revisión estructural manual y llegó a estable 1.0.0 con la revisión independiente de la persona
  registrada en `revisado_por`; los contratos restantes entran en experimental bajo la autorización de R1.
  `PERF.AOT.LEVEL` llegó a estable 1.0.0 desde experimental 2.0.0 tras retirar R4 (el nivel optimizado no tiene backend ni plan vigente; sus identidades quedan como lápidas) y conservar R1 a R3, que Cranelift cumple.
  `PERF.PROTOCOL` y `PERF.ARTIFACT.SIZE` llegaron a estable 1.0.0. `PERF.PROTOCOL` conserva R1 a R6, que el arnés ya verifica, y deja R7 como lápida: medía la latencia de la app sobre un dispositivo que ninguna regla definía. `PERF.ARTIFACT.SIZE` se certificó con bytes de binarios de release (ios-arm64 2,985,792 B de 3 MiB; Wasm Brotli 530,599 B de 600 KiB), que no requieren dispositivo; se retiró la mención de Android porque la app no lo soporta. `PERF.VM.STEP-LATENCY` y `PERF.FRONTEND.THROUGHPUT` se eliminaron sin tombstone, por ser experimentales: la primera quedaba acoplada a hardware físico sin definición ni arnés, y la segunda no se cumplía en Apple M2 (770 000 líneas/s frente a 1 000 000). La primera versión del lenguaje no contiene especificaciones experimentales.
  `API.WIRE-FORMAT` llegó a estable 1.0.0 tras cerrar R2 (el codificador ya transporta `source`) y R3 con la prueba de Chrome de `pseudolearn_wasm`; el vínculo app queda exento porque su adaptador nativo no anuncia `wasm`.
- Problema: clasificar significado requiere juicio. Elección: diff propone clases y exige registro
  de clasificación e impacto; cambios de texto quedan para revisión. No infiere aprobación humana.

### Hallazgos del sujeto reference

Identidades permanentes de evidencia, independientes de la investigación transitoria. Los esperados son normativos; las exenciones solo afectan al sujeto congelado y se resuelven en la fase indicada: R4 para el análisis y R5 para la observación de la ejecución. Los hallazgos del contraste inicial de R3 se resumen a continuación. La matriz mide los casos declarados, no una demostración universal del contrato.

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

Problema: algunos argumentos de clase término, como la causa de `variableUsedUninitialized`, son identidades técnicas
que no se deben mostrar tal cual en un mensaje. Elección: `diagnosticTerms` (D2 de `DIAG.CATALOG`) asocia código,
argumento y término a un texto `es` y otro `en`; `diagnostic_terms` exige que el código exista en el recurso
`diagnostics` de la misma especificación, que el argumento sea de clase término, que haya exactamente los dos idiomas,
sin llaves de plantilla y con español neutro. El recurso viaja en la exportación y en `cases/catalogs.json`; el
argumento conserva el término y solo el borde que presenta el mensaje lo sustituye. Se rechaza cambiar el valor del
argumento, porque los casos y los consumidores lo comparan como identidad.

Cada sujeto lee su manifiesto de vínculos en una ruta fija (`bindings::manifest_path`) y se lanza con una descripción de
datos (`subject_adapters`): `reference` como archivo histórico sin lanzador, `engine` con el adaptador del motor, `cli` y `aot` con el binario `pseudo`
(`--see-adapter` y `--see-adapter aot`), y `app` con `dart run tool/see_app_adapter.dart` desde la raíz de
`apps/pseudolearn_app`. El adaptador app inicializa el transporte FRB generado y ejecuta análisis, ejecución,
consulta de estado, completado y llamadas de propiedades API por esa frontera. `aot` ejecuta los casos `execute` y los casos `api` de `execute_project` contra ejecutables reales; un caso `api` cuyas llamadas son solo `execute_project` y `analyze_project` exige la capacidad `project_api`, que también satisface un sujeto que anuncia `api` completa, de modo que un sujeto puede ofrecer proyectos sin ofrecer la sesión de ejecución observable; los casos de análisis,
representación intermedia y traza quedan `no aplicable` o `pendiente` por capacidad. Las propiedades se ejecutan con
`conform --subject <sujeto> --operation properties`; una propiedad cuya capacidad el sujeto no anuncia queda `pendiente` y no
cuenta como fallo, y un escenario que exige observación (cancelación, consulta de estado o eventos) no se envía a un
sujeto sin `observe`. `differential` compara además `engine` con `aot` (salida, terminación, códigos, argumentos y tramos de errores, sin
exenciones) cuando existe evidencia local de ambos sujetos y guarda el informe en el directorio local ignorado.

El hash normativo incluye identidad, edición, sujetos, dependencias, reemplazos y bloques de contrato; excluye estado,
versión, revisor, títulos, resumen y prosa. Una edición normativa autorizada que conserva versión sustituye solo la clave
`ID@versión` de `history`, y la orden `lock` genera los anclajes actualizados. Los cambios de estado y revisión
actualizan el anclaje activo sin reemplazar el hash histórico.

La conformidad de propiedades usa `property-conformance.json`: identidad versionada, algoritmo,
semilla y cantidad de muestras. Incluye las treinta propiedades del motor y la CLI, también las de
API y reimpresión heredadas; omitir una propiedad del sujeto es un error de vínculo. El archivo de datos conserva los vínculos regla–código y la validación
rechaza duplicados, referencias retiradas y cantidades cero. Registrar un vínculo no es evidencia de ejecución.
Las propiedades de las herramientas de edición (`service_format`, `service_translate`, `service_incremental`,
`service_workspace`, `service_node_identity`, `service_completion_templates`) se ejecutan contra el sujeto `service` sobre cada programa de
ejecución del corpus: verifican idempotencia del formateo, identidad de la doble traducción, equivalencia de la edición
incremental con el análisis desde cero, equivalencia del workspace y orden de archivos, estabilidad de la identidad de nodos ante ediciones locales y validez sintáctica de
las plantillas. Un ejecutor que no encuentra contraejemplo en un sujeto sin la capacidad `service` queda `pendiente`, nunca `cumple`.
Las propiedades de reimpresión y recuperación sin pérdida también las ejecuta el sujeto `service`.


El manifiesto admite `estado: activo` o `estado: retirado`; omitirlo mantiene compatibilidad con
manifiestos activos. Un sujeto retirado conserva identidad y vínculos sin requerir rutas instaladas,
aparece como no aplicable en la matriz y no cuenta para la estabilidad del lenguaje.
Solicitar su ejecución produce `SEE-SUBJECT-RETIRED`. La revisión independiente es un requisito adicional:
la existencia de un vínculo no demuestra por sí sola conformidad ni estabilidad.

La actualización `see lock --refresh ID,ID` reancla exclusivamente los identificadores autorizados,
sin cambiar sus versiones durante el congelamiento. Las ediciones oficiales de una versión congelada no llevan
`cambio`; las identidades terminales no admiten actualización. La comprobación ordinaria conserva la inmutabilidad
del anclaje histórico y rechaza cualquier edición que no se haya reanclado.
El diferencial activo compara engine y aot; no lee ni exige hashes actuales del archivo histórico.
La puerta local incluye rechazo de dependencias operativas retiradas y sus casos negativos.

Las cargas sin traza declarada se ejecutan completas con sus límites originales. Para evitar exceder el MiB del protocolo, el registro devuelve un resumen SHA-256 incremental y la cantidad de eventos, con identidades de revisión y nodo normalizadas biyectivamente por primera aparición; conserva tramos, alias, orden y datos de cada evento. Las variantes comparan ese resumen junto con salida, terminación, diagnósticos y consumo de entrada. No se sustituye la ejecución por un prefijo.

Las propiedades que comparan particiones de eventos solicitan registros sin snapshots completos; conservan eventos, tramos y cinta. Las propiedades de estado solicitan sus snapshots de forma explícita. Así una prueba de lotes no introduce copias cuadráticas ni supera el límite de transporte al transportar estados que no consulta.

La propiedad CLI de RI recorre las fuentes de casos de análisis, ejecución y traza. Obtiene la RI mediante un proceso real y exige aceptación y reimpresión idéntica mediante la API pública; los fallos y las salidas alteradas tienen negativos del ejecutor.

Las páginas consultadas comparan los campos declarados y reconocen `next_cursor: "opaque"` como una cadena no vacía; los estados completos siguen comparándose exactamente. Los negativos conservan el rechazo de elementos distintos, cursor vacío y estado completo con datos adicionales.

Las comparaciones entre ejecuciones renombran identidades opacas de forma biyectiva, conservando alias, revisiones y tramos. La propiedad de no interferencia de observación compara la ejecución sin consultas de estado auxiliares; estas conservan sus casos de conformidad propios.

Un caso de frontera que solicita transporte Wasm exige la capacidad `wasm`; el adaptador nativo de app no la anuncia. La retención local de respuestas no acredita crecimiento de memoria Wasm.

Los casos pueden restringir `sujetos` a un subconjunto explícito de los declarados; la ausencia conserva la aplicación a todos. Así se separan fronteras de app y CLI sin convertir capacidades ausentes en aprobaciones. La propiedad de revisión de `program_view` usa pares de documentos mínimos idénticos para detectar reutilización incorrecta de identidades entre revisiones y después del cierre.

### Corredor de conformidad: grabar y reproducir, observación del anfitrión y privacidad

- `grabar_y_reproducir` se ejecuta en el corredor (`recording_replay.rs` de `see_conformance`), no solo en pruebas de
  Rust: tras una ejecución viva, el corredor reenvía la misma petición en modo `replay_from_tape` con la cinta recibida
  y un anfitrión reducido a los campos de identidad (`permissions`, `requested_permissions`, `max_tape_bytes`), de modo
  que la reproducción no dispone de archivos, argumentos ni reloj. Compara salida y terminación y exige cero llamadas al
  proveedor. Aplica a los sujetos que anuncian `execute` con cinta (`engine` y `aot`).
  Si la ejecución viva no produjo cinta (por ejemplo, `aot` ante tareas), el caso registra esa ausencia como una
  diferencia propia y la sesión continúa; abortar la sesión impedía medir los demás casos del sujeto y ocultaba la
  causa bajo un fallo del corredor.
- La clave `anfitrion_observado` de `espera` (`llamadas`, `recursos_abiertos`) compara la observación del anfitrión que
  devuelve el sujeto.
- Si el anfitrión declara `secrets`, el corredor busca el valor de cada secreto en la cinta viva en forma textual,
  escapada, decimal (octetos) y hexadecimal, y en la carga de cada entrada; cualquier aparición es una diferencia
  `SEE-PRIVACY`.
- El esquema `see-1` acepta `secret_keys` (identidad de clave → clave del proveedor de prueba) y `detached`, que el
  motor ya leía; antes el esquema los rechazaba. El validador de casos (`host_cases.rs`) usa ahora los identificadores
  reales de operación (`file_write_text`, `file_close`, …) para decidir qué fallos pueden ser inciertos; antes comparaba
  contra nombres que ningún proveedor emite.
- Operaciones de directorio y de archivo: `LIB.IO` R5–R11 especifican las operaciones de directorio (`Existe`, `EsDirectorio`, `Listar`, `Borrar`, `Renombrar`,
  `CrearDirectorio`) y de archivo (`AgregarTexto`, `AgregarBytes`); `LIB.MODEL` D2 las declara con familia `io`, efecto y falibilidad.
  El esquema `see-1` acepta la directiva `directories` del anfitrión en memoria (directorios vacíos explícitos) y el validador
  de casos admite incertidumbre en las nuevas operaciones que mutan. Los casos C22–C67 usan salidas idénticas en ambos perfiles
  (los booleanos se imprimen como `1`/`0`) y se ejecutan con grabación y reproducción donde la regla lo permite. No hay caso
  de incertidumbre en el corpus: la búsqueda por evento de la historia no soporta todavía un efecto fallido incierto (ocurre
  también con `file_write_text`), de modo que la incertidumbre de `Renombrar` se cubre en `pseudolearn_api/tests/directory_effects.rs`.
- Hallazgos registrados al reescribir los casos: la ortografía `Funcion`/`function` es un alias de `SubProceso`, de
  modo que la traducción automática de `perfil_base` a inglés convierte una función pura en subprograma; los casos de
  pureza declaran por eso ambos programas. La operación de escritura de `Consola` se llamaba `Escribir`/`write`, igual que una
  palabra reservada, y no podía invocarse; ahora se llama `EscribirTexto`/`writeText` (identidad `console_write` sin
  cambios) y `LIB.MODEL#M2` prohíbe que una forma de biblioteca coincida con una palabra reservada.

### Ficha del lenguaje para agentes (`see agent-sheet`)

Los modelos de lenguaje conocen PSeInt y no PseudoLearn; sin contexto escriben base uno, omiten el punto y
coma o declaran parámetros sin tipo. `see agent-sheet [--check]` genera una ficha en Markdown por idioma
(`es`, `en`) a partir del mismo corpus que `export`: reglas de oro, vocabulario canónico por perfil,
funciones de biblioteca y operaciones con capacidad, la gramática EBNF de `grammar`, las diferencias con
PSeInt y ejemplos canónicos.

- La selección editorial vive en `agents/agent-sheet.json`, fuera del corpus: textos de las secciones,
  reglas de oro, diferencias y ejemplos. El corpus sigue sin citar herramientas externas
  (`SPEC-SELF-CONTAINED`); el archivo de la ficha sí nombra PSeInt porque es material para agentes.
- Cada diferencia nombra una regla con identidad `ESPECIFICACION#R`; el generador cita su texto
  normativo y falla si la regla no existe. Cada ejemplo es un caso `ESPECIFICACION#C` de operación
  `execute`, con programa en el perfil de la ficha y salida esperada con terminación `completed`; el
  generador falla en cualquier otro caso. «Se ejecuta al generar» se cumple por construcción: solo se
  admiten casos que `see conform --subject engine` ejecuta en cada `cargo xtask verify`. Se descartó
  ejecutar los ejemplos desde SEE porque obligaría a importar un sujeto en la exportación.
- Los textos normativos se citan en español, el idioma del corpus, también en la ficha inglesa.
- Destinos: `apps/pseudolearn_app/assets/agent/<idioma>/language-sheet.md` (lo empaqueta la app),
  `apps/pseudolearn_web/src/shared/agent-sheet/generated/` (lo publica la web como `llms-full.txt`) y
  `apps/pseudolearn_cli/generated/language-sheet.<idioma>.md` (la incrusta `pseudo mcp`). Son
  los únicos consumidores, por eso se versionan (`GEN-NO-HAND-COPY`). `cargo xtask verify` ejecuta
  `agent-sheet --check`, que falla con `SEE-STALE` si una copia difiere de la generada.

### Orden de regeneración tras editar el corpus

Editar una especificación cambia el hash de la exportación y, con él, artefactos que viven en otros miembros. Cada uno
tiene un verificador que falla mientras no se regenere, y se regeneran siempre con su generador, nunca a mano
(`GEN-NO-HAND-COPY`). El orden importa porque cada paso lee la salida del anterior:

| Paso | Dónde | Orden | Qué detecta el desfase |
|---|---|---|---|
| 1 | `packages/pseudolearn_spec` | `see validate` | Contrato inválido o identidades retiradas sin lápida |
| 2 | `packages/pseudolearn_spec` | `see lock --refresh ID,ID` solo para identidades autorizadas; `see lock` registra las nuevas | `see lock --check` (`SEE-HASH`) |
| 3 | `packages/pseudolearn_spec` | `see export --root .` | `see export --check` |
| 4 | `packages/pseudolearn_spec` | `see agent-sheet` (copias de la app, la web y la CLI) | `see agent-sheet --check` (`SEE-STALE`) |
| 5 | `apps/pseudolearn_vscode` | `pnpm generate:grammar` | `pnpm check:grammar`, que también ejecutan `pnpm build` y `pnpm build:web` |
| 6 | `packages/pseudolearn_reference` | `reference lock` si cambió un ancla, y `reference build` (libro y ruta que empaqueta la app) | `reference check` (`REF-BUNDLE-STALE`, `RUTA-BUNDLE-STALE`) |

Tras un cambio de comportamiento hay que repetir en los miembros afectados su verificación completa: la evidencia de
conformidad y de propiedades guarda el hash de cada especificación y se rechaza como obsoleta (`SEE-STALE`) hasta
volver a ejecutarla, primero `conform --operation properties` y después `conform`.

La puerta de identidades compara con la revisión Git base: la del último commit si hay cambios sin confirmar en
`specifications/`, y la del commit anterior si ya se confirmaron. Retirar de una especificación estable reglas o casos
ya confirmados sin dejar lápida falla con `SEE-IDENTITY` hasta que un commit posterior no toque `specifications/`; el
movimiento de `TOOL.CLI.CONVENTIONS#R11` a `R16` hacia `TOOL.MCP` se confirmó en ese orden.

### Servidor MCP (`TOOL.MCP`)

El contrato de `pseudo mcp` nació como las reglas R11 a R16 de `TOOL.CLI.CONVENTIONS` porque se creyó que el
congelamiento impedía una especificación nueva sin revisión independiente. Tiene identidad propia porque su ciclo de
vida, su esquema de herramientas y sus casos no dependen de las convenciones de órdenes, idioma y códigos de salida. Nace
estable `1.0.0` y sin `cambio` (`check_initial`), con `revisado_por` igual a la persona responsable,
quien autorizó crearla y registró su aprobación como revisión independiente, con
precedencia sobre el congelamiento solo para esta especificación. El resto del corpus sigue congelado.

La revisión corrigió lo que el contrato dejaba al código: faltaban casos para `tools/list`, `search_reference`, `example`,
los recursos y casi todas las rutas de error; el orden de claves, los esquemas de herramienta, el troceado de la ficha en
secciones y la puntuación de la búsqueda eran los de la implementación; el tipo de los argumentos no se validaba; y la
regla de `run` fijaba una guarda de cinco segundos de reloj que `ENG.LIMITS#R14` hace innecesaria. `resources/read` de una
ficha completa no tiene caso porque la salida exacta sería la ficha entera; la comprueba una prueba del miembro.

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
cargo-deny (avisos, licencias, duplicados y fuentes), `see validate`, `see export --check`, la ejecución
de propiedades y la conformidad engine. Genera exportación y evidencia bajo `results/`, rutas locales
ignoradas. Antes de abrir la sesión de protocolo, construye el adaptador release para excluir el tiempo de
compilación del límite de espera de inicio.
Los casos negativos prueban duplicados, regla huérfana, captura sin revisor, versión congelada,
ciclos y perfil faltante; otros prueban esquema, referencias, rango, estados y clasificación.
Cada rechazo del motor y sus fronteras tiene fixture propio comprobado por su identificador:
`trace-class` → SEE-TRACE-CLASS, `ir-expectation` → SEE-IR-EXPECTATION, `cli-exit` → SEE-CLI-EXIT,
`limit-kind` → SEE-LIMIT-KIND, `measurement-protocol` → SEE-MEASUREMENT-PROTOCOL, `ir-coverage` →
SEE-IR-COVERAGE, `ir-unknown` → SEE-IR-UNKNOWN, `profile-openers` → SEE-PROFILE-OPENERS,
`message-parity` → SEE-MESSAGE-PARITY y `message-arguments` → SEE-MESSAGE-ARGUMENTS.
El corpus completo rechaza enlaces HTTP externos y conserva referencias entre sus propias identidades. La procedencia
de programas adaptados a `PERF.SUITE.CORE` se registra en la sección de fuentes de este README, no en la especificación.
La conformidad tolera hasta 60 segundos para iniciar un adaptador que compila al lanzarse y mantiene
15 segundos por petición protocolaria. Las pruebas de protocolo incluyen negociación inválida, JSON corrupto, EOF, timeout y capacidad ausente;
el adaptador de prueba cubre además observación anunciada, eventos no anunciados, RI y CLI.
Las pruebas de traducción incluyen cadenas, comentarios, ida/vuelta y colisión.
Las dependencias internas declaran versión y ruta; no hay excepciones de auditoría. Los fallos esperados del piloto se conservan como evidencia,
con exenciones justificadas; cualquier vínculo cumple que falle impide verificar.

Los casos de ámbitos léxicos distinguen nombre desconocido y declaración terminada, sombreado y bloques hermanos.
El control de `Para` pertenece al bucle; los casos que consultaban su valor posterior pasan a comprobar el rechazo
de ese acceso. Los ejemplos ejecutables de ayuda usan casos que no dependen de un control fuera de ámbito.
Las ediciones conservan la identidad y versión de los contratos; no introducen migradores ni compatibilidad.

## 8. Fuentes consultadas y genealogía conceptual

Los contratos SEE definen see/1, identidad, fases de ciclo de vida y protocolo. Cargo aporta workspaces,
metadatos y xtask; serde aporta contratos de datos; semver rangos; SHA-256 anclaje canónico.
Se toma el modelo de versión semántica para cambios declarados; se rechaza equiparar cambio
textual con clasificación semántica definitiva. No se consultan fuentes externas para decidir
comportamiento del lenguaje.

`PERF.SUITE.CORE` adapta diez algoritmos y tamaños del conjunto Are We Fast Yet, de Stefan Marr,
publicado entre 2015 y 2016 bajo licencia MIT. Se conservan los algoritmos y valores de control; se
rechazan sus mediciones como oráculo de rendimiento de PseudoLearn. Las entradas, adaptaciones,
oráculos y resultados que sí son normativos están completos en el corpus.

Aviso de copyright y licencia de los programas adaptados:

```text
Copyright (c) 2015-2016 Stefan Marr

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

Las aclaraciones de ejecución fijan redondeo binario64 al más cercano con empates al par, formato mínimo
de ida y vuelta, raíces nocionales que incluyen temporales vivos y sondeos de cancelación en condiciones.
Los esperados matemáticos añadidos se justifican por intervalos racionales en
intervalos racionales; ninguna captura del sujeto define esos resultados.

Los adaptadores engine y service se compilan en Release para ejecutar las propiedades completas sobre cargas grandes; el plazo máximo por solicitud de propiedades es de 300 segundos. Esto es una puerta funcional y no una medición de rendimiento. El corpus conserva los límites semánticos de cada solicitud.

El esquema `see/1` admite la terminación `awaiting_effect` con `efecto_pendiente`, el corte del anfitrión
durante una espera de efecto mediante `cancel_on_awaiting_effect`, la observación de `estado_cinta`,
`efectos` (`effect_seq`, `capability_kind`, `operation`, `outcome` y `secret_key_id`) y `reproduccion_fallo`
en `anfitrion_observado`, la mutación controlada de la cinta grabada con `alterar_cinta` antes de intentar
reproducirla y las operaciones `start`, `advance`, `input`, `effect_result` y `cancel` en secuencias `api`.

### Propiedad de trampas y sujetos sin observación

`property_traps.rs` genera programas con todos los enlaces inicializados (`Definir r Como Entero <- …`), porque el lenguaje rechaza el enlace sin inicializador y la propiedad fallaba en todos los sujetos antes de ejercer la regla, y solo pide el modo `observe: events` a los sujetos que anuncian la capacidad `observe`; el sujeto nativo lo rechaza por diseño. Cubre `property_traps_tests.rs`. Los casos con anfitrión admiten además `cancel_on_awaiting_effect` y `alterar_cinta` como directivas del corredor.

### Contratos de tareas y canales

Los fallos de ámbito amplían las reglas existentes conservando versión y estado. El formato exige
identidades de regla `R…`: las seis reglas de fallos ocupan `LANG.TASK.SCOPE#R11`–`R16`, las ocho
de canales `LANG.TASK.CHANNEL#R1`–`R8` y la detección de bloqueo `ENG.TASK.AGENDA#R7`. Los casos
se derivan del orden FIFO, la cancelación antes de reanudar y la selección por orden textual; los
lexemas de programa se mantienen bilingües y los nombres propios no se traducen. Las vinculaciones
nuevas permanecen pendientes de conformidad hasta ejecutar a ambos sujetos. Un test del runtime
sobre errores asociados comprueba sucesos terminales ya registrados; dos hijas con retornos
inmediatos no implican por sí solas dos errores porque la segunda recibe la cancelación antes
de ejecutar. Los esperados del corpus no se obtienen de capturas de ejecución.

## Contratos de aislamiento y memoria de tareas

El aislamiento y la memoria se incorporan como identidades estables `1.0.0`, conservando el
congelamiento. Los casos de aislamiento derivan los rechazos de tipos, lectura inmutable y
presupuestos exactos sin capturar resultados del motor. Los vínculos de ambos sujetos permanecen
pendientes de conformidad. El recurso de firmas admite la entrada de instantánea y su retorno
inmutable, y el catálogo presenta ambas identidades con ejemplos bilingües del corpus. La cesión
conserva masa entre vueltas inferiores al cuanto: reiniciarla en cada vuelta impediría ceder a los
bucles pequeños. El texto normativo explicita esta acumulación.

### Contrato HTTP y anfitrión falso

`LIB.HTTP` declara los métodos, las respuestas HTTP completas y el formato de los guiones locales en
`anfitrion.http`. Los guiones se resuelven por método y URL en el anfitrión de memoria; no habilitan
conexiones públicas. El corredor de conformidad nunca abre sockets ni resuelve nombres: `anfitrion.http`
es la única fuente de respuestas HTTP para los casos. Un caso sin permiso de red recibe
`PermisoDenegado` al solicitar la capacidad, antes de poder enviar una petición. Las comprobaciones de
transporte real usan solo el servidor de prueba de la CLI ligado a loopback. La clave se valida y se
interpreta en `see_validation`, mientras `see_format` permite URL literales en el texto de contratos
sin aceptar enlaces Markdown externos.

La regla `LIB.HTTP#R6` y su caso `C8` discrepan sobre cintas con credenciales: la regla pide conservar
la respuesta completa para reproducirla, pero el caso exige una cinta marcada no reproducible tras
redactar el secreto. El motor conserva la política general de redacción y no reproducibilidad; la
reproducción de esa respuesta queda pendiente de resolver en el contrato.

## Depuración e integración LSP portátil

El control de depuración se especifica en las operaciones públicas de ejecución y estado; el adaptador DAP solo traduce el protocolo. La expresión de inspección comparte compilador y VM, exige EOF y un subconjunto sin llamadas, y usa un estado aislado sin anfitrión. Las ventanas históricas conservan separadas la punta y la inspección. Una sesión LSP es un recurso persistente de API: Wasm no importa servicio directamente. El transporte Wasm puede devolver una proyección con números como cadenas sin alterar el JSON original.

Los casos DAP usan entrada/salida de la capacidad CLI ya existente y un comparador de framing y campos observables. Los vínculos nuevos permanecen pendientes hasta la campaña, y las especificaciones conservan estados/versiones congelados. La preparación del contrato no concede revisión independiente ni autoriza reanclajes.

## Doble de efectos de conformidad

El bloque anfitrion de un caso contiene únicamente datos y fallos del doble de prueba. El esquema
rechaza permissions, requested_permissions, network_origins y local_origins: la autoridad inicial
es plena. Una denegación se deriva de una atenuación voluntaria o de un fallo de plataforma inyectado.
Los paths del doble admiten rutas de sistema portátiles, incluidos .., letras de unidad y UNC.
El doble no se distribuye en los anfitriones de producto. Estados, identidades y versiones siguen
congelados; los contratos oficiales se corrigen y reanclan juntos conservando su versión.

## Ampliación numérica y de colecciones

Los miembros contextuales de ordenación, inversión, búsqueda y claves y las diez funciones numéricas conservan identidades y versiones congeladas. La propiedad math_oracle contrasta muestras reproducibles con el oráculo independiente. Los vínculos nativos nuevos permanecen pendientes de paridad.

## Entorno, fecha y hora

La configuración `anfitrion` de los casos admite `environment` (objeto de cadenas, que el doble de memoria sirve a
`Obtener`) y `offset_seconds` (entero, el desplazamiento que `AhoraLocal` añade al instante de `clock`). La lista
cerrada de tipos de `LIB.MODEL` D2 gana `environment`, `date_time` y `optional_date_time` (`capability_library.rs`).
Las fichas de ayuda de las dieciocho operaciones nuevas viven en `tool.service.catalog.md` y los tres identificadores de
vocabulario nuevos comparten una tarjeta propia porque la de capacidades ya está en el máximo de partes. Los valores
esperados de `LIB.TIME` salen de la definición del calendario, calculados con `datetime` de Python como oráculo
independiente del motor; ningún valor se capturó de una ejecución. La propiedad de ida y vuelta ISO sobre instantes
sembrados no tiene generador propio: queda cubierta por el caso `LIB.TIME#C15` (seis semillas fijas) y es un pendiente
declarado.

## Formato de números

`LIB.CORE.CONVERSION#R2` (`Decimales`) y `LIB.CORE.TEXT#T5` (`RellenarIzquierda`, `RellenarDerecha`) se verifican con casos del corpus. Los
valores esperados salen de la definición decimal (expansión exacta del binario64, empates alejados de cero), no de una
ejecución. Los límites de celdas de `C14`/`C15` y `C41`/`C42` son medidas del contador del motor (la cadena de relleno y
sus literales cuentan), no una fórmula de la regla. Pendiente declarado: la propiedad de ida y vuelta
`AReal(Decimales(x, 17)) ≈ x` sobre reales sembrados no tiene generador propio; los casos fijos la cubren puntualmente.
Exportación a otros lenguajes (`format!("{:.2}")`, `f"{x:.2f}"`): no existe exportador de operaciones D2, así que se
declara «sin equivalente» y queda pendiente con el sujeto nativo.

## Código de salida y salida de error

`LIB.IO#R15` (`EstablecerCodigoSalida`), `LIB.IO#R16` (`EscribirError`) y `TOOL.CLI.RUN#R8`. Los casos `TOOL.CLI.RUN`
`C23`–`C26` ejecutan el binario real y comprueban código de proceso y salida de error. Para que el validador acepte los
códigos 7 y 9, `TOOL.CLI.CONVENTIONS#D1` los declara como códigos establecidos por el programa (rango 0–255).
`TOOL.CLI.RUN#R2` pasa de «0 si completed» a «el código establecido (0 por omisión) si completed». El contrato de salida es aditivo: `output` conserva ambos
flujos en una sola cadena y `error_ranges` marca los tramos de error; los consumidores sin soporte muestran todo.

## Alias de operaciones de biblioteca y suite clásica

Problema: los nombres clásicos `Mayusculas` y `Minusculas` debían nombrar las operaciones de texto ya confirmadas sin
crear identidades nuevas. Elección: una fila de D2 admite un campo opcional `alias` con listas `es` y `en`, con la misma
semántica que en D1; el validador acepta el campo solo con ambas listas y nombres no vacíos, y comprueba cada alias como
una forma más del registro de unicidad (M2). Alternativas descartadas: duplicar la fila, que rompe la identidad única
(M1). `LANG.PROGRAM.CLASSIC` reúne programas de pseudocódigo clásico que se pegan sin retoques y se verifican en
`engine` (ejecución y análisis), `cli` (`pseudo ejecutar` con entrada estándar) y `service` (diagnósticos de un proyecto
de un archivo); su perfil `en` se excluye con justificación porque ese pseudocódigo está escrito en español y cada
construcción se verifica en inglés en su propia regla. `aot` queda pendiente hasta que el código nativo implemente el azar
entero.

## Vocabulario, biblioteca y formato canónico (revisión de 2026-11)

- **Una sola grafía de la rama contraria.** Por decisión de la persona, `LANG.PROFILE.VOCABULARY` ya no declara el alias
  `Si No`: con él, `Si NO x Entonces` se leía como `Sino`. El lexema es `Sino`, que el formateador ya escribía, y todos los
  programas del corpus, la ayuda, la base de conocimiento de la app y las pruebas usan esa grafía. Los casos C6 y C7
  cubren `Si NO x` y el rechazo de `Si No` como rama; la ficha «Signos y NO» ya no advierte del problema y
  `LANG.OPS.PRECEDENCE` C3 escribe `Si NO abierto Entonces` sin paréntesis.
- **Formas de biblioteca frente a palabras reservadas.** `JsonLogico(...)` y `consola.Escribir(...)` fallaban porque su
  forma coincidía con una palabra de D1. `library_reserved` (`SEE-LIB-RESERVED`, regla `LIB.MODEL#M2`) pliega mayúsculas y
  tildes y rechaza cualquier forma o alias de función u operación que coincida con un lexema o alias reservado del mismo
  perfil. Con esa comprobación aparecieron exactamente las dos colisiones conocidas. La de consola se resolvió renombrando
  la operación; la de JSON, sacando de D1 los doce valores de `TipoJson` y `CodigoErrorJson`, que ya estaban en D2. El
  corpus no pide escribir esos valores como expresiones (`LIB.JSON#J8`): se obtienen de `Tipo()` y de `Codigo` y se
  comparan entre sí; un nombre como `Arreglo` escrito en una expresión es una variable no declarada (C40). Se descartó
  renombrar la función a `LogicoJson`, porque dejaba reservadas palabras tan comunes como `objeto` o `arreglo`.
- **Lexemas contextuales en los esperados.** `cases/vocabulary.json` incluye las entradas de D2 con el prefijo
  `contextual:`. `{{lexema:jsonKindBoolean}}` las encuentra cuando no hay identidad reservada con ese nombre, y el traductor
  léxico las ignora, de modo que una variable `objeto` no se traduce a `Object`.
- **Casos fuera de la verificación de su regla.** `references` (`SEE-REFERENCE`) exige que cada caso o propiedad figure en
  la `verificacion` de la regla que declara; un caso puede verificar además otras reglas. Aparecieron quince
  discrepancias, no solo las tres conocidas: `LIB.IO` C19–C21 prueban rutas del sistema y pasan a declarar R3;
  `LANG.TASK.ISOLATION` C11 y C13 prueban `Instantanea` y pasan de la verificación de R3 a la de R4; `API.PROJECT.LOCK`
  C16 pasa de R2 a R1 y C14 de R1 a R5; el resto (`API.PROGRAM.VIEW` C6, `API.VERSIONING` C3 y C4, `LANG.TASK.SCOPE` C22,
  `LIB.CORE.MATH` P1, `LIB.HTTP.POLICY` C7, `TOOL.SERVICE.NAVIGATION` C7 y `TOOL.SERVICE.WORKSPACE` C8) se añade a la
  verificación de la regla que ya declaraba.
- **Aperturas de perfil.** `TOOL.CLI.CONVENTIONS#D1` enumera todas las aperturas de nivel superior, incluidas interfaz,
  variante y visibilidad, y el motor genera la detección desde esa lista. `SEE-PROFILE-OPENERS` busca también en D2.
- **Lagunas cerradas.** `ConTiempoMaximo` recibe nanosegundos (`LIB.HTTP#R2`, `#R7`), como `Reloj` y `Temporizador`.
  `LIB.JSON#J4` cuenta columnas en puntos de código y sitúa `FinInesperado` tras el último carácter (C41, C42); el motor
  informaba bytes y el último carácter. `Longitud` de un dato JSON que no es arreglo ni objeto vale 0 (`#J6`, C43).
  `LIB.IO#R10` hacía normativo que abrir en escritura o en lectura_escritura crea o vacía el archivo; la revisión
  posterior de esta misma sección cambió `lectura_escritura` (C100–C103). `LIB.CORE.BYTES#B1` define `En` y los argumentos de su
  `arrayIndexOutOfRange` (C13, C14).
- **Forma canónica.** `TOOL.FORMAT.STYLE` fija qué abre un nivel de sangría (toda construcción con cierre de la gramática),
  dónde no va `;`, que los ángulos de tipo no llevan espacios y la grafía: el lexema tal cual en español (`div`, `mod`,
  `Sino`, `Algoritmo`), y mayúscula inicial por palabra en inglés, como ya
  fijaba C4, también para las palabras contextuales en posición de palabra clave. Los esperados de C5–C7 de esa
  especificación y de `TOOL.TRANSLATE.ROUND-TRIP` C5 se obtuvieron ejecutando el formateador y se contrastaron línea a
  línea con las reglas; no llevan `revisado_por` y requieren revisión independiente. Los 290 programas de ejemplo de la
  ayuda que cambiaban de forma se regeneraron con el formateador, y las plantillas `form` pegan los ángulos genéricos y el
  paréntesis tras `Algo`, `Exito`, `Error` y `SubProceso`. El tope de segmentos por línea de plantilla sube de 16 a 20
  para que `FechaHora(...)` quepa en una línea (fixture `crowded-form-line`).
- **Conflicto resuelto: `Algoritmo` es canónico.** `LANG.PROFILE.VOCABULARY` declaraba `Proceso`/`FinProceso` como
  lexemas canónicos, pero el formateador, la ayuda y casi todo el corpus escribían `Algoritmo`, y `TOOL.FORMAT.STYLE#R2`
  lo resolvía con una excepción. Ver la sección siguiente.

## Conflictos y defectos resueltos (revisión de 2026-11, segunda parte)

Cada decisión se tomó con la opción recomendada; las ediciones conservan identidad, estado y versión y se reanclaron.

- **`Funcion` es palabra propia (`LANG.PROFILE.VOCABULARY#R3`).** El vocabulario declaraba `Funcion`/`FinFuncion` como
  alias de `SubProceso`, mientras `LANG.CAPABILITY.PURITY#R1` hace depender la pureza de escribir `Funcion`; el
  traductor canonizaba el alias a `Subroutine` y la función traducida perdía la pureza. D1 declara ahora las identidades
  `function` (`Funcion`/`function`) y `endFunction` (`FinFuncion`/`endFunction`, alias `Fin Funcion`/`end function`),
  la gramática acepta `function` donde aceptaba `subroutine` (subprograma, función anónima, tipo función y firma de
  interfaz, que ya admitía `SubProceso` en el motor) y empareja cada apertura con su cierre, y `function` se suma a las
  aperturas de `TOOL.CLI.CONVENTIONS#D1`. `EndFunction` se acepta como cualquier cierre, porque es la grafía canónica
  inglesa. Los ocho programas ingleses que abrían con `function` y cerraban con `endSubroutine` (posibles con el alias)
  pasan a `endFunction`. La ficha `help.subprogram` describe las dos aperturas. Se descartó conservar el alias y hacer
  que el traductor recordara la grafía: dos grafías de una identidad con significados distintos contradicen R1.
- **`Algoritmo` es canónico.** D1 intercambia lexema y alias: `Algoritmo`/`FinAlgoritmo` son canónicos y
  `Proceso`/`FinProceso` (también `Fin Proceso`, `Fin Algoritmo`) siguen reconocidos. `TOOL.FORMAT.STYLE#R2` pierde la
  excepción y el servicio la preferencia escrita a mano. Se descartó lo contrario porque obligaba a reescribir casi
  todo el corpus, la ayuda y las plantillas.
- **`lectura_escritura` conserva el contenido (`LIB.IO#R10`).** Abrir en `escritura` crea o vacía; en
  `lectura_escritura` crea si falta y conserva lo existente, de modo que `AgregarTexto` añade detrás y `EscribirTexto`
  sustituye. C100 espera ahora `[hola]`, y C102 y C103 cubren agregar y sustituir. Se descartó añadir un modo `agregar`.
- **Defectos del motor reproducidos antes de corregirlos.** `LANG.CLASS.OUT-OF-SCOPE` C6 (cascada tras una clase
  abstracta), `LANG.SUBPROGRAM.CALL` C6 (solo `callAsExpressionWithoutReturnType`), `LANG.CLASS.SELF-AND-SUPER` C5 (solo
  `identifierMatchesFieldWithoutThis`), `LIB.CORE.TEXT` C68–C70 (posición del argumento que rompe la condición),
  `LANG.OPS.POWER` C7–C8 (argumento `exponent`), `LANG.SYNTAX.RECOVERY` C10–C13 (`Sino` y `FinSi` sueltos),
  `LANG.LEXICAL.ERRORS` C4 (`Escribir 5 @ 2` sin `missingStatementTerminator`), `LANG.TASK.ISOLATION` C32–C35 (tipo con
  lexemas del perfil y ruta desde el argumento), `TOOL.TRANSLATE.ROUND-TRIP` C6–C8 y `TOOL.FORMAT.STYLE` C8–C11
  (`Funcion` traducida, `Diccionario()` con clave inválida, `Instantanea(Vector())`, `Proceso` formateado). Los textos de
  las reglas afectadas dicen ahora lo que antes solo hacía o no hacía el motor. Los argumentos que dependen del perfil se
  fijan en un caso por perfil con `exclusiones`, porque los marcadores `{{lexema:…}}` solo se resuelven en la salida y
  en los eventos.
- **Revisión de esperados capturados.** Los esperados de `TOOL.FORMAT.STYLE` C5–C7 y de `TOOL.TRANSLATE.ROUND-TRIP` C5 se
  derivaron otra vez a mano desde R1–R3 de cada especificación (sangría por bloque con cierre, ramas de `Segun` y
  `Elegir`, lexema del vocabulario, mayúscula inicial en inglés, lexema ante paréntesis de llamada, ángulos sin espacios,
  paréntesis pegado a `Algo`/`Exito`/`SubProceso`) y coinciden línea a línea con los guardados. La comparación la hizo el
  agente de implementación, no una persona, así que los cuatro casos siguen sin `revisado_por` y quedan **pendientes de
  revisión humana**; los casos nuevos de esta sección tampoco llevan revisor.
- **`TOOL.CLI.CONVENTIONS` C33 y C34.** Se añadieron con la lista de aperturas y nunca se habían ejecutado contra `cli`;
  al ejecutarlos chocaban con otras reglas aunque el perfil inglés ya se detectaba bien. C33 omitía el `;` que exige
  la firma de interfaz y ahora lo lleva. C34 abre con `public` en un archivo suelto, donde la visibilidad produce
  `moduleSyntaxOutsideProject` (`LANG.MODULE.MODEL`); espera ahora ese diagnóstico, que solo aparece si el perfil
  detectado es el inglés, de modo que sigue verificando la detección de R3.
- **`LIB.HTTP` R6 y C8.** Comprobado: ninguno expresa plazos (tratan la redacción de credenciales en la cinta); los únicos
  plazos del archivo son los de `ConTiempoMaximo` en C1, C17, C18, C19 y C38, en nanosegundos como fijan R2 y R7. No hubo cambio.
