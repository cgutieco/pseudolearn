# Fase PG-B · App y tareas observables — plan de ejecución

## 0. Metadatos y contrato de ejecución

- Origen: §4.11 del [plan general](plan-ejecucion-proposito-general.md); ADR-03/12/13, R-09–R-13/R-19/R-20, C-15, K-18/K-19 y E-PG-12 de la [hoja de ruta](../hoja-de-ruta-proposito-general.md).
- Fecha de preparación: 2026-11-02, America/Lima.
- Revisión inspeccionada: `5a0e12ae95d4f0a84743180e2a98f83a4423a16e`.
- Rama comprobada: `feature/agregar-ruta-de-especificacion`; árbol limpio antes de preparar el plan.
- Petición: «Crea el plan de ejecución detallado para `4.11 PG-B · App y tareas observables` como para que ninguna IA que lo ejecute pueda darse chance de alucinar».
- Autorización vigente: redactar este plan y enlazarlo desde el plan general. No constituye autorización de implementación, aprobación de C02, cierre de dependencias, commit, push, instalación ni inicio de PG-7. C01 y C02 siguen abiertos hasta mensajes que autoricen y revisen explícitamente el alcance correspondiente.
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
| PB-PRE-01 | PG-B depende de PG-A, PG-3, PG-4 y PG-5. PG-A está cerrada por decisión expresa el 2026-11-02; PG-4 y PG-5 figuran cerradas; PG-3 sigue en curso en el resumen global | Antes de implementar, comprobar los resúmenes detallados y obtener resolución explícita para avanzar con PG-3 abierta, o evidencia de su cierre. Crear este plan no levanta la dependencia |
| PB-PRE-02 | PG-A no declaró `PHASE-GREEN`: informó `SEE-HASH` en `API.ANALYZE`, `SEE-STALE` en conformidad engine, dos `SIZE-NESTING` Rust, suite completa Flutter no repetida y humo de plataforma pendiente | Reproducir línea base al iniciar; registrar errores vigentes, no presentarlos como comprobados hoy. Si impiden la puerta afectada, resolver dentro del alcance autorizado o informar bloqueo; no heredar un verde inexistente |
| PB-PRE-03 | La hoja de ruta emplea denominaciones históricas GP; PG-A registra edición oficial exclusivamente 2026 | Mantener edición 2026 y perfiles es/en existentes. No crear selector GP, migrador ni segunda gramática |
| PB-PRE-04 | `API.STATE.QUERY#R7` llama `task` al selector; `execution_queries.rs`, `state_pages.rs` y README de API utilizan `task_id` | Es una discrepancia literal que requiere informar y acordar alineación antes de cambiar ese contrato. Recomendación: conservar el cable `task_id`, aclarar la regla, derivar casos de aceptación/rechazo; no enviar ambos campos ni aceptar alias silenciosos |
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

- [ ] Registrar HEAD, diff y versiones reales de Flutter/Dart/Rust/FRB; volver a comprobar dependencias PB-PRE-01–06 y autorización.
- [ ] Leer completos los casos/propiedades que se reutilizarán y contratos `API.PROGRAM.VIEW`, `API.MODEL`, `API.ERRORS`, `ENG.LIMITS`, `LANG.TASK.ISOLATION`, `ENG.TASK.MEMORY`, `LIB.MODEL`, `LIB.IO`, `LIB.TIME`, `LIB.HTTP`, `LIB.SCENARIO.HTTP-TASKS` y `TOOL.SERVICE.CATALOG`. No citar un caso como leído solo por existir su archivo.
- [ ] Leer README de timeline, VM, runtime, service o SEE interno solo si se necesita modificar ese crate; aplicar su matriz de imports real, no la de otro crate del workspace.
- [ ] Registrar por regla afectada identidad, versión, estado, anclaje, casos/propiedades, sujeto y conformidad actuales. No marcar todos los contratos de esta lista como modificados.
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

- [ ] `PG-B.01.01` Contrato: inventariar evento/ejecución/revisión/tarea/marco/nodo y la atribución R8; resolver PB-PRE-04. Identificar cómo enumerar marcos y tareas, cómo empieza una hija sin `call`, qué se conserva al terminar y cómo recuperar contexto al iniciar una ventana. Extender `API.STATE.QUERY`/`API.PROGRAM.VIEW` solo donde falten datos públicos; no exportar AST privado ni adoptar nombres de depuración como identidad de dominio.
- [ ] `PG-B.01.02` Casos: derivar B01/B02/B03/B04/B14, con tabla por evento de dueño, foco, pila y variables. Incluir dos hijas del mismo subprograma con argumentos distintos y recursión dentro de una; no comparar solo nombres o profundidades.
- [ ] `PG-B.01.03` Tests: modelos/igualdad, decodificación, atribución entre lotes y tracker segregado; tarea desconocida, evento fuera de orden, revisión ajena, campos mal tipados y raíz antes del primer `task_resumed`. Mostrar que el test detecta mezclar las pilas.
- [ ] `PG-B.01.04` Código: extraer atribución/contextos del tracker global; preservar orden global y foco por tarea; consultar marcos por tarea en adaptador y mapear errores a resultados. La selección no ejecuta ni activa tareas; la vista de un evento previo no cambia al avanzar.
- [ ] `PG-B.01.05` Documentación: registrar claves y vida de identidades en README app/API, reemplazar afirmación de foco único en su ámbito y actualizar ayuda/cobertura si cambia contrato observable; aplicar §5 sin aumentar límites por comodidad.
- [ ] `PG-B.01.06` Verificar: tests espejo y API/puente afectados, casos B01–B04/B14 y arquitectura; adjuntar tabla esperado/obtenido por evento y mostrar marcos distintos en el mismo nodo. No cerrar con un mapa que nunca fue contrastado con Rust.

### PG-B.02 · Tres proyecciones y estado paginado

- [ ] `PG-B.02.01` Contrato: definir datos públicos de las tres superficies y navegación tarea/marco/evento/rango. Auditar `history_events`, `debug_state`, `query_page` y horizonte antes de proponer API nueva. Si cola/estado de canal o ámbito no se consulta, especificar consulta acotada o dato observable faltante; no reconstruir mensajes desde eventos que no los contienen.
- [ ] `PG-B.02.02` Casos: B02/B03/B05/B08/B09/B13/B14; incluir ámbito vacío, árbol anidado, unión sin espera, ausencia de más páginas, página vacía, horizonte expulsado, cursor de otra tarea/revisión/evento y 4096/4097 elementos solicitados.
- [ ] `PG-B.02.03` Tests: modelos geométricos y estado derivado; orden estable de nodos/aristas, conexiones sin cruzar cajas ajenas, hit testing, foco y leyenda; widgets compactos y accesibilidad sin depender solo de color. Negativos de toda ampliación del verificador de cobertura.
- [ ] `PG-B.02.04` Código: implementar geometría/proyección pura en adaptadores y filtrado/paginación en estado de aplicación; pintores/widgets consumen datos preparados. Una espera enlaza a causa/objetivo; una creación/unión no se pinta como bifurcación alternativa ni como control entre cuerpos locales. Eje lógico sin duración física inventada.
- [ ] `PG-B.02.05` Documentación: leyenda de extensiones didácticas, rótulos es/en, matriz construcción→flujo/estructura/evento/tabla/ayuda con test y regla; no aplicabilidad con motivo. Mantener formas estáticas de PG-A y bloqueo de exportación equivalente cuando no preserva semántica.
- [ ] `PG-B.02.06` Verificar: tests de escenas/estado/widgets y cobertura; demostrar consultas de rango, número de elementos leídos acotado, caché con límite, cambio de tarea sin movimiento de agenda y navegación con revisión correcta. No basta recortar una colección completa después de leerla.

### PG-B.03 · Paso global y paso de tarea

- [ ] `PG-B.03.01` Contrato: fijar evento global siguiente según `ENG.TRACE.STEP#R1/R2`; paso de tarea consume hasta el próximo evento atribuido a esa tarea, aplicando todos los intermedios. Separar selección/consumo/punta precargada y ritmos didácticos ya existentes. Definir resultado cuando tarea está terminada, falla, espera entrada/efecto, se alcanza límite o no existe próximo evento; sin bucle infinito ni respuesta fabricada.
- [ ] `PG-B.03.02` Casos: B02/B03/B06/B07/B12/B15. Derivar secuencia completa esperada y estado tras cada comando global o por tarea; seleccionar una tarea esperando mientras otra avanza. El lote que termina con espera primero entrega todos sus eventos confirmados.
- [ ] `PG-B.03.03` Tests: particiones 1/2/25 y cortes antes/después de cada `task_resumed`; igualdad del prefijo consumido con pasos globales; comandos rápidos concurrentes, detener entre lotes, tarea terminada/inexistente, ejecución que nunca alcanza la condición y ausencia de eventos.
- [ ] `PG-B.03.04` Código: ampliar control por un contrato pequeño, sin recrear análisis/sesión; bombear en lotes acotados y ceder a UI; aplicar eventos ajenos también a tabla/salida/esperas. Distinguir «tarea seleccionada espera» de «agenda global sin progreso». No exponer eventos futuros por haberlos precargado.
- [ ] `PG-B.03.05` Documentación: comandos, condiciones terminales, compatibilidad de ritmos y límites de seguridad de UI; distinguir tope local 10000 del límite del lenguaje (`ENG.TRACE.STEP#R4`), sin renombrar uno como otro ni retirarlo silenciosamente.
- [ ] `PG-B.03.06` Verificar: mismo programa/configuración/cinta con ambas formas de paso produce misma traza/terminación; FRB real más cubit/widget; salida no duplicada ni reemitida al consultar historia. Registrar diferencias de selección permitidas y estado canónico común.

### PG-B.04 · Efectos simulados y entradas identificadas

- [ ] `PG-B.04.01` Contrato: auditar identidad de solicitud de `Leer` frente a `effect_seq` de efecto, destinatario y vida de cada una. `input` actual recibe recurso/texto: no fingir que acepta task/solicitud. Definir rechazo de respuesta obsoleta/duplicada antes de enviarla; si se requieren lecturas concurrentes direccionables no expresables, especificar extensión pública y casos antes de implementarla. Mantener exclusión `input`/`effect_result`.
- [ ] `PG-B.04.02` Casos: B06/B07/B10/B11/B14; archivos virtuales, HTTP preparado, tiempo lógico, timeout, permiso denegado, resultado incierto y cancelación. Dos pendientes de tareas distintas; `Leer` inválido y reintento, respuesta cruzada/tardía, nueva ejecución con mismo texto.
- [ ] `PG-B.04.03` Tests: configuración inmutable del escenario, reinicio limpio del host, cero ampliación de derechos, validación de destinatario y rótulo simulado siempre visible en panel y ayuda. Dobles espía comprueban ausencia de acceso externo; integración valida lo que realmente acepta API.
- [ ] `PG-B.04.04` Código: escenario entrega datos al host del motor; VM decide espera, reanudación y fallo. Transportar tarea/solicitud en modelo y comando, validar identidad de ejecución antes de responder. Configuración y selección por estado/puerto, sin `await` en widgets ni E/S en `engine/` de Dart. No perder esperas por autoresolver toda la ejecución al precargar.
- [ ] `PG-B.04.05` Documentación: permisos, límites, orden de entrega, escenario simulado, incertidumbre y origen de respuestas; guiones válidos es/en enlazados a fichas/casos. No abrir red/rutas del equipo para «hacer pasar» HTTP.
- [ ] `PG-B.04.06` Verificar: casos de capacidad/HTTP/entrada por FRB y adaptador app, recursos abiertos cero al liberar/cortar donde corresponde, cero consultas al host durante replay y respuesta ajena rechazada sin avanzar.

### PG-B.05 · Proyecciones reproducibles

- [ ] `PG-B.05.01` Contrato: definir entrada completa y representación canónica de comparación: fuentes/perfil/rigor/configuración/semilla/límites/permisos/escenario/cinta/orden de entrega, revisión y secuencia de selección/página. Separar traza de eventos de cinta de efectos; una cinta no contiene necesariamente todos los campos de vista. Aplicar rechazos de `ENG.EFFECT.TAPE#R4`.
- [ ] `PG-B.05.02` Casos: B01/B03/B06/B12/B14; reproducción íntegra y cinta de otra identidad, truncada, adulterada, incierta/redactada y orden de entrega divergente. No esperar replay exitoso de una cinta sellada no reproducible.
- [ ] `PG-B.05.03` Tests: repetir desde estado nuevo con distintas particiones, navegación/páginas y pausas de UI; comparar IDs/relaciones/focos/pilas/variables/canales/solicitudes/terminación. No comparar timestamps ni píxeles dependientes del entorno como equivalencia semántica.
- [ ] `PG-B.05.04` Código: reconstrucción determinista sin activar host, análisis ni agenda desde pintado; invalidar caché por revisión/ejecución y ligar cursores a identidad completa. Si la ventana necesita contexto anterior a R8, obtenerlo por mecanismo verificado, no recorrer toda la cinta en cada render.
- [ ] `PG-B.05.05` Documentación: qué datos se necesitan para reproducir, límites de retención y fallos, qué cambia solo disposición y qué constituye divergencia; almacenamiento de muestras sin secretos ni artefactos generados manuales.
- [ ] `PG-B.05.06` Verificar: igualdad canónica entre ejecución/grabación/reproducción y reconstrucción de ventana; espía de host con cero llamadas en replay; todas las variantes de rechazo tipadas. La falta de transporte de cinta se resuelve antes, no se sustituye por volver a ejecutar contra host simulado.

### PG-B.06 · Cancelación, error, canal lleno y bloqueo

- [ ] `PG-B.06.01` Contrato: tabla de estados/transiciones según `LANG.TASK.SCOPE#R6`–`R16`, `LANG.TASK.CHANNEL#R2`–`R8`, `ENG.TASK.AGENDA#R7` y cinta. Diferenciar Error recuperable, trampa global, cancelación cooperativa de hermanas y cancelación del anfitrión; señalar recursos/limpiezas/efectos abandonados e incertidumbre.
- [ ] `PG-B.06.02` Casos: B08/B09/B10/B11; primer error por orden de terminación, asociados solo si realmente ocurrieron antes de cancelar, limpiezas LIFO, canal lleno/abierto vacío/cerrado con datos/cerrado vacío, `Elegir` empatado, bloqueo sin efectos frente a espera externa capaz de reanudar.
- [ ] `PG-B.06.03` Tests: estados y diagnósticos con sitios relacionados por tarea; no fabricar dos errores con dos hijas de retorno inmediato; cancelación con hijas anidadas y respuesta externa tardía; cola exacta sin confundir valor ausente con variable sin inicializar.
- [ ] `PG-B.06.04` Código: proyectar datos normativos de motor y transiciones confirmadas. Si el comando de corte requiere un `advance` para confirmar/sellar, consumir esa terminación antes de limpiar UI/recurso; no devolver «cancelled» inventado porque se llamó `stop()`. No representar el estado final del recurso como si fuera el estado de cada evento anterior.
- [ ] `PG-B.06.05` Documentación: tabla conducta→cinta→recursos→presentación→ayuda, sin copiar un plan transitorio. Corregir pendientes obsoletos solo tras resolver PB-PRE-05.
- [ ] `PG-B.06.06` Verificar: casos de error/canales/bloqueo por API y FRB, más tabla/foco/widgets. Cero hijas abandonadas por la proyección; error y cancelación no se pintan como unión exitosa; corte host no promete ejecutar limpiezas de usuario.

### PG-B.07 · Agenda independiente de presentación

- [ ] `PG-B.07.01` Contrato: reiterar agenda FIFO/cesión por masa normativa; distinguir bombeo cooperativo de UI, animación y tiempo lógico del programa. Decidir límites de cada llamada síncrona y cola/caché antes de implementarlos; respetar prohibición de Isolate del README actual.
- [ ] `PG-B.07.02` Casos: B02/B06/B12/B13/B15; mismas entradas con animación desactivada, más repintados, distintas velocidades, selección y redimensionado; efecto demorado manualmente sin sondeo infinito.
- [ ] `PG-B.07.03` Tests: pureza de presentación/composición, inmutabilidad y bombeo acotado; doble de transporte cuenta llamadas por comando y demuestra que reconstruir/repintar no pide `advance` ni responde efectos. Toda regla mecánica nueva necesita fixture que falle deliberadamente.
- [ ] `PG-B.07.04` Código: extracción de drenado de efectos si es ilimitado; acciones en aplicación, datos preparados para pintores, cesión entre lotes. Una animación puede suavizar transición visual, nunca decidir próxima tarea, respuesta ni evento. Cancelación/edición invalidan callbacks de ejecución vieja.
- [ ] `PG-B.07.05` Documentación: responsables de agenda/animación/consulta, políticas con dueño, límites de UI y cómo medirlos; no agregar excepciones de `Timer`, `await` o imports para facilitar un widget.
- [ ] `PG-B.07.06` Verificar: particiones y ritmos distintos conservan secuencia; validadores de arquitectura/pureza/límites en verde; registrar máximo lote observado y demora de detención sin afirmar garantía temporal desde un test funcional.

### PG-B.08 · Integración con puente real

- [ ] `PG-B.08.01` Contrato: inventario de operaciones y campos por escenario contra `ApiSession`, no contra métodos imaginados del bridge. Listar qué observación certifica API, adaptación Dart, cubit o widget. Conservar negociación/versiones y sesión/revisión.
- [ ] `PG-B.08.02` Casos: seleccionar B01–B15 según la matriz §7.1, recursos inválidos/liberados, JSON/clase/versión desconocidos, reinicio, edición y cierre. Casos de sintaxis es/en desde reglas y casos vigentes, sin «traducir» identificadores propios ni relajar parser para fixtures.
- [ ] `PG-B.08.03` Tests: añadir integración espejo que abre transporte real, ejecuta archivo suelto, consulta tarea suspendida, avanza otra, responde solicitud y cancela/libera. Afirmar estados de dominio y proyecciones de app, no solo sobres JSON. Los dobles se reservan para errores/particiones controlados.
- [ ] `PG-B.08.04` Código: adaptar frontera solo si hace falta; si no cambia firma Rust exportada, justificar no regenerar FRB. Si cambia, generar desde dueño y comparar; nunca editar `frb_generated.rs` ni `lib/engine/bridge/` a mano. Añadir escenario SEE app donde el corpus requiera observación Dart.
- [ ] `PG-B.08.05` Documentación: comandos exactos y alcance por plataforma; el humo de macOS no certifica iOS/Windows. README de puente actualizado solo si cambió su contrato/operación.
- [ ] `PG-B.08.06` Verificar: biblioteca nativa fresca, `bash tool/test_bridge.sh`, tests nativos afectados, integración app, conformidad afectada y generación si corresponde. Humo local de macOS/iOS según medios disponibles; cualquier falta se informa y no se presenta como ejecución física.

### PG-B.09 · E-PG-12 dinámico y medición

- [ ] `PG-B.09.01` Contrato/protocolo: cerrar inventario de escenas §7.1 con oráculo manual y configuración completa; cruzar cada estado/espera/unión/solicitud con regla. Conservar evidencia estática separada y tratar el diferimiento humano según PB-PRE-06.
- [ ] `PG-B.09.02` Casos: preparar fuentes bilingües validadas de mismo subprograma en dos tareas, una esperando y otra avanzando, error, cancelación, canal lleno, `Elegir` y revisión nueva; guion con evento exacto de cada pregunta y respuesta derivada antes de ejecutar.
- [ ] `PG-B.09.03` Tests: protocolo automatizado por identidad, geometría, tabla, navegación, accesibilidad y ausencia de omisiones; prueba de arnés que rechaza configuración diferente, muestra incompleta, resultado divergente o manifiesto faltante. No llamar a estos tests «comprensión humana».
- [ ] `PG-B.09.04` Implementar arnés de proyección pura y medición integrada por separado, con entradas preparadas y tamaños de §6; mantener rendimiento fuera de tests de widget como umbral de CI. Guardar datos crudos, manifiesto y resumen recalculable.
- [ ] `PG-B.09.05` Documentar protocolo y resultados dinámicos en `docs/` y procedimiento reutilizable en README del arnés dueño. Preparar material para ≥12 principiantes, orden contrabalanceado e idiomas, sin atribuir autoría/revisión/consentimiento inexistentes.
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
| `apps/pseudolearn_app/test/` espejo y fixtures bilingües propuestos `test/fixtures/e_pg_12_dynamic/` | Tests por responsabilidad de lib | No duplicar casos normativos Rust; fixtures no son esperados capturados. `tool/` solo arnés/adaptador/verificación |
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

### 11.1 Estado de preparación

Plan redactado el 2026-11-02 sobre la revisión de §0. Comprobaciones de preparación: `git diff --check` sin errores y puerta real `DOC-NO-TRANSIENT-REFS` de `xtask/src/documentation.rs` ejecutada mediante lanzador temporal, en verde; `cargo test -p xtask documentation` desde spec, tres tests de referencias documentales en verde; comprobación local de 54 IDs de tarea consecutivos, enlaces internos y existencia de identidades del corpus citadas (excepto `PERF.PG.APP.VIEW`, rotulado como candidato). Estas comprobaciones no certifican la implementación. Implementación no iniciada. Las casillas de §4 y C01–C13 permanecen abiertas. La creación del documento no certifica pasos implementados ni revisión humana.

Al iniciar trabajo, completar la fila de cada tarea `PG-B.nn.mm`; no reemplazarla solo por una fila agregada del punto. Estados permitidos del plan general: Cumplido, No cumplido, Diferido, No aplica y Retirado. Una tarea todavía no intentada se indica «Sin ejecutar» en el motivo con estado sin asignar; no se etiqueta artificialmente como fallo ni diferimiento.

| Tarea | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| PG-B.01.01 | — | — | Sin ejecutar |
| PG-B.01.02 | — | — | Sin ejecutar |
| PG-B.01.03 | — | — | Sin ejecutar |
| PG-B.01.04 | — | — | Sin ejecutar |
| PG-B.01.05 | — | — | Sin ejecutar |
| PG-B.01.06 | — | — | Sin ejecutar |
| PG-B.02.01 | — | — | Sin ejecutar |
| PG-B.02.02 | — | — | Sin ejecutar |
| PG-B.02.03 | — | — | Sin ejecutar |
| PG-B.02.04 | — | — | Sin ejecutar |
| PG-B.02.05 | — | — | Sin ejecutar |
| PG-B.02.06 | — | — | Sin ejecutar |
| PG-B.03.01 | — | — | Sin ejecutar |
| PG-B.03.02 | — | — | Sin ejecutar |
| PG-B.03.03 | — | — | Sin ejecutar |
| PG-B.03.04 | — | — | Sin ejecutar |
| PG-B.03.05 | — | — | Sin ejecutar |
| PG-B.03.06 | — | — | Sin ejecutar |
| PG-B.04.01 | — | — | Sin ejecutar |
| PG-B.04.02 | — | — | Sin ejecutar |
| PG-B.04.03 | — | — | Sin ejecutar |
| PG-B.04.04 | — | — | Sin ejecutar |
| PG-B.04.05 | — | — | Sin ejecutar |
| PG-B.04.06 | — | — | Sin ejecutar |
| PG-B.05.01 | — | — | Sin ejecutar |
| PG-B.05.02 | — | — | Sin ejecutar |
| PG-B.05.03 | — | — | Sin ejecutar |
| PG-B.05.04 | — | — | Sin ejecutar |
| PG-B.05.05 | — | — | Sin ejecutar |
| PG-B.05.06 | — | — | Sin ejecutar |
| PG-B.06.01 | — | — | Sin ejecutar |
| PG-B.06.02 | — | — | Sin ejecutar |
| PG-B.06.03 | — | — | Sin ejecutar |
| PG-B.06.04 | — | — | Sin ejecutar |
| PG-B.06.05 | — | — | Sin ejecutar |
| PG-B.06.06 | — | — | Sin ejecutar |
| PG-B.07.01 | — | — | Sin ejecutar |
| PG-B.07.02 | — | — | Sin ejecutar |
| PG-B.07.03 | — | — | Sin ejecutar |
| PG-B.07.04 | — | — | Sin ejecutar |
| PG-B.07.05 | — | — | Sin ejecutar |
| PG-B.07.06 | — | — | Sin ejecutar |
| PG-B.08.01 | — | — | Sin ejecutar |
| PG-B.08.02 | — | — | Sin ejecutar |
| PG-B.08.03 | — | — | Sin ejecutar |
| PG-B.08.04 | — | — | Sin ejecutar |
| PG-B.08.05 | — | — | Sin ejecutar |
| PG-B.08.06 | — | — | Sin ejecutar |
| PG-B.09.01 | — | — | Sin ejecutar |
| PG-B.09.02 | — | — | Sin ejecutar |
| PG-B.09.03 | — | — | Sin ejecutar |
| PG-B.09.04 | — | — | Sin ejecutar |
| PG-B.09.05 | — | — | Sin ejecutar |
| PG-B.09.06 | — | — | Sin ejecutar |

### 11.2 Cierre común: evidencia mínima por puerta

| Puerta | Evidencia que debe existir antes de marcarla |
|---|---|
| PG-B.C01 | Mensaje nuevo que autoriza implementar y su alcance; resolución de dependencia abierta aplicable |
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

Revisión Git de cierre: pendiente. Verificadores de implementación: no ejecutados durante la preparación documental. Pendientes: autorización/revisión del plan, dependencias y PB-PRE, implementación y sus verificaciones. Puntos de §4 cumplidos: ninguno por crear este plan. Commit/push: no realizados.
