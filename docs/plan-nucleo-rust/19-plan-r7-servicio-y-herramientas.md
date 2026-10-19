# Plan de R7 · Servicio de lenguaje y herramientas (`pseudolearn_service`, `pseudo format`, `pseudo translate`, `pseudo lsp`)

> **Estado:** propuesta de plan técnico y de ejecución de R7, pendiente de aprobación explícita
> (`PHASE-STOP`). Rama: `feature/agregar-ruta-de-especificacion` (`GIT-SINGLE-BRANCH`).
>
> Este documento detalla la arquitectura, las especificaciones del corpus `TOOL.*`, el análisis
> empírico del punto de partida tras R5 y R6, los conflictos normativos detectados (`CONFLICT-REPORT`),
> las decisiones de diseño (`D-R7-01`..`D-R7-10`), los experimentos **E-09** y **E-20** y la secuencia
> verificable de bloques (`B0`..`B8`) para ejecutar la fase **R7 («Servicio de lenguaje y
> herramientas»)** de [07-fases.md](07-fases.md#r7--servicio-de-lenguaje-y-herramientas).

---

## 1. Propósito, problemas que R7 resuelve e invariantes innegociables

### 1.1. Problemas del núcleo Dart y de las herramientas actuales que R7 cierra

La auditoría técnica de [07-herramientas-y-autocompletado.md](../07-herramientas-y-autocompletado.md) y
[03-identidad-bilingue-y-gramatica.md](../03-identidad-bilingue-y-gramatica.md) identificó cinco
defectos estructurales del servicio de edición actual (`ProfileCompletionSource` y `PseudoEngine` en
Dart) y cuatro ausencias de herramientas de lenguaje:

| Hallazgo / requisito | Estado previo a R7 | Cómo lo resuelve R7 |
|---|---|---|
| **H-17** · Plantillas en inglés con identificadores de relleno en español (`variable`, `condicion`, `"mensaje"`, `nombre`, `Nombre` en `apps/pseudolearn_app/lib/engine/completion/profile_completion_source.dart`) | Sigue en el código Dart congelado (`ADR-001`) | `TOOL.SERVICE.COMPLETION` + `pseudolearn_service`: plantillas generadas desde `LANG.SYNTAX.GRAMMAR` y `LANG.PROFILE.VOCABULARY` con marcadores localizados por perfil (`es` / `en`) |
| **H-18** · Plantilla `Segun variable\n  \nFinSegun` inválida al omitir `Hacer` (`@doKeyword` obligatorio según `LANG.SYNTAX.GRAMMAR`) | Sigue en el código Dart congelado | `TOOL.SERVICE.COMPLETION#Q1` exige que el **100 %** de las plantillas insertadas en su contexto válido produzcan un árbol sintáctico sin errores nuevos |
| **H-19** · Ausencia de analizador tolerante a fallos para autocompletar por alcance, miembros de clase (`p.`) y cierres pendientes | Resuelto en la capa sintáctica en R4 (`pseudolearn_syntax` siempre devuelve `SyntaxTree` sin pérdida); falta el motor de consultas de edición | `pseudolearn_service` explota el `SyntaxTree` en postorden tolerante a fallos y el índice semántico (`SemanticIndex`) para completar en programas incompletos |
| **H-20** · Sin identidad estable de nodos entre ediciones (`SyntaxNodeId`) | `SyntaxNode` usa índices secuenciales postorden (`0..N`) que se desplazan al insertar tokens antes de un nodo | `TOOL.SERVICE.NODE-IDENTITY` + `SyntaxNodeId` estructural anclado a la unidad superior (`Algoritmo`, `SubProceso`, `Clase` + miembro) y camino relativo tipado |
| **H-21** · Reanálisis completo de cinco pasadas en cada pulsación sin caché por documento ni presupuesto de latencia | En R4/R5 cada llamada a `analyze_with_options` parte de cero | `TOOL.SERVICE.INCREMENTAL` + sesión de documento con tabla de símbolos de nivel superior cacheada por huella (`UnitFingerprint`) de cada unidad (`SubProceso`, `Clase`, `Algoritmo`) |
| **EST-01..EST-10** · Sin formateador canónico | No existe formateador ni en Dart ni en Rust | `TOOL.FORMAT.STYLE` + `TOOL.CLI.FORMAT` (`pseudo formatear` / `pseudo format`) + `textDocument/formatting` en LSP, idempotente y con conservación íntegra de comentarios |
| **Traducción entre perfiles** · Sin traductor de código `es` ↔ `en` | Solo existe la sonda de léxico de `see` para `LANG.PROFILE.TRANSLATION`; no existe servicio sobre CST real ni subcomando CLI | `TOOL.TRANSLATE.ROUND-TRIP` + `TOOL.CLI.TRANSLATE` (`pseudo traducir` / `pseudo translate`), con preservación de comentarios, doble traducción idéntica sobre código canónico y detección de colisiones sin renombrado silencioso |
| **Navegación e inspección** · Sin ir a definición, referencias, resaltado de ocurrencias ni información emergente (*hover* y ayuda de firma) | Inexistente | `TOOL.SERVICE.NAVIGATION` y `TOOL.SERVICE.HOVER` en `pseudolearn_service` |
| **Servidor LSP** · Sin protocolo estándar para editores externos | Inexistente | `TOOL.LSP.CAPABILITIES` + `pseudo lsp` sobre JSON-RPC 2.0 en `stdio` |

### 1.2. Invariantes innegociables de la fase

1. **Especificación antes que código (`SPEC-FIRST`, `SPEC-BEHAVIOR-TRUTH`).** Las 10 especificaciones
   nuevas de `TOOL.*` (y la actualización coordinada de `TOOL.CLI.CONVENTIONS` y `TOOL.CLI.MESSAGES`)
   se redactan, validan con `see validate` y bloquean en `specifications.lock` en el bloque **B0** antes
   de escribir una sola línea en `pseudolearn_service` o `pseudolearn_cli`.
2. **Política de versiones congeladas del corpus ([07-fases.md](07-fases.md) §3).** Ninguna
   especificación existente incrementa su campo `version` ni añade bloques `"cambio": { ... }`. Las
   especificaciones nuevas nacen en `"version": "0.1.0"` y `"estado": "experimental"`, sin bloque
   `"cambio"`. El archivo `specifications.lock` se actualiza sustituyendo el hash de la entrada
   `<ID>@<version>` correspondiente.
3. **Autosuficiencia documental (`DOC-NO-TRANSIENT-REFS`, `DOC-README-TRUTH`).** Ninguna especificación
   de `packages/pseudolearn_spec/specifications/` ni ningún `README.md` de paquete o aplicación puede
   citar `docs/`, `docs/plan-nucleo-rust/`, números de documento transitorio, fases (`R0`–`R9`),
   bloques (`B0`–`B8`) ni identificadores de hallazgos de investigación (`H-*`, `D-*`, `E-*`, `ADR-*`).
   El campo `"revisado_por"` de las especificaciones nuevas o editadas debe describir la revisión de
   forma autosuficiente (p. ej. `"revisión técnica cruzada del corpus"`).
4. **Frontera estricta de capas (`LAYER-DIRECTION`, `LAYER-DECLARED`).** `pseudolearn_service` es la
   capa de **nivel 6** en `packages/pseudolearn_engine` ([04-arquitectura-del-workspace-rust.md](04-arquitectura-del-workspace-rust.md)
   §2.1): importa únicamente `pseudolearn_source`, `pseudolearn_diagnostics`, `pseudolearn_lexicon`,
   `pseudolearn_syntax` y `pseudolearn_semantic`. Jamás importa `pseudolearn_hir` (salvo tipos
   reexportados por `pseudolearn_semantic` si aplica, o mejor aún solo el modelo semántico público de
   `pseudolearn_semantic`), `pseudolearn_ir`, `pseudolearn_runtime`, `pseudolearn_stdlib`,
   `pseudolearn_vm` ni `pseudolearn_aot`. Declara `#![forbid(unsafe_code)]`.
5. **Calidad Rust estricta (`QUALITY-NO-COMMENTS`, `QUALITY-SEMANTIC-NAMES`, `QUALITY-NO-PANIC`).**
   Cero comentarios (`//`, `///`, `/* */`), cero `#[doc]`, `#[allow]` o `#[expect]`, cero `unwrap`,
   `expect`, `panic!`, `todo!`, `unimplemented!`, `unreachable!`, cero indexación directa `slice[i]` y
   cero aritmética implícita sin comprobación, verificado por `cargo clippy` y `rust-checks`.
6. **Determinismo y ausencia de IA generativa ([07-herramientas-y-autocompletado.md](../07-herramientas-y-autocompletado.md) §2).**
   El autocompletado, el formateo y la traducción son **100 % deterministas y locales**, derivados de la
   gramática, la tabla de símbolos y el vocabulario bilingüe.

---

## 2. Análisis del estado de partida verificado (post-R5 y R6)

### 2.1. Evidencia empírica de E-08 (`e08r`) y sus consecuencias para el diseño incremental

En R5 se ejecutó la campaña empírica del front-end Rust (`packages/pseudolearn_benchmarks/results/e08r/summary.json`
y `packages/pseudolearn_spec/results/r5-frontend-e08.json`) midiendo el pipeline completo
`SourceText` + `lex` + `parse` + `pseudolearn_semantic::analyze_with_options` sobre el hardware de
referencia (`Apple M2`, `rustc 1.94.1`):

| Tamaño del archivo | Modo | Media (`ms`) | Mediana (`ms`) | **p95 (`ms`)** | Caudal (`líneas/s`) |
|---|---|---:|---:|---:|---:|
| **1 000 líneas** | `es-strict` (completo) | 0,575 | 0,552 | **0,762 ms** | $1{,}74 \times 10^6$ |
| **1 000 líneas** | `es-strict` (incompleto) | 0,573 | 0,564 | **0,664 ms** | $1{,}75 \times 10^6$ |
| **10 000 líneas** | `es-strict` (completo) | 5,248 | 5,188 | **5,603 ms** | $1{,}91 \times 10^6$ |
| **10 000 líneas** | `es-strict` (incompleto) | 5,321 | 5,325 | **5,541 ms** | $1{,}88 \times 10^6$ |
| **10 000 líneas** | `es-flexible` (completo) | 5,642 | 5,638 | **5,843 ms** | $1{,}77 \times 10^6$ |
| **50 000 líneas** | `es-strict` (completo) | 27,633 | 27,620 | **28,096 ms** | $1{,}81 \times 10^6$ |
| **50 000 líneas** | `es-strict` (incompleto) | 12,837 | 12,802 | **13,274 ms** | $3{,}90 \times 10^6$ |

**Conclusión técnica fundamental de E-08 para R7:**

1. **Hasta 10 000 líneas**, el análisis completo desde cero en Rust tarda **5,60 ms p95**, casi tres
   veces por debajo del presupuesto de fotograma de 60 Hz (**16 ms**) y nueve veces por debajo del
   umbral de autocompletado (**50 ms**).
2. **A 50 000 líneas**, el análisis completo en archivos sin errores sube a **28,10 ms p95**, superando
   el umbral de **16 ms** para ediciones locales dentro del cuerpo de una función o algoritmo.
3. Por tanto, tal como anticipaban [04-arquitectura-del-workspace-rust.md](04-arquitectura-del-workspace-rust.md) §3
   y [09-plan-r3-motor-clepsidra.md](09-plan-r3-motor-clepsidra.md) §4.2:
   - **No hace falta `salsa` ni `rowan`** (cero dependencias pesadas externas, `SCOPE-YAGNI`).
   - **Sí hace falta una caché incremental por unidad de nivel superior (`UnitFingerprint`)** en
     `pseudolearn_service`: como todo programa PseudoLearn es una secuencia de unidades independientes de
     nivel superior (`Clase`, `SubProceso`/`Funcion`, `Algoritmo`), cuando una edición ocurre dentro del
     cuerpo de una unidad sin alterar ninguna cabecera/firma de nivel superior, `pseudolearn_service`
     reutiliza las firmas y diagnósticos de todas las unidades cuya huella léxica no cambió y solo
     reejecuta la comprobación semántica de cuerpo sobre la unidad editada. En un archivo de 50 000
     líneas con decenas de subprocesos, esto reduce la actualización tras teclear en un cuerpo de
     **28,1 ms** a **< 2 ms p95**.

### 2.2. Estado actual de `pseudolearn_syntax` y `TOOL.SERVICE.LOSSLESS-TREE`

- `packages/pseudolearn_engine/crates/pseudolearn_syntax` ya implementa `Tokens` (con `TriviaStore` de
  comentarios y blancos previos/posteriores por token) y `SyntaxTree` plano en postorden (`Vec<SyntaxNode>`
  con `SyntaxKind`, `Span`, `first_token`, `last_token`, `child_start`, `child_len`), además de
  `reconstruct_source(source, tokens, tree)`.
- `TOOL.SERVICE.LOSSLESS-TREE` (`0.2.0`, `experimental`) ya existe en
  `packages/pseudolearn_spec/specifications/tool/tool.service.lossless-tree.md` con `"sujetos": ["engine", "service"]`,
  4 casos (`C1`–`C4`) y 2 propiedades (`P1` y `P2`). Actualmente está vinculado en
  `packages/pseudolearn_engine/conformance.yaml` para `engine`, pero falta el manifiesto de `service`.

### 2.3. Estado actual de `pseudolearn_semantic`

- `packages/pseudolearn_engine/crates/pseudolearn_semantic/src/lib.rs` expone hoy:
  - `analyze(source, tokens, tree, profile) -> (HirModule, Vec<Diagnostic>)`
  - `analyze_with_options(source, tokens, tree, profile, options) -> (HirModule, Vec<Diagnostic>)`
- Internamente (`analyzer.rs`), `AnalysisSession` construye toda la información que el servicio de
  lenguaje necesita:
  - `classes: BTreeMap<String, ClassInfo>` (con `raw_name`, `super_class`, `fields`, `methods`, `span`),
  - `functions: BTreeMap<String, FunctionSignature>` (con `raw_name`, `params`, `return_type`, `span`),
  - `declarations: BTreeMap<usize, Vec<LocalId>>` y `local_names: BTreeMap<(usize, String), LocalId>`,
  - `inferred: BTreeMap<LocalId, ValueType>` y los tipos de cada expresión en `expr.rs`.
- Sin embargo, al terminar `analyze_with_options`, `AnalysisSession` se descarta y solo se devuelve
  `(HirModule, Vec<Diagnostic>)`. Además, no se registran las posiciones (`Span`) de cada referencia a
  símbolo (uso de variable, llamada a función, acceso a campo/método, referencia a clase) ni el tipo
  estático calculado por nodo de expresión (`SyntaxNode` index $\to$ `SemanticType`), indispensables
  para `TOOL.SERVICE.NAVIGATION`, `TOOL.SERVICE.HOVER` y `TOOL.SERVICE.COMPLETION` tras `.` (`p.`).

### 2.4. Estado actual de `apps/pseudolearn_cli` y `packages/pseudolearn_spec`

- `apps/pseudolearn_cli` implementa los subcomandos `comprobar` (`check`), `ejecutar` (`run`), `ri`
  (`ir`), `compilar` (`build`) y `preferencias` (`preferences`), más `--see-adapter cli`.
- En `packages/pseudolearn_spec/crates/see_cli`:
  - `bindings.rs` (línea 35) mapea el sujeto `"service"` a `"../pseudolearn_service/conformance.yaml"`.
  - `subject_adapters.rs` tiene lanzadores para `"reference"`, `"engine"`, `"aot"`, `"cli"` y `"see"`,
    pero **no tiene entrada para `"service"`**.
  - `requests.rs` soporta operaciones `check`, `run`, `trace`, `ir`, `cli`, `probe` y `validate`, y en
    `conformance.rs` redirige las especificaciones con prefijo `TOOL.SERVICE.` a la operación `probe`
    (`lossless_tree`).

---

## 3. Conflictos y tensiones detectados (`CONFLICT-REPORT`)

Siguiendo `CONFLICT-REPORT` de `AGENTS.md` §2 y §3, se documentan cinco conflictos entre archivos del
repositorio y el diseño de R7, junto con la resolución propuesta para ejecutar la fase:

### C-R7-01 · Ruta del manifiesto y adaptador del sujeto `service` en `see_cli`

- **Fuentes en tensión:**
  1. `packages/pseudolearn_spec/crates/see_cli/src/bindings.rs` (línea 35) busca el manifiesto de
     `service` en `../pseudolearn_service/conformance.yaml` (como si `pseudolearn_service` fuera un
     paquete de primer nivel en `packages/`).
  2. [04-arquitectura-del-workspace-rust.md](04-arquitectura-del-workspace-rust.md) §1 y §2.1 establece
     que `pseudolearn_service` es un crate interno (`packages/pseudolearn_engine/crates/pseudolearn_service`)
     dentro del único paquete de motor `packages/pseudolearn_engine`, igual que `pseudolearn_aot`. En R6,
     el sujeto `aot` se alojó en `packages/pseudolearn_engine/conformance-aot.yaml` y se sirve desde
     `pseudolearn_conformance --subject aot`.
  3. `packages/pseudolearn_spec/crates/see_cli/src/subject_adapters.rs` no define aún cómo lanzar el
     proceso adaptador para el sujeto `"service"`.
- **Resolución propuesta:** Alinear `service` exactamente con el patrón de `aot` en
  `packages/pseudolearn_engine`:
  - Mapear `"service"` en `packages/pseudolearn_spec/crates/see_cli/src/bindings.rs` a
    `"../pseudolearn_engine/conformance-service.yaml"`.
  - Añadir `"service"` en `packages/pseudolearn_spec/crates/see_cli/src/subject_adapters.rs` invocando
    `pseudolearn_conformance --subject service` en `packages/pseudolearn_engine`.

### C-R7-02 · Superficie de consulta semántica entre `pseudolearn_semantic` y `pseudolearn_service`

- **Fuentes en tensión:**
  1. `packages/pseudolearn_engine/architecture.yaml` y [04-arquitectura-del-workspace-rust.md](04-arquitectura-del-workspace-rust.md)
     §2.1 disponen que `pseudolearn_service` (nivel 6) importa `pseudolearn_semantic` (nivel 4) y **no**
     reimplementa la resolución de nombres ni la inferencia de tipos (`LAYER-DIRECTION`, una sola
     responsabilidad).
  2. `pseudolearn_semantic` actualmente devuelve solo `(HirModule, Vec<Diagnostic>)` y descarta la tabla
     de símbolos, los alcances léxicos, las referencias a definiciones y los tipos inferidos por
     expresión.
- **Resolución propuesta:** Extender `pseudolearn_semantic` con un tipo público de solo lectura
  `SemanticModel` (y una función `analyze_model_with_options(source, tokens, tree, profile, options) -> SemanticAnalysis`
  más un punto de entrada incremental por unidad `analyze_with_cached_units(...)`), actualizando el
  `README.md` de `packages/pseudolearn_engine` en el mismo cambio (`DOC-README-TRUTH`). `analyze` y
  `analyze_with_options` mantienen su firma exacta para no alterar ningún consumidor de R4/R5/R6.

### C-R7-03 · Especificaciones congeladas `TOOL.CLI.CONVENTIONS` y `TOOL.CLI.MESSAGES` frente a los nuevos subcomandos de R7

- **Fuentes en tensión:**
  1. [07-fases.md](07-fases.md) §R7 pide añadir `pseudo format` (`formatear`), `pseudo translate`
     (`traducir`) y `pseudo lsp` a `apps/pseudolearn_cli`, y [03-catalogo-de-especificaciones.md](03-catalogo-de-especificaciones.md)
     §2.10 incluye `TOOL.CLI.FORMAT` y `TOOL.CLI.TRANSLATE`.
  2. `TOOL.CLI.CONVENTIONS#R1` y `TOOL.CLI.MESSAGES#D1` (`helpCommands`, `helpOptions`) fijan la lista
     cerrada de subcomandos en la ayuda general (`comprobar (check), ejecutar (run), ri (ir), preferencias (preferences)`).
- **Resolución propuesta:** En el bloque **B0**, actualizar `TOOL.CLI.CONVENTIONS` y `TOOL.CLI.MESSAGES`
  para incluir `compilar (build)`, `formatear (format)`, `traducir (translate)` y `lsp`, así como las
  banderas `--hacia (--to)` y `--en-sitio (--in-place)` / `--verificar (--check)` según corresponda,
  respetando la **regla de versiones congeladas** ([07-fases.md](07-fases.md) §3: mantener `"version": "0.1.0"`,
  no añadir bloque `"cambio"`, actualizar el hash en `specifications.lock`).

### C-R7-04 · Defectos normativos en el autocompletado Dart congelado (`H-17`, `H-18`) frente al oráculo de `TOOL.SERVICE.COMPLETION`

- **Fuentes en tensión:**
  1. `ProfileCompletionSource` en Dart (`apps/pseudolearn_app/lib/engine/completion/profile_completion_source.dart`)
     emite `Segun variable\n  \nFinSegun` sin `Hacer` (inválido para `LANG.SYNTAX.GRAMMAR`) y mezcla
     identificadores en español en el perfil inglés (`H-17`, `H-18`).
  2. `ADR-001` y `SPEC-INDEPENDENT-ORACLE` establecen que el núcleo/app Dart está congelado y los
     hallazgos se resuelven en las especificaciones y en Rust, nunca copiando los defectos de Dart.
- **Resolución propuesta:** `TOOL.SERVICE.COMPLETION` tiene como único sujeto `["service"]` (tal como
  fija [03-catalogo-de-especificaciones.md](03-catalogo-de-especificaciones.md) §2.10) y define el
  comportamiento correcto desde la gramática (`Segun <expresion> Hacer ... FinSegun` /
  `Switch <expression> Do ... EndSwitch`) y marcadores localizados por idioma.

### C-R7-05 · Subcomando `pseudo format` y `pseudo translate`: nombres bilingües y banderas en `TOOL.CLI.*`

- **Fuentes en tensión:**
  1. [07-fases.md](07-fases.md) §R7 menciona abreviadamente `pseudo format`, `pseudo translate` y
     `pseudo lsp`.
  2. `TOOL.CLI.CONVENTIONS#R1` exige que todo subcomando de la CLI acepte su nombre en español e inglés:
     `formatear` / `format`, `traducir` / `translate`, y `lsp` (acrónimo universal invariante en ambos
     idiomas).
- **Resolución propuesta:** Soportar `formatear` (`format`), `traducir` (`translate`) y `lsp` en ambos
  idiomas, con banderas bilingües coherentes con `TOOL.CLI.CONVENTIONS#R2`:
  - En `formatear` / `format`: `--verificar` (`--check`) para comprobar si ya está en forma canónica sin
    modificar, y `--escribir` (`--write`, `-w`) para formatear el archivo en disco (por defecto escribe
    en `stdout`).
  - En `traducir` / `translate`: `--hacia <es|en>` (`--to <es|en>`) obligatorio para indicar el perfil o
    idioma de destino (aceptando tanto `es`/`en` como IDs de perfil `es-strict`, `en-flexible`, etc.), y
    `--salida <ruta>` (`--output <path>`, `-o`) opcional.

---

## 4. Alternativas consideradas y decisiones de diseño (`D-R7-01`..`D-R7-10`)

### D-R7-01 · Arquitectura incremental de `pseudolearn_service`: caché por unidad de nivel superior con huella léxica (`UnitFingerprint`)

- **Alternativas evaluadas:**
  1. *Framework externo de cómputo incremental (`salsa` + `rowan`)*: añade decenas de miles de líneas de
     dependencias externas, obliga a duplicar el `SyntaxTree` plano de `pseudolearn_syntax` y contradice
     los datos empíricos de E-08 (`5,60 ms` p95 en 10 000 líneas).
  2. *Reanálisis total sin caché en cada edición*: cumple en 1 000 líneas (`0,76 ms`) y 10 000 líneas
     (`5,60 ms`), pero falla el presupuesto de `16 ms` en 50 000 líneas (`28,10 ms` p95 en `e08r`).
  3. *Sesión de documento con partición por unidad de nivel superior (`UnitFingerprint`) sobre el árbol
     postorden existente (Elegida)*:
     - Mantiene el texto del documento (`SourceText`), su versión monótona (`DocumentVersion`), el
       `SyntaxTree` sin pérdida y un mapa de unidades de nivel superior (`Clase`, `SubProceso`,
       `Algoritmo`).
     - Calcula para cada unidad dos huellas de 64 bits (FNV-1a determinista sin dependencias externas):
       `signature_fingerprint` (cabecera, nombre, parámetros, retorno, herencia y campos de clase) y
       `body_fingerprint` (tokens del cuerpo).
     - Si una edición incremental (`TextEdit`) no altera el número de unidades ni ningún
       `signature_fingerprint`, el esquema global de declaraciones (`ModuleDeclarations`: firmas de
       subprocesos y esquemas de clases) se conserva intacto y solo se reejecuta el análisis semántico
       de cuerpo sobre las unidades cuyo `body_fingerprint` cambió. Para las demás unidades se reutilizan
       sus diagnósticos, símbolos locales, referencias y tipos de expresión ajustando sus desplazamientos
       (`ByteOffsetDelta`) cuando están después del punto de edición.

### D-R7-02 · Identidad estable de nodos sintácticos (`SyntaxNodeId`) para `TOOL.SERVICE.NODE-IDENTITY`

- **Problema (H-20, RC-04):** Un índice `usize` en `SyntaxTree::nodes()` cambia para todos los nodos
  posteriores cuando se inserta un token al principio del archivo.
- **Diseño elegido:**
  - Todo nodo del `SyntaxTree` recibe un `SyntaxNodeId` determinista de 128 bits (o estructura
    comparable/serializable `StableNodeId`) compuesto por:
    1. `unit_anchor`: categoría de unidad superior (`Algorithm`, `Subprogram`, `Class`, `Root`) + huella
       del nombre normalizado de la unidad (o índice ordinal si es anónima/incompleta) + huella del
       método si está dentro de una `Clase`.
    2. `kind`: `SyntaxKind` del nodo.
    3. `structural_occurrence`: ordinal preorden del nodo de ese `SyntaxKind` dentro de su unidad/miembro
       ancla (o clave del nombre declarado si el nodo es una declaración `Parameter`, `FieldDeclaration`,
       `DefineStatement`).
  - **Propiedad garantizada:** Editar el cuerpo de `SubProceso A` no modifica el `SyntaxNodeId` de ningún
    nodo en `SubProceso B`, `Clase C` ni `Algoritmo principal`. Editar una sentencia dentro de una unidad
    conserva el `SyntaxNodeId` de la unidad, de sus parámetros y de todas las sentencias previas a la
    edición.

### D-R7-03 · Índice semántico (`SemanticModel`) en `pseudolearn_semantic`

Para alimentar `COMPLETION`, `NAVIGATION` y `HOVER` sin violar `LAYER-DIRECTION`, `pseudolearn_semantic`
exportará:

- `SymbolId(u32)` y `SymbolInfo`:
  - `id: SymbolId`
  - `name: String` (lexema original tal como se declaró)
  - `normalized_name: String` (clave canónica según `caseSensitivity` del perfil)
  - `kind: SymbolKind` (`Variable`, `Constant`, `Parameter`, `Subprogram`, `Class`, `Field`, `Method`)
  - `static_type: SemanticType` (`Entero`, `Real`, `Logico`, `Caracter`, `Cadena`, `Arreglo { elem, dims }`,
    ` Instancia(ClassName)`, `Desconocido`, `Vacio`)
  - `is_inferred: bool` (verdadero cuando la variable nació por asignación implícita en modo flexible)
  - `declaration_span: Span` y `declaration_unit_index: usize`
  - `signature: Option<CallableSignature>` (parámetros con modo `PorValor`/`PorReferencia`, tipo y
    retorno)
  - `enclosing_class: Option<String>`
- `ReferenceOccurrence`:
  - `span: Span` (rango exacto del identificador en el código fuente)
  - `target: SymbolId`
  - `is_declaration: bool`
  - `is_write: bool`
- `ScopeSnapshot`:
  - Rango de bytes `Span` de cada unidad/método y lista de `SymbolId` visibles en ese alcance, incluyendo
    `Este`/`This` y campos heredados si es un método de clase.
- `ExpressionTypeEntry`:
  - Mapa `node_index: usize -> SemanticType` para consultar en $O(1)$ el tipo del receptor antes de un
    punto (`p.`) durante el autocompletado y el tipo bajo el cursor en `hover`.

### D-R7-04 · Motor de autocompletado bilingüe determinista (`TOOL.SERVICE.COMPLETION`)

El motor de autocompletado en `pseudolearn_service` opera en cinco etapas deterministas sobre
`(DocumentSession, cursor_byte_offset)`:

1. **Clasificación del contexto sintáctico y léxico en el cursor:**
   - *En comentario o literal de cadena:* devuelve lista vacía (no contamina con palabras clave mientras
     se escribe un mensaje o comentario).
   - *Acceso a miembro (`<receptor>.<prefijo>`):* resuelve el `SemanticType` de `<receptor>` en el
     `SemanticModel`. Si es `Instancia(C)`, ofrece únicamente los campos y métodos declarados en `C` y en
     su cadena de superclases (`Extends`), con sus firmas y tipos. Si el receptor no es una instancia de
     clase, no ofrece palabras clave de sentencia.
   - *Posición de tipo (`Como <prefijo>`, `: <prefijo>`, `Devuelve <prefijo>`):* ofrece los tipos
     primitivos del perfil activo (`Entero`/`Integer`, `Real`, `Logico`/`Boolean`, `Caracter`/`Char`,
     `Cadena`/`String`) más los nombres de las clases declaradas en el documento.
   - *Cabecera de nivel superior (fuera de unidades):* ofrece plantillas de unidades (`Algoritmo`,
     `SubProceso`, `Funcion`, `Clase`) y cierres si hay una unidad abierta sin cerrar.
   - *Posición de inicio de sentencia (dentro de unidad/bloque):* ofrece cierres de bloques abiertos,
     plantillas de estructuras de control y sentencias del perfil activo, variables/parámetros visibles
     en el alcance actual, subprocesos y funciones estándar.
   - *Posición de expresión (lado derecho de `<-`, condición de `Si`/`Mientras`, argumento de llamada o
     `Escribir`):* ofrece variables y parámetros del alcance, campos/métodos si está en clase, funciones
     del usuario, funciones de la biblioteca estándar en el idioma del perfil, literales booleanos
     (`Verdadero`/`Falso` o `True`/`False`), `Nuevo`/`New` y `Este`/`This` (si está en método).
2. **Detección de pila de bloques abiertos (`OpenBlockStack`):**
   - Inspecciona la cadena de ancestros en el `SyntaxTree` que contienen el cursor y detecta qué bloques
     carecen de su token de cierre (`FinAlgoritmo`, `FinSubProceso`, `FinFuncion`, `FinClase`, `FinSi`,
     `FinSegun`, `FinMientras`, `FinPara`, `Hasta Que` / `Until`). El cierre del bloque más interno
     abierto se promueve a prioridad máxima cuando el cursor está en una línea de sentencia.
3. **Pista bilingüe cruzada (`CrossLanguageHint`):**
   - Si el documento usa un perfil `es-*` y el prefijo escrito coincide exactamente o por prefijo claro
     ($\ge 3$ letras) con una palabra clave o función estándar del perfil `en-*` (p. ej. el estudiante
     escribe `while`, `switch`, `return`, `sqrt`), el motor incluye el candidato canónico del perfil
     activo (`Mientras`, `Segun`, `Retornar`, `rc`) con una etiqueta de pista bilingüe (`detail`:
     equivalente de `while` en español), insertando siempre el lexema válido del perfil activo. Y
     simétricamente de `es` hacia `en`.
4. **Plantillas válidas por construcción (`Q1`) y localizadas por idioma (`H-17`, `H-18`):**
   - Todas las plantillas se construyen a partir del vocabulario canónico de `pseudolearn_lexicon` para
     el perfil activo y marcadores localizados:
     - En `es`: `Si condicion Entonces\n  \nFinSi`, `Segun expresion Hacer\n  Caso valor:\n    \n  De Otro Modo:\n    \nFinSegun`, `Mientras condicion Hacer\n  \nFinMientras`, `Para indice <- 1 Hasta limite Con Paso 1 Hacer\n  \nFinPara`, `Repetir\n  \nHasta Que condicion`, `Algoritmo nombre_algoritmo\n  \nFinAlgoritmo`, `SubProceso nombre_subproceso(parametro)\n  \nFinSubProceso`, `Clase NombreClase\n  \nFinClase`.
     - En `en`: `If condition Then\n  \nEndIf`, `Switch expression Do\n  Case value:\n    \n  Otherwise:\n    \nEndSwitch`, `While condition Do\n  \nEndWhile`, `For index <- 1 To limit Step 1 Do\n  \nEndFor`, `Repeat\n  \nUntil condition`, `Algorithm algorithm_name\n  \nEndAlgorithm`, `Subprocess subprocess_name(parameter)\n  \nEndSubprocess`, `Class ClassName\n  \nEndClass`.
5. **Ordenación determinista (sin empates arbitrarios):**
   - Clave de ordenación tupla `(priority_tier, prefix_match_rank, type_compatibility_rank, normalized_label)`:
     1. Cierre del bloque abierto inmediato (cuando el prefijo coincide o está vacío al final del bloque).
     2. Miembros de instancia tras `.` / símbolos locales del alcance más cercano (`Parameter`, `Variable`, `Field`).
     3. Subprocesos/clases del documento y estructuras sintácticas válidas en la posición gramatical actual.
     4. Funciones intrínsecas de la biblioteca estándar (`pseudolearn_lexicon::builtins`) compatibles con el tipo esperado si el contexto impone tipo.
     5. Candidatos de pista bilingüe cruzada.

### D-R7-05 · Formateador canónico sin pérdida (`TOOL.FORMAT.STYLE`)

- **Reglas de estilo implementadas ([03-identidad-bilingue-y-gramatica.md](../03-identidad-bilingue-y-gramatica.md) §3):**
  - **EST-01 (Sangría):** 2 espacios (`U+0020`) por cada nivel de bloque (`Algoritmo`, `SubProceso`,
    `Funcion`, `Clase`, `Si`/`Sino`, `Segun`, cuerpo de cada `Caso`/`De Otro Modo`, `Mientras`, `Para`,
    `Repetir`). Cero tabuladores (`\t`).
  - **EST-02 (Palabras clave):** Forma canónica del perfil activo según `LANG.PROFILE.VOCABULARY` (p. ej.
    `Algoritmo`, `FinAlgoritmo`, `SubProceso`, `FinSubProceso`, `Si`, `Entonces`, `Sino`, `FinSi`,
    `Segun`, `Hacer`, `Caso`, `De Otro Modo`, `FinSegun`, `Mientras`, `FinMientras`, `Para`, `Hasta`,
    `Con Paso`, `FinPara`, `Repetir`, `Hasta Que`, `Definir`, `Como`, `Escribir`, `Leer`, `Sin Saltar`,
    `Verdadero`, `Falso`, `Y`, `O`, `No`, `Mod`, y sus equivalentes `en`). Los alias secundarios (p. ej.
    `Proceso`/`FinProceso` o variantes en minúsculas/mayúsculas) se normalizan a la forma canónica
    preferida del perfil, o se conserva la variante estructural si es una distinción semántica (`SubProceso`
    vs `Funcion`).
  - **EST-03 y EST-04 (Identificadores de usuario):** El formateador **jamás** renombra identificadores
    de usuario; conserva exactamente el lexema escrito en cada declaración o sincroniza las ocurrencias
    resueltas con la grafía exacta de su declaración cuando difieren solo en mayúsculas/minúsculas en
    perfiles insensibles a caja.
  - **EST-05 (Asignación):** Siempre `<-` con un espacio a cada lado (`x <- 1`). Si en un perfil flexible
    aparece `:=` como asignación, se normaliza a `<-`.
  - **EST-06 (Operadores):** Operadores binarios (`+`, `-`, `*`, `/`, `^`, `%`, `=`, `<>`, `<`, `<=`,
    `>`, `>=`, `Y`/`And`, `O`/`Or`, `Mod`) con un espacio a cada lado; menos unario pegado al operando
    (`-x`); `No`/`Not` seguido de un espacio (`No condicion`).
  - **EST-07 (Separadores):** Coma y punto y coma pegados al token anterior y seguidos de un espacio
    (`a, b`); dos puntos en `Caso valor:` pegados a `valor`; corchetes y paréntesis de llamada o
    indexación sin espacio interno (`A[i, j]`, `f(x, y)`).
  - **EST-08 (Punto y coma final):** En perfiles `*-strict`, toda sentencia simple lleva `;` al final de
    la línea (añadiéndolo si faltaba o conservándolo); en perfiles `*-flexible`, se omite el `;` al
    final de línea salvo cuando separa múltiples sentencias en la misma línea (que el formateador separa
    en líneas distintas). Las cabeceras y cierres de bloque nunca llevan `;`.
  - **EST-09 (Líneas en blanco):** Una línea en blanco entre unidades de nivel superior (`Clase`,
    `SubProceso`, `Algoritmo`). Dentro de un bloque se conserva a lo sumo **una** línea en blanco
    consecutiva escrita por la persona (colapsando $\ge 2$ líneas vacías seguidas en 1). El archivo
    termina siempre con un único `\n` (`LF`).
  - **EST-10 (Comentarios):** Todo comentario de línea (`// ...`) y de bloque (`/* ... */`) alojado en
    el `TriviaStore` de `Tokens` se preserva íntegramente y en su orden relativo. El comentario de línea
    asegura al menos un espacio tras `//` (`// comentario`) salvo que esté vacío (`//`), y se sangra al
    nivel del bloque donde aparece (o con dos espacios antes de `//` si es comentario al final de una
    línea de código).
  - **Guardia de seguridad ante errores sintácticos:** Si el árbol contiene nodos `Error` que impiden
    determinar la estructura de una sentencia, ese tramo se emite preservando sus tokens originales sin
    pérdida, garantizando que `format` nunca destruya código ni borre tokens.

### D-R7-06 · Traductor entre perfiles sin pérdida (`TOOL.TRANSLATE.ROUND-TRIP`)

- **Diferencia con el prototipo de R3/R4 en `see_translation`:** En R3/R4, `packages/pseudolearn_spec/crates/see_translation`
  implementó una sonda léxica para `LANG.PROFILE.TRANSLATION`. En R7, el traductor real vive en
  `pseudolearn_service` operando sobre `Tokens` + `SyntaxTree` + `SemanticModel`:
  1. **Traducción sobre CST y modelo semántico:**
     - Las palabras clave (`TokenKind::Keyword` y secuencias multicompuestas como `Con Paso` $\leftrightarrow$
       `Step`, `Sin Saltar` $\leftrightarrow$ `Without Newline` / `NoNewline`, `De Otro Modo`
       $\leftrightarrow$ `Otherwise`, `Hasta Que` $\leftrightarrow$ `Until`, `Por Valor` $\leftrightarrow$
       `ByValue`, `Por Referencia` $\leftrightarrow$ `ByRef`) se reemplazan por el lexema canónico del
       perfil de destino (`LANG.PROFILE.VOCABULARY`).
     - Las llamadas a funciones intrínsecas de la biblioteca estándar (`rc` $\leftrightarrow$ `sqrt`,
       `azar` $\leftrightarrow$ `rand`, `longitud` $\leftrightarrow$ `length`, `subcadena` $\leftrightarrow$
       `substring`, `mayusculas` $\leftrightarrow$ `uppercase`, `minusculas` $\leftrightarrow$
       `lowercase`, `convertiratexto` $\leftrightarrow$ `tostring`, `convertiranumero` $\leftrightarrow$
       `tonumber`, `trunc` $\leftrightarrow$ `trunc`, `redon` $\leftrightarrow$ `round`, `abs`, `sen`
       $\leftrightarrow$ `sin`, `cos`, `tan`, `asen` $\leftrightarrow$ `asin`, `acos`, `atan`, `ln`,
       `exp`) se traducen **si y solo si** el `SemanticModel` confirma que el identificador no está
       sombreado por una declaración del usuario (`Variable`, `Parameter`, `Subprogram`, `Method`).
     - Los identificadores del usuario, los literales numéricos/cadena y todos los comentarios (`//`,
       `/* */`) se conservan intactos byte a byte.
  2. **Detección de colisiones con el vocabulario de destino (`R3`):**
     - Antes de emitir la traducción, `pseudolearn_service` verifica si algún identificador declarado o
       usado por el usuario coincide (bajo la regla de caja del perfil destino) con una palabra
       reservada del perfil destino (por ejemplo, una variable llamada `fin` o `si` en un programa en
       inglés que se traduce a español, o una variable llamada `to`, `do`, `step`, `end` en un programa
       en español que se traduce a inglés).
     - Si existe colisión, **no se renombra silenciosamente**: el traductor emite el diagnóstico
       estructurado `reservedLexemeUsedAsName` con el `Span` exacto del identificador en conflicto y
       rechaza dar por válida la traducción (o en la CLI devuelve código de salida `1` con el diagnóstico
       formateado en `stderr`).
  3. **Idempotencia e identidad de doble traducción (`P1`):**
     - Para todo programa sintácticamente válido sin colisiones de vocabulario:
       $$\text{translate}(\text{translate}(\text{format}(P, \text{es}), \text{es} \to \text{en}), \text{en} \to \text{es}) = \text{format}(P, \text{es})$$
     - Si el programa original $P$ ya usa los lexemas canónicos del perfil de origen, incluso sin pasar
       por `format`, la doble traducción `es -> en -> es` preserva exactamente el código fuente original
       (incluidos espacios y comentarios).

### D-R7-07 · Servidor LSP (`pseudo lsp` y `TOOL.LSP.CAPABILITIES`)

- **Transporte y arquitectura:**
  - `pseudolearn_service` contiene el manejador puro e independiente de E/S (`LspServerSession`), que
    recibe mensajes JSON-RPC 2.0 deserializados y devuelve respuestas y notificaciones JSON-RPC 2.0.
    Así, todas las capacidades de `TOOL.LSP.CAPABILITIES` se prueban determinísticamente en memoria y a
    través del protocolo `see` sin abrir descriptores de proceso adicionales.
  - `apps/pseudolearn_cli` añade el subcomando `pseudo lsp`, que lee y escribe tramas HTTP-like
    `Content-Length: <N>\r\n\r\n<payload JSON>` sobre `stdin`/`stdout` y delega cada mensaje en
    `LspServerSession`.
- **Capacidades anunciadas en `initialize` (`TOOL.LSP.CAPABILITIES`):**
  - `textDocumentSync`: `Incremental` (`2`) y `Full` (`1`) soportados (`didOpen`, `didChange`, `didClose`).
  - `completionProvider`: `triggerCharacters: ["."]`, `resolveProvider: false`.
  - `hoverProvider`: `true`.
  - `signatureHelpProvider`: `triggerCharacters: ["(", ","]`.
  - `definitionProvider`: `true`.
  - `referencesProvider`: `true`.
  - `documentHighlightProvider`: `true`.
  - `documentSymbolProvider`: `true`.
  - `documentFormattingProvider`: `true`.
  - Diagnósticos publicados automáticamente mediante `textDocument/publishDiagnostics` tras `didOpen` y
    `didChange`, localizados en el idioma negociado en `initializeParams.locale` (`es` o `en`, con
    respaldo a la preferencia o al idioma del perfil del documento).

### D-R7-08 · Extensión del protocolo `see-protocol/1` para el sujeto `service`

- Se añade la operación `"service"` al protocolo `see-protocol/1` en
  `packages/pseudolearn_spec/crates/see_core/src/requests.rs` y en
  `packages/pseudolearn_engine/crates/pseudolearn_conformance`:
  - Suboperaciones declarativas por caso:
    - `"lossless_tree"`: verifica reconstrucción byte a byte y conservación de trivia (`TOOL.SERVICE.LOSSLESS-TREE`).
    - `"node_identity"`: aplica una secuencia de ediciones `(antes, edicion, despues)` y verifica qué
      consultas de nodos conservan o cambian su `SyntaxNodeId` (`TOOL.SERVICE.NODE-IDENTITY`).
    - `"incremental"`: aplica una secuencia de ediciones incrementales sobre una `DocumentSession` y
      verifica que los diagnósticos, el árbol y el modelo semántico coinciden bit a bit con un análisis
      en frío del texto resultante, además de reportar unidades reutilizadas vs. reanalizadas
      (`TOOL.SERVICE.INCREMENTAL`).
    - `"completion"`: abre el código con un marcador de cursor `|` (o posición `{ "line": L, "column": C }`),
      ejecuta el autocompletado y comprueba la presencia, orden, categoría, plantilla e inserción válida
      de los candidatos (`TOOL.SERVICE.COMPLETION`).
    - `"navigation"`: ejecuta `definition`, `references` o `highlight` en la posición marcada y verifica
      los rangos devueltos (`TOOL.SERVICE.NAVIGATION`).
    - `"hover"`: ejecuta `hover` o `signature_help` en la posición marcada y verifica el tipo estático,
      la firma y la documentación generada (`TOOL.SERVICE.HOVER`).
    - `"format"`: ejecuta el formateador canónico y verifica el texto resultante y la idempotencia
      $\text{format}(\text{format}(x)) == \text{format}(x)$ (`TOOL.FORMAT.STYLE`).
    - `"translate"`: ejecuta la traducción hacia el perfil destino y verifica el código traducido, la
      doble traducción y los diagnósticos de colisión (`TOOL.TRANSLATE.ROUND-TRIP`).
    - `"lsp"`: envía una secuencia de mensajes JSON-RPC al `LspServerSession` y verifica las respuestas y
      notificaciones `publishDiagnostics` (`TOOL.LSP.CAPABILITIES`).

### D-R7-09 · Diseño del experimento E-09 (Calidad y latencia del autocompletado)

Siguiendo el protocolo de [16-experimentos-y-benchmarks.md](../16-experimentos-y-benchmarks.md) §E-09 y
[07-herramientas-y-autocompletado.md](../07-herramientas-y-autocompletado.md) §2.5:

- **Corpus de evaluación:** Los **172 programas reales** de la base de conocimiento bilingüe
  (`apps/pseudolearn_app/assets/knowledge/examples/*.pseudo`, 86 en español y 86 en inglés).
- **Protocolo de truncado exhaustivo:** Para cada archivo, se tokeniza el programa y, en cada token
  significativo (palabras clave de estructura/sentencia, tipos, identificadores de variables/parámetros/campos/métodos/subprocesos
  en posición de uso y llamadas a funciones estándar), se trunca el documento en dos modalidades:
  1. *Prefijo de 0 caracteres* (al inicio de sentencia o tras `.` o tras `Como `) para medir predicción
     estructural y cierre de bloques.
  2. *Prefijo de 2 caracteres* (primeros 2 caracteres del token real) para medir **Precisión@1**,
     **Precisión@5** y **ahorro de pulsaciones** ($\text{caracteres ahorrados} / \text{caracteres totales}$).
- **Métricas y criterios de aceptación de E-09:**
  - **Validez sintáctica de plantillas (`TOOL.SERVICE.COMPLETION#Q1`):** **100 %** de las plantillas del
    servicio insertadas en su contexto válido producen un árbol sin errores sintácticos nuevos.
  - **Precisión@5 con prefijo de 2 caracteres (`TOOL.SERVICE.COMPLETION#Q2`):** $\ge 85\,\%$ en ambos
    idiomas (`es` y `en`), y **Precisión@1** $\ge 60\,\%$.
  - **Ahorro de pulsaciones (HIP-02):** $\ge 35\,\%$ de caracteres ahorrados al aceptar el primer
    candidato acertado.
  - **Latencia p95 (`TOOL.SERVICE.COMPLETION#M1`):** $\le 50\text{ ms}$ (objetivo práctico en Rust:
    $< 2\text{ ms}$).
- **Artefacto auditable:** `packages/pseudolearn_spec/results/r7-service-e09.json`.

### D-R7-10 · Diseño del experimento E-20 (Arranque y latencia de la cadena de herramientas)

Siguiendo el protocolo de [16-experimentos-y-benchmarks.md](../16-experimentos-y-benchmarks.md) §E-20:

- **Operaciones medidas en el hardware de referencia (`Apple M2`):**
  1. `pseudo comprobar` (`check`) sobre programa pequeño (`hello.pseudo`, ~15 líneas) y mediano (~1 000 líneas).
  2. `pseudo ejecutar` (`run`) sobre programa pequeño (`hello.pseudo`).
  3. `pseudo compilar` (`build`) sobre programa pequeño (`hello.pseudo`) + ejecución del binario nativo emitido.
  4. `pseudo formatear` (`format`) sobre programa pequeño y de 1 000 líneas.
  5. `pseudo traducir` (`translate --to en`) sobre programa pequeño y de 1 000 líneas.
  6. `pseudo lsp`: tiempo desde `spawn` del proceso hasta respuesta a `initialize` + primera notificación
     `textDocument/publishDiagnostics` tras `didOpen`, más latencia por petición `completion` y `hover`
     en caliente.
- **Protocolo estadístico:** $N = 30$ repeticiones medidas tras calentamiento para estado tibio y
  medición separada de arranque de proceso completo (`Command::new("pseudo")`), registrando media,
  mediana, MAD, IQR, p95, mínimo y máximo.
- **Artefacto auditable:** `packages/pseudolearn_spec/results/r7-toolchain-e20.json`.

---

## 5. Diseño detallado de las especificaciones de R7 (Bloque B0)

De acuerdo con [03-catalogo-de-especificaciones.md](03-catalogo-de-especificaciones.md) §2.10 y
[07-fases.md](07-fases.md) §R7, el corpus `TOOL.*` en `packages/pseudolearn_spec/specifications/tool/`
quedará constituido por las siguientes especificaciones:

### 5.1. `TOOL.SERVICE.LOSSLESS-TREE` (existente, se vincula a `service`)

- **Archivo:** `packages/pseudolearn_spec/specifications/tool/tool.service.lossless-tree.md`
- **Estado actual:** `0.2.0`, `experimental`, `"sujetos": ["engine", "service"]`.
- **Acción en R7:** No requiere cambio en el archivo Markdown; se vinculan sus reglas `R1` y `R2` en el
  nuevo manifiesto `packages/pseudolearn_engine/conformance-service.yaml` y sus propiedades `P1` y `P2`
  para el sujeto `service` en `packages/pseudolearn_spec/results/property-conformance.json`.

### 5.2. `TOOL.SERVICE.NODE-IDENTITY` (nueva)

- **Archivo:** `packages/pseudolearn_spec/specifications/tool/tool.service.node-identity.md`
- **Sujetos:** `["service"]` · **Depende de:** `["TOOL.SERVICE.LOSSLESS-TREE"]`
- **Reglas normativas:**
  - `R1` (*Identidad determinista por estructura*): Todo nodo del árbol sintáctico posee un identificador
    estable (`SyntaxNodeId`) determinado por su unidad superior contenedora (`Algoritmo`, `SubProceso`,
    `Clase` y miembro), su categoría sintáctica (`SyntaxKind`) y su posición estructural relativa dentro
    de esa unidad.
  - `R2` (*Invarianza entre unidades ante ediciones locales*): Una edición de texto contenida dentro de
    una unidad de nivel superior no altera el `SyntaxNodeId` de ninguna otra unidad de nivel superior ni
    de los nodos contenidos en ellas.
  - `R3` (*Estabilidad de ancestros y hermanos previos*): Añadir, modificar o eliminar una sentencia
    dentro de un bloque conserva el `SyntaxNodeId` de la unidad contenedora, de sus parámetros y de las
    sentencias anteriores al punto de edición.
- **Casos y propiedades:**
  - `C1`: Edición dentro de `Algoritmo` conserva intactos los `SyntaxNodeId` de un `SubProceso` previo y
    uno posterior.
  - `C2`: Inserción de una sentencia al final de un bloque `Si` conserva los `SyntaxNodeId` de la
    cabecera `Si` y de la primera sentencia del bloque.
  - `C3`: Inserción de un comentario o espacio en blanco no altera el `SyntaxNodeId` de ningún nodo
    semántico del documento.
  - `C4`: Renombrar un `SubProceso` actualiza el `SyntaxNodeId` de esa unidad sin alterar el de las
    demás unidades del archivo.
  - `P1`: Para toda edición en una unidad $U_i$ de un programa multi-unidad, el conjunto de
    `SyntaxNodeId` de toda unidad $U_j$ ($j \neq i$) permanece idéntico al conjunto previo a la edición.

### 5.3. `TOOL.SERVICE.INCREMENTAL` (nueva)

- **Archivo:** `packages/pseudolearn_spec/specifications/tool/tool.service.incremental.md`
- **Sujetos:** `["service"]` · **Depende de:** `["TOOL.SERVICE.LOSSLESS-TREE", "TOOL.SERVICE.NODE-IDENTITY", "PERF.FRONTEND.THROUGHPUT"]`
- **Reglas normativas:**
  - `R1` (*Equivalencia observacional con análisis desde cero*): Tras cualquier secuencia de ediciones
    incrementales (`apply_edit`) sobre una sesión de documento, el texto reconstruido, el árbol
    sintáctico, los diagnósticos y el modelo semántico producidos por el análisis incremental son
    idénticos a los obtenidos analizando el documento resultante desde cero.
  - `R2` (*Reutilización de unidades no afectadas*): Cuando una edición modifica únicamente el cuerpo de
    una unidad de nivel superior sin alterar su firma ni las firmas de las demás unidades del documento,
    el servicio reutiliza el análisis semántico de las unidades cuyas huellas no cambiaron.
  - `R3` (*Tolerancia a estados intermedios incompletos*): Durante la escritura línea a línea (con
    bloques abiertos o expresiones truncadas), la sesión incremental actualiza los diagnósticos y
    conserva la tabla de símbolos de las unidades válidas y de las declaraciones previas al punto de
    edición.
- **Casos, propiedades y mediciones:**
  - `C1`: Secuencia de tres ediciones (declarar variable, asignar valor incompatible que dispara
    diagnóstico, corregir valor) produce en cada paso los mismos diagnósticos que el análisis en frío.
  - `C2`: Edición del cuerpo de un `SubProceso` en un programa con tres unidades reutiliza las otras dos
    unidades (`reused_units == 2`, `reanalyzed_units == 1`).
  - `C3`: Edición de la firma de un `SubProceso` (cambio del número de parámetros) invalida la caché de
    firmas y detecta el error de aridad en el punto de llamada dentro de `Algoritmo`.
  - `C4`: Estado intermedio con `Si x > 0 Entonces` sin `FinSi` conserva los símbolos declarados antes
    del `Si` para consultas posteriores.
  - `P1`: Para cualquier secuencia de ediciones aleatorias sobre programas del corpus, el estado
    incremental tras el paso $k$ coincide exactamente con el análisis en frío del texto en el paso $k$.
  - `M1`: Latencia p95 de actualización incremental tras edición de cuerpo en archivos de 1 000 líneas
    $\le 5\text{ ms}$ y en archivos de 10 000 líneas $\le 16\text{ ms}$ en el hardware de referencia.

### 5.4. `TOOL.SERVICE.COMPLETION` (nueva)

- **Archivo:** `packages/pseudolearn_spec/specifications/tool/tool.service.completion.md`
- **Sujetos:** `["service"]` · **Depende de:** `["LANG.SYNTAX.GRAMMAR", "LANG.PROFILE.VOCABULARY", "LANG.TYPES.PRIMITIVES", "LANG.OOP.CLASSES", "TOOL.SERVICE.INCREMENTAL"]`
- **Reglas normativas:**
  - `R1` (*Filtrado por contexto gramatical y léxico*): El servicio ofrece candidatos acordes con la
    posición del cursor (sentencia, expresión, tipo tras `Como`/`:`, miembro tras `.`, cabecera de
    unidad) y no ofrece candidatos dentro de comentarios ni literales de cadena.
  - `R2` (*Símbolos en alcance y miembros de clase*): En posición de expresión o sentencia se incluyen
    las variables, constantes y parámetros visibles en el alcance actual; tras `<instancia>.` se ofrecen
    únicamente los campos y métodos de la clase estática del receptor y sus superclases.
  - `R3` (*Cierre de bloques abiertos*): Cuando existen bloques abiertos sin cerrar (`Algoritmo`,
    `SubProceso`, `Funcion`, `Clase`, `Si`, `Segun`, `Mientras`, `Para`, `Repetir`), el servicio propone
    como candidato prioritario el token de cierre correspondiente al bloque abierto más interno.
  - `R4` (*Coherencia de idioma y pista bilingüe cruzada*): Todas las palabras clave, funciones estándar
    y marcadores de plantilla se emiten exclusivamente en el idioma del perfil activo (`es` o `en`). Si
    el prefijo escrito coincide con un término del otro idioma (p. ej. `while` en un perfil `es-*`), se
    sugiere el término canónico del perfil activo (`Mientras`) indicando la correspondencia bilingüe.
  - `R5` (*Determinismo del orden*): Para un mismo documento, perfil y posición de cursor, la lista de
    candidatos devuelta es estrictamente determinista en contenido y orden.
- **Casos, propiedades, cualidades y mediciones:**
  - `C1`: En posición de tipo (`Definir total Como |`) en `es-strict`, ofrece `Entero`, `Real`,
    `Logico`, `Caracter`, `Cadena` (y clases declaradas) y excluye `Escribir`, `Mientras` o variables.
  - `C2`: Dentro de un bloque `Mientras x < 10 Hacer` sin `FinMientras`, ofrece `FinMientras` como
    primer candidato de cierre.
  - `C3`: Tras `p.` donde `p` es instancia de `Clase Punto` con campo `x` y método `Mover`, ofrece `x` y
    `Mover` y excluye variables globales y palabras clave de sentencia.
  - `C4`: Plantilla de `Segun` en `es-strict` incluye `Hacer` (`Segun expresion Hacer ... FinSegun`) y
    plantilla de `Switch` en `en-strict` incluye `Do` y marcadores en inglés (`Switch expression Do ... EndSwitch`).
  - `C5`: Pista bilingüe cruzada: al escribir `whi|` dentro de un algoritmo en `es-strict`, propone
    `Mientras` (con plantilla en español).
  - `C6`: Dentro de un comentario `// Escr|` o literal `"Escr|"`, la lista de candidatos es vacía.
  - `Q1`: El 100 % de las plantillas de estructuras y sentencias producidas por el servicio, al
    insertarse en su posición gramatical válida, se parsean sin introducir errores sintácticos nuevos.
  - `Q2`: Sobre el corpus bilingüe de programas de referencia (experimento E-09), con prefijo de 2
    caracteres, la Precisión@5 es $\ge 85\,\%$ y la Precisión@1 es $\ge 60\,\%$.
  - `M1`: Latencia p95 de una consulta de autocompletado $\le 50\text{ ms}$ en archivos de hasta 10 000
    líneas en el hardware de referencia.

### 5.5. `TOOL.SERVICE.NAVIGATION` (nueva)

- **Archivo:** `packages/pseudolearn_spec/specifications/tool/tool.service.navigation.md`
- **Sujetos:** `["service"]` · **Depende de:** `["LANG.CORE.DECLARATIONS", "LANG.SUBPROGRAMS.CALLS", "LANG.OOP.CLASSES", "TOOL.SERVICE.INCREMENTAL"]`
- **Reglas normativas:**
  - `R1` (*Ir a definición*): Dada una posición de cursor sobre un uso o declaración de variable,
    constante, parámetro, subproceso, función, clase, campo o método, el servicio devuelve el rango
    (`Span`) exacto de su declaración en el alcance correspondiente (o su primera asignación implícita
    en modo flexible).
  - `R2` (*Buscar referencias*): Dada una posición sobre un símbolo, devuelve en orden de aparición todos
    los rangos del documento que referencian ese mismo símbolo semántico (`SymbolId`), sin confundirlo
    con símbolos homónimos de otros alcances.
  - `R3` (*Resaltado de ocurrencias en documento*): Devuelve las ocurrencias del símbolo bajo el cursor
    clasificando cada una como lectura (`Read`) o escritura/declaración (`Write`).
- **Casos:**
  - `C1`: Ir a definición sobre una variable local dentro de `Algoritmo` salta a su sentencia `Definir`.
  - `C2`: Dos subprocesos con una variable local homónima `i`: buscar referencias sobre `i` en el primer
    subproceso devuelve únicamente las ocurrencias del primer subproceso.
  - `C3`: Ir a definición sobre una llamada a método `p.Mover()` salta a la declaración `SubProceso Mover`
    dentro de la clase `Punto` (o en su superclase si es heredado).
  - `C4`: Resaltado de documento distingue la asignación `x <- 1` (`Write`) de la lectura `Escribir x`
    (`Read`).

### 5.6. `TOOL.SERVICE.HOVER` (nueva)

- **Archivo:** `packages/pseudolearn_spec/specifications/tool/tool.service.hover.md`
- **Sujetos:** `["service"]` · **Depende de:** `["LANG.TYPES.PRIMITIVES", "LANG.SUBPROGRAMS.CALLS", "LANG.STDLIB.MATH", "LANG.STDLIB.TEXT", "TOOL.SERVICE.INCREMENTAL"]`
- **Reglas normativas:**
  - `R1` (*Información emergente de símbolos del usuario*): Al posicionar el cursor sobre una variable,
    constante, parámetro, campo, clase o subproceso, el servicio devuelve su categoría, su tipo estático
    (indicando si fue declarado o inferido en modo flexible) y, para subprocesos/métodos, su firma
    canónica con modos de paso (`Por Valor` / `Por Referencia`).
  - `R2` (*Información emergente de palabras clave y biblioteca estándar*): Sobre una función intrínseca
    de la biblioteca estándar (no sombreada) o palabra clave, devuelve su firma y descripción breve en el
    idioma solicitado (`es` o `en`).
  - `R3` (*Ayuda de firma en llamadas*): Cuando el cursor está dentro de la lista de argumentos de una
    llamada `f(a, |)`, el servicio devuelve la firma del subproceso/método/intrínseca y el índice del
    parámetro activo (basado en el número de comas de nivel superior previas al cursor).
- **Casos:**
  - `C1`: Hover sobre variable declarada `Definir contador Como Entero` muestra tipo `Entero` (`Integer`
    en inglés).
  - `C2`: Hover sobre variable inferida `x <- 3.14` en `es-flexible` muestra tipo `Real` e indica que es
    inferido.
  - `C3`: Hover y ayuda de firma en el segundo argumento de `SubProceso Intercambiar(a Por Referencia, b Por Valor)`
    en `Intercambiar(x, |)` identifica el parámetro activo `1` (`b Por Valor`).
  - `C4`: Hover sobre la intrínseca `subcadena` / `substring` devuelve su firma tipada en el idioma
    solicitado.

### 5.7. `TOOL.FORMAT.STYLE` (nueva)

- **Archivo:** `packages/pseudolearn_spec/specifications/tool/tool.format.style.md`
- **Sujetos:** `["service"]` · **Depende de:** `["LANG.SYNTAX.GRAMMAR", "LANG.PROFILE.VOCABULARY", "TOOL.SERVICE.LOSSLESS-TREE"]`
- **Reglas normativas:**
  - `R1` (*Sangría y bloques — EST-01, EST-09*): Sangría de 2 espacios por nivel de bloque, cero
    tabuladores, una línea en blanco entre unidades de nivel superior y a lo sumo una línea en blanco
    consecutiva dentro de un bloque.
  - `R2` (*Palabras clave e identificadores — EST-02, EST-03, EST-04*): Las palabras clave se escriben
    en la forma canónica del perfil activo; los identificadores de usuario nunca se renombran y sus usos
    resueltos adoptan la grafía exacta de su declaración.
  - `R3` (*Operadores, separadores y punto y coma — EST-05, EST-06, EST-07, EST-08*): Asignación `<-` y
    operadores binarios rodeados de un espacio; comas seguidas de un espacio; `;` al final de cada
    sentencia simple en perfiles `*-strict` y omitido en perfiles `*-flexible`.
  - `R4` (*Conservación de comentarios e idempotencia — EST-10*): Todo comentario de línea y de bloque
    se conserva en su posición relativa; aplicar el formateador por segunda vez produce exactamente el
    mismo texto ($\text{format}(\text{format}(P)) = \text{format}(P)$) y no altera los diagnósticos
    semánticos del programa.
- **Casos y propiedades:**
  - `C1`: Programa en `es-strict` con sangría desordenada, palabras clave en minúsculas (`algoritmo`,
    `definir`, `como`, `entero`, `escribir`, `finalgoritmo`), espacios irregulares `x<-1+2` y sin `;` o
    con `;`: se formatea a la forma canónica con 2 espacios de sangría.
  - `C2`: Programa en `es-flexible` con `;` redundantes y `:=`: elimina los `;` de fin de línea y
    normaliza `:=` a `<-`.
  - `C3`: Conservación de comentarios de cabecera, interiores a bloques y de fin de línea junto con
    colapso de múltiples líneas en blanco a una sola.
  - `C4`: En `en-strict`, normaliza `algorithm`, `define`, `as`, `integer`, `write`, `endalgorithm` a
    `Algorithm`, `Define`, `As`, `Integer`, `Write`, `EndAlgorithm`.
  - `P1` (*Idempotencia y preservación semántica*): Para todo programa válido del corpus en cualquier
    perfil, $\text{format}(\text{format}(P)) = \text{format}(P)$ y los diagnósticos e HIR de
    $\text{format}(P)$ son equivalentes a los de $P$.

### 5.8. `TOOL.TRANSLATE.ROUND-TRIP` (nueva)

- **Archivo:** `packages/pseudolearn_spec/specifications/tool/tool.translate.round-trip.md`
- **Sujetos:** `["service"]` · **Depende de:** `["LANG.PROFILE.TRANSLATION", "LANG.PROFILE.VOCABULARY", "TOOL.SERVICE.LOSSLESS-TREE", "TOOL.FORMAT.STYLE"]`
- **Reglas normativas:**
  - `R1` (*Traducción estructural y de intrínsecas no sombreadas*): Traduce todas las palabras clave,
    tipos primitivos, operadores verbales y llamadas a funciones estándar no sombreadas del perfil de
    origen al perfil de destino (`es` $\leftrightarrow$ `en`), conservando la modalidad (`strict` o
    `flexible`).
  - `R2` (*Invarianza de identificadores de usuario, literales y comentarios*): Los nombres de
    variables, constantes, parámetros, subprocesos, clases, campos y métodos del usuario, así como los
    literales y los comentarios, se conservan sin traducción ni renombrado; si el usuario sombreó una
    función estándar (p. ej. declaró una variable o subproceso `azar`), esa ocurrencia no se traduce a
    `rand`.
  - `R3` (*Detección de colisiones con vocabulario de destino*): Si un identificador del usuario coincide
    con una palabra reservada del perfil de destino, el servicio reporta el diagnóstico
    `reservedLexemeUsedAsName` con la posición exacta y no realiza renombrado silencioso.
  - `R4` (*Identidad de doble traducción sobre forma canónica*): Para todo programa en forma canónica
    libre de colisiones, traducir de `es` a `en` y de vuelta a `es` (o de `en` a `es` y de vuelta a
    `en`) devuelve un texto idéntico byte a byte al original.
- **Casos y propiedades:**
  - `C1`: Traducción de un programa completo `es-strict` $\to$ `en-strict` con `SubProceso`, `Si`,
    `Segun`, `Mientras`, `Para`, `Repetir`, `rc(x)` y comentarios, y regreso a `es-strict` idéntico al
    original.
  - `C2`: Variable local llamada `longitud` en un programa en español: su declaración y usos permanecen
    como `longitud` al traducir a inglés, mientras que una llamada a `mayusculas(s)` no sombreada sí se
    traduce a `uppercase(s)`.
  - `C3`: Variable llamada `fin` en un programa en `en-strict` (`Define fin As Integer;`): al traducir
    hacia `es-strict`, reporta colisión `reservedLexemeUsedAsName` porque `fin` es palabra reservada en
    español.
  - `C4`: Programa con alias secundario (`Proceso` / `FinProceso`): la traducción `es` $\to$ `en` produce
    `Algorithm` / `EndAlgorithm` y la vuelta a `es` produce la forma canónica `Algoritmo` /
    `FinAlgoritmo`.
  - `P1`: Sobre los 172 programas reales del corpus de referencia formateados en forma canónica (y los
    casos válidos del corpus de especificaciones sin identificadores que colisionen con palabras
    reservadas del otro idioma), la doble traducción `origen -> destino -> origen` es 100 % idéntica al
    original y preserva la validez semántica.

### 5.9. `TOOL.LSP.CAPABILITIES` (nueva)

- **Archivo:** `packages/pseudolearn_spec/specifications/tool/tool.lsp.capabilities.md`
- **Sujetos:** `["service"]` · **Depende de:** `["TOOL.SERVICE.INCREMENTAL", "TOOL.SERVICE.COMPLETION", "TOOL.SERVICE.NAVIGATION", "TOOL.SERVICE.HOVER", "TOOL.FORMAT.STYLE"]`
- **Reglas normativas:**
  - `R1` (*Negociación `initialize` y cierre limpio*): Al recibir `initialize`, el servidor responde con
    el objeto `capabilities` que declara `textDocumentSync`, `completionProvider`, `hoverProvider`,
    `signatureHelpProvider`, `definitionProvider`, `referencesProvider`, `documentHighlightProvider`,
    `documentSymbolProvider` y `documentFormattingProvider`, adoptando el idioma (`es` o `en`) de
    `locale`. Ante `shutdown` devuelve `null` y ante `exit` finaliza con código `0`.
  - `R2` (*Sincronización de documentos y publicación de diagnósticos*): Tras `textDocument/didOpen` y
    `textDocument/didChange`, el servidor actualiza la sesión incremental del URI y emite una
    notificación `textDocument/publishDiagnostics` con los códigos, severidades, rangos UTF-16/línea-columna
    basados en 0 (estándar LSP) y mensajes localizados. Al recibir `textDocument/didClose`, libera la
    sesión y publica lista vacía de diagnósticos.
  - `R3` (*Correspondencia de consultas de edición*): Las peticiones `textDocument/completion`,
    `textDocument/hover`, `textDocument/signatureHelp`, `textDocument/definition`,
    `textDocument/references`, `textDocument/documentHighlight`, `textDocument/documentSymbol` y
    `textDocument/formatting` devuelven resultados coherentes con las consultas directas de
    `pseudolearn_service`, convirtiendo entre posiciones 1-indexadas del motor y posiciones 0-indexadas
    de LSP.
- **Casos:**
  - `C1`: Handshake `initialize` (con `"locale": "es"`) $\to$ `initialized` $\to$ `shutdown` $\to$ `exit`
    verifica las capacidades anunciadas.
  - `C2`: `didOpen` con un programa con error de tipos $\to$ emite `publishDiagnostics` con el error;
    `didChange` corrigiendo la línea $\to$ emite `publishDiagnostics` con `diagnostics: []`.
  - `C3`: Secuencia `didOpen` + `textDocument/completion` + `textDocument/hover` + `textDocument/definition`
    + `textDocument/formatting` devuelve las estructuras LSP esperadas con posiciones 0-indexadas.

### 5.10. `TOOL.CLI.FORMAT` y `TOOL.CLI.TRANSLATE` (nuevas) + actualización de `TOOL.CLI.CONVENTIONS` y `TOOL.CLI.MESSAGES`

- **Archivos nuevos:**
  - `packages/pseudolearn_spec/specifications/tool/tool.cli.format.md` (`sujetos: ["cli"]`)
    - `R1`: `pseudo formatear <archivo.pseudo>` (`pseudo format <file.pseudo>`) imprime en `stdout` el
      programa formateado con código de salida `0`. Con `--escribir` (`--write`, `-w`) actualiza el
      archivo en sitio.
    - `R2`: Con `--verificar` (`--check`), no escribe nada en `stdout` ni modifica el archivo: devuelve
      `0` si el archivo ya está en forma canónica y `1` (con mensaje diagnóstico en `stderr`) si requiere
      formateo.
    - `R3`: Si el archivo contiene errores sintácticos o no existe, devuelve el código de salida
      correspondiente (`1` para errores del programa, `2` para error de uso/archivo inexistente) sin
      modificar el archivo en disco.
    - Casos `C1` (formateo a `stdout`), `C2` (`--verificar` sobre archivo ya canónico devuelve `0`),
      `C3` (`--verificar` sobre archivo no canónico devuelve `1`), `C4` (archivo con error sintáctico
      devuelve `1`).
  - `packages/pseudolearn_spec/specifications/tool/tool.cli.translate.md` (`sujetos: ["cli"]`)
    - `R1`: `pseudo traducir <archivo.pseudo> --hacia <es|en>` (`pseudo translate <file.pseudo> --to <es|en>`)
      emite en `stdout` (o en `--salida <ruta>` / `--output <path>`) el programa traducido al perfil
      destino con código de salida `0`.
    - `R2`: Si el programa contiene un identificador que colisiona con una palabra reservada del perfil
      destino o tiene errores sintácticos, escribe el diagnóstico en `stderr` y termina con código `1`.
    - `R3`: Si falta `--hacia` / `--to` o su valor no es válido, escribe el error de uso en `stderr` y
      termina con código `2`.
    - Casos `C1` (`es` $\to$ `en` exitoso en `stdout`), `C2` (`en` $\to$ `es` exitoso), `C3` (colisión de
      nombre reservado devuelve `1`), `C4` (falta `--hacia` devuelve `2`).

---

## 6. Arquitectura interna de `pseudolearn_service` y cambios por paquete

### 6.1. Grafo de capas en `packages/pseudolearn_engine`

En `packages/pseudolearn_engine/architecture.yaml` y `Cargo.toml` se añade el crate `pseudolearn_service`:

```
Nivel 1: pseudolearn_source
Nivel 2: pseudolearn_diagnostics, pseudolearn_lexicon
Nivel 3: pseudolearn_syntax
Nivel 4: pseudolearn_hir, pseudolearn_semantic
Nivel 6: pseudolearn_service  ──► importa: source, diagnostics, lexicon, syntax, semantic
Nivel 9: pseudolearn_api      ──► reexporta la fachada pública de pseudolearn_service
```

### 6.2. Módulos internos de `crates/pseudolearn_service/src/`

Cada archivo cumple una única responsabilidad y respeta los límites de `architecture.yaml` (máximo 500
líneas por archivo, 60 líneas por función, 5 parámetros, anidación 4, 12 ítems públicos por módulo):

| Módulo | Responsabilidad única |
|---|---|
| `lib.rs` | Fachada pública del crate `pseudolearn_service` y reexportación de tipos de servicio |
| `node_identity.rs` | Cálculo de `SyntaxNodeId` estable por unidad superior, miembro, `SyntaxKind` y camino estructural (`TOOL.SERVICE.NODE-IDENTITY`) |
| `unit_partition.rs` | Partición del `SyntaxTree` en unidades de nivel superior y cálculo de `UnitFingerprint` (`signature_fingerprint`, `body_fingerprint`) |
| `document_session.rs` | Gestión de documentos abiertos (`LanguageService`, `DocumentSession`), aplicación de ediciones de rango (`TextEdit`) y reanálisis incremental reutilizando unidades no modificadas (`TOOL.SERVICE.INCREMENTAL`) |
| `completion.rs` | Clasificación del contexto de cursor, pila de bloques abiertos y orquestación del autocompletado (`TOOL.SERVICE.COMPLETION`) |
| `completion_templates.rs` | Generación determinista de plantillas bilingües desde `pseudolearn_lexicon` y pistas bilingües cruzadas (`H-17`, `H-18`, `Q1`) |
| `navigation.rs` | Consultas de ir a definición, buscar referencias, resaltado de documento y símbolos de documento (`TOOL.SERVICE.NAVIGATION`) |
| `hover.rs` | Consultas de información emergente (*hover*) y ayuda de firma (` signature_help`) bilingües (`TOOL.SERVICE.HOVER`) |
| `formatter.rs` | Formateador canónico (`EST-01`..`EST-10`) sobre `Tokens`, `TriviaStore` y `SyntaxTree` (`TOOL.FORMAT.STYLE`) |
| `translator.rs` | Traductor entre perfiles `es` $\leftrightarrow$ `en` sobre CST y `SemanticModel` con detección de colisiones (`TOOL.TRANSLATE.ROUND-TRIP`) |
| `lsp_protocol.rs` | Tipos de mensaje JSON-RPC 2.0 y conversión de posiciones byte/1-indexado $\leftrightarrow$ línea/columna 0-indexado UTF-16 |
| `lsp_session.rs` | Manejador de estado del servidor LSP (`LspServerSession`) para `initialize`, sincronización incremental y consultas (`TOOL.LSP.CAPABILITIES`) |

Los tests unitarios de caja negra e internos siguen la regla de `AGENTS.md` §5: archivos hermanos
`*_tests.rs` o carpeta `tests/` espejo de `src/`, sin comentarios y con casos felices, infelices y
bordes.

### 6.3. Extensión de `pseudolearn_api` y `apps/pseudolearn_cli`

- En `packages/pseudolearn_engine/crates/pseudolearn_api`:
  - Nuevo módulo `service.rs` (activado con la feature `language-service`, incluida en `default` y en
    `cli`), exponiendo `LanguageService`, `format_source`, `translate_source`, `complete_at`,
    `hover_at`, `signature_help_at`, `goto_definition`, `find_references`, `document_highlights` y
    `LspServerSession`.
- En `apps/pseudolearn_cli`:
  - Nuevos módulos `format_command.rs`, `translate_command.rs` y `lsp_command.rs`.
  - Actualización de `args.rs`, `dispatch.rs` y `messages.rs` con los subcomandos `formatear` (`format`),
    `traducir` (`translate`) y `lsp`.

---

## 7. Secuencia de ejecución paso a paso (Bloques `B0`..`B8`)

Cada bloque tiene entregables concretos y puertas de verificación mecánicas que deben quedar en verde
antes de pasar al siguiente.

### Bloque B0 · Especificaciones de R7 y contrato de `see` para el sujeto `service`

1. Redactar las **10 especificaciones nuevas** en `packages/pseudolearn_spec/specifications/tool/`:
   - `tool.service.node-identity.md`
   - `tool.service.incremental.md`
   - `tool.service.completion.md`
   - `tool.service.navigation.md`
   - `tool.service.hover.md`
   - `tool.format.style.md`
   - `tool.translate.round-trip.md`
   - `tool.lsp.capabilities.md`
   - `tool.cli.format.md`
   - `tool.cli.translate.md`
2. Actualizar `tool.cli.conventions.md` y `tool.cli.messages.md` (sin incrementar `version` ni añadir
   `"cambio"`) para registrar `compilar (build)`, `formatear (format)`, `traducir (translate)` y `lsp`.
3. En `packages/pseudolearn_spec`:
   - Actualizar `crates/see_cli/src/bindings.rs` para apuntar `"service"` a
     `"../pseudolearn_engine/conformance-service.yaml"`.
   - Añadir el lanzador de `"service"` en `crates/see_cli/src/subject_adapters.rs`
     (`pseudolearn_conformance --subject service`).
   - Extender `crates/see_core/src/requests.rs` y `crates/see_cli/src/conformance.rs` con la operación
     `service` para despachar los casos declarativos de `TOOL.SERVICE.*`, `TOOL.FORMAT.STYLE`,
     `TOOL.TRANSLATE.ROUND-TRIP` y `TOOL.LSP.CAPABILITIES`.
4. Actualizar `packages/pseudolearn_spec/specifications.lock` y verificar:
   - `cargo run -p see_cli -- validate` en verde (cero reglas huérfanas, cero referencias transitorias).

### Bloque B1 · Modelo semántico de consulta (`SemanticModel`) en `pseudolearn_semantic`

1. Añadir en `packages/pseudolearn_engine/crates/pseudolearn_semantic` el recolector de `SemanticModel`
   (`SymbolId`, `SymbolInfo`, `ReferenceOccurrence`, `ScopeSnapshot`, `ExpressionTypeEntry` y firmas de
   unidades de nivel superior `ModuleDeclarations`).
2. Exponer `analyze_model_with_options` y el punto de entrada de análisis de unidad con declaraciones de
   nivel superior precalculadas para reutilización incremental.
3. Añadir tests en `pseudolearn_semantic` cubriendo resolución de locales, parámetros, subprocesos,
   clases con herencia (`Extends`), tipos inferidos en modo flexible y sombreado de intrínsecas.
4. Puerta de bloque: `cargo test -p pseudolearn_semantic` y `rust-checks` en verde.

### Bloque B2 · Identidad de nodos (`SyntaxNodeId`) y sesión incremental (`DocumentSession`)

1. Crear el crate `packages/pseudolearn_engine/crates/pseudolearn_service` y declararlo en
   `Cargo.toml`, `architecture.yaml` y `README.md` de `packages/pseudolearn_engine`.
2. Implementar `node_identity.rs` (`TOOL.SERVICE.NODE-IDENTITY`), `unit_partition.rs` y
   `document_session.rs` (`TOOL.SERVICE.INCREMENTAL`).
3. Añadir los casos de prueba unitarios y de propiedades (`P1` de identidad y `P1` de equivalencia
   incremental).
4. Puerta de bloque: `cargo test -p pseudolearn_service` en verde y latencia incremental medida por
   debajo de los umbrales de `M1`.

### Bloque B3 · Autocompletado bilingüe determinista, navegación e información emergente

1. Implementar `completion.rs` y `completion_templates.rs` (`TOOL.SERVICE.COMPLETION`), garantizando:
   - Cero identificadores en español en plantillas en inglés (`H-17` resuelto).
   - `Segun expresion Hacer ... FinSegun` y `Switch expression Do ... EndSwitch` válidos (`H-18` resuelto).
   - Cierre prioritario de bloques abiertos, miembros de instancia tras `.`, tipos tras `Como`/`:` y
     pistas bilingües cruzadas.
2. Implementar `navigation.rs` (`TOOL.SERVICE.NAVIGATION`: definición, referencias, resaltado y símbolos
   de documento) y `hover.rs` (`TOOL.SERVICE.HOVER`: hover de símbolos/intrínsecas/palabras clave y
   `signature_help`).
3. Puerta de bloque: todos los tests unitarios de `completion`, `navigation` y `hover` en verde, más
   verificación de que el 100 % de las plantillas producen árboles sin errores sintácticos (`Q1`).

### Bloque B4 · Formateador canónico (`EST-01`..`EST-10`) y traductor entre perfiles (`es` ↔ `en`)

1. Implementar `formatter.rs` (`TOOL.FORMAT.STYLE`) sobre `Tokens`, `TriviaStore` y `SyntaxTree`.
2. Implementar `translator.rs` (`TOOL.TRANSLATE.ROUND-TRIP`) usando `Tokens`, `SyntaxTree` y
   `SemanticModel` (respetando sombreado de intrínsecas y reportando colisiones `reservedLexemeUsedAsName`
   sin renombrado silencioso).
3. Probar la idempotencia del formateo y la identidad de doble traducción sobre los **172 programas** del
   corpus bilingüe de ejemplos.
4. Puerta de bloque: 100 % de idempotencia de formateo y 100 % de identidad en doble traducción canónica.

### Bloque B5 · Servidor LSP (`LspServerSession`), fachada en `pseudolearn_api` y CLI (`format`, `translate`, `lsp`)

1. Implementar `lsp_protocol.rs` y `lsp_session.rs` en `pseudolearn_service` (`TOOL.LSP.CAPABILITIES`).
2. Exponer el servicio de lenguaje en `packages/pseudolearn_engine/crates/pseudolearn_api`.
3. Implementar en `apps/pseudolearn_cli` los subcomandos:
   - `pseudo formatear` / `pseudo format` (`--verificar`/`--check`, `--escribir`/`--write`)
   - `pseudo traducir` / `pseudo translate` (`--hacia`/`--to`, `--salida`/`--output`)
   - `pseudo lsp` (transporte JSON-RPC 2.0 con `Content-Length` sobre `stdin`/`stdout`)
4. Actualizar `apps/pseudolearn_cli/conformance.yaml` y `apps/pseudolearn_cli/README.md`.
5. Puerta de bloque: `cargo test` en `apps/pseudolearn_cli` y conformidad del sujeto `cli` al 100 % en
   `cumple`.

### Bloque B6 · Adaptador de conformidad del sujeto `service` y matriz `see conformance`

1. Crear `packages/pseudolearn_engine/conformance-service.yaml` vinculando todas las reglas de:
   - `TOOL.SERVICE.LOSSLESS-TREE` (`R1`, `R2`)
   - `TOOL.SERVICE.NODE-IDENTITY` (`R1`–`R3`)
   - `TOOL.SERVICE.INCREMENTAL` (`R1`–`R3`)
   - `TOOL.SERVICE.COMPLETION` (`R1`–`R5`)
   - `TOOL.SERVICE.NAVIGATION` (`R1`–`R3`)
   - `TOOL.SERVICE.HOVER` (`R1`–`R3`)
   - `TOOL.FORMAT.STYLE` (`R1`–`R4`)
   - `TOOL.TRANSLATE.ROUND-TRIP` (`R1`–`R4`)
   - `TOOL.LSP.CAPABILITIES` (`R1`–`R3`)
2. Implementar el adaptador `--subject service` en
   `packages/pseudolearn_engine/crates/pseudolearn_conformance`.
3. Registrar las propiedades y mediciones de `service` en
   `packages/pseudolearn_spec/results/property-conformance.json`.
4. Puerta de bloque: `cargo run -p see_cli -- conformance --subject service` y
   `cargo run -p see_cli -- conformance --subject cli` en **100 % `cumple` (`0` fallos)**.

### Bloque B7 · Ejecución de los experimentos E-09 y E-20

1. Ejecutar el arnés reproducible de **E-09** sobre los 172 programas reales (`es` y `en`), generando
   `packages/pseudolearn_spec/results/r7-service-e09.json` con:
   - Validez sintáctica de plantillas (`Q1` = 100 %),
   - Precisión@1, Precisión@5 ($\ge 85\,\%$) y ahorro de pulsaciones ($\ge 35\,\%$),
   - Latencia p50, p95 ($\le 50\text{ ms}$), MAD e IQR.
2. Ejecutar el arnés reproducible de **E-20** sobre `pseudo comprobar`, `pseudo ejecutar`,
   `pseudo compilar`, `pseudo formatear`, `pseudo traducir` y `pseudo lsp`, generando
   `packages/pseudolearn_spec/results/r7-toolchain-e20.json`.
3. Registrar los resultados medidos en `packages/pseudolearn_spec/results/measurement-conformance.json`.

### Bloque B8 · Verificadores, documentación autosuficiente y puerta de cierre de R7 (`phase-gate`)

1. Actualizar `packages/pseudolearn_engine/README.md`, `apps/pseudolearn_cli/README.md` y
   `packages/pseudolearn_spec/README.md` (`DOC-README-TRUTH`, `DOC-NO-TRANSIENT-REFS`).
2. Actualizar el estado de R7 en [07-fases.md](07-fases.md).
3. Ejecutar la batería completa de verificadores de los paquetes afectados:
   - `packages/pseudolearn_rust_checks`: `cargo test` y binario `rust-checks check` sobre
     `packages/pseudolearn_spec`, `packages/pseudolearn_engine` y `apps/pseudolearn_cli` (incluidos sus
     casos negativos).
   - `packages/pseudolearn_spec`: `cargo test`, `cargo clippy --all-targets -- -D warnings`,
     `cargo run -p see_cli -- validate`, `cargo run -p see_cli -- conformance`.
   - `packages/pseudolearn_engine`: `cargo test`, `cargo clippy --all-targets -- -D warnings`.
   - `apps/pseudolearn_cli`: `cargo test`, `cargo clippy --all-targets -- -D warnings`.
4. Confirmar rama `feature/agregar-ruta-de-especificacion`, realizar commit en inglés (`LANG-EN-CODE`,
   sin atribución de IA), push ordinario comprobado y detenerse (`PHASE-STOP`).

---

## 8. Registro de riesgos de R7 y escalera de mitigación

| ID | Riesgo | Señal temprana | Mitigación prevista |
|---|---|---|---|
| `RR-R7-01` | Comentarios perdidos o desplazados al formatear construcciones con múltiples ramas (`Si`/`Sino`, `Segun`/`Caso`/`De Otro Modo`) | Fallo en `TOOL.FORMAT.STYLE#P1` o diferencia en la lista de tokens con trivia antes y después de `format` | El formateador adjunta una poscondición interna que compara la secuencia de comentarios de entrada y salida; si algún nodo o comentario no se consumió, aborta la reescritura del nodo y devuelve el tramo original sin pérdida |
| `RR-R7-02` | Colisiones de palabras reservadas al traducir entre `es` y `en` en ejemplos del corpus (p. ej. identificador `a`, `o`, `y` en inglés traducido a español, o `in`, `to`, `do` en español traducido a inglés) | Diagnóstico `reservedLexemeUsedAsName` al traducir ejemplos reales | `TOOL.TRANSLATE.ROUND-TRIP#R3` distingue entre programas libres de colisiones (donde exige round-trip idéntico) y programas con colisiones (donde exige reportar `reservedLexemeUsedAsName` sin renombrado silencioso) |
| `RR-R7-03` | Sombreado de funciones de biblioteca estándar (`longitud`, `azar`, `rc`) durante la traducción | Un identificador local llamado `longitud` se traduce erróneamente a `length` | El traductor consulta `SemanticModel::resolve_reference_at(span)` antes de traducir cualquier identificador que coincida con un nombre de intrínseca; si resuelve a un `SymbolId` del usuario, no se traduce |
| `RR-R7-04` | Desfase entre desplazamientos en bytes UTF-8 del motor y posiciones `(line, character)` UTF-16 de LSP con tildes o `ñ` (`á`, `é`, `í`, `ó`, `ú`, `ñ`) | Rangos de diagnósticos o resaltado desplazados en líneas con caracteres multibyte | `lsp_protocol.rs` convierte explícitamente entre desplazamientos de bytes UTF-8 y unidades de código UTF-16 por línea, con casos de prueba explícitos con identificadores acentuados (`año`, `número`, `condición`) |
| `RR-R7-05` | Degradación de Precisión@5 en E-09 por exceso de palabras clave irrelevantes en posición de expresión | Precisión@5 $< 85\,\%$ en el primer pase de E-09 | Separar estrictamente los conjuntos de candidatos de *inicio de sentencia*, *expresión*, *tipo* y *acceso a miembro*, y priorizar los símbolos locales declarados en el alcance actual sobre las intrínsecas globales |

---

## 9. Criterios de aceptación para dar R7 por cerrada

- [x] Las 10 especificaciones nuevas (`TOOL.SERVICE.NODE-IDENTITY`, `TOOL.SERVICE.INCREMENTAL`,
      `TOOL.SERVICE.COMPLETION`, `TOOL.SERVICE.NAVIGATION`, `TOOL.SERVICE.HOVER`, `TOOL.FORMAT.STYLE`,
      `TOOL.TRANSLATE.ROUND-TRIP`, `TOOL.LSP.CAPABILITIES`, `TOOL.CLI.FORMAT`, `TOOL.CLI.TRANSLATE`)
      están redactadas, validadas por `see validate` y bloqueadas en `specifications.lock`.
- [x] El crate `pseudolearn_service` está implementado en `packages/pseudolearn_engine` con análisis
      incremental por unidad, identidad estable de nodos, autocompletado bilingüe determinista,
      navegación, hover, formateo canónico, traducción entre perfiles y sesión LSP.
- [x] `apps/pseudolearn_cli` implementa `pseudo formatear` (`format`), `pseudo traducir` (`translate`) y
      `pseudo lsp`.
- [x] El sujeto `service` y el sujeto `cli` están al **100 % en `cumple`** en `see conformance`.
- [x] Formateo idempotente verificado en todo el corpus ($\text{format}(\text{format}(P)) = \text{format}(P)$).
- [x] Doble traducción idéntica al original en todo el corpus canónico libre de colisiones.
- [x] Experimentos **E-09** (`r7-service-e09.json`) y **E-20** (`r7-toolchain-e20.json`) ejecutados y
      cumpliendo las latencias y umbrales de calidad en el hardware de referencia.
- [x] Todos los tests y verificadores (`rust-checks`, `clippy`, `see validate`, `see conformance`) en
      verde y `README.md` actualizados sin referencias transitorias (`DOC-NO-TRANSIENT-REFS`).
