# Lenguaje completo sin simulación en todas las plataformas — análisis de viabilidad y plan

## 0. Metadatos

- Fecha: 2026-11-02, America/Lima.
- Rama: `feature/agregar-ruta-de-especificacion`; HEAD inspeccionado `194bd9ce`. El árbol tenía cambios ajenos en
  `apps/pseudolearn_vscode/examples/project/app/main.pseudo` y `apps/pseudolearn_vscode/media/pseudolearn.tmLanguage.json`;
  no se tocaron.
- Encargo: análisis y planificación. Este documento **no modifica** código, especificaciones, README ni el
  [plan general](plan-ejecucion-proposito-general.md); propone cómo reformular sus dos últimas fases. No autoriza
  ninguna fase (`PHASE-STOP`).
- Documento transitorio de `docs/`: nada fuera de `docs/` puede citarlo (`DOC-NO-TRANSIENT-REFS`). Las decisiones que
  se aprueben se trasladan a corpus y README en el mismo cambio que las implemente.
- Convención: **[O]** = observado en el repositorio (con ruta); **[I]** = inferido o conocimiento de plataforma no
  comprobado aquí; **[V]** = comprobado durante este análisis con una orden ejecutada.

### 0.1 Postura del dueño que este documento toma como requisito

Recogida del encargo y resumida en requisitos verificables:

| ID | Requisito |
|---|---|
| RQ-1 | Nada viene bloqueado por defecto en ninguna plataforma: ni red, ni archivos, ni reloj, ni temporizadores, ni argumentos. No hay pasos de desbloqueo ni concesiones. |
| RQ-2 | El archivo único de la app solo pierde los imports (no hay carpetas de las que importar). Nada más. |
| RQ-3 | Cero simulación en producto: ninguna respuesta preparada, archivo virtual, reloj lógico ni escenario. |
| RQ-4 | El 100 % del lenguaje desbloqueado en todas las plataformas donde el lenguaje está disponible. |
| RQ-5 | Lo que esta decisión deja muerto se elimina de raíz del monorepo. |
| RQ-6 | Aceptación: en la app, un archivo único que consulta una API pública (p. ej. Rick y Morty) muestra la respuesta real en la consola, sin configurar ni conceder nada; lo mismo en el resto de plataformas. |
| RQ-7 | (2026-11-02, segunda instrucción) El objetivo es sacar a producción un lenguaje completo y de propósito general. Está prohibido que se sienta como prueba de concepto: toda característica debe ser totalmente usable. Lo que esté sin terminar, mockeado, simulado, sin especificar o diferido pese a ser necesario entra en una fase como punto, o en una fase nueva según su complejidad. |

### 0.2 Decisiones del dueño registradas

El 2026-11-02 el dueño aceptó todas las recomendaciones de §A.6: D-01 (a), **D-02 (b)** (crate Rust compartido),
D-03 (a), D-04 (a), D-05, D-06 (a), D-07 (a), D-08 (a), **D-09 (a)** (compilador nativo completo, en una fase), D-10 (a),
D-11 (b), D-13 (a) y D-14. **D-12 queda sustituida por RQ-7**: las características ausentes se clasifican en §A.8 y las
necesarias para un lenguaje de propósito general entran en fases (§B.3a–§B.3c). Las decisiones nuevas D-15 a D-19 de
§A.8.3 también fueron aceptadas por el dueño el 2026-11-02 con la opción recomendada: enlazador incluido (D-15), y
fuera de este plan clases abstractas, miembros estáticos y visibilidad protegida (D-16), excepciones (D-17), servidor
HTTP, sockets, procesos hijos y FFI (D-18) y registro público de paquetes (D-19).

## 1. Resumen ejecutivo

**Veredicto: viable, con límites reales y acotados de tres plataformas que no dependen de PseudoLearn.** El criterio de
aceptación RQ-6 (HTTPS a una API pública desde un archivo único) es alcanzable en macOS, iOS, Windows, la CLI, la
extensión de escritorio y la extensión web. Lo que no se puede garantizar, y debe quedar documentado y presentado como
error tipado real, no como bloqueo de PseudoLearn:

1. **Navegador (extensión web en vscode.dev/github.dev):** CORS, contenido mixto, cabeceras prohibidas, redirecciones
   no observables y Private Network Access. La API de Rick y Morty sí funciona: responde `access-control-allow-origin: *`
   **[V]**. Una API sin CORS fallará en el navegador y funcionará en las demás plataformas.
2. **iOS:** HTTP sin TLS lo bloquea la plataforma y la política de red de Flutter salvo excepción ATS declarada por la
   app; el acceso a la red local dispara un aviso del sistema que no se puede suprimir; el sistema de archivos se limita
   al contenedor de la app. Riesgo de revisión de la App Store (guía 2.5.2).
3. **macOS (sandbox de Mac App Store):** archivos fuera del contenedor denegados por el sistema; aviso de red local del
   sistema en macOS 15 o superior **[I]**.

Además, el análisis encontró que la «simulación» no está solo en la app: **los anfitriones llamados físicos también
simulan** (reloj congelado tras la primera lectura, temporizador que no espera, argumentos siempre vacíos, semilla
aleatoria fija 42, archivos de la extensión web en memoria temporal). El plan los trata como simulación (RQ-3).

La auditoría de completitud de §A.8 (RQ-7) añade tres fases: **PG-L** (construcciones del lenguaje que hoy se
rechazan), **PG-S** (biblioteca estándar básica que falta) y **PG-N** (compilador nativo completo). El orden es
PG-B → PG-L → PG-S → PG-N → PG-7.

El cambio contradice reglas estables del corpus (`LANG.CAPABILITY.MODEL#R2`, `RT.HOST.INTERFACE#R1/R7/R9`,
`LIB.HTTP.POLICY`, `LIB.TIME`), README de cinco miembros y decisiones de la hoja de ruta (R-09, ADR-02, ADR-12). Por
`CONFLICT-REPORT` se listan en §A.5; la instrucción directa del dueño tiene precedencia (AGENTS.md §3), pero el
tratamiento concreto de cada choque requiere sus decisiones de §A.6.

---

# Parte A · Análisis

## A.1 Dónde está disponible el lenguaje hoy

| Superficie | Plataformas reales hoy | Cómo ejecuta | Evidencia |
|---|---|---|---|
| App Flutter | macOS 13+ (arm64/x86_64), iOS 16+, Windows 10/11 x64 | Puente FRB a `pseudolearn_api`; efectos atendidos en Dart | **[O]** `apps/pseudolearn_app/README.md` §2.1 y §4.50; carpetas `ios/`, `macos/`, `windows/` |
| App web | **No existe** (declarada «secundaria», sin carpeta `web/`) | — | **[O]** README app §2.1 y §1.5 «Andamiaje de la plataforma web: Abierto» |
| App Android/Linux | No existen; Android fuera de alcance explícito | — | **[O]** README app §4.50 |
| CLI `pseudo` | macOS arm64 empaquetada en el VSIX; compilable en otros destinos **[I]** | VM o AOT (`--nativo`); anfitrión físico Rust | **[O]** `apps/pseudolearn_cli/README.md`, `apps/pseudolearn_vscode/artifact.contract.json` |
| Extensión VS Code escritorio | Solo `darwin-arm64` | Lanza `pseudo run --editor` y `pseudo dap` | **[O]** `artifact.contract.json`, `apps/pseudolearn_vscode/src/application/run_arguments.ts` |
| Extensión VS Code web | Navegadores (Chromium y WebKit aprobados; Firefox no evaluado) | Wasm en Workers; Fetch del navegador | **[O]** README extensión §11–§12, plan PG-6B |
| Sitio `fe-pseudolearn` | — | **No ejecuta el lenguaje** | **[O]** `apps/fe-pseudolearn/README.md` «Sin ejecución del lenguaje en el navegador» |
| Backend Supabase | — | No ejecuta el lenguaje | **[O]** `apps/pseudolearn_backend/README.md` §1.1 |

**Conflicto con el encargo (`CONFLICT-REPORT`, CF-N01):** el encargo cita «web» como plataforma de la app. La app no
tiene variante web. El lenguaje sí corre en web a través de la extensión. Este plan cubre la extensión web y deja la
creación de una app Flutter web como decisión D-11.

## A.2 Estado actual: dónde se limita, deniega, simula o condiciona

### A.2.1 Corpus de especificaciones (`packages/pseudolearn_spec/specifications/`)

Todas las reglas citadas están en estado `estable`, versión `1.0.0`, bajo congelamiento **[O]**.

| Regla | Qué impone hoy | Choca con |
|---|---|---|
| `LANG.CAPABILITY.MODEL#R2` | «Rige la denegación por defecto: un programa no posee autoridad ambiental implícita»; capacidades pedidas en manifiesto o concedidas por el anfitrión, por intersección | RQ-1, RQ-2 |
| `LANG.CAPABILITY.MODEL#R3` | Rechaza `..` y rutas absolutas en directorios; `Limitar` solo dentro de orígenes concedidos | RQ-1 (rutas); la atenuación voluntaria no choca |
| `RT.HOST.INTERFACE#R1` | Reloj, archivos y red requieren concesión explícita del anfitrión | RQ-1 |
| `RT.HOST.INTERFACE#R3` | Semilla por omisión 42: misma secuencia de `Azar` en cada ejecución | RQ-3 (aleatoriedad simulada) |
| `RT.HOST.INTERFACE#R6` | Define el anfitrión de memoria con respuestas HTTP declaradas | RQ-3 si llega a producto; es el oráculo del corpus |
| `RT.HOST.INTERFACE#R7` | `RedCap` solo con permiso y limitada a orígenes declarados | RQ-1 |
| `RT.HOST.INTERFACE#R8` y `LIB.HTTP.POLICY#R2` | No seguir redirecciones, sin cookies ni proxies ambientales, TLS siempre validado | Compatible salvo en navegador (ver §A.4) |
| `RT.HOST.INTERFACE#R9` y `LIB.HTTP.POLICY#R4` | Deniega loopback, RFC 1918, enlace local, ULA, multidifusión; loopback solo con concesión de prueba | RQ-1 |
| `LIB.HTTP.POLICY#R1` | `http` solo para un origen local concedido para pruebas | RQ-1 |
| `LIB.HTTP.POLICY#R3` | Rechaza el descenso HTTPS→HTTP en `Redirigida` (`RedireccionDenegada`) | RQ-1 (lo decide el programa) |
| `LIB.HTTP#R1` | `SolicitarRed` exige permiso `red`; la capacidad solo contiene orígenes concedidos | RQ-1 |
| `LIB.HTTP#R3` | `Enviar` exige origen concedido; rechaza cabeceras `cookie`, `proxy-*`, etc. | RQ-1 (origen); cabeceras: D-06 |
| `LIB.TIME#R1/R2` | Reloj e instantes **lógicos**; el temporizador avanza tiempo lógico | RQ-3 en modo vivo; en reproducción es correcto |
| `API.PROJECT.MANIFEST` (resolución de `requests`/`grants.permissions`) | Permisos pedidos por manifiesto e intersección con concesión del anfitrión | RQ-1; queda muerto si no hay concesiones |
| `API.EXECUTE`, `ENG.EFFECT.TAPE`, `ENG.EXEC.EFFECT-*`, `ENG.TASK.AGENDA`, `LANG.TASK.*`, `LIB.IO`, `LIB.SCENARIO.*`, `ENG.LIMITS`, `LANG.CONTROL.CLEANUP` | Casos cuyo bloque `anfitrion` declara `permissions`/`requested_permissions`/`network_origins`; algunos esperan `permiso_denegado` o `destino_denegado` por falta de concesión | Sus casos dependen de la concesión; hay que rederivarlos |
| `TOOL.SERVICE.CATALOG` | Fichas: «autoridad explícita concedida por el anfitrión», «si el permiso está activo» | RQ-1 (texto de ayuda) |

Recuento de casos con bloque `permissions` por especificación **[V]** (`grep`): `LIB.HTTP` 28, `LIB.IO` 18,
`ENG.EFFECT.TAPE` 15, `LANG.CAPABILITY.MODEL` 11, `ENG.EXEC.EFFECT-COMMIT` 10, `LIB.HTTP.POLICY` 8,
`LIB.SCENARIO.HTTP-TASKS` 7, `RT.HOST.INTERFACE` 6, `API.EXECUTE` 6, `LIB.TIME` 5, `LIB.SCENARIO.FILE-JSON` 5,
`LANG.TASK.SCOPE` 4, `ENG.EXEC.MODEL` 4, `ENG.EXEC.EFFECT-ORDER` 4, `ENG.TASK.AGENDA` 3, y 1–2 en otras ocho.
`export.json` es generado (`GEN-NO-HAND-COPY`) y se regenera.

### A.2.2 Motor, runtime y API (`packages/pseudolearn_engine/`)

- **[O]** `crates/pseudolearn_api/src/execution_setup.rs`: toda ejecución recibe `host: crate::FakeHostProvider` y
  `configure_host_authority` aplica la autoridad declarada en la petición; `detached: true` hace que un consumidor
  (CLI, app, Worker) atienda los efectos. **La API no tiene anfitrión real**: o atiende un falso de memoria, o delega.
- **[O]** `crates/pseudolearn_api/README.md`: «`FakeHostProvider` provee un árbol virtual en memoria con archivos,
  argumentos y reloj lógico»; usa el mapa `http` del anfitrión de memoria.
- **[O]** `crates/pseudolearn_runtime/src/`: `memory_host.rs`, `memory_host_config.rs`, `memory_host_files.rs`,
  `local_http_effect.rs`, `effect_authority.rs`, `capability_table.rs`, `host_validation.rs`; siete archivos del
  runtime y nueve de la API manejan `network_origins`/`requested_permissions`/`local_origins` **[V]**.
- **[O]** `packages/pseudolearn_engine/README.md` «Cliente HTTP/HTTPS del motor»: autorización por origen, rechazo del
  descenso HTTPS→HTTP; «La API no añade conexiones reales».
- **[O]** Familias de capacidad cerradas en `crates/pseudolearn_abi/src/effect_operation.rs`: `filesystem`, `clock`,
  `console`, `arguments`, `timer`, `network`. No hay más E/S en el lenguaje; variables de entorno, procesos, sockets,
  servidor HTTP y FFI **no existen** (hoja de ruta: FUT-xx). No son bloqueos sino ausencias de característica (D-12).
- **[O]** AOT: `nativeTasksUnsupported` rechaza tareas en `build` y `run --native`; README CLI: «`--native` con `red`
  falla como error de uso: el runtime AOT no abre sockets».

### A.2.3 App Flutter (`apps/pseudolearn_app/`)

- **[O]** README §4.54: «la app no abre autoridad real; ofrece capacidades simuladas en memoria». Siete escenarios
  (`lib/domain/model/execution/simulated_scenario.dart`): sin anfitrión, sin permisos, archivos virtuales, HTTP preparado
  (`https://example.test/greeting` → «hola»), tiempo lógico, timeout simulado, resultado incierto.
- **[O]** Código de simulación: `lib/domain/model/execution/{simulated_capabilities,simulated_scenario}.dart`;
  `lib/engine/rust/{rust_simulated_host,rust_simulated_files,rust_simulated_http}.dart`;
  `lib/presentation/document/components/simulated_scenario_{panel,panel_content,selector,help_button}.dart`; uso en
  `document_footer.dart`, `execution_cubit.dart`, `execution_state.dart`, `ports/program_execution.dart`,
  `rust_effect_gate.dart`, `rust_program_execution.dart`, `rust_replay_host.dart`.
- **[O]** Localización: claves `simulatedScenario*` en `lib/presentation/l10n/app_es.arb` y `app_en.arb` («Simulado»,
  «HTTP preparado», «Timeout simulado»…) y sus generados.
- **[O]** Pruebas: `test/engine/rust/rust_simulated_{host,files,http}_test.dart`,
  `test/presentation/document/components/simulated_scenario_panel_test.dart` y usos en `execution_cubit_test.dart`,
  `step_batch_runner_test.dart`, `rust_effect_gate_test.dart`, `rust_program_execution_replay_test.dart`,
  `rust_task_bridge_integration_test.dart`, `rust_task_termination_test.dart`, `task_scene_runner.dart`,
  `test/fakes/fake_program_execution.dart`, `tool/native_bridge_adapters_test.dart`.
- **[O]** `architecture.yaml`: la capa `engine` prohíbe `dart:io`; `data` lo permite. No existe capa para un anfitrión
  de E/S real.
- **[O]** Puente `native/Cargo.toml`: solo `pseudolearn_api` sin la característica `native`, sin red ni TLS.
- **[O]** Plataforma: `macos/Runner/Release.entitlements` ya declara `com.apple.security.network.client` y sandbox (por
  Supabase); `ios/Runner/Info.plist` no declara ATS ni `NSLocalNetworkUsageDescription`; `pubspec.yaml` `msix_config`
  declara `capabilities: internetClient`.
- **[O]** README §1.3 y §4.54 condicionan además: «la vista pública todavía no presenta los valores configurados del
  escenario»; pendiente declarado.
- RQ-2 **[O]**: el modo de archivo único (PG-A.01) ya solo quita manifiesto e imports; el resto del bloqueo viene de los
  efectos simulados.

### A.2.4 CLI (`apps/pseudolearn_cli/`)

- **[O]** README: «Sin `--conceder` el comportamiento no cambia y toda capacidad se deniega». Concesiones `--conceder`/
  `--grant`, `--archivos`/`--files`, `--origen`/`--origin` (HTTPS exacto), `--origen-local`/`--local-origin` (HTTP solo
  loopback), `--raiz-prueba`/`--test-root`.
- **[O]** `physical_network_address.rs`, `physical_network_resolver.rs`: deniega rangos locales, privados y especiales.
- **[O]** `src/physical_host.rs`: `arguments_values` devuelve siempre `[]`; `clock_now` lee el sistema **solo la
  primera vez** y luego congela `logical_nanos`; `timer_wait` suma la duración **sin esperar**. Son simulación dentro del
  anfitrión «físico».
- **[O]** Archivos: una sola raíz `--archivos` vía `cap-std`; rutas relativas sin `..`.
- **[O]** Editor (`run --editor`): «no se concede ningún archivo ni red»; DAP: «La configuración no recibe permisos».
- **[O]** Pruebas atadas a la política: `network_address_policy_tests.rs`, `tests/network_vector_registry.rs`,
  `tests/network_security_vectors.rs`, pruebas de `--conceder` en `physical_host_tests.rs`, `confined_sources_tests.rs`
  (este último es lectura de proyecto, no del programa: se conserva).

### A.2.5 Extensión de escritorio (`apps/pseudolearn_vscode/`, ruta Node)

- **[O]** `src/application/run_arguments.ts`: `run --editor` sin concesiones. README: «No se concede ningún archivo ni
  red».
- **[O]** `src/application/debug_configuration.ts`: rechaza en `launch.json` las claves `grants`, `permissions`,
  `origins`, `filesRoot`, `env`, `args`.
- **[O]** `package.json` `capabilities.untrustedWorkspaces: limited`: ejecutar exige workspace confiable. Es la
  Confianza de Workspace de VS Code, propia de la plataforma (§A.4).
- **[O]** Solo existe el destino `darwin-arm64`; Windows y Linux no tienen VSIX.

### A.2.6 Extensión web y adaptador Fetch

- **[O]** `src/adapters/browser_commands.ts`: comandos `pseudolearn.grantNetwork` (origen exacto por gesto) y
  `pseudolearn.grantFiles` (raíz `scratchRoot` en memoria). Texto: «HTTP requires an explicit origin».
- **[O]** `src/adapters/browser_effect_host.ts`: sin orígenes concedidos, `request_network` falla; `network_send` pasa
  `allowedOrigins`. Toda operación que no es de red cae en `BrowserFileHost`, que no tiene ramas para reloj,
  temporizador ni argumentos **[O]**; deducido **[I]**: esas capacidades fallan en web.
- **[O]** README §11: archivos «temporal (1 MiB por archivo, 8 MiB total), sin symlinks ni persistencia» —archivos
  simulados—; «Ausencias: Sin DAP web, AOT, FFI, procesos».
- **[O]** `packages/pseudolearn_engine/crates/pseudolearn_wasm/browser/fetch_host.mjs`: `performFetch` con
  `allowedOrigins`.
- **[O]** Medición web: «HTTP simulado (el adaptador Fetch canónico con un `fetch` virtual, sin red)» en
  `scripts/lib/web-workloads.mjs`. Es banco de rendimiento, no producto (D-01).

### A.2.7 Documentación transitoria (`docs/`)

- **[O]** Hoja de ruta: R-09 «Denegación por defecto»; R-13 «Sin permisos implícitos»; C-07 «temporizadores lógicos»;
  C-08 «permiso denegado»; ADR-02; ADR-12 «Efectos en la app… escenarios deterministas… Se rotulan como simulados»;
  K-07, E-PG-09, tabla STRIDE (SSRF).
- **[O]** Plan general: PG-3.03 «denegación por defecto», PG-5.04 «política contra SSRF», PG-6B.05 «capacidades web
  explícitas», PG-B.04 «escenarios de efectos simulados», PG-B «Fuera de alcance: E/S real sin concesión del host».
- **[O]** Plan PG-B: D-PGB-10 «HTTP real; respuestas de escenario → extender host de memoria… cero DNS/sockets».

## A.3 Simulación encubierta (hallazgos que el dueño quizás no espera)

| Hallazgo | Dónde | Por qué es simulación |
|---|---|---|
| Reloj congelado | `apps/pseudolearn_cli/src/physical_host.rs` `clock_now` | Todas las lecturas tras la primera devuelven el mismo instante más lo «dormido» |
| Temporizador que no espera | mismo archivo, `timer_wait` | `Esperar 5 s` termina al instante |
| Argumentos vacíos | mismo archivo, `arguments_values` | El programa nunca recibe argumentos reales |
| Semilla fija | `RT.HOST.INTERFACE#R3` | `Azar` da la misma secuencia en cada ejecución |
| Archivos en memoria en web | `browser_scratch_files.ts` | No son los archivos del workspace ni persisten |
| Reloj/temporizador lógicos normativos | `LIB.TIME#R1/R2` | La regla los define lógicos incluso en vivo |

La reproducción desde cinta, el historial y `stepBack` **no** son simulación: reproducen una ejecución real grabada sin
repetir efectos (`PG-3.05`, `PG-6B.03`). Se conservan.

## A.4 Veredicto por plataforma

| Plataforma | Viable RQ-6 | Límite real de la plataforma (no eliminable por PseudoLearn) | Queda desbloqueado | No queda desbloqueado |
|---|---|---|---|---|
| CLI (macOS; Windows/Linux al compilar) | Sí | Ninguno relevante | Todo: red a cualquier destino, archivos del usuario con permisos del SO, reloj y temporizador reales, argumentos | — |
| Extensión escritorio | Sí | Confianza de Workspace de VS Code: un workspace no confiable no ejecuta código de extensiones | Lo mismo que la CLI | Ejecutar en Restricted Mode (decisión de VS Code, igual para cualquier extensión de lenguaje) |
| App macOS (Mac App Store, sandbox) | Sí **[I: no ejecutado]** | Sandbox: archivos solo en el contenedor (y en lo que el usuario abra por diálogo); aviso de red local del sistema en macOS 15+ para LAN **[I]** | HTTP/HTTPS a Internet y loopback; reloj, temporizador; archivos en una carpeta de trabajo real del contenedor | Rutas absolutas fuera del contenedor: el SO devuelve `PermisoDenegado` real |
| App iOS | Sí para HTTPS **[I: no ejecutado]** | ATS y la política de Flutter impiden `http://` sin TLS salvo excepción en `Info.plist` ([política de red de Flutter](https://docs.flutter.dev/release/breaking-changes/network-policy-ios-android)); aviso obligatorio de red local (`NSLocalNetworkUsageDescription`); contenedor; la app suspendida en segundo plano congela sockets | HTTPS público, loopback, archivos del contenedor, reloj y temporizador reales | `http://` si el dueño no acepta la excepción ATS (D-08); LAN sin el aviso del sistema; ejecución en segundo plano |
| App Windows | Sí **[I: no verificable aquí]** | Ninguno para salir a Internet; MSIX de confianza plena no aplica AppContainer **[I]** | Todo | — |
| Extensión web | Sí para APIs con CORS; Rick y Morty **[V]** | CORS; contenido mixto (`http://` desde `https://`, salvo `localhost`); cabeceras prohibidas (`cookie`, `host`…); `redirect: "manual"` devuelve respuesta opaca sin estado ni `location`; solo cabeceras de respuesta expuestas; Private Network Access; sin sistema de archivos del equipo fuera de `workspace.fs` | HTTP con CORS, archivos del workspace vía `workspace.fs`, reloj, temporizador, argumentos | APIs sin CORS; observar 3xx; cabeceras prohibidas; archivos fuera del workspace |
| AOT (`pseudo run --nativo`, `build`) | **No hoy** | No es límite de plataforma: falta implementación (tareas nativas y red) | — | Tareas y red hasta implementarlas (D-09) |

Consecuencia normativa en web: `RT.HOST.INTERFACE#R8` («entrega las 3xx al programa») es **imposible de cumplir** con
Fetch. La extensión web ya lo reconoce como «sin ubicación portable de redirección» (descriptor A4). El plan propone que
en navegador las redirecciones las siga el navegador y que el contrato lo declare como diferencia de plataforma
observable, nunca como bloqueo (D-07).

Riesgo de distribución iOS/macOS: la guía 2.5.2 de Apple admite código ejecutable en apps que enseñan programación si el
código es visible y editable, pero hay rechazos recientes documentados en apps educativas
([foro de desarrolladores de Apple](https://developer.apple.com/forums/thread/835555),
[MacStories, 2017](https://www.macstories.net/linked/apples-app-store-guidelines-now-allow-executable-code-in-educational-apps-and-developer-tools/)).
La red real aumenta la superficie que App Review mira. No impide implementar; sí puede retrasar la publicación.

## A.5 Conflictos con fuentes del repositorio (`CONFLICT-REPORT`)

La instrucción del dueño es la fuente de mayor autoridad (AGENTS.md §3). Aun así, cada conflicto cambia trabajo y se
reporta para que el dueño confirme el tratamiento propuesto antes de implementar.

| ID | Fuentes en conflicto | Naturaleza | Tratamiento propuesto |
|---|---|---|---|
| CF-N01 | Encargo («web» de la app) / README app §2.1 | La app no tiene web | D-11 |
| CF-N02 | RQ-1 / `LANG.CAPABILITY.MODEL#R2`, `RT.HOST.INTERFACE#R1/R7`, `LIB.HTTP#R1/R3`, `API.PROJECT.MANIFEST` | Denegación por defecto normativa | Reescribir el texto oficial en la misma identidad y versión (AGENTS.md §10) |
| CF-N03 | RQ-1 / `LIB.HTTP.POLICY#R1/R3/R4`, `RT.HOST.INTERFACE#R9` | Política SSRF y solo-HTTPS | Reescribir: cualquier destino que el SO permita (D-04) |
| CF-N04 | RQ-3 / `LIB.TIME#R1/R2`, `RT.HOST.INTERFACE#R3` | Tiempo y azar simulados | Vivo = tiempo real y semilla de entropía grabada; reproducción = cinta (D-05) |
| CF-N05 | RQ-3 / `RT.HOST.INTERFACE#R6`, corpus «no depende de Internet» (PG-5.07), `SPEC-INDEPENDENT-ORACLE` | El oráculo del corpus necesita un anfitrión determinista | D-01: doble de prueba no distribuible o eliminación total |
| CF-N06 | RQ-1 / `LANG.CAPABILITY.MODEL#R3` | Rutas absolutas y `..` prohibidos | D-03 |
| CF-N07 | `RT.HOST.INTERFACE#R8` / plataforma web | 3xx imposibles en Fetch | D-07 |
| CF-N08 | RQ-3 / README app §1.3 y §4.54, plan PG-B (D-PGB-10, PG-B.04 cumplido), hoja de ruta ADR-12 | Diseño vigente de la app basado en simulación | Retirar PG-B.04 y su implementación (§B.2) |
| CF-N09 | RQ-1 / README CLI, README extensión, README engine/API/runtime, hoja de ruta R-09, R-13, ADR-02, K-07, E-PG-09, STRIDE | Documentación de concesiones y SSRF | Reescribir en el mismo cambio (`DOC-README-TRUTH`) |
| CF-N10 | RQ-4 / AOT sin tareas ni red (`PG-4.12.04`, `CF-PG5-02`) | Un backend del lenguaje no ejecuta el 100 % | D-09 |
| CF-N11 | Anfitrión real en Rust para la app / `PERF.ARTIFACT.SIZE` (ios-arm64 ≤ 5 MiB; hoy 4 294 592 B, margen ≈ 948 KiB) | Hyper+Rustls+Tokio podrían no caber **[I: sin medir]** | Medir primero; si no cabe, el dueño decide entre revisar el presupuesto o volver a D-02a |
| CF-N13 | D-02b / README del motor («API, Wasm y puente móvil excluyen Hyper, `http`, Rustls, clientes HTTP y resolvedores DNS») y `isolation` de `packages/pseudolearn_engine/architecture.yaml` | La arquitectura vigente prohíbe red en el puente | Reescribir la decisión: el puente de la app admite `pseudolearn_host`; Wasm y API siguen sin transporte |
| CF-N12 | Casillas `[x]` de fases cerradas (PG-3.03, PG-5.04, PG-6B.05, PG-B.04) / RQ-1 | Puntos cumplidos que quedan contradichos | §B.1 |

## A.6 Decisiones que solo corresponden al dueño

| ID | Pregunta | Opciones | Recomendación |
|---|---|---|---|
| D-01 | ¿Qué hacer con el anfitrión de memoria (`FakeHostProvider`, `memory_host*`, `RT.HOST.INTERFACE#R6`) que usa el corpus como oráculo? | (a) Conservarlo solo como doble de prueba: fuera del producto, detrás de una característica de compilación de pruebas, sin nombre «simulado» ni selector, inaccesible desde app, CLI y extensión. (b) Eliminarlo y ejecutar los casos con efectos contra un servidor y un directorio reales en loopback | **(a)**. No es simulación para el alumno: es el oráculo independiente que exige `SPEC-INDEPENDENT-ORACLE`. Con (b) los casos de tiempo, fallo de red e incierto pierden determinismo. Si el dueño elige (b), el plan añade PG-7.13b |
| D-02 | ¿Dónde vive el anfitrión real de la app? | (a) Dart (`dart:io` `HttpClient`, `File`, `DateTime`, `Future.delayed`) en una capa nueva. (b) Extraer el anfitrión físico de la CLI a un crate Rust compartido (`pseudolearn_host`) y usarlo desde CLI (VM), runtime AOT y puente de la app | **(b), revisada el 2026-11-02.** La primera recomendación (a) se apoyaba en una estimación de tamaño no medida. (b) deja un solo dueño de la semántica del anfitrión para CLI, AOT y app, y con D-09a el AOT necesita red de todos modos. Condiciones: medir antes el tamaño del puente iOS con el crate (CF-N11) y que el dueño acepte, si hace falta, revisar `PERF.ARTIFACT.SIZE`; cambiar la regla `isolation` (CF-N13); raíces de confianza con un verificador de plataforma que admita iOS; hilo de trabajo Rust para la red, porque el puente FRB es síncrono. (a) queda como alternativa si la medición resulta inaceptable |
| D-03 | ¿Rutas de archivo? | (a) Rutas del sistema absolutas o relativas, `..` permitido; relativas contra una carpeta de trabajo (CLI: directorio actual; extensión: carpeta del workspace o del archivo; app: carpeta real del documento en el contenedor). La atenuación `Subdirectorio` sigue confinando lo que el programa decida. (b) Mantener raíz única sin `..` | **(a)**. Es lo que hacen Java y Python; la atenuación voluntaria se conserva como característica |
| D-04 | ¿Política de destinos HTTP? | (a) Cualquier esquema `http`/`https` y cualquier dirección (incluidas loopback y privadas). (b) Mantener la defensa SSRF | **(a)**. El programa es del usuario y corre en su equipo. Se conserva: TLS validado, sin proxies ni cookies ambientales y sin seguir redirecciones en nativo |
| D-05 | ¿Tiempo y azar? | En vivo: reloj real en cada lectura, temporizador que espera tiempo real, semilla tomada de la entropía del SO y grabada en la cinta; semilla explícita (`--semilla`) sigue disponible. En reproducción: todo de la cinta | Esa opción |
| D-06 | ¿Cabeceras que hoy rechaza `Enviar`? | (a) Rechazar solo las que gestiona el transporte (`host`, `content-length`, `transfer-encoding`, `connection`, `upgrade`, `te`, `trailer`, `keep-alive`). Permitir `cookie` y `proxy-authorization`. (b) Sin cambios | **(a)**. En navegador `cookie` sigue prohibida por la plataforma y se informa como `PeticionInvalida` con causa de plataforma |
| D-07 | ¿Redirecciones en navegador? | (a) El navegador las sigue; la respuesta lleva la URL final; el contrato declara la diferencia. (b) Error en web ante una 3xx | **(a)** |
| D-08 | ¿Excepción ATS en iOS para `http://`? | (a) `NSAllowsArbitraryLoads` con justificación para revisión. (b) Solo HTTPS en iOS, con `http://` como error tipado de plataforma | **(a)** si el dueño acepta el riesgo de revisión; si no, (b) documentado como límite de iOS. El criterio RQ-6 con HTTPS no depende de esto |
| D-09 | ¿AOT? | (a) Implementar tareas nativas y red en AOT (XL, diferido desde PG-4/PG-5). (b) Retirar AOT del monorepo de raíz (codegen, `aot_rt`, `conformance-aot.yaml`, `--nativo`, `build`) | **Decidido por el dueño el 2026-11-02: (a), en una fase.** El AOT solo existe en la CLI de escritorio: la app usa la VM y la regla `isolation` excluye codegen y `aot_rt` del puente, así que (b) no habría quitado ninguna plataforma móvil |
| D-10 | ¿VSIX y CLI para Windows (y Linux)? | (a) Añadir `win32-x64` implementado sin verificar (y `linux-x64` verificable en CI manual). (b) Solo macOS | **(a)** para `win32-x64`. Linux queda a elección |
| D-11 | ¿App Flutter web? | (a) Crear `web/` con el motor Wasm. (b) Fuera de este plan: el lenguaje en web ya está en la extensión | **(b)**: no estaba disponible hoy; crearla es una fase nueva |
| D-12 | ¿Características ausentes (variables de entorno, procesos, sockets, servidor HTTP, FFI)? | Siguen fuera: no existen en el lenguaje, no están bloqueadas | **Sustituida por RQ-7 el 2026-11-02**: ver la clasificación de §A.8 |
| D-13 | ¿Casillas de fases cerradas que la decisión contradice? | (a) No reabrir; anotar en el registro de decisiones del plan general y en el resumen de cada fase «sustituido por PG-B.xx». (b) Reabrir esas fases | **(a)** |
| D-14 | ¿Límites de recurso (salida de 1 MiB en `--editor`, `max_http_*`, combustible)? | No son bloqueos de características; se conservan con valores documentados | Conservar; revisar valores por omisión en PG-7.02 |

## A.7 Riesgos

| ID | Riesgo | Señal temprana | Mitigación |
|---|---|---|---|
| RN-1 | El alumno daña sus archivos (borrado o escritura fuera de lo previsto) | Programas de ejemplo que escriben en rutas absolutas | Carpeta de trabajo por omisión, mensajes claros de escritura; es el mismo modelo que Java |
| RN-2 | Pruebas inestables por red real | Fallos intermitentes en CI | El corpus no usa Internet (D-01a); integración solo en loopback; Internet solo en la prueba de aceptación manual |
| RN-3 | Rechazo en App Store | Rechazo 2.5.2 o ATS | Nota de revisión, ejemplos visibles; HTTPS por defecto |
| RN-4 | Divergencia entre anfitrión Rust (CLI) y Dart (app) | Mismo caso con distinto resultado | Contrato de adaptador común contra `cargo xtask http-test-server`, ejecutado por ambos |
| RN-5 | Reproducción de una cinta grabada con tiempo real | Cinta no reproducible | Ya está en `ENG.EFFECT.TAPE`; se añaden casos con reloj y semilla reales grabados |
| RN-6 | Windows sin verificar | Defecto descubierto por el usuario | Build en CI manual autorizado; pruebas unitarias de rutas Windows; rotulado «no verificado» |
| RN-7 | Tamaño del VSIX con más destinos | Supera presupuesto | Un VSIX por destino, como hoy |
| RN-8 | Borrar de más (el doble de prueba o la cinta) | Corpus sin oráculo | Inventario §B.4 revisado antes de borrar |
| RN-9 | El alcance de RQ-7 crece sin límite | Cada fase descubre más huecos | Inventario cerrado de §A.8; un hueco nuevo entra como punto con aprobación del dueño, no en silencio |
| RN-10 | El compilador nativo completo (PG-N) es el trabajo más grande y arriesgado del plan | La paridad VM/AOT en tareas no llega a cero diferencias | Puertas internas por bloque en PG-N; las fases PG-L y PG-S no esperan a PG-N para la VM |

## A.8 Auditoría de completitud (RQ-7)

Revisión del 2026-11-02 sobre corpus, archivos de conformidad y README de los miembros. Criterio para llamar
**necesaria** a una característica: un programador que viene de Java, Python o C# la espera en la primera semana de uso
real, y sin ella hay que escribir a mano lo que cualquier lenguaje trae (o directamente no se puede hacer).

### A.8.1 Hallazgos: existe pero no está terminado

| ID | Hallazgo | Evidencia | Destino |
|---|---|---|---|
| H-01 | Los registros no pueden ser elemento de arreglo, campo de clase, parámetro o resultado de métodos y constructores, ni pasarse por referencia | **[O]** `crates/pseudolearn_semantic/README.md`: diagnósticos `recordArrayElementNotSupported`, `recordClassFieldNotSupported`, `recordMemberSignatureNotSupported`, `recordPassedByReference` | PG-L.01 |
| H-02 | Constantes, enumerados y registros no se pueden exportar entre módulos; `Publico`/`Privado` no se aplica a ellos | **[O]** mismo README: «hoy son privados del módulo» | PG-L.02 |
| H-03 | Los genéricos no cruzan módulos: una biblioteca no puede exportar una función ni un registro genérico | **[O]** mismo README: «los genéricos no cruzan módulos, porque las plantillas son privadas de la unidad» | PG-L.03 |
| H-04 | No hay clases genéricas ni variantes genéricas definidas por el usuario | **[O]** mismo README y `LANG.CLASS.OUT-OF-SCOPE` («genéricos de clases… no son construcciones de la edición vigente») | PG-L.04 |
| H-05 | La plantilla genérica sin instanciar no se comprueba, y el servicio de lenguaje no tiene símbolo propio para ella | **[O]** mismo README | PG-L.05 |
| H-06 | Los límites de ámbito no llegan a los mapas de estado ni a las raíces: la memoria de un bloque no se libera al salir de él | **[O]** mismo README, «Pendientes declarados: transportar los límites de ámbito…» | PG-L.06 |
| H-07 | Compilador nativo: sin tareas, canales, esperas de efecto ni red | **[O]** `crates/pseudolearn_codegen/README.md` («El soporte nativo de tareas es un pendiente declarado»), `UNSUPPORTED_OPERATIONS`; 80 vínculos `pendiente` en `conformance-aot.yaml` **[V]** | PG-N |
| H-08 | Ejecutable nativo aislado por diseño: semilla fijada al compilar, sin argumentos ni recursos salvo concesión, sin directorio de trabajo | **[O]** `RT.PROCESS` | PG-N.01 |
| H-09 | `pseudo build` enlaza llamando a `cc` del sistema: sin un compilador de C instalado no se puede generar el ejecutable, y en Windows no existe `cc` | **[O]** `apps/pseudolearn_cli/src/native_linker.rs` (`Command::new("cc")`) | PG-N.09, D-15 |
| H-10 | Vínculos de conformidad `pendiente` cuyas fases ya se cerraron: 45 en `engine` (tareas y canales «PG-4», escenarios integradores «PG-5.09.07», límites «PG-5.03.07», API «PG-6B», HTTP «P6»), 9 de `TOOL.DAP` en `cli` y 3 de `TOOL.SERVICE.CATALOG` en `service` | **[V]** recuento sobre `packages/pseudolearn_engine/conformance*.yaml` y `apps/pseudolearn_cli/conformance.yaml` | PG-7.17 |
| H-11 | La app no tiene selector de rigor (estricto/flexible): fija flexible | **[O]** README app §1.5 | PG-B.28 |
| H-12 | La app no tiene control para reproducir una ejecución, aunque el puerto lo admite | **[O]** README app §4.57 | PG-B.29 |
| H-13 | En la app, el vocabulario del receptor de objeto en la tabla de traza no se localiza para perfiles no hispanos | **[O]** README app §1.5 | PG-B.30 |
| H-14 | La matriz de cobertura de diagramas de la app trata patrones de variante y literales de función como «extensiones» | **[O]** README app (sección de cobertura sintáctica, «Pendientes declarados») | PG-B.30 |
| H-15 | Sin depuración en la extensión web | **[O]** README extensión §11 «Sin DAP web» | PG-7.18 |
| H-16 | Latencia del servicio de lenguaje en proyectos grandes fuera de umbral: cuatro grupos de E-PG-02 por encima de 100 ms y `PERF.PG.SERVICE` no aprobado | **[O]** plan general, resumen de PG-6A | PG-7.19 |
| H-17 | `PERF.SUITE.CORE` 1,0443× frente al presupuesto 1,02× | **[O]** resumen de PG-5 | PG-7.02 |
| H-18 | Ayuda: celdas de cobertura sin ficha asignada | **[O]** README app (cobertura) y H-10 de servicio | PG-7.17 |

Fuera de esta lista y no considerados huecos: las exenciones de observación del sujeto `aot` (un binario compilado no
se depura paso a paso con PseudoLearn; se depura con la VM, igual que en otros lenguajes compilados), las exenciones de
análisis estático del sujeto `aot` y las de `API.PROGRAM.VIEW` que acredita el sujeto `app`.

### A.8.2 Hallazgos: no existe y es necesario para propósito general

Inventario de la biblioteca: `LIB.MODEL` declara 84 nombres canónicos **[V]**. Entre ellos no hay ninguno para:

| ID | Falta | Por qué es necesaria | Destino |
|---|---|---|---|
| N-01 | Mayúsculas y minúsculas de texto | Comparar o normalizar texto de usuario | PG-S.01 |
| N-02 | Ordenar vectores (orden natural y con función de comparación), invertir, buscar | Tarea de la primera semana; hoy hay que escribir el algoritmo | PG-S.02 |
| N-03 | Mínimo, máximo, piso, techo, `tan`, `asen`, `acos`, `atan2`, `log10`, `log2` | Matemática básica de cualquier lenguaje (la regla de precisión de `LIB.CORE.MATH` ya existe) | PG-S.03 |
| N-04 | Archivos: listar un directorio, comprobar existencia, borrar, renombrar, crear directorio, añadir al final | Hoy solo abrir, leer y escribir reemplazando; no se puede ni saber qué archivos hay | PG-S.04 |
| N-05 | Fecha y hora de calendario: componentes, zona horaria, formato y análisis ISO 8601 | `Reloj.Ahora` solo da nanosegundos | PG-S.05 |
| N-06 | Variables de entorno (lectura) | Configurar un programa real (claves de API, rutas) | PG-S.06 |
| N-07 | Código de salida elegido por el programa y escritura en la salida de error | Scripts y herramientas de línea de órdenes | PG-S.07 |
| N-08 | Formato de números en texto (decimales fijos, relleno) | Mostrar resultados | PG-S.08 |

### A.8.3 No existe y no se considera necesario ahora (aceptado por el dueño el 2026-11-02)

| ID | Característica | Recomendación |
|---|---|---|
| D-15 | Enlazador incluido para `pseudo build` (H-09) | **Incluir** `lld` (o el enlazador de Rust) en la distribución, para no exigir un compilador de C; alternativa: exigirlo con un diagnóstico claro y documentado |
| D-16 | Clases abstractas, miembros estáticos y visibilidad protegida | **No incluir.** Las interfaces cubren la abstracción y las funciones de módulo cubren lo estático; añadirlo duplica conceptos para un alumno |
| D-17 | Excepciones | **No incluir.** `Resultado`, `Propagar` y `Diferir` son el modelo de errores del lenguaje, no una carencia |
| D-18 | Servidor HTTP, sockets, procesos hijos, FFI C (FUT-08, FUT-14) | **No incluir en este plan.** Son grandes, cambian el modelo de seguridad y el alcance de ENT-1 no los pide. Si el dueño los considera necesarios, cada uno es una fase nueva |
| D-19 | Registro público de paquetes (FUT-11) | **No incluir.** Las dependencias locales y el lock bastan; un registro es infraestructura y operación, no lenguaje |

---

# Parte B · Plan

## B.0 Las dos últimas fases y qué ocurre con su contenido

Según el orden de §3 del plan general, las dos últimas fases son **PG-B · App y tareas observables** y
**PG-7 · Calificación y distribución** **[O]**. Estado actual:

- **PG-B**: abierta. El plan detallado registra iteraciones de PG-B.01–PG-B.09 y el cierre de puertas `.06` (§11.1–§11.9
  de [fase-pg-b-plan-ejecucion.md](fase-pg-b-plan-ejecucion.md)), con commits hasta `194bd9ce`. El resumen del plan
  general está vacío y quedan pendientes de conformidad de app (`APP.EDITOR.COMPLETION`, `APP.EXEC.SNAPSHOT-VIEW`).
  `C01`–`C13` sin marcar.
- **PG-7**: sin iniciar y sin plan detallado.

### B.0.0 Orden propuesto tras RQ-7

| Fase | Nombre | Depende de | Tamaño |
|---|---|---|---|
| PG-B (reformulada) | Lenguaje completo con anfitriones reales y app con tareas observables | PG-A, PG-3, PG-4, PG-5, PG-6B | XL |
| **PG-L** (nueva) | Lenguaje sin restricciones de construcción | PG-B bloque 1 | L |
| **PG-S** (nueva) | Biblioteca estándar de producción | PG-B (anfitrión común), PG-L.03 | L |
| **PG-N** (nueva) | Compilador nativo completo | PG-B, PG-L, PG-S | XL |
| PG-7 (reformulada) | Erradicación, calificación y distribución del lenguaje completo | PG-B, PG-L, PG-S, PG-N | L |

PG-N va después de PG-L y PG-S para que el compilador nativo implemente el lenguaje y la biblioteca definitivos una sola
vez, en lugar de perseguir cambios. Cada fase nueva respeta §4.0 del plan general (cierre común `C01`–`C13`) y tendrá su
`fase-<id>-plan-ejecucion.md` antes de escribir código. ENT-1 se considera entregado cuando PG-7 esté completada.

### B.0.1 Destino del contenido actual de PG-B

| Punto | Destino | Motivo |
|---|---|---|
| PG-B.01 Evento global, foco y pila por tarea | Absorbido sin cambios | Independiente del anfitrión |
| PG-B.02 Tres proyecciones | Absorbido | Igual |
| PG-B.03 Paso global y por tarea | Absorbido | Igual |
| PG-B.04 Efectos simulados y entradas identificadas | **Retirado**; la parte de entradas identificadas (`InputWait`, `request_id`) se conserva en PG-B.10–.20 | Choca con RQ-3; la identidad de `Leer` no depende de la simulación |
| PG-B.05 Proyecciones reproducibles | Absorbido; se reverifica con cintas grabadas por el anfitrión real | Hoy usa cintas del anfitrión simulado |
| PG-B.06 Cancelación, error, canal lleno y bloqueo | Absorbido; el corte del anfitrión se reverifica con red real | — |
| PG-B.07 Agenda independiente de la presentación | Absorbido; el temporizador real no debe decidir la agenda | — |
| PG-B.08 Pruebas con el puente real | Absorbido; ampliado al anfitrión real | — |
| PG-B.09 E-PG-12 dinámico | Absorbido; escenas regeneradas sin escenarios simulados | Las seis escenas actuales no dependen de HTTP preparado **[I]**; se comprueba |
| «Fuera de alcance: E/S real sin concesión del host» | **Eliminado** | Choca con RQ-1 |

### B.0.2 Destino del contenido actual de PG-7

| Punto | Destino |
|---|---|
| PG-7.01 Conformidad completa | Absorbido; incluye todos los casos rederivados |
| PG-7.02 Presupuestos | Absorbido; añade los límites de D-14 |
| PG-7.03 Capacidades C-01–C-16 | Reformulado: C-07 y C-08 con los criterios nuevos (sin «permiso denegado» como bloqueo, con temporizador real) |
| PG-7.04 Trazabilidad | Absorbido |
| PG-7.05 Casos negativos de K-05, K-06, K-07 y K-13 | Reformulado: K-07 (ampliación de permiso por ruta/DNS/redirect) se reemplaza por «la atenuación voluntaria no se amplía»; los vectores SSRF se eliminan |
| PG-7.06 Documentación bilingüe | Absorbido; incluye los límites de plataforma de §A.4 |
| PG-7.07 Licencia | Sin cambios |
| PG-7.08 Artefactos con «capacidades negociadas» | Reformulado: artefactos por plataforma y límites de plataforma documentados |
| PG-7.09 Casos integradores ENT-1 | Absorbido; «permiso denegado» pasa a ser fallo real del SO |
| PG-7.10 Publicación | Sin cambios |
| PG-7.11 Informe final | Absorbido |

## B.1 Tratamiento de lo estable, lo cerrado y lo congelado

1. **Especificaciones estables 1.0.0 (`SPEC-VERSION-FREEZE`, AGENTS.md §10).** Se edita el texto oficial de cada regla
   en la misma especificación, sin campo `cambio`, conservando identidad, estado y versión. Ninguna regla se borra: la
   identidad de una regla obsoleta se conserva con texto nuevo que describe el comportamiento vigente (por ejemplo,
   `LIB.HTTP.POLICY#R4` pasa a describir la resolución y conexión sin filtro de rangos). No se comprobó si SEE admite
   retirar una regla; reescribir evita depender de ello. Tras editar, `see lock --refresh` lista en una sola orden todos
   los IDs modificados y se registra el reanclaje.
2. **Casos.** Se rederivan de la regla nueva (`SPEC-INDEPENDENT-ORACLE`), nunca copiando la salida del motor. Los que
   esperaban `permiso_denegado`/`destino_denegado` por falta de concesión se reescriben: o prueban una denegación real
   del SO inyectada por el doble de prueba (D-01a), o prueban la atenuación voluntaria (`Limitar`, `Subdirectorio`).
3. **Vínculos de conformidad** (`conformance*.yaml`, `differential-exemptions.json`, `property-conformance.json`) se
   actualizan como datos (`SPEC-BINDING-AS-DATA`).
4. **Fases cerradas** (D-13a): no se reabren ni se desmarcan casillas. El registro «Decisiones posteriores de la persona»
   del plan general recibe una entrada con la decisión del dueño y la lista de puntos sustituidos (PG-3.03, PG-5.04,
   PG-5.07 en lo relativo a concesiones, PG-6B.05, PG-B.04), y el resumen de cada fase una nota «sustituido por …».
5. **Hoja de ruta**: R-09, R-13, C-07, C-08, ADR-02, ADR-12, K-07, E-PG-09 y la fila SSRF de STRIDE se anotan como
   sustituidos en el mismo cambio que los reemplaza.
6. **README**: cada miembro afectado actualiza su README en el mismo commit que su código (`DOC-README-TRUTH`); ninguno
   cita `docs/`.

## B.2 PG-B reformulada · Lenguaje completo con anfitriones reales y app con tareas observables

Objetivo: todo programa válido se ejecuta con autoridad plena y efectos reales en CLI, extensión (escritorio y web) y
app (macOS, iOS, Windows), sin concesiones ni simulación; la app enseña tareas y efectos reales sin falsear causalidad.

Dependencias: PG-A, PG-3, PG-4, PG-5, PG-6B (todas cerradas o con iteraciones ya hechas). Orden interno obligatorio:
contrato y casos (bloque 1) → motor/API (bloque 2) → anfitriones (bloques 3–5) → app y tareas (bloque 6).

### Bloque 1 · Contrato del corpus

- [ ] `PG-B.10` Autoridad plena por omisión. Reescribir `LANG.CAPABILITY.MODEL#R2`, `RT.HOST.INTERFACE#R1/R7`,
  `LIB.HTTP#R1/R3` y las reglas de permisos de `API.PROJECT.MANIFEST` y `API.EXECUTE`: `Solicitar*` siempre concede si
  el anfitrión soporta la familia; sin manifiesto de permisos ni intersección; una familia no soportada por la plataforma
  devuelve un error tipado de plataforma, nunca una denegación por política. Casos derivados es/en, ambos rigores.
- [ ] `PG-B.11` Destinos de red (D-04, D-06, D-07). Reescribir `LIB.HTTP.POLICY#R1–R4` y `RT.HOST.INTERFACE#R8/R9`:
  `http` y `https` a cualquier host y dirección; TLS validado; nativo sin seguir redirecciones, sin cookies ni proxies
  ambientales; navegador: redirección seguida por la plataforma y URL final visible; descenso HTTPS→HTTP decidido por
  el programa. Casos de diferencia de plataforma marcados por sujeto.
- [ ] `PG-B.12` Tiempo y azar reales (D-05). Reescribir `LIB.TIME#R1/R2` y `RT.HOST.INTERFACE#R3`: modo vivo con reloj
  del sistema en cada lectura, temporizador que espera tiempo real sin bloquear otras tareas, semilla de entropía del SO
  grabada; reproducción idéntica desde cinta. Casos en `ENG.EFFECT.TAPE` para reloj y semilla grabados.
- [ ] `PG-B.13` Archivos con rutas del sistema (D-03). Reescribir `LANG.CAPABILITY.MODEL#R3` y reglas de `LIB.IO`:
  `SolicitarDirectorio` acepta ruta absoluta o relativa a la carpeta de trabajo del anfitrión; la atenuación
  `Subdirectorio` confina lo que el programa decida; `PermisoDenegado` solo proviene del SO.
- [ ] `PG-B.14` Argumentos reales: `Argumentos` entrega los argumentos de ejecución del anfitrión (CLI: tras `--`;
  extensión: configuración de ejecución; app: campo de argumentos de la ejecución). Sin cambios de sintaxis.
- [ ] `PG-B.15` Anfitrión de memoria (D-01a): `RT.HOST.INTERFACE#R6` pasa a definir el doble de prueba del corpus,
  declarado no distribuible. Rederivar todos los casos de §A.2.1 con bloque de permisos; fichas de
  `TOOL.SERVICE.CATALOG` sin lenguaje de concesión. `see validate`, `export --check`, `lock --refresh` de los IDs
  modificados.

### Bloque 2 · Motor y API

- [ ] `PG-B.16` Runtime y API sin autoridad por concesión: eliminar `effect_authority` por intersección, listas de
  orígenes (`network_origins`, `local_origins`, `requested_permissions`) y `DestinoDenegado` salvo en la atenuación
  voluntaria; `FakeHostProvider` y `memory_host*` solo bajo característica de pruebas, ausentes de los artefactos de
  CLI, puente y Wasm (verificación por `cargo tree -e features` y símbolos). Conformidad `engine` de los IDs del bloque 1.
- [ ] `PG-B.17` Cinta con tiempo real y semilla: reloj, temporizador y semilla vivos se graban; la reproducción no
  consulta al anfitrión; pruebas de cinta truncada/alterada intactas.

### Bloque 3 · CLI y extensión de escritorio

- [ ] `PG-B.18` CLI con anfitrión físico completo por omisión: eliminar `--conceder`/`--grant`, `--archivos`/`--files`,
  `--origen`/`--origin`, `--origen-local`/`--local-origin`; `--raiz-prueba` se conserva solo si las pruebas lo exigen
  (raíces TLS de prueba), documentado como opción de pruebas. Reloj y temporizador reales, argumentos tras `--`, rutas del
  sistema. Eliminar el filtro de rangos de `physical_network_address`/`physical_network_resolver` y sus vectores
  (`network_address_policy_tests.rs`, entradas SSRF de `tests/network_vector_registry.rs` y
  `tests/network_security_vectors.rs`). Mensajes es/en de `messages.rs` actualizados. `TOOL.CLI.RUN` y
  `TOOL.CLI.CONVENTIONS` reescritas antes del código.
- [ ] `PG-B.19` Extensión de escritorio y DAP heredan la autoridad plena: `run --editor` y `pseudo dap` con anfitrión
  físico; carpeta de trabajo = carpeta del workspace o del archivo; argumentos desde configuración de ejecución
  (`launch.json` `args` pasa a aceptarse; se retiran de la lista de rechazo de `debug_configuration.ts` las claves que
  ya no significan nada). La Confianza de Workspace de VS Code se conserva y se documenta como límite de VS Code.

### Bloque 4 · Extensión web

- [ ] `PG-B.20` Anfitrión web real: eliminar `pseudolearn.grantNetwork`, `pseudolearn.grantFiles`, `BrowserGrants`,
  `browser_scratch_files.ts` y `allowedOrigins` de `fetch_host.mjs`; archivos sobre `workspace.fs` del workspace
  abierto; reloj (`Date.now`), temporizador (`setTimeout` en el Worker) y argumentos implementados; fallos de CORS,
  contenido mixto y cabeceras prohibidas como `ErrorES` tipados con causa de plataforma. `showCapabilities` pasa a
  mostrar los límites de navegador de §A.4. Pruebas web (`tests/web/http_scenarios.ts`, `file_scenarios.ts`) sin pasos
  de concesión, con el servidor local y la ruta «sin CORS» esperando el error de plataforma.

### Bloque 5 · App: anfitrión real en macOS, iOS y Windows

- [ ] `PG-B.21` Capa de anfitrión: declarar en `apps/pseudolearn_app/architecture.yaml`, antes del código, una capa
  `host` (anillo 2, `may_import: [model, ports]`, permite `dart:io`, prohíbe Flutter de interfaz y `engine/`). Puerto en
  `domain/ports` para atender efectos; `RustEffectGate` depende del puerto; composición estática en `composition/`.
- [ ] `PG-B.22` Implementación (D-02b): primero medir el puente ios-arm64 Release con `pseudolearn_host` (CF-N11) y
  parar si supera `PERF.ARTIFACT.SIZE`. Extraer de la CLI el anfitrión físico (archivos, red, reloj, temporizador,
  argumentos) al crate `pseudolearn_host`, declarado en `architecture.yaml` del motor y con `isolation` reescrita
  (CF-N13). Lo consumen la CLI y el puente de la app; el puente atiende la red en un hilo Rust propio y Dart consulta
  sus resultados sin bloquear la UI. Carpeta de trabajo real por documento dentro del contenedor y argumentos desde un
  campo de la ejecución. La capa Dart `host` de PG-B.21 solo resuelve la carpeta de trabajo y los argumentos.
- [ ] `PG-B.23` Configuración de plataforma: iOS `NSLocalNetworkUsageDescription` y, según D-08, excepción ATS; macOS
  `Release.entitlements`/`DebugProfile.entitlements` revisados (red cliente ya presente) y carpeta de trabajo del
  contenedor; Windows `msix_config.capabilities` con `internetClient` y `privateNetworkClientServer` **[I: efecto en
  MSIX de confianza plena no verificado]**; Inno Setup y ZIP sin cambios de permisos.
- [ ] `PG-B.24` Eliminación de la simulación de la app (lista exacta en §B.4.4): código, pruebas, claves ARB es/en y
  generados, README §1.3/§4.54 reescritos como «Anfitrión real en modo de archivo único», ayuda localizada sin
  «Simulado». El panel de escenarios desaparece; el pie del documento muestra el estado real de la espera de efecto.

### Bloque 6 · Tareas observables con efectos reales (absorbe PG-B.01–.03, .05–.09)

- [ ] `PG-B.25` Reverificar PG-B.01–.03, .05–.08 con el anfitrión real: cintas grabadas contra el servidor loopback,
  reproducción con cero llamadas al anfitrión, corte del anfitrión durante HTTP real, temporizador real sin alterar la
  agenda (`PG-B.07`). Resolver o reportar los pendientes de conformidad de app `APP.EDITOR.COMPLETION` y
  `APP.EXEC.SNAPSHOT-VIEW` heredados de §11.9.
- [ ] `PG-B.26` E-PG-12 dinámico (PG-B.09) regenerado sin escenarios simulados; estudio humano conserva el diferimiento
  del 2026-10-22.

### Bloque 7 · Aceptación por plataforma

- [ ] `PG-B.27` Programa de aceptación es/en en archivo único (GET `https://rickandmortyapi.com/api/character/1`,
  imprime nombre y estado) ejecutado sin configuración en: CLI macOS **[verificable]**, extensión escritorio macOS
  **[verificable]**, extensión web Chromium y WebKit **[verificable]**, app macOS **[verificable]**, app iOS simulador
  **[verificable]**, app Windows **[implementado, no verificable en este equipo]**. Se registra salida real, hora y
  código de estado; Internet solo se usa en este punto, nunca en el corpus.

### Bloque 8 · Características de la app que hoy no se pueden usar (RQ-7)

- [ ] `PG-B.28` Selector de rigor estricto/flexible en la app, persistido por documento y aplicado a análisis y
  ejecución (H-11).
- [ ] `PG-B.29` Control de interfaz para reproducir una ejecución grabada, con rechazos tipados visibles (H-12).
- [ ] `PG-B.30` Vocabulario del receptor localizado en la tabla de traza para el perfil inglés (H-13); patrones de
  variante y literales de función con proyección completa en la matriz de cobertura, sin filas «extensión» (H-14).

Fuera de alcance: app Flutter web (D-11) y lo que se descarta en §A.8.3. El compilador nativo pasa a PG-N.

#### Criterios de salida de PG-B (medibles)

| Criterio | Medida |
|---|---|
| Cero concesiones | `grep` de `--conceder`, `--grant`, `--origin`, `--local-origin`, `grantNetwork`, `grantFiles`, `network_origins`, `requested_permissions`, `local_origins`, `simulatedScenario`, `SimulatedCapabilities` fuera del doble de prueba: 0 coincidencias |
| Corpus | `see validate`, `export --check`, `lock --check` en verde; reanclaje de los IDs modificados registrado; `see conform --subject engine` y `app` sin divergencias en los IDs modificados |
| Motor | Clippy `-D warnings`, `rust-checks all`, `cargo deny`, pruebas de los crates tocados; doble de prueba ausente del árbol de dependencias de CLI, puente y Wasm |
| CLI | Pruebas dirigidas del anfitrión físico; contrato de adaptador en loopback; `Esperar 1 s` mide ≥ 1 s reales |
| Extensión | `vitest`, `check:*`, `node tests/web/run-web.mjs` Chromium y WebKit, host de escritorio confiable |
| App | `flutter analyze --fatal-infos --fatal-warnings`, `check_limits`, `check_content`, `check_design_system`, `check_syntax_coverage`, arquitectura (capa nueva y caso negativo), `tool/test_bridge.sh`, pruebas de la capa `host` con camino feliz, infeliz y límites (respuesta 4xx/5xx, timeout, TLS inválido, ruta inexistente, carpeta de trabajo vacía) |
| Aceptación | PG-B.27 con evidencia por plataforma; Windows rotulado «no verificado» |
| Cierre común | `PG-B.C01`–`C13` según §4.0 del plan general |

## B.3a PG-L · Lenguaje sin restricciones de construcción (nueva)

Objetivo: que toda construcción de la edición 2026 se combine con las demás sin diagnósticos de «no soportado». Cada
punto sigue especificación → casos → pruebas → código, con fichas de ayuda es/en, proyección de app (`C09`) y paridad
en VM; la paridad nativa se acredita en PG-N.

- [ ] `PG-L.01` Registros en todas las posiciones (H-01): elemento de arreglo y de vector, campo de clase, parámetro y
  resultado de métodos y constructores, paso por referencia. Se retiran los diagnósticos
  `recordArrayElementNotSupported`, `recordClassFieldNotSupported`, `recordMemberSignatureNotSupported` y
  `recordPassedByReference` del catálogo y de `DIAG.MESSAGES`. Casos de copia por valor y de aliasing en cada posición.
- [ ] `PG-L.02` Visibilidad y exportación de constantes, enumerados y registros entre módulos (H-02), con
  `Publico`/`Privado` y reexportación según `LANG.MODULE.IMPORT`.
- [ ] `PG-L.03` Genéricos entre módulos (H-03): plantillas exportables e instanciadas en el módulo consumidor, con
  identidad estable de instancia en el lock y en la caché incremental del servicio.
- [ ] `PG-L.04` Clases genéricas y variantes genéricas de usuario (H-04): sintaxis `<T>` tras el nombre, restricciones
  por interfaz, herencia e interfaces genéricas; se elimina la mención correspondiente de `LANG.CLASS.OUT-OF-SCOPE`.
  Medición de crecimiento por instancia (E-PG-03) con la misma condición de reversión vigente.
- [ ] `PG-L.05` Comprobación de la plantilla genérica sin instanciar y símbolo propio de plantilla en el servicio de
  lenguaje (H-05): hover, referencias y renombrado sobre la plantilla.
- [ ] `PG-L.06` Liberación por ámbito (H-06): los límites de bloque llegan a los mapas de estado y de raíces; prueba de
  memoria que demuestre que un bucle con objetos de bloque no crece sin límite.
- [ ] `PG-L.07` App y extensión: diagramas, tabla de traza, ayuda y resaltado para todo lo anterior; matriz de cobertura
  sin filas nuevas en «no soportado».

Criterios de salida: cero diagnósticos de «no soportado» para construcciones de la edición (búsqueda en el catálogo de
diagnósticos); `see conform --subject engine` y `app` sin divergencias en las reglas tocadas; `cargo test` de
`semantic`, `lowering`, `vm`, `service` y `api`; Clippy y `rust-checks all`; verificadores de app y extensión.

## B.3b PG-S · Biblioteca estándar de producción (nueva)

Objetivo: cubrir las necesidades básicas de §A.8.2 con la misma disciplina de `LIB.MODEL` (identidad única, facetas
es/en, firmas, efectos y fichas). Todo efecto nuevo usa el crate `pseudolearn_host` de PG-B y la cinta.

- [ ] `PG-S.01` Texto: mayúsculas y minúsculas según Unicode sin configuración regional (N-01).
- [ ] `PG-S.02` Colecciones: ordenar con orden natural y con función de comparación (orden estable), invertir, buscar,
  y el equivalente para claves de diccionario (N-02).
- [ ] `PG-S.03` Números: mínimo, máximo, piso, techo, `tan`, `asen`, `acos`, `atan2`, `log10`, `log2` con la regla de
  redondeo correcto de `LIB.CORE.MATH` (N-03).
- [ ] `PG-S.04` Archivos: listar directorio, existe, borrar, renombrar, crear directorio, añadir al final; errores del
  SO como `ErrorES` portables (N-04).
- [ ] `PG-S.05` Fecha y hora: tipo de instante de calendario, componentes, zona horaria del sistema y UTC, formato y
  análisis ISO 8601 (N-05). Grabable en cinta.
- [ ] `PG-S.06` Variables de entorno de solo lectura, grabables en cinta con los valores sensibles por referencia,
  igual que las credenciales HTTP (N-06).
- [ ] `PG-S.07` Código de salida del programa y salida de error (N-07), en CLI, extensión y app (la app los muestra en
  la consola con su propio estilo).
- [ ] `PG-S.08` Formato de números en texto (N-08).
- [ ] `PG-S.09` Cada operación nueva en la VM, en la extensión web (o con error tipado de plataforma si el navegador no
  la ofrece, por ejemplo variables de entorno) y en la app de las tres plataformas.

Criterios de salida: `LIB.MODEL` con todas las identidades nuevas y sus fichas es/en (`see validate`); casos derivados
con camino feliz, infeliz y límites (vector vacío, ordenación estable con iguales, fechas en cambios de horario, ruta
inexistente); conformidad `engine`, `app` y `cli`; regla de precisión matemática comprobada con su propiedad.

## B.3c PG-N · Compilador nativo completo (nueva, D-09a)

Objetivo: que `pseudo build` y `pseudo run --nativo` ejecuten **todo** programa válido con la misma salida, efectos y
cinta que la VM, en macOS (arm64 y x86_64), Linux x64 y Windows x64, sin exigir herramientas al usuario.

Punto de partida comprobado **[O]**: Cranelift genera objeto nativo para las 74 operaciones de la RI
(`pseudolearn_codegen`); las operaciones de tarea, espera de efecto y canal están en `UNSUPPORTED_OPERATIONS` y terminan
en `nativeTasksUnsupported`; `task.yield_check` se baja como operación vacía porque el binario es de un solo hilo lógico
sin agenda; `conformance-aot.yaml` tiene 80 vínculos `pendiente` (tareas, canales, agenda, memoria de tareas, efectos,
HTTP, módulos `LANG.MODULE.*` y `LANG.PROFILE.MODEL` con «PG-1.12», `LIB.JSON` con «PG-5.01», `RT.PROCESS`); el
enlazador es `cc` del sistema. Las disposiciones de continuación, tarea y canal ya tienen dueño único en
`pseudolearn_abi`, compartido con la VM.

### Bloque 1 · Contrato

- [ ] `PG-N.01` Reescribir `RT.PROCESS` y `RT.ABI` para el ejecutable con autoridad plena (H-08): argumentos de la línea
  de órdenes, directorio de trabajo, rutas del sistema, red, reloj y temporizador reales, semilla de entropía del SO
  (semilla fija solo con opción explícita al ejecutar), código de salida y salida de error de PG-S.07, cinta opcional.
  Casos derivados para el sujeto `aot`.
- [ ] `PG-N.02` Contrato de continuación nativa: qué valores vivos se guardan en cada punto de suspensión, cómo los
  recorre el recolector y cómo se reanudan, sobre las disposiciones de `pseudolearn_abi`. Casos de `ENG.TASK.MEMORY`
  y `ENG.TASK.AGENDA` vinculados a `aot`.

### Bloque 2 · Tareas, canales y agenda

- [ ] `PG-N.03` Funciones suspendibles en código nativo: transformación a máquina de estados o marcos en montón
  (decisión de diseño en el README de `pseudolearn_codegen`, con alternativas y condición de reversión); `Aguardar`,
  ámbitos `Tareas`, `Lanzar`, unión, cancelación cooperativa y limpieza LIFO.
- [ ] `PG-N.04` Agenda nativa en `pseudolearn_aot_rt` con el mismo orden lógico, desempate y puntos de cesión que la VM
  (`ENG.TASK.AGENDA`); canales con capacidad, cierre, contrapresión y elección; bloqueo diagnosticado (`taskDeadlock`).
- [ ] `PG-N.05` Recolector: raíces de marcos suspendidos, continuaciones, mensajes pendientes y canales.
- [ ] `PG-N.06` Efectos concurrentes: espera de efecto por tarea, entrega en orden de finalización, cinta con el mismo
  orden de entrega que la VM.

### Bloque 3 · Anfitrión, red y biblioteca

- [ ] `PG-N.07` Enlace del runtime nativo con `pseudolearn_host` (D-02b): archivos, red HTTP/HTTPS, reloj, temporizador,
  argumentos, entorno y salida de error reales; desaparece el error de uso `--native` con red.
- [ ] `PG-N.08` Toda la biblioteca de PG-S y las construcciones de PG-L en código nativo; los vínculos `LANG.MODULE.*`,
  `LANG.PROFILE.MODEL` y `LIB.JSON` pasan de `pendiente` a `cumple` con evidencia.

### Bloque 4 · Distribución sin herramientas del usuario

- [ ] `PG-N.09` Enlazador (D-15): `pseudo build` funciona sin un compilador de C instalado, con el enlazador incluido
  en la distribución; en Windows genera `.exe` con el enlazador compatible con MSVC; diagnóstico claro si el destino no
  está soportado.
- [ ] `PG-N.10` Destinos: macOS arm64 y x86_64, Linux x64 y Windows x64. Windows queda implementado y rotulado «no
  verificado» mientras no haya ejecución real; las pruebas unitarias de rutas y del enlazador corren en macOS.

### Bloque 5 · Paridad y rendimiento

- [ ] `PG-N.11` Diferencial VM/AOT con cero diferencias en todo el corpus ejecutable, incluidas las 10 000 agendas
  sembradas de E-PG-06 (hoy comparadas solo en VM) y los casos integradores `LIB.SCENARIO.*`.
- [ ] `PG-N.12` `PERF.AOT.LEVEL` se mantiene (≤ 1,70 frente a V1F) con tareas presentes; la cesión de la agenda no
  penaliza a los programas sin tareas (control sin tareas medido).
- [ ] `PG-N.13` Se eliminan `UNSUPPORTED_OPERATIONS` para tareas, el diagnóstico `nativeTasksUnsupported`, sus
  mensajes es/en y las menciones de «pendiente declarado» en los README de `pseudolearn_codegen`, `pseudolearn_aot_rt`,
  motor y CLI.

Se conserva como característica normal de un compilado, no como hueco: el ejecutable nativo no ofrece observación paso
a paso ni retroceso; esas exenciones de `conformance-aot.yaml` siguen justificadas (se depura con la VM).

#### Criterios de salida de PG-N

| Criterio | Medida |
|---|---|
| Vínculos | `conformance-aot.yaml` con 0 `pendiente`; exenciones solo de observación o análisis estático |
| Paridad | `see conform --subject aot` y diferencial VM/AOT sin divergencias; E-PG-06 en AOT con 0 diferencias |
| Ejecutable | Programa de PG-B.27 compilado con `pseudo build` y ejecutado como binario en macOS sin compilador de C instalado (perfil de usuario limpio) |
| Rendimiento | `PERF.AOT.LEVEL` en verde; medición con procedencia |
| Calidad | Clippy `-D warnings`, `rust-checks all` (incluido `unsafe` solo en `pseudolearn_aot_rt` con su tabla de invariantes), `cargo deny` |
| Windows | Implementado; build cruzado o en comprobación manual autorizada; rotulado «no verificado» |

## B.3 PG-7 reformulada · Erradicación, calificación y distribución del lenguaje completo

Objetivo: demostrar que el 100 % del lenguaje corre en todos sus backends y plataformas, sin restos de la política
anterior, y dejarlo listo para distribuir.

Puntos conservados (texto ajustado): PG-7.01, .02 (incluye D-14), .03 (C-07/C-08 nuevos), .04, .05 (K-07 reformulado),
.06 (con límites de plataforma), .07, .08 (artefactos por plataforma y límites documentados), .09, .10, .11.

Puntos nuevos:

- `PG-7.12` **Retirado antes de existir**: el compilador nativo completo es la fase PG-N (§B.3c), por decisión del dueño
  del 2026-11-02 («en una fase»). §B.4.6 queda sin efecto. El ID no se reutiliza.
- [ ] `PG-7.13` Destinos Windows de CLI y extensión (D-10a): `win32-x64` en `artifact.contract.json`, rutas Windows en
  el anfitrión físico (letras de unidad, separadores, UNC), pruebas unitarias de rutas; build en comprobación manual de
  GitHub Actions solo si el dueño la autoriza. Rotulado «implementado, no verificado» mientras no exista ejecución real.
- [ ] `PG-7.14` Barrido de eliminación de raíz: verificador mecánico por miembro (lista negra de identificadores y
  textos de §B.4) con caso negativo deliberado (AGENTS.md §5); `git grep` de los términos de §B.4 en todo el monorepo
  con 0 coincidencias fuera del doble de prueba declarado y de `docs/` histórico.
- [ ] `PG-7.15` Reconciliación documental: plan general, hoja de ruta y planes de fase con las notas de §B.1; README
  raíz si describe permisos o simulación.
- [ ] `PG-7.16` Aceptación final del dueño: el dueño ejecuta el programa de PG-B.27 en la app y en las demás
  plataformas y registra su resultado; sin él la fase no se cierra («requiere a la persona»).
- [ ] `PG-7.17` Cero vínculos `pendiente` sin fase viva (H-10): los 45 de `engine`, 9 de `TOOL.DAP` y 3 de
  `TOOL.SERVICE.CATALOG` pasan a `cumple` con evidencia, o a `exento` con una justificación que no sea «falta
  implementar». Fichas de ayuda para toda celda de cobertura (H-18).
- [ ] `PG-7.18` Depuración en la extensión web (H-15): adaptador de depuración en el Worker sobre la VM Wasm con el
  mismo contrato `TOOL.DAP` que escritorio (puntos de parada, pasos, tareas como hilos, `stepBack`).
- [ ] `PG-7.19` Latencia del servicio de lenguaje (H-16): `files-1000-extended` de E-PG-02 por debajo de 100 ms en todos
  los grupos, o un umbral nuevo aprobado por el dueño con medición reproducible.

#### Criterios de salida de PG-7

| Criterio | Medida |
|---|---|
| Conformidad | `see conform` de todos los sujetos (`engine`, `aot` o retirado, `service`, `cli`, `app`) sin divergencias no exentas |
| Erradicación | PG-7.14 en verde con su caso negativo fallando como se espera |
| AOT | Acreditado por el cierre de PG-N; PG-7 repite el diferencial completo VM/AOT con cero diferencias |
| Vínculos | `grep '"pendiente"'` en todos los `conformance*.yaml`: 0 |
| Plataformas | Tabla de §A.4 transcrita a la documentación de uso es/en; Windows rotulado |
| Distribución | Hashes por artefacto; licencias comprobadas (PG-7.07) |
| Cierre común | `PG-7.C01`–`C13` |

## B.4 Inventario de eliminación de raíz

Sujeto a D-01. Las rutas son las observadas el 2026-11-02; el plan detallado de cada fase debe reinventariar al
empezar.

### B.4.1 Corpus

Textos reescritos (no borrados) en: `LANG.CAPABILITY.MODEL`, `RT.HOST.INTERFACE`, `LIB.HTTP`, `LIB.HTTP.POLICY`,
`LIB.TIME`, `LIB.IO`, `API.PROJECT.MANIFEST`, `API.EXECUTE`, `TOOL.CLI.RUN`, `TOOL.CLI.CONVENTIONS`,
`TOOL.CLI.MESSAGES`, `TOOL.SERVICE.CATALOG`, `DIAG.CATALOG`/`DIAG.MESSAGES` si contienen códigos de concesión. Casos
rederivados en las especificaciones de §A.2.1. Regenerados: `export.json`, `specifications.lock`. Vínculos:
`conformance.yaml` de `pseudolearn_spec`, `pseudolearn_engine` (`conformance*.yaml`), CLI y app;
`differential-exemptions.json`; `property-conformance.json`.

### B.4.2 Motor

`pseudolearn_runtime`: lógica de intersección de autoridad y listas de orígenes en `effect_authority.rs`,
`host_validation.rs`, `local_http_effect.rs` y los demás archivos con `network_origins`/`requested_permissions`; los
`memory_host*.rs` pasan a característica de pruebas (o se borran con D-01b). `pseudolearn_api`: `fake_host.rs` y su uso
en `execution_setup.rs` bajo característica de pruebas; nueve archivos con listas de orígenes; `negotiation.rs` si solo
anuncia concesiones. `pseudolearn_bench_worker`: tres archivos con orígenes. `pseudolearn_wasm/browser/fetch_host.mjs`:
`allowedOrigins` y sus pruebas. README de motor, API, runtime y Wasm.

### B.4.3 CLI

Opciones de concesión en `options.rs`/`execution_options.rs` y pruebas; `physical_network_address.rs` (filtro de
rangos) y `network_address_policy_tests.rs`; entradas SSRF de `tests/network_vector_registry.rs` y
`tests/network_security_vectors.rs`; reloj/temporizador lógicos y argumentos vacíos de `physical_host.rs`; mensajes en
`messages.rs`; README §política de red, proveedor físico, editor y DAP.

### B.4.4 App

Borrar: `lib/domain/model/execution/simulated_capabilities.dart`, `simulated_scenario.dart`;
`lib/engine/rust/rust_simulated_host.dart`, `rust_simulated_files.dart`, `rust_simulated_http.dart`;
`lib/presentation/document/components/simulated_scenario_panel.dart`, `simulated_scenario_panel_content.dart`,
`simulated_scenario_selector.dart`, `simulated_scenario_help_button.dart`; sus pruebas
`test/engine/rust/rust_simulated_{host,files,http}_test.dart` y
`test/presentation/document/components/simulated_scenario_panel_test.dart`. Modificar: `document_footer.dart`,
`execution_cubit.dart`, `execution_state.dart`, `ports/program_execution.dart`, `rust_effect_gate.dart`,
`rust_program_execution.dart`, `rust_replay_host.dart` y sus pruebas; `test/fakes/fake_program_execution.dart`;
`tool/native_bridge_adapters_test.dart`; escenas de `test/engine/rust/task_scene_runner.dart`. Localización: claves
`simulatedScenario*` de `app_es.arb`/`app_en.arb` y regeneración de `lib/presentation/l10n/generated/`. README §1.3,
§4.54 y referencias en §4.57–§4.60.

### B.4.5 Extensión

`src/adapters/browser_commands.ts` (comandos de concesión), `src/contracts/host_capabilities.ts` (`BrowserGrants`),
`src/adapters/browser_scratch_files.ts`, `browser_effect_host.ts` y `browser_file_host.ts` (raíz `root` en memoria),
`src/application/debug_configuration.ts` (lista de rechazo), mensajes «No permission/origin»; pruebas web y unitarias
asociadas; carga «HTTP simulado» de `scripts/lib/web-workloads.mjs` (se convierte en carga contra el servidor local o se
rotula como doble de banco, según D-01); README §8, §11, §12.

### B.4.6 AOT (solo con D-09b)

`pseudolearn_codegen`, `pseudolearn_aot_rt`, `pseudolearn_native_probe`, `conformance-aot.yaml`, `native_*` de la API y
de la CLI, opciones `--nativo`/`build`, especificaciones `RT.ABI`, `RT.LINKING`, `RT.PROCESS` y casos de sujeto `aot`,
presupuesto `PERF.AOT.LEVEL`, README.

### B.4.7 Documentación

Hoja de ruta y plan general según §B.1; plan de PG-B (D-PGB-10, PG-B.04) anotado; README de los miembros anteriores.

## B.5 Orden de ejecución y paradas

1. Decisiones D-01–D-19: aceptadas el 2026-11-02. **Parada** hasta autorización de iniciar PG-B.
2. Plan detallado `fase-pg-b-plan-ejecucion.md` reescrito para la PG-B reformulada (C02). **Parada** para revisión.
3. PG-B: bloque 1 (corpus) → bloque 2 → bloques 3–5 (en este orden, cada uno con su borrado en el mismo cambio) →
   bloques 6 y 8 → bloque 7. Cada bloque cierra con sus verificaciones dirigidas; las campañas pesadas solo al final de
   la fase (decisión del 2026-10-24 sobre alcance de verificación). Cierre. **Parada** (`PHASE-STOP`).
4. PG-L: plan detallado, revisión, ejecución, cierre. **Parada.**
5. PG-S: plan detallado, revisión, ejecución, cierre. **Parada.**
6. PG-N: plan detallado, revisión; bloques 1 → 5 con puerta interna al final de cada uno. Cierre. **Parada.**
7. PG-7: plan detallado; PG-7.13 → .14 → .17 → .18 → .19 → resto → .16. **Parada final.**

## B.6 Qué quedará sin verificar y debe declararse

- App Windows y destino `win32-x64` de CLI/extensión: implementado, sin ejecución real en este equipo (macOS).
- iOS físico (solo simulador) y aviso de red local en dispositivo; revisión de App Store.
- Firefox en la extensión web (sigue sin lanzarse en el equipo, PG-5/PG-6B).
- Efecto real de las capacidades MSIX sobre una app de confianza plena.
- Aviso de red local de macOS 15+ en la app.
- Ejecutables nativos de Windows x64 generados por PG-N (enlazador incluido y `.exe`), sin ejecución real.

---

# Parte C · Fuentes y alcance de la revisión

## C.1 Archivos revisados

- `AGENTS.md`; `docs/plan-ejecucion-proposito-general/plan-ejecucion-proposito-general.md` (§0, §2–§4.12);
  `docs/plan-ejecucion-proposito-general/fase-pg-b-plan-ejecucion.md` (§0–§3, §4 PG-B.04, §11.5–§11.9);
  `docs/hoja-de-ruta-proposito-general.md` (búsqueda de R-08, R-09, R-13, C-07, C-08, C-10, ADR-02, ADR-12, K-07,
  K-09, E-PG-05/07/08/09, STRIDE).
- Corpus: `lang/lang.capability.model.md`, `rt/rt.host.interface.md`, `lib/lib.http.md`, `lib/lib.http.policy.md`,
  `lib/lib.time.md`, `lib/lib.io.md` (texto de reglas), `api/api.project.manifest.md` (reglas de permisos),
  `tool/tool.service.catalog.md` (fichas de capacidades); recuento de bloques de permisos en todo el corpus.
- Motor: `packages/pseudolearn_engine/README.md` (AOT, HTTP, depuración y web), `crates/pseudolearn_api/Cargo.toml`,
  `crates/pseudolearn_api/src/execution_setup.rs`, listado de `crates/pseudolearn_api/src`,
  `crates/pseudolearn_runtime/src`, `crates/pseudolearn_library/src`, `crates/pseudolearn_wasm/README.md`,
  `crates/pseudolearn_abi/src/effect_operation.rs`, menciones de `FakeHostProvider` en el README de la API.
- App: `apps/pseudolearn_app/README.md` (§1, §2.1, §4.50, §4.54, índice), `architecture.yaml` (capas), `pubspec.yaml`
  (`msix_config`), `native/Cargo.toml`, `macos/Runner/{DebugProfile,Release}.entitlements`, `ios/Runner/Info.plist`
  (búsqueda de ATS y red local), `lib/domain/model/execution/simulated_scenario.dart`, claves ARB y listado de archivos
  con «simulat».
- CLI: `apps/pseudolearn_cli/README.md` (red, proveedor físico, editor, DAP, pruebas), `Cargo.toml`,
  `src/physical_host.rs`, listado de `src/`.
- Extensión: `apps/pseudolearn_vscode/README.md`, `package.json`, `artifact.contract.json`,
  `src/application/run_arguments.ts`, `src/application/debug_configuration.ts`, `src/adapters/browser_effect_host.ts`,
  `src/adapters/browser_commands.ts`, `src/adapters/browser_file_host.ts` (búsqueda).
- Sitio y backend: `apps/fe-pseudolearn/README.md` (§1), `apps/pseudolearn_backend/README.md` (§1).
- Auditoría de completitud (§A.8): `packages/pseudolearn_engine/crates/pseudolearn_semantic/README.md` (registros,
  ámbitos, genéricos), `crates/pseudolearn_codegen/README.md` (tareas nativas), `packages/pseudolearn_engine/README.md`
  (aislamiento de red y AOT), `packages/pseudolearn_engine/architecture.yaml` (`isolation`),
  `packages/pseudolearn_engine/conformance.yaml`, `conformance-aot.yaml`, `conformance-service.yaml`,
  `apps/pseudolearn_cli/conformance.yaml`, `apps/pseudolearn_app/conformance.yaml` (recuento de `pendiente` y `exento`),
  `lib/lib.model.md` (84 nombres canónicos), `rt/rt.process.md`, `lang/lang.class.out-of-scope.md`,
  `lib/lib.core.*.md` (resúmenes y reglas), `apps/pseudolearn_cli/src/native_linker.rs`, `docs/pendientes-rezagados.md`,
  tabla FUT-01–FUT-14 de la hoja de ruta, README app §1.5 y secciones de cobertura y reproducción.

## C.2 Comprobado durante el análisis

- `curl -H "Origin: https://vscode.dev" https://rickandmortyapi.com/api/character/1`: HTTP/2 200 con
  `access-control-allow-origin: *`.
- Búsquedas `grep` de los identificadores y recuentos citados.
- Búsquedas web: [política de red de Flutter en iOS/Android](https://docs.flutter.dev/release/breaking-changes/network-policy-ios-android)
  (la página describe la restricción como vigente; su línea de reversión figura como «propuesta», no confirmada);
  guía 2.5.2 de Apple vía fuentes secundarias ([MacStories](https://www.macstories.net/linked/apples-app-store-guidelines-now-allow-executable-code-in-educational-apps-and-developer-tools/),
  [foro de Apple](https://developer.apple.com/forums/thread/835555)). No se consultó la página oficial de las guías.

## C.3 No comprobado

- No se compiló ni ejecutó la CLI, la app ni la extensión; el comportamiento descrito de denegación procede de README y
  código, no de una ejecución.
- No se leyeron completos todos los casos de las especificaciones afectadas ni todos los archivos del runtime; el
  inventario de §B.4 debe reinventariarse al iniciar.
- No se verificó si SEE admite retirar reglas de una especificación estable.
- No se midió el tamaño que añadiría un anfitrión Rust al puente iOS (CF-N11 es estimación).
- No se comprobó si las seis escenas de E-PG-12 dinámico dependen de escenarios simulados.
- Comportamiento de MSIX, aviso de red local de macOS 15+ y política de Flutter en la versión fijada 3.47.5.
- Las carencias de biblioteca de §A.8.2 se dedujeron de los nombres canónicos de `LIB.MODEL` y de búsquedas en `lib/` y
  `lang/`; no se comprobó en el motor si existe alguna operación equivalente con otro nombre fuera del corpus.
- No se midió el esfuerzo de PG-N; su tamaño XL es estimación a partir de lo que el README de codegen declara ausente.
