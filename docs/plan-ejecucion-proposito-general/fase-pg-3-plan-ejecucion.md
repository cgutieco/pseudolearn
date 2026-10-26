# Fase PG-3 · Capacidades y cinta — plan de ejecución

## 0. Metadatos

- Fase: `PG-3` · Capacidades y cinta; requisitos `R-08`, `R-09` y `R-13`; capacidad principal `C-07` (con impacto en `C-06`, `C-10` y `C-16`).
- Decisiones rectoras: `ADR-02` (modelo de capacidades explícitas y cinta), `ADR-06` (determinismo por semilla y reloj grabado), `ADR-07` (errores tipados `Resultado<T, E>` + `Diferir`), `ADR-12` (archivo único sin `pseudolearn.toml`) y `ADR-13` (paridad semántica VM/AOT).
- Conflictos que cierra la fase: `CF-07` (frontera de confirmación lógica y estado externo incierto) y `CF-11` (formulación revisada por la persona sobre fallo controlado frente a caída o terminación del anfitrión).
- Riesgos principales: `K-06`, `K-07` y `K-13`. Experimentos: `E-PG-05` y la porción de archivos y cinta de `E-PG-09`.
- Fecha de preparación: `2026-10-26`, zona `America/Lima`.
- Revisión Git inicial: `5f6b4b91dcff4dc56945ab946f371251baafecda`; árbol limpio al comenzar.
- Rama única: `feature/agregar-ruta-de-especificacion` (`GIT-SINGLE-BRANCH`).
- Autorización documental: «crea el plan de ejecución para `4.5 PG-3 · Capacidades y cinta` detallado y acotado a la
  realidad del lenguaje de programación que estoy creando. Ya que las soluciones deben ser a medida y solo reutilizar
  métodos existente de otros lenguajes si encaja a la perfección con mi lenguaje de programación creado. Dejar en claro
  que las pruebas son acotadas y que la aplicación de PseudoLearn debe evolucionar con la sintaxis nueva del lenguaje.»
- Estado: plan detallado creado y revisado por la persona (`PG-3.C02` cumplido). No autoriza por sí mismo ejecutar las
  iteraciones de implementación; cada iteración de §10 requiere confirmación en mensaje nuevo (`PHASE-STOP`).
- Dependencia transversal: `PG-1.01`–`.13` y `PG-2.01`–`.17` están cumplidos (el cierre común `PG-1.C01`–`C13` sigue
  abierto en el plan general).

**Constancia de soluciones a medida.** Ninguna pieza de `PG-3` importa un sistema genérico de efectos algebraicos, un
*runtime* asíncrono externo (`tokio`) ni descriptores numéricos crudos del sistema operativo en los bancos de registros.
Todo el diseño se construye a medida sobre la arquitectura real de PseudoLearn: registros bicamerales (`u64` escalar /
`u32` referencia `GcRef`), mapas estáticos de raíces (`StackMap`), RI SSA verificada con columnas tipadas, bytecode
mellizo de 8 bytes (`Fast` y `Probed`), compilación de mundo cerrado (`pseudolearn_project`), paridad con Cranelift AOT
(`pseudolearn_aot_rt`) y oráculo normativo en `see/1`. Solo se reutiliza un mecanismo existente en otros ecosistemas
cuando encaja sin fricción con estas invariantes (por ejemplo, descriptores de directorio confinados con `cap-std` ya
adoptados en `PG-1.09`), dejando constancia explícita en §3.1 y en los `README.md` dueños de qué se toma y qué se
rechaza (`AGENTS.md` §3).

**Constancia de alcance de pruebas (pruebas acotadas).** En ninguna iteración ni en el cierre de `PG-3` se ejecutan por
defecto las pruebas de todo el monorepo (`cargo xtask verify`), ni `cargo test --workspace`, ni `see conform` sin
`--only`, ni `flutter test` global. Cada iteración ejecuta únicamente las pruebas acotadas a lo que desarrolló: los
casos del corpus de las especificaciones que tocó (`--only <ID>`), los tests espejo de los archivos que cambió, los
consumidores directos de una frontera que modificó y los verificadores estáticos rápidos de los miembros afectados. La
ampliación solo procede por los disparadores cerrados de §7.1, y cada iteración registra en §11 lo ejecutado y lo
omitido sin presentar una selección como suite completa.

**Constancia de evolución sincronizada de `pseudolearn_app`.** La aplicación Flutter (`apps/pseudolearn_app`) evoluciona
en la misma fase junto con toda sintaxis, tipo incorporado, operación intrínseca y estado de terminación nuevos del
lenguaje. Cada adición sintáctica o semántica de `PG-3` entrega sus fichas bilingües (`es`/`en`) en
`TOOL.SERVICE.CATALOG`, su proyección de solo lectura en `API.PROGRAM.VIEW` y la adaptación correspondiente en los
modelos de cable y sesión de `apps/pseudolearn_app/lib/engine/rust/` (`rust_wire_models.dart`,
`rust_execution_api.dart`, `rust_program_execution.dart`, `rust_program_view_builder.dart`,
`rust_construct_projection.dart`), permitiendo que el modo educativo de archivo único (`ADR-12`) analice, explique y
ejecute programas con capacidades simuladas o grabadas sin exigir `pseudolearn.toml`, mientras el rediseño visual de
diagramas y línea de tiempo multicarril permanece en `PG-A` y `PG-B`.

Documento transitorio de `docs/`. Desarrolla el [plan general](plan-ejecucion-proposito-general.md) y la
[hoja de ruta](../hoja-de-ruta-proposito-general.md). Ningún archivo fuera de `docs/` lo cita
(`DOC-NO-TRANSIENT-REFS`). Las decisiones aceptadas se trasladan a los `README.md` dueños y el comportamiento observable
al corpus, sin depender de este texto.

---

## 1. Punto de partida

1. **Lo que ya existe en el motor (`packages/pseudolearn_engine`):**
   - **Frontera de proyecto y confinamiento físico (`PG-1`):** `pseudolearn_project` resuelve manifiestos
     `pseudolearn.toml`, construye el grafo cerrado de paquetes, confina rutas físicas mediante `cap-std` en
     `workspace_fs.rs` y calcula la intersección de autoridad `requested ∩ granted` en `authority.rs`. Sin embargo,
     `API.PROJECT.MANIFEST#R4` mantiene todavía el vocabulario de permisos cerrado y vacío: `HostGrants` solo contiene
     `limits: BTreeMap<LimitName, u64>` y cualquier permiso solicitado en `[permisos]` / `[permissions]` produce
     `unknownPermission`.
   - **Tipos de valor, variantes, clausuras, interfaces y limpieza (`PG-2`):** Ya existen `Opcional<T>`,
     `Resultado<T, E>`, la propagación explícita `Propagar` / `Propagate`, la limpieza léxica `Diferir ... FinDiferir` /
     `Defer ... EndDefer` (`LANG.CONTROL.CLEANUP`, reducida en `pseudolearn_lowering` duplicando bloques de limpieza en
     cada arista de salida de alcance), los tipos función y clausuras con entorno inmutable en `GcRef`, las interfaces
     nominales con despacho estático/en tabla sellada y las colecciones `Vector<T>` y `Diccionario<K, V>`.
   - **Frontera actual con el anfitrión y razones de salida:** `RT.HOST.INTERFACE` limita el intercambio con el
     anfitrión a `source`, `stdin`, `stdout`, `clock`, `memory` y `random_seed`, prohibiendo abrir archivos, leer
     argumentos o consultar el reloj desde el programa. En `pseudolearn_vm/src/model.rs`, `RunExit` contempla
     `Completed`, `AwaitingInput`, `Cancelled`, `LimitReached`, `Service(ServiceReason)` y `Trap(VmTrap)`; aún no existe
     `AwaitingEffect`.
   - **Grabación y línea de tiempo actuales:** En `pseudolearn_api/src/recording.rs` y `recording_digest.rs`,
     `host_tape` es todavía un objeto mínimo con `seed` e `inputs: Vec<String>`, y `pseudolearn_timeline/src/replay.rs`
     solo reinyecta líneas de `Leer` (`options.inputs`) al reconstruir estados para `seek`.
   - **Estado actual de `apps/pseudolearn_app`:** En `lib/engine/rust/rust_wire_models.dart`, `RustTerminationKind`
     reconoce `running`, `completed`, `awaitingInput`, `cancelled`, `failed` y `limitReached`. El vocabulario del
     editor, las firmas de referencia (`rust_reference_vocabulary.dart`), la ayuda contextual (`rust_syntax_help_source.dart`)
     y la vista pública (`rust_program_view.dart`) se alimentan de los datos exportados por `pseudolearn_service` y
     `pseudolearn_api`.

2. **Lo que falta para cumplir `PG-3`:**
   - Especificar `CF-07` (frontera de confirmación lógica y estado externo incierto) y cerrar `CF-11` (fallo controlado
     del programa frente a caída o terminación del anfitrión).
   - Abrir el vocabulario cerrado de permisos de `PG-3` en `API.PROJECT.MANIFEST#R4` y materializar las capacidades de
     consola, argumentos, archivos relativos a una capacidad, reloj grabado y temporizadores lógicos con denegación por
     defecto.
   - Diseñar e implementar el esquema versionado de cinta `EffectTape` con identidad de ejecución ampliada, privacidad
     de secretos por referencia, presupuesto de bytes, tres modos separados (`LiveRecord`, `ReplayFromTape`,
     `HistorySeek`) y rechazo sin consultar al anfitrión ante cinta divergente, truncada o alterada.
   - Incorporar el contrato de suspensión `awaiting_effect`, el análisis estático de efectos transitivos en compilación
     (`Funcion` pura sin E/S oculta ni por llamada directa, ni por clausura, ni por interfaz), los tipos `Bytes` y
     `ErrorES` junto con `Resultado<T, ErrorES>` y limpieza determinista con `Diferir`, el anfitrión falso de
     conformidad, la paridad de cinta con Cranelift AOT y la evolución sincronizada de `apps/pseudolearn_app`.

---

## 2. Lectura realizada

- [x] `AGENTS.md` y `README.md` de la raíz.
- [x] `docs/hoja-de-ruta-proposito-general.md`, `docs/plan-ejecucion-proposito-general/plan-ejecucion-proposito-general.md`,
  `fase-pg-0-plan-ejecucion.md`, `fase-pg-1-plan-ejecucion.md` y `fase-pg-2-plan-ejecucion.md`.
- [x] `README.md` y `architecture.yaml` de `packages/pseudolearn_engine`, `packages/pseudolearn_spec`,
  `apps/pseudolearn_cli` y `apps/pseudolearn_app`.
- [x] Especificaciones vigentes del corpus: `RT.HOST.INTERFACE`, `RT.PROCESS`, `ENG.EXEC.MODEL`,
  `ENG.EXEC.EFFECT-ORDER`, `ENG.LIMITS`, `ENG.TRACE.EVENTS`, `API.EXECUTE`, `API.STATE.QUERY`, `API.ERRORS`,
  `API.PROJECT.MANIFEST`, `API.PROGRAM.VIEW`, `LANG.CONTROL.CLEANUP`, `IR.MODEL`, `LIB.MODEL` y `TOOL.SERVICE.CATALOG`.
- [x] Código fuente de las fronteras afectadas en `pseudolearn_api`, `pseudolearn_project`, `pseudolearn_timeline`,
  `pseudolearn_vm`, `pseudolearn_ir`, `pseudolearn_semantic`, `pseudolearn_aot_rt` y `apps/pseudolearn_app/lib/engine/rust/`.

---

## 3. Decisiones de diseño

### 3.1 Qué se diseña a medida y qué se toma o rechaza de otras referencias (`AGENTS.md` §3)

| Referencia / Paradigma evaluado | Qué se toma (encaje exacto con PseudoLearn) | Qué se rechaza y qué se construye a medida |
|---|---|---|
| Capacidades de sistema de archivos (`cap-std` / WASI) | Descriptores de directorio confinados en el anfitrión (`cap_std::fs::Dir`, ya integrado en `pseudolearn_project`) y principio de intersección `requested ∩ granted` sin amplificación | Se rechazan *file descriptors* enteros visibles al usuario, tablas POSIX globales y *preopens* ambientales. En PseudoLearn toda capacidad es un valor tipado opaco en el banco de referencias (`GcRef` hacia un `CapabilityToken` con ranura, generación y máscara de derechos) |
| Sistemas de efectos algebraicos (Koka, Eff) o coloreado `async` | Separación estática entre unidades puras (`Funcion` / `Function`) y unidades con efecto (`SubProceso` / `SubProcess`, `Algoritmo` / `Algorithm`) | Se rechazan el polimorfismo de filas de efectos, los manejadores reanudables arbitrarios y las anotaciones de efecto por firma. En PseudoLearn la pureza ya existe en la gramática (`Funcion` frente a `SubProceso`) y `pseudolearn_semantic` calcula el cierre transitivo en mundo cerrado sobre llamadas, clausuras e interfaces |
| Grabadores de ejecución de bajo nivel (`rr`, `Replay.io`) | Secuencia determinista de respuestas externas en orden de entrega y fallo inmediato ante divergencia de cinta | Se rechaza grabar llamadas al sistema operativo o páginas de memoria cruda. `EffectTape` graba en la frontera semántica de `RT.HOST.INTERFACE`, es portable entre VM y Cranelift AOT (`ADR-13`) y permite `seek` pedagógico sin tocar disco ni red |
| Destructores implícitos (`Drop` / finalizadores de GC) | Limpieza determinista en aristas de salida léxica, `Retornar` y `Propagar` mediante `Diferir ... FinDiferir` (`ADR-07`) | Se rechaza cerrar archivos o emitir efectos en el recolector de basura (`GcHeap`), porque el GC por épocas no puede introducir efectos no deterministas en la cinta. El cierre de recursos es explícito o estructurado con `Diferir`, sin que un error secundario de cierre oculte el error primario |

### 3.2 Tabla de decisiones técnicas de `PG-3`

| Decisión | Opciones evaluadas | Criterio | Elección | Reversión |
|---|---|---|---|---|
| `D-PG3-01` Representación de capacidades y `Bytes` | (A) Entero `u64` con ID de descriptor; (B) Objeto gestionado en banco de referencias `u32` (`GcRef`) con generación y derechos | Seguridad de tipos, imposibilidad de falsificar descriptores y conteo determinista en `ENG.LIMITS` | **B**: `CapabilityToken` (1 celda) y `Bytes` ($1 + \lceil n/8 \rceil$ celdas) en el banco de referencias `GcRef`, con generación para invalidación tras cierre | Si una capacidad sin estado necesitara evitar el montón, podría codificarse como escalar etiquetado solo dentro del ABI privado sin cambiar la semántica pública |
| `D-PG3-02` Suministro de capacidades y modo de archivo único (`ADR-02`, `ADR-12`) | (A) Obligar a `pseudolearn.toml` en todo programa con capacidades; (B) Inyección desde manifiesto en proyectos y proveedor simulado en memoria para archivo único | Preservar la fricción cero en `pseudolearn_app` y en el corpus educativo sin abrir autoridad real | **B**: `Leer`/`Escribir` clásicos siguen funcionando sin cambios; las capacidades explícitas usan `requested ∩ granted` en proyecto y un anfitrión virtual en memoria en archivo único | Ninguna sin romper `ADR-12` |
| `D-PG3-03` Vocabulario cerrado de permisos en `API.PROJECT.MANIFEST#R4` | (A) Mantener permisos libres como cadenas; (B) Vocabulario cerrado de `PG-3` bilingüe (`consola`, `argumentos`, `archivos_lectura`, `archivos_escritura`, `reloj`, `temporizador`) | Determinismo de validación y rechazo de permisos desconocidos o futuros (`red_http` queda para `PG-5`) | **B**: Edición oficial de `API.PROJECT.MANIFEST#R4` con las seis clases de permiso de `PG-3` y denegación por defecto | Ampliar el conjunto cerrado en `PG-5` para `red_http` |
| `D-PG3-04` Análisis de efectos transitivos en compilación (`PG-3.08`, `K-13`) | (A) Comprobar solo llamadas directas dentro de `Funcion`; (B) Punto fijo sobre grafo de llamadas más comprobación en valores función/clausuras y métodos de `Interfaz` | Impedir que una `Funcion` pura esconda E/S a través de una clausura de `PG-2.07` o una interfaz de `PG-2.09` | **B**: `effect_check` en `pseudolearn_semantic` propaga efectos hasta punto fijo; los valores `Funcion(...)` y los métodos `Funcion` de una `Interfaz` exigen huella pura | Ninguna; es requisito directo de `PG-3.08` y `K-13` |
| `D-PG3-05` Frontera de confirmación lógica y estado incierto (`CF-07`, `PG-3.01`) | (A) Registrar solo efectos completados; (B) Registro en dos fases (`Requested` → `Committed` / `Failed` / `Uncertain`) en `EffectTape` | Distinguir un rechazo previo a mutar de un fallo ocurrida tras cruzar al anfitrión | **B**: Toda solicitud abre entrada con `effect_seq` y `request_digest`, y cierra con `Committed`, `Failed(ErrorES)` o `Uncertain(ErrorES)` (marcando la cinta `UncertainExternalState`) | Si un efecto de solo lectura falla, se clasifica siempre como `Failed` y nunca como `Uncertain` |
| `D-PG3-06` Fallo controlado frente a caída/terminación del anfitrión (`CF-11`, `PG-3.02`) | (A) Tratar errores de E/S como trampas; (B) Separación tripartita: `Resultado<T, ErrorES>` recuperable (ejecuta `Diferir`), trampa `failed` del programa y corte del anfitrión (`cancelled`/`limit_reached`/`AbortedByHost`) | `ADR-07`, limpieza predecible y no ejecutar efectos nuevos cuando el anfitrión ya cortó la sesión | **B**: Los fallos de E/S devuelven `Resultado::Err(ErrorES)` y recorren `Diferir`; la cancelación o corte del anfitrión detiene de inmediato sin ejecutar efectos nuevos en `Diferir` y sella la cinta como `Incomplete` | Revisable por la persona en `PG-3.02` antes de anclar |
| `D-PG3-07` Suspensión `awaiting_effect` (`PG-3.07`) | (A) Reutilizar `awaiting_input`; (B) Variante dedicada `RunExit::AwaitingEffect(PendingEffectRequest)` y operación `effect_result` | No mezclar la entrada pedagógica `Leer` con efectos tipados de archivo, reloj o temporizador | **B**: `awaiting_input` queda exclusivo de `Leer`; `awaiting_effect` expone `effect_seq`, clase de capacidad, operación y resumen de argumentos | Ninguna; exigido por `PG-3.07` |
| `D-PG3-08` Esquema versionado de cinta y privacidad (`PG-3.04`, `PG-3.10`) | (A) Extender la lista `inputs` actual; (B) Esquema `pseudolearn.tape/v1` con `identity`, `policy` (`max_tape_bytes`, `SecretRef`) y `entries` encadenadas con SHA-256 | Reproducibilidad verificable, detección de adulteración y protección de secretos y memoria (`K-07`) | **B**: `EffectTape` versionado con hash encadenado, referencias opacas `SecretRef { key_id, value_hmac }` y marcas `NonReproducibleRedacted` / `NonReproducibleTruncated` | Incrementar versión del esquema en fases futuras si `PG-4`/`PG-5` añaden metadatos |
| `D-PG3-09` Tres modos de ejecución aislados (`PG-3.05`, `PG-3.06`) | (A) Banderas booleanas dispersas; (B) `ExecutionMode::{LiveRecord, ReplayFromTape, HistorySeek}` con proveedor `TapeReplayProvider` desconectado del anfitrión | Garantizar por construcción que reproducir y `seek` jamás toquen disco, reloj ni red | **B**: En `ReplayFromTape` y `HistorySeek` el motor instala `TapeReplayProvider`; cualquier divergencia, truncamiento o hash inválido aborta con error de reproducción sin consultar al anfitrión | Ninguna |
| `D-PG3-10` Separación `Bytes` / `Cadena` UTF-8 y limpieza con `Diferir` (`PG-3.09`) | (A) Reemplazar bytes inválidos con `U+FFFD`; (B) `Bytes` para datos crudos y validación UTF-8 estricta con `Resultado<Cadena, ErrorES::Utf8Invalido>` | No corromper datos binarios ni esconder errores de codificación; limpieza determinista de descriptores | **B**: Operaciones binarias y de texto separadas; `Diferir` permite cerrar capacidades al salir o propagar `ErrorES` sin sobrescribir el error primario en vuelo | Ninguna |
| `D-PG3-11` Instrucción `EffectCall` y sobrecosto cero en código puro (`PG-3.12`, `PG-3.13`) | (A) Interceptar cada llamada de función; (B) Opcode dedicado `Opcode::EffectCall` / `Op::EffectCall` y `EffectSession` alojada perezosamente | Cumplir `≤ 2 %` en `PERF.SUITE.CORE` (`E-PG-05`) y compartir runtime C-ABI con Cranelift AOT (`ADR-13`) | **B**: Cero ramificaciones nuevas en los opcodes puros de `Fast`/`Probed`; `pseudolearn_aot_rt` expone `pl_aot_effect_call` sobre la misma `EffectTape` y `CapabilityTable` | Ninguna |
| `D-PG3-12` Anfitrión falso declarativo en `see/1` (`PG-3.11`) | (A) Archivos temporales en `/tmp`; (B) Clave declarativa `anfitrion` en el caso `see/1` respaldada por `FakeHostProvider` en memoria | Pruebas rápidas, deterministas, sin disco ni reloj real y con inyección reproducible de fallos e incertidumbre | **B**: `FakeHostProvider` en memoria dentro de `pseudolearn_api`, gobernado por los datos del caso en `packages/pseudolearn_spec` | Ninguna |
| `D-PG3-13` Evolución sincronizada de `apps/pseudolearn_app` (`C-16`) | (A) Posponer todo cambio de la app a `PG-A`/`PG-B`; (B) Actualizar en `PG-3` el catálogo de ayuda, `API.PROGRAM.VIEW` y los adaptadores de ejecución y vista de `pseudolearn_app` | La aplicación debe evolucionar con la sintaxis nueva del lenguaje sin esperar al rediseño visual de diagramas | **B**: Actualizar `TOOL.SERVICE.CATALOG`, `API.PROGRAM.VIEW`, `rust_wire_models.dart`, `rust_execution_api.dart`, `rust_program_execution.dart`, `rust_program_view_builder.dart` y `rust_construct_projection.dart` | Las superficies visuales nuevas de multicarril quedan en `PG-B` |

---

## 4. Desglose por punto

### PG-3.01 · `CF-07` especificado: frontera de confirmación lógica y estado externo incierto, con casos

- [ ] `PG-3.01.01` Especificar en `ENG.EXEC.EFFECT-COMMIT` (nuevo) y en `ENG.EXEC.EFFECT-ORDER` (edición oficial) las dos fases de cada efecto (`Requested` y `Resolved`), los tres resultados de confirmación (`Committed`, `Failed`, `Uncertain`), el momento exacto en que se asigna `effect_seq` tras evaluar argumentos de izquierda a derecha y el efecto sobre el estado de reproducibilidad de la cinta.
- [ ] `PG-3.01.02` Casos: efecto confirmado de lectura y de escritura, fallo controlado previo a mutar (`PermisoDenegado`, `NoEncontrado`), fallo con estado externo incierto durante escritura (`Uncertain` con bandera `incierto` en `ErrorES` y cinta marcada `UncertainExternalState`), orden de `effect_seq` cuando una expresión combina dos efectos en secuencia.
- [ ] `PG-3.01.03` Tests unitarios de la máquina de estados de confirmación (`Requested` → `Committed` / `Failed` / `Uncertain`) y del rechazo de transiciones inválidas (doble resolución o resolución sin solicitud).
- [ ] `PG-3.01.04` Implementar `EffectPhase`, `CommitOutcome` y `ReproducibilityStatus` en `pseudolearn_runtime` / `pseudolearn_vm` y `pseudolearn_timeline`.
- [ ] `PG-3.01.05` Actualizar `README.md` de `pseudolearn_vm` y `pseudolearn_timeline` con la frontera de confirmación lógica.
- [ ] `PG-3.01.06` Verificación acotada: `see validate` y `see conform --subject engine --only ENG.EXEC.EFFECT-COMMIT,ENG.EXEC.EFFECT-ORDER`.

### PG-3.02 · `CF-11` resuelto: fallo controlado frente a caída o terminación del anfitrión

- [ ] `PG-3.02.01` Editar `ENG.EXEC.MODEL` y `RT.HOST.INTERFACE` como texto oficial con la formulación revisada por la persona (`D-PG3-06`): distinguir fallo controlado de efecto (`Resultado<T, ErrorES>`, recuperable y con ejecución normal de `Diferir`), trampa del programa (`termination = failed`) y corte/terminación del anfitrión (`cancelled`, `limit_reached`, desconexión en `awaiting_effect` que sella `AbortedByHost` sin ejecutar nuevos efectos en `Diferir`).
- [ ] `PG-3.02.02` Casos: fallo de archivo manejado con `Segun` sobre `Resultado`, fallo propagado con `Propagar` que ejecuta `Diferir`, cancelación del anfitrión mientras un efecto está en `awaiting_effect`, agotamiento de límite de sentencias después de abrir una capacidad (cierre inmediato en el anfitrión sin ejecutar efectos adicionales del usuario).
- [ ] `PG-3.02.03` Tests de `pseudolearn_vm` y `pseudolearn_api` que comprueban la liberación determinista de la tabla de capacidades del anfitrión ante `Cancelled`, `LimitReached` y `Trap`.
- [ ] `PG-3.02.04` Implementar el cierre forzoso de recursos de anfitrión y el sellado `AbortedByHost` en `pseudolearn_vm` y `pseudolearn_api`.
- [ ] `PG-3.02.05` Documentar en `README.md` de `pseudolearn_vm` y `pseudolearn_api` la separación entre `Resultado<T, ErrorES>`, trampa y terminación de anfitrión.
- [ ] `PG-3.02.06` Verificación acotada: `--only ENG.EXEC.MODEL,RT.HOST.INTERFACE` y tests espejo de `execution_resource`.

### PG-3.03 · Capacidades para consola, argumentos, archivos relativos a una capacidad, reloj grabado y temporizadores lógicos; denegación por defecto

- [ ] `PG-3.03.01` Crear `LANG.CAPABILITY.MODEL` y editar `API.PROJECT.MANIFEST` (`R4`), `RT.HOST.INTERFACE` y `RT.PROCESS`: tipos bilingües `Consola`/`Console`, `Argumentos`/`Arguments`, `DirectorioCap`/`DirCap`, `ArchivoCap`/`FileCap`, `Reloj`/`Clock` y `Temporizador`/`Timer`; vocabulario cerrado de permisos en `pseudolearn.toml` (`consola`, `argumentos`, `archivos_lectura`, `archivos_escritura`, `reloj`, `temporizador`); denegación por defecto; atenuación de subrutas y modos (`lectura`/`escritura`) sin amplificación; invalidación por cierre (`CapacidadCerrada`).
- [ ] `PG-3.03.02` Casos: programa sin permisos que intenta usar archivo o reloj (denegado), intersección `requested ∩ granted` en proyecto, apertura de archivo relativo a `DirectorioCap`, atenuación a subdirectorio de solo lectura e intento rechazado de abrir para escritura desde capacidad de solo lectura, intento de escape con `..` o ruta absoluta, uso de `ArchivoCap` tras `cerrar`.
- [ ] `PG-3.03.03` Tests espejo en `pseudolearn_project` (`authority_tests.rs`, `capability_fs_tests.rs`) y en `pseudolearn_vm` (`capability_tests.rs`) para intersección de permisos, generación de `CapabilityToken` y confinamiento con `cap-std`.
- [ ] `PG-3.03.04` Extender `authority.rs` en `pseudolearn_project`, añadir `CapabilityToken` y `CapabilityTable` en `pseudolearn_runtime`/`pseudolearn_vm`, y registrar el vocabulario bilingüe en `pseudolearn_syntax` y `pseudolearn_semantic`.
- [ ] `PG-3.03.05` Actualizar `README.md` de `pseudolearn_project`, `pseudolearn_runtime` y `pseudolearn_semantic`; añadir fichas de ayuda en `TOOL.SERVICE.CATALOG`.
- [ ] `PG-3.03.06` Verificación acotada: `--only API.PROJECT.MANIFEST,LANG.CAPABILITY.MODEL,RT.HOST.INTERFACE,RT.PROCESS` y tests de `pseudolearn_project` y `pseudolearn_vm`.

### PG-3.04 · Identidad de ejecución ampliada y esquema versionado de cinta con todos los datos de cada efecto y su orden de entrega

- [ ] `PG-3.04.01` Crear `ENG.EFFECT.TAPE`: esquema `pseudolearn.tape/v1`, `ExecutionIdentity` (resúmenes de fuentes, grafo de paquetes, perfil, semilla, límites y permisos efectivos), `TapeEntry` (`effect_seq`, `task_id = 0`, `source_node_id`, `capability_kind`, `operation`, `request_digest`, `secret_ref`, `outcome`, `payload_bytes`, `entry_hash`) y cálculo de resumen encadenado SHA-256.
- [ ] `PG-3.04.02` Casos: grabación de secuencia mixta (argumentos, reloj, lectura/escritura de archivo, temporizador y consola), determinismo de serialización entre dos ejecuciones idénticas, preservación del orden de entrega por `effect_seq` y cambio del digest ante modificación de semilla, límite o fuente.
- [ ] `PG-3.04.03` Tests espejo de serialización canónica, encadenamiento de hashes y compatibilidad con las grabaciones de `Leer` existentes en `pseudolearn_timeline` y `pseudolearn_api`.
- [ ] `PG-3.04.04` Implementar `EffectTape`, `ExecutionIdentity` y `TapeEntry` en `pseudolearn_timeline` y conectarlos con `recording.rs` y `recording_digest.rs` en `pseudolearn_api`.
- [ ] `PG-3.04.05` Actualizar `README.md` de `pseudolearn_timeline` y `pseudolearn_api`.
- [ ] `PG-3.04.06` Verificación acotada: `--only ENG.EFFECT.TAPE` y tests de `recording` en `pseudolearn_api` y `pseudolearn_timeline`.

### PG-3.05 · Tres modos separados: ejecutar y grabar, ejecutar desde cinta, consultar historia (`seek`); reproducir y retroceder nunca tocan disco ni red

- [ ] `PG-3.05.01` Editar `API.EXECUTE` y `API.STATE.QUERY` para especificar los tres modos (`LiveRecord`, `ReplayFromTape`, `HistorySeek`) y la garantía de aislamiento total del anfitrión durante `ReplayFromTape` y `HistorySeek`.
- [ ] `PG-3.05.02` Casos: ejecutar en `LiveRecord` con efectos de archivo y reloj, reproducir la cinta resultante en `ReplayFromTape` con el sistema de archivos virtual vacío/desconectado obteniendo idéntica salida y traza, y realizar consultas `seek` hacia adelante y hacia atrás sobre una sesión con efectos sin reejecutar llamadas al anfitrión.
- [ ] `PG-3.05.03` Tests con espía de anfitrión (`PanickingHostSpy` / contador de llamadas = `0`) que demuestran que `ReplayFromTape` y `HistorySeek` jamás invocan al proveedor físico del anfitrión.
- [ ] `PG-3.05.04` Implementar `ExecutionMode`, `TapeReplayProvider` y la integración con `CheckpointStore` en `pseudolearn_timeline` (`replay.rs`) y `pseudolearn_api` (`execution_resource.rs`).
- [ ] `PG-3.05.05` Actualizar `README.md` de `pseudolearn_timeline` y `pseudolearn_api`.
- [ ] `PG-3.05.06` Verificación acotada: `--only API.EXECUTE,API.STATE.QUERY,ENG.STATE.SNAPSHOT,ENG.STATE.INCREMENTAL` y tests de `replay` en `pseudolearn_timeline`.

### PG-3.06 · Cinta divergente, truncada o alterada rechazada con error de reproducción, sin consultar al anfitrión

- [ ] `PG-3.06.01` Especificar en `ENG.EFFECT.TAPE` y `API.ERRORS` los códigos de rechazo de reproducción (`replay_identity_mismatch`, `replay_divergence`, `replay_truncated_tape`, `replay_corrupted_tape`, `replay_non_reproducible`) y la prohibición de caer de vuelta (*fallback*) al anfitrión vivo cuando falla la cinta.
- [ ] `PG-3.06.02` Casos negativos: reproducción con código fuente modificado (`replay_identity_mismatch`), con argumento de efecto distinto (`replay_divergence`), con última entrada recortada (`replay_truncated_tape`), con `entry_hash` o `payload_bytes` alterado (`replay_corrupted_tape`) y con cinta marcada como no reproducible (`replay_non_reproducible`).
- [ ] `PG-3.06.03` Tests unitarios de cada código de rechazo en `TapeReplayProvider` verificando que el contador de llamadas al anfitrión permanece en `0`.
- [ ] `PG-3.06.04` Implementar la validación de identidad, secuencia y hash en `TapeReplayProvider` y proyectar los errores en `pseudolearn_api`.
- [ ] `PG-3.06.05` Actualizar `README.md` de `pseudolearn_timeline` y catálogo de errores en `pseudolearn_api`.
- [ ] `PG-3.06.06` Verificación acotada: `--only ENG.EFFECT.TAPE,API.ERRORS` y tests negativos de `tape_replay`.

### PG-3.07 · Contrato de suspensión por efecto pendiente (`awaiting_effect`), distinto de la espera de entrada (`awaiting_input`)

- [ ] `PG-3.07.01` Editar `ENG.EXEC.MODEL` y `API.EXECUTE` para definir la terminación de lote `awaiting_effect`, su carga útil (`effect_seq`, `capability_kind`, `operation`, `arguments_summary`, `source_node_id`), la operación `effect_result` para reanudar y su distinción estricta frente a `awaiting_input` (`Leer`).
- [ ] `PG-3.07.02` Casos: sesión que alterna `awaiting_input` (por `Leer`) y `awaiting_effect` (por operación de capacidad en modo desacoplado), entrega de `effect_result` exitoso y con `ErrorES`, rechazo de `input` cuando el motor espera `effect_result` y viceversa.
- [ ] `PG-3.07.03` Tests en `pseudolearn_vm`, `pseudolearn_api` y test espejo Dart en `apps/pseudolearn_app/test/engine/rust/` para la deserialización y manejo de `awaiting_effect`.
- [ ] `PG-3.07.04` Añadir `RunExit::AwaitingEffect(PendingEffectRequest)` en `pseudolearn_vm`, la operación `effect_result` en `pseudolearn_api` y actualizar `rust_wire_models.dart`, `rust_execution_api.dart` y `rust_program_execution.dart` en `apps/pseudolearn_app`.
- [ ] `PG-3.07.05` Actualizar `README.md` de `pseudolearn_vm`, `pseudolearn_api` y `apps/pseudolearn_app`.
- [ ] `PG-3.07.06` Verificación acotada: `--only ENG.EXEC.MODEL,API.EXECUTE`, tests de `pseudolearn_api` y `flutter test` del archivo de ejecución tocado en `apps/pseudolearn_app`.

### PG-3.08 · Análisis de efectos transitivos en compilación: una función pura no puede esconder E/S

- [ ] `PG-3.08.01` Crear `LANG.CAPABILITY.PURITY` y editar `DIAG.CATALOG`/`DIAG.MESSAGES`: prohibición de realizar efectos directos o transitivos dentro de `Funcion` / `Function`; propagación sobre el grafo de llamadas; prohibición de asignar o pasar una unidad o clausura con efecto donde se espera un tipo `Funcion(...)`; coherencia de pureza en realizaciones de `Interfaz` / `Interface`.
- [ ] `PG-3.08.02` Casos: `Funcion` que invoca `Leer`, `Escribir` o una operación de capacidad (rechazada); `Funcion` `A` que llama a `B` que llama a `C` con efecto (rechazada con cadena causal); clausura con efecto pasada a orden superior que espera `Funcion` pura (rechazada); clase que implementa un método `Funcion` de una `Interfaz` realizando E/S (rechazada); `SubProceso` que realiza los mismos efectos (aceptado).
- [ ] `PG-3.08.03` Tests unitarios de `effect_check` en `pseudolearn_semantic` cubriendo ciclos de recursión mutua, clausuras anidadas e interfaces.
- [ ] `PG-3.08.04` Implementar `effect_check.rs` en `pseudolearn_semantic` y emitir los diagnósticos tipados con ruta de propagación de impureza.
- [ ] `PG-3.08.05` Actualizar `README.md` de `pseudolearn_semantic` y `pseudolearn_diagnostics`.
- [ ] `PG-3.08.06` Verificación acotada: `--only LANG.CAPABILITY.PURITY,DIAG.CATALOG,DIAG.MESSAGES` y tests de `pseudolearn_semantic`.

### PG-3.09 · Errores de E/S portables, separación de bytes y texto UTF-8, y limpieza en retorno, propagación y salida

- [ ] `PG-3.09.01` Crear `LIB.IO` y `LIB.TIME`, y editar `LIB.MODEL`, `LANG.CONTROL.CLEANUP`, `IR.INSTRUCTIONS`, `API.PROGRAM.VIEW` y `TOOL.SERVICE.CATALOG`: tipo `Bytes`, variante estructurada `ErrorES` / `IoError` (`NoEncontrado`, `PermisoDenegado`, `YaExiste`, `FinDeArchivo`, `Utf8Invalido`, `RutaInvalida`, `CapacidadCerrada`, `TiempoAgotado`, `Interrumpido`, con bandera `incierto`), operaciones separadas de `Bytes` y `Cadena` UTF-8, reloj y temporizador lógico, y ejecución de `Diferir` para cerrar capacidades al salir del alcance, retornar o propagar `Resultado::Err(ErrorES)` sin ocultar el error primario.
- [ ] `PG-3.09.02` Casos: lectura/escritura de `Bytes` binarios arbitrarios; lectura de texto UTF-8 válido e inválido (`Utf8Invalido`); apertura de archivo seguida de `Diferir cerrar(f)` que sale por retorno normal, por `Propagar` de un `ErrorES` de lectura y por salida anticipada de bucle, comprobando que el archivo queda cerrado y el `ErrorES` primario se preserva intacto; consulta de reloj grabado y espera en temporizador lógico.
- [ ] `PG-3.09.03` Tests de `Bytes` en el montón y recolector (`GcHeap`), tests de aristas de limpieza con `EffectCall` en `pseudolearn_lowering` y tests Dart de vista pública y vocabulario en `apps/pseudolearn_app`.
- [ ] `PG-3.09.04` Implementar `Bytes` y `ErrorES` en `pseudolearn_abi`/`pseudolearn_runtime`/`pseudolearn_library`, `Opcode::EffectCall` en `pseudolearn_ir`/`pseudolearn_lowering`/`pseudolearn_bytecode`, fichas en `pseudolearn_service` y proyecciones en `pseudolearn_api` y `apps/pseudolearn_app` (`rust_program_view_builder.dart`, `rust_construct_projection.dart`).
- [ ] `PG-3.09.05` Actualizar `README.md` de `pseudolearn_abi`, `pseudolearn_runtime`, `pseudolearn_library`, `pseudolearn_lowering`, `pseudolearn_service` y `apps/pseudolearn_app`.
- [ ] `PG-3.09.06` Verificación acotada: `--only LIB.IO,LIB.TIME,LANG.CONTROL.CLEANUP,API.PROGRAM.VIEW,TOOL.SERVICE.CATALOG` y tests espejo en Rust y Flutter.

### PG-3.10 · Privacidad de la cinta: secretos por referencia, retención y presupuesto de bytes definidos, y cinta incompleta marcada como no reproducible

- [ ] `PG-3.10.01` Especificar en `ENG.EFFECT.TAPE` y `ENG.LIMITS` la política de privacidad y retención: referencias opacas `SecretRef { key_id, value_hmac }` sin valor en claro en la cinta, límite configurable `max_tape_bytes` y marcado obligatorio `NonReproducibleRedacted`, `NonReproducibleTruncated` o `Incomplete` cuando la cinta no contiene todos los bytes necesarios para reproducción autónoma.
- [ ] `PG-3.10.02` Casos: efecto con argumento sensible grabado como `SecretRef` (comprobando ausencia de la cadena secreta en la cinta serializada), ejecución que supera `max_tape_bytes` (continúa la ejecución en vivo si el límite es solo de cinta, pero sella la cinta como `NonReproducibleTruncated`), e intento rechazado de reproducir una cinta truncada o sin resolución del secreto.
- [ ] `PG-3.10.03` Tests unitarios de redacción de secretos y de corte exacto en `max_tape_bytes - 1`, `max_tape_bytes` y `max_tape_bytes + 1` en `pseudolearn_timeline`.
- [ ] `PG-3.10.04` Implementar `SecretRef`, el filtro de redacción y el contador de presupuesto `max_tape_bytes` en `EffectTapeRecorder`.
- [ ] `PG-3.10.05` Actualizar `README.md` de `pseudolearn_timeline`.
- [ ] `PG-3.10.06` Verificación acotada: `--only ENG.EFFECT.TAPE,ENG.LIMITS` y tests de privacidad/presupuesto en `pseudolearn_timeline`.

### PG-3.11 · Conformidad con anfitrión falso de resultados derivados, sin red ni disco reales

- [ ] `PG-3.11.01` Especificar en `SEE.CASE.FORMAT` / documentación de `packages/pseudolearn_spec` la extensión declarativa `anfitrion` en los casos de prueba (árbol de archivos en memoria, argumentos, secuencia de instantes de reloj, inyección de fallos `ErrorES` y estados `Uncertain`, secretos y modo `grabar_y_reproducir`).
- [ ] `PG-3.11.02` Casos de validación en `packages/pseudolearn_spec` (positivo de caso con anfitrión falso y negativo de esquema `anfitrion` mal formado).
- [ ] `PG-3.11.03` Tests unitarios del parser/validador de `see` y de `FakeHostProvider` en `pseudolearn_api`.
- [ ] `PG-3.11.04` Implementar `FakeHostProvider` en `pseudolearn_api` y su cableado en el corredor de conformidad de `packages/pseudolearn_spec` y `see_cli`.
- [ ] `PG-3.11.05` Actualizar `README.md` de `packages/pseudolearn_spec` y `pseudolearn_api`.
- [ ] `PG-3.11.06` Verificación acotada: tests de `pseudolearn_spec` y `see conform --subject engine --only LIB.IO,LIB.TIME,ENG.EFFECT.TAPE`.

### PG-3.12 · AOT comparte cinta y determinismo de salida sin anunciar observación ni retroceso

- [ ] `PG-3.12.01` Declarar al sujeto `aot` en `ENG.EXEC.EFFECT-COMMIT`, `ENG.EFFECT.TAPE`, `LANG.CAPABILITY.MODEL`, `LANG.CAPABILITY.PURITY`, `LIB.IO` y `LIB.TIME`, especificando que AOT graba y reproduce el mismo formato `pseudolearn.tape/v1` y produce idéntica salida y errores, manteniendo rechazados `observe` y `seek`.
- [ ] `PG-3.12.02` Casos de paridad cruzada: cinta grabada por `engine` (VM) reproducida por `aot`, cinta grabada por `aot` reproducida e inspeccionada con `seek` por `engine`, y rechazo de `observe`/`seek` en `aot`.
- [ ] `PG-3.12.03` Tests espejo en `pseudolearn_codegen` / `pseudolearn_aot_rt` y en `apps/pseudolearn_cli` (`--record-tape`, `--replay-tape`).
- [ ] `PG-3.12.04` Reducir `Opcode::EffectCall` en `pseudolearn_codegen` hacia `pl_aot_effect_call` en `pseudolearn_aot_rt`, compartiendo `EffectTape` y `CapabilityTable`, y exponer las banderas de cinta en `apps/pseudolearn_cli`.
- [ ] `PG-3.12.05` Actualizar `README.md` de `pseudolearn_codegen`, `pseudolearn_aot_rt` y `apps/pseudolearn_cli` (incluyendo la fila correspondiente en la tabla «Invariantes de `unsafe`» si `pl_aot_effect_call` cruza la frontera FFI).
- [ ] `PG-3.12.06` Verificación acotada: `see conform --subject aot --only <contratos_PG3>` y tests de `pseudolearn_codegen`, `pseudolearn_aot_rt` y `pseudolearn_cli`.

### PG-3.13 · `E-PG-05` y la parte de archivos de `E-PG-09` ejecutados; sobrecosto de infraestructura inactiva dentro del presupuesto candidato

- [ ] `PG-3.13.01` Definir los subcomandos de medición de `E-PG-05` (sobrecosto en `PERF.SUITE.CORE` con infraestructura de capacidades/cinta inactiva y razón de crecimiento de cinta en cargas con efectos) y la suite de vectores de ataque de archivos y cinta de `E-PG-09`.
- [ ] `PG-3.13.02` Cargas sembradas de `E-PG-05` (`100`, `1 000` y `10 000` efectos de consola, reloj y archivo) y vectores adversarios de `E-PG-09` (`..`, enlaces simbólicos salientes, rutas absolutas, NUL interior, amplificación de derechos, uso tras cierre, adulteración de un bit en cinta, truncamiento).
- [ ] `PG-3.13.03` Tests del arnés de medición y de la batería de seguridad `E-PG-09` garantizando que ningún escape o corrupción pase en verde.
- [ ] `PG-3.13.04` Ampliar `pseudolearn_bench_worker` para `E-PG-05` y el arnés de seguridad para `E-PG-09`.
- [ ] `PG-3.13.05` Registrar la metodología y resultados en los `README.md` correspondientes y en §11 de este plan.
- [ ] `PG-3.13.06` Ejecutar la campaña en segundo plano siguiendo `PERF.PROTOCOL`, verificar que el sobrecosto sobre `PERF.SUITE.CORE` es `≤ 2 %` y que el 100 % de los vectores de `E-PG-09` son bloqueados sin tocar el exterior.

---

## 5. Capas y archivos

`E` = `packages/pseudolearn_engine/crates`, `S` = `packages/pseudolearn_spec`, `A` = `apps/pseudolearn_app`,
`C` = `apps/pseudolearn_cli`. Antes de tocar cada archivo se verifican las tres preguntas de `AGENTS.md` §1 y los
límites del miembro (`600` líneas en Rust, `250` líneas en Dart, cero comentarios).

| Archivos previstos | Capa; imports permitidos / prohibidos | Dueño y motivo; puntos |
|---|---|---|
| Este archivo (`fase-pg-3-plan-ejecucion.md`) y `plan-ejecucion-proposito-general.md` | Documentación transitoria de `docs/` / nunca citada desde fuera de `docs/` | Planificación de `PG-3` |
| `S/specifications/eng/`: nuevos `eng.exec.effect-commit.md`, `eng.effect.tape.md`; editados `eng.exec.model.md`, `eng.exec.effect-order.md`, `eng.limits.md` | Datos normativos del corpus / sin enlaces externos | Confirmación lógica, cinta, modos y límites; `.01`, `.02`, `.04`–`.07`, `.10` |
| `S/specifications/lang/`: nuevos `lang.capability.model.md`, `lang.capability.purity.md`; editado `lang.control.cleanup.md` | Datos normativos del corpus | Modelo de capacidades, pureza transitiva y limpieza con `Diferir`; `.03`, `.08`, `.09` |
| `S/specifications/lib/`: nuevos `lib.io.md`, `lib.time.md`; editado `lib.model.md` | Datos normativos del corpus | `Bytes`, `ErrorES`, archivos, consola, argumentos, reloj y temporizador; `.03`, `.09` |
| `S/specifications/{rt,api,diag,ir,tool}/`: editados `rt.host.interface.md`, `rt.process.md`, `api.project.manifest.md`, `api.execute.md`, `api.state.query.md`, `api.errors.md`, `api.program.view.md`, `diag.catalog.md`, `diag.messages.md`, `ir.instructions.md`, `tool.service.catalog.md` | Datos normativos del corpus | Frontera de anfitrión, permisos de manifiesto, API, diagnósticos, RI, vista pública y ayuda; `.02`–`.12` |
| `E/pseudolearn_abi/src/`: nuevos `capability_layout.rs`, `bytes_layout.rs`, `io_error_layout.rs` | `abi` (sin dependencias internas) / prohibido `runtime`, `ir`, `codegen` | Disposiciones compartidas entre VM y AOT; `.03`, `.09`, `.12` |
| `E/pseudolearn_syntax/src/` y generador de léxico | `syntax` / sin `semantic` ni `runtime` | Palabras y nombres de tipos incorporados bilingües de `PG-3` (`GEN-NO-HAND-COPY`); `.03`, `.09` |
| `E/pseudolearn_semantic/src/`: nuevos `effect_check.rs`, `capability_types.rs` | `semantics` / sin `runtime`, `ir` ni `codegen` | Análisis de efectos transitivos en funciones, clausuras e interfaces, y tipado de capacidades; `.03`, `.08`, `.09` |
| `E/pseudolearn_lowering/src/`: nuevo `effect_calls.rs`; ajuste en `cleanup_edges.rs` | `lowering` (`source`, `semantic`, `ir`, `diagnostics`) / sin `runtime` | Reducción a `Opcode::EffectCall` y limpieza de capacidades en `Diferir`; `.03`, `.09` |
| `E/pseudolearn_ir/src/` y `E/pseudolearn_bytecode/src/`: instrucción `EffectCall` y verificación de operandos | `ir` y `bytecode` / sin `semantic` ni `runtime` | Representación SSA y opcode de 8 bytes; `.09`, `.12` |
| `E/pseudolearn_project/src/`: `authority.rs`, nuevo `capability_fs.rs` | `project` / usa `cap-std` ya autorizado | Permisos de `PG-3` (`requested ∩ granted`) y raíces de archivos confinadas; `.03` |
| `E/pseudolearn_runtime/src/`: nuevos `capability_table.rs`, `bytes_buffer.rs`, `io_error.rs`; `heap/` para raíces y conteo de celdas | `runtime` (`abi`, `diagnostics`) / sin `vm` ni `codegen` | Objetos `CapabilityToken` y `Bytes` en `GcHeap`; `.01`, `.03`, `.09` |
| `E/pseudolearn_vm/src/`: nuevo `effect_dispatch.rs`, ajuste en `model.rs` (`RunExit::AwaitingEffect`) | `vm` / sin `codegen` | Despacho perezoso de `Op::EffectCall` y suspensión `AwaitingEffect`; `.01`–`.07`, `.09` |
| `E/pseudolearn_timeline/src/`: nuevos `effect_tape.rs`, `tape_replay.rs`, `tape_privacy.rs`; ajuste en `replay.rs` | `timeline` / sin acceso directo al sistema operativo | Esquema `pseudolearn.tape/v1`, hash encadenado, privacidad y `TapeReplayProvider`; `.04`–`.06`, `.10` |
| `E/pseudolearn_codegen/src/`: nuevo `lower_effects.rs`; `E/pseudolearn_aot_rt/src/`: nuevo `effect_runtime.rs` | `aot` / `unsafe` solo en `pseudolearn_aot_rt` documentado en su tabla de invariantes | Paridad de efectos y cinta en Cranelift AOT; `.12` |
| `E/pseudolearn_service/src/` y `E/pseudolearn_api/src/`: `recording.rs`, `recording_digest.rs`, `execution_resource.rs`, `program_view*.rs`, nuevo `fake_host.rs` | `service` y `api` | Catálogo de ayuda, vista pública, modos de ejecución/cinta y `FakeHostProvider`; `.04`–`.11` |
| `C/src/`: banderas `--record-tape`, `--replay-tape` y concesión explícita de capacidades | `cli` (solo consume `pseudolearn_api`) | Grabación y reproducción desde terminal en VM y AOT; `.05`, `.12` |
| `A/lib/engine/rust/`: `rust_wire_models.dart`, `rust_execution_api.dart`, `rust_program_execution.dart`, `rust_program_view_builder.dart`, `rust_construct_projection.dart` y sus tests espejo en `A/test/engine/rust/` | `engine` → `model`, `ports` / sin widgets de Flutter (`max_file_lines: 250`) | Evolución sincronizada de `pseudolearn_app` con la sintaxis nueva, `awaiting_effect` y capacidades simuladas en archivo único; `.03`, `.07`, `.09` |

---

## 6. Presupuestos de rendimiento y seguridad

### 6.1 Rendimiento y memoria (`E-PG-05`)

| Magnitud | Presupuesto / Criterio | Cómo se verifica |
|---|---|---|
| Sobrecosto en código puro (`PERF.SUITE.CORE`) | `≤ 2 %` de variación en tiempo de ejecución y `0` bytes adicionales alojados cuando el programa no ejecuta `Op::EffectCall` | `EffectSession` alojada perezosamente; bucle de despacho de opcodes puros sin ramas adicionales; campaña A/B en `.13` (`E-PG-05`) |
| Costo de grabación por efecto (`LiveRecord`) | Tiempo $O(1)$ amortizado por entrada más hash SHA-256 lineal en los bytes transferidos | Microbenchmark de `100`, `1 000` y `10 000` efectos en `.13` |
| Presupuesto de memoria de cinta (`max_tape_bytes`) | Límite determinista configurable en `ENG.LIMITS` (`16 MiB` por defecto en motor, `1 MiB` en archivo único educativo) | Test determinista en el borde exacto (`max_tape_bytes - 1`, `max_tape_bytes`, `max_tape_bytes + 1`) que verifica transición a `NonReproducibleTruncated` sin abortar el proceso |
| Tamaño de artefactos (`PERF.ARTIFACT.SIZE`) | Respetar los topes vigentes autorizados (`≤ 5 MiB` en `ios-arm64` y `≤ 900 KiB` en Wasm con Brotli) | Medición al cierre si se activa el disparador de crecimiento de runtime (§7.1) |

### 6.2 Seguridad y confinamiento (`E-PG-09`, matriz STRIDE §9.3)

- **Cero autoridad ambiental (`R-08`, `K-06`):** Ningún opcode de la VM ni función de `pseudolearn_aot_rt` invoca
  `std::fs`, `std::env` ni `std::time` directamente; toda operación atraviesa `HostCapabilityProvider`.
- **Invariante de no amplificación:** Una capacidad hija (`subdirectorio` o `abrir_archivo`) verifica que
  `child_rights ⊆ parent_rights` y resuelve la ruta exclusivamente mediante `cap_std::fs::Dir`, rechazando `..` que
  escape de la raíz, rutas absolutas y enlaces simbólicos hacia fuera del árbol concedido.
- **Invalidación generacional:** Cerrar un `ArchivoCap` o `DirectorioCap` incrementa la generación de su ranura en
  `CapabilityTable`; cualquier `CapabilityToken` previo con generación obsoleta produce deterministamente
  `Resultado::Err(ErrorES::CapacidadCerrada)`.
- **Secretos fuera de la cinta (`PG-3.10`, `K-07`):** Todo argumento clasificado como secreto se reemplaza antes de
  serializar por `SecretRef { key_id, value_hmac }`, impidiendo fugas de credenciales en archivos de cinta o reportes de
  fallo.

---

## 7. Pruebas y experimentos

### 7.1 Política de pruebas acotadas

Esta política aplica la instrucción explícita de la persona y la constancia de §0. Es **obligatoria** en todas las
iteraciones de `PG-3` y en su cierre.

**Se ejecuta en cada iteración**, únicamente sobre las piezas desarrolladas o modificadas:

| Qué se verifica | Cómo se acota | Comando de referencia |
|---|---|---|
| Casos del corpus de cada contrato tocado | `--only <ID>` para los contratos editados o creados en la iteración | `cargo run --locked -p see_cli --bin see -- conform --subject engine --only <ID>` (y `--subject aot --only <ID>` si aplica) |
| Integridad del corpus | Solo cuando la iteración crea o edita especificaciones `see/1` | `cargo run --locked -p see_cli --bin see -- validate`, `lock --check`, `export --check` |
| Tests espejo de los archivos Rust modificados | Por crate y por archivo de test o filtro de módulo | `cargo test -p <crate> --test <archivo>` o `cargo test -p <crate> <filtro>` |
| Verificadores estáticos rápidos de Rust | Solo sobre el crate tocado y el verificador de reglas de código | `cargo fmt --check`, `cargo clippy -p <crate> --all-targets -- -D warnings`, `rust-checks all .` |
| Adaptadores y modelos tocados en `apps/pseudolearn_app` | Solo los tests espejo de los archivos Dart modificados y los verificadores estáticos de límites/arquitectura | `dart run tool/check_limits.dart`, `flutter test test/architecture_test.dart`, `flutter test test/engine/rust/<archivo>_test.dart` |

**No se ejecuta por defecto** en ninguna iteración ni en el cierre:
- `cargo xtask verify` de ningún paquete,
- `cargo test --workspace`,
- `see conform --subject <sujeto>` sin `--only`,
- `flutter test` sobre toda la carpeta `test/` de `apps/pseudolearn_app`,
- `bash tool/bridge.sh clean-checkout` o `bash tool/wasm.sh test` salvo que se active su disparador cerrado,
- las campañas completas de rendimiento fuera del punto `PG-3.13`.

**Disparadores cerrados de ampliación.** Solo estos eventos autorizan ampliar la selección, y únicamente al alcance
indicado en la columna derecha:

| Disparador | Ampliación máxima permitida |
|---|---|
| Se añadió una palabra reservada nueva al léxico | Conjunto centinela léxico/sintáctico con `--only`: `LANG.LEXICAL.KEYWORD`, `LANG.LEXICAL.IDENTIFIER`, `LANG.PROFILE.VOCABULARY`, `LANG.PROFILE.TRANSLATION`, `LANG.SYNTAX.GRAMMAR`, más tests de `pseudolearn_syntax` |
| Se añadió o modificó una instrucción en `IR.INSTRUCTIONS` o en el despacho de bytecode | Tests unitarios de `pseudolearn_ir`, `pseudolearn_bytecode` y `pseudolearn_vm_dispatch`, más comparación de gemelos (`Fast`/`Probed`) acotada a los contratos de la iteración |
| Cambió el contrato JSON de `pseudolearn_api` consumido por `apps/pseudolearn_app` | Tests Dart del adaptador consumidor en `test/engine/rust/` y `bash tool/test_bridge.sh` |
| Cambió `Cargo.lock` o una dependencia en `Cargo.toml` | `cargo deny check` en el paquete afectado |
| Creció el runtime estático enlazado en AOT/Wasm | Medición puntual de `PERF.ARTIFACT.SIZE` al cerrar la iteración que lo modifica |
| Falló un test acotado por una causa en un crate vecino | Los tests del módulo vecino implicado, una sola vez |

### 7.2 Matriz mínima de comportamiento (`TEST-BOTH-PATHS`)

| Punto | Camino feliz | Camino infeliz | Casos límite explícitos |
|---|---|---|---|
| `.01` Confirmación (`CF-07`) | Efecto solicitado y confirmado (`Committed`) queda grabado con su `effect_seq` | Efecto rechazado antes de mutar (`Failed`) o interrumpido tras cruzar al anfitrión (`Uncertain`) | Secuencia de dos efectos en una misma sentencia; lectura fallida nunca se marca `Uncertain` |
| `.02` Fallo vs anfitrión (`CF-11`) | `Resultado::Err(ErrorES)` manejado en el programa ejecuta `Diferir` y continúa | Trampa no recuperable (`failed`) o corte del anfitrión (`cancelled`/`AbortedByHost`) | Cancelación del anfitrión justo durante `awaiting_effect` sella cinta `Incomplete` sin ejecutar efectos nuevos en `Diferir` |
| `.03` Capacidades | Intersección `requested ∩ granted`, lectura/escritura relativa a `DirectorioCap`, reloj y temporizador | Denegación por defecto sin permiso, intento de amplificar lectura a escritura, escape con `..` o symlink, uso tras `cerrar` | Archivo de `0` bytes, nombre de `1` carácter, subdirectorio anidado de `3` niveles |
| `.04` Esquema de cinta | Grabación y serialización determinista de identidad y entradas con hash encadenado | Rechazo de esquema con versión desconocida | Ejecución con `0` efectos nuevos; preservación exacta de grabaciones de `Leer` |
| `.05` Tres modos | `LiveRecord` → `ReplayFromTape` → `HistorySeek` con idéntica salida y estado | Intento de tocar el anfitrión durante `ReplayFromTape` o `HistorySeek` | `seek` al evento `0`, al último evento y retroceso repetido sobre puntos con efectos |
| `.06` Rechazo de cinta | Cinta íntegra reproduce hasta `completed` | Código fuente distinto, argumento distinto, cinta truncada, byte adulterado en `entry_hash` | Truncamiento exactamente en la última entrada; alteración de `1` bit en `payload_bytes` |
| `.07` `awaiting_effect` | Suspensión en `awaiting_effect` y reanudación con `effect_result` | Enviar `input` cuando se espera `effect_result` o viceversa | Programa que combina `Leer` (`awaiting_input`) y archivo/reloj (`awaiting_effect`) en el mismo bucle |
| `.08` Pureza transitiva | `Funcion` pura con llamadas y clausuras puras; `SubProceso` con efectos | `Funcion` que llama a `SubProceso` con efecto, invoca clausura con efecto o realiza método `Funcion` de `Interfaz` con efecto | Recursión mutua de `3` funciones donde la última lee el reloj; interfaz mixta (`Funcion` + `SubProceso`) |
| `.09` `Bytes`, `ErrorES` y `Diferir` | E/S de `Bytes`, E/S de `Cadena` UTF-8, `Diferir cerrar(f)` en retorno normal y en `Propagar` | Secuencia UTF-8 inválida (`0xFF`) produce `ErrorES::Utf8Invalido`; error secundario al cerrar en `Diferir` no oculta el `ErrorES` primario | `Bytes` vacío (`0` elementos), UTF-8 de `4` bytes en borde de lectura, dos bloques `Diferir` anidados cerrando dos archivos en orden inverso |
| `.10` Privacidad y tope | Secreto reemplazado por `SecretRef` y cinta dentro de `max_tape_bytes` | Reproducción de cinta redactada sin almacén de secretos o de cinta truncada por `max_tape_bytes` (`replay_non_reproducible`) | Entrada cuyo tamaño hace alcanzar exactamente `max_tape_bytes` |
| `.11` Anfitrión falso | Casos `see/1` con archivos en memoria, reloj y argumentos derivados de las reglas | Caso con esquema `anfitrion` inválido rechazado por `see validate` | Inyección declarativa de fallo `Uncertain` y verificación de cinta en una sola pasada `grabar_y_reproducir` |
| `.12` Paridad AOT + App | Cinta grabada en VM reproducida en AOT y viceversa; `pseudolearn_app` proyecta vista, ayuda y ejecuta con capacidades simuladas | Divergencia de cinta en AOT falla con el mismo código que en VM; `--observe` y `--seek` rechazados en AOT | Modo archivo único en `pseudolearn_app` ejecutando un programa con reloj y archivo simulado sin `pseudolearn.toml` |

### 7.3 Experimento `E-PG-05` · Sobrecosto de cinta e infraestructura de capacidades

1. **Control:** Ejecución de `PERF.SUITE.CORE` antes de introducir `Opcode::EffectCall` y `EffectTape`.
2. **Tratamiento inactivo:** Ejecución de `PERF.SUITE.CORE` con el binario que incluye la infraestructura de `PG-3` (sin efectos activos en los programas de la suite).
3. **Tratamiento activo:** Cargas sembradas de `100`, `1 000` y `10 000` efectos (`consola`, `reloj`, `archivo` de `64 B` y `4 KiB`) midiendo tiempo en `LiveRecord`, tiempo en `ReplayFromTape` y bytes de cinta por efecto.
4. **Criterio de éxito:** Sobrecosto en `PERF.SUITE.CORE` `≤ 2 %`; crecimiento lineal $O(N)$ del tamaño de cinta y corte limpio al alcanzar `max_tape_bytes`.

### 7.4 Experimento `E-PG-09` (porción de archivos y cinta) · Confinamiento y no amplificación

1. **Vectores de prueba automatizados:**
   - Escape por ruta relativa (`../secreto.txt`, `sub/../../fuera.txt`).
   - Escape por ruta absoluta (`/etc/passwd`, `C:\Windows\...`).
   - Escape por enlace simbólico dentro del directorio concedido que apunta fuera de la raíz.
   - Amplificación de derechos: intentar abrir en modo escritura desde un `DirectorioCap` concedido solo en `archivos_lectura`, o derivar un subdirectorio con más derechos que el padre.
   - Uso tras cierre (`use-after-close`) de un `ArchivoCap` o `DirectorioCap`, verificando rechazo por generación obsoleta (`CapacidadCerrada`).
   - Adulteración de un bit en `EffectTape` y truncamiento de entradas durante `ReplayFromTape`, verificando rechazo inmediato y `0` llamadas al sistema operativo.
2. **Criterio de éxito:** `100 %` de los vectores bloqueados con diagnóstico o `ErrorES` determinista y `0` accesos fuera de la raíz confinada.

### 7.5 Procedencia

Las mediciones de `E-PG-05` en `.13` se ejecutan una sola vez en segundo plano en perfil `release` siguiendo
`PERF.PROTOCOL` (al menos `10` procesos × `30` muestras por carga, intervalo de confianza bootstrap al `95 %` y registro
completo de revisión Git, toolchain, hardware y semilla).

---

## 8. Riesgos y señales tempranas

| Riesgo | Señal temprana | Mitigación y evidencia |
|---|---|---|
| `K-06` Fuga de autoridad o escape de directorio | Cualquier llamada a `std::fs` fuera de `cap-std` o resolución de ruta sin `DirectorioCap` | Prohibición arquitectónica de `std::fs` en `pseudolearn_vm`/`pseudolearn_aot_rt`; confinamiento en `capability_fs.rs` con `cap_std::fs::Dir`; batería `E-PG-09` |
| `K-07` Explosión de tamaño de cinta o fuga de secretos | La cinta crece sin cota en un bucle de lectura/escritura o serializa credenciales en texto plano | Presupuesto `max_tape_bytes` con transición a `NonReproducibleTruncated` y redacción obligatoria con `SecretRef` (`.10`) |
| `K-13` Función pura que esconde efectos por clausura o interfaz | Una `Funcion` invoca un parámetro de tipo función o un método de interfaz cuya implementación realiza E/S | Pase `effect_check.rs` sobre el grafo cerrado en `pseudolearn_semantic` que valida llamadas directas, clausuras e implementaciones de interfaz (`.08`) |
| `PG3-R01` Sobrecosto en el bucle rápido de la VM (`Fast`/`Probed`) | `PERF.SUITE.CORE` empeora más del `2 %` o aumenta el número de instrucciones emitidas en programas puros | Opcode dedicado `Op::EffectCall` fuera del camino de opcodes puros y alojamiento perezoso de `EffectSession`; comprobación temprana del bytecode emitido |
| `PG3-R02` Divergencia entre VM y Cranelift AOT en efectos o cinta | Una cinta grabada en VM falla al reproducirse en AOT o produce distinto `entry_hash` | Disposición única en `pseudolearn_abi` y uso de la misma librería de cinta y tabla de capacidades a través de `pl_aot_effect_call` en `pseudolearn_aot_rt` (`.12`) |
| `PG3-R03` Desfase de `apps/pseudolearn_app` ante la sintaxis y terminación nuevas | Un programa con capacidades o `Bytes`/`ErrorES` produce nodos desconocidos en `rust_program_view.dart` o estado desconocido al suspender en `awaiting_effect` | Actualización sincronizada de `TOOL.SERVICE.CATALOG`, `API.PROGRAM.VIEW` y de los adaptadores de `apps/pseudolearn_app/lib/engine/rust/` en la Iteración 4 |

---

## 9. Dependencias de la persona

| Momento | Dependencia | Estado / Efecto |
|---|---|---|
| Antes de iniciar las iteraciones de implementación | Creación y revisión de este plan detallado (`PG-3.C02`) | **Cumplido el 2026-10-26** (aprobado por la persona junto con `CF-11`, vocabulario bilingüe y alcance de evolución de `pseudolearn_app`) |
| Para iniciar cada iteración de §10 | Autorización explícita de la persona en un mensaje nuevo (`PG-3.C01`, `PHASE-STOP`) | Sin ese mensaje no se escribe especificación ni código de la iteración |
| Al cerrar contratos nuevos del corpus | Revisión de la persona para el campo `revisado_por` y autorización de `lock --refresh` en las especificaciones editadas | Se mantiene `SPEC-VERSION-FREEZE` (`1.0.0` estable sin bloque `cambio`) |
| Al cerrar la fase | Revisión del resumen de cierre, resultados de `E-PG-05`/`E-PG-09` y publicación en la rama única | No autoriza automáticamente `PG-4` ni `PG-A`/`PG-B` |

---

## 10. Orden de ejecución y puntos de control

Cada iteración requiere autorización propia y se detiene al concluir (`PHASE-STOP`).

| Iteración | Puntos incluidos | Depende de | Evidencia acotada para dar por cerrada la iteración |
|---|---|---|---|
| **1 · Corpus normativo de capacidades, confirmación, pureza y cinta** | Especificación y casos (`*.01`, `*.02`) de `PG-3.01` a `PG-3.11` | Plan revisado | `see validate`, `lock --check` (tras reanclar los IDs autorizados) y `check_limits.py` en verde |
| **2 · Compilador: permisos de manifiesto, tipos de capacidad/`Bytes`/`ErrorES` y pureza transitiva** | Implementación y tests (`*.03`–`*.06`) de `PG-3.03` (parte estática y manifiesto), `PG-3.08` y `PG-3.09` (tipos y lowering con `Diferir`) | Iteración 1 | `rust-checks all .`, Clippy y tests acotados de `pseudolearn_project`, `pseudolearn_syntax`, `pseudolearn_semantic`, `pseudolearn_lowering` y `pseudolearn_ir`; conformidad `--only API.PROJECT.MANIFEST,LANG.CAPABILITY.PURITY` en verde |
| **3 · Runtime VM, tabla de capacidades confinada, cinta `pseudolearn.tape/v1`, `awaiting_effect` y anfitrión falso** | Implementación y tests (`*.03`–`*.06`) de `PG-3.01`, `PG-3.02`, `PG-3.03` (runtime), `PG-3.04`, `PG-3.05`, `PG-3.06`, `PG-3.07`, `PG-3.09` (runtime), `PG-3.10` y `PG-3.11` | Iteración 2 | Conformidad `--subject engine --only` de todos los contratos de `PG-3` en verde con `FakeHostProvider` (cero accesos a disco/red real); tests espejo de `pseudolearn_runtime`, `pseudolearn_vm`, `pseudolearn_timeline` y `pseudolearn_api` en verde |
| **4 · Paridad con Cranelift AOT, CLI y evolución sincronizada de `apps/pseudolearn_app`** | `PG-3.12` completo más proyección de vista pública, catálogo de ayuda y adaptadores de `apps/pseudolearn_app` (`PG-3.07.04`, `PG-3.09.04`) | Iteración 3 | Conformidad `--subject aot --only` de los contratos de `PG-3` en verde; tests acotados de `pseudolearn_codegen`, `pseudolearn_aot_rt` y `apps/pseudolearn_cli` en verde; `check_limits.dart`, `architecture_test.dart` y tests espejo de `test/engine/rust/` en `apps/pseudolearn_app` en verde |
| **5 · Experimentos `E-PG-05` y `E-PG-09`, READMEs dueños y cierre común (`PG-3.13`, `C01`–`C13`)** | `PG-3.13` y lista de cierre común `PG-3.C01`–`PG-3.C13` | Iteración 4 | Campañas `E-PG-05` (`≤ 2 %` en `PERF.SUITE.CORE`) y `E-PG-09` (`0` fugas) registradas en §11; unión acotada de los contratos de `PG-3` en verde; commit y push ordinario a `feature/agregar-ruta-de-especificacion` |

### 10.1 Verificaciones ejecutables por iteración

1. **Desde `packages/pseudolearn_spec` (agrupadas en una sola invocación cuando se toca el corpus):**
   - `python3 tool/check_limits.py`
   - `cargo run --locked -p see_cli --bin see -- validate`
   - `cargo run --locked -p see_cli --bin see -- lock --check` (tras `lock --refresh <IDs>` de los documentos editados)
   - `cargo run --locked -p see_cli --bin see -- conform --subject engine --only <IDs_PG3>`
   - `cargo run --locked -p see_cli --bin see -- conform --subject aot --only <IDs_PG3>` (en la Iteración 4 y cierre)
2. **Desde `packages/pseudolearn_engine`:**
   - `cargo fmt --check`
   - `cargo clippy -p <crate_tocado> --all-targets -- -D warnings`
   - `cargo test -p <crate_tocado> --test <test_espejo>` (o filtro del módulo tocado)
   - `cargo run --manifest-path ../pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command --bin rust-checks -- all .`
3. **Desde `apps/pseudolearn_cli` y `apps/pseudolearn_app` (Iteración 4):**
   - En `apps/pseudolearn_cli`: `cargo test -p pseudolearn_cli <filtro>` y `rust-checks all .`.
   - En `apps/pseudolearn_app`: `dart run tool/check_limits.dart`, `flutter test test/architecture_test.dart` y `flutter test test/engine/rust/<archivo_tocado>_test.dart`.

---

## 11. Resumen de ejecución

### 11.1 Registro por tarea

| Tarea | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| Preparación y revisión del plan (`PG-3.C02`) | Cumplido | Este documento (`fase-pg-3-plan-ejecucion.md`) aprobado por la persona el `2026-10-26` sobre la revisión inicial `5f6b4b9` | Quedan fijados el diseño a medida (§3), la política de pruebas acotadas (§7.1) y la evolución sincronizada de `apps/pseudolearn_app` |
| Resolución de diseño de `CF-11` (`PG-3.02`) y vocabulario bilingüe (`PG-3.03`) | Cumplido en diseño | Aprobación del plan detallado el `2026-10-26` | Pendiente de plasmar como texto normativo y casos en la Iteración 1 |

Contratos de `PG-3` para la selección acotada: se listarán aquí conforme se creen y editen en la Iteración 1.

Selección de pruebas ejecutadas y omitidas por iteración: se registrará aquí al cerrar cada iteración.

Revisión Git de cierre: · Verificadores ejecutados: · Pendientes justificados: · Puntos de §4 cumplidos:
