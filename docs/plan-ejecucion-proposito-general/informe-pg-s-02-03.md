# Informe de PG-S.02 y PG-S.03

Fecha: 2026-11-04. Revisión inicial: `19462776d81059bcd49b17eafe6b32f4782759ad`.
Rama única: `feature/agregar-ruta-de-especificacion`.
Estado: detenido por instrucción explícita de la persona el 2026-11-04 a las 13:54 (Lima). Código implementado; 19 de 22 puntos completados. PG-S.02 y PG-S.03 permanecen abiertas. No quedan pruebas propias ejecutándose.

## Autorización y orden de trabajo

La instrucción directa de la persona autoriza ambas fases juntas, el paso por G2 y el inicio antes
del cierre de PG-L. Se conserva la inconsistencia histórica de PG-B como antecedente; no se declara
cerrada esa fase. Se aplican DS-02–DS-11 y los nombres bilingües propuestos. No se inicia PG-S.04–.09.

La persona pidió preparar todo el cambio antes de ejecutar pruebas. Esa instrucción prevalece sobre
la línea base previa y el ensayo descartable de PS-E02: se prepararon oráculo, especificaciones,
casos, tests y código sin ejecutar pruebas intermedias; el candidato de mezcla se conservó y se
verificó al final. La línea base de rendimiento se reconstruyó aisladamente desde la revisión inicial
mediante `git archive`, sin crear ramas ni modificar su fuente. No se relajaron límites.

## Decisiones y verificaciones de hipótesis

| ID | Resultado y decisión |
|---|---|
| PS-V-03 | D1 conserva ampliación numérica; `widestNumeric` selecciona Entero cuando ambos argumentos son enteros y Real cuando participa un real. |
| PS-V-05 | Se incorporan operaciones de RI tipadas para las funciones numéricas y las primitivas de reordenación. La mezcla usa mínimo entero para sus límites. |
| PS-V-06 | Se reutiliza una función sintetizada por tipo de vector y firma de comparador. La alternativa A de DS-10 satisface PS-E02; no se introduce otra máquina de estados. |
| PS-V-07 | La mezcla no emite pasos ni decisiones internas; se ocultan sus marcos y se conserva el tramo del llamador. Las llamadas y sentencias del comparador siguen siendo observables. |
| PS-V-08 | El sistema de tipos no admite usar una función suspendible como comparador ordinario; se exige firma síncrona por valor. |
| DS-02–DS-06 | Funciones D1 con RI propia; intervalos y Ziv sin libm para las seis trascendentes; casos exactos y ceros antes del refinamiento; piso y techo producen Entero i64 comprobado. |
| DS-07–DS-11 | Ordenación e inversión mutan y versionan; mezcla estable con dos copias O(n) contabilizadas; confirmación completa tras comprobar versión; toda escritura por alias durante el comparador se rechaza. Búsqueda de primitivos por valor y copia de claves por inserción. |

La bandera de ordenación impide también el reemplazo no estructural por alias; comprobar únicamente
la versión no detectaría esa escritura. El error terminal deja el receptor sin reordenamiento parcial;
los efectos de usuario del comparador conservan su semántica.

El umbral de recolección puede cruzarse dentro de una copia grande. `collection.clone` recibe siempre
las raíces del llamador y es punto seguro de bytecode; las pruebas fuerzan recolección en ambos gemelos.

Las doce variantes escalares nuevas se cargan en una tabla lateral tipada y comparten una forma de
despacho. La primera medición detectó una regresión al expandir cada operación en el despacho
principal; la campaña posterior conserva ambas mediciones para revisar la corrección.

El oráculo sigue siendo racional e independiente. Conserva un intervalo de pi/4 por hilo, calculado inicialmente con al menos 1280 bits y comprimido hacia afuera a la precisión solicitada;
tras reducir un ángulo, acota su centro y conserva todo el ancho como radio. Esa optimización evita
arrastrar los bits del exponente original durante las series sin cambiar la inclusión matemática.

## Consumidores y límites explícitos

Las quince fichas es/en, las firmas, el vocabulario contextual y el resaltado se generan desde el
corpus. El servicio conserva los homónimos de usuario al traducir y resuelve completado y ayuda por
identidad del receptor. La vista pública añade `collection_operation`, consumida por la app dentro
de los nodos de llamada existentes; no se agregan formas sintácticas ni pasos internos de mezcla.

La exportación Rust/Python declara sin equivalente las nuevas formas que no conservan fielmente
alias, atomicidad, combustible o versión de colección. Las seis trascendentes también se identifican
sin equivalente: la libm del destino no garantiza el redondeo exigido. No se presentan traducciones
aproximadas como soporte semántico. Los README de la app y del motor conservan esta decisión.

El sujeto nativo conserva vínculos pendientes para PG-N.08 y rechaza explícitamente las operaciones
nuevas no soportadas. Los casos nativos previos siguen ejecutándose; sus filtros consultan los vínculos
de conformidad para no exigir soporte pendiente. No se declara paridad nativa nueva.

## Evidencia de ejecución

Los resultados crudos, argumentos exactos, salidas, manifiestos, hashes de fuentes y binarios y logs
se conservan en `packages/pseudolearn_spec/results/pg-s-02-03-2026-11-04/`, ignorado por Git conforme
al contrato del repositorio. Los generadores permiten reproducir las entradas por semilla.

- PS-E02/E-PG-03: 1, 10 y 100 combinaciones producen 74, 740 y 7 400 instrucciones auxiliares;
  se reutiliza cada instancia y no hay crecimiento superlineal. Ordenación de 100 000 elementos:
  se comprueba cada posición y la terminación completa con los límites existentes declarados por el test.
El ensayo de 100 000 elementos fija 1 000 000 de celdas, 2 000 000 de sentencias y 500 000 000 de micropasos mediante los límites públicos existentes. Son restricciones adicionales: la memoria por omisión es 4 194 304 celdas y la ejecución sin límite explícito no tiene esos topes. No se modificó ningún máximo del motor.

- Semilla de estabilidad y multiconjunto: 20261104, tamaños 0, 1, 2, 7, 31 y 96; oráculo independiente
  de orden estable por clave. Casos del corpus en ambos perfiles cubren comparadores cero e inconsistente,
  error de comparador, alias, iteración activa, Unicode, ceros, vacíos y búsquedas ausentes.
- Las pruebas semánticas incluyen inmutabilidad, tipos, aridad, firma y obligaciones sobre el resultado.
- Los extremos adicionales suman 266 argumentos, con subnormales, máximos finitos, vecinos de pi/2,
  vecinos de uno y los cuadrantes/ceros de atan2: cero discrepancias.
- El sondeo del motor produjo los seis millones de resultados crudos. El contraste independiente completó tan, asin y acos: 1 000 000 de muestras por función, cero discrepancias. Se detuvo durante atan2; atan2, log2 y log10 siguen pendientes. No existe un veredicto completo de seis millones.

## Rendimiento

La repetición intermedia, conservada como v2, dio 0,9700 en VM. Se conservaron diez procesos por carga y treinta pares por proceso, para las diez cargas existentes.
La campaña `paired` registra VM, nativo y techo en el mismo proceso; la comparación por medias de
proceso usa 10 000 remuestreos bootstrap con semilla 20261104 e intervalos del 95 %.

La primera razón geométrica VM fue 1,0330. Después de compactar el despacho, una medición intermedia dio 0,9659. Tras la corrección de inmutabilidad, la medición final es 0,9832;
ninguna carga tiene un intervalo de regresión por encima de uno. La razón nativa final es 0,9689 y la del control de techo es 0,9628; su razón relativa es 1,0064. Ninguna carga muestra un intervalo de regresión significativa por encima de uno en los tiempos VM o nativos. No se atribuye causalmente una mejora a estas cifras.
Se conservan todos los crudos, sin descartar observaciones. Estas cifras comparan tiempos medidos;
no se interpretan como una mejora causal aislada porque el control de techo también cambió.

El objetivo absoluto de PERF.AOT.LEVEL falla tanto en la revisión inicial como en la final.
La comprobación de estacionariedad tampoco queda demostrada por el arnés. Son límites medidos
que se conservan, sin rebajar presupuestos ni declarar resuelto el trabajo de rendimiento previo.
La medición requerida se ejecutó; la afirmación respaldada es ausencia de regresión significativa
en las muestras conservadas, no certificación del objetivo absoluto pendiente.

## Verificación y publicación

No se ejecutarán más pruebas en este chat por instrucción de la persona. El árbol contiene todos los cambios sin commit sobre `19462776`; el remoto consultado seguía en esa misma revisión. No se hizo push ni se declaró cierre de fase.

Resultados disponibles:

- 981 pruebas de los crates centrales en verde; 12 de API dirigidas, propiedades de ordenación y pruebas adicionales de inmutabilidad, registros y ayuda también en verde. La última prueba de colecciones incluye ambos gemelos, GC forzado y los nuevos casos de diccionario.
- 122 pruebas de oráculo/validación y 126 de CLI/conformidad en verde; negativo de resultado matemático alterado detectado.
- Propiedad LIB.CORE.MATH P1: 96 muestras, sin capacidades pendientes, en verde.
- Conformidad previa: matemática 34, redondeo 10, vector 54 y diccionario 24 observaciones, sin divergencias. Los casos C13/C14 de diccionario se añadieron después; sus pruebas de API pasan, pero su conformidad final no quedó consolidada.
- App: 70 pruebas seleccionadas en verde y repetición final de 16 pruebas funcionales con el puente reconstruido; análisis estricto, límites y cobertura 78/78 en verde.
- Extensión: cuatro pruebas de gramática y controles de tipos, arquitectura, comentarios, tamaño y artefacto generado en verde.
- Corpus: 197 identidades validadas; anclajes de los diez IDs modificados reanclados conjuntamente y exportación comprobada. Estados y versiones conservados.
- Formato, Clippy estricto, verificadores Rust, cadena de herramientas, cargo-deny y puerta documental con tres negativos en verde en las ejecuciones conservadas. Los últimos cambios de código fueron la conservación de Inmutable y la lectura de límites del harness; revisar los logs finales antes de certificar el cierre.

La plataforma física verificada fue macOS arm64/Apple M2. No se presenta como prueba física de Windows, Linux o navegador. Se liberaron únicamente cachés regenerables de compilación incremental, sin borrar fuentes ni evidencia.

## Pendientes para la siguiente IA

1. **PG-S.02.11:** consolidar conformidad contra el corpus actual. Los intentos finales registraron `SEE-PROTOCOL: adapter timeout or EOF` y `SEE-STALE: engine evidence corpus hash mismatch for LANG.TYPES.DICTIONARY`. El adaptador precompilado arranca en 0,38 s mediante Cargo cuando se prueba aisladamente. Revisar la evidencia histórica combinada por `see_cli/src/conformance.rs` y `property_execution`, especialmente `results/engine.json` y `results/properties-engine.json`; conservar copias antes de regenerar. No se aumentaron timeouts. Los logs previos verdes y los fallidos se conservan por separado.
2. **PG-S.03.07:** terminar un millón de muestras para atan2, log2 y log10 con la misma semilla y los mismos argumentos ya generados. Los tres primeros millones están respaldados por `math-million-partial.json` y el log final. La terminación fue solicitada por la persona, no una discrepancia detectada. No dar por completo el contraste ni sustituir el esperado por los resultados del motor.
3. **PG-S.03.11:** resolver la consolidación de conformidad, revisar los verificadores del código final y documentar los resultados finales. La medición ya está ejecutada en `perf-current-readonly-final`; no es necesario repetirla sin un cambio de código que lo justifique. El objetivo absoluto AOT y la estacionariedad no quedaron certificados; también fallaban en la base y no se deben convertir en verde por documentación.
4. Tras completar lo anterior, marcar esas tres casillas, cerrar únicamente ambas fases solicitadas, preparar commits con la skill `commit-message` y hacer push ordinario comprobado a la misma rama. No iniciar PG-S.04–.09 ni declarar soporte nativo pendiente de PG-N.08.

Comandos orientativos para continuar, únicamente cuando la persona vuelva a autorizar pruebas:

```bash
cd packages/pseudolearn_spec
target/release/see math-check --only atan2,log2,log10 --input results/pg-s-02-03-2026-11-04/math-million
```

El informe de ese comando solo cubrirá las tres funciones pendientes. Conservarlo junto con la evidencia parcial de las tres ya completadas y comprobar hashes antes de consolidar un informe conjunto. Los binarios del oráculo y del sondeo usados se conservan en la carpeta `binaries` de la evidencia. El comando `math-check` escribe `results/r5-math-contrast.json`; copiarlo antes de otra ejecución.

```bash
cd packages/pseudolearn_engine
cargo build --release --locked --offline -p pseudolearn_conformance --bin conformance_adapter
```

Compilar el adaptador solo: combinarlo con el benchmark puede unificar características nativas y obligar al lanzamiento posterior a reconstruir otra variante. Esto puede superar el timeout de arranque. No repetir todos los tests del monorepo; retomar las comprobaciones dirigidas pendientes.


## Matriz de los 22 puntos

| Punto | Implementación y evidencia |
|---|---|
| PG-S.02.01 | Lecturas de corpus/README/reglas y registro de capas; PS-V-05–PS-V-08 resueltas arriba. |
| PG-S.02.02 | Alternativa A validada por `collection_sort`, `collection_sort_tests` y límite de combustible; excepción de orden autorizada arriba. |
| PG-S.02.03 | Reglas VECTOR R4/R5 y DICTIONARY R4; vocabulario, diagnósticos e instrucciones normativas. |
| PG-S.02.04 | VECTOR C12–C27 y DICTIONARY C11–C14, ambos perfiles, más propiedades sembradas. |
| PG-S.02.05 | Tests de semantic, lowering, runtime, API y consumidores; GC forzado en ambos gemelos. |
| PG-S.02.06 | Miembros contextuales, mezcla sintetizada, primitivas de montón y carga/ejecución de VM. |
| PG-S.02.07 | Inventario explícito de operaciones no soportadas, rechazo de build y vínculos pendientes PG-N.08. |
| PG-S.02.08 | Cinco fichas bilingües; identidad `collection_operation`; mezcla sin pasos internos, comparador observable. |
| PG-S.02.09 | Servicio y gramática generada; proyección app y bloqueo explícito de exportaciones sin equivalencia fiel. |
| PG-S.02.10 | README de cada dueño modificado; decisiones DS-07–DS-11 autosuficientes. |
| PG-S.02.11 | **Pendiente:** consolidación de conformidad actual; el resto de evidencia se conserva. |
| PG-S.03.01 | Lecturas de matemática, redondeo, firmas, biblioteca, sondeo y oráculo; PS-V-03/PS-V-05 resueltas. |
| PG-S.03.02 | Oráculo racional de seis funciones; negativo que altera log2(1) y detecta el desacuerdo. |
| PG-S.03.03 | Diez entradas D1, `widestNumeric`, MATH R2/R3 y ROUNDING R2; vocabulario no reservado. |
| PG-S.03.04 | Casos notables, ceros, dominios, mezclas, i64 y propiedad MATH P1 con vínculo/esquema/ejecutor. |
| PG-S.03.05 | Tests espejo de biblioteca, tipos, RI, API, errores y tramos; casos bilingües del corpus. |
| PG-S.03.06 | Intervalos y Ziv, rutas exactas previas, RI, lowering, bytecode y despacho escalar compacto. |
| PG-S.03.07 | Seis millones de resultados del motor y 266 extremos; contraste independiente de tres millones completado. Pendiente: atan2/log2/log10. |
| PG-S.03.08 | Rechazo explícito de las doce operaciones numéricas de RI; vínculos nativos pendientes PG-N.08. |
| PG-S.03.09 | Diez fichas bilingües y consumidores; trascendentes sin equivalente exportable con garantía de último bit. |
| PG-S.03.10 | README de biblioteca, RI, VM, semantic, lowering y SEE actualizados en el mismo cambio. |
| PG-S.03.11 | **Pendiente:** contraste restante y consolidación de verificaciones; campañas VM/AOT ya ejecutadas con sus límites explícitos. |

## Responsabilidad y dependencias por archivo

Cada archivo permanece en su dueño existente. Los módulos nuevos separan comprobación semántica,
construcción de mezcla, consultas, primitivas de montón, evaluación escalar y comparación racional.
Las capas pueden importar de sí mismas y de la lista indicada; las demás capas están prohibidas.
La tabla registra el límite arquitectónico; tests y README pertenecen al mismo dueño de su código.

| Archivo | Dueño/capa | Puede importar | Responsabilidad |
|---|---|---|---|
| `apps/pseudolearn_app/README.md` | documentación app | no importa código | Documentar equivalencia de exportación |
| `apps/pseudolearn_app/lib/engine/rust/export/export_coverage.dart` | app/engine | model, ports | Rechazar exportaciones sin equivalencia fiel |
| `apps/pseudolearn_app/lib/engine/rust/rust_program_view_wire_semantics.dart` | app/engine | model, ports | Proyectar identidad semántica de colección |
| `apps/pseudolearn_app/lib/engine/rust/rust_view_semantics.dart` | app/engine | model, ports | Proyectar identidad semántica de colección |
| `apps/pseudolearn_app/test/engine/rust/export/rust_program_exporter_availability_test.dart` | app/engine | model, ports | Verificar rechazar exportaciones sin equivalencia fiel |
| `apps/pseudolearn_app/test/engine/rust/rust_view_semantics_test.dart` | app/engine | model, ports | Verificar proyectar identidad semántica de colección |
| `apps/pseudolearn_vscode/media/pseudolearn.tmLanguage.json` | media generado | no importa código | Resaltar identidades derivadas del corpus |
| `docs/plan-ejecucion-proposito-general/fase-pg-s-plan-ejecucion.md` | documentación transitoria | documentación y evidencia | Registrar alcance, decisiones y resultados |
| `docs/plan-ejecucion-proposito-general/informe-pg-s-02-03.md` | documentación transitoria | documentación y evidencia | Registrar alcance, decisiones y resultados |
| `packages/pseudolearn_engine/conformance-aot.yaml` | datos del miembro | no importa código | Declarar vínculos de conformidad o esquema |
| `packages/pseudolearn_engine/conformance.yaml` | datos del miembro | no importa código | Declarar vínculos de conformidad o esquema |
| `packages/pseudolearn_engine/crates/pseudolearn_abi/README.md` | pseudolearn_abi | ninguna otra capa | Documentar arquitectura y decisiones del dueño |
| `packages/pseudolearn_engine/crates/pseudolearn_abi/src/collection_command.rs` | pseudolearn_abi | ninguna otra capa | Codificar órdenes internas de colección |
| `packages/pseudolearn_engine/crates/pseudolearn_api/README.md` | pseudolearn_api | pseudolearn_api, pseudolearn_source, pseudolearn_project, pseudolearn_abi, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_ir, pseudolearn_lowering, pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_vm, pseudolearn_timeline, pseudolearn_service, pseudolearn_codegen, pseudolearn_aot_rt | Documentar arquitectura y decisiones del dueño |
| `packages/pseudolearn_engine/crates/pseudolearn_api/src/program_view_annotations.rs` | pseudolearn_api | pseudolearn_api, pseudolearn_source, pseudolearn_project, pseudolearn_abi, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_ir, pseudolearn_lowering, pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_vm, pseudolearn_timeline, pseudolearn_service, pseudolearn_codegen, pseudolearn_aot_rt | Proyectar identidades semánticas de llamadas |
| `packages/pseudolearn_engine/crates/pseudolearn_api/tests/collection_execution.rs` | pseudolearn_api | pseudolearn_api, pseudolearn_source, pseudolearn_project, pseudolearn_abi, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_ir, pseudolearn_lowering, pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_vm, pseudolearn_timeline, pseudolearn_service, pseudolearn_codegen, pseudolearn_aot_rt | Contrastar casos bilingües, límites y gemelos |
| `packages/pseudolearn_engine/crates/pseudolearn_api/tests/collection_sort.rs` | pseudolearn_api | pseudolearn_api, pseudolearn_source, pseudolearn_project, pseudolearn_abi, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_ir, pseudolearn_lowering, pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_vm, pseudolearn_timeline, pseudolearn_service, pseudolearn_codegen, pseudolearn_aot_rt | Construir la función estable de ordenación |
| `packages/pseudolearn_engine/crates/pseudolearn_api/tests/collection_sort_properties.rs` | pseudolearn_api | pseudolearn_api, pseudolearn_source, pseudolearn_project, pseudolearn_abi, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_ir, pseudolearn_lowering, pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_vm, pseudolearn_timeline, pseudolearn_service, pseudolearn_codegen, pseudolearn_aot_rt | Contrastar estabilidad y conservación de valores |
| `packages/pseudolearn_engine/crates/pseudolearn_api/tests/extended_math.rs` | pseudolearn_api | pseudolearn_api, pseudolearn_source, pseudolearn_project, pseudolearn_abi, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_ir, pseudolearn_lowering, pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_vm, pseudolearn_timeline, pseudolearn_service, pseudolearn_codegen, pseudolearn_aot_rt | Verificar ejecución matemática |
| `packages/pseudolearn_engine/crates/pseudolearn_api/tests/program_view_collections.rs` | pseudolearn_api | pseudolearn_api, pseudolearn_source, pseudolearn_project, pseudolearn_abi, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_ir, pseudolearn_lowering, pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_vm, pseudolearn_timeline, pseudolearn_service, pseudolearn_codegen, pseudolearn_aot_rt | Verificar identidades de colección en la vista |
| `packages/pseudolearn_engine/crates/pseudolearn_bytecode/README.md` | pseudolearn_bytecode | pseudolearn_ir, pseudolearn_source | Documentar arquitectura y decisiones del dueño |
| `packages/pseudolearn_engine/crates/pseudolearn_bytecode/src/roots.rs` | pseudolearn_bytecode | pseudolearn_ir, pseudolearn_source | Declarar puntos seguros con raíces vivas |
| `packages/pseudolearn_engine/crates/pseudolearn_codegen/README.md` | pseudolearn_codegen | pseudolearn_ir, pseudolearn_diagnostics, pseudolearn_aot_rt | Documentar arquitectura y decisiones del dueño |
| `packages/pseudolearn_engine/crates/pseudolearn_codegen/src/instruction_dispatch.rs` | pseudolearn_codegen | pseudolearn_ir, pseudolearn_diagnostics, pseudolearn_aot_rt | Inventariar soporte nativo por operación |
| `packages/pseudolearn_engine/crates/pseudolearn_codegen/src/task_support.rs` | pseudolearn_codegen | pseudolearn_ir, pseudolearn_diagnostics, pseudolearn_aot_rt | Clasificar operaciones que requieren tareas nativas |
| `packages/pseudolearn_engine/crates/pseudolearn_ir/README.md` | pseudolearn_ir | pseudolearn_source, pseudolearn_abi | Documentar arquitectura y decisiones del dueño |
| `packages/pseudolearn_engine/crates/pseudolearn_ir/src/collection_types.rs` | pseudolearn_ir | pseudolearn_source, pseudolearn_abi | Definir el contrato tipado de colección |
| `packages/pseudolearn_engine/crates/pseudolearn_ir/src/type_checker.rs` | pseudolearn_ir | pseudolearn_source, pseudolearn_abi | Coordinar verificación de tipos de RI |
| `packages/pseudolearn_engine/crates/pseudolearn_ir/src/type_checker_dynamic_collections.rs` | pseudolearn_ir | pseudolearn_source, pseudolearn_abi | Verificar operandos de colecciones dinámicas |
| `packages/pseudolearn_engine/crates/pseudolearn_ir/src/type_checker_intrinsics.rs` | pseudolearn_ir | pseudolearn_source, pseudolearn_abi | Verificar operandos de operaciones numéricas |
| `packages/pseudolearn_engine/crates/pseudolearn_ir/tests/catalog_tests.rs` | pseudolearn_ir | pseudolearn_source, pseudolearn_abi | Verificar integridad del inventario de RI |
| `packages/pseudolearn_engine/crates/pseudolearn_ir/tests/type_checker_intrinsics_tests.rs` | pseudolearn_ir | pseudolearn_source, pseudolearn_abi | Rechazar tipos de RI incompatibles |
| `packages/pseudolearn_engine/crates/pseudolearn_library/README.md` | pseudolearn_library | pseudolearn_runtime, pseudolearn_diagnostics | Documentar arquitectura y decisiones del dueño |
| `packages/pseudolearn_engine/crates/pseudolearn_library/src/collections.rs` | pseudolearn_library | pseudolearn_runtime, pseudolearn_diagnostics | Despachar operaciones internas de colección |
| `packages/pseudolearn_engine/crates/pseudolearn_library/src/lib.rs` | pseudolearn_library | pseudolearn_runtime, pseudolearn_diagnostics | Declarar la frontera y composición del módulo |
| `packages/pseudolearn_engine/crates/pseudolearn_library/src/rounding.rs` | pseudolearn_library | pseudolearn_runtime, pseudolearn_diagnostics | Producir enteros comprobados al redondear |
| `packages/pseudolearn_engine/crates/pseudolearn_library/src/transcendental/arctangent.rs` | pseudolearn_library | pseudolearn_runtime, pseudolearn_diagnostics | Encerrar arcotangente por reducción |
| `packages/pseudolearn_engine/crates/pseudolearn_library/src/transcendental/extended.rs` | pseudolearn_library | pseudolearn_runtime, pseudolearn_diagnostics | Evaluar trascendentes con intervalos de precisión variable |
| `packages/pseudolearn_engine/crates/pseudolearn_library/src/transcendental/logarithm_base.rs` | pseudolearn_library | pseudolearn_runtime, pseudolearn_diagnostics | Encerrar logaritmos de base fija |
| `packages/pseudolearn_engine/crates/pseudolearn_library/src/transcendental/mod.rs` | pseudolearn_library | pseudolearn_runtime, pseudolearn_diagnostics | Declarar la frontera y composición del módulo |
| `packages/pseudolearn_engine/crates/pseudolearn_library/src/transcendental/trigonometric.rs` | pseudolearn_library | pseudolearn_runtime, pseudolearn_diagnostics | Encerrar seno y coseno reducidos |
| `packages/pseudolearn_engine/crates/pseudolearn_library/tests/extended_math_tests.rs` | pseudolearn_library | pseudolearn_runtime, pseudolearn_diagnostics | Verificar dominios, ceros y resultados exactos |
| `packages/pseudolearn_engine/crates/pseudolearn_lowering/README.md` | pseudolearn_lowering | pseudolearn_source, pseudolearn_semantic, pseudolearn_ir, pseudolearn_diagnostics | Documentar arquitectura y decisiones del dueño |
| `packages/pseudolearn_engine/crates/pseudolearn_lowering/src/collection_builder.rs` | pseudolearn_lowering | pseudolearn_source, pseudolearn_semantic, pseudolearn_ir, pseudolearn_diagnostics | Construir instrucciones de auxiliares de colección |
| `packages/pseudolearn_engine/crates/pseudolearn_lowering/src/collection_extensions.rs` | pseudolearn_lowering | pseudolearn_source, pseudolearn_semantic, pseudolearn_ir, pseudolearn_diagnostics | Bajar miembros contextuales a RI |
| `packages/pseudolearn_engine/crates/pseudolearn_lowering/src/collection_merge.rs` | pseudolearn_lowering | pseudolearn_source, pseudolearn_semantic, pseudolearn_ir, pseudolearn_diagnostics | Emitir pasos de mezcla estable |
| `packages/pseudolearn_engine/crates/pseudolearn_lowering/src/collection_optional.rs` | pseudolearn_lowering | pseudolearn_source, pseudolearn_semantic, pseudolearn_ir, pseudolearn_diagnostics | Construir resultados opcionales de búsqueda |
| `packages/pseudolearn_engine/crates/pseudolearn_lowering/src/collection_queries.rs` | pseudolearn_lowering | pseudolearn_source, pseudolearn_semantic, pseudolearn_ir, pseudolearn_diagnostics | Construir consultas lineales y copias de claves |
| `packages/pseudolearn_engine/crates/pseudolearn_lowering/src/collection_sort.rs` | pseudolearn_lowering | pseudolearn_source, pseudolearn_semantic, pseudolearn_ir, pseudolearn_diagnostics | Construir la función estable de ordenación |
| `packages/pseudolearn_engine/crates/pseudolearn_lowering/src/collection_sort_tests.rs` | pseudolearn_lowering | pseudolearn_source, pseudolearn_semantic, pseudolearn_ir, pseudolearn_diagnostics | Verificar observaciones de la mezcla sintetizada |
| `packages/pseudolearn_engine/crates/pseudolearn_lowering/src/collections.rs` | pseudolearn_lowering | pseudolearn_source, pseudolearn_semantic, pseudolearn_ir, pseudolearn_diagnostics | Despachar operaciones internas de colección |
| `packages/pseudolearn_engine/crates/pseudolearn_lowering/src/expressions_builtins.rs` | pseudolearn_lowering | pseudolearn_source, pseudolearn_semantic, pseudolearn_ir, pseudolearn_diagnostics | Bajar incorporadas numéricas a RI |
| `packages/pseudolearn_engine/crates/pseudolearn_lowering/src/lib.rs` | pseudolearn_lowering | pseudolearn_source, pseudolearn_semantic, pseudolearn_ir, pseudolearn_diagnostics | Declarar la frontera y composición del módulo |
| `packages/pseudolearn_engine/crates/pseudolearn_math_probe/README.md` | pseudolearn_math_probe | pseudolearn_library | Documentar arquitectura y decisiones del dueño |
| `packages/pseudolearn_engine/crates/pseudolearn_math_probe/src/lib.rs` | pseudolearn_math_probe | pseudolearn_library | Declarar la frontera y composición del módulo |
| `packages/pseudolearn_engine/crates/pseudolearn_math_probe/tests/lib_tests.rs` | pseudolearn_math_probe | pseudolearn_library | Verificar intercambio y rechazo de argumentos |
| `packages/pseudolearn_engine/crates/pseudolearn_runtime/README.md` | pseudolearn_runtime | pseudolearn_runtime, pseudolearn_abi, pseudolearn_diagnostics | Documentar arquitectura y decisiones del dueño |
| `packages/pseudolearn_engine/crates/pseudolearn_runtime/src/collection/mod.rs` | pseudolearn_runtime | pseudolearn_runtime, pseudolearn_abi, pseudolearn_diagnostics | Declarar la frontera y composición del módulo |
| `packages/pseudolearn_engine/crates/pseudolearn_runtime/src/collection/reorder.rs` | pseudolearn_runtime | pseudolearn_runtime, pseudolearn_abi, pseudolearn_diagnostics | Ejecutar primitivas atómicas de reordenación |
| `packages/pseudolearn_engine/crates/pseudolearn_runtime/src/lib.rs` | pseudolearn_runtime | pseudolearn_runtime, pseudolearn_abi, pseudolearn_diagnostics | Declarar la frontera y composición del módulo |
| `packages/pseudolearn_engine/crates/pseudolearn_runtime/src/vector.rs` | pseudolearn_runtime | pseudolearn_runtime, pseudolearn_abi, pseudolearn_diagnostics | Aplicar mutaciones de vector con sus invariantes |
| `packages/pseudolearn_engine/crates/pseudolearn_runtime/tests/collection_reorder.rs` | pseudolearn_runtime | pseudolearn_runtime, pseudolearn_abi, pseudolearn_diagnostics | Verificar confirmación e identidad de vectores |
| `packages/pseudolearn_engine/crates/pseudolearn_semantic/README.md` | pseudolearn_semantic | pseudolearn_abi, pseudolearn_source, pseudolearn_project, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax | Documentar arquitectura y decisiones del dueño |
| `packages/pseudolearn_engine/crates/pseudolearn_semantic/src/builtin_checker.rs` | pseudolearn_semantic | pseudolearn_abi, pseudolearn_source, pseudolearn_project, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax | Seleccionar tipos de incorporadas numéricas |
| `packages/pseudolearn_engine/crates/pseudolearn_semantic/src/collection_checker.rs` | pseudolearn_semantic | pseudolearn_abi, pseudolearn_source, pseudolearn_project, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax | Comprobar usos y mutaciones de colecciones |
| `packages/pseudolearn_engine/crates/pseudolearn_semantic/src/collection_extensions.rs` | pseudolearn_semantic | pseudolearn_abi, pseudolearn_source, pseudolearn_project, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax | Comprobar miembros contextuales |
| `packages/pseudolearn_engine/crates/pseudolearn_semantic/src/collection_model.rs` | pseudolearn_semantic | pseudolearn_abi, pseudolearn_source, pseudolearn_project, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax | Representar acciones de colección tipadas |
| `packages/pseudolearn_engine/crates/pseudolearn_semantic/src/lib.rs` | pseudolearn_semantic | pseudolearn_abi, pseudolearn_source, pseudolearn_project, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax | Declarar la frontera y composición del módulo |
| `packages/pseudolearn_engine/crates/pseudolearn_semantic/tests/builtin_checker_extensions.rs` | pseudolearn_semantic | pseudolearn_abi, pseudolearn_source, pseudolearn_project, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax | Verificar precisión y ampliación de extremos |
| `packages/pseudolearn_engine/crates/pseudolearn_semantic/tests/collection_extensions.rs` | pseudolearn_semantic | pseudolearn_abi, pseudolearn_source, pseudolearn_project, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax | Verificar contratos de miembros nuevos |
| `packages/pseudolearn_engine/crates/pseudolearn_service/README.md` | pseudolearn_service | pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_project | Documentar arquitectura y decisiones del dueño |
| `packages/pseudolearn_engine/crates/pseudolearn_service/src/completion_collections.rs` | pseudolearn_service | pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_project | Completar miembros según el tipo receptor |
| `packages/pseudolearn_engine/crates/pseudolearn_service/src/completion_members.rs` | pseudolearn_service | pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_project | Resolver proveedores de miembros completables |
| `packages/pseudolearn_engine/crates/pseudolearn_service/src/contextual_tokens.rs` | pseudolearn_service | pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_project | Resolver identidades léxicas contextuales |
| `packages/pseudolearn_engine/crates/pseudolearn_service/src/help_resolution/context.rs` | pseudolearn_service | pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_project | Seleccionar la ficha exacta por identidad semántica |
| `packages/pseudolearn_engine/crates/pseudolearn_service/src/lib.rs` | pseudolearn_service | pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_project | Declarar la frontera y composición del módulo |
| `packages/pseudolearn_engine/crates/pseudolearn_service/src/type_names.rs` | pseudolearn_service | pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_project | Presentar nombres de tipo en cada perfil |
| `packages/pseudolearn_engine/crates/pseudolearn_service/tests/completion.rs` | pseudolearn_service | pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_project | Verificar candidatos de completado |
| `packages/pseudolearn_engine/crates/pseudolearn_service/tests/contextual_tokens.rs` | pseudolearn_service | pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_project | Resolver identidades léxicas contextuales |
| `packages/pseudolearn_engine/crates/pseudolearn_service/tests/help_extensions.rs` | pseudolearn_service | pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_project | Verificar fichas bilingües y homónimos |
| `packages/pseudolearn_engine/crates/pseudolearn_service/tests/help_resolution.rs` | pseudolearn_service | pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax, pseudolearn_semantic, pseudolearn_project | Verificar resolución de fichas de ayuda |
| `packages/pseudolearn_engine/crates/pseudolearn_vm/README.md` | pseudolearn_vm | pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_diagnostics, pseudolearn_vm_dispatch | Documentar arquitectura y decisiones del dueño |
| `packages/pseudolearn_engine/crates/pseudolearn_vm/data/dispatch_forms.json` | pseudolearn_vm | pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_diagnostics, pseudolearn_vm_dispatch | Declarar formas compactas de despacho |
| `packages/pseudolearn_engine/crates/pseudolearn_vm/src/evaluate/extended_math.rs` | pseudolearn_vm | pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_diagnostics, pseudolearn_vm_dispatch | Adaptar operaciones numéricas a palabras de VM |
| `packages/pseudolearn_engine/crates/pseudolearn_vm/src/evaluate/mathematics.rs` | pseudolearn_vm | pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_diagnostics, pseudolearn_vm_dispatch | Exponer evaluación matemática de VM |
| `packages/pseudolearn_engine/crates/pseudolearn_vm/src/evaluate/mod.rs` | pseudolearn_vm | pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_diagnostics, pseudolearn_vm_dispatch | Declarar la frontera y composición del módulo |
| `packages/pseudolearn_engine/crates/pseudolearn_vm/src/load/extended_scalar.rs` | pseudolearn_vm | pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_diagnostics, pseudolearn_vm_dispatch | Decodificar sitios escalares tipados |
| `packages/pseudolearn_engine/crates/pseudolearn_vm/src/load/init.rs` | pseudolearn_vm | pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_diagnostics, pseudolearn_vm_dispatch | Inicializar metadatos de funciones cargadas |
| `packages/pseudolearn_engine/crates/pseudolearn_vm/src/load/instructions.rs` | pseudolearn_vm | pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_diagnostics, pseudolearn_vm_dispatch | Clasificar instrucciones al cargarlas |
| `packages/pseudolearn_engine/crates/pseudolearn_vm/src/load/mod.rs` | pseudolearn_vm | pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_diagnostics, pseudolearn_vm_dispatch | Declarar la frontera y composición del módulo |
| `packages/pseudolearn_engine/crates/pseudolearn_vm/src/load/model.rs` | pseudolearn_vm | pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_diagnostics, pseudolearn_vm_dispatch | Representar funciones y sitios cargados |
| `packages/pseudolearn_engine/crates/pseudolearn_vm/src/machine/calls.rs` | pseudolearn_vm | pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_diagnostics, pseudolearn_vm_dispatch | Gestionar marcos visibles de llamadas |
| `packages/pseudolearn_engine/crates/pseudolearn_vm/src/machine/collection_frames.rs` | pseudolearn_vm | pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_diagnostics, pseudolearn_vm_dispatch | Resolver profundidad y tramo visibles |
| `packages/pseudolearn_engine/crates/pseudolearn_vm/src/machine/collections.rs` | pseudolearn_vm | pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_diagnostics, pseudolearn_vm_dispatch | Despachar operaciones internas de colección |
| `packages/pseudolearn_engine/crates/pseudolearn_vm/src/machine/extended_scalar.rs` | pseudolearn_vm | pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_diagnostics, pseudolearn_vm_dispatch | Ejecutar sitios escalares tipados |
| `packages/pseudolearn_engine/crates/pseudolearn_vm/src/machine/fault_context.rs` | pseudolearn_vm | pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_diagnostics, pseudolearn_vm_dispatch | Atribuir fallos a su fuente y perfil |
| `packages/pseudolearn_engine/crates/pseudolearn_vm/src/machine/mod.rs` | pseudolearn_vm | pseudolearn_bytecode, pseudolearn_runtime, pseudolearn_library, pseudolearn_diagnostics, pseudolearn_vm_dispatch | Declarar la frontera y composición del módulo |
| `packages/pseudolearn_spec/README.md` | datos del miembro | no importa código | Documentar arquitectura del miembro |
| `packages/pseudolearn_spec/crates/see_cli/README.md` | see_cli | see_model, see_format, see_graph, see_change, see_validation, see_conformance, see_report, see_export, see_translation | Documentar arquitectura y decisiones del dueño |
| `packages/pseudolearn_spec/crates/see_cli/src/math_contrast.rs` | see_cli | see_model, see_format, see_graph, see_change, see_validation, see_conformance, see_report, see_export, see_translation | Conducir archivos y emitir veredictos matemáticos |
| `packages/pseudolearn_spec/crates/see_cli/src/math_verdicts.rs` | see_cli | see_model, see_format, see_graph, see_change, see_validation, see_conformance, see_report, see_export, see_translation | Contrastar resultados binarios con el oráculo |
| `packages/pseudolearn_spec/crates/see_cli/src/math_verdicts_tests.rs` | see_cli | see_model, see_format, see_graph, see_change, see_validation, see_conformance, see_report, see_export, see_translation | Detectar resultados alterados deliberadamente |
| `packages/pseudolearn_spec/crates/see_conformance/README.md` | see_conformance | see_model, see_translation, see_format, see_generators, see_oracles | Documentar arquitectura y decisiones del dueño |
| `packages/pseudolearn_spec/crates/see_conformance/src/lib.rs` | see_conformance | see_model, see_translation, see_format, see_generators, see_oracles | Declarar la frontera y composición del módulo |
| `packages/pseudolearn_spec/crates/see_conformance/src/math_arguments.rs` | see_conformance | see_model, see_translation, see_format, see_generators, see_oracles | Generar argumentos matemáticos por semilla |
| `packages/pseudolearn_spec/crates/see_conformance/src/math_contrast.rs` | see_conformance | see_model, see_translation, see_format, see_generators, see_oracles | Derivar resultados matemáticos independientes |
| `packages/pseudolearn_spec/crates/see_conformance/src/properties.rs` | see_conformance | see_model, see_translation, see_format, see_generators, see_oracles | Preparar escenarios de propiedades |
| `packages/pseudolearn_spec/crates/see_conformance/src/property_comparison.rs` | see_conformance | see_model, see_translation, see_format, see_generators, see_oracles | Seleccionar la comparación de propiedades |
| `packages/pseudolearn_spec/crates/see_conformance/src/property_math.rs` | see_conformance | see_model, see_translation, see_format, see_generators, see_oracles | Construir escenarios con esperado racional independiente |
| `packages/pseudolearn_spec/crates/see_model/README.md` | see_model | ninguna otra capa | Documentar arquitectura y decisiones del dueño |
| `packages/pseudolearn_spec/crates/see_model/src/properties.rs` | see_model | ninguna otra capa | Declarar ejecutores de propiedades |
| `packages/pseudolearn_spec/crates/see_oracles/README.md` | see_oracles | ninguna otra capa | Documentar arquitectura y decisiones del dueño |
| `packages/pseudolearn_spec/crates/see_oracles/src/bounded_series.rs` | see_oracles | ninguna otra capa | Encerrar series racionales con redondeo hacia afuera |
| `packages/pseudolearn_spec/crates/see_oracles/src/extended.rs` | see_oracles | ninguna otra capa | Encerrar trascendentes racionales |
| `packages/pseudolearn_spec/crates/see_oracles/src/interval.rs` | see_oracles | ninguna otra capa | Operar intervalos racionales exactos |
| `packages/pseudolearn_spec/crates/see_oracles/src/interval_tests.rs` | see_oracles | ninguna otra capa | Verificar extremos y signos de intervalos |
| `packages/pseudolearn_spec/crates/see_oracles/src/lib.rs` | see_oracles | ninguna otra capa | Declarar la frontera y composición del módulo |
| `packages/pseudolearn_spec/crates/see_oracles/src/mathematics.rs` | see_oracles | ninguna otra capa | Refinar intervalos hasta decidir un binario64 |
| `packages/pseudolearn_spec/crates/see_oracles/src/series.rs` | see_oracles | ninguna otra capa | Evaluar series elementales racionales |
| `packages/pseudolearn_spec/crates/see_oracles/src/small_angle.rs` | see_oracles | ninguna otra capa | Decidir redondeos mediante restos analíticos |
| `packages/pseudolearn_spec/crates/see_oracles/src/transcendentals.rs` | see_oracles | ninguna otra capa | Encerrar funciones reducidas con constantes racionales |
| `packages/pseudolearn_spec/crates/see_oracles/tests/extended.rs` | see_oracles | ninguna otra capa | Encerrar trascendentes racionales |
| `packages/pseudolearn_spec/crates/see_validation/README.md` | see_validation | see_model, see_graph, see_change, see_format | Documentar arquitectura y decisiones del dueño |
| `packages/pseudolearn_spec/crates/see_validation/src/resources/lexicon.rs` | see_validation | see_model, see_graph, see_change, see_format | Validar clases y firmas del catálogo |
| `packages/pseudolearn_spec/crates/see_validation/tests/resources/help_catalog/coverage.rs` | see_validation | see_model, see_graph, see_change, see_format | Verificar la matriz normativa de ayuda |
| `packages/pseudolearn_spec/property-conformance.json` | datos del miembro | no importa código | Declarar vínculos de conformidad o esquema |
| `packages/pseudolearn_spec/schemas/properties-1.schema.json` | datos del miembro | no importa código | Declarar vínculos de conformidad o esquema |
| `packages/pseudolearn_spec/specifications/api/api.program.view.md` | corpus | identidades internas del corpus | Especificar api.program.view |
| `packages/pseudolearn_spec/specifications/cases/catalogs.json` | artefacto generado | identidades internas del corpus | Exportar recursos normativos |
| `packages/pseudolearn_spec/specifications/cases/vocabulary.json` | artefacto generado | identidades internas del corpus | Exportar recursos normativos |
| `packages/pseudolearn_spec/specifications/diag/diag.catalog.md` | corpus | identidades internas del corpus | Especificar diag.catalog |
| `packages/pseudolearn_spec/specifications/ir/ir.instructions.md` | corpus | identidades internas del corpus | Especificar ir.instructions |
| `packages/pseudolearn_spec/specifications/lang/lang.profile.vocabulary.md` | corpus | identidades internas del corpus | Especificar lang.profile.vocabulary |
| `packages/pseudolearn_spec/specifications/lang/lang.types.dictionary.md` | corpus | identidades internas del corpus | Especificar lang.types.dictionary |
| `packages/pseudolearn_spec/specifications/lang/lang.types.vector.md` | corpus | identidades internas del corpus | Especificar lang.types.vector |
| `packages/pseudolearn_spec/specifications/lib/lib.core.math.md` | corpus | identidades internas del corpus | Especificar lib.core.math |
| `packages/pseudolearn_spec/specifications/lib/lib.core.rounding.md` | corpus | identidades internas del corpus | Especificar lib.core.rounding |
| `packages/pseudolearn_spec/specifications/lib/lib.model.md` | corpus | identidades internas del corpus | Especificar lib.model |
| `packages/pseudolearn_spec/specifications/tool/tool.service.catalog.md` | corpus | identidades internas del corpus | Especificar tool.service.catalog |
