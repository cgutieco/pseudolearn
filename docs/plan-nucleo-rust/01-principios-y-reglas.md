# 01 · Principios y reglas de trabajo

> **Estado:** principios y reglas de R0 aprobados. Las reglas transversales aplicadas viven en
> `AGENTS.md`; los verificadores Rust documentan su operación en su README. El flujo de corpus y
> sus herramientas se implementan en R1; los contratos del motor conservan sus fases R2–R9.

---

## 1. Orden de trabajo: especificación → casos → tests → código

Ninguna pieza del núcleo nuevo se escribe en otro orden. Cada escalón tiene una salida verificable:

| Escalón | Qué se produce                                                                        | Salida verificable                                                                  | Quién lo verifica      |
|---------|---------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|------------------------|
| 1       | **Especificación** en `borrador`: reglas, errores, definiciones, no objetivos         | `see validate` pasa las capas 1–3 (esquema, referencias, reglas del sistema)         | `see`                  |
| 2       | **Casos y propiedades** de cada regla; la especificación pasa a `propuesta`            | Toda regla cubierta (ninguna huérfana). El sujeto `reference` ejecuta los casos y las diferencias quedan registradas | `see conform --subject reference` |
| 3       | **Revisión y paso a `experimental`**                                                   | Decisión explícita registrada; preguntas abiertas resueltas                          | Persona responsable    |
| 4       | **Tests de unidad** del crate que implementará la regla, escritos antes del código; fallan | Tests en rojo por la razón esperada (no por no compilar)                             | `cargo test`           |
| 5       | **Código** mínimo que pone en verde los tests y los casos                              | Tests verdes; casos verdes en `engine`; verificadores del crate verdes               | CI                     |
| 6       | **Estabilización**: casos verdes en dos sujetos, o divergencia de `reference` justificada como `exento` | Paso a `estable`                                                  | `see` + revisión       |

Notas sobre el orden:

- **Los casos de conformidad no se reescriben como tests de Rust.** El corpus los ejecuta a través del
  adaptador ([05](05-sistema-de-especificaciones.md)). Los tests de Rust del escalón 4 prueban **piezas
  internas** de un crate (un lexer de números, una tabla de símbolos), cuyo contrato está en el
  `README.md` del crate y no en el corpus.
- **Escribir los casos antes que los tests evita el error compartido**: lo esperado lo fija una persona
  leyendo la regla, no quien implementa leyendo su propio código
  ([10](../10-especificaciones-ejecutables-fundamentos.md#errores-compartidos)).
- Una especificación puede adelantarse varias fases a su implementación. Una implementación nunca puede
  adelantarse a su especificación.

---

## 2. Idiomas

| Artefacto                                                                 | Idioma                          | Regla vigente o propuesta |
|---------------------------------------------------------------------------|---------------------------------|---------------------------|
| Prosa de especificaciones, títulos, motivación, no objetivos              | Español                         | `LANG-ES-DOCS`            |
| Identificadores de especificación (`LANG.CONTROL.FOR`) y de elemento (`R3`) | Inglés, ASCII en mayúsculas   | D-20, asumida             |
| Claves de metadatos y de bloques del formato (`titulo`, `fuerza`, `caso`)  | Español, como en [11](../11-especificaciones-ejecutables-diseno.md) | Formato `see/1` |
| Programas de los casos                                                    | El perfil que declare el caso (`es` o `en`) | —            |
| Código Rust: identificadores, nombres de test, mensajes de error internos | Inglés                          | `LANG-EN-CODE`            |
| Protocolo de conformidad (JSON), salidas de máquina de `see`               | Inglés                          | `LANG-EN-CODE`            |
| `README.md` de cada crate y del workspace                                 | Español                         | `LANG-ES-DOCS`            |
| Mensajes de commit                                                        | Inglés                          | `LANG-EN-CODE`            |
| Texto para personas (diagnósticos renderizados, CLI)                       | Bilingüe, generado desde el corpus | `GEN-NO-HAND-COPY`     |

---

## 3. Nombres semánticos (`QUALITY-SEMANTIC-NAMES`)

El código no tiene comentarios, así que **los nombres son la documentación**. Un nombre dice el
**papel** que cumple un valor en ese punto del programa, no su tipo ni su forma.

### 3.1 Reglas

1. **Prohibidos los identificadores de menos de tres caracteres**, incluidos los parámetros de
   closures, las variables de bucle, los parámetros genéricos y los tiempos de vida. Se admite una
   lista cerrada de términos del dominio que son palabras completas en su campo: `id`, `io`, `ir`, `vm`,
   `gc`, `os`.
2. **Prohibidas las abreviaturas.** Se escribe la palabra entera:

   | Prohibido                         | Se escribe                              |
   |-----------------------------------|-----------------------------------------|
   | `ctx`, `cfg`, `env`               | `context`, `configuration`, `environment` |
   | `expr`, `stmt`, `decl`, `tok`     | `expression`, `statement`, `declaration`, `token` |
   | `idx`, `len`, `pos`, `cnt`, `num` | `index`, `length`, `position`, `count`, `number` |
   | `buf`, `ptr`, `ref_`, `val`       | `buffer`, `pointer`, `reference`, `value` |
   | `msg`, `err`, `res`, `ret`        | `message`, `error`, `result`/nombre del resultado, nombre de lo devuelto |
   | `args`, `params`, `attrs`         | `arguments`, `parameters`, `attributes` |
   | `tmp`, `temp`, `aux`, `data`, `info`, `item`, `obj`, `thing`, `stuff`, `foo`, `bar` | El papel concreto: `pending_statement`, `parsed_literal`, `enclosing_scope` |

3. **Nombres por papel, no por tipo.** No `vec`, `map`, `string`, `iterator` a secas, sino
   `remaining_tokens`, `symbols_by_name`, `rendered_output`, `statement_cursor`.
4. **Los parámetros genéricos se nombran por su papel:** `Node`, `Payload`, `Subject`, no `T`, `U`. Los
   tiempos de vida, por lo que garantizan: `'source`, `'arena`, no `'a`.
5. **Los booleanos se leen como afirmaciones:** `is_terminated`, `has_errors`, `can_assign`,
   `should_recover`.
6. **Las funciones son frases verbales:** `parse_counted_loop`, `resolve_designator`,
   `emit_overflow_diagnostic`. Las conversiones siguen la convención de Rust: `to_`, `into_`, `from_`,
   `as_`.
7. **El nombre de un archivo es el nombre de lo que contiene.** Un archivo `counted_loop.rs` contiene el
   análisis del bucle contado y nada más. No hay `utils.rs`, `helpers.rs`, `common.rs` ni `misc.rs`.

### 3.2 Cómo se verifica

| Mecanismo                                                  | Qué detecta                                         |
|------------------------------------------------------------|-----------------------------------------------------|
| `clippy::min_ident_chars` con umbral 3 y la lista cerrada de §3.1.1 | Identificadores cortos                    |
| `clippy::disallowed_names` con la lista de §3.1.2          | Nombres de relleno                                  |
| `clippy::many_single_char_names`                           | Refuerzo del anterior                               |
| `rust-checks names` del workspace (propio)                  | Abreviaturas (por componente de `snake_case`), parámetros genéricos y tiempos de vida de una letra, archivos prohibidos |
| Caso negativo de cada verificador                          | Un archivo con violaciones deliberadas que el verificador debe rechazar (`AGENTS.md` §5) |

Las opciones de Clippy de los verificadores se fijan en `clippy.toml` en R0; los futuros workspaces las fijan en su fase. Si una no existe
en la versión fijada de la cadena, se cubre con `rust-checks names` y se registra en el `README.md` del
workspace.

---

## 4. Cero comentarios en Rust (`QUALITY-NO-COMMENTS` aplicada a Rust)

- Se prohíben todas las formas: `//`, `/* */`, `///`, `//!`, `/** */`, `/*! */` y el atributo
  `#[doc = …]`. En Rust **no hay excepción de docstring**: la de Python no se extiende.
- La documentación de la API pública **no se escribe en rustdoc**. Se genera desde las especificaciones
  `API.*` ([03](03-catalogo-de-especificaciones.md) §2.9).
- **`unsafe` sin comentario `// SAFETY:`.** La convención de Rust de justificar cada bloque `unsafe` con
  un comentario choca con esta regla. Se resuelve así:
  1. `unsafe` solo se permite en los crates que `architecture.yaml` declara (`pseudolearn_runtime`,
     `pseudolearn_bridge`, `pseudolearn_wasm`). Los demás llevan `#![forbid(unsafe_code)]`.
  2. Cada bloque `unsafe` vive en una función de no más de diez líneas cuyo nombre expresa el invariante
     que la hace segura (`read_slot_within_verified_frame`).
  3. El `README.md` del crate tiene una sección «Invariantes de `unsafe`» con una fila por función: qué
     invariante se asume y qué lo garantiza.

  Un verificador comprueba que cada función con `unsafe` tenga su fila, en ambos sentidos.
- El verificador de comentarios usa el analizador léxico de Rust (`ra_ap_rustc_lexer`), no expresiones
  regulares, para no confundir `//` dentro de una cadena con un comentario.
- **`#[allow(...)]` y `#[expect(...)]` también están prohibidos en el código.** Las excepciones a los
  lints viven en la configuración del workspace, con su porqué en el `README.md`.

---

## 5. Funciones pequeñas y límites de tamaño

Valores iniciales propuestos para `architecture.yaml` de cada crate. Son los del núcleo Dart vigente, que
han funcionado:

| Límite                            | Valor | Verificación                                              |
|-----------------------------------|-------|-----------------------------------------------------------|
| Líneas por archivo                | 300   | `tool/check_limits` del workspace                          |
| Líneas por función                | 40    | `clippy::too_many_lines` (umbral 40) y `check_limits`      |
| Parámetros por función            | 4     | `clippy::too_many_arguments` (umbral 4); más de cuatro → estructura de parámetros con nombre |
| Profundidad de anidación          | 3     | `check_limits` (y `clippy::excessive_nesting` si su métrica coincide) |
| Métodos públicos por tipo         | 7     | `check_limits`                                             |
| Variantes por `enum` sin datos    | Sin límite | Un `enum` largo de códigos de diagnóstico es un catálogo, no una responsabilidad múltiple |

Rust no tiene parámetros con nombre: cuando una función necesitaría más de cuatro, recibe una
estructura cuyo nombre describe la petición (`CountedLoopBounds`, `RunRequest`).

---

## 6. Frontera sin pánicos (`QUALITY-NO-PANIC`)

«Ninguna excepción sin control cruza la frontera pública de un paquete» (`AGENTS.md` §5) se traduce en
Rust a **ningún pánico alcanzable**:

| Lint de Clippy (nivel `deny` en todo el workspace)          | Por qué                                                       |
|-------------------------------------------------------------|---------------------------------------------------------------|
| `unwrap_used`, `expect_used`                                | Un fallo esperable es un `Result`, no un pánico                |
| `panic`, `todo`, `unimplemented`, `unreachable`             | Lo inalcanzable se expresa con tipos, no con una aserción     |
| `indexing_slicing`                                          | Un índice fuera de rango en el motor es un pánico; se usa `get` |
| `arithmetic_side_effects`                                   | La aritmética del lenguaje es **comprobada** (`checked_add`…); un desbordamiento silencioso en el motor sería el error que `LANG.TYPES.INTEGER` prohíbe |
| `as_conversions`                                            | Las conversiones numéricas con pérdida se hacen con `try_from` |

Además, la capa de API pública envuelve cada punto de entrada con `std::panic::catch_unwind`
**solo como red de seguridad**. Un pánico atrapado es un defecto del motor: produce el diagnóstico
`DIAG.ENGINE.INTERNAL-FAULT` y un caso de conformidad lo cubre. Nunca es un camino de control.

---

## 7. Tests en Rust

- **`TEST-BOTH-PATHS`**: cada función pública de un crate tiene al menos un test de camino feliz, uno de
  camino infeliz y los casos límite de `AGENTS.md` §5: vacío, tamaño cero, profundidad extrema, bordes
  numéricos, identificador de un carácter (en el programa PseudoLearn, no en Rust) y programa vacío.
- **`TEST-MIRROR`** en Rust:
  - **Tests de caja negra** del crate: en `tests/`, con un árbol espejo de `src/`
    (`src/syntax/counted_loop.rs` ↔ `tests/syntax/counted_loop.rs`).
  - **Tests de unidad internos**: en un archivo hermano `<módulo>_tests.rs`, declarado con
    `#[cfg(test)]`. Nunca en línea dentro del archivo de código, para que los límites de tamaño midan
    solo código.
- **Nombres de test**: frases en inglés que dicen el comportamiento: `rejects_zero_step_before_first_iteration`,
  `keeps_control_variable_after_loop_exit`.
- **Propiedades** con `proptest`. Las propiedades `Q*` del corpus las ejecuta `see` contra el sujeto;
  las de Rust son para invariantes internos (por ejemplo: el árbol sin pérdida reimprime exactamente el
  texto de entrada).
- **Instantáneas** (`insta`) **prohibidas para valores esperados del lenguaje**: un valor capturado sin
  revisión es justo el error que la política de oráculos impide. Se admiten solo para salidas de
  herramientas internas sin valor normativo, y con revisión.

---

## 8. Determinismo

Lo que observa un programa o una herramienta no puede depender de la plataforma ni del orden de un
`HashMap`:

- **Iteración observable**: con `BTreeMap` o `IndexMap`, nunca con `HashMap`/`HashSet` (se verifica con
  `clippy::disallowed_types` en los crates que producen salidas observables).
- **Sin reloj ni entropía del sistema en el motor**: el tiempo y la aleatoriedad se inyectan
  (`LIB.CORE.RANDOM`, `RT.HOST.INTERFACE`).
- **Formato de reales**: un único algoritmo especificado (`LANG.IO.VALUE-FORMAT`), igual en nativo y Wasm.

---

## 9. Dependencias de terceros

- Cada crate declara en `architecture.yaml` una **lista cerrada de dependencias externas permitidas**.
  Añadir una es un cambio de arquitectura: se registra en el `README.md` del crate qué se toma de ella,
  qué se rechazó y por qué (`AGENTS.md` §3).
- `cargo-deny` verifica licencias compatibles con la licencia propietaria del proyecto, avisos de
  seguridad y versiones duplicadas.
- Candidatas iniciales, a confirmar en cada fase:

  | Crate             | Uso                                         | Alternativa propia si se rechaza          |
  |-------------------|---------------------------------------------|-------------------------------------------|
  | `rowan`           | Árbol de sintaxis sin pérdida               | Árbol verde/rojo propio                   |
  | `salsa`           | Análisis incremental del servicio de lenguaje | Caché por archivo sin dependencias finas |
  | `unicode-normalization`, `unicode-ident` | NFC e identificadores Unicode | Ninguna razonable              |
  | `cranelift-codegen`, `cranelift-object`, `cranelift-frontend` | Backend nativo | LLVM (`inkwell`) |
  | `serde`, `serde_json`, `serde_yaml` (o `serde_yml`) | Protocolo y formato del corpus | — |
  | `pulldown-cmark`  | Lectura del Markdown del corpus             | —                                         |
  | `jsonschema`      | Validación de esquema del corpus            | Validación escrita a mano                 |
  | `proptest`        | Propiedades                                 | —                                         |
  | `flutter_rust_bridge` | Puente con Flutter                      | `dart:ffi` con C ABI escrito a mano       |
  | `wasm-bindgen`    | Puente con la web                           | —                                         |
  | `tower-lsp`       | Servidor de lenguaje                        | `lsp-server` (el de rust-analyzer)        |
