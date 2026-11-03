# Eliminación del eje de rigor · un solo lenguaje — plan de ejecución

## 0. Metadatos y contrato de ejecución

- Fecha: 2026-11-03, America/Lima. Revisión inspeccionada: `53c04124`. Rama: `feature/agregar-ruta-de-especificacion`.
  Cambios ajenos presentes y conservados: `apps/pseudolearn_app/macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme`,
  `apps/pseudolearn_cli/examples/general-purpose/character.es.pseudo`, `apps/pseudolearn_vscode/media/pseudolearn.tmLanguage.json`.
- Petición: eliminar el modo flexible y toda etiqueta del modo estricto, de modo que el lenguaje sea uno solo y lo que hoy
  exige el modo estricto pase a ser el lenguaje oficial; quitar también el selector de rigor de la app; asegurar que los
  errores sean claros, incluido un marcador de línea. El lenguaje no ha salido a producción, así que los cambios de ruptura
  se hacen ahora y no queda rastro de funciones obsoletas ni de código muerto.
- Estado: plan **sin ejecutar**. Este análisis no ejecutó ninguna suite; los conteos son de `grep` e incluyen falsos
  positivos (por ejemplo «BEM estricto» en el frontend o `strict-casts` en el análisis de Dart).
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
| D-05 | Las clases de diagnóstico quedan: A estructural y ejecución fatal (error), C higiene (advertencia), D inferencia (información), E lectura inválida (advertencia, recuperable). La letra B no se reutiliza ni se renumera; si el corpus exige letras contiguas, se decide en PF-1 y se informa. | Evita reescribir identidades por estética; el corpus manda. |
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
- Si el diagnóstico abarca varias líneas, el marcador muestra la primera y subraya hasta el final de ella.
- Las líneas muy largas se recortan alrededor de la columna, con puntos suspensivos en los extremos.
- Los tabuladores se expanden a un ancho fijo, para que la marca caiga bajo el carácter correcto.
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

- [ ] PF-0.1 Registrar HEAD, diff y resultados de las suites de cada miembro afectado como línea base.
- [ ] PF-0.2 Buscar comportamiento exclusivo de flexible oculto en datos y no en ramas de código. Las entradas históricas
      `REF-FLEXIBLE-INITIALIZATION` y `REF-STRICT-INFERENCE` sugieren que la advertencia de lectura sin inicializar y la
      información `inferredVariableType` dependían del modo. Confirmar en el motor actual cuál es el comportamiento real
      y reportarlo si contradice el corpus.
- [ ] PF-0.3 Ejecutar `comprobar` en el lenguaje actual sobre todos los programas de ejemplo, onboarding, conocimiento,
      benchmarks y fixtures, y registrar cuántos fallan. Es la medida real del riesgo de D-09.
- [ ] PF-0.4 Leer `tool.cli.messages` y `tool.cli.check` y fijar el formato exacto del marcador (§2.1).

### PF-1 · Especificación (tamaño L)

- [ ] PF-1.1 Reescribir el capítulo del sistema de tipos (`esp-i-sistema-de-tipos`, español e inglés): quitar «perfil
      estricto/flexible», la política de severidad por política y la invariante «flexible es siempre igual o más permisiva».
- [ ] PF-1.2 Reescribir `diag.severity.policy` (clases A, C, D, E; sin B) y las reglas de `diag.classes` que mencionen rigor.
- [ ] PF-1.3 Colapsar `severidad` a un valor por código en `catalogs.json` y en `see-1.schema.json`; retirar `rigor` y
      `strictness` del esquema.
- [ ] PF-1.4 Quitar `"rigor"` de las 1537 líneas de casos y `"strictness"` de sus entradas, con edición textual dirigida.
      Borrar el único caso exclusivo de flexible y los casos que solo comparaban ambos modos; reescribir la regla afectada.
- [ ] PF-1.5 Reescribir `app.exec.configuration`: la regla R1 deja de hablar de rigor y queda «un programa con el
      terminador omitido no se ejecuta porque su análisis tiene un error»; renombrar el contrato a configuración de
      reproducción; C2 se borra y C3 se reduce a un solo caso.
- [ ] PF-1.6 Reescribir el texto de `api.analyze`, `api.execute`, `api.model` y `api.errors` sin el argumento de rigor.
- [ ] PF-1.7 Texto oficial del marcador de línea en `tool.cli.*` y casos con esperado derivado (§2).
- [ ] PF-1.8 Reanclar con `lock --refresh` listando todos los IDs modificados.

### PF-2 · Verificadores del corpus (tamaño M)

- [ ] PF-2.1 Adaptar `see_validation`, `see_conformance` y `see_report` y sus fixtures: eliminar el campo `rigor` y la
      validación de combinaciones.
- [ ] PF-2.2 Ajustar los casos negativos de los verificadores para que sigan cubriendo violaciones deliberadas.
- [ ] PF-2.3 `cargo xtask verify` del paquete en verde.

### PF-3 · Motor (tamaño L, mecánico)

- [ ] PF-3.1 Tests que fallan antes del cambio: terminador, paso y tipo de parámetro obligatorios sin consultar ningún modo.
- [ ] PF-3.2 `pseudolearn_diagnostics`: el generador de código del catálogo (`codegen/policy.rs`) emite una sola severidad y
      `DiagnosticCode::severity` pierde su argumento.
- [ ] PF-3.3 `pseudolearn_syntax`: el terminador es siempre obligatorio; desaparece `with_terminator`,
      `parse_source_with_terminator` y `terminator_diagnostic`.
- [ ] PF-3.4 `pseudolearn_semantic`: quitar `SemanticOptions.strict` y las seis ramas.
- [ ] PF-3.5 `pseudolearn_service`, `pseudolearn_api`, `aot_rt`, `conformance` y `bench_worker`: quitar `strictness`,
      `strict` e `is_strict` de las firmas, modelos y operaciones; `execution_sources`, `ir_execution`, `native_build`,
      `diagnostic_template`, `edit_session_operations` y `program_view` incluidos.
- [ ] PF-3.6 Reescribir los ~90 tests que pasan `strictness` o comparan modos; no duplicar casos del corpus como tests.
- [ ] PF-3.7 README de cada crate tocado y `cargo xtask verify` en verde.

### PF-4 · Marcador de línea (tamaño M)

- [ ] PF-4.1 Tests que detectan la ausencia del marcador, con caso de punto y coma omitido y caso de línea larga.
- [ ] PF-4.2 Implementar el marcador en la salida de texto de la CLI, tras `format_diagnostic_line`, y en los cuatro
      puntos que la comparten (`check`, `format`, `ir`, reporte de proyecto).
- [ ] PF-4.3 Revisar el resto de mensajes de error del lenguaje que más se encontrarán al aprender (terminador, tipo de
      parámetro, paso de `Para`) y confirmar que dicen qué falta y dónde.

### PF-5 · CLI y extensión de VS Code (tamaño M)

- [ ] PF-5.1 CLI: eliminar `--rigor`/`--strictness`, `handle_strictness_option`, el valor por defecto `strict` y su
      traducción en comandos y DAP; actualizar el README y el corpus `tool.cli.*`.
- [ ] PF-5.2 VS Code: eliminar el ajuste de `package.json` (dos apariciones), `extension_configuration`,
      `configuration_resolver`, `configuration_message`, `debug_configuration`, `run_arguments` y los tests asociados.
- [ ] PF-5.3 `pnpm` de la extensión y `cargo xtask verify` de la CLI en verde.

### PF-6 · App (tamaño M)

- [ ] PF-6.1 Quitar `Document.strictness`, el campo del archivo y de la sincronización (`file_document_repository`,
      `document_sync_drainer`), `ExecutionConfiguration.strictness` y los parámetros de `ProgramAnalyzer`,
      `rust_execution_opening`, `rust_program_analyzer` y los demás adaptadores del puente.
- [ ] PF-6.2 Quitar el selector «Flexible» de `ExecutionConfigurationControls` y sus cadenas `.arb`; revisar el diseño de la
      fila con el campo «Argumentos» y el botón «Reproducir» en pantalla de móvil (verificación visual en el simulador).
- [ ] PF-6.3 Capítulos de conocimiento y manifiestos: regenerar o reescribir las secciones que hablan de rigor, en
      español e inglés, desde el corpus y no a mano si existe generador (`GEN-NO-HAND-COPY`).
- [ ] PF-6.4 Corregir los programas de onboarding y de la base de conocimiento que no pasen `comprobar` (D-09).
- [ ] PF-6.5 `flutter analyze`, tests y verificadores del paquete en verde; `see conform --subject app` sin regresiones
      frente a la línea base de PF-0.

### PF-7 · Documentación y barrido de rastros (tamaño S)

- [ ] PF-7.1 READMEs de la raíz, motor, CLI, extensión y app: quitar la sección de rigor y la fila «Selector del eje de
      rigor» de los pendientes de la app; registrar la decisión de lenguaje único donde corresponda.
- [ ] PF-7.2 Frontend: renombrar el título `spec.types` en `es.json` y `en.json` («Sistema de tipos y política de rigor»,
      «Type system and strictness policy»).
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
| R-05 | El marcador cambia la forma de la salida de la CLI y rompe casos de conformidad que comparan texto | PF-1.7 los reescribe con esperado derivado; `--json` queda intacto |
| R-06 | Quitar `Document.strictness` deja archivos locales de desarrollo con una clave sin uso | Aceptado por D-02; si el lector del front matter la ignora, no hay código nuevo; se confirma en PF-6.1 |

## 6. Puertas de cierre

- Cada fase: tests propios en verde y todos los verificadores del miembro en verde, empuje ordinario comprobado a la rama
  única y parada a la espera de confirmación.
- Cierre del plan: PF-7.4 registrado, `see validate` y `see conform` sin regresiones frente a PF-0, `flutter analyze` y
  suite de la app, `cargo xtask verify` de motor, CLI y spec, y suite de la extensión en verde.

## 7. Registro de ejecución

| Fase | HEAD inicial | Comandos y salida | Resultado | Pendientes |
|---|---|---|---|---|
| PF-0 | | | | |
| PF-1 | | | | |
| PF-2 | | | | |
| PF-3 | | | | |
| PF-4 | | | | |
| PF-5 | | | | |
| PF-6 | | | | |
| PF-7 | | | | |
