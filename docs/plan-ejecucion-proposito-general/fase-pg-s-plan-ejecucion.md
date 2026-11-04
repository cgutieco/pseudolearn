# Fase PG-S · Biblioteca estándar de producción — plan de ejecución

## 0. Metadatos y contrato de ejecución

- Fase: PG-S (§4.14 del [plan general](plan-ejecucion-proposito-general.md)). Origen: §A.8.2 (N-01–N-08) y §B.3b del
  [análisis del 2026-11-02](analisis-lenguaje-completo-sin-simulacion.md); requisitos RQ-1–RQ-7 y decisiones D-01–D-19
  aceptadas ese día.
- Fecha de redacción: 2026-11-04, America/Lima. Revisión Git inspeccionada: `f62a386b`, rama
  `feature/agregar-ruta-de-especificacion`, árbol limpio.
- Autorización de la persona: **ninguna todavía** (`PG-S.C01` pendiente). Este documento es el plan detallado de
  `PG-S.C02`: crearlo no autoriza ejecutarlo. La persona lo revisa antes de cualquier especificación o código.
- Dependencias de la fase según §3 del plan general: PG-B y PG-L. Ninguna está cerrada (ver §1.1). Este plan se puede
  revisar ya; **no se puede ejecutar** hasta superar la puerta G0 de §10.
- Documento transitorio: ninguna especificación, README ni código fuera de `docs/` puede citarlo
  (`DOC-NO-TRANSIENT-REFS`). Cada decisión de §3 se traslada a su dueño (corpus o README del miembro) en el mismo
  cambio que la implementa (`DOC-README-TRUTH`, `DOC-NO-ORPHAN-DECISION`).

### 0.1 Reglas para quien ejecute (anti-alucinación)

1. Este plan separa tres clases de afirmación, rotuladas siempre:
   **Comprobado** (`PS-H-nn`: lo vi en el repositorio en `f62a386b`, con ruta), **Hipótesis** (`PS-V-nn`: parece
   cierto pero nadie lo comprobó; trae el comando que lo confirma o desmiente) y **Propuesta** (`CANDIDATA`: nombre,
   firma o diseño que el corpus aún no decide). Una hipótesis no es un hecho: la primera tarea que la usa la verifica y
   registra el resultado en §11. Una propuesta no es sintaxis final (§5.5 del plan general).
2. Ningún nombre de archivo, función, tipo, regla o ID que aparezca aquí como «propuesto» existe hasta que se crea. No
   se cita como prueba de que una API lo admite. Antes de editar un archivo, abrirlo; antes de usar un símbolo,
   buscarlo (`grep`) en el árbol actual.
3. Si HEAD cambió desde `f62a386b`, repetir las comprobaciones de §1.2 antes de seguir y anotar las diferencias en §11.
   Conservar cambios ajenos del árbol.
4. Secuencia obligatoria por punto: especificación → casos con esperado **derivado de la regla** → tests que fallan por
   ausencia → código → README y reglas → verificación (`SPEC-FIRST`, `SPEC-INDEPENDENT-ORACLE`). Prohibido copiar al
   esperado la salida del motor.
5. `SPEC-VERSION-FREEZE`: las identidades existentes conservan estado y versión; el texto oficial se edita sobre la misma
   identidad, sin campo `cambio`, y se reancla con `see lock --refresh` listando en una sola orden todos los IDs
   editados. Las identidades nuevas nacen en estable `1.0.0` sin `cambio`. No se borran reglas: se reescriben.
6. `GEN-NO-HAND-COPY`: `packages/pseudolearn_spec/specifications/export.json` y los recursos que los `build.rs` generan en
   `OUT_DIR` jamás se editan a mano; se regeneran con la orden del miembro (`see export`, `cargo build`).
7. Contradicción entre fuentes: se reporta con ID, texto y alcance y se espera decisión (`CONFLICT-REPORT`). Los
   conflictos ya conocidos están en §9.
8. Cero simulación (RQ-3) y cero concesiones (RQ-1): ninguna operación nueva puede devolver datos preparados, reloj
   lógico en vivo ni exigir un permiso. El doble de prueba del corpus (anfitrión de memoria) sigue siendo la única
   excepción y es inalcanzable desde CLI, extensión y app.
9. Al terminar el alcance autorizado: informar y parar (`PHASE-STOP`). Las puertas de §10 no amplían una autorización
   parcial; la autorización de la persona puede ser por punto (precedente: PG-1, PG-B).

## 1. Punto de partida comprobado

Rutas relativas a la raíz del repositorio. Todo lo de §1.2 se leyó en `f62a386b`; **no se ejecutó ninguna suite** para
redactar este plan.

### 1.1 Dependencias y puertas previas

| ID | Evidencia | Tratamiento exigido |
|---|---|---|
| PS-P-01 | PG-L figura «Sin iniciar» y sin plan detallado en §6 del plan general | Puerta G0: PG-L completada o decisión expresa de la persona de iniciar PG-S antes (en ese caso, §3 DS-13 fija qué se vuelve a verificar) |
| PS-P-02 | §4.11 marca `PG-B.10`–`PG-B.30` como `[x]`, pero la fila de PG-B en §6 dice «.10–.30 sin iniciar», «C01/C02 pendientes» y no registra revisión de cierre | Reportar la contradicción a la persona (`CONFLICT-REPORT`); no cerrar PG-B desde PG-S |
| PS-P-03 | `docs/plan-ejecucion-proposito-general/` no contiene `fase-pg-l-plan-ejecucion.md` | Sin plan de PG-L no hay lista de archivos que PG-L tocará; al iniciar PG-S, releer los README de `semantic`, `lowering` y `service` (PG-L los reescribe) |
| PS-P-04 | Línea base de pruebas de `f62a386b` desconocida (no se ejecutó) | Tarea `PG-S.C11.01`: ejecutar y registrar la línea base de los miembros afectados antes del primer cambio |

### 1.2 Hechos comprobados

**Corpus y generación**

- `PS-H-01` `packages/pseudolearn_spec/specifications/lib/lib.model.md` (`LIB.MODEL`, estable 1.0.0, sujetos `reference`,
  `engine`, `aot`) contiene tres bloques de datos: **D1** `functions` (28 funciones incorporadas: 12 de familia `numbers`
  —`squareRoot, absoluteValue, naturalLogarithm, exponential, sine, cosine, arcTangent, truncate, round, random,
  textToInteger, textToReal`—, 14 `text` y 2 `collections`), **D2** `capabilityLibrary` (62 operaciones con `identity`,
  `family`, `receiver`, `es`, `en`, `parameters`, `result`, `effect`, `fallible`) y **D3** `channelLibrary`. El análisis
  del 2026-11-02 hablaba de 84 nombres: el recuento cambió tras `f62a386b`; usar los de aquí y repetirlos en `PS-V-01`.
- `PS-H-02` Las reglas de `LIB.MODEL` relevantes: `R1` (declaración y comprobación estática de aridad/tipos), `M1`
  (identidad única, facetas es/en con la misma firma, efecto y falibilidad), `M2` (formas únicas por perfil), `M3`
  (cada identidad tiene ficha de ayuda es/en; su ausencia invalida el corpus) y `M4` (familias permitidas:
  `text, bytes, numbers, collections, io, time, json, network, tasks`).
- `PS-H-03` `export.json` es generado y contiene `resources.functions`, `resources.capabilityLibrary`,
  `resources.helpCatalog` (147 fichas, formato `help-catalog/1`), `resources.vocabulary`,
  `resources.contextualVocabulary`, `resources.diagnostics`, entre otros. Las fuentes de las fichas y de varios recursos
  son `packages/pseudolearn_spec/specifications/cases/catalogs.json` y `cases/vocabulary.json`.
- `PS-H-04` `packages/pseudolearn_engine/crates/pseudolearn_lexicon/build.rs` genera `BuiltinKind` y las firmas a partir de
  `resources.functions` (D1). `crates/pseudolearn_abi/build.rs` genera `EFFECT_OPERATIONS` a partir de
  `resources.capabilityLibrary.operations` **más** una lista fija `TEXT_FUNCTIONS` (`substring … trim`) tomada de D1; su
  función `value_kind` es la lista cerrada de tipos de dato de efecto admitidos.
- `PS-H-05` `crates/pseudolearn_abi/src/effect_operation.rs` define `EffectValueKind` (24 variantes: `Integer, Real,
  Boolean, Text, Bytes, TextList, JsonValue, JsonResult, JsonKind, Optional{Boolean,Integer,Real,Text,JsonValue},
  Console, Arguments, Directory, File, Clock, Timer, Network, HttpMethod, HttpRequest, HttpResponse`).
  `crates/pseudolearn_runtime/src/host_effect.rs` define `HostValue` con las variantes correspondientes.
  `crates/pseudolearn_semantic/src/effect_types.rs` resuelve nombres de tipo (`Bytes`, `PeticionHttp`, `ErrorES`, …) y
  traduce `EffectValueKind` a tipos del lenguaje.

**Camino de una función incorporada y de una operación de biblioteca**

- `PS-H-06` Las 12 funciones numéricas de D1 bajan a operaciones de RI propias (`crates/pseudolearn_lowering/src/
  expressions_builtins.rs`: `MathSqrt, MathAbs, MathLn, MathExp, MathSin, MathCos, MathAtan, RealTrunc, RealRound, …`);
  su tipado vive en `crates/pseudolearn_semantic/src/builtin_checker.rs` (ampliación entero→real cuando el parámetro es
  `numeric`/`real`; retorno fijo o `sameAsFirstArgument`) y en `crates/pseudolearn_ir/src/type_checker_intrinsics.rs`.
  El generador nativo las baja en `crates/pseudolearn_codegen/src/lower_math.rs`.
- `PS-H-07` Las funciones de texto `Contains … Trim` están mapeadas a `Operation::Unreachable` en
  `expressions_builtins.rs`; se ejecutan como operaciones de biblioteca (`HirExpression::Effect` →
  `crates/pseudolearn_lowering/src/effect_values.rs`). Las operaciones **locales** (`effect: false`) las atiende
  `pseudolearn_library::local_operation` (`crates/pseudolearn_library/src/local_operation_dispatch.rs`), que despacha
  por `operation.family` (`text`, `bytes`, `json`, `network`) hacia `local_operations.rs`. La VM la invoca en
  `crates/pseudolearn_vm/src/machine/effects.rs` (`complete_local_effect`) y el sujeto nativo en
  `crates/pseudolearn_aot_rt/src/effects.rs` (`local_reply`). Sin coincidencia cae a `pseudolearn_runtime::local_effect`.
- `PS-H-08` Precedente de operaciones libres sin receptor y puras en D2: `bytes_from_text` (`BytesDesdeTexto`),
  `json_parse` (`AnalizarJson`), `json_null`, etc. Precedente de tipos opacos con métodos: `Bytes`, `ValorJson`,
  `PeticionHttp`/`RespuestaHttp` (valor opaco en el montón, accesores como operaciones con receptor).
- `PS-H-09` Los métodos de vector (`Agregar`, `Insertar`, `Eliminar`, `Longitud`) y de diccionario (`Buscar`,
  `Eliminar`, `Longitud`) **no** están en `LIB.MODEL`: son vocabulario contextual (`lang.profile.vocabulary.md`, recurso
  `contextualVocabulary`) comprobado por `crates/pseudolearn_semantic/src/collection_checker.rs` y
  `collection_model.rs`, bajado por `crates/pseudolearn_lowering/src/collections.rs` a operaciones de RI
  (`CollectionInsert`, …; correspondencia en `crates/pseudolearn_ir/src/collection_types.rs`) con `CollectionCommand`
  de `pseudolearn_abi`; la ejecución está en `crates/pseudolearn_library/src/collections.rs` y
  `crates/pseudolearn_aot_rt/src/collections.rs`.
- `PS-H-10` `lang.types.vector.md` (`R1`–`R3`) y `lang.types.dictionary.md` (`R1`–`R3`): colecciones por referencia,
  versión estructural `u32`, atomicidad («comprueban tamaño antes de modificar»), límites `cells`, `collectionLimitExceeded`
  y `cellLimitExceeded`. Reemplazar un elemento no cambia la versión. El diccionario **no tiene** accesor de claves.
- `PS-H-11` `crates/pseudolearn_codegen/src/instruction_dispatch.rs`: toda `Operation` de la RI debe estar bajada en
  `FAMILIES` o listada en `UNSUPPORTED_OPERATIONS` (la función `is_accounted_for` existe para una prueba). Un módulo con
  una operación no bajada produce `CodegenError::Unsupported`.

**Anfitrión, cinta y consumidores**

- `PS-H-12` `crates/pseudolearn_host/src/physical_host.rs`: `PhysicalHost::perform` despacha por nombre de operación
  (`console_write`, `arguments_values`, `clock_now`, `timer_wait`, `request_directory`, `request_*`, `network_*` y el
  resto a `file_operation` en `physical_files.rs`). `physical_paths.rs` define `DirectoryResource::{Ambient, Confined}`
  (cap-std); `physical_error.rs::HostError::from_io` solo distingue `NotFound`, `PermissionDenied`, `AlreadyExists`,
  `InvalidInput` y manda el resto a `interrumpido`. `physical_request.rs::mode_rights` acepta `lectura/escritura/
  lectura_escritura` (y sus equivalentes en inglés); `write_all` reemplaza el contenido (`set_len(0)`).
  `architecture.yaml` declara las dependencias externas de `pseudolearn_host` (sin ninguna biblioteca de fechas).
- `PS-H-13` `crates/pseudolearn_runtime/src/memory_host.rs` y `memory_host_files.rs`: doble de prueba del corpus. Debe
  conocer cada operación nueva que los casos del corpus ejerzan.
- `PS-H-14` Salida del programa: `crates/pseudolearn_vm/src/machine/effect_completion.rs` añade el texto a la salida
  del motor cuando se confirma `console_write`; el anfitrión físico solo devuelve la longitud. No existe flujo de error
  ni código de salida elegido por el programa.
- `PS-H-15` `ENG.EFFECT.TAPE#R3`: `capability_kind` toma un valor del vocabulario cerrado
  `console, arguments, filesystem, clock, timer, network`. `#R5`: argumentos secretos se sustituyen por
  `SecretHandle {key_id, value_hmac}`; `crates/pseudolearn_runtime/src/secret_policy.rs` detecta secretos **por valor**
  declarado en la configuración del anfitrión (`secrets`, `secret_keys`); sin almacén de resolución la cinta se sella
  `NonReproducibleRedacted`.
- `PS-H-16` `RT.HOST.INTERFACE#R1/R2`: autoridad plena por omisión y toda capacidad del anfitrión es grabable.
  `LIB.IO#R2`: `ErrorES` es una lista cerrada de variantes (no incluye «directorio no vacío» ni «es un directorio»).
  `LIB.TIME#R1/R2`: `Reloj` devuelve nanosegundos desde la época Unix, grabados en cinta.
- `PS-H-17` Consumidores de operaciones de anfitrión: CLI (`apps/pseudolearn_cli/src/`: `editor_effects.rs`,
  `dap_effects.rs`, `dap_pump.rs`, `adapter.rs`), extensión web (`apps/pseudolearn_vscode/src/adapters/
  browser_effect_host.ts` despacha por nombre de operación; `browser_file_host.ts` usa `vscode.workspace.fs`), puente de
  la app (`apps/pseudolearn_app/native/`, que usa `pseudolearn_host` según su README) y exportación de código de la app
  (`apps/pseudolearn_app/lib/engine/rust/export/{rust,python}_expression_rules.dart`, `export_support.dart`,
  `export_coverage.dart`, escritos a mano).
- `PS-H-18` Contratos que hoy contradicen lo que PG-S añade (se resuelven según el plan de PG-N, ver §9):
  `RT.PROCESS#R2` (códigos 0/3/4/5), `RT.PROCESS#R3` («no depende de variables de entorno») y `TOOL.CLI.RUN#R2`
  («0 si completed, 1 en cualquier otro caso»).
- `PS-H-19` `Salir` ya existe en el lenguaje y significa «terminar el bucle interior» (`LANG.CONTROL.EXIT#R1`). El
  nombre no puede reutilizarse para terminar el programa.
- `PS-H-20` Mecanismo de pendientes del sujeto nativo: `packages/pseudolearn_engine/conformance-aot.yaml` admite
  vínculos con `"estado": "pendiente"` y `"resuelve_en": "<ID de fase>"` (hoy 80, p. ej. `PG-4.12`).
  `conformance.yaml` (engine) y `conformance-service.yaml` son los otros archivos de vínculos del motor.
- `PS-H-21` Precedente de huella al añadir una familia de biblioteca: el commit `62023207` («add bilingual text, bytes, and
  JSON library», 120 archivos) tocó, entre otros: `lib.model.md`, `lib.core.{text,bytes}.md`, `lib.json.md`,
  `diag.catalog.md`, `diag.messages.md`, `ir.instructions.md`, `eng.limits.md`, `lang.profile.vocabulary.md`,
  `cases/{catalogs,vocabulary}.json`, `property-conformance.json`, `schemas/{properties-1,see-1}.schema.json`,
  `see_validation/src/resources/{capability_library,library_facets,lexicon}.rs` y
  `help_catalog/{coverage,coverage_inventory,coverage_presentation,references}.rs`, fixtures de
  `fixtures/help-catalog/`, `pseudolearn_abi`, `pseudolearn_runtime`, `pseudolearn_semantic`, `pseudolearn_lowering`,
  `pseudolearn_library`, `pseudolearn_vm`, `pseudolearn_aot_rt`, `pseudolearn_syntax/codegen/contextual.rs`,
  `conformance*.yaml` y los README de todos ellos. El commit `f62a386b` (tipos HTTP) añadió además el trabajo de
  `pseudolearn_service` (`effect_tokens.rs`, `identifier_roles.rs`, `translator.rs`). **Esa lista es la plantilla de
  huella de PG-S**; no es exhaustiva ni vinculante.
- `PS-H-22` El oráculo independiente de matemática vive en `packages/pseudolearn_spec/crates/see_oracles/src/
  transcendentals.rs` (y `interval.rs`, `rounding.rs`, `exact_power.rs`); el contraste lo usa
  `see_conformance/src/math_contrast.rs` (`MathFunction`). La implementación bajo prueba está en
  `crates/pseudolearn_library/src/transcendental/` y `precision/`; el contraste masivo contra el oráculo se describe en
  `crates/pseudolearn_math_probe/README.md`. La regla vigente (`LIB.CORE.MATH#R1`) exige el binario64 más cercano al
  valor exacto, empates al par, incluidos subnormales y ceros con signo; dominio inválido, infinito o NaN →
  `nonFiniteRealResult`. `LIB.CORE.ROUNDING#R1`: `redon` aleja los empates de cero; fuera de rango → `integerOverflow`.
- `PS-H-23` Reglas de límites de código del motor (`packages/pseudolearn_engine/architecture.yaml`): archivo ≤ 300
  líneas, función ≤ 40, parámetros posicionales ≤ 4, anidación ≤ 3, métodos públicos por clase ≤ 7; `unsafe` solo en
  `pseudolearn_wasm`, `pseudolearn_aot_rt`, `pseudolearn_native_probe`.

### 1.3 Hipótesis por verificar (no usar como hecho)

| ID | Hipótesis | Comando o lectura que la confirma | Dónde se consume |
|---|---|---|---|
| PS-V-01 | D1 tiene 28 entradas y D2 62 (recuento actual) | `python3` sobre `lib.model.md` como en §7.5, o `jq` sobre `export.json` | S.01 |
| PS-V-02 | Una operación D2 con `receiver: null`, `family: "text"`, `effect: false` se resuelve como llamada libre por `semantic` y se despacha por `local_operation` sin tocar la RI | Leer `crates/pseudolearn_semantic/src/effect_checker.rs` y `effect_types.rs`; buscar cómo se resuelve `BytesDesdeTexto`; prueba mínima en `S.01.03` | S.01, S.08 |
| PS-V-03 | El traslado `numeric` → `Real` de `value_kind` basta para que un argumento entero entre a una operación D2 con parámetro real | Buscar el ensanchamiento de argumentos de `HirExpression::Effect` en `semantic` | S.03, S.08 |
| PS-V-04 | Los fallos de operaciones locales (`MemoryError` → `memory_fault`) pueden llevar un código de diagnóstico propio (p. ej. `stringPositionOutOfRange` lo hace hoy) | `crates/pseudolearn_library/src/error.rs`, `pseudolearn_vm/src/machine/memory.rs` | S.01, S.08 |
| PS-V-05 | La RI no tiene instrucción de selección condicional barata para `min`/`max` | `spec` `ir.instructions.md` y `crates/pseudolearn_ir/src/operation.rs` | S.03 |
| PS-V-06 | `lowering` puede sintetizar funciones auxiliares (precedente: `crates/pseudolearn_lowering/src/task_wrappers.rs`) y llamarlas con la misma ruta de llamadas indirectas que una clausura de usuario | Leer `task_wrappers.rs`, `expressions_complex.rs::lower_call`; experimento `PS-E02` | S.02 |
| PS-V-07 | Las sentencias de una función sintetizada no aparecen en la traza ni consumen presupuesto de sentencias visible al usuario | Leer `ir.observation-points`, `ENG.TRACE.EVENTS`; `PS-E02` | S.02 |
| PS-V-08 | El tipo función admite marcar «suspendible» y se puede rechazar un comparador suspendible en compilación | `lang.types.function.md`, `lang.task.suspension.md`, `crates/pseudolearn_semantic/src/` (buscar `Suspendible`) | S.02 |
| PS-V-09 | El flujo de la salida del motor (cadena única) lo consumen API, CLI, protocolo de editor, DAP, timeline, app y extensión; añadir un segundo flujo cruza todos | `grep -rn "output" crates/pseudolearn_api crates/pseudolearn_timeline apps/pseudolearn_cli/src apps/pseudolearn_vscode/src`; `api.execute.md`, `api.wire-format.md` | S.07 |
| PS-V-10 | Agregar un valor opaco nuevo (`DateTime`) exige: variante en `EffectValueKind`/`HostValue`, esquema de palabras en `host_words.rs`, tipo en `effect_types.rs`, serialización JSON hacia anfitriones y cinta, y presentación de valores en API | Seguir `HttpRequest`/`JsonValue` en los crates citados en `PS-H-21` | S.05 |
| PS-V-11 | `unicode`: las tablas de `str::to_uppercase`/`to_lowercase` de la cadena `rust-toolchain.toml` son idénticas en nativo, Wasm y las demás plataformas del mismo toolchain | Leer `rust-toolchain.toml` de cada miembro Rust; prueba de igualdad por plataforma | S.01 |
| PS-V-12 | La exportación de código de la app (`export_support.dart`) clasifica una función de biblioteca desconocida como «sin equivalente» y no falla | Leer `export_support.dart` y `export_coverage.dart`; ver cómo se trató `Bytes`/JSON | S.09 |
| PS-V-13 | `see conform --subject aot` informa `pendiente` (no `incumple`) para un vínculo con `resuelve_en` | `see conform --subject aot --only LIB.CORE.TEXT` tras añadir un vínculo pendiente | S.01 |
| PS-V-14 | La extensión de escritorio ejecuta por el CLI (`pseudo ejecutar --editor`), de modo que un cambio en el anfitrión físico alcanza escritorio sin código propio | `apps/pseudolearn_vscode/README.md`, `src/adapters/node_process_launcher.ts` | S.09 |

### 1.4 Lo que esta fase no cambia

- No se crean construcciones sintácticas nuevas del lenguaje salvo los miembros contextuales de colección de PG-S.02
  (vocabulario, no gramática). Sin excepciones (D-17), sin clases abstractas ni estáticos (D-16), sin servidor HTTP,
  sockets, procesos hijos ni FFI (D-18), sin registro de paquetes (D-19).
- No se toca `RT.PROCESS` ni el ejecutable nativo: su reescritura es `PG-N.01`. La paridad nativa de la biblioteca es
  `PG-N.08`.
- No se cambia el modelo de autoridad: autoridad plena por omisión, atenuación voluntaria (`Limitar`, `Subdirectorio`).
- No se retoca la política de red ni el cliente HTTP.
- No se implementan zonas horarias con nombre (`America/Lima`), calendarios no gregorianos, segundos intercalares,
  localización de números ni de mayúsculas por idioma. Quedan fuera por `SCOPE-YAGNI` y se documentan en el README de la
  biblioteca como límites.

## 2. Lectura realizada y lectura de entrada obligatoria

### 2.1 Fuentes consultadas para redactar este plan

- [ ] `AGENTS.md` (§1–§10) y `docs/plan-ejecucion-proposito-general/plan-ejecucion-proposito-general.md` (§0–§6).
- [ ] [analisis-lenguaje-completo-sin-simulacion.md](analisis-lenguaje-completo-sin-simulacion.md): §0, §A.6, §A.8, §B.3a–c, §B.5, §B.6.
- [ ] `packages/pseudolearn_engine/README.md` (secciones 1–4) y `architecture.yaml` completo.
- [ ] `packages/pseudolearn_engine/crates/pseudolearn_library/README.md` y `crates/pseudolearn_host/README.md`.
- [ ] Corpus: `lib.model.md` (D1, D2, `R1`, `M1`–`M4`), `lib.core.{math,rounding,text,conversion,random}.md`, `lib.io.md`
  (`R2`, `R3`), `lib.time.md`, `lang.types.{vector,dictionary,generic,function}.md`, `lang.control.exit.md`,
  `rt.host.interface.md`, `rt.process.md`, `eng.effect.tape.md` (`R3`, `R5`), `tool.cli.run.md` (`R1`–`R7`).
- [ ] Código leído de forma parcial (cabeceras y puntos de despacho, no íntegro): ver `PS-H-04`–`PS-H-17`.
- [ ] **No leído y por leer antes de la tarea que lo usa**: `lib.core.bytes.md`, `lib.json.md`, `api.execute.md`,
  `api.wire-format.md`, `api.program.view.md`, `tool.service.catalog.md`, `tool.dap.md`, `ir.instructions.md`,
  `diag.catalog.md`, `diag.messages.md`, `lang.profile.vocabulary.md`, `lang.capability.model.md`, `app.exec.*`,
  README de `abi`, `runtime`, `semantic`, `lowering`, `bytecode`, `vm`, `aot_rt`, `codegen`, `service`, `api`,
  `pseudolearn_spec`, `pseudolearn_cli`, `pseudolearn_vscode`, `pseudolearn_app` y `apps/pseudolearn_app/native`.

### 2.2 Antes del primer cambio (tarea `PG-S.C11.01`)

1. `git status`, `git rev-parse --short HEAD`, `git branch --show-current` (debe ser `feature/agregar-ruta-de-especificacion`).
2. Releer `AGENTS.md`, README y reglas de cada miembro que se vaya a tocar (los de §2.1 «por leer»).
3. Responder por escrito, para cada archivo nuevo o modificado de §5, las tres preguntas de `AGENTS.md` §1. §5 trae las
   respuestas esperadas; si el árbol las contradice, mandan el árbol y el README (`CONFLICT-REPORT`).
4. Ejecutar la línea base de §7.4 y registrarla en §11.

## 3. Decisiones de diseño

Las decisiones marcadas **Persona** cambian comportamiento observable o añaden superficie no pedida literalmente por la
hoja de ruta; el plan propone una elección, pero queda **sin ejecutar** hasta que la persona la confirme al revisar
`PG-S.C02`. Las demás las toma la IA a cargo y se registran en el README dueño.

| ID | Decisión | Opciones | Criterio | Elección propuesta | Reversión |
|---|---|---|---|---|---|
| DS-01 | Vía de las operaciones **puras** de texto, formato y fecha (PG-S.01, .05, .08) | (a) operaciones D2 `receiver: null`/`effect: false` despachadas por `local_operation`; (b) funciones D1 con operación de RI; (c) biblioteca escrita en PseudoLearn | `LIB.MODEL` ya usa (a) para `bytes_*`/`json_*` «sin instrucciones de RI nuevas» (`PS-H-08`, README de `pseudolearn_library`); el sujeto nativo comparte `local_operation` (`PS-H-07`); (b) toca RI, bytecode, VM y codegen; (c) exige un prelude y genéricos exportables (PG-L.03) | **(a)**, verificando `PS-V-02` en la tarea `S.01.03` | Si `PS-V-02` falla (la ruta D2 no admite llamadas libres puras de texto), parar y reportar; (b) solo con ADR propio |
| DS-02 | Vía de las funciones **numéricas** (PG-S.03) | (a) D1 + operaciones de RI como `sen`/`atan`; (b) D2 locales | (a) conserva el tipado `numeric` con ampliación, la trampa `nonFiniteRealResult`, el camino rápido de la VM y el precedente exacto de las 12 funciones existentes (`PS-H-06`); (b) paga una llamada de efecto por cada `sin` y no puede expresar un retorno «el más ancho de los dos» | **(a)** para `tan, asin, acos, atan2, log10, log2, floor, ceil, min, max` | Si el coste de tocar RI + bytecode + VM + codegen excede el presupuesto de la persona, volver a (b) para las trascendentes y documentar el coste medido |
| DS-03 | `min`/`max`: tipo del resultado | (a) devuelve el tipo más ancho de los dos argumentos (entero si ambos enteros, real si alguno real); (b) siempre real; (c) dos pares de nombres | (a) es lo que espera quien viene de Java/Python/C# y evita `min(3,4)` → `3.0`; requiere una clase de retorno nueva en la firma de D1 (`widestNumeric`, **CANDIDATA**) y su tratamiento en `builtin_checker.rs` | **(a)**. Semántica: con reales, `min(-0,0)` es `-0` y `max(-0,0)` es `0` (orden total sobre el bit de signo); sin NaN porque los reales son finitos | Si `PS-V-05` muestra que no hay selección barata, añadir cuatro operaciones de RI (`IntMin, IntMax, RealMin, RealMax`, **CANDIDATAS**) |
| DS-04 | Semántica de `piso`/`techo` | (a) como `trunc`/`redon`: real → entero de 64 bits, `integerOverflow` fuera de rango; (b) real → real | (a) coherente con `LIB.CORE.ROUNDING#R1` y con el uso típico (índices, conteos); un real entero se obtiene ya con `AReal(piso(x))` | **(a)** | Añadir variantes que devuelvan real solo si la persona lo pide |
| DS-05 | `atan2(0,0)` y dominios | (a) seguir IEEE 754/C99: `atan2(±0,+0)=±0`, `atan2(±0,−0)=±π`; (b) trampa `nonFiniteRealResult` | Todos los resultados son finitos; la regla vigente atrapa solo lo no finito. `asen`/`acos` fuera de [−1,1] y `log10`/`log2` de x ≤ 0 → `nonFiniteRealResult` | **(a)** (**Persona**: confirma que `atan2(0,0)` no atrapa) | Cambiar a (b) en una edición oficial de `LIB.CORE.MATH` |
| DS-06 | Precisión de las funciones nuevas | (a) binario64 más cercano, como `LIB.CORE.MATH#R1`; (b) libm del anfitrión | La regla vigente es independiente de la libm y el repositorio rechazó la libm del anfitrión con medición (README de `pseudolearn_library`) | **(a)** con la escalada de Ziv existente; casos exactos resueltos antes de escalar: `log2(2^k)=k`, `log10(10^k)=k` para k entero con `10^k` representable, `acos(1)=0`, `asen(0)=0`, `tan(0)=0` conservando signo | Si algún caso no converge (punto medio), `PrecisionExhausted` es un defecto interno: documentar y tratar caso a caso |
| DS-07 | Semántica de `Ordenar`/`Invertir` (PG-S.02) | (a) mutan el vector en sitio y no devuelven valor, como `Agregar`; (b) devuelven un vector nuevo | `Vector<T>` es referencia compartida; (a) es coherente con `lang.types.vector.md#R2` y no duplica celdas. Un cambio de orden con un `Para Cada` en curso sobre el mismo vector es un error de programa | **(a)**, con incremento de la versión estructural (así un recorrido en curso atrapa con el mismo mecanismo de modificación concurrente; **Persona**: reemplazar un elemento hoy NO incrementa versión, ordenar sí) | (b) como segunda forma solo si la persona lo pide |
| DS-08 | Orden natural y comparador | (a) orden natural para `Entero`, `Real`, `Carácter`, `Cadena`, `Lógico` (Falso < Verdadero); con comparador `SubProceso(T, T) Como Entero` (negativo/cero/positivo); (b) solo comparador | Ordenar números y cadenas es el 90 % de los usos. Cadenas por puntos de código (equivale al orden de bytes UTF-8, sin normalización ni configuración regional, coherente con el diccionario). `Real`: `-0` y `0` son iguales (coherente con `=`), así que el orden estable los deja como estaban. Otros tipos sin comparador → diagnóstico estático nuevo (**CANDIDATO** `elementTypeNotOrderable`) | **(a)** | Ampliar el conjunto natural (p. ej. enumerados por orden de declaración) solo por petición |
| DS-09 | Ordenación estable, atómica y total | Mezcla estable con búfer; el vector original no se toca hasta que el resultado está completo; un comparador inconsistente produce **alguna** permutación determinista y el algoritmo termina siempre; si el comparador falla, el vector queda intacto; si el comparador modifica el vector (alias) se atrapa con el error de modificación de colección | Atomicidad ya exigida a las colecciones; terminación sin depender de que el comparador sea un orden válido | Fijado por el corpus; la implementación se elige en `PS-E02` | Ninguna: son requisitos de corrección |
| DS-10 | Ruta de implementación del comparador | (A) `lowering` sintetiza una función auxiliar de mezcla por instancia de tipo que llama al comparador por la ruta normal de llamadas; (B) instrucción de VM reentrante que reejecuta (precedente: `request_effect` decrementa el contador de programa); (C) ordenar solo con orden natural | (A) no exige reentrada de la VM, respeta combustible, tareas y errores del comparador; coste: tamaño de código por instancia (**E-PG-03**) y visibilidad en la traza (`PS-V-07`). (B) es una máquina de estados compleja. (C) incumple el punto | **(A)**; el orden natural y `Invertir` son operaciones de colección directas sobre el montón | Si `PS-E02` muestra que (A) no se puede ocultar de la traza o crece sin cota, pasar a (B) con ADR; (C) solo con aprobación de la persona |
| DS-11 | «Buscar» y «el equivalente para claves de diccionario» (PG-S.02) | Vector: `PosicionDe(x)` → `Opcional<Entero>` y `Contiene(x)` → `Lógico`, por igualdad de valor para primitivos; Diccionario: `Claves()` → `Vector<K>` copia en orden de inserción | El nombre `PosicionDe` y su resultado ya existen en texto (`LIB.CORE.TEXT#T2`); `Buscar` ya es del diccionario (`Opcional<V>`). La hoja de ruta no define «equivalente»; esta es una interpretación (**Persona**): si lo que quería era `Claves()` ordenadas, se obtiene con `d.Claves()` seguido de `.Ordenar()` | Elección propuesta; para elementos no primitivos (registros, objetos, clausuras) la búsqueda se rechaza en compilación (**CANDIDATO** `elementTypeNotComparable`) | Añadir búsqueda con predicado solo por petición |
| DS-12 | Mayúsculas y minúsculas (PG-S.01) | Conversión Unicode **completa e independiente de la configuración regional** (p. ej. `ß` → `SS`; `İ` en minúsculas → `i` + U+0307; sigma final contextual) con la tabla de la cadena de herramientas fijada | La hoja de ruta pide «según Unicode sin configuración regional»; la longitud del resultado puede crecer (cuenta celdas, `LIB.CORE.TEXT#T3`). Se pinea la versión de Unicode de la cadena de herramientas y se escribe en el README (`PS-V-11`) | **Persona**: nombres **CANDIDATOS** `AMayusculas`/`toUpper` y `AMinusculas`/`toLower` (siguen el patrón `ATexto`/`AEntero`) | Si las plataformas difieren (`PS-V-11`), parar |
| DS-13 | Qué se vuelve a verificar si PG-S arranca antes de cerrar PG-L | PG-S no añade ni reutiliza construcciones de PG-L salvo la lista de aquí: no usa registros como resultado de métodos (el valor de calendario es opaco), no exporta genéricos y no los instancia entre módulos | Aislar PG-S de PG-L reduce el acoplamiento (`SCOPE-YAGNI`); `Vector<T>`/`Opcional<T>` genéricos de biblioteca ya existen | Si la persona autoriza arrancar antes, repetir `S.02.01` (README de `semantic`/`lowering`) cuando PG-L cierre | Ninguna |
| DS-14 | Operaciones de archivo (PG-S.04) | Receptor `Directorio` (ya cubre rutas absolutas del directorio inicial y confinamiento de `Subdirectorio`): `Existe(ruta)`, `Listar(ruta)`, `Borrar(ruta)`, `Renombrar(origen, destino)`, `CrearDirectorio(ruta)`; receptor `Archivo`: `AgregarTexto(texto)`, `AgregarBytes(bytes)` (**CANDIDATOS**) | Las rutas siempre pasan por una capacidad de directorio (`LIB.IO#R3`), así que el confinamiento de `Subdirectorio` aplica por construcción; añadir al final como operación del archivo evita ampliar el modelo de derechos | Elección propuesta; **Persona**: además `EsDirectorio(ruta)` → `Lógico`, porque listar sin poder distinguir directorios de archivos obliga a abrir cada entrada. Sin él, `Listar` devuelve solo nombres | Retirar `EsDirectorio` si la persona lo considera fuera de alcance |
| DS-15 | Semántica de archivos | `Listar`: nombres (no rutas) ordenados por puntos de código del nombre, sin `.` ni `..`; nombre no UTF-8 → `ErrorES::Utf8Invalido`; `Borrar`: archivo o directorio **vacío**, nunca recursivo; `Renombrar`: nunca sobrescribe, destino existente → `YaExiste`; `CrearDirectorio`: un solo nivel, existente → `YaExiste`; `Agregar*`: crea el archivo si no existe y escribe al final; mapeo de errores del sistema operativo a las variantes **existentes** de `ErrorES` (directorio no vacío → `PeticionInvalida`; es-un-directorio/no-es-un-directorio → `RutaInvalida`) | El orden del disco no puede decidir un observable (§5.4 del plan general). No se añaden variantes a `ErrorES` (cerrada, repartida en abi, runtime, anfitriones y presentación) sin necesidad. Residuo honesto: comprobar-y-renombrar no es atómico; `incierto` se usa solo cuando el sistema interrumpe | **Persona**: confirma el mapeo y la no-sobrescritura | Añadir variante `ErrorES` (`DirectorioNoVacio`) como edición oficial de `LIB.IO#R2` si la persona prefiere distinguir |
| DS-16 | Calendario (PG-S.05): representación | Tipo opaco `FechaHora` (en `DateTime`, **CANDIDATO**) = instante en nanosegundos desde la época Unix (`i64`, igual que `Reloj.Ahora`) + desplazamiento UTC en segundos (`i32`). Rango: 1677-09-21 a 2262-04-11 UTC; fuera de rango → `Nada` al analizar/construir. Gregoriano proléptico, sin segundos intercalares (el segundo 60 se rechaza) | Un tipo opaco con accesores sigue el precedente de `RespuestaHttp`/`ValorJson` y evita depender de registros como resultado (DS-13). `i64` de nanosegundos es el tipo que el lenguaje ya entrega | Elección propuesta | Si la persona exige años fuera de 1677–2262, ampliar la representación (`i128`) con ADR |
| DS-17 | Calendario: zona horaria | UTC siempre disponible sin anfitrión (función pura). «Zona del sistema»: operación del receptor `Reloj` que, dado un instante, devuelve el `FechaHora` local con el desplazamiento vigente en ese instante (incluye horario de verano) y se **graba en la cinta** como cualquier lectura de reloj. Desplazamientos fijos ISO 8601 (`+05:30`, `Z`) al analizar. Sin zonas con nombre | La hoja de ruta pide «zona horaria del sistema y UTC». La reproducción devuelve el desplazamiento grabado sin consultar al sistema (`RT.HOST.INTERFACE#R2`) | Elección propuesta | Añadir zonas IANA solo por petición |
| DS-18 | Origen del desplazamiento del sistema | (a) crate de zonas horarias del sistema en `pseudolearn_host` (**CANDIDATO**: `jiff`; alternativas `chrono` + `iana-time-zone`, `time` con `local-offset`); (b) `unsafe`/FFI propio; (c) el consumidor inyecta el desplazamiento (CLI/app/web cada uno a su manera) | (b) prohibido (`pseudolearn_host` declara `unsafe_allowed: false`). (c) duplicaría lógica y rompería «los consumidores no copian implementaciones» (README de `pseudolearn_host`). (a) añade una dependencia: exige revisión de licencia (`cargo-deny`), de tamaño (`PERF.ARTIFACT.SIZE`; la app ya tiene parada si el puente lo supera) y de soporte en iOS y Windows | **(a)** sujeto a `PS-E01` (medición y compatibilidad). La extensión web usa `Date` del navegador | Si `PS-E01` falla por tamaño o plataforma, parar y presentar a la persona (c) con su coste |
| DS-19 | Variables de entorno (PG-S.06) | (a) capacidad nueva `Entorno` (`SolicitarEntorno()`, **CANDIDATO**) con `Obtener(nombre)` → `Opcional<Cadena>`; (b) operación de `Argumentos`; (c) función libre sin capacidad | Coherencia con el modelo de capacidades: toda lectura del anfitrión pasa por una capacidad solicitada (`LANG.CAPABILITY.MODEL`, `RT.HOST.INTERFACE#R1`) y es grabable (`#R2`). (c) rompería la pureza (`LANG.CAPABILITY.PURITY`). (b) mezcla dos recursos | **(a)**. Requiere ampliar el vocabulario cerrado de la cinta con `environment` (edición oficial de `ENG.EFFECT.TAPE#R3`), `CapabilityKind` y la lista de familias de `LIB.MODEL#M4` o reutilizar `io` (decisión en `S.06.01`) | — |
| DS-20 | Sensibilidad de las variables de entorno en la cinta | (a) por valor, con el mecanismo de secretos actual (`PS-H-15`); (b) además por **nombre**: valores de variables cuyo nombre termina en `token`, `key`, `secret` o `password` (sin distinguir mayúsculas ASCII) van por referencia, igual que `Redirigida` retira esos nombres; (c) todos por referencia | K-13 (cinta que revela credenciales) es el riesgo de mayor puntuación (20) de la hoja de ruta. (c) hace irreproducible cualquier programa que lea el entorno; (a) filtra lo que el anfitrión no declare | **(b)** (**Persona**). Consecuencia declarada: un programa que lee `API_KEY` produce cinta `NonReproducibleRedacted` salvo almacén de resolución; la reproducción de esa ejecución en la app se rechaza con `replay_non_reproducible` | (a) si la persona prefiere reproducibilidad total y acepta el riesgo |
| DS-21 | Código de salida (PG-S.07) | (a) operación del receptor `Consola`: `EstablecerCodigoSalida(n)`; no termina el programa; vale para el final normal, 0 por omisión; (b) sentencia/función que termina de inmediato | (a) no toca el flujo de control, ni `Diferir`, ni las tareas (K-08). (b) exige definir limpieza, cancelación de tareas y su interacción con `Propagar`. `Salir` está tomado (`PS-H-19`) | **(a)** (**Persona**). Rango 0–255 (portable a POSIX); fuera de rango → `ErrorES::PeticionInvalida`. Un fallo del programa mantiene su código actual (no lo reemplaza el establecido) | (b) como punto nuevo solo con aprobación y ADR |
| DS-22 | Salida de error (PG-S.07) | Operación del receptor `Consola`: `EscribirError(texto)` (**CANDIDATO**). La salida del motor pasa a ser una secuencia de fragmentos etiquetados `salida`/`error` en el orden del programa | La app «los muestra en la consola con su propio estilo» (§B.3b): necesita distinguir el flujo. Mantiene el orden relativo entre ambos (no hay dos búferes) | Elección propuesta; el cambio de contrato de salida se verifica con `PS-V-09` | Si el cambio de contrato es demasiado ancho, la persona puede aceptar `EscribirError` solo en la CLI y declarar el resto «con error tipado de plataforma» |
| DS-23 | Formato de números (PG-S.08) | `Decimales(valor, cantidad)` → `Cadena` con `cantidad` decimales fijos (0 ≤ cantidad ≤ **CANDIDATO** 100); redondeo sobre la expansión decimal **exacta** del binario64 con empates alejados de cero (coherente con `redon`); acepta entero (ampliado) o real; `-0` se muestra `-0.00…`; `RellenarIzquierda(texto, ancho, relleno)` y `RellenarDerecha(...)` (relleno = un punto de código; ancho en puntos de código; si el texto ya es más largo no se recorta) | Sin configuración regional ni separadores de miles. El relleno es textual: no trata el signo de forma especial | Elección propuesta (**Persona** sobre nombres y tope de decimales) | — |
| DS-24 | Sujeto nativo en PG-S | Las operaciones nuevas no se acreditan en `aot` en esta fase (`PG-N.08`): las reglas nuevas llevan vínculos `pendiente` con `resuelve_en: "PG-N.08"` en `conformance-aot.yaml`; las operaciones de RI nuevas entran en `UNSUPPORTED_OPERATIONS` de `codegen` y `pseudo build` las rechaza con el diagnóstico existente de operación no soportada | Es lo que fija el plan general (`PG-N.08`) y el análisis (`PG-L`: «paridad en VM; la nativa se acredita en PG-N»). Va en contra de H-10 (pendientes con fase cerrada) **solo** si PG-N no los resuelve: `PG-N.08` ya lo exige | Elección propuesta; verificar `PS-V-13` | Si la persona quiere paridad nativa ya, `PG-S` crece (codegen + `aot_rt` unsafe) y debe replanificarse |

## 4. Desglose por punto

Convención: cada tarea es `PG-S.<punto>.<nn>`. Las casillas se marcan al cumplirse **con evidencia en §11**. Las tareas
transversales de preparación y cierre cuelgan de los puntos comunes `PG-S.C03`, `PG-S.C11` y `PG-S.C12`.
«Corpus» significa `packages/pseudolearn_spec/specifications/`. «Motor» significa `packages/pseudolearn_engine/`.
Los nombres entre «**CANDIDATA**» son propuestas (DS-xx): el texto oficial de la especificación manda.

### 4.0 Tareas transversales (preparación)

- [x] `PG-S.C11.01` Línea base: `git rev-parse HEAD`, árbol limpio, y ejecución registrada (comando, código de salida,
  conteos) de las pruebas dirigidas de §7.4 sobre HEAD **antes** de cualquier edición. Si la base ya falla, se informa y
  no se arrastra como regresión de PG-S.
- [x] `PG-S.C03.01` Verificar las hipótesis `PS-V-01`–`PS-V-14` que no consumen su punto: `PS-V-01`, `PS-V-09`, `PS-V-11`,
  `PS-V-12`, `PS-V-14`. Registrar cada resultado en §11. Una hipótesis refutada se convierte en conflicto o en cambio de
  diseño **por escrito** antes de seguir.
- [x] `PG-S.C03.02` Confirmar con la persona las decisiones **Persona** de §3 (DS-05, DS-07, DS-11, DS-12, DS-14, DS-15,
  DS-20, DS-21, DS-23) o registrar sus alternativas. Sin respuesta, el punto afectado no avanza.
- [x] `PG-S.C03.03` Plantilla de huella: sobre `git show --stat 62023207` y `f62a386b` (`PS-H-21`), elaborar la lista real
  de archivos que una operación D2 nueva toca y compararla con §5. Cualquier diferencia corrige §5 antes de editar.

### PG-S.01 · Mayúsculas y minúsculas de texto

Piloto de toda la tubería: lo que aquí se aprende (huella real, errores del validador, fichas, proyección de app)
corrige los demás puntos. Puerta G2 de §10.

- [x] `PG-S.01.01` Leer `lib.core.text.md` íntegro, `lib.model.md` D2 y `M1`–`M4`, y `LIB.CORE.TEXT#T1`–`T3`. Resolver
  `PS-V-02`, `PS-V-04` y `PS-V-11` (sin código). Registrar.
- [x] `PG-S.01.02` Especificación: nueva regla `T4` en `LIB.CORE.TEXT` (o regla análoga): conversión a mayúsculas y a
  minúsculas por la tabla Unicode completa independiente de la configuración regional; no normaliza; no modifica el
  argumento; el resultado cuenta celdas como cualquier cadena creada en ejecución (`T3`); la versión de Unicode aplicable
  se declara por referencia al README del motor, no por cita de documento. Añadir dos entradas D2 en `LIB.MODEL`
  (`text_to_upper`, `text_to_lower`; familia `text`; sin receptor; parámetro `text`; resultado `text`; `effect: false`;
  `fallible: false`) con facetas es y en y sin alias.
- [x] `PG-S.01.03` Casos derivados (esperado deducido de las tablas de Unicode, **no** de la salida del motor):
  ASCII; vacío; ya en el caso pedido; acentos (`é`↔`É`); `ß` → `SS`; `ǆ`; `İ` (U+0130) en minúsculas = `i` + U+0307;
  sigma final (`ΑΣ` → `ας`, `ΑΣΑ` → `ασα`); un carácter; cadena con emoji (sin cambio); entrada con tilde combinante
  (no se normaliza); programas en es y en. Caso infeliz: argumento no cadena → `incompatibleArgumentType`; aridad →
  `argumentCountMismatch`. Cada regla con al menos un caso (`SPEC-NO-ORPHAN-RULE`).
- [x] `PG-S.01.04` Tests que fallan por ausencia: `pseudolearn_library/src/text_case_tests.rs` (**CANDIDATO**, espejo de
  `text_replace_tests.rs`), prueba de resolución semántica en `pseudolearn_semantic/tests/`, prueba de despacho en
  `pseudolearn_vm`/`pseudolearn_api/tests/` según el patrón de `bytes_operations_tests.rs`.
- [x] `PG-S.01.05` Código: archivo nuevo `pseudolearn_library/src/text_case.rs` (una responsabilidad); registro en
  `lib.rs`; ramas nuevas en `local_operations.rs::text_operation` (si `PS-V-02` lo confirma). Regenerar con `cargo build`
  (nunca editar lo generado). Ajustar `abi/build.rs` **solo si** la operación nueva no entra por `capabilityLibrary`.
- [x] `PG-S.01.06` Fichas de ayuda es/en de ambas identidades en `cases/catalogs.json` (fuente), con anclas a `LIB.MODEL`
  y al caso ejecutable; cobertura (`help_catalog/coverage*.rs`) y fixtures negativos si el validador exige uno nuevo.
- [x] `PG-S.01.07` Consumidores: vocabulario/`service` (completado, hover, resaltado: `pseudolearn_service` y
  `pseudolearn_syntax/codegen/contextual.rs` si el patrón de `f62a386b` lo exige); extensión (gramática TextMate y
  ejemplos si el validador de la extensión los exige); app (`export_support.dart`, reglas de Rust y Python: equivalente
  `to_uppercase`/`to_lowercase` o «sin equivalente» rotulado, `PS-V-12`).
- [x] `PG-S.01.08` Sujeto nativo: vínculos `pendiente`/`resuelve_en: "PG-N.08"` para las reglas nuevas en
  `conformance-aot.yaml`; verificar `PS-V-13`.
- [x] `PG-S.01.09` README: `pseudolearn_library` (módulo `text_case`, versión de Unicode, límite de crecimiento),
  `pseudolearn_abi`/`runtime`/`semantic` solo si cambiaron, y el README de `pseudolearn_spec` si el validador cambió.
- [x] `PG-S.01.10` Verificación: `see validate`, `see lock --refresh <IDs editados>`, `see export --check`,
  `see conform --subject engine --only LIB.CORE.TEXT` y `--only LIB.MODEL`, `cargo test -p pseudolearn_library`,
  y los consumidores tocados. Registrar salida y código de salida.
- [ ] `PG-S.01.11` Informe de piloto en §11: huella real de archivos, errores inesperados, ajustes a §5 y a los demás
  puntos. **Parada de control G2.**

### PG-S.02 · Ordenar, invertir y buscar en colecciones

- [x] `PG-S.02.01` Leer `lang.types.{vector,dictionary,function,generic}.md`, `lang.profile.vocabulary.md` (sección de
  miembros de colección), README de `semantic` y `lowering`, y `ir.instructions.md` (operaciones `Collection*`). Resolver
  `PS-V-05`–`PS-V-08`. Si PG-L ya cerró, releer sus cambios a estos README.
- [x] `PG-S.02.02` **Experimento `PS-E02` (decisión DS-10)**: prototipo descartable en rama de trabajo única
  (no se crean ramas, `GIT-SINGLE-BRANCH`: el prototipo vive como cambios sin commit) para comprobar que (A) una función
  de mezcla sintetizada llama al comparador, respeta combustible, no aparece en la traza y no crece sin cota. Resultado
  y decisión en §11 y, después, en el README de `lowering`. El prototipo se **revierte** antes de la especificación.
- [x] `PG-S.02.03` Especificación: en `LANG.TYPES.VECTOR` reglas nuevas para `Ordenar()`, `Ordenar(comparador)`,
  `Invertir()`, `PosicionDe(x)`, `Contiene(x)` y en `LANG.TYPES.DICTIONARY` para `Claves()` (DS-07–DS-11): efecto en
  la versión estructural, atomicidad, estabilidad, terminación con comparador inconsistente, error del comparador,
  comparador que modifica el vector, tipos admitidos, límite de celdas (copia de claves cuenta como vector nuevo),
  vector de uno o cero elementos. Vocabulario contextual es/en en `LANG.PROFILE.VOCABULARY` (**CANDIDATAS**:
  `Ordenar/sort`, `Invertir/reverse`, `PosicionDe/indexOf`, `Contiene/contains`, `Claves/keys`; revisar colisiones con
  alias existentes y con `M2`). Diagnósticos nuevos en `DIAG.CATALOG` y `DIAG.MESSAGES` en ambos idiomas
  (**CANDIDATOS** `elementTypeNotOrderable`, `elementTypeNotComparable`) y, si se añaden operaciones de RI, en
  `IR.INSTRUCTIONS`.
- [x] `PG-S.02.04` Casos derivados: vector vacío; un elemento; ya ordenado; orden inverso; todos iguales (estabilidad con
  comparador que solo mira una clave de registro… sin usar registros nuevos de PG-L: usar `Vector<Entero>` con
  comparador por módulo para observar la estabilidad); duplicados; negativos y `-0`/`0` en reales; cadenas con acentos
  y mayúsculas (orden por puntos de código); comparador que devuelve siempre 0; comparador inconsistente (siempre −1);
  comparador que falla a mitad (vector intacto); comparador que modifica el vector (error de modificación);
  `Para Cada` en curso sobre el vector ordenado (error); vector en el límite de celdas; `Claves()` de diccionario vacío,
  con borrados y reinserciones (orden de inserción); `PosicionDe` ausente → `Nada`; ambos perfiles.
- [x] `PG-S.02.05` Tests espejo: `pseudolearn_semantic/tests/` (tipos admitidos y rechazados), `pseudolearn_lowering/tests/`
  (bajada y, si DS-10 = A, función sintetizada por tipo), `pseudolearn_library` (operación de montón), `pseudolearn_vm`
  y `pseudolearn_api/tests/` (ejecución, versión, atomicidad), propiedad de estabilidad y de permutación (misma
  multiconjunto) con generadores sembrados.
- [x] `PG-S.02.06` Código en las capas de `PS-H-09`: `semantic` (`collection_checker.rs`/`collection_model.rs` pueden
  superar el límite de 300 líneas: crear archivos nuevos por responsabilidad), `lowering` (archivo nuevo para la
  bajada de ordenación), `abi` (`CollectionCommand` nuevo si DS-10 lo exige), `runtime` (`collection/`),
  `library/src/collections.rs` o archivo nuevo, `ir`/`bytecode`/`vm`/`vm_dispatch` si hay operaciones de RI nuevas.
- [x] `PG-S.02.07` Sujeto nativo: operaciones de RI nuevas → `UNSUPPORTED_OPERATIONS` en `codegen`; vínculos `pendiente`
  `PG-N.08` (DS-24); el diagnóstico de `pseudo build` se prueba con un programa que usa `Ordenar`.
- [x] `PG-S.02.08` Fichas es/en para cada miembro nuevo (los miembros contextuales tienen ficha de rol, ver
  `cases/catalogs.json` para `Agregar`/`Eliminar`), cobertura de vistas de la app y diagramas/traza (`C09`): consultar la
  matriz de cobertura de sintaxis de la app; una operación de ordenación se presenta como **un paso** en la traza
  salvo que `PS-E02` decida otra cosa, y eso se documenta.
- [x] `PG-S.02.09` Consumidores: `service`, extensión (resaltado), app (proyección de miembros de colección y exportación
  Rust/Python: `sort`, `reverse`, `iter().position`, `contains`, `keys`).
- [x] `PG-S.02.10` README (`semantic`, `lowering`, `library`, `runtime`, `vm`, `aot_rt`/`codegen` si cambian) con DS-07–DS-11
  y el resultado de `PS-E02` (`DOC-NO-ORPHAN-DECISION`).
- [ ] `PG-S.02.11` Verificación dirigida: `see validate/lock/export --check`, `see conform --subject engine` para las
  reglas editadas, `cargo test` de `semantic`, `lowering`, `library`, `runtime`, `vm`, `api`, `service`; E-PG-03
  (crecimiento por instancia) si DS-10 = A; `PERF.SUITE.CORE` sin regresión (§6).

### PG-S.03 · Mínimo, máximo, piso, techo y funciones trigonométricas y logarítmicas faltantes

- [x] `PG-S.03.01` Leer `lib.core.math.md` y `lib.core.rounding.md` íntegros, `lib.model.md` D1 (filas `numbers`),
  README de `pseudolearn_library` (sección de intervalos y Ziv) y `pseudolearn_math_probe`, `see_oracles` y
  `math_contrast.rs`. Resolver `PS-V-03` y `PS-V-05`.
- [x] `PG-S.03.02` **Oráculo primero** (`SPEC-INDEPENDENT-ORACLE`): ampliar `see_oracles` con `tan`, `asin`, `acos`,
  `atan2`, `log10`, `log2` por el método independiente (racionales/intervalos del propio crate, sin reutilizar código del
  motor), con sus tests y su caso negativo (oráculo con un error deliberado debe ser detectado por el contraste).
- [x] `PG-S.03.03` Especificación: en `LIB.CORE.MATH` regla nueva `R2` para `tan`, `asen`, `acos`, `atan2`, `log10`,
  `log2` (mismos criterios que `R1`: binario64 más cercano, empates al par, subnormales, ceros con signo, dominio
  inválido → `nonFiniteRealResult`, sin consultar entorno) con dominios explícitos y los casos exactos de DS-06;
  `atan2(y, x)` con cuadrantes y ceros con signo (DS-05). Regla de `piso`/`techo` en `LIB.CORE.ROUNDING` (DS-04) y de
  `min`/`max` (DS-03) en `LIB.CORE.MATH` o regla nueva. Diez entradas en D1 de `LIB.MODEL` con lexemas es/en
  (**CANDIDATAS**: `min/min`, `max/max`, `piso/floor`, `techo/ceil`, `tan/tan`, `asen/asin`, `acos/acos`,
  `atan2/atan2`, `log10/log10`, `log2/log2`; alias solo si el corpus los pide) y, para `min`/`max`, la clase de retorno
  nueva. Comprobar `M2` y colisiones léxicas con los identificadores de usuario (los nombres no son reservados).
- [x] `PG-S.03.04` Casos derivados: valores notables (`tan(0)`, `asen(1)`, `acos(-1)`, `atan2(1,1)`), cuadrantes de
  `atan2`, `atan2(±0, ±0)`, `log10(1000)=3`, `log2(0.5)=-1`, `log2` de subnormal, `log10(0)`/`log2(-1)` →
  `nonFiniteRealResult`, `asen(2)` → trampa, argumentos enteros ampliados, `piso(-0.5)`, `techo(-0.5)`, `piso` de
  `9.3e18` → `integerOverflow`, `min`/`max` con enteros, con reales, mezclados, con `-0`/`0`, con iguales; aridad y tipo
  incorrectos. Propiedad: para muestras sembradas, cada función coincide con el oráculo (**regla de precisión
  comprobada con su propiedad**, criterio de salida del análisis): bloque `propiedad` en `LIB.CORE.MATH`, ejecutor en
  `see_conformance`, entrada en `property-conformance.json` y, si el ejecutor es nuevo, el enumerado de
  `schemas/properties-1.schema.json`.
- [x] `PG-S.03.05` Tests: `pseudolearn_library/tests/math_tests.rs` y `transcendental_tests.rs` ampliados o archivos
  espejo nuevos; `pseudolearn_semantic/tests/` (retorno ancho, ampliación); `pseudolearn_ir` (verificador de tipos);
  `pseudolearn_vm`/`api` (ejecución y trampa con su atribución de span).
- [x] `PG-S.03.06` Código en `pseudolearn_library/src/transcendental/` (un archivo por función o familia; sin superar
  300 líneas; `tan` como cociente de intervalos, `asin/acos` por `atan` y raíz de intervalos con tratamiento de |x|=1,
  `atan2` por cuadrantes sobre `atan`, `log10/log2` como `ln x / ln b` con los casos exactos resueltos antes de la
  escalada), `ir` (operaciones nuevas si DS-02 = a, con `type_checker_intrinsics.rs`), `lowering/expressions_builtins.rs`
  (dividir si supera el límite), `bytecode`, `vm`, `vm_dispatch`, `semantic/builtin_checker.rs`.
- [ ] `PG-S.03.07` Contraste masivo con `pseudolearn_math_probe` contra el oráculo para las seis trascendentes: número de
  muestras, semilla, argumentos extremos (subnormales, ±`f64::MAX`, cercanos a múltiplos de π/2, |x| cerca de 1) y
  cero discrepancias. Procedencia completa (plataforma, hashes, semilla, muestras crudas) según `C10`; si no se ejecuta,
  se difiere con aprobación de la persona.
- [x] `PG-S.03.08` Sujeto nativo (DS-24): operaciones de RI nuevas a `UNSUPPORTED_OPERATIONS`; vínculos `pendiente`.
- [x] `PG-S.03.09` Fichas es/en (diez identidades), consumidores (`service`, extensión, app: proyección y exportación a
  Rust `f64::tan`… **ojo**: la exportación a Rust/Python usa la libm del destino y puede diferir en el último bit;
  rotular esa diferencia como límite conocido o declarar «sin equivalente», decisión registrada en el README de la app).
- [x] `PG-S.03.10` README de `library`, `ir`, `vm`, `semantic`, `lowering`, `pseudolearn_spec`, con DS-02–DS-06.
- [ ] `PG-S.03.11` Verificación dirigida (§7.4) + `PERF.SUITE.CORE` y `PERF.AOT.LEVEL` sin regresión (las funciones
  nuevas no cambian los benchmarks existentes).

### PG-S.04 · Archivos: listar, existir, borrar, renombrar, crear directorio y añadir

- [ ] `PG-S.04.01` Leer `lib.io.md` íntegro (`R2`–`R4`), `rt.host.interface.md` (`R1`, `R2`, `R4`), `eng.effect.commit`
  (`ENG.EXEC.EFFECT-COMMIT`), README de `pseudolearn_host` y `pseudolearn_runtime`, `physical_files.rs`, `physical_paths.rs`,
  `memory_host_files.rs`, `host_paths.rs`.
- [ ] `PG-S.04.02` Especificación: reglas nuevas en `LIB.IO` para cada operación de DS-14/DS-15 (efecto, falibilidad,
  errores `ErrorES` por causa, confinamiento por `Subdirectorio`, orden y filtrado de `Listar`, no sobrescritura de
  `Renombrar`, `Borrar` no recursivo, `Agregar*` crea y escribe al final, UTF-8 estricto en `AgregarTexto`, incertidumbre
  cuando una mutación pudo confirmarse). Entradas D2 en `LIB.MODEL` (receptores `directory`/`file`, familia `io`,
  `effect: true`, `fallible: true`). Resultado de `Listar`: `Vector<Cadena>` (tipo `text_list` ya existe). `RT.HOST.INTERFACE`
  recibe la mención de operaciones de sistema de archivos del anfitrión. Sin cambio en el vocabulario de la cinta
  (`filesystem` ya existe).
- [ ] `PG-S.04.03` Casos derivados con el anfitrión de memoria del corpus: directorio vacío, con archivos y
  subdirectorios (orden por puntos de código, `.` y `..` ausentes), nombre con Unicode; `Existe` de archivo, de
  directorio, de ausente; `Borrar` de archivo, de directorio vacío, de directorio no vacío (`PeticionInvalida`), de
  ausente (`NoEncontrado`); `Renombrar` a destino libre, a destino existente (`YaExiste`), de ausente, dentro de
  `Subdirectorio`; `..` y ruta absoluta fuera del confinamiento (`PermisoDenegado`/`RutaInvalida` según la regla);
  `CrearDirectorio` nuevo, existente (`YaExiste`), padre ausente; `AgregarTexto` a archivo inexistente, existente, dos
  veces seguidas, con UTF-8 inválido en bytes; capacidad cerrada (`CapacidadCerrada`); reproducción desde cinta de cada
  operación sin tocar el disco.
- [ ] `PG-S.04.04` Tests: `pseudolearn_runtime` (doble de memoria), `pseudolearn_host/tests/` (carpetas temporales, nunca
  rutas del usuario), `pseudolearn_abi` (tabla de operaciones), `pseudolearn_api` (suspensión/commit de efecto),
  adversarios de rutas (E-PG-09 ampliado: 1000 rutas con `..`, enlaces simbólicos, nombres no UTF-8 en Unix, rutas con
  `:` y `\` en Windows, destino existente, carrera de creación) con cero escapes del confinamiento.
- [ ] `PG-S.04.05` Código `pseudolearn_host`: archivos nuevos por responsabilidad (p. ej. `physical_directory_ops.rs`,
  `physical_file_append.rs`; `physical_files.rs` ya tiene 172 líneas, no crece más de 300); ampliar `HostError::from_io`
  con los `ErrorKind` necesarios (`DirectoryNotEmpty`, `NotADirectory`, `IsADirectory`) según DS-15; ambas ramas
  (`Ambient` y `Confined`) con la misma semántica. Doble de memoria con la misma semántica. `abi` y `runtime`
  (`host_validation.rs` lista las operaciones válidas por nombre: añadir). `semantic`/`lowering` solo si el receptor o el
  resultado necesitan tipos nuevos (no: usan los existentes).
- [ ] `PG-S.04.06` Anfitriones: extensión web (`browser_file_host.ts` con `vscode.workspace.fs`: `readDirectory`,
  `stat`, `delete`, `rename`, `createDirectory`, lectura+escritura para añadir; semántica de DS-15 idéntica y errores
  tipados de plataforma si el proveedor del sistema de archivos virtual no soporta una operación), pruebas del adaptador
  (`apps/pseudolearn_vscode/tests/adapters/`), CLI (`editor_effects.rs`/`dap_effects.rs` si enumeran operaciones),
  puente de la app (`apps/pseudolearn_app/native/`).
- [ ] `PG-S.04.07` Fichas es/en, consumidores (`service`, extensión, app: proyección de operaciones sobre capacidades;
  exportación a Rust/Python: `std::fs` y `os`/`pathlib`, o «sin equivalente»).
- [ ] `PG-S.04.08` Sujeto nativo: vínculos `pendiente` `PG-N.08` (nativo con `pseudolearn_host`: `PG-N.07`).
- [ ] `PG-S.04.09` README (`host`, `runtime`, `abi`, `spec`, CLI, extensión, app) con DS-14/DS-15.
- [ ] `PG-S.04.10` Verificación dirigida: `cargo test -p pseudolearn_host`, `-p pseudolearn_runtime`, `-p pseudolearn_api`;
  `see conform --subject engine --only LIB.IO`; pruebas del adaptador web; prueba manual **registrada** en CLI con
  carpeta temporal (comandos y salida en §11).

### PG-S.05 · Fecha y hora de calendario con zona horaria e ISO 8601

- [ ] `PG-S.05.01` Leer `lib.time.md` íntegro, `eng.effect.tape.md` (`R3`, `R6`), `ENG.EXEC.EFFECT-COMMIT`, README de
  `host`, `runtime`, `abi`, `api` (presentación de valores), `physical_host.rs::real_nanos`. Resolver `PS-V-10`.
- [ ] `PG-S.05.02` **Experimento `PS-E01` (decisión DS-18)**: medir el candidato de zonas horarias del sistema en
  `pseudolearn_host` (licencia con `cargo-deny`, tamaño de `pseudolearn_host` y del puente de la app frente a
  `PERF.ARTIFACT.SIZE`, comportamiento en macOS, Linux, iOS simulador y Windows —este último solo compila; no se afirma
  ejecución—). Entregable: tabla de alternativas con números. Si algo supera el presupuesto: **parar** (el puente de la
  app ya tiene una parada declarada en PG-B.22).
- [ ] `PG-S.05.03` Especificación en `LIB.TIME`: tipo `FechaHora` (DS-16), operaciones puras (UTC desde instante,
  construcción desde componentes con validación de calendario, accesores `año, mes, día, hora, minuto, segundo,
  nanosegundo, díaDeLaSemana, desplazamientoUtc, instante`, formato ISO 8601 con y sin fracción, análisis ISO 8601
  que acepta `Z`, `±hh:mm`, fracción y fecha sola, y devuelve `Nada` ante cualquier forma inválida o fuera de rango)
  y la operación de zona del sistema del receptor `Reloj` (DS-17) con grabado en cinta y reproducción sin consulta.
  Reglas del calendario gregoriano proléptico: bisiestos (1900 no, 2000 sí, 2100 no), 29 de febrero, fin de mes, días
  por mes, día de la semana, salto de horario de verano (hora inexistente y ambigua: el instante determina el
  desplazamiento, el inverso no se ofrece en esta fase). Entradas D2 en `LIB.MODEL` (familia `time`), nuevo tipo de dato
  de efecto (`date_time`, `optional_date_time`, **CANDIDATOS**) y su registro en `value_kind` (`abi/build.rs`),
  `EffectValueKind`, `HostValue`, `host_words.rs`, `effect_types.rs`; facetas del nombre del tipo es/en en el vocabulario.
- [ ] `PG-S.05.04` Casos derivados: época (`1970-01-01T00:00:00Z`), un nanosegundo, fecha negativa (1969), 29/02 de año
  bisiesto y de uno que no lo es (rechazo), 31/12→01/01, 1900/2000/2100, límites del rango (primer y último instante),
  fuera de rango (`Nada`), desplazamientos `+14:00`/`-12:00`/`+05:30`/`Z`/sin zona, formatos inválidos
  (`2026-13-01`, `2026-02-30`, `T25:00`, vacío, espacios, minúsculas `t`/`z` según la regla), fracciones de 1 a 9
  dígitos, segundo 60 (rechazo), ida y vuelta `analizar(formato(x)) = x`, día de la semana de fechas conocidas,
  zona del sistema grabada y reproducida (sin consultar al sistema), instante repetido en cambio de horario (la zona la
  fija el anfitrión: el caso del corpus usa el doble de memoria con un desplazamiento declarado en `anfitrion`).
  Propiedad: ida y vuelta ISO sobre instantes sembrados dentro del rango.
- [ ] `PG-S.05.05` Tests: `pseudolearn_library` (calendario puro en un archivo propio; algoritmo de días civiles
  verificado contra un oráculo independiente de `see_oracles` o tabla derivada de la definición del calendario, no contra
  una biblioteca), `pseudolearn_runtime`, `pseudolearn_host` (zona del sistema con el `TZ` controlado **solo en la
  prueba**, nunca en producto), `pseudolearn_api` (presentación del valor opaco en el estado), adaptadores TS.
- [ ] `PG-S.05.06` Código: calendario en un archivo propio de `pseudolearn_library` (sin dependencia de zonas); la
  consulta a la zona del sistema solo en `pseudolearn_host` y en el adaptador web (`Date#getTimezoneOffset` del
  instante; límite: sin precisión de segundos para fechas históricas, documentado); doble de memoria con
  desplazamiento declarado por la configuración del caso.
- [ ] `PG-S.05.07` Cinta: el resultado de la zona del sistema se graba con `capability_kind` `clock`; verificar con
  `PS-E05` (E-PG-05 ampliado) que reproducir no consulta al sistema.
- [ ] `PG-S.05.08` Fichas es/en (tipo, constructores, accesores, formato, análisis, zona del sistema); consumidores
  (`service`: identificación del tipo en hover/completado; extensión; app: presentación del valor en variables y estado;
  exportación a Rust/Python: `std::time`/`datetime` o «sin equivalente»).
- [ ] `PG-S.05.09` Sujeto nativo: pendiente `PG-N.08`.
- [ ] `PG-S.05.10` README (`library`, `host`, `abi`, `runtime`, `spec`, extensión, app) con DS-16–DS-18, límites (rango,
  sin segundos intercalares, sin zonas con nombre) y el resultado de `PS-E01`.
- [ ] `PG-S.05.11` Verificación dirigida y registro de la tabla de `PS-E01`.

### PG-S.06 · Variables de entorno de solo lectura

- [ ] `PG-S.06.01` Leer `lang.capability.model.md`, `lang.capability.purity.md`, `rt.host.interface.md`,
  `eng.effect.tape.md` (`R3`, `R5`), `secret_policy.rs`, `tape_privacy.rs`, `api.program.view.md` (menciones de tipos de
  capacidad). Resolver el reparto de familia (`io` frente a una familia nueva `environment`) y anotarlo.
- [ ] `PG-S.06.02` Especificación (DS-19, DS-20): capacidad `Entorno` y su solicitud en `LANG.CAPABILITY.MODEL`;
  `RT.HOST.INTERFACE#R1` añade las variables de entorno a la lista de autoridad plena; `ENG.EFFECT.TAPE#R3` añade
  `environment` al vocabulario cerrado y `#R5` la clasificación por nombre; operación `Obtener(nombre)` →
  `Opcional<Cadena>`: variable ausente → `Nada`; variable presente pero vacía → `Algo("")`; nombre vacío o con `=` o NUL →
  `ErrorES::PeticionInvalida`; valor no UTF-8 → `ErrorES::Utf8Invalido`; mayúsculas: sensible a mayúsculas en Unix,
  **insensible en Windows**, así que el corpus declara «el anfitrión decide» y el caso lo fija con el doble de memoria.
  En el navegador no hay entorno: la capacidad se solicita y `Obtener` devuelve un `ErrorES` tipado de plataforma (§B.3b).
- [ ] `PG-S.06.03` Casos derivados: ausente, presente, presente vacío, nombre inválido, valor Unicode, nombre sensible
  (cinta con `SecretHandle`, valor ausente de la cinta serializada en forma textual, escapada, decimal y hexadecimal:
  `ENG.EFFECT.TAPE#R5`), reproducción de lectura no sensible sin consultar al sistema, reproducción de lectura sensible
  rechazada con `replay_non_reproducible` o resuelta con almacén, dos lecturas del mismo nombre (se graban ambas), perfil
  es/en, capacidad cerrada.
- [ ] `PG-S.06.04` Tests en `abi` (`CapabilityKind`, `EffectValueKind::Environment`), `runtime` (`capability_table.rs`,
  `host_validation.rs`, `secret_policy.rs` con la regla por nombre en un archivo propio), `semantic` (`capability_types.rs`,
  `effect_types.rs`), `host`, `api`.
- [ ] `PG-S.06.05` Código: `pseudolearn_host` (lectura de `std::env::var_os`, sin heredar nada más), doble de memoria con un
  entorno declarado por el caso, adaptador web con error tipado, puente de la app. La **configuración** del anfitrión
  no añade ninguna opción de permiso (RQ-1).
- [ ] `PG-S.06.06` Fichas es/en, consumidores, README (`abi`, `runtime`, `host`, `semantic`, `spec`) con DS-19/DS-20 y la
  consecuencia de reproducibilidad.
- [ ] `PG-S.06.07` Sujeto nativo: pendiente `PG-N.08`; recordar que `RT.PROCESS#R3` se reescribe en `PG-N.01` (§9).
- [ ] `PG-S.06.08` Verificación dirigida, incluida una prueba de seguridad: ni el valor ni el nombre sensible aparecen en la
  cinta, en el estado de la API, en la traza ni en la exportación.

### PG-S.07 · Código de salida y salida de error

- [ ] `PG-S.07.01` Leer `api.execute.md`, `api.wire-format.md`, `api.model.md`, `tool.cli.run.md` (`R1`–`R7`),
  `tool.dap.md`, `eng.input.md`, `eng.trace.events.md`, README de `api`, `timeline`, `vm` (`effect_completion.rs`),
  CLI (`editor_protocol.rs`, `dap_pump.rs`, `execution_options.rs`), extensión (`browser_run.ts`,
  `vscode_run_presenter.ts`), app (`app.exec.*`, su consola). Resolver `PS-V-09`.
- [ ] `PG-S.07.02` **Verificar el alcance real del cambio de contrato** y presentarlo a la persona antes de la
  especificación: lista de contratos (`API.EXECUTE`, `API.WIRE-FORMAT`, `API.PROGRAM.VIEW`, `TOOL.CLI.RUN`,
  `TOOL.DAP`, `APP.EXEC.*`, `ENG.TRACE.EVENTS`) con la regla afectada. Si el costo es mayor que el previsto, DS-22 admite
  el alcance reducido descrito allí.
- [ ] `PG-S.07.03` Especificación: `Consola.EscribirError(texto)` y `Consola.EstablecerCodigoSalida(n)` (DS-21, DS-22):
  orden relativo entre salida y error preservado; el error no se mezcla con la salida en la CLI (`stderr`), el
  protocolo de editor lleva un campo de flujo, el DAP usa la categoría de salida de error, la app lo muestra con estilo
  propio; un fallo de ejecución produce su código vigente; un código establecido más de una vez conserva el último; fuera de
  0–255 → `ErrorES::PeticionInvalida`; el código se aplica al final normal; `TOOL.CLI.RUN#R2` pasa de «0 si completed, 1
  en cualquier otro caso» a «el código establecido (0 por omisión) si completed, 1 en cualquier otro caso».
  Entradas D2 en `LIB.MODEL` (receptor `console`, familia `io`).
- [ ] `PG-S.07.04` Casos derivados: error solo; salida y error intercalados (orden); código 0, 1, 7, 255; 256 y −1
  (error); dos establecimientos; código establecido seguido de fallo de ejecución (gana el fallo); código establecido
  y límite agotado; cancelación; reproducción desde cinta de ambos flujos y del código sin duplicarlos; programa sin
  `SolicitarConsola` (si la capacidad es obligatoria para estas dos operaciones; si `Escribir` no la exige, el corpus lo
  declara y los casos lo reflejan).
- [ ] `PG-S.07.05` Tests: `vm` (finalización de efecto con flujo), `runtime` (cinta), `api` (resultado y eventos con
  flujo y código), `timeline` (instantáneas con ambos flujos), CLI (código de proceso real: pruebas del binario con
  `std::process::Command` sobre `pseudo ejecutar`), protocolo de editor, DAP, extensión (presentador y worker web), app
  (puerto de ejecución y vista de consola).
- [ ] `PG-S.07.06` Código en las capas de `PS-V-09` tras su verificación: `abi`/`runtime`/`vm`/`timeline`/`api`/`wasm`
  (frontera Wasm: formato versionado, `API.VERSIONING` si el contrato cambia), CLI, extensión, puente y vista de la app.
  El nuevo campo de flujo se añade de forma compatible con el protocolo versionado o se sube la versión del protocolo,
  según `API.VERSIONING` (leer antes).
- [ ] `PG-S.07.07` Fichas es/en, consumidores, README de cada miembro afectado y de `pseudolearn_spec` si el validador cambia.
- [ ] `PG-S.07.08` Sujeto nativo: pendiente `PG-N.08`; la reescritura de `RT.PROCESS` es `PG-N.01` (§9).
- [ ] `PG-S.07.09` Verificación dirigida: `see conform --subject engine`, `--subject cli`, `--subject app` para las reglas
  editadas; pruebas de CLI con códigos de proceso; Flutter dirigido a la consola de la app.

### PG-S.08 · Formato de números en texto

- [ ] `PG-S.08.01` Leer `lib.core.conversion.md`, `lang.io.value-format.md` (algoritmo de dígitos mínimos), `decimal.rs`,
  `format.rs`, `rounding.rs` de `pseudolearn_library` y `lib.core.text.md#T3`. Resolver `PS-V-03`.
- [ ] `PG-S.08.02` Especificación en `LIB.CORE.CONVERSION` (o regla nueva) para `Decimales` y en `LIB.CORE.TEXT` para
  `RellenarIzquierda`/`RellenarDerecha` (DS-23): expansión decimal exacta, empates alejados de cero, rango de
  `cantidad`, `-0`, enteros ampliados, relleno de un punto de código (relleno vacío o de más de un punto → trampa con
  diagnóstico **CANDIDATO** `invalidPaddingText`), ancho negativo (trampa), texto más largo que el ancho (sin
  recorte), conteo de celdas del resultado, tope de `ancho` por el presupuesto de celdas. Entradas D2 en `LIB.MODEL`
  (familia `text`; `Decimales` con parámetro `numeric`; resultado `text`).
- [ ] `PG-S.08.03` Casos derivados con esperado deducido de la definición decimal: `Decimales(2.5, 0)`=`3`,
  `Decimales(-2.5, 0)`=`-3`, `Decimales(0.125, 2)`=`0.13` (empate exacto), `Decimales(0.1, 20)` (muestra la expansión
  exacta de 0.1: `0.10000000000000000555`), `Decimales(1e22, 2)`, `Decimales(5e-324, 3)`=`0.000`, `Decimales(-0.0, 2)`=
  `-0.00`, `Decimales(7, 2)`=`7.00`, cantidad 0 sin punto decimal, cantidad en el tope, cantidad sobre el tope y
  negativa (trampa), relleno con `0` y con `.`, relleno multicarácter (trampa), texto vacío, texto con acentos y emoji
  (cuenta puntos de código), ancho 0. Propiedad: para reales sembrados, `AReal(Decimales(x, 17))` ≈ `x` dentro de la
  tolerancia que la regla fije, y la longitud de la parte decimal es `cantidad`.
- [ ] `PG-S.08.04` Tests y código: nuevos archivos en `pseudolearn_library` (`decimal_format.rs`, `text_padding.rs`), sin
  reutilizar `format_value` (que es el formato de salida de dígitos mínimos); el cálculo del redondeo usa los naturales de
  precisión arbitraria de `precision/natural.rs`; ninguna conversión con pérdida (`QUALITY-NO-PANIC`).
- [ ] `PG-S.08.05` Fichas es/en, consumidores, exportación (`format!("{:.2}")`, `f"{x:.2f}"`; ojo con el redondeo de
  empates del destino: documentar o declarar sin equivalente), README con DS-23, sujeto nativo pendiente.
- [ ] `PG-S.08.06` Verificación dirigida.

### PG-S.09 · Cada operación en VM, extensión web y app de las tres plataformas

Este punto integra y acredita; el trabajo por anfitrión de cada operación ya se hizo en su punto. No introduce
operaciones nuevas.

- [ ] `PG-S.09.01` Matriz de aceptación (§7.2): operación × plataforma, con el resultado esperado derivado del corpus.
  Plataformas: VM (API), CLI, extensión de escritorio, extensión web (Chromium y WebKit), app macOS, app iOS simulador,
  app Windows. Cada celda: `cumple`, `error tipado de plataforma esperado` (con el `ErrorES` que lo documenta) o
  `no verificado` (Windows, sin ejecución real, rotulado como en PG-B.27).
- [ ] `PG-S.09.02` Programa de aceptación por plataforma: **un archivo único** por área que ejerce todas las operaciones
  nuevas del área con salida determinista (no depende de la hora, del entorno ni del disco del usuario salvo las
  variables que el propio programa fija o la carpeta temporal que crea y borra). Se ejecuta en cada plataforma real
  disponible en el equipo (CLI, extensión web, app macOS, app iOS en simulador) siguiendo el patrón de PG-B.27.
- [ ] `PG-S.09.03` Extensión web: para cada operación, el adaptador responde con valor real o con `ErrorES` tipado de
  plataforma (entorno, quizá `Renombrar` según el proveedor); ninguna operación queda sin rama (prueba de exhaustividad
  contra `EFFECT_OPERATIONS`, **tarea que debe fallar si se añade una operación nueva sin adaptador**).
- [ ] `PG-S.09.04` App: puente (`native/`), puerto, consola con estilo para error y código de salida, diagramas/traza y
  ayuda (`C09`), selector de ejemplos si la app los tiene, exportación Rust/Python con equivalente o rótulo explícito
  (`PS-V-12`), matriz de cobertura sin celdas nuevas en «no soportado». Resultado de la suite Flutter dirigida.
- [ ] `PG-S.09.05` Extensión de escritorio: confirmar `PS-V-14` y ejecutar el programa de aceptación; DAP: la salida de
  error aparece con su categoría.
- [ ] `PG-S.09.06` Declarar en el README de cada miembro y en §11 lo que no se pudo verificar físicamente (Windows,
  dispositivos físicos, Firefox), sin afirmar cobertura que no existe.

## 5. Capas y archivos

Respuestas a `AGENTS.md` §1 por miembro. «Esperado» significa lo que el árbol permitía en `f62a386b`; si el árbol
cambió, manda el árbol y el README. Todos los archivos nuevos respetan los límites de `PS-H-23`, cero comentarios
(`QUALITY-NO-COMMENTS`), nombres semánticos (`QUALITY-SEMANTIC-NAMES`) y `#![forbid(unsafe_code)]` salvo en las tres
cajas declaradas.

| Miembro / capa | Archivos nuevos o modificados (propuesta) | Puede importar | Tiene prohibido | Dueño de la responsabilidad |
|---|---|---|---|---|
| `pseudolearn_spec` / `specifications` (datos) | `lib/lib.model.md`, `lib/lib.core.{text,math,rounding,conversion}.md`, `lib/lib.io.md`, `lib/lib.time.md`, `lang/lang.types.{vector,dictionary}.md`, `lang/lang.profile.vocabulary.md`, `lang/lang.capability.model.md`, `rt/rt.host.interface.md`, `eng/eng.effect.tape.md`, `api/api.execute.md`, `api/api.wire-format.md`, `tool/tool.cli.run.md`, `tool/tool.dap.md`, `diag/diag.catalog.md`, `diag/diag.messages.md`, `ir/ir.instructions.md`, `cases/{catalogs,vocabulary}.json`, `property-conformance.json`, `schemas/properties-1.schema.json` | (datos) | Citar `docs/` (`DOC-NO-TRANSIENT-REFS`); editar `export.json` | Cada especificación es dueña del comportamiento de su dominio |
| `pseudolearn_spec` / `see_oracles` | `transcendentals.rs` y archivos nuevos por función | biblioteca estándar, num-* | Sujetos | Oráculo independiente |
| `pseudolearn_spec` / `see_conformance`, `see_validation` | `math_contrast.rs`, `math_arguments.rs`, ejecutor de propiedad, `resources/{capability_library,library_facets,lexicon}.rs`, `help_catalog/*` | `model`, `change`, etc. según `architecture.yaml` del miembro | Importar el motor | Contraste y validación del corpus |
| Motor / `pseudolearn_abi` | `build.rs` (tipos de dato nuevos), `src/effect_operation.rs`, `src/capability_layout.rs` (capacidad `Entorno`), `src/collection_command.rs` (si DS-10 lo exige) | (hoja) | Capas superiores | Contrato de capas de datos |
| Motor / `pseudolearn_lexicon` | `build.rs`, `codegen/function_metadata.rs` (clase de retorno `widestNumeric`), `src/signatures.rs` | `source` | Capas superiores | Vocabulario y firmas de funciones |
| Motor / `pseudolearn_syntax` | `codegen/contextual.rs` (miembros nuevos de colección) | `source`, `diagnostics`, `lexicon` | Capas superiores | Gramática y vocabulario contextual |
| Motor / `pseudolearn_semantic` | `builtin_checker.rs`, `collection_checker.rs`, `collection_model.rs`, `effect_types.rs`, `capability_types.rs`, archivos nuevos para tipos ordenables/comparables y calendario | `abi, source, project, diagnostics, lexicon, syntax` | Importar `runtime`, `vm`, `library` | Tipado y reglas estáticas |
| Motor / `pseudolearn_ir` | `operation.rs`, `type_checker_intrinsics.rs`, `collection_types.rs`, `type_checker_*` (solo si DS-02/DS-10 añaden operaciones) | `source`, `abi` | `runtime`, `vm`, `library` | Modelo y verificador de la RI |
| Motor / `pseudolearn_lowering` | `expressions_builtins.rs` (dividir al superar 300 líneas), `collections.rs`, archivo nuevo de bajada de ordenación | `source, semantic, ir, diagnostics` | `runtime`, `vm` | Bajada de HIR a RI |
| Motor / `pseudolearn_bytecode`, `pseudolearn_vm`, `pseudolearn_vm_dispatch` | `compile*`, `load/`, `machine/`, tablas de despacho (solo con operaciones de RI nuevas); `machine/effect_completion.rs` y `effects.rs` (PG-S.07) | según `architecture.yaml` | `semantic`, `lowering`, `service` | Ejecución en VM |
| Motor / `pseudolearn_runtime` | `host_effect.rs`, `host_words.rs`, `host_validation.rs`, `memory_host*.rs`, `capability_table.rs`, `secret_policy.rs` y archivos nuevos (regla de sensibilidad por nombre; semántica de directorios del doble) | `runtime, abi, diagnostics` | `vm`, `library` | Sesión de efectos, cinta, doble de memoria |
| Motor / `pseudolearn_library` | archivos nuevos: `text_case.rs`, `decimal_format.rs`, `text_padding.rs`, `calendar_*.rs`, `transcendental/{tangent,arcsine,arccosine,arctangent2,logarithm_bases}.rs`; modificados: `lib.rs`, `local_operations.rs`, `collections.rs` | `runtime, diagnostics` | `vm`, `host`, E/S real | Funciones puras de texto, números, calendario y colecciones |
| Motor / `pseudolearn_host` | archivos nuevos por operación de sistema de archivos, entorno y zona del sistema; `physical_error.rs`, `physical_host.rs`, `architecture.yaml` (dependencia de zonas, DS-18) | (hoja; dependencias externas declaradas) | Importar el motor | Efectos reales del sistema |
| Motor / `pseudolearn_aot_rt`, `pseudolearn_codegen` | `codegen/instruction_dispatch.rs` (`UNSUPPORTED_OPERATIONS`) y sus pruebas | según `architecture.yaml` | `unsafe` en codegen | Sujeto nativo (acreditación en PG-N) |
| Motor / `pseudolearn_service`, `pseudolearn_api`, `pseudolearn_timeline`, `pseudolearn_wasm` | `service`: `effect_tokens.rs`, `identifier_roles.rs`, `translator.rs`; `api`/`timeline`/`wasm`: salida con flujo y código (PG-S.07), presentación de valores opacos | según `architecture.yaml` | `semantic` desde `api` solo lo declarado | Servicio de lenguaje y fachada |
| `pseudolearn_cli` | `editor_effects.rs`, `dap_effects.rs`, `dap_pump.rs`, `editor_protocol.rs`, `execution_options.rs`, `adapter.rs`, `conformance.yaml` | su `architecture.yaml` | Copiar implementaciones del anfitrión | CLI y protocolo de editor |
| `pseudolearn_vscode` | `adapters/browser_effect_host.ts`, `browser_file_host.ts`, presentadores, gramática TextMate, `tests/adapters/*` | su `architecture.json` | Importar el motor Rust directamente | Extensión de escritorio y web |
| `pseudolearn_app` | `native/` (puente), `lib/engine/rust/export/*`, puerto/consola/vistas de ejecución, `test/*` espejo | su `architecture.yaml` | Capas de dominio importando infraestructura | App |

Respuesta a la tercera pregunta de `AGENTS.md` §1 (¿ya existe archivo dueño?): `physical_files.rs`, `local_operations.rs`,
`collection_checker.rs`, `expressions_builtins.rs` y `lib.rs` de `pseudolearn_library` ya concentran una responsabilidad
cada uno; **ninguna operación nueva se añade dentro de un archivo que ya está cerca de su límite**: cada una nace en un
archivo propio y el despacho solo gana una rama. Si añadir esa rama supera 300 líneas, el despacho se divide por familia
primero.

## 6. Presupuestos de rendimiento y seguridad

### 6.1 Rendimiento

| Presupuesto | Control | Línea base |
|---|---|---|
| La suite pura no paga por lo nuevo (infraestructura inactiva) | `PERF.SUITE.CORE` y `PERF.AOT.LEVEL` con `PERF.PROTOCOL` antes y después, mismo equipo | `PERF.SUITE.CORE` ya estaba en 1,0443× frente a 1,02× (H-17 del análisis; se resuelve en PG-7.02): PG-S no puede **empeorarlo**; se mide y se informa la diferencia |
| `Ordenar` es O(n log n) con memoria auxiliar O(n) contada en celdas | prueba con 10⁵ elementos; límite `cells` | Sin precedente: la medición es la primera |
| Funciones trascendentes nuevas: coste por llamada comparable a `sen`/`atan` | `pseudolearn_math_probe` registra µs por llamada (README de `library`: 20–70 µs ordinarios, ~300 µs en argumentos extremos) | Línea base de las siete existentes |
| Tamaño del puente de la app y de `pseudolearn_host` | `PERF.ARTIFACT.SIZE` antes y después de la dependencia de zonas (DS-18) | Sin medir (PS-E01) |
| Crecimiento de código por instancia de ordenación (DS-10 = A) | E-PG-03: 1/10/100 combinaciones de tipos | Sin medir |

Afirmaciones de coste solo con línea base, control semántico equivalente y protocolo `PERF.PROTOCOL` (§5.4 del plan general).

### 6.2 Seguridad y límites

- Todo lo que crece tiene límite y terminación definida: `Ordenar` (celdas y combustible con comparador),
  `Listar` (número de entradas contado como celdas del vector resultante), `Decimales`/`Rellenar*` (tope de dígitos y de
  ancho), lectura de entorno (tamaño de valor acotado por el presupuesto de celdas de cadena), `Claves()` (celdas).
- Ninguna operación nueva usa `unwrap`/`expect`/pánico/índice inseguro/aritmética implícita/conversión con pérdida
  (`QUALITY-NO-PANIC`); los fallos esperables son valores (`ErrorES`) o trampas con código de diagnóstico.
- Confinamiento: toda ruta pasa por una capacidad de directorio; `Subdirectorio` no se amplifica; pruebas adversarias
  con `..`, enlaces simbólicos y rutas absolutas contra una capacidad confinada (STRIDE de la hoja de ruta, §9, y
  E-PG-09).
- Privacidad en cinta: DS-20; prueba de que el valor sensible no aparece en ninguna salida observable.
- Determinismo: ningún observable depende del orden del disco, del reloj de presentación ni del entorno salvo por la
  lectura grabada; `Listar` ordena; `Claves()` usa el orden de inserción.
- Cero simulación: la zona horaria y el entorno son lecturas reales en vivo; el doble de memoria no es accesible desde
  producto.

## 7. Pruebas, verificadores y experimentos

### 7.1 Matriz por punto (corpus, espejo, consumidor, verificador)

| Punto | Corpus | Tests espejo | Consumidores | Verificadores |
|---|---|---|---|---|
| S.01 | `LIB.CORE.TEXT`, `LIB.MODEL` | `library`, `semantic`, `vm`/`api` | `service`, extensión, app (export, ayuda) | `see validate/lock/export --check`, `conform engine` |
| S.02 | `LANG.TYPES.VECTOR/DICTIONARY`, `LANG.PROFILE.VOCABULARY`, `DIAG.*`, `IR.INSTRUCTIONS` | `semantic`, `lowering`, `library`, `runtime`, `vm`, `api`, propiedades | `service`, extensión, app (diagramas, traza, export) | ídem + E-PG-03 |
| S.03 | `LIB.CORE.MATH`, `LIB.CORE.ROUNDING`, `LIB.MODEL` | `library`, `semantic`, `ir`, `vm`, oráculo y su negativo | ídem | ídem + contraste masivo + propiedad |
| S.04 | `LIB.IO`, `RT.HOST.INTERFACE`, `LIB.MODEL` | `host`, `runtime`, `abi`, `api`, adversarios | CLI, web, app | ídem + E-PG-09 |
| S.05 | `LIB.TIME`, `LIB.MODEL` | `library`, `host`, `runtime`, `api` | ídem | ídem + `PS-E01`, `PS-E05` |
| S.06 | `LANG.CAPABILITY.MODEL`, `RT.HOST.INTERFACE`, `ENG.EFFECT.TAPE` | `abi`, `runtime`, `semantic`, `host`, `api` | ídem | ídem + prueba de privacidad |
| S.07 | `API.EXECUTE`, `API.WIRE-FORMAT`, `TOOL.CLI.RUN`, `TOOL.DAP`, `APP.EXEC.*`, `LIB.MODEL` | `vm`, `runtime`, `api`, `timeline`, CLI, extensión, app | CLI, extensión, app | `conform engine/cli/app` |
| S.08 | `LIB.CORE.CONVERSION`, `LIB.CORE.TEXT`, `LIB.MODEL` | `library`, `semantic` | ídem | ídem + propiedad |
| S.09 | (ninguno nuevo) | exhaustividad de adaptadores, aceptación por plataforma | todos | matriz de §7.2 |

Camino feliz, infeliz y límite de cada pieza (`TEST-BOTH-PATHS`) en carpetas espejo (`TEST-MIRROR`; en Rust, black box en
`tests/` y los internos en `<módulo>_tests.rs`). Una suite completa de un miembro solo se añade si una prueba dirigida
falla o el cambio cruza fronteras sin cobertura (decisión del 2026-10-24); se registra qué se ejecutó y qué se omitió.

### 7.2 Matriz de aceptación por plataforma (PG-S.09)

Filas: S.01 mayúsculas/minúsculas, S.02 colecciones, S.03 números, S.04 archivos, S.05 fecha y hora, S.06 entorno,
S.07 error y código de salida, S.08 formato. Columnas: VM/API, CLI, extensión de escritorio, extensión web (Chromium,
WebKit), app macOS, app iOS simulador, app Windows. Celdas esperadas distintas de `cumple`: S.06 en web (error tipado),
Windows (`no verificado` en todas las filas), S.04 en web según el proveedor del sistema de archivos virtual.

### 7.3 Verificadores nuevos y sus casos negativos

Cada verificador o prueba de exhaustividad que PG-S añada lleva un fixture con una violación deliberada que **debe**
fallar (`AGENTS.md` §5). Lista mínima: (1) oráculo con error deliberado detectado por el contraste de matemática;
(2) prueba de exhaustividad de adaptadores web contra `EFFECT_OPERATIONS` (`PG-S.09.03`) con una operación sin rama;
(3) ficha de ayuda ausente para una identidad nueva (ya cubierto por `fixtures/help-catalog/`: añadir caso si el
validador cambia); (4) vínculo `pendiente` sin `resuelve_en`; (5) operación de RI sin bajar ni listada como no soportada.

### 7.4 Comandos y alcance

Los comandos exactos están en la sección «Cómo se verifica» del README de cada miembro; **copiarlos de allí**, no de
este plan. Referencia a verificar contra esos README (`PS-V` no necesaria: ya figuran en el README de `pseudolearn_spec`
y en los README de crates citados):

- Corpus: `cargo run -p see_cli --bin see -- validate`, `lock --check`, `lock --refresh <IDs>`, `export --check`,
  `conform --subject engine|aot|service|cli|app [--only ID]`, `conform --operation properties`.
- Motor: `cargo test -p <crate>` por crate afectado; `cargo xtask verify`; `rust-checks` (capas, límites, nombres,
  comentarios) y Clippy estricto según el README del motor.
- CLI: pruebas del miembro; extensión: `pnpm` (Node 22.23.3, pnpm 12.8.1) según su README; app: `flutter test`
  dirigido a los directorios espejo tocados.

### 7.5 Recuento de D1/D2 (apoyo a PS-V-01)

El recuento se obtiene leyendo los bloques `definicion` de `lib.model.md` (JSON): contar `valor` de `D1` y
`valor.operations` de `D2`. Registrar la salida en §11.

### 7.6 Experimentos

| ID | Objetivo | Protocolo | Procedencia exigida | Si falla |
|---|---|---|---|---|
| `PS-E01` | Elegir el origen del desplazamiento de zona horaria del sistema (DS-18) | Comparar alternativas por licencia, tamaño de `pseudolearn_host` y del puente, compatibilidad macOS/Linux/iOS sim/Windows (solo compilación) | Hashes de lockfile, versión de la cadena, plataforma, tamaños crudos | Parar; presentar a la persona |
| `PS-E02` | Validar la ruta (A) del comparador (DS-10) | Prototipo con 1/10/100 combinaciones de tipos, combustible agotado dentro del comparador, comparador que falla, comparador que modifica, traza activa | Semillas, tamaños de código, conteos | Pasar a (B) con ADR o (C) con aprobación |
| `PS-E03` | Corrección de las seis trascendentes | Contraste masivo con el oráculo (`PG-S.03.07`) | Plataforma, hashes de oráculo y biblioteca, semilla, muestras crudas | No cerrar S.03 |
| `PS-E04` | Igualdad de tablas Unicode por plataforma (`PS-V-11`) | Mismo corpus de cadenas en nativo y Wasm, comparando bytes del resultado | Versión de la cadena de herramientas, hashes de resultados | Parar S.01 |
| `PS-E05` | Reproducción sin consultar al sistema (E-PG-05 ampliado) | Grabar y reproducir programas con cada operación de efecto nueva; fallar en cada frontera solicitud/commit/respuesta | Semilla, cintas | No cerrar el punto |
| `PS-E06` | Adversarios de rutas (E-PG-09 ampliado) | 1000 rutas generadas sobre una capacidad confinada y una ambiente; `..`, enlaces, `:`/`\`, nombres no UTF-8 | Semilla, sistema operativo, muestras | No cerrar S.04 |

Cualquier experimento que dependa de dispositivos físicos o participantes es complementario y no bloquea el cierre
(decisión del 2026-10-22–24); se registra su ausencia sin afirmar cobertura.

## 8. Riesgos y señales tempranas

| ID | Riesgo | Señal temprana | Mitigación |
|---|---|---|---|
| K-13 (hoja de ruta) | La cinta revela una variable de entorno sensible | Un valor de entorno en texto claro en una cinta exportada | DS-20, prueba de privacidad (S.06.08) |
| K-07 (hoja de ruta) | Una ruta escapa del confinamiento de `Subdirectorio` con las operaciones nuevas | `PS-E06` encuentra un escape | Pruebas por rama `Ambient`/`Confined`; cap-std para `Confined` |
| K-06 (hoja de ruta) | La reproducción repite un borrado o un renombrado | Un efecto de archivo llega al anfitrión durante la reproducción | `PS-E05`; vocabulario de cinta ya cubre `filesystem` |
| K-14 (hoja de ruta) | Diferencia de último bit en una trascendente nueva | Una discrepancia en `PS-E03` | Escalada de Ziv y oráculo racional |
| K-09 (hoja de ruta) | La dependencia de zonas excede tamaño o no soporta una plataforma | Resultado de `PS-E01` | Parar; alternativa (c) con coste explícito |
| K-04 (hoja de ruta) | Crecimiento de código por instancia de ordenación | E-PG-03 superlineal | DS-10 reversión a (B) |
| K-16/K-17 (hoja de ruta) | La ficha o la explicación se asigna al símbolo equivocado | Cobertura de ayuda con huecos; `service` resuelve un miembro de colección a otro rol | Cobertura exhaustiva (`C09`); pruebas de `service` con homónimos (`Contiene` de texto frente a `Contiene` de vector) |
| K-19 (hoja de ruta) | Una operación nueva cae como proceso genérico en la app | Celda «no soportado» nueva en la matriz | S.09.04 |
| PS-K-01 | Cambio de contrato de salida (flujo de error) más ancho de lo previsto | `PS-V-09` revela más de seis consumidores | DS-22 alcance reducido, decisión de la persona |
| PS-K-02 | PG-L reescribe `semantic`/`lowering` mientras PG-S los toca | Conflicto de archivos o de README | Puerta G0; no ejecutar en paralelo (el DAG no autoriza paralelismo) |
| PS-K-03 | Colisión léxica de los nombres nuevos (`min`, `max`, `keys`, `contains`, `sort`) con identificadores de usuario o alias existentes | Fallo de `M2` o regresión en casos con esos identificadores | Los nombres no son reservados (`LIB.MODEL#R1`); casos de homonimia en S.03/S.02 |
| PS-K-04 | Crecimiento de huella mayor que la de `62023207` (120 archivos) | La plantilla de `PG-S.C03.03` | Puntos de control por punto; commits por punto autorizado |
| PS-K-05 | Exportación Rust/Python de la app promete una semántica distinta (empates de redondeo, libm, orden de cadenas) | Diferencia al comparar con el destino | Rotular «sin equivalente» o documentar el límite |

## 9. Dependencias de la persona

Todas las decisiones **Persona** de §3 se piden juntas al revisar `PG-S.C02` para no bloquear la ejecución más tarde.

| Cuándo | Qué se necesita |
|---|---|
| Antes de `C01` | Autorización expresa, en mensaje nuevo, para iniciar PG-S (`PHASE-STOP`). Puede ser por punto |
| Antes de `C01` | Resolver `PS-P-01` (PG-L sin cerrar) y `PS-P-02` (PG-B inconsistente en §6 del plan general) |
| Al revisar `C02` | Confirmar o ajustar DS-05, DS-07, DS-11, DS-12, DS-14, DS-15, DS-20, DS-21, DS-23 y nombres **CANDIDATOS** |
| `PG-S.05.02` | Revisar la tabla de `PS-E01` (dependencia nueva, tamaño, plataformas) |
| `PG-S.07.02` | Aprobar el alcance real del cambio de contrato de salida (o el alcance reducido de DS-22) |
| Cierre | Aprobar los pendientes declarados y los diferimientos; los puntos que dependen de dispositivos físicos o de participantes quedan «requiere a la persona» |

**Conflictos conocidos (`CONFLICT-REPORT`)** que este plan no resuelve por su cuenta:

1. `RT.PROCESS#R3` («el ejecutable no depende de variables de entorno») y `#R2` (códigos 0/3/4/5) contradicen DS-19 y
   DS-21 para el sujeto nativo. El análisis reserva su reescritura a `PG-N.01`. PG-S no edita `RT.PROCESS`; el sujeto
   `aot` queda con vínculos `pendiente`. Si la persona prefiere reescribirlo ya, es un cambio de alcance.
2. `TOOL.CLI.RUN#R2` («0 si completed, 1 en cualquier otro caso») se edita en PG-S.07 como texto oficial sin `cambio`.
3. `ENG.EFFECT.TAPE#R3` y `LANG.CAPABILITY.MODEL` (familias y capacidades cerradas) se amplían (DS-19): se edita texto
   oficial de reglas estables; `SPEC-VERSION-FREEZE` lo permite sin `cambio`.
4. `PS-P-02`: §4.11 y §6 del plan general se contradicen sobre el estado de PG-B.

## 10. Orden de ejecución y puntos de control

Orden propuesto (dentro de cada punto rige especificación → casos → tests → código → README → verificación):

1. **G0 · Puerta de entrada.** `C01` recibido, `PS-P-01`/`PS-P-02` resueltos, `PG-S.C11.01` (línea base) y
   `PG-S.C03.01`–`.03` hechos, decisiones **Persona** confirmadas. Sin G0 no hay edición.
2. **PG-S.01 (piloto) → G2.** Parar y reportar la huella real; ajustar §5 y los demás puntos.
3. **PG-S.08** (formato; reutiliza la tubería de S.01) y **PG-S.03** (números, con su oráculo primero) → **G3**
   (contraste masivo y `PERF.*` sin regresión).
4. **PG-S.02** (colecciones; `PS-E02` primero) → **G4** (E-PG-03, traza y app).
5. **PG-S.06** (entorno), **PG-S.07** (error y código; `PG-S.07.02` aprobado antes de especificar), **PG-S.04**
   (archivos), **PG-S.05** (fecha y hora; `PS-E01` primero) → **G5** (cinta/privacidad, adversarios de rutas y
   reproducción).
6. **PG-S.09** (aceptación por plataforma) → **G6**.
7. Cierre `C04`–`C13`, resumen y **parada** (`PHASE-STOP`).

Cada punto cierra con sus verificaciones dirigidas; las campañas pesadas (rendimiento, contraste masivo, aceptación por
plataforma) se ejecutan en los controles indicados y no por tarea. Un commit por punto autorizado, en la rama única
(`GIT-SINGLE-BRANCH`), con el formato de la skill `commit-message` (inglés, Conventional Commits, ámbito del miembro,
sin atribución de IA en el cuerpo del mensaje), y push ordinario comprobado (`git branch --show-current` y revisión del
destino).

## 11. Resumen de ejecución

Estado de las tareas: §4.0 y PG-S.01 ejecutadas el 2026-11-04 sobre `2d6254aa`, por instrucción directa de la persona («implementa 4.0 y PG-S.01», eligiendo siempre la opción recomendada). Esa instrucción se toma como `PG-S.C01` parcial, como decisión de iniciar PG-S antes de cerrar PG-L (`PS-P-01`, DS-13) y como confirmación de las decisiones **Persona** de DS-12 (nombres `AMayusculas`/`toUpper`, `AMinusculas`/`toLower`). `PS-P-02` sigue sin resolver y no afecta a PG-S.01. PG-S.02 y PG-S.03 tienen implementación preparada y 19 de sus 22 puntos completados. La persona pidió detener las pruebas y preparar el relevo el 2026-11-04: PG-S.02.11, PG-S.03.07 y PG-S.03.11 permanecen pendientes. Ninguna de ambas fases se declara cerrada. PG-S.04–.09 siguen pendientes.

| Tarea | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| `PG-S.C01` | Parcial | Instrucción de la persona del 2026-11-04 | Cubre §4.0, PG-S.01 y la iteración conjunta PG-S.02/PG-S.03 autorizada posteriormente |
| `PG-S.C02` | Pendiente | Este documento | Requiere revisión de la persona |
| `PG-S.C11.01`, `PG-S.C03.01`–`.03` | Cumplida | Línea base: `cargo test -p pseudolearn_library` en verde sobre `2d6254aa` antes de editar el código de S.01; `see validate` y `see export --check` en verde. Hipótesis en §11.1 | La suite completa del motor se ejecutó al cierre (`cargo xtask verify`) |
| `PG-S.01.01`–`.10` | Cumplida | Corpus: `LIB.CORE.TEXT#T4`, casos C19–C30, D2 `text_to_upper`/`text_to_lower`, fichas `help.pgs01.*` en `tool.service.catalog.md`, cobertura IR V210, vínculos engine (`cumple`) y aot (`pendiente`, `PG-N.08`). Motor: `text_case.rs`, `text_case_tests.rs`, ramas en `local_operations.rs`. `see validate`, `lock --refresh` (IR.INSTRUCTIONS, LIB.MODEL, LIB.CORE.TEXT, TOOL.SERVICE.CATALOG), `export --check`, `conform --subject engine --operation properties` (31 propiedades) y `conform --subject engine` (2206 observaciones, 0 divergencias) | |
| `PG-S.01.11` | Informe en §11.2 | | La parada de control G2 la decide la persona |
| `PG-S.02.01`–`.10` | Cumplidas | [Informe y relevo](informe-pg-s-02-03.md) | Implementación, corpus, tests y consumidores preparados |
| `PG-S.02.11` | Pendiente | Informe, sección de pendientes | Falta consolidar conformidad con el último hash de diccionario; no se cierra la fase |
| `PG-S.03.01`–`.06`, `.08`–`.10` | Cumplidas | [Informe y relevo](informe-pg-s-02-03.md) | Código, oráculo, casos, propiedad y consumidores implementados |
| `PG-S.03.07`, `.11` | Pendientes | Informe, sección de pendientes | Contraste completado para tan/asin/acos; faltan atan2/log2/log10 y consolidación final |
| `PG-S.04.01`–`.10` | Pendiente | | |
| `PG-S.05.01`–`.11` | Pendiente | | |
| `PG-S.06.01`–`.08` | Pendiente | | |
| `PG-S.07.01`–`.09` | Pendiente | | |
| `PG-S.08.01`–`.06` | Pendiente | | |
| `PG-S.09.01`–`.06` | Pendiente | | |
| `PG-S.C03`–`C13` | Pendiente | | |

### 11.1 Registro de hipótesis (`PS-V-01`–`PS-V-14`)

| ID | Resultado | Evidencia | Consecuencia |
|---|---|---|---|
| PS-V-01 | Confirmada | D1 = 28 y D2 = 62 antes de S.01 (64 después), por lectura de los bloques `definicion` de `lib.model.md` | Ninguna |
| PS-V-02 | Confirmada | La operación D2 `receiver: null`, familia `text`, `effect: false` se resuelve como llamada libre y se despacha por `local_operation`; casos C19–C28 cumplen en es y en | DS-01 (a) se mantiene |
| PS-V-04 | No consumida | Ninguna operación de S.01 falla en ejecución | Se verifica en S.08 |
| PS-V-09 | Pendiente | Se consume en S.07 | |
| PS-V-11 | Parcial | Las tablas son las de la cadena `1.99.0` fijada en `rust-toolchain.toml` de cada miembro; no se ejecutó `PS-E04` (nativo frente a Wasm) | `PS-E04` queda pendiente; el README de `pseudolearn_library` declara el límite |
| PS-V-12 | Confirmada por lectura | `apps/pseudolearn_app/lib/engine/rust/export/export_coverage.dart` marca como bloqueo `capability` toda `effectOperation`; no se ejecutó `flutter test` | Sin cambio en la app |
| PS-V-13 | Confirmada por validación | `see validate` acepta un vínculo `pendiente` con `resuelve_en` para `LIB.CORE.TEXT#T4` en aot | Ninguna |
| PS-V-14 | Pendiente | Se consume en S.09 | |

### 11.2 Informe de piloto de PG-S.01

- Huella real: corpus (`lib.model.md`, `lib.core.text.md`, `ir.instructions.md`, `tool.service.catalog.md`; `catalogs.json` y `export.json` se regeneran con `see export`), `conformance.yaml`, `conformance-aot.yaml`, y en `pseudolearn_library`: `text_case.rs`, `text_case_tests.rs`, `lib.rs`, `local_operations.rs`, README. No hubo cambios en `abi`, `lexicon`, `semantic`, `lowering`, `vm`, `host`, `service`, extensión ni app: el generador (`build.rs`) recoge las operaciones D2 nuevas sin edición.
- Correcciones a §5 para los demás puntos: `catalogs.json` es artefacto generado, y la fuente de las fichas de ayuda es `tool.service.catalog.md` (cards e inventario de roles); los vínculos de conformidad del motor y la cobertura IR (`ir.instructions.md`) son obligatorios para cada regla estable nueva; la ejecución de `conform` exige antes `--operation properties` con el corpus actualizado.
- Hallazgo: un literal de un solo carácter (`"x"`) en un parámetro `text` se trata como `Caracter` y su conversión a cadena cuesta celdas; los casos de límite de celdas usan literales de dos o más caracteres.
- Una propiedad (`IR.LOWERING#R2`) falló en la primera ejecución de propiedades y pasó en la segunda sin cambios de código; no se investigó la causa.

Revisión Git de cierre: · Verificadores ejecutados: · Suites omitidas y razón: · Pendientes justificados: · Decisiones de
la persona: · Puntos de §4 cumplidos:

### 11.3 Relevo de PG-S.02 y PG-S.03

La persona solicitó detener las pruebas y resumir el trabajo. Se marcaron 19 puntos completados; tres permanecen sin marcar. El [informe de relevo](informe-pg-s-02-03.md) conserva implementación, decisiones, resultados, errores pendientes, comandos de continuación y ubicación de los crudos. No se hicieron commits ni push de esta iteración y no se cerró ninguna de las dos fases.
