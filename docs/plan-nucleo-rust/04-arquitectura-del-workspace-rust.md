# 04 · Arquitectura del workspace Rust

> **Estado:** propuesta. Cuando se apruebe, el contenido de este documento pasa a los `README.md` de
> los miembros nuevos, que son su fuente de verdad (`DOC-README-TRUTH`). Este documento deja de ser
> normativo en ese momento. Los nombres de crates y módulos son provisionales hasta R0.

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

| Nº | Crate                       | Responsabilidad (una frase, sin «y»)                                                    | Puede depender de                          | `unsafe`  | Especificaciones que cumple |
|----|-----------------------------|------------------------------------------------------------------------------------------|--------------------------------------------|-----------|-----------------------------|
| 0  | `pseudolearn_source`        | Representa el texto fuente normalizado con sus posiciones y tramos                        | —                                          | No        | `LANG.SOURCE.*`             |
| 0  | `pseudolearn_abi`           | Declara la disposición de valores y los símbolos que comparten runtime y código generado  | —                                          | No        | `RT.ABI`                    |
| 1  | `pseudolearn_diagnostics`   | Modela diagnósticos independientes del idioma con su catálogo de códigos generado          | source                                     | No        | `DIAG.MODEL`, `DIAG.CATALOG`, `DIAG.SEVERITY.POLICY`, `DIAG.ORDERING` |
| 1  | `pseudolearn_lexicon`       | Expone los perfiles y su vocabulario bilingüe generado                                    | source                                     | No        | `LANG.PROFILE.*`, `LIB.MODEL` |
| 2  | `pseudolearn_syntax`        | Convierte texto en un árbol de sintaxis sin pérdida con recuperación de errores           | source, diagnostics, lexicon               | No        | `LANG.LEXICAL.*`, `LANG.SYNTAX.*`, `LANG.PROGRAM.*`, `LANG.STMT.TERMINATION`, `TOOL.SERVICE.LOSSLESS-TREE` |
| 3  | `pseudolearn_semantic`      | Resuelve nombres y comprueba tipos produciendo un árbol tipado (HIR)                      | source, diagnostics, lexicon, syntax       | No        | `LANG.TYPES.*` (estático), `LANG.DECL.*`, `LANG.SUBPROGRAM.*` (estático), `LANG.CLASS.*` (estático) |
| 3  | `pseudolearn_ir`            | Define la representación intermedia con su verificador y su formato textual               | source, abi                                | No        | `IR.MODEL`, `IR.INSTRUCTIONS`, `IR.WELL-FORMEDNESS`, `IR.TEXT-FORMAT`, `IR.SOURCE-MAP` |
| 4  | `pseudolearn_lowering`      | Traduce el árbol tipado a representación intermedia                                       | semantic, ir, diagnostics                  | No        | `IR.LOWERING`, `IR.OBSERVATION-POINTS` |
| 4  | `pseudolearn_runtime`       | Gestiona valores, montón, recolección y aritmética comprobada en ejecución                 | abi, diagnostics                           | **Sí**    | `MEM.*`, `RT.HOST.INTERFACE`, la parte de ejecución de `LANG.TYPES.*` y `LANG.OPS.*` |
| 5  | `pseudolearn_library`       | Implementa las funciones incorporadas sobre el runtime                                    | runtime, diagnostics                       | No        | `LIB.CORE.*`                |
| 6  | `pseudolearn_vm`            | Compila la RI a bytecode y la ejecuta emitiendo eventos observables                       | ir, runtime, library, diagnostics          | No        | `ENG.*`                     |
| 6  | `pseudolearn_codegen`       | Compila la RI a código objeto nativo con Cranelift                                         | ir, abi                                    | No        | `RT.FAULT.REPORTING`, `RT.LINKING` (con `pseudo build`) |
| 6  | `pseudolearn_service`       | Responde consultas del servicio de lenguaje sobre documentos abiertos                     | source, diagnostics, lexicon, syntax, semantic | No    | `TOOL.SERVICE.*`, `TOOL.FORMAT.*`, `TOOL.TRANSLATE.*` |
| 7  | `pseudolearn_api`           | Ofrece la superficie pública estable del núcleo como operaciones que nunca entran en pánico | todos los anteriores; `codegen` y `service` detrás de *features* | No | `API.*`, `DIAG.ENGINE.INTERNAL-FAULT` |
| 8  | `pseudolearn_wasm`          | Expone la API pública a JavaScript mediante Wasm                                          | api                                        | **Sí** (generado por `wasm-bindgen`) | — |
| 8  | `pseudolearn_conformance`   | Implementa el protocolo de conformidad sobre la API (binario no distribuido)              | api                                        | No        | `SEE.ADAPTER.PROTOCOL`      |

*Features* de `pseudolearn_api`:

| *Feature*             | Activa                  | La usan                         |
|-----------------------|-------------------------|---------------------------------|
| `native-compilation`  | `pseudolearn_codegen`   | CLI, app de escritorio          |
| `language-service`    | `pseudolearn_service`   | CLI (`pseudo lsp`), app         |

Los builds de iOS, Android y Wasm **no activan** `native-compilation`
([00](00-adr-001-nucleo-en-rust.md) §5).

### 2.2 Diagrama por niveles

Cada nivel solo depende de niveles inferiores, y solo de los crates que la tabla de §2.1 permite.

```
Nivel 8   pseudolearn_wasm        pseudolearn_conformance        (y fuera del workspace: pseudo, pseudolearn_bridge)
             │                       │
Nivel 7   pseudolearn_api ───────────┘   fachada: única entrada para todos los consumidores
             │
Nivel 6   pseudolearn_vm      pseudolearn_codegen*      pseudolearn_service*
             │                    │                          │
Nivel 5   pseudolearn_library     │                          │
             │                    │                          │
Nivel 4   pseudolearn_runtime     │      pseudolearn_lowering│
             │                    │          │               │
Nivel 3      │               pseudolearn_ir ◄┘   pseudolearn_semantic
             │                    │                          │
Nivel 2      │                    │              pseudolearn_syntax
             │                    │                          │
Nivel 1   pseudolearn_diagnostics             pseudolearn_lexicon
             │                    │                          │
Nivel 0   pseudolearn_source                  pseudolearn_abi

* detrás de una feature de pseudolearn_api
```

### 2.3 Flujo de datos

```
texto ──► pseudolearn_source ──► SourceText (NFC, índice de líneas)
      ──► pseudolearn_syntax ──► árbol sin pérdida + diagnósticos léxicos y sintácticos
      ──► pseudolearn_semantic ──► HIR tipado + diagnósticos semánticos
      ──► pseudolearn_lowering ──► módulo de RI verificado
            ├─► pseudolearn_vm ──► bytecode ──► ejecución ──► eventos y estado observable
            └─► pseudolearn_codegen ──► objeto nativo ──► enlace con libpseudolearn_runtime.a ──► binario
```

---

## 3. Decisiones internas que el plan fija (y que pasarán a los `README.md`)

Son decisiones de **cómo**, no de **qué**: viven en el `README.md` de cada crate, no en el corpus. Se
listan aquí porque condicionan el orden de trabajo.

| Crate          | Decisión propuesta                                                                                                                                | Alternativa descartada                       | Se valida con |
|----------------|---------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------|---------------|
| syntax         | Árbol verde/rojo (`rowan`). Los tipos de nodo se **generan** de `LANG.SYNTAX.GRAMMAR`                                                               | AST con pérdida como el núcleo Dart          | `TOOL.SERVICE.LOSSLESS-TREE` |
| syntax         | Parser de descenso recursivo escrito a mano, guiado por la gramática; la gramática genera tests de aceptación                                       | Generador de parsers (LALR, PEG)             | `LANG.SYNTAX.RECOVERY` |
| semantic       | Arenas con índices tipados (`SymbolId`, `TypeId`) en vez de referencias con tiempos de vida                                                         | Grafo con `Rc<RefCell<…>>`                   | `PERF.FRONTEND.THROUGHPUT` |
| ir             | CFG tipado en forma SSA con parámetros de bloque (el mismo modelo que Cranelift)                                                                     | Árbol de expresiones; pila                   | `IR.LOWERING`, R6 |
| vm             | VM **de registros** con instrucciones especializadas por tipo (`add_integer_checked`); los tipos estáticos permiten ranuras sin caja              | VM de pila con valores en caja               | `PERF.VM.THROUGHPUT` |
| vm             | Dos modos de despacho, **observado** y **no observado**. El no observado no comprueba eventos                                                       | Un solo modo con comprobación de bandera     | `PERF.VM.STEP-LATENCY`, H-12 |
| vm             | Instantáneas incrementales con puntos de control periódicos                                                                                        | Instantánea completa por evento              | `ENG.STATE.INCREMENTAL`, E-06 |
| runtime        | Recolector **preciso, sin movimiento**, de marcado y barrido. Las raíces de la VM se conocen por el tipo de cada ranura                              | Conteo de referencias (descartado por H-35)  | `MEM.MANAGED.UNOBSERVABLE`, E-12 |
| runtime        | Texto en UTF-8 con un indicador «solo ASCII», para acceso por posición en tiempo constante en el caso común                                         | UTF-32                                       | `LANG.TYPES.TEXT`, `PERF.*` |
| codegen        | Raíces del recolector en código nativo con **pila sombra** al principio. Mapas de pila de Cranelift solo si E-12 lo justifica                       | Recolección conservadora                     | `RT.ABI`      |
| codegen        | Enlazado con el enlazador del sistema (`cc`) al principio. Distribuir `lld` es decisión de R6                                                        | Enlazador propio                             | `RT.LINKING`  |
| api            | Recursos con identificador (documento, análisis, ejecución); avance por **lotes** de eventos; consulta de estado **por referencia**                  | Copiar el estado completo en cada paso       | `API.EXECUTE`, `API.STATE.QUERY` |

---

## 4. Archivo de reglas del workspace

`packages/pseudolearn_engine/architecture.yaml`. Forma propuesta: es la misma estructura que el del núcleo
Dart, con lo que Rust añade.

```yaml
package: pseudolearn_engine
workspace_root: crates

layers:
  - { id: 0, crate: pseudolearn_source,      may_depend_on: [] }
  - { id: 0, crate: pseudolearn_abi,         may_depend_on: [] }
  - { id: 1, crate: pseudolearn_diagnostics, may_depend_on: [pseudolearn_source] }
  - { id: 1, crate: pseudolearn_lexicon,     may_depend_on: [pseudolearn_source] }
  - { id: 2, crate: pseudolearn_syntax,      may_depend_on: [pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon] }
  - { id: 3, crate: pseudolearn_semantic,    may_depend_on: [pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax] }
  - { id: 3, crate: pseudolearn_ir,          may_depend_on: [pseudolearn_source, pseudolearn_abi] }
  - { id: 4, crate: pseudolearn_lowering,    may_depend_on: [pseudolearn_semantic, pseudolearn_ir, pseudolearn_diagnostics] }
  - { id: 4, crate: pseudolearn_runtime,     may_depend_on: [pseudolearn_abi, pseudolearn_diagnostics] }
  - { id: 5, crate: pseudolearn_library,     may_depend_on: [pseudolearn_runtime, pseudolearn_diagnostics] }
  - { id: 6, crate: pseudolearn_vm,          may_depend_on: [pseudolearn_ir, pseudolearn_runtime, pseudolearn_library, pseudolearn_diagnostics] }
  - { id: 6, crate: pseudolearn_codegen,     may_depend_on: [pseudolearn_ir, pseudolearn_abi] }
  - { id: 6, crate: pseudolearn_service,     may_depend_on: [pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic] }
  - { id: 7, crate: pseudolearn_api,         may_depend_on: [all_lower_layers] }
  - { id: 8, crate: pseudolearn_wasm,        may_depend_on: [pseudolearn_api] }
  - { id: 8, crate: pseudolearn_conformance, may_depend_on: [pseudolearn_api] }

external_dependencies:
  pseudolearn_source:  [unicode-normalization, unicode-ident]
  pseudolearn_syntax:  [rowan]
  pseudolearn_codegen: [cranelift-codegen, cranelift-frontend, cranelift-object, target-lexicon]
  pseudolearn_service: [salsa]
  pseudolearn_api:     [serde, serde_json]
  pseudolearn_wasm:    [wasm-bindgen]
  pseudolearn_conformance: [serde, serde_json]

tooling: [xtask]

unsafe_allowed: [pseudolearn_runtime, pseudolearn_wasm]

deterministic_output_crates: [pseudolearn_diagnostics, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_vm, pseudolearn_service, pseudolearn_api]

limits:
  file_lines: 300
  function_lines: 40
  parameters: 4
  nesting_depth: 3
  public_methods_per_type: 7
  unsafe_function_lines: 10

naming:
  min_identifier_length: 3
  allowed_short_identifiers: [id, io, ir, vm, gc, os]
  forbidden_abbreviations: [ctx, cfg, env, expr, stmt, decl, tok, idx, len, pos, cnt, num, buf, ptr, val, msg, err, res, ret, args, params, attrs, tmp, temp, aux]
  forbidden_names: [data, info, item, obj, thing, stuff, foo, bar, baz, utils, helpers, common, misc]

code_rules:
  forbid_comments: true
  forbid_doc_attributes: true
  forbid_lint_allow_attributes: true

generated_sources:
  - crates/pseudolearn_diagnostics/generated
  - crates/pseudolearn_lexicon/generated
  - crates/pseudolearn_syntax/generated

limits_exempt:
  - crates/*/tests/
  - crates/*/generated/
```

`may_depend_on: [all_lower_layers]` es azúcar que el verificador expande. Se acepta solo en la capa de
fachada, para que añadir un crate inferior no obligue a tocarla.

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
| `pseudo check`      | `TOOL.CLI.CHECK`       | R4   |
| `pseudo run`        | `TOOL.CLI.RUN`         | R5   |
| `pseudo ir`         | `TOOL.CLI.IR`          | R5   |
| `pseudo build`      | `TOOL.CLI.BUILD`       | R6   |
| `pseudo format`     | `TOOL.CLI.FORMAT`      | R7   |
| `pseudo translate`  | `TOOL.CLI.TRANSLATE`   | R7   |
| `pseudo lsp`        | `TOOL.LSP.CAPABILITIES` | R7  |

Las órdenes se nombran en inglés de forma provisional, con alias en español. El idioma canónico lo fija
D-21 dentro de `TOOL.CLI.CONVENTIONS`.

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
declarado en `architecture.yaml` como `tooling`. Ese crate depende por ruta de
`pseudolearn_rust_checks` y encadena todos los verificadores. El `README.md` del workspace lo documentará
en «Cómo se verifica»:

```bash
(cd packages/pseudolearn_engine && cargo xtask verify)
```
