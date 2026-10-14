# 08 · Decisiones, riesgos y cambios de reglas

> **Estado:** las decisiones asumidas y las propuestas asignadas a R0 están aprobadas por la persona
> responsable el 2026-10-14. Los cambios de reglas de R0 se aplican en esta fase. Las decisiones y
> modificaciones de otras fases conservan su dependencia y requieren autorización de esa fase.

---

## 1. Decisiones

### 1.1 Tomadas en conversación (2026-10-13)

| ID      | Decisión                                                                                                   | Sustituye o resuelve                    |
|---------|------------------------------------------------------------------------------------------------------------|-----------------------------------------|
| ADR-001 | Núcleo completo en Rust (A2), con el núcleo Dart en paralelo como `reference` hasta completar la paridad     | D-05; REC-05 (A3) queda descartada       |
| —       | El foco del proyecto es el lenguaje; la app es un consumidor                                                | Matiz de D-02 y D-03                     |
| —       | Las especificaciones ejecutables son la fuente de verdad; orden especificación → casos → tests → código     | D-09 en su forma R2                      |
| —       | Los tests del núcleo Dart dejan de ser normativos; el corpus los sustituye como oráculo                      | —                                        |
| —       | Código en inglés, documentación y especificaciones en español; nombres semánticos; cero comentarios        | `LANG-EN-CODE`, `LANG-ES-DOCS`, `QUALITY-NO-COMMENTS`; nueva `QUALITY-SEMANTIC-NAMES` |
| —       | Se podan las funciones a medias y el código muerto: lo que no tiene especificación no se porta              | C-04 (perfiles institucionales: se retiran) |

### 1.2 Asumidas de la investigación («el resto de la documentación es coherente»), aprobadas en R0

| ID   | Recomendación que el plan asume                                                       | Fase que la necesita |
|------|----------------------------------------------------------------------------------------|----------------------|
| D-02 | PseudoLearn es destino, con el orden de desempate de [04](../04-filosofia-y-modelo-del-lenguaje.md) §1.2 | R2 |
| D-03 | Propósito general en sentido (a): aplicaciones, herramientas, servicios, bibliotecas   | R3 (`RT.HOST.INTERFACE`) |
| D-04 | Memoria administrada por trazado; `Registro` como tipo valor en el futuro              | R3 (`MEM.*`)         |
| D-11 | Ediciones por paquete; la vigente es la primera numerada                               | R2 (`LANG.EDITION.MODEL`) |
| D-18 | Se especifica el contrato de observación                                              | R3 (`ENG.*`)         |
| D-20 | Identificadores de especificación en inglés ASCII; títulos en español                  | R1                   |
| D-22 | Los hallazgos se resuelven como casos. Con la reescritura se resuelven **en Rust**; en `reference` quedan como `exento` | R2 |
| D-23 | Verificación local de todos los miembros; comprobaciones remotas puntuales manuales y autorizadas                                | R0                   |

### 1.3 Nuevas, propuestas por este plan

| ID     | Pregunta                                                       | Propuesta                                                                                    | Ver                                           | Fase |
|--------|----------------------------------------------------------------|----------------------------------------------------------------------------------------------|-----------------------------------------------|------|
| D-P01  | ¿En qué lenguaje se escribe `see`? (revisa D-10)               | Rust, en `packages/pseudolearn_spec`, sin depender de ningún miembro                          | [05](05-sistema-de-especificaciones.md) §1    | R0   |
| D-P02  | ¿Primer backend nativo? (resuelve D-06)                        | Cranelift; la RI se diseña para admitir LLVM; E-NR1 en R6 decide si se añade                  | [00](00-adr-001-nucleo-en-rust.md) §2         | R0   |
| D-P03  | ¿Cómo habla `see` con los sujetos?                             | `see-protocol/1`: JSON por líneas sobre la entrada y salida estándar                          | [05](05-sistema-de-especificaciones.md) §3    | R1   |
| D-P04  | ¿Cómo se expresan las capas en Rust?                           | Un crate por capa; `architecture.yaml` declara las dependencias permitidas                    | [04](04-arquitectura-del-workspace-rust.md) §2 | R0  |
| D-P05  | ¿Cómo llegan los datos del corpus al código?                   | Exportación JSON versionada y verificada, más `build.rs`                                      | [04](04-arquitectura-del-workspace-rust.md) §5 | R1  |
| D-P06  | ¿Nombres de los sujetos?                                       | `reference`, `engine`, `aot`, `service`, `cli`, `app`, `see`                                  | [02](02-modelo-de-especificaciones.md) §4     | R1   |
| D-P07  | ¿Qué pasa con los emisores (Python, Rust) y los diagramas de la app? | Se decide en R8: o consumen una vista del árbol especificada en `API.*`, o se retiran     | [03](03-catalogo-de-especificaciones.md) §4   | R8   |
| D-P08  | ¿Nombre y ubicación de la CLI?                                 | Binario `pseudo` en `apps/pseudolearn_cli`                                                    | [04](04-arquitectura-del-workspace-rust.md) §7 | R0  |
| D-P09  | ¿Dónde viven los tests de Rust?                                | Caja negra en `tests/` espejo de `src/`; unidad interna en `<módulo>_tests.rs` hermano        | [01](01-principios-y-reglas.md) §7            | R0   |
| D-P10  | ¿Cómo se justifica `unsafe` sin comentarios?                   | Crates permitidos, funciones de ≤ 10 líneas con nombre de invariante, tabla en el `README.md` | [01](01-principios-y-reglas.md) §4            | R0   |
| D-P11  | ¿Lista inicial de dependencias externas?                       | La de [01](01-principios-y-reglas.md) §9, confirmada crate a crate en cada fase               | [01](01-principios-y-reglas.md) §9            | R1+  |
| D-P12  | ¿Se congelan los cambios del lenguaje durante la reescritura?  | Sí: ninguna construcción nueva hasta R9; solo correcciones especificadas                      | [03](03-catalogo-de-especificaciones.md) §5   | R0   |

### 1.4 Abiertas que bloquean una fase del plan

| ID   | Pregunta                                                     | Bloquea                       |
|------|--------------------------------------------------------------|-------------------------------|
| D-13 | Palabras reservadas: vocabulario contextual, `Y`/`O`         | R2 (`LANG.LEXICAL.KEYWORD`)   |
| D-14 | NFC y `ñ` en el perfil estricto                              | R2 (`LANG.SOURCE.ENCODING`, `LANG.LEXICAL.IDENTIFIER`) |
| D-17 | Límites de recursos: ¿regla del lenguaje o del entorno?       | R3 (`ENG.LIMITS`)             |
| D-21 | Idioma canónico de la CLI                                    | R3 (`TOOL.CLI.CONVENTIONS`)   |
| D-07 | Nivel de rendimiento aceptado como «muy optimizado»          | Umbrales de R5 y R6           |
| D-01 | Licencia                                                     | Política de `cargo-deny`; si algún crate se publica |

Quedan fuera del plan, para después de R9: D-08 (eliminación de código), D-12 (ámbitos de bloque),
D-15, D-16, D-19 y D-24.

---

## 2. Riesgos

Escala como en [17](../17-riesgos-preguntas-y-decisiones.md) §3: probabilidad e impacto en Baja, Media
o Alta.

| ID    | Riesgo                                                                                       | P | I | Mitigación                                                                                                          | Señal temprana                                              |
|-------|----------------------------------------------------------------------------------------------|---|---|---------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------|
| RN-01 | **Segundo sistema:** la reescritura acumula mejoras y nunca alcanza la paridad                 | M | A | Alcance = paridad (D-P12); la matriz como medida de avance; construcciones nuevas solo después de R9                | Especificaciones `LANG` nuevas que no vienen de `language-spec.md` |
| RN-02 | **Coste de autoría** de ≈159 especificaciones (R-05 de la investigación)                      | A | A | Piloto con medición (E-15); `see new` con plantillas; admitir `experimental` para avanzar; priorizar por el grafo    | Más de una hora por regla en el piloto                      |
| RN-03 | **Consagrar los defectos del núcleo Dart** al escribir casos mirando lo que hace               | M | A | Origen `escrito`; `capturado` con revisor; los hallazgos H-xx como `exento` en `reference`                           | Muchos `capturado` en una especificación                    |
| RN-04 | **Curva de Rust** con una sola persona                                                        | A | M | Empezar por `see`; los lints estrictos enseñan; la arquitectura por crates limita el alcance de cada error          | R1 se alarga más que R2                                     |
| RN-05 | **Observar a través de FFI** es demasiado caro para el paso a paso                            | M | A | Lotes de eventos, consulta por referencia, estado incremental; E-NR2 en R8; se mide en R5 sin puente                | `PERF.VM.STEP-LATENCY` al límite ya en R5                   |
| RN-06 | **Recolector con `unsafe`** con errores de memoria                                            | M | A | Sin movimiento; `unsafe` confinado; `cargo miri test` sobre `pseudolearn_runtime` en la CI; propiedades con recolección forzada | Fallos intermitentes en propiedades `MEM`             |
| RN-07 | **`pseudo build` exige un enlazador** en la máquina de quien compila                          | A | M | `RT.LINKING` lo declara; diagnóstico claro si falta; evaluar distribuir `lld` en R6                                | —                                                           |
| RN-08 | **La app y el núcleo divergen** durante la transición (la app sigue con Dart hasta R8)          | M | M | Congelación del lenguaje (D-P12); la app no cambia de motor hasta que `engine` cumpla todo `LANG`                   | Cambios en la base de conocimiento que dependen de construcciones nuevas |
| RN-09 | **Fricción entre las reglas del proyecto y las convenciones de Rust** (`T`, `'a`, `|x|`, `// SAFETY:`) | A | B | Aceptada a sabiendas; los lints corrigen pronto; la política de `unsafe` sustituye el comentario | Excepciones pedidas con frecuencia                          |
| RN-10 | **Tamaño** de la biblioteca en móvil y del Wasm                                               | M | M | Sin Cranelift ni servicio pesado en móvil; `PERF.ARTIFACT.SIZE`; `opt-level = "z"` evaluado para Wasm               | Crecimiento por encima del presupuesto en R5                |
| RN-11 | **Cranelift no alcanza** el nivel acordado                                                     | M | M | RI compatible con LLVM; E-NR1; LLVM como backend de «release» opcional                                              | Informe de R6                                               |
| RN-12 | **El núcleo Dart deja de compilar** con versiones nuevas de Dart antes de R9                  | B | M | Fijar la versión del SDK para el sujeto `reference`; es solo un oráculo                                             | Avisos de obsolescencia del SDK                             |

---

## 3. Cambios de reglas por fase

### 3.1 `AGENTS.md`

| Sección | Cambio propuesto                                                                                                      |
|---------|-----------------------------------------------------------------------------------------------------------------------|
| §2      | **Nuevas:** `SPEC-BEHAVIOR-TRUTH` (el comportamiento observable vive en el corpus), `SPEC-FIRST` (especificación → casos → tests → código), `SPEC-NO-ORPHAN-RULE`, `SPEC-BINDING-AS-DATA` (los vínculos regla–código viven en archivos de conformidad, nunca en el código), `SPEC-CHANGE-CLASSIFIED`, `SPEC-INDEPENDENT-ORACLE`, `QUALITY-SEMANTIC-NAMES`, `QUALITY-NO-PANIC` |
| §2      | **Modificadas:** `DOC-README-TRUTH` se acota a arquitectura, operación y porqué de la implementación (contrato R2). `QUALITY-NO-COMMENTS` añade las formas de Rust, la ausencia de excepción de docstring en Rust, la política de `unsafe` y `rust-checks comments` como verificador. `LANG-ES-DOCS` incluye el corpus de especificaciones |
| §3      | **Precedencia:** (1) la persona; (2) `AGENTS.md`; (3) el corpus de especificaciones para el comportamiento y el `README.md` del paquete para la arquitectura, que tienen ámbitos disjuntos (si chocan, la afirmación está mal clasificada y se reporta); (4) `language-spec.md` mientras quede algo sin migrar; (5) terceros |
| §4      | Cero comentarios también en Rust; `#[allow]` prohibido en código                                                        |
| §5      | Tests de Rust: ubicación (D-P09); los casos de conformidad no se duplican como tests                                     |
| §8      | Skills nuevas y modificadas (§3.3)                                                                                       |
| §9      | Quinta cadena de herramientas: `cargo` y `rustup` para `pseudolearn_spec`, `pseudolearn_engine`, `pseudolearn_rust_checks`, `pseudolearn_cli` y el puente de la app |

**Resolución aprobada en R0.** `AGENTS.md` declara cinco cadenas; la quinta corresponde a Rust.

### 3.2 `README.md` raíz

- §1 y §3.1–3.3: mapa con los miembros nuevos y las aristas nuevas (CLI → núcleo, app → puente →
  núcleo, `see` → sujetos por proceso, núcleo ← exportación del corpus).
- §1.3: la CI deja de estar fuera de alcance (D-23).
- §1.5: cerrar el pendiente de CI; añadir «retiro del núcleo Dart (R9)».
- §2.1, §2.2 y §2.5: requisitos y comandos de los miembros Rust.

### 3.3 Skills

| Skill                      | Cambio                                                                                                         | Fase |
|----------------------------|----------------------------------------------------------------------------------------------------------------|------|
| `spec-authoring` (nueva)   | Cómo escribir, clasificar y estabilizar una especificación; el flujo de [06](06-flujo-de-trabajo.md)            | R1   |
| `rust-code-quality` (nueva) o ampliación de `code-quality` | Nombres semánticos, cero comentarios en Rust, sin pánicos, `unsafe`, tests        | R0   |
| `language-spec-authoring`  | Se sustituye por `spec-authoring` para `LANG`; el criterio de desempate pasa a D-02 (C-01)                      | R2   |
| `layer-boundaries`         | Lee también `architecture.yaml` de workspaces Rust (crates como capas)                                          | R0   |
| `diagnostics-authoring`    | Reescrita: un diagnóstico nace en `DIAG.CATALOG` y llega al código por exportación                              | R4   |
| `ast-node-authoring`       | Reescrita para el árbol sin pérdida: los nodos se generan de `LANG.SYNTAX.GRAMMAR`                              | R4   |
| `phase-gate`               | Añade «matriz de conformidad sin regresiones» y `see validate` a la comprobación de cierre                       | R1   |
| `package-docs`             | Admite citar identificadores de especificación; el historial vive en el corpus (C-02)                          | R1   |
| `commit-message`           | Ámbitos de los miembros nuevos; nombrar la especificación en el cuerpo                                          | R0   |

### 3.4 Otros documentos

- `packages/pseudolearn_core/README.md`: estado «sujeto `reference`, congelado» (R0) y «retirado» (R9).
- `packages/pseudolearn_core/docs/language-spec.md`: tabla de correspondencia y migración (R2).
- `docs/README.md`: enlace a este plan (hecho en el mismo cambio que crea el plan).
- `docs/14` y `docs/17`: **no se reescriben**. Son investigación con fecha. La resolución de D-05,
  D-06 y D-10 queda en este plan y, al aprobarse, en `AGENTS.md` y en el `README.md` raíz.

La instrucción de la persona responsable del 2026-10-14 reserva GitHub Actions para despliegues
productivos y comprobaciones puntuales manuales. D-23 no exige verificaciones automáticas en push/PR.
E-01 tiene autorización explícita para usar runners remotos y completar su matriz de métricas.
