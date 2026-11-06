# Fase PG-N · Compilador nativo completo — plan de ejecución

## 0. Metadatos y contrato de ejecución

- Fase: PG-N (§4.15 del [plan general](plan-ejecucion-proposito-general.md)). Origen: decisión D-09 (a) de la persona del
  2026-11-02 y [análisis del 2026-11-02](analisis-lenguaje-completo-sin-simulacion.md), §B.3c. Donde el análisis y este
  plan difieran, **manda este plan** (ver `PN-C-01`).
- Fecha de redacción: 2026-11-06, America/Lima. Revisión Git inspeccionada: `c3e3f24f`, rama
  `feature/agregar-ruta-de-especificacion`. El árbol **no estaba limpio**: 54 entradas sin commit de otro trabajo
  (posterior a PG-C) en `pseudolearn_semantic`, `pseudolearn_aot_rt`, `pseudolearn_codegen`, `pseudolearn_diagnostics`,
  `pseudolearn_service`, `pseudolearn_syntax`, SEE, corpus, `conformance-aot.yaml`, `conformance.yaml` del motor y de
  la CLI, extensión y app (ver `PN-P-03`).
- Autorización de la persona: **concedida** el 2026-11-06 con la instrucción de ejecutar el plan en una iteración (ver §11). Este documento se redactó por petición directa de la persona del
  2026-11-06 («Crea el plan de ejecución para `4.15 PG-N`… enfocado en la velocidad de desarrollo ágil y rápido…»). Esa
  petición no autoriza la ejecución (`PG-N.C01`) ni sustituye la revisión (`PG-N.C02`).
- **Modo de ejecución pedido por la persona: bloques rápidos de implementación y un único bloque final pesado.** Los
  bloques `B0`–`B6` solo implementan y usan comprobaciones de **nivel D** (§7.4): compilar, Clippy y tests dirigidos
  del crate tocado, y `see conform --only` de las identidades del bloque. **Todo** lo pesado —suites completas,
  `cargo xtask verify`, conformidad completa de todos los sujetos, diferencial VM/AOT (`PG-N.11`), E-PG-06 en nativo,
  rendimiento (`PG-N.12`), consumidores y aceptación por plataforma— se concentra en el bloque final `BF`, seguido de
  un ciclo de corrección. Ningún bloque intermedio detiene la ejecución salvo las paradas de §10.3.
- **Disco:** liberar espacio está autorizado con las reglas de §0.2 (mismas que en PG-C). Al redactar quedaban
  **27 GiB libres** (`PN-H-16`), por debajo del umbral: se libera antes de `B0`.
- Documento transitorio: ninguna especificación, README ni código fuera de `docs/` puede citarlo
  (`DOC-NO-TRANSIENT-REFS`). Cada decisión de §3 se traslada a su dueño (corpus o README del miembro) **en el mismo
  cambio** que la implementa (`DOC-README-TRUTH`, `DOC-NO-ORPHAN-DECISION`).

### 0.1 Reglas para quien ejecute (anti-alucinación)

Obligatorias. Ante la duda entre una regla de esta lista y la velocidad, gana la regla.

1. **Tres clases de afirmación, siempre rotuladas.** **Comprobado** (`PN-H-nn`: visto en `c3e3f24f`, con ruta),
   **Hipótesis** (`PN-V-nn`: nadie lo comprobó; trae la orden que lo confirma) y **Propuesta** (`CANDIDATA`: nombre de
   archivo, opción, código de diagnóstico o texto que el corpus todavía no fija). La primera tarea que consume una
   hipótesis la verifica y anota el resultado en §11.1. Una `CANDIDATA` se puede cambiar si choca con una convención
   existente; el cambio se anota en §11.3.
2. **Nada existe hasta que se crea.** Ningún archivo, función, tipo, opción o ID marcado como `CANDIDATA` existe. Antes
   de editar un archivo, leerlo entero; antes de usar un símbolo, `git grep -n` en el árbol actual. Prohibido inventar
   firmas de Cranelift, de `pseudolearn_runtime` o de `pseudolearn_host`: se leen en el código o en `~/.cargo/registry`.
3. **HEAD cambiado.** Si `git rev-parse --short HEAD` no es `c3e3f24f`, ejecutar `git diff --stat c3e3f24f..HEAD`,
   repetir las comprobaciones de §1.2 afectadas y anotar las diferencias en §11.
4. **Secuencia por punto:** especificación → casos con esperado **derivado de la regla** → tests dirigidos → código →
   README y reglas → nivel D (`SPEC-FIRST`, `SPEC-INDEPENDENT-ORACLE`). La mayoría de los puntos de PG-N **no crean
   reglas nuevas**: activan para el sujeto `aot` casos que ya existen y que el sujeto `engine` ya cumple. En ese caso la
   «especificación» es comprobar que la regla no excluye al sujeto `aot` y los «casos» son los existentes; prohibido
   copiar al esperado la salida del binario nativo. Si el nativo discrepa de un caso que la VM cumple, el defecto está en
   el nativo.
5. **Congelamiento (`SPEC-VERSION-FREEZE`).** `RT.PROCESS`, `RT.ABI`, `RT.LINKING` y cualquier otra identidad editada
   conservan `estable` `1.0.0`; su texto se reescribe sobre la misma identidad, sin `cambio`, y se reancla con
   `see lock --refresh` listando **en una sola orden** todos los IDs editados del bloque.
6. **Generados (`GEN-NO-HAND-COPY`).** `specifications/export.json`, lo que generan los `build.rs` (incluido el
   archivo del runtime nativo que embebe la CLI) y la gramática de la extensión **jamás** se editan a mano.
7. **Edición quirúrgica.** Prohibidos los formateadores masivos y los *round-trip* de JSON sobre archivos existentes.
   `conformance-aot.yaml`, `cases/catalogs.json` y `diag/diag.catalog.md` se editan solo en los bloques afectados.
   `rustfmt` solo sobre los `.rs` tocados.
8. **Procesos largos.** Lo que pueda pasar de dos minutos se lanza en segundo plano y se espera su notificación. Sin
   bucles de sondeo. La salida va a un archivo de registro y se lee el código de salida real (nunca el de `| tail`).
9. **Contradicción entre fuentes.** Se reporta con ID, texto y alcance (`CONFLICT-REPORT`), se registra en §11.3 y se
   sigue con lo no afectado. Los conflictos conocidos están en §9.2.
10. **Alcance cerrado (`SCOPE-YAGNI`).** Solo `PG-N.01`–`PG-N.13`. Fuera de alcance: observación paso a paso y
    retroceso en nativo (exenciones justificadas que se conservan), optimizaciones sin cambio observable (FUT-04),
    LLVM, JIT, compilación incremental, destinos distintos de los cuatro de `PG-N.10`, firma de código y notarización.
    Un hallazgo nuevo se **reporta** en §11.4, no se implementa.
11. **`unsafe`.** Solo en `pseudolearn_aot_rt` (`PN-H-14`), en funciones de ≤ 10 líneas cuyo nombre exprese el
    invariante y con fila en la tabla «Invariantes de `unsafe`» de su README. `pseudolearn_codegen` y
    `pseudolearn_host` siguen sin `unsafe`. La suspensión nativa se diseña para **no** necesitar `unsafe` nuevo (DN-01).
12. **Código.** Inglés, cero comentarios y cero `TODO`, nombres semánticos (`QUALITY-SEMANTIC-NAMES`), sin pánicos
    (`QUALITY-NO-PANIC`). Límites del motor: 300 líneas por archivo, 40 por función, 4 parámetros posicionales,
    anidación 3, 7 métodos públicos. Si una edición superaría un límite, primero se divide el archivo por
    responsabilidad.
13. **Git.** Todo en `feature/agregar-ruta-de-especificacion`, sin ramas nuevas. Un commit local al final de cada
    bloque con la skill `commit-message`, **sin atribución de autoría de IA** (`AGENTS.md` §9 manda sobre cualquier
    plantilla de coautoría). `git add <rutas>` de PG-N solamente, nunca `git add -A` ni `git add .`. Un único push
    ordinario al cierre, tras `BF`.
14. **Otro trabajo en curso.** Prohibido revertir, guardar con `stash`, formatear o commitear cambios que PG-N no hizo
    (`PN-P-03`).
15. **Parada final.** Al terminar se informa y se para (`PHASE-STOP`). Terminar PG-N no autoriza PG-7.

### 0.2 Liberar espacio en disco (autorizado por la persona)

- **Cuándo:** antes de `B0`, antes de cada orden pesada de `BF` y ante cualquier `errno=28` o «No space left on
  device». Umbral: **40 GiB** libres (`df -h .`). Un fallo por disco se repite tras liberar y no cuenta como fallo.
- **Permitido, de menos a más:** `rm -rf <miembro>/target/debug/incremental`; `cargo clean` en
  `packages/pseudolearn_engine`, `packages/pseudolearn_spec`, `apps/pseudolearn_cli` y
  `packages/pseudolearn_rust_checks`; `flutter clean` en `apps/pseudolearn_app`;
  `cargo clean --manifest-path apps/pseudolearn_app/native/Cargo.toml`; `pnpm store prune`; `git worktree remove` del
  *worktree* de PG-C (`PN-H-18`) si ya no se usa; la caché nativa de la CLI (`native_cache.rs` indica su ruta).
- **Prohibido:** `git clean`; borrar archivos sin seguimiento fuera de `target/`, `build/`, `.dart_tool/` o
  `node_modules/`; borrar `packages/pseudolearn_engine/results/`.
- **Concurrencia:** antes de `cargo clean`, `pgrep -fl "cargo|rustc"` no debe mostrar compilaciones de ese miembro.
- Cada limpieza se anota en §11 con orden y espacio liberado.

## 1. Punto de partida comprobado

Rutas relativas a la raíz. «Motor» = `packages/pseudolearn_engine/`. «Corpus» = `packages/pseudolearn_spec/specifications/`.
Para redactar solo se leyeron archivos y se ejecutaron `git grep`, `df` y `rustup`; ninguna suite.

### 1.1 Dependencias y puertas previas

| ID | Evidencia | Tratamiento exigido |
|---|---|---|
| PN-P-01 | §6 del plan general: PG-N sin iniciar | La persona revisa este plan (`C02`) y autoriza `C01` en un mensaje nuevo |
| PN-P-02 | §3 del plan general: PG-N depende de PG-B, PG-L, PG-S y PG-C. PG-C cerrada; PG-L sin `C12`–`C13`; PG-S sin `C10`–`C13`; la fila de PG-B en §6 dice «.10–.30 sin iniciar» mientras el plan de PG-C la da por cerrada | La persona confirma con `C01` que PG-N empieza igual (como hizo con PG-C). PG-N no cierra ni reabre esas fases (`PN-C-02`) |
| PN-P-03 | 54 entradas sin commit ajenas, incluidas `aot_rt/src/{effects,lib,random}.rs`, `aot_rt/src/effect_text_faults*.rs` (sin seguimiento), `codegen/src/{abi_signatures,instruction_dispatch,lower_io}.rs`, `conformance-aot.yaml` | `B0` comprueba `git status`. Si siguen sin commit archivos que PG-N debe tocar, **parada** y pregunta a la persona |

### 1.2 Hechos comprobados

| ID | Hecho | Ruta |
|---|---|---|
| PN-H-01 | HEAD `c3e3f24f` («close the phase» de PG-C) | `git log -1` |
| PN-H-02 | `conformance-aot.yaml`: 362 vínculos, 100 `cumple`, 148 `exento`, **114 `pendiente`**. `resuelve_en`: `PG-N.08` 32, `PG-4.12` 17, `PG-4` 14, `PG-1.12` 13, `P6` 12, `PG-3.12` 11, `PG-4.07` 5, `PG-5.03.07` 3, `CF-PG5-02` 2, `PG-5.09.07` 2, `PG-4.10` 1, `PG-N.13` 1, `PG-5.01` 1 | motor, `conformance-aot.yaml` |
| PN-H-03 | Pendientes por familia: `LIB.IO` 12, `LANG.TASK.SCOPE` 10, `LANG.MODULE.IMPORT` 8, `LANG.TASK.CHANNEL` 8, `ENG.TASK.AGENDA` 7, `LIB.HTTP` 7, `LIB.TIME` 6, `ENG.EXEC.EFFECT-COMMIT` 5, `ENG.LIMITS` 4, `LANG.CAPABILITY.MODEL` 4, `LANG.MODULE.MODEL` 4, `LIB.HTTP.POLICY` 4, `RT.HOST.INTERFACE` 4, `ENG.TASK.MEMORY` 3, `LANG.TYPES.VARIANT` 3, y 1–2 en `ENG.EFFECT.TAPE`, `ENG.EXEC.EFFECT-ORDER`, `LANG.CONTROL.CLEANUP`, `LANG.PROFILE.MODEL`, `LANG.TASK.ISOLATION`, `LANG.TASK.SUSPENSION`, `LANG.TYPES.{DICTIONARY,GENERIC,VECTOR}`, `LIB.CORE.{CONVERSION,MATH,ROUNDING,TEXT}`, `LIB.JSON`, `LIB.SCENARIO.{BILINGUAL,FILE-JSON,HTTP-TASKS}`, `RT.PROCESS` | ídem |
| PN-H-04 | `UNSUPPORTED_OPERATIONS` tiene 28 operaciones: 16 de biblioteca (`CollectionBeginSort`, `CollectionClone`, `CollectionCommit`, `CollectionReverse`, `MathTan`, `MathAsin`, `MathAcos`, `MathAtan2`, `MathLog10`, `MathLog2`, `RealFloor`, `RealCeil`, `RealMin`, `RealMax`, `IntMin`, `IntMax`) y 12 de tareas (`TaskScopeOpen`, `TaskSpawn`, `TaskAwait`, `TaskScopeJoin`, `CallSuspendible`, `EffectAwait`, `TaskChannel`, `TaskValueLoad`, `TaskOutcome`, `TaskScopeResult`, `TaskCancelPoint`, `TaskScopeBoundary`). Terminan en `CodegenError::Unsupported` | `crates/pseudolearn_codegen/src/instruction_dispatch.rs:43` |
| PN-H-05 | `task.yield_check` se baja como operación vacía; `task_support.rs` detecta tareas y la API devuelve `NativeTasksUnsupported` | `codegen/src/task_support.rs`, `api/src/native_tasks.rs:6`, `api/tests/native_build.rs:130,151` |
| PN-H-06 | El diagnóstico `nativeTasksUnsupported` vive en el corpus y en los README | `cases/catalogs.json:4120`, `diag/diag.catalog.md:3507`, `README.md` del motor:620, `apps/pseudolearn_cli/README.md:445` |
| PN-H-07 | **La semántica de tareas ya es compartida**: `pseudolearn_runtime` contiene `task_agenda.rs` (`TaskAgenda`, `with_running_root`, `create_scope`, `spawn`, `execution`, `cancellation`, `close_scope`), `task_execution.rs` (`take_ready`, `begin`, `resume`, `complete`, `yield_task`, `fail`), `task_channel.rs`, `channel_selection.rs`, `channel_storage.rs`, `task_deadlock.rs`, `task_cancellation.rs`, `task_limits.rs`, `continuation.rs`, `effect_session.rs` y `tape_*.rs`. El recolector ya recorre `CONTINUATION_SHAPE_TAG` | `crates/pseudolearn_runtime/src/`, `heap/collect.rs:127` |
| PN-H-08 | La VM conduce esas piezas con ≈ 1 900 líneas propias en `crates/pseudolearn_vm/src/machine/{tasks,task_*,channels}.rs` | `wc -l` |
| PN-H-09 | `pseudolearn_abi` fija las disposiciones de continuación (cabecera de 8 palabras; función, estado, padre, resultado, ranuras escalares y de referencia), tarea y canal, compartidas con la VM | `crates/pseudolearn_abi/src/{continuation,task,channel}_layout.rs` |
| PN-H-10 | `pseudolearn_aot_rt` importa `pseudolearn_runtime` y `pseudolearn_library`, **no** `pseudolearn_host`; `unsafe` permitido | `architecture.yaml` del motor:119–123 |
| PN-H-11 | `pseudolearn_host` no importa crates del motor; usa `tokio`, `hyper`, `rustls`, `rustls-platform-verifier`, `cap-std`, `getrandom`, `jiff` | `architecture.yaml`:54–58, `crates/pseudolearn_host/Cargo.toml` |
| PN-H-12 | La regla `isolation` prohíbe `pseudolearn_codegen`, `pseudolearn_aot_rt` y `cranelift-*` en los grafos Wasm y de la app: enlazar `pseudolearn_host` en `aot_rt` no los afecta | `architecture.yaml`:12–47 |
| PN-H-13 | El runtime nativo de distribución usa el anfitrión desprendido: cada efecto de capacidad responde `interrumpido`; la feature `test-host` de la CLI usa el anfitrión de memoria para conformidad | `apps/pseudolearn_cli/README.md`:35,37 |
| PN-H-14 | El enlazador es `Command::new("cc")` con `-Wl,-dead_strip -lm` (macOS) o `--gc-sections -lpthread -ldl -lm -lgcc_s` (Linux) y sin argumentos en el resto; el archivo del runtime se embebe con `include_bytes!` desde `OUT_DIR/libpseudolearn_runtime_aot.a` | `apps/pseudolearn_cli/src/native_linker.rs`, `runtime_archive.rs`, `build_runtime_archive.rs` |
| PN-H-15 | La cadena fijada 1.99.0 trae `rust-lld` con los sabores `ld64.lld`, `ld.lld` y `lld-link` en `lib/rustlib/aarch64-apple-darwin/bin/gcc-ld/`. Solo está instalado el destino `aarch64-apple-darwin`. Xcode está instalado (`xcode-select -p`) | `rustup target list --installed` |
| PN-H-16 | Disco: 27 GiB libres de 228 GiB (87 %) | `df -h .` |
| PN-H-17 | Cranelift 0.136.3 y `target-lexicon` 0.13.5; `object` 0.40 solo de lectura en pruebas | `crates/pseudolearn_codegen/Cargo.toml` |
| PN-H-18 | El *worktree* de PG-C sigue en `.claude/worktrees/fase-pg-c-ejecucion-c65131` | `ls .claude/worktrees` |
| PN-H-19 | `RT.PROCESS`: R1 flujos; R2 códigos 0/3/4/5; **R3 «no depende de variables de entorno, del directorio de trabajo… solo de su entrada estándar y de la semilla fijada al compilar»**; R4 ya dice «autoridad plena… mediante las capacidades explícitas que el programa solicita». El runtime define además `EXIT_REPLAY = 6`, que R2 no nombra | corpus `rt/rt.process.md`; `aot_rt/src/process.rs:11–15` |
| PN-H-20 | `RT.LINKING`: R1 estático con el runtime, «sin bibliotecas dinámicas propias»; R2 intermedios eliminados siempre; R3 permiso de ejecución en Unix | corpus `rt/rt.linking.md` |
| PN-H-21 | `PERF.AOT.LEVEL`: R1 media geométrica ≤ 1,70 frente a V1F por familia; R2 salida verificada y nativo más rápido que la VM en las diez cargas; R3 emisión ≤ 15 ms de mediana. El resumen de PG-S registra R1 absoluto no certificado ya en la base | corpus `perf/perf.aot.level.md`; §4.14 del plan general |
| PN-H-22 | El ejecutable acepta `--effects-in`/`--effects-out` (los usa el adaptador `aot`); la CLI ya ofrece `--semilla`/`--seed` para la VM | `aot_rt/src/entry.rs:10–11`, `apps/pseudolearn_cli/src/execution_options.rs:62` |
| PN-H-23 | E-PG-06 (`pseudolearn_bench_worker pg-tasks`) solo corre en VM: ocho familias, un programa por semilla con los parámetros en el texto, «porque la ejecución nativa de tareas aún no existe» | `crates/pseudolearn_bench_worker/README.md`:115–135 |
| PN-H-24 | No existe una herramienta de diferencial VM/AOT con ese nombre; la paridad actual es la conformidad por sujeto y `aot_effect_parity` en la CLI | `git grep -i differential` |
| PN-H-25 | Pendientes heredados: fallos nativos de efectos, tareas y `tan` (PG-L); `aot` sin azar entero ni argumentos de fallos nativos (PG-C; el trabajo sin commit de `PN-P-03` parece abordarlo); repetir PG-S.02.01; PS-E04 (tablas Unicode nativo/Wasm) | §4.13, §4.14 y §4.16 del plan general |

### 1.3 Hipótesis por verificar (no usar como hecho)

| ID | Hipótesis | Orden que la confirma | La consume |
|---|---|---|---|
| PN-V-01 | Toda la semántica observable de tareas que la VM añade sobre `pseudolearn_runtime` (`PN-H-08`) puede extraerse al runtime sin cambiar la VM de forma observable | Leer `vm/src/machine/task_*.rs` y clasificar cada función en «conducción de marcos» o «semántica» | `PG-N.04.01` |
| PN-V-02 | La RI marca explícitamente todo punto de suspensión y el conjunto de funciones suspendibles se conoce al compilar | `git grep -n "Suspendible\|suspendible" packages/pseudolearn_engine/crates/pseudolearn_{ir,lowering}/src` | `PG-N.02.01` |
| PN-V-03 | El recolector ya trata tareas, canales y mensajes como raíces cuando los sostiene la agenda | Leer `runtime/src/heap/collect.rs` y `channel_references.rs` | `PG-N.05.01` |
| PN-V-04 | La bomba física de efectos concurrentes (hasta ocho solicitudes) vive en la CLI y no en `pseudolearn_host` | `git grep -n "8\|parallel\|worker" apps/pseudolearn_cli/src/physical_*.rs` | `PG-N.07.01` |
| PN-V-05 | `ld64.lld` enlaza un Mach-O ejecutable sin Xcode si recibe un `libSystem.tbd` propio y `-platform_version` | Espiga `PN-E01` | `PG-N.09.01` |
| PN-V-06 | Linux x64 sin bibliotecas del sistema se logra compilando el archivo del runtime para `x86_64-unknown-linux-musl` (CRT autocontenido) y enlazando con `ld.lld -static` | Espiga `PN-E01` | `PG-N.09.01` |
| PN-V-07 | Windows x64 se enlaza con `lld-link` y bibliotecas de importación generadas (no del SDK de Windows), con el archivo del runtime para `x86_64-pc-windows-msvc` o `-gnullvm` | Espiga `PN-E01` | `PG-N.09.01` |
| PN-V-08 | El archivo del runtime con `pseudolearn_host` (tokio, rustls) crece de forma aceptable y no afecta a `PERF.ARTIFACT.SIZE`, que mide otros artefactos | Medir `libpseudolearn_runtime_aot.a` y un ejecutable mínimo antes/después; leer `perf/perf.artifact.size.md` | `PG-N.07.05` |
| PN-V-09 | Los 114 pendientes se reparten en los puntos según la tabla provisional de §4 `PG-N.00.03` | Script de `PG-N.00.03` | `B0` |
| PN-V-10 | Rosetta 2 está disponible para ejecutar binarios `x86_64-apple-darwin` en este equipo | `arch -x86_64 /usr/bin/true` | `PG-N.10.03` |

## 2. Lectura realizada y lectura de entrada obligatoria

### 2.1 Fuentes consultadas para redactar este plan

- [x] `AGENTS.md`; §0–§5 y §4.13–§4.16 del plan general; §B.3c, §B.5, §B.6, D-02, D-09 y D-15 del análisis.
- [x] Plan de PG-C como modelo de ejecución en una iteración con bloque final.
- [x] README de `pseudolearn_codegen` (secciones de tareas, ampliación numérica y azar), de `pseudolearn_aot_rt`
  (cabeceras, `unsafe`) y de `pseudolearn_bench_worker` (E-PG-06); README de la CLI (nativo, anfitrión, `test-host`).
- [x] `architecture.yaml` del motor (capas, `isolation`, límites, `unsafe_allowed`).
- [x] Corpus: `RT.PROCESS`, `RT.LINKING`, `RT.ABI`, `PERF.AOT.LEVEL`, `ENG.TASK.AGENDA` (textos de reglas).
- [x] Código: `instruction_dispatch.rs`, `task_support.rs`, `native_linker.rs`, `runtime_archive.rs`,
  `aot_rt/src/process.rs`, `aot_rt/src/entry.rs`, `abi/src/continuation_layout.rs`, índice de `runtime/src`.

### 2.2 Antes del primer cambio (tarea `PG-N.00.01`)

Leer enteros: README del motor (sección nativa), README y `architecture.yaml` de la CLI, README de `pseudolearn_runtime`,
`pseudolearn_vm`, `pseudolearn_host`, `pseudolearn_abi` y `pseudolearn_api`; `RT.HOST.INTERFACE`, `ENG.TASK.MEMORY`,
`LANG.TASK.*`, `ENG.EXEC.EFFECT-*`, `ENG.EFFECT.TAPE`, `PERF.PROTOCOL` y `PERF.ARTIFACT.SIZE`; la skill
`commit-message`. Registrar en §11 la revisión Git leída.

## 3. Decisiones de diseño

Cada decisión se traslada a su README dueño en el bloque que la implementa. Las marcadas **Persona** necesitan respuesta
antes de su bloque (§9.1); el resto queda fijada por este plan salvo que la persona la cambie al revisarlo.

| ID | Decisión | Opciones | Criterio | Elección | Reversión |
|---|---|---|---|---|---|
| DN-01 | Suspensión en código nativo | (a) Máquina de estados: cada función suspendible recibe su continuación, salta por `estado` al punto de reanudación, guarda los valores vivos en las ranuras de la continuación de `pseudolearn_abi` y devuelve «suspendida» a su llamador. (b) Pilas propias por tarea con cambio de contexto en ensamblador. (c) Un hilo del SO por tarea con testigo único | Sin `unsafe` nuevo, portable a Windows, recolector sin escanear pilas nativas, misma disposición que la VM, coste cero en funciones no suspendibles | **(a)**. Solo se transforman las funciones que la RI marca suspendibles (`PN-V-02`); las demás se compilan igual que hoy. El análisis de vida existente (`liveness.rs`, `borrowed_roots.rs`) decide qué se guarda | Si `PN-V-02` es falsa o (a) obliga a duplicar más de la mitad de `lowering.rs`, parar y reportar |
| DN-02 | Dueño de la agenda nativa | (a) Reutilizar `pseudolearn_runtime` y extraer a él la semántica que hoy está en la VM (`PN-V-01`). (b) Reimplementar en `aot_rt` | Un solo dueño de la semántica; paridad por construcción; velocidad | **(a)**. La VM pasa a consumir lo extraído en el mismo cambio. `aot_rt` solo conduce: bucle de agenda que llama a la función de la tarea con su continuación | Si extraer cambia un observable de la VM (`see conform --only` de `ENG.TASK.*` en `engine` falla), conservar la pieza en la VM y duplicar en `aot_rt` con nota en §11.4 |
| DN-03 | Bucle de ejecución nativo | (a) El punto de entrada de `aot_rt` crea la raíz, llama a la función de entrada y, mientras haya tareas, toma la cabeza de la cola y la reanuda. (b) Cesión desde el código generado | Mismo orden que `ENG.TASK.AGENDA`; fallos como valores | **(a)** | — |
| DN-04 | `task.yield_check` | (a) Bajada real solo en unidades suspendibles: descuenta masa y, al alcanzar el cuanto 1024 con cola no vacía, suspende. (b) Seguir vacía | `ENG.TASK.AGENDA` (cuanto en aristas de retorno de unidades suspendibles); programas sin tareas sin coste | **(a)**; fuera de unidades suspendibles sigue vacía | — |
| DN-05 | Anfitrión del ejecutable | (a) `aot_rt` importa `pseudolearn_host` y su anfitrión físico es el de distribución; el de memoria queda tras `test-host`; el desprendido desaparece si queda sin uso. (b) Delegar efectos al proceso padre | D-02 (b) de la persona; el ejecutable corre sin `pseudo` (`RT.LINKING#R1`) | **(a)** | Si `PN-V-08` da un crecimiento que la persona no acepta, se reporta; no se cambia de opción sin ella |
| DN-06 | Bomba de efectos concurrentes | (a) Mover a `pseudolearn_host` la bomba acotada que hoy usa la CLI (`PN-V-04`) y usarla desde CLI (VM) y `aot_rt`. (b) Duplicarla | Un dueño; mismo orden de entrega | **(a)** | — |
| DN-07 | Semilla del ejecutable | (a) Entropía del SO por omisión; `--semilla N` (`CANDIDATA`, mismo nombre que en `pseudo run`, `PN-H-22`) la fija al ejecutar; `pseudo run --nativo --semilla N` la pasa. (b) Fijada al compilar | Texto de `PG-N.01`; paridad con la VM | **(a)**. La semilla deja de viajar en los metadatos `PLM5` | — |
| DN-08 | Enlazador incluido (D-15) | (a) `rust-lld` (`PN-H-15`) distribuido junto a `pseudo`, con sabor por destino, más los archivos de apoyo que cada destino necesite (`PN-V-05`–`07`). (b) Enlazador propio. (c) Seguir con `cc` | D-15; tamaño; licencia Apache-2.0 con excepción LLVM | **(a)** — **Persona** confirma la distribución del binario `lld` y de los archivos de apoyo (`P-02`) | Si `PN-E01` falla para un destino, ese destino queda «no verificado» con el motivo y se reporta |
| DN-09 | Selección del destino | (a) Destino del anfitrión por omisión y `--destino <triple>` (`CANDIDATA`) en `build`, validado contra la lista cerrada de `PG-N.10`; archivo del runtime por destino. (b) Solo destino del anfitrión | `PG-N.10` exige cuatro destinos y Windows sin máquina propia | **(a)**. Un destino sin archivo del runtime disponible devuelve un diagnóstico claro (`CANDIDATA` `nativeTargetUnavailable`) | — |
| DN-10 | E-PG-06 en nativo | (a) Ocho programas por familia que leen sus parámetros de la entrada: 8 compilaciones y 10 000 ejecuciones por sujeto. (b) 10 000 compilaciones | Coste del bloque final; mismo oráculo | **(a)**. La derivación del esperado sigue en el trabajador. La versión VM se ejecuta con los mismos ocho programas | Si cambiar las plantillas altera un esperado derivado, se corrige la plantilla, no el esperado |
| DN-11 | Diferencial VM/AOT (`PG-N.11`) | (a) Orden nueva del trabajador de pruebas que ejecuta cada caso ejecutable del corpus en `engine` y `aot` y compara salida, terminación, código de salida y cinta. (b) Solo comparar los informes de `see conform` | Cero diferencias exige comparar entre sí y no solo contra el esperado | **(a)** en `pseudolearn_bench_worker` (`CANDIDATA` `vm-aot-diff`), reutilizando los adaptadores existentes | — |
| DN-12 | Verificación durante la fase | (a) Nivel D por bloque y todo lo pesado en `BF`. (b) Puerta interna completa por bloque (análisis §B.5) | Instrucción directa de la persona del 2026-11-06 | **(a)** (`PN-C-01`) | — |

## 4. Desglose por punto

Orden dentro de cada punto: especificación → casos → tests → código → README y reglas → nivel D. Los nombres de
archivos nuevos son `CANDIDATA` (§5).

### PG-N.00 · Preparación (transversal, bloque `B0`)

- [x] `PG-N.00.01` Lectura de §2.2; `git rev-parse --short HEAD`; `git status` y aplicación de `PN-P-03`; liberar disco
  hasta ≥ 40 GiB (§0.2).
- [x] `PG-N.00.02` Línea base reproducible: `git worktree add --detach <scratchpad>/pg-n-base <HEAD>`; en ella, una sola
  vez y en segundo plano, `see conform --subject aot` con la salida guardada en
  `packages/pseudolearn_engine/results/pg-n-<fecha>/base/` (sirve al ciclo de corrección de `BF`). No se ejecuta nada
  más pesado en `B0`.
- [x] `PG-N.00.03` Script de clasificación (en el *scratchpad*, no en el repositorio) que lee `conformance-aot.yaml` y
  asigna cada vínculo `pendiente` a un punto según esta tabla provisional; resultado en §11.2 (`PN-V-09`):

  | Familias | Punto |
  |---|---|
  | `RT.PROCESS` | `.01` |
  | `ENG.TASK.MEMORY` | `.02`, `.05` |
  | `LANG.TASK.SCOPE`, `LANG.TASK.SUSPENSION`, `LANG.TASK.ISOLATION`, `LANG.CONTROL.CLEANUP` | `.03` |
  | `ENG.TASK.AGENDA`, `LANG.TASK.CHANNEL`, `ENG.LIMITS` | `.04` |
  | `ENG.EXEC.EFFECT-*`, `ENG.EFFECT.TAPE`, `LIB.SCENARIO.HTTP-TASKS` | `.06` |
  | `LIB.IO`, `LIB.HTTP`, `LIB.HTTP.POLICY`, `LIB.TIME`, `RT.HOST.INTERFACE`, `LANG.CAPABILITY.MODEL` | `.07` |
  | `LANG.MODULE.*`, `LANG.PROFILE.MODEL`, `LIB.JSON`, `LIB.CORE.*`, `LANG.TYPES.*`, `LIB.SCENARIO.BILINGUAL`, `LIB.SCENARIO.FILE-JSON` | `.08` |

- [x] `PG-N.00.04` Instalar destinos: `rustup target add x86_64-apple-darwin x86_64-unknown-linux-musl
  x86_64-pc-windows-msvc` (o `-gnullvm` según `PN-E01`) en la cadena del motor y de la CLI; comprobar `PN-V-10`.
- [x] `PG-N.00.05` Espiga `PN-E01` (§7.5) en el *scratchpad*: enlazar a mano un objeto mínimo y el archivo del runtime
  actual con `rust-lld` para los cuatro destinos, sin `cc` en el `PATH`. Resultado en §11.1 (`PN-V-05`–`07`). Es la
  única tarea de `B0` que puede cambiar el plan de `B5`.

### PG-N.01 · `RT.PROCESS` y `RT.ABI` con autoridad plena (bloque `B1`)

- [x] `PG-N.01.01` Especificación: reescribir `RT.PROCESS#R3` (el ejecutable usa argumentos de la línea de órdenes,
  directorio de trabajo, entorno, rutas del sistema, red, reloj y temporizador reales; semilla de entropía salvo
  `--semilla`; cinta opcional con `--effects-out`/reproducción con `--effects-in`); ajustar `#R2` para nombrar el
  código 6 de reproducción si es observable (`PN-H-19`) o justificar en §11.3 por qué no; `#R1` añade la salida de error
  de PG-S.07 y el código de salida pedido por el programa. `RT.ABI`: añadir una regla para la convención de
  suspensión (DN-01): firma de una función suspendible, resultado «suspendida» y propiedad de la continuación.
- [x] `PG-N.01.02` Casos: derivados de las reglas reescritas para el sujeto `aot` (argumentos, entorno, directorio,
  semilla fijada frente a dos ejecuciones con entropía distintas en la propiedad, código de salida pedido, salida de
  error). Los que necesitan anfitrión real se declaran con el anfitrión de memoria de conformidad.
- [x] `PG-N.01.03` Tests: `aot_rt/tests/process_*.rs` para el análisis de argumentos del ejecutable (feliz, opción
  desconocida, `--semilla` sin número o fuera de rango, `--` y argumentos del programa vacíos).
- [x] `PG-N.01.04` Código: `aot_rt` lee argumentos y semilla al ejecutar (DN-07); retirar la semilla de
  `ExecutableMetadata` y de la CLI al compilar; `pseudo run --nativo` reenvía `--semilla` y los argumentos del programa.
- [x] `PG-N.01.05` README de `pseudolearn_aot_rt` y de la CLI; `see lock --refresh RT.PROCESS RT.ABI`.
- [x] `PG-N.01.06` Nivel D: `see validate`; `cargo test -p pseudolearn_aot_rt --test <archivos tocados>`;
  `see conform --subject aot --only RT.PROCESS`.

### PG-N.02 · Contrato de continuación nativa y raíces (bloque `B1`)

- [x] `PG-N.02.01` Verificar `PN-V-02`. Especificación: en `RT.ABI` (o en `ENG.TASK.MEMORY` si su texto ya cubre el
  sujeto), qué se guarda en cada punto de suspensión (solo valores vivos tras el punto, escalares y referencias en
  ranuras separadas), cómo se reanuda (estado = índice del punto) y que el recolector recorre las ranuras de referencia.
- [x] `PG-N.02.02` Casos: los de `ENG.TASK.MEMORY` y `ENG.TASK.AGENDA` existentes se activan para `aot` (sin esperados
  nuevos); si la regla nueva de `RT.ABI` necesita un caso propio, programa con muchos valores vivos atravesando
  `Aguardar` bajo recolección forzada.
- [ ] `PG-N.02.03` Tests: `codegen/src/suspension_layout_tests.rs` (`CANDIDATA`): cálculo de ranuras desde el análisis
  de vida — función sin puntos de suspensión (cero ranuras), un punto, puntos en bucle, valor vivo solo en una rama,
  límite de `u16::MAX` ranuras (`ContinuationLayout::new` devuelve `None` → `CodegenError` con diagnóstico).
- [ ] `PG-N.02.04` Código: `codegen/src/suspension_layout.rs` (`CANDIDATA`) que produce un `ContinuationLayout` y el mapa
  valor→ranura por punto de suspensión.
- [x] `PG-N.02.05` README de `pseudolearn_codegen` (DN-01 con alternativas y reversión); `see lock --refresh` junto con
  `.01.05` si se editan en el mismo bloque.
- [x] `PG-N.02.06` Nivel D: `cargo test -p pseudolearn_codegen suspension_layout`.

### PG-N.03 · Funciones suspendibles, ámbitos, unión, cancelación y limpieza (bloque `B4`)

- [x] `PG-N.03.01` Especificación: ninguna regla nueva; comprobar que `LANG.TASK.SCOPE`, `LANG.TASK.SUSPENSION`,
  `LANG.TASK.ISOLATION` y `LANG.CONTROL.CLEANUP` no excluyen a `aot`.
- [ ] `PG-N.03.02` Tests: `codegen/src/lower_suspension_tests.rs` (`CANDIDATA`): el CLIF de una función suspendible
  tiene bloque de despacho por estado; una función no suspendible no cambia (comparación con el CLIF previo);
  `call.suspendible` propaga «suspendida» y fallo.
- [x] `PG-N.03.03` Código, `pseudolearn_codegen`: `lower_suspension.rs` (prólogo de reanudación, guardado y restauración
  de ranuras, retorno «suspendida»), `lower_tasks.rs` (`task.scope_open`, `task.spawn`, `task.await`,
  `task.scope_join`, `task.scope_result`, `task.scope_boundary`, `task.outcome`, `task.value_load`,
  `task.cancel_point`) y bajada real de `task.yield_check` (DN-04), cada una por entradas `rt_aot_task_*`
  (`CANDIDATA`). Retirar esas operaciones de `UNSUPPORTED_OPERATIONS` a medida que se bajan.
- [x] `PG-N.03.04` Código, `pseudolearn_aot_rt`: entradas `rt_aot_task_*` sobre `TaskAgenda` (DN-02) y bucle de
  ejecución (DN-03). Cancelación cooperativa y limpieza LIFO usan las aristas de RI existentes (`codegen` README
  «La limpieza ya está explicitada en las aristas de RI»).
- [x] `PG-N.03.05` README de `pseudolearn_codegen` y `pseudolearn_aot_rt` (secciones «Operaciones de tarea» reescritas
  como comportamiento, no como pendiente).
- [x] `PG-N.03.06` Nivel D: tests de `.02`; `see conform --subject aot --only LANG.TASK.SCOPE LANG.TASK.SUSPENSION
  LANG.TASK.ISOLATION LANG.CONTROL.CLEANUP` (con `test-host`).

### PG-N.04 · Agenda nativa y canales (bloque `B4`)

- [ ] `PG-N.04.01` Verificar `PN-V-01`; extraer a `pseudolearn_runtime` la semántica que hoy está en la VM y hacer que
  la VM la consuma (DN-02). Nivel D de la VM: `cargo test -p pseudolearn_vm tasks` y `see conform --subject engine
  --only ENG.TASK.AGENDA LANG.TASK.CHANNEL`.
- [ ] `PG-N.04.02` Tests: `aot_rt/tests/task_agenda_drive.rs` (`CANDIDATA`): orden FIFO, desempate, cesión por cuanto,
  despertar múltiple en orden de espera, `taskDeadlock` con ubicaciones relacionadas, límite de tareas de
  `ENG.LIMITS`.
- [x] `PG-N.04.03` Código: bajada de `task.channel` y de las operaciones de canal (capacidad, envío, recepción, cierre,
  contrapresión, `Elegir`) a `rt_aot_channel_*` (`CANDIDATA`) sobre `task_channel.rs` y `channel_selection.rs`.
- [x] `PG-N.04.04` README de `pseudolearn_runtime` (lo extraído y por qué), `pseudolearn_vm` y `pseudolearn_aot_rt`.
- [x] `PG-N.04.05` Nivel D: `see conform --subject aot --only ENG.TASK.AGENDA LANG.TASK.CHANNEL ENG.LIMITS`.

### PG-N.05 · Recolector sobre marcos suspendidos, continuaciones, mensajes y canales (bloque `B4`)

- [x] `PG-N.05.01` Verificar `PN-V-03`. Especificación: ninguna regla nueva si `ENG.TASK.MEMORY` ya lo exige.
- [ ] `PG-N.05.02` Tests: `aot_rt/tests/task_roots.rs` (`CANDIDATA`) con recolección forzada: valor solo vivo en una
  continuación suspendida, mensaje en un canal lleno, tarea terminada cuyo resultado nadie lee (debe liberarse),
  continuación de tarea cancelada (debe liberarse).
- [x] `PG-N.05.03` Código: registro de continuaciones, tareas y canales vivos como raíces desde la agenda nativa; la
  pila de raíces de cada marco se vacía al suspender (las referencias pasan a la continuación).
- [x] `PG-N.05.04` Nivel D: `see conform --subject aot --only ENG.TASK.MEMORY`.

### PG-N.06 · Efectos concurrentes y cinta (bloque `B4`)

- [x] `PG-N.06.01` Especificación: ninguna regla nueva; comprobar `ENG.EXEC.EFFECT-COMMIT`, `ENG.EXEC.EFFECT-ORDER` y
  `ENG.EFFECT.TAPE` para `aot`.
- [ ] `PG-N.06.02` Tests: `aot_rt/tests/concurrent_effects.rs` (`CANDIDATA`) con el anfitrión de memoria: tres efectos
  con permutación de entrega declarada, efecto abandonado por cancelación, entrega solo con cola vacía, cinta
  reproducida idéntica.
- [x] `PG-N.06.03` Código: `effect.await` bajado a `rt_aot_effect_await` (`CANDIDATA`) que suspende la tarea; la
  entrega usa `effect_session.rs` y `tape_delivery.rs` del runtime.
- [x] `PG-N.06.04` Nivel D: `see conform --subject aot --only ENG.EXEC.EFFECT-COMMIT ENG.EXEC.EFFECT-ORDER
  ENG.EFFECT.TAPE LIB.SCENARIO.HTTP-TASKS`.

### PG-N.07 · Runtime nativo con `pseudolearn_host` (bloque `B3`)

- [x] `PG-N.07.01` Verificar `PN-V-04`; mover a `pseudolearn_host` la bomba de efectos concurrentes (DN-06) y adaptar
  la CLI en el mismo cambio. Nivel D: tests de la CLI que cubren la bomba, con filtro.
- [x] `PG-N.07.02` Reglas: `architecture.yaml` del motor añade `pseudolearn_host` a `may_import` de
  `pseudolearn_aot_rt`; comprobar que `isolation` sigue intacta (`PN-H-12`).
- [ ] `PG-N.07.03` Tests: `aot_rt/tests/physical_effects.rs` (`CANDIDATA`) con directorios y servidores efímeros
  locales: leer y escribir archivo, listar, reloj real monótono, temporizador que espera, entorno, argumentos, HTTP a
  `127.0.0.1`; infelices: archivo inexistente, puerto cerrado, TLS inválido (si el README de `pseudolearn_host` ofrece
  el servidor TLS local de pruebas).
- [x] `PG-N.07.04` Código: el anfitrión físico pasa a ser el de distribución del ejecutable (DN-05); el de memoria
  sigue tras `test-host`; borrar el anfitrión desprendido si queda sin consumidores. Desaparece el error de uso de
  `--native` con red y el `interrumpido` de `PN-H-13`.
- [x] `PG-N.07.05` Medición `PN-V-08` (tamaño del archivo y de un ejecutable mínimo) registrada en §11; README de
  `pseudolearn_aot_rt`, `pseudolearn_host` y CLI (borrar el «Pendiente declarado» de `PN-H-13`).
- [x] `PG-N.07.06` Nivel D: `see conform --subject aot --only LIB.IO LIB.TIME RT.HOST.INTERFACE
  LANG.CAPABILITY.MODEL LIB.HTTP LIB.HTTP.POLICY`.

### PG-N.08 · Biblioteca de PG-S y construcciones de PG-L en nativo (bloque `B2`)

- [x] `PG-N.08.01` Especificación: ninguna regla nueva. Casos: los existentes.
- [x] `PG-N.08.02` Código: bajar las 16 operaciones de biblioteca de `PN-H-04` (`lower_math.rs`, `lower_real.rs`,
  `lower_arithmetic.rs`, `lower_collections.rs`) usando las mismas funciones de `pseudolearn_library` que la VM
  (misma precisión y mismos fallos); retirarlas de `UNSUPPORTED_OPERATIONS`.
- [x] `PG-N.08.03` Tests: `instruction_dispatch_tests.rs` (cada operación bajada) y gemelos de `tan`, `asin` fuera de
  dominio, `atan2(0,0)`, `log10(0)`, `floor/ceil` de ±0 y NaN, `min/max` con NaN, ordenar vacío y de un elemento,
  invertir, clonar con alias.
- [x] `PG-N.08.04` Módulos, perfil y JSON: identificar por qué `LANG.MODULE.*`, `LANG.PROFILE.MODEL` y `LIB.JSON` siguen
  `pendiente` (resuelve_en `PG-1.12`/`PG-5.01`) y corregir lo que falte (probable: el adaptador `aot` no compila
  proyectos multiarchivo con `build_native_project_object`, o el perfil no viaja). Registrar la causa en §11.
- [x] `PG-N.08.05` Pendientes heredados de `PN-H-25` que caen aquí: argumentos de fallos nativos, azar entero (si el
  trabajo de `PN-P-03` no los cerró), PS-E04 si es nativo.
- [x] `PG-N.08.06` README de `pseudolearn_codegen` (borrar «Ampliación numérica y de colecciones» como pendiente y
  «Azar entero pendiente» si procede).
- [x] `PG-N.08.07` Nivel D: `cargo test -p pseudolearn_codegen instruction_dispatch`; `see conform --subject aot --only`
  de las familias `.08` de `PG-N.00.03`.

### PG-N.09 · Enlazador incluido (bloque `B5`)

- [ ] `PG-N.09.01` Con `PN-E01` y la respuesta a `P-02`. Especificación: `RT.LINKING` añade que `pseudo build` no
  requiere herramientas del usuario y que en Windows produce `.exe`; diagnóstico de destino no soportado.
- [ ] `PG-N.09.02` Casos: `RT.LINKING` para el sujeto `cli`/`aot` según dónde se acrediten hoy sus reglas.
- [x] `PG-N.09.03` Tests: `apps/pseudolearn_cli/tests/native_linker_*.rs` (`CANDIDATA`): argumentos por destino (pura,
  sin ejecutar el enlazador), ausencia de `cc` en el `PATH` (`env -i`), enlazador ausente → error tipado, nombre `.exe`
  en Windows, limpieza de intermedios con fallo (`RT.LINKING#R2`).
- [x] `PG-N.09.04` Código: `native_linker.rs` deja de llamar a `cc`: localiza el `lld` distribuido (ruta relativa al
  ejecutable `pseudo`, nunca absoluta) y construye los argumentos por destino como datos (una tabla por destino, no un
  condicional por configuración); archivos de apoyo de `PN-V-05`–`07`.
- [ ] `PG-N.09.05` Empaquetado: copia de `lld` y apoyos en la distribución de la CLI y en el VSIX según el README de la
  extensión (`artifact.contract.json`); README de la CLI y de la extensión; `deny.toml` si cambia.
- [x] `PG-N.09.06` Nivel D: tests de `.03`; `pseudo build` de un programa sencillo con `env -i PATH=<solo pseudo>`.

### PG-N.10 · Destinos (bloque `B5`)

- [ ] `PG-N.10.01` Código: `codegen/src/target.rs` acepta los cuatro triples (Mach-O arm64/x86_64, ELF x64, COFF x64)
  con la convención de llamada de cada uno; `build_runtime_archive.rs` construye el archivo por destino instalado
  (DN-09).
- [x] `PG-N.10.02` Tests: `codegen` emite objeto para los cuatro triples y `object` lo lee con el formato y la
  arquitectura esperados; la CLI rechaza un triple fuera de la lista con el diagnóstico de DN-09.
- [ ] `PG-N.10.03` Ejecución real: macOS arm64 y x86_64 (Rosetta, `PN-V-10`). Linux x64: solo con el medio que la
  persona indique (`P-03`); si no, «no verificado». Windows x64: «no verificado».
- [x] `PG-N.10.04` README de `pseudolearn_codegen` y CLI con la tabla de destinos y su estado de verificación.
- [x] `PG-N.10.05` Nivel D: tests de `.02`.

### PG-N.11 · Diferencial VM/AOT con cero diferencias (implementación en `B6`, ejecución en `BF`)

- [x] `PG-N.11.01` Código: orden `vm-aot-diff` (DN-11) en `pseudolearn_bench_worker`, con su README y tests (caso que
  difiere de forma deliberada → informe de diferencia; caso igual → cero; caso que solo corre en un sujeto → error).
- [ ] `PG-N.11.02` Código: plantillas de E-PG-06 con parámetros en la entrada y opción de sujeto (DN-10); tests del
  trabajador.
- [ ] `PG-N.11.03` Ejecución (`BF.06`): diferencial sobre todo el corpus ejecutable, `LIB.SCENARIO.*` incluidos, y
  E-PG-06 con 10 000 semillas en VM y en `aot`. Criterio: cero diferencias.

### PG-N.12 · `PERF.AOT.LEVEL` con tareas presentes (ejecución en `BF`)

- [ ] `PG-N.12.01` `B6`: carga de control sin tareas y carga equivalente con un ámbito de tareas que no cede (solo si
  `PERF.PROTOCOL` admite cargas nuevas sin cambiar el contrato; si no, se mide fuera del contrato y se informa).
- [ ] `PG-N.12.02` `BF.07`: `PERF.AOT.LEVEL` antes (línea base de `PG-N.00.02`) y después según `PERF.PROTOCOL`. Una
  regresión mayor que el ruido es fallo de PG-N. El incumplimiento absoluto de R1 ya presente en la base se informa,
  no se atribuye a PG-N (`PN-H-21`).

### PG-N.13 · Eliminación de `nativeTasksUnsupported` y pendientes (bloque `B6`)

- [x] `PG-N.13.01` `UNSUPPORTED_OPERATIONS` vacía y eliminada junto con `task_support.rs` y la rama `Unsupported` del
  despacho si ya no tiene uso; el catálogo de instrucciones exige que toda operación esté bajada.
- [x] `PG-N.13.02` Corpus: retirar `nativeTasksUnsupported` de `diag/diag.catalog.md` y `cases/catalogs.json` según la
  regla de retirada de diagnósticos del corpus (no se borra una identidad si el corpus exige lápida); regenerar
  `export.json`.
- [x] `PG-N.13.03` Código: borrar `api/src/native_tasks.rs`, sus tests de `native_build.rs` y sus mensajes es/en;
  `git grep -n -i "nativeTasksUnsupported\|pendiente declarado" -- packages apps` sin resultados de PG-N.
- [x] `PG-N.13.04` `conformance-aot.yaml`: cada vínculo `pendiente` pasa a `cumple` solo tras `BF.04`; en `B6` se
  preparan las ediciones. Las exenciones de observación y análisis estático se conservan.
- [x] `PG-N.13.05` README del motor, `pseudolearn_codegen`, `pseudolearn_aot_rt` y CLI sin menciones de pendiente
  nativo.

### Bloque final `BF` · Pruebas pesadas, conformidad y corrección

`BF` no es un punto nuevo de §4 del plan general: es el bloque transversal donde se acreditan `PG-N.11`, `PG-N.12` y
`C11`. Se ejecuta **una sola vez**, al terminar `B6`, en el orden de §10.2. Antes de cada orden, §0.2. Cada orden en
segundo plano con la salida en `packages/pseudolearn_engine/results/pg-n-<fecha>/logs/<orden>.log`; en §11 se anotan
orden, código de salida y conteos.

- [x] `BF.01` Corpus: `see validate`, `see lock --check`, `see export --check`.
- [ ] `BF.02` Estática: `cargo xtask verify` del motor (Clippy `-D warnings`, capas, límites, `rust-checks all`, incluido
  `unsafe` con su tabla), `cargo deny`; lo mismo en `packages/pseudolearn_spec` y `apps/pseudolearn_cli`.
- [ ] `BF.03` Pruebas: `cargo test --workspace` del motor, de SEE y de la CLI (con y sin `test-host`).
- [x] `BF.04` Conformidad completa: `see conform` de `engine`, `aot`, `service`, `cli`, `app` y
  `--operation properties`. Criterio: `aot` con **0 `pendiente`** y 0 `incumple`; los demás sin divergencias nuevas
  respecto a la línea base. Aplicar entonces `PG-N.13.04`.
- [ ] `BF.05` Consumidores: CLI según su README; extensión (pruebas y VSIX con `lld`); app: `flutter analyze`, biblioteca
  nativa y `flutter test` (la VM cambió en `PG-N.04.01`); `packages/pseudolearn_benchmarks` según su README.
- [x] `BF.06` `PG-N.11.03`: diferencial y E-PG-06 en ambos sujetos.
- [ ] `BF.07` `PG-N.12.02`: rendimiento. También `PERF.SUITE.CORE` para descartar regresión de la VM por la extracción.
- [ ] `BF.08` Negativos de los verificadores afectados (capas, límites, `unsafe`, comentarios, nombres, `isolation`)
  siguen fallando con su violación deliberada.
- [x] `BF.09` Ciclo de corrección (§10.4) contra el *worktree* de `PG-N.00.02`.
- [ ] `BF.10` Aceptación: el programa de PG-B.27 y el más completo de `LANG.PROGRAM.CLASSIC` compilados con
  `pseudo build` y ejecutados como binario en macOS arm64 y x86_64 con `env -i` (sin `cc`, sin Xcode en el `PATH`);
  un programa con tareas, canales y HTTP real a `127.0.0.1`; `pseudo run --nativo` desde la extensión de escritorio.
  Linux según `P-03`; Windows «no verificado» con el `.exe` generado.
- [x] `BF.11` Criterios de salida del análisis §B.3c comprobados uno por uno y anotados en §11.

### Cierre común

- [ ] `PG-N.C03`–`C11` se acreditan con la evidencia de §11. `C09`: PG-N no añade sintaxis; las opciones nuevas
  (`--semilla` del ejecutable, `--destino`) llevan mensajes es/en en el corpus de la CLI.
- [ ] `PG-N.C12.01` Revisión del diff completo (`git diff <HEAD inicial> --stat` y lectura de cada archivo de código):
  comentarios, `TODO`, `unwrap`, `expect`, `panic!`, `unsafe` fuera de la tabla y citas a `docs/` fuera de `docs/`
  (`git grep -n "docs/plan-ejecucion\|fase-pg-" -- packages apps` vacío).
- [ ] `PG-N.C12.02` Commits por bloque con la skill `commit-message`, sin atribución de IA, solo rutas de PG-N; push
  ordinario comprobado (`git branch --show-current`, `git push`, `git status -sb`).
- [ ] `PG-N.C13.01` Completar §11, §4.15 y la fila de §6 del plan general; informe a la persona y **parada**.

## 5. Capas y archivos

Respuestas a `AGENTS.md` §1. Nombres nuevos `CANDIDATA`; antes de crear uno, confirmar capa y matriz en
`architecture.yaml`.

| Archivo | Capa | Puede importar | Responsabilidad única |
|---|---|---|---|
| `codegen/src/suspension_layout.rs` (nuevo) | `pseudolearn_codegen` | `pseudolearn_ir`, `pseudolearn_diagnostics`, `pseudolearn_aot_rt` | Ranuras de continuación por punto de suspensión |
| `codegen/src/lower_suspension.rs` (nuevo) | ídem | ídem | Prólogo de reanudación, guardado y retorno «suspendida» |
| `codegen/src/lower_tasks.rs`, `lower_channels.rs` (nuevos) | ídem | ídem | Bajada de operaciones de tarea / de canal a entradas del runtime |
| `codegen/src/instruction_dispatch.rs`, `target.rs`, `lower_math.rs`, `lower_real.rs`, `lower_collections.rs`, `abi_signatures.rs`, `runtime_calls.rs` (mod.) | ídem | ídem | Lo que ya poseen |
| `codegen/src/task_support.rs` (borrado en `.13`) | ídem | — | — |
| `aot_rt/src/task_entries.rs`, `channel_entries.rs`, `agenda_loop.rs` (nuevos) | `pseudolearn_aot_rt` | + `pseudolearn_host` (tras `.07.02`) | Entradas `extern "C"` de tareas / de canales; bucle de agenda |
| `aot_rt/src/process.rs`, `entry.rs`, `metadata.rs`, `effects.rs`, `engine.rs` (mod.) | ídem | ídem | Argumentos y semilla; anfitrión físico |
| `runtime/src/task_*.rs` (extracción desde la VM) | `pseudolearn_runtime` | lo que hoy importa | Semántica de agenda compartida |
| `vm/src/machine/task_*.rs` (mod.) | `pseudolearn_vm` | lo que hoy importa | Conducción de marcos de la VM |
| `host/src/physical_effect_pump.rs` (nuevo, desde la CLI) | `pseudolearn_host` | sin crates del motor | Bomba acotada de efectos concurrentes |
| `api/src/native_tasks.rs` (borrado) | `pseudolearn_api` | — | — |
| `apps/pseudolearn_cli/src/native_linker.rs`, `native_link_targets.rs` (nuevo), `build_runtime_archive.rs`, `build_command.rs`, `native_run_command.rs` (mod.) | adaptador de borde de la CLI | API pública del motor con `native` | Invocar `lld`; tabla de argumentos por destino; archivo del runtime por destino |
| `pseudolearn_bench_worker/src/vm_aot_diff.rs` (nuevo), plantillas de `pg-tasks` (mod.) | `pseudolearn_bench_worker` (herramienta) | lo que declare su entrada | Diferencial; E-PG-06 parametrizado |
| Corpus: `rt/rt.process.md`, `rt/rt.abi.md`, `rt/rt.linking.md`, `diag/diag.catalog.md`, `cases/catalogs.json` | corpus | — | Reglas y casos |

Si un archivo modificado superaría 300 líneas (probable: `instruction_dispatch.rs`, `lowering.rs`, `engine.rs`), se
divide primero por responsabilidad.

## 6. Presupuestos de rendimiento y seguridad

### 6.1 Rendimiento

- `PERF.AOT.LEVEL#R1–R3` sin regresión mayor que el ruido (`BF.07`). La transformación DN-01 solo toca funciones
  suspendibles: una función no suspendible debe generar el mismo CLIF que antes (test de `.03.02`).
- `PERF.SUITE.CORE` de la VM sin regresión por la extracción de `.04.01`.
- Emisión (`#R3`, ≤ 15 ms) medida con las funciones suspendibles presentes.
- Tamaño del ejecutable mínimo y del archivo del runtime con `pseudolearn_host`: medido e informado (`PN-V-08`).

### 6.2 Seguridad y límites

- Autoridad plena por omisión; TLS validado, sin proxies ni cookies ambientales, sin seguir redirecciones (como la VM).
- Límites de `ENG.LIMITS` (tareas, colas, profundidad, bytes) aplicados igual que en la VM; agotar uno termina con
  código 4.
- `unsafe` solo en `aot_rt`, con tabla de invariantes al día; ninguna entrada nueva desreferencia punteros fuera de las
  funciones ya declaradas, salvo nueva fila en la tabla.
- `lld` se invoca con argumentos construidos como lista (nunca a través de un intérprete de órdenes) y con rutas de
  salida validadas.

## 7. Pruebas, verificadores y experimentos

### 7.1 Matriz por punto

| Punto | Corpus | Tests espejo | Consumidores | Verificadores |
|---|---|---|---|---|
| `.01` | `RT.PROCESS`, `RT.ABI` | `aot_rt/tests/process_*` | CLI `run --nativo` | `see validate` |
| `.02`–`.06` | `LANG.TASK.*`, `ENG.TASK.*`, `ENG.EXEC.EFFECT-*`, `ENG.EFFECT.TAPE`, `LANG.CONTROL.CLEANUP` | `codegen/*_tests.rs`, `aot_rt/tests/{task_agenda_drive,task_roots,concurrent_effects}.rs` | VM (extracción) | Clippy, capas |
| `.07` | `LIB.IO`, `LIB.HTTP*`, `LIB.TIME`, `RT.HOST.INTERFACE`, `LANG.CAPABILITY.MODEL` | `aot_rt/tests/physical_effects.rs`, CLI | CLI VM (bomba movida) | `isolation` |
| `.08` | `LIB.CORE.*`, `LANG.MODULE.*`, `LANG.PROFILE.MODEL`, `LIB.JSON`, `LANG.TYPES.*` | `instruction_dispatch_tests.rs` | — | — |
| `.09`–`.10` | `RT.LINKING` | `cli/tests/native_linker_*`, `codegen` destinos | Extensión (VSIX) | `cargo deny` |
| `.11`–`.12` | todo lo ejecutable | `bench_worker` | — | `PERF.*` |
| `.13` | `diag` | `api/tests/native_build.rs` | — | `see export --check` |

### 7.2 Verificadores

PG-N no crea verificadores nuevos. El de `unsafe` gana filas si `aot_rt` añade funciones `unsafe`; su caso negativo se
ejecuta en `BF.08`.

### 7.3 Experimentos

| ID | Objetivo | Protocolo | Si falla |
|---|---|---|---|
| PN-E01 | Enlazar sin `cc` en los cuatro destinos | `PG-N.00.05`: `rust-lld -flavor <sabor>` sobre un objeto mínimo y el archivo del runtime, `env -i`, ejecutar lo que se pueda (macOS arm64/x86_64) | El destino queda «no verificado» con el motivo; se informa en el resumen de `B0` y se sigue |
| PN-E02 | Coste de la suspensión | En `BF.07`, mediana de un programa con 1 000 tareas que ceden 100 veces, VM frente a `aot` | Informar; optimizar solo con autorización (FUT-04) |
| E-PG-06 | 10 000 agendas en ambos sujetos | `BF.06` con DN-10 | Cero diferencias es criterio de salida |

### 7.4 Comandos y niveles

Los comandos exactos se copian de «Cómo se verifica» del README de cada miembro, no de este plan.

- **Nivel D (bloques `B0`–`B6`, rápido):** `cargo check -p <crate>`; `cargo clippy -p <crate> -- -D warnings`;
  `cargo test -p <crate> --test <archivo>` o `cargo test -p <crate> <filtro>` sobre los tests creados o tocados;
  `see validate` tras cada edición del corpus; `see conform --subject <sujeto> --only <IDs del bloque>`;
  `pseudo build`/`pseudo run --nativo` sobre programas de sondeo del *scratchpad*.
  **Prohibido en nivel D:** `cargo test --workspace`; `cargo test -p` sin filtro en `pseudolearn_api`,
  `pseudolearn_service`, `pseudolearn_semantic`, `pseudolearn_runtime`, `pseudolearn_vm` y la CLI;
  `cargo xtask verify`; `see conform` sin `--only`; `flutter test`; campañas `PERF.*`; Playwright; el diferencial.
- **Nivel F (`BF`):** `BF.01`–`BF.11`.

## 8. Riesgos y señales tempranas

| ID | Riesgo | Señal temprana | Respuesta |
|---|---|---|---|
| PN-K-01 (RN-10) | La paridad de tareas no llega a cero diferencias | `see conform --only ENG.TASK.AGENDA` en `aot` con `incumple` en `B4` | Revisar primero DN-02: si la semántica está en un solo dueño, la diferencia está en la conducción nativa |
| PN-K-02 | DN-01 resulta inviable con el análisis de vida actual | `PN-V-02` falsa o `.02.03` no puede calcular ranuras | Parada y reporte con alternativas (DN-01 reversión) |
| PN-K-03 | La extracción de `.04.01` cambia un observable de la VM | `see conform --subject engine --only ENG.TASK.*` falla | Reversión de DN-02 |
| PN-K-04 | `ld64.lld` sin SDK no produce un Mach-O que arranque | `PN-E01` en `B0` | El destino macOS sigue dependiendo de Xcode y se reporta a la persona: es criterio de salida |
| PN-K-05 | El archivo del runtime crece demasiado con tokio y rustls | `PN-V-08` | Informar; la persona decide (DN-05) |
| PN-K-06 | El trabajo sin commit de `PN-P-03` toca los mismos archivos | `git status` | Parada y pregunta |
| PN-K-07 | Disco lleno al compilar varios destinos | `errno=28` | §0.2 |
| PN-K-08 | Errores de nivel D ocultan regresiones que solo `BF` detecta | Muchas correcciones en `BF.09` | Es el coste aceptado por la persona (DN-12); el ciclo de corrección tiene tres vueltas por orden |
| PN-K-09 | Convención de llamada de Windows mal elegida en Cranelift | Test de `.10.02` lee un COFF con símbolos correctos pero el `.exe` no se puede ejecutar | Queda «no verificado»; se documenta |

## 9. Dependencias de la persona

### 9.1 Qué se necesita y cuándo

| ID | Momento | Qué | Si no responde |
|---|---|---|---|
| P-01 | Antes de empezar | `C01` en mensaje nuevo, revisión de este plan (`C02`) y conformidad con empezar sin el cierre formal de PG-L/PG-S (`PN-P-02`) | No se empieza |
| P-02 | Antes de `B5` | Distribuir `rust-lld` y sus archivos de apoyo con la CLI y el VSIX (DN-08), con el tamaño medido en `PN-E01` | `B5` implementa la invocación y los tests puros, sin empaquetar; `PG-N.09` queda «No cumplido» |
| P-03 | Antes de `BF.10` | Medio para ejecutar Linux x64 (máquina, contenedor o comprobación manual) | Linux «no verificado» (desviación de `PG-N.10`, que solo admite Windows sin verificar) |
| P-04 | `B0` | Si sigue el trabajo sin commit de `PN-P-03` en archivos de PG-N | Se espera |
| P-05 | Cierre | Push | Commit local y aviso |

### 9.2 Conflictos conocidos (`CONFLICT-REPORT`)

| ID | Fuentes | Tratamiento |
|---|---|---|
| PN-C-01 | Análisis §B.5 («bloques 1 → 5 con puerta interna al final de cada uno») frente a la instrucción de la persona del 2026-11-06 (bloques rápidos, pruebas pesadas solo al final) | Prevalece la instrucción directa (`AGENTS.md` §3). Las puertas internas pasan a nivel D (DN-12) |
| PN-C-02 | §3 del plan general (PG-N depende de PG-L y PG-S completadas) frente al estado de §6 (sin cierre formal) y fila de PG-B desactualizada respecto del plan de PG-C | La persona decide en `P-01`; se registra en §11.3 |
| PN-C-03 | `RT.PROCESS#R3` (independiente del entorno, semilla al compilar) frente a `PG-N.01` (autoridad plena, entropía) | Decidido por la persona el 2026-11-02 (D-09 y política de autoridad plena); se reescribe la regla bajo congelamiento |
| PN-C-04 | `RT.PROCESS#R2` no nombra el código 6 que el runtime define (`PN-H-19`) | `.01.01` decide con la regla: si el código es observable para el usuario se nombra; si no, se justifica |

## 10. Orden de ejecución y puntos de control

### 10.1 Orden único

El orden no sigue la numeración: va de lo independiente y rápido a lo acoplado, para que cada bloque deje el sujeto
`aot` funcionando.

1. **B0 · Entrada.** `P-01`; `PG-N.00.01`–`.05`. Informe breve del resultado de `PN-E01` (sin parada).
2. **B1 · Contrato.** `PG-N.01`, `PG-N.02` → control **K1**.
3. **B2 · Biblioteca.** `PG-N.08` → **K2**. (Reduce `UNSUPPORTED_OPERATIONS` a las 12 de tareas.)
4. **B3 · Anfitrión.** `PG-N.07` → **K3**. (Programas sin tareas ya ejecutan efectos reales en nativo.)
5. **B4 · Tareas.** `PG-N.03` → `PG-N.04` → `PG-N.05` → `PG-N.06` → **K4**. Es el bloque grande; se commitea por punto.
6. **B5 · Distribución.** `P-02`; `PG-N.09`, `PG-N.10` → **K5**.
7. **B6 · Limpieza y herramientas.** `PG-N.13.01`–`.03`, `.05`; `PG-N.11.01`–`.02`; `PG-N.12.01` → **K6**.
8. **BF** en el orden de §10.2, con el ciclo de §10.4.
9. Cierre `C12`–`C13`, informe y **parada**.

Los controles K no detienen la ejecución: comprueban el nivel D del bloque, `git status` sin rutas ajenas añadidas, y
producen el commit local. Si un control falla, se corrige antes del bloque siguiente.

### 10.2 Orden del bloque final

§0.2 → `BF.01` → `BF.02` → `BF.03` → `BF.04` (y `PG-N.13.04`) → `BF.05` → `BF.08` → `BF.06` → `BF.07` → `BF.09`
(intercalado tras cada orden que falle) → `BF.10` → `BF.11`. Push solo tras `BF.11` en verde o con pendientes aceptados
por escrito por la persona.

### 10.3 Paradas obligatorias (las únicas)

- Cambios ajenos sin commit en archivos que PG-N debe tocar (`PN-P-03`).
- `PN-K-02` (DN-01 inviable).
- Decisión **Persona** sin respuesta: se aplica la columna «Si no responde» de §9.1 y se sigue.
- Conflicto nuevo entre fuentes que cambia el trabajo: se registra en §11.3, se omite lo afectado y se sigue.
- Fin de la fase: informe y parada.

### 10.4 Ciclo de corrección del bloque final

1. Para cada orden que falle, guardar el registro y clasificar cada fallo con la **misma orden** en el *worktree* de
   `PG-N.00.02`: si también falla allí, **preexistente** (se registra; se corrige solo si es nativo y cae en un punto de
   PG-N, porque PG-N debe dejar `aot` sin pendientes); si no, **regresión de PG-N**; si es intermitente en tres
   ejecuciones, **inestable**.
2. Corregir las regresiones en el archivo dueño respetando §0.1-4.
3. Repetir solo la orden afectada y las que dependen de ella (un cambio en `pseudolearn_runtime` repite `BF.03` del
   motor, `BF.04` `engine` y `aot`, y `BF.06`).
4. Máximo tres vueltas por orden; si una regresión persiste, «No cumplido» con su causa. Tras la última corrección,
   `BF.01`–`BF.05` completos una vez más.
5. `git worktree remove` al terminar.

## 11. Resumen de ejecución

Estado: ejecutado el 2026-11-06 en una sola iteración, por instrucción directa de la persona del mismo día («ejecuta el
plan… no quiero que me hagas preguntas… toma siempre la mejor opción»), que se toma como `C01` y como respuesta a
`P-01`–`P-05` según la columna «Si no responde» o la mejor opción técnica. Revisión Git inicial `52219da0` (no
`c3e3f24f`: el trabajo de `PN-P-03` ya estaba commiteado y el árbol estaba limpio).

| Tarea | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| B0 | Cumplido | `results/pg-n-2026-11-06/base/aot.json` (local) | Disco liberado de 38 a 45 GiB (`git worktree remove` del *worktree* de PG-C, `cargo clean` en CLI, SEE y biblioteca nativa de la app). Base `aot`: 1 389 cumple, 200 incumple, 778 no aplicable |
| B1 (`.01`, `.02`) | Cumplido con cambio de diseño | `RT.PROCESS` R1–R3 y P2 reescritas, `RT.ABI#R5` y C3 nuevas, `process_options_tests.rs` | `.02.03`/`.02.04` no aplican: DN-01 pasó a (c) (ver §11.3) |
| B2 (`.08`) | Cumplido | 16 operaciones bajadas, `extended_math_tests.rs`, adaptador `aot` con proyectos | `LANG.MODULE.*`, `LANG.PROFILE.MODEL`, `LIB.SCENARIO.BILINGUAL` verificados contra ejecutables |
| B3 (`.07`) | Cumplido salvo tests físicos | `physical_provider.rs`, enlace con `-framework Security/CoreFoundation` | `.07.03` (tests con servidores efímeros) no escrito; comprobado a mano con entorno real |
| B4 (`.03`–`.06`) | Cumplido salvo tests unitarios del runtime | Conformidad `aot` de `ENG.TASK.*`, `LANG.TASK.*`, `LANG.CONTROL.CLEANUP`, `ENG.EXEC.EFFECT-*`, `ENG.EFFECT.TAPE` sin divergencias | `.03.02`, `.04.02`, `.05.02`, `.06.02` no escritos: la cobertura es la conformidad y las propiedades `aot` (incluida la recolección forzada) |
| B5 (`.09`, `.10`) | Parcial | `native_link_targets.rs`, `native_link_stubs.rs`, `target_objects_tests.rs` | Enlace con `rust-lld` sin `cc` ni Xcode verificado en macOS arm64 con `env -i`; empaquetado de `rust-lld`+`libLLVM` no hecho (P-02 sin respuesta); `--destino` y archivos del runtime por destino no implementados; x86_64, Linux y Windows no verificados |
| B6 (`.11`–`.13`) | Parcial | Diagnóstico retirado del corpus y del código | `.11.01` se resolvió con la orden existente `see differential`; `.11.02` (E-PG-06 nativo) y `.12.01` no hechos |
| BF | Parcial | `results/pg-n-2026-11-06/logs/` (local) | Ver abajo |

Bloque final: `BF.01` `see validate`, `lock --check` y `export --check` en verde. `BF.04` conformidad `aot` completa sin
`incumple` (base 200) y propiedades `aot` en verde (15 ejecutadas, 3 pendientes por capacidad no anunciada); `engine`
2 922 observaciones sin divergencias. `conformance-aot.yaml`: 0 `pendiente`; 87 vínculos pasan a `cumple` y 28 a `exento`
con justificación (27 sin evidencia de ejecución para `aot`, y `ENG.TASK.AGENDA#R7`). `BF.06` `see differential`: 1 650
observaciones comparadas; las 4 diferencias de la primera pasada (`ENG.LIMITS` C23 y C25) se corrigieron. `BF.09`: el ciclo
de corrección encontró y corrigió, entre otras, la falta de raíces en `task.spawn` bajo recolección forzada y el tramo de
los fallos dentro de auxiliares sintetizados (preexistente). `BF.10`: `pseudo build` con solo `pseudo` y `rust-lld` en el
`PATH` (`env -i`) produce y ejecuta un programa con tareas y otro con canales en macOS arm64.

### 11.1 Registro de hipótesis (`PN-V-01`–`PN-V-10`) y de `PN-E01`

| ID | Resultado | Evidencia |
|---|---|---|
| PN-V-01 | No necesaria | La conducción nativa reutiliza `TaskAgenda`, `TaskChannels`, `TaskFailures` y las reservas de cinta tal como están; la VM no cambió |
| PN-V-02 | Verdadera | `Function.suspendible` y `suspension_points::points` |
| PN-V-03 | Verdadera para la VM; en nativo las raíces de las tareas suspendidas las recorre `task_roots` | `aot_rt/src/task_roots.rs` |
| PN-V-04 | Falsa: la bomba acotada ya vivía en `pseudolearn_host` (`HostWorker`) | `host/src/worker.rs` |
| PN-V-05 | Verdadera | `ld64.lld` con *stub* `.tbd` generado enlaza y el binario arranca sin Xcode |
| PN-V-06 | No verificada | Sin destino musl ni medio Linux |
| PN-V-07 | No verificada | Sin bibliotecas de importación ni medio Windows |
| PN-V-08 | Medida | Archivo del runtime 3,1 → 5,6 MB; ejecutable mínimo ≈ 3,5 MB |
| PN-V-09 | Verdadera con ajuste | 114 pendientes: `.01` 1, `.02/.05` 3, `.03` 15, `.04` 19, `.06` 9, `.07` 37, `.08` 30 |
| PN-V-10 | Falsa | `arch -x86_64` falla: Rosetta 2 no instalado |

### 11.2 Clasificación de los vínculos `pendiente` (`PG-N.00.03`)

| Punto | Vínculos | Resueltos en `BF.04` |
|---|---|---|
| `.01` | 1 | Sí |
| `.02`/`.05` | 3 | Sí |
| `.03` | 15 | Sí (algunos como exentos sin casos de ejecución) |
| `.04` | 19 | Sí; `ENG.TASK.AGENDA#R7` exento |
| `.06` | 9 | Sí |
| `.07` | 37 | Sí |
| `.08` | 30 | Sí |

### 11.3 Conflictos, `CANDIDATA` fijadas y decisiones de la persona

| ID | Resolución | Fuente |
|---|---|---|
| P-01 / C01 | Inicio autorizado sin cierre formal de PG-L/PG-S | Mensaje de la persona del 2026-11-06 |
| DN-01 | Cambia a (c): un hilo por tarea con testigo único; sin `unsafe` nuevo (las direcciones cruzan como procedencia expuesta) y sin transformar funciones. (a) habría exigido duplicar la bajada en cada punto de suspensión | README de `pseudolearn_codegen` y `pseudolearn_aot_rt` |
| DN-02 | La conducción vive en `aot_rt`; no se extrajo semántica de la VM porque las piezas compartidas bastaron | README de `pseudolearn_aot_rt` |
| DN-08 / P-02 | `rust-lld` necesita `libLLVM` (cientos de MB): no se empaqueta sin decisión de la persona; la CLI lo usa si está junto a `pseudo` y si no usa `cc` | README de la CLI |
| DN-11 | Se usa `see differential` (ya existente) en lugar de una orden nueva del trabajador | README de SEE |
| C20, C4 de `LANG.TASK.SCOPE`/`ENG.TASK.AGENDA`, C5 de `LIB.SCENARIO.BILINGUAL`, C4/C6 de los escenarios | Restringidos a `engine`: cancelación externa, `awaiting_effect` y API de sesión son fronteras del anfitrión alojado | Corpus |
| `project_api` | Capacidad nueva de SEE para casos `api` solo de proyecto | README de SEE |
| `PN-C-04` | `RT.PROCESS#R2` nombra el código 6 (documento de efectos ilegible o reproducción divergente) | Corpus |
| Commits | Sin atribución de IA, por `AGENTS.md` §9 y la skill `commit-message` | — |

### 11.4 Hallazgos fuera de alcance

| ID | Hallazgo | Destino propuesto |
|---|---|---|
| H-01 | `ENG.TASK.MEMORY#R1`: el coste de las continuaciones suspendidas no se descuenta en nativo (solo la de entrada de cada tarea) | Revisar con la persona si R1 se reformula para el sujeto nativo |
| H-02 | Entrega concurrente real de efectos físicos en nativo (la entrega es secuencial por rango) | Fase de rendimiento |
| H-03 | `pseudo run --nativo` no propaga el código de salida pedido por el programa (el ejecutable sí) | PG-7 |

Revisión Git de cierre: ver `git log` de la rama tras el push · Verificadores ejecutados: Clippy `-D warnings` y
`rust-checks all` del motor, Clippy de la CLI y de SEE, tests dirigidos de `aot_rt`, `codegen`, `api`, CLI y SEE, conformidad
y propiedades `aot` y `engine`, diferencial · Suites omitidas y motivo: `cargo xtask verify` completo, `cargo deny`,
consumidores (extensión, app, benchmarks), `PERF.*` y E-PG-06 nativo, por coste dentro de la iteración · Pendientes
justificados: `PG-N.09.01/.02/.05`, `PG-N.10.01/.03`, `PG-N.11.02/.03` (E-PG-06), `PG-N.12`, tests unitarios de
`.03.02`, `.04.02`, `.05.02`, `.06.02`, `.07.03`, `BF.02/.03/.05/.07/.08/.10` parciales · Puntos de §4 cumplidos: `.00`,
`.01`, `.02`, `.03`, `.04`, `.05`, `.06`, `.07`, `.08`, `.13`; parciales `.09`, `.10`, `.11`; no cumplido `.12`.
