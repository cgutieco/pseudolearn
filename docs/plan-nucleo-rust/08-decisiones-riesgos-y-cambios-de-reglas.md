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
| —       | Se podan las funciones a medias y el código muerto: lo que no tiene especificación no se porta              | Catálogo de poda |

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
| D-07 | Nivel de rendimiento aceptado como «muy optimizado»; R3 fija umbrales provisionales (D-R3-03) | Umbrales definitivos de R5 y R6 |
| D-01 | Licencia                                                     | Política de `cargo-deny`; si algún crate se publica |

D-17 y D-21 quedan resueltas por D-R3-01 y D-R3-02 (§1.5).

### 1.5 Decisiones de R3

Fuente: mensaje de autorización de R3 de la persona responsable del 2026-10-14, que ordena ejecutar
R3 según el plan [09](09-plan-r3-motor-clepsidra.md) sin modificar ninguna recomendación; y, para
D-R3-02, la conversación del 2026-10-14 que aprobó la frontera de idioma, incluida la regla de que el
alias de una orden no decide el idioma de interfaz.

| ID       | Decisión aprobada                                                                                     | Resuelve |
|----------|-------------------------------------------------------------------------------------------------------|----------|
| D-R3-01  | Los límites son recursos del entorno con unidades deterministas (marcos, entradas a sentencia, celdas) y mínimos garantizados de 1 000 marcos y 2²² celdas. Profundidad y celdas producen fallo del programa; sentencias y tiempo, `limit_reached`. Valores por omisión: app 1 000 marcos; CLI 100 000 marcos sin presupuesto de sentencias | D-17 |
| D-R3-02  | Español canónico en órdenes y opciones, inglés como alias total; vocabulario autodeclarado por la palabra de apertura; idioma de interfaz por bandera > entorno > preferencias > sistema > español, nunca por el archivo ni por la forma de la orden | D-21 |
| D-R3-03  | Umbrales provisionales: VM sin observar ≥ 10× la línea base (media geométrica AWFY-core), objetivo 30×, ninguna prueba < 5×; paso observado p95 ≤ 1 ms en el dispositivo modesto y ≤ 0,1 ms en M2; sobrecoste del gemelo rápido con observador en pausa ≤ 2 %; front-end ≥ 10⁶ líneas/s en M2; biblioteca móvil ≤ 3 MiB por ABI; Wasm ≤ 600 KiB con brotli | D-07 (provisional) |
| D-R3-04  | E-02 usa Rust idiomático como sustituto de C, sin Go en la verificación local                          | Desviación de E-02 |
| D-R3-05  | `API.EXECUTE` incluye la consulta en un instante pasado como capacidad negociada `seek`                 | — |
| D-R3-06  | Se aprueban los cambios sobre la arquitectura de [04](04-arquitectura-del-workspace-rust.md): árbol postorden, código gemelo, línea temporal, runtime sin `unsafe` y `salsa` aplazado a R7 | Decisiones propuestas de 04 §3 |
| D-R3-07  | Se elevan a objetivo la transferencia AOT → VM (R6), la frontera grabable en `RT.HOST.INTERFACE` desde R3 y LLVM como nivel de *release* tras E-NR1 | — |

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
| RC-01 | La tabla de páginas y la barrera de época cuestan demasiado en cargas de objetos                | M | A | E-02 V2/V1 decide antes de R5; alternativa: montón directo con `unsafe` acotado y tarjetas sucias                     | V2/V1 > 1,30 en una familia                                 |
| RC-02 | Los gemelos rápido y sondeado divergen                                                         | B | A | Se generan desde la misma RI con una sola función parametrizada; conformidad diferencial interna obligatoria         | Un caso que difiere entre gemelos                           |
| RC-03 | Memoria de puntos de control en ejecuciones largas                                            | M | M | Raleo exponencial y presupuesto configurable; `API.STATE.QUERY` declara el horizonte retenido                        | E-06 en R5                                                  |
| RC-04 | El árbol postorden dificulta la identidad de nodo de R7                                       | M | M | El servicio de R7 deriva la identidad o construye su estructura incremental encima                                   | E-08 en R4                                                  |
| RC-05 | LLVM asigna mal registros en un `match` de despacho grande                                     | M | M | Manejadores pequeños, estado en variables locales, superinstrucciones; alternativa: despacho por familias           | `PERF.VM.THROUGHPUT` al empezar R5                          |
| RC-06 | Los bancos de tamaño fijo ocupan memoria en Wasm y móvil                                       | M | B | 2¹⁸ ranuras en Wasm y móvil, 2²⁰ en escritorio; el mínimo de 1 000 marcos se cumple en ambos                         | `PERF.ARTIFACT.SIZE`, RSS en E-06                           |
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

## Evidencia E-02 de R3

La captura final local contiene 12.000 muestras. La representación requiere revisión antes de autorizar R5 (RC-01); no se rediseña durante R3.

| Familia | V1/V0 [IC 95 %] | V2/V1 [IC 95 %] | V3/V2 [IC 95 %] | Revisar antes de R5 |
|---|---|---|---|---|
| arrays | 2.3099 [2.1023, 2.7506] | 4.0548 [3.2911, 5.5906] | 0.9946 [0.7455, 1.1965] | Sí |
| numeric | 1.7158 [1.6864, 1.7382] | 2.0575 [1.9962, 2.1611] | 1.0045 [0.9735, 1.0266] | Sí |
| objects | 1.1139 [1.0882, 1.1609] | 3.6046 [3.4272, 3.7087] | 1.1092 [1.0992, 1.1232] | Sí |
| recursive | 2.7728 [2.7524, 2.8071] | 2.5893 [2.5514, 2.6174] | 1.1206 [1.1021, 1.1463] | Sí |


La evidencia completa, incluidas las muestras iniciales con instrumentación insuficiente, se conserva en
`packages/pseudolearn_benchmarks/results/e02/`. El informe declara qué mide el experimento y sus límites.
