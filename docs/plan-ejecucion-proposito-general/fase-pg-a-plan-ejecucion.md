# Fase PG-A · App y sintaxis estática — plan de ejecución

## 0. Metadatos y límite de autorización

- Fase de origen: §4.10 del [plan general](plan-ejecucion-proposito-general.md).
- Fecha de preparación: 2026-11-01.
- Revisión inspeccionada: `d621b16bb413c43677f7f9588b7e46728ed282f0`.
- Rama comprobada: `feature/agregar-ruta-de-especificacion`; árbol limpio antes de redactar.
- Petición: «Crea el plan de ejecución detallado para `4.10 PG-A · App y sintaxis estática`, lo suficientemente detallado para que el agente que complete las fases no tenga chance de alucinar».
- Autorización actual: el 2026-11-01 la persona autorizó implementar `PG-A.01` y `PG-A.02` en una sola iteración, aun con `PG-1` abierto. Esta autorización no cierra `PG-1`, `PG-A` ni `PG-A.C01`–`PG-A.C13`, y no autoriza `.03`–`.09`, commit, push ni PG-B/PG-7. Al terminar `.01` y `.02`, informar y detenerse.
- Autorización posterior: el 2026-11-01 la persona autorizó implementar `PG-A.03` y `PG-A.04` en una sola iteración. Tampoco cierra `PG-1`, `PG-A` ni `PG-A.C01`–`PG-A.C13`, y no autoriza `.05`–`.09`, commit, push ni PG-B/PG-7. Al terminar `.03` y `.04`, informar y detenerse.
- Este documento es transitorio de `docs/`. Sus decisiones operativas deben trasladarse al corpus y a los README dueños sin citarlo desde fuera de `docs/` (`DOC-NO-TRANSIENT-REFS`).

Las subsecciones de trabajo son puntos de PG-A, no fases nuevas. Una autorización posterior que nombre solo un punto no autoriza los demás ni el cierre común. Al completar el alcance autorizado se informa y se detiene (`PHASE-STOP`). Si la persona autoriza PG-A completa, las puertas técnicas internas no requieren pedir confirmación rutinaria; sí se detiene ante los conflictos y dependencias humanas expresamente identificados.

## 1. Punto de partida comprobado

### 1.1 Dependencias y discrepancias que no se pueden resolver por inferencia

| ID local | Evidencia en la revisión inicial | Consecuencia antes de implementar |
|---|---|---|
| PA-PRE-01 | El plan general exige PG-1, PG-2 y PG-H. PG-H y PG-2 figuran cerradas; PG-1 continúa abierto | Resuelto solo para el alcance autorizado: se implementan `.01` y `.02` con `PG-1` abierto; su estado y los cierres comunes de PG-A no cambian |
| PA-PRE-02 | ADR-12 describe tipo declarado de interfaz y llamadas por interfaz. `LANG.TYPES.INTERFACE#R1/R3` declara que la interfaz no es tipo de valor y no existen valores ni tablas dinámicas de interfaz | Resuelto para `.02` por la suposición explícita aceptada: contrato nominal y restricción sobre valores concretos; no se introducen valores de interfaz ni despacho dinámico |
| PA-PRE-03 | La hoja antigua dice «GP»; las decisiones del 2026-10-22 y `LANG.EDITION.MODEL#R1` mantienen exclusivamente 2026 | Aplicar la decisión explícita ya registrada: no crear edición GP, selector GP ni migrador. «Sintaxis nueva» significa sintaxis oficial vigente de 2026 |
| PA-PRE-04 | `LANG.PROGRAM.STRUCTURE#R1` enumeraba menos declaraciones que los contratos dueños; hay contratos para interfaces, registros y enumerados | Resuelto para `.01`: se trató como inventario incompleto y se alineó `R1` con los contratos dueños; permanece una sola entrada algorítmica |
| PA-PRE-05 | PG-6A/6B informan deuda heredada de validación SEE/revisión independiente y cierres por decisión expresa sin `PHASE-GREEN`; el reanclaje local detectó desajustes en `API.ANALYZE` y `API.ERRORS`, que no se editaron aquí | Separar esa deuda del cambio actual. `see validate` sí pasa; no reanclar reglas ajenas por inferencia ni declarar verdes las puertas que fallen |

La autorización del 2026-11-01 resuelve PA-PRE-01/02/04 para `.01` y `.02` únicamente. PA-PRE-05 conserva su deuda y sus fallos actuales se registran con procedencia en §11.

### 1.2 Lo que ya existe y lo que falta demostrar

Rutas de esta sección relativas a la raíz del monorepo:

| Dueño actual | Hecho inspeccionado | Trabajo de PG-A |
|---|---|---|
| `apps/pseudolearn_app/lib/engine/rust/rust_program_view_source.dart` | `load` rechaza errores; `loadStructure` conserva errores semánticos y libera el recurso en `finally`; ambos usan análisis público | Conservar la separación estructura/ejecución; transportar diagnóstico y estado de invalidez sin borrar estructura útil |
| `lib/engine/rust/rust_class_diagram_builder.dart` dentro de la app | Filtra unidades `class`; construye relaciones por nombre | Incluir contratos y tipos aplicables; relaciones con identidad, origen y validez; no deducir realización de firmas parecidas |
| `lib/domain/model/diagram/class_model.dart` | `ClassRelationKind` solo contiene `generalization` y `association`; filas/cajas tienen nodo y línea | Añadir discriminantes y relaciones segregadas sin usar línea/nombre como identidad universal |
| `lib/engine/rust/rust_program_view_builder.dart` | Convierte IDs públicos opacos a ordinales `ProgramNodeId` locales | Preservar ida/vuelta y revisión; impedir que el mismo ordinal de otra vista reutilice selección anterior |
| `lib/engine/rust/rust_view_semantics.dart` | Lee operadores, literales, incorporadas, capacidades y `suspendable` | Auditar atributos nominales, variantes, capturas y ámbitos todavía no transportados; no inventarlos en Dart |
| `lib/engine/rust/rust_flowchart_block_builder.dart` | Distingue controles tradicionales y tareas; su forma simple tiene fallback `process` | Admitir procesos conocidos por inventario explícito; desconocidos producen resultado de cobertura no soportada, nunca éxito genérico |
| `lib/engine/rust/rust_structogram_cell_builder.dart` | Tiene selección/bucles/tareas y fallback a hoja `process` | Misma exigencia; resolver `for_each_loop`, salidas, propagación y limpieza con sus roles reales |
| `lib/engine/rust/rust_construct_projection.dart` | Reconoce ocho formas y devuelve `null` en otras | Es taxonomía curricular parcial, no prueba de exhaustividad del lenguaje |
| `lib/engine/rust/export/rust_program_exporter.dart` | Carga vista válida y emite Python/Rust con `UnitShapeReader` | Clasificar soporte antes de emitir y bloquear programas mixtos que perderían semántica |
| `lib/domain/model/export/export_result.dart` | Existen `ExportSuccess`, `ExportUnavailable` y `ExportAnalysisError` | Reutilizar; añadir estado ilustrativo solo con contrato visible y separado de equivalencia |
| `packages/pseudolearn_engine/crates/pseudolearn_api/src/program_view_nominal.rs`, `program_view_values.rs`, `program_view_variants.rs` | Hay anotaciones públicas nominales/de valores/variantes; `API.PROGRAM.VIEW` incluye C9–C12 y regla R4 de tareas | Inventariar campo por campo y probar su llegada al consumidor; existencia del módulo no prueba completitud |
| README de app, ayuda y capacidades simuladas | Hay consulta PG-H y anfitrión simulado; tareas tienen algunas formas estáticas | Reutilizar puertos. Foco/pilas por tarea, agenda y proyecciones dinámicas permanecen en PG-B |
| `tool/see_app_adapter.dart` y `conformance.yaml` de app | El sujeto app usa FRB real; dispone de peticiones API secuenciales | Extender observaciones a la proyección nueva sin responder constantes ni comprobar solamente JSON del motor |

En la tabla anterior las rutas `lib/`, `test/`, `tool/` y `assets/` pertenecen a `apps/pseudolearn_app` salvo indicación contraria. Los nombres nuevos de este plan son propuestas; no se presentan como archivos o herramientas existentes.

## 2. Lectura y fuentes de verdad

### 2.1 Lectura realizada para preparar el plan

- `AGENTS.md` provisto en la conversación, README raíz y §4.10/§5 del plan general.
- Hoja de ruta: R-03/05–08/17–20, C-15, ADR-12/13, CF-16/18, E-PG-12 y K-18/19; decisiones posteriores del plan general.
- README de app: arquitectura, foco, emisores, frontera FRB, conformidad, ayuda, efectos simulados, pruebas visuales y datos de tareas; `architecture.yaml` completo de app y de `native/`, README del puente.
- README de spec y engine, matrices y límites de sus reglas; README de API, README y reglas de CLI. Para cualquier edición de un crate interno falta releer su README particular y su fila exacta de imports.
- Contratos inspeccionados: `LANG.EDITION.MODEL`, `LANG.PROGRAM.STRUCTURE`, `LANG.MODULE.IMPORT`, `LANG.TYPES.INTERFACE`, `LANG.TYPES.FUNCTION`, `API.PROGRAM.VIEW`, `APP.ENGINE.BOUNDARY` y sus casos pertinentes.
- Código concreto de §1.2 y puerta documental `packages/pseudolearn_spec/xtask/src/documentation.rs`.

Esta lectura es de diseño, no evidencia de que tests o verificadores del producto hayan pasado.

### 2.2 Lectura adicional obligatoria al retomar

Antes de la primera modificación de producto, leer completos los contratos del punto y registrar reglas/casos exactos. No derivar semántica del resumen del plan:

| Preocupación | Fuentes iniciales; todas bajo `packages/pseudolearn_spec/specifications/` |
|---|---|
| Documento aislado | `lang/lang.edition.model.md`, `lang/lang.program.structure.md`, `lang/lang.module.model.md`, `lang/lang.module.import.md`, `api/api.analyze.md`, `api/api.project.md`, `api/api.execute.md` |
| Tipos/valores | `lang/lang.types.interface.md`, `lang/lang.types.generic.md`, `lang/lang.types.record.md`, `lang/lang.types.enum.md`, `lang/lang.types.function.md`, `lang/lang.types.vector.md`, `lang/lang.types.dictionary.md`, `lang/lang.types.relations.md` |
| Control/vínculos | `lang/lang.control.for-each.md`, `lang/lang.control.switch.md`, `lang/lang.control.exit.md`, `lang/lang.control.cleanup.md`, `lang/lang.subprogram.scope.md`, `lang/lang.decl.constant.md`; localizar contratos de Opcional/Resultado y mutabilidad por ID real |
| Proyecciones y frontera | `api/api.program.view.md`, `api/api.state.query.md`, `api/api.versioning.md`, `api/api.errors.md`, `app/app.engine.boundary.md`, `app/app.exec.snapshot-view.md`, `app/app.exec.pace.md` |
| Ayuda y pruebas | Contrato `TOOL.SERVICE.CATALOG`, gramática y vocabulario oficiales, `perf/perf.protocol.md`, `perf/perf.artifact.size.md` |

`rg --files` localiza archivos; buscar el ID en `specifications/` localiza el contrato. Si un nombre propuesto no existe, no crear una copia bajo ese nombre sin revisar al dueño existente. No consultar terceros para decidir la gramática propia. Si se necesitan APIs de Flutter/FRB distintas de las existentes, consultar documentación primaria de la versión fijada y registrar en README qué se adopta.

## 3. Decisiones de diseño propuestas y condiciones

| Decisión | Alternativas y criterio | Elección para revisión | Condición de revisión / dueño documental |
|---|---|---|---|
| PA-D01 Documento aislado | Reescritura oculta en Dart / configuración pública del núcleo; reproducibilidad y mismos rangos | Operación o configuración pública reutilizando la API vigente cuando baste; texto intacto y entorno normativo determinista | No crear nombre de operación/flag antes del contrato. API y CLI documentan la decisión en sus README |
| PA-D02 Preludio | Lista manual por consumidor / catálogo común; evitar deriva | Inventario normativo de símbolos disponibles en 2026 y reglas de colisión/sombreado; sin concesiones ambientales | Si el corpus no fija un nombre o su disponibilidad, especificarlo primero. Spec/API son dueños; no ampliar biblioteca por conveniencia |
| PA-D03 Identidad | Nombre o línea / ID público y revisión | Identidad de sesión/proyecto, revisión, fuente y nodo; ordinal Dart solo como índice local | Si una relación no tiene origen suficiente, ampliar API antes de proyectarla. README API/app |
| PA-D04 Modelos de tipos | Meter todo en `class_model.dart` / separar responsabilidades | Conservar API útil de clases; crear datos segregados de contrato, restricción, variante, captura e iteración/ámbito donde no haya dueño | Resolver PA-PRE-02 primero. No crear una clase monolítica con todos los campos opcionales. README app |
| PA-D05 Cobertura | Lista paralela a mano / inventario público verificable | Matriz declarativa con identidades del corpus/API y celdas tipadas; el verificador contrasta conjuntos completos | Si no hay catálogo público exhaustivo, añadirlo desde su dueño; muestras observadas no prueban exhaustividad. README spec/API/app según alcance |
| PA-D06 Import/export | Resolver disco/red / explicar fuente conservada | Dependencia no resuelta explícita, diagnóstico y navegación al origen; no ejecuta el programa con enlace pendiente | Reutilizar diagnóstico normativo; uno nuevo solo después de especificarlo. README API/app |
| PA-D07 Exportación | Traducción parcial / disponibilidad total por programa y destino | Equivalencia solo para intersección comprobada; indisponibilidad precisa cuando una construcción la rompe; explicación ilustrativa rotulada si aporta valor | No obliga a ampliar backend ni a incorporar intérprete Python/Rust. README app |
| PA-D08 Escenas | Goldens / invariantes estructurales y render medible | Identidades, relaciones, geometría, semántica accesible y foco; capturas solo como evidencia inspeccionable | Mantener política visual vigente. README app |

Son decisiones propuestas dentro del alcance, no evidencia ni nuevos requisitos aprobados. Si la revisión cambia una elección, actualizar el contrato/README dueño y las tareas dependientes antes de programar. La app no recibe objetos del compilador ni decide satisfacción de interfaces, exhaustividad, captura, orden de iteración o limpieza.

## 4. Desglose por punto

Orden obligatorio por punto: regla → casos derivados → tests que detectan la ausencia → implementación → documentación → verificación. Una tarea se marca solo con evidencia concreta en §11. Los IDs `.01`–`.09` conservan el significado del plan general.

### PG-A.01 · Documento único y preludio público

- [x] `PG-A.01.01` Resolver las puertas de §1.1 y registrar autorización. Auditar análisis, ejecución, ayuda y servicio sobre documento aislado; localizar configuración pública reutilizable. Separar qué existe de lo que falta con rutas y casos.
- [x] `PG-A.01.02` Especificar el modo aislado en contratos dueños existentes; crear contrato adicional solo si no hay dueño. Fijar: una entrada, declaraciones hermanas admitidas, edición 2026, perfiles/rigores, inventario de preludio, disponibilidad y sombreado, rechazo de múltiples entradas, import/export sin resolución y relación de IDs/revisiones. Ninguna capacidad procede del preludio por sí sola. No decidir nombres ni reglas de sombreado sin norma revisada.
- [x] `PG-A.01.03` Derivar casos es/en y estricto/flexible: archivo autosuficiente válido, vacío, algoritmo vacío, dos entradas, nombre en colisión con preludio, símbolo ausente, Unicode/BOM, import no resuelto y ausencia de permisos. Expected de diagnósticos, salida e identidades viene de cada regla; no capturar resultados del motor.
- [x] `PG-A.01.04` Añadir pruebas API/CLI/puente que fallen sin configuración uniforme. Comparar el mismo archivo/configuración y el texto antes/después; abrir/consultar no edita, traduce ni migra. Variar directorio de ejecución y entorno del proceso para probar independencia.
- [x] `PG-A.01.05` Implementar en API/semántica solo las carencias demostradas; CLI acepta la misma configuración y el sujeto SEE la transporta. La app pasa configuración, no antepone texto/imports, crea manifiestos ocultos ni lee dependencias instaladas. El nombre del flag, si hace falta, se fija en corpus de CLI antes del parser.
- [x] `PG-A.01.06` Actualizar README de spec, crate/miembro engine, CLI y app afectados; registrar opción pública, inventario, límites, fallos y por qué. Verificar casos de este punto por engine, cli y app, más tests espejo y puertas afectadas de §7.

Salida exigida: un caso autocontenido reproducible por operación pública, CLI y FRB con configuración equivalente; fuente idéntica y sin manifiesto obligatorio. No basta ejecutar solo un `Algoritmo` tradicional.

### PG-A.02 · Modelos y proyección estática

- [x] `PG-A.02.01` Elaborar inventario de campos públicos actuales: forma, ID, revisión, rango, papeles, relación y condición de error. Para interfaz/realización/restricción/variante/captura/iteración/ámbito identificar campo existente o carencia. Contrastar también registros, constantes, inmutabilidad y tipos función; no reconstruirlos con regex.
- [x] `PG-A.02.02` Extender `API.PROGRAM.VIEW` y, solo si hace falta, `API.STATE.QUERY` con datos ausentes. Definir realización explícita/heredada y estado inválido, restricciones por identidad, discriminante/carga de variante, origen y modo de captura, vínculos/colección/cuerpo de iteración y dueño de ámbito. La representación de captura no expone direcciones ni materializa un entorno inexistente.
- [x] `PG-A.02.03` Derivar casos del contrato para interfaz vacía, dos implementaciones, contrato incompleto, restricción válida/inválida, captura transitiva y mutable rechazada, variante con/sin carga, colección vacía y ámbito anidado. Añadir casos de revisión ajena, ID ausente y rangos Unicode.
- [x] `PG-A.02.04` Escribir tests espejo de modelos y adaptadores, y de API donde cambie. Inyectar transporte para probar campos faltantes/desconocidos y errores tipados; los tests de integración usarán FRB real en `.07`. Ninguna excepción esperable debe escapar del puerto.
- [x] `PG-A.02.05` Crear/extender modelos inmutables y puertos pequeños; adaptar `rust_program_view*`/`rust_view_semantics.dart`. Conservar el mapa de identidad pública a índice local y revisión. Extraer archivos especializados antes de superar límites; no engordar `EditorCubit` ni `ClassModel` con responsabilidades ajenas.
- [x] `PG-A.02.06` Documentar invariantes en README de API/app, actualizar reglas solo si cambia realmente la arquitectura y ejecutar tests/casos del punto. Entregar tabla de campos consumidos con contrato y test por fila.

### PG-A.03 · Interfaces, realización y tipos visibles

- [x] `PG-A.03.01` Fijar contrato de representación en corpus de app: caja `«interface»`, operaciones/restricciones, realización discontinua con triángulo hueco hacia contrato, herencia continua, dependencia de uso diferenciada, estado inválido unido a diagnóstico y origen. Elegir contrato existente o identidad nueva revisada, sin inventar un ID supuestamente vigente.
- [ ] `PG-A.03.02` Derivar escenas: contrato solo, una y dos implementaciones, dos contratos, herencia más realización, método heredado, sobrescritura inválida y destino desconocido. Enumerar cajas/filas/relaciones y origen esperado manualmente. Resolver PA-PRE-02 antes de escribir cualquier caso de «valor de interfaz».
- [ ] `PG-A.03.03` Añadir tests de `class_model`, adaptador de clases, layout/routing, pintores y accesibilidad. Afirmar dirección/estilo del triángulo y segmentos, no únicamente que se pintó una línea. Interfaz sin implementación sigue visible; relación inválida no parece válida solo por su color.
- [ ] `PG-A.03.04` Implementar proyección de unidades aplicables y relaciones por ID. El layout calcula cajas/rutas; presentación dibuja estados ya derivados. La tabla usa valores concretos y restricciones aprobadas sin fabricar objeto/marco abstracto. Navegar firma/relación lleva al rango exacto; inspeccionar no modifica texto.
- [ ] `PG-A.03.05` Hacer visibles y navegables parámetros genéricos, registros, enumerados y restricciones según la matriz de `.04`; no insertar pasos ejecutables para declaraciones. Reutilizar tokens de tema y localización para leyenda/estado, con ambos idiomas de interfaz.
- [x] `PG-A.03.06` Actualizar README app/API según cambios y ejecutar casos/escenas/negativos. Adjuntar evidencia de relaciones y diagnóstico con el puente real, completada en `.07`.

### PG-A.04 · Matriz exhaustiva y controles fieles

- [x] `PG-A.04.01` Fijar esquema de cobertura como datos: identidad de construcción y papel, anclaje regla/versión, formas públicas, vista, representación exacta/extensión declarada/no aplicable con motivo, foco/origen, estado, ayuda y casos/test. Separar taxonomía curricular `AstConstruct` del inventario exhaustivo de lenguaje.
- [ ] `PG-A.04.02` Escribir contrato/casos para rechazo de identidades activas sin fila, filas obsoletas/duplicadas, celda sin motivo, ayuda inexistente, rol no cubierto y forma pública desconocida. Definir la respuesta visible no soportada sin entregar diagrama falso como válido.
- [x] `PG-A.04.03` Crear tests del verificador con fixtures aislados: quitar fila, agregar construcción activa, cambiar rol, repetir identidad, ocultar control en fallback y declarar «no aplicable» sin explicación. Cada violación debe fallar por causa esperada; un conjunto válido debe pasar.
- [ ] `PG-A.04.04` Completar todas las filas de §4.10 contra inventario vigente, incluidos controles previos. Implementar recorrido y manejadores de iteración, patrones, propagación, salidas y limpieza. Distinguir salida normal, ruptura, retorno y propagación; dibujar las limpiezas en su orden normativo, sin reevaluarlas para producir la escena.
- [x] `PG-A.04.05` Sustituir fallbacks silenciosos de ambos constructores por clasificación exhaustiva: proceso conocido permitido, contenedor/expresión proyectado en su dueño o fallo explícito. Un `_` que simplemente produce `process`, hoja ordinaria o `null` no demuestra cobertura.
- [x] `PG-A.04.06` Incorporar el verificador a la puerta local de la app, documentar comando real en README y probarlo con su negativo. Ampliar SEE solo si la regla necesita datos normativos/exportación; no crear un verificador global nuevo por comodidad. Registrar conjunto esperado frente al cubierto, sin porcentajes inventados.

### PG-A.05 · Import/export pegados

- [ ] `PG-A.05.01` Precisar en el contrato aislado de `.01` y en proyección app qué se analiza y qué queda sin enlace: ruta, alias, visibilidad, origen y diagnóstico, sin efecto de E/S ni ejecución. Coordinar nombres de diagnóstico con `LANG.MODULE.IMPORT` y catálogo, sin reutilizar uno con significado distinto.
- [ ] `PG-A.05.02` Derivar casos con import de módulo/símbolo, alias, export encadenado, ruta incompleta, nombre reservado y dependencia ausente. Comparar bytes antes/después; probar ruta absoluta/escape y contenido pegado que nombra un paquete existente en disco sin conceder su lectura.
- [ ] `PG-A.05.03` Añadir tests de API, adaptador, ayuda y widgets: dependencia visible, rango navegable, error legible y ejecución bloqueada ante enlace pendiente. Instrumentar capacidades del host para afirmar cero llamadas de lectura/resolución/red; no basta «no hizo HTTP» en un fake que no podía hacerlo.
- [ ] `PG-A.05.04` Implementar el consumo de formas públicas; conservar fuente y las demás unidades recuperables. No añadir gestor de dependencias, selector de proyecto, descargas ni archivos auxiliares. Documento con fallo sintáctico muestra diagnóstico sin inventar estructura válida de esa parte.
- [ ] `PG-A.05.05` Documentar la frontera en README API/CLI/app afectados; ejecutar casos y puente real. Import/export soportado visualmente no se anuncia como proyecto ejecutable resuelto.

### PG-A.06 · Código equivalente honesto

- [ ] `PG-A.06.01` Inventariar por destino Python/Rust cada construcción y garantía que los emisores actuales conservan; vincularla a pruebas existentes y faltantes. Revisar `UnitShapeReader`, lectores de sentencias/expresiones y ambos emisores: un lector que descarta una unidad invalida el programa completo.
- [ ] `PG-A.06.02` Especificar clasificación por destino: equivalente comprobada, ilustración explícita o no disponible con motivo/identidad/rango. Para programa mixto manda la construcción menos soportada; errores de análisis siguen siendo error de análisis. Definir mapeo de foco solo para líneas realmente emitidas.
- [ ] `PG-A.06.03` Derivar casos de subconjunto válido conocido, una forma nueva no soportada, mezcla válido/no soportado, error semántico y revisión obsoleta. Probar que no aparece un programa parcial como exportación exitosa ni queda código anterior visible bajo una fuente nueva.
- [ ] `PG-A.06.04` Escribir tests de exportador, cubit y panel; implementar prevalidación de cobertura por destino y resultados de dominio. Reutilizar `ExportUnavailable`; agregar ilustración únicamente si existe contenido rotulado y pruebas que impiden copiarlo/exportarlo como equivalente.
- [ ] `PG-A.06.05` Para cada equivalencia declarada, registrar el tipo de prueba que la respalda y sus límites. Pruebas de cadenas emitidas no prueban equivalencia semántica. Si falta evidencia suficiente, declarar indisponibilidad o ilustración, sin prometer backend ejecutable universal ni secuencializar concurrencia.
- [ ] `PG-A.06.06` Actualizar README y matriz por destino y verificar casos de regresión es/en. No añadir compilación/ejecución de traducciones al flujo del producto ni ampliar destinos.

### PG-A.07 · Identidades, geometría, accesibilidad y puente real

- [ ] `PG-A.07.01` Fijar invariantes observables en corpus de app/API: asociación escena/revisión, foco por nodo/rango, identidad de valores, recuperación semántica y semántica accesible. Derivar escenas manuales antes de implementar tests.
- [ ] `PG-A.07.02` Probar dos sentencias en una línea, mismo nombre en ámbitos distintos, dos implementaciones con firma igual, edición que cambia ordinales, revisión anterior rechazada, entrada vacía, identificador de un carácter, Unicode multicode-unit y error en una unidad con otra recuperable. No comparar IDs opacos contra una codificación privada.
- [ ] `PG-A.07.03` Probar cajas sin solapamiento, aristas sin atravesar cajas ajenas, etiquetas/triángulos dentro de sus límites y hit targets que llevan al origen correcto. Incluir nombres largos, restricciones largas, muchas relaciones, zoom y lienzo compacto con escalado de texto. Registrar tamaños exactos usados por los tests según tokens existentes.
- [ ] `PG-A.07.04` Probar árbol Semantics: tipo/contrato, nombre, firma, relación, invalidez y diagnóstico disponibles sin depender del color; selección/navegación por teclado y acción táctil. Layout y semántica accesible deben coincidir en identidad, incluso con texto truncado visualmente.
- [ ] `PG-A.07.05` Ejecutar las escenas con `openNativeTransport()` y biblioteca recién compilada: analizar → consultar vista → proyectar modelos → construir escena/estado → seleccionar origen/consultar ayuda → liberar. Probar manejo de fallo y no crecimiento de recursos en repeticiones. No sustituir el caso por un test JSON de API ni por fakes.
- [ ] `PG-A.07.06` Extender sujeto app y vínculos de conformidad donde la regla lo requiera; ejecutar propiedades/casos pertinentes con semilla/procedencia. Si el adaptador SEE no puede observar una escena, añadir una observación de consumidor derivada de la escena real, sin respuestas precalculadas.
- [ ] `PG-A.07.07` Actualizar README, ejecutar verificadores afectados y registrar limitaciones de plataforma. Humo macOS/simulador iOS según disponibilidad y riesgo; resultado de un host no certifica Windows/iOS físico. No disparar CI ni tiendas sin autorización específica.

### PG-A.08 · Ayuda, referencia y ejercicios

- [ ] `PG-A.08.01` Cruzar inventario estático con catálogo PG-H: identidad/papel, ficha es/en, regla y ejemplo vigente por idioma. Revisar también marcadores de referencia y ejercicios de `assets/knowledge`; no copiar prosa normativa al consumidor.
- [ ] `PG-A.08.02` Para cada hueco redactar regla/datos editoriales en el dueño del catálogo y casos aceptados/diagnósticos/ejecutables según contrato. Revisar rol de restricción, captura, variante, iteración, ámbito e import/export, no solo palabra inicial.
- [ ] `PG-A.08.03` Añadir tests de consulta API y `RustSyntaxHelpSource`, cubit/panel y contenido: cursor sobre papel específico, límite de token compuesto, ausencia válida, documento revisado durante consulta y ambos idiomas de interfaz independientes de es/en del documento.
- [ ] `PG-A.08.04` Ampliar narrativa/ejercicios bilingües existentes con ejemplos autocontenidos de las familias de §4.10; registrar cada objetivo, solución, caso normativo y resultado esperado. Reutilizar manifiestos y generadores actuales, sin fabricar una pista curricular completa ajena a C-15. Extender `AstConstruct` cuando esos ejercicios realmente lo requieran.
- [ ] `PG-A.08.05` Regenerar catálogo/referencia por sus comandos dueños; verificar ausencia de copias normativas y vigencia de anclajes. Comprobar por FRB que editor y vista navegada obtienen la misma identidad y ejemplo. Ejecutar verificador de contenido y tests espejo, documentando alcance en README.

### PG-A.09 · E-PG-12 estático y cierre de evidencia

- [ ] `PG-A.09.01` Preparar protocolo automatizable con escenas de §7, oráculo manual y configuración completa. Separar escenas estáticas de `.01`–`.08` del trabajo de tareas/eventos de PG-B; no declarar E-PG-12 completo por ejecutar esta parte.
- [ ] `PG-A.09.02` Ejecutar comprobaciones de cero omisiones y cero confusiones de identidad, geometría y accesibilidad. Medir proyección estática según §6; conservar muestras crudas y resultados desfavorables. Las métricas candidatas no se convierten en presupuesto aprobado.
- [ ] `PG-A.09.03` Preparar material humano: archivo con interfaz y dos implementaciones; variantes/Resultado, captura e iteración; preguntas, respuestas derivadas, orden contrabalanceado y registro por idioma/tarea. Piloto de al menos 12 principiantes solo si la persona aporta participantes/consentimiento y resultados; no simular participantes ni comprensión.
- [ ] `PG-A.09.04` Registrar el diferimiento complementario ya autorizado el 2026-10-22, si no llegan resultados humanos. Dejar la casilla humana sin cumplir y el resumen como Diferido con esa procedencia; no pedir de nuevo el concepto aprobado. La parte automatizable sigue siendo obligatoria. No usar el ≥80 % humano como resultado de widget tests.
- [ ] `PG-A.09.05` Consolidar por tarea/punto los resultados, hashes, comandos, fallos heredados/nuevos y omisiones justificadas; completar cierre común solo con sus evidencias y con autorización correspondiente. Informar a la persona y detenerse.

### 4.10 Matriz mínima que debe expandirse al inventario real

Esta tabla orienta la autoría; **no es todavía la matriz exhaustiva ni fija sintaxis**. Cada familia debe desagregarse en identidades/papeles públicos vigentes. «No aplicable» requiere motivo por celda. Las columnas de tabla describen solo datos que la API realmente puede observar.

| Familia | Ordinograma / estructograma | Tipos / estructura | Tabla / foco / ayuda |
|---|---|---|---|
| Interfaces y realizaciones | Sin paso por declarar contrato; cuerpos concretos navegables | Caja, firma, realización/estado inválido y origen | Ninguna instancia abstracta; contrato/restricción conforme decisión PA-PRE-02 |
| Genéricos y restricciones | Cuerpo con origen fuente, sin inventar ejecución de parámetro de tipo | Parámetro, argumento y contrato nominal | Tipo declarado/concreto cuando exista dato público; explicación de restricción |
| Registros, clases, enumerados | Declaración sin ejecución ficticia; constructor/cuerpo donde corresponda | Campos y semántica de valor/referencia; miembros enumerados | Copia frente a alias y campos; enumerado no es objeto inventado |
| Opcional/Resultado/patrones | Selección por variantes con cobertura y salidas correctas | Discriminante, carga y vínculos de patrón | Ausencia distinta de no inicializado; variante/error visible |
| Funciones/clausuras | Unidad de cuerpo enlazada al sitio de creación | Firma y captura por origen/modo aprobado | Entorno solo si existe; copia de registro frente a identidad de objeto |
| Colecciones/Para Cada | Iteración, orden, vínculos, cuerpo y salida; no proceso genérico | Tipos de colección y ámbito del iterador | Tamaño/paginación; sin leer colección completa para dibujar bucle |
| Constantes/inmutabilidad/ámbito | Declaración y alcance con origen; no efecto ficticio | Vínculos, tipo, mutabilidad y vigencia | Sombreado/fin de ámbito conforme norma; sin conservar variable como activa |
| Propagar/Descartar/Diferir/salidas | Continuación y salidas explícitas; limpieza en orden normativo | Error/resultado y ámbito propietario | Primer fallo y recursos observables, sin ejecutar cierres desde pintor |
| Módulos/import/export/visibilidad | Dependencia estructural, nunca celda ejecutable por keyword | Ruta/alias/origen y resolución ausente visible | Diagnóstico, explicación y ejecución bloqueada según `.05` |
| Función suspendible/await/tareas/Elegir | Conservar formas estáticas entregadas; await no es rombo ni bifurcación de hijas | Firma/ámbito y marcas estáticas verificadas | Ayuda estática disponible. Estado/foco por tarea y esperas reales: PG-B, pendientes explícitos |
| Capacidades/efectos | Identidad de operación sin activar host por dibujar | Tipo/capacidad según dato público | Rotulado existente de simulación; solicitudes y vistas dinámicas nuevas: PG-B |
| Sintaxis anterior | Decisión/bucle/call/input/output/proceso conocido conservados | Unidades y miembros existentes | Foco y ayuda sin regresiones por cambiar el clasificador |

## 5. Capas, archivos y dueño de cada responsabilidad

Las rutas propuestas se rotulan **nuevo propuesto**. Antes de editar, inventariar cada archivo concreto del diff con capa, imports permitidos/prohibidos y dueño; esta tabla no autoriza modificar carpetas enteras. Si el archivo queda con dos razones de cambio, extraer uno en su capa antes del código (`AGENTS.md` §1).

| Archivos / capa | Imports y prohibiciones | Responsabilidad y límite de edición |
|---|---|---|
| `docs/plan-ejecucion-proposito-general/fase-pg-a-plan-ejecucion.md` y enlace del plan general; documentación raíz | Sin imports de producto; citables solo dentro de `docs/` | Únicos archivos de esta preparación; no cambia arquitectura ni estado de ejecución |
| `packages/pseudolearn_spec/specifications/{api,app,lang}/` y recurso del catálogo; datos | Referencias internas del corpus, nunca `docs/`/URLs | Contratos/casos, identidad/estado/versión congelados; nuevos estable 1.0.0 sin `cambio`, revisión independiente auténtica |
| `packages/pseudolearn_spec/crates/see_validation/`, `see_export/`, `see_conformance/`; condicional | Solo matriz exacta de `architecture.yaml`; sin importar engine o Flutter | Cambiar únicamente si esquema/exportación/observación nuevos lo exigen. Leer README de cada crate primero; fixtures negativos y tests espejo |
| `packages/pseudolearn_engine/crates/pseudolearn_api/src/program_view*.rs` y operación/configuración aislada por localizar | Dependencias exactas del crate en reglas; sin tipos UI ni E/S ambiental | Datos públicos faltantes e invariantes de recursos/revisión; nuevo archivo especializado si crece responsabilidad |
| `pseudolearn_semantic`/`pseudolearn_service`; condicional | Semantic no importa API/servicio/VM; service no importa VM ni UI; rige matriz real | Cambiar solo si la configuración pública no basta o faltan datos semánticos; leer README dueño antes. No reconstruir semántica dentro de API/Dart |
| `apps/pseudolearn_cli/src/check_command.rs`, opciones/adaptador por localizar; borde | Solo API pública y dependencias declaradas; ningún crate interno | Exponer y comprobar el mismo modo, no crear un segundo preludio |
| App `lib/domain/model/{analysis,diagram,export,knowledge}/`; model | Sin otras capas ni Flutter/bloc/dart:io/dart:ui | Identidad/estado/modelos propios. `type_contract.dart`, `syntax_view_coverage.dart` son **nuevos propuestos**, verificar dueño antes de crearlos |
| App `lib/domain/ports/{class_diagram_builder,flowchart_builder,structogram_builder,program_exporter,syntax_help_source}.dart`; ports | Solo model; sin engine/Flutter/E/S | Reutilizar contratos; agregar resultado tipado/capacidad pequeña cuando sea necesario, sin exponer JSON/FRB |
| App `lib/engine/rust/{rust_program_view*,rust_view_semantics,rust_class_diagram_builder,rust_flowchart_block_builder,rust_structogram_cell_builder}.dart` y `export/`; engine | Model/ports/engine; sin Flutter/dart:io/dart:ui; sin RegExp | Traducir datos públicos a dominio y escenas. `rust_type_contract_projection.dart` es **nuevo propuesto** para evitar mezclar lectura nominal/layout |
| App `lib/engine/{classdiagram,diagram,structogram}/`; engine | Mismas restricciones de engine | Tamaño/routing/escena puros; ninguna consulta FFI ni semántica inferida por texto |
| App `lib/application/{diagram,export,editor/help}/`; application | Solo model/ports/application; sin engine/Flutter/RegExp/E/S | Estados inmutables y derivaciones; fallo/indisponibilidad/revisión separados del búfer editable |
| App `lib/presentation/{diagram,export,editor/help,l10n}/`; presentation | Model/application/presentation; sin engine/puertos directos/E/S; sin await ni derivación prohibida | Dibujo, selección y semántica accesible de estado ya derivado; etiquetas localizadas y tokens existentes |
| App `lib/composition/`; composition | Puede importar todas las capas declaradas; sin condicionales | Conectar puertos solo cuando cambien, sin resolver modo/idioma/plataforma con ramas |
| App `assets/knowledge/`, `tool/content/`, `tool/check_content.dart`, tests espejo y nuevo verificador por concretar | Datos curriculares y tooling actual, no semántica duplicada | Referencia/ejercicios y matriz; comando nuevo debe documentarse y probar rechazo deliberado |
| App `native/src/api.rs`, `native/README.md` y enlaces generados; condicional | Solo API/FRB/serde_json; aislamiento sin HTTP/TLS/AOT | No cambiar si el transporte genérico ya alcanza. Si cambia interfaz FRB: fuente dueña → generador fijado → check. Nunca editar salidas a mano |

Límites vigentes: Dart 250 líneas/archivo, 40/función, 30/build, 3 parámetros posicionales, anidación 3 y 5 métodos públicos. Rust de miembros afectados: 300/archivo, 40/función, 4 parámetros posicionales, anidación 3 y 7 métodos públicos; restricciones adicionales de nombres/unsafe según reglas. No subir límites para acomodar la implementación. Datos y herramientas conservan las exenciones exactas ya declaradas, no una exención genérica nueva.

## 6. Presupuestos de rendimiento y seguridad

- No activar ejecución/observación, host de efectos ni consultas de montón por construir una vista estática. Registrar operaciones de transporte y comprobar que no hay consultas auxiliares por caja/fila; consultar datos compartidos una vez cuando la API lo permita.
- Mantener paginación de valores; no materializar vectores, diccionarios o entornos completos para rotular un tipo. Registrar límites vigentes que afectan texto, profundidad, nodos, relaciones y valores. Cualquier límite visual nuevo exige valor, motivo, comportamiento al excederlo y test desde contrato/README, no truncado silencioso.
- `PERF.PG.APP.VIEW` es candidato, no contrato aprobado. El p95 ≤50 ms de ventana de 100 eventos/100 tareas es trabajo dinámico de PG-B; no aplicarlo a PG-A como si fuera una meta estática aprobada.
- Campaña estática: medir archivo tradicional de control y archivos es/en con 1/10/100 tipos/relaciones y controles anidados dentro de límites del motor. Validar primero semántica/escena del control; no usar un programa incompleto como comparación barata.
- Separar tiempos de análisis/transporte, proyección, layout y render; medir memoria y número de consultas antes/después. Fijar host, build, versiones, revisión, hashes, tamaño de entrada, calentamiento, repeticiones y estimador según `PERF.PROTOCOL`. Conservar muestras crudas y error/intervalos exigidos por ese contrato; no sustituirlos por un cronómetro único ni comparar Debug con Release.
- Si hay regresión, registrar magnitud y causa; modificar presupuesto requiere decisión, no cambiar fixture para ocultarla. Si cambia grafo nativo/artefacto, repetir la medición pertinente de `PERF.ARTIFACT.SIZE`; el README advierte margen iOS reducido. No certificar tamaño de plataformas que no se compilaron.
- Host denegado por defecto: el modo aislado no concede disco/red por nombres del preludio. Import/export no abre paquetes; consulta de ayuda/diagrama no ejecuta programa. Probar entradas adversarias: ruta de escape, alias colisionado, relaciones cíclicas, ID de otra sesión/revisión y profundidad/tamaño excesivos.
- Liberar recursos al fallar, cerrar sesiones y descartar resultados de revisión vieja. Los fallos públicos son resultados tipados/localizados; no escapar `FormatException`/casts fallidos de un puerto ni añadir pánicos Rust.

## 7. Pruebas, verificadores y evidencia

### 7.1 Escenas derivadas obligatorias

| Escena | Camino feliz | Infeliz / borde | Evidencia exigida |
|---|---|---|---|
| Archivo aislado | Una entrada con tipos, funciones y preludio permitido | Vacío, dos entradas, símbolo ausente, sombra/colisión según norma, import externo | Casos corpus engine/cli/app; misma fuente/configuración |
| Contratos | Interfaz con dos realizaciones y restricción usada | Vacía, sin realización, firma incompatible, heredada/sobrescrita | IDs, cajas, dirección de relaciones, diagnóstico/origen |
| Valores y capturas | Registro copiado, objeto alias, clausura con captura válida | Captura mutable rechazada, entorno todavía no creado, nombre sombreado | Tipos/campos/origen reales, ausencia de memoria ficticia |
| Variantes/control | Opcional/Resultado y patrón exhaustivo, propagación/limpieza | Ausencia, error, caso incompleto, limpieza con fallo | Ramas/salidas/orden derivados; diagnóstico sin ocultación |
| Iteración/ámbito | Para Cada sobre colección con orden normativo | Cero elementos, un elemento, salida temprana, variable fuera de ámbito | Bucle y continuación fieles, ninguna repetición inventada |
| Dependencia pegada | Import/export conservado y explicado | Ruta inválida, paquete en disco no concedido, alias reservado | Cero E/S de resolución; no ejecución con enlace pendiente |
| Cobertura/exportación | Inventario cubierto y subconjunto equivalente comprobado | Identidad/rol nuevo, programa mixto, traducción parcial | Negativos fallan; indisponibilidad visible por destino |
| Revisión/accesibilidad | Foco coherente en vistas y ayuda, navegación por teclado/táctil | Unicode, misma línea, edición cambia ordinal, zoom/compacto/texto largo | Rango/ID de revisión correctos, Semantics y geometría |

Ejecutar casos normativos en es/en y rigores declarados. Widgets cruzan perfil es/en con interfaz es/en sin asumir que son el mismo eje. Agregar ejecución con puente real al menos para cada familia modificada y para fallos de revisión/estructura inválida. Fakes prueban lógica local; no sustituyen integración. No duplicar programas del corpus como tests Rust: referenciar casos mediante conformidad y reservar tests espejo para contratos de módulos/adaptadores.

### 7.2 Comandos existentes y selección durante ejecución

Los comandos siguientes existen en los README inspeccionados. Ejecutarlos desde el miembro indicado; para filtros nuevos registrar el comando final exacto, no dejar marcadores como evidencia.

| Miembro | Preparación/verificación | Selección y ampliación |
|---|---|---|
| Spec | `cargo run -p see_cli --bin see -- validate`; `lock --check` y `export --check` mediante el mismo lanzador | Tras texto/casos y revisión auténtica, reanclar solo IDs editados con `lock --refresh ID,ID`, generar exportación y comprobarla. No refrescar todo ni ocultar revisión ausente |
| Spec/conformidad | `cargo run -p see_cli --bin see -- conform --subject app --only API.PROGRAM.VIEW` | Repetir por cada ID afectado y sujeto compatible engine/cli/app/service; registrar `--operation` solo cuando proceda. `.01` exige también el contrato aislado y CLI; `.07` exige observación de consumidor |
| Engine | `cargo test -p pseudolearn_api`; `cargo fmt --all --check`; Clippy y reglas del miembro | Elegir tests/crates concretos del diff; ampliar a semantic/service si cambian. El comando completo `cargo xtask verify` es campaña ampliada, no requisito de ejecutar toda suite por defecto |
| CLI | `cargo test`; `cargo xtask verify` como puerta ampliada | Seleccionar tests del modo/opciones/adaptador, además de conformidad CLI real. No ejecutar pruebas DAP/HTTP ajenas salvo dependencia o fallo |
| App/puente | `cargo build --release --locked --lib --manifest-path native/Cargo.toml`; `bash tool/test_bridge.sh` | Compilar antes de tests con FRB; frescura de biblioteca obligatoria. Si cambian enlaces: `bash tool/bridge.sh generate` y `bash tool/bridge.sh check` antes del build/tests, nunca en paralelo |
| App/análisis | `flutter analyze --fatal-infos --fatal-warnings`; `dart run tool/check_limits.dart`; `dart run tool/check_content.dart`; `dart run tool/check_design_system.dart` | Límites/análisis y reglas afectadas siempre; contenido si cambia currículo/catálogo; diseño si toca presentación. Añadir comando documentado del verificador de cobertura cuando exista |
| App/tests | `flutter test test/engine/rust/rust_class_diagram_builder_contract_test.dart test/engine/rust/rust_flowchart_builder_contract_test.dart test/engine/rust/rust_structogram_builder_contract_test.dart` | Añadir tests de dominios/adaptadores/layout/widgets/render y sus nuevos archivos espejo, no una lista inmutable que omita código nuevo |
| App/arquitectura | `flutter test test/architecture/`; `flutter test test/tool/spec_coverage_test.dart` | Incluir negativos de límites, cobertura y aislamiento; preservar pureza de presentación/composición, estados y cadenas visibles |
| Puente nativo si se edita | Desde `native/`: `cargo fmt --all --check`, `cargo clippy --all-targets`, `cargo test`, `cargo deny check` y reglas de su README | Mantener aislamiento declarado; no inferir que build macOS prueba todos los targets |

La puerta documental de esta preparación se comprueba con pruebas de `xtask` y comprobación de referencias; no requiere ejecutar app o motor. Durante implementación: ejecutar reglas mecánicas directamente afectadas y sus negativos, registrar selección y omisiones. Ampliar suites si hay fallo dirigido, frontera nueva o riesgo no cubierto, conforme decisión del 2026-10-24. Ninguna salida vieja se reutiliza como evidencia de fuentes nuevas.

### 7.3 Registro reproducible

Por comprobación guardar: comando, directorio, revisión/hash de fuentes, versiones, configuración/semilla/límites, fecha/plataforma, código de salida, conteo real y ruta/hash de salida cruda. Para test negativo registrar violación y diagnóstico esperado. Para escena guardar expectativa manual y resultado estructural/semántico, con captura opcional inspeccionada. Si falta revisión SEE, registrar quién debe revisarla y fallo literal; nunca llenar `revisado_por` con quien no revisó.

### 7.4 Protocolo humano estático E-PG-12

Material mínimo: escena de contrato frente a instancia; realización válida frente a inválida; selección de variante/error; captura por valor/alias; orden de Para Cada y fin de ámbito. Para cada una: fuente revisada es/en, tarea de comprensión, respuesta esperada derivada y criterio de puntuación previo. Contrabalancear orden y separar idioma de interfaz del perfil.

Registrar por participante seudónimo, consentimiento gestionado por la persona, idioma, orden, respuesta, acierto y tiempo si se mide. Analizar por tarea e idioma, informar denominadores y confusiones; el objetivo candidato de ≥80 % para distinguir interfaz de instancia no demuestra la distinción espera/paralelo, que se evalúa en PG-B. Una muestra insuficiente o ausente se informa como tal. No almacenar datos personales innecesarios en el repositorio.

## 8. Riesgos y señales de detención

| Riesgo | Señal temprana | Acción concreta |
|---|---|---|
| K-19 Cobertura didáctica incompleta | Forma nueva queda como proceso, hoja o `null`; cuadro de cobertura usa solo `AstConstruct` | Fallar verificador, agregar dato/manejador y negativo; no excluir la forma para pasar |
| K-18 Foco/causalidad falsa | ID local reusado tras editar; await parece condición; contrato crea marco | Invalidar selección de revisión vieja y corregir modelo; no implementar agenda PG-B |
| K-16 Deriva de ayuda | Prosa/lexemas copiados en ARB/Dart o rol sin ficha | Llevar contenido al catálogo y regenerar; comprobar identidad por FRB |
| PA-R01 Autoridad ambiental | Import funciona porque existe carpeta o permiso previo | Test de host con cero llamadas; aislar configuración pública; detener ejecución no autorizada |
| PA-R02 Semántica duplicada | Dart compara firmas o infiere captura por texto | Solicitar dato público al núcleo y caso normativo; eliminar inferencia local |
| PA-R03 Exportación engañosa | Traducción exitosa sin una unidad o destino con garantías desconocidas | Clasificar y bloquear programa completo para ese destino; conservar motivo y rango |
| PA-R04 Dependencias no cerradas / contratos contradictorios | Puertas PA-PRE sin decisión o textos normativos incompatibles | Informar y esperar resolución; no marcar casillas de ejecución |
| PA-R05 Evidencia falsa de calidad | Fake sustituye FRB, golden pasa sin accesibilidad o deuda SEE se declara verde | Ejecutar frontera real y negativos; registrar fallos heredados separados; no declarar `PHASE-GREEN` |
| PA-R06 Crecimiento y margen de artefacto | Layout superlineal, consultas por nodo, dependencia nativa nueva | Medir controles de §6; paginar/reusar datos; comprobar tamaño pertinente y no cambiar umbral |

## 9. Dependencias de la persona

| Momento | Dependencia | Estado inicial y conducta |
|---|---|---|
| Antes de ejecución | Revisión del plan y autorización de PG-A o punto concreto | Pendientes; esta petición solo prepara plan |
| Antes de ejecución | PA-PRE-01: dependencia PG-1 aún abierta | Requiere decisión explícita o evidencia de cierre real; no pedir que reapruebe lo ya aprobado en PG-H/PG-2 |
| Antes de contrato de interfaces | PA-PRE-02 y auditoría PA-PRE-04 | Presentar contratos exactos y opciones; esperar resolución; conservar alcance de 2026 y no introducir valores dinámicos por iniciativa propia |
| Antes de validar/reanclar | Revisión independiente auténtica de reglas/casos nuevos o editados | El agente redacta resultado concreto revisable; no inventa aprobador ni desactiva validador |
| Antes de declarar métrica aprobada | Aprobación de presupuesto candidato si se pretende hacerlo normativo | Medir y entregar datos primero; no condicionar implementación a aprobación de un umbral inventado |
| Estudio humano | Participantes/resultados E-PG-12 | Complementario, diferimiento ya autorizado en decisión del 2026-10-22. Registrar ausencia y no eficacia pedagógica |
| Comprobación remota/publicación | Actions/tiendas o credenciales si resultaran necesarios | Fuera del alcance de preparar plan; no iniciar por inferencia. Push ordinario de cierre seguirá regla cuando se autorice ejecución/cierre |

## 10. Orden de ejecución y puertas

1. **P0 · Arranque.** Releer estado Git y fuentes; registrar autorización, PA-PRE-01/02/04 y línea base SEE. No modificar producto hasta resolver dependencias que cambian contrato/trabajo. No crear rama/worktree nuevo.
2. **P1 · Contrato público.** `.01`, contratos/casos de `.02`, `.04`, `.05`, `.06` y `.08`; resolver revisión independiente y anclajes. Cada campo nuevo tiene regla/caso antes de motor. Si SEE falla, separar deuda heredada de fallo nuevo y reportar; no continuar implementando contra contradicción no resuelta.
3. **P2 · Frontera de datos.** Tests y código público de `.01/.02/.05`, CLI y adaptadores. Comprobar equivalencia de configuración/rangos y consumo por FRB antes de dibujar. Si faltan datos, volver al contrato, nunca rellenarlos por heurística.
4. **P3 · Modelos y escenas.** `.03/.04` y controles de §4.10; cumplir límites/capas/negativos antes de conectar UI. Declarar cada celda de cobertura con prueba, no solo con texto descriptivo.
5. **P4 · Superficies.** `.06/.08`: estados de exportación, ayuda, referencia y ejercicios con revisión coherente. Pintores reciben estado derivado; composición estática.
6. **P5 · Integración.** `.07`: puente real, widgets, render, geometría, Semantics y regresiones pertinentes. No aceptar equivalencia solo por ejecutar el mismo núcleo a través de dos bordes.
7. **P6 · Evidencia.** `.09`: campaña automatizable y mediciones; humanos diferidos con registro previo si ausentes. Completar resumen por tarea y cierre común.
8. **P7 · Cierre autorizado.** Revisar diff final, leer/aplicar skill `commit-message`, ejecutar checks afectados, commit sin atribución de IA y push ordinario comprobado a `feature/agregar-ruta-de-especificacion`; registrar HEAD/remoto. Si falla una puerta obligatoria, fase abierta y fallo informado; un cierre excepcional solo puede registrarse por decisión expresa, nunca como `PHASE-GREEN`. Entregar informe y parar sin iniciar PG-B/PG-7.

### 10.1 Cierre común que se comprobará, sin marcar por redactar

- [ ] `PG-A.C01` Mensaje nuevo que autoriza implementación, alcance y dependencias registrado.
- [ ] `PG-A.C02` Plan revisado por la persona; decisiones pendientes resueltas con procedencia.
- [ ] `PG-A.C03` SPEC-FIRST, 2026 y congelamiento sin estados/versiones ficticios.
- [ ] `PG-A.C04` Reglas con casos/propiedades y vínculos como datos, evidencia por sujeto.
- [ ] `PG-A.C05` Tests feliz/infeliz/límite y espejo; no duplicación de casos normativos en Rust.
- [ ] `PG-A.C06` Capas/imports/tamaños en verde para archivos cambiados; sin relajar reglas.
- [ ] `PG-A.C07` Código en inglés, cero comentarios/TODO, Rust sin pánicos ni unsafe no declarado.
- [ ] `PG-A.C08` README/reglas dueños autosuficientes actualizados; nada externo depende de este plan.
- [ ] `PG-A.C09` Cobertura estática, ayuda bilingüe y ejemplos por identidad/papel demostrados.
- [ ] `PG-A.C10` Riesgos revisados; E-PG-12 estático automatizable ejecutado, humanidad con evidencia o diferimiento autorizado.
- [ ] `PG-A.C11` Tests/verificadores afectados en verde; comandos, salidas y omisiones justificadas; deuda no ocultada.
- [ ] `PG-A.C12` Commit según skill y push ordinario comprobado en rama única, dentro del alcance autorizado.
- [ ] `PG-A.C13` Resumen aquí y plan general actualizados con evidencia, informe entregado y parada.

## 11. Resumen de ejecución

Implementación autorizada: PG-A.01 y PG-A.02 ejecutados en esta iteración con PG-1 abierto. La API pública de análisis y la entrada de archivo suelto de CLI conservan texto, perfil y rigor; la app transporta esos valores intactos. La vista estática agrega solo las relaciones ausentes y la app las decodifica en modelos inmutables. `API.STATE.QUERY` no cambió.

Implementación autorizada posterior: PG-A.03 y PG-A.04 ejecutados en una sola iteración. La vista de clases proyecta contratos, realizaciones, restricciones y estados inválidos por identidad de nodo; la matriz de cobertura sintáctica y su verificador cubren las 78 formas públicas del motor; los constructores de diagramas clasifican de forma exhaustiva y reportan lo que no dibujan.

Verificación `.03`/`.04`: `see validate` (196 especificaciones), `see conform --subject app --only API.PROGRAM.VIEW` (50 observaciones, 0 divergencias), `dart run tool/check_syntax_coverage.dart`, `dart run tool/check_limits.dart`, `flutter analyze --fatal-infos --fatal-warnings` y tests nuevos (contratos, formas, verificador, estado no soportado) en verde. La suite completa de Flutter tiene 29 fallos idénticos con y sin estos cambios (verificado con `git stash`): fixtures de transporte falso que el validador estricto del commit anterior rechaza, linaje de contenido, aislamiento de composición, corpus base de `robotAutonomo` y tabla de funciones incorporadas. `see lock --check` sigue fallando por `SEE-HASH` en `API.ANALYZE@1.0.0` (PA-PRE-05), y las reglas R6–R9 de `API.PROGRAM.VIEW` están sin reanclar y sin revisión independiente. El esquema de casos de SEE ganó el escenario `class_diagram`.

El registro sigue cada tarea de §4 y cada cierre común por su ID. Completar tareas de `.01` y `.02` no cierra PG-A ni habilita `.03`; las tareas `.03` y `.04` parciales o pendientes quedan abiertas en la tabla.

| Tarea / punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| PG-A.01.01 | Cumplido | Autorización explícita del 2026-11-01; auditoría de AnalyzeRequest, CLI de archivo y transporte de app | Alcance ejecutado; no implica cierre común de PG-A |
| PG-A.01.02 | Cumplido | LANG.PROGRAM.STRUCTURE#R1, LANG.EDITION.MODEL#R2, LANG.MODULE.MODEL#R3/C22 e IR.INSTRUCTIONS#V209 | Alcance ejecutado; no implica cierre común de PG-A |
| PG-A.01.03 | Cumplido | Casos LANG.PROGRAM.STRUCTURE C1–C5, LANG.EDITION.MODEL C3–C4 y LANG.MODULE.MODEL C22 | Alcance ejecutado; no implica cierre común de PG-A |
| PG-A.01.04 | Cumplido | Prueba de transporte Dart; editor_process prueba entrada suelta con entorno vacío y desde otro directorio | Alcance ejecutado; no implica cierre común de PG-A |
| PG-A.01.05 | Cumplido | AnalyzeRequest, API y entrada CLI existentes; sin manifiesto, transformación ni opción nueva | Alcance ejecutado; no implica cierre común de PG-A |
| PG-A.01.06 | Cumplido | README de spec, engine, CLI y app; conformidad SEE, pruebas dirigidas y límites registrados abajo | Alcance ejecutado; no implica cierre común de PG-A |
| PG-A.02.01 | Cumplido | Inventario de campos y filas contrato/prueba en README de app; auditoría del esquema previo API.PROGRAM.VIEW | Alcance ejecutado; no implica cierre común de PG-A |
| PG-A.02.02 | Cumplido | API.PROGRAM.VIEW#R5 y campos aditivos; API.STATE.QUERY permanece intacta | Alcance ejecutado; no implica cierre común de PG-A |
| PG-A.02.03 | Cumplido | API.PROGRAM.VIEW C13–C16 en español/inglés y rigor estricto/flexible | Alcance ejecutado; no implica cierre común de PG-A |
| PG-A.02.04 | Cumplido | 10 pruebas API nominales, 6 de identidad, pruebas espejo Dart de modelos/decodificador/transporte | Alcance ejecutado; no implica cierre común de PG-A |
| PG-A.02.05 | Cumplido | Modelos Dart inmutables y lectura tipada; proyección estática Rust con relaciones por IDs locales | Alcance ejecutado; no implica cierre común de PG-A |
| PG-A.02.06 | Cumplido | README de API/app y matriz campo–contrato–prueba; verificadores y fallos anotados abajo | Alcance ejecutado; no implica cierre común de PG-A |
| PG-A.03.01 | Cumplido | API.PROGRAM.VIEW#R6–R9 y casos C17–C23; PA-PRE-02 resuelto por contrato nominal | Se amplió un contrato existente porque un contrato nuevo exige revisión independiente que no consta; el texto editado queda sin reanclar (SEE-HASH heredado) y pendiente de revisión |
| PG-A.03.02 | Parcial | Escenas: contrato solo, una y dos implementaciones, dos contratos, herencia más realización, incompleta, destino desconocido y restricción, en es/en | Falta la sobrescritura inválida; el método heredado queda cubierto solo por la realización heredada que no se redibuja |
| PG-A.03.03 | Parcial | rust_type_contract_diagram_test, class_shapes_test (triángulo, punta abierta, guiones, color por estado), validadores de geometría de escena | Sin pruebas del árbol Semantics del lienzo: pertenecen a PG-A.07.04 |
| PG-A.03.04 | Parcial | RustTypeContractProjection, ClassRelation/DiagramEdge con IDs, origen y diagnósticos; enrutado y pintores | La navegación de relación a rango exacto se prueba solo como dato (nodeId/origen), sin prueba de widget |
| PG-A.03.05 | Pendiente | Restricciones visibles como relación de uso; registros, enumerados y parámetros genéricos quedan como extensiones declaradas en la matriz | Cajas de registro y enumerado no se dibujan; no se insertaron pasos ejecutables para declaraciones |
| PG-A.03.06 | Cumplido | README de app; conformidad app de API.PROGRAM.VIEW: 50 observaciones, 0 divergencias, por el puente real | La evidencia de interfaz sobre FRB real se amplía en .07 |
| PG-A.04.01 | Cumplido | Matriz como datos en lib/domain/model/diagram/coverage/, separada de AstConstruct; 78 formas públicas, 78 cubiertas | Inventario leído del código fuente del motor; la API no publica un catálogo |
| PG-A.04.02 | Parcial | Códigos COV-* con casos negativos en check_syntax_coverage_test; respuesta visible no soportada con mensaje es/en | Las reglas del verificador no están en el corpus; son contrato de herramienta documentado en el README |
| PG-A.04.03 | Cumplido | check_syntax_coverage_test: fila quitada, construcción activa añadida, rol cambiado, identidad repetida, sin motivo, control ocultado, regla y prueba inexistentes; conjunto válido pasa | Alcance ejecutado |
| PG-A.04.04 | Parcial | Todas las filas contra el inventario vigente; for_each_loop dibujado como bucle en ordinograma y estructograma | Ruptura, limpieza y propagación se reportan como no soportadas: dibujarlas exige aristas de salida en la disposición; no se implementaron |
| PG-A.04.05 | Cumplido | rustStatementTreatment exhaustivo; ambos constructores sin rama genérica; DiagramProgram.unsupported | Alcance ejecutado |
| PG-A.04.06 | Cumplido | dart run tool/check_syntax_coverage.dart documentado en el README con su negativo; SEE no se amplió | Conjunto esperado 78, cubierto 78 |
| PG-A.05.01 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.05.02 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.05.03 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.05.04 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.05.05 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.06.01 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.06.02 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.06.03 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.06.04 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.06.05 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.06.06 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.07.01 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.07.02 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.07.03 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.07.04 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.07.05 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.07.06 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.07.07 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.08.01 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.08.02 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.08.03 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.08.04 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.08.05 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.09.01 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.09.02 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.09.03 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.09.04 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.09.05 | Pendiente | Casilla de §4 sin ejecutar | Fuera de la autorización actual, que se limita a PG-A.01 y PG-A.02 |
| PG-A.C01 | Pendiente | Casilla de §10.1 | No autorizado el cierre común de PG-A |
| PG-A.C02 | Pendiente | Casilla de §10.1 | No autorizado el cierre común de PG-A |
| PG-A.C03 | Pendiente | Casilla de §10.1 | No autorizado el cierre común de PG-A |
| PG-A.C04 | Pendiente | Casilla de §10.1 | No autorizado el cierre común de PG-A |
| PG-A.C05 | Pendiente | Casilla de §10.1 | No autorizado el cierre común de PG-A |
| PG-A.C06 | Pendiente | Casilla de §10.1 | No autorizado el cierre común de PG-A |
| PG-A.C07 | Pendiente | Casilla de §10.1 | No autorizado el cierre común de PG-A |
| PG-A.C08 | Pendiente | Casilla de §10.1 | No autorizado el cierre común de PG-A |
| PG-A.C09 | Pendiente | Casilla de §10.1 | No autorizado el cierre común de PG-A |
| PG-A.C10 | Pendiente | Casilla de §10.1 | No autorizado el cierre común de PG-A |
| PG-A.C11 | Pendiente | Casilla de §10.1 | No autorizado el cierre común de PG-A |
| PG-A.C12 | Pendiente | Casilla de §10.1 | No autorizado el cierre común de PG-A |
| PG-A.C13 | Pendiente | Casilla de §10.1 | No autorizado el cierre común de PG-A |
| Preparación documental | Cumplido | Este documento y enlace desde §4.10 del plan general | No equivale a `PG-A.C02` revisado por la persona |
| PA-PRE-01 | Cumplido para .01/.02 | Autorización del 2026-11-01 | `PG-1` continúa abierto; solo se habilitaron estos dos puntos |
| PA-PRE-02 | Cumplido para .02 | Contrato nominal y restricciones sobre valores concretos | Sin valores de interfaz ni despacho dinámico |
| PA-PRE-03 | Cumplido | Edición 2026 y `LANG.EDITION.MODEL#R1/R2` | Sin selector ni migrador GP |
| PA-PRE-04 | Cumplido para .01 | `LANG.PROGRAM.STRUCTURE#R1` y casos C1–C5 | Un algoritmo por archivo |
| PA-PRE-05 | No cumplido; deuda heredada | Desajustes de lock y puerta de propiedades descritos después de la tabla | No se modificaron contratos ajenos ni estados/versiones congelados |

Verificación en verde: `see validate` validó 196 especificaciones; `see export --check` aprobó; conformidad engine para `LANG.PROGRAM.STRUCTURE` (20 observaciones), `LANG.EDITION.MODEL` (16) y `LANG.MODULE.MODEL` (37), todas con cero divergencias; conformidad app para `API.PROGRAM.VIEW` (43 observaciones, cero divergencias); 10 tests `program_view_nominal`, 6 tests de identidad, 2 tests CLI de archivo suelto, `cargo clippy --locked -p pseudolearn_api --all-targets --features native -- -D warnings`, `cargo fmt --all --check`, verificador de reglas Rust del engine, límites Dart, análisis Flutter y suite Flutter (21 tests).

Puertas fallidas o incompletas, separadas de la implementación: `see conform --subject engine --only API.PROGRAM.VIEW` observó 42 casos sin divergencias, pero termina en `SEE-REGRESSION` por el vínculo heredado de `API.PROGRAM.VIEW#R3`, cuyo único caso es de app y no ofrece caso engine; el reanclaje de los contratos editados queda bloqueado por `SEE-HASH` sobre `API.ANALYZE@1.0.0` y `API.ERRORS@1.0.0`, sin cambios a esos contratos. `cargo xtask verify` del engine llegó a tests después de Clippy, pero los tests de workspace terminaron con `No space left on device`; las pruebas dirigidas API sí pasan. `cargo xtask verify` de CLI pasó formato y Clippy, pero 12 pruebas de red local no pudieron abrir sockets (`Operation not permitted`); 104 tests de binario pasaron y las dos pruebas CLI dirigidas pasan. El verificador completo de spec pasó exportación, lint, tests y validaciones, pero quedó sin concluir en `see conform --subject engine --operation properties` por más de seis minutos y se interrumpió; no se declara verde.

La conformidad adicional de `LANG.SOURCE.POSITION` no generó evidencia nueva porque `SEE-STALE` detectó la matriz engine local anterior de `API.PROGRAM.VIEW` con hash de corpus desactualizado. El caso sí cuenta con tests de identidad de fuente en Rust y tests de rangos Unicode/BOM en el adaptador Dart.

No hubo commit ni push. No se cerró PG-1, PG-A ni ninguno de sus cierres comunes. La implementación de `.03` y `.04` queda reportada y la iteración se detiene aquí.
