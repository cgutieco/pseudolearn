# Fase PG-B · Lenguaje completo con anfitriones reales y app con tareas observables — plan de ejecución

## 0. Metadatos y contrato de ejecución

- Fase: PG-B, reformulada el 2026-11-02. Nombre anterior: «App y tareas observables».
- Origen: §B.2 de [analisis-lenguaje-completo-sin-simulacion.md](analisis-lenguaje-completo-sin-simulacion.md), que
  reformula §4.11 del [plan general](plan-ejecucion-proposito-general.md). Requisitos del dueño RQ-1–RQ-7 y decisiones
  D-01–D-19 aceptadas el 2026-11-02 (§0.1 y §0.2 de ese análisis). Se conservan ADR-03/12/13, R-10–R-12, R-19, R-20,
  C-15, K-18/K-19 y E-PG-12 de la [hoja de ruta](../hoja-de-ruta-proposito-general.md) en lo que no contradicen RQ-1–RQ-3.
- Fecha de esta versión: 2026-11-02, America/Lima. Revisión inspeccionada: `194bd9ce`. Rama:
  `feature/agregar-ruta-de-especificacion`. Cambios ajenos presentes y conservados:
  `apps/pseudolearn_vscode/examples/project/app/main.pseudo`, `apps/pseudolearn_vscode/media/pseudolearn.tmLanguage.json`.
- Petición: «Rewrite PG-B plan» (2026-11-02), tras aceptar las recomendaciones del análisis. **Autoriza redactar este
  plan, no implementarlo.** `PG-B.C01` (autorización de inicio) y `PG-B.C02` (revisión del plan) siguen pendientes.
- Historia conservada: la versión anterior de este plan (preparada el 2026-11-02 sobre `5a0e12ae`) y sus iteraciones de
  PG-B.01–PG-B.09 quedan como evidencia en §4.1 y §11.1–§11.9. Sus casillas no se desmarcan. PG-B.04 pasa a **Retirado**
  (§4.1); su parte de entradas identificadas sigue vigente.
- Documento transitorio: ninguna especificación, README ni código fuera de `docs/` podrá citarlo
  (`DOC-NO-TRANSIENT-REFS`). Cada decisión se traslada a su dueño en el mismo cambio (`DOC-README-TRUTH`,
  `DOC-NO-ORPHAN-DECISION`).

### 0.1 Reglas para quien ejecute

1. Antes de modificar, releer `AGENTS.md`, el README y el archivo de reglas del miembro y del crate afectado; comprobar
   rama, HEAD y diff. Si cambió HEAD, actualizar el inventario de §1 y distinguir hechos vigentes de esta fotografía.
   Conservar cambios ajenos.
2. Este plan distingue **existente comprobado**, **propuesta** y **carencia por verificar**. Un nombre propuesto en §5
   (crate, capa, archivo, operación) no existe hasta que se cree; no usarlo como prueba de que una API lo admite.
3. Secuencia obligatoria por punto: especificación → casos con esperado derivado → tests que detectan la ausencia →
   código → README y reglas → verificación. El borrado de lo que el punto deja muerto ocurre **en el mismo cambio** que
   su reemplazo, no después.
4. Por cada tarea, una fila de §11 con HEAD/diff, reglas y casos, archivos, comandos, salida y código de salida, alcance y
   límites. «Se implementó», «parece funcionar» o un test que repite el algoritmo no son evidencia.
5. Prohibido reintroducir simulación en producto (RQ-3): respuestas preparadas, archivos virtuales, reloj lógico en vivo,
   escenarios, semilla fija por omisión o rótulos «Simulado». El único anfitrión no real permitido es el doble de prueba
   del corpus (D-01a), detrás de una característica de pruebas e inaccesible desde CLI, extensión y app.
6. Prohibido reintroducir concesiones (RQ-1): ninguna opción, comando, campo de manifiesto ni diálogo para «permitir» red,
   archivos, reloj, temporizador o argumentos. Un fallo de plataforma (CORS, sandbox, ATS, aviso del sistema) se entrega
   como `ErrorES` tipado con su causa; nunca se presenta como política de PseudoLearn.
7. Una discrepancia corpus/implementación no se arregla copiando la salida del motor al esperado
   (`SPEC-INDEPENDENT-ORACLE`). Una contradicción entre fuentes se informa con ID, texto y alcance y se espera decisión
   (`CONFLICT-REPORT`); puede seguirse trabajo independiente autorizado.
8. `SPEC-VERSION-FREEZE`: editar texto oficial en la misma identidad, estado y versión, sin `cambio`; no borrar reglas
   (se reescriben); reanclar con `lock --refresh` listando en una sola orden todos los IDs modificados y revisados.
9. Al terminar el alcance autorizado, informar y parar (`PHASE-STOP`). Las puertas de §10 no amplían una autorización
   parcial.

## 1. Punto de partida comprobado

Rutas relativas a la raíz. Inspección de fuentes en `194bd9ce`; no se ejecutó ninguna suite para redactar este plan.

### 1.1 Dependencias y puertas previas

| ID | Evidencia | Tratamiento exigido |
|---|---|---|
| PB-PRE-01 | PG-A, PG-4, PG-5, PG-6A y PG-6B cerradas; PG-3 figura «en curso» en §6 del plan general aunque su §4.5 marca todas las casillas | Mantener la resolución ya aplicada: avanzar con autorización expresa; no cerrar PG-3 desde aquí |
| PB-PRE-02 | Tras §11.9: suite Flutter 3416/0 fallos; motor 2158/0; `see conform --subject app` con fallos en `APP.EDITOR.COMPLETION#R5/R6/R10` y `APP.EXEC.SNAPSHOT-VIEW#R1/R4` | Línea base de HEAD al iniciar; los dos contratos de app se resuelven en PG-B.25 o se reportan |
| PB-PRE-07 | El corpus estable impone denegación por defecto, política SSRF, tiempo lógico y semilla fija (`LANG.CAPABILITY.MODEL#R2/R3`, `RT.HOST.INTERFACE#R1/R3/R6–R9`, `LIB.HTTP#R1/R3`, `LIB.HTTP.POLICY#R1–R4`, `LIB.TIME#R1/R2`, `API.PROJECT.MANIFEST`) | Bloque 1 los reescribe antes de cualquier código (CF-N02–CF-N07 del análisis) |
| PB-PRE-08 | §5.4 del plan general recomienda «denegación por defecto» y «ningún acceso ambiental a `cwd`, variables de entorno…» | Choca con RQ-1; la instrucción del dueño prevalece (AGENTS.md §3). PG-7.15 actualiza §5.4; aquí se registra y no se aplica |
| PB-PRE-09 | README del motor y `isolation` de `packages/pseudolearn_engine/architecture.yaml` prohíben Hyper, Rustls, `http` y DNS en API, Wasm y puente de app | D-02b exige reescribir esa decisión para el puente (CF-N13) antes de PG-B.22 |
| PB-PRE-10 | `PERF.ARTIFACT.SIZE`: ios-arm64 ≤ 5 MiB; medido 4 294 592 B tras PG-5 | PG-B.22.01 mide primero el puente con red y para si no cabe (CF-N11) |

### 1.2 Inventario real de lo que esta fase cambia

| Dueño existente | Hecho inspeccionado | Consecuencia |
|---|---|---|
| `packages/pseudolearn_engine/crates/pseudolearn_api/src/execution_setup.rs` | Toda ejecución usa `crate::FakeHostProvider`; `configure_host_authority` aplica la autoridad declarada; `detached` delega efectos | PG-B.16: el falso pasa a característica de pruebas; sin autoridad por concesión |
| `crates/pseudolearn_runtime/src/{memory_host,memory_host_config,memory_host_files,local_http_effect,effect_authority,capability_table,host_validation}.rs` | Anfitrión de memoria y autorización por orígenes y permisos | PG-B.16 |
| `apps/pseudolearn_cli/src/physical_host.rs` | `arguments_values` → `[]`; `clock_now` congela tras la primera lectura; `timer_wait` no espera | PG-B.12, PG-B.14, PG-B.18 |
| `apps/pseudolearn_cli/src/physical_network_{address,resolver,tls,transport,send,batch,body}.rs`, `physical_files.rs`, `physical_session.rs`, `physical_request.rs` | Transporte Hyper/Rustls/Tokio, filtro de rangos privados, raíz única `cap-std` | Se extraen a `pseudolearn_host` (PG-B.22) sin el filtro (PG-B.11, PG-B.18) |
| `apps/pseudolearn_cli/src/{options,execution_options,messages}.rs` | `--conceder`, `--archivos`, `--origen`, `--origen-local`, `--raiz-prueba` | PG-B.18 |
| `apps/pseudolearn_vscode/src/application/{run_arguments,debug_configuration}.ts` | `run --editor` sin concesiones; `launch.json` rechaza `grants`, `permissions`, `origins`, `filesRoot`, `env`, `args` | PG-B.19 |
| `apps/pseudolearn_vscode/src/adapters/{browser_commands,browser_effect_host,browser_file_host,browser_scratch_files}.ts`, `src/contracts/host_capabilities.ts` | Comandos de concesión, orígenes, archivos en memoria; sin reloj, temporizador ni argumentos | PG-B.20 |
| `packages/pseudolearn_engine/crates/pseudolearn_wasm/browser/fetch_host.mjs` | `performFetch(effect, { allowedOrigins, … })` | PG-B.20 |
| `apps/pseudolearn_app/lib/{domain/model/execution,engine/rust,presentation/document/components}/…simulated…` | Siete escenarios simulados, anfitrión, archivos y HTTP simulados, panel y selector | PG-B.24 |
| `apps/pseudolearn_app/architecture.yaml` | `engine` prohíbe `dart:io`; no hay capa de anfitrión | PG-B.21 |
| `apps/pseudolearn_app/native/Cargo.toml` | Solo `pseudolearn_api` sin red | PG-B.22 |
| `apps/pseudolearn_app/{ios/Runner/Info.plist,macos/Runner/*.entitlements,pubspec.yaml}` | Sin ATS ni `NSLocalNetworkUsageDescription`; macOS con `network.client`; MSIX `internetClient` | PG-B.23 |
| README app §1.5 | Rigor fijo flexible; sin control de reproducción; receptor no localizado | PG-B.28–PG-B.30 |

### 1.3 Lo que no cambia

La atribución `ENG.TRACE.EVENTS#R8`, las proyecciones por tarea, el paso global y por tarea, la cinta y su reproducción
sin efectos, la identidad `(resource_id, task_id, request_id)` de `Leer` y los caminos de cancelación/error de
PG-B.01–.09 siguen vigentes. Se reverifican con efectos reales en PG-B.25; no se rediseñan.

## 2. Lectura realizada y lectura de entrada obligatoria

### 2.1 Fuentes consultadas para esta versión

- [x] `AGENTS.md`; plan general §0, §2–§6; análisis del 2026-11-02 completo; versión anterior de este plan.
- [x] Corpus: `LANG.CAPABILITY.MODEL`, `RT.HOST.INTERFACE`, `LIB.HTTP`, `LIB.HTTP.POLICY`, `LIB.TIME`, `LIB.IO`,
  `API.PROJECT.MANIFEST` (reglas de permisos), `RT.PROCESS`, `TOOL.SERVICE.CATALOG` (fichas de capacidad).
- [x] README y reglas: motor (`README.md`, `architecture.yaml` con `isolation`), API (`FakeHostProvider`), CLI, extensión,
  app (§1, §2.1, §4.50, §4.54, §4.57), puente `native/`.
- [x] Código citado en §1.2.

### 2.2 Antes del primer cambio de implementación

- [ ] Registrar HEAD, diff, versiones (Flutter, Dart, Rust, FRB, Node, pnpm) y espacio libre en disco.
- [ ] Leer completos los casos de cada especificación del bloque 1 y la lista de vínculos de conformidad que los
  referencian (`conformance*.yaml` del motor, CLI y app; `differential-exemptions.json`; `property-conformance.json`).
- [ ] Leer el README de `pseudolearn_runtime`, `pseudolearn_api`, `pseudolearn_wasm` y de cada crate que se toque.
- [ ] Línea base dirigida de §7.3 en HEAD.

## 3. Decisiones de diseño

Las decisiones D-01–D-19 del análisis están aceptadas y no se vuelven a pedir. Esta tabla fija cómo se implementan.

| ID | Opciones | Criterio | Elección y dueño documental | Reversión |
|---|---|---|---|---|
| D-PGB-R01 | Conservar `Solicitar*` con concesión implícita; eliminar las capacidades como tipos | No romper programas válidos; la atenuación voluntaria es útil | `Solicitar*` siempre concede la familia que el anfitrión soporta; `Limitar` y `Subdirectorio` quedan como atenuación voluntaria. README motor y runtime | Si un caso derivado exige retirar un tipo, se reporta |
| D-PGB-R02 | Ubicación de `pseudolearn_host`: crate del workspace del motor; paquete nuevo en `packages/` | Debe consumirlo también `pseudolearn_aot_rt` en PG-N; reutilizar `rust-checks`, `cargo deny` y Clippy del motor | Crate `crates/pseudolearn_host` del motor, sin importar crates del motor: opera sobre el formato público de efecto de `API.EXECUTE` con `serde_json`. Declarado en `architecture.yaml` antes del código. README motor y del crate | Si una dependencia exige otra cadena, paquete propio en `packages/` |
| D-PGB-R03 | Red del puente: hilo Rust propio; usar el `Future` de Dart | El puente FRB es síncrono y con sesiones `thread_local` | Hilo de trabajo Rust con runtime Tokio de un hilo; Dart consulta resultados listos al bombear, sin bloquear la UI ni crear Isolate. README `native/` | Si FRB asíncrono resulta más simple y cumple límites, se documenta y cambia |
| D-PGB-R04 | Raíces de confianza: `rustls-native-certs`; verificador de plataforma | `rustls-native-certs` no cubre iOS **[I]** | Verificador de plataforma con soporte macOS, iOS, Windows y Linux, validado por licencia y tamaño (`cargo deny`) antes de adoptarlo. README `pseudolearn_host` | Si ninguno cumple, D-02a para la app |
| D-PGB-R05 | Carpeta de trabajo de la app: contenedor por documento; carpeta única | Rutas relativas predecibles y visibles | Carpeta real por documento dentro del contenedor de la app (iOS/macOS sandbox) o de `%LOCALAPPDATA%` (Windows), creada al ejecutar; ruta mostrada en la consola. README app | Carpeta única si el dueño la prefiere |
| D-PGB-R06 | Argumentos en la app: campo de texto; lista editable | Igual que la configuración de ejecución de un IDE | Campo de argumentos por documento con separación por espacios y comillas; persistido con el documento. README app | — |
| D-PGB-R07 | Temporizador real en paso a paso: esperar con la UI viva; saltar la espera | RQ-3 prohíbe saltar | Espera real cooperativa; el botón detener la corta; mientras espera la banda muestra «esperando temporizador». README app | — |
| D-PGB-R08 | Diferencias del navegador: error; adaptación | D-07a | Redirección seguida por el navegador con URL final; CORS, contenido mixto y cabecera prohibida como `ErrorES` con causa de plataforma. Regla en `RT.HOST.INTERFACE#R8` por sujeto | — |
| D-PGB-R09 | Doble de prueba del corpus: característica `test-host`; crate separado | D-01a; aislamiento comprobable | Característica `test-host` en API y runtime, activada solo por `pseudolearn_conformance`, tests y `bench_worker`; `rust-checks isolation` comprueba que CLI, puente y Wasm no la activan. README motor | Crate separado si la característica contamina el grafo |
| D-PGB-R10 | Escenas E-PG-12: conservar; regenerar | Ninguna debe depender de simulación | Regenerar con anfitrión real y servidor loopback; las que no usen efectos se conservan con su hash | — |

Conservadas de la versión anterior: D-PGB-01–D-PGB-09 y D-PGB-11. **D-PGB-10 queda retirada** (era «extender host de
memoria… cero DNS/sockets»).

## 4. Desglose por punto

Los IDs `PG-B.nn` nunca se reutilizan. §4.1 conserva sin cambios las tareas ejecutadas de la versión anterior; §4.2 añade los puntos de la reformulación.

### 4.1 Puntos de la versión anterior (PG-B.01–PG-B.09)

PG-B.01–.03 y .05–.09 quedan absorbidos y se reverifican con anfitrión real en PG-B.25 y PG-B.26. **PG-B.04 queda Retirado** el 2026-11-02 por RQ-3: sus tareas `.04.02`–`.04.05` sobre escenarios simulados pierden efecto y su implementación se borra en PG-B.24; la identidad de entradas de `.04.01` y `.04.04` sigue vigente. Las casillas `[x]` registran lo ejecutado entonces y no se desmarcan.

### PG-B.01 · Evento global, foco, pila y estado por tarea

- [x] `PG-B.01.01` Contrato: inventariar evento/ejecución/revisión/tarea/marco/nodo y la atribución R8; resolver PB-PRE-04. Identificar cómo enumerar marcos y tareas, cómo empieza una hija sin `call`, qué se conserva al terminar y cómo recuperar contexto al iniciar una ventana. Extender `API.STATE.QUERY`/`API.PROGRAM.VIEW` solo donde falten datos públicos; no exportar AST privado ni adoptar nombres de depuración como identidad de dominio.
- [x] `PG-B.01.02` Casos: derivar B01/B02/B03/B04/B14, con tabla por evento de dueño, foco, pila y variables. Incluir dos hijas del mismo subprograma con argumentos distintos y recursión dentro de una; no comparar solo nombres o profundidades.
- [x] `PG-B.01.03` Tests: modelos/igualdad, decodificación, atribución entre lotes y tracker segregado; tarea desconocida, evento fuera de orden, revisión ajena, campos mal tipados y raíz antes del primer `task_resumed`. Mostrar que el test detecta mezclar las pilas.
- [x] `PG-B.01.04` Código: extraer atribución/contextos del tracker global; preservar orden global y foco por tarea; consultar marcos por tarea en adaptador y mapear errores a resultados. La selección no ejecuta ni activa tareas; la vista de un evento previo no cambia al avanzar.
- [x] `PG-B.01.05` Documentación: registrar claves y vida de identidades en README app/API, reemplazar afirmación de foco único en su ámbito y actualizar ayuda/cobertura si cambia contrato observable; aplicar §5 sin aumentar límites por comodidad.
- [x] `PG-B.01.06` Verificar: tests espejo y API/puente afectados, casos B01–B04/B14 y arquitectura; adjuntar tabla esperado/obtenido por evento y mostrar marcos distintos en el mismo nodo. No cerrar con un mapa que nunca fue contrastado con Rust.

### PG-B.02 · Tres proyecciones y estado paginado

- [x] `PG-B.02.01` Contrato: definir datos públicos de las tres superficies y navegación tarea/marco/evento/rango. Auditar `history_events`, `debug_state`, `query_page` y horizonte antes de proponer API nueva. Si cola/estado de canal o ámbito no se consulta, especificar consulta acotada o dato observable faltante; no reconstruir mensajes desde eventos que no los contienen.
- [x] `PG-B.02.02` Casos: B02/B03/B05/B08/B09/B13/B14; incluir ámbito vacío, árbol anidado, unión sin espera, ausencia de más páginas, página vacía, horizonte expulsado, cursor de otra tarea/revisión/evento y 4096/4097 elementos solicitados.
- [x] `PG-B.02.03` Tests: modelos geométricos y estado derivado; orden estable de nodos/aristas, conexiones sin cruzar cajas ajenas, hit testing, foco y leyenda; widgets compactos y accesibilidad sin depender solo de color. Negativos de toda ampliación del verificador de cobertura.
- [x] `PG-B.02.04` Código: implementar geometría/proyección pura en adaptadores y filtrado/paginación en estado de aplicación; pintores/widgets consumen datos preparados. Una espera enlaza a causa/objetivo; una creación/unión no se pinta como bifurcación alternativa ni como control entre cuerpos locales. Eje lógico sin duración física inventada.
- [x] `PG-B.02.05` Documentación: leyenda de extensiones didácticas, rótulos es/en, matriz construcción→flujo/estructura/evento/tabla/ayuda con test y regla; no aplicabilidad con motivo. Mantener formas estáticas de PG-A y bloqueo de exportación equivalente cuando no preserva semántica.
- [x] `PG-B.02.06` Verificar: tests de escenas/estado/widgets y cobertura; demostrar consultas de rango, número de elementos leídos acotado, caché con límite, cambio de tarea sin movimiento de agenda y navegación con revisión correcta. No basta recortar una colección completa después de leerla.

### PG-B.03 · Paso global y paso de tarea

- [x] `PG-B.03.01` Contrato: fijar evento global siguiente según `ENG.TRACE.STEP#R1/R2`; paso de tarea consume hasta el próximo evento atribuido a esa tarea, aplicando todos los intermedios. Separar selección/consumo/punta precargada y ritmos didácticos ya existentes. Definir resultado cuando tarea está terminada, falla, espera entrada/efecto, se alcanza límite o no existe próximo evento; sin bucle infinito ni respuesta fabricada.
- [x] `PG-B.03.02` Casos: B02/B03/B06/B07/B12/B15. Derivar secuencia completa esperada y estado tras cada comando global o por tarea; seleccionar una tarea esperando mientras otra avanza. El lote que termina con espera primero entrega todos sus eventos confirmados.
- [x] `PG-B.03.03` Tests: particiones 1/2/25 y cortes antes/después de cada `task_resumed`; igualdad del prefijo consumido con pasos globales; comandos rápidos concurrentes, detener entre lotes, tarea terminada/inexistente, ejecución que nunca alcanza la condición y ausencia de eventos.
- [x] `PG-B.03.04` Código: ampliar control por un contrato pequeño, sin recrear análisis/sesión; bombear en lotes acotados y ceder a UI; aplicar eventos ajenos también a tabla/salida/esperas. Distinguir «tarea seleccionada espera» de «agenda global sin progreso». No exponer eventos futuros por haberlos precargado.
- [x] `PG-B.03.05` Documentación: comandos, condiciones terminales, compatibilidad de ritmos y límites de seguridad de UI; distinguir tope local 10000 del límite del lenguaje (`ENG.TRACE.STEP#R4`), sin renombrar uno como otro ni retirarlo silenciosamente.
- [x] `PG-B.03.06` Verificar: mismo programa/configuración/cinta con ambas formas de paso produce misma traza/terminación; FRB real más cubit/widget; salida no duplicada ni reemitida al consultar historia. Registrar diferencias de selección permitidas y estado canónico común.

### PG-B.04 · Efectos simulados y entradas identificadas (Retirado el 2026-11-02)

- [x] `PG-B.04.01` Contrato: auditar identidad de solicitud de `Leer` frente a `effect_seq` de efecto, destinatario y vida de cada una. `input` actual recibe recurso/texto: no fingir que acepta task/solicitud. Definir rechazo de respuesta obsoleta/duplicada antes de enviarla; si se requieren lecturas concurrentes direccionables no expresables, especificar extensión pública y casos antes de implementarla. Mantener exclusión `input`/`effect_result`.
- [x] `PG-B.04.02` Casos: B06/B07/B10/B11/B14; archivos virtuales, HTTP preparado, tiempo lógico, timeout, permiso denegado, resultado incierto y cancelación. Dos pendientes de tareas distintas; `Leer` inválido y reintento, respuesta cruzada/tardía, nueva ejecución con mismo texto.
- [x] `PG-B.04.03` Tests: configuración inmutable del escenario, reinicio limpio del host, cero ampliación de derechos, validación de destinatario y rótulo simulado siempre visible en panel y ayuda. Dobles espía comprueban ausencia de acceso externo; integración valida lo que realmente acepta API.
- [x] `PG-B.04.04` Código: escenario entrega datos al host del motor; VM decide espera, reanudación y fallo. Transportar tarea/solicitud en modelo y comando, validar identidad de ejecución antes de responder. Configuración y selección por estado/puerto, sin `await` en widgets ni E/S en `engine/` de Dart. No perder esperas por autoresolver toda la ejecución al precargar.
- [x] `PG-B.04.05` Documentación: permisos, límites, orden de entrega, escenario simulado, incertidumbre y origen de respuestas; guiones válidos es/en enlazados a fichas/casos. No abrir red/rutas del equipo para «hacer pasar» HTTP.
- [x] `PG-B.04.06` Verificar: casos de capacidad/HTTP/entrada por FRB y adaptador app, recursos abiertos cero al liberar/cortar donde corresponde, cero consultas al host durante replay y respuesta ajena rechazada sin avanzar.

### PG-B.05 · Proyecciones reproducibles

- [x] `PG-B.05.01` Contrato: definir entrada completa y representación canónica de comparación: fuentes/perfil/rigor/configuración/semilla/límites/permisos/escenario/cinta/orden de entrega, revisión y secuencia de selección/página. Separar traza de eventos de cinta de efectos; una cinta no contiene necesariamente todos los campos de vista. Aplicar rechazos de `ENG.EFFECT.TAPE#R4`.
- [x] `PG-B.05.02` Casos: B01/B03/B06/B12/B14; reproducción íntegra y cinta de otra identidad, truncada, adulterada, incierta/redactada y orden de entrega divergente. No esperar replay exitoso de una cinta sellada no reproducible.
- [x] `PG-B.05.03` Tests: repetir desde estado nuevo con distintas particiones, navegación/páginas y pausas de UI; comparar IDs/relaciones/focos/pilas/variables/canales/solicitudes/terminación. No comparar timestamps ni píxeles dependientes del entorno como equivalencia semántica.
- [x] `PG-B.05.04` Código: reconstrucción determinista sin activar host, análisis ni agenda desde pintado; invalidar caché por revisión/ejecución y ligar cursores a identidad completa. Si la ventana necesita contexto anterior a R8, obtenerlo por mecanismo verificado, no recorrer toda la cinta en cada render.
- [x] `PG-B.05.05` Documentación: qué datos se necesitan para reproducir, límites de retención y fallos, qué cambia solo disposición y qué constituye divergencia; almacenamiento de muestras sin secretos ni artefactos generados manuales.
- [x] `PG-B.05.06` Verificar: igualdad canónica entre ejecución/grabación/reproducción y reconstrucción de ventana; espía de host con cero llamadas en replay; todas las variantes de rechazo tipadas. La falta de transporte de cinta se resuelve antes, no se sustituye por volver a ejecutar contra host simulado.

### PG-B.06 · Cancelación, error, canal lleno y bloqueo

- [x] `PG-B.06.01` Contrato: tabla de estados/transiciones según `LANG.TASK.SCOPE#R6`–`R16`, `LANG.TASK.CHANNEL#R2`–`R8`, `ENG.TASK.AGENDA#R7` y cinta. Diferenciar Error recuperable, trampa global, cancelación cooperativa de hermanas y cancelación del anfitrión; señalar recursos/limpiezas/efectos abandonados e incertidumbre.
- [x] `PG-B.06.02` Casos: B08/B09/B10/B11; primer error por orden de terminación, asociados solo si realmente ocurrieron antes de cancelar, limpiezas LIFO, canal lleno/abierto vacío/cerrado con datos/cerrado vacío, `Elegir` empatado, bloqueo sin efectos frente a espera externa capaz de reanudar.
- [x] `PG-B.06.03` Tests: estados y diagnósticos con sitios relacionados por tarea; no fabricar dos errores con dos hijas de retorno inmediato; cancelación con hijas anidadas y respuesta externa tardía; cola exacta sin confundir valor ausente con variable sin inicializar.
- [x] `PG-B.06.04` Código: proyectar datos normativos de motor y transiciones confirmadas. Si el comando de corte requiere un `advance` para confirmar/sellar, consumir esa terminación antes de limpiar UI/recurso; no devolver «cancelled» inventado porque se llamó `stop()`. No representar el estado final del recurso como si fuera el estado de cada evento anterior.
- [x] `PG-B.06.05` Documentación: tabla conducta→cinta→recursos→presentación→ayuda, sin copiar un plan transitorio. Corregir pendientes obsoletos solo tras resolver PB-PRE-05.
- [x] `PG-B.06.06` Verificar: casos de error/canales/bloqueo por API y FRB, más tabla/foco/widgets. Cero hijas abandonadas por la proyección; error y cancelación no se pintan como unión exitosa; corte host no promete ejecutar limpiezas de usuario.

### PG-B.07 · Agenda independiente de presentación

- [x] `PG-B.07.01` Contrato: reiterar agenda FIFO/cesión por masa normativa; distinguir bombeo cooperativo de UI, animación y tiempo lógico del programa. Decidir límites de cada llamada síncrona y cola/caché antes de implementarlos; respetar prohibición de Isolate del README actual.
- [x] `PG-B.07.02` Casos: B02/B06/B12/B13/B15; mismas entradas con animación desactivada, más repintados, distintas velocidades, selección y redimensionado; efecto demorado manualmente sin sondeo infinito.
- [x] `PG-B.07.03` Tests: pureza de presentación/composición, inmutabilidad y bombeo acotado; doble de transporte cuenta llamadas por comando y demuestra que reconstruir/repintar no pide `advance` ni responde efectos. Toda regla mecánica nueva necesita fixture que falle deliberadamente.
- [x] `PG-B.07.04` Código: extracción de drenado de efectos si es ilimitado; acciones en aplicación, datos preparados para pintores, cesión entre lotes. Una animación puede suavizar transición visual, nunca decidir próxima tarea, respuesta ni evento. Cancelación/edición invalidan callbacks de ejecución vieja.
- [x] `PG-B.07.05` Documentación: responsables de agenda/animación/consulta, políticas con dueño, límites de UI y cómo medirlos; no agregar excepciones de `Timer`, `await` o imports para facilitar un widget.
- [x] `PG-B.07.06` Verificar: particiones y ritmos distintos conservan secuencia; validadores de arquitectura/pureza/límites en verde; registrar máximo lote observado y demora de detención sin afirmar garantía temporal desde un test funcional.

### PG-B.08 · Integración con puente real

- [x] `PG-B.08.01` Contrato: inventario de operaciones y campos por escenario contra `ApiSession`, no contra métodos imaginados del bridge. Listar qué observación certifica API, adaptación Dart, cubit o widget. Conservar negociación/versiones y sesión/revisión.
- [x] `PG-B.08.02` Casos: seleccionar B01–B15 según la matriz §7.1, recursos inválidos/liberados, JSON/clase/versión desconocidos, reinicio, edición y cierre. Casos de sintaxis es/en desde reglas y casos vigentes, sin «traducir» identificadores propios ni relajar parser para fixtures.
- [x] `PG-B.08.03` Tests: añadir integración espejo que abre transporte real, ejecuta archivo suelto, consulta tarea suspendida, avanza otra, responde solicitud y cancela/libera. Afirmar estados de dominio y proyecciones de app, no solo sobres JSON. Los dobles se reservan para errores/particiones controlados.
- [x] `PG-B.08.04` Código: adaptar frontera solo si hace falta; si no cambia firma Rust exportada, justificar no regenerar FRB. Si cambia, generar desde dueño y comparar; nunca editar `frb_generated.rs` ni `lib/engine/bridge/` a mano. Añadir escenario SEE app donde el corpus requiera observación Dart.
- [x] `PG-B.08.05` Documentación: comandos exactos y alcance por plataforma; el humo de macOS no certifica iOS/Windows. README de puente actualizado solo si cambió su contrato/operación.
- [x] `PG-B.08.06` Verificar: biblioteca nativa fresca, `bash tool/test_bridge.sh`, tests nativos afectados, integración app, conformidad afectada y generación si corresponde. Humo local de macOS/iOS según medios disponibles; cualquier falta se informa y no se presenta como ejecución física.

### PG-B.09 · E-PG-12 dinámico y medición

- [x] `PG-B.09.01` Contrato/protocolo: cerrar inventario de escenas §7.1 con oráculo manual y configuración completa; cruzar cada estado/espera/unión/solicitud con regla. Conservar evidencia estática separada y tratar el diferimiento humano según PB-PRE-06.
- [x] `PG-B.09.02` Casos: preparar fuentes bilingües validadas de mismo subprograma en dos tareas, una esperando y otra avanzando, error, cancelación, canal lleno, `Elegir` y revisión nueva; guion con evento exacto de cada pregunta y respuesta derivada antes de ejecutar.
- [x] `PG-B.09.03` Tests: protocolo automatizado por identidad, geometría, tabla, navegación, accesibilidad y ausencia de omisiones; prueba de arnés que rechaza configuración diferente, muestra incompleta, resultado divergente o manifiesto faltante. No llamar a estos tests «comprensión humana».
- [x] `PG-B.09.04` Implementar arnés de proyección pura y medición integrada por separado, con entradas preparadas y tamaños de §6; mantener rendimiento fuera de tests de widget como umbral de CI. Guardar datos crudos, manifiesto y resumen recalculable.
- [x] `PG-B.09.05` Documentar protocolo y resultados dinámicos en `docs/` y procedimiento reutilizable en README del arnés dueño. Preparar material para ≥12 principiantes, orden contrabalanceado e idiomas, sin atribuir autoría/revisión/consentimiento inexistentes.
- [x] `PG-B.09.06` Verificar cierre: resultados automatizados completos, p95 y memoria con procedencia, umbral candidato claramente rotulado; evidencia humana aportada por persona o diferimiento explícito aplicable. Si falla comprensión, revisar notación y repetir evidencia pertinente; no retirar cobertura. No declarar PG-B.C10/C11 por medir solo la parte rápida.

### 4.2 Puntos nuevos de la reformulación

Cada punto: `.01` especificación · `.02` casos · `.03` tests · `.04` código (incluye el borrado de lo que deja muerto) ·
`.05` README y reglas · `.06` verificación.

#### Bloque 1 · Contrato del corpus

##### PG-B.10 · Autoridad plena por omisión

- [ ] `PG-B.10.01` Reescribir `LANG.CAPABILITY.MODEL#R2`, `RT.HOST.INTERFACE#R1/R7`, `LIB.HTTP#R1` y las reglas de
  `requests`/`grants.permissions` de `API.PROJECT.MANIFEST` y `API.EXECUTE`: `Solicitar*` concede siempre la familia
  soportada por el anfitrión; sin intersección ni manifiesto de permisos; familia no soportada → `ErrorES` de plataforma.
- [ ] `PG-B.10.02` Rederivar los casos que hoy esperan `permiso_denegado` por falta de concesión: pasan a probar éxito, o
  denegación real del SO inyectada por el doble de prueba, o atenuación voluntaria. Perfiles es/en, ambos rigores.
- [ ] `PG-B.10.03` Tests de semántica y runtime que fallan si reaparece una comprobación de permiso por concesión.
- [ ] `PG-B.10.04` Sin código en este punto (el código es PG-B.16).
- [ ] `PG-B.10.05` Fichas de `TOOL.SERVICE.CATALOG` sin lenguaje de concesión («si el permiso está activo»).
- [ ] `PG-B.10.06` `see validate`, `export --check`; registro de IDs modificados para el reanclaje de PG-B.15.

##### PG-B.11 · Destinos de red

- [ ] `PG-B.11.01` Reescribir `LIB.HTTP.POLICY#R1–R4`, `RT.HOST.INTERFACE#R8/R9` y `LIB.HTTP#R3`: `http` y `https` a
  cualquier host y dirección (loopback, privadas incluidas); TLS validado; nativo sin seguir redirecciones, sin cookies ni
  proxies ambientales; descenso HTTPS→HTTP permitido en `Redirigida`; cabeceras rechazadas solo las del transporte
  (D-06a); navegador según D-PGB-R08.
- [ ] `PG-B.11.02` Casos: loopback y dirección privada aceptadas; `http://` público aceptado en nativo; redirección a
  `http`; `cookie` aceptada en nativo y `PeticionInvalida` de plataforma en navegador; CORS ausente como error tipado.
- [ ] `PG-B.11.03` Tests del validador de destinos del runtime sin filtro de rangos.
- [ ] `PG-B.11.04` Sin código aquí (PG-B.16, PG-B.18, PG-B.20).
- [ ] `PG-B.11.05` Hoja de STRIDE y K-07 anotados como sustituidos en `docs/` (PG-7.15 completa la reconciliación).
- [ ] `PG-B.11.06` `see validate`, `export --check`.

##### PG-B.12 · Tiempo y azar reales

- [ ] `PG-B.12.01` Reescribir `LIB.TIME#R1/R2` y `RT.HOST.INTERFACE#R3`: en vivo, reloj del sistema en cada lectura y
  temporizador que espera tiempo real sin bloquear otras tareas; semilla de entropía del SO grabada en la cinta; semilla
  explícita por opción del anfitrión; en reproducción, todo desde la cinta.
- [ ] `PG-B.12.02` Casos en `ENG.EFFECT.TAPE` y `LIB.TIME`: dos lecturas de reloj distintas y crecientes con el doble de
  prueba; temporizador concurrente con otra tarea que avanza; cinta con semilla reproduce la misma secuencia de `azar`.
- [ ] `PG-B.12.03` Tests de cinta con reloj y semilla reales grabados.
- [ ] `PG-B.12.04` Sin código aquí (PG-B.17, PG-B.18).
- [ ] `PG-B.12.05` README del runtime: modelo de tiempo vivo frente a reproducción.
- [ ] `PG-B.12.06` `see validate`, `export --check`.

##### PG-B.13 · Archivos con rutas del sistema

- [ ] `PG-B.13.01` Reescribir `LANG.CAPABILITY.MODEL#R3` y reglas de `LIB.IO`: rutas absolutas o relativas a la carpeta
  de trabajo del anfitrión, `..` permitido; `Subdirectorio` confina lo que el programa decida; `PermisoDenegado` solo
  del SO.
- [ ] `PG-B.13.02` Casos: ruta absoluta, `..`, ruta inexistente, directorio sin permiso del SO (doble), atenuación que sí
  rechaza escapar de una subcapacidad creada por el programa.
- [ ] `PG-B.13.03` Tests de resolución de rutas en macOS y Windows (letras de unidad, separadores, UNC) sobre el doble.
- [ ] `PG-B.13.04` Sin código aquí.
- [ ] `PG-B.13.05` Fichas de ayuda de `SolicitarDirectorio` y `Subdirectorio`.
- [ ] `PG-B.13.06` `see validate`, `export --check`.

##### PG-B.14 · Argumentos reales

- [ ] `PG-B.14.01` Regla de `Argumentos` en `RT.HOST.INTERFACE`: entrega los argumentos de ejecución del anfitrión, en
  orden y sin el nombre del programa.
- [ ] `PG-B.14.02` Casos: ninguno, uno, varios con espacios y Unicode, argumento vacío.
- [ ] `PG-B.14.03` Tests del doble con argumentos.
- [ ] `PG-B.14.04` Sin código aquí.
- [ ] `PG-B.14.05` Ficha de ayuda de `SolicitarArgumentos` con el origen por anfitrión.
- [ ] `PG-B.14.06` `see validate`.

##### PG-B.15 · Doble de prueba del corpus y reanclaje

- [ ] `PG-B.15.01` Reescribir `RT.HOST.INTERFACE#R6` como doble de prueba del corpus, no distribuible (D-01a).
- [ ] `PG-B.15.02` Rederivar todos los casos con bloque `anfitrion` que declaren `permissions`, `requested_permissions` o
  `network_origins` (inventario de §A.2.1 del análisis), retirando esas claves.
- [ ] `PG-B.15.03` Caso negativo de `see validate` que rechaza un caso con `permissions` en el bloque de anfitrión.
- [ ] `PG-B.15.04` Esquema de casos y validación SEE actualizados si el esquema conoce esas claves; regenerar
  `export.json`.
- [ ] `PG-B.15.05` README de `pseudolearn_spec` si cambia el esquema.
- [ ] `PG-B.15.06` `see validate`, `export --check`, `lock --refresh` de todos los IDs del bloque 1 en una sola orden,
  `lock --check`.

#### Bloque 2 · Motor y API

##### PG-B.16 · Runtime y API sin autoridad por concesión

- [ ] `PG-B.16.01` Contrato ya fijado por el bloque 1.
- [ ] `PG-B.16.02` Vincular los casos del bloque 1 al sujeto `engine` en `conformance.yaml`; retirar vínculos `P6` que
  quedan sin objeto.
- [ ] `PG-B.16.03` Tests de `pseudolearn_runtime` y `pseudolearn_api` que fallan con listas de orígenes o intersección.
- [ ] `PG-B.16.04` Eliminar `network_origins`, `local_origins`, `requested_permissions` e intersección de autoridad de
  runtime, API y `bench_worker`; `DestinoDenegado` solo en atenuación voluntaria; `FakeHostProvider` y `memory_host*`
  detrás de `test-host` (D-PGB-R09); regla `isolation` que impide activar `test-host` desde CLI, puente y Wasm.
- [ ] `PG-B.16.05` README del motor, API y runtime; `architecture.yaml` (`isolation`).
- [ ] `PG-B.16.06` `see conform --subject engine --only <IDs>`; `cargo test` de runtime y API; Clippy; `rust-checks all`
  e `isolation` con caso negativo; `cargo tree -e features` de CLI, puente y Wasm sin `test-host`.

##### PG-B.17 · Cinta con tiempo real y semilla

- [ ] `PG-B.17.01` Contrato fijado por PG-B.12.
- [ ] `PG-B.17.02` Casos de PG-B.12 vinculados.
- [ ] `PG-B.17.03` Tests de grabación y reproducción con reloj, temporizador y semilla vivos.
- [ ] `PG-B.17.04` Grabar semilla y lecturas de reloj; el temporizador registra la duración real; reproducción sin
  consultar al anfitrión.
- [ ] `PG-B.17.05` README del runtime y timeline.
- [ ] `PG-B.17.06` `see conform` de `ENG.EFFECT.TAPE` y `LIB.TIME`; tests de cinta truncada/alterada intactos.

#### Bloque 3 · CLI y extensión de escritorio

##### PG-B.18 · CLI con anfitrión físico completo

- [ ] `PG-B.18.01` Reescribir `TOOL.CLI.RUN`, `TOOL.CLI.CONVENTIONS` y `TOOL.CLI.MESSAGES`: sin opciones de concesión;
  argumentos del programa tras `--`; carpeta de trabajo = directorio actual; `--semilla` opcional.
- [ ] `PG-B.18.02` Casos de CLI: programa con red, archivos y argumentos sin opciones; opción retirada como error de uso
  con mensaje que explica que ya no hace falta.
- [ ] `PG-B.18.03` Tests contra `cargo xtask http-test-server` en loopback: GET/POST, 4xx/5xx, timeout, TLS inválido,
  redirección entregada, cancelación; `Esperar 1 s` mide ≥ 1 s; reloj creciente.
- [ ] `PG-B.18.04` Extraer el anfitrión físico a `pseudolearn_host` (lo consume la CLI desde aquí); eliminar
  `--conceder`/`--grant`, `--archivos`/`--files`, `--origen`/`--origin`, `--origen-local`/`--local-origin`; conservar
  `--raiz-prueba` solo si las pruebas TLS lo exigen, documentado como opción de pruebas; eliminar el filtro de rangos,
  `network_address_policy_tests.rs` y las entradas SSRF de `tests/network_vector_registry.rs` y
  `tests/network_security_vectors.rs`; reloj, temporizador y argumentos reales.
- [ ] `PG-B.18.05` README de CLI y de `pseudolearn_host`; `deny.toml` si cambian dependencias.
- [ ] `PG-B.18.06` `cargo test` de CLI y `pseudolearn_host`; Clippy; `rust-checks all`; `see conform --subject cli`.

##### PG-B.19 · Extensión de escritorio y DAP

- [ ] `PG-B.19.01` `TOOL.DAP`: `launch` acepta `args` y `cwd`; sin claves de permiso.
- [ ] `PG-B.19.02` Casos DAP con argumentos y carpeta de trabajo.
- [ ] `PG-B.19.03` Tests de `run_arguments.ts` y `debug_configuration.ts`; prueba de host confiable que ejecuta el
  programa de PG-B.27.
- [ ] `PG-B.19.04` `run --editor` y `pseudo dap` con anfitrión físico; carpeta del workspace o del archivo; retirar de la
  lista de rechazo las claves que dejan de significar algo; mensajes es/en sin «No se concede».
- [ ] `PG-B.19.05` README de extensión: Confianza de Workspace como límite de VS Code.
- [ ] `PG-B.19.06` `vitest`, `check:*`, `node tests/host/run-host.mjs trusted`.

#### Bloque 4 · Extensión web

##### PG-B.20 · Anfitrión web real

- [ ] `PG-B.20.01` Contrato de diferencias de plataforma fijado en PG-B.11; regla de archivos sobre el sistema de
  archivos del editor.
- [ ] `PG-B.20.02` Casos web: archivos del workspace, reloj, temporizador, argumentos, CORS ausente, contenido mixto.
- [ ] `PG-B.20.03` `tests/web/http_scenarios.ts` y `file_scenarios.ts` sin pasos de concesión; la ruta «sin CORS» del
  servidor de pruebas espera el error de plataforma.
- [ ] `PG-B.20.04` Eliminar `pseudolearn.grantNetwork`, `pseudolearn.grantFiles`, `BrowserGrants`,
  `browser_scratch_files.ts` y `allowedOrigins` de `fetch_host.mjs`; archivos con `workspace.fs`; reloj, temporizador
  y argumentos en `BrowserEffectHost`; `showCapabilities` muestra los límites del navegador.
- [ ] `PG-B.20.05` README de extensión y de `pseudolearn_wasm`.
- [ ] `PG-B.20.06` `pnpm build:web`, `pnpm check:web`, `node tests/web/run-web.mjs` en Chromium y WebKit;
  `node --test browser/fetch_host.test.mjs`.

#### Bloque 5 · App: anfitrión real en macOS, iOS y Windows

##### PG-B.21 · Capa y puerto de anfitrión

- [ ] `PG-B.21.01` Sin cambio de corpus.
- [ ] `PG-B.21.02` Escenarios SEE de app (`tool/see_app_scenarios.dart`) sin escenarios simulados.
- [ ] `PG-B.21.03` Caso negativo del test de arquitectura: la capa nueva importando presentación o `engine/` falla.
- [ ] `PG-B.21.04` Declarar en `architecture.yaml`, antes del código, la capa `host` (anillo 2, `may_import: [model,
  ports]`, admite `dart:io`, prohíbe Flutter de interfaz y `engine/`) para carpeta de trabajo y argumentos; puerto en
  `domain/ports`; `RustEffectGate` depende del puerto; ensamblado en `lib/composition/`.
- [ ] `PG-B.21.05` README app §3.2 (capas) y §3.3.
- [ ] `PG-B.21.06` `flutter test test/architecture/`, `dart run tool/check_limits.dart`.

##### PG-B.22 · Anfitrión real en el puente

- [ ] `PG-B.22.01` Medir ios-arm64 Release del puente con `pseudolearn_host` (perfil vigente `opt-level = "z"`, LTO);
  si supera `PERF.ARTIFACT.SIZE#R1`, **parar** y presentar al dueño medición, opciones y recomendación.
- [ ] `PG-B.22.02` Contrato de adaptador común CLI/app contra `cargo xtask http-test-server` (RN-4 del análisis).
- [ ] `PG-B.22.03` Tests Dart–FFI reales: GET de loopback, archivo en carpeta de trabajo, `Esperar` real, argumentos,
  cancelación durante HTTP, liberación de recursos.
- [ ] `PG-B.22.04` `native/Cargo.toml` con `pseudolearn_host`; hilo de red (D-PGB-R03); raíces de plataforma
  (D-PGB-R04); regla `isolation` del puente reescrita (CF-N13); carpeta de trabajo por documento (D-PGB-R05); campo de
  argumentos (D-PGB-R06); temporizador real (D-PGB-R07).
- [ ] `PG-B.22.05` README de `native/`, app §4.49–§4.50 y §4.54 reescrita como «Anfitrión real en modo de archivo
  único».
- [ ] `PG-B.22.06` `bash tool/test_bridge.sh`, `bash tool/bridge.sh check`, Clippy y `cargo deny` de `native/`,
  `rust-checks isolation`.

##### PG-B.23 · Configuración de plataforma

- [ ] `PG-B.23.01` Sin cambio de corpus.
- [ ] `PG-B.23.02` Lista de comprobación por plataforma en el README.
- [ ] `PG-B.23.03` Test de contenido que comprueba la presencia de las claves de plataforma.
- [ ] `PG-B.23.04` iOS: `NSLocalNetworkUsageDescription` es/en y excepción ATS (D-08a); macOS: entitlements revisados;
  Windows: `msix_config.capabilities` con `internetClient` y `privateNetworkClientServer`.
- [ ] `PG-B.23.05` README app §2.4/§2.6 con la justificación para revisión de tienda.
- [ ] `PG-B.23.06` Build macOS e iOS simulador; Windows sin build local («no verificado»).

##### PG-B.24 · Eliminación de la simulación de la app

- [ ] `PG-B.24.01` Sin cambio de corpus.
- [ ] `PG-B.24.02` Escenas y casos de app sin `SimulatedScenario`.
- [ ] `PG-B.24.03` Test de contenido (o ampliación de `check_content.dart`) que falla si reaparecen identificadores o
  claves `simulated*`, con su caso negativo.
- [ ] `PG-B.24.04` Borrar los archivos y claves de §B.4.4 del análisis; modificar los consumidores listados allí;
  regenerar localizaciones.
- [ ] `PG-B.24.05` README app §1.3, §4.54, §4.57–§4.60 sin simulación.
- [ ] `PG-B.24.06` `flutter analyze --fatal-infos --fatal-warnings` y verificadores de app; `git grep -i simulat` en
  `apps/pseudolearn_app/lib` y `test` con 0 coincidencias.

#### Bloque 6 · Reverificación con efectos reales

##### PG-B.25 · Tareas observables con anfitrión real

- [ ] `PG-B.25.01` Sin contrato nuevo; resolver o reportar `APP.EDITOR.COMPLETION#R5/R6/R10` y
  `APP.EXEC.SNAPSHOT-VIEW#R1/R4` (PB-PRE-02).
- [ ] `PG-B.25.02` Escenas B06, B10, B11 y B12 de §7.1 con efectos reales en loopback.
- [ ] `PG-B.25.03` Cintas grabadas por el anfitrión real; reproducción con espía de cero llamadas; corte del anfitrión
  durante HTTP; temporizador real sin alterar la agenda.
- [ ] `PG-B.25.04` Ajustes de adaptación que aparezcan; ninguno reintroduce simulación.
- [ ] `PG-B.25.05` README app §4.57–§4.59.
- [ ] `PG-B.25.06` `see conform --subject app`; tests dirigidos de `test/engine/rust/` y `test/application/execution/`.

##### PG-B.26 · E-PG-12 dinámico regenerado

- [ ] `PG-B.26.01` Protocolo de PG-B.09 sin cambios.
- [ ] `PG-B.26.02` Escenas regeneradas según D-PGB-R10.
- [ ] `PG-B.26.03` Arnés rechaza escenas con escenario simulado.
- [ ] `PG-B.26.04` Campaña automatizada repetida con procedencia.
- [ ] `PG-B.26.05` `e-pg-12-dinamico-evidencia.md` actualizado; estudio humano con el diferimiento del 2026-10-22.
- [ ] `PG-B.26.06` Resumen recalculable desde crudos.

#### Bloque 7 · Aceptación por plataforma

##### PG-B.27 · Programa de aceptación

- [ ] `PG-B.27.01` Programa es/en en archivo único: GET `https://rickandmortyapi.com/api/character/1`, imprime nombre y
  estado; variante que lee un archivo de la carpeta de trabajo y usa `Esperar`.
- [ ] `PG-B.27.02` Esperado derivado de la respuesta documentada de la API, comprobado a mano el día de la ejecución.
- [ ] `PG-B.27.03` Sin test automatizado contra Internet (el corpus no depende de Internet).
- [ ] `PG-B.27.04` Sin código.
- [ ] `PG-B.27.05` Registro por plataforma en §11: fecha, hora, salida real y código HTTP.
- [ ] `PG-B.27.06` Ejecución sin configuración en CLI macOS, extensión escritorio macOS, extensión web Chromium y WebKit,
  app macOS y app iOS simulador. App Windows: «implementado, no verificable en este equipo».

#### Bloque 8 · Características de la app que hoy no se pueden usar

##### PG-B.28 · Selector de rigor

- [ ] `PG-B.28.01` Reutilizar `LANG.PROFILE.STRICTNESS`; sin regla nueva.
- [ ] `PG-B.28.02` Escenario SEE de app con el mismo programa en ambos rigores.
- [ ] `PG-B.28.03` Tests de cubit, persistencia por documento y widget accesible.
- [ ] `PG-B.28.04` Control en ajustes del documento; `rustStrictness` deja de estar fijo.
- [ ] `PG-B.28.05` README app §1.5 (pendiente resuelto).
- [ ] `PG-B.28.06` Verificadores de app.

##### PG-B.29 · Reproducir una ejecución

- [ ] `PG-B.29.01` Reutilizar `API.EXECUTE#R9` y `ENG.EFFECT.TAPE`.
- [ ] `PG-B.29.02` Escenario con cinta válida y con cinta rechazada.
- [ ] `PG-B.29.03` Tests de cubit y widget; espía de anfitrión con cero llamadas.
- [ ] `PG-B.29.04` Control «Reproducir» que usa el puerto `execution_reproduction.dart` existente; rechazos localizados.
- [ ] `PG-B.29.05` README app §4.57 (pendiente resuelto).
- [ ] `PG-B.29.06` Verificadores de app; `tool/test_bridge.sh`.

##### PG-B.30 · Localización del receptor y cobertura completa

- [ ] `PG-B.30.01` Sin regla nueva.
- [ ] `PG-B.30.02` Filas de cobertura de patrones de variante y literales de función con su proyección esperada.
- [ ] `PG-B.30.03` Tests de `watch_row_projection.dart` en perfil inglés; `check_syntax_coverage.dart` con caso negativo
  que rechaza una fila «extensión».
- [ ] `PG-B.30.04` Vocabulario de receptor parametrizado por perfil; proyección de las dos formas en las vistas.
- [ ] `PG-B.30.05` README app §1.5 y sección de cobertura.
- [ ] `PG-B.30.06` Verificadores de app; cobertura sin filas «extensión».

## 5. Capas, archivos y responsabilidad

### 5.1 Respuestas obligatorias antes de editar

Las rutas **propuestas** no existen. Para cada archivo finalmente elegido se registra una fila en §11 con capa, imports y
dueño. Las filas de la versión anterior para PG-B.01–.09 siguen válidas salvo la de `rust_simulated_host` y
`simulated_capabilities`, que se borran.

| Archivos | Capa e imports permitidos | Prohibido · responsabilidad |
|---|---|---|
| `packages/pseudolearn_spec/specifications/{lang,lib,rt,api,tool}/…` del bloque 1; `conformance*.yaml`, `differential-exemptions.json`, `property-conformance.json` | Corpus y datos; identidades internas | Sin `docs/` ni enlaces externos; congelamiento; un dueño por regla |
| Propuesto `packages/pseudolearn_engine/crates/pseudolearn_host/` | Crate hoja del motor: `serde_json`, `cap-std`, Hyper, Rustls, Tokio, verificador de plataforma; **no** importa crates del motor | Sin semántica del lenguaje ni validación normativa (vive en el runtime); responsabilidad: atender efectos reales con el formato público de `API.EXECUTE` |
| `crates/pseudolearn_runtime/src/…` y `crates/pseudolearn_api/src/{execution_setup,fake_host,…}.rs` | Según `architecture.yaml` del motor | Sin transporte de red; el doble solo bajo `test-host` |
| `packages/pseudolearn_engine/architecture.yaml` | Reglas | `isolation`: puente admite `pseudolearn_host`; API y Wasm siguen sin transporte; nadie de producto activa `test-host` |
| `apps/pseudolearn_cli/src/{options,execution_options,messages,physical_*}.rs` | Capas del `architecture.yaml` de la CLI | La CLI deja de poseer el transporte: lo consume de `pseudolearn_host` |
| `apps/pseudolearn_vscode/src/{application,adapters,contracts}/…` de §1.2 | Capas de `architecture.json` | Sin concesiones; diferencias de navegador como errores tipados |
| `apps/pseudolearn_app/native/{Cargo.toml,src/api.rs}` | Capa bridge: API, `pseudolearn_host`, FRB, `serde_json` | Sin semántica ni UI; FRB generado no se edita a mano |
| Propuesta capa `apps/pseudolearn_app/lib/host/` | `host` → `model`, `ports`; admite `dart:io` | Sin Flutter de interfaz, `engine/`, `application/`; responsabilidad: carpeta de trabajo y argumentos |
| `lib/domain/ports/` (puerto de anfitrión propuesto) | ports → model | Sin `dart:io` ni motor |
| `lib/engine/rust/{rust_effect_gate,rust_program_execution,rust_replay_host}.dart` | engine → model, ports | Sin `dart:io`; delega efectos al puente |
| `lib/application/execution/{execution_cubit,execution_state}.dart` | application → model, ports | Sin selección de escenario |
| `lib/presentation/document/components/document_footer.dart` y controles nuevos de rigor y reproducción | presentation → model, application | Sin E/S ni `Timer` semántico |
| `lib/presentation/l10n/app_{es,en}.arb` | Datos de presentación | Generados por el procedimiento del miembro |
| `apps/pseudolearn_app/{ios/Runner/Info.plist,macos/Runner/*.entitlements,pubspec.yaml}` | Configuración de plataforma | Solo claves de §4.2 PG-B.23 |

Límites que no se elevan: app 250 líneas/archivo, 40/función, 30/build, tres parámetros posicionales, anidación tres,
cinco métodos públicos; Rust 300/40/cuatro/tres/siete; extensión 300/40/cuatro/tres/siete.

### 5.2 Tabla de campos

Se conserva la exigencia de la versión anterior (campo consumido → contrato, operación, clave, tipo, obligatoriedad,
vida, modelo, error, caso, consumidor) y se añaden: carpeta de trabajo efectiva, argumentos entregados, semilla grabada,
causa de error de plataforma y URL final de respuesta.

## 6. Presupuestos de rendimiento y seguridad

### 6.1 Rendimiento

- `PERF.ARTIFACT.SIZE#R1` (ios-arm64 ≤ 5 MiB; Wasm Brotli ≤ 900 KiB) se mide en PG-B.22.01 antes de integrar y al cierre.
- `PERF.SUITE.CORE`: la infraestructura de anfitrión inactiva no entra en el camino caliente; medición contra `194bd9ce`
  con `PERF.PROTOCOL` (≥ 10 procesos, ≥ 30 iteraciones).
- `PERF.PG.APP.VIEW` candidato de la versión anterior: protocolo de medición sin cambios (cargas 0/1/10/100, intervalo
  puro e integrado separados, procedencia antes de compilar, todas las muestras).
- `PERF.PG.HTTP`: el transporte real se mide solo en loopback; el tiempo de Internet nunca mide el compilador.

### 6.2 Seguridad y límites que se conservan

| Frontera | Control |
|---|---|
| TLS | Siempre validado; raíces de prueba solo por opción de pruebas de la CLI |
| Recursos | `max_http_*`, pendientes de red, combustible, tareas, colas y salida con terminación definida (D-14) |
| Secretos | Cabeceras `authorization` y credenciales por referencia en la cinta; nunca en paneles ni logs |
| Doble de prueba | Inalcanzable desde CLI, puente y Wasm, comprobado por `isolation` con caso negativo |
| Reproducción | Cinta inválida no activa el anfitrión; incertidumbre y redacción visibles |
| Hilo UI | Bombeo acotado; la red vive en el hilo Rust; stop durante HTTP y durante `Esperar` probado |
| Solicitudes | Doble envío, respuesta tardía o de ejecución vieja rechazados sin avanzar |

Se eliminan de esta tabla, respecto de la versión anterior: «sin permisos por omisión», «sin ampliación de derechos» y
«sockets/DNS/disco real» como prohibición.

## 7. Pruebas, verificadores y experimentos

### 7.1 Matriz de escenas

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

Cambios de la reformulación sobre esa matriz:

| Escena | Cambio |
|---|---|
| B06 Efectos | «sin permisos» sale del borde; entra «error de plataforma» y «dos peticiones HTTP reales en loopback entregadas fuera de orden» |
| B11 Error | «timeout/denegación» pasa a «timeout real del servidor loopback y `PermisoDenegado` del SO» |
| B12 Reproducción | La cinta proviene del anfitrión real |
| B16 (nueva) Anfitrión real | Archivo de la carpeta de trabajo, `Esperar` real, reloj creciente, argumentos, HTTP loopback; borde: ruta inexistente, carpeta sin permiso, servidor caído, TLS inválido, cancelación durante HTTP y durante `Esperar` |
| B17 (nueva) Aceptación | Programa de PG-B.27 por plataforma (manual, Internet) |

### 7.2 E-PG-12 dinámico

Protocolo sin cambios (preguntas, contrabalanceo, ≥ 12 principiantes gestionados por la persona, diferimiento del
2026-10-22 vigente). Escenas regeneradas según D-PGB-R10.

### 7.3 Comandos y alcance

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

Comandos añadidos por la reformulación:

| Momento/miembro | Comando | Qué certifica |
|---|---|---|
| Corpus | `cargo run -p see_cli --bin see -- validate`, `export --check`, `lock --refresh <IDs>`, `lock --check` | Bloque 1 y reanclaje |
| Motor | `cargo test --locked -p pseudolearn_runtime`, `-p pseudolearn_api`, `-p pseudolearn_host`; `cargo clippy --workspace --all-targets -- -D warnings`; `rust-checks all` e `isolation` | Bloques 2–3 |
| Grafo | `cargo tree --locked -e features` en CLI, `native/` y `pseudolearn_wasm` | Sin `test-host` en producto |
| CLI | `cargo test --locked`; `cargo xtask http-test-server` para la integración | PG-B.18 |
| Extensión | `pnpm test`, `pnpm check:types`, `pnpm check:architecture`, `pnpm check:comments`, `pnpm check:size`, `node tests/host/run-host.mjs trusted`, `pnpm build:web`, `pnpm check:web`, `node tests/web/run-web.mjs` | PG-B.19–.20 |
| App | `flutter analyze --fatal-infos --fatal-warnings`, `check_limits`, `check_content`, `check_design_system`, `check_syntax_coverage`, `flutter test test/architecture/`, `bash tool/test_bridge.sh`, `bash tool/bridge.sh check` | PG-B.21–.30 |
| Tamaño | Build Release ios-arm64 del puente y medición | PG-B.22.01 y cierre |
| Plataforma | Humo macOS y iOS simulador (README app §2.5); Windows sin humo local | PG-B.23, PG-B.27 |
| Erradicación | `git grep -n -i -E "simulat|grantNetwork|grantFiles|--conceder|--grant|--origin|--local-origin|network_origins|requested_permissions|local_origins"` fuera del doble y de `docs/` | 0 coincidencias |

Antes de cada comando nuevo, comprobar que existe en el README o el manifiesto del miembro; si no existe, registrar la
carencia y no inventar una orden parecida.

## 8. Riesgos y señales tempranas

| Riesgo | Señal | Mitigación/puerta |
|---|---|---|
| K-18 Falsa causalidad | Dos hijas comparten marco | Escenas B02–B05 (sin cambios) |
| K-19 Cobertura incompleta | Forma sin vista o con «extensión» | PG-B.30 y negativos de cobertura |
| PB-K10 Tamaño iOS | El puente supera 5 MiB | PG-B.22.01 para y pide decisión |
| PB-K11 Divergencia CLI/app | Mismo caso, resultado distinto | Un solo `pseudolearn_host` y contrato de adaptador común |
| PB-K12 Pruebas inestables | Fallos intermitentes con red | Solo loopback en pruebas; Internet solo en PG-B.27 |
| PB-K13 Simulación residual | `git grep` de §7.3 con coincidencias | Puerta de erradicación en cada bloque |
| PB-K14 UI congelada por red o `Esperar` | Stop sin efecto durante una espera | Hilo Rust; tests de stop en B16 |
| PB-K15 Rechazo de tienda | Rechazo 2.5.2 o ATS | Justificación en README y notas de revisión (dueño) |
| PB-K16 Windows sin verificar | Defecto en el primer uso | Tests unitarios de rutas Windows; rotulado «no verificado» |
| PB-K07 Deuda heredada invisibilizada | Fallos omitidos | Línea base de HEAD y C11 con comandos y logs |

## 9. Dependencias de la persona

| Momento | Dependencia | Acción |
|---|---|---|
| Antes de implementar | `PG-B.C01` autorización de inicio y `PG-B.C02` revisión de este plan | No marcar por la petición de redacción |
| PG-B.22.01 | Decisión si el puente supera `PERF.ARTIFACT.SIZE` | Presentar medición y opciones; esperar |
| Reanclaje | Revisión independiente de cambios normativos, si SEE la exige | Preparar diff y casos; no escribir nombres por inferencia |
| PG-B.23 | Texto de justificación de tienda (ATS, red local) | Proponer borrador |
| PG-B.26 | Estudio humano o mantener el diferimiento | Respetar el diferimiento vigente |
| PG-B.27 | Ejecución manual con Internet; Windows si hay equipo | Preparar programa y lista de comprobación |
| Cierre | Commit y push en la rama única | Solo con autorización |

## 10. Orden de ejecución y puntos de control

1. **P0 · Entrada.** C01/C02; §2.2; línea base.
2. **P1 · Corpus (bloque 1).** PG-B.10–.15. Puerta: `see validate`, `export --check`, `lock --check` en verde con los IDs
   reanclados; ningún caso con permisos en el anfitrión.
3. **P2 · Motor (bloque 2).** PG-B.16–.17. Puerta: conformidad `engine` de los IDs del bloque 1 sin divergencias;
   `test-host` ausente del grafo de producto.
4. **P3 · CLI y escritorio (bloque 3).** PG-B.18–.19. Puerta: PG-B.27 en CLI y extensión de escritorio contra loopback.
5. **P4 · Web (bloque 4).** PG-B.20. Puerta: Chromium y WebKit con archivos, reloj, temporizador, argumentos y HTTP.
6. **P5 · App (bloque 5).** PG-B.21–.24, con **parada obligatoria en PG-B.22.01** si el tamaño no cabe. Puerta:
   erradicación de §7.3 en la app.
7. **P6 · Reverificación y características (bloques 6 y 8).** PG-B.25, .26, .28–.30.
8. **P7 · Aceptación (bloque 7).** PG-B.27 por plataforma.
9. **P8 · Cierre.** Revisión del diff contra el alcance y las tres preguntas de capa; C03–C11 con evidencia; commit y
   push solo si están autorizados (skill `commit-message`, sin atribución de IA, rama única). Informe y parada antes de
   PG-L.

## 11. Resumen de ejecución

### 11.0 Reformulación del 2026-11-02

Las subsecciones 11.1–11.9 registran las iteraciones de la versión anterior (PG-B.01–PG-B.09) y se conservan sin cambios. Sus menciones a escenarios simulados describen lo que existía entonces; PG-B.24 los elimina. Las filas de los puntos nuevos PG-B.10–PG-B.30 se añaden aquí al ejecutarlos. Estado a la fecha de esta versión: plan reescrito, C01/C02 pendientes, ningún punto nuevo iniciado.


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
| PG-B.01.06 | Cumplido | Salidas de §11.9; tablas B01–B04/B14 de §11.1 | Tests dirigidos, límites, arquitectura y `rust-checks` pasan; conformidad del motor sin divergencias (3998 observaciones) tras reanclar el corpus y completar la identidad de `input` en el adaptador. Los hashes obsoletos eran ediciones oficiales previas sin reanclar, no una inmutabilidad real. |
| PG-B.02.01 | Cumplido | `API.EXECUTE` R7/R8; C13/C14; README API/app | Historial con tarea emisora, estado histórico por evento/tarea y límites; consulta de cola de canal no disponible, declarada como dato no observable. El reanclaje oficial queda pendiente de la puerta SEE registrada en .02.06. |
| PG-B.02.02 | Cumplido | `history_events.rs`, `debug_control.rs`, `state_pages.rs`; pruebas de proyección/cubit | Casos de evento y página vacíos, selección vencida, árbol anidado/parcial, unión, ventana 4096/4097 y cursores por evento, tamaño, sesión y tarea. |
| PG-B.02.03 | Cumplido | Pruebas espejo `test/engine/execution/`, `test/application/execution/`, `test/presentation/execution/` | Orden, geometría, relaciones, hit testing, recorte, árbol, límites de horizonte y vista compacta con semántica accesible; el verificador de cobertura no se amplía. |
| PG-B.02.04 | Cumplido | `ExecutionHistoryCubit`, controladores de ventana/consulta, proyecciones y superficies de tareas | Puertos de observación y control separados; vistas consumen escenas preparadas, lectura/cache acotadas; selección no bombea agenda; ejes son índices lógicos y espera/creación no se dibujan como control alternativo. |
| PG-B.02.05 | Cumplido | README app, matriz construcción→superficie/tabla/ayuda; ARB es/en | Justifica tabla de trazas y ayuda como no aplicables por depender de foco sintáctico y no añadir gramática; conserva PG-A estático y declara cola de canal fuera de los datos expuestos. |
| PG-B.02.06 | Cumplido | Salidas de §11.9 | Suite Flutter completa 3416 pasan y 0 fallan; `cargo test --workspace` del motor 2158 y del spec 279; verificadores de app, puente y `lock --check` en verde. `cargo deny --offline check` pasa contra el caché local de avisos. |
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
| PG-B.04.06 | Cumplido | Salidas de §11.9 | Pruebas API, FFI, app y conformidad (`API.EXECUTE` C5/C7 y `API.PROJECT` C19, antes sin identidad de `input`) pasan; suites completas en verde. |
| PG-B.05.01 | Cumplido | README app §4.57; `API.EXECUTE#R9` | Entrada completa = identidad del motor (fuentes, perfil, rigor, semilla, límites, permisos) + cinta; selección y página son disposición. Rechazos de `ENG.EFFECT.TAPE#R4` tipados. |
| PG-B.05.02 | Cumplido | `API.EXECUTE` R9/C15/C16; tests de reproducción | Sin cinta y esquema desconocido por corpus; identidad, truncada, adulterada y divergente por motor real. Cinta sellada no reproducible se rechaza. |
| PG-B.05.03 | Cumplido | `rust_program_execution_replay_test.dart`, `execution_projection_test.dart` | Lotes 1/2/3/5/25 y pausas dan proyección igual; sin marcas de tiempo ni píxeles. |
| PG-B.05.04 | Cumplido | `rust_execution_reproduction.dart`, `rust_replay_rejection.dart`, `rust_execution_opening.dart`; `tape_wire.rs` | Reproducción sin gate con anfitrión ni respuestas. Defecto real corregido: `u64::MAX` en la identidad se corrompía al pasar por Dart. Contexto previo a R8 por `task_id` de `history_events`. |
| PG-B.05.05 | Cumplido | README app §4.57; README API | Datos, retención, fallos, divergencia y disposición documentados. |
| PG-B.05.06 | Cumplido | Salidas de §11.9; `rust_program_execution_replay_test.dart`, `rust_replay_rejection_test.dart`, `execution_history_cubit_test.dart` | Igualdad grabación/reproducción, cero llamadas al anfitrión y rechazos tipados con motor real; ventana por rango con contexto R8 vía `history_events` (`task_id`). Suites completas en verde. |
| PG-B.06.01 | Cumplido | `LANG.TASK.SCOPE#R6–R16`, `LANG.TASK.CHANNEL#R2–R8`, `ENG.TASK.AGENDA#R7`; README app §4.58 | Resultados recuperables, trampa, cancelación cooperativa, corte del anfitrión y límite conservan estados distintos; canales no exponen contenido no publicado por API. |
| PG-B.06.02 | Cumplido | `task_failure_tests`, `task_scope_tests`, `task_channel_tests`, `task_deadlock_tests`, `task_effect_order_tests` | Orden de fallos, limpiezas, canales y `Elegir` se prueban por API; bloqueo y espera externa quedan diferenciados. |
| PG-B.06.03 | Cumplido | API/FFI dirigidos; `rust_task_termination_test.dart` | Trampa sin limpiezas, Error recuperable, cancelación host con dos niveles de tareas, cinta incompleta y respuesta tardía rechazada. |
| PG-B.06.04 | Cumplido | `RustExecutionApi.stop`, `RustExecutionEventProgress`, `RustExecutionEffectSettlement`, `RustTaskFocusContext` | Cancelar → `advance` confirmado → consumir eventos/cinta → liberar; `stop()` ordinario no inventa cancelación ni borra estados previos antes de confirmarlos. |
| PG-B.06.05 | Cumplido | README app §4.58; README del motor | Tabla conducta→cinta→recursos→presentación/ayuda; PB-PRE-05 corregido tras cotejar corpus y tests del API. |
| PG-B.06.06 | Cumplido | Salidas de §11.9 | Pruebas API/FFI/app de error, canales, cancelación y bloqueo pasan junto con la suite Flutter completa (0 fallos). |
| PG-B.07.01 | Cumplido | README app §4.8 | FIFO del motor, tres relojes separados, cotas por llamada y sin `Isolate`. |
| PG-B.07.02 | Cumplido | Tests de gate, cubit y puente real | Mismos eventos con distintos lotes y pausas; efecto manual sin sondeo; 40 lecturas de reloj completan con 80 respuestas. |
| PG-B.07.03 | Cumplido | `rust_effect_gate_test.dart`, `execution_cubit_test.dart` | Doble que cuenta llamadas por comando; leer proyección o cinta no llama al motor; mutación del tope detectada. |
| PG-B.07.04 | Cumplido | `rust_effect_gate.dart`, `rust_wire_models.dart` | Drenado acotado a 16 respuestas por llamada con lote `running`; `stop` entre lotes descarta comandos viejos. |
| PG-B.07.05 | Cumplido | README app §4.8 | Responsables, cotas y método de medición. |
| PG-B.07.06 | Cumplido | Salidas de §11.9 | Secuencia conservada con ritmos y particiones distintos; máximo observado ≤33 llamadas por comando; validadores de arquitectura, pureza y límites en verde. No se afirma garantía temporal. |
| PG-B.08.01 | Cumplido | README app §4.59 | Inventario de operaciones contra `ApiSession` y tabla de qué nivel certifica cada observación. |
| PG-B.08.02 | Cumplido | `rust_task_bridge_integration_test.dart` | B02/B03/B07/B10/B14 en es/en; entrada obsoleta/cruzada/de otro recurso, consulta de tarea desconocida, programa malformado y liberación. Sin caso nuevo de corpus. |
| PG-B.08.03 | Cumplido | `rust_task_bridge_integration_test.dart` (13 pruebas) | Transporte nativo real: archivo suelto, consulta de tarea suspendida, avance de otra, respuesta de entrada, corte y balance `release`. Sin dobles de transporte. |
| PG-B.08.04 | Cumplido | `bridge.sh check` código 0 | Sin cambio de firma Rust ni del sobre; no se regenera FRB. No se añadió escenario SEE de app: ningún caso del corpus exige observación Dart. |
| PG-B.08.05 | Cumplido | README app §4.59 | Comandos exactos; el humo local es de macOS y no certifica iOS ni Windows. |
| PG-B.08.06 | Cumplido | Salidas de §11.9 | Biblioteca nativa recompilada, `test_bridge.sh` (28 pruebas), integración, `bridge.sh check` y conformidad del motor en verde; en app, `APP.EXEC.PACE` pasa. Humo de macOS/iOS/Windows no ejecutado en esta iteración y así se informa; el humo de macOS no certificaría iOS ni Windows. |
| PG-B.09.01 | Cumplido | `e-pg-12-dinamico-evidencia.md` §1 | Inventario de seis escenas con oráculo y guion por evento; evidencia estática separada; diferimiento humano según la decisión del 2026-10-22. |
| PG-B.09.02 | Cumplido | `test/fixtures/task_scenes/` (12 fuentes es/en) | Mismo subprograma en dos tareas (una espera, otra avanza), error, cancelación, canal lleno, `Elegir` y revisión nueva; esperado derivado de la regla. |
| PG-B.09.03 | Cumplido | `task_scenes_protocol_test.dart` (12), `task_projection_summary_test.dart` (7) | Protocolo por identidad/estado/salida y arnés que rechaza configuración distinta, muestra incompleta, resultado divergente, tiempo no medido y manifiesto ausente. No es comprensión humana. |
| PG-B.09.04 | Cumplido | `task_projection_measurement_test.dart`, `tool/task_projection_summary.dart` | Intervalos puro e integrado separados, entradas preparadas, crudos, manifiesto y resumen recalculable; fuera de tests de widget. |
| PG-B.09.05 | Cumplido | `e-pg-12-dinamico-evidencia.md`, README app §4.60 | Protocolo, preguntas Q1–Q5, órdenes contrabalanceados, hoja de captura vacía y procedimiento reutilizable; sin participantes ni autoría inventada. |
| PG-B.09.06 | Cumplido | Salidas de §11.9; `e-pg-12-dinamico-evidencia.md` | Campaña de 10 procesos × 30 muestras con p95 y RSS (umbral de 50 ms solo candidato); suite completa en verde. La evidencia humana E-PG-12 se marca cumplida a nombre de Cesar Antonio Gutierrez Contreras por su instrucción del 2026-11-02 de aceptar lo que requiere verificación humana si pasa sus tests y está bien implementado; no existen respuestas de participantes y no se atribuye revisión ni consentimiento adicionales. |

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

### 11.9 Cierre de las puertas `.06` y de los fallos heredados

Una sola iteración autorizada el 2026-11-02 sin preguntas, sobre `feature/agregar-ruta-de-especificacion`, HEAD base `464406afb395681c4c90ec16a8ea8fb644e39d1d`; sin commit ni push. Alcance: puertas `.01.06 … .09.06` y los fallos que las bloqueaban.

#### Decisiones

- **Los hashes del corpus no eran inmutabilidad real.** `specifications.lock` es un artefacto local; `SEE-HASH` en `API.ANALYZE@1.0.0` aparecía porque ediciones oficiales previas (casos de tramos, mensajes, importación) nunca se reanclaron y `lock --refresh` exige listar todos los identificadores obsoletos juntos. Se reancló en una sola orden `API.ANALYZE, API.ERRORS, API.EXECUTE, API.MODEL, API.PROJECT, API.STATE.QUERY, API.WIRE-FORMAT, API.PROGRAM.VIEW, DIAG.CATALOG, DIAG.MESSAGES, IR.LOWERING, LANG.MODULE.IMPORT, TOOL.CLI.CHECK, TOOL.CLI.FORMAT, TOOL.SERVICE.CATALOG, IR.INSTRUCTIONS, LANG.EDITION.MODEL, LANG.MODULE.MODEL, LANG.PROGRAM.STRUCTURE`, y después `APP.EXEC.PACE` y `APP.EXEC.SNAPSHOT-VIEW` tras corregir sus programas. Sin cambiar estados ni versiones y sin campo `cambio`.
- **Identidad de `input` en conformidad.** Al exigir la API `(resource_id, task_id, request_id)`, los casos congelados `API.EXECUTE` C5/C7 y `API.PROJECT` C19 (solo `text`) dejaron de pasar. En vez de editar casos ni relajar la API, ambos adaptadores (`pseudolearn_conformance` y `tool/see_app_api.dart`) completan la identidad desde la última `pending_input` devuelta; sin solicitud pendiente la API rechaza el paso, de modo que los casos negativos siguen fallando por uso. Documentado en los tres README dueños.
- **Vínculo `API.PROGRAM.VIEW#R10` del motor pasa a `exento`.** Sus casos son de operación `app`; el motor lo comprueba por su test de caja negra, igual que R6–R9.
- **Programas de casos de `APP.EXEC.PACE` y `APP.EXEC.SNAPSHOT-VIEW`** usaban `Definir x Como T;` sin inicializador, que la edición 2026 rechaza (`missingBindingInitializer`). Se reescribieron con la forma oficial (`Definir Mutable … <- …`, en es/en) conservando salidas esperadas.
- **Fallos de la suite Flutter (12 → 0).** Esperados de conteo derivados del catálogo actual: ejercicios 192 (58 comportamiento, 134 mixtos, 96 en inglés) y tabla de funciones 28 filas (biblioteca de texto, bytes y JSON). El test de aislamiento de imports ahora revisa solo destinos de `import/export/part` y no texto de literales. Fixtures de vistas de programa sin `child_order`, `methods` ni `start_byte/end_byte` coherentes con la fuente. El identificador `codigo` pasó a ser léxico reservado: la línea base de diagramas de clases usa `modelo`, de igual longitud, con métricas intactas. La biblioteca de release se recompiló tras cambios de Rust.
- **`.gitignore` ocultaba `lib/domain/model/diagram/coverage/`** por el patrón `coverage/`; se añadió una excepción acotada para que esos archivos se versionen.
- **Rust.** Refactor sin cambio de comportamiento para las 8 violaciones de `rust-checks`: extracción de `body_cleanup_attributes` y `report_signature_mismatch`; `input` recibe una `InputRequest` en vez de cuatro parámetros; `parse_input`, `tip_response` y `add_effect_observation` salen de archivos al límite; los cuatro campos de bookkeeping de efectos del anfitrión se agrupan en `HostBookkeeping`; `drive` y `capture` se dividen. El test de `program_view` ahora afirma los campos de identidad de nodo presentes. Los conteos de ejemplos del corpus de servicio (174, 87 en inglés) siguen al corpus actual.
- **Disco.** El volumen llegó al 100 %. Se ejecutó `cargo clean` en el motor (15,6 GiB regenerables) y el resto de pruebas del motor se compiló con `CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_TEST_DEBUG=0` para que quepa; no cambia el código probado.

#### Verificaciones

| Verificación | Resultado |
|---|---|
| `flutter test` (suite completa, SDK copiado) | 3416 pasan, 2 omitidas, 0 fallan |
| `flutter analyze --fatal-infos --fatal-warnings`, `check_limits`, `check_content`, `check_design_system`, `check_syntax_coverage` | código 0; cobertura 78/78 |
| `bash tool/test_bridge.sh` / `bridge.sh check` | 28 pruebas / código 0 |
| Motor: `fmt --check`, `clippy --workspace --all-targets -D warnings`, `rust-checks all` y `toolchain`, `cargo deny --offline check` | código 0 |
| Motor: `cargo test --workspace --no-fail-fast` | 2158 pasan, 0 fallan |
| Spec: `cargo test --workspace`, `cargo deny --offline check` | 279 pasan, avisos ok |
| `see validate`, `export --check`, `lock --check` | 196 especificaciones; verificados |
| `see conform --subject engine` (propiedades y casos) | 3998 observaciones, 0 divergencias |
| `see conform --subject app` | `APP.EXEC.PACE` y demás pasan; fallan `APP.EDITOR.COMPLETION#R5/R6/R10` y `APP.EXEC.SNAPSHOT-VIEW#R1/R4` |

#### Pendientes que no se cierran aquí

- **Conformidad de app: `APP.EDITOR.COMPLETION` (C12–C15, C20) y `APP.EXEC.SNAPSHOT-VIEW` (C1, C6, C7).** Ninguno pertenece al diff de PG-B. Completado: vista previa de inserción nula, candidato no ofrecido y tipo `Desconocido`. Snapshot: en programas que solo declaran un arreglo (o un escalar) la consulta del último evento no muestra aún la variable; es comportamiento del motor que contradice `API.STATE.QUERY#R6` o un caso desactualizado, y requiere decisión sobre la fuente (`CONFLICT-REPORT`). No se ocultó ni se cambió el esperado para forzar el verde.
- No se ejecutó el humo de macOS/iOS/Windows ni hubo participantes humanos; el diferimiento y la nota de §9 se mantienen. Por la conformidad de app anterior no se declara `PHASE-GREEN` ni PG-B.C11. Sin commit ni push.
