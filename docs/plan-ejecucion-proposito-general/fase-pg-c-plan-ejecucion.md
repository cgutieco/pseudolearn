# Fase PG-C · Pseudocódigo clásico ejecutable — plan de ejecución

## 0. Metadatos y contrato de ejecución

- Fase: PG-C (§4.16 del [plan general](plan-ejecucion-proposito-general.md)). Origen: decisión de la persona del
  2026-11-05 registrada en las «Decisiones posteriores» del plan general y
  [propuesta del 2026-11-05](propuesta-pseudocodigo-clasico.md). Donde la propuesta y este plan difieran, **manda este
  plan**: la propuesta dejaba abiertas D-C6 (`;`) y D-C10 (base de índices), ya resueltas (`;` obligatorio, base 0).
- Fecha de redacción: 2026-11-05, America/Lima. Revisión Git inspeccionada: `052a4c1e`, rama
  `feature/agregar-ruta-de-especificacion`. El árbol **no estaba limpio**: otro agente tenía cambios sin commit en
  `apps/pseudolearn_cli/*`, `packages/pseudolearn_engine/crates/pseudolearn_service/*`,
  `packages/pseudolearn_spec/crates/see_cli/*`, `packages/pseudolearn_spec/crates/see_conformance/*` y
  `packages/pseudolearn_spec/specifications/tool/tool.service.hover.md` (ver `PC-P-03`).
- Autorización de la persona: **concedida** el 2026-11-05 por mensaje directo que pidió implementar este plan en una sola
  iteración (`PG-C.C01`, `C02`); ejecución registrada en §11.
- Dependencias según §3 del plan general: PG-B (cerrada), PG-L y PG-S (implementadas, sin cierre formal). PG-C no cierra
  ni reabre PG-L ni PG-S (`PC-P-02`).
- **Modo de ejecución: una sola iteración, implementación rápida y pruebas pesadas al final.** Los bloques `PG-C.00` a
  `PG-C.11` son de implementación y solo usan comprobaciones acotadas de nivel D (§7.4). **Todas** las pruebas pesadas
  (suites completas del motor, del runtime, de la app, de la extensión, `cargo xtask verify`, conformidad completa,
  rendimiento y el monorepo) se concentran en el bloque final `PG-C.12`, seguido de un ciclo de corrección. Ningún
  bloque intermedio detiene la ejecución salvo las paradas de §10.3.
- **Disco:** liberar espacio está autorizado por la persona cuando haga falta, con las reglas de §0.2.
- Documento transitorio: ninguna especificación, README ni código fuera de `docs/` puede citarlo
  (`DOC-NO-TRANSIENT-REFS`). Cada decisión de §3 se traslada a su dueño (corpus o README del miembro) **en el mismo
  cambio** que la implementa (`DOC-README-TRUTH`, `DOC-NO-ORPHAN-DECISION`).

### 0.1 Reglas para quien ejecute (anti-alucinación)

Obligatorias. Ante la duda entre una regla de esta lista y la comodidad, gana la regla.

1. **Tres clases de afirmación, siempre rotuladas.** **Comprobado** (`PC-H-nn`: visto en `052a4c1e`, con ruta),
   **Hipótesis** (`PC-V-nn`: nadie lo comprobó; trae la orden que lo confirma) y **Propuesta** (`CANDIDATA`: nombre,
   código de diagnóstico, argumento o texto que el corpus todavía no fija). La primera tarea que consume una hipótesis
   la verifica y anota el resultado en §11.1. Una `CANDIDATA` se puede cambiar al redactar la especificación si choca
   con una convención existente del corpus; el cambio se anota en §11.3.
2. **Nada existe hasta que se crea.** Ningún archivo, función, tipo, regla, diagnóstico o ID marcado como «nuevo» o
   `CANDIDATA` existe. Antes de editar un archivo, leerlo entero; antes de usar un símbolo, buscarlo con `grep -rn` en el
   árbol actual. Prohibido inventar firmas del motor: si una tarea necesita una función que no existe, se crea en el
   archivo dueño que dicta §5.
3. **HEAD cambiado.** Si `git rev-parse --short HEAD` no es `052a4c1e`, ejecutar `git diff --stat 052a4c1e..HEAD`,
   repetir las comprobaciones de §1.2 afectadas y anotar las diferencias en §11.
4. **Secuencia obligatoria por punto:** especificación → casos con esperado **derivado de la regla** → tests dirigidos
   que fallan por ausencia → código → README y reglas → comprobación de nivel D (`SPEC-FIRST`,
   `SPEC-INDEPENDENT-ORACLE`). Prohibido copiar al esperado de un caso la salida del motor. Si el motor discrepa de un
   caso, se revisa primero la derivación desde la regla; solo si es correcta se corrige el motor.
5. **Congelamiento (`SPEC-VERSION-FREEZE`).** Las identidades existentes conservan estado `estable` y versión `1.0.0`;
   su texto se edita sobre la misma identidad, sin campo `cambio`, y se reancla con `see lock --refresh` listando **en
   una sola orden** todos los IDs editados. Las identidades nuevas nacen `estable` `1.0.0` sin `cambio`. No se borran
   reglas: se reescriben. Un caso cuyo esperado contradice la regla nueva se reescribe con el esperado derivado y se anota
   en §11.2.
6. **Generados (`GEN-NO-HAND-COPY`).** `specifications/export.json`, lo que los `build.rs` generan en `OUT_DIR`,
   `apps/pseudolearn_vscode/media/pseudolearn.tmLanguage.json` y cualquier archivo con origen de generador **jamás** se
   editan a mano: se regeneran con la orden del README del miembro.
7. **Edición quirúrgica.** Prohibidos los formateadores masivos sobre archivos existentes (`dart format` sobre
   directorios, `cargo fmt --all`, *round-trip* de JSON con `json.load`/`json.dump`). `cases/catalogs.json`
   (≈ 30 000 líneas) y `diag/diag.catalog.md` se editan solo en los bloques afectados. Una sustitución textual con
   `sed` está permitida cuando cambia exactamente el texto buscado y nada más (§4, `PG-C.10`). `rustfmt` solo sobre los
   `.rs` tocados.
8. **Procesos largos.** Lo que pueda pasar de dos minutos se lanza en segundo plano y se espera su notificación. Sin
   bucles de sondeo. No se confía en el código de salida de una tubería con `| tail`: la salida va a un archivo de
   registro y se lee el código de salida real.
9. **Contradicción entre fuentes.** Se reporta con ID, texto y alcance (`CONFLICT-REPORT`), se registra en §11.3 y se
   sigue con lo no afectado. Los conflictos ya conocidos están en §9.2.
10. **Alcance cerrado (`SCOPE-YAGNI`).** Solo se implementa lo de `PG-C.01`–`PG-C.11` con las decisiones de §3. Fuera de
    alcance, aunque sea «clásico»: `;` opcional (rechazado por la persona), índices base 1 (rechazado), parámetros sin
    tipo en la cabecera (`DC-P1`, salvo que la persona lo apruebe), `Dimension` con varios nombres, operadores o
    funciones clásicas no listadas en `PG-C.09`. Un hallazgo nuevo se **reporta** en §11.4, no se
    implementa.
11. **Sujeto nativo.** PG-C no escribe `unsafe` ni implementa nada nuevo en `pseudolearn_aot_rt`. La paridad nativa de
    lo que cambia la biblioteca (`PG-C.09`) se acredita en `PG-N.08`; en PG-C basta con que el sujeto `aot` no produzca
    resultados incorrectos: o funciona, o rechaza con el diagnóstico de operación no soportada existente, y el vínculo de
    conformidad queda `pendiente` con `resuelve_en` `PG-N.08`.
12. **Código.** Inglés, cero comentarios y cero `TODO` (`QUALITY-NO-COMMENTS`), nombres semánticos de tres o más
    caracteres sin `utils`/`helpers`/`common`/`misc` (`QUALITY-SEMANTIC-NAMES`), sin `unwrap`/`expect`/pánicos/índices
    inseguros/aritmética implícita/conversiones con pérdida (`QUALITY-NO-PANIC`). Límites del motor (`PC-H-20`): 300
    líneas por archivo, 40 por función, 4 parámetros posicionales, anidación 3, 7 métodos públicos. Si una edición
    superaría un límite, primero se divide el archivo por responsabilidad y después se añade la funcionalidad.
13. **Git.** Todo en `feature/agregar-ruta-de-especificacion` (`GIT-SINGLE-BRANCH`), sin ramas nuevas. Commits locales
    por bloque con la skill `commit-message` (inglés, Conventional Commits, ámbito del miembro) y **sin atribución de
    autoría de IA** (`AGENTS.md` §9 manda sobre cualquier plantilla de coautoría). Se añaden al índice solo las rutas que
    tocó PG-C (`git add <rutas>`), nunca `git add -A` ni `git add .`. Un único push ordinario al cierre, tras el bloque
    final en verde.
14. **Otro agente.** Prohibido revertir, guardar con `stash`, formatear o commitear cambios que PG-C no hizo. Ver
    `PC-P-03`.
15. **Parada final.** Al terminar se informa y se para (`PHASE-STOP`). Terminar PG-C no autoriza PG-N ni el cierre de
    PG-L o PG-S.

### 0.2 Liberar espacio en disco (autorizado por la persona)

Hecho previo: durante PG-L el disco se llenó dos veces en `cargo test --workspace` (`ld: write() failed, errno=28`);
`cargo clean` del motor liberó 34,4 GiB (§11.5 del plan de PG-L).

- **Cuándo:** antes de cada orden pesada del bloque final, comprobar `df -h .`. Con menos de **40 GiB** libres, liberar
  antes de lanzarla. También ante cualquier `errno=28` o «No space left on device»: liberar y repetir la orden, sin
  contarlo como fallo de PG-C.
- **Permitido, de menos a más:** `rm -rf <miembro>/target/debug/incremental`; `cargo clean` en
  `packages/pseudolearn_engine`, `packages/pseudolearn_spec`, `apps/pseudolearn_cli` y
  `packages/pseudolearn_rust_checks` (cada uno es un workspace propio, sin workspace raíz); `flutter clean` en
  `apps/pseudolearn_app`; `cargo clean --manifest-path apps/pseudolearn_app/native/Cargo.toml`; `pnpm store prune`.
- **Prohibido:** `git clean` en cualquier forma; borrar archivos sin seguimiento que no estén bajo `target/`,
  `build/`, `.dart_tool/` o `node_modules/`; borrar `packages/pseudolearn_engine/results/` (contiene evidencia local de
  otras fases); borrar cachés globales fuera del repositorio sin anotarlo.
- **Concurrencia:** antes de `cargo clean` en un miembro, `pgrep -fl "cargo|rustc"` no debe mostrar compilaciones de ese
  miembro (podría ser el otro agente). Si las hay, limpiar solo `incremental` o esperar.
- Cada limpieza se anota en §11 con orden y espacio liberado.

## 1. Punto de partida comprobado

Rutas relativas a la raíz del repositorio. «Corpus» = `packages/pseudolearn_spec/specifications/`. «Motor» =
`packages/pseudolearn_engine/`. «Semantic» = `packages/pseudolearn_engine/crates/pseudolearn_semantic/src/`. Lo de
§1.2 se leyó en `052a4c1e`; para redactar el plan solo se ejecutó `pseudo comprobar` y `pseudo ejecutar` sobre programas
de sondeo, nunca una suite.

### 1.1 Dependencias y puertas previas

| ID | Evidencia | Tratamiento exigido |
|---|---|---|
| PC-P-01 | §6 del plan general: PG-C sin iniciar, plan redactado | La persona revisa este plan (`C02`) y autoriza `C01` en un mensaje nuevo |
| PC-P-02 | PG-L «Implementada, pendiente de push y cierre»; PG-S «sin cierre formal» (C10–C13) | PG-C no cierra ni reabre ninguna. Antes de editar un README, `git log -3 -- <README>` para no pisar texto de esas fases |
| PC-P-03 | Árbol sucio en `052a4c1e` por otro agente (lista en §0) | Tarea `PG-C.00.02`: si `git status --short` muestra cambios que PG-C no hizo en archivos que PG-C debe tocar, **parar y preguntar** a la persona (§10.3). Si los cambios ajenos están en archivos que PG-C no toca, seguir sin tocarlos |
| PC-P-04 | Línea base de pruebas en `052a4c1e` desconocida | No se mide al inicio (velocidad); los fallos del bloque final se clasifican contra `052a4c1e` en `PG-C.12.08` |

### 1.2 Hechos comprobados

**Corpus: reglas vigentes que PG-C reescribe**

- `PC-H-01` `lang/lang.decl.variable.md` R1: «`Definir nombre Como tipo <- expresión` declara un vínculo local
  individual, inmutable y con inicializador obligatorio. `Definir Mutable` permite reasignarlo […] las declaraciones
  locales no crean ámbitos de bloque […] Reasignar un vínculo inmutable, usarlo como destino de `Leer` o pasarlo por
  referencia para modificarlo es `immutableBindingAssignment` […] Un mutable sin modificación recibe
  `mutableBindingNeverModified`». Casos C1–C8.
- `PC-H-02` `lang/lang.decl.uninitialized.md` R1: «omitirlo es `missingBindingInitializer`, error […]
  `bindingReadsOwnInitializer` […] No se inventan valores por defecto. Los campos y elementos de arreglo […] conservan la
  trampa `uninitializedVariableRead`. No hay migrador ni modo de compatibilidad […] Un vínculo declarado dentro de un
  bloque deja de existir al terminarlo […] `bindingOutsideScope`». Casos C1–C4 (C1 y C2 tienen el mismo programa).
- `PC-H-03` `lang/lang.types.inference.md` R1 cierra con «la forma oficial usa `Definir` con tipo e inicializador y
  `Mutable` cuando el vínculo se reasigna».
- `PC-H-04` `lang/lang.types.function.md`: «La clausura copia solo los vínculos inmutables que utiliza […] Capturar un
  vínculo mutable o prestado se rechaza con `mutableClosureCapture` […] un parámetro mutable se copia antes a un vínculo
  inmutable para capturarlo».
- `PC-H-05` `lang/lang.subprogram.scope.md` R1: cada rama de `Si` y `Segun` y cada cuerpo de `Mientras`, `Para` y
  `Repetir` introduce un ámbito léxico. **Contradice** la frase de `PC-H-01` sobre ámbitos de bloque (`PC-C-01`).
- `PC-H-06` `lang/lang.control.for.md`: «la cláusula Con Paso es obligatoria». El parser ya la acepta ausente: el
  diagnóstico `missingStepClause` lo emite Semantic en `for_checker.rs:47-48` cuando `bounds.get(2)` está vacío.
- `PC-H-07` `lang/lang.types.relations.md` R1: «Se admite entero a real por ampliación y subclase a superclase […] No se
  convierten implícitamente real a entero, lógico a número, cadena a carácter ni primitivos a texto». No menciona
  carácter a cadena. `lang/lang.lexical.text-literal.md` R1: un literal de exactamente un punto de código es carácter.
- `PC-H-08` `lang/lang.array.dimension.md` R1: «`Dimension` declara nombre, dimensiones y tipo en una sola sentencia».
- `PC-H-09` `lang/lang.subprogram.declaration.md` R1: «`SubProceso` exige nombre y paréntesis […]». El vocabulario
  (`lang/lang.profile.vocabulary.md`, líneas ≈ 417–490) ya tiene `Funcion` y `FinFuncion` como alias de `SubProceso` y
  `FinSubProceso`. `lang/lang.subprogram.return.md` R1: un camino que alcanza el cierre sin retornar es fallo de
  ejecución.
- `PC-H-10` Biblioteca, `lib/lib.model.md` D1 (funciones con campo `alias`): `random` = es `azar` (alias `aleatorio`),
  en `random` (alias `rand`), sin parámetros, retorno `real`; `lib/lib.core.random.md`: «azar no recibe argumentos y
  produce real en [0,1) […] fuente inyectada con semilla». `substring` = `Subcadena(string, integer, integer)`, y
  `lib/lib.core.text.md`: «Subcadena usa inicio desde cero y cantidad». `textToReal` = `AReal(string) → real`;
  `lib/lib.core.conversion.md`: texto inválido produce `stringToNumberConversionFailed`. `toText` = `ATexto` con alias
  `ConvertirATexto`. D2 (operaciones, **sin** campo `alias`): `text_to_upper` = es `AMayusculas`, en `toUpper`;
  `text_to_lower` = es `AMinusculas`, en `toLower`. No existen `Mayusculas`, `Minusculas`, `Concatenar` ni
  `ConvertirANumero`. Los nombres de PG-S.01 los confirmó la persona el 2026-11-05.
- `PC-H-11` Las fichas de ayuda viven en el recurso `helpCatalog` de `tool/tool.service.catalog.md`; la ficha de
  declaración enumera `mutableKeyword` (líneas ≈ 928 y 992, texto «Permite reasignar el vínculo.»). Los textos de los
  diagnósticos viven en `cases/catalogs.json` (p. ej. línea ≈ 3430: «El vínculo es inmutable; usa Definir Mutable para
  reasignarlo»; ≈ 4043 `Mutable binding is never modified`; ≈ 8354; ≈ 30427). Las entradas de un caso se declaran con
  el campo `entradas` (ver `lang/lang.io.input.md`, líneas 69 y 99).
- `PC-H-12` Otros archivos del corpus que nombran `mutableKeyword`, `mutableBindingNeverModified` o
  `mutableClosureCapture`: `api/api.program.view.md`, `cases/catalogs.json`, `cases/vocabulary.json`,
  `diag/diag.catalog.md`, `lang/lang.decl.variable.md`, `lang/lang.profile.vocabulary.md`,
  `lang/lang.syntax.grammar.md`, `lang/lang.types.function.md`, `tool/tool.service.catalog.md`. Usan
  `immutableBindingAssignment`: `diag/diag.catalog.md`, `lang/lang.decl.variable.md`, `lang/lang.types.variant.md`. Usan
  `missingBindingInitializer`: `diag/diag.severity.policy.md`, `lang/lang.types.record.md`, `diag/diag.catalog.md`,
  `lang/lang.decl.uninitialized.md`, `lang/lang.types.enum.md`. El código `variableUsedUninitialized` ya existe en
  `diag/diag.catalog.md`.
- `PC-H-13` Huella: `git grep "Mutable"` fuera de `docs/`, `target/` y `node_modules/` da 636 apariciones en 309
  archivos: `apps/pseudolearn_app` 164 (125 en `assets/knowledge`, 33 en `test`, 1 en `lib`:
  `lib/engine/execution/task_structure_projection.dart`), `packages/pseudolearn_spec` 66 (270 programas con
  `Definir Mutable` en el corpus, 1 en `fixtures/spanish-neutrality/specifications/fixture-1.md`), motor 60,
  `apps/pseudolearn_vscode` 8, `apps/pseudolearn_cli` 7, `packages/pseudolearn_benchmarks` 4 (incluye
  `tool/data/r5-vm-workloads.json`). El generador de programas `packages/pseudolearn_spec/crates/see_generators/src/program.rs`
  y su test emiten `Mutable`.

**Motor**

- `PC-H-14` `pseudolearn_syntax/src/declaration_parser.rs::declaration`: avanza `Definir`, consume opcionalmente
  `KeywordKind::MutableKeyword`, exige **un** nombre, `TypeConnector`, tipo y `<- expresión`; si falta el inicializador
  emite `MissingBindingInitializer` y aborta. La función hermana `field` del mismo archivo ya analiza listas de nombres
  separadas por comas.
- `PC-H-15` `HirLocal::mutable` (`hir.rs:26`) solo lo leen `binding_checker.rs:73` (`ImmutableBindingAssignment`),
  `capture_analysis.rs:17` (`MutableClosureCapture`, que también rechaza `Passing::Reference`) y `usage.rs:79`
  (`mutable_warning` → `MutableBindingNeverModified`). Lo escriben `local_registry.rs` (`mutable_declaration`),
  `record_locals.rs`, `closure_locals.rs`, `task_bindings.rs`, `variant_bindings.rs`, `inspection_expression.rs` y
  `name_resolution.rs:100`. **Ningún** archivo de `pseudolearn_lowering`, `pseudolearn_ir`, `pseudolearn_bytecode`,
  `pseudolearn_vm`, `pseudolearn_codegen` ni `pseudolearn_abi` lo consulta.
- `PC-H-16` Inicialización hoy: `session.initialized: Vec<bool>` (`session.rs:50`); `name_resolution.rs:69-72` emite
  `VariableUsedUninitialized`; `binding_checker.rs::replace_self_read` lo convierte en `BindingReadsOwnInitializer`. Las
  restauraciones en `switch_checker.rs`, `for_checker.rs` (`check_body`) y `flow_bindings.rs` son conservadoras: lo
  asignado dentro de una rama o cuerpo no cuenta después. `result_obligations.rs` (`pending_results`) es un análisis por
  caminos ya existente que sirve de precedente de estilo.
- `PC-H-17` HIR: `statement_model.rs` define `HirStatement` con `Declare(Vec<LocalId>)`, `Assign`, `Conditional`,
  `While`, `Repeat`, `For`, `ForEach`, `Switch`, `VariantMatch`, `Select`, `TaskScope`, `Spawn`, `Defer`, `Break`,
  `Read(Vec<HirPlace>)`, `Call`, `Return(Option<ExpressionId>)`, `Write`, `Dimension`; `StatementColumns` guarda un
  `Span` por sentencia. `HirExpression::Uninitialized(LocalId)` existe (`expression_model.rs:63`) y lo produce
  `hir_finalization.rs:33`.
- `PC-H-18` Lowering: `statements_declare.rs::lower_declare` ya baja `HirStatement::Declare` (locales sin valor), con
  celda si el local se pasa por referencia o se toma su dirección, y valor en otro caso. `HirExpression::Uninitialized`
  se baja como lectura de local (`expressions.rs:133`). El bucle contado está en `statements_for.rs` y
  `statements_for_condition.rs`.
- `PC-H-19` `pseudolearn_lexicon/build.rs` genera `generated_lexicon.rs` desde `specifications/export.json`
  (`resources.vocabulary` y `resources.functions`): quitar `mutableKeyword` del vocabulario elimina
  `KeywordKind::MutableKeyword` en la siguiente compilación. Las operaciones D2 se resuelven en
  `pseudolearn_library/src/local_operations.rs` (`"text_to_upper" => …`).
- `PC-H-20` `packages/pseudolearn_engine/architecture.yaml` líneas 197–198: `file_lines: 300`, `function_lines: 40`.
  Semantic tiene 165 archivos en `src/` y 38 en `tests/`.

**Comportamiento observado con `apps/pseudolearn_cli/target/debug/pseudo` del 2026-11-05**

- `PC-H-21` Sondeos de una línea dentro de `Algoritmo T … FinAlgoritmo`:

| Programa | Resultado |
|---|---|
| `Definir n, i Como Entero` | `expectedTypeConnector` |
| `Definir x Como Real` (sin valor) | `missingBindingInitializer` |
| `Definir n Como Entero <- 0; Leer n;` | `immutableBindingAssignment` |
| `Para i <- 1 Hasta 3 Hacer … FinPara` | `missingStepClause` |
| acumulador `v <- v + i` | `immutableBindingAssignment` |
| `Definir c Como Cadena <- "b";` | `incompatibleTypesInAssignment` («no se puede asignar Caracter a Cadena») |
| `Dimension notas[10]` tras `Definir notas Como Real` | `expectedTypeConnector` |
| `Funcion r <- doble(x)` | `expectedSubroutineLeftParenthesis` |
| `Azar(3)`, `Aleatorio(1,3)` | `argumentCountMismatch` (se esperaban 0) |
| `Mayusculas("a")`, `Minusculas`, `Concatenar`, `ConvertirANumero` | `undeclaredSubroutine` |
| `Dimension a[3] Como Entero; a[3] <- 1;` | `arrayIndexOutOfRange` en ejecución (base 0, se conserva) |
| `Proceso`, `Segun … De Otro Modo`, `Repetir … Hasta Que`, `Mientras`, `SiNo`, `=`, `<>`, `&`, `\|`, `~`, `MOD`, `%`, `^`, `Sin Saltar`, `RC`, `trunc`, `Redon`, `Raiz`, `Ln`, `Exp`, `Sen`, `Subcadena`, `Longitud`, `ConvertirATexto` | Sin diagnóstico de forma |

### 1.3 Hipótesis por verificar (no usar como hecho)

| ID | Hipótesis | Orden o lectura que la resuelve | Tarea que la consume |
|---|---|---|---|
| PC-V-01 | `lower_declare` + SSA soportan un local sin valor que se asigna solo dentro de ramas y se lee después de la unión | Test dirigido `PG-C.02.05` con `Si … SiNo` que asigna en ambas ramas y escribe después | `PG-C.02.05` |
| PC-V-02 | Los bucles contados bajan correctamente con paso ausente si se le da 1 | Leer `statements_for.rs` y `statements_for_condition.rs`; buscar `bounds`/`step` | `PG-C.05.04` |
| PC-V-03 | Los casos del corpus aceptan un perfil único `es` | `grep -rn '"perfiles": \[' -A2 specifications/lang \| grep -B1 -A1 '"es"$'` y leer el esquema de casos en `schemas/` | `PG-C.11.01` |
| PC-V-04 | El esquema y el validador de D2 aceptan añadir un campo `alias` opcional | `grep -rn "receiver" packages/pseudolearn_spec/crates/*/src \| grep -i "operation"`; leer el esquema en `schemas/` | `PG-C.09.01` |
| PC-V-05 | El sujeto `aot` usa la tabla de funciones generada y un cambio de firma de `random` no rompe la compilación de `pseudolearn_aot_rt`/`pseudolearn_codegen` | `grep -rn "Random\|random" packages/pseudolearn_engine/crates/pseudolearn_codegen/src packages/pseudolearn_engine/crates/pseudolearn_aot_rt/src \| head` | `PG-C.09.05` |
| PC-V-06 | La gramática de la extensión se genera desde el corpus y no tiene `Mutable` escrito a mano | README de `apps/pseudolearn_vscode`, sección de gramática | `PG-C.10.06` |
| PC-V-07 | Los contenidos de `apps/pseudolearn_app/assets/knowledge` no llevan hashes ni manifiestos que haya que regenerar al cambiar su texto | Leer `assets/knowledge/manifest_es.json` y el README de la app | `PG-C.10.07` |
| PC-V-08 | Cambiar el texto de una carga de `packages/pseudolearn_benchmarks` invalida la comparación con líneas base guardadas | README de `packages/pseudolearn_benchmarks`, sección de datos | `PG-C.10.08` |
| PC-V-09 | Las reescrituras quitan columnas en casos con posiciones esperadas (completado, *hover*, navegación, análisis, vista de programa, mapa de fuentes, traza) | Lista de `PG-C.10.02` | `PG-C.10.02` |
| PC-V-10 | El generador `see_generators` usa semillas cuyos programas generados se guardan en resultados versionados | `grep -rn "Mutable" packages/pseudolearn_spec/crates/see_generators` y README de `see_generators` | `PG-C.10.05` |

## 2. Lectura realizada y lectura de entrada obligatoria

### 2.1 Fuentes consultadas para redactar este plan

`AGENTS.md`; plan general §3, §4.0, §4.13–§4.15, §5; plan de PG-L (estructura, reglas, bloque F, §11.5); propuesta del
2026-11-05; plan de PG-2 (D-PG2-01, D-PG2-08, D-PG2-09); `lib.model`, `lib.core.random`, `lib.core.text`,
`lib.core.conversion`, todas las reglas `LANG.DECL.*`, `LANG.TYPES.INFERENCE`, `LANG.TYPES.FUNCTION`,
`LANG.TYPES.RELATIONS`, `LANG.SUBPROGRAM.*`, `LANG.CONTROL.FOR`, `LANG.CONTROL.FOR-EACH`, `LANG.ARRAY.*`,
`LANG.IO.INPUT`, `LANG.STMT.*`, `LANG.PROFILE.VOCABULARY`; los archivos de motor citados en §1.2.

### 2.2 Antes del primer cambio (tarea `PG-C.00.01`)

Leer enteros: README raíz; README y `architecture.yaml` de `packages/pseudolearn_engine` y de cada crate que se toca
(`pseudolearn_lexicon`, `pseudolearn_syntax`, `pseudolearn_semantic`, `pseudolearn_lowering`, `pseudolearn_library`,
`pseudolearn_diagnostics`, `pseudolearn_service`, `pseudolearn_api`); README y reglas de `packages/pseudolearn_spec`,
`apps/pseudolearn_cli`, `apps/pseudolearn_vscode`, `apps/pseudolearn_app`, `packages/pseudolearn_benchmarks`; el
esquema de casos y de definiciones en `packages/pseudolearn_spec/schemas/`; y las especificaciones de §6.2 de este plan.
Registrar en §11 la revisión Git leída.

## 3. Decisiones de diseño

Todas confirmadas por la persona el 2026-11-05 («todas tus recomendaciones me gustan»; `;` y base 0 decididos aparte),
salvo las marcadas **Persona**. Cada decisión se traslada a su dueño en el mismo cambio que la implementa.

| ID | Decisión | Elección | Dueño | Reversión |
|---|---|---|---|---|
| DC-01 | Forma de `Definir` | `Definir n₁, …, nₖ Como T;` declara k locales sin valor. `<- expresión` opcional **solo con un nombre**; con varios es error `initializerWithMultipleNames` (`CANDIDATA`). Duplicados en la lista o en el ámbito, error como hoy | `LANG.DECL.VARIABLE`, README de syntax | La persona pide evaluar el inicializador por nombre |
| DC-02 | `Mutable` | Desaparece de ambos perfiles (`mutableKeyword` sale del vocabulario, de la gramática y de las fichas). `Mutable` pasa a ser un identificador ordinario. Sin alias ni diagnóstico de migración | `LANG.PROFILE.VOCABULARY`, `LANG.SYNTAX.GRAMMAR` | — |
| DC-03 | Mutabilidad | Todo local declarado con `Definir` y todo parámetro por valor se puede reasignar. Siguen sin poder reasignarse: la variable de control de `Para` (`controlVariableModified`), los vínculos de `Para Cada`, de patrones de variante y de tareas (`immutableBindingAssignment`, con mensaje nuevo sin «usa Definir Mutable»). Desaparece `mutableBindingNeverModified` | `LANG.DECL.VARIABLE`, `DIAG.CATALOG` | — |
| DC-04 | Dónde se implementa la asignación definitiva | **Pasada dedicada sobre el HIR** después de la comprobación de tipos, en archivos nuevos de Semantic (§5). Sustituye a la comprobación en línea de `initialized` para locales. Razones: el HIR ya tiene todas las construcciones y un `Span` por sentencia (`PC-H-17`); centraliza la lógica en vez de tocar cada verificador de control; y la necesitan también DC-06 y DC-07, que requieren el cuerpo completo | README de semantic | Si el HIR no conserva lo necesario para nombrar el camino, se extiende el vector `initialized` en línea con intersección de ramas |
| DC-05 | Reglas de la asignación definitiva | Ver §3.1. Error con el código existente `variableUsedUninitialized` (severidad error), origen relacionado en la declaración y, cuando la falta viene de una unión, segundo origen relacionado en la construcción que deja el camino sin valor, más un argumento `cause` (`CANDIDATA`) con valores `branchWithoutElse`, `branchWithoutAssignment`, `loopMayNotRun`, `switchWithoutDefault` (`CANDIDATA`). Mensajes es/en en `cases/catalogs.json`. `bindingReadsOwnInitializer` se conserva | `LANG.DECL.UNINITIALIZED`, `DIAG.CATALOG` | — |
| DC-06 | Parámetros de salida | Ver §3.2 | `LANG.SUBPROGRAM.BY-REFERENCE` | La persona prefiere exigir siempre argumento asignado |
| DC-07 | Constancia inferida y capturas | Ver §3.3. El código `mutableClosureCapture` se conserva; cambia su texto y su origen relacionado (la primera reasignación) | `LANG.TYPES.FUNCTION`, `LANG.SUBPROGRAM.SCOPE` | — |
| DC-08 | Ámbitos de bloque | Se elimina de `LANG.DECL.VARIABLE#R1` la frase «las declaraciones locales no crean ámbitos de bloque»; manda `LANG.SUBPROGRAM.SCOPE#R1` (resuelve `PC-C-01`) | `LANG.DECL.VARIABLE` | — |
| DC-09 | `Con Paso` | Opcional. Ausente equivale a `Con Paso 1`, también si inicial > final (el cuerpo no se ejecuta). `zeroStepInCountedLoop` y el resto de la regla no cambian. `missingStepClause` desaparece del catálogo | `LANG.CONTROL.FOR` | — |
| DC-10 | Carácter a cadena | Ampliación implícita `Caracter → Cadena` en todo contexto donde hoy se aplica `Entero → Real` (inicialización, asignación, argumento por valor, retorno, elemento de colección con tipo de contexto). Nunca por referencia (tipo exacto). Igual que la ampliación numérica, no cambia la comparación ni la concatenación | `LANG.TYPES.RELATIONS`, README de semantic | — |
| DC-11 | `Dimension` en dos pasos | `Dimension nombre[d₁, …];` sin `Como` se admite si `nombre` es un local declarado con `Definir` en el mismo ámbito, sin inicializador y sin ningún uso entre ambas sentencias. El local pasa a ser arreglo de elemento T y esas dimensiones; cuenta como asignado. Si no se cumple: `dimensionWithoutType` (`CANDIDATA`) con origen relacionado en la declaración. `Dimension nombre[…] Como T;` se conserva | `LANG.ARRAY.DIMENSION` | — |
| DC-12 | Función con variable de retorno | `Funcion r <- nombre(parámetros)` (es; en: `function r <- name(…)`, verificar alias en `PC-H-09`). El cuerpo debe declarar `r` con `Definir` (si no: `returnVariableNotDeclared`, `CANDIDATA`); el tipo de retorno es el de `r`. En cada fin normal del cuerpo y en cada `Retornar` sin expresión, `r` debe estar definitivamente asignada (DC-05, origen relacionado en la cabecera). `Retornar expresión` dentro de esta forma es `returnValueInReturnVariableFunction` (`CANDIDATA`). Semantic la desazucara: añade `Return(Some(Local r))` al final y convierte cada `Return(None)` en `Return(Some(Local r))`, de modo que Lowering no cambia | `LANG.SUBPROGRAM.DECLARATION`, `LANG.SUBPROGRAM.RETURN` | — |
| DC-13 | Biblioteca clásica | Ver §3.4 | `LIB.MODEL`, `LIB.CORE.RANDOM`, `LIB.CORE.TEXT`, `LIB.CORE.CONVERSION` | — |
| DC-14 | Suite de aceptación | Especificación nueva `LANG.PROGRAM.CLASSIC` (`CANDIDATA`, archivo `lang/lang.program.classic.md`, dominio `lenguaje`, `estable` `1.0.0`) con una regla de comportamiento y los casos de §7.2 | Corpus | — |
| DC-15 | Reescritura de programas existentes | Ver `PG-C.10` (reglas mecánicas exactas) | — | — |
| DC-P1 | **Persona.** Parámetros sin tipo en la cabecera de `Funcion`, con su tipo tomado de un `Definir` al inicio del cuerpo | **No se implementa** salvo aprobación expresa al autorizar la fase | — | — |

### 3.1 Reglas de la asignación definitiva (DC-05)

Estado del análisis en cada punto del programa: conjunto **A** de locales *definitivamente asignados* y conjunto **P** de
locales *posiblemente asignados* (P lo usa DC-07), más una marca **inalcanzable**.

| Construcción | Efecto |
|---|---|
| `Definir x …;` sin valor | `x` ∉ A, `x` ∉ P |
| `Definir x … <- e;` | Se evalúa `e` (que no puede leer `x`), después `x` ∈ A ∩ P |
| `x <- e`, `Leer x` | Se evalúa `e`; `x` ∈ A y P. Si `x` ya estaba en P, es una **reasignación** (DC-07) |
| Lectura de `x` con `x` ∉ A | `variableUsedUninitialized` |
| Escritura de un campo `x.c <- e` con `x` registro local | Se trata por hoja (`records::targets`, como hoy) |
| `Si` con `SiNo` | A = A₁ ∩ A₂; P = P₁ ∪ P₂ (una rama inalcanzable no restringe A) |
| `Si` sin `SiNo` | A = A_antes ∩ A_rama; causa `branchWithoutElse` |
| `Segun` / `VariantMatch` | Intersección de todas las ramas; sin `De Otro Modo` y sin cobertura exhaustiva se incluye el camino «ninguna rama» (causa `switchWithoutDefault`) |
| `Mientras`, `Para`, `Para Cada` | Después: A = A_antes (causa `loopMayNotRun`); P = P_antes ∪ P_cuerpo. Dentro del cuerpo, una escritura de un local declarado fuera del bucle cuenta como reasignación |
| `Repetir … Hasta Que c` | El cuerpo se ejecuta al menos una vez: `c` se comprueba con A_fin_cuerpo; después A = A_fin_cuerpo ∩ A de cada `Salir` del cuerpo |
| `Salir` | Su A va a la salida del bucle; el resto del bloque es inalcanzable |
| `Retornar`, fallo propagado explícito | Camino terminado: inalcanzable (no restringe uniones). `Propagar` dentro de una expresión se trata como camino que continúa (conservador) |
| `Seleccionar`, ámbito de tareas, `Diferir` | Mismo tratamiento que una rama que puede no ejecutarse, salvo que su regla garantice la ejecución; verificar su regla antes de decidir y anotarlo |
| Literal de función | Cada local capturado debe estar en A en el punto de creación |
| Argumento por referencia | Ver §3.2 |
| Arreglo tras `Dimension` | Asignado; sus elementos conservan la trampa `uninitializedVariableRead` |

### 3.2 Parámetros de salida (DC-06)

- Un parámetro por referencia `p` de tipo no arreglo de un subprograma o método `S` es **de salida** si, en el cuerpo de
  `S`, `p` está definitivamente asignado antes de toda lectura en todos los caminos, y no se pasa a otro parámetro por
  referencia que no sea también de salida antes de asignarlo.
- Se calcula un resumen por subprograma en orden de dependencias. Dentro de un componente recursivo (recursión directa o
  mutua), los parámetros del componente no son de salida (conservador). Las firmas importadas de otros módulos usan el
  resumen del módulo dueño si existe en la misma compilación de proyecto; si no, no son de salida.
- En una **llamada directa** a `S` (nombre conocido o método resuelto estáticamente), un argumento `x` en un parámetro de
  salida no necesita estar en A; después de la llamada `x` ∈ A y P. En un parámetro por referencia que no es de salida,
  `x` debe estar en A (se lee) y la llamada es una reasignación de `x`.
- En una **llamada indirecta** (valor función) o con despacho virtual, todo argumento por referencia debe estar en A.
- El resumen no cambia la firma ni el tipo función: es un dato del análisis.

### 3.3 Constancia inferida y capturas (DC-07)

- Un local o parámetro por valor es **efectivamente constante** si nunca sufre una reasignación según §3.1 (escritura con
  el local ya en P, escritura dentro de un bucle de un local declarado fuera, o argumento a un parámetro por referencia
  que no es de salida).
- La captura en un literal de función se registra cuando se encuentra y se **valida al terminar el análisis del cuerpo
  dueño**: si el local capturado no es efectivamente constante, `mutableClosureCapture` con origen relacionado en la
  primera reasignación. Los parámetros por referencia siguen sin poder capturarse.
- El modelo de entorno (copia por valor, raíces precisas, límite de 65 535 palabras) no cambia.
- No se añade ningún aviso que sugiera `Constante`. `Constante` (`LANG.DECL.CONSTANT`) no cambia.

### 3.4 Biblioteca clásica (DC-13)

Principio, que va al README de `pseudolearn_library` y del corpus: **un nombre, una semántica**; una forma clásica
conocida no puede existir con otro significado.

| Identidad | es | en | Firma | Semántica |
|---|---|---|---|---|
| `random` (existente, reescrita) | `azar` | `random` (alias `rand`) | `(integer) → integer` | Entero uniforme en `[0, n)`; `n ≤ 0` es fallo de ejecución `invalidRandomBound` (`CANDIDATA`). Pierde el alias `aleatorio` |
| `randomBetween` (nueva) | `Aleatorio` | `randomBetween` | `(integer, integer) → integer` | Entero uniforme en `[a, b]`; `a > b` es `invalidRandomRange` (`CANDIDATA`) |
| `randomUnit` (nueva, `CANDIDATA`) | `AzarReal` | `randomReal` | `() → real` | Lo que hoy hace `azar()`: real en `[0, 1)`. Todo uso actual de `azar()` en el monorepo pasa a `AzarReal()` |
| `substring` (existente, reescrita) | `Subcadena` | `substring` | `(string, integer, integer) → string` | `Subcadena(c, desde, hasta)`, posiciones **base 0 inclusivas**. Válido si `0 ≤ desde ≤ hasta + 1 ≤ Longitud(c)`; `desde = hasta + 1` da la cadena vacía; en otro caso `stringPositionOutOfRange` |
| `concatenate` (nueva) | `Concatenar` | `concat` | `(string, string) → string` | Igual que la concatenación de dos cadenas |
| `textToReal` (existente) | `AReal`, alias nuevo `ConvertirANumero` | `toReal` | sin cambios | sin cambios |
| `text_to_upper`, `text_to_lower` (D2) | alias nuevos `Mayusculas`, `Minusculas` | sin cambios | sin cambios | sin cambios. Requiere campo `alias` opcional en D2 con la misma semántica que en D1 (`PC-V-04`). Los nombres canónicos de PG-S.01 se conservan |

- Los enteros aleatorios salen de la misma fuente con semilla; el método de reducción a un intervalo es uniforme y sin
  sesgo (rechazo), y su algoritmo exacto pertenece al contrato del runtime y a su README, como hoy la fuente.
- Cada identidad nueva lleva ficha de ayuda es/en (la regla de `LIB.MODEL` invalida el corpus sin ella) y familia
  (`numbers` o `text`).

## 4. Desglose por punto

Cada tarea sigue §0.1-4. «Nivel D» = §7.4. Al final de cada punto, commit local del bloque.

### PG-C.00 · Preparación (transversal)

- [x] `PG-C.00.01` Lectura de §2.2; anotar revisión Git en §11.
- [x] `PG-C.00.02` `git status --short`: aplicar `PC-P-03`. Registrar la lista de archivos ajenos sin commit.
- [x] `PG-C.00.03` `df -h .` y anotar el espacio libre; si hay menos de 40 GiB, aplicar §0.2.
- [x] `PG-C.00.04` Comprobar que `pseudo` del motor compila (`cargo build` según el README de `apps/pseudolearn_cli`) y
  repetir los sondeos de `PC-H-21` escribiendo cada fila de la tabla dentro de `Algoritmo T … FinAlgoritmo` en un
  archivo `.psc` del *scratchpad* propio; anotar diferencias.

### PG-C.01 · `Definir` clásico, sin `Mutable`, ámbitos coherentes

- [x] `PG-C.01.01` Especificación: reescribir `LANG.DECL.VARIABLE#R1` según DC-01, DC-03 y DC-08;
  `LANG.DECL.UNINITIALIZED#R1` (sin `missingBindingInitializer`; lectura sin valor según DC-05; conservar «no se
  inventan valores por defecto», trampa de campos y elementos y ámbitos de bloque); `LANG.TYPES.INFERENCE#R1` (sin
  «`Mutable` cuando el vínculo se reasigna»; la declaración lleva tipo y el valor es opcional); `LANG.PROFILE.VOCABULARY`
  (quitar `mutableKeyword` de D1, es y en); `LANG.SYNTAX.GRAMMAR` (producción de declaración con lista e inicializador
  opcional); `DIAG.CATALOG` (retirar `missingBindingInitializer` y `mutableBindingNeverModified`; añadir
  `initializerWithMultipleNames`); `DIAG.SEVERITY.POLICY` (casos que usaban
  `missingBindingInitializer`).
- [x] `PG-C.01.02` Casos en `LANG.DECL.VARIABLE` y `LANG.DECL.UNINITIALIZED` (es y en): lista de tres nombres sin
  valor, asignados y escritos; nombre de un carácter; inicializador con un nombre; inicializador con dos nombres
  (`initializerWithMultipleNames`); duplicado dentro de la lista; reasignación de un local (válida); `Mutable` como
  identificador ordinario (`Definir Mutable Como Entero <- 1;` válido); `Definir Mutable x Como Entero;` (error de forma
  derivado de la gramática nueva); `C2` de `UNINITIALIZED`, hoy duplicado de `C1`, pasa a probar la lectura sin valor
  (`variableUsedUninitialized`). Reescribir los casos de `LANG.TYPES.RECORD`, `LANG.TYPES.ENUM` y
  `LANG.TYPES.VARIANT` que esperan `missingBindingInitializer` o `immutableBindingAssignment` sobre un local de
  `Definir`, con el esperado derivado de DC-03/DC-05.
- [x] `PG-C.01.03` Ficha de ayuda de la declaración en `TOOL.SERVICE.CATALOG`: quitar `mutableKeyword` de sus
  identidades y del texto; describir la lista de nombres y el valor opcional. Mensajes es/en de `cases/catalogs.json`
  para los códigos tocados (el de `immutableBindingAssignment` sin «usa Definir Mutable»).
- [x] `PG-C.01.04` Tests: en `pseudolearn_syntax/tests/` (espejo de `declaration_parser.rs`), lista, inicializador
  opcional, inicializador con varios nombres, nombre duplicado y lista vacía tras `Definir`. En
  `pseudolearn_lexicon/tests/`, que `Mutable` ya no es palabra reservada en es ni `mutable` en en.
- [x] `PG-C.01.05` Código: `see export` (regenera `export.json`); `pseudolearn_syntax/src/declaration_parser.rs`
  (`declaration`: quitar `state.keyword(KeywordKind::MutableKeyword)`, lista de nombres como en `field`, inicializador
  opcional, error con varios nombres); `pseudolearn_diagnostics` (códigos retirados y nuevo, según cómo genera su
  catálogo: leer su README); Semantic: `local_registry.rs` (`mutable_declaration` desaparece; todo local de `Definir`
  se registra reasignable; una lista crea un local por nombre, `session.declarations` ya guarda un `Vec<LocalId>` por
  nodo), `binding_checker.rs` (`initialize` sin valor emite `HirStatement::Declare`; `check_destination` solo rechaza
  vínculos no reasignables de DC-03), `usage.rs` (quitar `mutable_warning`), y el campo `HirLocal::mutable` pasa a
  significar «reasignable» o se renombra (`reassignable`) si el nombre engaña; decidir y anotar.
- [x] `PG-C.01.06` README: syntax (forma de declaración), semantic (reasignación y por qué se eliminó `Mutable`),
  lexicon si enumera palabras.
- [x] `PG-C.01.07` Nivel D: `see validate`; `cargo check -p pseudolearn_syntax -p pseudolearn_semantic`; tests de
  `.04`; `see conform --subject engine --only LANG.DECL.VARIABLE` y `--only LANG.DECL.UNINITIALIZED` (los casos de
  lectura sin valor pueden fallar hasta `PG-C.02`; anotarlo, no ocultarlo).

### PG-C.02 · Asignación definitiva

- [x] `PG-C.02.01` Especificación: completar `LANG.DECL.UNINITIALIZED` con las reglas de §3.1 como texto normativo
  (una regla por grupo: secuencia y `Leer`; ramas y `Segun`; bucles, `Repetir` y `Salir`; retornos; literales de
  función). `LANG.IO.INPUT#R1`: `Leer` asigna su designador. `DIAG.CATALOG`: argumentos y orígenes relacionados de
  `variableUsedUninitialized` (DC-05).
- [x] `PG-C.02.02` Casos (es y en, `operacion: analyze` salvo indicación): leer sin valor en secuencia; `Leer` y luego
  leer (válido, `execute` con `entradas`); `Si` con `SiNo` asignando en ambas (válido); `Si` sin `SiNo` (error,
  `branchWithoutElse`); `SiNo` que solo asigna en una rama (error, `branchWithoutAssignment`); rama que retorna sin
  asignar (válido); `Segun` exhaustivo de enumerado (válido) y sin `De Otro Modo` (error); `Mientras` que asigna y
  lectura después (error, `loopMayNotRun`); `Repetir` que asigna y lectura después y en `Hasta Que` (válido); `Repetir`
  con `Salir` antes de asignar (error); lectura dentro de un literal de función de un local sin valor (error);
  registro local sin valor con un campo asignado y lectura de otro campo (error por hoja); arreglo tras `Dimension`
  (válido, elemento sin valor sigue siendo trampa en `execute`); variable de un carácter; bucle anidado de profundidad 3.
- [x] `PG-C.02.03` Tests espejo en `pseudolearn_semantic/tests/` para la pasada nueva: un archivo por archivo nuevo de
  §5 (unión de ramas, bucles, salidas, nombre del camino en el diagnóstico).
- [x] `PG-C.02.04` Código: archivos nuevos de Semantic de §5 (`definite_assignment.rs` y hermanos); invocación al final
  del análisis de cada cuerpo, después de la comprobación de tipos y antes de `hir_finalization`; retirar la emisión en
  línea de `VariableUsedUninitialized` para locales en `name_resolution.rs` y las restauraciones de `initialized` que
  queden sin uso (`switch_checker.rs`, `for_checker.rs`, `flow_bindings.rs`, `assignment_checker.rs`,
  `task_bindings.rs`, `variant_bindings.rs`, `closure_locals.rs`, `record_locals.rs`, `dimension_checker.rs`,
  `generic_discard.rs`, `inspection_expression.rs`), conservando lo que siga sirviendo a campos, elementos o
  `bindingReadsOwnInitializer`. Antes de borrar un uso, `grep -rn "initialized" src` y leer cada sitio.
- [x] `PG-C.02.05` Verificar `PC-V-01` con un test de `pseudolearn_lowering` o `pseudolearn_api` que ejecuta en la VM un
  local declarado sin valor, asignado en ambas ramas y escrito después; si falla, corregir en `statements_declare.rs`.
- [x] `PG-C.02.06` README de semantic: la pasada, su lugar en el orden de análisis, por qué es una pasada sobre el HIR
  (DC-04) y su coste (lineal por cuerpo, sin punto fijo salvo el resumen de DC-06).
- [x] `PG-C.02.07` Nivel D: tests de `.03` y `.05`; `see conform --subject engine --only LANG.DECL.UNINITIALIZED`,
  `--only LANG.DECL.VARIABLE`, `--only LANG.IO.INPUT`.

### PG-C.03 · Parámetros de salida

- [x] `PG-C.03.01` Especificación: `LANG.SUBPROGRAM.BY-REFERENCE` con §3.2.
- [x] `PG-C.03.02` Casos: procedimiento que lee y asigna su parámetro (salida) llamado con variable sin valor (válido,
  `execute`); procedimiento que lee el parámetro antes de asignarlo (error en la llamada); recursión directa (no es de
  salida); recursión mutua; valor función con parámetro por referencia (exige valor); método por referencia resuelto
  estáticamente; parámetro arreglo (no aplica); llamada que hace la variable definitivamente asignada para una lectura
  posterior.
- [x] `PG-C.03.03` Tests espejo del archivo de resúmenes de §5.
- [x] `PG-C.03.04` Código: resumen por subprograma (archivo nuevo de §5), consumido por la pasada de `PG-C.02`.
- [x] `PG-C.03.05` README de semantic. Nivel D: tests y `see conform --subject engine --only LANG.SUBPROGRAM.BY-REFERENCE`.

### PG-C.04 · Constancia inferida y capturas

- [x] `PG-C.04.01` Especificación: `LANG.TYPES.FUNCTION` (captura según §3.3; quitar «un parámetro mutable se copia
  antes»); `LANG.SUBPROGRAM.SCOPE#R1` (la clausura conserva valores de locales efectivamente constantes);
  `DIAG.CATALOG` (`mutableClosureCapture` con origen en la reasignación).
- [x] `PG-C.04.02` Casos: captura de un local asignado una vez (válido); captura y reasignación **posterior** en el texto
  (error con origen en la reasignación); local asignado en dos ramas excluyentes y capturado (válido); asignado en un
  bucle y capturado (error); `Leer` de un local y captura (válido); parámetro por valor no reasignado (válido) y
  reasignado (error); parámetro por referencia (error, como hoy); clausura anidada que captura transitivamente.
  Reescribir los casos existentes de `mutableClosureCapture` (`lang.types.function.md`, `api.program.view.md`,
  `tool.service.catalog.md`) con programas sin `Mutable`.
- [x] `PG-C.04.03` Tests espejo de `capture_analysis.rs` y del archivo de validación diferida.
- [x] `PG-C.04.04` Código: `capture_analysis.rs` deja de consultar `declaration.mutable` y registra la captura; la
  validación diferida (§5) consulta el conjunto de reasignaciones de la pasada de `PG-C.02`.
- [x] `PG-C.04.05` README de semantic (D-PG2-09 sigue vigente: no hay celdas compartidas). Nivel D: tests y
  `see conform --subject engine --only LANG.TYPES.FUNCTION`.

### PG-C.05 · `Con Paso` opcional

- [x] `PG-C.05.01` Especificación: `LANG.CONTROL.FOR` (DC-09); `DIAG.CATALOG` sin `missingStepClause`.
- [x] `PG-C.05.02` Casos: `Para i <- 1 Hasta 3 Hacer` escribe `123`; `Para i <- 3 Hasta 1 Hacer` no ejecuta el cuerpo;
  `Para i <- 1 Hasta 1 Hacer` una vez; con `Con Paso -1` sigue igual; reescribir el caso que esperaba `missingStepClause`.
- [x] `PG-C.05.03` Tests espejo de `for_checker.rs` y del archivo de lowering tocado.
- [x] `PG-C.05.04` Código: `for_checker.rs` deja de emitir `MissingStepClause` y fija paso 1; verificar `PC-V-02` y
  ajustar `statements_for*.rs` si asumían paso presente.
- [x] `PG-C.05.05` Nivel D: tests y `see conform --subject engine --only LANG.CONTROL.FOR`.

### PG-C.06 · `Caracter → Cadena`

- [x] `PG-C.06.01` Especificación: `LANG.TYPES.RELATIONS#R1` (DC-10).
- [x] `PG-C.06.02` Casos: `Definir c Como Cadena <- "s";`; asignación de un `Caracter` a `Cadena`; argumento por valor;
  retorno; elemento de `Vector<Cadena>`; argumento por referencia (sigue siendo error); `Cadena → Caracter` (sigue
  siendo error); comparación `"s" = opcion` con `opcion` cadena.
- [x] `PG-C.06.03` Tests espejo de `type_resolution.rs` (`assignable`) y de `expression_checker::widen`.
- [x] `PG-C.06.04` Código: `type_resolution.rs::assignable` y `expression_checker::widen` (conversión explícita en el
  HIR, como `Entero → Real`); Lowering de la conversión si no existe una operación de RI para ella: buscar primero con
  `grep -rn "CharToString\|char_to_string\|ToText" crates/pseudolearn_ir/src crates/pseudolearn_lowering/src`.
- [x] `PG-C.06.05` Nivel D: tests y `see conform --subject engine --only LANG.TYPES.RELATIONS`.

### PG-C.07 · `Dimension` en dos pasos

- [x] `PG-C.07.01` Especificación: `LANG.ARRAY.DIMENSION#R1` (DC-11); `LANG.SYNTAX.GRAMMAR` (`Como T` opcional en
  `Dimension`); `DIAG.CATALOG` (`dimensionWithoutType`).
- [x] `PG-C.07.02` Casos: `Definir v Como Real; Dimension v[3];` con escritura y lectura; tamaño cero; nombre no
  declarado; nombre declarado con inicializador; nombre usado entre `Definir` y `Dimension`; declarado en otro ámbito;
  bidimensional.
- [x] `PG-C.07.03` Tests espejo del parser de `Dimension` (en `statement_parser.rs` o el archivo que el `grep` indique) y
  de `dimension_checker.rs`.
- [x] `PG-C.07.04` Código: parser y `dimension_checker.rs`.
- [x] `PG-C.07.05` Nivel D: tests y `see conform --subject engine --only LANG.ARRAY.DIMENSION`.

### PG-C.08 · `Funcion r <- nombre(…)`

- [x] `PG-C.08.01` Especificación: `LANG.SUBPROGRAM.DECLARATION` y `LANG.SUBPROGRAM.RETURN` (DC-12);
  `LANG.SYNTAX.GRAMMAR`; `DIAG.CATALOG`.
- [x] `PG-C.08.02` Casos: función clásica que suma dos parámetros tipados; `r` asignada en ambas ramas; `r` sin asignar en
  un camino (error con origen en la cabecera); `Retornar` sin expresión (válido si `r` asignada); `Retornar expresión`
  (error); sin `Definir r` (error); llamada recursiva; uso como valor función (firma igual a la forma `SubProceso`).
- [x] `PG-C.08.03` Tests espejo de `unit_parser.rs`/`parameter_parser.rs` (según dónde está la cabecera) y del archivo
  de desazucarado.
- [x] `PG-C.08.04` Código: parser de cabecera; Semantic (registro del tipo de retorno desde `r` y desazucarado, archivo
  nuevo de §5).
- [x] `PG-C.08.05` Ficha de ayuda de subprogramas con la forma nueva. Nivel D: tests y `see conform --subject engine
  --only LANG.SUBPROGRAM.DECLARATION`, `--only LANG.SUBPROGRAM.RETURN`.

### PG-C.09 · Biblioteca clásica

- [x] `PG-C.09.01` Verificar `PC-V-04`. Especificación: `LIB.MODEL` (D1: `random` reescrita, `randomBetween`,
  `randomUnit`, `concatenate`, alias `ConvertirANumero`; D2: campo `alias` y alias `Mayusculas`/`Minusculas`; texto de
  la regla que dice «veintiocho funciones» actualizado al número real); `LIB.CORE.RANDOM`; `LIB.CORE.TEXT` (`Subcadena`
  y, si alguna otra regla de texto depende de «inicio y cantidad», también); `LIB.CORE.CONVERSION` (alias). Fichas de
  ayuda es/en de cada identidad nueva en `TOOL.SERVICE.CATALOG`.
- [x] `PG-C.09.02` Casos: `Azar(1)` siempre 0; `Azar(0)` y `Azar(-1)` fallan; `Aleatorio(5, 5)` = 5; `Aleatorio(3, 1)`
  falla; rango de `Azar(6)` con semilla fija comprobado como propiedad (todos los valores en `[0, 6)`), nunca un valor
  capturado; `AzarReal()` en `[0, 1)`; `Subcadena("hola", 0, 1)` = `ho`, `Subcadena("hola", 2, 1)` = cadena vacía,
  `Subcadena("", 0, -1)` = cadena vacía, `Subcadena("hola", 0, 4)` falla, `Subcadena("hola", -1, 0)` falla;
  `Concatenar("a", "")`; `ConvertirANumero("3,5")` falla y `ConvertirANumero("3.5")` escribe según
  `LANG.IO.VALUE-FORMAT`; `Mayusculas("ñ")`; aridad incorrecta de cada una. Reescribir los casos existentes que usan
  `azar()` (pasan a `AzarReal()`) y `Subcadena` con cantidad.
- [x] `PG-C.09.03` Tests espejo en `pseudolearn_library/tests/` y, si cambia, en el lector de D2.
- [x] `PG-C.09.04` Código: `see export`; validador de D2 en `packages/pseudolearn_spec/crates` (si `PC-V-04` lo exige;
  **comprobar antes con `git status` que el otro agente no tiene cambios sin commit en ese crate**); `pseudolearn_library`
  (entero aleatorio sin sesgo, intervalo, `Subcadena`, `Concatenar`); resolución de alias de D2 donde se resuelven hoy
  (`PC-H-19`).
- [x] `PG-C.09.05` Verificar `PC-V-05`: `cargo check -p pseudolearn_codegen -p pseudolearn_aot_rt`. Si el sujeto nativo
  no soporta las firmas nuevas, rechazar con el diagnóstico de operación no soportada existente y dejar los vínculos de
  `packages/pseudolearn_engine/conformance-aot.yaml` en `pendiente` con `resuelve_en` `PG-N.08` (§0.1-11).
- [x] `PG-C.09.06` README de `pseudolearn_library` (principio «un nombre, una semántica», método sin sesgo) y del
  runtime si documenta la fuente. Nivel D: tests y `see conform --subject engine --only` de cada especificación de `.01`.

### PG-C.10 · Reescritura del monorepo y consumidores

Reglas mecánicas exactas (DC-15), aplicadas con `sed -i ''` sobre archivos con seguimiento, **solo** con estos patrones:

1. `Definir Mutable ` → `Definir ` y `define mutable ` → `define ` (respetando la caja que aparezca: buscar antes
   `git grep -n -i "definir mutable\|define mutable"` y listar variantes).
2. En contenidos pedagógicos y ejemplos (no en el corpus), la secuencia `Definir x Como T <- v;` seguida, en la línea
   siguiente, de `Leer x;` con `v` igual a `0`, `0.0`, `""`, `''`, `Falso` o `'a'` → se quita `<- v`. Esto se hace a
   mano o con un script revisado línea a línea, nunca con un patrón ciego.
3. Toda otra aparición de `Mutable` se revisa a mano.

- [x] `PG-C.10.01` Corpus: aplicar la regla 1 a todos los programas de casos de `specifications/` excepto los que
  `PG-C.01`–`.09` ya reescribieron; reescribir el texto en prosa que nombre `Mutable`; `fixtures/` incluido
  (`fixture-1.md`). `git grep -n "Mutable\|mutable" -- packages/pseudolearn_spec` debe dar solo apariciones justificadas
  y anotadas.
- [x] `PG-C.10.02` Posiciones (`PC-V-09`): para cada especificación tocada en `.01` cuyos casos esperan líneas,
  columnas, desplazamientos o tramos (`grep -ln '"linea"\|"columna"\|"inicio"\|"fin"\|"posicion"\|"span"' <archivos
  tocados>`), recalcular a mano los esperados afectados por los caracteres eliminados, derivándolos del programa nuevo.
  Candidatos conocidos: `app.editor.completion`, `tool.service.hover`, `tool.service.navigation`, `api.analyze`,
  `api.program.view`, `api.state.query`, `ir.source-map`, `ir.observation-points`, `eng.trace.*`. **No tocar**
  `tool.service.hover.md` mientras tenga cambios ajenos sin commit (`PC-P-03`).
- [x] `PG-C.10.03` `see lock --refresh` con **todas** las identidades editadas en PG-C en una sola orden; `see export`;
  `see export --check`; `see lock --check`; `see validate`.
- [x] `PG-C.10.04` Motor: regla 1 en los tests y cargas (`pseudolearn_service/tests/*`, `pseudolearn_api/tests/*`,
  `pseudolearn_bench_worker/src/*`, demás de `git grep -l Mutable -- packages/pseudolearn_engine`);
  `pseudolearn_api/src/program_view_variants.rs` (revisar a mano); servicio: completado, *hover* y formateador ya no
  proponen ni imprimen `Mutable` (leer `completion*.rs`, `hover*.rs` y el formateador; sus tests de
  `completion_assignment.rs`, `completion_ranking.rs`, `completion.rs`, `formatter.rs`, `hover.rs`, `incremental.rs`).
- [x] `PG-C.10.05` Generador `see_generators` (`src/program.rs` y `tests/program.rs`): deja de emitir `Mutable`; verificar
  `PC-V-10` y, si hay resultados versionados que dependen de la semilla, regenerarlos con la orden del README.
- [x] `PG-C.10.06` Extensión: regla 1 en `examples/`, `tests/` y `scripts/`; regenerar la gramática según `PC-V-06`;
  `git grep -n Mutable -- apps/pseudolearn_vscode` vacío salvo `node_modules`.
- [x] `PG-C.10.07` App: reglas 1 y 2 en los 125 archivos de `assets/knowledge` (lecciones y ejercicios es/en); donde la
  prosa explique `Mutable`, reescribirla para explicar que una variable de `Definir` puede cambiar y que leerla sin
  valor es error; `lib/engine/execution/task_structure_projection.dart`; los 33 tests. Verificar `PC-V-07`.
- [x] `PG-C.10.08` CLI (`examples/` y `tests/`, 7 archivos) y `packages/pseudolearn_benchmarks` (4 archivos); verificar
  `PC-V-08` y anotar en §11 si alguna línea base queda incomparable (no se regenera ninguna línea base de rendimiento en
  PG-C).
- [x] `PG-C.10.09` READMEs: `git grep -n "Mutable\|missingBindingInitializer\|mutableBindingNeverModified\|Con Paso" --
  '*README.md'` y reescribir cada aparición que describa el comportamiento viejo.
- [x] `PG-C.10.10` Nivel D: `git grep -n "Mutable" -- . ':!docs/**' ':!**/node_modules/**'` sin apariciones no
  justificadas; `cargo check` de los crates tocados; en la app, `flutter analyze` y `flutter test <archivos tocados>`;
  en la extensión, la prueba de gramática de su README.

### PG-C.11 · Suite de aceptación clásica

- [x] `PG-C.11.01` Verificar `PC-V-03`. Especificación nueva `LANG.PROGRAM.CLASSIC` (DC-14), regla R1 `CANDIDATA`:
  «Un programa formado solo por `Algoritmo` o `Proceso`, `Definir` con lista de nombres, `Leer`, `Escribir`, `Si`,
  `Segun`, `Mientras`, `Repetir`, `Para` sin paso, `Dimension` en dos pasos, `Funcion` con variable de retorno,
  `SubProceso` con parámetros por referencia de salida y las funciones clásicas de la biblioteca se analiza sin
  diagnósticos y se ejecuta con la salida que derivan las reglas de cada construcción». `depende_de` cada identidad
  usada.
- [x] `PG-C.11.02` Casos de §7.2, cada uno con programa es (y en si `PC-V-03` lo exige), `entradas` cuando hay `Leer`,
  `operacion: execute` y salida derivada a mano; la derivación paso a paso de cada salida se anota en §11.
  Más un caso `analyze` por programa con `diagnosticos: []`.
- [x] `PG-C.11.03` Vínculos de conformidad como datos para `LANG.PROGRAM.CLASSIC` en
  `packages/pseudolearn_engine/conformance.yaml`, `packages/pseudolearn_engine/conformance-service.yaml`,
  `apps/pseudolearn_cli/conformance.yaml` y, como `pendiente` con `resuelve_en` `PG-N.08`,
  `packages/pseudolearn_engine/conformance-aot.yaml`; seguir el formato de las filas vecinas.
- [x] `PG-C.11.04` Nivel D: `see validate`; `see conform --subject engine --only LANG.PROGRAM.CLASSIC`.

### PG-C.12 · Bloque final: pruebas pesadas, conformidad y corrección

Se ejecuta **una sola vez**, al terminar `PG-C.11`, en el orden de §10.2. Antes de cada orden, §0.2. Cada orden se
lanza en segundo plano con la salida en `packages/pseudolearn_engine/results/pg-c-<fecha real>/logs/<orden>.log`, y se
registra en §11 la orden, el código de salida y los conteos.

- [x] `PG-C.12.01` Corpus: `see validate`, `see lock --check`, `see export --check`.
- [x] `PG-C.12.02` Estática: `cargo xtask verify` del motor (Clippy estricto, capas, límites); `rust-checks` (`layers`,
  `comments`, `names`, límites) según el README de `pseudolearn_rust_checks`; lo mismo en `packages/pseudolearn_spec` y
  `apps/pseudolearn_cli`.
- [x] `PG-C.12.03` Pruebas del motor: `cargo test -p` de `pseudolearn_lexicon`, `pseudolearn_syntax`,
  `pseudolearn_semantic`, `pseudolearn_lowering`, `pseudolearn_library`, `pseudolearn_ir`, `pseudolearn_bytecode`,
  `pseudolearn_vm`, `pseudolearn_runtime`, `pseudolearn_service`, `pseudolearn_api`, `pseudolearn_timeline`,
  `pseudolearn_wasm`; después `cargo test --workspace`. Pruebas de `packages/pseudolearn_spec` (`cargo test
  --workspace` en su directorio).
- [x] `PG-C.12.04` Conformidad completa: `see conform --subject engine`; `--subject service`; `--subject cli`;
  `--subject aot` (vínculos `pendiente` informados, cero `incumple` en reglas tocadas por PG-C que no estén
  `pendiente`); `--operation properties`; `--subject app`.
- [x] `PG-C.12.05` Consumidores: pruebas de la CLI según su README; extensión (pruebas y gramática vigente; web Chromium y
  WebKit si el README los incluye); app: `flutter analyze`, `dart run tool/check_syntax_coverage.dart`, biblioteca
  nativa (`cargo build --release --locked --lib --manifest-path native/Cargo.toml`) y **suite completa** `flutter test`;
  `packages/pseudolearn_benchmarks` según su README.
- [x] `PG-C.12.06` Rendimiento: `PERF.SUITE.CORE` y `PERF.AOT.LEVEL` antes (`052a4c1e`, en el *worktree* de `.08`) y
  después según `PERF.PROTOCOL`. Esperado: sin cambio fuera del ruido (`PC-H-15`). Una regresión mayor que el ruido es
  fallo de PG-C.
- [x] `PG-C.12.07` Casos negativos de los verificadores afectados (los de comentarios, nombres, capas y límites del motor
  y de SEE) siguen fallando con su violación deliberada.
- [x] `PG-C.12.08` Ciclo de corrección (§10.4) contra `git worktree add --detach <scratchpad>/pg-c-base 052a4c1e`.
- [x] `PG-C.12.09` Aceptación por plataforma: el programa más completo de `LANG.PROGRAM.CLASSIC` (§7.2, `CL-10`) pegado
  sin cambios y ejecutado en CLI (`pseudo ejecutar`), extensión de escritorio, extensión web (Chromium y WebKit), app
  macOS y app iOS en simulador; Windows «no verificado». Salida esperada la del caso.
- [x] `PG-C.12.10` Criterio de salida: repetir los sondeos de `PC-H-21` y anotar el resultado nuevo de cada fila; todas
  las filas de barreras deben quedar sin diagnóstico salvo `a[3]` en un arreglo de tamaño 3 (base 0 conservada).

### Cierre común

- [x] `PG-C.C03`–`C11` se acreditan con la evidencia de §11.
- [x] `PG-C.C12.01` Revisión del diff completo (`git diff 052a4c1e --stat` y lectura de cada archivo de código): búsqueda
  de comentarios, `TODO`, `unwrap`, `expect`, `panic!` y de citas a `docs/` fuera de `docs/`
  (`grep -rn "docs/plan-ejecucion\|fase-pg-\|propuesta-pseudocodigo" packages apps` vacío).
- [x] `PG-C.C12.02` Commits con la skill `commit-message`, sin atribución de IA, solo rutas de PG-C, y push ordinario
  comprobado (`git branch --show-current`, `git push`, `git status -sb` sin divergencia).
- [x] `PG-C.C13.01` Completar §11 de este plan, §4.16 y la fila de §6 del plan general; informe a la persona con
  puntos cumplidos, decisiones aplicadas, `CANDIDATA` fijadas, hallazgos de §11.4, pendientes (PG-N.08,
  Windows/físicos, `DC-P1`) y **parada**.

## 5. Capas y archivos

Respuestas a `AGENTS.md` §1. Los archivos nuevos son `CANDIDATA` de nombre; respetan `PC-H-20`, cero comentarios y
`#![forbid(unsafe_code)]` donde el crate lo exige. Antes de crear uno, confirmar en `architecture.yaml` del motor la capa
del crate y su matriz de imports.

| Archivo | Capa (según `architecture.yaml`) | Puede importar | Responsabilidad única |
|---|---|---|---|
| `pseudolearn_syntax/src/declaration_parser.rs` (mod.) | syntax | lo que hoy importa | Forma de `Definir` |
| Parser de `Dimension` y de cabecera de subprograma (mod., localizar con `grep`) | syntax | ídem | `Dimension` sin tipo; `Funcion r <-` |
| `pseudolearn_semantic/src/definite_assignment.rs` (nuevo) | semantic | HIR, `identities`, `pseudolearn_diagnostics` | Recorrido del HIR de un cuerpo con el estado A/P de §3.1 |
| `pseudolearn_semantic/src/definite_assignment_state.rs` (nuevo) | semantic | `identities` | Conjuntos A y P, unión, intersección, marca inalcanzable |
| `pseudolearn_semantic/src/definite_assignment_report.rs` (nuevo) | semantic | `pseudolearn_diagnostics` | Diagnóstico con causa y orígenes relacionados |
| `pseudolearn_semantic/src/output_parameters.rs` (nuevo) | semantic | HIR, `function_model` | Resumen de parámetros de salida (§3.2) |
| `pseudolearn_semantic/src/capture_validation.rs` (nuevo) | semantic | HIR, diagnostics | Validación diferida de capturas (§3.3) |
| `pseudolearn_semantic/src/return_variable.rs` (nuevo) | semantic | HIR | Registro de tipo y desazucarado de DC-12 |
| `local_registry.rs`, `binding_checker.rs`, `capture_analysis.rs`, `usage.rs`, `name_resolution.rs`, `for_checker.rs`, `type_resolution.rs`, `expression_checker*.rs`, `dimension_checker.rs`, `hir.rs` (mod.) | semantic | sin cambios de matriz | Ver tareas |
| `pseudolearn_lowering/src/statements_for*.rs`, `statements_declare.rs` (mod. solo si `PC-V-01`/`PC-V-02` lo exigen) | lowering | sin cambios | Paso por omisión; declaración sin valor |
| `pseudolearn_library/src/*` (mod.) | library | sin cambios | Funciones de `PG-C.09` |
| Tests espejo en `crates/<crate>/tests/` o `<módulo>_tests.rs` hermano con `#[cfg(test)]` | — | — | `TEST-MIRROR`; nunca un `all_tests` común |

Si un archivo de Semantic modificado supera 300 líneas, dividirlo por responsabilidad antes de añadir. Ningún crate
cambia de capa ni de matriz; si una tarea parece necesitarlo, es un conflicto (§0.1-9).

## 6. Presupuestos de rendimiento y seguridad

### 6.1 Rendimiento

- La pasada de asignación definitiva es lineal en el tamaño de cada cuerpo; el resumen de parámetros de salida recorre
  el grafo de llamadas una vez (componentes fuertemente conexos sin iteración). Medir en `PG-C.12.06` el tiempo de
  análisis de la suite `PERF.SUITE.CORE`; un aumento mayor que el ruido del protocolo se informa.
- Ejecución: sin cambios esperados (`PC-H-15`). `PERF.AOT.LEVEL` se mide antes y después.

### 6.2 Seguridad y límites

- Ninguna lectura de local sin valor llega a ejecución: lo garantiza el análisis estático; los elementos de arreglo y los
  campos conservan la trampa en ejecución.
- Ningún estado mutable compartido entre clausuras o tareas (DC-07, `LANG.TASK.ISOLATION` sin cambios).
- Profundidad: la pasada recorre el HIR con recursión acotada por los límites de anidación existentes
  (`LANG.SYNTAX.ANALYSIS-LIMITS`); si el recorrido no es iterativo, comprobar que el límite de profundidad de esa regla
  protege la pila y anotarlo.

## 7. Pruebas, verificadores y experimentos

### 7.1 Matriz por punto

| Punto | Corpus (`see conform --only`) | Tests espejo | Consumidores |
|---|---|---|---|
| C.01 | `LANG.DECL.VARIABLE`, `LANG.DECL.UNINITIALIZED`, `LANG.TYPES.INFERENCE`, `LANG.TYPES.RECORD`, `LANG.TYPES.ENUM`, `LANG.TYPES.VARIANT` | syntax, lexicon, semantic | — |
| C.02 | `LANG.DECL.UNINITIALIZED`, `LANG.IO.INPUT` | semantic, lowering | — |
| C.03 | `LANG.SUBPROGRAM.BY-REFERENCE` | semantic | — |
| C.04 | `LANG.TYPES.FUNCTION`, `LANG.SUBPROGRAM.SCOPE` | semantic | — |
| C.05 | `LANG.CONTROL.FOR` | semantic, lowering | — |
| C.06 | `LANG.TYPES.RELATIONS` | semantic | — |
| C.07 | `LANG.ARRAY.DIMENSION` | syntax, semantic | — |
| C.08 | `LANG.SUBPROGRAM.DECLARATION`, `LANG.SUBPROGRAM.RETURN` | syntax, semantic | Ficha de ayuda |
| C.09 | `LIB.MODEL`, `LIB.CORE.RANDOM`, `LIB.CORE.TEXT`, `LIB.CORE.CONVERSION` | library | Fichas |
| C.10 | Las tocadas | servicio | CLI, extensión, app, benchmarks |
| C.11 | `LANG.PROGRAM.CLASSIC` | — | Aceptación en `.12.09` |

### 7.2 Programas de la suite clásica (`LANG.PROGRAM.CLASSIC`)

Todos con `;`, índices base 0, sin `Con Paso`, sin inicializadores ficticios y sin palabras propias de PseudoLearn. Los
esperados se derivan a mano de las reglas y se anotan.

| ID | Programa | Ejercita |
|---|---|---|
| CL-01 | Saludo: `Definir nombre Como Cadena; Leer nombre; Escribir "Hola ", nombre;` | `Leer` asigna |
| CL-02 | Suma de n números con acumulador `Mientras` | Lista en `Definir`, reasignación, `Mientras` |
| CL-03 | Mayor de tres con `Si` anidados | Ramas |
| CL-04 | Menú con `Segun` sobre opción numérica y confirmación `Definir resp Como Cadena; Leer resp; Si resp = "s" …` | `Segun`, literal de un carácter |
| CL-05 | Factorial con `Repetir … Hasta Que` | `Repetir` |
| CL-06 | Tabla de multiplicar con `Para i <- 1 Hasta 10 Hacer` | `Para` sin paso |
| CL-07 | Promedio de notas con `Definir notas Como Real; Dimension notas[5];` y `Para i <- 0 Hasta 4 Hacer` | `Dimension` en dos pasos, base 0 |
| CL-08 | `Funcion r <- Mayor(a Como Entero, b Como Entero)` y su uso | Variable de retorno |
| CL-09 | `SubProceso LeerPositivo(n Como Entero Por Referencia)` con `Repetir Leer n; Hasta Que n > 0`, llamado con una variable sin valor | Parámetro de salida |
| CL-10 | Programa integrador: CL-02, CL-04, CL-07 y CL-08 juntos, más `Mayusculas`, `Longitud`, `Subcadena(c, 0, 2)`, `Concatenar` y `ConvertirANumero` | Todo |

### 7.3 Verificadores

PG-C no crea verificadores nuevos. Los afectados (SEE, `rust-checks`, cobertura de sintaxis de la app) se ejecutan en el
bloque final con sus casos negativos (`PG-C.12.07`).

### 7.4 Comandos y niveles

Los comandos exactos se copian de la sección «Cómo se verifica» del README de cada miembro, no de este plan.

- **Nivel D (bloques `PG-C.00`–`PG-C.11`, rápido y acotado):** `cargo check -p <crate>`; `cargo test -p <crate> --test
  <archivo>` o `cargo test -p <crate> <filtro>` sobre los tests creados o tocados; desde `packages/pseudolearn_spec`,
  `see validate` tras cada edición del corpus y `see conform --subject engine --only <ID>` de las identidades del
  bloque; en la app, `flutter analyze` y `flutter test <archivos tocados>`.
  **Prohibido en nivel D:** `cargo test --workspace`, `cargo test -p <crate>` sin filtro en `pseudolearn_api`,
  `pseudolearn_service`, `pseudolearn_semantic` y `pseudolearn_runtime`, `cargo xtask verify`, `see conform` sin
  `--only`, `flutter test` completo, campañas `PERF.*`, Playwright.
- **Nivel F (`PG-C.12`):** todo lo de `PG-C.12.01`–`.10`.

### 7.5 Experimentos

| ID | Objetivo | Protocolo | Si falla |
|---|---|---|---|
| PC-E01 | Coste de la pasada de asignación definitiva | Tiempo de `pseudo comprobar` sobre los programas de `PERF.SUITE.CORE` y sobre un programa sintético con 1 000 ramas anidadas en 10 niveles, antes y después | Informar; optimizar solo si supera el ruido del protocolo |
| PC-E02 | Rendimiento de ejecución sin cambios | `PG-C.12.06` | Una regresión mayor que el ruido es fallo de PG-C |

## 8. Riesgos y señales tempranas

| ID | Riesgo | Señal temprana | Respuesta |
|---|---|---|---|
| PC-K-01 | La reescritura mueve columnas y rompe esperados posicionales | `see conform --only` de una especificación posicional falla tras `PG-C.10.01` | `PG-C.10.02` |
| PC-K-02 | Falsos positivos de asignación definitiva en construcciones poco comunes (`Seleccionar`, tareas, `Diferir`) | Casos existentes de `LANG.TASK.*` o `LANG.CONTROL.CLEANUP` fallan en el bloque final | Revisar la regla de la construcción; tratarla según §3.1 y anotar |
| PC-K-03 | El otro agente edita los mismos archivos | `git status` muestra cambios ajenos en archivos de PG-C | Parar y preguntar (`PC-P-03`) |
| PC-K-04 | Disco lleno en el bloque final | `errno=28` | §0.2 |
| PC-K-05 | Un archivo de Semantic supera 300 líneas | `rust-checks` de límites | Dividir por responsabilidad antes de añadir |
| PC-K-06 | Cambiar `Subcadena` o `azar` rompe programas de la app o ejemplos de PG-S | `git grep -n "Subcadena\|azar(" -- apps packages` | Reescribir esos usos en `PG-C.10` |
| PC-K-07 | El sujeto nativo da resultados distintos con las firmas nuevas | `--subject aot` con `incumple` | Rechazo explícito y vínculo `pendiente` (§0.1-11) |

## 9. Dependencias de la persona

### 9.1 Qué se necesita y cuándo

| Momento | Qué | Si no responde |
|---|---|---|
| Antes de empezar | `C01` en un mensaje nuevo; revisión de este plan (`C02`) | No se empieza |
| Antes de empezar | `DC-P1` (parámetros sin tipo) | No se implementa |
| `PG-C.00.02` | Si hay cambios ajenos en archivos de PG-C | Se espera |
| Cierre | Push | Se deja el commit local y se informa |

### 9.2 Conflictos conocidos (`CONFLICT-REPORT`)

| ID | Fuentes | Tratamiento |
|---|---|---|
| PC-C-01 | `LANG.DECL.VARIABLE#R1` («no crean ámbitos de bloque») frente a `LANG.SUBPROGRAM.SCOPE#R1` y `LANG.DECL.UNINITIALIZED#R1` (ámbitos por rama y cuerpo) | Resuelto por DC-08 con la decisión de la persona del 2026-11-05 |
| PC-C-02 | D-PG2-01 (opción A) y PG-2.05 frente a la decisión del 2026-11-05 | La decisión de la persona prevalece; registrada en el plan general. Las casillas de PG-2 no se desmarcan |
| PC-C-03 | Nombres de PG-S.01 confirmados (`AMayusculas`) frente a `Mayusculas` clásico | Se conservan los canónicos y se añaden alias (DC-13) |
| PC-C-04 | `LANG.DECL.UNINITIALIZED#R1` dice «No hay migrador ni modo de compatibilidad» | Se conserva: PG-C tampoco añade migrador |

## 10. Orden de ejecución y puntos de control

### 10.1 Orden único (una iteración)

1. **G0 · Entrada.** `C01` recibido; `PG-C.00.01`–`.04`.
2. **PG-C.01** → control **K1** (sin parada): nivel D en verde, `see validate` limpio, commit local.
3. **PG-C.02** → **K2**. 4. **PG-C.03** → **K3**. 5. **PG-C.04** → **K4**. 6. **PG-C.05** → **K5**.
7. **PG-C.06** → **K6**. 8. **PG-C.07** → **K7**. 9. **PG-C.08** → **K8**. 10. **PG-C.09** → **K9**.
11. **PG-C.10** → **K10**. 12. **PG-C.11** → **K11**.
13. **Bloque final `PG-C.12`** en el orden de §10.2, con el ciclo de §10.4.
14. Cierre `C12`–`C13`, informe y **parada**.

Los controles K no detienen la ejecución: comprueban el nivel D del punto y producen su commit local. Si un control falla,
se corrige antes de pasar al siguiente punto.

### 10.2 Orden del bloque final

§0.2 → `.01` corpus → `.02` estática → `.03` pruebas del motor y de SEE → `.04` conformidad → `.05` consumidores →
`.07` negativos → `.06` rendimiento → `.08` corrección (intercalada: tras cada orden que falle) → `.09` aceptación por
plataforma → `.10` criterio de salida. Push solo después de `.10` en verde o con pendientes aceptados por escrito.

### 10.3 Paradas obligatorias (las únicas)

- Cambios ajenos sin commit en archivos que PG-C debe tocar (`PC-P-03`).
- Decisión **Persona** sin respuesta: se omite lo afectado y se sigue.
- Conflicto nuevo entre fuentes que cambia el trabajo: se registra en §11.3, se omite lo afectado y se sigue.
- Fin de la fase: informe y parada.

### 10.4 Ciclo de corrección del bloque final

1. Para cada orden que falle, guardar el registro y clasificar cada fallo con la **misma orden** en el *worktree*
   desacoplado de `052a4c1e`: si también falla allí, es **preexistente** (se registra, no se corrige salvo que PG-C lo
   agrave); si no, es **regresión de PG-C**; si falla de forma intermitente en tres ejecuciones, **inestable**.
2. Corregir las regresiones en el archivo dueño respetando §0.1-4 (si la causa es un caso mal derivado, se corrige el
   caso con la derivación correcta y se anota).
3. Repetir solo la orden afectada y las que dependen de ella (un cambio en Semantic repite `.03` de `semantic`,
   `lowering`, `api` y `.04` `engine`).
4. Máximo tres vueltas por orden; si una regresión persiste, «No cumplido» con su causa. Tras la última corrección,
   `.01`–`.05` completos una vez más.
5. `git worktree remove` al terminar.

## 11. Resumen de ejecución

Estado: PG-C.00–PG-C.12 y el cierre común cumplidos el 2026-11-05/06 en una sola iteración. Autorización (`PG-C.C01`,
`C02`): mensaje de la persona del 2026-11-05 («Implementa … en una sola iteración. No me hagas preguntas … elige siempre
la opción recomendada»), que revisa y autoriza este plan; `DC-P1` no se implementó porque no fue aprobada. Revisión Git
de partida: `9d732d46` (no `052a4c1e`; `PC-H-*` repetidos donde aplicaba). El trabajo se hizo en el *worktree*
`claude/fase-pg-c-ejecucion-c65131`, avanzado por avance rápido a `9d732d46`, y se fusionó `07ecbb3a` (cierre de PG-L del
otro agente) antes del push. Disco: se liberaron ≈ 54 GB (`cargo clean` del motor y de la CLI de la copia principal sin
compilaciones en curso, 23,5 + 7,1 GiB; destino nativo y `build/` de la app, 3,8 + 1,7 GiB; cachés `incremental` del
motor y de la CLI en ambas copias, ≈ 20 GiB).

| Tarea | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| `PG-C.C01`, `C02` | Cumplida | Mensaje de la persona del 2026-11-05 | Autorización y revisión del plan en la misma petición |
| `PG-C.00.01`–`.04` | Cumplida | §11.1; sondeos `PC-H-21` repetidos con `pseudo` del *worktree*: resultados idénticos a la tabla | `PC-P-03`: sin cambios ajenos en el *worktree*; `PC-P-02`: PG-L/PG-S no se reabrieron |
| `PG-C.01.01`–`.07` | Cumplida | `d63ad3a5`, `3d0b175a`; `LANG.DECL.VARIABLE` C1–C12, `LANG.DECL.UNINITIALIZED` C1–C4, `DIAG.SEVERITY.POLICY`, `LANG.TYPES.ENUM#C9`, `LANG.TYPES.RECORD#C15`; tests `declaration_parser_tests.rs`, `reserved_tests.rs`, `binding_checker.rs` | `HirLocal::mutable` renombrado a `reassignable` (falso solo para vínculos de `Para Cada`, patrones, tareas y capturas) |
| `PG-C.02.01`–`.07` | Cumplida | `LANG.DECL.UNINITIALIZED` R1–R6 y C1–C21, `LANG.IO.INPUT#C5`; tests `definite_assignment_state.rs`, `definite_assignment_report.rs`, `record_assignment.rs`; `pseudolearn_api/tests/declaration_without_value.rs` | Implementación en línea (PC-C-05); campos de registro por hoja con `ExpressionPurpose::Receiver` |
| `PG-C.03.01`–`.05` | Cumplida | `LANG.SUBPROGRAM.BY-REFERENCE` C4–C11; `semantic/tests/output_parameters.rs` (7 pruebas) | PC-C-08, PC-C-09, PC-C-10 |
| `PG-C.04.01`–`.05` | Cumplida | `LANG.TYPES.FUNCTION` C3 y C18–C25, `API.PROGRAM.VIEW#C16`; `semantic/tests/capture_validation.rs` | Capturas rechazadas se quitan del modelo para que la vista no las muestre |
| `PG-C.05.01`–`.05` | Cumplida | `LANG.CONTROL.FOR` C2, C11, C18–C21; `for_checker_tests.rs` | PC-V-02 confirmada: Lowering ya daba paso 1 |
| `PG-C.06.01`–`.05` | Cumplida | `LANG.TYPES.RELATIONS` C22–C29 | `Widen` reutilizado: `text.format` desde carácter; comparación mixta (PC-C-06) |
| `PG-C.07.01`–`.05` | Cumplida | `LANG.ARRAY.DIMENSION` C5–C11; `semantic/tests/dimension_adoption.rs`; `declaration_parser_tests.rs` | Campos de clase siguen exigiendo `Como tipo` (`field_dimension`) |
| `PG-C.08.01`–`.05` | Cumplida | `LANG.SUBPROGRAM.DECLARATION` C3–C5, `LANG.SUBPROGRAM.RETURN` C5–C8; `unit_parser_tests.rs`, `semantic/tests/return_variable.rs` | Producción `returnVariable` (nodo `ReturnVariable`); ficha de subprogramas sin cambio de identidades porque `Funcion` ya era alias |
| `PG-C.09.01`–`.06` | Cumplida | `LIB.MODEL` (41 funciones, alias D2, C6–C7), `LIB.CORE.RANDOM` C1–C12, `LIB.CORE.TEXT` C5–C7 y C44–C51, `LIB.CORE.CONVERSION` C16–C17; `runtime/tests/random_tests.rs`, `library/src/text_search_tests.rs`; IR O124–O125 | `aot` rechaza `host.random_below/between` como no soportadas (PC-V-05, `PG-N.08`) |
| `PG-C.10.01`–`.10` | Cumplida | 57 especificaciones reescritas (regla 1); 80 pares `Definir … <- 0;`/`Leer` en contenidos (regla 2); gramática TextMate regenerada; `see lock --refresh` de 73 identidades y alta de `LANG.PROGRAM.CLASSIC`; `git grep Mutable` sin apariciones fuera de `LANG.DECL.VARIABLE#C5/#C7` | PC-V-06/07/08/09/10 en §11.1; `flutter analyze`, `check_content`, `check_syntax_coverage`, `pnpm test` en verde |
| `PG-C.11.01`–`.04` | Cumplida | `lang/lang.program.classic.md`: R1 (engine, C1–C20), R2 (cli, C21–C30), R3 (service, C31–C40); vínculos en los cuatro manifiestos | PC-V-03, PC-C-14; `aot` R1 pendiente (`PG-N.08`) |
| `PG-C.12.01` | Cumplida | `see validate` (199 especificaciones), `see lock --check`, `see export --check` en verde | |
| `PG-C.12.02` | Cumplida | `cargo xtask verify` del motor, de SEE y de la CLI con código 0 (`results/pg-c-2026-11-05/logs/f02-*.log`) | Se corrigieron dos problemas heredados de `9d732d46` (límite de `help_resolution.rs` y de `xtask` de la CLI); en la fusión prevaleció la corrección equivalente de `07ecbb3a` |
| `PG-C.12.03` | Cumplida | Motor `cargo test --workspace` (incluido en `xtask verify`); SEE: 299 pruebas | Siete fallos intermedios corregidos: posiciones desplazadas por `Mutable `, recuento de instrucciones y casos con entradas en `function_execution.rs` |
| `PG-C.12.04` | Cumplida con pendientes heredados | engine 2896 observaciones, service 196, cli 157, app 244: 0 divergencias; propiedades engine 32/32, service 8/8, app 3/3; aot: solo `RT.FAULT.REPORTING#R2` y su propiedad P1, ya en falta en la base | Los fallos `aot` son los de la base (argumentos de fallos nativos, tareas y efectos), que resuelve PG-N; ninguna regla tocada por PG-C queda en `incumple` sin estar `pendiente` |
| `PG-C.12.05` | Cumplida | `flutter test` 2690 en verde y 2 omitidas, tras recompilar la biblioteca nativa, `check_*` de la app, benchmarks (29 pruebas, analizador), extensión (35 archivos, 191 pruebas) | Se corrigió un aviso heredado del analizador en `capture_bridge_artifacts.dart` |
| `PG-C.12.06` | Cumplida | `results/pg-c-2026-11-05/perf-suite-core.json`: `PERF.SUITE.CORE` (11 programas, mediana de 15) con binarios release de `9d732d46` y de PG-C: análisis 0,97–1,03, ejecución 0,93–0,98, salidas idénticas; PC-E01 (1 000 ramas en 10 niveles) 8,42 → 8,58 ms | `PERF.AOT.LEVEL` no se volvió a medir: PG-C no cambia `pseudolearn_codegen` salvo declarar dos instrucciones no soportadas |
| `PG-C.12.07` | Cumplida | `rust-checks` (55 pruebas con casos negativos), SEE (fixtures negativos dentro de sus 299 pruebas), verificadores de la app y de la extensión en sus suites | |
| `PG-C.12.08` | Cumplida | Clasificación contra `9d732d46` (*worktree* desacoplado, retirado al terminar) y contra los registros de PG-L de la misma base | |
| `PG-C.12.09` | Cumplida con alcance acotado | CL-10 sin cambios: CLI (`pseudo ejecutar`), protocolo `--editor` que lanza la extensión de escritorio, extensión web en Chromium y WebKit (`tests/web/classic_scenario.ts`), app macOS y simulador iPhone 18 Pro (`integration_test/classic_acceptance_test.dart`) | Firefox «no calificado» como en fases previas; Windows y VS Code de escritorio con interfaz no verificados |
| `PG-C.12.10` | Cumplida | Sondeos repetidos: todas las filas sin diagnóstico salvo `a[3]` en arreglo de tamaño 3 (`arrayIndexOutOfRange`, base 0) | |
| `PG-C.C03`–`C11` | Cumplida | Evidencia de esta tabla, §11.1–§11.4 y READMEs de semantic, syntax, lowering, library, runtime, vm, ir, codegen, abi, api, bytecode, service, SEE, app y extensión | |
| `PG-C.C12.01`, `.02` | Cumplida | Diff revisado sin comentarios, `TODO`, `unwrap`, `expect` ni `panic!` añadidos y sin citas a `docs/`; commits sin atribución de IA | Push ordinario a `feature/agregar-ruta-de-especificacion` |
| `PG-C.C13.01` | Cumplida | Este resumen, §4.16 y §6 del plan general | Parada |

Revisión Git de cierre: fusión de `07ecbb3a` sobre la rama de PG-C · Verificadores ejecutados: `see validate`/`lock`/`export`,
`cargo xtask verify` (motor, SEE, CLI), `rust-checks`, conformidad de los cinco sujetos y sus propiedades, `flutter test`,
`check_*`, `pnpm test`, web Chromium/WebKit, app macOS e iOS · Pendientes justificados: `aot` de azar entero y fallos
nativos (PG-N.08), Windows, Firefox y VS Code de escritorio con interfaz · Puntos de §4 cumplidos: todos.

### 11.1 Registro de hipótesis (`PC-V-01`–`PC-V-10`)

| ID | Resultado | Evidencia |
|---|---|---|
| PC-V-01 | Confirmada: `lower_declare` y SSA ejecutan un local sin valor asignado en las dos ramas y escrito después, por lotes y paso a paso; no hizo falta tocar `statements_declare.rs` | `pseudolearn_api/tests/declaration_without_value.rs` (3 pruebas en verde) |
| PC-V-02 | Confirmada: `statements_for_condition.rs::resolve_step_value` ya emite `ConstI64 1` cuando falta el paso; solo Semantic emitía `missingStepClause` | Lectura del archivo; `LANG.CONTROL.FOR` C18–C21 en verde |
| PC-V-03 | Refutada en parte: un caso `LANG.*` exige perfil `en` o una exclusión justificada (`exclusiones.en`); los casos de `LIB.*` admiten solo `es` | `see_validation/src/references.rs`; `LANG.PROGRAM.CLASSIC` lleva la exclusión en cada caso |
| PC-V-04 | Refutada: el validador exigía exactamente nueve campos en cada fila de D2 | `see_validation/src/resources/capability_library.rs`; se añadió el campo opcional `alias` con su comprobación y tres pruebas |
| PC-V-05 | El sujeto `aot` no usa la tabla de funciones para el azar: `Azar(n)` y `Aleatorio(a, b)` bajan a instrucciones nuevas que `pseudolearn_codegen` declara no soportadas; `cargo check` del motor completo en verde | `instruction_dispatch.rs` (`UNSUPPORTED_OPERATIONS`); `every_operation_is_lowered_or_declared_unsupported` en verde |
| PC-V-06 | Confirmada: la gramática TextMate se genera desde la exportación (`pnpm generate:grammar`) | Gramática regenerada sin `Mutable`; `pnpm check:grammar` y `pnpm test` (35 archivos, 191 pruebas) en verde |
| PC-V-07 | Confirmada: `manifest_es.json`/`manifest_en.json` no llevan hashes; `tool/check_content.dart` sí comprueba que cada programa de «errores frecuentes» produzca el diagnóstico citado | `dart run tool/check_content.dart` en verde tras reescribir los ejemplos |
| PC-V-08 | Las cargas de `packages/pseudolearn_benchmarks` cambian de texto (sin `Mutable`) y no de comportamiento; las procedencias de campañas anteriores registran el SHA de la fuente anterior, así que esas líneas base no son comparaciones de fuente idéntica. No se regeneró ninguna | `git diff 9d732d46 -- packages/pseudolearn_benchmarks` |
| PC-V-09 | Confirmada: `API.ANALYZE#C5`, `TOOL.SERVICE.NAVIGATION` C1/C2/C5/C7, `TOOL.LSP.CAPABILITIES#C14` y `APP.EDITOR.COMPLETION` C12–C15/C20 tenían posiciones, cursores u offsets UTF-16 después de `Mutable `; también las pruebas `api_tests.rs`, `identifier_tests.rs`, `lsp.rs` y `navigation.rs`. Se recalcularon desde el programa nuevo (8 unidades menos tras la palabra) | Conformidad engine, service y app en verde |
| PC-V-10 | Confirmada: `see_generators` genera por semilla en cada ejecución y no hay resultados versionados que dependan de él | `crates/see_generators`; pruebas del generador en verde |

### 11.2 Esperados reescritos

| Caso | Esperado anterior | Esperado nuevo | Regla de la que se deriva |
|---|---|---|---|
| `LANG.DECL.VARIABLE#C4` | `immutableBindingAssignment` | ejecuta `2` | DC-03: toda variable de `Definir` se reasigna |
| `LANG.DECL.VARIABLE#C5` | ejecuta `2` con `Definir Mutable` | `expectedTypeConnector` | DC-02: `Mutable` es un nombre y falta `Como` |
| `LANG.DECL.VARIABLE#C7` | `mutableBindingNeverModified` | `Mutable` como identificador ordinario, ejecuta `1` | DC-02 |
| `LANG.DECL.VARIABLE#C8` | `immutableBindingAssignment` | `Leer` sobre la variable, ejecuta `7` | DC-03 |
| `LANG.DECL.UNINITIALIZED#C1` | `missingBindingInitializer` | declaración sin valor, asignación y lectura: ejecuta `5` | DC-01, DC-05 |
| `LANG.DECL.UNINITIALIZED#C2` | duplicado de C1 | `variableUsedUninitialized` con `cause` `noAssignment`, tramo y declaración relacionada | DC-05 |
| `DIAG.SEVERITY.POLICY#C1`, `C2` | `missingBindingInitializer` | `variableUsedUninitialized` (política A, error) | DC-05 |
| `LANG.TYPES.ENUM#C9`, `LANG.TYPES.RECORD#C15` | `missingBindingInitializer` | `variableUsedUninitialized` | DC-05 |
| `LANG.TYPES.FUNCTION#C3` | captura de un vínculo `Mutable` | captura y reasignación posterior: `mutableClosureCapture` | DC-07 |
| `API.PROGRAM.VIEW#C16` | captura de `Mutable` | captura y reasignación posterior; sin capturas en la vista | DC-07 |
| `API.PROGRAM.VIEW` (vista de variantes) | `mutable` y `initialized` | solo `initialized` | DC-02 |
| `LANG.CONTROL.FOR#C2`, `C11` | `missingStepClause` | ejecuta `123`; análisis sin diagnósticos | DC-09 |
| `LIB.CORE.RANDOM#C1`–`C3` | `azar()` real; `azar(1)` es error de aridad | `AzarReal()` real; `Azar()` es error de aridad | DC-13 |
| `LIB.CORE.TEXT#C6`, `C7` | `Subcadena` con cantidad | `Subcadena("ab", 2, 1)` vacía; `Subcadena("abc", 2, 3)` fuera de rango | DC-13 |
| `RT.HOST.INTERFACE#C1`–`C4`, `TOOL.CLI.RUN` (programa con semilla) | `azar()` | `AzarReal()`, misma secuencia | DC-13 |
| `API.ANALYZE#C5` | `año` en columnas 17–20 | columnas 9–12 | Programa sin `Mutable ` (8 puntos de código menos) |
| `TOOL.SERVICE.NAVIGATION` C1, C2, C5, C7; `TOOL.LSP.CAPABILITIES#C14` | Definición, referencias y cursor de renombrado tras `Mutable ` | Las mismas posiciones 8 caracteres antes | Programa sin `Mutable ` |
| `APP.EDITOR.COMPLETION` C12–C15, C20 | Cursores y selecciones UTF-16 tras `Mutable ` | 8 unidades menos | Programa sin `Mutable ` |
| `APP.EXEC.CONFIGURATION#C2` y texto de R1 | `Para` sin `Con Paso` no se ejecuta | Se ejecuta y escribe `123` | DC-09 |
| `LIB.CORE.TEXT` C49, C50 | Casos de análisis en una regla también verificada por ejecución | Lápidas; los casos pasan a `LIB.MODEL` C6–C7 | La aridad y el tipo se comprueban estáticamente (`LIB.MODEL#R1`) |
| 57 especificaciones con programas `Definir Mutable` | — | mismo programa sin la palabra | Regla mecánica 1 de `PG-C.10` |

### 11.3 Conflictos, `CANDIDATA` fijadas y decisiones de la persona

| ID | Detalle | Resolución |
|---|---|---|
| PC-C-01 | Ámbitos de bloque | Resuelto por DC-08: `LANG.DECL.VARIABLE#R1` ya no dice que las declaraciones no crean ámbitos |
| PC-C-05 | DC-04 elegía una pasada nueva sobre el HIR, pero Semantic ya tenía un análisis por caminos en línea (`session.initialized`) con unión de ramas y hojas de registro | Se usó la reversión que DC-04 prevé: se extendió el análisis en línea (conjuntos A y P, causas, salidas, reasignaciones) en los archivos de §5 (`definite_assignment_state`, `definite_assignment_report`, `output_parameters`, `capture_validation`, `return_variable`). Una pasada nueva habría duplicado el recorrido y el modelo de inicialización. Razonamiento en el README de semantic |
| PC-C-06 | DC-10 decía que la ampliación no cambia la comparación, pero `PG-C.06.02` y CL-04 exigen `"s" = opcion` con `opcion` cadena, que el motor rechazaba | Se aplicó «igual que la ampliación numérica»: en comparaciones mixtas el carácter se amplía a cadena; la concatenación no cambia. `LANG.TYPES.RELATIONS#R1` lo dice y `C29` lo verifica |
| PC-C-07 | DC-05 enumeraba cuatro valores de `cause`; el catálogo exige que todo argumento aparezca en el mensaje y la lectura sin ninguna asignación previa no tiene unión | `cause` es un argumento `termino` presente en el mensaje y se añade `noAssignment`. Mensaje: «La variable {lexeme} puede no tener valor en este punto (causa: {cause})» |
| PC-C-08 | §3.2 no exigía que un parámetro de salida tenga valor al terminar el cuerpo, lo que dejaría sin valor al argumento | Un parámetro de salida debe tener valor también en todo fin del cuerpo (`LANG.SUBPROGRAM.BY-REFERENCE#R1`) |
| PC-C-09 | §3.2 hablaba de «tipo no arreglo»; los registros por referencia se siguen por hoja | Los registros por referencia no son de salida (conservador) |
| PC-C-10 | «Método resuelto estáticamente» no tenía criterio | Son directas las llamadas por nombre, a `Super` y a constructores; un método sobre un objeto se trata como despacho dinámico |
| PC-C-11 | §3.1 no fijaba el tratamiento de `Elegir`, `Tareas` y `Diferir` | `Elegir` une sus ramas como `Segun`; el cuerpo de `Tareas` se ejecuta en secuencia; lo que asigna `Diferir` no cuenta después |
| PC-C-12 | `invalidRandomBound` llevaba el argumento `limit` | Sin argumento: las trampas de la VM no transportan argumentos numéricos sin un cambio de protocolo ajeno a PG-C |
| PC-C-13 | El sujeto `aot` no implementa las instrucciones nuevas de azar | `host.random_below` y `host.random_between` declaradas no soportadas; `LANG.PROGRAM.CLASSIC#R1` en `aot` `pendiente` con `resuelve_en` `PG-N.08`; R2 y R3 exentas |
| PC-C-14 | Una regla con casos de operaciones distintas queda «no aplicable» en un sujeto que solo ejecuta una de ellas (`see_report::measurement`) | `LANG.PROGRAM.CLASSIC` se dividió en R1 (engine), R2 (cli) y R3 (service) con vínculos `exento` justificados donde no aplican |
| `CANDIDATA` | `initializerWithMultipleNames`, `dimensionWithoutType`, `returnVariableNotDeclared`, `returnValueInReturnVariableFunction`, `invalidRandomBound`, `invalidRandomRange`, `randomUnit` (`AzarReal`/`randomReal`), `LANG.PROGRAM.CLASSIC` | Fijadas sin cambio de nombre. Nuevas: `randomBetween` en inglés, `concatenate`/`concat`, nodo `ReturnVariable`, instrucciones `host.random_below` (O124) y `host.random_between` (O125) |
| Commits | `AGENTS.md`/skill `commit-message`: sin atribución de IA | Se respetó; ningún commit lleva coautoría |
| `DC-P1` | Parámetros sin tipo | No implementado (sin aprobación) |

### 11.4 Hallazgos fuera de alcance

Cerrados el 2026-11-06 a petición de la persona («cerrar los pendientes que PG-C dejó registrados», eligiendo siempre
la opción recomendada), sin reabrir PG-C: ninguna decisión de §3 ni de §11.3 cambia.

| Hallazgo | Evidencia | Estado y resolución |
|---|---|---|
| `Definir i Como Entero;` seguido de `Para i <- …` producía `bindingShadowsOuter` y `variableDeclaredNeverUsed` | Sondeo `p04` | **Resuelto.** `LANG.CONTROL.FOR#R4` amplía la regla: si el bloque inmediato tiene una variable homónima `Entero` de `Definir`, no parámetro, sin valor y sin lecturas ni escrituras (salvo como control de otro `Para` del bloque), `Para` la reutiliza sin avisos; el control sigue siendo local y la variable sigue sin valor tras el bucle. Casos C22–C27 y `LANG.PROGRAM.CLASSIC` C41–C42; `semantic/src/for_control_reuse.rs` y `tests/for_control_reuse.rs`; README de semantic. Decisión propia: reutilizarla no cuenta como uso, para admitir varios `Para` consecutivos |
| Palabras reservadas que chocan con nombres clásicos (`Codigo`, `Hacer`) | `LANG.PROGRAM.CLASSIC`; casos de `LANG.TYPES.FUNCTION` | **Resuelto.** `Codigo`/`code` sale de D1 de `LANG.PROFILE.VOCABULARY` y queda solo en D2 (contextual); nueva `R2` con C3–C5 y cobertura `V254`. El parser de miembros ya aceptaba identificadores tras el punto; semantic toma el nombre del campo de `ErrorJson` de la grafía contextual y `service/src/contextual_members.rs` lo traduce solo cuando el receptor es un registro de biblioteca, de modo que un campo `Codigo` del usuario conserva su nombre. `Hacer` sigue reservada porque cierra cabeceras de `Para`, `Mientras` y `Segun`. Gramática TextMate regenerada. READMEs de syntax, semantic y service |
| El mensaje de `variableUsedUninitialized` mostraba la causa como término técnico | Catálogo | **Resuelto.** Nueva D2 `diagnosticTerms` de `DIAG.CATALOG` (texto es/en por código, argumento y término) y `R2` con casos `cli` C3–C8; `see_validation/src/resources/diagnostic_terms.rs` con casos negativos; `pseudolearn_diagnostics` genera `term_text` y `render` sustituye el término solo al presentar el mensaje; el argumento `cause` no cambia. Vínculos: `cli` `cumple`, engine `exento` |
| El exportador Rust de la app conservaba valores fijos para `Azar`, `Aleatorio` y `AzarReal` | `rust_expression_rules.dart` | **Resuelto.** Las tres ya estaban bloqueadas por `ExportCoverage` (no figuran en las incorporadas de `rustExportSupport`), así que los valores fijos eran inalcanzables: se retiraron y una prueba fija los bloqueos `builtin:random`, `builtin:randomBetween` y `builtin:randomUnit` con su rango. README de la app |
| Paridad `aot` del azar entero (`host.random_below`/`host.random_between` no soportadas) | `UNSUPPORTED_OPERATIONS` | **Resuelto**, compatible con `PG-N.08` (es la biblioteca nativa que esa fase acredita). `rt_aot_random_below`/`rt_aot_random_between` usan el mismo `RandomState` sembrado y el mismo rechazo sin sesgo que la VM y las mismas trampas; `lower_io` las baja. `see conform --subject aot`: `LIB.CORE.RANDOM` 24 observaciones y `LANG.PROGRAM.CLASSIC` 42, sin divergencias. `LANG.PROGRAM.CLASSIC#R1` y `LANG.PROFILE.VOCABULARY#R2` pasan en `aot` de `pendiente` a `exento`: sus casos de ejecución pasan, pero la regla mezcla casos de análisis que `aot` no mide (mismo motivo que PC-C-14) |
| `stringPositionOutOfRange` nativo sin `length` ni `position` (`RT.FAULT.REPORTING#R2`, P1) | Propiedad P1 | **Resuelto.** `aot_rt/src/effect_text_faults.rs` completa la trampa de las operaciones locales de texto con la fórmula de la VM. P1 `cumple` (100 muestras). Propiedades `aot` completas: 14 `cumple`, 4 `pendiente` por capacidades no anunciadas, como antes |
| **Nuevo.** La VM informa `position` = inicio + tercer argumento de `Subcadena`, una fórmula de la antigua firma con cantidad; con `Subcadena(texto, primero, último)` de PG-C la posición informada no es la que falla (`Subcadena("abc", 2, 3)` informa 5) | `vm/src/machine/fault_context/text_effects.rs` | **Pendiente**, sin corregir: cambia un mensaje observable de la VM y la paridad exige que `aot` la copie. Propuesta: fijar en `LIB.CORE.TEXT` qué posición se informa y corregir VM y `aot` a la vez |
| Verificación por plataforma (Firefox en la extensión web, VS Code de escritorio con interfaz) | §11, `PG-C.12.09` | **No verificado**, por decisión de la persona del 2026-11-06 de cerrar sin las corridas de plataforma. Firefox además no se puede lanzar sin descargar el Firefox de Playwright, que no está instalado. Windows y dispositivos físicos siguen sin verificar |

Verificadores de este cierre: `see validate` (199 especificaciones), `see lock --refresh` de `LANG.CONTROL.FOR`,
`LANG.PROGRAM.CLASSIC`, `DIAG.CATALOG`, `LANG.PROFILE.VOCABULARY` e `IR.INSTRUCTIONS`, `see export --check`;
`cargo xtask verify` del motor, de SEE (incluye engine, 2922 observaciones sin divergencias) y de la CLI; `see conform`
service (198, 8 propiedades), cli (169) y app (244, 3 propiedades) sin divergencias; propiedades `aot`; `flutter test`
(2692 en verde, 2 omitidas), `flutter analyze` y `check_*` de la app; `pnpm test` (35 archivos, 191 pruebas). Disco: se
limpiaron los destinos `cargo` del *worktree* antiguo de PG-C (≈ 30 GiB), `flutter clean` de la app (4,7 GiB), cachés
`incremental` y `cargo clean` del motor tras su verificación (13,2 GiB). La evidencia local desfasada de `results/` se
conservó renombrada con el sufijo `stale-pg-c-pendientes`, y el anclaje local se tomó del *worktree*, que coincidía con
HEAD.
