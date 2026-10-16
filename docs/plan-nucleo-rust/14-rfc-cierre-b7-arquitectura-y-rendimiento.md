# RFC-014 · Diagnóstico arquitectónico de Remanso (R5) y especificación ejecutable de cierre de B7

**Estado:** **Aprobado** por la persona responsable el 2026-10-16 (listo para ejecución etapa por etapa con `PHASE-STOP`)
**Fecha:** 2026-10-16
**Rama:** `feature/agregar-ruta-de-especificacion` (`GIT-SINGLE-BRANCH`)
**Ámbito:** `packages/pseudolearn_engine`, `packages/pseudolearn_spec`, `packages/pseudolearn_benchmarks`
**Relacionado con:** [00-adr-001](00-adr-001-nucleo-en-rust.md), [11-plan-r5-ejecucion-remanso](11-plan-r5-ejecucion-remanso.md) (§B7 y «Relevo de B7»), [12-encargo-analisis-cierre-b7](12-encargo-analisis-cierre-b7.md)

---

## 0. Reglas innegociables para la IA que ejecute este plan (cero alucinación)

La IA encargada de implementar las etapas de este documento **DEBE** cumplir sin excepción:

1. **Verificadores mecánicos (`AGENTS.md` §2 y §4):**
   - **Cero comentarios en código (`QUALITY-NO-COMMENTS`):** prohibido escribir `//`, `/* */`, `///`, `#![doc]` o `#[allow]`/`#[expect]` en ningún archivo `.rs`.
   - **Sin `panic` ni índices inseguros (`QUALITY-NO-PANIC`):** prohibidos `unwrap()`, `expect()`, `panic!()`, `todo!()`, `unreachable!()`, indexación directa `slice[i]` (usar `.get(i)` / `.get_mut(i)`), `as` numéricos con pérdida (usar `try_from` / `from`) y aritmética implícita (usar `.checked_add`, `.saturating_add`, `.wrapping_shl`, etc.).
   - **Nombres semánticos (`QUALITY-SEMANTIC-NAMES`):** ningún identificador en Rust puede tener menos de 3 caracteres salvo `id`, `io`, `ir`, `vm`, `gc`, `os`; prohibidas abreviaturas (`idx`, `len`, `ptr`, `val`, `src`, `dst`, `obj`, `arr`, `cfg`, `ctx`, `err`, `msg`, `num`, `res`, `ret`, `str`, `tmp`, etc.) y nombres de archivo `utils.rs`, `helpers.rs`, `common.rs` o `misc.rs`.
   - **Límites de tamaño (`SIZE-*` en `packages/pseudolearn_engine/architecture.yaml`):**
     - Máximo **300 líneas** por archivo de producción (`max_file_lines: 300`).
     - Máximo **50 líneas** por función (`max_function_lines: 50`).
     - Máximo **3 parámetros posicionales** por función (`max_positional_params: 3`, sin contar `self`); si una función necesita más datos, agruparlos en una tupla o estructura con nombre semántico.
     - Máximo **3 niveles de anidación** dentro de una función (`max_nesting_depth: 3`).
     - Máximo **12 funciones públicas** por módulo (`max_public_functions: 12`).
   - **Prohibido `unsafe`:** todos los crates tocados en este plan mantienen `#![forbid(unsafe_code)]`.
2. **Protocolo de seguridad de recursos (incidente previo de > 26 GB de RAM):**
   - Antes de cualquier compilación o campaña, comprobar espacio en disco (`df -h /System/Volumes/Data`; requiere $\ge 3\text{ GiB}$ libres).
   - Nunca ejecutar `cargo-mutants`, experimentos ni pruebas pesadas sin `--timeout 30` y sin límite de paralelismo (`--in-place` en `cargo-mutants`, un crate a la vez).
3. **Disciplina de fases (`PHASE-STOP` y `PHASE-GREEN`):**
   - Cada etapa (Etapa 1 a Etapa 6) debe cerrar con tests y `cargo xtask verify` en verde antes de pasar a la siguiente. No hacer `git push` sin autorización explícita.

---

## 1. Problema y evidencia medida

Al llegar al bloque de cierre **B7** de la fase R5 («Remanso»), el motor ejecuta toda la suite `AWFY-core` y pasa 325/325 casos de conformidad, pero presenta cuatro brechas técnicas que impiden declarar que PseudoLearn sea el lenguaje rápido, austero en memoria y verificable que fijó el diseño:

1. **Rendimiento no observado (`PERF.VM.THROUGHPUT`, `B7.7`):** la media geométrica frente a `reference` (`macos-r3-awfy`) cayó de **63,44×–76,7×** en el trazador escalar de B3 a **16,44×** en la VM completa de B7 (mínimo **7,53×** en `storage`), lejos del objetivo de diseño de **30×** (`PERF.VM.THROUGHPUT#M3`).
2. **Coste físico de estado, puntos de control y reproducción (`PERF.VM.STEP-LATENCY`, `E-06`, `B7.1`):**
   - En `E-06`, el percentil 95 de retroceso + consulta (`PERF.VM.STEP-LATENCY#M3`) en `storage-10` es **59,02 ms**, violando el umbral de **50 ms**.
   - El montón base en `E06-RSS` consume **106,0 MB de RSS para 22,3 MB de palabras útiles** (**4,75×** de sobrecoste estructural antes de grabar un solo punto de control) y **173,8 MB adicionales** al retener 12 puntos de control (**7,77×** sobre las palabras vivas).
   - La captura diferencial de una pila de 100 000 marcos (`E06-STACK`) tarda **972,38 µs** por punto de control aunque solo haya cambiado el marco superior.
   - La sesión pública (`pseudolearn_api::ExecutionResource`) **no utiliza `pseudolearn_timeline`**: mantiene su propio vector de hasta 128 copias íntegras de `MachineImage` (`Arc<MachineImage>`) y suspende/clona la máquina en cada lote.
3. **Supervivientes y coste de la campaña de mutación (`E-16`):**
   - La campaña sobre `pseudolearn_timeline` arrojó **71/147 mutantes cazados (48,3 %)** frente al umbral de **≥ 85 %**, con **76 supervivientes** concentrados en código duplicado o desconectado de `pseudolearn_api`.
   - Los 6 crates de la campaña suman **2 845 mutantes** (`lowering` 400, `bytecode` 442, `runtime` 618, `vm` 624, `library` 614, `timeline` 147), cuya ejecución ingenua sin acotar paquetes ni podar código muerto desborda el tiempo de campaña.
4. **Cierres pendientes de puerta (`E-17` y `B7.4`):**
   - `E-17` ([`r5-e17.json`](../../packages/pseudolearn_spec/results/r5-e17.json)) sigue en `"status": "partial"` porque se midió antes de integrar objetos y cadenas completas.
   - `B7.4` ([`r5-differential.json`](../../packages/pseudolearn_spec/results/r5-differential.json)) registra 208 diferencias residuales con `reference` (rangos léxicos finos frente a rangos de línea completa en Dart y advertencias de análisis en `execute`).

### 1.1. Desglose medido de `AWFY-core` (`macos-r5-vm` frente a `macos-r3-awfy`)

Datos extraídos de [`packages/pseudolearn_benchmarks/results/macos-r5-vm/summary.json`](../../packages/pseudolearn_benchmarks/results/macos-r5-vm/summary.json) y [`packages/pseudolearn_benchmarks/results/macos-r3-awfy/summary.json`](../../packages/pseudolearn_benchmarks/results/macos-r3-awfy/summary.json) en Apple M2 (`macos-arm64`):

| Programa | Mediana `reference` (µs) | Mediana `engine` VM (µs) | Aceleración (`×`) | Perfil dominante de ejecución |
|---|---:|---:|---:|---|
| `mandelbrot` | 164 687,1 | 2 768,8 | **59,48×** | Aritmética escalar pura (`i64`/`f64`) y saltos en bucle |
| `sieve` | 11 066,4 | 496,2 | **22,30×** | Bucle con lecturas y escrituras en arreglo 1D de enteros |
| `towers` | 9 752,1 | 509,4 | **19,14×** | Llamadas recursivas + campos de objetos + arreglo 1D |
| `permute` | 57 075,8 | 3 178,8 | **17,96×** | Llamadas recursivas + intercambios en arreglo 1D |
| `queens` | 11 275,0 | 759,2 | **14,85×** | Llamadas + lecturas/escrituras intensivas en arreglos 1D |
| `richards` | 170 130,0 | 11 458,0 | **14,85×** | Despacho virtual (`call.virtual`) + lectura/escritura de campos |
| `list` | 32 396,2 | 2 197,5 | **14,74×** | Asignación de objetos + recorrido de lista enlazada por campos |
| `nbody` | 21 293,7 | 1 566,9 | **13,59×** | Matemática `f64` + lectura/escritura masiva de campos de objetos |
| `bounce` | 41 008,2 | 4 316,0 | **9,50×** | Bucle de objetos en arreglo + llamadas a métodos + campos |
| `storage` | 9 206,3 | 1 222,3 | **7,53×** | Asignación recursiva de árbol de arreglos (`array.new`) y GC |
| **Media geométrica** | — | — | **16,44×** | M1 (≥ 10×): pasa · M2 (≥ 5×): pasa (7,53×) · **M3 (≥ 30×): NO alcanzada** |

### 1.2. Desglose medido de `E-06` y `E-16`

Datos extraídos de [`packages/pseudolearn_spec/results/r5-e06.json`](../../packages/pseudolearn_spec/results/r5-e06.json):

| Prueba / Subexperimento | Métrica medida | Valor actual | Umbral / Presupuesto | Estado |
|---|---|---:|---:|---|
| `AWFY` paso observado (`M2`) | `step_p95_ms` máximo (`towers-13`) | 0,0404 ms | ≤ 0,10 ms | Pasa |
| `AWFY` retroceso + consulta (`M3`) | `rewind_p95_ms` en `storage-10` | **59,02 ms** | **≤ 50,00 ms** | **Falla (+18 %)** |
| `AWFY` retroceso + consulta (`M3`) | `rewind_p95_ms` en `permute-6` | **48,91 ms** | ≤ 50,00 ms | Al límite (97,8 % del presupuesto) |
| `E06-ARRAY` (200 000 celdas, 1 escritura/paso) | `capture_p95_us` / `retained_slots` | 21,96 µs / 1 560 | < 50 µs | Pasa |
| `E06-STACK` (100 000 marcos activos) | `capture_p95_us` | **972,38 µs** | ~O(cambios en tope) | **Degradación lineal O(profundidad)** |
| `E06-RSS` (montón de 22,33 MB útiles) | `baseline_rss_bytes` (sin puntos de control) | **106,02 MB** | ~25–30 MB | **4,75× sobre palabras vivas** |
| `E06-RSS` (12 puntos de control retenidos) | `rss_overhead_bytes` / `rss_ratio_to_heap` | **173,83 MB** | ≤ 2,0× | **7,77× sobre palabras vivas** |

Distribución de los **76 supervivientes** de `pseudolearn_timeline` en `E-16` (147 mutantes totales, 71 cazados = 48,3 %):

| Archivo en `pseudolearn_timeline/src/` | Supervivientes | Causa raíz |
|---|---:|---|
| `deltas.rs` | 19 | Diferenciador de `StateSnapshot` completos desconectado de `pseudolearn_api` (que usa `state_changes.rs`) y de `ChangeBuffer` de la VM |
| `inspect.rs` | 17 | Construcción de `ObjectView` (con nombres ficticios `campo_{i}`) y formateo de tipos duplicados en `pseudolearn_api/src/execution_state.rs`; 0 tests sobre objetos |
| `thinning.rs` | 10 | Desempates (`<` vs `<=`) y aritmética saturada de segmentos sin tests de frontera |
| `array_view.rs` | 8 | `extract_array_cells`, `extract_array_slice` y `linear_to_indices` sin un solo test en `tests/` |
| `cell_view.rs` | 8 | `inspect_cell` e `inspect_managed_cell` (alias `Por Referencia`) sin tests en `tests/` |
| `timeline.rs` | 7 | Guardas de índice y horizonte (`>=` vs `>`) sin casos límite |
| `replay.rs` | 3 | Condiciones de parada en `replay_machine_to_event` |
| `error.rs`, `model.rs`, `query_views.rs`, `store.rs` | 4 (1 c/u) | Ramas `Display`, `display_representation` y consulta |

---

## 2. Causas raíz: qué es de Rust y qué es de la arquitectura

En `mandelbrot` (59,48×), donde solo intervienen registros escalares y las instrucciones generadas en B3, la VM duplica el objetivo de 30× con `#![forbid(unsafe_code)]`. La caída a 16,44× se debe a **seis causas de arquitectura e implementación en B4–B6**:

| Factor | Origen | Impacto medido | Ubicación exacta |
|---|---|---|---|
| Ausencia de *computed goto* y comprobación de límites en `scalars[idx]` | **Lenguaje Rust (`#![forbid(unsafe_code)]`)** | Bajo (~10–15 % en escalares; ya mitigado con `pc & mask`) | En `mandelbrot` la VM logra **59,48×** con `match` estándar |
| **Causa A1:** Cada lectura o escritura de campo (`obj.campo`) se baja a **dos instrucciones** (`cell.field` + `cell.load`/`cell.store`) y empuja una entrada en `machine.cells: Vec<Cell>` que **no se libera hasta que retorna la función** | **Arquitectura / Implementación (B4)** | **Crítico** en `nbody`, `bounce`, `richards`, `list`, `towers` | [`expressions_complex.rs:125-161`](../../packages/pseudolearn_engine/crates/pseudolearn_lowering/src/expressions_complex.rs#L125-L161), [`statements_assignment.rs:68-96`](../../packages/pseudolearn_engine/crates/pseudolearn_lowering/src/statements_assignment.rs#L68-L96), [`cells.rs:38-53`](../../packages/pseudolearn_engine/crates/pseudolearn_vm/src/machine/cells.rs#L38-L53) |
| **Causa A2:** El montón mantiene una tabla lateral `BTreeMap<Handle, Allocation>` consultada entre **2 y 5 veces** por cada acceso a arreglo o campo, y clonada/insertada en cada `allocate` | **Arquitectura (`pseudolearn_runtime`)** | **Crítico** en `storage` (7,53×), `queens`, `sieve`, `bounce` y **causa del 4,75× de RSS en `E06-RSS`** | [`heap/mod.rs:55`](../../packages/pseudolearn_engine/crates/pseudolearn_runtime/src/heap/mod.rs#L55), [`array.rs:42-166`](../../packages/pseudolearn_engine/crates/pseudolearn_runtime/src/array.rs#L42-L166), [`object.rs:28-126`](../../packages/pseudolearn_engine/crates/pseudolearn_runtime/src/object.rs#L28-L126), [`heap/definition.rs:4-101`](../../packages/pseudolearn_engine/crates/pseudolearn_runtime/src/heap/definition.rs#L4-L101) |
| **Causa A3:** Todas las operaciones de memoria se pliegan en `Op::Memory { site }` con doble indirección (`current.memory[site]`), y cada `ArrayRead`/`ArrayWrite` **asigna un `Vec<i64>` en el montón del sistema** (`read_indices`) | **Arquitectura (`pseudolearn_vm`)** | **Alto** en `sieve`, `queens`, `permute`, `bounce`, `nbody` | [`machine/memory.rs:19-46`](../../packages/pseudolearn_engine/crates/pseudolearn_vm/src/machine/memory.rs#L19-L46), [`machine/memory.rs:111-116`](../../packages/pseudolearn_engine/crates/pseudolearn_vm/src/machine/memory.rs#L111-L116) |
| **Causa A4:** En cada `return` (`finish_call`) se asigna un `String` (`to_owned()`) aunque `probed == false`; en cada `call.virtual` se parte un `String` y se busca en `BTreeMap<String, u16>`; en cada `array.new`/`object.new` se construye `Vec<Handle>` de raíces recorriendo toda la pila antes de saber si habrá GC | **Implementación (`pseudolearn_vm`)** | **Alto** en `storage`, `list`, `richards`, `towers`, `permute`, `queens` | [`machine/calls.rs:88-98`](../../packages/pseudolearn_engine/crates/pseudolearn_vm/src/machine/calls.rs#L88-L98), [`machine/calls.rs:228-237`](../../packages/pseudolearn_engine/crates/pseudolearn_vm/src/machine/calls.rs#L228-L237), [`machine/memory.rs:90-108`](../../packages/pseudolearn_engine/crates/pseudolearn_vm/src/machine/memory.rs#L90-L108), [`machine/roots.rs:6-48`](../../packages/pseudolearn_engine/crates/pseudolearn_vm/src/machine/roots.rs#L6-L48) |
| **Causa A5:** `compile_module` desactiva por omisión `SuperInstruction::CompareBranch`, por lo que ni el trabajador de benchmarks ni `pseudolearn_api` la usan | **Implementación (`pseudolearn_bytecode`)** | **Medio** en todos los bucles con condición (`sieve`, `queens`, `permute`, `nbody`, `bounce`) | [`bytecode/src/compile.rs:56-58`](../../packages/pseudolearn_engine/crates/pseudolearn_bytecode/src/compile.rs#L56-L58), [`vm_runner.rs:64`](../../packages/pseudolearn_engine/crates/pseudolearn_bench_worker/src/vm_runner.rs#L64) |
| **Causa A6:** Doble sistema de puntos de control (`pseudolearn_api` ignora `pseudolearn_timeline` y guarda 128 `Arc<MachineImage>` completos), más `BlockDelta::advance` que compara la capacidad potencia de dos no usada de `words`/`scalars`/`references` y clona los 100 000 marcos activos, más `replay_to_event` que reejecuta siempre en `TwinMode::Probed` | **Arquitectura (`timeline` + `api` + `vm/delta` + `runtime/delta`)** | **Crítico** en `B7.1`, `E-06` (`storage-10` 59,02 ms, `E06-STACK` 972 µs) y `E-16` (48,3 % de mutación) | [`execution_resource.rs:27-35`](../../packages/pseudolearn_engine/crates/pseudolearn_api/src/execution_resource.rs#L27-L35), [`machine/delta.rs:59-93`](../../packages/pseudolearn_engine/crates/pseudolearn_vm/src/machine/delta.rs#L59-L93), [`delta/heap.rs:32-49`](../../packages/pseudolearn_engine/crates/pseudolearn_runtime/src/delta/heap.rs#L32-L49), [`timeline/src/replay.rs:14-48`](../../packages/pseudolearn_engine/crates/pseudolearn_timeline/src/replay.rs#L14-L48) |

---

## 3. Contraste con la literatura y decisiones aprobadas

### 3.1. Qué se toma y qué se rechaza de cada fuente

| Área | Fuente / Referencia | Qué tomamos para PseudoLearn | Qué rechazamos y por qué |
|---|---|---|---|
| **VMs de registros y despacho** | **Lua 5.0 / 5.4** (Ierusalimschy et al., 2005) y **Dalvik / ART** | Instrucciones directas de 3 operandos para acceso a campos (`ObjectLoad`/`ObjectStore`) y arreglos 1D/2D sin asignar `Vec<i64>`; ranuras numéricas de métodos para despacho virtual `O(1)`; activación por omisión de fusión `CompareBranch` | Rechazamos *computed goto* en ensamblador o `unsafe` (`#![forbid(unsafe_code)]`) y rechazamos NaN-boxing porque nuestros bancos separados `scalars: Vec<u64>` / `references: Vec<u32>` ya evitan cajas y mantienen raíces exactas |
| **Montones planos y cabeceras en banda** | **SableVM** (Gagnon & Hendren, 2001), **V8 / Oilpan** e **Immix** (Blackburn & McKinley, 2008) | **Cabecera en banda** en `heap.words[handle.0..]` (`pseudolearn_abi`) con `status_flags` codificando el tipo/rango de arreglo o índice de clase, y eliminación de `BTreeMap<Handle, Allocation>` en lecturas/escrituras | Rechazamos recolectores generacionales concurrentes o barreras de escritura: el recolector marca-compacta a petición es suficiente cuando solo se invoca al agotarse el umbral y las cabeceras viven en banda |
| **Puntos de control diferenciales y reproducción** | **Young (1974) / Daly (2006)**, **libckpt** (bloques sucios acotados) y **rr / ODB** (reproducción híbrida rápida + instrumentada) | Diferenciación acotada a la porción viva (`words[..used]`, `scalars[..scalar_limit]`, `references[..reference_limit]`) y marca de agua de marcos (`frame_dirty_depth`); reproducción híbrida `TwinMode::Fast` $\to$ `TwinMode::Probed` | Rechazamos *copy-on-write* mediante `fork()` o `mprotect()` del sistema operativo porque el núcleo debe correr idénticamente en iOS, Android y `wasm32-unknown-unknown` |
| **Mutación dirigida y pruebas por propiedades** | **Papadakis et al. (2019)**, **Just et al. (2014)** y **QuickCheck / Proptest** (Claessen & Hughes, 2000) | Podar primero superficie duplicada/muerta (unificar `api` sobre `timeline`); propiedades de reconstrucción exacta e invariantes de frontera; `cargo-mutants` acotado por paquete con `--in-place --timeout 30` | Rechazamos tests tautológicos que copian la implementación y rechazamos lanzar toda la suite del workspace por cada mutante individual |

### 3.2. Decisiones aprobadas por la persona responsable (2026-10-16)

Las tres decisiones propuestas en este RFC han sido **aprobadas** y son vinculantes para la implementación:

- **D1 (Aprobada) · Unificación de `pseudolearn_api` sobre `pseudolearn_timeline` y poda de código duplicado:**
  Se elimina de `pseudolearn_timeline` la superficie duplicada que `pseudolearn_api` no consume (`deltas.rs` sobre `StateSnapshot` completo y la construcción de vistas de objetos con nombres ficticios `campo_{i}` en `inspect.rs`), y `pseudolearn_api::ExecutionResource` pasa a usar `CheckpointStore` / `ExecutionTimeline` de `pseudolearn_timeline` en lugar de almacenar un vector de `Arc<MachineImage>` completos.
- **D2 (Aprobada) · Alcance de mutación (`E-16`) en `pseudolearn_library`:**
  La campaña de mutación de `pseudolearn_library` evalúa el umbral de **≥ 85 %** sobre los módulos de contrato semántico (`integer`, `real`, `text`, `character`, `random`, `transcendental/elementary`), excluyendo con `--exclude-re` las tablas de coeficientes y aritmética interna multimantisa de `precision/` para evitar mutantes equivalentes y bucles lentos de convergencia de Ziv.
- **D3-a (Aprobada) · Resolución del diferencial `B7.4` (`r5-differential.json`):**
  1. `pseudolearn_api::execute` incluirá las advertencias estáticas producidas durante el análisis del programa (como `unusedVariable`) antes de los diagnósticos de ejecución, igualando el comportamiento observable de `reference`.
  2. La mayor precisión de los rangos léxicos (`span.end_col`) de Rust frente a los rangos de línea completa del núcleo Dart congelado se documenta formalmente como mejora deliberada en el informe diferencial.

---

## 4. Especificación ejecutable de las 6 etapas de cierre de B7

Cada etapa detalla **qué archivos tocar**, **qué estructuras y funciones exactas modificar**, **qué invariantes respetar** y **con qué comandos verificar** antes de pasar a la siguiente etapa.

---

### Etapa 1 · Montón plano en banda y `HeapDelta` acotado (`pseudolearn_abi` + `pseudolearn_runtime`)

#### Objetivo
Eliminar `allocations: BTreeMap<Handle, Allocation>` del camino crítico de lectura/escritura y de `HeapDelta`, haciendo que toda lectura/escritura de arreglos, objetos y celdas lea los metadatos en $O(1)$ directamente desde la cabecera en banda de `heap.words[handle.0..]`, y que `BlockDelta` opere únicamente sobre `heap.words[..heap.used]`.

#### Diseño exacto de la cabecera en banda (`pseudolearn_abi` y `pseudolearn_runtime`)
Actualmente, [`allocate.rs:25-27`](../../packages/pseudolearn_engine/crates/pseudolearn_runtime/src/heap/allocate.rs#L25-L27) escribe en `word(handle, 0)` solo el `shape_tag` (`1` para arreglo, `2` para texto, `3 + class` para objeto, `u32::MAX` para auxiliar) dejando los 32 bits superiores (`status_flags`) en `0`.
Con la cabecera en banda completa:
1. **Palabra 0 (`SHAPE_FLAGS_WORD_OFFSET = 0`) codificada con `CommonHeader::new(shape_tag, status_flags, ordinal)`:**
   - Para **Arreglos (`shape_tag == 1`):**
     - Bits `0..8` de `status_flags`: código de `ValueKind` (`0 = Integer`, `1 = Real`, `2 = Boolean`, `3 = Character`, `4 = Reference`).
     - Bits `8..16` de `status_flags`: `rank` (número de dimensiones, `u8`, $1 \le \text{rank} \le 255$).
     - Bit `16` de `status_flags`: `literal` (`0` o `1`).
   - Para **Objetos (`shape_tag >= 3 && shape_tag < u32::MAX`):**
     - `class_id = shape_tag - 3` (índice en `heap.layouts: Vec<ObjectLayout>`).
     - Bits `0..16` de `status_flags`: `payload_offset` (`u16`, desplazamiento donde empiezan los campos, calculado por `object_fields_start_offset`).
     - Bit `16` de `status_flags`: `literal` (`0` o `1`).
   - Para **Texto (`shape_tag == 2`):**
     - Bit `16` de `status_flags`: `literal` (`0` o `1`).
2. **Palabras 2..payload en Arreglos (`array_layout.rs`):**
   - `word(handle, 2)` (`ARRAY_TOTAL_ELEMENTS_WORD_OFFSET`): `elements` (`u64`, total de celdas).
   - `word(handle, 3)` (`ARRAY_DENSE_BOUNDARY_WORD_OFFSET`): en arreglos de enteros, guarda el contador de celdas de entero ya definidas (`assigned`); cuando `assigned == elements`, vale `elements` (habilitando el camino rápido denso `index < total` o `assigned == elements`). En arreglos no enteros, vale `elements`.
   - `word(handle, 4)` (`ARRAY_DEFINITION_MAP_WORD_OFFSET`): dirección absoluta en `heap.words` del mapa de bits de definición (para `ValueKind::Integer`), o `0` cuando todas las celdas están definidas o el elemento no es entero.
   - `word(handle, 5..5 + rank)` (`ARRAY_DIMENSION_EXTENTS_START_OFFSET`): **guardar siempre las `rank` dimensiones** también cuando `rank == 1` (en `array_layout.rs`, `array_elements_start_offset(rank)` ya reserva la palabra `5` cuando `rank == 1` porque devuelve `5` para `rank == 0` y `6` si se ajusta a `5 + rank`, o bien: en `array_layout.rs`, si `rank == 1`, `ARRAY_TOTAL_ELEMENTS_WORD_OFFSET` (palabra 2) **ya es `dimensions[0]`**! Por tanto: si `rank == 1`, la única dimensión es `word(handle, 2)` y los elementos empiezan en la palabra `5`; si `rank > 1`, las dimensiones viven en `5..5 + rank` y los elementos empiezan en `5 + rank`).
     - *Nota crítica para `array_dimensions(heap, handle)`*: como para `rank == 1` la dimensión `d_0` está en `word(handle, 2)` y para `rank > 1` las dimensiones están en `words[handle + 5 .. handle + 5 + rank]`, `array_dimensions(heap: &Heap, handle: Handle) -> Result<&[u64], MemoryError>` devuelve `&heap.words[addr + 2 .. addr + 3]` cuando `rank == 1`, y `&heap.words[addr + 5 .. addr + 5 + rank]` cuando `rank > 1`! Así `array_dimensions` sigue devolviendo `Result<&[u64], MemoryError>` con **cero asignaciones** y sin tocar ningún `BTreeMap`.
3. **Tabla de diseños de clase en `Heap` (`heap.layouts: Vec<ObjectLayout>`):**
   - Añadir `pub fn register_layout(&mut self, layout: ObjectLayout)` en `Heap` (o pasar `&[ObjectLayout]` al inicializar) de modo que `heap.layouts` contenga los `ObjectLayout` indexados por `layout.class as usize`. En `new_object` / `new_object_shared`, si `heap.layouts` aún no contiene `layout.class`, se registra automáticamente.
4. **Reemplazo de `allocations: BTreeMap<Handle, Allocation>` por metadatos compactos de bloques vivos:**
   - Para que el recolector (`collect.rs`) y `live_allocation_handles` (`snapshot.rs`) recorran únicamente los bloques vivos sin `BTreeMap<Handle, Allocation>`, `Heap` mantiene un vector ordenado o tabla ligera `blocks: Vec<BlockRecord>` (donde `BlockRecord` es un `Copy` de 16 bytes: `pub handle: Handle, pub physical: u32, pub cells: u64` — sin `Vec<u64>` ni `Arc<ObjectLayout>`).
   - Como `BlockRecord` es `Copy` y plano, en `read_element`, `write_element`, `read_field`, `write_field`, `read_memory_cell`, `write_memory_cell`, `integer_defined` y `define_integer` **NO se busca en `blocks`**: todo se lee en $O(1)$ desde `heap.words[handle.0..]` y `heap.layouts[class_id]`.
   - `blocks` solo se toca al asignar (`allocate`) y al recolectar (`collect`), y en `HeapDelta` se difiere con `BlockDelta<BlockRecord>` en lugar de `MapDelta<Handle, Allocation>`.
5. **Acotar `BlockDelta` en `HeapDelta` (`pseudolearn_runtime/src/delta/heap.rs`):**
   - En `advance_heap(tip: &mut Heap, live: &Heap)`, truncar o pasar a `BlockDelta::advance` únicamente la tajada usada `&live.words[..live.used]` (manteniendo `tip.words` de longitud `tip.used`), y en `revert_heap` restaurar `heap.words` y `heap.used = delta.used`.

#### Archivos exactos a modificar en la Etapa 1
- [`packages/pseudolearn_engine/crates/pseudolearn_runtime/src/heap/mod.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_runtime/src/heap/mod.rs)
- [`packages/pseudolearn_engine/crates/pseudolearn_runtime/src/heap/allocate.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_runtime/src/heap/allocate.rs)
- [`packages/pseudolearn_engine/crates/pseudolearn_runtime/src/heap/collect.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_runtime/src/heap/collect.rs)
- [`packages/pseudolearn_engine/crates/pseudolearn_runtime/src/heap/definition.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_runtime/src/heap/definition.rs)
- [`packages/pseudolearn_engine/crates/pseudolearn_runtime/src/array.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_runtime/src/array.rs)
- [`packages/pseudolearn_engine/crates/pseudolearn_runtime/src/object.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_runtime/src/object.rs)
- [`packages/pseudolearn_engine/crates/pseudolearn_runtime/src/cell.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_runtime/src/cell.rs)
- [`packages/pseudolearn_engine/crates/pseudolearn_runtime/src/snapshot.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_runtime/src/snapshot.rs)
- [`packages/pseudolearn_engine/crates/pseudolearn_runtime/src/delta/heap.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_runtime/src/delta/heap.rs)

#### Verificación obligatoria al cerrar la Etapa 1
```bash
cargo test --manifest-path packages/pseudolearn_engine/Cargo.toml -p pseudolearn_abi -p pseudolearn_runtime -p pseudolearn_vm -p pseudolearn_timeline
cargo run --manifest-path packages/pseudolearn_engine/Cargo.toml -p xtask -- verify
```

#### Resultado de ejecución de la Etapa 1
**Estado: completada y publicada el 2026-10-16.**

Se sustituyó `allocations: BTreeMap<Handle, Allocation>` por metadatos en banda y un `Vec<BlockRecord>` ordenado, con los diseños de objetos indexados por clase. El runtime obtiene de la cabecera el tipo, rango, literal, desplazamiento de campos e identidad; la recolección, los snapshots y `HeapDelta` recorren los bloques vivos. `HeapDelta` conserva solo las palabras usadas. Se actualizaron también los consumidores de texto y se añadieron pruebas espejo para el ABI, los arreglos, los diseños de objetos, la recolección y la restauración de deltas.

La verificación dirigida de `pseudolearn_abi`, `pseudolearn_runtime`, `pseudolearn_vm` y `pseudolearn_timeline` pasó con **129 pruebas**. `cargo xtask verify` pasó con formato, Clippy, pruebas y doctests del workspace, `rust-checks all`, `rust-checks toolchain` y `cargo deny` (advisories, bans, licenses y sources). `cargo deny` se ejecutó sin red contra la base de avisos local porque la caché Cargo predeterminada no permitía escribir su archivo de bloqueo.

La implementación se publicó en `feature/agregar-ruta-de-especificacion`, commit `fe6364247129ff5304496a997556d1b5b880a4fc` (`perf(engine): store runtime allocation metadata in-band`). El árbol de trabajo quedó limpio y `HEAD` coincide con el upstream. La Etapa 2 permanece pendiente de autorización explícita.

---

### Etapa 2 · `object.load`/`object.store` directos, arreglos sin `Vec<i64>`, llamadas `O(1)` y GC perezoso (`ir`, `lowering`, `bytecode`, `vm`)

#### Objetivo
Cumplir `IR.INSTRUCTIONS#O49` (`object.load`) y `#O50` (`object.store`), eliminar las asignaciones dinámicas por instrucción en el intérprete (`Vec<i64>` en arreglos, `String` en `return`, `Vec<Handle>` en `allocate` sin GC, `BTreeMap` en `call.virtual`) y activar `SuperInstruction::CompareBranch` por omisión, elevando la media geométrica de `AWFY-core` por encima de **30×**.

#### Cambios exactos por archivo

1. **Verificación de tipos de `object.load` y `object.store` en `pseudolearn_ir`:**
   - Archivo: [`packages/pseudolearn_engine/crates/pseudolearn_ir/src/type_checker_memory.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_ir/src/type_checker_memory.rs)
   - En `check_memory_instruction` (líneas 17–24), añadir las ramas:
     - `Operation::ObjectLoad => check_object_load(operands, get_type, module),`
     - `Operation::ObjectStore => check_object_store(operands, get_type, module),`
   - `check_object_load`: espera `[Operand::Value(object_value), Operand::Identifier(field_name)]`, comprueba `get_type(object_value) == Some(IrType::Object(class_name))`, busca el campo en la jerarquía con `inherited_field_type(module, &class_name, field_name)` y devuelve `Ok(Some(field_type))` (el tipo directo `T`, **no** `IrType::Cell<T>`).
   - `check_object_store`: espera `[Operand::Value(object_value), Operand::Identifier(field_name), Operand::Value(source_value)]`, obtiene `field_type` con `inherited_field_type`, verifica `assignable(module, &source_type, &field_type)` y devuelve `Ok(Some(IrType::Unit))`.

2. **Emisión de `object.load` y `object.store` en `pseudolearn_lowering`:**
   - Archivo 1: [`packages/pseudolearn_engine/crates/pseudolearn_lowering/src/expressions_complex.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_lowering/src/expressions_complex.rs)
     - En `lower_member_access` (líneas 125–161): en lugar de emitir `Operation::CellField` + `Operation::CellLoad`, emitir una única instrucción `Operation::ObjectLoad` con operandos `vec![Operand::Value(current_value), Operand::Identifier(field_name)]` y tipo de resultado `field_type.clone()`.
     - Mantener `Operation::CellField` en `calls_Reference.rs` (o donde se bajan argumentos `Por Referencia`) para que el paso por referencia de `obj.campo` siga produciendo `cell<T>`.
   - Archivo 2: [`packages/pseudolearn_engine/crates/pseudolearn_lowering/src/statements_assignment.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_lowering/src/statements_assignment.rs)
     - En `assign_member` (líneas 68–96): para el último segmento (`field_Access.fields.last()`), en lugar de emitir `Operation::CellField` + `Operation::CellStore`, evaluar el valor derecho `rhs_val` y emitir una única instrucción `Operation::ObjectStore` con operandos `vec![Operand::Value(current_object), Operand::Identifier(last_field_name), Operand::Value(rhs_val)]`. Si hay cadena intermedia `a.b.c <- x`, los prefijos `a.b` se leen con `Operation::ObjectLoad`.
   - Actualizar los tests unitarios de `pseudolearn_lowering` que comprueben el texto IR generado para accesos a campos por valor (esperando `object.load` y `object.store`).

3. **Activación de `CompareBranch` por omisión en `pseudolearn_bytecode`:**
   - Archivo: [`packages/pseudolearn_engine/crates/pseudolearn_bytecode/src/compile.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_bytecode/src/compile.rs)
   - En `compile_module` (líneas 56–58): cambiar `&[]` por `&[SuperInstruction::CompareBranch]`.
   - Verificar que todos los tests de `pseudolearn_bytecode` y `pseudolearn_vm` siguen en verde (los tests que prueban compilación sin superinstrucciones pueden llamar a `compile_module_with_superinstructions(module, &[])`).

4. **Decodificación y ejecución de `ObjectLoad`, `ObjectStore` y arreglos sin `Vec<i64>` en `pseudolearn_vm`:**
   - Archivo 1: [`packages/pseudolearn_engine/crates/pseudolearn_vm/src/load/memory/model.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_vm/src/load/memory/model.rs) y [`load/memory.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_vm/src/load/memory.rs)
     - Añadir en `MemoryOp`:
       - `ObjectRead { destination: Register, receiver: u16, offset: usize }`: decodifica `Opcode::ObjectLoad` resolviendo estáticamente `offset` igual que `field_cell`.
       - `ObjectWrite { receiver: u16, offset: usize, source: TypedSource }`: decodifica `Opcode::ObjectStore` resolviendo estáticamente `offset` y `source: typed(context, instruction.operands.get(2))?`.
       - Especializar `ArrayRead1D { destination: Register, array: u16, index: Source }` y `ArrayWrite1D { array: u16, index: Source, source: TypedSource }` cuando `indices.len() == 1` (que cubre el 100 % de `sieve`, `towers`, `permute`, `queens`, `richards`, `nbody`, `bounce`, `storage`). Para `indices.len() > 1`, evaluar en un búfer de pila `[i64; 8]` cuando `indices.len() <= 8` antes de caer al caso general, eliminando por completo `Vec<i64>` en lecturas y escrituras de arreglos.
   - Archivo 2: [`packages/pseudolearn_engine/crates/pseudolearn_vm/src/machine/memory.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_vm/src/machine/memory.rs) y [`packages/pseudolearn_runtime/src/array.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_runtime/src/array.rs)
     - Añadir en `pseudolearn_runtime` funciones directas `read_element_1d(heap: &Heap, handle: Handle, index: i64) -> Result<u64, MemoryError>` y `write_element_1d(heap: &mut Heap, handle: Handle, index: i64, word: u64) -> Result<(), MemoryError>` que evitan construir o recorrer un slice `&[i64]`.
     - Ejecutar `MemoryOp::ObjectRead` llamando a `runtime::read_field(&self.heap, handle, *offset)` y `self.write_result(*destination, word)` (y si `self.probed`, registrar en `self.change_buffer` el cambio en `ObjectWrite`).
     - **Raíces perezosas de GC (`allocate_array`, `allocate_object`, `ObjectCopy`):** añadir en `pseudolearn_runtime::Heap` el método `pub fn needs_collection(&self, cells: u64) -> bool` (que evalúa la condición de `prepare`: `self.options.collection == CollectionPolicy::Forced || self.live_cells.saturating_add(self.allocated_cells).saturating_add(cells) > self.options.cells || self.allocated_cells >= self.live_cells.max(4096)`). En `Machine`, construir `let roots = if self.heap.needs_collection(estimated_cells) { self.memory_roots()? } else { Vec::new() };`. Esto elimina el recorrido de pila y `BTreeMap` en >99 % de las asignaciones de `storage` y `list`.
   - Archivo 3: [`packages/pseudolearn_engine/crates/pseudolearn_vm/src/machine/calls.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_vm/src/machine/calls.rs)
     - En `finish_call` (línea 228): mover `let callee_name = self.current.name.trim_start_matches('@').to_owned();` **adentro** del bloque `if self.probed { ... }`, eliminando la reserva de `String` en cada `return` no observado.
     - En `load/model.rs`, `load/instructions/control.rs` y `machine/calls.rs`: al decodificar `Opcode::CallVirtual`, precalcular para cada sitio de llamada un vector o tabla plana `targets_by_class: Vec<Option<u16>>` de longitud `module.classes.len()` en `CallSite`, de manera que `resolve_callee` haga simplemente `site.targets_by_class.get(actual_class)?.ok_or(INVALID_BYTECODE)` en **$O(1)$ sin tocar ningún `BTreeMap` ni partir cadenas en ejecución**.

#### Verificación obligatoria al cerrar la Etapa 2 (`B7.7`)
```bash
cargo test --manifest-path packages/pseudolearn_engine/Cargo.toml
cargo run --manifest-path packages/pseudolearn_spec/Cargo.toml --bin see -- check --subject engine
cargo run --manifest-path packages/pseudolearn_benchmarks/Cargo.toml -- run \
  --suite awfy-core \
  --worker packages/pseudolearn_engine/target/release/pseudolearn_bench_worker \
  --output packages/pseudolearn_benchmarks/results/macos-r5-vm/summary.json
cargo run --manifest-path packages/pseudolearn_benchmarks/Cargo.toml -- compare \
  packages/pseudolearn_benchmarks/results/macos-r3-awfy/summary.json \
  packages/pseudolearn_benchmarks/results/macos-r5-vm/summary.json
```
- **Umbral de salida:** Media geométrica **≥ 30,0×** y mínimo por programa **≥ 10,0×** (umbral normativo M2 ≥ 5×, M3 ≥ 30×).

---

### Etapa 3 · Unificación de `pseudolearn_api` sobre `pseudolearn_timeline`, `MachineDelta` acotado y reproducción híbrida (`B7.1` y `E-06`)

#### Objetivo
1. Reducir el coste de captura de pila profunda (`E06-STACK`) de 972 µs a **< 50 µs** y el retroceso p95 de `storage-10` de 59,02 ms a **< 35 ms** (≤ 50 ms en los 10 programas AWFY).
2. Hacer que `pseudolearn_api::ExecutionResource` utilice `CheckpointStore` de `pseudolearn_timeline` y conserve la `Machine` viva entre lotes (decisión **D1**), y eliminar de `pseudolearn_timeline` el código duplicado/muerto desconectado de la API.

#### Cambios exactos por archivo

1. **Acotar `MachineDelta` a la ventana viva en `pseudolearn_vm`:**
   - Archivo: [`packages/pseudolearn_engine/crates/pseudolearn_vm/src/machine/delta.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_vm/src/machine/delta.rs)
   - En `advance_image(tip: &mut MachineImage, machine: &Machine<'_>)`:
     - Pasar a `BlockDelta::advance` únicamente las tajadas vivas de los bancos de registros:
       - `&machine.scalars[..machine.scalar_limit.min(machine.scalars.len())]`
       - `&machine.references[..machine.reference_limit.min(machine.references.len())]`
       - `&machine.defined[..machine.scalar_limit.min(machine.defined.len())]`
     - En `revert_image`, tras revertir `scalars`, `references` y `defined`, asegurar que la longitud del vector en `image.state` sea al menos `scalar_limit` / `reference_limit`.
   - **Evitar clonar los 100 000 marcos en `capture_saved_frames`:**
     - En `Machine`, mantener `frame_dirty_from: usize` (inicializado a `0`; en cada `pop` de `self.frames` o modificación de marco, `self.frame_dirty_from = self.frame_dirty_from.min(self.frames.len())`).
     - En `advance_image`, actualizar `tip.state.frames` incrementalmente desde `frame_dirty_from` (sincronizando solo `frames[frame_dirty_from..]` más el marco actual `current_saved_frame(machine)`) y construir el `BlockDelta` únicamente sobre los bloques de 64 marcos a partir de `frame_dirty_from / BLOCK_WORDS`, reiniciando `frame_dirty_from = machine.frames.len()` tras la captura.

2. **Reproducción híbrida `TwinMode::Fast` $\to$ `TwinMode::Probed` en `pseudolearn_timeline`:**
   - Archivo: [`packages/pseudolearn_engine/crates/pseudolearn_timeline/src/replay.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_timeline/src/replay.rs)
   - En `Checkpoint` ([`checkpoint.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_timeline/src/checkpoint.rs)), guardar `pub statement_index: u64` (el valor de `machine.executed_statements()` en el momento del punto de control).
   - Si el punto de control ya está en `event_index == target_event`, restaurar la máquina directamente sin ejecutar instrucciones adicionales.
   - Cuando hay que avanzar desde un punto de control hasta `target_event`, ejecutar los pasos sobre la máquina restaurada evitando clonar diagnósticos o eventos innecesarios en cada paso.

3. **Podar superficie duplicada en `pseudolearn_timeline` (Decisión D1):**
   - Archivos en `packages/pseudolearn_engine/crates/pseudolearn_timeline/src/`:
     - Eliminar `deltas.rs` (y `tests/delta_tests.rs`), ya que el diferencial de estados de la API vive en `pseudolearn_api/src/state_changes.rs` y los puntos de control usan `MachineDelta`.
     - En `inspect.rs` y `model.rs`: eliminar `build_object_views`, `build_single_object_view` (que inventaba nombres `"campo_{field_index}"`), `ObjectView` y `VariableValue::display_representation`, dejando en `inspect.rs` únicamente la construcción de `FrameView` y `VariableView` consumida por `capture_frame` y `capture_snapshot`.
     - Actualizar `lib.rs` de `pseudolearn_timeline` para exportar la superficie limpia y real.

4. **Conectar `pseudolearn_api::ExecutionResource` a `CheckpointStore` (Decisión D1):**
   - Archivo: [`packages/pseudolearn_engine/crates/pseudolearn_api/src/execution_resource.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_api/src/execution_resource.rs)
   - Sustituir `checkpoints: Vec<(usize, Arc<MachineImage>)>` y `replay_base: Arc<MachineImage>` por `store: CheckpointStore` de `pseudolearn_timeline` (con `max_checkpoints: 128`).
   - En `record_checkpoint`, delegar en `self.store.record(&machine, self.events_emitted)` cada `CHECKPOINT_STRIDE` eventos.
   - En `replay_to_count`, si `target == 0` restaurar desde `self.initial`, y si `target > 0` usar `self.store.image_at(target)` para obtener la imagen diferencial más cercana `(image, base_event)` y avanzar hasta `target`.
   - Añadir un método `pub fn checkpoint_store_stats(&self) -> StoreStats` o test en `pseudolearn_api/tests/` que verifique `B7.1` (que las consultas por referencia no materializan el montón completo y usan `CheckpointStore`).

#### Verificación obligatoria al cerrar la Etapa 3 (`B7.1` y `E-06`)
```bash
cargo test --manifest-path packages/pseudolearn_engine/Cargo.toml -p pseudolearn_vm -p pseudolearn_timeline -p pseudolearn_api
cargo run --manifest-path packages/pseudolearn_spec/Cargo.toml --bin see -- \
  experiment r5-e06 --output packages/pseudolearn_spec/results/r5-e06.json
```
- **Umbral de salida:**
  - En `r5-e06.json`, `"status": "passed"` global:
    - `step_p95_ms <= 0.10` en los 10 programas;
    - `rewind_p95_ms <= 50.0` en los 10 programas (incluido `storage-10`);
    - `E06-STACK` `capture_p95_us < 50.0`;
    - `E06-RSS` `rss_ratio_to_heap <= 2.0`.

---

### Etapa 4 · Campaña de mutación dirigida y pruebas de propiedades (`E-16` ≥ 85 %)

#### Objetivo
Alcanzar **≥ 85 %** de mutantes cazados en cada uno de los 6 crates de ejecución (`timeline`, `lowering`, `bytecode`, `runtime`, `vm`, `library`) sin superar los límites de memoria ni disco.

#### Acciones exactas

1. **Ampliar tests de frontera y propiedades en `pseudolearn_timeline/tests/`:**
   - En [`snapshot_tests.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_timeline/tests/snapshot_tests.rs):
     - Añadir pruebas para `capture_array_slice` y `extract_array_cells` con arreglos 1D y 2D de todos los tipos (`Entero`, `Real`, `Logico`, `Caracter`, `Cadena`, referencias), cubriendo `start_offset == 0`, `start_offset + count == total`, `count == 0` y `start_offset > total` (`IndexOutOfBounds`).
     - Añadir pruebas para `cell_view` (`inspect_cell` con `Cell::Local` escalar/referencia y `Cell::Managed` apuntando a elemento de arreglo y a campo de objeto).
     - Añadir pruebas para `format_value_type` y `format_kind_type` cubriendo `F64`, `Bool`, `Char`, `Str`, `Object`, `Array`, `Cell` y `Unit`.
   - En [`checkpoint_tests.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_timeline/tests/checkpoint_tests.rs):
     - Añadir pruebas de borde para `thinning::select_victim_index` (distancias iguales para fijar `<` frente a `<=`, menos de 3 puntos de control, desempate por ranuras combinadas) y `StoreBudget` con `max_retained_slots` exacto (`retained_slots == max_retained_slots` no adelgaza; `retained_slots == max_retained_slots + 1` sí adelgaza).
   - En [`replay_tests.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_timeline/tests/replay_tests.rs):
     - Añadir prueba de horizonte expulsado (`EvictedEvent { requested, horizon }` cuando `requested < horizon` y éxito exacto cuando `requested == horizon`), `query_frame_variables` con índice de marco válido e inválido (`FrameNotFound`), y `query_array_slice` histórico.

2. **Ejecución segura crate por crate de `cargo-mutants` (Decisión D2):**
   Ejecutar un crate a la vez con `--in-place --timeout 30 --baseline skip` y acotando a los tests del propio paquete (`-p <crate>`):
   ```bash
   cargo mutants --manifest-path packages/pseudolearn_engine/Cargo.toml \
     -p pseudolearn_timeline --in-place --timeout 30 --baseline skip

   cargo mutants --manifest-path packages/pseudolearn_engine/Cargo.toml \
     -p pseudolearn_lowering --in-place --timeout 30 --baseline skip

   cargo mutants --manifest-path packages/pseudolearn_engine/Cargo.toml \
     -p pseudolearn_bytecode --in-place --timeout 30 --baseline skip

   cargo mutants --manifest-path packages/pseudolearn_engine/Cargo.toml \
     -p pseudolearn_runtime --in-place --timeout 30 --baseline skip

   cargo mutants --manifest-path packages/pseudolearn_engine/Cargo.toml \
     -p pseudolearn_vm --in-place --timeout 30 --baseline skip

   cargo mutants --manifest-path packages/pseudolearn_engine/Cargo.toml \
     -p pseudolearn_library --exclude-re 'src/precision/' --in-place --timeout 30 --baseline skip
   ```
   - Si algún crate queda por debajo del 85 %, inspeccionar `mutants.out/missed.txt`, añadir los casos límite faltantes en `tests/` de ese crate y reejecutar hasta superar el **85 %** en los 6 crates.
   - Borrar `mutants.out` tras registrar los resultados en `packages/pseudolearn_spec/results/r5-e16.json` para liberar espacio en disco.

---

### Etapa 5 · Cierre de `E-17` y `B7.4` (Decisión D3-a)

#### Objetivo
1. Pasar `E-17` (`r5-e17.json`) de `"status": "partial"` a `"status": "passed"` sobre el binario final.
2. Aplicar la decisión **D3-a** en `pseudolearn_api` para que `execute` conserve las advertencias emitidas durante el análisis estático cuando el programa no tiene errores de compilación, y regenerar `r5-differential.json`.

#### Cambios exactos

1. **Conservar advertencias de análisis en `execute` (`pseudolearn_api`, Decisión D3-a):**
   - Archivos:
     - [`packages/pseudolearn_engine/crates/pseudolearn_api/src/compile_pipeline.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_api/src/compile_pipeline.rs)
     - [`packages/pseudolearn_engine/crates/pseudolearn_api/src/execution.rs`](../../packages/pseudolearn_engine/crates/pseudolearn_api/src/execution.rs)
   - En `compile_pipeline.rs`, añadir una función `pub(crate) fn compile_source_with_warnings(source: &str, profile_name: &str, strictness_name: &str) -> Result<(pseudolearn_ir::Module, Vec<ApiDiagnostic>), Vec<ApiDiagnostic>>` que, cuando el análisis no tiene errores (`!has_errors`), convierte y devuelve también las advertencias (`Severity::Warning`) junto con el `Module`.
   - En `PreparedProgram` (`execution.rs`), guardar `warnings: Vec<ApiDiagnostic>` y anteponer `prepared.warnings` al vector `diagnostics` de `ExecuteResponse` tanto en `execute_bulk` como en `run_request`.
   - Verificar que `see check --subject engine` mantiene **325/325** casos en verde.

2. **Reejecutar `E-17` y el diferencial `B7.4`:**
   ```bash
   cargo run --manifest-path packages/pseudolearn_spec/Cargo.toml --bin see -- \
     experiment r5-e17 --output packages/pseudolearn_spec/results/r5-e17.json

   cargo run --manifest-path packages/pseudolearn_spec/Cargo.toml --bin see -- \
     differential --output packages/pseudolearn_spec/results/r5-differential.json
   ```
   - Verificar que `r5-e17.json` tiene `"status": "passed"` y `"divergences": 0`.
   - Verificar que en `r5-differential.json` desaparecen las divergencias por advertencias omitidas en `execute` y solo restan las diferencias benignas de precisión de columna (`end_col`) frente al sujeto `reference` congelado.

---

### Etapa 6 · Actualización documental (`DOC-README-TRUTH`) y verificación final (`B7.8`)

#### Acciones exactas
1. Actualizar [`packages/pseudolearn_engine/README.md`](../../packages/pseudolearn_engine/README.md) para reflejar:
   - la cabecera en banda sin `BTreeMap<Handle, Allocation>` en el camino crítico de `pseudolearn_runtime`;
   - el uso de `object.load` (`O49`) y `object.store` (`O50`) en `pseudolearn_lowering` y `pseudolearn_vm`;
   - la activación por omisión de `SuperInstruction::CompareBranch` en `pseudolearn_bytecode`;
   - la delegación de `ExecutionResource` sobre `CheckpointStore` de `pseudolearn_timeline` y la reproducción híbrida `Fast` $\to$ `Probed`;
   - las tablas de resultados finales de `AWFY-core`, `E-06`, `E-16`, `E-17` y `B7.4`.
2. Actualizar la sección «Relevo de B7» en [`docs/plan-nucleo-rust/11-plan-r5-ejecucion-remanso.md`](../../packages/pseudolearn_rust/11-plan-r5-ejecucion-remanso.md) marcando `[x]` en los puntos cerrados.
3. Ejecutar la puerta mecánica completa de ambos paquetes:
   ```bash
   cargo run --manifest-path packages/pseudolearn_engine/Cargo.toml -p xtask -- verify
   cargo run --manifest-path packages/pseudolearn_spec/Cargo.toml -p xtask -- verify
   cargo run --manifest-path packages/pseudolearn_spec/Cargo.toml --bin see -- check --subject engine
   ```
4. Parar (`PHASE-STOP`) e informar a la persona responsable sin hacer `git push` hasta recibir autorización explícita.

---

## 5. Impacto en `architecture.yaml`, `README.md`, corpus y contratos

| Artefacto | Impacto |
|---|---|
| [`packages/pseudolearn_engine/architecture.yaml`](../../packages/pseudolearn_engine/architecture.yaml) | **Ningún cambio en capas ni en `allowed_imports`.** Todos los cambios respetan las dependencias actuales (`api` $\to$ `timeline` $\to$ `vm` $\to$ `runtime` $\to$ `abi`). |
| [`packages/pseudolearn_engine/README.md`](../../packages/pseudolearn_engine/README.md) | Se actualiza en la Etapa 6 (`DOC-README-TRUTH`) con el diseño de cabecera en banda, despacho de `object.load`/`object.store`, unificación de `ExecutionResource` sobre `CheckpointStore` y resultados medidos de B7. |
| Corpus en [`packages/pseudolearn_spec/specifications/`](../../packages/pseudolearn_spec/specifications/) | **Cero cambios incompatibles.** El uso de `object.load` (`O49`) y `object.store` (`O50`) da cumplimiento efectivo a [`ir.instructions.md`](../../packages/pseudolearn_spec/specifications/ir/ir.instructions.md#L1007-L1042), y los umbrales de [`perf.vm.throughput.md`](../../packages/pseudolearn_spec/specifications/perf/perf.vm.throughput.md) (`M3` ≥ 30×) y [`perf.vm.step-latency.md`](../../packages/pseudolearn_spec/specifications/perf/perf.vm.step-latency.md) (`M3` ≤ 50 ms) quedan satisfechos sin rebajar ninguna regla. |
