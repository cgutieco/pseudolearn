# Fase PG-4 · Tareas aisladas — plan de ejecución

## 0. Metadatos

- Fase: `PG-4` · Tareas aisladas. Requisitos `R-06`, `R-10` y `R-12`, con impacto en `R-13` (límites de tareas y
  colas) y `R-19` (la app visualiza la sintaxis entregada). Capacidad principal `C-09`; impacto en `C-05` (capturas
  entre tareas), `C-06` (limpieza ante cancelación), `C-15` y `C-16` (ayuda y proyección de la sintaxis nueva).
- Decisión rectora: `ADR-03` (async explícito con tareas estructuradas aisladas y canales acotados). Decisiones
  vinculadas: `ADR-02` (cinta), `ADR-06` (presupuestos por característica), `ADR-07` (errores como valores),
  `ADR-12` (app de archivo único) y `ADR-13` (catálogo de ayuda).
- Riesgos: `K-05` (alias o captura rompe aislamiento o GC) y `K-08` (hambre, bloqueo o fuga de tareas).
  Experimento: `E-PG-06`.
- Fecha de preparación: `2026-10-27`, zona `America/Lima`.
- Revisión Git inicial: `276a156fe600a6bde98ca45f5018f70920de7319`; árbol limpio al comenzar.
- Rama única: `feature/agregar-ruta-de-especificacion` (`GIT-SINGLE-BRANCH`).
- Encargo documental de la persona (2026-10-27): «Crea el plan de ejecución para `4.6 PG-4 · Tareas aisladas` […]
  acotado a la evolución de mi lenguaje y no simple reutilización de paradigmas aplicados en otros lenguajes, debe
  ser algo personalizado, a no ser que los paradigmas de otros lenguajes funcionen, el plan de ejecución debe ser lo
  más detallado posible para que ninguna IA por más tonta que parezca tenga chance de error. Para agilizar el
  desarrollo en la última fase recién se ejecutarán los test pesados […]. Deja claro que si hace falta espacio en la
  maquina debe eliminarse cosas del almacenamiento sin usar, no sé, como caché, logs, cualquier cosa que no sea
  critica para liberar espacio».
- Estado: plan detallado creado; **pendiente de revisión de la persona** (`PG-4.C02`). Crear este plan no inicia la
  fase ni autoriza ninguna iteración de §10 (`PHASE-STOP`). `PG-4.C01` sigue pendiente.
- Dependencias: `PG-2` cerrada el 2026-10-26; `PG-3` con todos sus puntos y casillas de cierre marcados (commit
  `4bdbd52`, documentado en `276a156`). El cierre común de `PG-1` sigue abierto en el plan general; no bloquea
  técnicamente `PG-4`, pero se registra en §11.

### 0.1 Cuatro constancias que rigen todo el plan

**1. Diseño a medida.** Ninguna pieza de `PG-4` incorpora un *runtime* asíncrono externo (`tokio`, `async-std`),
corrutinas de pila nativa, hilos del sistema operativo, `async`/`await` de Rust en el motor, actores públicos ni un
sistema de préstamos o capacidades de referencia al estilo Pony. Todo se construye sobre lo que PseudoLearn ya tiene:
la separación `Funcion` pura / `SubProceso` con efecto y su análisis transitivo (`effect_check`), la RI SSA verificada
con masa de sentencia, los bancos bicamerales (`u64` escalar / `u32` referencia), los mapas de raíces estáticos, la
compilación de mundo cerrado, la cinta `pseudolearn.tape/v1` con `task_id` ya reservado, `Resultado<T, E>` con
obligaciones de uso, `Segun` exhaustivo, `Diferir` y la paridad VM/AOT por disposiciones únicas en `pseudolearn_abi`.
Un paradigma ajeno solo se toma cuando encaja sin fricción; §3.1 registra qué se toma y qué se rechaza, y la misma
tabla pasa al README dueño (`AGENTS.md` §3).

**2. Velocidad: pruebas pesadas solo en la última iteración.** Por decisión de la persona del 2026-10-27, las
iteraciones 1 a 4 de §10 ejecutan **solo verificaciones ligeras** (§7.1: integridad del corpus, compilación,
verificadores estáticos y tests unitarios de los módulos creados o modificados). **Todas** las pruebas pesadas
(conformidad `see conform`, contraste diferencial, ejecución AOT, `gc_stress`, campaña `E-PG-06` de 10 000 agendas,
regresión de rendimiento, `flutter test` y pruebas del puente) se ejecutan **únicamente en la iteración 5**, que es
la que da conformidad a lo implementado y generado. Esto no relaja `PHASE-GREEN`: la fase no se cierra sin la
iteración 5 en verde. Tampoco se ejecutan nunca las suites completas del monorepo (`cargo xtask verify`,
`cargo test --workspace`, `see conform` sin `--only`, `flutter test` sobre toda la carpeta), salvo los disparadores
cerrados de §7.1.4.

**3. Espacio en disco.** El 2026-10-27 el volumen de trabajo tenía **2,3 GiB libres de 228 GiB**; solo
`packages/pseudolearn_engine/target` ocupa 19 GiB. Antes de cada iteración y antes de cualquier compilación
`release` o campaña, la IA **debe** aplicar el protocolo de §13: medir, y si falta espacio, eliminar cachés,
registros y artefactos de compilación regenerables que no sean críticos, sin tocar nada versionado, ninguna
evidencia ignorada de campañas ni datos personales. Quedarse sin disco a mitad de una compilación o de una campaña
no es aceptable como causa de un fallo.

**4. Evolución sincronizada de `apps/pseudolearn_app`.** Toda identidad sintáctica, tipo incorporado, evento y
estado nuevo de `PG-4` llega a la app en la misma fase: fichas bilingües en `TOOL.SERVICE.CATALOG`, proyección en
`API.PROGRAM.VIEW`, modelos de cable de los eventos de tarea, varios efectos pendientes en el anfitrión simulado y
nodos explícitos (nunca un nodo desconocido que cae en «proceso») en ordinograma y estructograma. Las tres
proyecciones de concurrencia de `ADR-12` (flujo por tarea, estructura de creación/unión y ventana de eventos), la
pila de foco por tarea y el paso por tarea son de `PG-B` y quedan fuera de esta fase.

### 0.2 Sintaxis candidata

Toda forma sintáctica de este plan (§3.3) es **candidata**. La persona la confirma o la cambia en el punto de
control `P1` (§10) antes de anclar el corpus; la forma final la fija el corpus, no este documento (plan general §5.5).
Si la persona cambia un lexema, la IA sustituye ese lexema en todo lo que redacte después y no reabre el resto.

Documento transitorio de `docs/`. Desarrolla el [plan general](plan-ejecucion-proposito-general.md) y la
[hoja de ruta](../hoja-de-ruta-proposito-general.md). Ningún archivo fuera de `docs/` lo cita
(`DOC-NO-TRANSIENT-REFS`). Las decisiones aceptadas se trasladan a los `README.md` dueños y el comportamiento
observable al corpus, sin depender de este texto.

---

## 1. Punto de partida

Estado verificado en la revisión `276a156`.

### 1.1 Lo que ya existe y `PG-4` reutiliza

| Pieza | Dónde | Qué aporta a `PG-4` |
|---|---|---|
| Máquina única con un cursor, una pila de marcos y dos bancos | `pseudolearn_vm/src/machine/mod.rs` (`Machine`, `frames: Vec<ControlFrame>`, `scalars`, `references`, `cursor`) | Una sola tarea ejecuta a la vez; el cambio de tarea vacía y vuelve a llenar esta pila desde continuaciones en el montón |
| Raíces precisas de marcos activos y suspendidos | `pseudolearn_vm/src/machine/roots.rs` (`memory_roots`, `frame_roots`, `suspended_roots`) | Mismo mecanismo de mapas estáticos para los marcos de la tarea actual; se añaden las raíces de la agenda |
| Suspensión reanudable por efecto | `RunExit::AwaitingEffect(PendingEffectRequest)` en `pseudolearn_vm/src/model.rs`; `effect_seq`, `effect_result: Option<HostReply>` en `Machine` | Se amplía a una **lista** de efectos pendientes cuando varias tareas esperan efectos |
| Cinta con `task_id` reservado | `ENG.EFFECT.TAPE#R3` (`task_id` siempre `0`); `pseudolearn_runtime/src/effect_tape.rs`, `tape_codec.rs`, `tape_replay.rs` | `task_id` pasa a ser real; se añade `delivery_seq` y el desenlace `abandoned` sin cambiar el esquema `v1` (D-PG4-14) |
| Pureza transitiva | `LANG.CAPABILITY.PURITY#R1`–`#R5`; `pseudolearn_semantic/src/effect_check.rs` | Una `Funcion` no puede suspenderse ni operar tareas o canales; se reutiliza el mismo punto fijo |
| Clausuras con entorno inmutable | `LANG.TYPES.FUNCTION#R1`; `capture_analysis.rs`, `capture_environment.rs` | La captura copia vínculos inmutables, **pero un objeto capturado conserva su identidad mutable**: no es aislamiento transitivo; `PG-4.06` lo resuelve en la frontera de tarea |
| Colecciones compartidas | `LANG.TYPES.VECTOR#R1`, `LANG.TYPES.DICTIONARY#R1` (referencias compartidas mutables); `LANG.TYPES.RECORD#R3` (registros por valor, campos de clase compartidos); `LANG.CLASS.COPY#R1` (`Copiar` superficial); `LANG.SUBPROGRAM.BY-REFERENCE#R1` (alias permitido) | Definen exactamente qué tipos **no** pueden cruzar una frontera de tarea |
| Limpieza léxica | `LANG.CONTROL.CLEANUP`; `pseudolearn_lowering/src/cleanup_edges.rs` | `LANG.CONTROL.CLEANUP#R2` vigente ordena cancelar y unir a las hijas antes de ejecutar las limpiezas cooperativas; las trampas y la cancelación del anfitrión no ejecutan limpiezas |
| Masa de sentencia | `IR.OBSERVATION-POINTS#R2`; combustible por bloque en la VM | Base de los puntos de cesión lógicos (`PG-4.07`), sin reloj físico |
| Límites deterministas | `ENG.LIMITS#R1`–`#R9` | Se añaden límites de tareas y de capacidad de canal con la misma clasificación que las celdas |
| Disposiciones únicas VM/AOT | `pseudolearn_abi/src/` (`frame.rs`, `closure_layout.rs`, `record_layout.rs`, `vector_layout.rs`…) | Se añaden `continuation_layout.rs`, `task_layout.rs`, `channel_layout.rs` |
| Runtime compartido por VM y AOT | `pseudolearn_runtime` es importado por `pseudolearn_vm` y por `pseudolearn_aot_rt` | La agenda vive aquí como estructura de datos pura: **una sola implementación** para ambos motores (D-PG4-11) |
| Pila de raíces en AOT | `pseudolearn_codegen/src/shadow_stack.rs`, `lexical_roots.rs` | Se amplía con el volcado de valores vivos en las continuaciones |
| Campañas `pg_*` | `pseudolearn_bench_worker/src/pg_campaign.rs`, `pg_tape_*.rs`, `pg_workloads.rs` | Modelo para la campaña `pg_tasks` de `E-PG-06` |
| Anfitrión falso declarativo | `pseudolearn_api/src/fake_host.rs`; clave `anfitrion` de los casos `see/1` | Se amplía con orden de entrega de efectos concurrentes |
| App | `apps/pseudolearn_app/lib/engine/rust/` (`rust_wire_models.dart`, `rust_execution_api.dart`, `rust_program_execution.dart`, `rust_simulated_host.dart`, `rust_effect_gate.dart`, `rust_construct_projection.dart`, `rust_program_view_builder.dart`, `rust_flowchart_block_builder.dart`, `rust_structogram_cell_builder.dart`, `rust_focus_tracker.dart`) | Destino de la evolución sincronizada (§0.1, constancia 4) |

### 1.2 Hechos que condicionan nombres y decisiones

1. **Colisión de `Esperar`.** `LIB.TIME` ya usa `Temporizador.Esperar(ms)` / `Timer` como operación de efecto. La
   palabra de espera explícita no puede ser `Esperar`; se propone `Aguardar` / `await` (D-PG4-02).
2. **Colisión de nombres internos.** `pseudolearn_timeline/src/scheduler.rs` ya define `CostScheduler` (programa
   puntos de control). La agenda de tareas **no** se llama `scheduler` en ningún crate: se llama `task_agenda`.
   `pseudolearn_aot_rt/src/effect_channel.rs` ya existe como transporte de efectos; el canal del lenguaje se llama
   `task_channel` en todos los crates.
3. **`Cerrar` ya existe** como método de `ArchivoCap`/`DirectorioCap`; como es un método por tipo, `Canal.Cerrar()`
   no colisiona.
4. **Límites reales de tamaño.** `architecture.yaml` del motor, de `pseudolearn_spec` y de la CLI fijan
   `file_lines: 300`, `function_lines: 40`, `positional_parameters: 4`, `nesting_depth: 3`,
   `public_methods_per_class: 7`, `unsafe_function_lines: 10`, nombres de al menos tres caracteres con la lista de
   componentes prohibidos (`ctx`, `env`, `buf`, `tmp`, `idx`, `len`, `val`, `err`…) y archivos prohibidos `utils`,
   `helpers`, `common`, `misc`. La app fija `file_lines: 250`, `function_lines: 40`, `build_method_lines: 30`,
   `positional_parameters: 3`, `nesting_depth: 3`, `public_methods_per_class: 5`. El plan de `PG-3` §5 citaba
   600 líneas; **el archivo de reglas manda** y este plan usa 300 (motor) y 250 (app).
5. **Disco.** 2,3 GiB libres; artefactos regenerables medidos: `packages/pseudolearn_engine/target` 19 GiB,
   `apps/pseudolearn_cli/target` 4,9 GiB, `apps/pseudolearn_app/native/target` 4,3 GiB,
   `apps/pseudolearn_app/build` 3,0 GiB, `packages/pseudolearn_spec/target` 2,8 GiB; cachés de usuario:
   `~/Library/Developer/CoreSimulator` 11 GiB, `~/Library/Caches` 4,8 GiB, `~/Library/pnpm` 2,5 GiB, `~/.cache`
   1,8 GiB. Ver §13.

### 1.3 Lo que falta para cumplir `PG-4`

- Unidades suspendibles y espera explícita bilingües (`PG-4.01`).
- Ámbitos de tareas obligatorios con unión, sin hijos abandonados, cancelación cooperativa con limpieza
  (`PG-4.02`) y política de fallos con error primero y asociados (`PG-4.03`).
- Canales acotados con cierre y contrapresión, y elección simultánea determinista (`PG-4.04`).
- Diagnóstico de bloqueo distinto de `awaiting_effect` (`PG-4.05`).
- Aislamiento transitivo estático e instantánea inmutable explícita con coste declarado (`PG-4.06`).
- Agenda lógica compartida por VM y AOT con identidades monotónicas, desempate y cesión por masa (`PG-4.07`).
- Continuaciones con disposición y raíces comunes, recorridas por el GC (`PG-4.08`).
- Límites de tareas y colas como terminaciones definidas (`PG-4.09`).
- Reproducción de 10 000 agendas sembradas sin diferencias (`PG-4.10`).
- Eventos de tarea observables para la app (`PG-4.11`).
- `E-PG-06` y métrica candidata de tareas; async nativo en AOT solo si pasa (`PG-4.12`).

---

## 2. Lectura realizada

Revisión `276a156`.

- [x] `AGENTS.md` y `README.md` de la raíz.
- [x] `docs/hoja-de-ruta-proposito-general.md`: §1, §4.1 (`R-06`, `R-10`, `R-12`, `R-13`, `R-19`), §5 (`C-09`,
  `C-15`), §6.2 (fila de `PG-4`), §6.3 (`E-PG-06`, `E-PG-12`), `ADR-03`, `ADR-12` (asincronía y concurrencia),
  §9 (`K-05`, `K-08`, STRIDE), §10 y §11.
- [x] `plan-ejecucion-proposito-general.md` (§2–§6) y `fase-pg-3-plan-ejecucion.md` como modelo.
- [x] `README.md` y `architecture.yaml` de `packages/pseudolearn_engine`; límites de `packages/pseudolearn_spec`,
  `apps/pseudolearn_cli` y `apps/pseudolearn_app`.
- [x] Especificaciones: `LANG.PROFILE.VOCABULARY`, `LANG.TYPES.FUNCTION`, `LANG.TYPES.VECTOR`,
  `LANG.TYPES.DICTIONARY`, `LANG.TYPES.RECORD`, `LANG.TYPES.TEXT`, `LANG.TYPES.INTERFACE`, `LANG.TYPES.GENERIC`,
  `LANG.CLASS.COPY`, `LANG.SUBPROGRAM.BY-REFERENCE`, `LANG.CAPABILITY.MODEL`, `LANG.CAPABILITY.PURITY`,
  `LANG.CONTROL.CLEANUP`, `LANG.CONTROL.SWITCH`, `LIB.TIME`, `LIB.IO`, `ENG.LIMITS`, `ENG.TRACE.EVENTS`,
  `ENG.EXEC.MODEL`, `ENG.EXEC.EFFECT-ORDER`, `ENG.EFFECT.TAPE`, `API.EXECUTE`, `IR.OBSERVATION-POINTS`,
  `IR.INSTRUCTIONS` (`O1`–`O93`).
- [x] Código: `pseudolearn_vm/src/machine/` (`mod.rs`, `roots.rs`, `control_state.rs`), `pseudolearn_vm/src/model.rs`,
  `pseudolearn_abi/src/frame.rs`, listados de `pseudolearn_runtime`, `pseudolearn_timeline`, `pseudolearn_ir`,
  `pseudolearn_lowering`, `pseudolearn_semantic`, `pseudolearn_codegen`, `pseudolearn_aot_rt`, `pseudolearn_api`,
  `pseudolearn_bench_worker` y `apps/pseudolearn_app/lib/engine/rust/`.
- [ ] Pendiente para la iteración 1 (lectura obligatoria antes de redactar cada especificación): `LANG.SYNTAX.GRAMMAR`,
  `LANG.LEXICAL.KEYWORD`, `API.STATE.QUERY`, `API.PROGRAM.VIEW`, `TOOL.SERVICE.CATALOG`, `DIAG.CATALOG`,
  `DIAG.MESSAGES`, `IR.WELL-FORMEDNESS`, `RT.ABI`, `RT.HOST.INTERFACE`, el README de `packages/pseudolearn_spec`
  y los esquemas de caso `see/1` (clave `anfitrion`). La IA marca esta casilla cuando los haya leído completos.

---

## 3. Decisiones de diseño

### 3.1 Qué se toma y qué se rechaza de otros lenguajes (`AGENTS.md` §3)

| Referencia | Qué se toma (encaja con PseudoLearn) | Qué se rechaza y qué se construye a medida |
|---|---|---|
| Kotlin `coroutineScope`, Trio *nurseries* (concurrencia estructurada) | Ámbito obligatorio que une a sus hijas al salir; un fallo cancela a las hermanas | Se rechazan los receptores implícitos, `GlobalScope`, `launch` desprendido y `Job` como valor almacenable. A medida: bloque léxico `Tareas … FinTareas`, `Lanzar` solo dentro de su cuerpo léxico y `Tarea<T>` como asa local no escapable |
| Rust `async fn` (máquinas de estado sin pila) | Bajar cada unidad suspendible a una función reanudable con número de estado y valores vivos volcados en un registro del montón | Se rechazan `Future`/`poll` públicos, `Pin`, *wakers* y ejecutores intercambiables. A medida: el registro de continuación tiene disposición única en `pseudolearn_abi` y su mapa de raíces sale de la RI verificada, igual para VM y AOT |
| Go canales y `select` | Canal con capacidad, cierre y recepción que distingue «cerrado y vacío» | Se rechazan el `select` aleatorio, el pánico al enviar a un canal cerrado, la capacidad cero y `select` con envío. A medida: `Aguardar c.Enviar(v)` devuelve `Logico`; `Aguardar c.Recibir()` devuelve `Opcional<T>`; `Elegir` solo con ramas de recepción y gana la primera rama lista en orden textual |
| Swift `Sendable` y aislamiento | Comprobar en compilación qué datos pueden cruzar una frontera de tarea | Se rechazan actores, reentrancia y `@unchecked`. A medida: predicado estructural `transferible` sobre los tipos de PseudoLearn, más la regla de «movimiento del resultado» de una tarea terminada |
| Pony, capacidades de referencia | La idea de que el aislamiento debe ser verificable y transitivo | Se rechazan `iso`/`val`/`ref`/`tag` y la lógica de préstamos (coste de enseñanza demostrado en `ADR-03`). A medida: un único tipo `Inmutable<T>` producido por `Instantanea(x)` |
| JavaScript bucle de eventos y promesas | Un solo hilo lógico de ejecución | Se rechazan promesas sin dueño, `then` encadenado y errores no observados. A medida: no existe valor «futuro»; llamar a una unidad suspendible sin `Aguardar` es error de compilación |
| Erlang/BEAM | Fallos de tareas reportados al dueño | Se rechazan buzones, `link`/`monitor`, reinicio y promesa de rendimiento BEAM |
| Pruebas de simulación determinista (sembrado de agendas) | Generar miles de ejecuciones desde una semilla y comparar | Se rechaza un planificador aleatorio. A medida: la agenda **no tiene semilla**; la semilla solo genera programas, argumentos y el orden de entrega de efectos del anfitrión falso |
| Hilos, `mutex`, memoria compartida | Nada | Se rechazan en el lenguaje (`ADR-03`); los adaptadores nativos pueden coordinar sus hilos internos fuera del lenguaje |

### 3.2 Decisiones técnicas

| Decisión | Opciones | Criterio | Elección | Reversión |
|---|---|---|---|---|
| `D-PG4-01` Marca de unidad suspendible | (A) Toda unidad puede suspender; (B) modificador explícito en `SubProceso` | `ADR-03` exige espera explícita y coste visible; `Funcion` es pura | **B**: `SubProceso Suspendible` / `subroutine suspendable`, palabra contextual tras `SubProceso`. `Proceso`/`Algoritmo` es la tarea raíz y es implícitamente suspendible. `Funcion`, métodos, constructores y literales de función no pueden ser suspendibles | Permitir métodos suspendibles si `PG-5` lo exige, con ADR propio |
| `D-PG4-02` Palabra de espera | `Esperar` (colisiona con `Temporizador.Esperar`); `Aguardar`; símbolo | Sin colisión, bilingüe, legible | **`Aguardar` / `await`**, operador prefijo reservado | Persona en `P1` |
| `D-PG4-03` Unidad suspendible como valor | (A) Tipo función suspendible; (B) no es valor | `SCOPE-YAGNI`; el aislamiento de clausuras se simplifica | **B**: nombrarla sin llamarla es `suspendibleAsValue` | Abrir tipos función suspendibles en una fase posterior si un caso de ENT-1 lo pide |
| `D-PG4-04` Forma del ámbito | (A) Asa de grupo con nombre (`grupo.Lanzar`); (B) bloque léxico | Impide por construcción que el ámbito escape | **B**: `Tareas [vínculo] … FinTareas`; `Lanzar U(args)` solo en el cuerpo léxico directo del bloque (incluidos `Si`, bucles y `Segun` dentro de él; no dentro de clausuras, `Diferir` ni de otra unidad) | Ninguna sin ADR |
| `D-PG4-05` Asa de tarea | (A) `Tarea<T>` como valor libre; (B) asa local | Sin tareas desprendidas ni asas que sobrevivan al ámbito | **B**: `Tarea<T>` solo como vínculo inmutable `Definir t Como Tarea<T> <- Lanzar …;` dentro del bloque, usable solo en `Aguardar t`; cualquier otro uso es `taskHandleEscape` | Ninguna |
| `D-PG4-06` Qué es un fallo de tarea | (A) Trampa recuperable en la frontera de tarea; (B) `Error(e)` de `Resultado<T, E>` | `ADR-07`: fallos esperables como valores; trampas son defectos del programa | **B**: una tarea falla si su unidad retorna `Error(e)`. Una trampa en cualquier tarea termina **toda** la ejecución con `failed`, igual que hoy, sin ejecutar limpiezas pendientes (`LANG.CONTROL.CLEANUP` vigente) | Reabrir si `E-PG-12` muestra que las trampas por tarea son imprescindibles |
| `D-PG4-07` Entrega del fallo al padre | (A) `Propagar` implícito al salir; (B) vínculo tipado obligatorio | Explícito, tipado y con obligación de uso ya existente | **B**: `Tareas fallo … FinTareas` declara tras el bloque `fallo : Opcional<FalloTareas<E>>`; `Nada` si todo terminó bien. Obligatorio si alguna tarea lanzada es falible; prohibido si ninguna lo es. Se consume con `Segun` o `Descartar` como cualquier valor con obligación | Ninguna |
| `D-PG4-08` Cancelación | (A) Asíncrona en cualquier punto; (B) cooperativa | Determinismo y limpieza predecible | **B**: solo se cancela una tarea que **no** está ejecutando; la cancelación surte efecto al reanudarse, antes de ejecutar ninguna sentencia más fuera de `Diferir`. Primero cancela y une a sus propias hijas; después ejecuta sus `Diferir` pendientes en orden inverso. No existe `Cancelar` explícito en el lenguaje (`SCOPE-YAGNI`) | Añadir `Cancelar t` si un caso de `PG-5` lo exige |
| `D-PG4-09` Canales | Rendezvous, capacidad libre, capacidad explícita ≥ 1 | Contrapresión enseñable y memoria acotada | **Capacidad explícita ≥ 1**: `Canal(n)` con contexto de tipo. `Enviar` → `Logico` (`Falso` si cerrado, sin trampa), `Recibir` → `Opcional<T>` (`Nada` si cerrado y vacío), `Cerrar` síncrono e idempotente | Ninguna |
| `D-PG4-10` Elección simultánea | Aleatoria, por llegada, por orden textual | Reproducible y explicable en una frase | **Orden textual**: `Elegir … FinElegir` solo con ramas `Recibir x Desde c:`; al entrar gana la primera rama lista en orden textual; si ninguna lo está, se suspende y gana la rama cuyo canal reciba el primer envío o cierre en orden de agenda | Añadir ramas de envío si `PG-5` lo exige |
| `D-PG4-11` Dónde vive la agenda | (A) Una por motor; (B) una sola en `pseudolearn_runtime` | `pseudolearn_runtime` ya lo importan VM y `pseudolearn_aot_rt`; paridad por construcción | **B**: `TaskAgenda`, colas de espera y canales son estructuras de datos puras del runtime, sin E/S ni reloj | Ninguna |
| `D-PG4-12` Representación de una tarea suspendida | (A) Pila propia por tarea solo en VM; (B) continuaciones en el montón compartidas | Principio 5 del README del motor: VM y AOT comparten disposición y raíces; el conteo de celdas es observable | **B**: cada marco de unidad suspendible se vuelca, en su primera suspensión, a un registro de continuación del montón con disposición única y solo los valores vivos del punto. Reanudación «en trampolín»: la agenda reanuda el marco más interno; al retornar entrega su resultado al registro padre y encola al padre. Nunca se usa la pila nativa como única fuente de vida | Pilas separadas por tarea en VM solo con ADR y medición que demuestre igualdad observable |
| `D-PG4-13` Puntos de cesión | Por tiempo físico; en todo bucle; en bucles de unidades suspendibles | `ADR-03` exige cesión reproducible; coste cero para código no suspendible | **Instrucción de cesión en cada arista de retorno de bucle de una unidad suspendible**. Cada tarea acumula la masa de sentencia ejecutada desde su última reanudación (en cualquier marco). En un punto de cesión, si la masa ≥ cuanto `Q = 1 024` y la cola de listas no está vacía, la tarea pasa al final de la cola; en ambos casos el contador vuelve a cero. Las unidades no suspendibles nunca ceden: se ejecutan completas (las acota el presupuesto de sentencias) | Ajustar `Q` en `P1` o tras `E-PG-06`; cambiarlo cambia observables y exige reanclar casos |
| `D-PG4-14` Efectos concurrentes y cinta | Esquema `v2`; `v1` con campos aditivos | Sin migradores (`PG-2.15` retirado) y sin reescribir casos de `PG-3` | **`v1` con edición oficial aditiva**: `task_id` real; `delivery_seq` **omitido cuando coincide** con el orden de petición (siempre en programas sin `Aguardar` sobre efectos), y desenlace `abandoned`. `Aguardar cap.Op(…)` dentro de una unidad suspendible emite una petición concurrente y suspende solo a su tarea. Las llamadas de efecto sin `Aguardar` y `Leer` conservan la semántica de `PG-3`: suspenden **toda** la ejecución | `v2` si la persona lo pide en `P1` |
| `D-PG4-15` Cuándo se entregan resultados de efectos | En cualquier momento; solo con la agenda ociosa | Determinismo sin depender del tiempo físico | **Solo cuando la agenda está ociosa**: cola de listas vacía y al menos un efecto pendiente no abandonado ⇒ `awaiting_effect` con la lista completa en orden de `effect_seq`; `effect_result` nombra el `effect_seq` | Ninguna; la concurrencia no garantiza plazos reales (`ADR-03`) |
| `D-PG4-16` Bloqueo | Esperar indefinidamente; nueva terminación; fallo con diagnóstico | Distinto de `awaiting_effect` y sin ampliar el conjunto cerrado de terminaciones | **`failed` con `taskDeadlock`**: cola vacía, sin efectos pendientes no abandonados y la raíz sin terminar. Sitio: la operación de la tarea que acaba de suspenderse; ubicaciones relacionadas: cada tarea suspendida con su causa, en orden de identidad | Ninguna |
| `D-PG4-17` Aislamiento | Comprobación dinámica de pertenencia; predicado estático | Verificar una vez, no comprobar nunca (principio 3 del motor) | **Predicado estático `transferible`** (§3.4.4) en argumentos de `Lanzar`, tipo de elemento de `Canal<T>` y tipo de error de `FalloTareas<E>`. El **resultado** de una tarea terminada se **mueve** al padre sin exigir transferibilidad: la tarea ya no existe y solo recibió datos transferibles | Ninguna sin ADR |
| `D-PG4-18` Instantánea | Copia profunda implícita; tipo de solo lectura explícito | Coste declarado y visible | **`Instantanea(x)` / `snapshot(x)`** devuelve `Inmutable<S>`: copia profunda que conserva alias internos y ciclos, cuenta sus celdas como creación y solo admite lecturas. Rechaza objetos de clase y funciones (`snapshotNotSupported`); comparte, sin copiar, canales y capacidades | Admitir objetos sin métodos mutadores con ADR propio |
| `D-PG4-19` Límites | `limit_reached` o `failed` | `ENG.LIMITS#R4` clasifica las celdas como fallo del programa | **`failed`**: `taskLimitExceeded` al superar el máximo de tareas vivas (omisión `4 096`; app `256`); `channelCapacityInvalid` si la capacidad es `< 1`; `channelCapacityExceeded` si supera el máximo (omisión `65 536`). Tareas, continuaciones y búferes de canal cuentan celdas | Ninguna |
| `D-PG4-20` Eventos de tarea | Añadir `task` a todo evento; eventos de cambio | No cambiar el esquema de los eventos existentes ni el PLEV de `PG-3` | **Clases nuevas** (§3.4.6). La tarea dueña de cualquier otro evento es la última que recibió `task_resumed` (la raíz al inicio). Solo se emiten observando (gemelo sondeado) | Ninguna |
| `D-PG4-21` Evolución de la app | Esperar a `PG-B`; sincronizar datos ahora | Constancia 4 | **Sincronizar datos**: catálogo, vista pública, cable de eventos, varios efectos pendientes y nodos explícitos con marca de suspensión; las vistas multicarril quedan en `PG-B` | Ninguna |

### 3.3 Sintaxis candidata (se confirma en `P1`)

| Identidad (vocabulario) | `es` | `en` | Clase léxica |
|---|---|---|---|
| `suspendibleModifier` | `Suspendible` | `suspendable` | Contextual: solo inmediatamente después de `SubProceso`/`subroutine` |
| `awaitKeyword` | `Aguardar` | `await` | Reservada |
| `tasksKeyword` / `endTasks` | `Tareas` / `FinTareas` | `tasks` / `endTasks` | Reservadas |
| `spawnKeyword` | `Lanzar` | `spawn` | Reservada |
| `taskType` | `Tarea` | `task` | Nombre de tipo incorporado (como `Vector`) |
| `taskFailureType` y campos | `FalloTareas` con `Primero`, `Asociados`, `Canceladas` | `taskFailure` con `first`, `associated`, `cancelled` | Tipo incorporado |
| `channelType` | `Canal` | `channel` | Nombre de tipo incorporado y constructor con contexto |
| `channelSend` / `channelReceive` / `channelClose` | `Enviar` / `Recibir` / `Cerrar` | `send` / `receive` / `close` | Métodos de `Canal<T>`; `Recibir` también encabeza rama de `Elegir` |
| `selectKeyword` / `endSelect` | `Elegir` / `FinElegir` | `select` / `endSelect` | Reservadas |
| `receiveSource` | `Desde` | `from` | Contextual: solo en rama de `Elegir` |
| `immutableType` | `Inmutable` | `immutable` | Nombre de tipo incorporado |
| `snapshotBuiltin` | `Instantanea` | `snapshot` | Función incorporada |

Ejemplo candidato (perfil `es`; no normativo, sirve para que la IA entienda la intención):

```text
SubProceso Suspendible Medir(espera Como Entero) Como Resultado<Entero, ErrorES>
Definir timer Como Temporizador <- Propagar SolicitarTemporizador();
Definir medido Como Entero <- Propagar Aguardar timer.Esperar(espera);
Retornar Exito(medido);
FinSubProceso
Algoritmo Main
Tareas fallo
Definir a Como Tarea<Entero> <- Lanzar Medir(10);
Definir b Como Tarea<Entero> <- Lanzar Medir(20);
Escribir (Aguardar a) + (Aguardar b);
FinTareas
Segun fallo Hacer
Nada: Escribir "listo";
Algo(problema): Escribir problema.Primero.Codigo;
FinSegun
FinAlgoritmo
```

### 3.4 Modelo semántico que el corpus debe expresar

Cada enunciado tiene un ID de trabajo (`U`, `S`, `F`, `C`, `I`, `A`, `M`, `E`) que la iteración 1 convierte en reglas
`R<n>` de la especificación indicada. La IA no inventa semántica fuera de esta lista; si algo falta, se detiene y lo
reporta (`CONFLICT-REPORT`).

#### 3.4.1 Unidades suspendibles y `Aguardar` → `LANG.TASK.SUSPENSION`

- `U1` `SubProceso Suspendible` declara una unidad suspendible. La tarea raíz (`Proceso`/`Algoritmo`) es suspendible.
  Declararla no crea ninguna tarea.
- `U2` Una unidad suspendible no es un valor (`suspendibleAsValue`). `Funcion`, métodos, constructores y literales de
  función no admiten `Suspendible` (`suspendibleModifierNotAllowed`).
- `U3` `Aguardar` solo se escribe en una unidad suspendible o en la raíz (`awaitOutsideSuspendible`); nunca dentro de
  `Diferir` (`awaitInsideDefer`).
- `U4` `Aguardar` se aplica exactamente a: llamada a unidad suspendible, vínculo `Tarea<T>`, `c.Enviar(v)`,
  `c.Recibir()` y operación de capacidad de `LIB.IO`/`LIB.TIME`. Cualquier otro operando es `awaitOperandInvalid`.
- `U5` Llamar a una unidad suspendible sin `Aguardar` es `suspendibleCallWithoutAwait`. `Aguardar U(args)` ejecuta `U`
  **en la misma tarea**; no crea tareas.
- `U6` `Aguardar` puede aparecer en cualquier posición de expresión; el orden de evaluación sigue siendo de izquierda a
  derecha y los valores intermedios se conservan a través de la suspensión.
- `U7` La profundidad de marcos de `ENG.LIMITS` se cuenta por tarea.
- `U8` `Aguardar` sobre algo ya disponible (tarea terminada, canal con dato) no suspende y no produce
  `task_suspended`.

#### 3.4.2 Ámbitos, unión y cancelación → `LANG.TASK.SCOPE`

- `S1` `Tareas [vínculo] … FinTareas` abre un ámbito. `Lanzar` solo aparece en su cuerpo léxico directo; fuera es
  `spawnOutsideTaskScope`. `Tareas` y `Lanzar` dentro de `Diferir` son `taskScopeInsideDefer`. Un ámbito sin ningún
  `Lanzar` es válido.
- `S2` `Lanzar U(args)` exige que `U` sea una unidad suspendible nombrada. Los argumentos se evalúan en el padre, de
  izquierda a derecha, y deben ser transferibles (`taskArgumentNotTransferable`); un parámetro por referencia es
  `taskByReferenceArgument`. Crea una tarea con identidad nueva, padre = tarea actual y ámbito = el bloque. Lanzar
  **no cede**: el padre sigue ejecutando.
- `S3` Si `U` retorna `Resultado<T, E>`, la tarea es **falible** con error `E` y el asa es `Tarea<T>`. Si `U` retorna
  `T` no resultado, es infalible y el asa es `Tarea<T>`. Si `U` no retorna valor, `Lanzar` solo es sentencia.
- `S4` `Lanzar` como sentencia descarta el valor de éxito; los errores nunca se descartan (los recoge el ámbito).
- `S5` `Definir t Como Tarea<T> <- Lanzar …;` solo dentro del bloque; `t` es inmutable y su único uso es
  `Aguardar t`, que devuelve `T` (el valor de `Exito` si es falible). Asignar, pasar, retornar, capturar, almacenar,
  comparar o escribir `t` es `taskHandleEscape`. `Aguardar t` repetido devuelve el mismo valor sin suspender.
- `S6` `FinTareas` une: la tarea dueña espera a que terminen todas las hijas del ámbito (causa `join`). Si ya
  terminaron, no suspende. Ninguna tarea sobrevive a su ámbito.
- `S7` Cancelación cooperativa: solo se cancela una tarea que no está ejecutando; surte efecto cuando la agenda la
  reanuda, antes de ejecutar ninguna sentencia más fuera de `Diferir`. Al surtir efecto: (1) solicita cancelar a sus
  hijas vivas, en orden de identidad, y las une; (2) ejecuta sus `Diferir` pendientes en orden inverso; (3) termina
  con desenlace `cancelled`.
- `S8` Dentro de una limpieza por cancelación se permiten efectos sin `Aguardar`; `Aguardar`, `Lanzar` y `Tareas`
  están prohibidos estáticamente (`U3`, `S1`).
- `S9` Una tarea cancelada mientras espera un efecto concurrente no espera al anfitrión: termina y el efecto queda
  **abandonado**. Si llega su resultado, se graba con su `delivery_seq` y se descarta; si la ejecución termina antes,
  la entrada se sella `abandoned`; si la operación escribía, la cinta se marca `UncertainExternalState` (`CF-07`).
- `S10` La cancelación por el anfitrión (`ENG.EXEC.MODEL#R4`) no cambia: detiene todo de inmediato, sin limpiezas.

#### 3.4.3 Política de fallos → `LANG.TASK.SCOPE`

- `F1` Una tarea falible falla cuando su unidad retorna `Error(e)`.
- `F2` El **primer fallo** de un ámbito es el de la primera tarea del ámbito que termina con `Error` en orden de
  agenda (orden total de sucesos, no reloj). Ese suceso: marca el ámbito como fallido con `Primero = e`; solicita
  cancelar a todas las demás hijas vivas del ámbito, en orden de identidad; y solicita cancelar el **cuerpo** del
  ámbito en la tarea dueña, que salta a `FinTareas` (a la unión) ejecutando los `Diferir` abiertos dentro del bloque.
- `F3` Toda hija que termine con `Error(e')` después del primer fallo y antes de que su cancelación surta efecto se
  conserva en `Asociados`, en orden de terminación. Los éxitos posteriores al primer fallo se descartan.
  `Canceladas` cuenta las hijas que terminaron con `cancelled`.
- `F4` Todas las tareas falibles de un ámbito comparten el mismo `E` exacto (`taskScopeErrorTypeMismatch`), y `E` es
  transferible (`taskErrorNotTransferable`).
- `F5` Tras la unión, el vínculo del ámbito vale `Nada` si no hubo fallo y `Algo(FalloTareas)` si lo hubo. Falta de
  vínculo con tareas falibles: `taskScopeFailureUnbound`; vínculo sin tareas falibles: `taskScopeFailureUnused`.
- `F6` Una trampa en cualquier tarea termina toda la ejecución con `failed` (`D-PG4-06`).

#### 3.4.4 Aislamiento e instantánea → `LANG.TASK.ISOLATION`

- `I1` Son **transferibles**: `Entero`, `Real`, `Logico`, `Caracter`, `Cadena`, enumerados, registros cuyos campos son
  todos transferibles, `Opcional<T>` y `Resultado<T, E>` con componentes transferibles, `Inmutable<T>`, `Canal<T>`,
  `FalloTareas<E>` con `E` transferible y las capacidades de `LANG.CAPABILITY.MODEL`. `Bytes` solo si `LIB.IO` no
  declara ninguna operación que lo mute (la IA lo comprueba en la iteración 1 y, si es mutable, lo excluye y lo
  registra).
- `I2` **No** son transferibles: `Vector`, `Diccionario`, arreglos, objetos de clase, tipos función (incluidas las
  clausuras, aunque su entorno sea inmutable, porque `LANG.TYPES.FUNCTION#R1` conserva la identidad de los objetos
  capturados), `Tarea<T>` y cualquier compuesto que contenga uno de ellos. Un registro con un campo de clase no es
  transferible aunque el registro se copie por valor.
- `I3` En un cuerpo genérico, un argumento de `Lanzar` de tipo parámetro opaco no es transferible (coherente con
  `LANG.TYPES.GENERIC#R1`: el cuerpo se comprueba una vez).
- `I4` El diagnóstico de no transferibilidad nombra el tipo y la **ruta** hasta el componente culpable (por ejemplo
  `Pedido.cliente: Cliente (clase)`), recorriendo registros y variantes; un ciclo de tipos se recorre una vez.
- `I5` `Instantanea(x)` acepta escalares, `Cadena`, enumerados, registros, `Opcional`, `Resultado`, `Vector`,
  `Diccionario`, arreglos e `Inmutable`; devuelve `Inmutable<S>`. Copia en profundidad conservando alias internos y
  ciclos; los canales y capacidades se comparten sin copiar. Objetos de clase o funciones en el grafo:
  `snapshotNotSupported` con la ruta. Coste: las celdas del grafo copiado se cuentan como creación (`ENG.LIMITS#R2`)
  y pueden producir `cellLimitExceeded`.
- `I6` `Inmutable<S>` admite solo lecturas (índice, `Longitud`, `Buscar`, lectura de clave o campo, `Para Cada`,
  `Escribir` si `S` es imprimible, comparación si `S` la admite). Una lectura cuyo resultado es una referencia no
  transferible devuelve `Inmutable<…>` de ese elemento. Toda escritura o método mutador es `immutableValueWrite`.
  No hay conversión implícita entre `Inmutable<S>` y `S`.
- `I7` `Copiar` sigue siendo superficial y no cambia (`ADR-03`).

#### 3.4.5 Canales y elección → `LANG.TASK.CHANNEL`

- `C1` `Canal<T>` exige `T` transferible (`channelElementNotTransferable`); no admite igualdad, orden ni `Escribir`.
- `C2` `Canal(n)` con contexto de tipo crea un canal abierto de capacidad `n`. `n < 1` ⇒ `failed` con
  `channelCapacityInvalid` (estático si `n` es constante); `n` mayor que el límite ⇒ `failed` con
  `channelCapacityExceeded`. Celdas: `1 + n × max(1, ancho(T))`. Identidad de canal monotónica desde 1, solo visible
  en eventos.
- `C3` `Aguardar c.Enviar(v)` → `Logico`: cerrado ⇒ `Falso` sin suspender; hay receptor esperando ⇒ entrega directa al
  primero en espera, lo despierta, `Verdadero`; hay hueco ⇒ encola, `Verdadero`; lleno ⇒ suspende en la cola de
  emisores (FIFO por orden de espera). Al liberarse un hueco, el primer emisor en espera encola su valor y despierta
  con `Verdadero`. Si el canal se cierra mientras espera, despierta con `Falso` y su valor se descarta.
- `C4` `Aguardar c.Recibir()` → `Opcional<T>`: con datos ⇒ `Algo(cabeza)` y, si hay emisores esperando, el primero
  encola su valor y despierta; vacío y cerrado ⇒ `Nada`; vacío y abierto ⇒ suspende en la cola de receptores (FIFO).
- `C5` `c.Cerrar()` no requiere `Aguardar`, no suspende y es idempotente: despierta a todos los receptores en espera con
  `Nada` y a todos los emisores con `Falso`, en orden de espera. Los datos ya encolados siguen recibiéndose.
- `C6` `Enviar` y `Recibir` sin `Aguardar` son `channelOperationWithoutAwait`. Una `Funcion` no puede `Cerrar`,
  `Enviar` ni `Recibir` (`pureFunctionTaskOperation`); sí puede crear un canal.
- `C7` `Elegir` exige al menos dos ramas `Recibir x Desde c:` (`selectNeedsTwoBranches`); `x` es un vínculo nuevo e
  inmutable de tipo `Opcional<T>` limitado a su rama. Al entrar se evalúan las expresiones de canal en orden textual,
  una vez. Gana la primera rama lista en orden textual (lista = datos, emisor esperando o cerrado). Si ninguna está
  lista, la tarea se registra en las colas de receptores de todos los canales y se suspende (causa `select`); el
  primer envío o cierre en orden de agenda sobre cualquiera de ellos completa la elección con esa rama y retira el
  registro de los demás canales en el mismo suceso. Un mismo canal en dos ramas: decide el orden textual.
- `C8` `Elegir` es sentencia compuesta: `statement_entered`, una `decision` con rama `caso` e índice de la rama ganadora
  (como `Segun`, `ENG.TRACE.EVENTS#R4`) y `statement_exited`.

#### 3.4.6 Agenda, efectos, bloqueo, memoria y eventos → `ENG.TASK.AGENDA` y `ENG.TASK.MEMORY`

- `A1` La raíz tiene identidad `0`. Las demás reciben `1, 2, 3…` al ejecutarse `Lanzar`; nunca se reutilizan.
- `A2` En cada instante lógico ejecuta exactamente una tarea; las demás están listas, suspendidas (con causa:
  `task`, `channel_send`, `channel_receive`, `select`, `effect`, `join`, `yield`) o terminadas (`success`, `error`,
  `cancelled`).
- `A3` Cola de listas FIFO. Entran: la tarea recién lanzada; la despertada (en el suceso que la despierta); la que
  cede por cuanto. Si un suceso despierta varias, entran en orden de espera.
- `A4` Cuando la tarea actual se suspende o termina, ejecuta la primera de la cola.
- `A5` Cesión por cuanto según `D-PG4-13` con `Q = 1 024`.
- `A6` Efectos concurrentes y entrega según `D-PG4-14` y `D-PG4-15`. `delivery_seq` empieza en `1` y crece en cada
  entrega. En reproducción, la entrega sigue el orden de la cinta; un orden distinto es `replay_divergence`.
- `A7` Bloqueo según `D-PG4-16`.
- `A8` La raíz que termina con hijas vivas es imposible por `S6`; si ocurriera, es `DIAG.ENGINE.INTERNAL-FAULT`.
- `M1` Disposición única del registro de continuación (`RT.ABI`): cabecera, índice de función, estado de reanudación,
  enlace al registro padre, ranura de resultado y dos segmentos (escalar y referencia) con tamaño **máximo de valores
  vivos** sobre los puntos de suspensión de esa función, calculado en la RI. Se aloja en la primera suspensión del
  marco y cuesta `1 + ranuras` celdas.
- `M2` Raíces: los marcos activos de la tarea actual (mecanismo vigente) más, en orden de identidad de tarea, los
  registros de continuación, los resultados no entregados y los valores de emisores en espera que mantiene la agenda.
  Los búferes de canal son objetos del montón y se recorren por alcanzabilidad ordinaria.
- `M3` Con `gc_stress`, recolectar en cada asignación no cambia ningún observable con tareas suspendidas, canales con
  datos e instantáneas cíclicas.
- `E1` Clases nuevas de `ENG.TRACE.EVENTS`: `task_spawned {task, parent, scope}`, `task_suspended {task, cause,
  target}`, `task_ready {task, cause}`, `task_resumed {task}`, `task_completed {task, outcome}`,
  `task_cancel_requested {task, reason, origin}` (`reason`: `sibling_failure` | `parent_cancelled`),
  `scope_joined {task, outcome}`, `channel_created {channel, capacity}`, `channel_sent {channel}`,
  `channel_received {channel, present}`, `channel_closed {channel}`, `effect_delivered {effect_seq, delivery_seq,
  task}`. Cada uno lleva `source` como el resto (`ENG.TRACE.EVENTS#R2`).
- `E2` La tarea dueña de un evento ordinario es la última con `task_resumed`; la raíz al inicio.

### 3.5 Conflictos que se reportan (`CONFLICT-REPORT`)

| ID | Fuentes en choque | Propuesta | Estado |
|---|---|---|---|
| `CF-PG4-01` | Afirmación histórica de este plan frente a la regla vigente | `LANG.CONTROL.CLEANUP#R2` ya contiene la distinción propuesta: la cancelación cooperativa de tarea ejecuta `Diferir`; la cancelación del anfitrión y las trampas no | **Obsoleto en el estado actual del corpus**; no requiere editar `LANG.CONTROL.CLEANUP` en esta iteración |
| `CF-PG4-02` | `README.md` del motor: «Fuera de alcance de producto: … concurrencia» y «una ejecución y su línea temporal se procesan secuencialmente» frente a `ADR-03` aprobado | Actualizar el README en el mismo cambio (`DOC-README-TRUTH`): concurrencia cooperativa de una sola tarea ejecutando a la vez; paralelismo fuera de alcance | Se aplica en la iteración 3; se informa, no bloquea |
| `CF-PG4-03` | Plan de `PG-3` §5 cita 600 líneas por archivo frente a `architecture.yaml` (300) | Manda el archivo de reglas | Informativo |
| `CF-PG4-04` | `ENG.EXEC.MODEL#R5` y `API.EXECUTE#R6` describen **un** efecto pendiente | Edición oficial: lista de pendientes en orden de `effect_seq`; con un solo pendiente la forma de `PG-3` no cambia | Se aplica en la iteración 1 |

---

## 4. Desglose por punto

Convención de cada tarea: `.01` especificación, `.02` casos, `.03` tests, `.04` código, `.05` README y reglas,
`.06` verificación ligera (iteraciones 1–4), `.07` verificación pesada (**solo** iteración 5). Ninguna tarea se
marca `[x]` sin evidencia en §11.

### PG-4.01 · Funciones suspendibles y espera explícita, con identidad sintáctica bilingüe

- [x] `PG-4.01.01` Crear `LANG.TASK.SUSPENSION` (estable `1.0.0`, sujetos `engine` y `aot`, sin `cambio`) con
  `U1`–`U8`. Editar como texto oficial `LANG.PROFILE.VOCABULARY` (identidades de §3.3 que use esta regla),
  `LANG.SYNTAX.GRAMMAR` (producciones del modificador y del prefijo `Aguardar`), `LANG.CAPABILITY.PURITY` (regla
  nueva: una `Funcion` no es suspendible ni contiene `Aguardar`), `DIAG.CATALOG` y `DIAG.MESSAGES` (códigos
  `suspendibleModifierNotAllowed`, `suspendibleAsValue`, `awaitOutsideSuspendible`, `awaitInsideDefer`,
  `awaitOperandInvalid`, `suspendibleCallWithoutAwait`, con plantillas `es`/`en`).
- [x] `PG-4.01.02` Casos derivados de la regla (nunca capturados del motor): feliz (`Aguardar` de unidad suspendible
  en la raíz, cadena de tres unidades suspendibles, `Aguardar` dentro de una expresión aritmética y dentro de un
  argumento); infeliz (uno por código de diagnóstico); límite (unidad suspendible sin ningún punto de suspensión,
  recursión suspendible de profundidad 3, identificador de un carácter, `Suspendible` como identificador fuera de la
  cabecera y programa con `Aguardar` de un efecto ya resuelto que no suspende). Cada caso en `es` y `en`.
- [x] `PG-4.01.03` Tests espejo: `pseudolearn_syntax` (árbol sin pérdida con el modificador contextual: `Suspendible`
  sigue siendo identificador fuera de esa posición), `pseudolearn_semantic` (`suspension_checker_tests.rs`,
  `await_checker_tests.rs`).
- [x] `PG-4.01.04` Código: regenerar el léxico desde el corpus (`GEN-NO-HAND-COPY`; nunca editar el vocabulario
  generado a mano); producciones en `pseudolearn_syntax`; `suspension_checker.rs` y `await_checker.rs` en
  `pseudolearn_semantic`; marca `suspendible` en el HIR de la unidad; integración con `effect_check.rs`.
- [x] `PG-4.01.05` README de `pseudolearn_engine` (secciones `syntax` y `semantic`).
- [x] `PG-4.01.06` Ligera: `see validate`, `lock --check`, `cargo test -p pseudolearn_syntax <filtro>`,
  `cargo test -p pseudolearn_semantic --lib suspension_checker`, `cargo test -p pseudolearn_semantic --lib
  await_checker`, `rust-checks all .` y Clippy de los dos crates.
- [x] `PG-4.01.07` Pesada: `see conform --subject engine --only <ID>` por `LANG.TASK.SUSPENSION`,
  `LANG.CAPABILITY.PURITY` y los cinco IDs del centinela léxico (§7.1.4); 246 observaciones, 0 divergencias.
  `cargo test -p pseudolearn_syntax`: 59 tests, 0 fallos.

### PG-4.02 · Ámbitos obligatorios: unión al salir, ningún hijo abandonado y cancelación cooperativa

- [x] `PG-4.02.01` Crear `LANG.TASK.SCOPE` con `S1`–`S10`. `LANG.CONTROL.CLEANUP#R2` vigente ya distingue la
  cancelación cooperativa de la del anfitrión y las trampas. Códigos: `spawnOutsideTaskScope`,
  `taskScopeInsideDefer`, `taskArgumentNotTransferable`
  (compartido con `PG-4.06`), `taskByReferenceArgument`, `taskHandleEscape`, `spawnTargetNotSuspendible`.
- [x] `PG-4.02.02` Casos: feliz (dos hijas unidas, hija sin valor como sentencia, ámbitos anidados de tres niveles,
  ámbito vacío); infeliz (un caso por código; `Lanzar` dentro de clausura y dentro de `Diferir`; asa asignada,
  retornada, capturada y pasada); cancelación (hija suspendida en canal cancelada por fallo de hermana ejecuta sus
  `Diferir` en orden inverso; nieta cancelada antes que su madre); límite (`Aguardar t` dos veces; ámbito cuya unión no
  suspende porque las hijas ya terminaron; cancelación de una tarea que espera un efecto concurrente ⇒ efecto
  `abandoned`). `C22` verifica la clausura; `C15` y `C16`, la cancelación y el orden de limpiezas; `C19`, el
  efecto `abandoned`; `C33` (añadido en `PG-4.04`) cancela mientras una hija espera un canal. La conformidad del
  motor de estos casos quedó verificada en `PG-4.02.07`.
- [x] `PG-4.02.03` Tests espejo: `task_scope_checker_tests.rs`, `task_handles_tests.rs` en semantic;
  `task_agenda_tests.rs` (cancelación y unión como estructura de datos) en runtime.
- [x] `PG-4.02.04` Código: semantic (`task_scope_checker.rs`, `task_handles.rs`); lowering (`task_scopes.rs`, aristas
  de unión en `cleanup_edges.rs`); runtime (`task_agenda.rs`, `task_state.rs`); VM (`machine/tasks.rs`). La RI ahora
  declara `O94`–`O100`; lowering genera operaciones de ámbito, lanzamiento, espera y unión; la agenda FIFO y la VM
  ejecutan tareas hijas con bancos y marcos aislados, resultados, esperas repetidas, unión de ámbitos anidados,
  cancelación cooperativa, limpiezas y esperas por canal y efecto (integradas en `PG-4.03`, `PG-4.04` y `PG-4.10`).
  La recolección incluye las raíces de contextos suspendidos. AOT sigue rechazando operaciones de tarea según
  `PG-4.12.04`.
- [x] `PG-4.02.05` README del motor (`semantic`, `lowering`, `runtime`, `vm`).
- [x] `PG-4.02.06` Ligera: tests de los módulos anteriores, `rust-checks`, Clippy por crate tocado.
- [ ] `PG-4.02.07` Pesada: `--only LANG.TASK.SCOPE,LANG.CONTROL.CLEANUP` en `engine` y `aot`. `engine` pasa
  SCOPE de nuevo (132 observaciones, 0 divergencias); CLEANUP conserva evidencia anterior vigente (52, 0).
  `aot` detiene SCOPE con código 1: `nativeTasksUnsupported` provoca `failed/analysisFailed` sin cinta y el corredor
  eleva `SEE-RECORDING`. Queda bloqueada por el soporte nativo pendiente de `PG-4.12.04`: la ruta de rechazo
  de `PG-4.12.07` no satisface esta casilla. En la revisión no se repiten CLEANUP ni los diferenciales, por §10.1.

### PG-4.03 · Política de fallos: el primero por orden lógico cancela a los hermanos; los demás se conservan

- [x] `PG-4.03.01` En `LANG.TASK.SCOPE`: reglas `F1`–`F6` y el tipo `FalloTareas<E>`; editar `LANG.PROFILE.VOCABULARY`
  (tipo y campos) y `DIAG.*` (`taskScopeErrorTypeMismatch`, `taskErrorNotTransferable`, `taskScopeFailureUnbound`,
  `taskScopeFailureUnused`).
- [x] `PG-4.03.02` Casos: feliz (ningún fallo ⇒ `Nada`); fallo único ⇒ `Algo` con `Primero`, `Asociados` vacío y
  `Canceladas` correcto; dos errores terminales registrados antes de cancelar ⇒ un asociado (modelo de datos); dos hijas con retorno inmediato ⇒ la segunda se cancela antes de retornar; fallo de
  la tarea con identidad mayor que termina primero ⇒ es `Primero` (orden de agenda, no de identidad); infeliz (uno por
  código); límite (fallo de la única hija; fallo con el cuerpo del ámbito suspendido en `Aguardar` de otra hija;
  trampa en una hija ⇒ `failed` global sin limpiezas).
- [x] `PG-4.03.03` Tests: `task_failure_tests.rs` en runtime (orden de primer fallo y asociados como datos puros);
  `task_failure_types_tests.rs` en semantic.
- [x] `PG-4.03.04` Código: runtime `task_failure.rs`; semantic `task_failure_types.rs` y conexión con
  `result_obligations.rs`; lowering del vínculo del ámbito.
- [x] `PG-4.03.05` README del motor.
- [x] `PG-4.03.06` Ligera: tests anteriores.
- [ ] `PG-4.03.07` Pesada: `--only LANG.TASK.SCOPE` en `engine` y `aot`.

### PG-4.04 · Canales con capacidad, cierre y contrapresión; elección resuelta por orden normativo

- [x] `PG-4.04.01` Crear `LANG.TASK.CHANNEL` con `C1`–`C8`; editar `LIB.MODEL` (métodos `Enviar`, `Recibir`,
  `Cerrar`), `ENG.TRACE.EVENTS` (`decision` de `Elegir`) y `DIAG.*` (`channelElementNotTransferable`,
  `channelOperationWithoutAwait`, `pureFunctionTaskOperation`, `selectNeedsTwoBranches`, `channelCapacityInvalid`).
- [x] `PG-4.04.02` Casos: productor/consumidor con capacidad 1 y 4; canal lleno que suspende al emisor y lo despierta
  al recibir; entrega directa a receptor en espera; `Recibir` de canal cerrado con datos y luego `Nada`; `Enviar` a
  canal cerrado ⇒ `Falso`; cierre con emisores y receptores en espera; `Cerrar` dos veces; `Elegir` con dos ramas
  listas ⇒ gana la primera textual; `Elegir` suspendido que despierta por cierre; mismo canal en dos ramas; infeliz
  (uno por código); límite (capacidad `1`, capacidad igual al máximo configurado, elemento de un registro con campo de
  clase rechazado).
- [x] `PG-4.04.03` Tests: `task_channel_tests.rs` y `wait_queue_tests.rs` en runtime; `channel_types_tests.rs` y
  `select_checker_tests.rs` en semantic.
- [x] `PG-4.04.04` Código: abi `channel_layout.rs`; runtime `task_channel.rs`, `wait_queue.rs`; semantic
  `channel_types.rs`, `select_checker.rs`; lowering `channel_operations.rs`, `select_dispatch.rs`; VM
  `machine/channels.rs`, `machine/select.rs`.
- [x] `PG-4.04.05` README del motor.
- [x] `PG-4.04.06` Ligera: tests anteriores.
- [ ] `PG-4.04.07` Pesada: `--only LANG.TASK.CHANNEL,LIB.MODEL,ENG.TRACE.EVENTS` en `engine` y `aot`.

### PG-4.05 · Bloqueo sin tareas ejecutables ni efectos pendientes, distinto de la espera de efecto

- [x] `PG-4.05.01` En `ENG.TASK.AGENDA`: `A7`; editar `ENG.EXEC.MODEL` (bloqueo como `failed` con `taskDeadlock`,
  distinto de `awaiting_effect`) y `DIAG.*` (`taskDeadlock` con ubicaciones relacionadas).
- [x] `PG-4.05.02` Casos: dos tareas que se reciben mutuamente ⇒ `taskDeadlock`; raíz en `FinTareas` con hija que
  espera un canal que nadie cierra ⇒ `taskDeadlock`; mismo programa con un efecto concurrente pendiente ⇒
  `awaiting_effect` (no bloqueo); efecto pendiente abandonado como único pendiente ⇒ bloqueo si la raíz no puede
  avanzar; límite (una sola tarea, la raíz, en `Aguardar c.Recibir()` sin emisores ⇒ `taskDeadlock`).
- [x] `PG-4.05.03` Tests: `task_deadlock_tests.rs` en runtime.
- [x] `PG-4.05.04` Código: runtime `task_deadlock.rs`; VM `model.rs` (trampa con causas) y `machine/tasks.rs`.
- [x] `PG-4.05.05` README del motor (`vm`).
- [x] `PG-4.05.06` Ligera: tests anteriores.
- [ ] `PG-4.05.07` Pesada: `--only ENG.TASK.AGENDA,ENG.EXEC.MODEL` en `engine` y `aot`.

### PG-4.06 · Aislamiento transitivo e instantánea inmutable con coste declarado

- [x] `PG-4.06.01` Crear `LANG.TASK.ISOLATION` con `I1`–`I7`; editar `LANG.PROFILE.VOCABULARY` (`Inmutable`,
  `Instantanea`), `LIB.MODEL` (firma y coste de `Instantanea`), `DIAG.*` (`snapshotNotSupported`,
  `immutableValueWrite`).
- [x] `PG-4.06.02` Casos adversarios (todos deben **rechazarse** en compilación): `Vector` como argumento; registro con
  campo de clase; `Opcional` de objeto; clausura que captura un objeto; clausura con entorno solo escalar (también se
  rechaza, `I2`); ciclo de clases `A → B → A` dentro de un registro; alias por parámetro por referencia; argumento de
  tipo genérico opaco; canal de `Vector`; error de tarea no transferible. Casos felices: `Instantanea` de vector de
  vectores con alias interno (el alias se conserva en la copia: modificar el original no cambia la copia y dos
  posiciones que compartían vector siguen compartiendo el copiado); `Inmutable` leído con `Para Cada`; resultado
  `Vector` movido desde una tarea terminada. Límite: `Instantanea` de vector vacío; instantánea que alcanza
  exactamente el presupuesto de celdas y la que lo supera por una.
- [x] `PG-4.06.03` Tests: `transferability_tests.rs`, `snapshot_types_tests.rs` en semantic;
  `snapshot_copy_tests.rs` en runtime (alias y ciclos con memoria por identidad de asa).
- [x] `PG-4.06.04` Código: semantic `transferability.rs`, `snapshot_types.rs`; runtime `snapshot_copy.rs`; lowering
  `snapshot_values.rs`.
- [x] `PG-4.06.05` README del motor (`semantic`, `runtime`), incluida la fila de Swift `Sendable` y Pony de §3.1.
- [x] `PG-4.06.06` Ligera: tests anteriores.
- [ ] `PG-4.06.07` Pesada: `--only LANG.TASK.ISOLATION,LIB.MODEL` en `engine` (análisis) y `aot` (ejecución).

### PG-4.07 · Planificador lógico con identidades monotónicas, desempate y cesión por masa compartidos por VM y AOT

- [x] `PG-4.07.01` En `ENG.TASK.AGENDA`: `A1`–`A6`; editar `IR.OBSERVATION-POINTS` (la masa por tarea y los puntos de
  cesión no cambian la cuenta de `#R2`), `IR.INSTRUCTIONS` (operaciones nuevas, §5.1) e `IR.WELL-FORMEDNESS`
  (operaciones de suspensión solo en funciones suspendibles; cesión solo en aristas de retorno de bucle).
- [x] `PG-4.07.02` Casos: dos tareas con bucles de CPU que escriben ⇒ entrelazado exacto según `Q`; tarea que cede con
  cola vacía ⇒ no hay `task_suspended`; despertar múltiple por `Cerrar` en orden de espera; tres hijas lanzadas
  seguidas ⇒ identidades `1, 2, 3` y primer turno del padre; límite (bucle de exactamente `Q` sentencias; tarea que
  nunca alcanza `Q`).
- [x] `PG-4.07.03` Tests: `task_agenda_tests.rs` (FIFO, desempate, cesión) en runtime;
  `suspension_points_tests.rs` y verificador en ir.
- [x] `PG-4.07.04` Código: ir `suspension_points.rs`, `verifier_suspension.rs`; bytecode (formas de 8 bytes de las
  operaciones nuevas, despacho regenerado por `pseudolearn_vm_dispatch`); lowering `yield_points.rs`; runtime
  `task_agenda.rs`; VM `machine/yield_points.rs`.
- [x] `PG-4.07.05` README del motor (`ir`, `bytecode`, `runtime`, `vm`).
- [x] `PG-4.07.06` Ligera: tests de ir, bytecode y runtime tocados.
- [ ] `PG-4.07.07` Pesada: `--only ENG.TASK.AGENDA,IR.INSTRUCTIONS,IR.WELL-FORMEDNESS,IR.OBSERVATION-POINTS` en
  `engine` y `aot`; comparación de gemelos `Fast`/`Probed` acotada a estos contratos.

### PG-4.08 · Continuaciones con disposición y raíces comunes; el GC recorre marcos suspendidos, entornos y mensajes

- [x] `PG-4.08.01` Crear `ENG.TASK.MEMORY` con `M1`–`M3`; editar `RT.ABI` (disposiciones de continuación, tarea y
  canal) y `ENG.LIMITS` (celdas de continuaciones y canales).
- [x] `PG-4.08.02` Casos con `gc_stress`: 100 tareas suspendidas con referencias vivas; canal lleno de objetos;
  instantánea cíclica en un canal; clausura capturada en el marco de una unidad suspendible; conteo de celdas
  observable igual antes y después de recolectar.
- [x] `PG-4.08.03` Tests: `continuation_layout_tests.rs` en abi; `suspension_spill_tests.rs` en VM; raíces en orden de
  identidad en runtime.
- [x] `PG-4.08.04` Código: abi `continuation_layout.rs`, `task_layout.rs`; VM `machine/suspension.rs` (volcado y
  restauración con el mapa de la RI), `machine/roots.rs` (raíces de la agenda), `machine/image.rs` (la imagen y el
  punto de control incluyen la agenda); timeline (puntos de control y `seek` con agenda).
- [x] `PG-4.08.05` README del motor (`abi`, `vm`, `timeline`).
- [x] `PG-4.08.06` Ligera: tests anteriores.
- [ ] `PG-4.08.07` Pesada: `--only ENG.TASK.MEMORY,RT.ABI,ENG.LIMITS,ENG.STATE.SNAPSHOT,ENG.STATE.INCREMENTAL` en
  `engine` y `aot` con `gc_stress`.

### PG-4.09 · Límites de tareas y de colas como terminaciones definidas

- [x] `PG-4.09.01` Editar `ENG.LIMITS`: regla nueva con los límites `tasks` y `channel_capacity`, sus omisiones
  (`4 096` y `65 536`; app `256` tareas, informativo como `#R8`) y su clasificación `failed`
  (`taskLimitExceeded`, `channelCapacityExceeded`).
- [x] `PG-4.09.02` Casos en el borde exacto: límite de tareas `N` con `N` vivas (pasa) y `N + 1` (falla en el
  `Lanzar`, con su tramo, sin efectos posteriores); capacidad igual al máximo (pasa) y máximo + 1 (falla); tareas
  terminadas no cuentan como vivas.
- [x] `PG-4.09.03` Tests: límites en `task_agenda_tests.rs` y `task_channel_tests.rs`.
- [x] `PG-4.09.04` Código: runtime y configuración de límites en `pseudolearn_api` (`RunOptions` y negociación).
  Si la CLI ya expone límites configurables, añadir `tasks`; si no, nada (`SCOPE-YAGNI`).
- [x] `PG-4.09.05` README del motor y de la CLI si cambia.
- [x] `PG-4.09.06` Ligera: tests anteriores.
- [ ] `PG-4.09.07` Pesada: `--only ENG.LIMITS` en `engine` y `aot`.

### PG-4.10 · 10 000 agendas sembradas reproducen sus observables, con cero diferencias

- [x] `PG-4.10.01` Editar `ENG.EFFECT.TAPE` (`delivery_seq`, `abandoned`, `task_id` real; `D-PG4-14`),
  `ENG.EXEC.EFFECT-ORDER` (orden de entrega), `ENG.EXEC.MODEL#R5` y `API.EXECUTE#R6` (lista de pendientes;
  `CF-PG4-04`), `RT.HOST.INTERFACE` (entrega con agenda ociosa) y el esquema del caso `see/1` (`anfitrion` acepta
  `orden_entrega`).
- [x] `PG-4.10.02` Casos: tres efectos concurrentes entregados en orden inverso graban `delivery_seq` y se reproducen
  igual; misma cinta con orden alterado ⇒ `replay_divergence`; programa de `PG-3` sin `Aguardar` produce cinta
  idéntica byte a byte a la de antes de `PG-4`.
- [x] `PG-4.10.03` Tests: `tape_codec` y `tape_replay` con entregas desordenadas; anfitrión falso con orden declarado.
- [x] `PG-4.10.04` Código: runtime `effect_tape.rs`, `tape_codec.rs`, `tape_replay.rs`; VM `machine/effects.rs` y
  `effect_completion.rs` (varios pendientes); timeline `effect_replay.rs`; API `execution_effects.rs`,
  `fake_host.rs`, `tape_wire.rs`; generador y campaña `pg_tasks` en `pseudolearn_bench_worker` (§7.3).
- [x] `PG-4.10.05` README del motor (`runtime`, `timeline`, `api`) y README del trabajador de medición.
- [x] `PG-4.10.06` Ligera: tests de cinta y del generador de agendas (sin ejecutar la campaña).
- [ ] `PG-4.10.07` Pesada: campaña completa de 10 000 agendas (§7.3) con cero diferencias, más
  `--only ENG.EFFECT.TAPE,ENG.EXEC.EFFECT-ORDER,ENG.EXEC.MODEL,API.EXECUTE,RT.HOST.INTERFACE`.

### PG-4.11 · Eventos de tarea observables disponibles para la app

- [x] `PG-4.11.01` Editar `ENG.TRACE.EVENTS` (clases `E1`, regla `E2`), `API.WIRE-FORMAT` si el PLEV necesita códigos
  de clase nuevos, `API.STATE.QUERY` (el estado en un evento lista los marcos de la tarea actual y un resumen de todas
  las tareas: identidad, padre, estado, causa y objetivo), `API.PROGRAM.VIEW` (§3.3: modificador, `Aguardar`, ámbito
  con vínculo, `Lanzar`, `Elegir` y ramas, operaciones de canal, tipos nuevos) y `TOOL.SERVICE.CATALOG` (una ficha
  `es`/`en` por identidad de §3.3 con ejemplo verificable).
- [x] `PG-4.11.02` Casos: la cinta ilustrativa de seis pasos de `ADR-12` reproducida como caso de traza; consulta de
  estado con una tarea suspendida y otra lista; vista pública de cada forma nueva; ayuda de cada identidad en ambos
  perfiles.
- [x] `PG-4.11.03` Tests: `event_codec` y `event_binary` con clases nuevas; `program_view_tasks_tests.rs`; tests Dart
  espejo de cada archivo de la app tocado (se escriben ahora, se **ejecutan** en la iteración 5).
- [x] `PG-4.11.04` Código: VM `events.rs`; API `event_codec.rs`, `event_binary.rs`, `state_pages.rs`,
  `program_view_tasks.rs`; datos del catálogo; app: `rust_wire_models.dart` (clases de evento, lista de pendientes),
  `rust_execution_api.dart` y `rust_program_execution.dart` (`effect_result` por `effect_seq`),
  `rust_simulated_host.dart` (entrega FIFO determinista de varios pendientes), `rust_construct_projection.dart` y
  `rust_program_view_builder.dart` (tipos de nodo nuevos), `rust_flowchart_block_builder.dart` y
  `rust_structogram_cell_builder.dart` (nodos explícitos con marca de suspensión y textos desde l10n o catálogo, nunca
  literales sueltos en la capa equivocada).
- [x] `PG-4.11.05` README de `pseudolearn_engine` (`api`) y de `apps/pseudolearn_app` (qué entrega `PG-4` y qué queda
  para `PG-B`).
- [x] `PG-4.11.06` Ligera: tests Rust de codificación; `dart analyze` y `dart run tool/check_limits.dart` en la app.
- [x] `PG-4.11.07` Pesada: `--only ENG.TRACE.EVENTS,API.STATE.QUERY,API.PROGRAM.VIEW,TOOL.SERVICE.CATALOG,API.WIRE-FORMAT`;
  `flutter test test/architecture_test.dart` y tests espejo tocados; `bash tool/test_bridge.sh` (disparador de
  contrato JSON).

### PG-4.12 · `E-PG-06` ejecutado; métrica candidata medida; async nativo en AOT solo si pasa

- [x] `PG-4.12.01` Sin especificación normativa nueva: las métricas son candidatas (`PERF.PG.TASKS.*`) hasta que la
  persona las apruebe. Si la persona las aprueba en `P5`, se redactan después como identidades `PERF` propias.
- [x] `PG-4.12.02` Protocolo de §7.3 y §7.5 escrito en el README del trabajador antes de medir.
- [x] `PG-4.12.03` Tests del generador, del resumen y del comparador (`pg_tasks_*_tests.rs`).
- [ ] `PG-4.12.04` Código AOT: codegen `suspension_frames.rs` (función reanudable con selector de estado y volcado),
  `lower_tasks.rs`, `lower_channels.rs`; `pseudolearn_aot_rt` `task_runtime.rs` y `task_channel.rs` (frontera
  `extern "C"` que delega en la agenda del runtime; `unsafe` solo en funciones breves con su fila de invariantes en el
  README) y `effects.rs` (peticiones concurrentes); `conformance-aot.yaml`: reglas de tareas en `pendiente` hasta la
  iteración 5.
- [x] `PG-4.12.05` README del motor (`codegen`, `aot_rt`, tabla de invariantes de `unsafe`) y del trabajador.
- [x] `PG-4.12.06` Ligera: `cargo check` y tests unitarios de codegen y `aot_rt` tocados.
- [ ] `PG-4.12.07` Pesada: `E-PG-06` completo; si **toda** la comparación VM/AOT da cero diferencias, las reglas pasan a
  `cumple` en `conformance-aot.yaml`; si no, quedan `pendiente`, el README del motor declara que AOT no ofrece tareas
  y la CLI rechaza `--nativo` con tareas mediante un diagnóstico explícito. Nunca se anuncia async nativo sin pasar.

---

## 5. Capas y archivos

`E` = `packages/pseudolearn_engine/crates`, `S` = `packages/pseudolearn_spec`, `A` = `apps/pseudolearn_app`,
`C` = `apps/pseudolearn_cli`. Antes de crear o tocar cada archivo la IA responde por escrito, en su mensaje de trabajo,
las tres preguntas de `AGENTS.md` §1 y confirma que el archivo cabe en los límites de §1.2.4. Si un archivo
existente superaría 300 líneas (250 en la app), la responsabilidad nueva va en un archivo hermano nuevo.

| Archivos | Capa · imports permitidos / prohibidos | Dueño y motivo · puntos |
|---|---|---|
| Este archivo y `plan-ejecucion-proposito-general.md` | Documentación transitoria · nunca citada fuera de `docs/` | Planificación |
| `S/specifications/lang/`: nuevos `lang.task.suspension.md`, `lang.task.scope.md`, `lang.task.channel.md`, `lang.task.isolation.md`; editados `lang.profile.vocabulary.md`, `lang.syntax.grammar.md`, `lang.capability.purity.md`, `lang.control.cleanup.md` (solo tras `CF-PG4-01`) y, si enumera reservadas, `lang.lexical.keyword.md` | Datos normativos · sin enlaces externos (`SPEC-SELF-CONTAINED`) | Sintaxis y semántica del lenguaje · `.01`–`.06` |
| `S/specifications/eng/`: nuevos `eng.task.agenda.md`, `eng.task.memory.md`; editados `eng.limits.md`, `eng.trace.events.md`, `eng.exec.model.md`, `eng.exec.effect-order.md`, `eng.effect.tape.md` | Datos normativos | Agenda, memoria, límites, eventos y cinta · `.05`, `.07`–`.11` |
| `S/specifications/{lib,rt,api,ir,diag,tool}/`: `lib.model.md`, `rt.abi.md`, `rt.host.interface.md`, `api.execute.md`, `api.state.query.md`, `api.program.view.md`, `api.wire-format.md` (si aplica), `ir.instructions.md`, `ir.well-formedness.md`, `ir.observation-points.md`, `diag.catalog.md`, `diag.messages.md`, `tool.service.catalog.md`; esquema del caso `see/1`; `conformance.yaml` y `conformance-aot.yaml` del motor | Datos normativos y de conformidad (`SPEC-BINDING-AS-DATA`) | Contratos de frontera, diagnósticos, ayuda y vínculos |
| `E/pseudolearn_abi/src/`: `continuation_layout.rs`, `task_layout.rs`, `channel_layout.rs` | `abi` · sin dependencias internas | Disposiciones únicas VM/AOT · `.04`, `.08` |
| `E/pseudolearn_lexicon` (generado) y `E/pseudolearn_syntax/src/` | `lexicon`, `syntax` · sin `semantic` ni `runtime` | Vocabulario generado y gramática · `.01`–`.04`, `.06` |
| `E/pseudolearn_semantic/src/`: `suspension_checker.rs`, `await_checker.rs`, `task_scope_checker.rs`, `task_handles.rs`, `task_failure_types.rs`, `transferability.rs`, `snapshot_types.rs`, `channel_types.rs`, `select_checker.rs`; ajustes en `effect_check.rs`, `result_obligations.rs`, `cleanup_checker.rs` | `semantics` · `source`, `project`, `diagnostics`, `lexicon`, `syntax`; prohibido `runtime`, `ir`, `codegen` | Reglas estáticas · `.01`–`.06` |
| `E/pseudolearn_ir/src/`: `suspension_points.rs`, `verifier_suspension.rs`; operaciones nuevas en el catálogo generado | `ir` · `source`, `abi`; prohibido `semantic`, `runtime` | Mapa de suspensión y verificación · `.07`, `.08` |
| `E/pseudolearn_lowering/src/`: `task_scopes.rs`, `await_calls.rs`, `channel_operations.rs`, `select_dispatch.rs`, `yield_points.rs`, `snapshot_values.rs`; ajustes en `cleanup_edges.rs`, `effect_calls.rs` | `lowering` · `semantic`, `ir`, `diagnostics`; prohibido `runtime` | HIR → RI · `.01`–`.07` |
| `E/pseudolearn_bytecode/src/` y `E/pseudolearn_vm_dispatch` | `bytecode` · `ir`, `source` | Formas de 8 bytes y despacho regenerado · `.07` |
| `E/pseudolearn_runtime/src/`: `task_agenda.rs`, `task_state.rs`, `task_failure.rs`, `task_deadlock.rs`, `task_channel.rs`, `wait_queue.rs`, `snapshot_copy.rs`; ajustes en `effect_tape.rs`, `tape_codec.rs`, `tape_replay.rs` | `runtime` · `abi`, `diagnostics`; prohibido `vm`, `codegen`; `#![forbid(unsafe_code)]` | Agenda única, canales, instantánea y cinta · `.02`–`.10` |
| `E/pseudolearn_vm/src/machine/`: `tasks.rs`, `suspension.rs`, `channels.rs`, `select.rs`, `yield_points.rs`; ajustes en `roots.rs`, `image.rs`, `effects.rs`, `effect_completion.rs`, `mod.rs`; `model.rs`, `events.rs` | `vm` · `bytecode`, `runtime`, `library`, `diagnostics`; prohibido `codegen` | Ejecución y suspensión · `.02`–`.11` |
| `E/pseudolearn_timeline/src/`: ajustes en `checkpoint.rs`, `replay.rs`, `effect_replay.rs` | `timeline` · `vm`, `runtime`, `bytecode`, `diagnostics` | Puntos de control y `seek` con agenda · `.08`, `.10` |
| `E/pseudolearn_codegen/src/`: `suspension_frames.rs`, `lower_tasks.rs`, `lower_channels.rs`; ajustes en `shadow_stack.rs`, `lexical_roots.rs`, `instruction_dispatch.rs` | `codegen` · `ir`, `diagnostics`, `aot_rt` | Paridad AOT · `.12` |
| `E/pseudolearn_aot_rt/src/`: `task_runtime.rs`, `task_channel.rs`; ajuste en `effects.rs` | `aot_rt` · `source`, `abi`, `diagnostics`, `runtime`, `library`; `unsafe` solo declarado | Frontera nativa · `.12` |
| `E/pseudolearn_api/src/`: `program_view_tasks.rs`; ajustes en `execution_effects.rs`, `execution_wire.rs`, `event_codec.rs`, `event_binary.rs`, `state_pages.rs`, `fake_host.rs`, `tape_wire.rs` | `api` · las capas de su fila | Frontera pública · `.09`–`.11` |
| `E/pseudolearn_bench_worker/src/`: `pg_tasks_agendas.rs`, `pg_tasks_campaign.rs`, `pg_tasks_compare.rs`, `pg_tasks_summary.rs` y sus `_tests.rs` | `tooling` | `E-PG-06` y `PG-4.10` |
| `C/src/`: solo si existe configuración de límites o para el rechazo explícito de `--nativo` con tareas | `cli` · solo `pseudolearn_api` | `.09`, `.12` |
| `A/lib/engine/rust/`: archivos de `PG-4.11.04` y sus tests en `A/test/engine/rust/` | `engine` → `model`, `ports`; sin widgets | Evolución sincronizada · `.11` |

### 5.1 Operaciones nuevas de la RI (candidatas)

`IR.INSTRUCTIONS` llega hoy a `O93`. Se añaden en este orden, con identidad `O94` en adelante, nombre con punto como
las existentes y fila completa (operandos, clases, efecto, observación, trampas): `task.scope_open`, `task.spawn`,
`task.await`, `task.scope_join`, `call.suspendible`, `effect.await`, `task.yield_check`, `channel.new`,
`channel.send`, `channel.receive`, `channel.close`, `channel.select`, `value.snapshot`. El despacho de la VM se
regenera desde la exportación (`GEN-NO-HAND-COPY`); nunca se escribe a mano.

---

## 6. Presupuestos de rendimiento y seguridad

### 6.1 Rendimiento y memoria (candidatos hasta `P5`)

| Magnitud | Presupuesto | Control |
|---|---|---|
| Infraestructura inactiva en `PERF.SUITE.CORE` | Media geométrica ≤ 2 %; por carga, razón puntual ≤ 1,08 y límite superior del IC 95 % ≤ 1,15 (misma forma que la revisada por la persona en `PG-3`) | Las unidades no suspendibles no contienen `task.yield_check`; la agenda se aloja de forma perezosa en el primer `task.scope_open`; cero bytes adicionales sin tareas |
| Memoria de 1 000 continuaciones vacías | ≤ 8 MiB adicionales (`E-PG-06`) | Medición en §7.3 |
| Lanzar + unir por tarea | Lineal en número de tareas (1, 10, 100, 1 000); sin crecimiento cuadrático | Regresión lineal sobre las cuatro cargas |
| Cambio de tarea | Coste proporcional a los valores vivos del punto, no al tamaño del marco | Microcarga con 0, 8 y 64 valores vivos |
| Canal | Envío/recepción O(1) amortizado; memoria fija por capacidad | Microcarga productor/consumidor |
| `PERF.ARTIFACT.SIZE` | Topes vigentes (`≤ 5 MiB` iOS, `≤ 900 KiB` Wasm con Brotli) | Solo si crece el runtime enlazado (§7.1.4) |

### 6.2 Seguridad (STRIDE de la hoja de ruta §9.3)

- **Manipulación entre tareas:** ninguna referencia mutable cruza una frontera (`I1`–`I4`), verificado en compilación;
  sin `mutex` ni memoria compartida mutable.
- **Denegación de servicio:** límites de tareas, capacidad y celdas (`D-PG4-19`); presupuesto de sentencias global;
  el bloqueo termina con diagnóstico en vez de colgar.
- **Repudio/reproducibilidad:** el orden de entrega queda en la cinta (`delivery_seq`); la reproducción jamás consulta
  al anfitrión.
- **Elevación:** las capacidades transferidas siguen siendo no amplificables; transferir no concede derechos nuevos.
- **Revelación:** los valores de mensajes no se graban en la cinta (son internos); los eventos de canal no incluyen
  valores, solo identidades.

---

## 7. Pruebas y experimentos

### 7.1 Política de pruebas: ligeras en iteraciones 1–4, pesadas solo en la iteración 5

#### 7.1.1 Ligeras (las únicas permitidas en las iteraciones 1–4)

| Qué | Cuándo | Comando de referencia |
|---|---|---|
| Integridad del corpus | La iteración crea o edita especificaciones | Desde `packages/pseudolearn_spec`: `cargo run --locked -p see_cli --bin see -- validate`; `… lock --check` (tras `lock --refresh <ID,ID>` autorizado en `P1`); `… export --check`. Si se tocó Rust de `pseudolearn_spec` (esquema de caso, anfitrión falso), además `rust-checks all .` desde ese miembro. `pseudolearn_spec` no tiene `check_limits.py`: ese script es del motor de marca y no se usa aquí |
| Compilación del crate tocado | Siempre que se toca Rust | Desde `packages/pseudolearn_engine`: `cargo check -p <crate>` |
| Tests unitarios de los módulos creados o tocados | Siempre | `cargo test -p <crate> --lib <módulo>` o `cargo test -p <crate> --test <archivo>` |
| Verificadores estáticos | Siempre | `cargo fmt --check`; `cargo clippy -p <crate> --all-targets -- -D warnings`; `cargo run --manifest-path ../pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command --bin rust-checks -- all .` |
| App | Solo archivos Dart tocados | Desde `apps/pseudolearn_app`: `dart analyze lib/engine/rust test/engine/rust`; `dart run tool/check_limits.dart` |

#### 7.1.2 Pesadas (solo en la iteración 5)

- `see conform --subject engine --only <ID>` y `--subject aot --only <ID>` de **todos** los contratos creados o
  editados en `PG-4` (lista en §10.1), seguidos de `see differential` por contrato (§10.1).
- **Atención:** `--only` admite **un único ID** (el filtro de `see_cli` compara por igualdad). En este plan, la
  notación `--only A,B,C` significa una invocación por ID, nunca una lista separada por comas en una sola orden.
- Comparación de gemelos `Fast`/`Probed` acotada a esos contratos.
- `gc_stress` de los casos de `ENG.TASK.MEMORY`.
- Campaña `E-PG-06` de §7.3 (incluye `PG-4.10`) y regresión de `PERF.SUITE.CORE` en `release`.
- `flutter test test/architecture_test.dart` y tests espejo Dart tocados; `bash tool/test_bridge.sh`.
- Los conjuntos de §7.1.4 cuyo disparador se haya activado durante la fase.

#### 7.1.3 Nunca

`cargo xtask verify`, `cargo test --workspace`, `see conform` sin `--only`, `flutter test` de toda la carpeta, y
campañas de rendimiento fuera de la iteración 5.

#### 7.1.4 Disparadores cerrados de ampliación (se ejecutan en la iteración 5)

| Disparador | Ampliación máxima |
|---|---|
| Palabra reservada nueva | `--only LANG.LEXICAL.KEYWORD,LANG.LEXICAL.IDENTIFIER,LANG.PROFILE.VOCABULARY,LANG.PROFILE.TRANSLATION,LANG.SYNTAX.GRAMMAR` y tests de `pseudolearn_syntax` |
| Operación nueva en la RI o en el despacho | Tests de `pseudolearn_ir`, `pseudolearn_bytecode`, `pseudolearn_vm_dispatch` y gemelos acotados |
| Cambio del JSON consumido por la app | Tests Dart del adaptador y `bash tool/test_bridge.sh` |
| Cambio de `Cargo.lock` o de dependencias | `cargo deny check` del miembro (no se espera ninguna dependencia nueva) |
| Crecimiento del runtime enlazado en AOT/Wasm | `PERF.ARTIFACT.SIZE` puntual |
| Falla un test por causa en un crate vecino | Tests del módulo vecino, una vez |

#### 7.1.5 Riesgo aceptado por la persona

Aplazar la conformidad a la iteración 5 aumenta la probabilidad de descubrir errores tarde. Mitigaciones: los casos se
derivan de la regla en la iteración 1, antes de cualquier código; los tests unitarios de cada módulo cubren feliz,
infeliz y límite; y la iteración 5 reserva una **subsanación** con orden fijo (§10, `P5`).

### 7.2 Matriz mínima de comportamiento (`TEST-BOTH-PATHS`)

| Punto | Feliz | Infeliz | Límite |
|---|---|---|---|
| `.01` | `Aguardar` de cadena suspendible | Cada diagnóstico de `U2`–`U5` | Unidad suspendible sin suspensión; recursión de profundidad 3 |
| `.02` | Dos hijas unidas | `Lanzar` fuera del bloque, asa escapada | Ámbito vacío; unión sin suspensión |
| `.03` | Sin fallo ⇒ `Nada` | Tipos de error distintos | Fallo con cuerpo suspendido; trampa global |
| `.04` | Productor/consumidor | Elemento no transferible; `Enviar` sin `Aguardar` | Capacidad 1 y máxima; dos ramas listas |
| `.05` | Programa que termina | Bloqueo mutuo | Raíz sola esperando |
| `.06` | `Instantanea` con alias interno | Diez adversarios de §4 | Vector vacío; borde de celdas |
| `.07` | Entrelazado por `Q` | Cesión con cola vacía | Bucle de exactamente `Q` |
| `.08` | 100 tareas con `gc_stress` | Ninguna raíz perdida (fallo = divergencia) | Continuación sin valores vivos |
| `.09` | `N` tareas vivas | `N + 1` | Tareas terminadas no cuentan |
| `.10` | Cinta con entregas desordenadas | Orden alterado | Programa de `PG-3` idéntico byte a byte |
| `.11` | Cinta ilustrativa de seis pasos | Clase de evento desconocida rechazada en la app | Estado con cero tareas hijas |
| `.12` | VM = AOT en las 10 000 agendas | Una diferencia ⇒ AOT no anuncia tareas | 1 000 tareas |

### 7.3 Experimento `E-PG-06` y `PG-4.10` · 10 000 agendas sembradas

1. **Generador** (`pg_tasks_agendas.rs`): para cada semilla `s` en `[0, 10 000)`, familia `s mod 8` y parámetros desde
   un generador SplitMix64 implementado en el trabajador (nunca en el motor). Familias:
   `F1` abanico y unión de 1–1 000 tareas; `F2` productor/consumidor con capacidad ∈ {1, 2, 8, 64} y cola llena;
   `F3` fallo de una hermana elegida por semilla, con cancelación y asociados; `F4` hambre: tareas de CPU con cesión y
   una tarea que espera; `F5` `Elegir` con 2–4 canales listos a la vez; `F6` bloqueo inyectado (resultado esperado
   `taskDeadlock`); `F7` efectos concurrentes con permutación de entrega elegida por semilla en el anfitrión falso;
   `F8` `gc_stress` con instantáneas cíclicas y vectores de vectores con alias.
2. **Un binario por familia.** Las ocho plantillas leen sus parámetros por la capacidad `Argumentos`, de modo que AOT
   compila **ocho** ejecutables, no 10 000.
3. **Por semilla:** (a) VM en vivo, gemelo rápido: salida, terminación, diagnósticos con sitio y cinta `τ`;
   (b) VM sondeada: eventos; (c) VM desde `τ`; (d) VM en vivo repetida: `τ` idéntica byte a byte; (e) AOT en vivo con
   el mismo anfitrión falso y AOT desde `τ`.
4. **Comparación:** salida, terminación y diagnósticos con sitio iguales en (a)–(e); eventos iguales entre las
   ejecuciones de VM; cintas iguales entre (a), (d) y AOT. Cualquier diferencia se registra con su semilla.
5. **Adversarios estáticos:** la batería de `PG-4.06.02` más alias cíclico generado: 100 % rechazados.
6. **Memoria:** celdas y bytes por tarea con 1, 10, 100 y 1 000 tareas; 1 000 continuaciones vacías.
7. **Criterio:** cero divergencias, cero capturas mutables admitidas, memoria por tarea y por cola acotada, ≤ 8 MiB
   para 1 000 continuaciones vacías. Si AOT diverge, se aplica `PG-4.12.07`.
8. **Ejecución:** en segundo plano, con notificación al terminar; **nunca** con bucles de sondeo (`sleep`/`until`)
   sobre su salida. Si dura más de 60 minutos, se parte por rangos de semilla y se registra la partición.

### 7.4 Regresión de `PERF.SUITE.CORE`

Control: binario de la revisión inicial `276a156`. Tratamiento: binario final de `PG-4` sin tareas en los programas.
Protocolo `PERF.PROTOCOL`: al menos 10 procesos × 30 muestras por carga, IC bootstrap 95 %, revisión Git, toolchain,
hardware (Mac M2 de referencia) y semilla.

### 7.5 Procedencia

Cada campaña registra en §11: comando exacto, revisión Git, `rustc --version`, hardware, fecha, semillas, número de
muestras, ruta local ignorada de los datos crudos y resumen. Los datos crudos no se versionan.

---

## 8. Riesgos y señales tempranas

| Riesgo | Señal temprana | Mitigación |
|---|---|---|
| `K-05` Alias o captura rompe aislamiento o GC | Un adversario de `PG-4.06.02` compila; una divergencia aparece solo con `gc_stress` | Predicado estático único; raíces de la agenda en orden de identidad; `F8` en `E-PG-06` |
| `K-08` Hambre, bloqueo o fuga | Un caso `F4` no progresa; una tarea viva tras `FinTareas` | Cesión por cuanto; unión obligatoria; `A8` como fallo interno detectable |
| `PG4-R01` Divergencia VM/AOT en el orden de agenda | Una semilla de `E-PG-06` difiere solo en AOT | Agenda única en el runtime (`D-PG4-11`); mapa de suspensión único en la RI |
| `PG4-R02` Coste en el camino rápido | `PERF.SUITE.CORE` empeora | Sin cesión en unidades no suspendibles; agenda perezosa |
| `PG4-R03` Explosión de valores vivos | Registros de continuación grandes | Tamaño = máximo de vivos por función; medir en `E-PG-06` |
| `PG4-R04` Conformidad tardía | Muchos fallos en la iteración 5 | Casos derivados en la iteración 1; subsanación con orden fijo |
| `PG4-R05` Disco lleno a mitad de compilación o campaña | `df` < 15 GiB | Protocolo §13 antes de cada iteración y antes de `release` |
| `PG4-R06` Desfase de la app | Nodo desconocido o clase de evento no reconocida | Tests espejo Dart y `test_bridge.sh` en la iteración 5 |

---

## 9. Dependencias de la persona

| Momento | Qué necesita la IA de la persona |
|---|---|
| Antes de todo | Revisión de este plan (`PG-4.C02`) y autorización para iniciar la fase (`PG-4.C01`) en un mensaje nuevo |
| Cada iteración de §10 | Autorización explícita en mensaje nuevo; la persona puede autorizar varias iteraciones juntas, y entonces la IA se detiene solo en los puntos de control `P` |
| `P1` (fin de la iteración 1, antes de anclar) | Confirmar lexemas de §3.3, `Q = 1 024`, `CF-PG4-01` y los límites por omisión; aportar `revisado_por` y autorizar `lock --refresh` de los IDs editados |
| §13 | Confirmación solo para los elementos marcados «consultar» (papelera, otros proyectos o herramientas ajenas) |
| `P5` | Aprobar o rechazar las métricas candidatas `PERF.PG.TASKS.*`; revisar resultados de `E-PG-06`; autorizar commit y push de cierre |

---

## 10. Orden de ejecución y puntos de control

Antes de **cada** iteración: (1) `git status` limpio o solo con cambios de la fase; (2) `git branch --show-current`
debe ser `feature/agregar-ruta-de-especificacion`; (3) protocolo de disco de §13.

| Iteración | Contenido | Verificación al cerrar | Punto de control |
|---|---|---|---|
| **1 · Corpus** | Tareas `.01` y `.02` de todos los puntos; respuesta a `CF-PG4-04`; lectura pendiente de §2 | Ligera de corpus (§7.1.1) | **`P1`**: la persona confirma sintaxis, `Q`, `CF-PG4-01`, límites y `revisado_por`; solo entonces `lock --refresh` |
| **2 · Frente estático** | Léxico generado, sintaxis, semántica (`.01`–`.06`, parte estática de `.03`, `.04`, `.09`), catálogo de ayuda y vista pública (`.11`, parte estática) | Ligera Rust de `lexicon`, `syntax`, `semantic`, `service`, `api` (vista) | `P2`: informe breve y parada |
| **3 · RI, runtime y VM** | Operaciones de RI, mapa de suspensión, disposiciones, agenda, canales, instantánea, cancelación, bloqueo, límites, raíces, puntos de control, eventos, efectos concurrentes y cinta (`.02`–`.11` en VM); README del motor (`CF-PG4-02`) | Ligera Rust de `abi`, `ir`, `lowering`, `bytecode`, `runtime`, `vm`, `timeline`, `api` | `P3`: informe breve y parada |
| **4 · AOT, CLI, app y trabajador** | `.12.04`, ajustes de CLI, app (`.11.04`), generador `pg_tasks` y sus tests | `cargo check` y tests unitarios de `codegen`, `aot_rt`, CLI y trabajador; `dart analyze` y `check_limits.dart` | `P4`: informe breve y parada |
| **5 · Conformidad pesada, experimentos y cierre** | Todas las tareas `.07`; §7.3 y §7.4; disparadores de §7.1.4; cierre común `PG-4.C01`–`C13`; commit y push | Todas las pesadas en verde | **`P5`**: la persona revisa y autoriza commit y push |

**Orden fijo de subsanación en la iteración 5.** Si una prueba pesada falla: (1) reproducir el caso aislado con
`--only` y el ID de caso; (2) decidir si el error está en el código o en el caso; si está en el caso, **no** se cambia
el esperado sin derivarlo de nuevo de la regla y sin informar a la persona (`SPEC-INDEPENDENT-ORACLE`); (3) corregir;
(4) repetir solo lo que falló; (5) al final, repetir una vez la selección pesada completa de §10.1.

### 10.1 Selección pesada de la iteración 5

Contratos para `--only` (engine y aot): `LANG.TASK.SUSPENSION`, `LANG.TASK.SCOPE`, `LANG.TASK.CHANNEL`,
`LANG.TASK.ISOLATION`, `ENG.TASK.AGENDA`, `ENG.TASK.MEMORY`, `LANG.CAPABILITY.PURITY`, `LANG.CONTROL.CLEANUP`,
`LANG.PROFILE.VOCABULARY`, `LANG.SYNTAX.GRAMMAR`, `LIB.MODEL`, `ENG.LIMITS`, `ENG.TRACE.EVENTS`, `ENG.EXEC.MODEL`,
`ENG.EXEC.EFFECT-ORDER`, `ENG.EFFECT.TAPE`, `ENG.STATE.SNAPSHOT`, `ENG.STATE.INCREMENTAL`, `RT.ABI`,
`RT.HOST.INTERFACE`, `API.EXECUTE`, `API.STATE.QUERY`, `API.PROGRAM.VIEW`, `API.WIRE-FORMAT` (si se editó),
`IR.INSTRUCTIONS`, `IR.WELL-FORMEDNESS`, `IR.OBSERVATION-POINTS`, `TOOL.SERVICE.CATALOG`, más los centinelas de
§7.1.4 activados. Comandos desde `packages/pseudolearn_spec`, **por cada ID de la lista, en este orden** (el
`differential` no tiene filtro: compara la última evidencia de `results/engine.json` y de `aot`, por eso va justo
después de las dos conformidades del mismo ID):

1. `cargo run --locked -p see_cli --bin see -- conform --subject engine --only <ID>`
2. `cargo run --locked -p see_cli --bin see -- conform --subject aot --only <ID>` (omitir si el contrato no declara
   `aot` en `sujetos`)
3. `cargo run --locked -p see_cli --bin see -- differential` (omitir si se omitió el paso 2)

Se detiene en el primer código de salida distinto de `0` y se aplica el orden de subsanación. El resultado de cada
paso se copia a §11 antes de pasar al siguiente ID, porque cada `conform` reescribe la evidencia local.

Desde `packages/pseudolearn_engine`: `cargo run --release -p pseudolearn_bench_worker -- <subcomando pg_tasks>` según
lo que documente su README tras la iteración 4. Desde `apps/pseudolearn_app`: `flutter test test/architecture_test.dart`,
`flutter test test/engine/rust/<archivo>_test.dart` por cada archivo tocado y `bash tool/test_bridge.sh`.

---

## 11. Resumen de ejecución

| Tarea | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| `PG-4.01` | Completa | `.01`–`.07`; 15 casos bilingües, 4 felices, 6 de diagnóstico y 5 de límite; verificaciones ligeras previas en verde. Tras las correcciones, `see validate` validó 187 especificaciones; `lock --check` y `see export --check` pasan. La conformidad pesada ejecutó 7 contratos de `engine`: 246 observaciones, 0 divergencias (`LANG.TASK.SUSPENSION` 60, `LANG.CAPABILITY.PURITY` 92, `LANG.LEXICAL.KEYWORD` 20, `LANG.LEXICAL.IDENTIFIER` 38, `LANG.PROFILE.VOCABULARY` y `LANG.PROFILE.TRANSLATION` 8 cada uno, `LANG.SYNTAX.GRAMMAR` 20). `cargo test -p pseudolearn_syntax`: 59 tests, 0 fallos. Se corrigieron los programas de `C3`, `C4`, `C14`, `C15` y `C23`; se preservaron esperados, estados y versiones. La evidencia previa con hashes obsoletos se conservó bajo nombres `*.before-pg-4-01-07-2026-10-28.json` en `results/` | PG-4 continúa abierta; esta casilla no declara cerrada la fase |
| `PG-4.02` | Parcial; `.07` bloqueada en AOT | `.01`–`.06`; revisión de SCOPE en `engine`: código 0, 132 observaciones y 0 divergencias. CLEANUP: evidencia anterior vigente de `engine`, 52 observaciones y 0 divergencias, sin repetición en esta revisión. Se conservaron esperados, estados y versiones de los ocho casos corregidos; `validate` (187), `lock --check` y `export --check` pasan | AOT de SCOPE: código 1, rechazo `nativeTasksUnsupported` y respuesta sin cinta; el corredor aborta con `SEE-RECORDING` antes de guardar resultados. El `aot.json` anterior es de MEMORY y no certifica SCOPE. Falta el soporte nativo de `PG-4.12.04`; R5 y R6 siguen `pendiente` con resolución declarada en `PG-4.07`. La ruta de rechazo de `PG-4.12.07` no equivale a conformidad. Por §10.1 no se continúa con CLEANUP ni diferenciales. `.07`, PG-4.02 y PG-4 permanecen abiertos (`PHASE-GREEN`, `PHASE-STOP`) |
| `PG-4.03` | Implementación y ligera completas; pesada parcial | `.01`–`.06`; reglas `R11`–`R16`, casos bilingües `C23`–`C31`, agregación de errores, tipos exactos, obligaciones del vínculo, cancelación y limpiezas de ámbitos anidados; tests filtrados y verificadores de esta iteración en verde. `.07` en `engine`: 132 observaciones, 0 divergencias | `.07` en `aot` aborta con `SEE-RECORDING` por `nativeTasksUnsupported`; falta `.12.04`. No se declara cerrada la casilla ni PG-4 |
| `PG-4.04` | Implementación y ligera completas; pesada de `engine` en verde; AOT no ofrece ejecución de tareas | `.01`–`.06`; `engine`: CHANNEL 84, LIB.MODEL 20 y TRACE.EVENTS 69 observaciones, 0 divergencias; AOT: CHANNEL 84 observaciones, 56 divergencias | `.07` se ejecutó en ambos sujetos. AOT rechaza los programas con `nativeTasksUnsupported`; queda pendiente hasta construir `PG-4.12.04` |
| `PG-4.05` | Implementación y ligera completas; pesada de `engine` en verde; AOT no ofrece ejecución de tareas | `.01`–`.06`; `engine`: AGENDA 52 y EXEC.MODEL 60 observaciones, 0 divergencias; AOT: AGENDA 52 observaciones, 52 divergencias | `.07` se ejecutó; el diferencial AOT queda pendiente de `PG-4.12.04` |
| `PG-4.06` | Implementación, ligera y pesada de `engine` completas; AOT parcial por soporte no construido | `.01`–`.06`; `engine`: ISOLATION 100 y LIB.MODEL 20 observaciones, 0 divergencias; AOT: ISOLATION 100 observaciones, 8 divergencias | `.07` se ejecutó; AOT todavía diverge en C1 y C19, que lanzan tareas. Las reglas AOT correspondientes siguen `pendiente` |
| `PG-4.07` | Implementación, ligera y pesada de `engine` completas; AOT parcial por soporte no construido | `.01`–`.06`; `engine`: AGENDA 52, IR.INSTRUCTIONS 14, IR.WELL-FORMEDNESS 17 e IR.OBSERVATION-POINTS 12, 0 divergencias; AOT pasa IR.INSTRUCTIONS y IR.OBSERVATION-POINTS, pero AGENDA tiene 52 divergencias | `.07` se ejecutó; la agenda y los eventos de tarea AOT dependen de `PG-4.12.04` |
| `PG-4.08` | Implementación, ligera y pesada de `engine` completas; AOT parcial por soporte no construido | `.01`–`.06`; `engine`: MEMORY 16, LIMITS 117, STATE.SNAPSHOT 24 e INCREMENTAL 4, 0 divergencias; AOT: MEMORY 16 (16 divergencias), LIMITS 117 (40 divergencias); RT.ABI P1/P2 no supera `SEE-REGRESSION` | `.07` se ejecutó; las continuaciones, raíces de tareas y sus propiedades AOT requieren `PG-4.12.04` |
| `PG-4.09` | Implementación y ligera completas; pesada de `engine` en verde | `.01`–`.06`; `ENG.LIMITS`: engine 117 observaciones, 0 divergencias; AOT 117 observaciones, 40 divergencias | `.07` se ejecutó; las divergencias AOT se deben a tareas no implementadas y quedan pendientes de `PG-4.12.04` |
| `PG-4.10` | Implementación y ligera completas; campaña VM completa; conformidad AOT parcial por soporte no construido | `.01`–`.06`; E-PG-06: 10 000 semillas, 1 250 por familia, 0 divergencias; engine: EFFECT.TAPE 56, EFFECT-ORDER 36, EXEC.MODEL 60, API.EXECUTE 28 y HOST.INTERFACE 32, todo en verde | `.07` se ejecutó. Los contratos AOT de cinta, orden y anfitrión abortan o divergen con `nativeTasksUnsupported`; falta `PG-4.12.04` |
| `PG-4.11` | Implementación, ligera y pesada completas | `.01`–`.07`; engine: TRACE.EVENTS 69, STATE.QUERY 14, PROGRAM.VIEW 26 y WIRE-FORMAT 6, 0 divergencias; service 11, CLI 1 y app: PROGRAM.VIEW 27, WIRE-FORMAT 7 y TRACE.EVENTS 69, todos en verde; bridge (20), arquitectura/adaptadores (37), clases de evento (5), `dart analyze` y `check_limits.dart` pasan | La evidencia nueva está en `pg-4-04-12-continued-2026-10-28/`; las evidencias app obsoletas se guardaron como `pre-refresh-*` antes de regenerar |
| `PG-4.12` | Campaña E-PG-06 y medición PERF ejecutadas; AOT y presupuesto PERF pendientes | `.01`–`.03`, `.05`, `.06`; 10 000 semillas VM, 0 divergencias, artefacto `pg-tasks-final-tree-0-10000-2026-10-28/tasks-0-10000.json`; PERF final: 20 pares, 30 muestras por carga, 1,2192×, IC 95 % `[1,2119; 1,2243]` frente al máximo 1,02× | `.04` aún no construye tareas AOT. `.07` se ejecutó; el rechazo nativo mantiene la conformidad AOT pendiente y PERF no alcanza su umbral. No se declara la fase verde |
| Espacio liberado (§13) | Ejecutado en la preparación previa | La limpieza previa elevó el espacio libre de 2,8 a 33 GiB y dejó 32 GiB tras esas verificaciones. En la continuación actual no se limpió nada; quedaron 17 GiB al cierre | Sin tocar datos personales ni evidencias |

Registro del primer intento parcial de PG-4.04 a PG-4.12 (2026-10-28), anterior a la instrucción explícita de continuar:

- Rama `feature/agregar-ruta-de-especificacion`, revisión base `021094b04b96bbb71b86a15b6c285dd95512d1ea`. Rust `1.99.0`, Darwin `27.0.0 arm64`; 39 GiB libres al inicio de la campaña y 38 GiB al terminar. No se limpió nada.
- `PG-4.04.07`: `cargo run --locked -p see_cli --bin see -- conform --subject engine --only LANG.TASK.CHANNEL` terminó con código 0, 84 observaciones y 0 divergencias. La ejecución AOT del mismo contrato terminó con código 0, 84 observaciones y 56 divergencias. `see differential` terminó con código 1 y 56 diferencias no resueltas; todos los casos de ejecución afectados reciben `nativeTasksUnsupported`. La petición aislada de `LANG.TASK.CHANNEL#C13` al adaptador `pseudo --see-adapter aot` reprodujo ese diagnóstico, con terminación `failed/analysisFailed` y sin salida. No se modificaron caso, esperado ni código.
- Se conserva la evidencia anterior y la nueva bajo `packages/pseudolearn_spec/results/pg-4-04-12-heavy-2026-10-28/`; el resumen de diferencial tiene SHA-256 `fe48a0fce4ae6afa8e0578396ca06c045c4eb6272154a930dc37258aa869253a`.
- Como indica §10.1, la secuencia de conformidad contractual se detuvo ante el primer código distinto de cero. No se ejecutaron los contratos posteriores ni la regresión `PERF.SUITE.CORE`.
- En la vía de decisión prevista por `PG-4.12.07`, `cargo run --locked --release -p pseudolearn_bench_worker -- pg-tasks results/pg-tasks-0-10000-2026-10-28 0 10000` terminó con código 0: 10 000 semillas, 1 250 por familia y 0 divergencias VM. El resumen está en `packages/pseudolearn_engine/results/pg-tasks-0-10000-2026-10-28/tasks-0-10000.json`, SHA-256 `d3364c0dc1cb2faa3af9d103a1db9be289775029554bcca718c681675993b724`. Esta implementación de la campaña no compara AOT ni mide las métricas candidatas, por lo que PG-4.10 y PG-4.12 siguen abiertas.
- La app pasó `RUSTUP_TOOLCHAIN=1.99.0 FRB_DART_LOAD_EXTERNAL_LIBRARY_NATIVE_LIB_DIR="$PWD/native/target/debug" bash tool/test_bridge.sh` (20 tests), arquitectura más pruebas de anfitrión simulado y diagramas (37 tests), `rust_event_classes_test.dart` (5 tests), `dart analyze` y `dart run tool/check_limits.dart`. Se actualizaron fixtures obsoletos del arnés: declaraciones mutables inicializadas, un caso de arreglo multidimensional usado mediante `m[0,0]`, y lectura del carácter para comprobar su formato. El caso simple conserva `a[0]`, que el corpus define como índice válido. El script de bridge compiló las bibliotecas nativas debug y release.
- No hubo cambios en corpus, motor ni README. Se modificó el fixture de `apps/pseudolearn_app/tool/native_bridge_adapters_test.dart` y este registro; no se creó commit ni se hizo push.

Registro de continuación completa autorizada de PG-4.04 a PG-4.12 (2026-10-28):

- La persona pidió continuar todas las tareas pesadas en una sola iteración pese a fallos de conformidad. Se ejecutaron las selecciones restantes en vez de detenerse tras el primer diferencial; se conservaron los fallos y no se cambiaron esperados para producir un resultado verde. Rama `feature/agregar-ruta-de-especificacion`, sin commit ni push.
- Barrido `engine`: 26 contratos con salida 0, 1 151 observaciones y 0 divergencias. `RT.ABI` no tenía especificaciones seleccionadas y devolvió código 1 sin salida. Evidencia y salidas en `packages/pseudolearn_spec/results/pg-4-04-12-continued-2026-10-28/summary.json`.
- Barrido AOT: 15 IDs; pasan `LANG.CAPABILITY.PURITY` (88), `IR.INSTRUCTIONS` (14) e `IR.OBSERVATION-POINTS` (12); divergen `ENG.TASK.MEMORY` (16), `LANG.TASK.ISOLATION` (8), `LANG.TASK.CHANNEL` (56), `ENG.TASK.AGENDA` (52), `ENG.LIMITS` (40) y `LANG.CONTROL.CLEANUP` (4); seis selecciones abortan o no producen evidencia válida por `nativeTasksUnsupported` o `SEE-REGRESSION`, incluido `RT.ABI`. Resumen: `aot-summary.json` en el mismo directorio. El soporte requerido sigue siendo `PG-4.12.04`.
- Barrido de app y contratos no VM: `TOOL.SERVICE.CATALOG` 11 observaciones, 0 divergencias; CLI `API.WIRE-FORMAT` 1/0; app `API.PROGRAM.VIEW` 27/0, `API.WIRE-FORMAT` 7/0 y `ENG.TRACE.EVENTS` 69/0. `PG-4.11.07` queda completada: bridge 20 tests, arquitectura/adaptadores 37, clases de evento 5, `dart analyze` y `dart run tool/check_limits.dart` pasan. Las evidencias nuevas están en `app-summary.json`; las evidencias app anteriores con hash obsoleto se preservaron como `pre-refresh-*`.
- E-PG-06 se ejecutó sobre el árbol final: 10 000 semillas, 1 250 por familia, 0 divergencias en la campaña VM. Artefacto `packages/pseudolearn_engine/results/pg-tasks-final-tree-0-10000-2026-10-28/tasks-0-10000.json`, SHA-256 `d3364c0dc1cb2faa3af9d103a1db9be289775029554bcca718c681675993b724`. La parte comparativa AOT no puede completarse hasta implementar tareas nativas.
- Regresión `PERF.SUITE.CORE`: 20 pares de procesos, 30 muestras por carga, 10 cargas; media geométrica 1,219196×, IC 95 % `[1,211882; 1,224342]`, por encima del presupuesto 1,02×. Manifiesto `packages/pseudolearn_engine/results/perf-pg4-core-final-tree-pg4-2026-10-28/manifest.json`, SHA-256 `fc9a4e128255b97a504fedd4303416bcf75a9141024a06b7999f865d1a821667`; el binario candidato medido tiene SHA-256 `4b56eab5fce0f037762ca8a149bf21f0468eb74ab4f8276925f6d5503cdf5db9`. La medición terminó; el presupuesto no pasa.
- Verificaciones: `cargo test --locked --workspace` (0 fallos; 1 test de estrés ignorado), `cargo clippy --locked --workspace --all-targets -- -D warnings`, `rust-checks all .`, `rust-checks toolchain ../..`, `cargo deny check`, `see validate` (187), `see lock --check` y `see export --check` pasan. `cargo xtask verify` no pasa en su primer control: `cargo fmt --all --check` encuentra diferencias de formato fuera de los `.rs` tocados; el `rustfmt --check` dirigido a todos los `.rs` modificados pasa. Se corrigió en `pseudolearn_bench_worker` la generación del programa de carga para que inicialice las declaraciones mutables requeridas por la gramática; sus tests pasan.
- No se limpió espacio durante esta continuación; `df -h /` muestra 17 GiB disponibles al cierre. No se borraron datos ni evidencias. La fase no queda verde: AOT depende del soporte aún no construido de `PG-4.12.04`, y el presupuesto PERF medido no cumple. No se hizo commit ni push.

Registro de la iteración solicitada de PG-4.02; la fase PG-4 sigue abierta: rama `feature/agregar-ruta-de-especificacion`,
sin commit ni push · El cambio añade RI `O94`–`O100`, ejecución VM de tareas con unión de ámbitos y protección de
raíces suspendidas ante GC; el corpus valida y las pruebas ligeras pasan · Verificadores: `see validate` (183),
`lock --check`, `see export --check`, `rust-checks all .`, Clippy de siete crates, `rustfmt --check` dirigido y
`git diff --check` · Pendientes de `.02`: ejecución de cancelación por fallo con `Diferir` y cancelación durante
espera de canal; AOT y conformidad pesada (`.07`) siguen en sus tareas futuras · `PHASE-GREEN` no satisfecho para
cerrar PG-4.02 ni la fase PG-4 (`PHASE-STOP`).

Registro de ejecución de `PG-4.02.07` (2026-10-28): se corrigieron los programas de `LANG.TASK.SCOPE#C1`, `C8`,
`C9`, `C11`, `C13`, `C15`, `C16` y `C20`, conservando esperados, estados y versiones, y se reancló el contrato.
`engine` ejecutó `LANG.TASK.SCOPE` (132 observaciones) y `LANG.CONTROL.CLEANUP` (52), ambos con cero divergencias.
El primer comando AOT, `conform --subject aot --only LANG.TASK.SCOPE`, se detuvo con `SEE-RECORDING` y
`nativeTasksUnsupported`, comportamiento previsto por `PG-4.12.04`; por §10.1 no se ejecutaron
`LANG.CONTROL.CLEANUP` en AOT ni `differential`. `see validate` validó 187 especificaciones; `lock --check`,
`export --check` y `git diff --check` pasan. El disco tenía 40 GiB libres (targets: 326 MiB y 338 MiB); no hizo
falta liberar espacio. Rama única, sin commit ni push. La casilla `.07` queda abierta y PG-4.02 no se declara
cerrada (`PHASE-GREEN`, `PHASE-STOP`).

Registro de revisión y reproducción de `PG-4.02.07` (2026-10-28), sobre `d2a96758`:

- Preparación: rama `feature/agregar-ruta-de-especificacion`, árbol inicialmente limpio. Se preservaron siete
  archivos de resultados anteriores y sus hashes SHA-256 en
  `packages/pseudolearn_spec/results/pg-4-02-07-recheck-2026-10-28/` (`before-*`, `provenance.json`).
- Espacio liberado (§13): 38 GiB iniciales; nivel 1, incrementales de Cargo (motor, especificaciones y CLI),
  `xcrun simctl delete unavailable` y `npm cache clean --force`; 39 GiB tras la primera limpieza. Nivel 2,
  `cargo clean` del motor (260,3 MiB) y de la CLI (1,3 GiB); 40 GiB antes de la selección pesada
  (`df -k /`: 42 000 000 KiB disponibles, por encima de 41 943 040 KiB). `brew cleanup -n -s` estimó solo
  19,6 MB y no se aplicó; tampoco se tocó el almacén pnpm compartible ni las cachés de IntelliJ, que estaba
  abierto. No se borraron evidencias, fuentes versionadas ni datos personales.
- Antes de la compilación de la CLI para AOT, el espacio había descendido a 41 600 000 KiB. Se retiró
  únicamente `stable` (463 MiB, también era la toolchain predeterminada global), como permite el nivel 2;
  se conserva `1.99.0`, fijada y comprobada en el motor y la CLI. El espacio volvió a 42 000 000 KiB,
  suficiente para iniciar esa compilación. No se cambió la configuración global de toolchain predeterminada.
- Auditoría previa: `validate` (187), `lock --check`, `export --check` y `git diff --check` pasan. Los hashes
  de las dos evidencias conservadas de `engine` coinciden con los anclajes vigentes: SCOPE, 132 observaciones,
  y CLEANUP, 52, todas `cumple`; son ejecuciones anteriores, no repeticiones de esta revisión.
- Revisión crítica del corpus: 64 solicitudes JSONL de análisis compararon los ocho casos de `HEAD^` con
  `d2a96758`, en ambos perfiles y rigores. Antes se reproducen el nombre reservado de C1, el constructor
  inválido de C8, errores adicionales de inmutabilidad en C9/C11, descarte de un valor no Resultado en C13
  y propagaciones incompatibles en C15/C16/C20. Después, C8/C9/C11/C13 conservan únicamente los errores
  previstos; C1/C15/C16/C20 carecen de errores estáticos. Los ocho esperados permanecen idénticos.
  C15 registra las limpiezas antes de la espera; C16 sincroniza el fallo por canal para que la nieta alcance
  su limpieza antes de ser cancelada: R6 exige nieta antes que madre y orden inverso de limpiezas, de acuerdo
  con la cola FIFO de `ENG.TASK.AGENDA`. C20 conserva la cancelación inmediata sin limpiezas de R9; su
  evidencia anterior contiene cinta `incomplete`. No se encontraron errores nuevos que justifiquen editar el corpus.
- Selección pesada, primer paso: `cargo run --locked -p see_cli --bin see -- conform --subject engine
  --only LANG.TASK.SCOPE` termina con código 0, 132 observaciones y 0 divergencias. Se conserva la nueva
  evidencia como `engine-scope-engine.json`, su matriz y los registros `engine-scope.*` en el directorio anterior.
- Preparación AOT: `cargo build --locked --bin pseudo` desde la CLI termina con código 0; sus registros
  `aot-build.*` permiten separar la compilación del tiempo límite de inicio del adaptador.
- Segundo paso: `cargo run --locked -p see_cli --bin see -- conform --subject aot --only LANG.TASK.SCOPE`
  termina con código 1 y `SEE-RECORDING`: respuesta nativa `failed/analysisFailed`, diagnóstico
  `nativeTasksUnsupported`, sin cinta de efectos. Se conservan stdout, stderr y código de salida en
  `aot-scope.*`. Se aplica la parada de §10.1: no se repite CLEANUP en ningún sujeto ni se ejecuta diferencial.
  `.07` permanece abierta y PG-4 no se declara cerrada.
- Reproducción aislada autorizada: `--only` compara solo IDs de especificación, por lo que la persona autorizó
  JSONL para aislar casos sin ampliar la CLI. `pseudo --see-adapter aot` reproduce C1 y C15 (`es`, `strict`);
  C15 es el primer caso del contrato que solicita `grabar_y_reproducir`. Ambos devuelven
  `failed/analysisFailed`, `nativeTasksUnsupported` y ninguna cinta. Una tercera petición auxiliar de C15,
  con reproducción desactivada solo en la petición, conserva el mismo rechazo: quitar esa comprobación
  no aportaría conformidad. El proceso del adaptador termina con código 0 por cierre protocolario, que no
  significa ejecución exitosa de los programas. Peticiones, respuestas y resumen: `aot-isolated.*`.
- Causa verificada: la API rechaza la RI con operaciones de tarea antes de generar el objeto nativo; la
  respuesta de rechazo no incluye cinta. El corredor compara la respuesta y después exige la cinta de C15;
  `recording_replay` eleva `SEE-RECORDING`, por lo que la conformidad aborta antes de guardar resultados.
  `aot.json`, su matriz y el diferencial anteriores permanecen intactos; el primero corresponde a
  `ENG.TASK.MEMORY`, no a SCOPE. `verification.json` comprueba las siete copias, los hashes vigentes,
  los esperados conservados y que no se reemplazó el diferencial.
- Bloqueo y decisión pendiente: el rechazo documentado en el README del motor y permitido por `PG-4.12.07`
  protege contra anunciar tareas nativas inexistentes, pero no satisface SCOPE ni el requisito de ambos sujetos
  de esta casilla. Faltan continuaciones reanudables, agenda, canales y efectos concurrentes nativos de
  `PG-4.12.04`; R5/R6 siguen pendientes con resolución declarada en `PG-4.07`. Para cerrar `.07` hay que
  autorizar y completar esa dependencia, o aprobar explícitamente otro alcance de la casilla. No se cambian
  sujetos, esperados, versiones ni vínculos para convertir el rechazo o un resultado no aplicable en cumplimiento.
- Cierre de la revisión: el único archivo versionado modificado es este plan; las evidencias nuevas quedan
  en el directorio local ignorado. Sin cambios del corpus ni del motor, sin commit ni push, sin cierre de PG-4.
  El disco queda en 39 GiB tras recompilar. La revisión final del registro, de las evidencias y
  `git diff --check` pasa; `PHASE-GREEN` no permite cerrar `.07`.


Registro de la iteración conjunta autorizada de PG-4.03 a PG-4.05:

- Implementados y marcados `.01`–`.06` de los tres puntos; `.07` permanece sin ejecutar por exclusión explícita
  de la persona. Se mantiene la rama `feature/agregar-ruta-de-especificacion`, sin commit ni push; la fase PG-4
  sigue abierta. La fila anterior de PG-4.02 conserva el estado histórico de su iteración, no declara su cierre.
- Verificación ligera: 71 tests dirigidos pasan: API (17), runtime (28), ABI (1), semantic (17), syntax (2),
  IR (2), lowering (2) y bytecode (2). Los filtros de runtime incluyen agenda, fallos, canales, bloqueo y cola;
  los de semantic incluyen ámbitos, manejadores, errores, canales y selección. Se ejecutaron los cuatro archivos
  `task_*_tests` nuevos de API y `task_scopes` de lowering. No se ejecutó ninguna batería completa del workspace.
- `rust-checks all packages/pseudolearn_engine`, Clippy `--all-targets -- -D warnings` de los nueve crates tocados,
  `rustfmt --check` dirigido y `git diff --check` pasan. Clippy de API activa su feature `native` porque sus
  tests nativos importan símbolos condicionados por ella; esto compila los destinos, sin ejecutar AOT.
- `see validate` valida 185 especificaciones; `lock --check` y `export --check` pasan. Se reanclaron los doce
  contratos editados conservando estados y versiones; vocabulario, sintaxis y despacho se regeneraron desde
  sus generadores. Las referencias de conformidad quedan pendientes de ejecución pesada.
- Espacio: 28 GiB al iniciar esta iteración y 25 GiB al terminar las compilaciones dirigidas; sin limpieza,
  sin borrar evidencias ni datos personales.

Decisiones de implementación de esta iteración:

1. Los nombres de plan `F1`–`F6`, `C1`–`C8` y `A7` se registran en el corpus como reglas estables
   `LANG.TASK.SCOPE#R11`–`R16`, `LANG.TASK.CHANNEL#R1`–`R8` y `ENG.TASK.AGENDA#R7`.
2. El primer fallo se decide por terminación lógica, aunque su identidad sea mayor. Con una única tarea
   ejecutándose y cancelación antes de reanudar otra, dos retornos inmediatos no producen dos errores terminales:
   la segunda hija cuenta como cancelada. Se precisó `.03.02` para comprobar asociados sobre eventos terminales
   puros y la cancelación alcanzable en VM, sin inventar ejecución simultánea. `Asociados` conserva los errores
   ya terminales antes de aplicar cancelación; el caso de fallo único prueba la colección vacía.
3. Se usa un comando RI tipado `task.channel` para crear, enviar, recibir, cerrar y elegir, más `task.value_load`
   para transportar agregados. `task.outcome`, `task.scope_result`, `task.cancel_point` y `task.scope_boundary`
   expresan resultados y continuaciones de limpieza. Son `O101`–`O106`; las firmas y trampas viven en el corpus.
4. Las entradas internas de lanzamiento son envoltorios con celdas propias de resultado. Las limpiezas conservan
   su continuación incluso al llamar subprogramas; un fallo exterior cancela también los ámbitos anidados.
5. Los canales usan capacidad positiva, máximo predeterminado 65536, reserva contable y colas FIFO. Selección
   evalúa los canales una vez, prefiere la primera rama textual lista y retira sus registros hermanos al despertar.
6. La VM distingue tareas ejecutables, efectos pendientes vigentes y bloqueo. Un efecto abandonado no mantiene
   artificialmente `awaiting_effect`; el diagnóstico de bloqueo ordena ubicaciones por identidad de tarea.
7. No se ejecutaron conformidad, diferencial, GC forzado, campañas, pruebas AOT ni compilaciones release.
   La serialización histórica completa, la cinta concurrente y la ejecución nativa siguen en PG-4.08, PG-4.10
   y PG-4.12 respectivamente. Los README afectados documentan estas fronteras.

Registro de la iteración que cierra PG-4.06 a PG-4.08 (sin `.07` completos):

- Se partió del trabajo sin cerrar de una iteración previa; ninguna casilla estaba marcada. Se marcan `.01`–`.06` de los tres
  puntos y `.07` permanece abierto por lo indicado arriba. Rama `feature/agregar-ruta-de-especificacion`, sin commit ni push.
- Defectos de la iteración previa corregidos: etiquetas de forma `TASK`/`CONTINUATION` iguales a las de bytes y capacidades
  (rompía `Bytes`, archivos y el recorrido del GC); `taskScopeFailureUnused` con argumento `type`; dos tarjetas de ayuda
  con texto idéntico; función genérica suspendible registrada como no suspendible; programas de casos con identificadores
  en inglés mal traducidos; recuento de operaciones de RI y de builtins en tests; ayudante de test que no reconocía
  `func suspendible`; `ENG.LIMITS` y `RT.ABI` sin las reglas de `.08.01`.
- Efecto de marcar la raíz como suspendible: las aristas de bucle de `Main` llevan `task.yield_check`; el sujeto `aot` lo baja
  como operación vacía. El resto de operaciones de tarea figura en `UNSUPPORTED_OPERATIONS` del generador nativo.
- Casos ajenos a estos puntos que se corrigieron porque bloqueaban la selección pesada (`SPEC-INDEPENDENT-ORACLE`, a revisar por la persona):
  `LANG.TASK.SCOPE#C19` y `LANG.CONTROL.CLEANUP#C13` (el esperado `failed` partía de un ámbito sin vínculo, que `R15` rechaza;
  ahora llevan vínculo y `Wait` devuelve `Resultado<Entero, Cadena>`; `C19` espera `completed`), el identificador `failure` de `C13`
  (palabra reservada en inglés), `IR.WELL-FORMEDNESS#C13`/`C14` (sintaxis de RI y tramos), y el texto inglés con `Algoritmo`/`FinAlgoritmo`
  en LIB.MODEL, CHANNEL, SCOPE, EXEC.MODEL, TRACE.EVENTS, DIAG.MESSAGES y AGENDA. Se reanclaron 18 contratos (`lock --check` y `export` pasan).
- Verificación: `cargo test --workspace --no-fail-fast` solo falla `workloads_tests::generates_all_configurations…` (también falla en `HEAD`);
  Clippy `--all-targets -D warnings` y `rust-checks all .` pasan; `cargo fmt --all --check` ya falla en `HEAD` por 52 archivos ajenos
  (solo se formatearon los archivos tocados). `see validate` valida 187.
- Pendientes ajenos detectados y no tocados: `LANG.TASK.SCOPE` (≈34 observaciones de `engine` divergentes), `LANG.TASK.SUSPENSION` (casos con
  `Propagar` en `Main`), `API.STATE.QUERY#C8`, `LANG.MODULE.IMPORT#C10`, `LANG.CAPABILITY.PURITY#C23`, `LANG.LEXICAL.KEYWORD#C5`; la propiedad
  `ENG.INPUT#P1` y la campaña completa de propiedades se detienen en un programa del corpus con errores de análisis. `aot` necesita una capacidad
  `tasks` no anunciada para que casos, propiedades y `differential` omitan los programas de tareas (decisión de `PG-4.12`).
- Espacio: 12–14 GiB libres durante la iteración (por debajo de los 25 GiB de §13); no se limpió nada.

Registro de la iteración conjunta de PG-4.02 (pendientes), PG-4.09 a PG-4.12 (sin `.07`):

- Rama `feature/agregar-ruta-de-especificacion`, sin commit ni push. Los `.07` de PG-4.09 a PG-4.12 se omiten por
  instrucción de la persona; los de PG-4.01 a PG-4.08 siguen abiertos porque el sujeto `aot` no ofrece tareas.
- Barrido de conformidad del sujeto `engine` (una orden `--only` por contrato, sin `aot` ni `differential`):
  0 divergencias en `LANG.TASK.CHANNEL`, `LANG.CONTROL.CLEANUP`, `ENG.TASK.AGENDA`, `ENG.TASK.MEMORY`,
  `LANG.TASK.ISOLATION`, `LIB.MODEL`, `ENG.EXEC.MODEL`, `ENG.LIMITS`, `ENG.EFFECT.TAPE`,
  `ENG.EXEC.EFFECT-ORDER`, `RT.HOST.INTERFACE`, `ENG.TRACE.EVENTS`, `API.PROGRAM.VIEW`, `API.WIRE-FORMAT`,
  `API.EXECUTE` y `TOOL.SERVICE.CATALOG`. Divergencias previas ajenas a esta iteración: `LANG.TASK.SCOPE`
  (30 observaciones, casos `C1`, `C8`, `C9`, `C11`, `C13`, `C15`, `C16`, `C20` con errores de análisis en sus
  programas), `LANG.TASK.SUSPENSION` (`Propagar` en la raíz), `LANG.CAPABILITY.PURITY#C23` y `API.STATE.QUERY#C8`.
- La evidencia de propiedades del motor quedó obsoleta por las ediciones del corpus; para poder ejecutar `conform`
  se apartó temporalmente (copias `properties-engine.pre-pg4-iteration.json` y `engine.pre-pg4-iteration.json`
  en `results/`) y se restauró; `engine.json` contiene la última ejecución.
- Verificación ligera: `see validate` (187), `lock --check`, `export --check`; `rust-checks all .` y Clippy
  `-D warnings` de motor, especificaciones y CLI; `dart analyze` y `check_limits.dart`; tests de runtime (41 de
  biblioteca y las pruebas de cinta), VM, línea temporal, API (40 archivos de prueba), CLI, trabajador y validador.
- Espacio: 13 GiB al empezar; limpieza de nivel 1 elevó a 18 GiB; 14 GiB al terminar (por debajo de los 25 GiB de §13).

Decisiones de implementación de esta iteración:

1. **Tareas vivas.** Se cuentan las hijas no terminadas; la raíz no cuenta. El límite se comprueba antes de asignar
   identidad. Capacidad máxima de canal: `channel_capacity`; el diagnóstico `taskLimitExceeded` lleva `limit`.
2. **Cinta.** `effect_seq` numera en orden de petición, reservado cuando la API observa los pendientes; la cinta
   se escribe en orden de entrega y `delivery_seq` es la posición en la cinta, omitida si coincide. La reproducción
   deriva el orden de entrega de la cinta. `task_id` real; `abandoned` se sella al terminar. El anfitrión desprendido
   no reordena a mitad de espera: el orden se declara antes con `orden_entrega`.
3. **Eventos.** Solo con el gemelo sondeado; la línea es la de la instrucción emisora; `task_ready` tiene causas
   `spawn`, `completion`, `channel`, `yield` y `resume`; `effect_delivered.delivery_seq` es un ordinal de entregas
   de capacidad. Una instrucción puede producir varios eventos, así que el estado y la reconstrucción de historia
   corresponden al instante posterior a la instrucción que contiene el evento pedido.
4. **Corpus.** Se añaden `channelClose` y `snapshotBuiltin` al vocabulario porque el validador de cobertura de
   ayuda exige una ficha por identidad; el esquema de casos admite `tareas`, `capacidad_canal`, `orden_entrega` y
   `task_id`/`delivery_seq` en los efectos esperados. La orden de «orden alterado ⇒ `replay_divergence`» no es
   expresable como caso del corpus (alterar el orden rompe el encadenado de hashes); se prueba en la API con una
   cinta reordenada y vuelta a encadenar. Los vínculos de la app para las reglas nuevas quedan `pendiente` hasta
   la verificación pesada.
5. **Nativo.** `.12.04` no se implementa: el sujeto `aot` rechaza programas con tareas con `nativeTasksUnsupported`.
6. **App.** No se amplía `AstConstruct`; los textos de cabecera de los diagramas salen del propio nodo.
7. **Generador de agendas.** Cada semilla produce un programa propio (parámetros en el texto) en lugar de ocho
   plantillas con `Argumentos`, porque no hay ejecución nativa que compilar por familia.

Registro de ejecución de `PG-4.03.07` (2026-10-28):

- Preparación: rama `feature/agregar-ruta-de-especificacion`, árbol limpio, 39 GiB libres al inicio. Se preservaron
  `engine.json`, `aot.json` y sus matrices con copias y hashes bajo
  `packages/pseudolearn_spec/results/pg-4-03-07-2026-10-28/`; no se liberó espacio porque no hizo falta.
- `cargo run --locked -p see_cli --bin see -- conform --subject engine --only LANG.TASK.SCOPE`: código 0, 132
  observaciones y 0 divergencias. Evidencia y matriz guardadas en el directorio anterior. Los archivos completos
  `engine.json` y `matrix-engine.json` se restauraron y sus hashes coinciden con las copias previas.
- `cargo build --locked --bin pseudo`: código 0. `cargo run --locked -p see_cli --bin see -- conform --subject aot
  --only LANG.TASK.SCOPE`: código 1, `SEE-RECORDING`; los casos terminan `failed/analysisFailed` con
  `nativeTasksUnsupported` y el corredor no recibe cinta. El adaptador AOT reprodujo tres solicitudes aisladas:
  C1 y C15 con y sin grabación; las tres responden el mismo diagnóstico y no producen eventos ni cinta.
- La selección se detuvo en el primer error como exige §10.1; no se ejecutaron `differential` ni otros contratos.
  `aot.json` y `matrix-aot.json` conservaron sus hashes previos. La causa es la ausencia del soporte nativo de
  `.12.04`, no una divergencia de los casos de fallo de tarea; no se alteraron corpus, esperados ni código.
- Queda `.07` abierta y PG-4 sin cerrar (`PHASE-GREEN`, `PHASE-STOP`). Sin commit ni push; 39 GiB libres al terminar.

---

## 12. Protocolo operativo para la IA ejecutora

Reglas que no admiten interpretación:

1. **No empezar sin autorización.** Si el mensaje de la persona no autoriza explícitamente una iteración de §10, la IA
   no escribe especificación ni código.
2. **Orden inamovible por tarea:** especificación → casos → tests → código → README → verificación ligera. No se
   escribe código de una regla cuyo caso no existe.
3. **Esperados derivados de la regla**, nunca copiados de la salida del motor (`SPEC-INDEPENDENT-ORACLE`).
4. **Identidades nuevas** del corpus: `estado: estable`, `version: 1.0.0`, sin campo `cambio`; `revisado_por` solo con
   el nombre que aporte la persona en `P1`. Identidades existentes: edición oficial del texto, misma versión y estado,
   y reanclaje autorizado (`SPEC-VERSION-FREEZE`).
5. **Edición quirúrgica.** Nunca reescribir un archivo de especificación con `json.load`/`json.dump` ni otro
   recorrido de ida y vuelta; editar solo los bloques afectados. Nunca ejecutar `cargo fmt` sin `--check` sobre un
   miembro entero ni `dart format .`: formatear solo los archivos creados o tocados (`rustfmt --edition 2024
   <archivo>`).
6. **Cero comentarios, cero `TODO`**, código e identificadores en inglés, documentos en español. En Rust: sin
   `unwrap`, `expect`, `panic!`, `todo!`, `unimplemented!`, `unreachable!`, índices inseguros, aritmética implícita
   ni conversiones con pérdida; sin `#[allow]`, `#[expect]` ni comentarios de documentación.
7. **Límites:** antes de guardar un archivo, contar sus líneas; si pasaría de 300 (250 en la app) o una función de 40,
   dividir por responsabilidad. Nombres de al menos tres caracteres sin componentes prohibidos (§1.2.4).
8. **Nombres reservados internos:** la agenda se llama `task_agenda`; el canal del lenguaje, `task_channel`; nunca
   `scheduler` ni `channel` a secas (§1.2.2).
9. **Generados:** léxico, despacho de la VM y exportación del corpus se regeneran con su generador; nunca a mano.
10. **Conflictos:** ante cualquier contradicción entre fuentes o una semántica no cubierta por §3.4, detenerse,
    citar las dos fuentes y esperar a la persona.
11. **Pruebas:** solo las de §7.1.1 en las iteraciones 1–4. Una prueba ligera roja bloquea la iteración: se corrige
    antes del informe. Las pesadas solo en la iteración 5.
12. **Procesos largos:** compilaciones `release` y campañas en segundo plano con notificación; nunca bucles de sondeo
    que se autoconfirman ni confiar en el código de salida de una tubería con `| tail`.
13. **Registro:** cada iteración añade a §11 qué se ejecutó, su resultado, qué se omitió y por qué, y el espacio
    liberado.
14. **Git:** sin ramas nuevas, sin `git clean`, sin `--force`, sin atribución de IA en commits; commit con la skill
    `commit-message` y push ordinario solo en la iteración 5 tras `P5`.
15. **Parada:** al cerrar cada iteración, informe breve y parada (`PHASE-STOP`).

---

## 13. Protocolo de espacio en disco

**Obligatorio.** Se aplica antes de cada iteración, antes de toda compilación `release`, antes de la campaña de §7.3 y
siempre que una orden falle por falta de espacio. El objetivo es trabajar con **al menos 25 GiB libres** en las
iteraciones 1–4 y **al menos 40 GiB** antes de la iteración 5.

### 13.1 Medir

1. `df -h /` y anotar el espacio libre.
2. `du -sh` sobre los candidatos de §13.2 para saber cuánto libera cada uno.

### 13.2 Liberar, en este orden, hasta alcanzar el objetivo

**Nivel 1 — sin coste práctico (aplicar siempre que el libre sea < 25 GiB):**

| Qué | Cómo | Por qué es seguro |
|---|---|---|
| Directorios incrementales de Cargo | `rm -rf <miembro>/target/*/incremental` en todos los miembros Rust | Caché de compilación incremental; se regenera |
| Simuladores no disponibles | `xcrun simctl delete unavailable` | Solo borra runtimes de simulador sin uso |
| Datos derivados de Xcode | `rm -rf ~/Library/Developer/Xcode/DerivedData/*` | Caché de compilación de Xcode |
| Registros de usuario | `rm -rf ~/Library/Logs/*` | Registros; ninguno es evidencia del repositorio |
| Cachés de gestores de paquetes | `npm cache clean --force`; `pnpm store prune`; `brew cleanup -s` (si `brew` existe) | Se vuelven a descargar si hacen falta |
| Salida de compilación de la app | `rm -rf apps/pseudolearn_app/build` | Artefacto de Flutter ignorado por Git; se regenera |
| `target` de miembros que la iteración no compila | Por ejemplo `packages/pseudolearn_benchmarks/ceiling/target` y, en las iteraciones 1–4, `apps/pseudolearn_app/native/target` | Artefactos regenerables |

**Nivel 2 — coste de recompilación (aplicar si tras el nivel 1 sigue < 25 GiB, o < 40 GiB antes de la iteración 5):**

| Qué | Cómo |
|---|---|
| Artefactos del motor | `cargo clean` dentro de `packages/pseudolearn_engine` (19 GiB medidos) |
| Artefactos de la CLI y de las especificaciones | `cargo clean` dentro de `apps/pseudolearn_cli` y de `packages/pseudolearn_spec` |
| Cachés de aplicaciones de usuario | Vaciar el **contenido** de `~/Library/Caches/` (nunca la carpeta), con las aplicaciones cerradas |
| Toolchain Rust no fijada | `rustup toolchain uninstall stable` (todos los miembros fijan `1.99.0`; esa nunca se borra) |
| Cachés de Dart/Flutter | `flutter pub cache clean` solo si se va a tener red para `flutter pub get` |
| Caché de registro de Cargo | `rm -rf ~/.cargo/registry/cache` (se vuelve a descargar con red) |

**Consultar a la persona antes de borrar:** vaciar la papelera; `~/.cache/codex-runtimes` u otras herramientas ajenas
al repositorio; `~/Library/pnpm` si otros proyectos lo usan; cualquier carpeta cuyo dueño no sea evidente.

### 13.3 Prohibido borrar

Cualquier archivo versionado; `.git`; `packages/pseudolearn_spec/results/` y cualquier directorio ignorado con datos de
campañas o evidencias de fases (se citan en los resúmenes); la toolchain `1.99.0`; `~/.cargo/bin`, `~/.rustup` salvo
la toolchain no fijada; `~/.ssh`, llaveros, credenciales y documentos personales. Nunca usar `git clean -fdx` ni
borrados por patrón sobre la raíz del repositorio o sobre `~`.

### 13.4 Registrar

Cada limpieza se anota en §11 (fila «Espacio liberado»): espacio libre antes y después y qué niveles se aplicaron.
