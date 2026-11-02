# Fase PG-B · App y tareas observables — plan de ejecución

## 0. Metadatos y contrato de ejecución

- Origen: §4.11 del [plan general](plan-ejecucion-proposito-general.md); ADR-03/12/13, R-09–R-13/R-19/R-20, C-15, K-18/K-19 y E-PG-12 de la [hoja de ruta](../hoja-de-ruta-proposito-general.md).
- Fecha de preparación: 2026-11-02, America/Lima.
- Revisión inspeccionada: `5a0e12ae95d4f0a84743180e2a98f83a4423a16e`.
- Rama comprobada: `feature/agregar-ruta-de-especificacion`; árbol limpio antes de preparar el plan.
- Petición: «Crea el plan de ejecución detallado para `4.11 PG-B · App y tareas observables` como para que ninguna IA que lo ejecute pueda darse chance de alucinar».
- Estado al redactar: la autorización cubría redactar este plan y enlazarlo desde el plan general, no su implementación ni la revisión C02. Instrucciones directas posteriores autorizaron una iteración de PG-B.01, PG-B.02 y PG-B.03; el 2026-11-02 se autorizó una sola iteración de PG-B.04, otra de PG-B.05 y PG-B.07 conjuntas, otra de PG-B.06 y otra de PG-B.08 y PG-B.09 conjuntas, sin preguntas y eligiendo la opción recomendada. Cada autorización se limita a su punto; no habilita los demás puntos, C02, commit, push, instalación ni inicio de PG-7.
- Documento transitorio: ninguna especificación, README ni código fuera de `docs/` podrá citarlo (`DOC-NO-TRANSIENT-REFS`). Las decisiones se trasladan a sus dueños en el mismo cambio (`DOC-README-TRUTH`, `DOC-NO-ORPHAN-DECISION`).

### 0.1 Reglas para quien ejecute

1. Antes de modificar, releer `AGENTS.md`, README y reglas del miembro y del crate afectado; comprobar rama, HEAD y diff. Si cambió HEAD, actualizar el inventario y distinguir hechos vigentes de esta fotografía. Conservar cambios ajenos.
2. Este plan distingue **existente comprobado**, **propuesta de implementación** y **carencia por verificar**. Los nombres propuestos de §5 no son clases, operaciones ni archivos existentes. No usar un nombre de esta guía como prueba de que una API lo admite.
3. Secuencia obligatoria por punto: contrato → casos con esperado derivado → tests que detectan la ausencia → implementación → README/reglas → verificaciones. Si el contrato ya cubre la conducta, documentar su reutilización; no inventar una regla nueva para justificar cada archivo.
4. Mantener por cada tarea una fila de §11 con HEAD/diff, reglas/casos, archivos, comandos, salida/código de salida, alcance y límites. «Se implementó», «parece funcionar» o un test que solo comprueba el mismo algoritmo no son evidencia suficiente.
5. No convertir datos ausentes en raíz/cero, éxito, lista vacía o estado aproximado. La raíz cero se usa únicamente donde el contrato lo establece. Desconocidos y errores esperables atraviesan el puerto como resultados tipados; no escapan `FormatException`, `StateError` ni fallos del transporte.
6. No deducir semántica con regex, texto de cabecera, orden de pintado, profundidad aislada o número de línea. Sí aplicar la atribución explícita de `ENG.TRACE.EVENTS#R8` sobre la secuencia íntegra de eventos.
7. Una discrepancia corpus/implementación no se arregla copiando la salida del motor al esperado. Una contradicción entre fuentes se informa con ID, texto y alcance, y se espera decisión para el trabajo dependiente (`CONFLICT-REPORT`). Puede continuarse trabajo independiente autorizado.
8. Cumplir `SPEC-VERSION-FREEZE`: conservar identidad, estado y versión, sin `cambio`; reanclar solamente los contratos modificados y revisados. Nunca asignarse revisión humana ni refrescar todo el corpus para ocultar deuda.
9. Al terminar el alcance autorizado, informar y parar (`PHASE-STOP`). Las puertas internas de §10 no son fases nuevas ni exigen confirmaciones rutinarias si la persona autorizó el conjunto; no amplían una autorización parcial.

## 1. Punto de partida comprobado

Rutas relativas a la raíz salvo indicación contraria. Esta sección describe inspección de fuentes, no una campaña de pruebas ejecutada para este plan.

### 1.1 Dependencias y puertas previas

| ID | Evidencia disponible | Tratamiento exigido |
|---|---|---|
| PB-PRE-01 | PG-B depende de PG-A, PG-3, PG-4 y PG-5. PG-A está cerrada por decisión expresa el 2026-11-02; PG-4 y PG-5 figuran cerradas; PG-3 sigue en curso en el resumen global | Para el alcance exacto de PG-B.01, la instrucción directa de implementación del 2026-11-02 resuelve avanzar con PG-3 abierta. No cierra PG-3 ni autoriza otros puntos |
| PB-PRE-02 | PG-A no declaró `PHASE-GREEN`: informó `SEE-HASH` en `API.ANALYZE`, `SEE-STALE` en conformidad engine, dos `SIZE-NESTING` Rust, suite completa Flutter no repetida y humo de plataforma pendiente | Reproducir línea base al iniciar; registrar errores vigentes, no presentarlos como comprobados hoy. Si impiden la puerta afectada, resolver dentro del alcance autorizado o informar bloqueo; no heredar un verde inexistente |
| PB-PRE-03 | La hoja de ruta emplea denominaciones históricas GP; PG-A registra edición oficial exclusivamente 2026 | Mantener edición 2026 y perfiles es/en existentes. No crear selector GP, migrador ni segunda gramática |
| PB-PRE-04 | `API.STATE.QUERY#R7` llamaba `task` al selector; `execution_queries.rs`, `state_pages.rs` y README de API utilizan `task_id` | Resuelto para PG-B.01 al aceptar la opción recomendada: conservar `task_id`, aclarar R7 y derivar casos de rechazo; `task` no se acepta como alias |
| PB-PRE-05 | README del motor contiene párrafos antiguos que llaman pendientes a cancelación/canales/efectos que su introducción describe integrados; API documenta integración y tiene tests específicos | No resolver la contradicción documental por intuición. Informarla; antes de comprometer una conducta, contrastar regla, caso y prueba real y registrar corrección autorizada en el README dueño |
| PB-PRE-06 | E-PG-12 humano quedó diferido por decisión del 2026-10-22 y el cierre de PG-A conserva ese diferimiento; evidencia estática excluye explícitamente tareas | Registrar el alcance literal del diferimiento al preparar la parte dinámica; no inventar participantes, volver a pedir conceptos ya aprobados ni trasladar métricas estáticas a esta fase. Si el alcance registrado no cubre el cierre dinámico, solicitar solo esa precisión |

Estos puntos son advertencias para implementación futura. No impiden redactar el plan pedido. La documentación histórica no autoriza corregir de oficio todas las fases previas.

### 1.2 Inventario real y brechas

| Dueño existente | Hecho inspeccionado | Consecuencia de PG-B |
|---|---|---|
| `apps/pseudolearn_app/lib/engine/rust/rust_event_classes.dart` | Nueve clases ordinarias y doce de tareas/canales/entrega; `RustTaskEvent` lee el mapa de datos | Reutilizar alfabeto vigente; tipar campos por clase y rechazar desconocidos sin fallback |
| `rust_wire_models.dart` en ese directorio | `RustEvent` conserva clase, línea, profundidad, datos y `nodeId`; no conserva la identidad completa de revisión. `PendingEffectRequest` tiene `taskId` con cero por defecto; `RustBatch` conserva lista de pendientes | Preservar identidad/revisión y distinguir campos obligatorios, compatibilidad y ausencia. No asumir que `termination` incluye `task_id`: `execution_wire.rs` no lo incluye en `awaiting_effect`; la lista sí tiene su contrato |
| `rust_focus_tracker.dart` / `rust_statement_stack.dart` | Un tracker conserva un único foco y una única pila; procesa entrada/salida, decisión, llamada/retorno | Segregar contexto por tarea; un cambio de tarea no apila una llamada de otra |
| `rust_program_execution.dart` | Una cola global; consume un evento por `step()`, pero precarga lotes de 25; un entorno/foco y un índice global; `provideInput(String)` y `stop()` sin destinatario | Mantener evento entregado separado de punta calculada y selección. Procesar todos los intermedios sin exponer estado futuro |
| `rust_state_api.dart` / `rust_watch_rows.dart` | Consultas sin selector de tarea; filas recorren marcos por profundidad; hay consulta de forma paginada de un elemento, no tabla completa paginada | Consumir consultas por tarea y rango; no usar `state` completo para después recortar la tabla |
| `domain/ports/program_execution.dart` | Cinco métodos y getter de salida; no hay puerto de observación de tareas/historia | Segregar puertos; no exceder cinco métodos públicos por clase para añadir todo al puerto existente |
| `application/execution/` | `ExecutionCubit`, `ExecutionState`, `StepSettlement`, `StepBatchRunner`; ritmos por foco/bloque y tope local 10000; cesión con `Future.delayed(Duration.zero)` entre lotes | Paso por evento y por tarea requieren comandos explícitos; no rebautizar `nextStatement` como evento. La cesión de UI no cambia el cuanto normativo |
| `rust_effect_gate.dart` | En automático puede resolver varias esperas y acumular sus eventos antes de entregarlos; en manual se detiene; exige primera secuencia FIFO del host simulado | Acotar bombeo; mostrar espera/entrega confirmadas. FIFO es política de este host, no restricción universal del motor |
| `rust_simulated_host.dart` / `SimulatedCapabilities` | Archivos/argumentos/reloj/temporizador en memoria; no hay guiones HTTP en este modelo; operación no atendida devuelve fallo | Añadir escenarios HTTP declarados si faltan, por el protocolo de efectos vigente; no afirmar que la UI actual ya simula HTTP ni recurrir a red |
| `domain/model/execution/effect_wait.dart` y `execution_step.dart` | Una espera y un foco agregados | Mantener compatibilidad secuencial, añadir identidades y colecciones de observación con dueños pequeños |
| `packages/pseudolearn_engine/crates/pseudolearn_api/src/execution_queries.rs` / `state_pages.rs` | Inspección de copia por `task_id`; cursor ligado a consulta, evento, tarea y generación; máximo 4096 | Reutilizar y probar por FRB; consulta no debe activar la tarea inspeccionada |
| `execution_state.rs` del mismo crate | `state` materializa marcos/objetos y, con hijas, resumen de tareas | No usar este camino sin límite para la ventana de cien tareas; verificar disponibilidad de resumen acotado en `debug_state` antes de pedir ampliación |
| `execution_debug.rs`, `history_operations.rs`, `debug_state.rs` y README de API | `history_events`, `debug_state` y control persistente existen; ventana de eventos y marcos hasta 4096; cursor y punta separados | Aprovechar consultas sin activar por accidente comandos de depuración, breakpoints ni retroceso de producto |
| `apps/pseudolearn_app/native/src/api.rs` | Sobre JSON genérico hacia `ApiSession`; sesiones `thread_local`, FRB síncrono | Una operación JSON de API no exige por sí sola cambiar firma FRB ni crear hilo. Regenerar solo si cambian fuentes del generador |
| `tool/see_app_adapter.dart`, `tool/see_app_api.dart`, `tool/see_app_scenarios.dart` en la app | Sujeto app atraviesa transporte real y admite escenarios | Una prueba que solo reenvía `session.call` certifica API/puente, no la proyección Dart: añadir observaciones del modelo/vista real |

### 1.3 Contrato que ya resuelve la atribución

`ENG.TRACE.EVENTS#R8` establece que un evento ordinario pertenece a la última tarea de `task_resumed`; antes de la primera, a la raíz cero. No falta una identidad normativa en cada evento ordinario. El consumidor debe conservar el último dueño a través de lotes, eventos sin foco y páginas; filtrar antes de atribuir destruye la información necesaria. Una ventana que comienza a mitad de cinta necesita contexto anterior verificado, no inicializarse arbitrariamente en raíz.

`task_spawned.task` identifica la hija; no significa que esa hija esté ejecutando. `task_ready` tampoco significa ejecución. `effect_delivered.task` identifica receptora; recibir un resultado no equivale a ejecutar continuación. El estado posterior de `API.STATE.QUERY#R6` y la atribución del evento tienen responsabilidades distintas; no intercambiarlos.

## 2. Lectura realizada y lectura de entrada obligatoria

### 2.1 Fuentes consultadas para esta revisión

- [x] `AGENTS.md` aportado en la conversación y `README.md` raíz; plan general §2–§5, hoja de ruta ADR-12, requisitos, riesgos y E-PG-12.
- [x] README de app: arquitectura/capas, ejecución/foco, verificación, puente, simulación, cobertura y pendientes de tareas; `apps/pseudolearn_app/architecture.yaml`.
- [x] `apps/pseudolearn_app/native/README.md`, sus reglas y `src/api.rs`.
- [x] README y `architecture.yaml` de `packages/pseudolearn_engine` y `packages/pseudolearn_spec`; README de `pseudolearn_api`, en especial consultas, efectos y control persistente.
- [x] Reglas/definiciones de `ENG.TRACE.EVENTS`, `ENG.TRACE.STEP`, `ENG.TASK.AGENDA`, `ENG.STATE.SNAPSHOT`, `ENG.STATE.INCREMENTAL`, `ENG.EFFECT.TAPE`, `ENG.EXEC.EFFECT-ORDER`, `ENG.EXEC.EFFECT-COMMIT`, `ENG.INPUT`, `API.EXECUTE`, `API.STATE.QUERY`, `API.WIRE-FORMAT`, `LANG.TASK.SCOPE`, `LANG.TASK.SUSPENSION`, `LANG.TASK.CHANNEL`, `RT.HOST.INTERFACE` y `PERF.PROTOCOL`.
- [x] Implementaciones de §1.2 y tests de contratos de ejecución/foco; inventario de tests API de tareas, efectos, historia y depuración; cierre de PG-A y material estático de E-PG-12.

### 2.2 Antes del primer cambio de implementación

- [x] Registrar HEAD, diff y versiones reales para PG-B.01; volver a comprobar dependencias PB-PRE-01–06 y autorización. Registro: HEAD `c31bf4c18202967dddab99201d63c188714b710c`, rama `feature/agregar-ruta-de-especificacion`; Flutter 3.47.5, Dart 3.13.4, Rust/Cargo 1.99.0, FRB 2.13.0.
- [x] Leer completos los casos/propiedades reutilizados y los contratos afectados por PG-B.01: `API.STATE.QUERY` C10/C11 y R7, `ENG.TRACE.EVENTS#R8`, más identidad de revisión de `API.PROGRAM.VIEW`. Los contratos listados para puntos PG-B posteriores quedan pendientes; no se usaron como autoridad de este alcance.
- [ ] Leer README de timeline, VM, runtime, service o SEE interno solo si se necesita modificar ese crate; aplicar su matriz de imports real, no la de otro crate del workspace.
- [x] Registrar por regla afectada identidad, versión, estado, anclaje, casos/propiedades, sujeto y conformidad actuales. No marcar todos los contratos de esta lista como modificados. `API.STATE.QUERY@1.0.0` sigue `estable`, sujeto `engine`; el anclaje previo es `a0b9e05706705444beaeba3ef539342d16d8360a6cfe222a3b8511d361ed3d24`, aún no reanclado. R7 vincula ahora C10/C11/C18/C19. `ENG.TRACE.EVENTS#R8` se reutiliza sin modificación.
- [ ] Levantar línea base dirigida de §7.3 antes de editar. Una suite previa no certifica HEAD nuevo.

## 3. Decisiones de diseño propuestas

Las elecciones son recomendaciones para la revisión del plan. No modifican por sí mismas el corpus. Las decisiones conceptuales de ADR-03/12/13 ya aprobadas se respetan sin pedirlas nuevamente.

| ID | Opciones | Criterio | Elección propuesta y dueño documental | Reversión |
|---|---|---|---|---|
| D-PGB-01 | Atribuir por R8; añadir task a cada evento; deducir por línea | Contrato vigente y cero semántica alternativa | R8 sobre cinta completa, con contexto de inicio de ventana; README app | Si la API no permite obtener contexto acotado, ampliar primero contrato/consulta, sin cambiar R8 unilateralmente |
| D-PGB-02 | Pila global; contextos por tarea | Mismo nodo no implica mismo marco | Mapa de contextos por identidad de ejecución/tarea; cada uno con foco/pila; README app | Extraer estructuras por responsabilidad si exceden límites; nunca volver a mezclar marcos |
| D-PGB-03 | Agrandar `ProgramExecution`; puertos segregados | Límite de cinco métodos y consumidores simples | Puerto de observación separado del control; compartir recurso en composición estática; README app | Ajustar contratos mínimos tras tests de consumidores, sin crear segunda sesión |
| D-PGB-04 | Comandos de depurador; filtro de eventos sobre avance | Paso global de un evento difiere de parar en sentencia | Reutilizar `advance` y predicados de consumo sobre evento; evaluar API de control solo si conserva exactamente ADR-12. No usar operación `step` que recompila; README app/API si cambia | Si el bombeo no conserva límites/continuación, corregir API tras casos; no emular agenda |
| D-PGB-05 | Resolver todo al precargar; bombeo acotado con estados de espera | Evitar UI congelada y estados futuros | Host en memoria entrega solo donde agenda/API permiten, con respuestas explícitas y eventos confirmados; README app | Reducir lote o separar compuerta, sin temporizadores semánticos |
| D-PGB-06 | FIFO como ley universal; política del escenario | Motor admite orden externo grabado | FIFO por omisión en app; otro orden solo si escenario lo declara y API lo valida. Reconstrucción sigue cinta; README app | Mantener inicialmente solo FIFO si basta, sin rechazar como inválida una cinta legal por otro orden |
| D-PGB-07 | Historial completo en Dart; ventanas retenidas | Volumen acotado y horizonte explícito | Consultas de API, páginas y caché acotada con expulsión determinista; README app/API | Añadir consulta pública mínima si falta contexto/estado de canal, sin leer privados VM desde Dart |
| D-PGB-08 | Panel único saturado; tres proyecciones coordinadas | ADR-12 y compact accesible | Flujo local, creación/unión y eventos/estado con selector común de tarea y evento; README app | Cambiar disposición/agrupación si E-PG-12 falla; preservar cobertura |
| D-PGB-09 | Un «cancelado» genérico; caminos normativos | Cooperativa, corte host, trampa y Error tienen efectos distintos | Estados y causas diferenciados, sin acción nueva de cancelar hija si el contrato no la ofrece; README app | Revisar rótulos, no igualar semánticas |
| D-PGB-10 | HTTP real; respuestas de escenario | Denegación por defecto y reproducibilidad | Extender host de memoria por protocolo vigente y guiones declarados; cero DNS/sockets; README app | Preferir proveedor de memoria existente si API permite configuración equivalente; comprobar antes de duplicar protocolo |
| D-PGB-11 | Métrica candidata como aprobado; medir y presentar resultado | R-12 y PERF.PROTOCOL | Medir p95 de 100 eventos/100 tareas visibles, mantener ≤50 ms como candidato; README del arnés dueño | Si no se logra, publicar resultado y proponer ajuste; aprobación solo por persona |

## 4. Desglose por punto

Cada punto incluye tareas en orden SPEC-FIRST. «Documentar» exige mover los porqués al README del miembro, no enlazar este plan. Los casos de §7.1 son IDs locales de planificación: no son casos SEE existentes.

### PG-B.01 · Evento global, foco, pila y estado por tarea

- [x] `PG-B.01.01` Contrato: inventariar evento/ejecución/revisión/tarea/marco/nodo y la atribución R8; resolver PB-PRE-04. Identificar cómo enumerar marcos y tareas, cómo empieza una hija sin `call`, qué se conserva al terminar y cómo recuperar contexto al iniciar una ventana. Extender `API.STATE.QUERY`/`API.PROGRAM.VIEW` solo donde falten datos públicos; no exportar AST privado ni adoptar nombres de depuración como identidad de dominio.
- [x] `PG-B.01.02` Casos: derivar B01/B02/B03/B04/B14, con tabla por evento de dueño, foco, pila y variables. Incluir dos hijas del mismo subprograma con argumentos distintos y recursión dentro de una; no comparar solo nombres o profundidades.
- [x] `PG-B.01.03` Tests: modelos/igualdad, decodificación, atribución entre lotes y tracker segregado; tarea desconocida, evento fuera de orden, revisión ajena, campos mal tipados y raíz antes del primer `task_resumed`. Mostrar que el test detecta mezclar las pilas.
- [x] `PG-B.01.04` Código: extraer atribución/contextos del tracker global; preservar orden global y foco por tarea; consultar marcos por tarea en adaptador y mapear errores a resultados. La selección no ejecuta ni activa tareas; la vista de un evento previo no cambia al avanzar.
- [x] `PG-B.01.05` Documentación: registrar claves y vida de identidades en README app/API, reemplazar afirmación de foco único en su ámbito y actualizar ayuda/cobertura si cambia contrato observable; aplicar §5 sin aumentar límites por comodidad.
- [ ] `PG-B.01.06` Verificar: tests espejo y API/puente afectados, casos B01–B04/B14 y arquitectura; adjuntar tabla esperado/obtenido por evento y mostrar marcos distintos en el mismo nodo. No cerrar con un mapa que nunca fue contrastado con Rust.

### PG-B.02 · Tres proyecciones y estado paginado

- [x] `PG-B.02.01` Contrato: definir datos públicos de las tres superficies y navegación tarea/marco/evento/rango. Auditar `history_events`, `debug_state`, `query_page` y horizonte antes de proponer API nueva. Si cola/estado de canal o ámbito no se consulta, especificar consulta acotada o dato observable faltante; no reconstruir mensajes desde eventos que no los contienen.
- [x] `PG-B.02.02` Casos: B02/B03/B05/B08/B09/B13/B14; incluir ámbito vacío, árbol anidado, unión sin espera, ausencia de más páginas, página vacía, horizonte expulsado, cursor de otra tarea/revisión/evento y 4096/4097 elementos solicitados.
- [x] `PG-B.02.03` Tests: modelos geométricos y estado derivado; orden estable de nodos/aristas, conexiones sin cruzar cajas ajenas, hit testing, foco y leyenda; widgets compactos y accesibilidad sin depender solo de color. Negativos de toda ampliación del verificador de cobertura.
- [x] `PG-B.02.04` Código: implementar geometría/proyección pura en adaptadores y filtrado/paginación en estado de aplicación; pintores/widgets consumen datos preparados. Una espera enlaza a causa/objetivo; una creación/unión no se pinta como bifurcación alternativa ni como control entre cuerpos locales. Eje lógico sin duración física inventada.
- [x] `PG-B.02.05` Documentación: leyenda de extensiones didácticas, rótulos es/en, matriz construcción→flujo/estructura/evento/tabla/ayuda con test y regla; no aplicabilidad con motivo. Mantener formas estáticas de PG-A y bloqueo de exportación equivalente cuando no preserva semántica.
- [ ] `PG-B.02.06` Verificar: tests de escenas/estado/widgets y cobertura; demostrar consultas de rango, número de elementos leídos acotado, caché con límite, cambio de tarea sin movimiento de agenda y navegación con revisión correcta. No basta recortar una colección completa después de leerla.

### PG-B.03 · Paso global y paso de tarea

- [x] `PG-B.03.01` Contrato: fijar evento global siguiente según `ENG.TRACE.STEP#R1/R2`; paso de tarea consume hasta el próximo evento atribuido a esa tarea, aplicando todos los intermedios. Separar selección/consumo/punta precargada y ritmos didácticos ya existentes. Definir resultado cuando tarea está terminada, falla, espera entrada/efecto, se alcanza límite o no existe próximo evento; sin bucle infinito ni respuesta fabricada.
- [x] `PG-B.03.02` Casos: B02/B03/B06/B07/B12/B15. Derivar secuencia completa esperada y estado tras cada comando global o por tarea; seleccionar una tarea esperando mientras otra avanza. El lote que termina con espera primero entrega todos sus eventos confirmados.
- [x] `PG-B.03.03` Tests: particiones 1/2/25 y cortes antes/después de cada `task_resumed`; igualdad del prefijo consumido con pasos globales; comandos rápidos concurrentes, detener entre lotes, tarea terminada/inexistente, ejecución que nunca alcanza la condición y ausencia de eventos.
- [x] `PG-B.03.04` Código: ampliar control por un contrato pequeño, sin recrear análisis/sesión; bombear en lotes acotados y ceder a UI; aplicar eventos ajenos también a tabla/salida/esperas. Distinguir «tarea seleccionada espera» de «agenda global sin progreso». No exponer eventos futuros por haberlos precargado.
- [x] `PG-B.03.05` Documentación: comandos, condiciones terminales, compatibilidad de ritmos y límites de seguridad de UI; distinguir tope local 10000 del límite del lenguaje (`ENG.TRACE.STEP#R4`), sin renombrar uno como otro ni retirarlo silenciosamente.
- [x] `PG-B.03.06` Verificar: mismo programa/configuración/cinta con ambas formas de paso produce misma traza/terminación; FRB real más cubit/widget; salida no duplicada ni reemitida al consultar historia. Registrar diferencias de selección permitidas y estado canónico común.

### PG-B.04 · Efectos simulados y entradas identificadas

- [x] `PG-B.04.01` Contrato: auditar identidad de solicitud de `Leer` frente a `effect_seq` de efecto, destinatario y vida de cada una. `input` actual recibe recurso/texto: no fingir que acepta task/solicitud. Definir rechazo de respuesta obsoleta/duplicada antes de enviarla; si se requieren lecturas concurrentes direccionables no expresables, especificar extensión pública y casos antes de implementarla. Mantener exclusión `input`/`effect_result`.
- [x] `PG-B.04.02` Casos: B06/B07/B10/B11/B14; archivos virtuales, HTTP preparado, tiempo lógico, timeout, permiso denegado, resultado incierto y cancelación. Dos pendientes de tareas distintas; `Leer` inválido y reintento, respuesta cruzada/tardía, nueva ejecución con mismo texto.
- [x] `PG-B.04.03` Tests: configuración inmutable del escenario, reinicio limpio del host, cero ampliación de derechos, validación de destinatario y rótulo simulado siempre visible en panel y ayuda. Dobles espía comprueban ausencia de acceso externo; integración valida lo que realmente acepta API.
- [x] `PG-B.04.04` Código: escenario entrega datos al host del motor; VM decide espera, reanudación y fallo. Transportar tarea/solicitud en modelo y comando, validar identidad de ejecución antes de responder. Configuración y selección por estado/puerto, sin `await` en widgets ni E/S en `engine/` de Dart. No perder esperas por autoresolver toda la ejecución al precargar.
- [x] `PG-B.04.05` Documentación: permisos, límites, orden de entrega, escenario simulado, incertidumbre y origen de respuestas; guiones válidos es/en enlazados a fichas/casos. No abrir red/rutas del equipo para «hacer pasar» HTTP.
- [ ] `PG-B.04.06` Verificar: casos de capacidad/HTTP/entrada por FRB y adaptador app, recursos abiertos cero al liberar/cortar donde corresponde, cero consultas al host durante replay y respuesta ajena rechazada sin avanzar.

### PG-B.05 · Proyecciones reproducibles

- [x] `PG-B.05.01` Contrato: definir entrada completa y representación canónica de comparación: fuentes/perfil/rigor/configuración/semilla/límites/permisos/escenario/cinta/orden de entrega, revisión y secuencia de selección/página. Separar traza de eventos de cinta de efectos; una cinta no contiene necesariamente todos los campos de vista. Aplicar rechazos de `ENG.EFFECT.TAPE#R4`.
- [x] `PG-B.05.02` Casos: B01/B03/B06/B12/B14; reproducción íntegra y cinta de otra identidad, truncada, adulterada, incierta/redactada y orden de entrega divergente. No esperar replay exitoso de una cinta sellada no reproducible.
- [x] `PG-B.05.03` Tests: repetir desde estado nuevo con distintas particiones, navegación/páginas y pausas de UI; comparar IDs/relaciones/focos/pilas/variables/canales/solicitudes/terminación. No comparar timestamps ni píxeles dependientes del entorno como equivalencia semántica.
- [x] `PG-B.05.04` Código: reconstrucción determinista sin activar host, análisis ni agenda desde pintado; invalidar caché por revisión/ejecución y ligar cursores a identidad completa. Si la ventana necesita contexto anterior a R8, obtenerlo por mecanismo verificado, no recorrer toda la cinta en cada render.
- [x] `PG-B.05.05` Documentación: qué datos se necesitan para reproducir, límites de retención y fallos, qué cambia solo disposición y qué constituye divergencia; almacenamiento de muestras sin secretos ni artefactos generados manuales.
- [ ] `PG-B.05.06` Verificar: igualdad canónica entre ejecución/grabación/reproducción y reconstrucción de ventana; espía de host con cero llamadas en replay; todas las variantes de rechazo tipadas. La falta de transporte de cinta se resuelve antes, no se sustituye por volver a ejecutar contra host simulado.

### PG-B.06 · Cancelación, error, canal lleno y bloqueo

- [x] `PG-B.06.01` Contrato: tabla de estados/transiciones según `LANG.TASK.SCOPE#R6`–`R16`, `LANG.TASK.CHANNEL#R2`–`R8`, `ENG.TASK.AGENDA#R7` y cinta. Diferenciar Error recuperable, trampa global, cancelación cooperativa de hermanas y cancelación del anfitrión; señalar recursos/limpiezas/efectos abandonados e incertidumbre.
- [x] `PG-B.06.02` Casos: B08/B09/B10/B11; primer error por orden de terminación, asociados solo si realmente ocurrieron antes de cancelar, limpiezas LIFO, canal lleno/abierto vacío/cerrado con datos/cerrado vacío, `Elegir` empatado, bloqueo sin efectos frente a espera externa capaz de reanudar.
- [x] `PG-B.06.03` Tests: estados y diagnósticos con sitios relacionados por tarea; no fabricar dos errores con dos hijas de retorno inmediato; cancelación con hijas anidadas y respuesta externa tardía; cola exacta sin confundir valor ausente con variable sin inicializar.
- [x] `PG-B.06.04` Código: proyectar datos normativos de motor y transiciones confirmadas. Si el comando de corte requiere un `advance` para confirmar/sellar, consumir esa terminación antes de limpiar UI/recurso; no devolver «cancelled» inventado porque se llamó `stop()`. No representar el estado final del recurso como si fuera el estado de cada evento anterior.
- [x] `PG-B.06.05` Documentación: tabla conducta→cinta→recursos→presentación→ayuda, sin copiar un plan transitorio. Corregir pendientes obsoletos solo tras resolver PB-PRE-05.
- [ ] `PG-B.06.06` Verificar: casos de error/canales/bloqueo por API y FRB, más tabla/foco/widgets. Cero hijas abandonadas por la proyección; error y cancelación no se pintan como unión exitosa; corte host no promete ejecutar limpiezas de usuario.

### PG-B.07 · Agenda independiente de presentación

- [x] `PG-B.07.01` Contrato: reiterar agenda FIFO/cesión por masa normativa; distinguir bombeo cooperativo de UI, animación y tiempo lógico del programa. Decidir límites de cada llamada síncrona y cola/caché antes de implementarlos; respetar prohibición de Isolate del README actual.
- [x] `PG-B.07.02` Casos: B02/B06/B12/B13/B15; mismas entradas con animación desactivada, más repintados, distintas velocidades, selección y redimensionado; efecto demorado manualmente sin sondeo infinito.
- [x] `PG-B.07.03` Tests: pureza de presentación/composición, inmutabilidad y bombeo acotado; doble de transporte cuenta llamadas por comando y demuestra que reconstruir/repintar no pide `advance` ni responde efectos. Toda regla mecánica nueva necesita fixture que falle deliberadamente.
- [x] `PG-B.07.04` Código: extracción de drenado de efectos si es ilimitado; acciones en aplicación, datos preparados para pintores, cesión entre lotes. Una animación puede suavizar transición visual, nunca decidir próxima tarea, respuesta ni evento. Cancelación/edición invalidan callbacks de ejecución vieja.
- [x] `PG-B.07.05` Documentación: responsables de agenda/animación/consulta, políticas con dueño, límites de UI y cómo medirlos; no agregar excepciones de `Timer`, `await` o imports para facilitar un widget.
- [ ] `PG-B.07.06` Verificar: particiones y ritmos distintos conservan secuencia; validadores de arquitectura/pureza/límites en verde; registrar máximo lote observado y demora de detención sin afirmar garantía temporal desde un test funcional.

### PG-B.08 · Integración con puente real

- [x] `PG-B.08.01` Contrato: inventario de operaciones y campos por escenario contra `ApiSession`, no contra métodos imaginados del bridge. Listar qué observación certifica API, adaptación Dart, cubit o widget. Conservar negociación/versiones y sesión/revisión.
- [x] `PG-B.08.02` Casos: seleccionar B01–B15 según la matriz §7.1, recursos inválidos/liberados, JSON/clase/versión desconocidos, reinicio, edición y cierre. Casos de sintaxis es/en desde reglas y casos vigentes, sin «traducir» identificadores propios ni relajar parser para fixtures.
- [x] `PG-B.08.03` Tests: añadir integración espejo que abre transporte real, ejecuta archivo suelto, consulta tarea suspendida, avanza otra, responde solicitud y cancela/libera. Afirmar estados de dominio y proyecciones de app, no solo sobres JSON. Los dobles se reservan para errores/particiones controlados.
- [x] `PG-B.08.04` Código: adaptar frontera solo si hace falta; si no cambia firma Rust exportada, justificar no regenerar FRB. Si cambia, generar desde dueño y comparar; nunca editar `frb_generated.rs` ni `lib/engine/bridge/` a mano. Añadir escenario SEE app donde el corpus requiera observación Dart.
- [x] `PG-B.08.05` Documentación: comandos exactos y alcance por plataforma; el humo de macOS no certifica iOS/Windows. README de puente actualizado solo si cambió su contrato/operación.
- [ ] `PG-B.08.06` Verificar: biblioteca nativa fresca, `bash tool/test_bridge.sh`, tests nativos afectados, integración app, conformidad afectada y generación si corresponde. Humo local de macOS/iOS según medios disponibles; cualquier falta se informa y no se presenta como ejecución física.

### PG-B.09 · E-PG-12 dinámico y medición

- [x] `PG-B.09.01` Contrato/protocolo: cerrar inventario de escenas §7.1 con oráculo manual y configuración completa; cruzar cada estado/espera/unión/solicitud con regla. Conservar evidencia estática separada y tratar el diferimiento humano según PB-PRE-06.
- [x] `PG-B.09.02` Casos: preparar fuentes bilingües validadas de mismo subprograma en dos tareas, una esperando y otra avanzando, error, cancelación, canal lleno, `Elegir` y revisión nueva; guion con evento exacto de cada pregunta y respuesta derivada antes de ejecutar.
- [x] `PG-B.09.03` Tests: protocolo automatizado por identidad, geometría, tabla, navegación, accesibilidad y ausencia de omisiones; prueba de arnés que rechaza configuración diferente, muestra incompleta, resultado divergente o manifiesto faltante. No llamar a estos tests «comprensión humana».
- [x] `PG-B.09.04` Implementar arnés de proyección pura y medición integrada por separado, con entradas preparadas y tamaños de §6; mantener rendimiento fuera de tests de widget como umbral de CI. Guardar datos crudos, manifiesto y resumen recalculable.
- [x] `PG-B.09.05` Documentar protocolo y resultados dinámicos en `docs/` y procedimiento reutilizable en README del arnés dueño. Preparar material para ≥12 principiantes, orden contrabalanceado e idiomas, sin atribuir autoría/revisión/consentimiento inexistentes.
- [ ] `PG-B.09.06` Verificar cierre: resultados automatizados completos, p95 y memoria con procedencia, umbral candidato claramente rotulado; evidencia humana aportada por persona o diferimiento explícito aplicable. Si falla comprensión, revisar notación y repetir evidencia pertinente; no retirar cobertura. No declarar PG-B.C10/C11 por medir solo la parte rápida.

## 5. Capas, archivos y responsabilidad

### 5.1 Respuestas obligatorias antes de editar

No se crea otra capa ni otro miembro. Las rutas con **propuesto** aún no existen y solo se crean si la responsabilidad no tiene dueño adecuado tras leer el archivo actual. Para cada archivo finalmente elegido se registra una fila propia con capa, imports y dueño en §11; esta tabla agrupa candidatos de la misma responsabilidad para preparar el trabajo.

| Archivos existentes o propuesta | Capa e imports permitidos | Prohibido y responsabilidad/dueño |
|---|---|---|
| Este archivo y enlace de plan general | Documentación transitoria raíz; enlaces internos de `docs/` | Sin producción, ni referencias entrantes desde fuera de `docs/`; dueño de secuencia/evidencia, no autoridad técnica del paquete |
| `apps/pseudolearn_app/lib/domain/model/execution/{execution_focus,execution_step,effect_wait,watch_row}.dart`; propuestos `task_execution_context.dart`, `execution_observation.dart`, `event_window.dart`, `pending_input.dart` | model: sí misma, sin otras capas | Sin Flutter/bloc/FRB/E/S; cada archivo representa contexto, observación, ventana o solicitud, no su adquisición |
| `lib/domain/ports/program_execution.dart`; propuestos `execution_observation_source.dart` y contrato de control segregado si hace falta | ports → model | Sin motor/transporte/application/Flutter; control existente conserva compatibilidad o migración explícita de todos sus consumidores |
| `lib/engine/rust/{rust_wire_models,rust_event_classes,rust_focus_tracker,rust_statement_stack,rust_program_execution,rust_execution_api,rust_state_api,rust_watch_rows}.dart`; propuestos `rust_event_owner.dart`, `rust_task_contexts.dart`, `rust_event_window_source.dart` | engine → model/ports y sí misma | Sin application/presentation/data/Flutter/E/S/regex; atribución, adaptación, pila y consulta en dueños distintos. No concentrar todos los estados en el tracker |
| `lib/engine/rust/{rust_effect_gate,rust_simulated_host}.dart`; `lib/domain/model/execution/simulated_capabilities.dart` | engine o model según archivo | Host entrega resultados por protocolo, no agenda ni interpretación. Extraer respuestas HTTP a dueño especializado si hace falta, sin archivo genérico helpers/utils |
| `lib/application/execution/{execution_cubit,execution_state,step_batch_runner,step_settlement,step_pace}.dart`; propuestos estado/control de observación segregados | application → model/ports y sí misma; bloc/equatable existentes | Sin engine/data/presentation/Flutter/E/S/regex; comandos, selección, filtros, paginación y estados inmutables. No concentrar trabajo nuevo en EditorCubit |
| `lib/engine/diagram/` para geometría nueva y `lib/domain/model/diagram/` para datos de escena, si se requieren | engine → model/ports; model → sí misma | No meter geometría Flutter ni consultas de motor en painter; reutilizar layout existente cuando conserve significado |
| `lib/presentation/document/components/execution_stepper.dart`, overlays de `lib/presentation/diagram/`; propuestos paneles específicos de tareas/eventos | presentation → model/application y sí misma | Sin puertos directos/engine/data/dart:io, `Timer`, `await`, filtrado/ordenación semánticos; widgets y pintores solo representación e interacción |
| `lib/presentation/l10n/app_es.arb`, `app_en.arb` | Datos de presentación | Vocabulario visible bilingüe; generar localizaciones por procedimiento del miembro, sin editar generated |
| `lib/composition/app_dependencies.dart` | composition → capas declaradas | Sin condicionales, workers ni localizadores de servicio; ensamblar control/consulta sobre mismo recurso |
| `apps/pseudolearn_app/test/` espejo y fixtures bilingües propuestos `test/fixtures/task_scenes/` | Tests por responsabilidad de lib | No duplicar casos normativos Rust; fixtures no son esperados capturados. `tool/` solo arnés/adaptador/verificación |
| `apps/pseudolearn_app/native/src/api.rs`, tests y README | Única capa bridge → API/FRB/serde_json según reglas | Sin semántica/UI/red; modificar solo si sobre o firma lo requiere. Salidas FRB generadas por su dueño |
| `packages/pseudolearn_spec/specifications/{eng,api,lang,rt,lib,tool}/` y manifiestos de conformidad | Corpus/datos; identidades internas | Sin referencias externas ni `docs/`, estados/versiones congelados; agregar casos/vínculos en dueño existente. SEE interno no se modifica sin carencia de esquema demostrada |
| `packages/pseudolearn_engine/crates/pseudolearn_api/src/{execution_queries,state_pages,execution_wire,execution_debug,history_operations,debug_state}.rs` y tests espejo | API, imports declarados en `architecture.yaml`; acceso público desde consumidor | Sin UI ni consumidores; solo ampliar contrato faltante/reparar divergencia demostrada. Leer README del crate antes |
| timeline/VM/runtime/service, solo condicionalmente | Cada crate importa exclusivamente su lista de `architecture.yaml` | Sin imports hacia API/consumidores si su regla no lo permite; no mover semántica al service ni implementar tareas AOT como parte lateral de esta fase |

Los límites de app son 250 líneas/archivo, 40/función, 30/build, tres parámetros posicionales, anidación tres y cinco métodos públicos. Rust usa 300/40/cuatro/tres/siete según reglas del miembro. No se elevan para acomodar esta fase. Una carpeta funcional nueva queda dentro de su capa declarada; una capa nueva exigiría decisión y reglas antes del código (`LAYER-DECLARED`). Tests espejo; Rust interno en archivos hermanos `_tests.rs` y caja negra en `tests/`.

### 5.2 Tabla de campos que debe entregar la implementación

Antes de cerrar `.01`–`.04`, completar una fila por campo consumido: contrato/regla, operación pública exacta, clave/tipo wire, obligatoriedad, identidad/vida, modelo destino, error al faltar, caso/test y consumidor. Como mínimo: evento/índice/horizonte, source y revisión, dueño por R8, tarea/padre/estado/espera, marco/unidad, ámbito/unión, canal/capacidad/estado de cola observable, effect_seq/delivery_seq, solicitud de entrada y cursor. Campo sin fuente pública suficiente es carencia de contrato; no se llena desde heurística.

## 6. Presupuestos de rendimiento y seguridad

### 6.1 Protocolo de medición

`PERF.PG.APP.VIEW` y p95 ≤50 ms para ventana de 100 eventos/100 tareas visibles son **candidatos**, no contratos aprobados. Cumplir o incumplir se publica sin cambiar el umbral a posteriori. No usar la campaña estática de PG-A como línea base dinámica equivalente.

- Cargas: 0, 1, 10 y 100 eventos/tareas visibles; caso principal 100/100 con varias tareas del mismo subprograma; retenidos mayores que ventana visible para demostrar paginación, y colecciones 0/1/4096/4097. Declarar límites configurados suficientes; no suponer que el máximo predeterminado admite cien tareas vivas.
- Entrada preparada: fuentes, escena, estado por tarea y cinta validados antes de medir. Intervalo puro: proyección de esa ventana a modelos/geométrica, sin compilación/FFI/E/S. Intervalo integrado separado: consulta/decodificación/proyección; render separado si se mide. No sumar resultados de intervalos distintos como si fueran la misma métrica.
- Control equivalente: misma ventana y datos, salida canónica y geometría correctas; comparar implementación previa solo donde existe la misma conducta. Para novedad sin control previo equivalente informar coste absoluto. Registrar prueba de consulta acotada y diferencia entre frío/caliente.
- `PERF.PROTOCOL`: ≥10 procesos independientes y ≥30 iteraciones por proceso/carga, estado nuevo, semilla fija, validación de resultado/terminación fuera del intervalo. Procedencia antes de compilar: HEAD/diff, fuentes del arnés, hash de entrada/cinta, versiones, modo de build, SO y hardware.
- Conservar resolución del reloj, todas las muestras y candidatos de cambio; ningún descarte selectivo. Publicar p50/p95 con estimador declarado y crudos; intervalos del 95 % y emparejamiento por proceso según protocolo. RSS máxima muestreada como cota inferior, CPU acumulada y bytes/cantidad de elementos/cachés; memoria no medida no vale cero.
- Demostrar que cambios de viewport/animación/página no alteran agenda; un reloj de medición observa, nunca decide. Latencia de detención se mide aparte, sin inventar un presupuesto aprobado.

### 6.2 Límites y pruebas adversarias

| Frontera | Control y evidencia exigida |
|---|---|
| Cursor/identidad | Otra sesión, recurso, ejecución, tarea, evento, revisión, generación o tamaño no reutiliza página. Rechazo sin cambio de agenda |
| Ventana | `history_events` 0–4096; fuera de horizonte/futuro y tamaño excesivo fallan explícitamente. Ventana parcial no muestra datos como completos |
| Valores | Consultas paginadas, aliases e identidad conservados; cero materialización global para recortar después. Profundidad/cantidad/bytes siempre acotados por contrato efectivo |
| Retención | Definir antes del código tope de eventos/tareas/escenas/caché y política de expulsión; no se permite crecimiento sin límite ni un número nuevo sin dueño README/caso de borde |
| Efectos | Sin permisos por omisión, sin ampliación de derechos, sockets/DNS/disco real ni credenciales en paneles/logs; límites de cuerpo/cabeceras/tiempo/pendientes del motor, sin elevarlos desde UI |
| Solicitudes | Doble envío, respuesta tardía o de ejecución vieja y confusión input/effect_result rechazados sin avanzar. Texto de entrada no puede dirigir otra tarea por nombre visible |
| Cancelación/liberación | Confirmación del motor, recursos liberados, respuesta tardía rechazada; verificar vida de recurso de ejecución y análisis, no asumir que cancelar equivale a liberar |
| Reproducción | Cinta inválida no activa host; incertidumbre/redacción/truncamiento visibles, sin resultados sintéticos |
| Hilo UI | Ninguna llamada/bucle sin cota por lote; prueba de stop/edición durante bombeo; sin Isolate ni async en pintores |

Si un límite aún no tiene valor, se registra como tarea de contrato/configuración pendiente en el punto dueño; no se considera cerrado con esta tabla.

## 7. Pruebas, verificadores y experimentos

### 7.1 Matriz mínima de escenas

IDs B01–B15 son locales a este plan. La implementación los vinculará a IDs SEE existentes o nuevos sin reutilizar identidades. Esperados derivados antes de ejecutar; incluir perfiles es/en y ambos rigores donde el contrato lo declare, con idioma UI independiente.

| Escena | Camino feliz | Infeliz y borde explícito | Contrato/oráculo y niveles |
|---|---|---|---|
| B01 Secuencial | Mismo foco/tabla/salida que antes | Fuente vacía, programa vacío, análisis fallido; sin lista de tareas inventada | `ENG.TRACE.EVENTS#R1`–`R8`, `API.STATE.QUERY#R6`; corpus, adaptación, widget |
| B02 Identidades | Dos hijas mismo subprograma, argumentos/variables distintos, una recursiva | Mismo nodo/línea/profundidad en ambas; tarea desconocida; identificador de un carácter | `ENG.TASK.AGENDA#R1/R2`, `LANG.TASK.SUSPENSION#R7`, R8 de eventos; API, FRB, tracker, escena |
| B03 Suspensión | Una espera mientras otra avanza; resultado→lista→reanudación | Resultado ya disponible, sin suspensión ficticia; tarea lista sin ejecutar | `LANG.TASK.SUSPENSION#R5/R8`, `ENG.TASK.AGENDA#R3`–`R6`; corpus, FRB, pasos, widgets |
| B04 Pilas/estado | Inspeccionar tarea suspendida y conservar variables/marcos | Recursión profunda hasta límite, marco ajeno, alias/ciclo, selección repetida | `API.STATE.QUERY#R1/R2/R7`, `ENG.STATE.SNAPSHOT#R4/R5/R7`; API/paginación, adaptación |
| B05 Creación/unión | Ámbitos anidados y unión obligatoria | Ámbito vacío, hijas ya terminadas, error en unión; cero hijas supervivientes | `LANG.TASK.SCOPE#R1/R2/R5/R11`–`R16`; corpus, estructura/estado/widget |
| B06 Efectos | Dos pendientes, entrega y atribución a receptora | Orden declarado distinto de FIFO, duplicado, secuencia ajena, sin permisos | `API.EXECUTE#R6`, `ENG.EXEC.EFFECT-ORDER#R4/R5`, `ENG.EFFECT.TAPE#R6`; API/FRB/host/tabla |
| B07 Entrada | Leer con destinatario y continuar misma posición | Conversión inválida, nueva petición, respuesta cruzada/tardía; input durante efecto | `ENG.INPUT#R1`–`R4`, `API.EXECUTE#R3/R6`; corpus/frontera/cubit/widget |
| B08 Canales | FIFO, contrapresión y recepción libera emisor | Capacidad 1 llena, cero inválido, cerrado con/sin datos, cierre repetido | `LANG.TASK.CHANNEL#R2`–`R6`; corpus/API/FRB/modelo/panel |
| B09 Elegir/bloqueo | Primera rama textual lista, retirar otras inscripciones | Dos ramas listas, canal repetido, todas esperando, efecto vivo evita falso deadlock | `LANG.TASK.CHANNEL#R7/R8`, `ENG.TASK.AGENDA#R7`; corpus/estado/escena |
| B10 Cancelación | Fallo de hija solicita cancelar hermanas y unión/limpieza | Corte host sin limpieza, hijo anidado, efecto abandonado y respuesta tardía | `LANG.TASK.SCOPE#R6`–`R9/R11`–`R13`, `RT.HOST.INTERFACE#R4`; corpus/FRB/cubit/widget |
| B11 Error | Resultado Error visible y primer fallo por terminación | Trampa global sin limpieza, cancelación y Uncertain diferentes; timeout/denegación | `LANG.TASK.SCOPE#R10`–`R16`, `ENG.EXEC.EFFECT-COMMIT#R2/R3/R5`; corpus/API/host/panel |
| B12 Reproducción | Misma cinta y configuración, diferentes lotes/ritmos | Cinta truncada/adulterada/otra identidad/no reproducible; host espía cero | `ENG.EFFECT.TAPE#R1`–`R6`, `API.EXECUTE#R5`, `ENG.TRACE.STEP#R2`; corpus/API/FRB/proyección |
| B13 Páginas | Ventana/valores por rango y orden estable | 0/1/4096/4097, cursor cruzado, horizonte expulsado y total mayor que visible | `API.STATE.QUERY#R3/R4/R7`, `API.EXECUTE#R8`; API/FRB/estado/geometría/medición |
| B14 Revisión | Navegar foco a fuente correcta, selección invalidada al editar | Unicode, ordinal local reutilizado, callback/cursor de revisión vieja | `ENG.TRACE.EVENTS#R2`, `API.WIRE-FORMAT#R4`, `API.STATE.QUERY#R4`; corpus/frontera/estado/widget |
| B15 Bombeo | UI responde al stop sin variar traza por repintar | Flujo largo sin próximo evento seleccionado, cancelación entre lotes, efecto manual sin respuesta | `ENG.TRACE.STEP#R1`–`R4`, `ENG.TASK.AGENDA#R5/R6`; runner/transporte/widget, medición separada |

No se fuerza cada combinación en todos los niveles: corpus demuestra semántica; tests espejo demuestran transformación; widgets demuestran interacción/representación; FRB real demuestra integración. Cada fila debe identificar qué prueba observa cada afirmación. Negativos obligatorios para validadores nuevos o ampliados: evento/clase/campo desconocido, fila de cobertura ausente/duplicada, identidad sin ayuda, cursor inválido y procedencia de medición incompleta, según el verificador dueño.

### 7.2 E-PG-12 dinámico

Preparar un documento hermano propuesto `e-pg-12-dinamico-evidencia.md` al ejecutar `.09`, con fuentes y hashes, configuración, cinta, oráculo por evento, secuencia de acciones, evidencia automatizada, medición, limitaciones y decisión humana. No crearlo ahora como si existieran resultados.

Preguntas humanas mínimas: qué tarea ejecuta; cuál espera y por qué; qué valores/marcos corresponden a cada hija del mismo subprograma; si entregar un efecto ya ejecutó la continuación; por qué no terminó la unión; por qué canal lleno causa espera y cuándo progresa; diferencia entre cancelación y error; si la pantalla demuestra instrucciones simultáneas en varios núcleos. Contrabalancear orden e idioma, registrar respuestas/aciertos/tiempos si se miden y denominadores. La meta candidata ≥80 % en espera frente a ejecución en paralelo se informa por tarea/idioma; no promediarla con interfaz frente a instancia para ocultar fallos.

Piloto con al menos doce principiantes y consentimiento gestionado por la persona. La IA prepara material y análisis, no recluta ni inventa sujetos/datos. Aplicar diferimiento previo solo si su alcance lo cubre y citar decisión/fecha; ausencia de participantes nunca se llama «No aplica» por conveniencia. Un test automatizado sin confusión de IDs no demuestra comprensión humana.

### 7.3 Comandos y alcance de verificación

Ejecutar desde el miembro indicado. Esta lista prescribe verificaciones futuras; no son resultados de la preparación documental. Antes de cada comando con filtro nuevo, comprobar target y opción en README/Cargo/CLI; si no existe, registrar carencia, no inventar resultado ni una orden parecida.

| Momento/miembro | Comando existente o procedimiento | Qué certifica |
|---|---|---|
| Inicio, raíz | `git status --short`, `git branch --show-current`, `git rev-parse HEAD` | Identidad y cambios previos; rama única |
| Corpus, spec | `cargo run -p see_cli --bin see -- validate`; `cargo run -p see_cli --bin see -- export --check` | Integridad y exportación; registrar errores heredados por ID |
| Cambio de contrato, spec | `cargo run -p see_cli --bin see -- lock --refresh <IDs-modificados-revisados>` y exportación normal | Reanclaje selectivo tras revisión; marcador entre ángulos se sustituye, nunca se ejecuta literal |
| Corpus afectado, spec | `cargo run -p see_cli --bin see -- conform --subject engine --only <ID>`; equivalente `--subject app` | Regla/casos de ese contrato; repetir por IDs realmente afectados. Verificar adaptadores/biblioteca frescos |
| Propiedades afectadas, spec | `cargo run -p see_cli --bin see -- conform --subject app --operation properties`; engine según impacto | Propiedades API por sujeto; no afirmar que certifica geometría Dart |
| Motor, dirigido | `cargo test --locked -p pseudolearn_api --test task_event_tests`; targets existentes `task_scope_tests`, `task_failure_tests`, `task_channel_tests`, `task_deadlock_tests`, `task_effect_order_tests`, `debug_task_control`, `debug_control`, `history_events`, `history_effect_counters_tests`, `state_pages` en invocaciones correspondientes | Seleccionar los targets de conducta afectada; agregar nuevos tests espejo para carencias |
| App, preparación | `flutter pub get`; `cargo build --release --locked --lib --manifest-path native/Cargo.toml` | Dependencias y biblioteca actual; no reutilizar artefacto anterior al Rust modificado |
| App, tests dirigidos | `flutter test test/engine/rust/`; `flutter test test/application/execution/`; tests espejo nuevos de model/presentation/diagram según §5 | Adaptación y controles; ampliar a suites dependientes si cambia contrato común |
| App, reglas | `flutter analyze --fatal-infos --fatal-warnings`; `dart run tool/check_limits.dart`; `dart run tool/check_content.dart`; `dart run tool/check_design_system.dart`; `dart run tool/check_syntax_coverage.dart`; `flutter test test/architecture/` | Todas las puertas del miembro afectado y negativos de verificadores |
| App, FFI real | `bash tool/test_bridge.sh` y nuevos tests de integración de `.08` | Compila biblioteca y llama transporte; adjuntar resultados sobre proyección Dart |
| Bridge, si se modifica | `cargo fmt --all --check`; `cargo clippy --all-targets`; `cargo test`; `cargo deny check`; comando `rust-checks all .` exacto de `native/README.md` | Frontera Rust y aislamiento; no asumir xtask inexistente en native |
| Generación, app | `bash tool/bridge.sh check`; si cambió fuente exportada, primero `bash tool/bridge.sh generate` | Vigencia de salidas. `clean-checkout` solo si se justifica repetir esa garantía, respetando rama única |
| Cierre, engine/spec si afectados | `cargo xtask verify` desde cada miembro | Verificadores completos del miembro; una ejecución fallida no certifica comandos que quedaron sin correr |
| Cierre, app | Verificadores anteriores y suites afectadas; `flutter test` completo si cambia puerto/estado común con impacto transversal o aparecen fallas fuera de selección | Justificar alcance/omisiones con riesgo y evidencia, no por ahorrar tiempo. No repetir suites verdes sin cambios ni preocupación pendiente |
| Plataforma | Humo macOS/iOS con órdenes de `apps/pseudolearn_app/README.md` §2.5 y escenas de tareas añadidas al target real | Integración de esa plataforma; físico/Actions solo con disponibilidad y autorización aplicables |

Si se modifica SEE interno, leer su README, escribir negativos y ejecutar sus tests/xtask; no dar por cubierto un verificador porque `validate` pasó sobre entradas válidas. No ampliar a CLI/VS Code/Wasm/AOT si no son consumidores afectados; si se cambia wire público, inventariarlos y agregar sus comprobaciones pertinentes antes del cierre.

Para preparar este plan se verifican solo estructura, referencias y diff documental. No se ejecuta una suite de producto para atribuirle verde a una implementación aún no autorizada.

## 8. Riesgos y señales tempranas

| Riesgo | Señal verificable | Mitigación/puerta |
|---|---|---|
| K-18 Falsa causalidad | Dos hijas comparten marco; lista se pinta ejecutando; unión antes de terminales | B02–B05 y tabla por evento; bloquear cierre `.01`–`.03` |
| K-19 Cobertura didáctica incompleta | await como rombo, canal oculto, efecto como proceso genérico o forma nueva sin ayuda | Matriz y negativos, B08/B09/B11, leyenda es/en, `.02/.09` |
| PB-K01 Dueño perdido al paginar | Primera página parcial atribuye todo a raíz | Contexto R8 verificado y prueba de corte en cada transición |
| PB-K02 Estado futuro por precarga | Tabla muestra resultado antes de `effect_delivered` visible | Separar índice consumido/punta; consultar evento exacto; B03/B06 |
| PB-K03 UI decide agenda | Cambiar animación/selección altera traza o entrega | B12/B15, espías y pureza de presentación |
| PB-K04 Memoria o bloqueo sin cota | `state` completo por evento, cola automática ilimitada, releer todo historial para página | Medición/contadores, páginas/caché/bombeo con límite en §6 |
| PB-K05 Mezcla de cortes | stop muestra limpiezas cooperativas o cancela recurso sin confirmar | B10/B11 y auditoría de vida de recursos |
| PB-K06 Evidencia aparente | Pasarela SEE aprueba JSON pero tracker/widget siguen únicos | `.08` observa modelo/proyección real; doble y FRB distinguidos |
| PB-K07 Deuda heredada invisibilizada | Reanclaje global, fallos omitidos, cierre previo citado como verde | Línea base PB-PRE-02/05 y C11 con comandos/logs de HEAD actual |
| PB-K08 Exposición de datos | Argumentos HTTP/secretos aparecen completos en tabla/log | Casos adversarios/redacción, permisos y cinta no reproducible |
| PB-K09 Comprensión o métrica inventadas | Automatización llamada estudio, p95 sin muestras o umbral aprobado sin mensaje | `.09`, procedencia PERF y dependencia humana registrada |

## 9. Dependencias de la persona

| Momento | Dependencia concreta | Acción del ejecutor |
|---|---|---|
| Antes de implementar | Revisión de este plan, autorización de alcance y resolución de PG-3 abierta | Solicitar únicamente decisiones faltantes; no marcar C01/C02 por la petición de redacción |
| Antes de contrato/consulta afectada | PB-PRE-04 y contradicciones efectivas PB-PRE-05 | Presentar textos, conducta vigente, recomendación y alcance; esperar respuesta para ese cambio |
| Antes de atribuir revisión | Revisión independiente requerida de cambios normativos/anclajes | Preparar diff y casos; no escribir nombre humano por inferencia |
| `.09` | Resultados humanos o diferimiento explícito cuyo alcance cubra dinámica | Respetar diferimiento existente, precisar solo si necesario; no fabricar evidencia |
| Al valorar métrica | Aceptar/rechazar presupuesto candidato o medición desfavorable | Entregar muestras/resumen antes de pedir decisión; no tratar ≥/≤ como aprobación |
| Humo/plataformas | Dispositivo y permisos de ejecución cuando hagan falta | Completar primero lo local; informar exactamente qué plataforma falta |
| Publicación/cierre | Alcance autorizado de commit/push y cierre de fase | Preparar diff/validaciones primero; si no está autorizado, no publicar. No abrir Actions ni desplegar para sustituir checks locales |

## 10. Orden de ejecución y puntos de control

1. **P0 · Revisión y entrada.** Mantener plan como preparado; resolver C01/C02 y PB-PRE-01–06 aplicables, releer fuentes, registrar línea base y campo→contrato. Parar trabajo dependiente ante conflicto, sin editar fuentes para «conciliarlas» a solas.
2. **P1 · Identidad y contratos.** Ejecutar `.01.01–.03`, y especificación/casos/tests de `.02–.07` donde compartan contrato. Cubrir contexto R8, selector de tarea, solicitud, ventanas/canales y límites. Puerta: no queda campo consumido sin origen público ni esperado derivado.
3. **P2 · Estado por tarea.** Completar `.01`, infraestructura de consulta de `.02` y reconstrucción base de `.05`. Puerta: dos hijas mismo nodo conservan pilas/variables independientes por FRB; páginas y revisión no cambian agenda.
4. **P3 · Control y efectos.** Completar `.03/.04/.06/.07`, implementando temprano sus pruebas `.08`. Puerta: paso global/tarea conserva prefijo, espera no bloquea falsas tareas, respuestas direccionadas, caminos de error/cancelación distintos, llamadas y retención acotadas.
5. **P4 · Tres superficies.** Completar `.02/.05` y widgets vinculados; FRB, escenas por cinta, geometría/accesibilidad, cobertura/ayuda. Puerta: todas las filas B01–B15 tienen evidencia del nivel que afirma su resultado, y cero omisiones silenciosas.
6. **P5 · Integración y experimento.** Completar `.08/.09`, medición con procedencia y tratamiento humano aplicable. Publicar también resultados desfavorables y límites físicos; no convertir rendimiento o comprensión insuficientes en verde cambiando etiquetas.
7. **P6 · Revisión de cierre.** Revisar diff contra alcance y las tres preguntas de capa por archivo; ejecutar pruebas/validadores afectados de §7.3 en revisión final; completar C03–C11 con evidencia propia y pendientes. Fallos obligatorios dejan fase abierta, salvo cierre excepcional expresamente decidido por persona, que no se llama `PHASE-GREEN`.
8. **P7 · Publicación autorizada y parada.** Si commit/push están autorizados, leer/aplicar skill `commit-message`, commit sin atribución de IA y push ordinario a `feature/agregar-ruta-de-especificacion`; comprobar rama/HEAD remoto y registrar hash. Sin force, ramas nuevas ni publicación externa. Completar resumen general/C12/C13, informar y parar antes de PG-7.

## 11. Resumen de ejecución

### 11.1 Estado de ejecución de PG-B.01

El mensaje de la persona del 2026-11-02 autoriza exclusivamente PG-B.01 y resuelve avanzar con PG-3 abierta para ese punto. El mismo título repetido en la petición se interpreta como una sola tarea. No autoriza puntos PG-B posteriores, revisión del plan, commit ni push. Se conserva la rama `feature/agregar-ruta-de-especificacion`; HEAD de base `c31bf4c18202967dddab99201d63c188714b710c`, con diff de trabajo sin commit. La verificación final no alcanza `PHASE-GREEN` por las puertas SEE indicadas en PG-B.01.06.

Los estados de tarea son Cumplido, No cumplido, Diferido, No aplica y Retirado. Las verificaciones exitosas no se sustituyen por una descripción de intención. La prueba completa del crate API no se certifica: la invocación por omisión falla al compilar `native_effects`, que importa una función habilitada solo con `native`; el target afectado se probó por separado con y sin esa feature.

#### B01/B02/B03/B04/B14: esperado derivado y observado

| Escena | Esperado derivado | Observado |
|---|---|---|
| B01 Secuencial | Antes del primer `task_resumed`, los eventos ordinarios pertenecen a raíz cero; la ejecución conserva el foco secuencial y finaliza la raíz con su resultado. | `RustProgramExecution` proyecta foco, salida y resultado; su primera secuencia también comprueba atribución a raíz. El paso terminal informa raíz `completed` y `success`. |
| B02 Identidades | Dos tareas hermanas en el mismo subprograma consultan el mismo sitio recursivo con argumentos independientes; sus marcos no se mezclan. | `task_id_reads_distinct_recursive_frames_for_sibling_tasks`: `query_frame` en la misma llamada `Recurse` devuelve `value=7` para tarea 1 y `value=9` para tarea 2, ambas en marco 2. |
| B03 Suspensión | Inspeccionar una hija suspendida conserva su estado y no la activa ni cambia el siguiente evento de agenda. | `task_id_reads_a_suspended_child_without_changing_the_schedule` compara el siguiente `advance` tras consultar contra una ejecución de control sin consulta; respuestas iguales. |
| B04 Pilas/estado | Cada tarea conserva foco, variables y pila propias; recursión añade marcos a la tarea activa y la lectura histórica permanece estable. | `task contexts keep independent stacks across event batches`, `old_event_state_is_stable_after_execution_advances` y la consulta por tarea a los marcos recursivos anteriores. |
| B14 Revisión | Un evento con revisión ajena a la vista activa se rechaza; la identidad de nodo no se resuelve por número de línea ni ordinal suelto. | `unknown tasks, foreign revisions and out-of-order events halt cleanly` rechaza `rev2` frente a `rev1`; `RustEvent` conserva revisión, proyecto/fuente opcionales y `node_id`. |

Tabla esperada/observada por evento en el tracker de la app:

| Evento | Dueño | Foco esperado | Pila esperada | Variables esperadas | Observado |
|---|---|---|---|---|---|
| `statement_entered`, `call` antes de reanudar una hija | Raíz cero por R8 | El nodo de sentencia llamado, en el contexto raíz | Aumenta solo la pila de raíz | Consulta `task_id: 0` al índice global consumido | El primer evento se atribuye a raíz; al crear hijas, la raíz conserva dos marcos y ellas nacen sin foco/pila. |
| `task_spawned`, `task_ready` | `data.task` recibe estado; raíz conserva selección activa | No cambia el foco activo; contexto hijo sin foco | Hijo empieza vacío; no hereda la pila del padre | Sin estado consultado hasta reanudar | El test Dart observa `created`, pila vacía y foco nulo; `task_ready` no selecciona la hija. |
| `task_resumed`, eventos ordinarios | `data.task` se vuelve dueño activo | Foco anterior propio o el nodo ordinario actual | `statement_entered`/`call` modifican solo la pila de esa tarea | Se consulta por `task_id` y evento actual | El test Dart cambia dueño a tarea 1 sin alterar la pila raíz; API Rust lee `value=7` y `value=9` en el mismo nodo recursivo, marco 2 de tareas distintas. |
| `task_suspended` | `data.task`, aunque ya no sea la activa | Conserva el foco de la tarea | Conserva su pila recursiva | Lectura histórica por el `task_id` suspendido | El API devuelve el marco `Consume` de la hija suspendida; la siguiente secuencia coincide con la ejecución de control sin consulta. |
| `task_completed` | `data.task` que termina | Conserva el foco final | Conserva sus marcos finales | Conserva el último estado y resultado `success` | El test Dart observa `completed/success`; la proyección del paso incluye la instantánea retenida. |
| Terminación global | Contexto raíz cero | Conserva su foco final | Conserva su pila final | Conserva variables y causa terminal | El paso terminal marca raíz `completed/success`; esperas de entrada/efecto no finalizan la raíz. |

| Tarea | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| PG-B.01.01 | Cumplido | `API.STATE.QUERY@1.0.0` R7; C18/C19; README API/app; `ENG.TRACE.EVENTS#R8` | Se conserva `task_id`, se rechaza `task` y tipo mal formado; estados/versiones no cambian. Reanclaje pendiente en .01.06. |
| PG-B.01.02 | Cumplido | Matriz B01/B02/B03/B04/B14 arriba; C18/C19 | Incluye hermanas, argumentos distintos, mismo sitio recursivo, suspensión e identidad de revisión. |
| PG-B.01.03 | Cumplido | Tests espejo Dart/Rust detallados en .01.06 | Modelos/igualdad, decodificación estricta, atribución interlotes, raíz antes del primer `task_resumed` y secuencias inválidas. |
| PG-B.01.04 | Cumplido | `execution_task_context.dart`, `execution_stack_frame.dart`, tracker/contextos; `execution_queries.rs`, `state_pages.rs` | Orden global, pila/foco por tarea, consulta histórica y errores tipados; selección no reanuda tarea. |
| PG-B.01.05 | Cumplido | README de app/API y `api.state.query.md` | Decisiones y vida de identidades autosustentables; sin cambiar versión/estado ni agregar campos `cambio`. |
| PG-B.01.06 | No cumplido | Comandos y salidas en .01.06 | Tests dirigidos, límites de app y arquitectura pasan; el verificador Rust completo conserva dos `SIZE-NESTING` preexistentes. Conformidad SEE falla por `API.PROGRAM.VIEW` vencido y el reanclaje queda bloqueado por `API.ANALYZE@1.0.0` inmutable. No se cierra PG-B.01 con `PHASE-GREEN`. |
| PG-B.02.01 | Cumplido | `API.EXECUTE` R7/R8; C13/C14; README API/app | Historial con tarea emisora, estado histórico por evento/tarea y límites; consulta de cola de canal no disponible, declarada como dato no observable. El reanclaje oficial queda pendiente de la puerta SEE registrada en .02.06. |
| PG-B.02.02 | Cumplido | `history_events.rs`, `debug_control.rs`, `state_pages.rs`; pruebas de proyección/cubit | Casos de evento y página vacíos, selección vencida, árbol anidado/parcial, unión, ventana 4096/4097 y cursores por evento, tamaño, sesión y tarea. |
| PG-B.02.03 | Cumplido | Pruebas espejo `test/engine/execution/`, `test/application/execution/`, `test/presentation/execution/` | Orden, geometría, relaciones, hit testing, recorte, árbol, límites de horizonte y vista compacta con semántica accesible; el verificador de cobertura no se amplía. |
| PG-B.02.04 | Cumplido | `ExecutionHistoryCubit`, controladores de ventana/consulta, proyecciones y superficies de tareas | Puertos de observación y control separados; vistas consumen escenas preparadas, lectura/cache acotadas; selección no bombea agenda; ejes son índices lógicos y espera/creación no se dibujan como control alternativo. |
| PG-B.02.05 | Cumplido | README app, matriz construcción→superficie/tabla/ayuda; ARB es/en | Justifica tabla de trazas y ayuda como no aplicables por depender de foco sintáctico y no añadir gramática; conserva PG-A estático y declara cola de canal fuera de los datos expuestos. |
| PG-B.02.06 | No cumplido | Salidas dirigidas en 11.3 | Las pruebas dirigidas de app/Rust, análisis, límites, arquitectura, puente y corpus pasan. `cargo xtask verify` de engine encuentra una expectativa vieja en `program_view`; el de spec llega a `cargo deny`, que no puede actualizar avisos sin red. Conformance de `API.EXECUTE` falla por hash obsoleto y `lock --refresh API.EXECUTE` se detiene en `SEE-HASH: immutable version API.ANALYZE@1.0.0`. No se cambia otra especificación congelada ni se cierra con `PHASE-GREEN`. |
| PG-B.03.01 | Cumplido | `ENG.TRACE.STEP#R1/R2/R4`, casos B02/B03/B06/B07/B12/B15; detalles en §11.4 | Paso global por índice de evento; tarea por próximo evento atribuido. Terminal, esperas, tarea ausente/completa y tope local definidos. |
| PG-B.03.02 | Cumplido | `step_settlement_test.dart`, `step_batch_runner_test.dart`, `execution_cubit_test.dart` | Secuencias registradas con casos de tarea intercalados; límites de entrada/efecto y tarea que no alcanza objetivo. |
| PG-B.03.03 | Cumplido | Tests de runner y cubit en §11.4 | Particiones 1/2/25, comandos concurrentes, detención, límite local y prefijo confirmado antes de espera. |
| PG-B.03.04 | Cumplido | `ExecutionCubit`, `StepSettlement`, `StepBatchRunner`; tests cubit/widget | Comandos serializados, bombeo en lotes de 25, procesamiento de cada paso y selección de tarea sin cambiar agenda. |
| PG-B.03.05 | Cumplido | README app §4.8/§4.10; ARB es/en | Compatibilidad de ritmos, condiciones y distinción entre tope UI y límite reportado por motor. |
| PG-B.03.06 | Cumplido | Tests dirigidos, transporte nativo y generación del puente; resultados en §11.4 | La traza y terminación coinciden entre ambos ritmos, y el historial no duplica eventos ni salida. La suite completa queda como puerta de `PHASE-GREEN` del paquete. |
| PG-B.04.01 | Cumplido | `execution_input.rs`, `execution_resource.rs`, `resources.rs`; README API | `input` exige `(resource_id, task_id, request_id)` y texto. `request_id` es independiente de `effect_seq`; la VM conserva una sola espera global `Leer` y la identidad valida destinatario y vigencia. |
| PG-B.04.02 | Cumplido | Casos de entrada/API y escenarios de app; §11.5 | Cruce, respuesta obsoleta/duplicada/tardía, cancelación, reintento inválido con identidad nueva, ejecución homónima y los siete escenarios simulados. No se modifica el corpus congelado. |
| PG-B.04.03 | Cumplido | Tests de host, capacidades, UI, entrada y efectos; §11.5 | Escenario inmutable por ejecución, derechos intersectados y no ampliables, ausencia de E/S externa, rótulo/ayuda «Simulado» y reinicio/liberación del anfitrión. |
| PG-B.04.04 | Cumplido | Modelos `InputWait`/`SimulatedScenario`, puerto, `RustSimulatedHost`, `RustEffectGate`, `RustProgramExecution`; §11.5 | La VM decide suspensión/reanudación/fallo; la app entrega capacidades declaradas. Entrada serializada y efectos con secuencia/destinatario propios; las esperas no se autoresuelven como `Leer`. |
| PG-B.04.05 | Cumplido | README app §4.54, README API; ARB es/en | Documentados permisos, límites, orden, respuestas exactas, incertidumbre, origen simulado y vida de identidades; interfaz localizada. |
| PG-B.04.06 | No cumplido | Verificaciones dirigidas y suites amplias descritas en §11.5 | Pruebas API, FFI y app específicas pasan; no se cierra la puerta: la suite completa Flutter conserva 11 fallos ajenos al diff y la suite completa del crate API conserva el esperado antiguo de `program_view`. No se declara `PHASE-GREEN`. |
| PG-B.05.01 | Cumplido | README app §4.57; `API.EXECUTE#R9` | Entrada completa = identidad del motor (fuentes, perfil, rigor, semilla, límites, permisos) + cinta; selección y página son disposición. Rechazos de `ENG.EFFECT.TAPE#R4` tipados. |
| PG-B.05.02 | Cumplido | `API.EXECUTE` R9/C15/C16; tests de reproducción | Sin cinta y esquema desconocido por corpus; identidad, truncada, adulterada y divergente por motor real. Cinta sellada no reproducible se rechaza. |
| PG-B.05.03 | Cumplido | `rust_program_execution_replay_test.dart`, `execution_projection_test.dart` | Lotes 1/2/3/5/25 y pausas dan proyección igual; sin marcas de tiempo ni píxeles. |
| PG-B.05.04 | Cumplido | `rust_execution_reproduction.dart`, `rust_replay_rejection.dart`, `rust_execution_opening.dart`; `tape_wire.rs` | Reproducción sin gate con anfitrión ni respuestas. Defecto real corregido: `u64::MAX` en la identidad se corrompía al pasar por Dart. Contexto previo a R8 por `task_id` de `history_events`. |
| PG-B.05.05 | Cumplido | README app §4.57; README API | Datos, retención, fallos, divergencia y disposición documentados. |
| PG-B.05.06 | No cumplido | §11.6 | Igualdad grabación/reproducción y cero llamadas al anfitrión verificadas con motor real; las suites completas no están en verde (fallos heredados) y no hay control de UI ni reconstrucción de ventana desde la cinta. |
| PG-B.06.01 | Cumplido | `LANG.TASK.SCOPE#R6–R16`, `LANG.TASK.CHANNEL#R2–R8`, `ENG.TASK.AGENDA#R7`; README app §4.58 | Resultados recuperables, trampa, cancelación cooperativa, corte del anfitrión y límite conservan estados distintos; canales no exponen contenido no publicado por API. |
| PG-B.06.02 | Cumplido | `task_failure_tests`, `task_scope_tests`, `task_channel_tests`, `task_deadlock_tests`, `task_effect_order_tests` | Orden de fallos, limpiezas, canales y `Elegir` se prueban por API; bloqueo y espera externa quedan diferenciados. |
| PG-B.06.03 | Cumplido | API/FFI dirigidos; `rust_task_termination_test.dart` | Trampa sin limpiezas, Error recuperable, cancelación host con dos niveles de tareas, cinta incompleta y respuesta tardía rechazada. |
| PG-B.06.04 | Cumplido | `RustExecutionApi.stop`, `RustExecutionEventProgress`, `RustExecutionEffectSettlement`, `RustTaskFocusContext` | Cancelar → `advance` confirmado → consumir eventos/cinta → liberar; `stop()` ordinario no inventa cancelación ni borra estados previos antes de confirmarlos. |
| PG-B.06.05 | Cumplido | README app §4.58; README del motor | Tabla conducta→cinta→recursos→presentación/ayuda; PB-PRE-05 corregido tras cotejar corpus y tests del API. |
| PG-B.06.06 | No cumplido | §11.7 | Tests específicos API, app y puente pasan, pero la suite Flutter completa termina con 11 fallos heredados; no se declara `PHASE-GREEN`. |
| PG-B.07.01 | Cumplido | README app §4.8 | FIFO del motor, tres relojes separados, cotas por llamada y sin `Isolate`. |
| PG-B.07.02 | Cumplido | Tests de gate, cubit y puente real | Mismos eventos con distintos lotes y pausas; efecto manual sin sondeo; 40 lecturas de reloj completan con 80 respuestas. |
| PG-B.07.03 | Cumplido | `rust_effect_gate_test.dart`, `execution_cubit_test.dart` | Doble que cuenta llamadas por comando; leer proyección o cinta no llama al motor; mutación del tope detectada. |
| PG-B.07.04 | Cumplido | `rust_effect_gate.dart`, `rust_wire_models.dart` | Drenado acotado a 16 respuestas por llamada con lote `running`; `stop` entre lotes descarta comandos viejos. |
| PG-B.07.05 | Cumplido | README app §4.8 | Responsables, cotas y método de medición. |
| PG-B.07.06 | No cumplido | §11.6 | Secuencia conservada con ritmos y particiones distintos; máximo observado ≤33 llamadas por comando. Suites completas no verdes por fallos heredados. |
| PG-B.08.01 | Cumplido | README app §4.59 | Inventario de operaciones contra `ApiSession` y tabla de qué nivel certifica cada observación. |
| PG-B.08.02 | Cumplido | `rust_task_bridge_integration_test.dart` | B02/B03/B07/B10/B14 en es/en; entrada obsoleta/cruzada/de otro recurso, consulta de tarea desconocida, programa malformado y liberación. Sin caso nuevo de corpus. |
| PG-B.08.03 | Cumplido | `rust_task_bridge_integration_test.dart` (13 pruebas) | Transporte nativo real: archivo suelto, consulta de tarea suspendida, avance de otra, respuesta de entrada, corte y balance `release`. Sin dobles de transporte. |
| PG-B.08.04 | Cumplido | `bridge.sh check` código 0 | Sin cambio de firma Rust ni del sobre; no se regenera FRB. No se añadió escenario SEE de app: ningún caso del corpus exige observación Dart. |
| PG-B.08.05 | Cumplido | README app §4.59 | Comandos exactos; el humo local es de macOS y no certifica iOS ni Windows. |
| PG-B.08.06 | No cumplido | §11.8 | Biblioteca fresca, `test_bridge.sh` (28 pruebas), integración y generación pasan; la suite Flutter completa conserva 11 fallos heredados. Sin humo de iOS/Windows. |
| PG-B.09.01 | Cumplido | `e-pg-12-dinamico-evidencia.md` §1 | Inventario de seis escenas con oráculo y guion por evento; evidencia estática separada; diferimiento humano según la decisión del 2026-10-22. |
| PG-B.09.02 | Cumplido | `test/fixtures/task_scenes/` (12 fuentes es/en) | Mismo subprograma en dos tareas (una espera, otra avanza), error, cancelación, canal lleno, `Elegir` y revisión nueva; esperado derivado de la regla. |
| PG-B.09.03 | Cumplido | `task_scenes_protocol_test.dart` (12), `task_projection_summary_test.dart` (7) | Protocolo por identidad/estado/salida y arnés que rechaza configuración distinta, muestra incompleta, resultado divergente, tiempo no medido y manifiesto ausente. No es comprensión humana. |
| PG-B.09.04 | Cumplido | `task_projection_measurement_test.dart`, `tool/task_projection_summary.dart` | Intervalos puro e integrado separados, entradas preparadas, crudos, manifiesto y resumen recalculable; fuera de tests de widget. |
| PG-B.09.05 | Cumplido | `e-pg-12-dinamico-evidencia.md`, README app §4.60 | Protocolo, preguntas Q1–Q5, órdenes contrabalanceados, hoja de captura vacía y procedimiento reutilizable; sin participantes ni autoría inventada. |
| PG-B.09.06 | No cumplido | §11.8 | 10 procesos × 30 muestras completos con p95 y RSS; umbral candidato rotulado; evidencia humana Diferido; la suite completa no está en verde y no se declaran PG-B.C10/C11. |

#### PG-B.01.06 · comandos y resultados

Base de ejecución: Flutter 3.47.5/Dart 3.13.4, FRB 2.13.0 y Rust/Cargo 1.99.0; sistema macOS arm64. Rama `feature/agregar-ruta-de-especificacion`; HEAD de base `c31bf4c18202967dddab99201d63c188714b710c`.

- `FLUTTER_ROOT=/private/tmp/pseudolearn-flutter.aUpZMf FLUTTER_SUPPRESS_ANALYTICS=true XDG_CONFIG_HOME=/private/tmp/pseudolearn-flutter-config /Users/cgutieco/Development/flutter/bin/cache/dart-sdk/bin/dart /private/tmp/pseudolearn-flutter.aUpZMf/bin/cache/flutter_tools.snapshot test --no-pub --reporter expanded test/engine/rust/rust_event_classes_test.dart test/engine/rust/rust_program_execution_test.dart test/engine/rust/rust_watch_rows_test.dart test/domain/model/execution/execution_task_context_test.dart test/architecture/` — salida 0; 46 tests pasan, incluidos negativos de capas.
- `FLUTTER_ROOT=/private/tmp/pseudolearn-flutter.aUpZMf FLUTTER_SUPPRESS_ANALYTICS=true XDG_CONFIG_HOME=/private/tmp/pseudolearn-flutter-config /Users/cgutieco/Development/flutter/bin/cache/dart-sdk/bin/dart /private/tmp/pseudolearn-flutter.aUpZMf/bin/cache/flutter_tools.snapshot analyze --suppress-analytics --fatal-infos --fatal-warnings` — salida 0, sin problemas.
- `/private/tmp/pseudolearn-flutter.aUpZMf/bin/cache/dart-sdk/bin/dart --disable-dart-dev tool/check_limits.dart` — salida 0, todos los límites pasan.
- `cargo test --locked -p pseudolearn_api --features native --test execution_queries` — salida 0, 4/4 tests.
- `cargo clippy --locked -p pseudolearn_api --features native --test execution_queries -- -D warnings` — salida 0.
- `cargo run --manifest-path packages/pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command --bin rust-checks -- all packages/pseudolearn_engine` — salida 1 por `SIZE-NESTING` en `crates/pseudolearn_api/src/program_view_exits.rs:68` y `crates/pseudolearn_semantic/src/interface_realizations.rs:111`; ninguno de esos archivos pertenece al diff. PB-PRE-02 ya registra ambas observaciones.
- `cargo fmt --all -- --check` y `git diff --check` — salida 0.
- `cargo test --locked -p pseudolearn_api` — salida 101 al compilar `tests/native_effects.rs`: `native_effect_input` está detrás de la feature `native`. La ejecución dirigida con `--features native` pasa; no se presenta como suite completa del crate.
- `cargo run -p see_cli --bin see -- validate` — salida 0, 196 especificaciones validadas. `cargo run -p see_cli --bin see -- export --check` — salida 0, export verificado.
- `cargo run -p see_cli --bin see -- conform --subject engine --only API.STATE.QUERY` — salida 1, `SEE-STALE: engine evidence corpus hash mismatch for API.PROGRAM.VIEW`.
- `cargo run -p see_cli --bin see -- lock --refresh API.STATE.QUERY` — salida 1, `SEE-HASH: immutable version API.ANALYZE@1.0.0`; el hash anterior de `API.STATE.QUERY` sigue visible en `specifications.lock`, por lo que el contrato modificado todavía requiere reanclaje.

El primer intento del target Rust con `native` agotó el espacio temporal de compilación y clippy detectó índices potencialmente inseguros en el test. Se sustituyeron por selección explícita de tarea; `cargo clean -p pseudolearn_api` retiró 9.4 GiB de artefactos de compilación de ese paquete, y los comandos dirigidos arriba pasaron después. No se borraron fuentes. El fallo SEE restante no se corrige aquí porque requiere modificar evidencia de contratos fuera del alcance PG-B.01.

### 11.2 Cierre común: evidencia mínima por puerta

| Puerta | Evidencia que debe existir antes de marcarla |
|---|---|
| PG-B.C01 | La primera instrucción del 2026-11-02 autorizó PG-B.01 con PG-3 abierta para ese punto; una instrucción directa posterior autorizó una iteración de PG-B.02 y no PG-B.03 |
| PG-B.C02 | Revisión/aprobación del plan por persona; no confundir entrega del archivo con revisión |
| PG-B.C03 | Diff y anclajes selectivos: especificación→casos→tests→código; estados/versiones conservados |
| PG-B.C04 | Regla→caso/propiedad→vínculo→sujeto; ningún caso esperado capturado sin revisión |
| PG-B.C05 | Matriz B01–B15 con feliz/infeliz/límites y tests espejo de cada transformación |
| PG-B.C06 | Tabla por archivo de §5, arquitectura/imports/límites y negativos en verde |
| PG-B.C07 | Verificadores de comentarios/nombres/pánicos/unsafe y revisión lingüística |
| PG-B.C08 | README dueños autosustentables y reglas actualizadas cuando corresponda; sin enlaces a docs |
| PG-B.C09 | Fichas/leyendas es/en, cobertura de vistas/focos y ayuda, o no aplicabilidad justificada |
| PG-B.C10 | Riesgos actualizados, E-PG-12 dinámico con procedencia y tratamiento humano autorizado |
| PG-B.C11 | Comandos, HEAD y salidas de todos los tests/verificadores afectados en verde; deuda o fallo no es pase |
| PG-B.C12 | Autorización aplicable, skill commit-message, hash y comprobación de push ordinario a rama única |
| PG-B.C13 | Resumen por tarea y general, pendientes justificados, informe y parada antes de PG-7 |

### 11.3 Estado de ejecución de PG-B.02

La instrucción directa del 2026-11-02 autorizó una iteración completa de `PG-B.02`, pidió no solicitar aclaraciones y usar la opción recomendada. Se trabajó únicamente en `.02.01–.06`, en `feature/agregar-ruta-de-especificacion`, con `HEAD` `9cc05e39dec57fadfe6bb57c672cb07c1b0ce756`. No hubo commit ni push. PG-B.01 conserva su estado histórico y su puerta `.01.06` abierta.

#### Decisiones de implementación

- Se separó el puerto de observación del puerto de control de ejecución y ambos usan la misma sesión Rust. La observación consulta el historial por rango y el estado por tarea, evento y marco; no altera cursor ni agenda.
- La ventana de historial y su caché tienen un tope de 4096 eventos. La vista de eventos muestra páginas de marcos y valores con cursores asociados a la misma sesión, revisión, tarea y evento. Al expulsarse el evento elegido, la selección avanza al primer evento retenido.
- Las tres superficies comparten ese estado paginado: flujo por tarea con marcadores y relaciones de creación/espera; estructura jerárquica con uniones asignadas a la tarea emisora; y eventos con selección de tarea, marco y página de valores. Los ejes representan índices de eventos, sin inferir duración.
- Se expone la atribución `task_id` en cada evento histórico y se amplía `debug_state` para leer un estado histórico con `event` y `task_id`. No se consultan colas internas de canales; se etiquetan como no observables y no se reconstruyen mensajes.
- Se mantuvieron las formas estáticas de PG-A, se añadieron etiquetas es/en y semántica accesible, y se usaron tokens del sistema de diseño para medidas de presentación.
- La matriz construcción→flujo/estructura/eventos/tabla/ayuda justifica como no aplicables la tabla de trazas sintácticas y la ayuda contextual: estas superficies describen eventos de ejecución y no añaden una construcción del lenguaje.
- Se editaron R7/R8 y se añadieron C13/C14 en `API.EXECUTE` sin cambiar identidad, estado ni versión. El reanclaje no se completó porque el refresco se bloquea en `API.ANALYZE@1.0.0` inmutable.

#### Verificaciones ejecutadas

| Área | Verificación y resultado |
|---|---|
| Aplicación | Tests de arquitectura, flujo, estructura y vista compacta: 35 pasan. El test aislado de `ExecutionHistoryCubit`: 6 pasan. |
| Aplicación | `flutter analyze --fatal-infos --fatal-warnings`, `tool/check_limits.dart`, `tool/check_content.dart`, `tool/check_design_system.dart` y `tool/check_syntax_coverage.dart`: pasan; cobertura de sintaxis 78/78. |
| Aplicación | `bash tool/bridge.sh check`: termina con salida 0 y sin diferencia entre generaciones. El codegen emite avisos no fatales al no poder escribir el log global de telemetría. `bash tool/test_bridge.sh`: build debug/release y 20 tests FFI pasan. |
| API Rust | `history_events`, `debug_control` y `state_pages`: 16 tests pasan; incluyen atribución de tarea, horizonte, lectura histórica sin mover agenda, tamaños/cursor inválidos y cursor cruzado de tarea. Clippy estricto dirigido y `cargo fmt --all -- --check`: pasan. |
| Especificaciones | `see validate`: 196 especificaciones; `see export --check`: pasa. Los 15 tests de comparación dirigidos pasan. El test de matriz de ayuda detectó conteos desactualizados: se actualizó el esperado y README a 413 filas (141 keyword y 147 role), y el test pasa. |
| Espacios de trabajo | `cargo xtask verify` de spec ejecuta Clippy y todos los tests correctamente; termina con `cargo deny check`, que intenta actualizar la base RustSec y falla porque el entorno no resuelve `github.com`. El intento con una copia temporal escribible del caché llega al mismo límite de red. |
| Espacios de trabajo | `CARGO_BUILD_JOBS=1 cargo xtask verify` de engine evita la falta de espacio del primer intento y ejecuta los tests hasta `program_view`; falla `view_lists_units_in_source_order_with_inheritance_and_overrides`, cuyo esperado omite `class_node_id` y `base_node_id` presentes en la respuesta. El test y la implementación de `program_view` no pertenecen al diff; la discrepancia coincide con la observación previa de `API.PROGRAM.VIEW`. |
| Conformidad | `see conform --subject engine --only API.EXECUTE` falla `SEE-STALE: engine evidence corpus hash mismatch for API.EXECUTE`. `see lock --refresh API.EXECUTE` falla `SEE-HASH: immutable version API.ANALYZE@1.0.0`; no se editó a mano el lock ni otro contrato congelado. |
| Estado Git | `git diff --check`: pasa. Rama única conservada; cambios sin commit ni publicación. |

`PG-B.02.01–.05` quedan implementados. `.02.06` queda **No cumplido** por la conformidad/anclaje SEE y las puertas completas de workspace descritas arriba; por ello PG-B.02 no se declara `PHASE-GREEN`. PG-B.03 no se inició. La fase previa PG-B.01 también sigue abierta por `.01.06`. Se informa y se para aquí (`PHASE-STOP`).

### 11.4 Estado de ejecución de PG-B.03

La instrucción directa del 2026-11-02 autorizó una sola iteración de `PG-B.03`, sin preguntas y con opción recomendada. Se trabajó únicamente en `.03.01–.06`, en la rama única `feature/agregar-ruta-de-especificacion`; no hubo commit ni push. La autorización de este punto no reabre PG-B.01/.02 ni autoriza PG-B.04.

#### Decisiones de implementación

- El paso global termina en el primer índice de evento posterior al actual. El paso de tarea consume en orden los eventos intermedios y se detiene en el próximo evento cuyo dueño atribuido coincide con la tarea elegida.
- Los ritmos didácticos existentes (`nextStatement`, `overBlock`, `outOfBlock` y `toEnd`) conservan sus condiciones de asentamiento. La selección de tarea solo fija la condición de parada y no cambia el planificador ni activa una tarea.
- Los comandos de avance y entrada se serializan. `stop()` cancela el bombeo vigente e invalida los comandos pendientes anteriores a la detención. El corredor cede a la UI cada 25 avances.
- Esperas de entrada y efecto, terminación, fallo, tarea inexistente/completada y límite local terminan el bombeo sin fabricar eventos. Cada evento confirmado se aplica antes de evaluar el punto de parada, incluidos salida y estado observable.
- El tope de 10 000 avances se identifica como límite de seguridad de UI y tiene estado/mensaje propios. El límite que informa el motor conserva estado separado.
- La interfaz ofrece paso global; en el modo compacto combina ese comando y la selección de tarea en un menú para mantener el espacio disponible.

#### Verificaciones ejecutadas

| Área | Verificación y resultado |
|---|---|
| Suite dirigida | `flutter test test/application/execution/step_settlement_test.dart test/application/execution/step_batch_runner_test.dart test/application/execution/execution_cubit_test.dart test/application/cross_cutting_integration_test.dart test/presentation/document/components/execution_stepper_test.dart test/presentation/rendering/document/execution_stepper_render_test.dart` — 75 tests pasan, incluido el caso con el puente nativo de equivalencia de traza/terminación. |
| Caso de equivalencia | Paso global y paso por tarea procesan el mismo prefijo confirmado, terminan con el mismo índice de evento y producen la misma salida. La lectura de historia no duplica índices ni salida. |
| Suite completa | `flutter test --reporter json` — salida 1; 14 errores/fallos en tests de composición, catálogo de marcadores/ejercicios, diagramas, efectos y métricas de diagrama de clases. Ninguno de esos archivos de test está modificado en esta iteración. |
| Verificadores de aplicación | `flutter analyze --fatal-infos --fatal-warnings`, `tool/check_limits.dart`, `tool/check_content.dart`, `tool/check_design_system.dart` y `tool/check_syntax_coverage.dart`: pasan; cobertura 78/78. |
| Puente nativo | `bash tool/test_bridge.sh` — salida 0; build debug/release y 21 tests Dart–FFI pasan. |
| Generación del puente | `RUSTUP_TOOLCHAIN=1.99.0 bash tool/bridge.sh check` — salida 0; las dos regeneraciones quedan idénticas. |
| Integridad del diff | `git diff --check`: pasa. La suite completa impide declarar `PHASE-GREEN`. |
| Estado Git | Rama única conservada; sin commit ni publicación. |

`.03.01–.06` quedan cumplidos en su alcance específico. Los 14 errores/fallos de la suite completa impiden declarar `PHASE-GREEN` para el paquete, aunque los tests específicos de este punto, el transporte Dart–FFI real y la generación del puente pasan. PG-B también conserva las observaciones previas registradas en `.01.06` y `.02.06`. Se informa y se para aquí (`PHASE-STOP`).

### 11.5 Estado de ejecución de PG-B.04

La instrucción directa del 2026-11-02 autorizó una sola iteración de `PG-B.04`, sin preguntas y eligiendo la opción recomendada. Se trabajó únicamente en `.04.01–.06`, sobre `feature/agregar-ruta-de-especificacion`; no hubo commit ni push. La autorización no habilita PG-B.05.

#### Decisiones de implementación

- `Leer` mantiene una sola espera global. Cada solicitud lleva `(resource_id, task_id, request_id)`; el contador de solicitud vive en el recurso de ejecución y no comparte identidad con `effect_seq`. La API valida destinatario y vigencia antes de pasar texto a la VM. Una respuesta rechazada no consume la espera; una lectura inválida genera una nueva identidad.
- Los efectos conservan su secuencia y destinatario por tarea, incluida la liquidación concurrente. `input` y `effect_result` no se sustituyen ni se aceptan durante la espera contraria. Replay e historial no consultan al anfitrión.
- Se eligieron siete escenarios de datos inmutables: sin anfitrión, sin permisos, archivos virtuales, HTTP preparado, reloj lógico, timeout y resultado incierto. Los archivos viven en memoria; HTTP solo usa coincidencia exacta de método y URL y no abre red, DNS ni redirecciones reales. Los derechos se limitan a la intersección de la concesión del motor y el escenario.
- La app conserva el escenario entre ejecuciones y muestra «Simulado» con ayuda localizada. El anfitrión y sus capacidades se cierran al terminar, cancelar o sustituir la ejecución.

#### Verificaciones ejecutadas

- App enfocada: 79 tests pasan. `bash tool/test_bridge.sh` compila debug/release y pasan 23 tests Dart–FFI; el smoke `test/tool/bridge_benchmark_smoke_test.dart` pasa tras actualizar la entrada del escenario suspendido.
- Verificadores de app: `flutter analyze --fatal-infos --fatal-warnings`, límites, contenido, design system y cobertura sintáctica pasan; cobertura 78/78.
- Suite Flutter completa: la ejecución inicial terminó con 12 fallos; uno era el smoke FFI ya corregido y ahora pasa por separado. Los otros 11 son de aislamiento de imports, conteos de marcadores/ejercicios, diagramas, aserciones estructurales y métricas de diagramas de clases; sus tests no pertenecen al diff. No se pudo repetir la suite completa porque Flutter no abre `bin/cache/lockfile` en el SDK instalado, fuera del área escribible.
- API Rust: `cargo fmt --all -- --check` y `cargo clippy --locked -p pseudolearn_api --all-targets --features native -- -D warnings` pasan. La suite completa del crate ejecuta todos sus tests salvo uno: `program_view::view_lists_units_in_source_order_with_inheritance_and_overrides`, cuyo esperado no incluye `class_node_id` ni `base_node_id`; todos los demás targets pasan.
- Motor Rust: `CARGO_BUILD_JOBS=1 cargo xtask verify` pasa `see export`, formato y Clippy; `cargo test --workspace` no logra enlazar `lock_operations_tests`: `ld: write() failed, errno=28 (No space left on device)`.
- Benchmarks: formato de 33 archivos sin cambios pendientes; `dart test` pasa 29 tests; `dart analyze --fatal-infos --fatal-warnings` y `dart run tool/check.dart` pasan.
- `git diff --check` pasa. Rama única conservada, sin commit ni publicación.

`.04.01–.05` quedan cumplidos en el alcance implementado. `.04.06` queda **No cumplido** como puerta de fase: los tests dirigidos de API, app y FFI pasan, pero no se obtiene verde de las suites completas de Flutter y del workspace Rust. Por `PHASE-GREEN`, PG-B.04 no se declara cerrada. Se informa y se para aquí (`PHASE-STOP`), antes de PG-B.05.

### 11.6 Estado de ejecución de PG-B.05 y PG-B.07

Una sola iteración conjunta, autorizada el 2026-11-02 sin preguntas y eligiendo siempre la opción recomendada, sobre `feature/agregar-ruta-de-especificacion`. Sin commit ni push.

#### Decisiones

- La app transporta la cinta del motor y la devuelve en `replay_from_tape`; no valida cintas. Rechazos tipados en `ReplayRejection`.
- Equivalencia por proyección canónica de eventos (sin etiqueta de revisión), salida, terminación y fallo.
- Defecto hallado: la identidad de la cinta escribía presupuestos ausentes como `u64::MAX`; Dart lo reenviaba como otro número y el motor lo rechazaba. Ahora los presupuestos no configurados no figuran y ningún entero supera `i64::MAX`.
- Nueva regla `API.EXECUTE#R9` con casos C15/C16 y vínculo en la conformidad del motor.
- Drenado de efectos acotado a 16 respuestas por llamada (`maxResolutionsPerDrain`); la espera pendiente se repite idéntica en el siguiente `advance` (verificado en Rust).
- Para cumplir los límites se extrajeron `RustExecutionOpening`, `RustExecutionReproduction`, `rust_event_signature`, `rust_replay_host` y `RustPendingInputRequest`.

#### Verificaciones

- Rust: `replay_transport_tests` (7) y `tape_rejection_tests` (8) pasan; Clippy estricto del crate y `cargo fmt --check` pasan; `rust-checks all` solo informa 8 violaciones preexistentes en archivos no tocados.
- App: `flutter analyze`, límites, contenido, diseño y cobertura sintáctica pasan; `bash tool/test_bridge.sh` pasa con las pruebas nuevas de reproducción y bombeo contra el motor real.
- Suite Flutter completa: 11 fallos, los mismos heredados de §11.5 (diagramas, ejercicios, aserciones estructurales, línea base de clases); ninguno toca este diff.
- Corpus: `see validate` y `export --check` pasan; `lock --check` y `--refresh` informan el `SEE-HASH` heredado de `API.ANALYZE`. La conformidad del motor para `API.EXECUTE` exige regenerar evidencia obsoleta; ver resultado en el resumen de la iteración.

`.05.01–.05` y `.07.01–.05` cumplidos; `.05.06` y `.07.06` no cumplidos como puertas por las suites heredadas. La iteración de PG-B.06 y su puerta quedan registradas en §11.7.

### 11.7 Estado de ejecución de PG-B.06

Una iteración, autorizada el 2026-11-02 sin preguntas y eligiendo la opción recomendada, sobre `feature/agregar-ruta-de-especificacion`. HEAD base `ba5640846aba77e0a6bc0110569b5e91eedf251a`; sin commit ni push. El alcance fue exclusivamente PG-B.06.

#### Resolución de PB-PRE-05

- Se cotejaron `LANG.TASK.SCOPE#R6–R16`, `LANG.TASK.CHANNEL#R2–R8` y `ENG.TASK.AGENDA#R7` con `task_failure_tests`, `task_scope_tests`, `task_channel_tests`, `task_deadlock_tests`, `task_effect_order_tests`, `effect_suspension_session_tests` y `host_release_tests` del API.
- Las reglas y pruebas confirman que las limpiezas cooperativas, canales, efectos abandonados, cinta y bloqueo ya están integrados en VM/API. El anfitrión puede cancelar/liberar un recurso, pero no alterar la agenda de tareas. Se retiraron las frases que los describían como pendientes del README dueño; no se cambió el corpus congelado ni se inventó una operación Rust.

#### Decisiones de implementación

- `Resultado::Error` completa una tarea con resultado recuperable; la trampa global marca como fallida a la tarea que emitió `failure` e interrumpe las demás; `task_completed.outcome = cancelled` conserva la cancelación cooperativa. El corte host y el límite del motor tienen estados propios.
- El corte del anfitrión ejecuta `cancel`, solicita un `advance`, procesa la terminación y eventos confirmados, registra la cinta incompleta y recién entonces libera el recurso. `stop()` ordinario solo limpia; no fabrica una terminación ni ejecuta limpiezas de usuario.
- Se conservaron contextos finales por `task_id` sin crear `task_completed` o `scope_joined`. Resultado y estado se localizan en tabla y banda de ejecución. La cola de canal sigue declarada como no observable porque la API solo expone identidad/operación.
- No se tocaron contratos, casos, evidencia SEE, motor Rust ni archivos generados. La corrección de PB-PRE-05 quedó en el README del motor y en la documentación de la app.

#### Verificaciones

- API Rust: 61 tests dirigidos pasan en `task_failure_tests`, `task_event_tests`, `task_channel_tests`, `task_deadlock_tests`, `task_scope_tests`, `task_effect_order_tests`, `effect_suspension`, `effect_suspension_session_tests` y `host_release_tests`; incluyen cancelación anidada, limpieza LIFO, cinta incompleta y rechazo de respuesta tardía.
- App dirigida: 122 tests pasan en aplicación de ejecución, proyección de tareas, `RustProgramExecution`, compuerta de efectos, terminación de tareas, tabla, paso y runner. El caso de terminación ejecuta el motor nativo por FFI y cubre corte host con dos niveles de tareas, salida previa preservada y limpiezas omitidas.
- `bash tool/test_bridge.sh`: código 0; builds debug/release y 28 tests Dart–FFI pasan.
- `flutter analyze --fatal-infos --fatal-warnings`, `check_limits.dart`, `check_content.dart`, `check_design_system.dart` y `check_syntax_coverage.dart`: código 0; cobertura sintáctica 78/78. `git diff --check`: pasa.
- Suite Flutter completa: 2622 pasan, 1 omitido y 11 fallan fuera del diff (aislamiento de imports, conteos de marcadores/ejercicios, diagramas, aserciones estructurales y baseline de clases). Por esa puerta no se declara `PHASE-GREEN`.
- Disco antes de limpieza: 3,6 GiB disponibles (99 % usado). Se ejecutó `cargo clean` en el paquete motor, retirando 12,7 GiB de salidas regenerables, y se eliminó `apps/pseudolearn_app/build/` (120 MiB). Quedaron 14 GiB disponibles (94 % usado); no se eliminaron fuentes ni artefactos versionados.

`.06.01–.06.05` cumplidos; `.06.06` queda **No cumplido** por los 11 fallos preexistentes de la suite completa. Se para aquí (`PHASE-STOP`), antes de PG-B.07.

### 11.8 Estado de ejecución de PG-B.08 y PG-B.09

Una sola iteración conjunta, autorizada el 2026-11-02 sin preguntas y eligiendo siempre la opción recomendada, sobre `feature/agregar-ruta-de-especificacion`. HEAD base `d762c471f09e37bd429ab22db46ffdf1f8ecb064`; sin commit ni push. El alcance fue exclusivamente `.08` y `.09`.

#### Decisiones

- La integración es un test espejo (`test/engine/rust/`) sobre el transporte nativo sin dobles, con `RecordingRustTransport` solo para contar operaciones. Se afirmó estado de dominio (contextos de tarea, observación por evento, salida, rechazos), no sobres JSON.
- Oráculo corregido contra el motor, sin copiar la salida al esperado: la consulta de estado usa el vocabulario `waiting`; una tarea que espera un efecto se consulta en su evento `task_suspended`, no en la punta; el eco de la entrada es una línea de salida propia; una tarea completada no admite consulta de marcos.
- No hubo cambio Rust ni de FRB; se justifica en el README (§4.59). No se creó escenario SEE de app ni se tocó el corpus congelado.
- Las escenas dinámicas son seis fuentes bilingües validadas por el análisis real. `channel` usa tres envíos con capacidad 1 porque con dos el receptor en espera absorbe el primero y el emisor no espera.
- La medición separa un intervalo puro y uno integrado, con 0/1/10/100 tareas y ventana de 100 eventos, más 100 tareas con ventana de 4096 (única donde las cien tareas son visibles). La carga literal «100 eventos / 100 tareas» no es alcanzable y se informa.
- El umbral de 50 ms queda como candidato rotulado; el resumen no lo evalúa. La evidencia humana se registra como Diferido citando la decisión del 2026-10-22.

#### Verificaciones

- `flutter test --no-pub test/engine/rust/rust_task_bridge_integration_test.dart test/engine/rust/task_scenes_protocol_test.dart test/tool/task_projection_summary_test.dart test/architecture/`: todas pasan (52 en la ejecución conjunta).
- `bash tool/test_bridge.sh`: código 0, 28 pruebas Dart–FFI. `RUSTUP_TOOLCHAIN=1.99.0 bash tool/bridge.sh check`: código 0.
- `flutter analyze --fatal-infos --fatal-warnings`, `check_limits`, `check_content`, `check_design_system` y `check_syntax_coverage`: pasan.
- Campaña dinámica: 10 procesos, código 0, 1500 muestras; resumen y crudos regenerables en `apps/pseudolearn_app/build/task-projection/` (fuera de git y de `docs/`).
- Suite Flutter completa: 2653 pasan, 2 omitidas, 11 fallan fuera del diff (diagramas, aserciones estructurales, marcadores, aislamiento de imports, ejercicios, línea base de clases). Un duodécimo fallo transitorio (frescura de la biblioteca de release tras regenerar el puente) desapareció al recompilarla. No se declara `PHASE-GREEN`.
- No se ejecutó el humo de iOS ni de Windows ni la conformidad SEE (`API.ANALYZE` inmutable sigue bloqueando el reanclaje).
- Disco: 14 GiB libres antes y después; no hizo falta liberar espacio.

`.08.01–.05` y `.09.01–.05` cumplidos; `.08.06` y `.09.06` no cumplidos como puertas. Se para aquí (`PHASE-STOP`).
