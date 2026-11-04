# Eliminación del eje de rigor · un solo lenguaje — plan de ejecución

## 0. Metadatos y contrato de ejecución

- Fecha: 2026-11-03, America/Lima. HEAD al iniciar PF-0: `6fb7bd7fd7b6b55e3e212d13b5095453bcfa2db7`. Rama:
  `feature/agregar-ruta-de-especificacion`. El árbol de trabajo y el índice estaban limpios.
- Petición: eliminar el modo flexible y toda etiqueta del modo estricto, de modo que el lenguaje sea uno solo y lo que hoy
  exige el modo estricto pase a ser el lenguaje oficial; quitar también el selector de rigor de la app; asegurar que los
  errores sean claros, incluido un marcador de línea. El lenguaje no ha salido a producción, así que los cambios de ruptura
  se hacen ahora y no queda rastro de funciones obsoletas ni de código muerto.
- Estado: PF-0 ejecutado y detenido por `PHASE-STOP`; la persona autorizó PF-1 el 2026-11-03. Antes de editar se comprobó
  que PF-1 no puede cerrar en verde de forma independiente: PF-1.3–1.4 rompen validación y conformidad antes de PF-2,
  PF-1.5–1.7 cambian contratos cuyos consumidores solo se actualizan en PF-3, PF-4 y PF-6. La persona instruyó conservar
  PF-2 como fase separada y reubicar los cambios incompatibles en fases atómicas. PF-1 queda reprogramada y no ejecutada;
  sus entregables se reasignan en §4. La línea base está registrada en §7. Los conteos históricos de `grep` de §3 son
  orientativos e incluyen falsos positivos (por ejemplo «BEM estricto» en el frontend o `strict-casts` en el análisis de Dart).
- Documento transitorio: ninguna especificación, README ni código fuera de `docs/` puede citarlo (`DOC-NO-TRANSIENT-REFS`).
  Cada decisión se traslada a su dueño en el mismo cambio (`DOC-README-TRUTH`, `DOC-NO-ORPHAN-DECISION`).

### 0.1 Reglas para quien ejecute

1. Antes de modificar un paquete, releer `AGENTS.md`, su README y su archivo de reglas, y comprobar rama, HEAD y diff.
2. Secuencia por punto: especificación → casos con esperado derivado → tests que detectan la ausencia → código → README →
   verificación. El borrado de lo que el punto deja muerto ocurre **en el mismo cambio**.
3. Editar el corpus con ediciones textuales dirigidas, línea a línea y revisando el diff. Prohibido formatear en masa ni
   reescribir archivos JSON por ida y vuelta (serializar y volver a escribir).
4. `SPEC-VERSION-FREEZE`: se edita el texto oficial en la misma identidad, estado y versión, sin `cambio`; las reglas no se
   borran, se reescriben; se reancla con `lock --refresh` indicando en una sola orden todos los IDs modificados.
5. `SPEC-NO-ORPHAN-RULE`: si al borrar un caso una regla queda sin cobertura, se escribe un caso nuevo con esperado derivado
   de la regla (`SPEC-INDEPENDENT-ORACLE`); no se copia la salida del motor.
6. Una contradicción entre fuentes se reporta y se espera respuesta (`CONFLICT-REPORT`).
7. Al cerrar cada fase se informa y se para; la siguiente exige confirmación nueva (`PHASE-STOP`), con verificaciones
   locales en verde (`PHASE-GREEN`).

## 1. Decisiones

| ID | Decisión | Por qué |
|---|---|---|
| D-01 | El lenguaje es uno solo. No existen las palabras «estricto», «flexible», «rigor» ni «política de rigor» en el lenguaje, el corpus, las herramientas ni la app. El capítulo del sistema de tipos pasa a llamarse «Sistema de tipos y severidad de diagnósticos». | Una sola configuración no necesita nombre ni etiqueta. |
| D-02 | Sin compatibilidad hacia atrás: no hay migración, no hay lectura tolerante de `flexible`, no hay alias de opciones antiguas. | El lenguaje no está en producción. Código de compatibilidad sería código muerto desde el primer día. |
| D-03 | Lo que hoy es exclusivo del estricto pasa a ser regla del lenguaje: terminador `;` obligatorio, cláusula de paso obligatoria en `Para`, tipo obligatorio en los parámetros y etiquetas de `Según` solo de tipo entero o enumerado. | Son las bondades que se conservan como oficiales. |
| D-04 | El catálogo de diagnósticos tiene una severidad por código. Desaparece el objeto `severidad` con dos columnas y la clase B «gobernada por exigencia». `IncompatibleSwitchCaseType` pasa a error fijo. | Con una sola política, la columna no aporta información. |
| D-05 | Las clases de diagnóstico quedan: A estructural y ejecución fatal (error), C higiene (advertencia), D inferencia (información), E lectura inválida (advertencia, recuperable). La letra B no se reutiliza ni se renumera; si el corpus exige letras contiguas, se decide en PF-3 y se informa. | Evita reescribir identidades por estética; el corpus manda. |
| D-06 | El parámetro `strictness` y el parámetro `terminator` opcional del parser desaparecen de las firmas, de los modelos de la API, del puente y de los adaptadores. No queda ningún booleano `strict`. | Un parámetro con un solo valor posible es código muerto. |
| D-07 | La app elimina `Document.strictness`, su persistencia en el front matter del archivo, su paso por la sincronización, el selector «Flexible» de `ExecutionConfigurationControls` y las cadenas `executionFlexible` y afines. `rustStrictness` desaparece. | Petición expresa; no hay valor que guardar. |
| D-08 | La CLI elimina `--rigor` y `--strictness`; VS Code elimina `pseudolearn.strictness` de `package.json` y del resolutor de configuración. | Opciones sin efecto son superficie engañosa. |
| D-09 | Todo programa de ejemplo, de onboarding, de la base de conocimiento, de benchmarks y de fixtures debe pasar `comprobar` en el lenguaje único. Los que no pasan se corrigen, no se exceptúan. | La app analiza hoy por defecto en flexible; los ejemplos pueden depender de esa tolerancia. |
| D-10 | Los planes históricos de `docs/` y las entradas históricas del sujeto `reference` retirado se conservan como registro. No se reescriben. | Son evidencia de fases cerradas. |
| D-11 | No se añade un verificador permanente de «ausencia de la palabra rigor». Se hace una comprobación manual de cierre con `grep` y su resultado se registra. | Un verificador de algo que ya no existe es ruido (`SCOPE-YAGNI`). |

## 2. Qué es el marcador de línea

Hoy `pseudo comprobar` imprime una sola línea por diagnóstico:

```
t.pseudo:3:9: error: Se esperaba un punto y coma al final de la sentencia [missingStatementTerminator]
```

El mensaje es correcto y la posición exacta, pero quien lo lee tiene que abrir el archivo y contar hasta la línea 3,
columna 9. El **marcador de línea** (fragmento con indicador) añade, debajo del diagnóstico, la línea de código afectada y
una marca bajo la columna del error:

```
t.pseudo:3:9: error: Se esperaba un punto y coma al final de la sentencia [missingStatementTerminator]
    3 |   x <- 1
      |         ^
```

La marca `^` señala el sitio exacto, de modo que un punto y coma olvidado se ve sin abrir el editor. Es el formato que
usan los compiladores modernos.

### 2.1 Alcance propuesto

- Solo en la salida de texto de la CLI. La salida `--json` no cambia: ya lleva línea, columna y tramo.
- La app no lo necesita: el editor ya marca la posición con el subrayado y la lista «N problemas».
- La línea de diagnóstico de `tool.cli.messages` queda intacta. Se agregan exactamente dos líneas:
  `    {n} | {texto de fuente}` y `{5 + dígitos(n) espacios}| {columna visible - 1 espacios}^`. `n` es el número de
  línea decimal, sin relleno; el `^` único apunta al inicio del tramo. Si el tramo cruza líneas, solo se muestra la
  primera línea y el mismo `^`.
- Las líneas se presentan en una ventana de hasta 80 columnas visibles, centrada alrededor de la marca cuando sea
  posible; cada extremo recortado lleva `…`. Los tabuladores se expanden a cuatro columnas antes de alinear el `^`.
- La columna cuenta como el resto de la herramienta cuenta columnas; el ancho visual de caracteres no latinos se
  decide en PF-4 leyendo `tool.cli.messages` antes de tocar nada.
- Hoy la regla de `pseudo comprobar` dice «una línea por diagnóstico». Esa frase se reescribe, y con ella los casos de
  `tool.cli.check`, `tool.cli.format`, `tool.cli.ir`, `tool.cli.messages` y el reporte de proyecto, que comparten
  `format_diagnostic_line`.

## 3. Inventario de la superficie

| Área | Archivos | Naturaleza |
|---|---|---|
| `packages/pseudolearn_spec` | ~247 | 1537 líneas `"rigor"` en 203 archivos de casos (88 solo estricto, 21 ambos, 1 solo flexible); ~890 entradas `"strictness"` en casos de API y app; esquema `see-1.schema.json`; catálogo `catalogs.json`; `specifications.lock` (8707 líneas) |
| `packages/pseudolearn_engine` | ~129 | ~40 de producción y ~90 de tests: 53 en `pseudolearn_api/tests` y 8 en `runtime/tests`; crates `syntax`, `semantic`, `diagnostics` (generador de código del catálogo), `service`, `api`, `aot_rt`, `conformance`, `bench_worker` |
| `apps/pseudolearn_app` | ~55 | Modelo de documento, repositorio de archivos, sincronización, adaptadores del puente, selector, `.arb`, capítulos de conocimiento en `assets/knowledge`, herramientas `tool/see_app_*` |
| `apps/pseudolearn_cli` | ~20 | Opciones, comandos, DAP, traducción, formateo |
| `apps/pseudolearn_vscode` | ~25 | Configuración, resolutor, depuración, comandos, tests |
| Frontend, backend, benchmarks | 2 | Título del capítulo en `i18n` del frontend; `bridge_scenarios.dart` pasa `flexible` |
| `docs/` | 16 | Históricos; no se tocan (D-10) |

Lógica real a modificar: unas seis ramas `if strict` en `pseudolearn_semantic` (`for_checker`, `local_registry`,
`switch_checker`, `session`, `usage`, `effect_pure_values`) y el terminador opcional del parser. El resto es transporte
del parámetro y datos del corpus.

## 4. Fases

### PF-0 · Inventario y línea base (tamaño S)

- [x] PF-0.1 Registrar HEAD, diff y resultados de las suites de cada miembro afectado como línea base.
- [x] PF-0.2 Buscar comportamiento exclusivo de flexible oculto en datos y no en ramas de código. Las entradas históricas
      `REF-FLEXIBLE-INITIALIZATION` y `REF-STRICT-INFERENCE` sugieren que la advertencia de lectura sin inicializar y la
      información `inferredVariableType` dependían del modo. Confirmar en el motor actual cuál es el comportamiento real
      y reportarlo si contradice el corpus.
- [x] PF-0.3 Ejecutar `comprobar` en el lenguaje actual sobre todos los programas de ejemplo, onboarding, conocimiento,
      benchmarks y fixtures, y registrar cuántos fallan. Es la medida real del riesgo de D-09.
- [x] PF-0.4 Leer `tool.cli.messages` y `tool.cli.check` y fijar el formato exacto del marcador (§2.1).

### PF-1 · Especificación (tamaño L) — reprogramada

PF-1 no se ejecuta como fase independiente: actualizar solo las reglas y casos produciría divergencias observables en
los sujetos activos, y quitar campos antes de sus validadores deja `cargo xtask verify` en rojo. Cada contrato se cambia
junto con su consumidor; el reanclaje ocurre en esa misma fase. La persona autorizó esta reordenación para mantener
`PHASE-GREEN` y conservar PF-2 separada.

- PF-1.1 → PF-6.3: el capítulo español e inglés y su manifiesto pertenecen a los activos pedagógicos de la app; se
  actualizan junto con el resto del material cuando el comportamiento de la app adopte el lenguaje único.
- PF-1.2 y la severidad de PF-1.3 → PF-3.2: política, catálogo, esquema de severidad y generador de diagnósticos se
  actualizan en una sola fase. La decisión sobre conservar el hueco de la clase B se toma allí, tras comprobar si existe
  una regla de contigüidad en el corpus y sus verificadores.
- La disponibilidad `strictness` de `helpCatalog/1` de PF-1.3 → PF-3.5 y PF-6.3: esquema, recurso y consumidores del
  motor y de la app cambian juntos; el formato del recurso se conserva hasta entonces.
- El eje `rigor` de los casos y la evidencia de conformidad en PF-1.3–1.4 → PF-3.1–3.6: se quitan junto con el
  comportamiento flexible del motor y su verificador. Los campos `strictness` que forman parte de solicitudes API/app
  se retiran junto con esos consumidores en PF-3.5 y PF-6.1.
- PF-1.4, cambios de esperados por comportamiento → PF-3, PF-4 o PF-6, con el consumidor correspondiente. Los casos
  no se reescriben antes de que el sujeto activo pueda satisfacer su nueva regla.
- PF-1.5 → PF-6.1: contrato y escenarios de configuración se actualizan junto con la app.
- PF-1.6 → PF-3.5: textos, casos API y firmas cambian junto con las fronteras públicas del motor.
- PF-1.7 → PF-4.2: regla, casos CLI e implementación del marcador se actualizan en una sola fase.
- PF-1.8 → cada fase que edite especificaciones: su comando `lock --refresh` enumera allí todos los IDs reanclados.

### PF-2 · Verificadores del corpus (tamaño M)

- [x] PF-2.1 Preparar una transición compatible: el esquema y `see_validation` aceptan `rigor` opcional; `see_conformance`
      conserva los valores declarados en casos existentes y usa estricto si falta el campo. Las referencias de
      `helpCatalog/1` se comprueban por perfil cuando el caso no declara rigor. La evidencia conserva ambos modos hasta
      que PF-3 retire el comportamiento flexible del motor.
- [x] PF-2.2 Probar ambas formas de caso y conservar los negativos de los verificadores con sus violaciones deliberadas.
- [x] PF-2.3 Completar en verde todos los controles de `cargo xtask verify`. El comando integral no pudo adquirir el
      bloqueo de cargo-deny en la ruta global de solo lectura; el control se repitió en modo offline con una copia
      temporal de la misma base y pasó sus cuatro comprobaciones.

### PF-3 · Motor (tamaño L, mecánico)

- [ ] PF-3.1 Tests que fallan antes del cambio: terminador, paso y tipo de parámetro obligatorios sin consultar ningún modo.
- [ ] PF-3.2 Especificación, catálogo y `pseudolearn_diagnostics`: el generador de código del catálogo
      (`codegen/policy.rs`) emite una sola severidad por código y `DiagnosticCode::severity` pierde su argumento. Resolver
      aquí si la clasificación conserva las letras A, C, D, E sin renumerar B.
- [ ] PF-3.3 `pseudolearn_syntax`: el terminador es siempre obligatorio; desaparece `with_terminator`,
      `parse_source_with_terminator` y `terminator_diagnostic`.
- [ ] PF-3.4 `pseudolearn_semantic`: quitar `SemanticOptions.strict` y las seis ramas.
- [ ] PF-3.5 Especificaciones API, recurso/esquema `helpCatalog/1` y `pseudolearn_service`, `pseudolearn_api`, `aot_rt`,
      `conformance` y `bench_worker`:
      quitar `strictness`, `strict` e `is_strict` de las firmas, modelos y operaciones; `execution_sources`, `ir_execution`,
      `native_build`, `diagnostic_template`, `edit_session_operations` y `program_view` incluidos.
- [ ] PF-3.6 Reescribir los ~90 tests que pasan `strictness` o comparan modos; no duplicar casos del corpus como tests.
- [ ] PF-3.7 README de cada crate tocado y `cargo xtask verify` en verde.

### PF-4 · Marcador de línea (tamaño M)

- [ ] PF-4.1 Tests que detectan la ausencia del marcador, con caso de punto y coma omitido y caso de línea larga.
- [ ] PF-4.2 Especificación y casos CLI: fijar el formato oficial y esperados derivados (§2); implementarlo en la salida
      de texto tras `format_diagnostic_line` y en los cuatro puntos que la comparten (`check`, `format`, `ir`, reporte de
      proyecto).
- [ ] PF-4.3 Revisar el resto de mensajes de error del lenguaje que más se encontrarán al aprender (terminador, tipo de
      parámetro, paso de `Para`) y confirmar que dicen qué falta y dónde.

### PF-5 · CLI y extensión de VS Code (tamaño M)

- [ ] PF-5.1 CLI: eliminar `--rigor`/`--strictness`, `handle_strictness_option`, el valor por defecto `strict` y su
      traducción en comandos y DAP; actualizar el README y el corpus `tool.cli.*`.
- [ ] PF-5.2 VS Code: eliminar el ajuste de `package.json` (dos apariciones), `extension_configuration`,
      `configuration_resolver`, `configuration_message`, `debug_configuration`, `run_arguments` y los tests asociados.
- [ ] PF-5.3 `pnpm` de la extensión y `cargo xtask verify` de la CLI en verde.

### PF-6 · App (tamaño M)

- [ ] PF-6.1 Especificación `APP.EXEC.CONFIGURATION` y escenarios de conformidad: quitar `Document.strictness`, el campo
      del archivo y de la sincronización (`file_document_repository`,
      `document_sync_drainer`), `ExecutionConfiguration.strictness` y los parámetros de `ProgramAnalyzer`,
      `rust_execution_opening`, `rust_program_analyzer` y los demás adaptadores del puente.
- [ ] PF-6.2 Quitar el selector «Flexible» de `ExecutionConfigurationControls` y sus cadenas `.arb`; revisar el diseño de la
      fila con el campo «Argumentos» y el botón «Reproducir» en pantalla de móvil (verificación visual en el simulador).
- [ ] PF-6.3 Capítulos de conocimiento y manifiestos, incluido `esp-i-sistema-de-tipos`: regenerar o reescribir las
      secciones que hablan de rigor, en español e inglés, desde el corpus y no a mano si existe generador
      (`GEN-NO-HAND-COPY`).
- [ ] PF-6.4 Corregir los programas de onboarding y de la base de conocimiento que no pasen `comprobar` (D-09).
- [ ] PF-6.5 `flutter analyze`, tests y verificadores del paquete en verde; `see conform --subject app` sin regresiones
      frente a la línea base de PF-0.

### PF-7 · Documentación y barrido de rastros (tamaño S)

- [ ] PF-7.1 READMEs de la raíz, motor, CLI, extensión y app: quitar la sección de rigor y la fila «Selector del eje de
      rigor» de los pendientes de la app; registrar la decisión de lenguaje único donde corresponda.
- [ ] PF-7.2 Frontend: renombrar el título `spec.types` en `es.json` y `en.json` («Sistema de tipos y política de rigor»,
      «Type system and strictness policy»). El título del capítulo de conocimiento se actualiza con PF-6.3.
- [ ] PF-7.3 Benchmarks: quitar `'strictness': 'flexible'` de `bridge_scenarios.dart`.
- [ ] PF-7.4 Comprobación manual de cierre: `git grep` de `strictness`, `strict`, `estricto`, `flexible`, `rigor` e
      `is_strict` fuera de `docs/`; cada coincidencia restante se justifica una por una (por ejemplo `strict-casts`) y el
      resultado queda registrado en este plan.

## 5. Riesgos

| ID | Riesgo | Mitigación |
|---|---|---|
| R-01 | La app analiza hoy por defecto en flexible: cuando el lenguaje pase a ser único, programas que hoy corren dejarán de hacerlo | PF-0.3 mide el alcance antes de empezar; PF-6.4 corrige ejemplos y onboarding |
| R-02 | Existe comportamiento exclusivo de flexible en datos del corpus que mi revisión de ramas no vio | PF-0.2 lo busca de forma explícita y se reporta antes de PF-1 |
| R-03 | Edición masiva del corpus a mano introduce errores | Edición textual dirigida, revisión del diff por archivo y `see validate` tras cada bloque |
| R-04 | Reescribir el capítulo del sistema de tipos desalinea español e inglés y los activos de la app | PF-6.3 regenera desde el corpus; el verificador de paridad del paquete debe seguir en verde |
| R-05 | El marcador cambia la forma de la salida de la CLI y rompe casos de conformidad que comparan texto | PF-4.2 implementa el formato y actualiza esos casos con esperado derivado; `--json` queda intacto |
| R-06 | Quitar `Document.strictness` deja archivos locales de desarrollo con una clave sin uso | Aceptado por D-02; si el lector del front matter la ignora, no hay código nuevo; se confirma en PF-6.1 |

## 6. Puertas de cierre

- Cada fase: tests propios en verde y todos los verificadores del miembro en verde, empuje ordinario comprobado a la rama
  única y parada a la espera de confirmación.
- Cierre del plan: PF-7.4 registrado, `see validate` y `see conform` sin regresiones frente a PF-0, `flutter analyze` y
  suite de la app, `cargo xtask verify` de motor, CLI y spec, y suite de la extensión en verde.

## 7. Registro de ejecución

| Fase | HEAD inicial | Comandos y salida | Resultado | Pendientes |
|---|---|---|---|---|
| PF-0 | `6fb7bd7fd7b6b55e3e212d13b5095453bcfa2db7` | Inventario y línea base en §7; verificadores locales en verde | PF-0 completado; detenida la ejecución por PHASE-STOP | PF-1 requiere autorización explícita nueva |
| PF-1 | | Reordenamiento autorizado el 2026-11-03; entregables reasignados a PF-2–PF-6 por dependencia de verificación | No ejecutada como fase independiente | Ninguno; no se modificó corpus ni código para PF-1 |
| PF-2 | `7e673d03cd6be3de62b4ebab9a904a17a21bf97e` | `cargo fmt --all --check`, Clippy estricto, `cargo test --workspace`, cargo-deny offline (advisories/bans/licenses/sources ok), `rust-checks all .`, `rust-checks toolchain ../..`, build release del adaptador engine, `see validate` (197), `see export --check`, conformidad de propiedades (31 ejecutadas, 0 pendientes), conformidad completa (4026 observaciones, 0 divergencias) | Completada; verificadores en verde. `cargo xtask verify` se detuvo al intentar bloquear `/Users/cgutieco/.cargo/advisory-dbs/db.lock`, de solo lectura; cargo-deny pasó con base local temporal | Ninguno |
| PF-3 | | | | |
| PF-4 | | | | |
| PF-5 | | | | |
| PF-6 | | | | |
| PF-7 | | | | |

### Línea base de PF-0

- Estado inicial: rama `feature/agregar-ruta-de-especificacion`, HEAD `6fb7bd7fd7b6b55e3e212d13b5095453bcfa2db7`,
  índice y diff de trabajo vacíos. El repositorio no tiene cambios ajenos al iniciar esta fase.
- PF-0.1: `cargo xtask verify` de `pseudolearn_spec` terminó en verde: 197 especificaciones validadas, 31 propiedades
  ejecutadas y 4.026 observaciones de conformidad sin divergencias. `cargo xtask verify` de `pseudolearn_engine` y
  `pseudolearn_cli` también terminó en verde, incluidos Clippy, tests, verificadores Rust y auditorías de dependencias.
  `pseudolearn_app`: `flutter analyze --fatal-infos --fatal-warnings`, límites, contenido, sistema visual y cobertura de
  sintaxis en verde; `flutter test` pasó 2.673 tests y omitió 2; el generador pasó 9 tests. `fe-pseudolearn`: `pnpm
  check:all`, `test:e2e` (32), `test:a11y` (22) y `test:visual` (6) en verde; el chequeo integral también cubrió 198
  tests unitarios. `pseudolearn_vscode`: checks de tipos, arquitectura, comentarios, tamaño y paquete en verde; 165 tests.
  `pseudolearn_benchmarks`: 29 tests, análisis, límites y formato en verde. Backend: la búsqueda no encontró código ni
  documentación operativa relacionada con el modo flexible; no se ejecutó su suite.
- Para dejar esas puertas en verde, se aplicó el formato requerido por rustfmt y dart format en sus archivos señalados
  por los verificadores. Clippy detectó que un helper de la prueba de historia viva del motor excedía el límite de
  función; se dividió por responsabilidades y el verificador completo del motor terminó en verde. Ningún cambio altera
  el comportamiento del producto.
- PF-0.2: `LANG.DECL.UNINITIALIZED#R1` establece `missingBindingInitializer` como error en ambos modos y evita valores por
  defecto; el sondeo `Definir Mutable valor Como Entero; Escribir valor;` produce solo ese error en estricto y flexible.
  `LANG.SUBPROGRAM.PARAMETERS#R1` permite omitir el tipo en flexible y exige `expectedType` en estricto; no es una
  contradicción: es el comportamiento que D-03 propone volver obligatorio. Omitir `;` da `missingStatementTerminator`
  solo en estricto, como prevé `LANG.PROFILE.STRICTNESS#R1`; omitir `Con Paso` da `missingStepClause` solo en estricto,
  como prevén `LANG.PROFILE.STRICTNESS#R1` y `LANG.CONTROL.FOR#R1`. La asignación a un nombre no declarado da
  `undeclaredVariable` en ambos modos, según `LANG.TYPES.INFERENCE#R1`;
  los sondeos no emitieron `inferredVariableType`. Las diferencias históricas `REF-FLEXIBLE-INITIALIZATION` y
  `REF-STRICT-INFERENCE` pertenecen al sujeto `reference` retirado, no describen una regresión del motor actual.
- PF-0.3, `pseudo comprobar --json`: 231 archivos `.pseudo` versionados; 210 sueltos, de los que 115 producen errores
  (432 diagnósticos; 368 son `missingStatementTerminator`, concentrados en 113 ejemplos de conocimiento). Los otros
  21 módulos se analizaron en sus 8 proyectos y perfiles declarados: 5 proyectos pasan y 3 proyectos negativos producen
  el error previsto. Entre 16 programas de benchmark, 6 fallan (2 cargas Annex y `queens`, `towers`, `list`, `storage` de
  CORE), principalmente por terminadores omitidos, conectores de tipo e inicializadores. Se extrajeron además 94 cercas
  `pseudo` de la documentación de conocimiento: todas generan diagnósticos al analizarlas como archivos completos; son
  fragmentos pedagógicos o ejemplos negativos, por lo que no se mezclan con el conteo de programas independientes.
- PF-0.4: el formato de texto existente continúa como primera línea; luego se imprime una línea de fuente con número y
  una línea de indicador con `^` en la columna inicial. Solo se presenta la primera línea de spans multilínea. JSON queda
  intacto. La expansión de tabuladores, recorte y ancho visual Unicode quedan descritos en §2.1 para PF-4.
