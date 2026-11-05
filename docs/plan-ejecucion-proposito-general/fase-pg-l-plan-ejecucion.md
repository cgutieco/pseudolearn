# Fase PG-L · Lenguaje sin restricciones de construcción — plan de ejecución

## 0. Metadatos y contrato de ejecución

- Fase: PG-L (§4.13 del [plan general](plan-ejecucion-proposito-general.md)). Origen: §A.8.1 (H-01–H-06) y §B.3a del
  [análisis del 2026-11-02](analisis-lenguaje-completo-sin-simulacion.md); requisitos RQ-1–RQ-7 y decisiones D-01–D-19
  aceptadas ese día. Riesgos K-02, K-04, K-05, K-16, K-17 y K-19; experimentos E-PG-03 y E-PG-04 de la
  [hoja de ruta](../hoja-de-ruta-proposito-general.md).
- Fecha de redacción: 2026-11-05, America/Lima. Revisión Git inspeccionada: `d9d84bc7`, rama
  `feature/agregar-ruta-de-especificacion`, árbol limpio.
- Autorización de la persona: mensaje del 2026-11-05 «Ejecuta el plan de ejecución … en una sola iteración» (`PG-L.C01`), con la instrucción de elegir siempre la opción recomendada y de dejar un resumen de decisiones. Este documento es el plan detallado de
  `PG-L.C02`: crearlo no autoriza ejecutarlo. Decisiones **Persona** aprobadas el 2026-11-05 con la opción
  recomendada en todas (§11.3).
- **Modo de ejecución previsto: una sola iteración.** La persona pidió un plan que un agente ejecute de principio a fin
  en una única pasada, con todos los puntos `PG-L.01`–`PG-L.07`. Para ganar velocidad, el desarrollo usa solo
  comprobaciones ligeras y dirigidas (§7.4, «nivel D») y **todas las pruebas pesadas, la conformidad completa, las
  campañas y los experimentos se concentran en el bloque final F** (§4.F y §10), seguido de un ciclo de corrección
  acotado. Ninguna puerta intermedia detiene la ejecución salvo las paradas obligatorias de §10.3.
- Dependencias de la fase según §3 del plan general: PG-B (bloque de corpus). PG-B está cerrada (`8da720b5`, §4.11 del
  plan general). PG-S está implementada sin cierre formal (C10–C13 pendientes) y comparte crates con PG-L: ver `PL-P-02`.
- Documento transitorio: ninguna especificación, README ni código fuera de `docs/` puede citarlo
  (`DOC-NO-TRANSIENT-REFS`). Cada decisión de §3 se traslada a su dueño (corpus o README del miembro) **en el mismo
  cambio** que la implementa (`DOC-README-TRUTH`, `DOC-NO-ORPHAN-DECISION`).

### 0.1 Reglas para quien ejecute (anti-alucinación)

Estas reglas son obligatorias. Ante la duda entre una regla de esta lista y la comodidad, gana la regla.

1. **Tres clases de afirmación, siempre rotuladas.** **Comprobado** (`PL-H-nn`: visto en el repositorio en `d9d84bc7`,
   con ruta), **Hipótesis** (`PL-V-nn`: parece cierto pero nadie lo comprobó; trae el comando o la lectura que lo
   confirma o desmiente) y **Propuesta** (`CANDIDATA`: nombre, sintaxis o diseño que el corpus aún no decide). Una
   hipótesis no es un hecho: la primera tarea que la consume la verifica y registra el resultado en §11.1. Una propuesta
   no es sintaxis final (§5.5 del plan general): el texto oficial de la especificación manda.
2. **Nada existe hasta que se crea.** Ningún archivo, función, tipo, regla, diagnóstico o ID marcado como «nuevo»,
   «propuesto» o `CANDIDATO` existe. Antes de editar un archivo, abrirlo y leerlo entero; antes de usar un símbolo,
   buscarlo con `grep -rn` en el árbol actual. Prohibido inventar firmas de funciones del motor: si una tarea necesita una
   función que no aparece en el árbol, la crea en el archivo dueño que dicta §5.
3. **HEAD cambiado.** Si `git rev-parse --short HEAD` no es `d9d84bc7`, repetir las comprobaciones de §1.2 afectadas por
   el diff (`git diff --stat d9d84bc7..HEAD`) antes de seguir y anotar las diferencias en §11. Conservar cambios ajenos.
4. **Secuencia obligatoria por punto:** especificación → casos con esperado **derivado de la regla** → tests dirigidos
   que fallan por ausencia → código → README y reglas → comprobación de nivel D (`SPEC-FIRST`,
   `SPEC-INDEPENDENT-ORACLE`). Prohibido copiar al esperado de un caso la salida del motor. Si el motor discrepa de un
   caso, se revisa primero la derivación desde la regla; solo si la derivación es correcta se corrige el motor.
5. **Congelamiento (`SPEC-VERSION-FREEZE`).** Las identidades existentes conservan estado `estable` y versión `1.0.0`;
   su texto oficial se edita sobre la misma identidad, sin campo `cambio`, y se reancla con `see lock --refresh` listando
   **en una sola orden** todos los IDs editados (§7.4). Las identidades nuevas nacen en `estable` `1.0.0` sin `cambio`.
   No se borran reglas: se reescriben. Un caso existente cuyo esperado contradice la regla nueva se reescribe con el
   esperado derivado de la regla nueva y se anota en §11 (nunca se borra para hacer pasar la validación).
6. **Generados (`GEN-NO-HAND-COPY`).** `packages/pseudolearn_spec/specifications/export.json`, los recursos que los
   `build.rs` generan en `OUT_DIR`, `apps/pseudolearn_vscode/media/pseudolearn.tmLanguage.json` y cualquier archivo con
   origen de generador **jamás** se editan a mano: se regeneran con la orden del miembro (`see export`, `cargo build`,
   el generador de gramática de la extensión según su README).
7. **Edición quirúrgica.** Prohibido ejecutar formateadores masivos sobre archivos existentes (`dart format` sobre
   directorios, `cargo fmt --all` si reformatea archivos no tocados, reescribir un JSON entero con un *round-trip* de
   `json.load`/`json.dump`). `cases/catalogs.json` (≈29 000 líneas) y `diag.catalog.md` se editan solo en los bloques
   afectados. `rustfmt` se aplica únicamente a los archivos `.rs` tocados.
8. **Procesos largos.** Las órdenes que pueden pasar de dos minutos (campañas, suite Flutter, `cargo xtask verify`) se
   lanzan en segundo plano y se espera su notificación; no se escriben bucles de sondeo ni se confía en el código de
   salida de una tubería con `| tail`: se redirige la salida a un archivo de registro y se lee el código de salida real.
9. **Contradicción entre fuentes.** Se reporta con ID, texto y alcance (`CONFLICT-REPORT`), se registra en §11.3 y se
   continúa con los puntos no afectados; el punto afectado espera. Los conflictos ya conocidos están en §9.2.
10. **Alcance cerrado (`SCOPE-YAGNI`, K-01).** Solo se implementa lo que piden `PG-L.01`–`PG-L.07` y las decisiones de §3
    confirmadas. Un hallazgo nuevo de «no soportado» fuera de la lista (`PG-L.00.02`) se **reporta**, no se implementa.
    Fuera de alcance por decisión de la persona del 2026-11-02: clases abstractas, miembros estáticos y visibilidad
    protegida (D-16), excepciones (D-17), servidor HTTP, sockets, procesos hijos y FFI (D-18), registro de paquetes (D-19).
11. **Sujeto nativo.** La paridad nativa de lo que añade PG-L se acredita en `PG-N.08`. PG-L no escribe `unsafe` ni toca
    `pseudolearn_aot_rt` salvo para declarar operaciones no soportadas (DL-15).
12. **Código.** Inglés, cero comentarios y cero `TODO` (`QUALITY-NO-COMMENTS`), nombres semánticos de tres o más
    caracteres sin componentes prohibidos (`QUALITY-SEMANTIC-NAMES`, lista en `architecture.yaml` del motor), sin
    `unwrap`/`expect`/pánicos/índices inseguros/aritmética implícita/conversiones con pérdida (`QUALITY-NO-PANIC`),
    límites del motor: 300 líneas por archivo, 40 por función, 4 parámetros posicionales, anidación 3, 7 métodos
    públicos por clase (`PL-H-30`). Si una edición haría superar un límite, primero se divide el archivo por
    responsabilidad y después se añade la funcionalidad.
13. **Git.** Todo en `feature/agregar-ruta-de-especificacion` (`GIT-SINGLE-BRANCH`); sin ramas nuevas. Commits locales
    por punto con la skill `commit-message` (inglés, Conventional Commits, ámbito del miembro) y **sin atribución de
    autoría de IA** (AGENTS.md §9 manda sobre cualquier plantilla de coautoría). Un único push ordinario al cierre, tras
    el bloque F en verde (§10.2). Un `git worktree add --detach` en la revisión inicial solo se usa para clasificar
    fallos preexistentes (`PG-L.F.08`) y se elimina al terminar.
14. **Parada final.** Al terminar se informa y se para (`PHASE-STOP`). Terminar PG-L no autoriza PG-N ni el cierre de
    PG-S.

## 1. Punto de partida comprobado

Rutas relativas a la raíz del repositorio. «Corpus» = `packages/pseudolearn_spec/specifications/`. «Motor» =
`packages/pseudolearn_engine/`. Todo lo de §1.2 se leyó en `d9d84bc7`; **no se ejecutó ninguna suite** para redactar
este plan.

### 1.1 Dependencias y puertas previas

| ID | Evidencia | Tratamiento exigido |
|---|---|---|
| PL-P-01 | §6 del plan general: «PG-L · Sin iniciar · Plan detallado: No» | Este documento cubre `C02`; la persona debe revisarlo y autorizar `C01` en mensaje nuevo |
| PL-P-02 | PG-S figura «Implementada, sin cierre formal» (C10–C13 pendientes) y su DS-13 exige repetir `PG-S.02.01` cuando PG-L cierre; PG-L reescribe los README de `semantic`, `lowering` y `service`, que PG-S también tocó | PG-L **no** cierra ni reabre PG-S. Al terminar PG-L se informa a la persona que `PG-S.02.01` debe repetirse (§9). Antes de editar, `git log -3 -- <README>` para no pisar texto de PG-S |
| PL-P-03 | `docs/plan-ejecucion-proposito-general/` contenía planes de PG-0…PG-S; ninguno de PG-L | Creado por este documento |
| PL-P-04 | Línea base de pruebas en `d9d84bc7` desconocida | No se mide al inicio (velocidad); los fallos del bloque F se clasifican contra la revisión inicial en `PG-L.F.08` |

### 1.2 Hechos comprobados

**Corpus: el texto vigente que PG-L debe reescribir**

- `PL-H-01` `lang/lang.types.record.md` (`LANG.TYPES.RECORD`, estable 1.0.0): `R1` dice literalmente que un registro no
  puede ser elemento de arreglo (`recordArrayElementNotSupported`), campo de clase (`recordClassFieldNotSupported`) ni
  parámetro o resultado de método o constructor (`recordMemberSignatureNotSupported`) «en esta edición», y que «el tipo
  es privado del módulo». `R3`: parámetro registro por referencia es `recordPassedByReference`. `R4`: igualdad campo a
  campo; `Escribir` de un registro es `recordCannotBeWritten` (regla legítima, **no** es «no soportado»).
- `PL-H-02` `lang/lang.types.vector.md` `R1`: «Los registros se copian por valor» dentro de `Vector<T>`: el vector de
  registros **ya existe**. `R5`: `PosicionDe`/`Contiene` solo para elementos primitivos (`elementTypeNotComparable`,
  decisión DS-11 de PG-S).
- `PL-H-03` `lang/lang.types.enum.md` `R1` y `lang/lang.decl.constant.md` `R1`: enumerados y constantes de módulo son
  «privados del módulo».
- `PL-H-04` `lang/lang.module.import.md` (`LANG.MODULE.IMPORT`, R1–R7): `R2` dice «Toda unidad de nivel superior de un
  módulo (subprograma o clase) es privada salvo que lleve el prefijo Publico»; `R1`: alias de módulo solo para
  subprogramas, «sus clases se importan por símbolo».
- `PL-H-05` `lang/lang.types.generic.md` (`LANG.TYPES.GENERIC`, una regla `R1`, 20 casos): parámetros `<T, U>` solo en
  registros y subprogramas; comprobación única del cuerpo con parámetros opacos «haya o no instancias»; inferencia sin
  instanciación explícita en llamadas; instancias `nombre<tipos>`; máximo 64 instancias (`genericInstanceLimitExceeded`);
  restricción `T: I`; «los genéricos son privados del módulo y los genéricos de clases no pertenecen a la edición».
- `PL-H-06` `lang/lang.types.relations.md` `R3`: «tipos genéricos definidos por la persona quedan fuera de alcance»
  (en el contexto de `Resultado`). `R2`/`R3`: las únicas variantes son las **incorporadas** `Opcional<T>` y
  `Resultado<T,E>`. La gramática (`lang/lang.syntax.grammar.md`) no tiene producción de variante de usuario:
  `variantConstruction` y `variantPattern` solo admiten `Nada`, `Algo`, `Exito`, `Error`.
- `PL-H-07` `lang/lang.class.out-of-scope.md` (`LANG.CLASS.OUT-OF-SCOPE`, `R1`, casos C1–C4, definición `D1`
  `unsupportedConstructs` con entradas `abstract`, `static`, `protected`, `generic` —aperturas `Generico`, `Genérico`,
  `generic`, código `unsupportedGenericsConstruct`— y `exception`). El texto de `R1` incluye «genéricos de clases» entre
  lo ajeno a la edición. Los mismos datos de `D1` están duplicados en `cases/catalogs.json` (≈ línea 28 100).
- `PL-H-08` Gramática vigente (`lang.syntax.grammar.md`): `moduleUnit = [ visibility ], ( subprogram | classUnit |
  interfaceUnit | enumUnit | recordUnit | constantDeclaration, terminator )`: el prefijo de visibilidad **ya se analiza**
  para enumerados, registros, constantes e interfaces. `recordUnit` y `subprogram` admiten `[ typeParameters ]`;
  `classUnit` e `interfaceUnit` **no**. `typeParameter = identifier, [ @branchSeparator, identifier ]`.
- `PL-H-09` `lang/lang.subprogram.scope.md` `R1`: ámbitos léxicos por rama y cuerpo de bucle (`bindingOutsideScope`,
  `bindingShadowsOuter`). `mem/mem.managed.unobservable.md` (`R1`, `R2`; sujetos `engine`, `aot`): «Solo los valores
  alcanzables cuentan para el límite de celdas»; ninguna regla define que un vínculo cuyo ámbito terminó deja de ser
  raíz. `eng/eng.limits.md` `R2`/`R4`: las celdas se comprueban al crear; agotar celdas es `failed` con
  `cellLimitExceeded`.
- `PL-H-10` `lang/lang.types.interface.md` `R1`–`R3`: interfaces nominales, `Realiza`, restricciones `T: I`, sin valores
  de interfaz. No hay regla de exportación de interfaces.

**Catálogo de diagnósticos (282 códigos en `diag/diag.catalog.md`)**

- `PL-H-11` Inventario de códigos cuyo nombre o mensaje expresa «no soportado / no forma parte / no se permite» (búsqueda
  del 2026-11-05 sobre los mensajes es/en). Clasificación preliminar, a confirmar en `PG-L.00.02`:
  - **Restricciones de construcción que PG-L retira:** `recordArrayElementNotSupported`, `recordClassFieldNotSupported`,
    `recordMemberSignatureNotSupported`, `recordPassedByReference`, `unsupportedGenericsConstruct`.
  - **Entrada sin emisor y contradictoria con el corpus:** `unsupportedInterfaceConstruct` («Interfaces are not
    supported in PseudoLearn») — las interfaces existen (`LANG.TYPES.INTERFACE`); `D1` ya no tiene entrada `interface`
    y el código no aparece en el código del motor salvo en `crates/pseudolearn_syntax/build.rs` y su README.
  - **Fuera de la edición por decisión D-16/D-17 (se conservan):** `unsupportedAbstractConstruct`,
    `unsupportedStaticConstruct`, `unsupportedProtectedConstruct`, `unsupportedExceptionConstruct`.
  - **Pendiente de otra fase:** `nativeTasksUnsupported` (PG-N.13).
  - **Reglas semánticas legítimas (no son restricciones de combinación):** `recordCannotBeWritten`,
    `invalidArrayReturnType`, `arrayCannotBeUsedAsValue`, `multipleInheritanceNotSupported`, `nestedClassNotSupported`,
    `subroutineInsideClass`, `classInsideAlgorithm`, `classInsideSubroutine`, `interfaceInsideAlgorithm`,
    `subroutineInsideAlgorithm`, `subroutineInsideSubroutine`, `unsupportedStructuredConstruct`, `duplicateConstructor`,
    `constructorVisibilityNotAllowed`, `constructorReturnTypeNotAllowed`, los de pureza, tareas, limpieza y constantes.
  - **Combinaciones dudosas que se reportan a la persona (no se implementan sin decisión):** `elementTypeNotComparable`
    con `Vector<Registro>` (la igualdad de registros existe por `LANG.TYPES.RECORD#R4`), `invalidDictionaryKeyType` con
    claves de registro o enumerado, `snapshotNotSupported` según el tipo afectado.
- `PL-H-12` Los cuatro códigos de registro solo se citan fuera de `docs/` en: `diag/diag.catalog.md`,
  `cases/catalogs.json`, `lang/lang.types.record.md`, `crates/pseudolearn_semantic/README.md`,
  `crates/pseudolearn_semantic/src/{local_registry.rs,unit_resolver.rs,class_registry.rs}` y
  `crates/pseudolearn_semantic/tests/type_declarations_tests.rs` (líneas 161–180). Ni la app ni la extensión los citan.

**Motor: dónde nacen las restricciones**

- `PL-H-13` `crates/pseudolearn_semantic/src/local_registry.rs` (268 líneas): `check_record_parameter` emite
  `RecordPassedByReference`, `RecordArrayElementNotSupported` (parámetro con corchetes) y
  `RecordMemberSignatureNotSupported` (si la unidad es `Method`/`Constructor` **y el tipo no es una variante
  incorporada**: `variant_types::get(...).is_none()`); `declared_name` emite `RecordArrayElementNotSupported` para
  `Dimension` de registros (≈ línea 256).
- `PL-H-14` `crates/pseudolearn_semantic/src/unit_resolver.rs` (183 líneas) `check_member_result`: mismo criterio para
  el resultado de métodos. `crates/pseudolearn_semantic/src/class_registry.rs` (137 líneas): un campo de clase de tipo
  `Type::Record` produce `RecordClassFieldNotSupported` y **no se añade** (`continue`).
- `PL-H-15` Representación de registros (README de `semantic` y `lowering`): `Type::Record` no es valor de la RI;
  semantic calcula hojas (`HirRecord.leaf_types`, `leaf_names`, `offset`, `width`) y crea un `HirLocal` sintético por
  hoja (`record_locals`, nombre `p.x`). Lowering (`record_values::lower_range`) entrega la lista de hojas a cada
  consumidor; argumentos = un argumento por hoja; resultado = una `cell<hoja>` por hoja (`FunctionBuilder.result_cells`)
  leída con `cell.load_raw`. **Las variantes incorporadas son también `Type::Record`** con disposición de abi y ya
  viajan en firmas de métodos (excepción de `PL-H-13`).
- `PL-H-16` README de `pseudolearn_abi`: `RecordLayout` (hojas con banco escalar/referencias y desplazamiento por banco;
  máximo de hojas = operando de 16 bits) «es el dato compartido que usarán la incrustación en objetos y vectores sin
  recalcular desplazamientos en cada motor». Arreglos: cabecera común; `status_flags` guarda `ValueKind` en bits 0–7
  (un solo tipo de elemento), rango, mapa de definición de enteros. Objetos: `shape_tag = 3 + class_id`, campos heredados
  antes que propios, mapa estático de desplazamientos de referencias por clase.
- `PL-H-17` RI (`ir/ir.instructions.md`): `array.new <tipo>, %d: i64... -> array<T, n>`, `array.load %a, %i... -> T`,
  `array.store %a, %i..., %v` (≈ líneas 917–959). Las colecciones usan `collection.*` con «hojas escalares antes de
  referencias», disposición canónica en declaraciones sintéticas y verificador que exige «claves, hojas y ordinales
  exactos» (README de `ir` y `bytecode`).
- `PL-H-18` Paso por referencia (README de `lowering`): «Los argumentos por referencia se traducen como celdas de local,
  campo o elemento y se validan antes» de llamar; `lowering/src/parameter_passing.rs` (10 líneas), `places.rs` (53).
- `PL-H-19` Módulos: `crates/pseudolearn_semantic/src/module_symbols.rs` define `SymbolKind { Function, Class }` y solo
  recoge `NodeKind::ClassUnit` y `NodeKind::Subprogram`; `module_exports.rs` (232 líneas) calcula exportaciones;
  `module_imports.rs` (113) enlaza; `type_scope.rs` define `TypeScope { enums, records, constants }` por unidad. Las
  interfaces tampoco se exportan.
- `PL-H-20` Genéricos: `generic_registry.rs` recoge `RecordUnit | Subprogram` con `TypeParameters`; las plantillas
  «son privadas de la unidad y viajan con `UnitScope`»; `generic_state.rs` fija `INSTANCE_LIMIT = 64`; la clave de caché
  de instancia es `(unidad, nodo de la plantilla, argumentos canónicos)`; `generic_opaque`/`generic_discard` comprueban
  cada plantilla una vez por pasada con parámetros opacos y descartan esa instancia de definición conservando sus
  diagnósticos; `generic_labels` nombra `nombre<tipos>`. Pruebas: `crates/pseudolearn_semantic/tests/generic_instances.rs`.
- `PL-H-21` README de `semantic`, «Pendientes declarados»: registros en arreglos/campos/firmas de miembros/por
  referencia; exportación de constantes, enumerados y registros; «los genéricos de clases y de variantes definidas por
  el usuario no forman parte de esta edición (el parser rechaza `<` tras el nombre de una clase); los genéricos no cruzan
  módulos…; la plantilla sin instanciar no se comprueba con tipos concretos; el servicio de lenguaje ve una instancia por
  cada uso, sin símbolo propio para la plantilla»; y «transportar los límites de ámbito a los mapas de estado y raíces de
  ejecución».
- `PL-H-22` Raíces en la VM: `crates/pseudolearn_bytecode/src/roots.rs::expire` (desde `6a7624bf`, 2026-10-25) retira de
  cada mapa de raíces los registros nombrados cuyo intervalo de visibilidad no contiene el tramo de la instrucción y que
  tampoco están vivos por flujo (`root_liveness.rs`). README de `bytecode`: «La generación de raíces elimina vínculos
  cerrados que tampoco siguen vivos por flujo». README de `codegen`: la pila de raíces nativa usa vivacidad por flujo
  (`liveness`), no intervalos léxicos. La afirmación de `PL-H-21` sobre raíces puede estar **desactualizada** (`PL-V-12`).
- `PL-H-23` Servicio (`crates/pseudolearn_service/src/`): `symbol_index.rs`, `symbol_queries.rs`, `hover.rs`,
  `navigation.rs`, `lsp_rename.rs`, `lsp_project_rename.rs`, `lsp_semantic_tokens.rs`, `workspace_invalidation.rs`.
  Contratos: `TOOL.SERVICE.HOVER` (R1–R4), `TOOL.SERVICE.NAVIGATION` (R1–R4), `TOOL.SERVICE.INCREMENTAL` (R1–R4).
- `PL-H-24` Sintaxis: `crates/pseudolearn_syntax/build.rs` genera el reconocimiento de `D1` de
  `LANG.CLASS.OUT-OF-SCOPE` (incluye `UnsupportedGenericsConstruct` y cita `UnsupportedInterfaceConstruct`).
- `PL-H-25` Nativo: `crates/pseudolearn_codegen/src/instruction_dispatch.rs:43` declara `UNSUPPORTED_OPERATIONS`;
  `task_support.rs` lo consulta. Precedente de PG-S: reglas nuevas con vínculo `pendiente` y `resuelve_en: "PG-N.08"`
  en `conformance-aot.yaml`; `see conform --subject aot` informa `pendiente`, no `incumple` (PS-V-13 confirmada en PG-S).

**Consumidores**

- `PL-H-26` App (`apps/pseudolearn_app/README.md`): el diagrama de clases lee `record_unit`, `enum_unit`,
  `interface_unit` y `type_parameters` de la vista pública (`RustValueTypeProjection`, `RustGenericSubprogramBoxes`,
  `ClassBoxKind.genericSubprogram`); declara fuera de alcance «Parámetros genéricos de tipo en clases (el lenguaje no
  los admite)». Matriz de cobertura en `lib/domain/model/diagram/coverage/`; verificador `dart run
  tool/check_syntax_coverage.dart` que lee el inventario de formas de `program_view_kind.rs` y `program_view_tasks.rs`
  del motor y falla con `COV-MISSING-ROW`, `COV-STALE-ROW`, `COV-DUPLICAT…`, `COV-EXTENSION`; contrato
  `API.PROGRAM.VIEW#R13`, escenarios `tool/see_app_syntax_coverage.dart` y `tool/see_app_class_diagram.dart`.
- `PL-H-27` Extensión (`apps/pseudolearn_vscode/README.md`): TypeScript no implementa parser ni semántica; la gramática
  TextMate `media/pseudolearn.tmLanguage.json` se **genera** desde las definiciones léxicas y el vocabulario exportado
  y lleva el hash de la exportación; `pnpm build` comprueba que esté vigente. Tokens semánticos `full` vía LSP del motor.
- `PL-H-28` Fichas de ayuda: PG-S registró sus fichas como `help.pgs01.*` en `tool/tool.service.catalog.md` con anclas a
  la regla y al caso ejecutable; `export.json` publica `resources.helpCatalog`.
- `PL-H-29` Comandos (README de cada miembro): corpus `cargo run -p see_cli --bin see -- validate|lock|export|conform`
  desde `packages/pseudolearn_spec`; motor `cargo xtask verify` (verificación completa), `cargo test --workspace`,
  `cargo test -p <crate>`; capas: `cargo run --manifest-path packages/pseudolearn_rust_checks/Cargo.toml -p
  pseudolearn_check_command -- layers packages/pseudolearn_engine` desde la raíz.
- `PL-H-30` `packages/pseudolearn_engine/architecture.yaml` (`limits`): `file_lines: 300`, `function_lines: 40`,
  `positional_parameters: 4`, `nesting_depth: 3`, `public_methods_per_class: 7`; nombres: mínimo 3, cortos permitidos
  `id, io, ir, vm, gc, os`, componentes prohibidos (`ctx, cfg, env, expr, stmt, decl, tok, idx, len, pos, cnt, num, buf,
  ptr, ref, val, msg, err, res, ret, args, params, attrs, tmp, temp, aux, data, info, item, obj, …`), archivos
  prohibidos `utils, helpers, common, misc`. Capas: `semantic` puede importar `abi, source, project, diagnostics,
  lexicon, syntax`; `lowering`: `source, semantic, ir, diagnostics`; `ir`: `source, abi`; `bytecode`: `ir, source`;
  `vm`: `bytecode, runtime, library, diagnostics, vm_dispatch`; `service`: `source, diagnostics, lexicon, syntax,
  semantic, project`; `codegen`: `ir, diagnostics, aot_rt`.

### 1.3 Hipótesis por verificar (no usar como hecho)

| ID | Hipótesis | Comando o lectura que la confirma | Se consume en |
|---|---|---|---|
| PL-V-01 | Retirar la comprobación de `PL-H-13`/`PL-H-14` para métodos y constructores basta para que un registro de usuario viaje como parámetro y resultado de miembros, porque lowering ya transporta variantes (también `Type::Record`) por hojas y celdas de resultado | Leer `lowering/src/functions.rs`, `expressions_objects.rs`, `constructor_flow.rs`, `dispatch_targets.rs` y cómo arman argumentos de `call.virtual`; prueba mínima en `PG-L.01.04` con despacho virtual y constructor de superclase | L.01 |
| PL-V-02 | Un campo de clase de tipo registro puede representarse como un campo sintético por hoja (`campo.hoja`) en `HirClass`, con el mapa de referencias por clase y la densidad (`class_density.rs`) sin cambios de RI | Leer `class_registry.rs::add_field`, `semantic/src/hir.rs` (`HirClass`/campos), `lowering/src/classes.rs`, `class_density.rs`, `abi` (mapa de referencias por clase) | L.01 |
| PL-V-03 | La RI no admite hoy elementos de arreglo de más de una palabra; `array<T,n>` exige un `T` de la RI y no hay instrucción de acceso por hoja | Leer `ir/src/operation.rs`, `ir/src/types*.rs`, verificador de arreglos (`bytecode/src/verify_array_types.rs`) y `IR.INSTRUCTIONS` | L.01 (DL-02) |
| PL-V-04 | Las colecciones ya resuelven elementos multihoja (metadatos tipados de hojas, `collection_layouts.rs` en semantic y `collection_metadata.rs` en bytecode) y esa disposición es reutilizable para arreglos | Leer esos archivos y `vm/src/machine/` de colecciones | L.01 (DL-02) |
| PL-V-05 | El paso por referencia admite una celda por hoja (local, campo y elemento) sin instrucción nueva, también en tipos función (`SubProceso(P Por Referencia)`) e `indirect_calls` | Leer `lowering/src/parameter_passing.rs`, `places.rs`, `address_taken.rs`, `indirect_calls.rs`, `semantic/src/argument_checker.rs` | L.01 |
| PL-V-06 | `Vector<Registro>`, `Diccionario<K,Registro>`, `Opcional<Registro>`, `Resultado<Registro,E>`, mensajes de canal y resultados de tarea con registros ya funcionan | `grep -n` de casos con registros en `lang.types.{vector,dictionary,relations}.md`, `lang.task.*.md`; programa de prueba por posición con `see` o test de API | L.00.02, L.01 |
| PL-V-07 | Semantic analiza `Publico`/`Privado` delante de enumerados, registros, constantes e interfaces y los ignora sin diagnóstico (o con uno que hay que retirar) | `grep -n "PublicVisibility\|PrivateVisibility" crates/pseudolearn_semantic/src/*.rs`; caso mínimo en proyecto | L.02 |
| PL-V-08 | El modo de uso de constantes (plegado a `Literal`) funciona igual para una constante importada si el evaluador puede consultar la tabla de la unidad dueña | Leer `constant_registry.rs`, `constant_evaluator.rs`, `constant_use.rs` y `session_units.rs` | L.02 |
| PL-V-09 | La comprobación de definición con parámetros opacos ya se ejecuta para plantillas **sin ninguna instancia**; la frase de `PL-H-21` «la plantilla sin instanciar no se comprueba con tipos concretos» describe solo que no hay tipos concretos que probar | Caso existente de `LANG.TYPES.GENERIC` con error en plantilla sin uso (buscar en sus 20 casos); `generic_opaque.rs` | L.05 |
| PL-V-10 | La clave de instancia `(unidad, nodo, argumentos)` usa la unidad **de la plantilla**, de modo que dos módulos consumidores con los mismos argumentos comparten instancia | Leer `generic_functions.rs`, `generic_records.rs`, `generic_state.rs` | L.03 |
| PL-V-11 | El parser rechaza `<` tras el nombre de una clase con un diagnóstico sintáctico concreto (cuál) | `grep -rn "ClassUnit" crates/pseudolearn_syntax/src | head`; caso mínimo con `pseudo check` | L.04 |
| PL-V-12 | La VM ya excluye de las raíces los vínculos cuyo ámbito terminó (`roots::expire`), de modo que un objeto creado en un bloque es recuperable al salir; la pieza que falta es la regla del corpus, la prueba y la frase obsoleta del README | Experimento `PL-E02` y lectura de `bytecode/src/compile*` (dónde se construye `visibility`) | L.06 |
| PL-V-13 | La vista de estado (`API.STATE.QUERY`, inspección y traza) no muestra vínculos de ámbitos terminados | README de `vm` («La inspección filtra nombres por el intervalo léxico actual»); prueba con `api` | L.06 |
| PL-V-14 | La pila de raíces nativa (vivacidad por flujo) puede liberar antes que la VM (vínculo en ámbito sin usos futuros), lo que haría observable una diferencia de `cellLimitExceeded` entre sujetos | README de `codegen` (`liveness`, `ParameterRoots`), `ENG.LIMITS#R2`, contraste `PL-E02` con `--subject aot` si se ejecuta | L.06, riesgo PL-K-04 |
| PL-V-15 | `cases/catalogs.json` es fuente y `diag.catalog.md`/`D1` se validan contra ella (o al revés) | README de `pseudolearn_spec` y `see_validation` (`grep -rn "catalogs.json" packages/pseudolearn_spec/crates`) | L.00, L.01, L.04 |
| PL-V-16 | `DiagnosticCode` es un enum generado desde el catálogo: retirar un código rompe la compilación de cada uso, lo que sirve de inventario mecánico | `grep -rn "DiagnosticCode" crates/pseudolearn_diagnostics/build.rs` | L.01, L.04 |
| PL-V-17 | Añadir parámetros de tipo a `classUnit` hace aparecer una forma nueva en `program_view_kind.rs` y la matriz de la app falla con `COV-MISSING-ROW` hasta añadir la fila | `dart run tool/check_syntax_coverage.dart` tras L.04 | L.07 |

## 2. Lectura realizada y lectura de entrada obligatoria

### 2.1 Fuentes consultadas para redactar este plan

- [x] `AGENTS.md` (§1–§10) y [plan general](plan-ejecucion-proposito-general.md) §0–§6, incluida §4.13 y §5.
- [x] [Análisis del 2026-11-02](analisis-lenguaje-completo-sin-simulacion.md): §A.8.1, §A.8.3, §B.0.0, §B.3a, §B.5.
- [x] [Plan de PG-S](fase-pg-s-plan-ejecucion.md) §0–§11 (formato, precedentes de fichas, vínculos `pendiente`).
- [x] Hoja de ruta: riesgos K-01–K-19 y E-PG-03/E-PG-04.
- [x] Corpus (texto de reglas): `LANG.TYPES.{RECORD,GENERIC,VECTOR,ENUM,INTERFACE,CLASS,ARRAY,RELATIONS}`,
  `LANG.DECL.CONSTANT`, `LANG.MODULE.{IMPORT,MODEL}`, `LANG.SUBPROGRAM.{SCOPE,BY-REFERENCE}`,
  `LANG.CLASS.OUT-OF-SCOPE`, `LANG.SYNTAX.GRAMMAR` (producciones de unidades y tipos), `MEM.*`, `ENG.LIMITS`,
  `ENG.TASK.MEMORY`, `TOOL.SERVICE.{NAVIGATION,HOVER,INCREMENTAL}`, `API.PROJECT.LOCK`, `ENG.STATE.INCREMENTAL`;
  inventario de `diag.catalog.md`.
- [x] README del motor (§1–§4 parcial), `architecture.yaml` (capas y límites) y README de `semantic` (íntegro hasta
  línea 300), `lowering`, `ir`, `abi`, `bytecode`, `vm`, `codegen` (fragmentos por búsqueda).
- [x] README de la app (§ diagrama de clases y matriz de cobertura) y de la extensión (gramática y LSP).
- [x] Código leído parcialmente: `local_registry.rs`, `unit_resolver.rs`, `class_registry.rs`, `module_symbols.rs`,
  `generic_registry.rs`, `type_scope.rs`, `bytecode/src/roots.rs`, `root_liveness.rs`.
- [ ] **No leído y por leer antes de la tarea que lo usa** (no suponer su contenido): `lang.types.dictionary.md`,
  `lang.control.switch.md`, `lang.profile.vocabulary.md`, `lang.lexical.keyword.md`, `ir.instructions.md` completo,
  `ir.well-formedness.md`, `api.program.view.md`, `api.state.query.md`, `tool.service.catalog.md`,
  `diag.messages.md`; README de `syntax`, `service`, `api`, `runtime`, `timeline`, `wasm`, `pseudolearn_spec`,
  `pseudolearn_cli`; código de `lowering` (records, classes, parameter_passing), `ir`, `bytecode` (arreglos),
  `vm` (arreglos, objetos), `service` (símbolos), app (`program_view_kind.rs`, cobertura, export Rust/Python).

### 2.2 Antes del primer cambio (tarea `PG-L.00.01`)

1. `git status --short`, `git rev-parse --short HEAD`, `git branch --show-current` (debe ser
   `feature/agregar-ruta-de-especificacion`). Registrar en §11.
2. Releer `AGENTS.md`, el README y el archivo de reglas de cada miembro de §5.
3. Escribir en §11.2, por cada archivo nuevo o modificado de §5, las tres respuestas de `AGENTS.md` §1 (capa, imports
   permitidos y prohibidos, archivo dueño). Si el árbol contradice §5, mandan el árbol y el README (`CONFLICT-REPORT`).
4. **No** se ejecuta la línea base pesada (§10.1). Solo `cargo build -p pseudolearn_api` y `see validate` para saber que
   el árbol compila y el corpus valida antes de editar; si fallan, se registra y se sigue (serán preexistentes).

## 3. Decisiones de diseño

Las decisiones marcadas **Persona** cambian comportamiento observable, fijan sintaxis o amplían la lista literal de
`PG-L.01`–`.07`; el plan propone una elección y **se ejecuta la recomendada solo si la persona la confirma al revisar
`C02`** (precedente de PG-S: «eligiendo siempre la opción recomendada» cuenta como confirmación). Las demás las toma la
IA a cargo y se registran en el README dueño.

| ID | Decisión | Opciones | Criterio | Elección propuesta | Reversión |
|---|---|---|---|---|---|
| DL-01 | Registro como **campo de clase** | (a) incrustar: un campo sintético por hoja (`campo.hoja`, no nombrable), igual que `record_locals` para variables; (b) caja: el campo guarda un objeto oculto copiado al asignar | (a) reutiliza el mapa estático de referencias por clase y la disposición de abi «para la incrustación en objetos» (`PL-H-16`), no asigna memoria por copia ni crea identidades de objeto observables (`MEM.IDENTITY#R1` cuenta todo objeto creado); (b) altera las identidades | **(a)**, sujeto a `PL-V-02` | Si `PL-V-02` falla por la densidad de clases o la herencia, (a) con capa de traducción en lowering; (b) nunca, por `MEM.IDENTITY` |
| DL-02 | Registro como **elemento de arreglo** | (a) arreglo de elementos anchos: cada elemento ocupa las hojas del registro según `RecordLayout`, con acceso por ordinal de hoja (instrucciones **CANDIDATAS** `array.load_leaf`/`array.store_leaf` o extensión de `array.load`/`store` con operando de hoja); (b) arreglos paralelos ocultos, uno por hoja; (c) arreglo de cajas | (b) rompe `MEM.IDENTITY` (N ordinales por un arreglo) y el paso del arreglo completo a parámetros; (c) rompe identidades y añade una asignación por elemento; (a) conserva una identidad, un asa y la regla «arreglo como parámetro comparte elementos» | **(a)**. La forma exacta de la RI la decide `PG-L.01.03` tras `PL-V-03`/`PL-V-04`, reutilizando metadatos de hojas de colecciones si existen | Ninguna alternativa conserva identidad: si (a) resulta inviable, **parar** el sub-punto «arreglos» y reportar (§10.3) |
| DL-03 | Definición por hoja (arreglos y campos) | (a) cada hoja conserva su propio estado de definición: escribir `a[i].x` en un elemento sin valor es válido; leer una hoja sin valor o **copiar** el registro completo con alguna hoja sin valor atrapa `uninitializedVariableRead`; (b) escribir una hoja de un elemento sin valor atrapa | (a) coincide con el contrato vigente de campos y elementos «sin valor conservan los centinelas y las comprobaciones existentes» (README de `lowering`) y con `LANG.TYPES.RECORD#R3` («Leer un campo de un registro sin valor es uninitializedVariableRead») | **(a)** (**Persona**) | (b) como edición oficial de `LANG.TYPES.RECORD#R3` |
| DL-04 | Registro **por referencia** | (a) una celda por hoja hacia el destino (variable, campo de objeto o elemento); el índice se fija una vez al llamar; escrituras visibles de inmediato por cualquier alias (`MEM.VALUE.COPY#R4`, `LANG.SUBPROGRAM.BY-REFERENCE#R1`); (b) celda única a un agregado | (a) usa la representación vigente de celdas de local, campo y elemento (`PL-H-18`) y no exige agregados en la RI | **(a)**, sujeto a `PL-V-05`. Coincidencia exacta de tipo de registro (no hay subtipos de registro) | Si `PL-V-05` falla para tipos función, limitar a llamadas directas y reportar |
| DL-05 | Registros en **firmas de métodos y constructores** | Transporte idéntico al de las variantes incorporadas (argumentos por hoja y celdas de resultado) | Ya probado para variantes (`PL-H-13`, `PL-H-15`) | Retirar la comprobación; pruebas de despacho virtual, sobrescritura con firma de registro, constructor de superclase y realización de interfaz con registros | Si `PL-V-01` falla en `call.virtual`, adaptar `dispatch_targets.rs` antes de retirar el diagnóstico |
| DL-06 | Visibilidad y exportación de **constantes, enumerados y registros** | (a) mismo contrato que subprogramas y clases: privados salvo `Publico`, importación **por símbolo** (`Importar paquete.modulo.Nombre [Como Alias]`), reexportación con `Exportar`; los miembros del enumerado se cualifican con el nombre local del tipo; la constante importada se pliega como literal; (b) además acceso por alias de módulo (`m.Constante`, `m.Color.Rojo`) | (a) extiende `LANG.MODULE.IMPORT#R1`–`R4` sin forma nueva («sus clases se importan por símbolo»); (b) amplía la resolución de alias de módulo, hoy limitada a llamadas | **(a)** | (b) solo por petición de la persona |
| DL-07 | **Interfaces** exportables | (a) incluirlas en DL-06; (b) dejarlas privadas | Sin interfaces exportables, una biblioteca no puede ofrecer genéricos restringidos `T: I` ni clases que otros realicen (`PG-L.03`), y el objetivo de la fase es «sin diagnósticos de no soportado». Excede la lista literal de `PG-L.02` | **(a)** (**Persona**: ampliación de alcance) | (b) y declarar el hueco en el README de `semantic` |
| DL-08 | **Genéricos entre módulos** (`PG-L.03`) | Plantilla pública exportable (función, registro y, tras L.04, clase, interfaz y variante); se instancia en el consumidor con la clave de la **unidad de la plantilla** (`PL-V-10`): dos consumidores con los mismos argumentos comparten instancia; nombre de instancia calificado por módulo (`paquete.modulo.nombre<tipos>`, **CANDIDATO**) estable para mapas de fuente y AOT; el límite de 64 instancias sigue siendo por programa | Identidad independiente del consumidor y del orden de archivos (`LANG.MODULE.MODEL#R1`) | Elección propuesta. El **lock no cambia**: `API.PROJECT.LOCK` fija digests de archivos y las instancias se derivan de ellos; «identidad estable de instancia en el lock» se acredita con un caso de proyecto bloqueado cuya salida no cambia al reordenar archivos | Si la persona exige registrar instancias en el lock, es edición de `API.PROJECT.LOCK` (fuera de esta propuesta) |
| DL-09 | **Clases e interfaces genéricas** (`PG-L.04`) | Sintaxis **CANDIDATA**: `Clase Caja<T: I> [Hereda De Base<T>] [Realiza J<T>]`, `Interfaz Comparable<T>`; argumentos explícitos al instanciar (`Nuevo Caja<Entero>(...)`, **CANDIDATO**) o inferidos desde el constructor; invariancia; cada instancia es una clase concreta con su `ClassId` (monomorfización, mundo cerrado conservado); métodos con parámetros de tipo propios **excluidos** | La inferencia desde constructores con herencia complica el diagnóstico (`cannotInferTypeArgument`); los argumentos explícitos en `Nuevo` no son ambiguos con una comparación porque siguen a la palabra `Nuevo`. Excluir métodos genéricos propios evita una segunda dimensión de instancias (K-04, `SCOPE-YAGNI`) | **Persona**: confirmar (1) argumentos explícitos obligatorios en `Nuevo` salvo contexto de declaración que los fije, (2) exclusión de métodos con parámetros de tipo propios, (3) invariancia | Inferencia en `Nuevo` como edición posterior si la persona la pide |
| DL-10 | **Variantes genéricas de usuario** (`PG-L.04`) | (a) construcción **nueva** de variante de usuario (no existe ninguna hoy, `PL-H-06`), genérica o no: declaración **CANDIDATA** `Variante Forma<T> … Alternativa Circulo(radio Como Real) … FinVariante`, construcción `Forma.Circulo(2.0)`, patrones `Forma.Circulo(r)` en `Segun` con exhaustividad, disposición con `VariantLayout`; palabras **contextuales** como `Interfaz`; (b) interpretar el punto como «tipos genéricos de usuario como carga de `Opcional`/`Resultado`» (ya posible) y declarar las variantes de usuario fuera de la edición; (c) diferir a una fase nueva | La lista del plan general nombra «variantes genéricas de usuario», pero `LANG.TYPES.RELATIONS#R3` las excluye y la gramática no tiene la forma: es una construcción nueva, no la retirada de una restricción. (a) es la lectura literal y la que cumple «toda construcción se combina»; su coste es gramática, vocabulario, patrones, exhaustividad, vista de app, fichas y diagramas | **Persona obligatoria** (`CONFLICT-REPORT` §9.2-1). Recomendación: **(a)** con palabras contextuales; si la persona elige (b) o (c), `PG-L.04.B` queda «Retirado/Diferido» con su mensaje citado | Según la elección |
| DL-11 | Forma `Generico` y entradas obsoletas | (a) retirar la entrada `generic` de `D1` y los códigos `unsupportedGenericsConstruct` y `unsupportedInterfaceConstruct` (sin emisor, `PL-H-11`) del catálogo, de `cases/catalogs.json`, de `syntax/build.rs` y del README de `syntax`; (b) conservar `Generico` con un mensaje que oriente a `<T>` | Ningún programa válido usa `Generico`; un diagnóstico que afirma «los genéricos no forman parte» es falso tras PG-L y viola el criterio de salida. Las palabras siguen sin ser reservadas | **(a)** (eliminación de raíz, D-19 del análisis); el caso de `R1` que use `Generico` se reescribe como identificador ordinario | (b) si la persona prefiere el diagnóstico pedagógico |
| DL-12 | Comprobación de plantillas sin instanciar (`PG-L.05`) | Extender la comprobación única con parámetros opacos (`generic_opaque`) a clases, interfaces y variantes genéricas y a plantillas públicas que su módulo no instancia | `PL-V-09`: si ya ocurre para funciones y registros, el punto se acredita con casos y se amplía a las formas nuevas | Elección propuesta | — |
| DL-13 | **Símbolo de plantilla** en el servicio | Un símbolo por plantilla (declaración), al que se asocian todos los usos de sus instancias; un símbolo por parámetro de tipo con su restricción; hover sobre un uso muestra la firma de la instancia y la de la plantilla; referencias y renombrado sobre la plantilla abarcan todos los módulos; renombrar `T` solo dentro de su plantilla | `TOOL.SERVICE.NAVIGATION#R1`/`R2` ya exigen identidad entre archivos; hoy cada instancia es un símbolo distinto (`PL-H-21`) | Elección propuesta; los parámetros de tipo entran en `TOOL.SERVICE.HOVER#R1` y `NAVIGATION#R1` como categoría nueva (**CANDIDATA** `parametro de tipo`) | — |
| DL-14 | **Liberación por ámbito** (`PG-L.06`) | Regla observable nueva **CANDIDATA** `MEM.MANAGED.UNOBSERVABLE#R3`: un valor alcanzable solo desde vínculos cuyo ámbito léxico terminó no cuenta para el límite de celdas; casos con presupuesto de celdas bajo: un bucle que crea en su cuerpo objetos de bloque termina `completed` con el mismo presupuesto que una sola iteración necesita; control que retiene los objetos en un vector exterior termina `failed`/`cellLimitExceeded` | Es la única consecuencia observable permitida por `MEM.MANAGED.UNOBSERVABLE#R1`; el esperado se deriva del recuento de celdas de `ENG.LIMITS#R2` y `LANG.TYPES.VECTOR#R3`, no del motor | Elección propuesta. Si `PL-V-12` confirma que la VM ya lo cumple, el código se limita a pruebas y documentación; si `PL-V-14` revela divergencia con AOT, el vínculo `aot` queda `pendiente` con `resuelve_en: "PG-N.05"` | Si la regla no puede derivarse sin fijar el recuento exacto de temporales, formularla solo con objetos de bloque y vector exterior |
| DL-15 | Sujeto nativo | Reglas nuevas o editadas: vínculo `aot` `cumple` si `see conform --subject aot --only <ID>` pasa en el bloque F; en otro caso `pendiente` con `resuelve_en: "PG-N.08"`; cualquier instrucción de RI nueva entra en `UNSUPPORTED_OPERATIONS` y `pseudo build` la rechaza con el diagnóstico existente | `PG-N.08` ya incluye «construcciones de PG-L en código nativo» | Elección propuesta | Paridad nativa inmediata solo con replanificación aprobada |
| DL-16 | Fichas de ayuda | Identidades nuevas `help.pgl0N.*` en `tool/tool.service.catalog.md` (precedente `help.pgs01.*`, `PL-H-28`), una por forma nueva o ampliada: campo/arreglo/parámetro registro, visibilidad de tipos y constantes, importación de tipos, clase genérica, interfaz genérica, variante (si DL-10 = a), parámetro de tipo; es/en con anclas a regla y caso ejecutable | `C09`, K-16, K-17 | Elección propuesta | — |
| DL-17 | Estrategia de verificación (pedido de la persona) | Desarrollo con nivel D (compilación del crate, tests dirigidos por archivo, `see validate`); bloque F con todo lo pesado; ciclo de corrección acotado | Velocidad sin perder `PHASE-GREEN` al cierre | Elección fijada por la persona el 2026-11-05 | — |

## 4. Desglose por punto

Convención: cada tarea es `PG-L.<punto>.<nn>`; las del bloque final son `PG-L.F.<nn>`. Las casillas se marcan al
cumplirse **con evidencia en §11**. Las tareas transversales cuelgan de `PG-L.00` y de los puntos comunes. «Nivel D»
es la comprobación ligera de §7.4; nada de lo marcado «F» se ejecuta antes del bloque final.

### PG-L.00 · Preparación y auditoría (transversal)

- [x] `PG-L.00.01` Entrada (§2.2): estado Git, lectura obligatoria, respuestas de `AGENTS.md` §1 para §5, compilación
  y `see validate` de partida.
- [x] `PG-L.00.02` Auditoría de «no soportado» (criterio de salida de §B.3a): recorrer los 282 códigos de
  `diag.catalog.md` con la búsqueda de `PL-H-11` y además buscar en los README del motor y de los consumidores las
  frases «no soportad», «not supported», «no forma parte», «pendiente declarado». Producir en §11.4 la tabla
  definitiva código → clase (retirar en PG-L / fuera de edición D-16–D-18 / otra fase / regla legítima / dudoso). Los
  «dudosos» de `PL-H-11` se presentan a la persona en el informe final; **no** se implementan.
- [x] `PG-L.00.03` Verificar sin código las hipótesis transversales: `PL-V-06`, `PL-V-15`, `PL-V-16`. Registrar.
- [x] `PG-L.00.04` Registrar en §11 las respuestas de la persona a las decisiones **Persona** (DL-03, DL-07, DL-09,
  DL-10). Una decisión sin respuesta bloquea solo su sub-punto (§10.3).

### PG-L.01 · Registros en todas las posiciones

Orden interno: firmas de miembros (lo más barato) → campos de clase → por referencia → arreglos (lo más caro).

- [x] `PG-L.01.01` Leer íntegros `lang.types.record.md`, `lang.types.array.md`, `lang.subprogram.by-reference.md`,
  `mem.value.copy.md`, `mem.identity.md`, `ir.instructions.md` (familia `array.*` y `cell.*`), y el código de
  `PL-V-01`–`PL-V-05`. Resolver esas cinco hipótesis y registrar.
- [x] `PG-L.01.02` Especificación (texto oficial sobre las mismas identidades): `LANG.TYPES.RECORD#R1` sin las tres
  prohibiciones y sin «privado del módulo» (lo reemplaza la referencia a la visibilidad de `PG-L.02`); `#R3` reescrita:
  parámetro por referencia de registro con alias por hoja (DL-04) y definición por hoja (DL-03); nueva regla `#R5`
  (**CANDIDATA**) para las posiciones nuevas: elemento de arreglo (copia al leer y escribir el elemento completo,
  `a[i].campo` como designador, arreglo pasado como parámetro comparte elementos), campo de clase (copia por valor al
  asignar el campo; `Copiar` de objeto copia el registro incrustado, `MEM.VALUE.COPY#R3` sin cambios para referencias
  internas), parámetro/resultado de método y constructor, por referencia. Ajustar `LANG.TYPES.ARRAY#R1` si menciona el
  tipo de elemento. `IR.INSTRUCTIONS`: instrucciones o forma de operando de DL-02 con firma, tipado y verificación
  (`IR.WELL-FORMEDNESS` si aplica). Retirar del catálogo los cuatro códigos (`diag.catalog.md` y `cases/catalogs.json`
  según `PL-V-15`) y de `DIAG.MESSAGES` si figuran.
- [x] `PG-L.01.03` Casos derivados de la regla (es y en, `origen: derivado`), por posición, cada uno con feliz, infeliz y
  límite: (1) arreglo: `Dimension a[3] Como P`, escribir y leer elementos; aliasing por parámetro arreglo; copia
  independiente al asignar `q <- a[1]` y modificar `q`; `a[i].x <- v` sobre elemento sin valor y lectura de otra hoja
  (`uninitializedVariableRead`); índice fuera de rango (trampa existente); arreglo bidimensional; registro anidado con
  campo de clase dentro del elemento (referencia compartida); registro de un solo campo; (2) campo de clase: lectura,
  escritura de hoja `o.p.x <- 1`, herencia (campo registro en la base usado desde la subclase), `Copiar`, igualdad de
  objetos por identidad sin cambios; (3) firmas de miembros: método que recibe y devuelve registro, sobrescritura,
  constructor con parámetro registro, llamada `Super`, realización de interfaz cuya firma usa registros, valor función
  de un método; (4) por referencia: variable, elemento y campo como destino; dos parámetros al mismo destino
  (`MEM.VALUE.COPY#R4`); tipo distinto → `byReferenceTypeMismatch` o el código vigente de coincidencia exacta (buscarlo);
  índice inválido falla antes de entrar (`LANG.SUBPROGRAM.BY-REFERENCE#R1`). Igualdad `=`/`<>` de elementos y campos.
  Límite de hojas: registro con el máximo de hojas que admite el operando de 16 bits (o el límite vigente que diga la
  regla) como arreglo y como campo. Cada regla nueva o reescrita con al menos un caso (`SPEC-NO-ORPHAN-RULE`).
- [ ] `PG-L.01.04` Tests dirigidos que fallan por ausencia: reescribir las aserciones de
  `semantic/tests/type_declarations_tests.rs` 161–180 (ya no se espera el diagnóstico; se espera HIR válido); pruebas
  de semantic para campos sintéticos y parámetros; pruebas de lowering/RI para la forma de DL-02 y celdas por hoja;
  pruebas de verificador (`bytecode/src/verify_array_types.rs` o el que corresponda) con un caso negativo de ordinal de
  hoja inválido; pruebas de VM de lectura/escritura de hojas con recolección forzada (referencias dentro de elementos
  sobreviven). Nombres en inglés; carpeta espejo.
- [x] `PG-L.01.05` Código, en este orden: (a) `local_registry.rs`/`unit_resolver.rs`: retirar
  `RecordMemberSignatureNotSupported` y `RecordPassedByReference`; (b) `class_registry.rs`: incrustación por hojas
  (DL-01) en un archivo nuevo de responsabilidad única (**CANDIDATO** `class_record_fields.rs`) si `class_registry.rs`
  superaría 300 líneas; acceso `o.p.x` en `record_access.rs`/`postfix_checker.rs` según el árbol; (c) por referencia
  por hojas en `argument_checker.rs` y lowering (`parameter_passing.rs`, `places.rs`, `address_taken.rs`,
  `indirect_calls.rs`); (d) arreglos: tipo y comprobación en semantic, bajada en lowering (archivo nuevo **CANDIDATO**
  `record_arrays.rs`), RI (`operation.rs`, tipado y verificador), bytecode (compilación, verificación, mapas de raíces
  y de definición), VM (ejecución y recolección), abi (disposición si hace falta). `codegen`: añadir las operaciones
  nuevas a `UNSUPPORTED_OPERATIONS` (DL-15). Regenerar con `cargo build`.
- [ ] `PG-L.01.06` Consumidores mínimos del motor: `api` (vista de estado e inspección de elementos y campos registro:
  presentación por hojas con nombres `campo.hoja` o anidada, según el formato vigente de `API.STATE.QUERY` —leerlo—),
  `timeline`, `wasm` solo si un test de nivel D lo exige. La app y la extensión van en `PG-L.07`.
- [ ] `PG-L.01.07` Fichas `help.pgl01.*` (DL-16) en `tool.service.catalog.md` con anclas a `LANG.TYPES.RECORD#R5` y
  a un caso ejecutable.
- [x] `PG-L.01.08` README: `semantic` (retirar el pendiente de registros; documentar DL-01, DL-03, DL-04, DL-05),
  `lowering` (bajada por hojas en campos, arreglos y referencias), `ir` y `bytecode` (forma de DL-02), `vm`, `abi`
  (uso de `RecordLayout` en objetos y arreglos), `codegen` (operaciones no soportadas). Vínculos de conformidad
  `engine` (`cumple` provisional, confirmado en F) y `aot` (DL-15).
- [x] `PG-L.01.09` Nivel D: `cargo test -p pseudolearn_semantic --test type_declarations_tests`, tests nuevos de
  `lowering`, `ir`, `bytecode`, `vm` por archivo; `see validate`. Commit local del punto.

### PG-L.02 · Visibilidad y exportación de constantes, enumerados, registros e interfaces

- [x] `PG-L.02.01` Leer íntegros `lang.module.import.md`, `lang.module.model.md`, `lang.types.enum.md`,
  `lang.decl.constant.md`, `lang.types.interface.md`, `api.project.md`; resolver `PL-V-07` y `PL-V-08`.
- [ ] `PG-L.02.02` Especificación: `LANG.MODULE.IMPORT#R2` («Toda unidad de nivel superior de un módulo —subprograma,
  clase, interfaz, enumerado, registro o constante— es privada salvo `Publico`…»); `#R1` (importación por símbolo de
  tipos y constantes; miembros de enumerado cualificados por el nombre local del tipo; alias de tipo con `Como`);
  `#R3`/`#R4` sin cambio de fondo pero con las nuevas clases de símbolo en colisión y reexportación;
  `LANG.TYPES.ENUM#R1`, `LANG.DECL.CONSTANT#R1`, `LANG.TYPES.RECORD#R1`, `LANG.TYPES.INTERFACE#R1`: sustituir «privado
  del módulo» por la referencia a la visibilidad de módulo. Regla de coherencia **CANDIDATA**: una firma pública
  (subprograma, método público de clase pública, campo público) que nombra un tipo privado del módulo produce un
  diagnóstico nuevo **CANDIDATO** `privateTypeInPublicSignature` — **Persona** si se prefiere permitirlo (decisión
  incluida en DL-06 al revisar `C02`).
- [ ] `PG-L.02.03` Casos de proyecto (sujeto `engine`, operación de proyecto vigente): importar y usar una constante
  (en expresión y en el inicializador de otra constante del consumidor), un enumerado (`Segun` exhaustivo sobre un
  enumerado importado; `Escribir` del miembro), un registro (construcción, campos, igualdad, como parámetro de
  subprograma público), una interfaz (clase del consumidor que la realiza); con alias; reexportación encadenada;
  infeliz: `privateImport`, `privateReexport`, `importNameCollision` entre un tipo importado y una clase local,
  `ambiguousReexport`; límite: enumerado vacío importado, constante de texto de 65 536 bytes importada, ciclo de
  constantes entre módulos (`circularConstantDefinition` con un solo diagnóstico) y de importaciones (`importCycle`).
  Mismos programas en perfil `en`. Un caso de `LANG.MODULE.MODEL#R3`: el prefijo de visibilidad delante de un
  registro en un texto suelto sigue siendo `moduleSyntaxOutsideProject`.
- [ ] `PG-L.02.04` Tests dirigidos: `semantic/tests/project_analysis_tests.rs` (o archivo espejo nuevo
  **CANDIDATO** `module_type_exports_tests.rs`) feliz/infeliz/límite; `module_cycles_tests.rs` si cambian las aristas.
- [x] `PG-L.02.05` Código: `module_symbols.rs` (nuevas variantes de `SymbolKind` para tipos, constantes e interfaces;
  recoger `EnumUnit`, `RecordUnit`, `ConstantDeclaration` de nivel superior e `InterfaceUnit` —nombres de nodo exactos
  por `grep`—); `module_exports.rs` (si supera 300 líneas, dividir por clase de símbolo antes); `module_imports.rs`;
  `type_scope.rs`/`session_units.rs` para que la resolución de tipos y constantes consulte símbolos importados con
  identidad de la unidad dueña; `constant_*` para plegar una constante importada; `type_resolution.rs`.
  Diagnóstico de DL-06 si se confirma.
- [ ] `PG-L.02.06` Servicio: navegación, referencias y renombrado entre archivos para los símbolos nuevos (prueba en
  `service`); completado de tipos importados si `completion_types.rs` filtra por clase de símbolo.
- [ ] `PG-L.02.07` Fichas `help.pgl02.*` (visibilidad de tipos y constantes, importación de tipos).
- [x] `PG-L.02.08` README de `semantic` (retirar pendiente de exportación; documentar DL-06/DL-07) y de `service` si
  cambió. Nivel D: tests dirigidos de `semantic` y `service`; `see validate`. Commit local.

### PG-L.04 · Clases genéricas, interfaces genéricas y variantes genéricas de usuario

Se ejecuta antes que `PG-L.03` porque las plantillas exportables incluyen clases, interfaces y variantes. Se divide en
`A` (clases e interfaces genéricas) y `B` (variantes de usuario, solo si DL-10 = a).

- [ ] `PG-L.04.01` Leer `lang.syntax.grammar.md` (producciones de unidades, tipos, patrones y vocabulario),
  `lang.profile.vocabulary.md`, `lang.lexical.keyword.md`, `lang.class.*.md`, `lang.control.switch.md`,
  `lang.types.relations.md` íntegros, README de `syntax` y `lexicon`. Resolver `PL-V-11`.
- [ ] `PG-L.04.A1` Especificación: `LANG.SYNTAX.GRAMMAR` (`classUnit` e `interfaceUnit` con `[ typeParameters ]`;
  `type` ya admite `identifier, [ typeArguments ]`; `instantiation` con argumentos de tipo según DL-09);
  `LANG.TYPES.GENERIC#R1` reescrita: parámetros de tipo en registros, subprogramas, clases e interfaces (y variantes si
  DL-10 = a); instanciación de clases; herencia de una base genérica con argumentos (`Hereda De Base<T>`); realización
  de interfaces genéricas (`Realiza Comparable<T>`); invariancia; métodos con parámetros propios excluidos;
  monomorfización con una clase concreta por instancia, desvirtualización y slots por instancia; el límite de 64
  cuenta instancias de clase. Si la regla supera una extensión razonable, añadir `#R2` (clases e interfaces) y `#R3`
  (variantes) como identidades nuevas dentro de la misma especificación. `LANG.CLASS.OUT-OF-SCOPE#R1` sin «genéricos de
  clases» y sin la entrada `generic` de `D1` (DL-11); `LANG.TYPES.INTERFACE#R1`/`R3` (interfaces genéricas y
  restricción `T: I<U>`). Catálogo: retirar `unsupportedGenericsConstruct` y `unsupportedInterfaceConstruct`.
- [ ] `PG-L.04.A2` Casos: clase genérica con campo `T`, constructor y métodos que usan `T`; dos instancias
  (`Caja<Entero>`, `Caja<Cadena>`) independientes; subclase genérica de base genérica; subclase concreta de
  `Base<Entero>`; despacho virtual entre instancias; interfaz genérica realizada por una clase concreta y por una
  genérica; restricción `T: Comparable<T>` (si DL-09 la admite); clase genérica con campo registro genérico (cruza con
  L.01); `Vector<Caja<Entero>>`; infeliz: `typeArgumentCountMismatch` en `Nuevo` y en tipos, operación no permitida
  sobre `T` opaco en un método (error en la definición sin instancias), argumento que no realiza la restricción,
  asignación entre instancias distintas (`incompatibleAssignment` o el código vigente), herencia cíclica a través de
  argumentos; límite: 64 instancias exactas válidas y la 65.ª con `genericInstanceLimitExceeded`; recursión
  polimórfica expansiva en una clase. El caso C de `LANG.CLASS.OUT-OF-SCOPE` que usa `Generico` se reescribe como
  identificador ordinario.
- [ ] `PG-L.04.A3` Tests dirigidos: sintaxis (árbol con `TypeParameters` en clases e interfaces; recuperación ante
  `<` sin cerrar), semantic (`generic_instances.rs` ampliado o archivo espejo nuevo **CANDIDATO**
  `generic_classes_tests.rs`), lowering (una clase por instancia, nombres `Caja<Entero>`).
- [ ] `PG-L.04.A4` Código: `syntax` (gramática generada o parser manual según el README de `syntax`; regenerar);
  `semantic`: `generic_registry.rs` (recoger `ClassUnit` e `InterfaceUnit`), archivo nuevo **CANDIDATO**
  `generic_classes.rs` (instanciación de clase: campos, métodos, constructor, jerarquía y slots por instancia),
  `hierarchy.rs`, `interface_*` para interfaces genéricas, `generic_labels.rs`, `type_resolution.rs`,
  `expressions_objects`/instanciación. `syntax/build.rs` sin la entrada `generic`. Lowering sin cambios si `PL-H-15`
  se mantiene («los genéricos no llegan a lowering»).
- [ ] `PG-L.04.B1` (solo DL-10 = a) Especificación de la variante de usuario: identidad nueva **CANDIDATA**
  `LANG.TYPES.VARIANT` en `lang/lang.types.variant.md`, estable 1.0.0, sujetos `engine` y `aot`: declaración (al menos
  una alternativa, nombres únicos, cargas con nombre y tipo, genérica con `<T>`), construcción cualificada, patrones en
  `Segun` con exhaustividad y `De Otro Modo`, copia por valor, igualdad (decidir: misma alternativa y cargas iguales,
  como registros), sin `Escribir` directo, sin paso por referencia de la carga, disposición por `VariantLayout`,
  límite `variantLayoutLimit`. Gramática (`variantUnit`, `variantPattern` ampliado), vocabulario contextual es/en
  (**CANDIDATOS** `Variante`/`FinVariante`/`Alternativa` y `variant`/`endVariant`/`case`) **no reservados**, con caso que
  demuestre que un identificador `Variante` sigue siendo válido (K-02). `LANG.TYPES.RELATIONS#R3` sin la exclusión de
  tipos genéricos de usuario. Diagnósticos nuevos solo si ningún código vigente sirve (buscar antes en el catálogo:
  `nonExhaustiveSwitch`, `duplicateSwitchCaseLabel`, `incompatibleVariantConstructor`, `variantRequiresPattern`).
- [ ] `PG-L.04.B2` Casos: variante no genérica y genérica; exhaustividad completa e incompleta (`nonExhaustiveSwitch`
  con alternativas faltantes en orden); patrón con vínculo inmutable; variante como campo de clase, elemento de
  arreglo y de vector, parámetro y resultado de método (cruza con L.01); variante exportada (cruza con L.02/L.03);
  variante vacía (decidir: inválida con diagnóstico, como `recordWithoutFields`); alternativa sin carga; límite de
  disposición; perfiles es/en.
- [ ] `PG-L.04.B3` Tests y código: `syntax`, `lexicon` (vocabulario contextual generado), `semantic` (registro de
  variantes de usuario reutilizando `variant_model.rs`, `variant_types.rs`, `variant_patterns.rs`,
  `switch_coverage.rs`), `lowering` (`variant_values.rs`, `statements_variant_match.rs`): reutilizar la disposición de
  abi existente; ninguna instrucción de RI nueva salvo que `PL-H-15` se desmienta.
- [ ] `PG-L.04.05` Fichas `help.pgl04.*` (clase genérica, interfaz genérica, parámetro de tipo, variante y alternativa).
- [ ] `PG-L.04.06` README: `semantic` (retirar el límite asumido; documentar DL-09/DL-10/DL-11), `syntax`, `lexicon`,
  `lowering` si cambió. Nivel D: tests dirigidos de `syntax`, `semantic`, `lowering`; `see validate`. Commit local.

### PG-L.05 · Comprobación de plantillas sin instanciar y símbolo de plantilla en el servicio

- [ ] `PG-L.05.01` Resolver `PL-V-09`. Leer `tool.service.hover.md`, `tool.service.navigation.md`,
  `tool.lsp.capabilities.md` y los archivos de servicio de `PL-H-23`.
- [ ] `PG-L.05.02` Especificación: `LANG.TYPES.GENERIC` (comprobación de definición explícita para toda plantilla,
  incluidas clases, interfaces, variantes y plantillas públicas no usadas por su módulo); `TOOL.SERVICE.HOVER#R1` y
  `TOOL.SERVICE.NAVIGATION#R1`/`R2`/`R4` con la categoría «parámetro de tipo» y la regla de DL-13 (usos de instancias
  se atribuyen a la plantilla).
- [ ] `PG-L.05.03` Casos: plantilla de función, registro y clase sin ningún uso con error en la definición
  (diagnóstico presente, ninguna instancia generada); servicio: hover sobre la plantilla, sobre un uso instanciado
  (muestra instancia y plantilla), sobre `T`; referencias desde la plantilla devuelven usos en dos módulos; renombrar la
  plantilla edita todos los módulos; renombrar `T` no toca un homónimo fuera de la plantilla (K-17); resaltado de
  documento lectura/escritura.
- [ ] `PG-L.05.04` Tests y código: `service` (`symbol_index.rs`, `symbol_queries.rs`, `hover.rs`, `navigation.rs`,
  `lsp_rename.rs`, `lsp_project_rename.rs`, `lsp_semantic_tokens.rs` para tipo de token de parámetro de tipo);
  `semantic` (`service_collection.rs`/`service_model.rs`: ocurrencias de instancias apuntan al símbolo de plantilla;
  ocurrencias de parámetros de tipo).
- [ ] `PG-L.05.05` README de `service` y `semantic` (retirar el pendiente). Nivel D: tests dirigidos de `service`;
  `see validate`. Commit local.

### PG-L.03 · Genéricos exportables entre módulos

- [ ] `PG-L.03.01` Resolver `PL-V-10`. Leer `api.project.lock.md`, `tool.service.incremental.md`,
  `tool.service.workspace.md`, `eng.state.incremental.md`.
- [ ] `PG-L.03.02` Especificación: `LANG.TYPES.GENERIC` (plantillas públicas exportables; instanciación en el
  consumidor con identidad de la plantilla; nombre de instancia calificado; límite por programa) y
  `LANG.MODULE.IMPORT#R1`/`R4` (importar y reexportar plantillas). Caso de lock según DL-08: la salida no cambia al
  reordenar archivos ni al reconstruir el lock.
- [ ] `PG-L.03.03` Casos de proyecto: biblioteca que exporta función, registro, clase, interfaz (y variante) genéricos;
  dos módulos consumidores instancian `Par<Entero>` y comparten instancia (observable: igualdad de registros entre
  valores producidos por ambos módulos y una sola entrada en la lista de instancias si la API la expone); restricción
  con interfaz exportada; infeliz: plantilla privada importada (`privateImport`), argumento que no cumple una
  restricción definida en otro paquete, límite de 64 instancias sumando módulos; límite: plantilla reexportada dos
  veces, homónimos genéricos en paquetes distintos bajo alias.
- [ ] `PG-L.03.04` Tests: semantic (proyecto), service (invalidación incremental: editar el cuerpo de la plantilla
  marca afectados a los consumidores que la instancian y no a los demás, `TOOL.SERVICE.INCREMENTAL#R2`).
- [ ] `PG-L.03.05` Código: `generic_registry.rs` (plantillas en exportaciones), `module_exports.rs`/`module_imports.rs`
  (clase de símbolo plantilla), `generic_functions.rs`/`generic_records.rs`/`generic_classes.rs` (instanciar con
  la unidad de la plantilla y cambiar de unidad con `switch_unit` mientras se comprueba el cuerpo), `generic_labels.rs`
  (calificación), servicio (`workspace_invalidation.rs`).
- [ ] `PG-L.03.06` Fichas (ampliar `help.pgl02.*`/`help.pgl04.*` con importación de plantillas). README de `semantic`
  (retirar «los genéricos no cruzan módulos») y `service`. Nivel D. Commit local.

### PG-L.06 · Liberación de memoria por ámbito de bloque

- [ ] `PG-L.06.01` Resolver `PL-V-12`, `PL-V-13` y `PL-V-14` leyendo el código (sin campaña). Leer
  `mem.managed.unobservable.md`, `eng.limits.md`, `api.state.query.md`, `eng.trace.events.md`.
- [x] `PG-L.06.02` Especificación: regla de DL-14 en `MEM.MANAGED.UNOBSERVABLE` y, si `PL-V-13` lo exige, regla de
  vista de estado (un vínculo fuera de ámbito no aparece en el estado de un evento posterior a su cierre) en
  `API.STATE.QUERY`.
- [x] `PG-L.06.03` Casos con presupuesto de celdas explícito (operación `execute` con límites del anfitrión, como los
  casos vigentes de `ENG.LIMITS`): bucle `Para` de N iteraciones que en su cuerpo crea un vector de k elementos;
  presupuesto = coste derivado de una iteración más el del programa base; espera `completed`. Control: mismo programa
  que agrega cada vector a un vector exterior; espera `failed` con `cellLimitExceeded`. Variante con objeto en una rama
  `Si` y bucle posterior que asigna. Variante con recolección forzada en cada asignación (`gc_stress`) y salida
  idéntica (`MEM.MANAGED.UNOBSERVABLE#R2`). Límite: presupuesto exacto (cabe) y presupuesto menos una celda (falla).
  El recuento de celdas de cada caso se escribe en el campo de justificación del caso, derivado de `ENG.LIMITS#R2`,
  `LANG.TYPES.VECTOR#R3` y `LANG.TYPES.CLASS`.
- [ ] `PG-L.06.04` Tests: `bytecode` (mapa de raíces sin el registro de un vínculo cerrado, con un caso negativo que
  elimina `expire` y debe fallar), `vm`/`api` (ejecución con límite de celdas).
- [x] `PG-L.06.05` Código: solo si `PL-V-12` o `PL-V-13` se desmienten (p. ej. límites de ámbito que no llegan a
  `visibility` para vínculos de bloque o a la inspección). Lowering conserva los orígenes con intervalo léxico
  (README de `lowering`); `bytecode/src/compile*` y `roots.rs`.
- [x] `PG-L.06.06` README de `semantic` (retirar el pendiente de ámbito), `bytecode` y `vm` si cambian; vínculo `aot`
  según DL-14. Nivel D. Commit local.

### PG-L.07 · App y extensión: diagramas, traza, ayuda y resaltado

- [ ] `PG-L.07.01` Leer el README de la app (secciones de vista pública, diagrama de clases, matriz de cobertura,
  traza/estado, exportación Rust/Python), `architecture.yaml` de la app, `api.program.view.md` (R5–R14) y el README de
  la extensión (gramática, LSP, tokens semánticos). Resolver `PL-V-17`.
- [ ] `PG-L.07.02` Motor/API de vista pública: nuevas formas en `program_view_kind.rs` (parámetros de tipo en clases e
  interfaces, variante de usuario, alternativa, patrón cualificado, visibilidad de tipos) con su papel; atributos de la
  vista para campos registro de clase y elementos registro (`API.PROGRAM.VIEW` edición oficial si cambia el contrato).
- [ ] `PG-L.07.03` App, diagrama de clases: caja de clase genérica con `<T: I>` en la cabecera; relación de herencia
  hacia `Base<T>` rotulada con los argumentos; realización de interfaz genérica; filas de campo registro
  `nombre: Registro`; caja «variant» con una fila por alternativa (si DL-10 = a); retirar la frase «Parámetros genéricos
  de tipo en clases (el lenguaje no los admite)» del README. Pruebas en los archivos espejo citados en `PL-H-26`.
- [ ] `PG-L.07.04` App, ordinograma/estructograma/estructura: `Segun` sobre variante de usuario con patrones
  cualificados; filas nuevas de la matriz de cobertura con celdas `exact` y ficha `CoverageCell.help` existente;
  `check_syntax_coverage` sin `COV-*`; ninguna celda nueva en «no soportado».
- [ ] `PG-L.07.05` App, traza y estado: tabla de traza y vista de estado muestran elementos y campos registro por
  hojas con el formato que fije `API.STATE.QUERY`; variables de bloque desaparecen tras el cierre del ámbito
  (`PG-L.06`). Exportación Rust/Python: equivalente o «sin equivalente» rotulado para clases genéricas, variantes de
  usuario y arreglos de registros (K-19, precedente PS-K-05).
- [ ] `PG-L.07.06` Extensión: regenerar la gramática TextMate desde el vocabulario exportado (palabras contextuales
  nuevas, si las hay) con la orden del README; tokens semánticos de parámetro de tipo vía LSP del motor; ejemplos de la
  extensión solo si su validador lo exige. Prohibido editar `media/pseudolearn.tmLanguage.json` a mano.
- [ ] `PG-L.07.07` Fichas: confirmar que toda forma nueva de la matriz tiene ficha (`C09`). README de la app y de la
  extensión. Nivel D: `flutter analyze` sobre los archivos tocados, tests espejo tocados con `flutter test <archivos>`,
  `dart run tool/check_syntax_coverage.dart`, `pnpm` de gramática según el README de la extensión. Commit local.

### PG-L.F · Bloque final: pruebas pesadas, conformidad y corrección

Se ejecuta **una sola vez**, al terminar `PG-L.07`, en el orden de §10.2. Cada orden se lanza con su salida redirigida
a `packages/pseudolearn_engine/results/pg-l-2026-11-05/logs/<orden>.log` (directorio nuevo; si el día cambia, usar la
fecha real) y se registra en §11 comando, código de salida y conteos.

- [x] `PG-L.F.01` Corpus: `see validate`, `see lock --refresh <todas las IDs editadas, en una orden>`,
  `see lock --check`, `see export`, `see export --check`.
- [ ] `PG-L.F.02` Estática del motor: `cargo xtask verify` (incluye Clippy estricto, capas, límites y aislamiento según
  el README); `rust-checks` (`layers`, `comments`, `names`, límites) desde la raíz.
- [ ] `PG-L.F.03` Pruebas del motor: `cargo test -p` de `semantic`, `syntax`, `lexicon`, `lowering`, `ir`, `bytecode`,
  `vm`, `service`, `api`, `timeline`, `wasm`; después `cargo test --workspace`.
- [ ] `PG-L.F.04` Conformidad: `see conform --subject engine` completo; `--subject service`; `--subject cli`;
  `--subject aot` (vínculos `pendiente` informados, cero `incumple` en reglas tocadas); `--operation properties`;
  `--subject app` con los escenarios de la app.
- [ ] `PG-L.F.05` Consumidores: pruebas de la CLI según su README; extensión (`pnpm` test y comprobación de gramática
  vigente; web Chromium y WebKit si el README los incluye en la verificación ordinaria); app: `flutter analyze`,
  `dart run tool/check_syntax_coverage.dart`, biblioteca nativa (`cargo build --release --locked --lib
  --manifest-path native/Cargo.toml`) y **suite completa** `flutter test`.
- [ ] `PG-L.F.06` Experimentos de §7.6 (`PL-E01`–`PL-E04`) con procedencia y `PERF.SUITE.CORE`/`PERF.AOT.LEVEL` antes y
  después según `PERF.PROTOCOL` (antes = revisión `d9d84bc7` en el *worktree* desacoplado de `PG-L.F.08`).
- [ ] `PG-L.F.07` Casos negativos de verificadores (§7.3): cada uno debe fallar con su violación deliberada.
- [x] `PG-L.F.08` Ciclo de corrección (§10.4): clasificar cada fallo (regresión de PG-L / preexistente / inestable)
  ejecutando la misma orden en `git worktree add --detach <scratch>/pg-l-base d9d84bc7`; corregir las regresiones;
  repetir solo las órdenes afectadas y, al final, F.01–F.05 completos una vez más.
- [ ] `PG-L.F.09` Aceptación por plataforma (PG-B.27 como precedente): un programa único que ejerce L.01–L.06 con
  salida determinista, ejecutado en CLI, extensión de escritorio, extensión web (Chromium y WebKit), app macOS y app
  iOS en simulador; Windows rotulado «no verificado». Cada celda con resultado esperado derivado del corpus.
- [ ] `PG-L.F.10` Criterio de salida de §B.3a: repetir la búsqueda de `PG-L.00.02` sobre el catálogo regenerado y
  confirmar cero códigos de restricción de construcción de la edición; registrar la tabla final en §11.4.

### Cierre común

- [ ] `PG-L.C03`–`C11` se acreditan con la evidencia de §11 (no hay tareas propias distintas de las anteriores).
- [x] `PG-L.C12.01` Revisión de diff completo (`git diff d9d84bc7 --stat` y lectura de cada archivo de código), búsqueda
  de comentarios, `TODO`, `unwrap`, `expect`, `panic!`, citas a `docs/` fuera de `docs/`
  (`grep -rn "docs/plan-ejecucion\|fase-pg-" packages apps` debe dar vacío).
- [ ] `PG-L.C12.02` Commit(s) con la skill `commit-message`, sin atribución de IA, y push ordinario comprobado
  (`git branch --show-current`, `git push`, `git status -sb` sin divergencia).
- [ ] `PG-L.C13.01` Completar §11 de este plan, la sección §4.13 y la fila de §6 del plan general; informe a la persona
  con: puntos cumplidos, decisiones aplicadas, hallazgos dudosos de `PG-L.00.02`, pendientes (PG-N.08, PG-S.02.01,
  Windows/físicos) y **parada**.

## 5. Capas y archivos

Respuestas a `AGENTS.md` §1 por miembro. «Esperado» = lo que el árbol permitía en `d9d84bc7`; si el árbol cambió,
mandan el árbol y el README. Todo archivo nuevo respeta `PL-H-30`, cero comentarios y `#![forbid(unsafe_code)]` (salvo
crates declarados, que PG-L no toca).

| Miembro / capa | Archivos nuevos o modificados (propuesta) | Puede importar | Tiene prohibido | Dueño de la responsabilidad |
|---|---|---|---|---|
| `pseudolearn_spec` / corpus (datos) | `lang/lang.types.{record,array,generic,enum,interface,relations}.md`, `lang/lang.decl.constant.md`, `lang/lang.module.import.md`, `lang/lang.class.out-of-scope.md`, `lang/lang.syntax.grammar.md`, `lang/lang.profile.vocabulary.md`, nuevo `lang/lang.types.variant.md` (si DL-10 = a), `mem/mem.managed.unobservable.md`, `api/api.state.query.md`, `api/api.program.view.md`, `ir/ir.instructions.md`, `tool/tool.service.{hover,navigation,catalog}.md`, `diag/diag.catalog.md`, `diag/diag.messages.md`, `cases/{catalogs,vocabulary}.json` | (datos) | Citar `docs/`; editar `export.json` | Cada especificación es dueña del comportamiento de su dominio |
| `pseudolearn_spec` / `see_*` | Solo si la validación de un recurso nuevo (variante, vocabulario contextual) lo exige; con su caso negativo | según su `architecture.yaml` | Importar el motor | Validación del corpus |
| Motor / `pseudolearn_lexicon` | `build.rs`/vocabulario contextual generado (DL-10) | `source` | Capas superiores | Vocabulario |
| Motor / `pseudolearn_syntax` | `build.rs` (sin `generic`), parser de `classUnit`/`interfaceUnit`/`variantUnit`, recuperación | `source, diagnostics, lexicon` | `semantic` y superiores | Árbol sin pérdida y gramática |
| Motor / `pseudolearn_semantic` | `local_registry.rs`, `unit_resolver.rs`, `class_registry.rs` + nuevo `class_record_fields.rs`, `argument_checker.rs`, `record_access.rs`, `module_symbols.rs`, `module_exports.rs` (dividir si >300), `module_imports.rs`, `type_scope.rs`, `session_units.rs`, `constant_*`, `type_resolution.rs`, `generic_registry.rs`, nuevo `generic_classes.rs`, `generic_labels.rs`, `hierarchy.rs`, `interface_*`, `variant_*` y `switch_coverage.rs` (DL-10), `service_collection.rs`, `service_model.rs`; tests espejo | `abi, source, project, diagnostics, lexicon, syntax` | `runtime`, `vm`, `library`, `lowering` | Tipado y reglas estáticas |
| Motor / `pseudolearn_ir` | `operation.rs`, tipos y verificador de la forma de DL-02 | `source, abi` | `runtime`, `vm`, `library` | Modelo y verificador de la RI |
| Motor / `pseudolearn_lowering` | `parameter_passing.rs`, `places.rs`, `address_taken.rs`, `indirect_calls.rs`, `classes.rs`, `records.rs`, `record_values.rs`, nuevo `record_arrays.rs`, `variant_values.rs`/`statements_variant_match.rs` (DL-10) | `source, semantic, ir, diagnostics` | `runtime`, `vm` | Bajada de HIR a RI |
| Motor / `pseudolearn_abi` | Solo si DL-02 necesita una disposición de elemento ancho | (hoja) | Capas superiores | Disposiciones compartidas |
| Motor / `pseudolearn_bytecode` | compilación, `verify_array_types.rs`, `roots.rs` (si `PL-V-12` falla), definición por hoja | `ir, source` | `vm`, `semantic` | Bytecode, verificación y mapas |
| Motor / `pseudolearn_vm` | ejecución de la forma de DL-02 y recolección | `bytecode, runtime, library, diagnostics, vm_dispatch` | `semantic`, `lowering` | Ejecución |
| Motor / `pseudolearn_codegen` | `instruction_dispatch.rs` (`UNSUPPORTED_OPERATIONS`) y su prueba | `ir, diagnostics, aot_rt` | `unsafe` | Sujeto nativo (acreditado en PG-N) |
| Motor / `pseudolearn_service` | `symbol_index.rs`, `symbol_queries.rs`, `hover.rs`, `navigation.rs`, `lsp_rename.rs`, `lsp_project_rename.rs`, `lsp_semantic_tokens.rs`, `workspace_invalidation.rs`, `completion_types.rs` | `source, diagnostics, lexicon, syntax, semantic, project` | `vm`, `runtime` | Servicio de lenguaje |
| Motor / `pseudolearn_api`, `timeline`, `wasm` | vista pública (`program_view_kind.rs` y afines), estado por hojas | según `architecture.yaml` | Reinterpretar texto fuente | Fachada |
| Motor / conformidad | `conformance.yaml`, `conformance-service.yaml`, `conformance-aot.yaml` | (datos) | Vínculos en código (`SPEC-BINDING-AS-DATA`) | Vínculos regla–sujeto |
| `pseudolearn_cli` | `conformance.yaml` solo si cambia una regla `TOOL.*` que acredita | su `architecture.yaml` | Copiar lógica del motor | CLI |
| `pseudolearn_vscode` | gramática regenerada, pruebas de gramática/tokens | su `architecture.json` | Implementar parser o semántica | Extensión |
| `pseudolearn_app` | `lib/domain/model/diagram/coverage/*`, proyecciones del diagrama de clases, traza/estado, exportación, `native/` si cambia la vista; tests espejo | su `architecture.yaml` | Dominio importando infraestructura | App |

Respuesta a la tercera pregunta de `AGENTS.md` §1: cada posición nueva de registro nace en el archivo que ya es dueño de
esa posición (campos → registro de clases; parámetros → registro de locales; arreglos → archivo nuevo de bajada), y
cada clase de plantilla nueva en un archivo propio (`generic_classes.rs`), nunca en `generic_functions.rs`.

## 6. Presupuestos de rendimiento y seguridad

### 6.1 Rendimiento

| Presupuesto | Control | Línea base |
|---|---|---|
| La suite pura no paga por lo nuevo | `PERF.SUITE.CORE` y `PERF.AOT.LEVEL` con `PERF.PROTOCOL` antes (revisión `d9d84bc7`) y después, mismo equipo, en `PG-L.F.06` | `PERF.SUITE.CORE` ya estaba sobre presupuesto (H-17 del análisis, se resuelve en PG-7.02): PG-L no puede **empeorarlo** de forma significativa; se informa la diferencia |
| Crecimiento por instancia de clase genérica | E-PG-03 ampliado (`PL-E01`): 1/10/100 combinaciones; tiempo de compilación, instrucciones de RI y tamaño de bytecode frente a un control no genérico | E-PG-03 de PG-2 y el recuento de PG-S (74/740/7 400 instrucciones) |
| Arreglo de registros sin asignación por elemento | `PL-E03`: celdas y tiempo frente a arreglos paralelos escritos a mano con la misma semántica | Sin precedente |
| Latencia del servicio con genéricos entre módulos | `PL-E04`: subconjunto de E-PG-02 con biblioteca genérica | Informativo; no bloquea (PG-7.19) |

Afirmaciones de coste solo con línea base, control semántico equivalente y `PERF.PROTOCOL`.

### 6.2 Seguridad y límites

- Todo lo que crece tiene límite: instancias (64 por programa, también entre módulos y con clases), hojas por registro
  (operando de 16 bits), elementos de arreglo (celdas), profundidad de reexportación (guarda de recursión vigente).
- Ningún fallo esperable cruza una frontera como pánico: elemento o hoja sin valor y ordinal inválido son trampas o
  rechazos del verificador con código de diagnóstico.
- Recolector: toda referencia dentro de un elemento de arreglo o de un campo registro incrustado es raíz precisa; prueba
  con recolección forzada en cada asignación (`gc_stress`) en los casos de L.01 y L.06 (K-05).
- Determinismo: el nombre e identidad de una instancia no dependen del orden de archivos ni del módulo consumidor.
- Autoridad y efectos: PG-L no añade efectos ni capacidades.

## 7. Pruebas, verificadores y experimentos

### 7.1 Matriz por punto

| Punto | Corpus | Tests espejo | Consumidores | Verificadores (bloque F) |
|---|---|---|---|---|
| L.01 | `LANG.TYPES.{RECORD,ARRAY}`, `LANG.SUBPROGRAM.BY-REFERENCE`, `MEM.VALUE.COPY`, `IR.INSTRUCTIONS`, `DIAG.CATALOG` | semantic, lowering, ir, bytecode, vm, api | app (traza, estado, diagrama), export | validate/lock/export, conform engine/aot, `gc_stress` |
| L.02 | `LANG.MODULE.IMPORT`, `LANG.TYPES.{ENUM,RECORD,INTERFACE}`, `LANG.DECL.CONSTANT` | semantic, service | extensión (navegación), app (proyecto) | conform engine/service |
| L.03 | `LANG.TYPES.GENERIC`, `LANG.MODULE.IMPORT`, `API.PROJECT.LOCK` (caso) | semantic, service | ídem | conform engine/service, `PL-E01`, `PL-E04` |
| L.04 | `LANG.SYNTAX.GRAMMAR`, `LANG.TYPES.{GENERIC,INTERFACE,RELATIONS,VARIANT}`, `LANG.CLASS.OUT-OF-SCOPE`, `LANG.PROFILE.VOCABULARY` | syntax, lexicon, semantic, lowering | extensión (gramática), app (diagrama, cobertura) | conform engine/aot, `PL-E01` |
| L.05 | `LANG.TYPES.GENERIC`, `TOOL.SERVICE.{HOVER,NAVIGATION}` | semantic, service | extensión (hover, rename) | conform service |
| L.06 | `MEM.MANAGED.UNOBSERVABLE`, `API.STATE.QUERY` | bytecode, vm, api | app (estado) | conform engine/aot, `PL-E02` |
| L.07 | `API.PROGRAM.VIEW`, `TOOL.SERVICE.CATALOG` | app, extensión | todos | `check_syntax_coverage`, conform app, suite Flutter, F.09 |

### 7.2 Matriz de aceptación por plataforma (`PG-L.F.09`)

Filas: L.01 (arreglo, campo, firma de miembro, por referencia), L.02 (constante, enumerado, registro, interfaz
importados), L.03 (genérico importado), L.04 (clase genérica, interfaz genérica, variante de usuario), L.06 (bucle con
objetos de bloque y límite de celdas, solo donde el anfitrión permite fijar el límite). Columnas: VM/API, CLI, extensión
de escritorio, extensión web (Chromium, WebKit), app macOS, app iOS simulador, app Windows (`no verificado`). Los
programas de proyecto (L.02/L.03) solo en los anfitriones que abren proyectos; el resto se rotula con motivo.

### 7.3 Verificadores nuevos y sus casos negativos

Cada uno lleva un fixture con violación deliberada que **debe** fallar (`AGENTS.md` §5): (1) verificador de RI/bytecode
con ordinal de hoja fuera de rango en la forma de DL-02; (2) mapa de raíces sin una referencia de elemento registro
(recolección forzada debe detectar el uso tras liberar); (3) `roots::expire` desactivado → el caso de L.06 debe
terminar `cellLimitExceeded`; (4) matriz de cobertura de la app sin la fila de una forma nueva → `COV-MISSING-ROW`;
(5) ficha `help.pgl0N.*` ausente para una forma nueva (validador de catálogo, si ya cubre la ausencia; si no, se añade
el caso al fixture existente de `help-catalog`); (6) vínculo `pendiente` sin `resuelve_en`.

### 7.4 Comandos y niveles

Los comandos exactos se copian de la sección operativa del README de cada miembro, no de este plan. Referencia:

- **Nivel D (durante el desarrollo, rápido):** `cargo check -p <crate>`; `cargo test -p <crate> --test <archivo>` o
  `cargo test -p <crate> <filtro>` sobre los tests creados o tocados; `cargo run -p see_cli --bin see -- validate`
  (desde `packages/pseudolearn_spec`) tras cada edición de corpus; en la app, `flutter test <archivos tocados>` y
  `dart run tool/check_syntax_coverage.dart`. **Prohibido en nivel D:** `cargo test --workspace`, `cargo xtask
  verify`, `see conform` completo, `flutter test` completo, campañas `PERF.*`, Playwright.
- **Nivel F (bloque final):** todo lo de `PG-L.F.01`–`F.09`.
- Corpus: `see validate`, `see lock --check`, `see lock --refresh ID,ID,…`, `see export`, `see export --check`,
  `see conform --subject engine|service|cli|aot|app [--only ID]`, `see conform --operation properties`.
- Motor: `cargo test -p <crate>`, `cargo test --workspace`, `cargo xtask verify`; capas desde la raíz con
  `cargo run --manifest-path packages/pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command -- layers
  packages/pseudolearn_engine` (y las demás subórdenes que liste el README de `pseudolearn_rust_checks`).
- Extensión: Node 22.23.3 y pnpm 12.8.1, órdenes de su README. App: órdenes de su README (análisis, cobertura,
  biblioteca nativa, `flutter test`).

### 7.5 Experimentos

| ID | Objetivo | Protocolo | Procedencia exigida | Si falla |
|---|---|---|---|---|
| `PL-E01` | E-PG-03 ampliado: crecimiento por instancia de clases y genéricos entre módulos | 1/10/100 combinaciones de argumentos de una clase genérica y de una función genérica importada; control no genérico equivalente; medir tiempo de análisis, instrucciones de RI y bytes de bytecode | Revisión, plataforma, hashes de fuentes, crudos | Si crece superlinealmente (K-04), informar y proponer reversión; no bloquea si es lineal |
| `PL-E02` | Liberación por ámbito (`PL-V-12`, `PL-V-14`) | Programas de `PG-L.06.03` con N = 10/1 000/100 000 iteraciones, presupuesto fijo, con y sin `gc_stress`; VM y, si compila, AOT | Semilla, límites, crudos | VM falla → corregir L.06; AOT diverge → vínculo `pendiente` `PG-N.05` y riesgo PL-K-04 |
| `PL-E03` | Coste de arreglos de registros | 10⁵ elementos de un registro de 3 hojas (escalar, real, cadena) frente a tres arreglos paralelos | Protocolo `PERF.PROTOCOL` | Informar; reversión solo si domina la copia por hoja |
| `PL-E04` | Latencia del servicio con biblioteca genérica | Subconjunto de E-PG-02 con 20 módulos consumidores | Plataforma, crudos | Informativo (PG-7.19) |

Experimentos con dispositivos físicos o participantes: complementarios, no bloquean (decisión 2026-10-22–24).

## 8. Riesgos y señales tempranas

| ID | Riesgo | Señal temprana | Mitigación |
|---|---|---|---|
| K-02 | Palabras nuevas (variante) rompen programas que las usaban como nombres | Caso con identificador `Variante` falla | Vocabulario contextual, no reservado (DL-10) |
| K-04 | Explosión de instancias con clases genéricas y entre módulos | `PL-E01` superlineal o límite de 64 alcanzado por programas ordinarios | Límite por programa; métodos genéricos propios excluidos (DL-09) |
| K-05 | Referencia dentro de un elemento o campo registro no es raíz y se libera | Fallo con `gc_stress` | Mapas de raíces por hoja; negativo §7.3-(2) |
| K-16/K-17 | Ficha o hover atribuidos a la instancia en vez de a la plantilla, o a un homónimo | Casos de L.05 | DL-13; pruebas de homónimos |
| K-19 | Forma nueva cae como proceso genérico o «no soportado» en la app | `COV-MISSING-ROW`, celda nueva `unsupported` | L.07.04 |
| PL-K-01 | DL-02 (arreglos) exige más cambios de RI de los previstos y bloquea la iteración | `PL-V-03`/`PL-V-04` muestran ausencia total de soporte multihoja | Ejecutar los demás puntos; parada acotada del sub-punto (§10.3) |
| PL-K-02 | Conflicto con texto de PG-S en README compartidos | Diff inesperado en README de `semantic`/`lowering`/`service` | `git log` antes de editar; edición por sección |
| PL-K-03 | Variante de usuario (DL-10 = a) multiplica el alcance | L.04.B supera el resto de la fase en archivos | Ejecutarla al final de L.04 y aislarla en commits propios |
| PL-K-04 | Diferencia VM/AOT en recuento de celdas por vivacidad | `PL-E02` con AOT | Vínculo `pendiente` y registro para PG-N |
| PL-K-05 | El bloque F revela muchas regresiones tardías por no haber probado antes | Más de 20 fallos nuevos en F.03 | Ciclo §10.4; si persiste, informar a la persona con la lista en vez de seguir parcheando |
| PL-K-06 | Casos existentes que esperaban los diagnósticos retirados | `see validate` o conformidad con casos huérfanos | Reescribir con esperado derivado de la regla nueva (§0.1-5) |

## 9. Dependencias de la persona

### 9.1 Qué se necesita y cuándo

| Cuándo | Qué se necesita |
|---|---|
| Antes de `C01` | Revisión de este plan (`C02`) y autorización en mensaje nuevo para ejecutar PG-L completa en una iteración |
| Al revisar `C02` | Decisiones **Persona**: DL-03 (definición por hoja), DL-06 (diagnóstico de tipo privado en firma pública), DL-07 (interfaces exportables), DL-09 (sintaxis y alcance de clases genéricas), DL-10 (variantes de usuario) y nombres **CANDIDATOS**. «Opción recomendada en todas» es una respuesta válida |
| Durante la ejecución | Ninguna salvo las paradas de §10.3 |
| Cierre | Revisar hallazgos «dudosos» de `PG-L.00.02`, pendientes (PG-N.08, PG-S.02.01, Windows y físicos) y autorizar el siguiente paso |

### 9.2 Conflictos conocidos (`CONFLICT-REPORT`)

1. **Variantes de usuario.** `PG-L.04` pide «variantes genéricas de usuario», pero el lenguaje no tiene variantes de
   usuario (`PL-H-06`) y `LANG.TYPES.RELATIONS#R3` excluye «tipos genéricos definidos por la persona». No es retirar
   una restricción sino añadir una construcción. Resolver con DL-10.
2. **Alcance de `PG-L.02`.** La lista literal no incluye interfaces; sin ellas `PG-L.03` no puede exportar genéricos
   restringidos. Resolver con DL-07.
3. **`unsupportedInterfaceConstruct`.** El catálogo afirma que las interfaces no forman parte del lenguaje mientras
   `LANG.TYPES.INTERFACE` las define. Se retira con DL-11 (eliminación de raíz); si la persona prefiere conservarla, es
   una contradicción del corpus que debe resolver.
4. **«Identidad de instancia en el lock»** (§B.3a). `API.PROJECT.LOCK` no registra instancias; DL-08 lo acredita sin
   cambiar el lock. Si la persona entendía otra cosa, es una edición de `API.PROJECT.LOCK`.
5. **Pendiente de raíces posiblemente obsoleto** (`PL-H-21` frente a `PL-H-22`). Se resuelve con `PL-V-12`: si la VM
   ya cumple, `PG-L.06` es especificación, prueba y documentación.

## 10. Orden de ejecución y puntos de control

### 10.1 Orden único (una iteración)

1. **G0 · Entrada.** `C01` recibido; decisiones de §9.1 registradas; `PG-L.00.01`–`.04`. No hay línea base pesada.
2. **PG-L.01** (firmas de miembros → campos → por referencia → arreglos) → control **K1** (sin parada): nivel D en
   verde y `see validate` limpio.
3. **PG-L.02** → **K2**.
4. **PG-L.04** (A y, si procede, B) → **K3**.
5. **PG-L.05** → **K4**.
6. **PG-L.03** → **K5**.
7. **PG-L.06** → **K6**.
8. **PG-L.07** → **K7**.
9. **Bloque F** en el orden de §10.2, con el ciclo de §10.4.
10. Cierre `C12`–`C13`, informe y **parada** (`PHASE-STOP`).

Los controles K1–K7 no detienen la ejecución: verifican el nivel D del punto y producen el commit local del punto. Si
un control falla, se corrige antes de pasar al siguiente punto (el siguiente punto se apoya en este).

### 10.2 Orden del bloque F

F.01 corpus → F.02 estática → F.03 pruebas del motor → F.04 conformidad → F.05 consumidores → F.07 negativos →
F.06 experimentos y rendimiento → F.08 ciclo de corrección (intercalado: tras cada orden que falle) → F.09 aceptación
por plataforma → F.10 criterio de salida. Push solo después de F.10 en verde o con pendientes aceptados por escrito.

### 10.3 Paradas obligatorias (las únicas)

- Decisión **Persona** sin respuesta: se omite el sub-punto afectado (estado «Pendiente, requiere a la persona») y se
  sigue con los demás. No es motivo para detener la iteración.
- DL-02 inviable tras `PL-V-03`/`PL-V-04` (ninguna forma conserva identidad): se detiene solo el sub-punto «arreglos»
  de L.01, se reporta con el dato observado y se sigue.
- Conflicto nuevo entre fuentes que cambia el trabajo: se registra en §11.3, se omite lo afectado y se sigue.
- Fin de la fase: informe y parada.

### 10.4 Ciclo de corrección del bloque F

1. Para cada orden que falle, guardar el registro y clasificar cada fallo ejecutando la **misma orden** en el
   *worktree* desacoplado de `d9d84bc7`: si también falla allí, es **preexistente** (se registra, no se corrige salvo que
   PG-L lo agrave); si no, es **regresión de PG-L**; si falla de forma intermitente en tres ejecuciones, **inestable**.
2. Corregir regresiones en el archivo dueño, respetando la secuencia de §0.1-4 (si la causa es un caso mal derivado,
   se corrige el caso con la derivación correcta y se anota).
3. Repetir solo la orden afectada y las que dependen de ella (p. ej. un cambio en `semantic` repite F.03 de
   `semantic`, `lowering`, `api` y F.04 `engine`).
4. Máximo tres vueltas por orden; si una regresión persiste, se registra como «No cumplido» con su causa y se informa
   (PL-K-05). Tras la última corrección, F.01–F.05 completos una vez más.
5. Eliminar el *worktree* (`git worktree remove`) al terminar.

## 11. Resumen de ejecución

Estado: ejecución parcial el 2026-11-05 en una sola sesión sobre `d9d84bc7`. **La fase no está cerrada**: se cumplieron
PG-L.01 (salvo consumidores del motor y fichas), PG-L.02 (salvo diagnóstico de firma pública, servicio y casos
secundarios) y PG-L.06 (regla y pruebas; la VM ya cumplía). No se iniciaron PG-L.03, PG-L.04, PG-L.05 ni PG-L.07; el
bloque F se ejecutó para lo implementado. Las casillas sin marcar son tareas **no realizadas**, no omitidas por descuido;
cada una consta en la tabla siguiente con su motivo. Commits locales: `9acfbe96` (PG-L.01), `98b00836` (PG-L.06),
`c61c2f63` (PG-L.02) y el commit de cierre; **no se hizo push** porque `PG-L.F.10` no está en verde y el plan exige
aceptar pendientes por escrito antes de publicar (`PHASE-GREEN`, §10.2).

| Tarea | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| `PG-L.C01`, `C02` | Cumplida | Mensaje de la persona del 2026-11-05 | Autorización de ejecución y decisiones **Persona** aprobadas |
| `PG-L.00.01`–`.04` | Cumplida | §11.1, §11.4; `cargo build -p pseudolearn_api` y `see validate` en verde al inicio | La línea base solo cubrió compilación y validación |
| `PG-L.01.01`, `.02`, `.03`, `.05`, `.08`, `.09` | Cumplida con desviación | `9acfbe96`; pruebas `record_*` de `pseudolearn_api`; `lang.types.record.md` R1, R3, R5, C7–C45; conformidad engine de `LANG.TYPES.RECORD` (88 observaciones, 0 divergencias) | DL-02 se resolvió con arreglos paralelos por hoja, no con elementos anchos en la RI (§11.3). Casos no escritos: límite de hojas de 16 bits, índice inválido antes de entrar por referencia, valor función de un método, registro con campo de clase dentro de un elemento |
| `PG-L.01.04` | No cumplida | | Se reescribieron las pruebas de `semantic`; no hay pruebas dirigidas nuevas de `lowering`, `ir`, `bytecode` ni `vm`, ni verificador negativo, porque no se tocaron esas capas |
| `PG-L.01.06` | No cumplida | | La vista de estado de `api` muestra los arreglos por hoja (`a.x`) sin agrupar; no se revisó `timeline` ni `wasm` |
| `PG-L.01.07` | No cumplida | | Sin fichas `help.pgl01.*` |
| `PG-L.02.01`, `.05`, `.08` | Cumplida | `c61c2f63`; `lang.module.import.md` R1, R2, C35–C42; conformidad engine de `LANG.MODULE.IMPORT`, `LANG.TYPES.ENUM` y `LANG.DECL.CONSTANT` en verde | El analizador sintáctico rechazaba `Publico` ante enumerados, registros, constantes e interfaces (PL-V-07 desmentida en parte) |
| `PG-L.02.02` | No cumplida | | Falta la regla y el diagnóstico `privateTypeInPublicSignature` |
| `PG-L.02.03` | No cumplida | | Faltan casos de `Segun` sobre enumerado importado, reexportación encadenada, `privateReexport`, `ambiguousReexport` y límites |
| `PG-L.02.04` | No cumplida | | Las pruebas viven en `pseudolearn_api/tests/module_type_exports.rs`; no hay archivo espejo en `semantic` |
| `PG-L.02.06`, `.07` | No cumplida | | El servicio no modela registros, enumerados, constantes ni interfaces como símbolos; no se implementó |
| `PG-L.04.*`, `PG-L.05.*`, `PG-L.03.*`, `PG-L.07.*` | No cumplida | | No iniciadas por alcance de la sesión (gramática de clases genéricas, variantes de usuario, símbolo de plantilla, genéricos entre módulos, app y extensión). Solo se retiró `unsupportedInterfaceConstruct` (DL-11) |
| `PG-L.06.01` | No cumplida | | PL-V-12 confirmada con experimento; PL-V-13 y PL-V-14 sin verificar |
| `PG-L.06.02`, `.03`, `.05`, `.06` | Cumplida | `98b00836`; `MEM.MANAGED.UNOBSERVABLE#R3`, C2–C6; conformidad engine en verde | La VM ya liberaba por ámbito; no hubo cambio de código. Vínculo `aot` declarado `cumple` sin ejecutar la conformidad nativa (evidencia obsoleta) |
| `PG-L.06.04` | No cumplida | | `pseudolearn_api/tests/scope_release.rs` cubre la VM; no se añadió el negativo con `roots::expire` desactivado |
| `PG-L.F.01` | Cumplida | `see validate`, `lock --check`, `export --check` en verde | |
| `PG-L.F.02` | No cumplida | `f02-clippy.log`, `f02-rust-checks-all.log`, `f02-toolchain.log`, `f02-deny.log` en verde | `cargo xtask verify` se detiene en `cargo fmt --all --check` por archivos no tocados (`pseudolearn_vm/src/machine/query.rs`, entre otros): preexistente |
| `PG-L.F.03` | No cumplida | `f03-workspace.log`: 2 401 pruebas en verde, 2 fallos | Los dos fallos (`library_cases_execute_and_replay_without_live_host_calls`, `builtins_follow_the_profile_lexemes_and_declare_their_signature`) fallan igual en `d9d84bc7`: preexistentes |
| `PG-L.F.04` | No cumplida | `f04-*.log` | Engine: 0 `incumple`; las 25 reglas «sin evidencia» son de propiedad y `conform --subject engine --operation properties` ejecutó 32 propiedades sin pendientes. CLI: 117 observaciones, 0 divergencias. Service y aot: `SEE-STALE: evidence corpus hash mismatch for API.PROGRAM.VIEW`, sin resolver. App: no ejecutada |
| `PG-L.F.05` | No cumplida | `dart run tool/check_syntax_coverage.dart`: 78 formas cubiertas | No se ejecutaron `flutter test`, pruebas de la extensión ni la biblioteca nativa |
| `PG-L.F.06`, `F.07`, `F.09` | No cumplida | | No ejecutadas |
| `PG-L.F.08` | Cumplida | §10.4 aplicado a los dos fallos, con *worktree* desacoplado en `d9d84bc7`, eliminado al terminar | Sin regresiones de PG-L que corregir en lo ejecutado |
| `PG-L.F.10` | No cumplida | §11.4 | Quedan `unsupportedGenericsConstruct` (los genéricos de clase no existen) y los «dudosos» |
| `PG-L.C12.01` | Cumplida | `rust-checks all`, Clippy `-D warnings`, `grep` de `docs/plan-ejecucion` fuera de `docs/` vacío | |
| `PG-L.C12.02`, `PG-L.C13.01`, `C03`–`C11` | No cumplida | | Sin push; fase incompleta |

Revisión Git de cierre: `feature/agregar-ruta-de-especificacion`, commits locales sobre `7ba4b117`. Verificadores ejecutados:
`see validate`, `lock --check`, `export --check`, `see conform --subject engine|cli`, Clippy de todo el espacio de trabajo,
`rust-checks all` y `toolchain`, `cargo deny check`, `cargo test --workspace --no-fail-fast`, `check_syntax_coverage`.
Suites omitidas: `flutter test`, extensión, `PERF.*`, experimentos `PL-E01`–`PL-E04`, aceptación por plataforma.

### 11.1 Registro de hipótesis (`PL-V-01`–`PL-V-17`)

| Hipótesis | Resultado | Evidencia | Consecuencia en el plan |
|---|---|---|---|
| PL-V-01 | Confirmada | `record_member_signatures.rs` (método, sobrescritura virtual, constructor con `Super`, interfaz), con `gc_stress` | Sin cambio de lowering |
| PL-V-02 | Confirmada con otra representación | `class_record_fields.rs`: campo lógico más un campo físico por hoja | DL-01 (a) |
| PL-V-03 | Confirmada en lo observado | La RI y la VM tienen un único tipo de elemento por arreglo; no se leyó el verificador completo | DL-02 se resolvió sin RI nueva |
| PL-V-04 | Sin comprobar | | No hizo falta |
| PL-V-05 | Confirmada para llamadas directas y métodos | `record_by_reference.rs` (variable, campo de objeto, elemento, anidado); valores función sin verificar | DL-04 |
| PL-V-06 | Confirmada para `Vector<Registro>` | `record_in_collections.rs`; `Dictionary`, `Opcional`, `Resultado`, canales y tareas sin comprobar | |
| PL-V-07 | Desmentida en parte | El analizador rechazaba el prefijo (`UnexpectedTokenOutsideProgramUnit`) | Se extendió `visibility_prefix` y `parse_visible_unit` |
| PL-V-08 | Confirmada | C36 de `LANG.MODULE.IMPORT`; `constant_evaluator::run` debía restaurar la unidad activa | |
| PL-V-09, V-10, V-11 | Sin comprobar | | |
| PL-V-12 | Confirmada | `scope_release.rs` y C2–C6 de `MEM.MANAGED.UNOBSERVABLE`: un bucle de 50 iteraciones con presupuesto de una iteración completa | Solo especificación y pruebas |
| PL-V-13, V-14 | Sin comprobar | | |
| PL-V-15 | Confirmada | `catalogs.json` y `diag.catalog.md` se editaron a la par y `see validate` pasa | |
| PL-V-16 | Confirmada | El motor compila sin los cinco códigos retirados | |
| PL-V-17 | Confirmada | `check_syntax_coverage`: 78 formas cubiertas tras los cambios (no hubo forma nueva) | |

### 11.2 Respuestas a `AGENTS.md` §1 por archivo

| Archivo | Capa | Imports permitidos / prohibidos | Dueño |
|---|---|---|---|
| `semantic/src/class_record_fields.rs` | semantic | `abi, source, project, diagnostics, lexicon, syntax`; no `lowering` ni `vm` | Campos de clase de tipo registro |
| `semantic/src/module_type_links.rs` | semantic | ídem | Enlace de tipos importados en un proyecto |
| `lowering/src/{class_record_values,record_arrays,record_cells,statements_dimension}.rs` | lowering | `source, semantic, ir, diagnostics`; no `vm` | Hojas de campos, arreglos, celdas por referencia y declaración de dimensiones |
| `syntax/src/{module_parser,parser}.rs` | syntax | `source, diagnostics, lexicon` | Prefijo de visibilidad de unidades |

### 11.3 Conflictos y decisiones de la persona

| ID | Texto | Respuesta de la persona (cita y fecha) | Efecto |
|---|---|---|---|
| DL-03 | Definición por hoja en arreglos y campos | «Sí, recomendadas», 2026-11-05 | Aplicada: cada hoja conserva su estado de definición |
| DL-06 | Exportación de constantes, enumerados y registros; tipo privado en firma pública | «Sí, recomendadas», 2026-11-05 | Importación por símbolo aplicada; `privateTypeInPublicSignature` **no implementado** |
| DL-07 | Interfaces exportables | «Sí, recomendadas», 2026-11-05 | Aplicada |
| DL-09, DL-10 | Clases genéricas y variantes de usuario | «Sí, recomendadas», 2026-11-05 | Aprobadas pero **no implementadas** en esta sesión |
| DL-11 | Retiro de `Generico` y de `unsupportedInterfaceConstruct` | «Sí, recomendadas», 2026-11-05 | `unsupportedInterfaceConstruct` retirado; `unsupportedGenericsConstruct` permanece hasta PG-L.04 |
| DL-02 (desviación) | Registro como elemento de arreglo | Opción (a) elegida el 2026-11-05 | **No aplicada**: la RI, el bytecode, la VM y el nativo exigirían elementos de varias hojas. Se aplicó el equivalente de (b) restringido: un arreglo de registros es un arreglo por hoja detrás de un único nombre, viable porque un arreglo solo vive en variables y parámetros. Identidad de arreglo y paso por parámetro se conservan; la vista de estado muestra una entrada por hoja. Reversión: medición de `PL-E03` o ambigüedad del estado |
| Nombres **CANDIDATOS** | Sintaxis y diagnósticos propuestos | «Sí, recomendadas», 2026-11-05 | Solo se usaron los de registros y módulos |

### 11.4 Auditoría de «no soportado» (`PG-L.00.02` y `PG-L.F.10`)

Catálogo tras los cambios: 277 códigos (282 menos `recordPassedByReference`, `recordArrayElementNotSupported`,
`recordClassFieldNotSupported`, `recordMemberSignatureNotSupported` y `unsupportedInterfaceConstruct`).

| Código | Clase | Destino | Estado final |
|---|---|---|---|
| `recordPassedByReference`, `recordArrayElementNotSupported`, `recordClassFieldNotSupported`, `recordMemberSignatureNotSupported` | Retirar en PG-L | Catálogo, `catalogs.json`, motor | Retirados |
| `unsupportedInterfaceConstruct` | Sin emisor y contradictorio | DL-11 | Retirado |
| `unsupportedGenericsConstruct` | Retirar en PG-L | PG-L.04 | Pendiente (genéricos de clase no implementados) |
| `unsupportedAbstractConstruct`, `unsupportedStaticConstruct`, `unsupportedProtectedConstruct`, `unsupportedExceptionConstruct` | Fuera de la edición (D-16, D-17) | Se conservan | Sin cambio |
| `nativeTasksUnsupported` | Otra fase | PG-N.13 | Sin cambio |
| `unsupportedStructuredConstruct`, `nestedClassNotSupported`, `multipleInheritanceNotSupported` | Regla legítima | | Sin cambio |
| `snapshotNotSupported`, `elementTypeNotComparable`, `invalidDictionaryKeyType` | Dudoso | Informe a la persona | Sin cambio |
