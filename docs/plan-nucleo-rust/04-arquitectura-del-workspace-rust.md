# 04 · Arquitectura del workspace Rust

> **Estado:** arquitectura de ADR-001 aprobada en R0; cada miembro adquiere implementación en su
> fase. El README de cada miembro existente es su fuente de verdad operativa. Los verificadores de
> R0 usan los crates de infraestructura descritos en su README; el motor sigue sin código hasta R4.

---

## 1. Miembros nuevos del monorepo

Se respeta la regla del `README.md` raíz §3.1:

- `packages/` aloja lo reutilizable que no se despliega;
- `apps/` aloja lo que se despliega o se distribuye.

Tampoco se crea un `Cargo.toml` en la raíz, por la misma razón por la que no hay `pubspec.yaml` de raíz:
la raíz no es un paquete.

| Miembro                               | Categoría  | Qué es                                                                     | Depende de                         | Fase  |
|---------------------------------------|------------|----------------------------------------------------------------------------|------------------------------------|-------|
| `packages/pseudolearn_rust_checks`    | packages   | Verificadores mecánicos para miembros Rust: límites, comentarios, nombres, capas, `unsafe` | —                    | R0    |
| `packages/pseudolearn_spec`           | packages   | Corpus de especificaciones y herramienta `see` (workspace Cargo propio)     | `pseudolearn_rust_checks` (solo desarrollo) | R1 |
| `packages/pseudolearn_engine`         | packages   | El núcleo: workspace Cargo con un crate por capa                            | `pseudolearn_rust_checks` (solo desarrollo); lee la exportación del corpus (§5) | R4 |
| `apps/pseudolearn_cli`                | apps       | Binario `pseudo`: `check`, `run`, `build`, `ir`, `format`, `translate`, `lsp` | `pseudolearn_engine` (por ruta)  | R4    |
| `apps/pseudolearn_app/native`         | (dentro de la app) | Crate puente `pseudolearn_bridge` para `flutter_rust_bridge`         | `pseudolearn_engine` (por ruta)    | R8    |

Dirección de dependencias entre miembros:

```
apps/pseudolearn_app ──► apps/pseudolearn_app/native ──┐
apps/pseudolearn_cli ──────────────────────────────────┼──► packages/pseudolearn_engine
packages/pseudolearn_core (Dart, reference) ◄─┐        │            ▲
                                              │        │            │ lee exportación JSON verificada
                                   protocolo  │        │            │
                                   por proceso│        │   packages/pseudolearn_spec
                                              └────────┴────────────┘ (no depende de ningún miembro)
```

- `pseudolearn_spec` **no depende** de ningún miembro. Habla con los sujetos por proceso
  ([05](05-sistema-de-especificaciones.md)).
- `pseudolearn_engine` **no depende** de `pseudolearn_spec` como crate. Consume su **exportación** como
  datos (§5), igual que la app consume los artefactos de `pseudolearn_brand`.
- La versión de Rust se fija en un `rust-toolchain.toml` por miembro. Un verificador de la CI comprueba
  que todos fijan la misma.

---

## 2. `pseudolearn_engine`: un crate por capa

Cada capa es un crate. **Cargo impide los ciclos y no deja usar un crate que no se declara como
dependencia**: la dirección de capas (`LAYER-DIRECTION`) se cumple al compilar. Lo único que queda para
un verificador es comprobar que las dependencias declaradas en cada `Cargo.toml` coinciden con
`architecture.yaml` (`LAYER-DECLARED`).

### 2.1 Capas

| Nivel | Crate | Responsabilidad | Imports internos permitidos |
|---|---|---|---|
| 0 | pseudolearn_source | Representa el texto fuente original con posiciones verificadas | — |
| 0 | pseudolearn_abi | Declara la disposición compartida de los valores de ejecución | — |
| 1 | pseudolearn_diagnostics | Representa diagnósticos mediante códigos con argumentos tipados | source |
| 1 | pseudolearn_lexicon | Expone vocabularios bilingües generados desde el corpus | source |
| 2 | pseudolearn_syntax | Construye un árbol sintáctico sin pérdida para cualquier texto | source, diagnostics, lexicon |
| 3 | pseudolearn_semantic | Produce un HIR tipado desde la resolución estática | source, diagnostics, lexicon, syntax |
| 3 | pseudolearn_ir | Define la representación intermedia verificada | source, abi |
| 4 | pseudolearn_lowering | Traduce el HIR a representación intermedia observable | semantic, ir, diagnostics |
| 4 | pseudolearn_bytecode | Traduce la RI verificada a bytecode gemelo con asignación bicameral de registros | ir, source |
| 4 | pseudolearn_runtime | Gestiona los valores de ejecución mediante memoria persistente determinista | abi, diagnostics |
| 5 | pseudolearn_library | Implementa las funciones incorporadas sobre valores del runtime | runtime, diagnostics |
| 6 | pseudolearn_vm | Ejecuta bytecode verificado emitiendo eventos observables | bytecode, runtime, library, diagnostics |
| 7 | pseudolearn_timeline | Reconstruye el estado observable de cualquier instante mediante puntos de control | vm, runtime, bytecode, diagnostics |
| 8 | pseudolearn_api | Ofrece operaciones públicas totales sobre recursos del núcleo | source, abi, diagnostics, lexicon, syntax, semantic, ir, lowering, bytecode, runtime, library, vm, timeline |
| 9 | pseudolearn_conformance | Adapta la API al protocolo de conformidad por procesos | api |

Capas posteriores: codegen (nivel 6, ir/abi, R6); service (nivel 6, source/diagnostics/lexicon/syntax/semantic, R7); wasm (nivel 9, api, unsafe solo generado, R8).
Se incorporan a las reglas con sus carpetas al empezar su fase; no hay README ni crates vacíos para ellas en R3.

*Features* de `pseudolearn_api`:

| *Feature*             | Activa                  | La usan                         |
|-----------------------|-------------------------|---------------------------------|
| `native-compilation`  | `pseudolearn_codegen`   | CLI, app de escritorio          |
| `language-service`    | `pseudolearn_service`   | CLI (`pseudo lsp`), app         |

Los builds de iOS, Android y Wasm **no activan** `native-compilation`
([00](00-adr-001-nucleo-en-rust.md) §5).

### 2.2 Diagrama por niveles

Cada nivel solo depende de niveles inferiores, y solo de los crates que la tabla de §2.1 permite.

```text
Nivel 9  conformance, wasm* → api
Nivel 8  api → capas inferiores permitidas
Nivel 7  timeline → vm, runtime, bytecode, diagnostics
Nivel 6  vm → bytecode, runtime, library, diagnostics; codegen* → ir, abi; service* → front-end
Nivel 5  library → runtime, diagnostics
Nivel 4  bytecode → ir, source; lowering → semantic, ir, diagnostics; runtime → abi, diagnostics
Nivel 3  semantic → front-end; ir → source, abi
Nivel 2  syntax → source, diagnostics, lexicon
Nivel 1  diagnostics, lexicon → source
Nivel 0  source, abi
* Capas de fases posteriores.
```

### 2.3 Flujo de datos

```
texto ──► pseudolearn_source ──► SourceText (bytes originales, índice de líneas)
      ──► pseudolearn_syntax ──► árbol sin pérdida + diagnósticos léxicos y sintácticos
      ──► pseudolearn_semantic ──► HIR tipado + diagnósticos semánticos
      ──► pseudolearn_lowering ──► módulo de RI verificado
            ├─► pseudolearn_bytecode ──► pseudolearn_vm ──► pseudolearn_timeline ──► eventos y estado observable
            └─► pseudolearn_codegen ──► objeto nativo ──► enlace con libpseudolearn_runtime.a ──► binario
```

---

## 3. Decisiones internas que el plan fija (y que pasarán a los `README.md`)

Son decisiones de **cómo**, no de **qué**: viven en el `README.md` de cada crate, no en el corpus. Se
listan aquí porque condicionan el orden de trabajo.

| Crate | Elección | Alternativa descartada | Verificación |
|---|---|---|---|
| syntax | Tokens en columnas, trivia y árbol postorden; descenso recursivo con recuperación, vistas generadas | rowan verde/rojo, AST con pérdida, parser generado | LOSSLESS-TREE, E-08 |
| semantic | Arenas tipadas en columnas y HIR con clase de valor | Rc/RefCell | PERF.FRONTEND.THROUGHPUT |
| ir | CFG SSA con parámetros, celdas, observe, masa de sentencia y regiones puras | Árbol de expresiones o pila | IR.*, cobertura de reglas |
| bytecode | Asignación bicameral, gemelos con marcos idénticos, código acolchado, despacho generado y superinstrucciones medidas | Modos de despacho con bandera, gemelos asignados separadamente | Diferencial de gemelos |
| vm | Bancos enmascarados, ventanas solapadas, combustible por bloque con caída precisa | unsafe, comprobaciones por acceso | ENG.*, PERF.VM.* |
| runtime | Páginas persistentes, asas u32, ordinales, marcado/barrido con marcas laterales y disparo por celdas | Conteo de referencias, movimiento, unsafe | MEM.*, E-02, E-12 |
| runtime | UTF-8, indicador ASCII y migas cada 64 puntos de código | UTF-32 | LANG.TYPES.TEXT |
| timeline | Cinta, puntos de control de páginas y bancos, reproducción, raleo exponencial y horizonte declarado | Copia completa por evento y tope fijo de pasos | ENG.STATE.*, E-06 |
| codegen | Banco de referencias como pila sombra, trampas diferidas y transferencia AOT → VM en bloques fríos; enlace del sistema | Recolección conservadora y marcos distintos | RT.ABI, E-NR1 (R6) |
| service | Incrementalidad sobre postorden elegida con E-08; salsa aplazado | Dependencia anticipada de salsa | R7 |
| api | Recursos, lotes columnares y consulta por referencia e instante | Un objeto por evento y copias completas | API.* |


---

## 4. Archivo de reglas del workspace

`packages/pseudolearn_engine/architecture.yaml`. Forma propuesta: es la misma estructura que el del núcleo
Dart, con lo que Rust añade.

```yaml
package: pseudolearn_engine
declarative: true
unsafe_allowed: [pseudolearn_wasm]
generated_sources:
  - crates/pseudolearn_diagnostics/generated
  - crates/pseudolearn_lexicon/generated
  - crates/pseudolearn_syntax/generated
  - crates/pseudolearn_bytecode/generated
  - crates/pseudolearn_vm/generated
deterministic_output_crates: [pseudolearn_diagnostics, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_bytecode, pseudolearn_vm, pseudolearn_timeline, pseudolearn_api]
layers:
  - name: pseudolearn_source
    path: crates/pseudolearn_source
    may_import: []
    external_dependencies: [unicode-normalization, unicode-ident]
    unsafe_allowed: false
  - name: pseudolearn_abi
    path: crates/pseudolearn_abi
    may_import: []
    external_dependencies: []
    unsafe_allowed: false
  - name: pseudolearn_diagnostics
    path: crates/pseudolearn_diagnostics
    may_import: [pseudolearn_source]
    external_dependencies: [serde_json]
    unsafe_allowed: false
  - name: pseudolearn_lexicon
    path: crates/pseudolearn_lexicon
    may_import: [pseudolearn_source]
    external_dependencies: [serde_json]
    unsafe_allowed: false
  - name: pseudolearn_syntax
    path: crates/pseudolearn_syntax
    may_import: [pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon]
    external_dependencies: [serde_json]
    unsafe_allowed: false
  - name: pseudolearn_semantic
    path: crates/pseudolearn_semantic
    may_import: [pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax]
    external_dependencies: []
    unsafe_allowed: false
  - name: pseudolearn_ir
    path: crates/pseudolearn_ir
    may_import: [pseudolearn_source, pseudolearn_abi]
    external_dependencies: [serde_json]
    unsafe_allowed: false
  - name: pseudolearn_lowering
    path: crates/pseudolearn_lowering
    may_import: [pseudolearn_semantic, pseudolearn_ir, pseudolearn_diagnostics]
    external_dependencies: []
    unsafe_allowed: false
  - name: pseudolearn_bytecode
    path: crates/pseudolearn_bytecode
    may_import: [pseudolearn_ir, pseudolearn_source]
    external_dependencies: [serde_json]
    unsafe_allowed: false
  - name: pseudolearn_runtime
    path: crates/pseudolearn_runtime
    may_import: [pseudolearn_abi, pseudolearn_diagnostics]
    external_dependencies: []
    unsafe_allowed: false
  - name: pseudolearn_library
    path: crates/pseudolearn_library
    may_import: [pseudolearn_runtime, pseudolearn_diagnostics]
    external_dependencies: []
    unsafe_allowed: false
  - name: pseudolearn_vm
    path: crates/pseudolearn_vm
    may_import: [pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_diagnostics]
    external_dependencies: [serde_json]
    unsafe_allowed: false
  - name: pseudolearn_timeline
    path: crates/pseudolearn_timeline
    may_import: [pseudolearn_vm, pseudolearn_runtime, pseudolearn_bytecode, pseudolearn_diagnostics]
    external_dependencies: []
    unsafe_allowed: false
  - name: pseudolearn_api
    path: crates/pseudolearn_api
    may_import: [pseudolearn_source, pseudolearn_abi, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_ir, pseudolearn_lowering, pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_vm, pseudolearn_timeline]
    external_dependencies: [serde, serde_json]
    unsafe_allowed: false
  - name: pseudolearn_conformance
    path: crates/pseudolearn_conformance
    may_import: [pseudolearn_api]
    external_dependencies: [serde, serde_json]
    unsafe_allowed: false
limits:
  file_lines: 300
  function_lines: 40
  positional_parameters: 4
  nesting_depth: 3
  public_methods_per_class: 7
  unsafe_function_lines: 10
names:
  minimum_length: 3
  permitted_short: [id, io, ir, vm, gc, os]
  forbidden_components: [ctx, cfg, env, expr, stmt, decl, tok, idx, len, pos, cnt, num, buf, ptr, ref, val, msg, err, res, ret, args, params, attrs, tmp, temp, aux, data, info, item, obj, thing, stuff, foo, bar]
  forbidden_files: [utils, helpers, common, misc]
```

La forma ejecutable usa `name`, `path` y `may_import`, con listas explícitas de dependencias.
`declarative: true` exige README por capa y rechaza Cargo.toml o fuentes Rust.
`unsafe_allowed` conserva la política para el puente Wasm; todos los crates presentes lo prohíben.
Los niveles están en la tabla arquitectónica; las dependencias ejecutables están en el YAML.


---

## 5. Artefactos generados desde el corpus

Varios crates necesitan datos que el corpus define. Copiarlos a mano viola `GEN-NO-HAND-COPY`:

| Dato normativo                                       | Especificación fuente          | Crate consumidor          | Qué se genera                              |
|------------------------------------------------------|--------------------------------|---------------------------|--------------------------------------------|
| Vocabulario bilingüe de cada perfil                   | `LANG.PROFILE.VOCABULARY`      | `pseudolearn_lexicon`     | Tablas de lexemas por perfil               |
| Nombres bilingües de funciones incorporadas           | `LIB.MODEL`, `LIB.CORE.*`      | `pseudolearn_lexicon`     | Tabla de funciones                          |
| Catálogo de códigos de diagnóstico y sus fichas       | `DIAG.CATALOG`, `DIAG.MESSAGES` | `pseudolearn_diagnostics` | `enum DiagnosticCode` y plantillas de mensaje bilingües |
| Gramática formal                                      | `LANG.SYNTAX.GRAMMAR`          | `pseudolearn_syntax`      | `enum SyntaxKind` y vistas tipadas de nodos |

Mecanismo, con el mismo patrón que `pseudolearn_brand`:

1. `see export` escribe `packages/pseudolearn_engine/specification-export/*.json`. **Este archivo sí se
   versiona**, porque lo consume un build ajeno (`AGENTS.md` §9).
2. `see export --check` falla si la exportación versionada no coincide con la que produciría el corpus
   actual. Es el verificador del consumidor: un `*-STALE` como los de la marca.
3. El `build.rs` de cada crate consumidor convierte el JSON en código Rust bajo `OUT_DIR`. El código
   generado **no se versiona** y queda exento de los límites de tamaño, pero no del verificador de
   comentarios.

---

## 6. Puente con Flutter (R8)

- Crate `apps/pseudolearn_app/native` (`pseudolearn_bridge`), de tipo `staticlib` + `cdylib`, que solo
  reexpone `pseudolearn_api`. No contiene lógica: `APP.ENGINE.BOUNDARY`.
- `flutter_rust_bridge` genera el código Dart en `apps/pseudolearn_app/lib/engine/bridge/`. Ese código lo
  consume el build de Flutter: se versiona y se verifica regenerándolo en la CI.
- La capa `engine/` de la app ya aísla el núcleo. Durante R8 conviven dos adaptadores, `DartCoreEngine`
  (núcleo Dart) y `RustCoreEngine` (puente), detrás de la misma interfaz. Se cambia de uno a otro por
  inyección, no con condicionales repartidos por la app.
- Compilación por plataforma con la integración de Cargo que trae `flutter_rust_bridge` (cargokit):
  - iOS: `aarch64-apple-ios` y el simulador, en un `xcframework`;
  - Android: `arm64-v8a`, `armeabi-v7a`, `x86_64`;
  - macOS y Windows: los objetivos de escritorio que la app ya distribuye.
- Los flujos de publicación de `.github/workflows/` instalan la cadena Rust y los objetivos necesarios.
  Es un cambio del `README.md` de la app en R8.
- **Web:** `pseudolearn_wasm` se compila con `wasm-bindgen`. Lo pueden consumir Flutter web y, si se
  decide, `apps/fe-pseudolearn` para un entorno de pruebas en el navegador (fuera de este plan).

---

## 7. CLI `pseudo` (R4 en adelante)

`apps/pseudolearn_cli`, binario `pseudo`. Es un consumidor más de `pseudolearn_api`, con las *features*
`native-compilation` y `language-service`.

| Orden               | Especificación         | Fase |
|---------------------|------------------------|------|
| `pseudo comprobar` (`check`)      | `TOOL.CLI.CHECK`       | R4   |
| `pseudo ejecutar` (`run`)        | `TOOL.CLI.RUN`         | R5   |
| `pseudo ri` (`ir`)         | `TOOL.CLI.IR`          | R5   |
| `pseudo compilar` (`build`)      | `TOOL.CLI.BUILD`       | R6   |
| `pseudo formatear` (`format`)     | `TOOL.CLI.FORMAT`      | R7   |
| `pseudo traducir` (`translate`)  | `TOOL.CLI.TRANSLATE`   | R7   |
| `pseudo lsp`        | `TOOL.LSP.CAPABILITIES` | R7  |

Español canónico, alias ingleses siempre aceptados. Idioma de interfaz: bandera > entorno > preferencias
de usuario > sistema > español; ni la forma de la orden ni el vocabulario del programa lo deciden.
El vocabulario se autodeclara con la primera apertura significativa; --vocabulario lo fuerza.
Los mensajes y narraciones proceden de TOOL.CLI.MESSAGES; JSON y salida del programa no se traducen.
`pseudo preferencias idioma en` (alias `preferences language en`) gestiona datos declarativos del usuario.

---

## 8. Verificadores de cada miembro Rust

Todos con su caso negativo (`AGENTS.md` §5). Viven en `packages/pseudolearn_rust_checks` y cada miembro
los ejecuta con su propio `architecture.yaml`.

| Verificador                      | Qué rechaza                                                                                   | Regla                                   |
|----------------------------------|-----------------------------------------------------------------------------------------------|-----------------------------------------|
| `cargo fmt --check`              | Formato distinto del canónico                                                                  | —                                       |
| `cargo clippy -- -D warnings` con los lints de [01](01-principios-y-reglas.md) §3, §5, §6 | Pánicos, aritmética implícita, nombres cortos, funciones largas | `QUALITY-NO-PANIC`, `QUALITY-SEMANTIC-NAMES`, `SIZE-*` |
| `rust-checks layers`             | Dependencias de `Cargo.toml` no declaradas en `architecture.yaml`; crates no declarados; capas declaradas sin crate | `LAYER-DIRECTION`, `LAYER-DECLARED` |
| `rust-checks comments`           | Cualquier comentario o `#[doc]` en código, incluido el generado                                | `QUALITY-NO-COMMENTS`                   |
| `rust-checks names`              | Abreviaturas, nombres de relleno, genéricos y tiempos de vida de una letra, archivos `utils`    | `QUALITY-SEMANTIC-NAMES`                |
| `rust-checks limits`             | Archivos, funciones, anidación y métodos públicos por encima de los límites                     | `SIZE-*`                                |
| `rust-checks unsafe`             | `unsafe` fuera de los crates permitidos; función `unsafe` sin fila en el `README.md`, o fila sin función | [01](01-principios-y-reglas.md) §4 |
| `rust-checks attributes`         | `#[allow]` y `#[expect]` en código                                                             | [01](01-principios-y-reglas.md) §4      |
| `cargo deny check`               | Licencias, avisos de seguridad, duplicados, dependencias externas no permitidas                | [01](01-principios-y-reglas.md) §9      |
| `cargo test --workspace`         | Tests de unidad y de caja negra                                                                | `TEST-BOTH-PATHS`                       |
| `see export --check`             | Exportación del corpus desactualizada                                                          | `GEN-NO-HAND-COPY`                      |
| `see conform --subject engine`   | Regresiones en la matriz de conformidad                                                        | `SPEC-*` (propuestas)                   |

Cada workspace Rust incluye un crate de tareas `xtask` (convención de Rust), fuera de las capas y
declarado en `architecture.yaml` como `tooling`. Ese crate ejecuta por proceso
`pseudolearn_rust_checks` y encadena todos los verificadores. El `README.md` del workspace lo documentará
en «Cómo se verifica»:

```bash
(cd packages/pseudolearn_engine && cargo xtask verify)
```
