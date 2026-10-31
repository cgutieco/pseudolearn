# Fase PG-6B · Depuración y web — plan de ejecución

## 0. Metadatos

| Campo                          | Valor                                                                                                                                                                         |
|--------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Fase                           | `PG-6B`, desarrollo de §4.9 del [plan general](plan-ejecucion-proposito-general.md)                                                                                           |
| Fecha de preparación           | 2026-10-31                                                                                                                                                                    |
| Revisión inicial inspeccionada | `88c2c176ccde217b5e69c83d7bb262e30f0429f6`                                                                                                                                    |
| Rama                           | `feature/agregar-ruta-de-especificacion`; sin ramas ni worktrees adicionales                                                                                                  |
| Estado inicial del árbol       | Limpio; rama un commit por delante de `origin` al comenzar la preparación                                                                                                     |
| Autorización de este encargo | «Necesito que implementes en una sola iteración todas las fases»; confirmada con «Ok, ejecuta el plan» |
| Alcance autorizado ahora | Implementar PG-6B.01–.09 y su cierre común; desarrollo continuo y campaña final única |
| Estado de implementación | En curso; C01/C02 autorizados el 2026-10-31; verificaciones finales pendientes |
| Dependencias                   | PG-4, PG-5 y PG-6A, con los residuos registrados en §1.2                                                                                                                      |
| Entregables futuros            | DAP VM de escritorio, variante web de la misma extensión, evidencia de navegador, materiales e informe telefónico y mediciones web                                            |

La preparación documental inicial fue seguida por autorización expresa para ejecutar toda PG-6B en
una sola iteración. Se conservan contratos → casos → tests escritos → código; las pruebas se ejecutan
al terminar el desarrollo integrado, sin cierres ni permisos rutinarios entre puntos. La autorización
incluye liberar cachés regenerables propias cuando sea necesario. No incluye instalación habitual,
publicación ni ejecución de PG-A, PG-B o PG-7. `PHASE-STOP` se aplica al cierre conjunto.

Este documento transitorio desarrolla la [hoja de ruta](../hoja-de-ruta-proposito-general.md),
ADR-08/09/10 y los puntos `PG-6B.01`–`.09`. No es fuente normativa del motor: durante la ejecución,
los contratos van al corpus y las decisiones a los README dueños, sin enlaces de regreso a `docs/`
(`DOC-README-TRUTH`, `DOC-NO-TRANSIENT-REFS`, `SPEC-BEHAVIOR-TRUTH`).

**Convenciones obligatorias.** «Existe» describe la revisión inicial, no una capacidad prometida.
«Propuesto» identifica una entrega por construir después de `C01/C02`. Los nombres de archivos nuevos
de §5 son destinos propuestos; antes de crearlos se comprueba que no exista ya un dueño equivalente.
Un comando futuro se rotula como tal. Ninguna dependencia o versión tomada de una rama `main` se
presenta como release instalada. Toda discrepancia nueva entre fuentes se reporta con sus IDs y
afecta solo al trabajo que depende de ella (`CONFLICT-REPORT`).

## 1. Punto de partida

### 1.1 Inventario comprobado

Las rutas de esta tabla son relativas a la raíz del monorepo. Un prefijo que comienza por el nombre
de un crate, como `pseudolearn_api/`, abrevia `packages/pseudolearn_engine/crates/<crate>/`.

| Pieza                      | Dueño actual                                                                                                           | Qué existe y qué falta                                                                                                                                                                                                     |
|----------------------------|------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Extensión                  | `apps/pseudolearn_vscode/package.json`, `src/activation/extension.ts`                                                  | `main: ./dist/extension.js`, cliente `vscode-languageclient/node`, comandos de archivo/proyecto, ayuda y gramática generada. No hay `browser`, DAP, Workers ni test-web                                                    |
| Capas TS                   | `apps/pseudolearn_vscode/architecture.json`                                                                            | `contracts`, `application`, `adapters`, `activation`; no existe una capa `web` ni se necesita crearla                                                                                                                      |
| Artefacto actual           | `apps/pseudolearn_vscode/artifact.contract.json`                                                                       | VSIX privado `darwin-arm64`, ejecutable incluido y hashes. El contrato solo describe ese destino; no describe un paquete web                                                                                               |
| CLI                        | `apps/pseudolearn_cli/src/`                                                                                            | `pseudo lsp`, `ejecutar --editor`, lectura confinada y transporte físico de efectos. No existe `pseudo dap`                                                                                                                |
| API de ejecución           | `packages/pseudolearn_engine/crates/pseudolearn_api/src/resources.rs`                                                  | `start`, `start_project`, `advance`, `input`, `effect_result`, `cancel`, `seek`, consultas de estado/páginas, `horizon`, retención y `release`                                                                             |
| Paso actual                | `pseudolearn_api/src/stepping.rs`                                                                                      | La operación `step` recompila y comienza otra ejecución. No controla el recurso vivo y no sirve como implementación del paso DAP con efectos                                                                               |
| Proyecto ejecutable        | `pseudolearn_api/src/project_start.rs`, `project_operations.rs`                                                        | Arranca un proyecto, pero no adjunta `ProgramView`; el pedido construido no propaga aún toda la configuración de observación, semilla, anfitrión, modo y cinta                                                             |
| Fuentes de eventos         | `pseudolearn_api/src/event_source.rs`, `program_view.rs`                                                               | La vista de fuente única no cubre por sí sola todos los módulos del proyecto; no deducir fuente y revisión desde una línea                                                                                                 |
| Tareas                     | `pseudolearn_vm/src/machine/task_queries.rs`, `task_context.rs`, `task_spill.rs`                                       | Existen contextos y resúmenes. La consulta pública actual de marcos cubre la tarea activa, no cualquier tarea suspendida                                                                                                   |
| Historia                   | `pseudolearn_timeline/src/`, `pseudolearn_api/src/execution_state.rs`                                                  | Checkpoints, horizonte, cinta y reconstrucción temporal. `seek` consulta una máquina reconstruida y conserva la continuación viva                                                                                          |
| Eventos históricos/páginas | API `execution_resource.rs`, `state_pages.rs`; timeline `effect_replay.rs`                                             | Los eventos se drenan entre lotes: no existe un historial público de eventos navegable. Páginas de marcos/objetos materializan actualmente el conjunto antes del corte; falta acceso acotado para esos casos               |
| Evaluate                   | `pseudolearn_syntax`, `pseudolearn_semantic`, `pseudolearn_lowering`                                                   | Parser y resolución de expresiones internos, operadores del runtime y análisis de efectos. No existe entrada pública para evaluar una expresión de inspección                                                              |
| Servicio LSP               | `pseudolearn_service/src/lsp_session.rs`, `lsp_workspace.rs`; `pseudolearn_api/src/service.rs`                         | `LspServer` recibe mensajes y el servicio acepta `pseudolearn/workspaceSnapshot`. El servicio no lee disco ni importa VM. API reexporta `LspServer`, pero aún no conserva un recurso LSP en `ApiSession`                   |
| Wasm                       | `pseudolearn_wasm/src/`, `tool/wasm.sh`                                                                                | `WasmSession.call(operation, argumentsJson)` devuelve texto JSON. No expone hoy una sesión LSP. Importa únicamente API, sin `native`; build canónico `wasm-release`, memoria máxima 256 MiB por instancia                  |
| Fetch de referencia        | `pseudolearn_wasm/browser/fetch_host.mjs`                                                                              | Negociación de garantías y ejecución HTTP con orígenes concedidos, `credentials: omit`, `cache: no-store`, `redirect: manual`, plazo y límite decodificado. Falta señal externa de aborto para cancelar desde la extensión |
| Tests existentes           | API `tests/history_seek_isolation_tests.rs`, `state_pages.rs`, `stepping.rs`; Wasm `browser/`; extensión `tests/host/` | Son puntos de apoyo. No acreditan DAP, extensión web ni dispositivos físicos                                                                                                                                               |

### 1.2 Deudas heredadas y consecuencias

- PG-6A fue cerrada por decisión expresa el 2026-10-31. No se declaró `PHASE-GREEN`: quedan revisión
  independiente SEE y cuatro grupos extendidos E-PG-02 por encima de 100 ms. La preparación de este
  plan no reabre esa fase ni convierte esos resultados en verde.
- El cargador LSP de escritorio atiende la primera raíz y resincroniza en guardados; no ofrece un
  watcher completo de disco. Rename materializa documentos cerrados en lotes de 64. La variante web
  necesita un cargador por URI/proveedor y debe medir también esa materialización.
- PG-4/5 conservan tareas AOT no soportadas, incumplimiento de `PERF.SUITE.CORE` y otras observaciones
  detalladas en sus planes. No prometer depuración AOT ni usar PG-6B como optimización general.
- Firefox de la campaña PG-5 no arrancó en esta máquina. Es un resultado heredado: se vuelve a
  intentar con versiones registradas, sin declarar cobertura por haber ejecutado Chromium o WebKit.
- El README de SEE registra una discrepancia entre `LIB.HTTP#R6` y `C8` sobre privacidad de cintas.
  La prueba principal de historia usa respuestas sin secretos. Si una tarea necesita resolver esa
  discrepancia, se aplica `CONFLICT-REPORT`; no cambiar regla ni esperado para habilitar replay.
- `PERF.ARTIFACT.SIZE#R1` vigente establece Wasm Brotli ≤900 KiB e iOS ≤5 MiB. Los 600 KiB/3 MiB
  que aparecen en resúmenes anteriores son antecedentes sustituidos por el cambio de PG-5. La línea
  base Wasm de 772 804 bytes pertenece a aquella revisión y no es una medición de PG-6B.

La ejecución registra nuevamente revisión, estado SEE y pruebas dirigidas antes de modificar producto.
Una falla heredada se identifica por ID y evidencia; una falla nueva no se disfraza como heredada.
Si SEE exige revisión, no se atribuye una revisión ficticia ni se concede conformidad. El cierre debe
informar cualquier impedimento de `PHASE-GREEN`; solo la persona puede decidir su tratamiento.

## 2. Lectura realizada

Preparación basada en lectura del repositorio en la revisión de §0 y auditorías separadas de núcleo/DAP,
Wasm/extensión y corpus/experimentos. El agente ejecutor vuelve a leer los dueños antes de editarlos.

- `AGENTS.md`, README raíz, plan general §2–5 y hoja de ruta: R-09/15/16, C-08/12/13,
  PG-6B, ADR-08/09/10, K-10/11, CF-14, E-PG-08 y STRIDE.
- Planes y cierres de PG-0, PG-4, PG-5 y PG-6A, para decisiones humanas y residuos pertinentes.
- README y `architecture.yaml` de `packages/pseudolearn_engine`, README de los crates syntax,
  semantic, lowering, API, VM, timeline, service y Wasm; código de las piezas inventariadas en §1.
- README y `architecture.yaml` de `apps/pseudolearn_cli`; README, `architecture.json`, manifiesto,
  contrato de artefacto, scripts de build/verificación y puertos de `apps/pseudolearn_vscode`.
- README y `architecture.yaml` de `packages/pseudolearn_spec`; puerta documental de `xtask` y su
  negativo; README/reglas del arnés de benchmarks para no introducir otra cadena allí.
- Corpus bajo `packages/pseudolearn_spec/specifications/`: `API.EXECUTE`, `API.STATE.QUERY`,
  `API.PROGRAM.VIEW`, `API.PROJECT`, `API.ERRORS`, `API.WIRE-FORMAT`, `API.VERSIONING`,
  `ENG.TRACE.STEP`, `ENG.TRACE.EVENTS`, `ENG.STATE.SNAPSHOT`, `ENG.STATE.INCREMENTAL`,
  `ENG.EFFECT.TAPE`, `ENG.EXEC.EFFECT-COMMIT`, `ENG.EXEC.EFFECT-ORDER`, `ENG.TASK.AGENDA`,
  `RT.HOST.INTERFACE`, `LIB.HTTP`, `LIB.HTTP.POLICY`, `LIB.IO`, contratos `TOOL.LSP.*` y
  `TOOL.SERVICE.WORKSPACE`, `PERF.PROTOCOL`, `PERF.ARTIFACT.SIZE`.

`TOOL.DAP` y `PERF.PG.WEB` **no existen como contratos del corpus** en la revisión inicial. El primero
es una identidad propuesta para especificar el protocolo; el segundo es una métrica candidata de la
hoja de ruta. No usarlos como si ya habilitaran `see conform` o fijaran un presupuesto aprobado.

Fuentes externas primarias consultadas para integración, sin autoridad sobre el lenguaje:

| Fuente                                                                                                                                                                                   | Qué se toma                                                       | Qué no se infiere                                                                                     |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------|
| [DAP overview](https://microsoft.github.io/debug-adapter-protocol/overview) y [esquema oficial](https://github.com/microsoft/debug-adapter-protocol/blob/main/debugAdapterProtocol.json) | Framing, inicialización, capacidades, requests y eventos          | Semántica de pasos, tareas o efectos de PseudoLearn; fijar revisión exacta del esquema al implementar |
| [Debugger Extension](https://code.visualstudio.com/api/extension-guides/debugger-extension)                                                                                              | Contribución de debugger y descriptor del adaptador               | Depuración fuente AOT o DAP web disponible                                                            |
| [Web Extensions](https://code.visualstudio.com/api/extension-guides/web-extensions)                                                                                                      | Entrada `browser`, Worker, ausencia de Node, URI y `workspace.fs` | Persistencia móvil, disco arbitrario o procesos                                                       |
| [Muestra LSP web de Microsoft](https://github.com/microsoft/vscode-extension-samples/tree/main/lsp-web-extension-sample)                                                                 | Cliente browser y transporte de mensajes al Worker                | Copiar un servidor o implementar semántica en TS                                                      |
| [test-web](https://github.com/microsoft/vscode-test-web) y [opciones del runner](https://github.com/microsoft/vscode-test-web/blob/main/src/server/index.ts)                             | Host automatizable y selección explícita de navegador/build       | Que su filesystem en memoria acredite guardado persistente ni que WebKit sea un iPhone                |
| [Artefactos por plataforma](https://code.visualstudio.com/api/working-with-extensions/publishing-extension#platform-specific-extensions)                                                 | Artefacto `web` de la misma identidad                             | Autorización para publicar o disponibilidad en hosts de terceros                                      |

Registrar después en cada README qué integración se adoptó y qué se descartó. Fijar versiones
publicadas exactas y locks, incluyendo el runner web, antes de ejecutar la campaña; no inventar ahora
una versión instalada de `@vscode/test-web`.

## 3. Decisiones de diseño

### 3.1 Elecciones propuestas y fronteras

Las recomendaciones conceptuales de ADR-08/09/10 ya están aprobadas; no se vuelven a preguntar.
Las elecciones técnicas de esta tabla forman parte de la revisión de `C02`; no son hechos implementados.

| ID          | Opciones y criterio                                                                        | Elección propuesta                                                                                            | Condición de reversión y dueño                                                                            |
|-------------|--------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------|
| `D-PG6B-01` | DAP en service, crate nuevo o borde CLI; respetar imports y evitar otra capa sin necesidad | `pseudo dap` stdio, módulos `dap_*` en CLI consumiendo solo API pública                                       | Crate nuevo solo con necesidad comprobada y reglas/README previos; nunca VM en service. README CLI/engine |
| `D-PG6B-02` | Reiniciar al avanzar o controlar recurso vivo                                              | Control observable persistente en API; CLI solo mapea protocolo                                               | Prohibido volver a `stepping.rs` para simular continuidad. README API                                     |
| `D-PG6B-03` | Hilos SO o identidad de tarea del programa                                                 | Tareas como hilos lógicos; pausa global en cada stop, agenda del núcleo intacta                               | Cambiar política requiere contrato y casos nuevos; README API/CLI                                         |
| `D-PG6B-04` | Watch arbitrario, llamadas certificadas puras o subconjunto sin llamadas                   | Evaluate inicial restringido, sobre snapshot aislado y mediante parser/semantic/lowering/VM existentes (§3.3) | Ampliación posterior solo con casos; no prometer toda expresión pura. README API/semantic                 |
| `D-PG6B-05` | Reejecutar desde pasado o cursor histórico separado                                        | Navegar historia sin repetir efectos; continuación viva conservada (§3.4)                                     | No crear ramas temporales mutables. README API/timeline/CLI                                               |
| `D-PG6B-06` | Servicio y programa juntos o aislados                                                      | Dos Workers dedicados además del host de extensión; una instancia Wasm por Worker                             | Unificar Workers queda vetado mientras un programa pueda bloquear LSP. README extensión/Wasm              |
| `D-PG6B-07` | Wasm importa service o API conserva sesión LSP                                             | Recurso LSP en API y borde fino `WasmSession.call`; Wasm sigue importando solo API                            | Si no cabe, revisión de contrato antes de implementar; no replicar handlers en JS. README API/Wasm        |
| `D-PG6B-08` | Rutas locales o URI/proveedor                                                              | `workspace.fs`, URI originales y snapshots explícitos; Rust resuelve manifiestos y proyecto                   | Proveedor incapaz se anuncia como tal. README extensión/CLI                                               |
| `D-PG6B-09` | Copiar Fetch, biblioteca nueva o consumir dueño existente                                  | Bundlear el módulo canónico `browser/fetch_host.mjs` como input externo declarado; ampliar aborto allí        | Extraer otro miembro solo si dos productos necesitan distribución independiente. README Wasm/extensión    |
| `D-PG6B-10` | Objetos JS o JSON dueño con valores exactos                                                | Mensajes de control acotados y payload API como texto; i64/u64 canónicos sin paso por `Number`                | Una codificación alternativa exige prueba de exactitud y contrato. README API/Wasm/extensión              |
| `D-PG6B-11` | Extensión nueva o variantes de la existente                                                | Misma identidad y recursos generados, bundles/contratos de artefacto separados desktop/web                    | Cambiar identidad/canal exige decisión de producto. README extensión                                      |
| `D-PG6B-12` | Inferir móvil desde WebKit o ensayar físicamente                                           | Automatización desktop obligatoria; E-PG-08 físico complementario, informe con vacíos explícitos              | CF-14 solo lo decide la persona con evidencia; no activar FUT-05. README extensión                        |

### 3.2 Contrato DAP mínimo, por definir antes del adaptador

Proponer `TOOL.DAP` en `specifications/tool/tool.dap.md`, después de comprobar que el ID siga libre.
Debe tener reglas y casos para cada fila siguiente. El esquema DAP se fija por revisión/hash; no se
añade un paquete Rust de DAP si `serde`/`serde_json` y los tipos necesarios ya resuelven la frontera.

| Operación                      | Contrato que se escribirá                                                                                                                                                                     | Rechazo o límite comprobable                                                                                                                                                               |
|--------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `initialize`                   | Capacidades reales, coordenadas según negociación del cliente y líneas/columnas del núcleo convertidas una sola vez                                                                           | No anunciar attach, setVariable/setExpression, condiciones, logpoints, reverseContinue, memoria, restart o AOT si no se implementan                                                        |
| `launch`                       | Archivo o proyecto guardado, entrada resuelta, VM, perfil/rigor/semilla/límites explícitos, snapshot inmutable de fuentes/revisiones                                                          | Configuración mal formada, raíz ajena, fuente ilegible, permisos insuficientes o backend nativo: respuesta fallida y cero ejecución                                                        |
| Configuración                  | Secuencia `initialize` → solicitud de launch → evento `initialized` → breakpoints/configuración → `configurationDone`; responder launch sin interbloquear al cliente que espera `initialized` | Configurar fuera de estado o duplicar launch no crea recursos; probar orden legal completo y variantes inválidas                                                                           |
| `setBreakpoints`               | Sustituye el conjunto de una fuente; resolver línea/columna a `statement_entered` ejecutable con identidad de fuente/nodo/revisión; devolver ubicación resuelta                               | Línea sin punto ejecutable o `sourceModified`: `verified:false` y motivo; no trasladar silenciosamente a otra sentencia                                                                    |
| `continue`                     | Avanza el recurso vivo desde su punta, o recorre primero historia retenida; responde y emite eventos en orden definido                                                                        | Una sola orden de control activa; petición duplicada o stop obsoleto no avanza dos veces                                                                                                   |
| `next`, `stepIn`, `stepOut`    | Predicados de `ENG.TRACE.STEP#R3` sobre eventos y marco de la tarea seleccionada                                                                                                              | Elegir tarea no altera la agenda; terminar esa tarea sin alcanzar el predicado produce stop/terminación definida, sin espera infinita                                                      |
| `pause`                        | Deja de bombear entre lotes y conserva recurso/entrada/efectos; emite `stopped` con pausa global                                                                                              | No llamar `cancel`, que termina la ejecución. Si no hay instrucción ejecutándose, pausar la espera conserva su identidad                                                                   |
| `threads`                      | IDs DAP int32 positivos asignados en tabla a identidades lógicas del núcleo, incluida raíz 0                                                                                                  | No usar directamente el id raíz 0 como `threadId`; no reutilizar un id de tarea terminada dentro de la sesión                                                                              |
| `stackTrace`, `scopes`         | Consulta inmutable por tarea y stop, fuente/revisión reales; pila paginada con total                                                                                                          | Tarea inexistente/terminada sin estado retenido, marco ajeno o stop vencido: error visible                                                                                                 |
| `variables`                    | Referencias opacas por stop, filtros named/indexed y páginas desde API; cantidades y valores renderizados por Rust                                                                            | Nunca materializar una colección completa para entregar una página; rango/contador inválidos y referencias viejas fallan                                                                   |
| `evaluate`                     | Subconjunto de §3.3 en marco concreto; mismo comportamiento en hover/watch/repl, sin comandos ejecutables                                                                                     | Contexto no soportado, expresión impura/no admitida, límite o error tipado: respuesta fallida sin cambio de estado                                                                         |
| `stepBack`                     | Solo VM, evento anterior de entrada a sentencia retenido y consulta exacta; capacidad anunciada solo con contrato completo                                                                    | Antes del horizonte: error, sin aproximación, reinicio ni llamada externa; AOT nunca anuncia la capacidad                                                                                  |
| Entrada                        | No reinterpretar el REPL como entrada del programa. Negociar extensión mínima: evento propuesto `pseudolearn/awaitingInput` con token de espera y request `pseudolearn/input` que lo consume  | Token opaco ligado a sesión/generación/espera; acciones línea o cancelar, vacío válido. Duplicado, token ajeno o tardío se rechazan sin alimentar otra espera; probar desde ambos clientes |
| `source`                       | Devuelve el texto del snapshot cuando se usa `sourceReference`; paths solo si corresponden a esa fuente                                                                                       | No mostrar el archivo nuevo como si fuera la revisión ejecutada                                                                                                                            |
| `terminate`, `disconnect`, EOF | Cancelar punta, abortar transportes propios, cerrar entrada, liberar recursos y finalizar una vez                                                                                             | Sin procesos ajenos afectados ni recursos vivos después del plazo; EOF antes del cierre se informa como cierre anormal                                                                     |

Entry, breakpoint, next y stepIn se detienen en el `statement_entered` que satisface su predicado,
antes de los efectos de esa sentencia; no implica que una subexpresión haya ocurrido. StepOut se
detiene en el `return` que cierra el marco, según `ENG.TRACE.STEP#R3`, sin avanzar una sentencia
extra. Pause conserva el último evento confirmado y el estado exacto de suspensión; no inventa un
`statement_entered`. Un fallo se informa en su evento `failure` y terminación conforme al contrato,
sin atribuirlo a una parada de entrada. Las mismas reglas resuelven varios puntos en una línea.
Aceptar el breakpoint no inserta instrumentación por fuera del modelo de eventos.

Toda parada global fija `(sesión, ejecución, revisión del proyecto, evento, generación de stop)`.
Marcos, scopes, páginas y referencias DAP se asocian a esa identidad. Continue, paso, seek, release
o cambio de sesión invalidan las referencias anteriores. La lista de tareas no se reconstruye desde
logs ni se confunden tareas lógicas con hilos del proceso adaptador.

**Autorización y configuración.** `.vscode/launch.json` solo solicita opciones declarativas. No
concede red, disco, secretos ni ejecutables. El proceso se crea sin shell, con argumentos separados y
entorno vacío, usando el binario verificado de PG-6A. Workspace Trust es requisito para ejecutar.
Los efectos de pruebas reciben concesiones explícitas del arnés; cualquier concesión de producto
proviene de un gesto/configuración personal confiable y de los puertos de capacidades existentes.
No ampliar permisos para que un ejemplo debug funcione. Depurar archivo/proyecto con cambios sin
guardar se rechaza inicialmente, como ejecutar en PG-6A; las consultas LSP conservan overlays.

### 3.3 Trabajo del núcleo necesario para DAP y evaluate

Antes de implementar `dap_*`, extender el contrato público en sus dueños:

1. **Control persistente.** Añadir operaciones de control/stop sobre el recurso de ejecución vivo.
   Los nombres wire se fijan en el corpus antes del dispatch. Reutilizar `advance` y eventos; un
   predicado de stop lo evalúa Rust con identidad de tarea/marco/nodo. Nunca compilar otra ejecución
   para continuar, pausar o pasar una sentencia.
2. **Proyecto.** `API.PROJECT`/`API.EXECUTE` deben expresar todas las opciones de ejecución de
   proyecto. Propagar semilla, observación, anfitrión, cinta, modo y límites; adjuntar mapa de vistas
   por fuente/revisión. `API.PROGRAM.VIEW` y los eventos deben mantener esa identidad al entrar en
   un importado. No fabricar el mapa desde nombres de subprograma.
3. **Tareas.** Ampliar `API.STATE.QUERY#R6` con inspección por tarea en un evento concreto. VM
   expone lectura inmutable de contextos activos/suspendidos; timeline consulta la copia reconstruida;
   API proyecta referencias. No activar temporalmente una tarea en la máquina viva para leerla.
   Completar acceso por rango de variables, campos y colecciones: `state_pages.rs` hoy captura el
   conjunto de variables/objeto antes de aplicar la ventana. Reutilizar cortes existentes de arreglos
   y añadir los que faltan para vector/diccionario/objetos. Una prueba instrumentada debe contar
   elementos leídos/asignaciones para demostrar que pedir una página no materializa el total.
4. **Expresión de inspección.** Proponer una operación pública con expresión, marco, revisión,
   evento y presupuesto. No existe actualmente: crear su contrato en API, con los fallos en
   `API.ERRORS`, antes de implementarla. La primera versión admite literales escalares, nombres del
   entorno léxico, campos de datos, índices y operadores puros ya definidos por el lenguaje. Rechaza
   todas las llamadas, incluso las certificadas puras, constructores con código, asignación,
   propagación, espera, creación de tareas y operaciones de capacidad. No promete toda expresión
   pura del lenguaje. No hay getters implícitos ejecutables en la inspección.
5. **Reutilización del compilador.** Abrir una entrada de expresión en syntax reutilizando el parser
   existente y exigiendo EOF; nada de concatenar una expresión a un programa de texto. Semantic
   resuelve contra un entorno de identidades y tipos del marco, sin importar API/timeline. Validar
   las formas permitidas antes de bajar. Lowering produce una función de inspección con capturas
   tipadas; bytecode/VM ejecutan sobre copia aislada, con anfitrión desconectado y presupuesto propio.
   La inyección de capturas es trabajo nuevo, no una API que ya exista. Reutilizar operadores y
   accesos del runtime; no crear un evaluador aritmético paralelo en CLI/API/TS.
6. **Inmutabilidad.** Compare antes/después de evaluate: variables, objetos, azar, cursor de cinta,
   salida, agenda y continuación vivos idénticos. Errores, límite, overflow, división por cero y
   acceso fuera de rango también conservan todo. El montón temporal se libera al terminar.

No hacer públicos los internos de `ExecutionResource` ni permitir imports inversos para ahorrar un
adaptador. Si una nueva función necesita dependencias fuera de la matriz, dividir responsabilidad o
reportar el conflicto; no añadir una excepción silenciosa.

### 3.4 Pasado sin efectos nuevos

Hay dos posiciones distintas: **punta viva** del recurso y **cursor de inspección**. `seek` actual
solo reconstruye. DAP StepBack mueve el segundo, nunca sustituye la continuación ni recrea el host.

- **Entrega nueva necesaria:** la API drena eventos después de cada lote y la reconstrucción actual
  los descarta; no existe una traza completa retenida que CLI pueda recorrer. Añadir en timeline/API
  consulta de ventanas de eventos reconstruidos desde checkpoints/cinta, con rango explícito,
  paginación máxima 4096, horizonte exacto y avance cancelable entre ventanas. Puede usar índice
  acotado bajo el presupuesto de retención, nunca una traza ilimitada en CLI. El contrato fija cómo
  encontrar el anterior `statement_entered` o `return` pertinente sin conservar toda la ejecución.
- Desde el pasado, continue/pasos recorren esas ventanas reconstruidas hasta la condición o la punta.
  No reemiten output como salida nueva ni vuelven a pedir `Leer`, HTTP o archivos. Al alcanzar la
  punta, una continuación posterior puede avanzar la ejecución viva conforme al contrato.
- Consulta fuera del horizonte falla de forma exacta. Una cinta corrupta, divergente, incompleta,
  truncada, no reproducible o con resultado externo incierto no habilita fallback `LiveRecord`.
- Una respuesta externa en vuelo pertenece a la punta y se correlaciona por sesión, generación y
  secuencia de efecto. Mientras se mira historia, no alimenta la máquina reconstruida; conservarla
  acotadamente para la punta o marcarla abandonada según el contrato existente. No reenviar la petición.
- Pause tampoco revoca un efecto físico ya despachado. Su resolución puede llegar durante la pausa;
  permanece ligada a la punta y no avanza la VM hasta reanudar. La UI no promete rollback del exterior.
- Terminate cancela la punta y sus transportes aunque el usuario mire el pasado. La ausencia de
  efectos nuevos se demuestra con contadores externos y hashes, además de fakes del núcleo (§7).

### 3.5 Worker de lenguaje y Worker de ejecución

Flujo propuesto: VS Code browser → adaptadores de URI/UI → cliente LSP browser → Worker de lenguaje
→ recurso LSP API → `LspServer`. Por separado: controlador de ejecución → Worker de ejecución →
API/VM, con solicitudes explícitas al anfitrión de capacidades. Ninguno requiere servidor remoto.

**Borde LSP.** Proponer en API operaciones de crear recurso, entregar un mensaje LSP y liberar.
El recurso conserva `LspServer`; devuelve todas sus respuestas/notificaciones en orden. Una llamada
fallida no pierde silenciosamente una notificación de sincronización. La negociación y lifecycle
siguen LSP 3.17 y el corpus vigente, no una versión indefinida. Los snapshots ya aceptados por Rust
se construyen con datos de `workspace.fs` y resoluciones públicas de manifiestos; el Worker no accede
al disco. El controlador enumera y lee, pero no decide imports, perfiles, entradas ni validez en TS.

**Cancelación LSP realista.** `LspServer.handle_message` es síncrono: un Worker sin memoria
compartida no procesa `$/cancelRequest` mientras Wasm calcula. Cancelar antes del dispatch retira
la consulta de la cola. Después del dispatch, el host marca la petición cancelada/obsoleta y no
presenta su resultado; al recuperar control, el borde cierra la petición conforme a LSP, sin prometer
interrupción inmediata ni un `-32800` instantáneo. No perder notificaciones de sincronización.
Si un plazo exige terminar el Worker, informar fallo de sesión, fallar las consultas pendientes y
recrear recurso/snapshot/overlays completos antes de servir consultas nuevas. Probar cancelación
que llega durante una consulta síncrona, no solo entre peticiones. El `AtomicBool` de la CLI depende
de otro hilo y no demuestra cancelación preemptiva del build Wasm.

**Sobre de transporte propuesto.** Versión de esquema, canal, id de sesión, generación, id de petición,
tipo y payload JSON dueño. Control con enums/cadenas y contadores dentro del rango seguro; todo valor
del programa y todo i64/u64 conserva su codificación canónica o su JSON bruto. Una respuesta tardía,
de otro Worker o de una generación anterior no produce efectos y libera sus recursos. Definir en
contratos TS las variantes concretas antes de implementar; rechazar esquemas/tipos desconocidos.

`JSON.parse`/`JSON.stringify` de un payload arbitrario del API está prohibido: puede redondear un
número antes de que el Worker lo reenvíe. El transporte opaco reenvía texto. Donde la UI necesite
proyección, Rust entrega campos de control acotados y valores canónicos como texto; el parser JS solo
lee ese esquema, nunca convierte un valor del programa a `Number`. Comprobar también cantidades de
evento, identificadores, semilla y límites. `API.WIRE-FORMAT` sigue siendo el dueño de su codificación.

**Lotes.** Una sola ejecución activa, lote acotado y una cesión real al event loop entre llamadas.
Una cadena de microtareas resueltas sin atender mensajes no cuenta como cesión. Cancel/close tienen
prioridad sobre el siguiente lote; agotado un lote se inspeccionan cancelación, entrada y respuestas.
El tamaño inicial y su máximo quedan fijados en §6, y se mide la latencia real. El Worker de lenguaje
sigue atendiendo consultas durante un bucle infinito en el otro Worker. Terminar un Worker de
ejecución por plazo se informa como aborto del anfitrión, sin afirmar limpieza semántica completada.

**Reinicio.** Cada Worker tiene estado independiente: creado → inicializando → listo → cerrando →
cerrado/fallido. No aceptar pedidos de programa antes de negociar; inicialización fallida no deja una
cola ilimitada. Reiniciar lenguaje exige snapshot y overlays completos antes de volver a responder.
Reiniciar ejecución invalida sus efectos/referencias, nunca los diagnósticos del servicio. Cerrar el
host termina ambos, cancela I/O pendiente y revoca listeners.

### 3.6 URI, capacidades y efectos del navegador

El cargador browser usa `Uri` y `workspace.fs`, conserva esquema, autoridad y percent-encoding y
comprueba pertenencia por componentes normalizados. No usa `fsPath`, `cwd`, prefijos de texto ni Node.
Raíces, archivos cerrados, overlays y manifiestos llegan como datos a Rust. Una pérdida de watcher o
un proveedor sin watcher fiable obliga a resincronización explícita antes de una operación que requiera
snapshot vigente; mostrar el estado desactualizado en vez de prometer seguimiento continuo.

La pertenencia lógica de URI no demuestra confinamiento físico si el proveedor resuelve symlinks o
alias. Rechazar enlaces detectables y operaciones de archivos del programa en proveedores cuya
garantía no alcance la capacidad solicitada. Declarar por proveedor si solo se dispone de espacio
URI lógico y no presentarlo como aislamiento nativo. Probar enlace/alias intermedio y una raíz cuyo
nombre sea prefijo de otra; no conceder acceso porque la cadena comience igual.

| Capacidad                | Concesión y operación                                                                                                                                                   | Ausencia o incertidumbre visible                                                                                                        |
|--------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------|
| Análisis/navegación      | Fuentes del editor y snapshot, sin ejecutar programa                                                                                                                    | Proveedor ilegible o snapshot incompleto: diagnóstico; no inventar archivos vacíos                                                      |
| Ejecutar/entrada/detener | VM Wasm sobre archivo/proyecto guardado y entrada seleccionada, misma política PG-6A                                                                                    | Workspace sin confianza, guardado fallido, entrada inexistente o Worker indisponible: rechazo antes de iniciar                          |
| Archivos del programa    | Capacidad distinta del permiso del editor; raíz/URI concedida expresamente y operaciones `LIB.IO` traducidas al proveedor                                               | Solo lectura, esquema no concedido, escape o límite: fallo tipado; un manifiesto no concede autoridad                                   |
| Escritura                | Entregar `Committed` solo después de confirmar el proveedor; conservar bytes necesarios de la cinta según privacidad/límites                                            | Si tras despachar una escritura no puede saberse el compromiso, `Uncertain`; no afirmar atomicidad/flush físico ni reintentar           |
| HTTP                     | Orígenes exactos concedidos fuera del proyecto; Fetch canónico con aborto externo                                                                                       | CORS, red, TLS, redirección opaca o política del sitio se muestran con la capacidad/resultado disponible                                |
| Red del navegador        | Descriptor A4 existente: TLS validado, cable no disponible, errores de certificado no distinguibles, ubicación de redirect no visible, SSRF/descompresión del navegador | No ofrecer medición de bytes de cable, control DNS/TLS, cookies ambientales, sockets o equivalencia de confinamiento con el host nativo |
| Guardado del editor      | Confirmación de la API/proveedor y verificación de contenido cuando sea posible                                                                                         | No equivale a persistencia tras expulsión/cierre ni a disponibilidad offline                                                            |
| AOT/FFI/procesos/DAP web | No disponibles en esta entrega browser                                                                                                                                  | Comandos/capacidades no se anuncian o explican su ausencia; no fallback remoto                                                          |

Reutilizar `pseudolearn_wasm/browser/fetch_host.mjs` por import y bundle automatizado, con input
externo declarado y hash. Ampliar allí `AbortSignal` externo y limpieza, manteniendo semántica y tests
existentes; no copiarlo a TS. Si hace falta tipado, declaración canónica `.d.mts` sin comentarios.
El wrapper de extensión aporta concesiones, correlación y UI, no reglas HTTP nuevas. Cada efecto
despachado tiene una sola resolución o abandono; cancelar aborta Fetch y las respuestas tardías no
se reutilizan. Cancelar después de enviar un método mutante conserva la incertidumbre que corresponda.

### 3.7 Construcción y artefactos de producto

- Mantener Node 22.23.3/pnpm 12.8.1 de la extensión y Rust 1.99.0/wasm-bindgen 0.2.129 del motor,
  salvo cambio explícitamente justificado en sus dueños. No tomar la cadena del frontend o de Flutter.
- Añadir entradas browser y Workers dentro de las capas existentes. El bundle browser no alcanza
  `node:*`, `process`, módulos nativos, `vscode-languageclient/node`, `child_process`, binarios ni
  polyfills que oculten esos imports. Usar `vscode-languageclient/browser` 10.1.2 si sus exports
  publicados lo permiten; comprobarlo antes de configurar el build.
- El build Wasm lo produce el motor; el script de empaquetado de la extensión lo consume, verifica y
  registra, sin editar enlaces ni Wasm generados. Conservar máximo lineal y grafo sin AOT.
- Extender el contrato de artefactos como datos por destino: desktop conserva bundle/binario y web
  declara bundle browser, Workers, glue/Wasm, gramática y avisos. El VSIX web usa destino `web` y no
  contiene ejecutable nativo. Cada paquete debe validar su inventario exacto; no relajar el de desktop.
- Derivar manifiestos por destino desde datos únicos: web declara `browser`, omite `main` y la
  contribución del debugger nativo; desktop conserva `main` y su debugger. Identidad, versión y
  contribuciones comunes no se mantienen en copias manuales. Validar todas las rutas declaradas y
  contextos de comandos/configuración: web no puede apuntar a un binario o bundle desktop ausente.
  Preparar `.artifacts/web-extension/` como directorio generado de instalación/host, con ese manifiesto;
  probarlo en vez de cargar el manifiesto fuente desktop por conveniencia.
- Registrar revisión/árbol sucio, toolchains, lock, target, hashes de Wasm, glue, Fetch canónico,
  bundles/Workers, gramática y VSIX. Informar licencia propia reservada y avisos de dependencias
  efectivamente incluidas. No cambiar licencia abierta ni publicar: corresponden a PG-7.

## 4. Desglose por punto

En cada punto el orden es contrato → casos derivados → tests → código/materiales → README/reglas →
verificación dirigida → integración/medición. No pasar al código si faltan contrato y casos. Las
subtareas `.07` son comprobaciones de integración/campaña, sin imponer el calendario de siete
iteraciones que tuvo PG-6A. Todas las casillas empiezan pendientes.

### PG-6B.01 · Ubicación y capa del adaptador DAP

- [ ] `PG-6B.01.01` Confirmar inventario, matriz de imports y `D-PG6B-01`–`05`; fijar el protocolo
  DAP por revisión/hash y el alcance VM. Documentar frontera CLI→API y service sin VM/DAP.
- [ ] `PG-6B.01.02` Escribir la matriz request/capacidad/error de §3.2 y derivar secuencias legales
  e ilegales; registrar qué requiere nuevo contrato API y qué es mero transporte.
- [ ] `PG-6B.01.03` Preparar tests negativos de arquitectura: intento CLI→VM/timeline, service→API/VM
  y Node alcanzable desde browser. Los fixtures deliberados no entran en recorridos ordinarios.
- [ ] `PG-6B.01.04` Declarar módulos y puertos DAP/configuración dentro de los miembros actuales,
  con una responsabilidad por archivo. No añadir ejecución al servidor LSP ni crear crate por rutina.
- [ ] `PG-6B.01.05` Actualizar README CLI, API/engine y extensión con elección, límites, imports y
  alternativas descartadas; actualizar reglas antes del código que dependa de ellas.
- [ ] `PG-6B.01.06` Verificar docs, capas/imports y negativos; revisar que ninguna propuesta se
  describa como operación existente ni que una regla de arquitectura autorice un import inverso.
- [ ] `PG-6B.01.07` Comprobar con grafo real que el adaptador consume solo API, Wasm excluye AOT y
  service conserva su matriz. Registrar evidencia antes de aceptar el resto de DAP.

### PG-6B.02 · DAP VM de escritorio y evaluate puro

- [ ] `PG-6B.02.01` Especificar `TOOL.DAP` propuesto y ampliar los contratos API de §3.3. Fijar
  lifecycle, puntos de parada, identidad por tarea/fuente/revisión, proyecto, input, evaluate y errores.
- [ ] `PG-6B.02.02` Derivar casos bilingües de archivo y proyecto de tres módulos; dos tareas con
  marcos distintos, suspensión, retorno, breakpoint repetido, edición durante pausa, referencias
  vencidas, paginación y expresiones rechazadas. Resultados derivados de reglas, sin capturas como oráculo.
- [ ] `PG-6B.02.03` Añadir tests espejo de parser/semantic/lowering/VM/timeline/API para los gaps de
  §3.3, incluida lectura/asignación acotada al paginar; tests del framing/estado DAP y cliente TS con
  puertos falsos. Fallo esperado antes de código.
- [ ] `PG-6B.02.04` Implementar primero núcleo público: configuración/vistas de proyecto, lectura
  por tarea, control vivo y evaluate aislado. Después `pseudo dap`, descriptor/configuración VS Code,
  traducción de coordenadas y entrada explícita; capacidades solo tras cobertura completa.
- [ ] `PG-6B.02.05` Actualizar README de cada crate modificado, CLI y extensión con subconjunto de
  evaluate, política de pausa, lifecycle, opciones y uso real; declarar nuevos comandos de verificación.
- [ ] `PG-6B.02.06` Ejecutar contratos dirigidos, tests espejo y verificadores afectados. Comparar
  estado/cinta/agenda antes y después de evaluate feliz, rechazado y agotado. AOT rechaza debug VM.
- [ ] `PG-6B.02.07` Ejecutar VS Code real y cliente stdio independiente sobre el mismo escenario:
  launch/configuración, breakpoint importado, entrada, pasos, tareas, pila/variables paginadas, evaluate,
  terminate y limpieza. Comparar observables exactos con las únicas normalizaciones de §7.3.

### PG-6B.03 · Historia sin HTTP ni escrituras repetidas

- [ ] `PG-6B.03.01` Completar en `API.EXECUTE`, `API.STATE.QUERY`, `ENG.EFFECT.TAPE` y DAP la
  separación punta/cursor, horizonte, respuestas en vuelo y errores sin fallback de §3.4.
- [ ] `PG-6B.03.02` Añadir casos de consultas ascendentes/descendentes, StepBack, avanzar desde
  pasado, fin de horizonte, cinta alterada/truncada y efecto mutante incierto; no exigir que una cinta
  privada no reproducible se vuelva reproducible.
- [ ] `PG-6B.03.03` Extender `history_seek_isolation_tests` con contadores de archivos/HTTP falsos;
  preparar integración física loopback y directorio temporal con hashes/contadores antes de implementar.
- [ ] `PG-6B.03.04` Implementar cursor histórico DAP y referencias de stop sin sustituir la
  continuación viva; ventanas reconstruidas en timeline/API, no una traza ilimitada CLI. La
  reproducción no recibe proveedor real; terminar cancela también la punta.
- [ ] `PG-6B.03.05` Documentar en API/timeline/CLI el pasado consultable, cinta/horizonte, errores y
  qué ocurre con input/respuestas que llegan mientras se inspecciona historia.
- [ ] `PG-6B.03.06` Probar que seek, pila, páginas y evaluate no cambian salida, azar, cinta,
  archivos ni contador HTTP y que ningún error activa LiveRecord.
- [ ] `PG-6B.03.07` En proceso real, efectuar una escritura y POST a servidor local con contador;
  retroceder, consultar y avanzar historia varias veces. Contador y bytes finales permanecen exactos;
  la siguiente sentencia viva sí puede causar un efecto nuevo una sola vez. Guardar evidencia de ambos.

### PG-6B.04 · Variante browser, LSP y ejecución separados

- [ ] `PG-6B.04.01` Especificar recurso LSP API, esquema/versionado/cierre del transporte Worker,
  cancelación, lotes y exactitud numérica. Aprobar técnicamente el borde `D-PG6B-07` en `C02`, sin
  añadir imports Wasm→service ni semántica al cliente.
- [ ] `PG-6B.04.02` Derivar casos de dos instancias aisladas, fuente obsoleta, Unicode/UTF-16,
  i64 mínimo/máximo, u64 máximo, respuesta tardía, Worker caído, memoria creciente y ejecución infinita.
- [ ] `PG-6B.04.03` Tests espejo de recurso LSP, puertos de Workers y controlador de ejecución;
  fixture de bundle con Node transitivo y prueba que detecte redondeo de enteros.
- [ ] `PG-6B.04.04` Implementar recurso API y borde Wasm; entradas browser y Workers; cliente LSP
  browser, lectura de snapshot por URI y ejecución por lotes. Portar comandos actuales a puertos
  compartidos, incluyendo formato, traducción, explicar y selección de entrada, sin CLI en browser.
- [ ] `PG-6B.04.05` Actualizar README API/Wasm/extensión, build y contratos de artefactos. Fortalecer
  verificador de imports para subpaths y inputs externos; incluir su negativo.
- [ ] `PG-6B.04.06` Probar independencia de Workers, cancelación entre lotes, liberación y exactitud
  de cada cruce host→Worker→Wasm→host; cancelación LSP en cola/durante llamada síncrona y
  resincronización tras timeout. Contrastar LSP con servidor Rust sobre el mismo snapshot.
- [ ] `PG-6B.04.07` Cargar artefacto browser final en host real automatizado; bucle infinito en VM
  no bloquea hover/diagnósticos; detener y volver a ejecutar no reinicia LSP ni aplica eventos anteriores.

### PG-6B.05 · Capacidades web y ausencias visibles

- [ ] `PG-6B.05.01` Completar descriptor de capacidades y matriz proveedor/operación de §3.6;
  especificar concesión externa, resultados Committed/Failed/Uncertain y fallos ambientales sin
  alterar `LIB.HTTP` para fingir garantías nativas.
- [ ] `PG-6B.05.02` Casos de origen no concedido, CORS, cabecera restringida, redirección opaca,
  plazo/cuerpo excesivo, cancelación tras envío, proveedor readonly, escape de raíz y escritura incierta.
- [ ] `PG-6B.05.03` Tests del Fetch canónico con señal externa y puertos FS falsos; doble resolución,
  respuesta de sesión vieja y permiso revocado. Asegurar cero llamadas físicas cuando se deniega antes del envío.
- [ ] `PG-6B.05.04` Consumir Fetch canónico en el build; implementar adaptadores de archivos del
  programa separados del guardado del editor; conectar a `effect_result`, cinta y limpieza. Sin cookies,
  reintentos automáticos, credenciales del entorno, APIs ambientales ocultas ni host remoto.
- [ ] `PG-6B.05.05` README de extensión/Wasm/CLI explican garantías por host/proveedor, comandos
  ausentes y limitaciones. Mostrar al usuario una matriz entendible, no detalles internos irrelevantes.
- [ ] `PG-6B.05.06` Tests de negociación y fallos con transporte falso; imports/artefacto verifican
  que no se incluyeron Node, backend nativo, rutas privadas, secretos ni gramática editada a mano.
- [ ] `PG-6B.05.07` Host browser con servidor HTTP/TLS de prueba y proveedor virtual: concesión,
  cuerpo/redirect/plazo, aborto en vuelo, guardado rechazado y desconexión. Comparar con nativo solo
  garantías comunes, registrando explícitamente las diferencias de A4.

### PG-6B.06 · Host real de navegador

- [ ] `PG-6B.06.01` Fijar matriz de navegadores/build VS Code, versiones publicadas del runner,
  capacidades y método de instalación local; crear manifiesto de campaña con hashes y resultado esperado.
- [ ] `PG-6B.06.02` Fixtures es/en de archivo suelto y proyecto de tres módulos con error en
  importado, Unicode, entrada vacía, cancelación y efectos concedidos/denegados; definir aserciones por paso.
- [ ] `PG-6B.06.03` Crear runner espejo de host web y pruebas de sus verificadores con bundle
  incompleto, Worker ausente, hash incorrecto y entrada Node; no contar una página mínima como host VS Code.
- [ ] `PG-6B.06.04` Añadir build/test web fijados y empaquetar artefacto browser. Mantener instalación
  desktop y su prueba de humo como consumidor afectado del manifiesto compartido.
- [ ] `PG-6B.06.05` Documentar órdenes reproducibles, versiones realmente ensayadas y proveedor de
  archivos usado. Distinguir FS en memoria de persistencia y Chromium/WebKit/Firefox de Safari físico.
- [ ] `PG-6B.06.06` Ejecutar tests dirigidos del runner, contratos de paquete, build e imports;
  comprobar que una dependencia ausente falla antes de iniciar la campaña y no se descarga al activar producto.
- [ ] `PG-6B.06.07` Ejecutar matriz Chromium, Firefox y WebKit automatizados: abrir/escribir,
  diagnosticar/completar/navegar/renombrar cerrado, formatear/traducir/ayuda, guardar, ejecutar/entrada,
  detener, reinicio y cierre. Un navegador que no arranca se registra como no evaluado, nunca aprobado.

### PG-6B.07 · E-PG-08 físico y materiales reproducibles

- [ ] `PG-6B.07.01` Transcribir el protocolo de §7.5, los criterios y la decisión previa que hace
  complementario el ensayo físico; no abrir una nueva puerta de aprobación por ausencia de teléfonos.
- [ ] `PG-6B.07.02` Preparar ambos programas/proyecto, textos inicial/final y resultados derivados,
  red normal/pérdida, página mínima de control con el mismo Wasm y formulario por combinación/ciclo.
- [ ] `PG-6B.07.03` Probar colector/analizador con datos sintéticos rotulados: duplicados, ciclo
  faltante, hash de fuente distinto, cancelación ausente y control de otro dispositivo deben fallar.
- [ ] `PG-6B.07.04` Generar materiales y scripts reproducibles en extensión, sin IDE propio;
  registrar SHA-256 de fuentes, Wasm y formularios. Los datos sintéticos nunca integran el resultado físico.
- [ ] `PG-6B.07.05` README de uso y guion describen instalación permitida, teclado, conservación
  del texto, confirmación de guardado, recuperación y límites; no publicar ni usar cuentas ajenas.
- [ ] `PG-6B.07.06` Verificar localmente integridad de materiales/control y cálculo de métricas;
  identificar qué campos requieren a la persona o APIs no disponibles.
- [ ] `PG-6B.07.07` Si la persona aporta recursos/resultados, ejecutar o analizar las 32 combinaciones
  y conservar crudos. Sin evidencia, registrar esta comprobación y la parte física del punto como
  Diferido por la decisión del 2026-10-22, «no evaluado físicamente», sin marcarlo cumplido.

### PG-6B.08 · Informe móvil y CF-14

- [ ] `PG-6B.08.01` Definir categorías del informe: comprobado automatizado, comprobado físico,
  no evaluado y no soportado; copiar la condición de decisión CF-14 sin darla por resuelta.
- [ ] `PG-6B.08.02` Derivar escenarios de informe con evidencia completa, parcial y sin teléfonos;
  ninguno puede convertir WebKit en Safari iPhone ni una falta de datos en un fallo o éxito móvil.
- [ ] `PG-6B.08.03` Tests del analizador de cobertura rechazan combinaciones inventadas, muestras
  sintéticas, pérdida de texto ocultada y cifras de memoria sin método.
- [ ] `PG-6B.08.04` Elaborar informe desde manifiestos y crudos: proveedor/guardado/teclado,
  red, ciclo básico, latencias, memoria/arranque y límites. Proponer opciones de CF-14 con evidencia,
  sin crear IDE, host remoto ni prometer móvil completo.
- [ ] `PG-6B.08.05` Actualizar README de producto con cobertura real y limitaciones; decisiones
  técnicas autosuficientes allí, informe de planificación en `docs/`, sin referencias inversas.
- [ ] `PG-6B.08.06` Auditar cada afirmación contra la matriz y cada cifra contra crudos; ninguna
  conclusión causal sobre enseñanza ni disponibilidad de todos los teléfonos.
- [ ] `PG-6B.08.07` Registrar decisión explícita de la persona sobre CF-14 cuando exista. Sin ella,
  conservar su diferimiento ya autorizado y distinguirlo del informe técnico completado. El cierre no
  usa el carácter complementario para afirmar que la persona decidió una cobertura que no decidió.

### PG-6B.09 · Métrica web candidata y tamaño del artefacto

- [ ] `PG-6B.09.01` Fijar objetivos/controles de §6 y §7.6 bajo `PERF.PROTOCOL`; distinguir
  criterios de E-PG-08, mediciones informativas y límite normativo `PERF.ARTIFACT.SIZE#R1`.
- [ ] `PG-6B.09.02` Cargas con archivo/proyecto, edición, bucle cancelable, i64, memoria creciente,
  HTTP simulado y arranque frío/caliente; definir resultado correcto antes de medir.
- [ ] `PG-6B.09.03` Tests de recolector/resumen con reloj falso y datos sintéticos: proceso faltante,
  muestra mala, salida divergente, unidad errónea y mezcla de dispositivo/build/control se rechazan.
- [ ] `PG-6B.09.04` Implementar arnés en la cadena ya admitida de extensión/browser; registrar
  preparación, motor, adaptador, I/O, total, tamaños y memoria disponible por separado. No añadir Node
  al paquete Dart de benchmarks ni un pipeline global raíz.
- [ ] `PG-6B.09.05` Documentar en README comandos, hardware, reloj, semillas y límites del método;
  si se propone `PERF.PG.WEB` en corpus, seguir creación estable 1.0.0 y aprobación sin inventar umbrales.
- [ ] `PG-6B.09.06` Verificar fórmulas, crudos, hashes, contenido de paquete, máximo lineal y
  compresión exacta; ningún número previo de PG-5 se usa como resultado nuevo.
- [ ] `PG-6B.09.07` Ejecutar 10 procesos ×30 iteraciones por objetivo/carga y control emparejado,
  conservar orden, fallos e intentos sin sustituirlos para reunir muestras válidas; calcular resumen/IC95.
  Medir Wasm Brotli y descarga/VSIX completos;
  informar aceptación/rechazo pendiente de la persona para la métrica candidata, sin bajar presupuestos.

## 5. Capas y archivos

Esta tabla responde capa, imports y dueño antes de escribir. Los prefijos de crates bajo engine
abrevian `packages/pseudolearn_engine/crates/`; no son nuevos miembros. Los archivos nuevos citados
son propuestas de separación: se pueden dividir para respetar límites, manteniendo la responsabilidad.

| Destino nuevo o modificado                                                                                          | Capa y responsabilidad única                                      | Puede importar                                                             | Prohibido / dueño que se conserva                                                                |
|---------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------|----------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| Este plan y enlaces del plan general                                                                                | Documentación transitoria raíz                                    | Documentos y fuentes consultadas                                           | No ser dependencia de código/corpus/README                                                       |
| `packages/pseudolearn_spec/specifications/tool/tool.dap.md` propuesto y contratos API/ENG/RT tocados                | Corpus normativo                                                  | Identidades internas del corpus                                            | Sin enlaces externos/docs, esperados capturados, cambios de versión/estado ni revisión atribuida |
| `packages/pseudolearn_engine/conformance.yaml`, `conformance-service.yaml`; `apps/pseudolearn_cli/conformance.yaml` | Vínculos de engine, service y CLI respectivamente                 | Contratos de los sujetos correspondientes                                  | No poner vínculos engine/DAP en manifiesto del sujeto SEE                                        |
| `packages/pseudolearn_spec/conformance.yaml`, `property-conformance.json`, esquemas/ejecutores pertinentes          | Sujeto SEE, propiedades y validación según corresponda            | Matriz declarada de `see_model`, `see_validation`, `see_conformance`, etc. | Sin imports del motor; vínculos como datos, nunca en código                                      |
| `pseudolearn_syntax/src/expression_entry.rs` propuesto                                                              | Parsear expresión aislada con parser existente                    | source, diagnostics, lexicon y propia capa                                 | Sin entorno runtime, VM, API ni segundo parser                                                   |
| `pseudolearn_semantic/src/inspection_expression.rs` propuesto                                                       | Resolver/tipar la expresión admitida en entorno explícito         | Imports ya declarados de semantic                                          | Sin lectura de máquina ni imports API/timeline; pureza sigue teniendo su dueño                   |
| `pseudolearn_lowering/src/inspection_lowering.rs` propuesto                                                         | Bajar la expresión tipada a RI                                    | Solo matriz de lowering                                                    | Sin evaluación directa en API ni semántica TS                                                    |
| VM `src/machine/task_inspection.rs` propuesto                                                                       | Leer contexto de una tarea sin activarla                          | Matriz actual VM                                                           | Sin timeline/API/service ni alteración de agenda                                                 |
| Timeline `src/task_views.rs` propuesto                                                                              | Vista por tarea desde snapshot retenido                           | vm, runtime, bytecode, diagnostics                                         | Sin anfitrión vivo durante reconstrucción ni imports API/DAP                                     |
| Timeline `src/history_window.rs` y API `src/history_operations.rs` propuestos                                       | Reconstrucción de ventanas y operación pública, separadas         | Matriz actual de cada crate                                                | No traza ilimitada CLI ni proveedor vivo; respetar horizonte/paginación                          |
| API `src/state_pages.rs` y vistas de rango de timeline                                                              | Consultas paginadas sin capturar el conjunto entero               | Matriz API/timeline respectiva                                             | Sin cortar después de materializar todos los elementos                                           |
| API `src/debug_control.rs`, `debug_evaluate.rs`, `debug_references.rs` propuestos                                   | Control vivo, evaluación aislada y referencias, cada uno separado | Matriz API existente, sin `native` obligatorio                             | No exponer recurso interno ni mezclar framing DAP con API                                        |
| API `project_start.rs`, `project_operations.rs`, vistas de proyecto                                                 | Propagar opciones / conservar identidades de fuentes              | Matriz API                                                                 | No meter resolución de disco ni reconstruir revisiones por línea                                 |
| API `src/lsp_resources.rs`, `lsp_operations.rs` propuestos                                                          | Recurso persistente y dispatch de mensajes                        | service y contratos públicos                                               | Sin E/S de host; `resources.rs` solo integra variantes                                           |
| Wasm `src/` y `tool/wasm.sh`                                                                                        | Frontera API y generación reproducible                            | Solo API; dependencias ya declaradas                                       | No service/VM directos, `native`, Cranelift ni vistas prestadas                                  |
| Wasm `browser/fetch_host.mjs`, declaración de tipos y tests                                                         | Adaptador Fetch canónico compartido                               | APIs browser y transporte inyectado                                        | No copiar a consumidor ni duplicar políticas; propio JS sin comentarios                          |
| CLI `src/dap_transport.rs`, `dap_session.rs`, `dap_requests.rs`, `dap_references.rs` propuestos                     | Framing, lifecycle, mapeo y referencias separados                 | `pseudolearn_api`, std y dependencias CLI declaradas                       | Sin crates internos del motor; reutilizar lector confinado/efectos existentes                    |
| Extensión `src/contracts/debug_session.ts`, `worker_transport.ts`, `host_capabilities.ts` propuestos                | Datos y puertos                                                   | Solo contracts                                                             | Sin VS Code, Node, Wasm ni cliente LSP                                                           |
| Extensión `src/application/` control de debug/web/snapshot                                                          | Casos de uso con puertos                                          | application, contracts                                                     | Sin APIs de host; no parser, evaluador o resolutor de manifiestos                                |
| Extensión `src/adapters/vscode_debug_adapter.ts`, `browser_language_client.ts`, `browser_*` propuestos              | Adaptadores de DAP, LSP, Workers, FS y presentación               | adapters/application/contracts y host que corresponda                      | Grafo browser sin Node; input Fetch externo exclusivamente declarado                             |
| Extensión `src/activation/browser_extension.ts`, `language_worker.ts`, `execution_worker.ts` propuestos             | Composición de cada entrada                                       | Todas las capas inferiores permitidas                                      | No alojar lógica de ejecución o capacidades en activación                                        |
| Extensión manifiesto, `artifact.contract.json`, scripts separados de build/package/check                            | Configuración/artefactos/tooling                                  | Herramientas de su cadena e inputs declarados                              | No desactivar inventario desktop ni depender de frontend/backend                                 |
| Tests de cada miembro y `tests/host`, `tests/web` en extensión                                                      | Espejo y consumidores de host                                     | Puertos públicos y tooling propio                                          | Sin duplicar casos normativos como tests Rust; negativos excluidos del recorrido ordinario       |

Antes de cambiar un archivo real, anotar en el registro de tarea su capa, imports y dueño concretos;
la tabla no permite editar cualquier archivo de un prefijo. Leer README/reglas de todos los crates
que finalmente se toquen. Si una responsabilidad ya existe, extender su dueño o delegar en él.

Límites vigentes de Rust/TS: 300 líneas por archivo, 40 por función, cuatro parámetros posicionales,
anidación tres y siete métodos públicos por clase; Rust además nombres semánticos y reglas de pánico/
unsafe. No aumentar límites para encajar un handler. Cero comentarios, incluidos JSDoc y docs Rust;
el porqué va al README. Sin excepciones a `LAYER-DIRECTION`/`LAYER-DECLARED`.

## 6. Presupuestos de rendimiento y seguridad

### 6.1 Qué es obligatorio y qué se propone medir

| Concepto                                  | Límite o criterio                                                                                                                                                            | Control y consecuencia                                                                                                                                            |
|-------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Wasm final                                | `PERF.ARTIFACT.SIZE#R1/M2`: ≤921 600 B con Brotli Q11/lgwin22, build canónico `wasm-release`                                                                                 | Mismo módulo final empaquetado; medir crudo/hash/comprimido. Superar el límite falla, sin retirar LSP del artefacto medido                                        |
| iOS                                       | ≤5 242 880 B vigente                                                                                                                                                         | Sin cambios de puente/AOT no reconstruir iOS por rutina; justificar omisión. Si cambia su frontera, medir por su procedimiento                                    |
| Memoria Wasm                              | Máximo 256 MiB por instancia                                                                                                                                                 | Verificar sección de memoria del binario. Dos instancias y editor cuestan más; no prometer máximo total de 256 MiB                                                |
| Valores/identidades                       | Exactitud i64/u64, revisiones y fuentes de extremo a extremo                                                                                                                 | Comparación exacta con control nativo y fuentes; cualquier redondeo invalida resultado                                                                            |
| Paginación                                | Máximo API existente 4096; completar mecanismos sin materialización total donde faltan                                                                                       | Casos 0, 1, 4096, 4097, primera/última/vacía y cursor de otro stop; contar elementos leídos/asignaciones                                                          |
| DAP framing propuesto                     | Cabecera ≤8 KiB, cuerpo ≤8 MiB, longitud UTF-8, ocho consultas pendientes                                                                                                    | Conservar límites equivalentes al LSP CLI; rechazar antes de reservar. Fijarlos en contrato/README, no asumir que ya existen para DAP                             |
| Workers propuestos                        | Sobre/payload ≤8 MiB, ocho consultas y 256 notificaciones pendientes; un programa activo                                                                                     | Saturación explícita, nunca descartar sincronización; pérdida exige snapshot nuevo                                                                                |
| Lote propuesto                            | Inicio 64 eventos observables; máximo 4096 y cesión entre lotes; probar también 1/2/7                                                                                        | Ajuste solo por medición manteniendo traza exacta y límite de cancelación; no confundir eventos con bytes o instrucciones                                         |
| Cancelación/edición web                   | Criterios de E-PG-08: cancelación ≤250 ms; edición p95 ≤150 ms                                                                                                               | Automatizar medición desktop y ensayar físico cuando exista; no convertirlos en PERF normativo aprobado                                                           |
| Ejecución web                             | Criterio E-PG-08: ≤3× página mínima del mismo módulo/carga/dispositivo                                                                                                       | Medir VM y coste total separados; distinto dispositivo no es control válido                                                                                       |
| Arranque, RAM, descarga JS/Workers y VSIX | Informativos, sin umbral nuevo aprobado                                                                                                                                      | Medir frío/caliente y total; no presentarlos como incluidos en límite Wasm                                                                                        |
| Evaluate propuesto                        | Texto ≤8 KiB; árbol ≤1024 nodos y profundidad ≤64; ejecución temporal con máximos de 4096 sentencias, 64 marcos y 65 536 celdas, reducidos al límite configurado si es menor | Fijar en contrato antes de código, incluidos costes de capturas y error al exceder. No ampliar límites del programa vivo, consumir su combustible ni conceder I/O |
| HTTP/FS                                   | Límites efectivos del núcleo y proveedor; reducción permitida, ampliación por proyecto prohibida                                                                             | Negociar antes de ejecutar. Cable/TLS/SSRF browser son garantías limitadas de A4                                                                                  |
| Apagado                                   | Heredar 2 s para servicio y 5 s para ejecución como plazos de host de PG-6A                                                                                                  | Medir recurso propio cerrado; si se fuerza terminate/kill, informar aborto del anfitrión                                                                          |

La métrica `PERF.PG.WEB` permanece candidata hasta decisión de la persona. No imponer los 100 ms
de E-PG-02 como si fueran un nuevo umbral web ni relajar E-PG-02 por esta fase. El programa sin
depuración no debe empezar a observar todo por defecto: control no observado frente a observado
comprueba salida/semántica y registra coste. Una regresión dispara investigación, no FUT-04 automático.

### 6.2 Límites y ataques que deben tener prueba

Denegar por defecto; concesiones externas no amplificables; paths/URI normalizados; ningún shell ni
descarga al activar. Acotar antes de reservar cada cola, cuerpo, snapshot, tabla de referencias y
retención; reutilizar límites de proyecto/ejecución existentes y documentar su valor efectivo. No
aceptar `usize` ilimitado porque una propiedad TypeScript diga `number`.

Casos STRIDE mínimos: sesión/efecto suplantado, payload alterado, cursor de otra revisión, path/URI de
escape, JSON/framing mal formado, colección/pila excesiva, bucle infinito, flood de notificaciones,
late response, credencial/cookie ambiental y escalamiento desde `launch.json` o manifiesto. Los logs
no incluyen cuerpos privados, secretos, cinta completa ni fuente íntegra por rutina. Todo fallo
esperable cruza la frontera como resultado tipado; defectos internos no filtran pila ni pánico.

## 7. Pruebas y experimentos

### 7.1 Selección, órdenes existentes y entregables futuros

La autorización del 2026-10-24 exige pruebas de corpus, espejo y consumidor del comportamiento
modificado, más verificadores afectados; no todas las suites de cada miembro por rutina. Ampliar
solo por cambio de frontera, fallo dirigido o riesgo sin cobertura y registrar el motivo.

Órdenes **existentes**; ejecutar desde el directorio indicado y seleccionar los targets reales:

| Directorio                                            | Orden y propósito                                                                                                                                                                            |
|-------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `packages/pseudolearn_spec`                           | `cargo run --locked -p see_cli --bin see -- validate`, `lock --check`, `export --check`; cada sufijo es una invocación separada del mismo prefijo                                            |
| `packages/pseudolearn_spec`                           | `cargo run --locked -p see_cli --bin see -- conform --subject engine --only API.EXECUTE`; repetir por ID/sujeto afectado, después de construir su adaptador y satisfacer validación/revisión |
| `packages/pseudolearn_engine`                         | `cargo test --locked -p pseudolearn_api --test history_seek_isolation_tests`, `--test state_pages` y `--test stepping` en invocaciones dirigidas                                             |
| `packages/pseudolearn_engine`                         | `cargo test --locked -p pseudolearn_timeline` si se cambia su reconstrucción; seleccionar tests de VM/API/semantic/lowering tocados                                                          |
| `packages/pseudolearn_engine`                         | `cargo fmt --all --check`; Clippy dirigido con `-- -D warnings`; grafo `cargo tree --locked -e normal -p pseudolearn_wasm` y API `--no-default-features`                                     |
| `packages/pseudolearn_engine`                         | `bash tool/wasm.sh build` y `bash tool/wasm.sh test` para generación reproducible y artefacto real en Chrome                                                                                 |
| `packages/pseudolearn_engine/crates/pseudolearn_wasm` | `node --test browser/fetch_host.test.mjs`; `node --test browser/http_contract.test.mjs` para loopback/Chromium-WebKit-Firefox                                                                |
| `apps/pseudolearn_cli`                                | `cargo xtask http-test-server` para servidor de integración; tests dirigidos CLI y sus verificadores según README                                                                            |
| `apps/pseudolearn_vscode`                             | `pnpm check:types`, `check:architecture`, `check:comments`, `check:size`, `check:package`, `check:grammar`, `pnpm build`, `pnpm package`                                                     |
| `apps/pseudolearn_vscode`                             | `pnpm exec vitest run <archivo-de-test-real>`; `node tests/host/run-host.mjs trusted [vsix]` y `restricted [vsix]`                                                                           |
| Miembro Rust afectado                                 | `cargo run --manifest-path <ruta-relativa-a-pseudolearn_rust_checks>/Cargo.toml -p pseudolearn_check_command -- all .`; sustituir la ruta según cwd, no ejecutar desde raíz                  |

`cargo xtask verify` integral existe en SEE, engine y CLI, pero no se ejecuta automáticamente por
redactar este plan ni sustituye la selección razonada durante implementación. `cargo deny check`
corresponde si cambia el grafo. Sin cambios Flutter, backend, frontend, marca o arnés Dart no correr
sus suites. No ejecutar GitHub Actions por push ni disparar comprobación remota sin su autorización.

**Entregables futuros de tooling.** Proponer y documentar en README de extensión scripts separados
`build:web`, `package:web`, `check:web`, `test:web` y `bench:web`, con estas responsabilidades:

- Build: consumir Wasm canónico y generar bundle browser/Workers; package: inventario/hash y VSIX web.
- Check: grafo sin Node, inputs externos permitidos, recursos/hash vigentes y máximos Wasm; cada regla
  con fixture que la viole. No sustituir estos checks por buscar una cadena en un bundle minificado.
- Test: host web fijado y fixture/runner; bench: manifiesto, recolección y resumen recalculable.

Estos scripts y suites `dap_process`, `dap_interop`, `debug_evaluate` o `tests/web` aún no existen.
Crear primero sus archivos, CLI y documentación; no simular su salida ni usar un comando imaginario
en un registro de evidencia. Si SEE no representa el nuevo protocolo, ampliar modelo/esquema,
validación y ejecutor con negativos o distinguir tests de protocolo de conformidad; nunca anunciar
una operación/sujeto DAP no negociado por el adaptador SEE.

### 7.2 Matriz mínima de casos

Los casos del corpus no se copian como tests Rust. El corpus verifica reglas observables; tests
espejo verifican mecanismos y límites; hosts verifican integración y recursos reales.

| Área               | Feliz                                      | Infeliz                                              | Borde explícito                                                                   |
|--------------------|--------------------------------------------|------------------------------------------------------|-----------------------------------------------------------------------------------|
| DAP lifecycle      | Launch/configuración/stop/terminate        | Orden inválido, launch duplicado, EOF                | Cabecera fragmentada, bytes UTF-8, longitud duplicada/excesiva, JSON vacío        |
| Breakpoint         | Archivo/importado en revisión exacta       | Línea no ejecutable, fuente modificada               | Dos sentencias en línea, CRLF, tabulador, no BMP, NFC/NFD                         |
| Control            | Continue/next/in/out sin reinicio          | Segundo control concurrente, tarea ajena             | Fin sin otro stop, pausa esperando `Leer` o efecto                                |
| Proyecto debug     | Semilla/observación/host/cinta propagados  | Entrada ausente, snapshot inválido                   | Marco en tercer módulo y perfiles por archivo                                     |
| Tareas             | Dos pilas distintas por tarea              | Id terminado o inexistente                           | Raíz 0 mapeada a DAP positivo, tarea suspendida y finalización de seleccionada    |
| Variables          | Referencias/páginas exactas                | Cursor de otro stop/sesión                           | 0/1/4096/4097, colección vacía, último índice                                     |
| Evaluate           | Lookup léxico, campo, índice, operador     | Llamada/asignación/await, nombre fuera de ámbito     | i64 extremos, división por cero, índice inválido, texto vacío, EOF extra y límite |
| Historia           | Seek y StepBack exactos                    | Horizonte/cinta inválida sin fallback                | Evento cero/primero/último, retención agotada, efecto en vuelo                    |
| Efectos históricos | Contador físico estable                    | Cinta privada o mutación incierta rechazada          | Varias idas/vueltas y retorno a punta sin reemitir output                         |
| LSP Wasm           | Mismo snapshot/respuestas que Rust         | Revisión vieja, recurso liberado                     | Cancel durante llamada síncrona, ráfaga/overflow y resincronización               |
| Workers            | Bucle VM y completado simultáneos          | Crash de uno, esquema desconocido                    | Cancel al inicio/fin de lote, respuesta de generación anterior                    |
| Valores/memoria    | i64/u64/texto exactos                      | Conversión Number detectada                          | `memory.grow`, copia propia, máximo por instancia y dos instancias                |
| URI/FS             | Virtual con autoridad y guardado           | Readonly/escape/desaparición                         | Enlace/alias intermedio, espacios/acentos/no BMP, raíz con nombre prefijo de otra |
| HTTP               | GET/POST concedido y grabado               | CORS, redirect, TLS/red/plazo, permiso denegado      | Cuerpo cero/excesivo, cancelación tras enviar, respuesta tardía                   |
| Confianza          | Ejecutar tras gesto en workspace confiable | Sin confianza no ejecuta ni concede efectos          | Revocación con sesión activa, settings de workspace intentan elevar permisos      |
| Paquete            | Desktop y web con inventario exacto        | Node transitivo, binario en web, hash/Worker ausente | Dos generaciones, actualización/reversión, ninguna descarga al activar            |
| Host               | Archivo y proyecto completos               | Guardado falla y no ejecuta versión distinta         | Recarga/cierre/desconexión, selector cancelado, input vacío frente a cancel       |
| Mediciones         | Recalcular resumen desde crudos            | Dispositivo/control/hash mezclados                   | Muestra fallida retenida, memoria no disponible, combinación física ausente       |

Cada verificador nuevo o ampliado debe fallar ante la violación deliberada y pasar al restaurar el
fixture válido. Probar el verificador, no solo el código que lo llama.

### 7.3 Interoperabilidad DAP y aislamiento físico de historia

Cliente A: host VS Code real con el VSIX y `DebugAdapterDescriptorFactory`. Cliente B: proceso stdio
independiente que construye requests según el esquema DAP fijado, sin usar el cliente TS de producto.
Ambos consumen el mismo núcleo: equivalencia no significa oráculo independiente.

Usar una secuencia declarativa compartida con entradas, stops y consultas previstas por regla. El
cliente A puede añadir mensajes propios del SDK; comparar la proyección de observables definidos,
no afirmar identidad byte a byte de toda la transcripción. Normalizar únicamente ids de transporte,
handles opacos mediante correspondencia biyectiva y prefijo temporal de rutas. No eliminar tarea,
orden, fuente, revisión, rango, resultado o error para ocultar diferencias. El comparador tiene
negativos que alteran cada uno de esos observables.

Prueba física mínima de §4.03.07: servidor ligado solo a loopback con contador de GET/POST y cuerpo
recibido; directorio temporal propio con archivo de bytes conocidos. Concesiones explícitas. Ejecutar
hasta escritura+POST, parar, registrar contador/contenido/hash y metadatos disponibles. Hacer seek,
variables, evaluate y StepBack en orden ascendente/descendente. Exigir mismo contador, mismos bytes
y cero operaciones nuevas del proveedor. Reanudar historia hasta la punta conserva todo; avanzar
a una sentencia nueva produce exactamente su efecto esperado. Incluir cancel/timeout de POST con
resultado incierto, sin reintento, y salida de programa que no se duplica al mirar atrás.

Conservar logs del servidor, manifiesto de archivos y secuencia de requests, sin datos privados.
Liberar servidor, procesos y temporales propios aun si una aserción falla. Un fake no sustituye esta
integración; la integración no sustituye los casos normativos de aislamiento del replay.

### 7.4 Navegadores y uso local de la variante web

Matriz objetivo automatizada: Chromium, Firefox y WebKit. Registrar SO, build real de cada navegador,
versión publicada exacta de test-web y commit de VS Code de 40 caracteres. Chromium automatizado no
certifica Chrome Android; WebKit no certifica Safari macOS ni Safari iPhone. Solo declarar productos/
versiones adicionales cuando haya ensayo real. Si Firefox vuelve a fallar, conservar error y hueco;
no afirmar los tres ni marcar `.06` cumplido sin la matriz requerida o tratamiento humano explícito.

Plantilla de invocación **futura**, desde `apps/pseudolearn_vscode`, después de crear runner y fixtures:

```bash
pnpm exec vscode-test-web --browser=chromium --quality=stable --commit="$PSEUDOLEARN_WEB_VSCODE_COMMIT" --extensionDevelopmentPath=.artifacts/web-extension --extensionTestsPath=dist/web/test/index.js --headless tests/fixtures/web/project
```

Repetir cambiando únicamente navegador a `firefox`/`webkit`. La variable se carga del manifiesto de
campaña y debe validarse antes; vacía no significa «usar latest». Test-web y sus descargas son tooling
de pruebas, no dependencias que producto descargue al activar. Verificar flags contra la release
fijada antes de guardar la orden definitiva en README.

El FS virtual del runner mantiene escrituras en memoria; probar confirmación/rechazo y lectura
posterior, sin acreditar persistencia tras recarga. La cobertura en `vscode.dev`/`github.dev` es otra
fila: solo ensayo real con proveedor y mecanismo de carga permitido. No suponer que un VSIX local se
instala en esos hosts como en escritorio. Preparar paquete servido por HTTPS y ruta de sideload
documentada si el host la permite; si necesita alojamiento/cuenta/publicación, preparar el artefacto
concreto y pedir únicamente ese acceso cuando se vaya a usar. No publicar por cumplir una prueba.

### 7.5 E-PG-08: materiales y resultados físicos

Matriz completa prevista: 2 teléfonos (Safari iPhone/Chrome Android) ×2 hosts (`vscode.dev`/`github.dev`)
×2 teclados (táctil/físico) ×2 cargas (archivo suelto/proyecto de tres módulos) ×2 redes (normal/pérdida)
= **32 combinaciones**, 20 ciclos por combinación, **640 ciclos** si todos los recursos están disponibles.
Una combinación inaccesible se registra, no se sustituye por otra y no entra al denominador de éxito.

Cada ciclo: abrir → escribir texto previsto → formatear → guardar y comprobar contenido → ejecutar
VM → entregar entrada → detener. Registrar texto antes/después, confirmación de guardado, salida,
terminación, latencias y cualquier recuperación. Criterios de la hoja de ruta: cero pérdida de texto,
edición p95 ≤150 ms, cancelación ≤250 ms mediante lotes y ejecución ≤3× la página mínima del mismo
teléfono con idéntico módulo Wasm/carga. Registrar arranque y RAM sin inventar un máximo aprobado.

El kit contiene manifiesto de dispositivo/SO/browser/build/host/proveedor/teclado/red, hashes,
instrucciones de carga, fuentes inicial/final, tabla de 20 ciclos, página de control, exportación de
crudos y analizador recalculable. Guardar el hash del control y producto para impedir comparaciones
de módulos distintos. Una pérdida de texto o un fallo persistente de teclado/guardado se informa
individualmente aunque un promedio parezca favorable.

`memory.buffer.byteLength` solo mide memoria lineal de una instancia, no RAM del editor/pestaña.
Si no hay API o medición física fiable, el campo RAM total dice «no disponible» con método/limitación.
Offline, recarga y expulsión de pestaña son observaciones separadas, no promesas por guardar una vez.

La persona ya declaró estas pruebas complementarias el 2026-10-22. La IA prepara y valida el kit;
no fabrica ensayos físicos ni exige un nuevo aplazamiento por falta de hardware. Sin resultados se
conserva el diferimiento autorizado y no se anuncia móvil completo. CF-14 sigue requiriendo decisión
explícita cuando corresponda; las opciones futuras no se activan automáticamente.

### 7.6 Campaña automatizable de rendimiento

Aplicar `PERF.PROTOCOL#R1–R6`: semilla fija, estado nuevo, diez procesos independientes y treinta
iteraciones por objetivo/carga; control emparejado en el mismo hardware, condiciones alternadas y
orden/semillas registrados. Dos contextos del mismo navegador no equivalen a dos procesos. No correr
compilaciones, hosts pesados o mediciones competidoras a la vez. Los arranques fríos se muestrean
creando instancias nuevas; las muestras calientes se etiquetan, sin mezclarlas en un solo percentil.
La instrumentación conserva datos en memoria durante el intervalo; no escribe archivos/logs dentro
de él. Validar salida/terminación y persistir la muestra después de cerrar el intervalo medido.

| Objetivo    | Inicio/fin de intervalo                                                                  | Control y validación                                                                                                                                        |
|-------------|------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Arranque    | Activación solicitada → Workers negociados, snapshot listo y primera respuesta útil      | Mismo artefacto/carga con preparación separada; informar red/cache/compilación Wasm                                                                         |
| Edición UI  | Gesto de edición → cambio de modelo/render confirmado, con instrumento/método registrado | Operacionalización propuesta de los 150 ms de E-PG-08; no reemplaza ensayo físico de teclado/guardado. Si no se observa render, declarar qué parte se midió |
| Diagnóstico | Cambio de versión del modelo → diagnóstico correcto de esa versión presentado            | Métrica semántica separada, sin atribuirle automáticamente el límite de edición UI; no contar una respuesta obsoleta como rápida                            |
| Cancelación | Comando recibido por host → confirmación terminal, sin más efectos propios               | Bucle determinista, lote registrado, comparar parada real y plazo de aborto                                                                                 |
| Ejecución   | Inicio de ejecución → terminación correcta                                               | Página mínima con mismo Wasm/hash/carga/semilla/límites; separar preparación/adaptador/motor                                                                |
| Memoria     | Instancias y checkpoints conocidos a lo largo de carga                                   | Memoria lineal de cada Worker por separado, herramienta/limitaciones del total; máximo muestreado es cota inferior                                          |
| Artefacto   | Bytes finales sin preparar otra variante menor                                           | Wasm crudo/Brotli, glue, cada bundle/Worker, recursos, VSIX y descarga total separados                                                                      |

Conservar crudos, fallos y timeouts. Verificar salida/estado antes de computar cocientes; una muestra
incorrecta invalida esa comparación y se informa, no se descarta silenciosamente. Cada intento
conserva su posición original; informar intentos, válidos y fallidos por proceso. No reemplazar
fallos para conseguir treinta éxitos ni aprobar rendimiento de una carga incorrecta. Calcular p95 y
IC95 bootstrap reproducible sobre medias por proceso según el protocolo, semilla del análisis
registrada. Documentar resolución del reloj y cambios de régimen. No extrapolar desktop a teléfonos.

La comparación VM pura/no observada frente a debug/observada registra el coste de la funcionalidad;
no sustituye el control página mínima para web. Generar resumen con rutas/hashes, umbrales de origen,
resultado y vacíos; pedir aceptación de la candidata solo con el informe concreto disponible.

## 8. Riesgos y señales tempranas

| Riesgo                                    | Señal temprana                                                    | Mitigación y evidencia                                                                                        |
|-------------------------------------------|-------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------|
| `K-10` SDK/host/distribución              | API browser ausente, bundle con Node, VSIX no carga               | Versiones fijadas, primer smoke host temprano, contratos de paquete y negativos; no publicar                  |
| `K-11` teléfono pierde texto              | Guardado no confirmado, teclado oculta acciones, expulsión/CORS   | Kit físico y conservación de texto, informe por combinación; no prometer móvil completo                       |
| `K-PG6B-01` DAP reinicia o repite efectos | Control usa `step` actual o reenvía fuente                        | Control vivo y contador físico antes/después de pasado                                                        |
| `K-PG6B-02` tarea equivocada              | Stacks idénticos para tareas distintas, selección cambia agenda   | Inspección inmutable por tarea y snapshot; casos con locales diferentes                                       |
| `K-PG6B-03` evaluate ejecuta código       | Watch cambia objeto/azar/cinta                                    | Subconjunto sin llamadas, compilación compartida y copia sin host, comparaciones de invariantes               |
| `K-PG6B-04` revisión mezclada             | Stop de importado muestra línea de otro texto                     | Mapas por fuente/revisión, sourceReference, rechazo de referencias viejas                                     |
| `K-PG6B-05` Workers bloqueados o fuga     | Hover no responde durante ejecución o quedan peticiones tras stop | Workers separados, lotes con cesión, prioridad cancel y limpieza correlacionada                               |
| `K-PG6B-06` i64 redondeado                | JSON pasa por Number, ids distintos se igualan                    | Payload opaco/cadenas canónicas y casos extremos en todos los cruces                                          |
| `K-PG6B-07` autoridad web exagerada       | Describir Fetch/FS como host nativo                               | Descriptor A4, proveedor/capacidad explícitos, incertidumbre y pruebas adversarias                            |
| `K-PG6B-08` crecimiento del artefacto     | LSP+debug exceden 900 KiB                                         | Medir módulo final temprano; sin cambiar presupuesto ni seleccionar un módulo distinto para medir             |
| `K-PG6B-09` falsa cobertura               | WebKit o mocks presentados como teléfono/guardado durable         | Matriz de evidencia y analizador que rechace atribución incorrecta                                            |
| `K-PG6B-10` deuda SEE oculta              | Conformidad bloqueada por revisión se declara verde               | Registro separado de validación/revisión/anclaje; no atribuir revisión ni aceptar automáticamente deuda nueva |

## 9. Dependencias de la persona

| Momento                                 | Dependencia                                                                                    | Trabajo independiente que puede avanzar                                                              |
|-----------------------------------------|------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------|
| Ahora                                   | Solo creación documental solicitada                                                            | Plan completo y verificación documental, sin implementación                                          |
| Antes de código                         | Mensaje nuevo que autorice alcance de implementación y revise `C02`                            | No iniciar producto por inferir aprobación del silencio                                              |
| Si aparece conflicto nuevo              | Decisión con IDs y fuentes concretas                                                           | Continuar tareas que no dependan del conflicto                                                       |
| Validación/reanclaje SEE                | Revisión independiente exigida por el corpus; autorización de reanclaje según política vigente | Casos/tests/implementación y evidencia separada, sin declarar conformidad concedida                  |
| Prueba física/hosts externos            | Dispositivos/resultados y, solo si se necesita, cuenta o alojamiento permitido                 | Kit, control y automatización desktop; ausencia física ya diferida, sin volver a preguntar por ella  |
| CF-14                                   | Decisión explícita sobre cobertura parcial y eventual evaluación futura                        | Informe honesto completo; conservar diferimiento si no existe decisión nueva                         |
| Métrica candidata                       | Aceptación/rechazo informado de `PERF.PG.WEB`                                                  | Medición y análisis reproducibles, sin afirmar aprobación                                            |
| Instalación habitual o canales externos | Autorización concreta si se pretende esa acción                                                | Ensayos aislados, artefactos listos con hashes; Marketplace/Open VSX y licencia final quedan en PG-7 |

No pedir otra vez CF-20, cadena de la extensión, migrador, elección VS Code ni licencia abierta para
crear el plan. Esas decisiones ya tienen tratamiento. Ninguna carencia física complementaria justifica
parar todo lo automatizable. Una cuenta externa tampoco se asume disponible sin verificarla.

## 10. Orden de ejecución y puntos de control

1. **Entrada.** Registrar autorización/revisión, rama/HEAD/árbol, espacio, toolchains, estado SEE y
   pendientes heredados. Leer cada dueño antes de tocarlo. Resolver solo conflictos que bloqueen.
2. **Fronteras.** Completar `.01` y contratos/casos de `.02/.03/.04`; verificar matrices y capacidad
   del ejecutor SEE. No arrancar TS DAP antes de que API pueda representar el comportamiento.
3. **Núcleo DAP.** Proyecto/vistas, consulta por tarea, control persistente y evaluate. Tests dirigidos
   y revisión de aislamiento. Fracaso de inmutabilidad o identidad detiene el adaptador dependiente.
4. **Escritorio.** DAP CLI/VS Code, segundo cliente y prueba física de historia. No dar `.02/.03`
   por cumplidos con stubs, mocks o solo tests del parser.
5. **Browser temprano.** Borde LSP, primer build con dos Workers y smoke host. Medir tamaño Wasm
   inmediatamente; descubrir aquí inviabilidad de SDK/memoria, no al cierre.
6. **Capacidades y paquete.** `.05`, integraciones FS/Fetch, artefactos separados y verificadores
   con negativos; después matriz `.06` y humo desktop por manifiestos/build compartidos.
7. **Evidencia.** Preparar `.07` desde temprano sin esperar hardware; ejecutar/analizar evidencia
   física si llega. `.08` informa faltantes y CF-14; `.09` corre campaña aislada en artefactos finales.
8. **Cierre.** Resolver fallos nuevos, reejecutar solo comprobaciones invalidadas por cambios,
   completar C01–C13 y resumen. No iniciar PG-A/PG-B/PG-7 ni otra fase al describir el cierre.

Si la persona autoriza puntos o iteraciones parciales, respetar ese límite. Estos controles técnicos
no añaden solicitudes de permiso rutinarias: dentro del alcance autorizado se continúa hasta entregar
evidencia completa. Una fase nueva requiere mensaje nuevo (`PHASE-STOP`).

### 10.1 Cierre común verificable

- [x] `PG-6B.C01` Mensaje nuevo de autorización registrado con alcance exacto.
- [x] `PG-6B.C02` Este plan revisado por la persona; propuestas/condiciones relevantes resueltas.
- [ ] `PG-6B.C03` SPEC-FIRST y congelamiento: identidades nuevas estables 1.0.0, sin `cambio` ni
  revisión ficticia; existentes conservan identidad/estado/versión y siguen revisión/anclaje exigidos.
- [ ] `PG-6B.C04` Reglas/casos/propiedades y vínculos de conformidad como datos; sin sujetos ni
  capacidades anunciados por conveniencia.
- [ ] `PG-6B.C05` Corpus, espejo y consumidores afectados cubren feliz/infeliz/límites de §7.2.
- [ ] `PG-6B.C06` Capas/imports/tamaños/nombres y grafo browser/Wasm pasan con sus negativos.
- [ ] `PG-6B.C07` Cero comentarios/TODO, código en inglés/docs en español y reglas Rust estrictas.
- [ ] `PG-6B.C08` README/reglas de todos los dueños actualizados, autosuficientes y sin citas a docs.
- [ ] `PG-6B.C09` Justificación comprobable: fase sin sintaxis nueva del lenguaje; ayuda existente
  reutilizada y textos de UI es/en. Si finalmente añade construcción, ficha y proyección obligatorias.
- [ ] `PG-6B.C10` Riesgos/experimentos revisados, procedencia y diferimientos físicos ya autorizados
  registrados sin atribuir evidencia o decisión humana inexistente.
- [ ] `PG-6B.C11` Pruebas/verificadores pertinentes verdes, selección y omisiones justificadas;
  deuda heredada separada y ningún fallo nuevo oculto. Informar impedimentos de `PHASE-GREEN`.
- [ ] `PG-6B.C12` Tras revisión de cambios y autorización Git vigente, usar skill `commit-message`,
  commit sin atribución de IA y push ordinario comprobado a la rama única; sin force push.
- [ ] `PG-6B.C13` Resumen por tarea y del plan general, informe de límites, revisión de cierre y parada.

## 11. Resumen de ejecución

Estado al preparar: **sin iniciar**. No hay tareas de implementación cumplidas ni autorización de fase
atribuida a este encargo. Las filas de punto agrupan el alcance; al ejecutar se añaden filas por cada
`PG-6B.nn.mm` y `Cnn`, con comando/cwd/revisión/resultado/ruta/hash y omisiones. Solo usar los estados
del plan general: Cumplido, No cumplido, Diferido, No aplica o Retirado, con sus condiciones.

| Punto             | Estado de implementación | Evidencia                        | Pendiente o condición                                          |
|-------------------|--------------------------|----------------------------------|----------------------------------------------------------------|
| `PG-6B.01`        | Pendiente; sin ejecutar  | Inventario y propuesta en §1/3/5 | Decisión técnica y declaración verificadas al implementar      |
| `PG-6B.02`        | Pendiente; sin ejecutar  | Contratos/tareas propuestos      | Núcleo público, DAP VM y dos clientes reales                   |
| `PG-6B.03`        | Pendiente; sin ejecutar  | Protocolo de aislamiento         | Contadores físicos de HTTP/archivos e historia                 |
| `PG-6B.04`        | Pendiente; sin ejecutar  | Frontera Worker propuesta        | Recurso LSP, Workers separados e i64 exacto                    |
| `PG-6B.05`        | Pendiente; sin ejecutar  | Matriz de capacidades            | Adaptadores, concesiones, fallos y limpieza                    |
| `PG-6B.06`        | Pendiente; sin ejecutar  | Matriz de host objetivo          | Artefacto final y cobertura por navegador                      |
| `PG-6B.07`        | Pendiente; sin ejecutar  | Protocolo de materiales          | Físico complementario; diferimiento previo si no hay evidencia |
| `PG-6B.08`        | Pendiente; sin ejecutar  | Formato de informe               | CF-14 conserva decisión pendiente/diferida                     |
| `PG-6B.09`        | Pendiente; sin ejecutar  | Protocolo de métricas            | Crudos/tamaño actuales y aceptación candidata separada         |
| `PG-6B.C01`–`.13` | Pendiente; sin ejecutar  | Preparación documental solamente | Revisión humana/implementación/cierre aún no realizados        |

El rótulo «Pendiente; sin ejecutar» es ausencia de evaluación inicial, no un sexto estado de resultado.
Al evaluar una tarea se reemplaza por uno de los cinco estados permitidos. No marcar el conjunto
cumplido por completar materiales si su evidencia de host, rendimiento o decisión todavía falta.

Revisión Git de cierre de fase: **no existe**. Verificaciones de producto: **no ejecutadas durante la
preparación**. Artefactos DAP/web calificados: **ninguno**. Puntos §4 cumplidos por este encargo:
**ninguno de implementación**. Registrar la verificación documental final a continuación cuando exista.

### 11.1 Verificación de esta preparación documental

El 2026-10-31 se comprobaron 63 subtareas únicas (nueve puntos por siete tareas), los trece cierres
comunes, las catorce secciones numeradas y los enlaces locales. Ninguna casilla de implementación
está marcada. Auditorías separadas de DAP/núcleo, web/hosts y corpus/experimentos revisaron hechos y
propuestas; se corrigieron sus hallazgos sobre ventanas históricas, entrada correlacionada,
paginación, cancelación LSP, manifiestos por destino, confinamiento URI y mediciones.

La puerta real `DOC-NO-TRANSIENT-REFS` de `packages/pseudolearn_spec/xtask/src/documentation.rs`
pasó mediante un lanzador temporal con Rust 1.99.0, invocando su función sin encadenar `xtask verify`.
También pasaron sus tres tests, incluidos los casos negativos, compilando directamente ese módulo
con `rustc --test`. `git diff --check` y revisión de espacios del archivo nuevo en verde.

No se cambió código de producto, corpus ni README de miembro. No se ejecutaron suites de lenguaje,
builds Wasm/VSIX, hosts ni campañas: esta entrega es la preparación documental solicitada y no aporta
evidencia de implementación, revisión humana de `C02` o cierre de PG-6B.

## 12. Protocolo operativo para el agente ejecutor

1. Revalidar HEAD y hechos; no asumir que este inventario reemplaza lectura de README/reglas.
2. Contrato → casos → tests → código → README → verificación; resultados derivados de reglas.
3. No inventar DAP, operaciones API/LSP, runner web, sujetos SEE ni comandos aún no implementados.
4. No usar `step` que recompila como control DAP vivo ni `cancel` como pause.
5. No consultar marcos de otra tarea cambiando la agenda; no fabricar fuentes/revisiones por línea.
6. Evaluate usa compilador/VM compartidos y copia aislada; nunca eval/regex ni otro intérprete TS.
7. Historia no recibe host real, no duplica salida/HTTP/escrituras y no cae a LiveRecord tras un error.
8. Wasm solo importa API; service nunca VM/DAP; entradas browser sin Node ni ejecución remota oculta.
9. Conservar URI y JSON exactos; negociar capacidades y permisos como cosas distintas.
10. Consumir generados y Fetch canónico por build verificable; no editar/copiar artefactos a mano.
11. Un host automatizado no es teléfono; FS en memoria no es persistencia; dato ausente sigue ausente.
12. No repetir preguntas ya resueltas ni ampliar alcance para esconder deudas de otras fases.
13. No publicar, instalar en perfil habitual ni atribuir revisión humana sin autorización/evidencia.
14. Informar implementación, pruebas, verificadores, artefactos y límites. Al cerrar, parar.

## 13. Disco, procesos y conservación de evidencia

Antes de builds release, descargas de navegador/VS Code o campaña medir espacio libre y tamaños de
targets, cachés y artefactos propios. Reutilizar el build fijado y limitar compilaciones simultáneas;
no construir plataformas no ensayadas. Guardar crudos/manifiestos/hashes antes de limpiar temporales.

Solo retirar caché regenerable y temporales propios identificados sin procesos en uso. No borrar
cambios ajenos, locks, fuentes, paquetes de reversión ni resultados que sostengan una comparación.
Los hosts usan perfiles aislados; cerrar procesos propios y listeners aun al fallar. No tocar el perfil
habitual ni matar procesos por coincidencia de nombre. Si falta espacio, reducir concurrencia y
reportar la operación concreta afectada, sin limpieza indiscriminada.

### 11.2 Ejecución integrada autorizada · 2026-10-31

Revisión inicial de ejecución: `aaffb6bf`; árbol limpio y rama única sincronizada con su remoto.
La petición directa de implementación revisa y autoriza el plan (`C01/C02`); no constituye revisión
editorial independiente del corpus ni aceptación de una métrica candidata.

Se distribuyen núcleo/API, corpus/evaluate, CLI/DAP y browser/artefactos. Los contratos y casos se
escribieron antes del código; las compilaciones incrementales de integración no cierran tareas ni
sustituyen la campaña final. No hay suites ni campañas aprobadas todavía.

Entorno confirmado: Rust 1.99.0, Node 22.23.3, pnpm 12.8.1, wasm-bindgen 0.2.129 y target
wasm32-unknown-unknown disponibles. El SDK instalado expone el cliente LSP browser.

Espacio liberado: 6,0 GiB libres antes y 9,3 GiB después de retirar exclusivamente
`target/debug/incremental` de engine, CLI y SEE, una vez comprobada la ausencia de compilaciones
Rust activas. Sus tamaños lógicos sumaban unos 5 GiB. Se conservaron resultados, locks, fuentes,
paquetes, perfiles y navegadores reutilizables. Los 25 GiB de PG-4/PG-5 no son una puerta de PG-6B;
se mide margen antes de cada operación pesada y se limita su concurrencia.

La descarga de `@vscode/test-web@0.0.81`, cuya publicación se consultó en el registro oficial,
fue rechazada por el servicio de revisión automática con un límite de uso. El intento en sandbox
falló por resolución DNS y el offline no encontró su metadata. El runner, los scripts y los tests se
preparan igualmente; esos errores no acreditan cobertura de host. La restauración local de enlaces
hacia paquetes exactos ya materializados permite continuar herramientas existentes sin afirmar una
instalación congelada satisfactoria.

### 11.3 Campaña de verificación y estado de cierre · 2026-10-31

Revisión base `aaffb6bf`, árbol con cambios sin confirmar al verificar. Resultados por frente.

**Cumplido (comprobado localmente)**
- Motor (`cargo check/clippy -D warnings/fmt`, `pseudolearn_check_command all`): sin hallazgos. Tests dirigidos de
  `pseudolearn_api` (depuración, tareas, historia, inspección, LSP, estado de colecciones), `pseudolearn_lowering`,
  `pseudolearn_wasm`, `pseudolearn_service` en verde.
- CLI: `cargo test` completo, Clippy, formato y verificadores en verde. DAP stdio independiente (proyecto de
  tres módulos, tareas, entrada, referencias vencidas, evaluate, retroceso) y prueba física de historia
  (POST loopback y archivos temporales conservan contadores, bytes y salida): aprobadas.
- Extensión: tipos, arquitectura, comentarios, tamaños, paquete, gramática, `check:web` y 116 tests en verde.
  Wasm empaquetado: 4 181 395 bytes, Brotli Q11 845 305 ≤ 921 600, memoria máxima 4096 páginas (256 MiB).
- Corpus: esquema SEE corregido (operaciones API nuevas) y caso `API.ERRORS#C2` con programa; `see export --check`
  verificado; tests de `see_conformance` en verde.
- Rendimiento web (Chromium, `bench:web`): 10 procesos × 30 intentos × 3 cargas × {Worker, control}; 1800
  intentos válidos, 0 fallos. Medias (ms): entero extremo 1,30/1,45; bucle 60,7/57,5; cancelación 14,4/13,5
  (Worker/control). Crudos en `apps/pseudolearn_vscode/test-results/web-bench/`. No es aceptación de `PERF.PG.WEB`.
- Contrato HTTP del Fetch canónico en Chromium y WebKit.

**Defectos corregidos durante la campaña** (nuevos, de este trabajo): verificación de breakpoints sin fuente
en ejecución de archivo único; `step_out` desde el marco base de una tarea; nombres de marco con `@`;
IR de resultado agregado sin tramo; rutas DAP no canónicas; `wasm.sh` con cadena de Rust distinta de la fijada;
avisos de terceros ante manifiestos sin nombre; globals Node por propiedad en el verificador web; verificadores
de la extensión recorrían salidas generadas.

**Antecedentes (fallaban antes de este cambio)**: `cli_tests::executes_ri_command_successfully` (esperaba un IR sin
`suspendible`), `reference_vocabulary` (conteo de builtins 19 vs 28), y diferencias de `cargo fmt` en
`pseudolearn_spec` fuera de los archivos tocados. Los dos primeros se actualizaron a la salida vigente.

**Segunda pasada (runner e hosts reales, autorizada)**
- `@vscode/test-web` 0.0.81 instalado en `tests/web/runner` con lock; VS Code web 1.144.0 commit
  `2c33b50b…` descargado por el runner. Defectos reales del host web encontrados y corregidos: la extensión se
  cargaba como ESM (ahora CJS) y los Workers anidados fallaban porque VS Code los envuelve con `importScripts`
  (ahora IIFE clásicos); el snapshot enviaba la ruta del manifiesto en lugar de su directorio, por lo que el
  servidor de lenguaje no resolvía el proyecto; el runner marcaba «passed» ante un tiempo agotado (ahora exige
  proceso sin error y resultado `passed` en el log); el módulo de pruebas debe vivir dentro de la extensión servida.
- Host VS Code web, **Chromium: aprobado** y **WebKit: aprobado** (activación, completado, hover, formato, ayuda,
  bucle infinito con LSP aún operativo, parada). Registros en `apps/pseudolearn_vscode/test-results/web/`
  (las corridas anteriores fallidas se conservan).
- **Firefox: no calificado.** El Firefox Nightly de Playwright (build 1555) termina con «Could not find profile
  folder» en macOS 27.0.1 incluso lanzado a mano con un perfil propio; es una incompatibilidad del entorno, no un
  resultado de producto.
- VS Code de escritorio real (instalación local, perfil y extensiones aislados en `/tmp`): 21 comprobaciones en
  verde en modo de confianza (incluye DAP con el depurador real y proceso liberado) y 4 en modo restringido. Su
  proyección DAP coincide exactamente con la del cliente stdio independiente (`tests/dap/compare.mjs`).
- Rendimiento re-medido sobre el Wasm final (4 181 471 bytes; Brotli 844 844): 1800 intentos válidos, 0 fallos.
  Medias Worker/control (ms): entero 1,29/1,44; bucle 64,8/62,1; cancelación 15,3/14,6; p95 bucle 107,6/104,7.
  La corrida anterior sobre el Wasm previo se conserva en `test-results/web-bench/`.
- `see conform` compila su adaptador release pero queda detenido por `SEE-STATE` (ver abajo).

**Bloqueado / no ejecutado**
- `SEE-STATE: independent review required` persiste: `TOOL.SERVICE.WORKSPACE` (heredado) y `TOOL.DAP` (nuevo) están
  `estable` sin revisor independiente. No se fabricó ni atribuyó revisión; por ello `see validate`,
  `see conform`, `runtime_corpus` y un test de `see_cli` no pueden pasar. Requiere decisión de la persona.
- Firefox, como arriba.
- E-PG-08 físico: kit generado; ensayos físicos **Diferido / no evaluado físicamente**. CF-14 y la aceptación de
  `PERF.PG.WEB` conservan su decisión posterior. No se aplicaron reanclajes.

`PHASE-GREEN`: **no declarada**. Quedan sin cerrar la revisión independiente del corpus (y con ella la
validación y conformidad SEE) y Firefox. No se inició PG-A, PG-B ni PG-7; no se instaló en el perfil habitual ni
se publicó nada.
