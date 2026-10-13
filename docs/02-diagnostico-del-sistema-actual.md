# 02 · Diagnóstico comprobado del sistema actual

> **Estado:** investigación, no normativo. Describe el repositorio en el commit `b44b2dd`
> (2026-10-13). No sustituye a ningún `README.md` ni a `packages/pseudolearn_core/docs/language-spec.md`,
> que siguen siendo las fuentes de verdad vigentes según `AGENTS.md`.

Este documento separa lo que **se comprobó** (ejecutando tests, sondas o leyendo el código que
implementa el comportamiento) de lo que **solo está documentado**. Las etiquetas están definidas en
el [índice](README.md#convenciones-de-lectura). Las mediciones y las sondas completas están en el
[anexo A](anexos/A-experimentos-reproducibles.md).

---

## 1. Método

1. Lectura de `AGENTS.md`, del `README.md` raíz, de los `README.md` y archivos de reglas de los cinco
   miembros, de `language-spec.md` completo y de las once skills de `.agents/skills/`.
2. Lectura del código que implementa los comportamientos discutidos en la investigación: intérprete,
   eventos, instantáneas, valores, entorno, perfiles, autocompletado, edición, proyección de la traza,
   ejecución por lotes de la app y verificadores de contenido.
3. Ejecución de la suite del núcleo, su análisis estático y su script de límites; ejecución de los
   tests de `engine/` y de ejecución de la app.
4. Sondas dirigidas sobre la API pública del núcleo para contrastar afirmaciones concretas de la
   documentación (anexo A, §A.4).
5. Micro-mediciones del intérprete en tres objetivos de compilación (anexo A, §A.3).

Lo que **no** se hizo: ejecutar la suite completa de la app, los verificadores de `brand`, `backend`
y `fe-pseudolearn`, ni pruebas en iOS, Windows o navegador. Ningún hallazgo depende de ellos.

---

## 2. Mapa del monorepo

| Miembro                      | Papel                                                    | Cadena          | Relación con el lenguaje                                    |
|------------------------------|----------------------------------------------------------|-----------------|-------------------------------------------------------------|
| `packages/pseudolearn_core`  | Motor del lenguaje: lexer, parser, AST, semántica, intérprete, diagnósticos | Dart puro       | Es el lenguaje hoy                                         |
| `apps/pseudolearn_app`       | Cliente Flutter: editor, ejecución paso a paso, diagramas, traza, base de conocimiento, exportación a Python y Rust | Flutter 3.47.5  | Único consumidor del núcleo (por ruta relativa)            |
| `apps/pseudolearn_backend`   | Supabase: Edge Function `delete-account`, esquema SQL y RLS | Deno + SQL      | Ninguna con el lenguaje                                    |
| `packages/pseudolearn_brand` | Motor paramétrico de la identidad visual                  | Python + fontTools | Ninguna con el lenguaje                                 |
| `apps/fe-pseudolearn`        | Sitio web (Astro, Cloudflare Workers)                     | Node + pnpm     | Muestra versiones; no ejecuta el lenguaje                  |

**[COMPROBADO]** No hay integración continua que ejecute tests ni verificadores: los cinco flujos de
`.github/workflows/` son de publicación (macOS, iOS, Windows R2, Windows Store, web), y ninguno invoca
`dart test`, `flutter test`, `analyze` ni `check_limits`. El `README.md` raíz lo declara como
pendiente (§1.5).

**[COMPROBADO]** El último commit (`b44b2dd`) cambia la licencia a propietaria. El `README.md` raíz
(§6.2) define el proyecto como de código cerrado. Esta condición pesa sobre la visión de comunidad;
se analiza en [17 · Riesgos y decisiones](17-riesgos-preguntas-y-decisiones.md#d-01).

**[COMPROBADO]** `docs/` existía vacía en la raíz y no figura en el catálogo de carpetas del
`README.md` raíz (§3.3). Ver [conflicto C-06](17-riesgos-preguntas-y-decisiones.md#c-06).

---

## 3. El núcleo del lenguaje (`pseudolearn_core`)

### 3.1 Arquitectura

**[COMPROBADO]** Pipeline concéntrico de cinco capas (`domain` → `syntax` → `semantic` → `evaluation`,
y `diagnostics` que solo depende de `domain`), verificado mecánicamente por
`test/architecture/layering_test.dart` contra `architecture.yaml`. Prohibidos `dart:io`, `dart:isolate`,
`dart:mirrors`, `dart:js*`, `dart:ui`, `dart:html` y Flutter. Límites de 300 líneas por archivo, 40 por
función, 4 parámetros posicionales, 3 niveles de anidación y 7 métodos públicos, verificados por
`tool/check_limits.dart` con caso negativo. Cero comentarios en `lib/`.

Unas 17 600 líneas de código en `lib/`, repartidas en archivos pequeños de una responsabilidad. La
API pública se exporta desde un único `lib/pseudolearn_core.dart` (74 exportaciones), que incluye tipos
internos del intérprete como `Interpreter.frames` y `RuntimeValue`, de modo que la superficie pública
es amplia.

### 3.2 Modelo de dos planos y perfiles

**[COMPROBADO]** La gramática trabaja sobre tipos de token abstractos (`TokenType`); los lexemas son
datos del perfil (`LexemeEntry(canónico, {alias})`). Hay dos perfiles cerrados, `ClassicSpanishProfile`
y `EnglishProfile`, cada uno con variantes `.strict()` y `.flexible()`. El español es insensible a
mayúsculas y tildes en el léxico reservado; el inglés es insensible a mayúsculas y sensible a tildes.
Las funciones incorporadas tienen identidad abstracta (`BuiltinFunction`) y nombre por perfil, sin
ser palabras reservadas.

**[COMPROBADO]** Este modelo está respaldado por tests de paridad (`multilingual_*_parity_test.dart`),
por el test de invariantes de la política de severidad y por el verificador de contenido de la app,
que exige que cada ejemplo bilingüe produzca **la misma forma de árbol** en los dos perfiles
(`tool/content/example_checks.dart`, `checkExamplesShareShape`).

**[COMPROBADO]** La superficie reservada retira nombres al programador en todas sus grafías:

| Perfil  | Formas reservadas que coinciden con nombres frecuentes                                                         |
|---------|----------------------------------------------------------------------------------------------------------------|
| Español | `y`, `o`, `no` (operadores lógicos), `real`, `cadena`, `hasta`, `para`, `este`, `nuevo`, `super`, `constructor`, `funcion`, `procedimiento`, `mostrar` |
| Inglés  | `step`, `to`, `do`, `as`, `new`, `this`, `function`, `procedure`, `default`, `print`, `char`, `declare`, `real`, `string` |

La sonda A del anexo confirma que `Definir x, y Como Entero` es inválido en español. Cada construcción
nueva (interfaces, módulos, closures, genéricos, errores) añadirá palabras a esta lista; el problema
crece con el lenguaje y se analiza en [03 · Identidad bilingüe](03-identidad-bilingue-y-gramatica.md#presupuesto-reservado).

### 3.3 Análisis sintáctico y semántico

**[COMPROBADO]** Parser de descenso recursivo modular con sincronizador de sentencias, tope de cien
diagnósticos y resultado tipado (`ParseResult(SourceUnitNode?, diagnostics)`). Devuelve árbol ante
código incompleto (sondas C1 y C2), salvo ante texto vacío (C3).

**[COMPROBADO]** `NodeId` es un entero secuencial asignado en cada análisis
(`domain/node_id.dart`): no es estable entre ediciones. La app lo usa para sincronizar cuatro
superficies dentro de un mismo análisis (`AnalysisCache`).

**[COMPROBADO]** El lexer descarta los comentarios (pendiente declarado en ambos `README.md`). En
consecuencia, ninguna reimpresión del programa puede conservarlos.

**[COMPROBADO]** Resolución de nombres en cuatro pasadas y chequeo de tipos con perfiles estricto y
flexible (inferencia en primera asignación, ampliación única de entero a real). `AnalyzedProgram.hasErrors`
incluye los diagnósticos de resolución, porque el chequeador los incorpora.

**[COMPROBADO]** La latencia del análisis completo es de ≈12,7 ms para 1 000 líneas y ≈50 ms para
5 000 (JIT, M2), dominada por el lexer. No hay análisis incremental (anexo A, §A.4.1).

### 3.4 Intérprete

**[COMPROBADO]** El evaluador es una **máquina de tareas explícita**: cada `InterpreterFrame` tiene una
pila de tareas (`ExecutionTask`, 32 variantes concretas selladas) y una pila de operandos de tipo `Object`. Cada
`step()` desapila y despacha **una** tarea mediante cuatro `switch` encadenados
(`task_dispatcher.dart`). No usa la pila del anfitrión para las llamadas del programa: el límite de
profundidad (`Interpreter.maxCallDepth = 1000`, `interpreter.dart:39`) se comprueba contando marcos.

**[COMPROBADO]** Coste: ≈74–86 ns por micro-paso en AOT nativo; un `Para` simple cuesta 10 micro-pasos
por iteración, una comparación con intercambio en burbuja ≈45, una llamada a método ≈20. Frente al
mismo cálculo escrito en Dart y compilado AOT, el intérprete es **≈500× a ≈1900× más lento**; en
JavaScript, ≈5× más lento que en nativo (anexo A, §A.3.1).

**[COMPROBADO]** Toda la aritmética entera pasa por `BigInt` (`PseudoInteger`), con comprobación de
rango de 64 bits en cada operación. Garantiza determinismo entre nativo, JavaScript y Wasm al precio
de una asignación de objeto por resultado.

**[COMPROBADO]** No existe límite de pasos en el núcleo. `ProgramRunner.runToCompletion` itera sin
tope y **lanza `StateError`** si el programa pide entrada y no hay proveedor
(`program_runner.dart:21`; sonda D).

**[COMPROBADO]** Un arreglo se almacena como una lista plana de `VariableCell`, una celda por elemento
(`array_storage.dart:8`), sin límite superior de tamaño: `Dimension a[100000000000]` hace escapar un
`OutOfMemoryError` (sonda F).

### 3.5 Eventos e instantáneas

**[COMPROBADO]** El intérprete emite eventos sellados (`StatementEnteredEvent`, `StatementExitedEvent`,
`DecisionEvaluatedEvent`, `OutputProducedEvent`, `InputRequestedEvent`, `InputAcceptedEvent`,
`SubroutineEnteredEvent`, `SubroutineExitedEvent`, `DiagnosticEmittedEvent`, `ExecutionFinishedEvent`,
`ExecutionHaltedEvent`). Cuando hay observador, cada evento de sentencia y de decisión lleva una
`EnvironmentSnapshot` de **todos** los marcos.

**[COMPROBADO]** La instantánea recorre solo las celdas escalares del ámbito
(`snapshot_builder.dart:14`): **los arreglos no aparecen** (sonda B), porque `RuntimeScope` los guarda en
un mapa aparte que no se expone. Los objetos aparecen como `ObjectValue`, que referencia la instancia
**viva**: una instantánea antigua no conserva el estado de un objeto en su momento, solo su identidad.

**[COMPROBADO]** Observar cuesta entre 1,3× (bucles planos) y 4,6× (recursión profunda, porque la
instantánea crece con la profundidad de la pila) (anexo A, §A.3.1).

### 3.6 Diagnósticos

**[COMPROBADO]** Diagnósticos estructurados e independientes del idioma
(`Diagnostic(code, severity, span, relatedSpans, arguments)`), renderizados en `diagnostics/` según
idioma de interfaz y perfil. Cinco clases de severidad (A–E) con invariantes verificados por test.
Es uno de los activos más sólidos del sistema y la base natural de diagnósticos bilingües en un
lenguaje de propósito general.

---

## 4. La aplicación (`pseudolearn_app`)

### 4.1 Acoplamiento al núcleo

**[COMPROBADO]** Arquitectura hexagonal con la capa `engine/` como único adaptador del núcleo
(verificado por `architecture.yaml`). `CoreProgramAnalyzer` compone las etapas y `AnalysisCache` las
comparte entre superficies.

### 4.2 Ejecución paso a paso

**[COMPROBADO]** `StepBatchRunner` avanza en lotes de 25 micro-pasos cediendo el hilo con
`Future.delayed(Duration.zero)`. Cuatro ritmos (`nextStatement`, `overBlock`, `outOfBlock`, `toEnd`)
definidos como condiciones de parada sobre el foco y la profundidad de bloque (`StepSettlement`).

**[COMPROBADO]** **Tope de 10 000 micro-pasos** también en `toEnd` (`step_batch_runner.dart:7`). Con los
costes de §3.4, equivale a ≈1 000 iteraciones de un bucle simple; `Fib(20)` necesita 361 204
micro-pasos y no puede terminar en la app. Es razonable para el producto pedagógico actual y
estructuralmente incompatible con «construir software real» dentro de la misma superficie.

### 4.3 Traza e inspección

**[COMPROBADO]** `WatchRowProjection` formatea los valores con `toString()` de Dart: un lógico se ve
como `true`/`false` también en el perfil español, y un real usa la representación de Dart en vez de la
de la especificación (§7.1 de `language-spec.md`). El receptor se muestra como `Este.<campo>` con el
lexema español fijo (pendiente declarado). Los arreglos no aparecen, por §3.5.

**[DOCUMENTADO, CONTRADICHO]** El `README.md` de la app (§1.4, punto 3) promete «visualización gráfica
de variables primitivas, matrices y aliasing». La parte de matrices no es posible con la instantánea
actual del núcleo.

### 4.4 Autocompletado y edición

**[COMPROBADO]** `ProfileCompletionSource` devuelve una **lista fija de diez plantillas** por perfil, sin
contexto: no ofrece identificadores, miembros, palabras de cierre ni construcciones según la
posición. Las plantillas llevan marcadores en español (`condicion`, `variable`, `mensaje`, `nombre`)
también en el perfil inglés. La plantilla de selección múltiple omite la palabra intermedia y produce
`expectedDoKeyword` en los dos perfiles (sonda G). El test de la fuente
(`test/engine/profile_completion_source_test.dart`) comprueba que existan etiquetas, no que las
plantillas sean programas válidos.

**[COMPROBADO]** `LexiconSourceEditor` calcula sangrías y saltos desde el léxico del perfil, sin
expresiones regulares (prohibidas en `engine/`).

### 4.5 Otros consumidores del árbol

**[COMPROBADO]** Ordinograma, estructograma, diagrama de clases, impresor de pseudocódigo y emisores de
Python y Rust viven en `engine/` y recorren el AST del núcleo. El impresor (`engine/printing/`) es lo
que permitiría traducir un programa entre perfiles; como el lexer descarta comentarios, esa traducción
los perdería.

**[DOCUMENTADO, CONTRADICHO]** El `README.md` del núcleo (§1.4, punto 7) atribuye la «normalización y
traducción de programas» a `ProfileNormalizer.normalize()`, que en realidad normaliza un lexema (espacios,
mayúsculas y tildes) y no traduce programas.

### 4.6 Base de conocimiento como especificación proyectada

**[COMPROBADO]** La base de conocimiento publica secciones `esp-i-*` y `esp-o-*` que proyectan
`language-spec.md` para estudiantes, con marcadores (`{{lexema:…}}`, `{{diagnostico:…}}`) resueltos contra
el perfil activo. `tool/check_content.dart` comprueba que cada ejemplo analiza sin errores, que los
ejemplos bilingües producen el mismo árbol, que cada subsección tiene ejemplo de código (con una lista
de exenciones justificadas) y que los diagnósticos citados existen.

---

## 5. Mecanismos de verificación existentes

Son la semilla de un sistema de especificaciones ejecutables y conviene inventariarlos antes de
diseñarlo ([10 · Fundamentos](10-especificaciones-ejecutables-fundamentos.md)).

| Mecanismo                                           | Qué hace ejecutable                                           | Límite                                                             |
|-----------------------------------------------------|---------------------------------------------------------------|--------------------------------------------------------------------|
| `architecture.yaml` + test de capas + `check_limits` | Reglas de arquitectura declarativas, con caso negativo        | Solo estructura del código                                         |
| Tests de paridad multilingüe                        | Equivalencia de perfiles                                      | Casos escritos a mano                                             |
| Invariantes de la política de severidad             | Dos invariantes de una tabla de datos                         | Solo esa tabla                                                     |
| `check_content.dart`                                | Coherencia entre contenido publicado y motor                  | Vive en la app; no conoce las reglas de `language-spec.md` por ID |
| Columna «Proyectada en» de `language-spec.md`       | Trazabilidad sección → contenido publicado                     | Mantenida a mano                                                   |
| `execution_benchmark_test.dart` (`CIE-F2`)          | Presupuesto de tiempo por lote                                | Un solo programa, sin protocolo estadístico                       |
| Identificadores de reglas (`DOC-README-TRUTH`, …)   | Vocabulario estable para reportar                              | No enlazados a verificaciones por máquina                          |

---

## 6. Catálogo de hallazgos

Severidad: **alta** (afecta a la viabilidad de la visión o a una regla transversal), **media** (defecto
o deriva que un sistema de especificaciones debería impedir), **baja** (deriva documental sin efecto
funcional). La columna «Lección» indica qué parte del diseño futuro motiva.

| ID   | Hallazgo                                                                                                     | Evidencia                                                              | Sev.  | Lección                                         |
|------|--------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------|-------|-------------------------------------------------|
| H-01 | El `README.md` del núcleo declara 748 tests; hay 772                                                         | `dart test`; `README.md` del núcleo, línea 15                          | Baja  | Estado derivado debe generarse, no escribirse   |
| H-02 | La especificación (§13) dice que el motor «se niega a ejecutar cualquier programa que declare una clase»; el motor ejecuta orientación a objetos y `NotExecutableReason.containsClassDeclaration` no se usa | `language-spec.md:2203`; `execution_result.dart:5`; tests `oop_*`; sonda I | Media | Una especificación no ejecutable envejece en silencio |
| H-03 | La especificación marca los grupos de subprogramas y objetos como «a la espera de aprobación» mientras la tabla de estado dice «Especificado» | `language-spec.md:245-249, 588` frente a la tabla de estado | Baja  | El estado de cada regla debe ser un dato         |
| H-04 | La especificación (§2.7) describe perfiles declarados por una institución; el `README.md` del núcleo (§1.3) los excluye | `language-spec.md:412`; `README.md` del núcleo, §1.3 | Media | Conflicto entre fuentes del mismo nivel sin detector |
| H-05 | Regla 1.3.7 («el parser siempre devuelve un árbol») incumplida con texto vacío                               | Sonda C3                                                               | Baja  | Cada regla necesita su caso ejecutable          |
| H-06 | Regla 1.3.3 («como máximo un diagnóstico sintáctico por sentencia») incumplida: `Escribir 1 +` produce dos diagnósticos idénticos | Sonda C2                                                  | Media | Ídem; los casos límite están en prosa           |
| H-07 | El `README.md` del núcleo describe `ExecutionResult` con cuatro variantes, `StepOutcome(stepped, …)` y `ProgramRunner.run()`; el código expone `ExecutionStartResult(ExecutionReady, ExecutionNotExecutable)`, `StepAdvanced/StepAwaitingInput/StepHalted/StepFinished` y `runToCompletion` | `README.md` del núcleo §1.4 y §5.5; código | Media | La superficie pública debe extraerse, no copiarse |
| H-08 | `ProgramRunner.runToCompletion` deja escapar `StateError`                                                   | `program_runner.dart:21`; sonda D                                      | Media | Viola `AGENTS.md` §5; nadie lo detecta mecánicamente |
| H-09 | Un tamaño de arreglo enorme hace escapar `OutOfMemoryError`; la especificación no fija límite                | Sonda F; `array_storage.dart:8`                                        | Media | Límites de recursos deben especificarse         |
| H-10 | Las instantáneas no incluyen arreglos y las de objetos son referencias vivas                                 | `snapshot_builder.dart:14`; sonda B                                    | Alta  | El contrato de observación no está especificado |
| H-11 | El `README.md` de la app promete visualizar matrices                                                         | `apps/pseudolearn_app/README.md:93`                                    | Baja  | Consecuencia de H-10                            |
| H-12 | Coste de observación de 1,3× a 4,6×                                                                         | Anexo A, §A.3.1                                                        | Media | La observación tiene que ser un modo, no un impuesto |
| H-13 | Intérprete ≈500×–1900× más lento que Dart AOT en micro-benchmarks                                            | Anexo A, §A.3.1                                                        | Alta  | La aspiración de rendimiento exige otro motor   |
| H-14 | Tope de 10 000 micro-pasos en la app, también al ejecutar hasta el final                                     | `step_batch_runner.dart:7`                                             | Alta  | Ejecutar y observar son necesidades distintas   |
| H-15 | Límite de recursión de 1 000 marcos fijado por el lenguaje (justificado por el valor por omisión de Python)  | `language-spec.md` §10.8; `interpreter.dart:39`                        | Media | Decisiones pedagógicas a revisar para propósito general |
| H-16 | Toda la aritmética entera usa `BigInt`                                                                       | `pseudo_integer.dart`                                                  | Media | Determinismo y rendimiento deben conciliarse por objetivo |
| H-17 | El autocompletado es una lista fija, sin contexto, con marcadores en español en el perfil inglés              | `profile_completion_source.dart`                                       | Alta  | Herramientas a reconstruir sobre un servicio de lenguaje |
| H-18 | La plantilla de selección múltiple genera código inválido y su test no lo detecta                            | Sonda G                                                                | Media | Una plantilla es una afirmación sobre la gramática |
| H-19 | El lexer descarta comentarios                                                                                | Pendiente declarado; código del lexer                                  | Media | Formateo, migración y LSP exigen árbol sin pérdida |
| H-20 | `NodeId` no es estable entre ediciones                                                                       | `node_id.dart`                                                         | Media | Identidad de nodo para herramientas incrementales |
| H-21 | Análisis completo en cada edición: ≈50 ms a 5 000 líneas                                                     | Anexo A, §A.4.1                                                        | Media | Análisis incremental                            |
| H-22 | `y`, `o`, `no` (español) y `step`, `to`, `do` (inglés) no pueden ser identificadores                         | Sondas A y A2                                                          | Alta  | Presupuesto de palabras reservadas              |
| H-23 | Un `ñ` escrito en forma descompuesta (NFD) es un error léxico, con cascada de diagnósticos                  | Sonda H                                                                | Media | Normalización Unicode de identificadores        |
| H-24 | El perfil estricto no admite `ñ` ni tildes en identificadores                                               | Sonda H2; `language-spec.md` §2.5                                      | Media | Tensión con una identidad que nace en español   |
| H-25 | La traza muestra lógicos como `true/false` y reales con la representación de Dart en el perfil español      | `watch_row_projection.dart:45`                                         | Baja  | La representación textual debe tener un solo dueño |
| H-26 | La app usa siempre la variante flexible del perfil                                                          | `profile_catalog.dart:10-11`; pendiente declarado                      | Baja  | —                                               |
| H-27 | El test de objetivos de compilación ejecuta el nativo, pero de JavaScript y Wasm solo comprueba que compilan | `test/compilation/compilation_targets_test.dart`                       | Media | La paridad entre objetivos no está verificada   |
| H-28 | El `README.md` del núcleo atribuye la traducción de programas a `ProfileNormalizer`; el impresor vive en la app | `README.md` del núcleo:117; `engine/printing/`                       | Baja  | Responsabilidades del futuro formateador        |
| H-29 | Hay varias fuentes de verdad paralelas: `language-spec.md`, `README.md`, proyecciones `esp-*`, `fundamentos-visuales.md` (fuera del `README.md`), y un `README.md` web con insignias contra §6.2 del raíz | Lectura | Media | La regla de fuente única ya tiene excepciones   |
| H-30 | El criterio de desempate de la skill `language-spec-authoring` («la forma que prepara mejor para el lenguaje real… para que el salto siguiente sea corto») presupone que PseudoLearn no es el destino | `.agents/skills/language-spec-authoring/SKILL.md` | Alta | Ver [C-01](17-riesgos-preguntas-y-decisiones.md#c-01) |
| H-31 | La skill `package-docs` prohíbe carpetas de decisiones fuera del `README.md` y la «arqueología de versiones» | `.agents/skills/package-docs/SKILL.md`, reglas 3 y 4 | Alta | Ver [C-02](17-riesgos-preguntas-y-decisiones.md#c-02) |
| H-32 | La gramática formal (§14) está pendiente: no hay gramática legible por máquina                               | `language-spec.md` §14                                                 | Alta  | Base de generadores (resaltado, plantillas, parser de editor) |
| H-33 | No hay CI que ejecute verificadores                                                                          | `.github/workflows/`                                                   | Media | Sin ejecución continua, ninguna especificación es «ejecutable» en la práctica |
| H-34 | No existe valor nulo; las estructuras recursivas usan banderas (`tieneSiguiente`) como sustituto             | `test/integration/oop_recursive_data_structure_test.dart`              | Media | Falta un tipo opcional para propósito general   |
| H-35 | Los ciclos de referencias entre objetos son expresables y se ejecutan                                         | Sonda I                                                                | Alta  | Descarta el conteo de referencias sin detección de ciclos ([09](09-gestion-de-memoria.md)) |
| H-36 | Las variables declaradas dentro de bloques viven en todo el subprograma (no hay ámbitos de bloque)           | `language-spec.md` §6.1; `README.md` del núcleo §4.8                   | Alta  | Condiciona la semántica de captura de closures ([04](04-filosofia-y-modelo-del-lenguaje.md#closures)) |
| H-37 | La especificación exige una advertencia al modificar la variable de control de un bucle contado (§8.5; clase C en §12.10); no existe código de diagnóstico ni se emite | Sonda: `Para i <- 1 Hasta 3 Hacer` · `i <- i + 1` no produce ningún diagnóstico; `diagnostic_code.dart` sin código equivalente | Media | Una regla sin caso ejecutable puede no haberse implementado nunca |

---

## 7. Exclusiones vigentes, registradas como antecedentes

Estas exclusiones son **decisiones vigentes** del alcance actual. La investigación estudia su
evolución; no las levanta.

| Exclusión vigente (fuente)                                           | Razón declarada                                         | Relación con la visión                                                           |
|----------------------------------------------------------------------|---------------------------------------------------------|----------------------------------------------------------------------------------|
| Herencia múltiple, interfaces, clases abstractas (núcleo §1.3)        | Claridad conceptual                                    | Interfaces son exigidas por la visión ([04](04-filosofia-y-modelo-del-lenguaje.md)) |
| Métodos estáticos y sobrecarga (núcleo §1.3)                          | Firma unívoca                                          | La sobrecarga puede seguir excluida; lo estático tiene alternativas en módulos   |
| Genéricos y sobrecarga de operadores (núcleo §1.3)                    | Explosión del sistema de tipos                         | Colecciones tipadas exigen genéricos o equivalente                               |
| Excepciones de usuario (núcleo §1.3)                                  | Precondiciones y estados tipados                        | Coherente con errores como valores; ver [04](04-filosofia-y-modelo-del-lenguaje.md#errores) |
| Visibilidad protegida (núcleo §1.3)                                   | Encapsulación canónica                                 | Puede mantenerse                                                                 |
| Constantes con nombre (núcleo §1.3)                                   | Expresiones constantes solo con literales               | Imprescindibles en propósito general                                             |
| Apuntadores, enumerados, tuplas, subrangos, archivos (núcleo §1.3)    | Alcance didáctico                                       | Enumerados y registros son prioritarios; apuntadores no                          |
| `Interrumpir`, `Continuar`, `Ir A` (núcleo §1.3)                      | Programación estructurada                              | Decisión a revisar con evidencia ([04](04-filosofia-y-modelo-del-lenguaje.md))  |
| Perfiles personalizados (núcleo §1.3)                                 | Colisiones, fragmentación, herramientas                | Se mantiene; refuerza un vocabulario cerrado bilingüe                            |
| Concurrencia, `Isolate`, E/S del sistema (núcleo §1.3)                 | Pureza y determinismo del núcleo                        | Un lenguaje de propósito general necesita E/S y concurrencia **en sus programas**, no necesariamente en su analizador |
| Ejecución reversible (app §1.3)                                       | No implementada                                         | El determinismo la hace barata ([06](06-ejecucion-pedagogica-y-app.md))         |
| IA integrada (app §1.3)                                               | Fuera de alcance                                        | Coherente con separar autocompletado determinista de sugerencias ([07](07-herramientas-y-autocompletado.md)) |
| Compilar y ejecutar el código traducido a Python o Rust (app §1.3)     | Fuera de alcance                                        | Distinto de compilar PseudoLearn a nativo                                        |
| Orquestador de monorepo y CI (raíz §1.3)                              | Sin problema que resolver con cinco miembros            | Un ecosistema de lenguaje lo vuelve necesario ([08](08-modulos-paquetes-y-monorepos.md)) |

---

## 8. Balance: qué se hereda y qué no

**Activos que la evolución debería conservar** (por evidencia, no por inercia):

1. El modelo de dos planos con pivote no lingüístico (tipo de token y función incorporada abstracta).
   Es raro en la industria, tiene precedente histórico (ALGOL 68) y está verificado por paridad.
2. Los diagnósticos estructurados independientes del idioma, con clases de severidad.
3. El determinismo del camino crítico (sin reloj, aleatoriedad sembrada), que abarata la reproducción
   y la depuración por reejecución ([06](06-ejecucion-pedagogica-y-app.md)).
4. La disciplina de arquitectura verificada con casos negativos.
5. El AST sellado con recorrido exhaustivo, que obliga a cada consumidor a tratar cada nodo nuevo.
6. La máquina de tareas no recursiva como **oráculo observable**: lenta, pero cada micro-paso es
   inspeccionable y suspendible.

**Pasivos que la evolución tiene que resolver**:

1. Ausencia de un contrato ejecutable entre especificación, implementación y documentación (H-01 a H-07,
   H-18, H-27, H-29).
2. Un motor cuyo coste por operación está tres órdenes de magnitud por encima del nativo (H-13, H-16).
3. Una observación sin contrato: qué se ve, cuánto cuesta y qué se pierde (H-10, H-12, H-25).
4. Herramientas de edición sin servicio de lenguaje (H-17 a H-21, H-32).
5. Decisiones pedagógicas que, sin revisión, chocan con propósito general (H-15, H-22, H-24, H-34, H-36).
