# Fase PG-5 · Biblioteca y HTTP — plan de ejecución

## 0. Metadatos

- Fase: `PG-5` · Biblioteca y HTTP. Requisitos `R-07` a `R-13`, con impacto en `R-17` (hábitos seguros), `R-19`
  (la app proyecta lo entregado) y `R-20` (ayuda granular). Capacidades principales `C-07` (adaptadores nativo y web),
  `C-08` (red/HTTP) y `C-10` (biblioteca); impacto en `C-06` (colecciones), `C-09` (HTTP con tareas), `C-15` y `C-16`.
- Decisiones rectoras: `ADR-02` (efectos grabables y reproducción sin autoridad externa) y `ADR-06` (presupuestos de
  coste y seguridad por característica). Decisiones vinculadas: `ADR-03` (tareas aisladas), `ADR-07` (errores como
  valores), `ADR-10` (cobertura web por capacidades declaradas), `ADR-12` (app de archivo único) y `ADR-13` (ayuda).
- Riesgos: `K-07` (permiso ampliado por ruta, DNS o redirección) y `K-09` (dependencias TLS/HTTP y blobs que exceden
  tamaño o memoria); vigilados además `K-02`, `K-06`, `K-13` y `K-15`. Experimentos: `E-PG-07` y la parte de red de
  `E-PG-09`.
- Fecha de preparación: `2026-10-28`, zona `America/Lima`.
- Revisión Git inicial: `7ea822d4350fe3d8f9cd760a8c34136c1bb1b0fe`; árbol limpio al comenzar.
- Rama única: `feature/agregar-ruta-de-especificacion` (`GIT-SINGLE-BRANCH`).
- Encargo documental de la persona (2026-10-28): «Crea el plan de ejecución para `4.7 PG-5 · Biblioteca y HTTP`,
  necesito que seas bastante detallado como para que las IAs no se pongan a alucinar. El plan debe ser a medida, no
  solo replicar patrones o arquitecturas de otros lenguajes, sino acotado al propósito educativo y fácil de leer de mi
  lenguaje de programación. Para velocidad de desarrollo las fases deben ejecutar la menor cantidad de test solo
  acotados a lo programado y al final una fase de ejecución de test pesados para dar conformidad general».
- Estado: plan detallado creado; **pendiente de revisión de la persona** (`PG-5.C02`). Crear este plan no inicia la
  fase ni autoriza ninguna iteración de §10 (`PHASE-STOP`). `PG-5.C01` sigue pendiente.
- Dependencias: `PG-2` cerrada (2026-10-26), `PG-3` con todos sus puntos y casillas marcados, `PG-4` cerrada por la
  persona el 2026-10-28 (commit `a1de5355`) con dos pendientes justificados que **condicionan esta fase**: tareas
  nativas en AOT no construidas (`PG-4.12.04`) y presupuesto de `PERF.SUITE.CORE` no alcanzado (1,2192× frente a
  1,02×). §1.2 y §3.5 dicen qué hace `PG-5` con cada uno.

### 0.1 Cinco constancias que rigen todo el plan

**1. Diseño a medida, educativo y legible.** `PG-5` no copia la API de ninguna biblioteca ajena (`fetch`, `requests`,
`reqwest`, `java.net.http`, `serde_json`, `JSON.parse`). Cada símbolo se diseña para que un estudiante lea el programa
en voz alta y entienda qué ocurre: los valores de la biblioteca son **inmutables**, cada operación hace **una sola
cosa visible**, los fallos esperables son **`Resultado`** y nunca excepciones, y **nada ocurre a escondidas** (sin
redirecciones automáticas, sin reintentos, sin cabeceras inventadas, sin proxies ni cookies implícitos). Todo se
construye sobre lo que PseudoLearn ya tiene: tabla de operaciones generada desde `LIB.MODEL` (`capabilityLibrary`),
capacidades no amplificables con derechos y generación, `ErrorES` con `Incierto`, `Resultado`/`Opcional` con
obligación de uso y `Propagar`, cinta `pseudolearn.tape/v1` con secretos redactados, `Aguardar` sobre efectos dentro
de unidades suspendibles, predicado `transferible` y anfitrión falso declarativo de los casos `see/1`. §3.1 registra
qué se toma y qué se rechaza de otros lenguajes; la misma tabla pasa a los README dueños (`AGENTS.md` §3).

**2. Velocidad: pruebas mínimas por iteración y pesadas solo al final.** Las iteraciones 1 a 5 de §10 ejecutan
**exclusivamente** las verificaciones ligeras de §7.1.1 que corresponden a lo que esa iteración programó: integridad
del corpus si tocó corpus, `cargo check` y tests unitarios **filtrados** de los módulos creados o tocados, Clippy y
`rust-checks` de los crates tocados, y `dart analyze`/límites solo de los archivos Dart tocados. **Todas** las pruebas
pesadas (conformidad `see conform`, diferencial VM/AOT, pruebas de integración de la CLI contra el servidor local,
baterías adversarias, Playwright en navegadores, `flutter test`, puente, `PERF.*` y las campañas `E-PG-07`/`E-PG-09`)
se ejecutan **únicamente en la iteración 6**, que da la conformidad general. Esto no relaja `PHASE-GREEN`: la fase no
se cierra sin la iteración 6 en verde. Nunca se ejecutan suites completas (§7.1.3).

**3. Red real fuera del corpus.** El corpus (`see conform`) **nunca** abre un socket ni resuelve un nombre: todo caso
de HTTP usa el anfitrión falso declarativo con respuestas derivadas de la regla. La red real solo se toca en pruebas
de integración del adaptador nativo y del adaptador Fetch, contra un **servidor de prueba local** que esta fase
construye, ligado a `127.0.0.1`/`[::1]`, sin Internet (`PG-5.07`). Ninguna prueba depende de DNS público, de un
certificado público ni de un servicio externo.

**4. Las dependencias de red no entran en el núcleo.** El motor (`packages/pseudolearn_engine`), el módulo Wasm y la
biblioteca del puente móvil (`apps/pseudolearn_app/native`) **no** ganan ninguna dependencia HTTP, TLS ni DNS: el
motor solo emite peticiones de efecto y valida respuestas, como ya hace con archivos. El transporte nativo vive en
`apps/pseudolearn_cli` y el transporte web en la página de pruebas del módulo Wasm. Así `PERF.ARTIFACT.SIZE` se
conserva por construcción (`PG-5.08`) y se demuestra con `cargo tree` y medición en la iteración 6.

**5. Espacio en disco.** El 2026-10-28 el volumen tenía **17 GiB libres de 228 GiB**. Antes de cada iteración, de
toda compilación `release` y de cada campaña, la IA aplica el protocolo de §13. Quedarse sin disco a mitad de una
compilación o campaña no es aceptable como causa de fallo.

### 0.2 Forma candidata

Todo nombre de tipo, función, método, variante de error, opción de CLI y valor por omisión de este plan (§3.3 y §3.4)
es **candidato**. La persona lo confirma o lo cambia en el punto de control `P1` (§10) antes de anclar el corpus; la
forma final la fija el corpus, no este documento (plan general §5.5). Si la persona cambia un nombre, la IA lo sustituye
en todo lo que redacte después sin reabrir lo demás. **`PG-5` no añade ninguna palabra reservada ni producción
gramatical**: todo lo nuevo son identidades de biblioteca (tipos incorporados, funciones y métodos), que es lo que
reduce el riesgo `K-02` y mantiene la fase en «biblioteca».

Documento transitorio de `docs/`. Desarrolla el [plan general](plan-ejecucion-proposito-general.md) y la
[hoja de ruta](../hoja-de-ruta-proposito-general.md). Ningún archivo fuera de `docs/` lo cita
(`DOC-NO-TRANSIENT-REFS`). Las decisiones aceptadas se trasladan a los `README.md` dueños y el comportamiento
observable al corpus, sin depender de este texto.

---

## 1. Punto de partida

Estado verificado en la revisión `7ea822d4`.

### 1.1 Lo que ya existe y `PG-5` reutiliza

| Pieza | Dónde | Qué aporta a `PG-5` |
|---|---|---|
| Tabla de operaciones de biblioteca como datos | `LIB.MODEL` `D2` (`capabilityLibrary.operations`: `identity`, `receiver`, `es`, `en`, `parameters`, `result`, `effect`, `fallible`); generada a Rust por `crates/pseudolearn_abi/build.rs` → `EFFECT_OPERATIONS` en `pseudolearn_abi/src/effect_operation.rs` | Las operaciones nuevas de red, bytes y JSON se añaden **como filas de datos** del corpus; el código Rust de la tabla se regenera (`GEN-NO-HAND-COPY`). Ya admite operaciones puras con receptor (`bytes_length`, `bytes_utf8` con `effect: false`) |
| Funciones incorporadas como datos | `LIB.MODEL` `D1` (`functions`: lexemas es/en, alias, parámetros, retorno); `LIB.CORE.TEXT`, `LIB.CORE.CONVERSION` | Las funciones de texto nuevas se añaden como filas de `D1` con su regla en `LIB.CORE.TEXT` |
| Clases de valor de efecto | `EffectValueKind` en `pseudolearn_abi/src/effect_operation.rs` (escrito a mano: `Integer`, `Boolean`, `Text`, `Bytes`, `TextList`, `Console`, `Arguments`, `Directory`, `File`, `Clock`, `Timer`) y su traducción de texto en `build.rs` | Se añaden las clases nuevas (§5); `capability_family()` gana la familia `network` |
| Capacidades no amplificables | `LANG.CAPABILITY.MODEL#R1`–`#R4`; `pseudolearn_runtime/src/capability_table.rs`, `effect_authority.rs`, `managed_capability.rs` | `RedCap` sigue el mismo modelo de ranura, generación, derechos y derivación sin amplificación que `DirectorioCap` |
| Errores portables con incertidumbre | `LIB.IO#R2` (`ErrorES` con `Codigo` e `Incierto`); `pseudolearn_runtime/src/io_error.rs`; `pseudolearn_abi/src/io_error_layout.rs` | Las variantes de red se **añaden a `ErrorES`** (D-PG5-05) |
| Confirmación en dos fases | `ENG.EXEC.EFFECT-COMMIT#R1`–`#R4` (`Committed`, `Failed`, `Uncertain`; solo lectura nunca `Uncertain`) | Clasificación de métodos HTTP de solo lectura y con potencial de mutación (`PG-5.05`) |
| Efectos resueltos sin anfitrión | `pseudolearn_runtime/src/local_effect.rs` | Precedente para validar la petición, el origen y el límite de pendientes **antes** de cruzar al anfitrión (la iteración 1 lo lee antes de redactar `LIB.HTTP`) |
| Cinta con secretos y presupuesto | `ENG.EFFECT.TAPE#R1`–`#R6`; `tape_privacy.rs`, `secret_policy.rs`, `tape_codec.rs`, `tape_replay.rs` | Cabeceras de credencial redactadas como `SecretHandle`; cuerpo de respuesta en la carga útil; `max_tape_bytes` (`ENG.LIMITS#R9`) |
| Efectos concurrentes | `ENG.EXEC.EFFECT-ORDER#R5`, `RT.HOST.INTERFACE#R5`, `API.EXECUTE#R6` (lista `pending_effects` con `task_id`; entrega en el orden que decide el anfitrión, grabado como `delivery_seq`) | Tres peticiones HTTP en tareas hijas sin sintaxis nueva: `Aguardar red.Enviar(p)` dentro de una unidad suspendible |
| Cancelación de tareas con efecto pendiente | `PG-4`: desenlace `abandoned` en la cinta (`tape_abandoned.rs`) | Una petición cuya tarea se cancela queda `abandoned`; el adaptador la aborta |
| Predicado `transferible` | `LANG.TASK.ISOLATION#R1`–`#R3` (`Bytes` y capacidades ya son transferibles) | Los tipos nuevos, inmutables, se declaran transferibles |
| Anfitrión falso declarativo | Clave `anfitrion` del esquema `packages/pseudolearn_spec/schemas/see-1.schema.json`; `pseudolearn_api/src/fake_host.rs`; `pseudolearn_runtime/src/memory_host*.rs` | Respuestas HTTP guionizadas derivadas de la regla; base de toda la conformidad sin red |
| Proveedor físico de la CLI | `apps/pseudolearn_cli/src/physical_host.rs` (despacho por `operation`), `physical_files.rs`, `physical_request.rs`, `physical_session.rs`, `physical_error.rs`; concesiones `--conceder`/`--grant` y `--archivos`/`--files`; `cap-std` | El adaptador HTTP nativo es un despachador hermano (`physical_network*.rs`) con la misma disciplina de concesión explícita |
| Batería adversaria con registro cerrado | `apps/pseudolearn_cli/tests/security_vectors.rs`, `tests/security_vector_registry.rs` (8 vectores de archivo y cinta, `E-PG-09` parte `PG-3`) | Modelo para la batería de red: cada vector registrado con su prueba y negativos del propio registro |
| AOT con anfitrión de memoria | `pseudolearn_aot_rt/src/effect_channel.rs` usa `MemoryHostProvider`; `pseudo run --nativo` intercambia `--effects-in`/`--effects-out` | En AOT, HTTP se ejecuta contra respuestas guionizadas y cinta, nunca contra la red (D-PG5-19) |
| Módulo Wasm y página de prueba | `crates/pseudolearn_wasm` (`WasmSession.call`, JSON exacto de enteros), `crates/pseudolearn_wasm/browser/` (`server.mjs`, `browser.test.mjs`, Playwright Core, pnpm) | Lugar del adaptador Fetch de referencia y de sus pruebas en navegador (D-PG5-18) |
| Negociación de capacidades | `pseudolearn_api/src/negotiation.rs` | Lugar donde un anfitrión declara qué garantías de red ofrece (capacidades web declaradas, `PG-5.06`) |
| Catálogo de ayuda y vista pública | `TOOL.SERVICE.CATALOG`, `API.PROGRAM.VIEW`; `pseudolearn_api/src/service_help*.rs`, `program_view_*.rs`; app `rust_help_projection.dart`, `rust_simulated_host.dart`, `rust_effect_gate.dart` | Fichas es/en de cada símbolo nuevo y proyección de los tipos nuevos (`C09`) |
| Campañas `pg_*` | `crates/pseudolearn_bench_worker/src/pg_*.rs` | Modelo para la campaña de coste `pg_http` (métrica candidata) |

### 1.2 Hechos que condicionan nombres y decisiones

1. **`Propagar` exige exactamente el mismo `E`** (`LANG.TYPES.RELATIONS#R4`). Si HTTP tuviera su propio tipo de error,
   un `SubProceso` que lee un archivo y luego hace una petición no podría usar `Propagar` en ambas líneas. Por eso los
   errores de red son **variantes nuevas de `ErrorES`** (D-PG5-05). JSON, que es puro y no es E/S, tiene su propio
   `ErrorJson` con línea y columna (D-PG5-11).
2. **El prefijo `Solicitar…` ya significa «pedir una capacidad al anfitrión»** (`SolicitarConsola`,
   `SolicitarDirectorio`, `SolicitarReloj`…). La operación que envía una petición HTTP **no** puede llamarse
   `Solicitar`: se propone `Enviar`/`send` como método de `RedCap`. `Canal.Enviar` ya existe, pero los métodos se
   resuelven por receptor; el precedente es `Cerrar` en `ArchivoCap`, `DirectorioCap` y `Canal`.
3. **`red` es una palabra española común** que un estudiante usará como identificador. El tipo de capacidad se llama
   `RedCap`/`NetworkCap`, en línea con `DirectorioCap`/`DirCap` y `ArchivoCap`/`FileCap` (capacidades sobre recursos
   externos). La iteración 1 comprueba en `LANG.LEXICAL.IDENTIFIER` y `LANG.PROFILE.VOCABULARY` si los nombres de tipo
   incorporados son reservados o solo se resuelven por contexto, y registra el resultado en §11. Si alguno de los
   nombres de §3.3 invalidara un programa válido de 2026, se detiene y se reporta (`CONFLICT-REPORT`, `K-02`).
4. **El vocabulario de permisos del manifiesto es cerrado** (`API.PROJECT.MANIFEST#R4`: `consola`, `argumentos`,
   `archivos_lectura`, `archivos_escritura`, `reloj`, `temporizador`). Añadir `red` es una edición oficial de esa regla
   (`SPEC-VERSION-FREEZE`). Un texto suelto sin manifiesto (la app) solo obtiene red por concesión del anfitrión.
5. **AOT no ejecuta tareas** (`PG-4.12.04` pendiente; rechazo `nativeTasksUnsupported`). Todo caso de `PG-5` que use
   `Tareas`/`Lanzar` divergirá en AOT por esa causa ajena. Los casos de HTTP **sin tareas** sí deben pasar en AOT.
6. **El ejecutable AOT no hace E/S real**: `pseudolearn_aot_rt` usa `MemoryHostProvider`. HTTP real queda fuera del
   sujeto nativo; `pseudo run --nativo` con permiso de red se rechaza con error de uso explícito (D-PG5-19).
7. **El presupuesto de `PERF.SUITE.CORE` ya está incumplido** desde `PG-4`. `PG-5` no lo empeora: su control de
   regresión es el binario del cierre de `PG-4` (`a1de5355`), no la revisión base de `PG-4` (§7.5).
8. **Genéricos entre módulos fuera de alcance**: el README del motor declara que «los genéricos de clases y variantes
   de usuario, y los que cruzan módulos, quedan fuera». El caso integrador de ENT-1 de la hoja de ruta habla de «una
   biblioteca genérica en inglés consumida desde programa español», y `PG-5.09` de «biblioteca bilingüe». §3.5
   (`CF-PG5-03`) lo reporta; este plan construye la biblioteca bilingüe **sin genéricos** salvo decisión contraria.
9. **Límites reales de tamaño** (archivos de reglas): motor, especificaciones y CLI `file_lines: 300`,
   `function_lines: 40`, `positional_parameters: 4`, `nesting_depth: 3`, `public_methods_per_class: 7`; app
   `file_lines: 250`, `build_method_lines: 30`, `positional_parameters: 3`, `public_methods_per_class: 5`. Nombres
   Rust de al menos tres caracteres y sin los componentes prohibidos (`data`, `obj`, `res`, `ret`, `val`, `buf`,
   `msg`, `err`, `info`, `item`, `tmp`…); `req` y `resp` no están en la lista, pero se evitan por legibilidad. En
   particular: nada de `json_data`, `http_obj`, `resp_buf`; se escribe `json_document`, `http_response_body`.
10. **Colisiones de nombres internos**: `apps/pseudolearn_cli/src/physical_request.rs` ya es la petición **de efecto**;
    todo archivo HTTP nuevo empieza por `network_` o `http_`. `pseudolearn_runtime` ya tiene `effect_*`, `tape_*`,
    `host_*`: la política de red se llama `network_policy*.rs`.
11. **Disco**: 17 GiB libres el 2026-10-28 (por debajo del objetivo de §13).

### 1.3 Lo que falta para cumplir `PG-5`

- Biblioteca estándar completa y auditada por familia (texto, bytes, números vigentes, colecciones, E/S, tiempo, JSON
  y tareas) con identidad canónica única y facetas es/en generadas y verificadas (`PG-5.01`).
- Capacidad de red, petición y respuesta HTTP inmutables, métodos explícitos y 4xx/5xx como respuesta (`PG-5.02`).
- Límites de bytes de transporte y decodificados, profundidad JSON, peticiones pendientes y tiempo externo
  (`PG-5.03`).
- Política de seguridad: TLS no desactivable, redirecciones dentro del permiso, credenciales retiradas al cambiar de
  origen, sin proxies del entorno y política contra SSRF (`PG-5.04`).
- Sin reintentos automáticos; estado incierto registrado (`PG-5.05`).
- Adaptador nativo elegido con evidencia y adaptador Fetch con capacidades declaradas (`PG-5.06`).
- Servidor de prueba local y corpus independiente de Internet (`PG-5.07`).
- `PERF.ARTIFACT.SIZE` conservado (`PG-5.08`).
- Casos integradores de ENT-1 (`PG-5.09`) y experimentos `E-PG-07`/`E-PG-09` red con métrica candidata (`PG-5.10`).

---

## 2. Lectura realizada

Revisión `7ea822d4`.

- [x] `AGENTS.md` y `README.md` de la raíz (§3.1 y §4.5 sobre `packages/` y `apps/`).
- [x] `docs/hoja-de-ruta-proposito-general.md`: §4.1 (`R-07`–`R-13`), §5 (`C-07`, `C-08`, `C-10`, casos integradores
  de ENT-1 y asignación de capacidades), §6.2 (fila de `PG-5`), §6.3 (`E-PG-07`, `E-PG-09`), `ADR-02`, `ADR-06`
  (fila HTTP/bytes/JSON y estrategia de adaptadores), §9.1 (`K-07`, `K-09`, `K-13`, `K-15`), §9.3 (STRIDE de HTTP,
  cinta y archivos).
- [x] `plan-ejecucion-proposito-general.md` (§2–§6) y `fase-pg-4-plan-ejecucion.md` como modelo y fuente de los
  pendientes heredados.
- [x] `README.md` y `architecture.yaml` de `packages/pseudolearn_engine` y de `apps/pseudolearn_cli`; README de
  `crates/pseudolearn_wasm`; límites de `apps/pseudolearn_app/architecture.yaml`.
- [x] Especificaciones (reglas leídas): `LIB.MODEL` (`D1`, `D2`, `D3`), `LIB.IO`, `LIB.TIME`, `LIB.CORE.TEXT`,
  `LIB.CORE.CONVERSION`, `LANG.CAPABILITY.MODEL`, `LANG.CAPABILITY.PURITY`, `LANG.TASK.ISOLATION`,
  `LANG.TYPES.RELATIONS`, `LANG.TYPES.TEXT`, `LANG.TYPES.VECTOR`, `LANG.TYPES.DICTIONARY`, `LANG.TYPES.ENUM`,
  `LANG.TYPES.RECORD`, `LANG.TYPES.GENERIC`, `LANG.MODULE.MODEL`, `LANG.MODULE.IMPORT`, `ENG.EFFECT.TAPE`,
  `ENG.EXEC.EFFECT-COMMIT`, `ENG.EXEC.EFFECT-ORDER`, `ENG.LIMITS`, `RT.HOST.INTERFACE`, `API.EXECUTE`,
  `API.PROJECT.MANIFEST`, `PERF.ARTIFACT.SIZE`, `TOOL.CLI.RUN`.
- [x] Código: `pseudolearn_abi/src/effect_operation.rs` y `build.rs`; listados de `pseudolearn_runtime/src`,
  `pseudolearn_library/src`, `pseudolearn_api/src`, `pseudolearn_aot_rt/src` (`effect_channel.rs`);
  `apps/pseudolearn_cli/src/physical_host.rs` y `native_run.rs`; listado de `apps/pseudolearn_app/lib/engine/rust/`.
- [ ] Pendiente para la iteración 1 (lectura obligatoria **antes** de redactar cada especificación; la IA marca esta
  casilla cuando los haya leído completos y anota en §11 lo que condicione el diseño): `LANG.LEXICAL.IDENTIFIER`,
  `LANG.PROFILE.VOCABULARY`, `LANG.SOURCE.POSITION` (convención de línea y columna para `ErrorJson`),
  `API.WIRE-FORMAT` (cómo viajan `Bytes` y los argumentos de efecto), `API.PROGRAM.VIEW`, `TOOL.SERVICE.CATALOG`,
  `TOOL.CLI.CONVENTIONS`, `DIAG.CATALOG`, `DIAG.MESSAGES`, `LIB.CORE.MATH`, `LIB.CORE.ROUNDING`, `MEM.VALUE.COPY`,
  `LANG.CONTROL.FOR-EACH` (iteración de `Diccionario` y orden de claves), el README de `packages/pseudolearn_spec`,
  el esquema `see-1.schema.json` (clave `anfitrion` y si un caso puede restringir sujetos), `local_effect.rs`,
  `host_validation.rs`, `memory_host.rs`, `fake_host.rs` y `negotiation.rs`.

---

## 3. Decisiones de diseño

### 3.1 Qué se toma y qué se rechaza de otros lenguajes (`AGENTS.md` §3)

| Referencia | Qué se toma (encaja con PseudoLearn) | Qué se rechaza y qué se construye a medida |
|---|---|---|
| `fetch` (web) y `reqwest`/`requests` | Un estado HTTP 4xx/5xx es una respuesta, no un error; el cuerpo se lee explícitamente como bytes o texto | Se rechazan promesas, `response.ok` implícito como filtro, `raise_for_status`, sesiones con cookies, redirecciones automáticas, reintentos y lectura perezosa de flujos. A medida: `Aguardar red.Enviar(peticion)` devuelve `Resultado<RespuestaHttp, ErrorES>`; `EsExito()` es una consulta explícita |
| Constructores encadenados (`Request.Builder`) | Construir la petición paso a paso, una propiedad por llamada | Se rechaza el constructor mutable. A medida: `PeticionHttp` es un **valor inmutable**; `p.ConCabecera(n, v)` devuelve una petición nueva, así la petición es transferible entre tareas y se puede mostrar en la app como un valor |
| Capacidades de objeto (Capsicum, WASI) | Autoridad explícita sobre un conjunto cerrado de orígenes; atenuación sin amplificación | Se rechaza el acceso ambiental a la red, `cwd`, variables de entorno, proxies y almacenes de certificados del programa. A medida: `RedCap` con lista de orígenes concedida por el anfitrión y `red.Limitar(origen)` que solo reduce |
| `serde_json`, `JSON.parse` | Gramática estricta de RFC 8259, números exactos como texto hasta que se consultan | Se rechazan la conversión a objetos del lenguaje por reflexión, los atributos de mapeo y el `any` dinámico. A medida: `ValorJson` inmutable consultado con `Tipo()`, `Campo()`, `Elemento()` y `ComoEntero()`/`ComoCadena()`… que devuelven `Opcional`; claves duplicadas rechazadas; `ErrorJson` con línea y columna para enseñar dónde está el error |
| Árboles JSON con nodos en el montón | Recorrer el documento como un árbol | Se rechaza un objeto del montón por nodo. A medida: un documento es **un solo bloque inmutable** con sus nodos aplanados; un `ValorJson` es una vista `(bloque, nodo)`: sin punteros internos, raíces triviales, igual en VM y AOT (D-PG5-12) |
| Seguimiento de redirecciones de los clientes HTTP | La semántica de 301/302/303/307/308 y la retirada de credenciales al cambiar de origen | Se rechaza seguirlas en silencio. A medida: una 3xx es una respuesta; `PeticionHttp.Redirigida(respuesta)` construye **explícitamente** la siguiente petición con la política segura, y la capacidad comprueba el nuevo origen al enviarla (D-PG5-08) |
| Python `str`, Java `String` | Operaciones de texto de uso diario (subcadena, contiene, dividir, unir, recortar, reemplazar) | Se rechazan índices negativos, rebanadas con paso, expresiones regulares, formato con plantillas y mayúsculas dependientes de configuración regional. A medida: conjunto cerrado de nueve funciones por puntos de código, con trampas tipadas ya existentes (D-PG5-13) |
| Bibliotecas estándar enormes | Nada | `SCOPE-YAGNI`: cada símbolo nuevo lo exige un punto de `PG-5` o un caso integrador de ENT-1; la matemática ampliada sigue fuera (`FUT-14`) |

### 3.2 Decisiones técnicas

| Decisión | Opciones | Criterio | Elección | Reversión |
|---|---|---|---|---|
| `D-PG5-01` Dónde vive cada familia en el corpus | (A) Un único `LIB.STD`; (B) un contrato por familia | Un dueño por responsabilidad; tamaño legible | **B**: texto en `LIB.CORE.TEXT` (edición oficial), bytes en `LIB.CORE.BYTES` (nueva), JSON en `LIB.JSON` (nueva), cliente en `LIB.HTTP` (nueva), seguridad de red en `LIB.HTTP.POLICY` (nueva); firmas siempre como filas de `LIB.MODEL` `D1`/`D2` | Ninguna |
| `D-PG5-02` Identidad canónica y facetas | (A) Tablas por idioma; (B) una fila por símbolo con `identity`, `es` y `en` | Ya existe (B) en `D1`/`D2`; la generación evita deriva | **B** más una regla nueva de `LIB.MODEL`: cada símbolo tiene identidad única, ambas facetas, misma firma, mismo efecto y una ficha de ayuda; `see validate` lo comprueba con caso negativo (`PG-5.01`) | Ninguna |
| `D-PG5-03` Palabras reservadas | Añadir reservadas para HTTP/JSON; solo identidades de biblioteca | `K-02`; programas 2026 válidos | **Cero reservadas nuevas** | Ninguna |
| `D-PG5-04` Capacidad de red | (A) Red global; (B) capacidad por origen; (C) capacidad con conjunto de orígenes atenuable | Denegación por defecto, enseñable, no amplificable | **C**: `SolicitarRed()` → `Resultado<RedCap, ErrorES>` con los orígenes que concedió el anfitrión; `red.Limitar(origen)` → `Resultado<RedCap, ErrorES>` con un subconjunto; no hay consulta de la lista de orígenes (`SCOPE-YAGNI`); `red.Cerrar()` como las demás capacidades | Permitir patrones de subdominio solo con ADR |
| `D-PG5-05` Tipo de error de red | (A) `ErrorRed` propio; (B) variantes nuevas de `ErrorES` | `Propagar` exige el mismo `E` (§1.2.1); un programa de archivo + red debe leerse sin conversiones | **B**: `ErrorES` gana `UrlInvalida`, `PeticionInvalida`, `DestinoDenegado`, `ConexionFallida`, `CertificadoInvalido`, `RespuestaInvalida`, `LimiteExcedido` y `RedireccionDenegada`; se reutilizan `PermisoDenegado`, `TiempoAgotado`, `Interrumpido`, `CapacidadCerrada` y `Utf8Invalido` | Ninguna sin ADR |
| `D-PG5-06` Forma de la petición | (A) Varios argumentos en `Enviar`; (B) valor `PeticionHttp` inmutable | Legibilidad, transferibilidad, proyección en la app | **B**: `PeticionHttp(MetodoHttp.GET, url)` y métodos puros `ConCabecera`, `ConCuerpo` (bytes), `ConCuerpoTexto` (UTF-8, sin `Content-Type` implícito), `ConLimiteRespuesta` (bytes, solo reduce) y `ConTiempoMaximo` (ns, solo reduce). Nunca fallan: la validación ocurre en `Enviar` (D-PG5-09) | Ninguna |
| `D-PG5-07` Métodos HTTP | Cadena libre; enumerado cerrado | «Métodos explícitos»; sin métodos peligrosos | **Enumerado incorporado `MetodoHttp`/`HttpMethod`** con `GET`, `HEAD`, `POST`, `PUT`, `PATCH`, `DELETE`, **misma grafía en ambos perfiles** (son nombres del protocolo, no vocabulario). Sin `OPTIONS`, `CONNECT`, `TRACE` | Añadir `OPTIONS` si un caso lo pide |
| `D-PG5-08` Redirecciones | (A) Seguir automáticamente con política; (B) nunca seguir, ayuda explícita | Nada a escondidas, un efecto por operación, política en un solo sitio y paridad nativo/web | **B**: los adaptadores nunca siguen redirecciones; una 3xx es una respuesta con `Cabecera("location")`. `PeticionHttp.Redirigida(respuesta)` (pura) → `Resultado<PeticionHttp, ErrorES>` aplica la política (§3.4.5) y `Enviar` comprueba el origen nuevo contra la capacidad. Así ninguna redirección sale del permiso y la política es una sola función del runtime, probada en el corpus | (A) solo si la persona lo pide en `P1`; exigiría registrar cada salto en la cinta |
| `D-PG5-09` Validación de la petición | En el constructor; en `Enviar` antes de cruzar al anfitrión | Constructores que no fallan son más legibles; un solo punto de validación | **En `Enviar`, en el motor y antes del anfitrión**, con el mismo mecanismo de `local_effect.rs` (efecto resuelto localmente como `Failed`, grabado y reproducible): URL, cabeceras, origen, límite de pendientes y capacidad cerrada | Ninguna |
| `D-PG5-10` Unidades de tiempo | Milisegundos; nanosegundos | Coherencia con `LIB.TIME` (`Ahora` y `Esperar` en ns) | **Nanosegundos**, como `LIB.TIME` | Persona en `P1` |
| `D-PG5-11` Error de JSON | `ErrorES`; `ErrorJson` propio | JSON es puro y analizar no es E/S; enseñar la posición del error | **`ErrorJson`/`JsonError`** con `Codigo` (enumerado `CodigoErrorJson`), `Linea` y `Columna` según `LANG.SOURCE.POSITION`. Los programas que combinan E/S y JSON tratan el `ErrorJson` con `Segun` (es lo que enseña «validar») | Ninguna |
| `D-PG5-12` Representación de JSON | Árbol de objetos; bloque aplanado inmutable con vistas | Raíces y paridad VM/AOT triviales; transferible gratis; principio 4 del motor | **Bloque único inmutable** (`json_layout.rs` en `pseudolearn_abi`): tabla de nodos con clase, inicio y fin, y almacén de texto; `ValorJson` = vista `(asa del bloque, índice de nodo)`. `Campo` es lineal en las entradas del objeto; `ConCampo`/`ConElemento` copian el documento (coste declarado en README y ficha) | Índice de claves solo si `PERF.PG.HTTP`/JSON lo exige con medición |
| `D-PG5-13` Funciones de texto | Ninguna; conjunto cerrado; biblioteca amplia | Casos de ENT-1 y enseñanza básica | **Conjunto cerrado de nueve** (§3.3.1), por puntos de código, sin normalización, sin regionalización, sin mayúsculas/minúsculas | Mayúsculas ASCII si la persona lo pide en `P1` |
| `D-PG5-14` Bytes | Mutables; inmutables con operaciones puras | `LANG.TASK.ISOLATION#R1` ya los trata como inmutables | **Inmutables**: `BytesDesdeTexto(c)`, `b.Segmento(inicio, cantidad)`, `b.Unir(otro)` | Ninguna |
| `D-PG5-15` Colecciones, números, E/S, tiempo y tareas | Añadir símbolos; auditar y completar solo lo exigido | `SCOPE-YAGNI`; matemática ampliada fuera de alcance | **Auditoría de facetas y fichas sin símbolos nuevos.** Si al escribir un caso integrador falta una operación de colección, la IA se detiene y la propone a la persona; no la añade sola. Las reversiones abiertas por `PG-4` (`Cancelar t`, ramas de envío en `Elegir`, métodos suspendibles) **no** se activan: `PG-5` no las necesita (`ConTiempoMaximo` cubre el plazo) | Persona |
| `D-PG5-16` Límites | Fijos en el lenguaje; configurados por el anfitrión | `ENG.LIMITS#R1`: los límites son del entorno | **Del anfitrión** (§3.4.6), con mínimos garantizados y el valor por petición solo puede reducirlos. Superarlos con datos externos es `Error(LimiteExcedido)`, nunca trampa: es un fallo esperable | Ninguna |
| `D-PG5-17` Biblioteca HTTP nativa | `reqwest` (bloqueante), `ureq`, `hyper`+`rustls` directo, cliente propio | `ADR-06`: biblioteca mantenida detrás de un puerto; cliente/TLS propio rechazado | **Se decide en `PG-5.06.01` con la tabla de criterios de §3.4.8**, medida en la iteración 4. Candidatos a evaluar: `ureq` y `reqwest` con `rustls`. Ninguno está aprobado de antemano; la IA no da por cierta ninguna API, opción o versión sin leer la documentación de la versión exacta | Elegir el segundo candidato si el primero falla un criterio obligatorio |
| `D-PG5-18` Dónde viven los adaptadores | Dentro del motor; en los consumidores de la API | Constancia 4: ninguna dependencia de red en motor, Wasm ni puente | **Nativo** en `apps/pseudolearn_cli` (archivos `physical_network*.rs`); **web** en `crates/pseudolearn_wasm/browser/` (`fetch_host.mjs`), que ya usa pnpm y Playwright | Mover el adaptador web a la extensión en `PG-6B` |
| `D-PG5-19` HTTP en AOT | HTTP real en el ejecutable; solo anfitrión de memoria y cinta | El runtime nativo usa `MemoryHostProvider`; `unsafe` y red en `aot_rt` no están declarados | **Anfitrión de memoria y cinta**: los casos sin tareas pasan en AOT; `pseudo run --nativo` con red concedida es error de uso explícito. No se anuncia HTTP real nativo | Fase futura con ADR |
| `D-PG5-20` Servidor de prueba | En Node; en Rust; dos servidores | Un solo comportamiento guionizado para nativo y web | **Uno en Rust**, como subcomando de la herramienta `xtask` de la CLI (`cargo xtask http-test-server`), ligado a loopback, con certificados de prueba generados en tiempo de prueba y nunca versionados; las pruebas Rust y Playwright lo lanzan | Ninguna |
| `D-PG5-21` Concurrencia del adaptador nativo | Secuencial; hilos acotados | `RT.HOST.INTERFACE#R5`: el orden de entrega es entrada grabada | **Hilos acotados por el límite de pendientes** (`std::thread::scope`) dentro del adaptador; entrega en orden de finalización; el orden queda en la cinta como `delivery_seq`. Ningún hilo es visible al lenguaje | Secuencial si la biblioteca elegida no es segura entre hilos |
| `D-PG5-22` Evolución de la app | Esperar a `PG-B`; sincronizar datos ahora | `R-19`, `C09` | **Datos ahora**: fichas, proyección de tipos y anfitrión simulado que deniega red por omisión y sirve respuestas declaradas por el ejercicio. Red real en la app queda fuera de `PG-5` | Ninguna |

### 3.3 Biblioteca candidata (se confirma en `P1`)

Identidad = valor de `identity` en `LIB.MODEL`. «Puro» = `effect: false` (admitido en `Funcion`); «Efecto» = `effect:
true`. «Falible» indica `Resultado`.

#### 3.3.1 Texto (`LIB.CORE.TEXT`, filas de `D1`)

| Identidad | `es` | `en` | Firma | Notas |
|---|---|---|---|---|
| `substring` | `Subcadena` | `substring` | `(Cadena, Entero inicio, Entero cantidad) → Cadena` | Trampa `stringPositionOutOfRange` si el intervalo sale de la cadena; `cantidad` 0 da `""` |
| `contains` | `Contiene` | `contains` | `(Cadena, Cadena) → Logico` | Parte vacía ⇒ `Verdadero` |
| `positionOf` | `PosicionDe` | `indexOf` | `(Cadena, Cadena) → Opcional<Entero>` | Primera aparición por punto de código; parte vacía ⇒ `Algo(0)` |
| `startsWith` | `EmpiezaCon` | `startsWith` | `(Cadena, Cadena) → Logico` | — |
| `endsWith` | `TerminaCon` | `endsWith` | `(Cadena, Cadena) → Logico` | — |
| `replaceAll` | `Reemplazar` | `replace` | `(Cadena, Cadena buscado, Cadena nuevo) → Cadena` | Todas las apariciones, de izquierda a derecha, sin solapes; `buscado` vacío ⇒ cadena sin cambios |
| `split` | `Dividir` | `split` | `(Cadena, Cadena separador) → Vector<Cadena>` | Separador vacío ⇒ trampa `emptySeparator` (código nuevo); `""` ⇒ vector con un elemento `""` |
| `join` | `Unir` | `join` | `(Vector<Cadena>, Cadena) → Cadena` | Vector vacío ⇒ `""` |
| `trim` | `Recortar` | `trim` | `(Cadena) → Cadena` | Solo quita U+0020, U+0009, U+000A y U+000D de ambos extremos: sin tablas Unicode |

#### 3.3.2 Bytes (`LIB.CORE.BYTES`, filas de `D2` con `effect: false`)

| Identidad | `es` | `en` | Firma |
|---|---|---|---|
| `bytes_from_text` | `BytesDesdeTexto` | `bytesFromText` | `(Cadena) → Bytes` (UTF-8) |
| `bytes_segment` | `Segmento` | `segment` | `Bytes.(Entero inicio, Entero cantidad) → Bytes`; trampa `bytesRangeOutOfBounds` (código nuevo) |
| `bytes_join` | `Unir` | `join` | `Bytes.(Bytes) → Bytes` |

Se conservan `Bytes()`, `Longitud`, `En` y `TextoUtf8`.

#### 3.3.3 JSON (`LIB.JSON`, filas de `D2` con `effect: false`)

| Identidad | `es` | `en` | Firma |
|---|---|---|---|
| `json_parse` | `AnalizarJson` | `parseJson` | `(Cadena) → Resultado<ValorJson, ErrorJson>` |
| `json_text` | `TextoJson` | `jsonText` | `(ValorJson) → Cadena` (forma compacta canónica, §3.4.4) |
| `json_null`, `json_boolean`, `json_integer`, `json_real`, `json_string` | `JsonNulo`, `JsonLogico`, `JsonEntero`, `JsonReal`, `JsonCadena` | `jsonNull`, `jsonBoolean`, `jsonInteger`, `jsonReal`, `jsonString` | Constructores de valores simples |
| `json_array`, `json_object` | `ArregloJson`, `ObjetoJson` | `jsonArray`, `jsonObject` | `() → ValorJson` vacíos |
| `json_kind` | `Tipo` | `kind` | `ValorJson.() → TipoJson` |
| `json_as_boolean`, `json_as_integer`, `json_as_real`, `json_as_text` | `ComoLogico`, `ComoEntero`, `ComoReal`, `ComoCadena` | `asBoolean`, `asInteger`, `asReal`, `asText` | `ValorJson.() → Opcional<…>` |
| `json_length` | `Longitud` | `length` | `ValorJson.() → Entero` (elementos o campos; 0 en escalares) |
| `json_element` | `Elemento` | `element` | `ValorJson.(Entero) → Opcional<ValorJson>` |
| `json_field` | `Campo` | `field` | `ValorJson.(Cadena) → Opcional<ValorJson>` |
| `json_keys` | `Claves` | `keys` | `ValorJson.() → Vector<Cadena>` en orden del documento |
| `json_with_element` | `ConElemento` | `withElement` | `ValorJson.(ValorJson) → ValorJson`; sobre un no arreglo es trampa `jsonKindMismatch` (código nuevo) |
| `json_with_field` | `ConCampo` | `withField` | `ValorJson.(Cadena, ValorJson) → ValorJson`; reemplaza en su posición si existe; sobre un no objeto, `jsonKindMismatch` |

Tipos incorporados: `ValorJson`/`JsonValue`; enumerado `TipoJson`/`JsonKind` con miembros `Nulo, Logico, JsonNumero,
Cadena, Arreglo, Objeto` / `Null, Boolean, JsonNumber, String, Array, Object`; `ErrorJson`/`JsonError` con `Codigo`,
`JsonLinea`, `JsonColumna` / `code`, `jsonLine`, `jsonColumn`; enumerado `CodigoErrorJson`/`JsonErrorCode` con `SintaxisInvalida`,
`FinInesperado`, `ClaveDuplicada`, `ProfundidadExcedida`, `EscapeInvalido`, `ContenidoSobrante` / `InvalidSyntax`,
`UnexpectedEnd`, `DuplicateKey`, `DepthExceeded`, `InvalidEscape`, `TrailingContent`.

#### 3.3.4 Red y HTTP (`LIB.HTTP`, `LIB.HTTP.POLICY`, filas de `D2`)

| Identidad | `es` | `en` | Firma | Efecto |
|---|---|---|---|---|
| `request_network` | `SolicitarRed` | `requestNetwork` | `() → Resultado<RedCap, ErrorES>` | Efecto |
| `network_restrict` | `Limitar` | `restrict` | `RedCap.(Cadena origen) → Resultado<RedCap, ErrorES>` | Efecto (como `Subdirectorio`) |
| `network_send` | `Enviar` | `send` | `RedCap.(PeticionHttp) → Resultado<RespuestaHttp, ErrorES>` | Efecto; con `Aguardar` dentro de unidad suspendible es concurrente |
| `network_close` | `Cerrar` | `close` | `RedCap.() → Resultado<Logico, ErrorES>` | Efecto |
| `http_request_new` | `PeticionHttp` | `HttpRequest` | `(MetodoHttp, Cadena url) → PeticionHttp` | Puro |
| `http_with_header` | `ConCabecera` | `withHeader` | `PeticionHttp.(Cadena, Cadena) → PeticionHttp` | Puro |
| `http_with_body` | `ConCuerpo` | `withBody` | `PeticionHttp.(Bytes) → PeticionHttp` | Puro |
| `http_with_text_body` | `ConCuerpoTexto` | `withTextBody` | `PeticionHttp.(Cadena) → PeticionHttp` | Puro |
| `http_with_response_limit` | `ConLimiteRespuesta` | `withResponseLimit` | `PeticionHttp.(Entero bytes) → PeticionHttp` | Puro |
| `http_with_timeout` | `ConTiempoMaximo` | `withTimeout` | `PeticionHttp.(Entero ns) → PeticionHttp` | Puro |
| `http_redirected` | `Redirigida` | `redirected` | `PeticionHttp.(RespuestaHttp) → Resultado<PeticionHttp, ErrorES>` | Puro |
| `http_status` | `Estado` | `status` | `RespuestaHttp.() → Entero` | Puro |
| `http_is_success` | `EsExito` | `isSuccess` | `RespuestaHttp.() → Logico` (200–299) | Puro |
| `http_header` | `Cabecera` | `header` | `RespuestaHttp.(Cadena) → Opcional<Cadena>` (nombre sin distinguir mayúsculas ASCII; varias apariciones se unen con `", "`) | Puro |
| `http_header_names` | `NombresCabeceras` | `headerNames` | `RespuestaHttp.() → Vector<Cadena>` (minúsculas, orden de llegada, sin repetir) | Puro |
| `http_body` | `Cuerpo` | `body` | `RespuestaHttp.() → Bytes` | Puro |
| `http_text_body` | `CuerpoTexto` | `textBody` | `RespuestaHttp.() → Resultado<Cadena, ErrorES>` (`Utf8Invalido`) | Puro |
| `http_final_url` | `Url` | `url` | `RespuestaHttp.() → Cadena` | Puro |

Tipos incorporados: `RedCap`/`NetworkCap`, `PeticionHttp`/`HttpRequest`, `RespuestaHttp`/`HttpResponse`, enumerado
`MetodoHttp`/`HttpMethod`. Permiso nuevo del vocabulario cerrado: `red`/`network`.

Ejemplo candidato (perfil `es`; no normativo, solo para que la IA entienda la intención y la legibilidad buscada):

```text
SubProceso Suspendible Descargar(red Como RedCap, url Como Cadena) Como Resultado<Cadena, ErrorES>
Definir peticion Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, url);
Definir respuesta Como RespuestaHttp <- Propagar Aguardar red.Enviar(peticion);
Si No respuesta.EsExito() Entonces
Retornar Exito("estado " + ATexto(respuesta.Estado()));
FinSi
Retornar respuesta.CuerpoTexto();
FinSubProceso
Algoritmo Main
Definir red Como RedCap <- Propagar SolicitarRed();
Tareas fallo
Definir a Como Tarea<Cadena> <- Lanzar Descargar(red, "https://127.0.0.1:8443/uno");
Definir b Como Tarea<Cadena> <- Lanzar Descargar(red, "https://127.0.0.1:8443/dos");
Escribir Aguardar a;
Escribir Aguardar b;
FinTareas
Segun fallo Hacer
Nada: Escribir "listo";
Algo(problema): Escribir problema.Primero.Codigo;
FinSegun
FinAlgoritmo
```

La IA comprueba en la iteración 1 que este programa respeta la gramática vigente (operadores, `Si No`, concatenación,
`Propagar` en la raíz); si algo no encaja, corrige el ejemplo, nunca la gramática.

### 3.4 Modelo semántico que el corpus debe expresar

Cada enunciado tiene un ID de trabajo que la iteración 1 convierte en reglas `R<n>` de la especificación indicada. La
IA **no inventa semántica fuera de esta lista**; si algo falta, se detiene y lo reporta (`CONFLICT-REPORT`).

#### 3.4.1 Facetas e identidad → `LIB.MODEL`

- `M1` Cada símbolo de biblioteca tiene una identidad única y estable; sus formas `es` y `en` (y alias) nombran la
  misma identidad, con la misma firma, el mismo efecto y la misma falibilidad.
- `M2` Dentro de un perfil, dos símbolos sin receptor no comparten forma; con receptor, la pareja (receptor, forma)
  es única (precedente `Cerrar`).
- `M3` Cada identidad tiene una ficha de ayuda en ambos perfiles (`TOOL.SERVICE.CATALOG`); la falta de una ficha o de
  una faceta es un error de validación del corpus, con caso negativo.
- `M4` Las familias de la biblioteca estándar de ENT-1 son: texto, bytes, números vigentes, colecciones, E/S, tiempo,
  JSON, red y tareas. Cada identidad declara su familia (campo nuevo `family` en las filas) para la auditoría.

#### 3.4.2 Texto → `LIB.CORE.TEXT`

- `T1` Las nueve funciones de §3.3.1 operan por puntos de código, sin normalizar ni depender de configuración
  regional, y nunca modifican su argumento.
- `T2` Los bordes de §3.3.1 (parte vacía, separador vacío, intervalo fuera de rango, vector vacío, recorte de los
  cuatro caracteres) son normativos.
- `T3` Las cadenas creadas cuentan celdas como cualquier cadena (`ENG.LIMITS#R2`).

#### 3.4.3 Bytes → `LIB.CORE.BYTES`

- `B1` `Bytes` es inmutable. `BytesDesdeTexto` codifica en UTF-8 sin BOM; `Segmento` y `Unir` devuelven secuencias
  nuevas; `Segmento` fuera de rango atrapa `bytesRangeOutOfBounds` en el sitio de la llamada.
- `B2` `Longitud` de `Bytes()` es 0; `Segmento(0, 0)` de cualquier secuencia es `Bytes()`.

#### 3.4.4 JSON → `LIB.JSON`

- `J1` `AnalizarJson` acepta exactamente la gramática JSON estricta: un valor, espacios solo U+0020/U+0009/U+000A/
  U+000D, sin BOM, sin comentarios, sin comas finales, sin `NaN`/`Infinity`, escapes `\"` `\\` `\/` `\b` `\f` `\n`
  `\r` `\t` `\uXXXX`, pares sustitutos válidos y sustitutos sueltos rechazados (`EscapeInvalido`).
- `J2` Una clave repetida en un mismo objeto es `ClaveDuplicada` (comparación de puntos de código exacta, sin NFC).
- `J3` La profundidad de anidación (arreglos y objetos) no supera el límite del anfitrión (§3.4.6); al superarlo,
  `ProfundidadExcedida`, sin recursión del anfitrión (`ENG.LIMITS#R7`).
- `J4` El error informa el primer problema en orden de lectura con su línea y columna según `LANG.SOURCE.POSITION`.
- `J5` Los números se conservan como su texto. `ComoEntero` devuelve `Algo` solo si el texto no tiene fracción ni
  exponente y cabe en el intervalo de `Entero`; `ComoReal` devuelve el binario64 con redondeo correcto (reutiliza la
  conversión de `LIB.CORE.CONVERSION`) o `Nada` si no es finito. `ComoX` sobre un tipo distinto devuelve `Nada`.
- `J6` `Campo` busca la clave exacta; `Elemento` usa índice desde cero y devuelve `Nada` fuera de rango (no atrapa: un
  documento externo puede no tener el elemento). `Claves` conserva el orden del documento.
- `J7` `TextoJson` produce la forma compacta canónica: sin espacios, claves en orden del documento, cadenas con los
  escapes mínimos (`\"`, `\\` y controles < U+0020 como `\uXXXX` en minúsculas, salvo `\b\f\n\r\t`), números como su
  texto original y los construidos con `JsonEntero`/`JsonReal` en el formato de salida del lenguaje. Para todo
  documento válido `d`, `AnalizarJson(TextoJson(d))` reconstruye un valor igual (propiedad, `see` de propiedades).
- `J8` `ValorJson`, `TipoJson`, `ErrorJson` y `CodigoErrorJson` son transferibles e inmutables; igualdad estructural
  `=` entre `ValorJson` no se define en `PG-5` (`SCOPE-YAGNI`): usar `TextoJson` para comparar.

#### 3.4.5 HTTP → `LIB.HTTP` y `LIB.HTTP.POLICY`

- `H1` `SolicitarRed()` devuelve una capacidad con los orígenes concedidos; sin permiso `red`, `PermisoDenegado`.
  `Limitar(origen)` acepta solo un origen ya incluido y nunca amplía (`LANG.CAPABILITY.MODEL#R3`); otro origen es
  `DestinoDenegado`.
- `H2` Un origen es esquema (`https`; `http` solo si el anfitrión lo concedió como origen local de prueba), host en
  minúsculas ASCII y puerto efectivo. Hosts no ASCII, URL con credenciales (`usuario@`), sin host o con esquema
  distinto son `UrlInvalida`. El fragmento `#…` nunca se envía.
- `H3` `Enviar` valida en el motor, en este orden y antes del anfitrión: capacidad abierta (`CapacidadCerrada`), URL
  (`UrlInvalida`), origen dentro de la capacidad (`DestinoDenegado`), cabeceras (nombre de token HTTP, valor sin CR,
  LF ni NUL, y ninguna de las prohibidas `host`, `content-length`, `transfer-encoding`, `connection`, `upgrade`,
  `te`, `trailer`, `keep-alive`, `proxy-*`, `cookie`, `set-cookie`, `accept-encoding`) (`PeticionInvalida`), cuerpo
  en `GET`/`HEAD` (`PeticionInvalida`) y peticiones pendientes por debajo del límite (`LimiteExcedido`). Cada fallo
  local es un efecto `Failed` grabado (D-PG5-09).
- `H4` Una respuesta con cualquier estado de 100 a 599 recibida completa es `Exito(respuesta)`; 4xx/5xx y 3xx **no**
  son errores. Las 1xx informativas las consume el adaptador; `101` y estados fuera de rango son `RespuestaInvalida`.
- `H5` Fallos de transporte: nombre no resuelto o conexión rechazada/cortada ⇒ `ConexionFallida`; certificado
  inválido, caducado, de otro host o sin cadena de confianza ⇒ `CertificadoInvalido`; plazo superado ⇒
  `TiempoAgotado`; resolución hacia una dirección no permitida ⇒ `DestinoDenegado`.
- `H6` Clasificación de confirmación (`ENG.EXEC.EFFECT-COMMIT`): `GET` y `HEAD` son de solo lectura y nunca
  `Uncertain`. `POST`, `PUT`, `PATCH` y `DELETE` tienen potencial de mutación: si el fallo ocurre después de empezar a
  enviar la petición y antes de recibir la respuesta completa, el resultado es `Uncertain` con `Incierto =
  Verdadero`; antes de enviar, `Failed` con `Incierto = Falso`.
- `H7` Ningún componente reintenta automáticamente una petición, de ningún método (`PG-5.05`). La cancelación de la
  tarea que espera deja el efecto `abandoned` y el adaptador aborta la conexión; no se afirma que el servidor no lo
  procesó.
- `H8` El adaptador nunca sigue redirecciones, nunca añade cookies, nunca usa proxies del entorno (`HTTP_PROXY`,
  `HTTPS_PROXY`, `ALL_PROXY`, `NO_PROXY` ni configuración del sistema) y nunca permite desactivar la validación TLS
  desde el programa. Solo la configuración del anfitrión puede añadir una raíz de confianza de prueba.
- `H9` `Redirigida(respuesta)`: exige estado 301, 302, 303, 307 o 308 y cabecera `location` (si no,
  `RedireccionDenegada`); resuelve `location` relativa contra la URL final; rechaza bajar de `https` a `http`
  (`RedireccionDenegada`); con 303, o con 301/302 sobre `POST`, produce `GET` sin cuerpo; con 307/308 conserva método y
  cuerpo; si el origen cambia, retira `authorization` y toda cabecera clasificada como credencial. El origen nuevo lo
  comprueba `Enviar`, nunca `Redirigida`.
- `H10` Política contra SSRF del adaptador nativo: resuelve el nombre una sola vez, comprueba **todas** las
  direcciones y conecta solo a una dirección comprobada. Deniega loopback, privadas (RFC 1918), enlace local
  (incluida `169.254.169.254`), únicas locales, multidifusión, no especificadas y las IPv4 mapeadas en IPv6 de esos
  rangos, salvo que el origen se haya concedido como **local de prueba**. Formas numéricas alternativas de IP
  (decimal, octal, hexadecimal) en el host son `UrlInvalida`.
- `H11` La respuesta registra en la cinta estado, cabeceras, cuerpo y URL final. En la petición, `authorization` y
  las cabeceras clasificadas como credencial se sustituyen por `SecretHandle` (`ENG.EFFECT.TAPE#R5`); la cinta
  declara que la respuesta se guarda completa para poder reproducirla. `capability_kind` vale `network`.
- `H12` `RedCap`, `PeticionHttp`, `RespuestaHttp` y `MetodoHttp` son transferibles (`LANG.TASK.ISOLATION#R1`).
- `H13` Reproducir desde cinta o posicionarse en el pasado (`API.EXECUTE#R4`, `#R5`) nunca envía una petición.

#### 3.4.6 Límites → `ENG.LIMITS` (edición oficial)

| Límite (nombre de configuración candidato) | Mínimo garantizado | CLI | App | Efecto al superarlo |
|---|---|---|---|---|
| `max_http_body_bytes` (cuerpo decodificado) | 1 MiB | 8 MiB | 1 MiB | `Error(LimiteExcedido)`; el adaptador deja de leer en el límite + 1 |
| `max_http_wire_bytes` (bytes en el cable, comprimidos o no) | 1 MiB | 8 MiB | 1 MiB | Igual |
| `max_http_header_bytes` y `max_http_headers` | 16 KiB y 64 | iguales | iguales | Igual |
| `max_pending_network` | 4 | 8 | 4 | `Error(LimiteExcedido)` local, sin enviar |
| `max_http_timeout_nanos` (plazo externo) | 30 s | 30 s | 15 s | `Error(TiempoAgotado)` grabado |
| `max_json_depth` | 64 | 64 | 64 | `ErrorJson(ProfundidadExcedida)` |

`ConLimiteRespuesta` y `ConTiempoMaximo` solo pueden reducir el valor efectivo; un valor mayor se recorta en silencio
al del anfitrión y uno no positivo es `PeticionInvalida`. Ningún límite de red es una terminación del programa.
Descompresión admitida: solo `gzip` en el adaptador nativo; ambos límites (cable y decodificado) se aplican.

#### 3.4.7 Anfitrión y capacidades declaradas → `RT.HOST.INTERFACE` y `API.EXECUTE`

- `A1` Petición de efecto `network_send`: método, URL normalizada, cabeceras en orden, cuerpo, límite y plazo
  efectivos, en el formato de `API.WIRE-FORMAT`. Resultado: `committed` con la respuesta, `failed` con el código, o
  `uncertain` con el código y `Incierto`.
- `A2` El motor valida cada respuesta del anfitrión (estado en rango, cuerpo dentro del límite efectivo, cabeceras en
  límite); una respuesta del anfitrión fuera de contrato se convierte en `Error(RespuestaInvalida)` determinista, nunca
  en trampa.
- `A3` Un anfitrión declara en la negociación sus garantías de red: `tls_validation`, `wire_limit`,
  `certificate_errors_distinguished`, `redirect_location_visible`, `ssrf_policy` (`adapter` o `browser`),
  `compression` (`gzip` o `browser`). Los casos del corpus no dependen de ninguna garantía opcional.
- `A4` El anfitrión web (Fetch) declara: `wire_limit = unavailable`, `certificate_errors_distinguished = false`
  (un certificado inválido llega como `ConexionFallida`), `redirect_location_visible = false` (una 3xx llega como
  `RedireccionDenegada` porque `redirect: "manual"` no deja leer `location`), `ssrf_policy = browser`,
  `compression = browser`. Esto es una diferencia declarada, no una paridad prometida (`E-PG-07`).

#### 3.4.8 Criterios de elección del adaptador nativo (`PG-5.06.01`)

| Criterio | Obligatorio | Cómo se mide |
|---|---|---|
| Licencia en la lista permitida de `apps/pseudolearn_cli/deny.toml` (sin ampliarla, salvo autorización) | Sí | `cargo deny check` del miembro con la dependencia añadida en una rama de trabajo local no publicada |
| Sin proxy del entorno por omisión o con desactivación explícita verificable | Sí | Prueba: `HTTPS_PROXY` apuntando a un puerto que registra conexiones ⇒ cero conexiones |
| Resolución de nombres sustituible (para fijar IP y aplicar `H10`) | Sí | Prueba con resolvedor falso inyectado |
| Redirecciones desactivables por completo | Sí | Prueba con 302 ⇒ la 302 llega al motor |
| TLS con `rustls`, raíz de prueba añadible por configuración del anfitrión, sin modo inseguro expuesto | Sí | Pruebas con certificado válido de prueba, caducado, de otro host y autofirmado |
| Lectura por flujo con corte exacto de bytes y plazo por petición | Sí | Pruebas `/grande`, `/bomba-gzip`, `/lento` |
| Aborto de una petición en vuelo | Sí | Prueba de cancelación |
| Compila con la toolchain fijada `1.99.0` sin herramientas de sistema adicionales (más allá del compilador C ya usado) | Sí | `cargo build --locked` limpio |
| Crecimiento del binario `release` de la CLI | Informativo, presupuesto candidato ≤ 4 MiB | `ls -l` antes/después, misma revisión |
| Plataformas | Solo macOS arm64 verificado; no se declara otra por analogía | Registro en §11 |

### 3.5 Conflictos que se reportan (`CONFLICT-REPORT`)

| ID | Fuentes en choque | Propuesta | Estado |
|---|---|---|---|
| `CF-PG5-01` | `PG-5.04` «redirecciones solo dentro del permiso» frente a D-PG5-08 (nunca seguir automáticamente) | No seguir automáticamente; `Redirigida` crea la siguiente petición y `Enviar` vuelve a validar el permiso | Confirmado por la persona el 2026-10-29 |
| `CF-PG5-02` | `R-11` «cliente nativo/VM/AOT» frente a §1.2.5–6 (AOT sin tareas ni E/S real) | AOT ejecuta HTTP con anfitrión de memoria y cinta; los casos con tareas divergen por `PG-4.12.04` y se registran como pendiente heredado, no como fallo de `PG-5` | Se informa; no bloquea salvo decisión contraria |
| `CF-PG5-03` | Hoja de ruta §5 («biblioteca genérica en inglés») frente al README del motor (genéricos entre módulos fuera) | `PG-5.09` usa una biblioteca bilingüe no genérica; el caso genérico queda para una decisión de la persona (abrir genéricos entre módulos o retirar el adjetivo de ENT-1) | Pendiente de `P1` |
| `CF-PG5-04` | Supuesto choque de `RT.HOST.INTERFACE#R1` con capacidades de archivo, tiempo y red | La regla vigente ya limita las capacidades implícitas a salida, entrada y semilla, y exige concesión explícita para las demás. No requiere edición | Obsoleto tras inspeccionar el contrato vigente |
| `CF-PG5-05` | `AGENTS.md` §9 asigna `node`/`pnpm` solo al frontend, pero `crates/pseudolearn_wasm/browser/` ya usa pnpm | Precedente existente, no creado por `PG-5`; el adaptador Fetch se añade ahí sin cadena nueva | Informativo |
| `CF-PG5-06` | `PERF.SUITE.CORE` ya incumplido en `PG-4` | `PG-5` mide su regresión contra `a1de5355` y no puede empeorarla; no se declara verde lo que ya no lo era | Informativo |

---

## 4. Desglose por punto

Convención de cada tarea: `.01` especificación, `.02` casos, `.03` tests, `.04` código, `.05` README y reglas,
`.06` verificación ligera (solo de lo tocado, iteraciones 1–5), `.07` verificación pesada (**solo** iteración 6).
Ninguna tarea se marca `[x]` sin evidencia en §11. Todos los casos se redactan en `es` y `en`, con `origen:
derivado`, y sus esperados se derivan de la regla, nunca de la salida del motor (`SPEC-INDEPENDENT-ORACLE`).

### PG-5.01 · Biblioteca bilingüe con símbolo canónico y facetas generadas

- [x] `PG-5.01.01` Especificación: en `LIB.MODEL`, reglas `M1`–`M4` y campo `family` en cada fila de `D1`/`D2`; filas
  nuevas de §3.3.1–§3.3.3; edición oficial de `LIB.CORE.TEXT` (`T1`–`T3`); crear `LIB.CORE.BYTES` (`B1`, `B2`) y
  `LIB.JSON` (`J1`–`J8`), estables `1.0.0`, sujetos `engine` y `aot`, sin `cambio`; `LANG.PROFILE.VOCABULARY` (tipos y
  miembros nuevos); `LANG.TASK.ISOLATION#R1` (transferibles); `ENG.LIMITS` (`max_json_depth`); `DIAG.CATALOG` y
  `DIAG.MESSAGES` (`emptySeparator`, `bytesRangeOutOfBounds`, `jsonKindMismatch`, con plantillas es/en);
  `TOOL.SERVICE.CATALOG` (una ficha por identidad nueva, con ejemplo derivado válido).
- [x] `PG-5.01.02` Casos: por cada función de texto, feliz, borde de §3.3.1 y, si atrapa, infeliz; bytes: vacío,
  segmento total, segmento fuera de rango, unión con vacío, `BytesDesdeTexto` con carácter de cuatro bytes; JSON:
  documento con los seis tipos, objeto vacío, arreglo vacío, cadena con par sustituto, número `-0`, `1e400`
  (`ComoReal` ⇒ `Nada`), `9223372036854775808` (`ComoEntero` ⇒ `Nada`), clave duplicada, sustituto suelto, coma
  final, BOM, contenido sobrante, profundidad igual al límite (acepta) y límite + 1 (rechaza), error en línea 3
  columna 5, `ConCampo` que reemplaza conservando posición, `ConElemento` sobre objeto ⇒ `jsonKindMismatch`,
  ida y vuelta `TextoJson`; facetas: un programa `en` y su traducción `es` con idéntica salida para cada familia;
  `ValorJson` lanzado a una tarea hija (transferible). Propiedad de ida y vuelta de `J7` en el archivo de propiedades.
- [x] `PG-5.01.03` Tests espejo: `see_validation` (validador de facetas `M1`–`M3` con fixture negativo: identidad sin
  `en`, firma distinta, ficha ausente, forma duplicada); `pseudolearn_library` (`text_search_tests.rs`,
  `text_split_tests.rs`, `json_parse_tests.rs`, `json_text_tests.rs`, `json_query_tests.rs`); `pseudolearn_abi`
  (`json_layout_tests.rs`); `pseudolearn_semantic` (tipos incorporados nuevos y transferibilidad).
- [x] `PG-5.01.04` Código: regenerar exportación, léxico y tabla de operaciones (`GEN-NO-HAND-COPY`);
  `pseudolearn_abi/src/json_layout.rs`; `EffectValueKind` y `build.rs` con las clases nuevas; `pseudolearn_library`:
  `text_search.rs`, `text_split.rs`, `text_replace.rs`, `bytes_operations.rs`, `json_parse.rs`,
  `json_parse_strings.rs`, `json_text.rs`, `json_query.rs`, `json_build.rs`; `pseudolearn_runtime`:
  `json_document.rs` (bloque y vistas sobre el montón) y raíces; `pseudolearn_semantic`: tipos incorporados y
  `transferability.rs`; `pseudolearn_lowering` y VM: llamadas a las operaciones puras por la vía existente de
  operaciones de biblioteca (si no existe vía genérica para puras con receptor, se reporta antes de crear
  instrucciones de RI nuevas); validador de facetas en `see_validation`.
- [x] `PG-5.01.05` README: motor (`library`, `runtime`, `abi`: representación JSON y su coste), `pseudolearn_spec`
  (validador de facetas).
- [x] `PG-5.01.06` Ligera: `see validate`, `lock --check`, `export --check`; `cargo test -p pseudolearn_library --lib
  <módulo>` por módulo nuevo; `cargo test -p pseudolearn_abi --lib json_layout`; `cargo test -p see_validation
  <filtro de facetas>`; Clippy y `rust-checks` de los crates tocados.
- [x] `PG-5.01.07` Pesada: `see conform --only` de `LIB.MODEL`, `LIB.CORE.TEXT`, `LIB.CORE.BYTES`, `LIB.JSON`,
  `LANG.TASK.ISOLATION`, `TOOL.SERVICE.CATALOG` en `engine` y `aot`; propiedades de `LIB.JSON`; centinela léxico
  (§7.1.4).

### PG-5.02 · Cliente HTTP/HTTPS con métodos explícitos y 4xx/5xx como respuesta

- [x] `PG-5.02.01` Especificación: crear `LIB.HTTP` (`H1`–`H7`, `H11`–`H13`); `LANG.CAPABILITY.MODEL` (`RedCap` en
  `#R1`, atenuación por origen en `#R3`); `LIB.IO#R2` (variantes nuevas de `ErrorES`); `LIB.MODEL` (filas de
  §3.3.4); `ENG.EXEC.EFFECT-COMMIT` (clasificación `H6`); `ENG.EFFECT.TAPE` (`network`, `H11`);
  `API.PROJECT.MANIFEST#R4` (permiso `red`); `RT.HOST.INTERFACE` (`A1`, `A2`, `CF-PG5-04`); `API.WIRE-FORMAT` (forma de
  petición y respuesta); esquema `see-1` (clave `anfitrion.http`: respuestas guionizadas por método y URL, con
  `estado`, `cabeceras`, `cuerpo`, `cuerpo_bytes`, `fallo`, `incierto`); `TOOL.SERVICE.CATALOG` (fichas).
- [x] `PG-5.02.02` Casos (anfitrión falso, sin red): `GET` 200 con texto; `POST` con cuerpo de texto y eco; `HEAD`
  sin cuerpo; `PUT`, `PATCH`, `DELETE` con 204; 404 y 500 como `Exito` con `EsExito() = Falso`; cuerpo binario no
  UTF-8 ⇒ `CuerpoTexto` = `Error(Utf8Invalido)` y `Cuerpo` correcto; `Cabecera` sin distinguir mayúsculas y repetida;
  `SolicitarRed` sin permiso ⇒ `PermisoDenegado`; `Limitar` a origen no concedido ⇒ `DestinoDenegado`; `Enviar` tras
  `Cerrar` ⇒ `CapacidadCerrada`; URL con `usuario@`, sin esquema, `ftp://`, host no ASCII ⇒ `UrlInvalida`; cabecera
  prohibida y cabecera con salto de línea ⇒ `PeticionInvalida`; `GET` con cuerpo ⇒ `PeticionInvalida`; `Enviar` sin
  `Aguardar` en la raíz (efecto síncrono de `PG-3`); tres `Aguardar red.Enviar` en tareas hijas con entrega
  desordenada declarada (`delivery_seq`); cinta grabada y reproducida sin consultar al anfitrión; reproducción con
  petición alterada ⇒ `replay_divergence`; `authorization` redactada en la cinta; límite: cuerpo vacío 200, estado 100
  consumido, 599, `101` ⇒ `RespuestaInvalida`.
- C1–C12 cubren métodos, estados, cuerpo binario, validación, permisos, cierre, secretos, entregas concurrentes,
  divergencia por petición alterada y límites de estado. La reproducción de una respuesta con credencial queda bajo el
  conflicto `LIB.HTTP#R6`/C8.
- [x] `PG-5.02.03` Tests espejo: `pseudolearn_runtime` (`network_policy_tests.rs`: orígenes, cabeceras, URL;
  `http_values_tests.rs`); `pseudolearn_api` (`fake_host` HTTP, `tape_wire`); `pseudolearn_semantic` (firmas y
  `Aguardar` sobre `Enviar`).
- [x] `PG-5.02.04` Código: ABI (`http_layout`, permiso y errores); runtime (`network_url`, `network_policy`,
  `network_headers`, `http_values`, autoridad, validación, efectos locales y anfitrión de memoria); operaciones puras
  en `pseudolearn_library`; tipos en `pseudolearn_semantic`; permiso `red` en `pseudolearn_project`; proyección API y
  anfitrión falso; corrección del chequeo escalar de `HttpMethod` en RI; esquema `see-1`, lector y catálogo. La VM y
  AOT usan la tabla generada compartida y no requirieron cambios propios de despacho.
- [x] `PG-5.02.05` README del motor (`runtime`, `api`), de `pseudolearn_spec` (clave `anfitrion.http`), ABI,
  semántica, biblioteca, proyecto y RI afectados.
- [x] `PG-5.02.06` Ligera: tests filtrados de ABI, runtime (`network_policy`, `http_values`, `network_effect_tests`,
  `memory_host_config_tests`), API (`fake_host_http_tests`), semantic, project, `see_format`, `see_validation` y
  `see_conformance`; los casos de API atraviesan library e IR. `cargo check`, Clippy `--all-targets` y
  `rust-checks all .` de los crates tocados; `rustfmt --check` de 61 archivos Rust tocados; `see validate`,
  `see lock --check` tras reanclar los 12 IDs editados, y `see export --check`. Todo lo anterior pasa, incluido
  `see validate` tras registrar la especificación como `estable`, su revisión por la persona y los vínculos de
  conformidad pendientes de P6. La conformidad pesada sigue pendiente en `.07`.
- [ ] `PG-5.02.07` Pesada: `--only` de `LIB.HTTP`, `LIB.IO`, `LANG.CAPABILITY.MODEL`, `ENG.EXEC.EFFECT-COMMIT`,
  `ENG.EFFECT.TAPE`, `RT.HOST.INTERFACE`, `API.EXECUTE`, `API.WIRE-FORMAT`, `API.PROJECT.MANIFEST` en `engine` y
  `aot` (los casos con tareas en AOT se registran bajo `CF-PG5-02`).

### PG-5.03 · Límites de bytes, profundidad JSON, peticiones pendientes y tiempo externo

- [x] `PG-5.03.01` Especificación: edición oficial de `ENG.LIMITS` con la tabla de §3.4.6 y su clasificación (no son
  terminaciones); regla de `LIB.HTTP` sobre recorte de `ConLimiteRespuesta`/`ConTiempoMaximo` y valores no positivos.
- [x] `PG-5.03.02` Casos: cuerpo exactamente en el límite (acepta) y límite + 1 (`LimiteExcedido`); `ConLimiteRespuesta`
  mayor que el del anfitrión (se recorta); `ConLimiteRespuesta(0)` ⇒ `PeticionInvalida`; `max_pending_network`
  pendientes y una más ⇒ `LimiteExcedido` local, sin efecto en el anfitrión; plazo superado declarado por el
  anfitrión falso en `GET` (`Failed`) y en `POST` tras enviar (`Uncertain`, `Incierto = Verdadero`); JSON con
  profundidad límite y límite + 1; respuesta del anfitrión falso que excede el límite efectivo ⇒ el motor la
  convierte en `LimiteExcedido` (`A2`); demasiadas cabeceras.
- [x] `PG-5.03.03` Tests espejo: `network_limits_tests.rs` en runtime; profundidad en `json_parse_tests.rs`.
- [x] `PG-5.03.04` Código: `pseudolearn_runtime/src/network_limits.rs`; configuración de límites en
  `pseudolearn_api` (`execution_prepare.rs`) y en la CLI (`execution_options.rs`).
- [x] `PG-5.03.05` README del motor (límites) y de la CLI (valores por omisión).
- [x] `PG-5.03.06` Ligera: tests filtrados anteriores.
- [ ] `PG-5.03.07` Pesada: `--only ENG.LIMITS,LIB.HTTP,LIB.JSON` en `engine` y `aot`; pruebas de integración de
  límites contra el servidor local (§7.3).

### PG-5.04 · TLS, redirecciones dentro del permiso, credenciales, proxies y SSRF

- [x] `PG-5.04.01` Especificación: crear `LIB.HTTP.POLICY` (`H2`, `H8`, `H9`, `H10`), con las amenazas STRIDE de HTTP
  de la hoja de ruta convertidas en reglas comprobables; añadir `Redirigida` a la firma generada de `LIB.MODEL` y una
  ficha en `TOOL.SERVICE.CATALOG`; `RT.HOST.INTERFACE` (obligaciones del adaptador: `H8`, `H10`).
- [x] `PG-5.04.02` Casos (motor, anfitrión falso): `Redirigida` con 301/302 sobre `GET`, 303 sobre `POST` (pasa a
  `GET` sin cuerpo), 307 y 308 (conservan método y cuerpo), `location` relativa, ausente o repetida,
  `https`→`http` ⇒ `RedireccionDenegada`, cambio de origen retira `authorization`, mismo origen la conserva,
  origen nuevo no concedido ⇒ `Enviar` devuelve `DestinoDenegado`; cadena de tres redirecciones escrita por el programa;
  host `2130706433`, `0x7f000001`, `0177.0.0.1` ⇒ `UrlInvalida`. Los casos de red real (TLS, DNS, proxy) **no** van al
  corpus: van a §7.3.
- [x] `PG-5.04.03` Tests espejo: `network_redirect_tests.rs` en runtime; en la CLI, `network_address_policy_tests.rs`
  (rangos IPv4/IPv6, mapeadas, origen local de prueba), `network_resolver_tests.rs` (resolvedores del sistema y falso,
  fijación de IP) y `network_tls_tests.rs`.
- [x] `PG-5.04.04` Código: runtime `network_redirect.rs`; CLI `physical_network_address.rs`,
  `physical_network_resolver.rs` (puerto con implementación del sistema y falsa en tests), configuración TLS en
  `physical_network_tls.rs`.
- [x] `PG-5.04.05` README de la CLI (política de red, qué se tomó de la biblioteca elegida y qué se rechazó) y del
  motor (`Redirigida`).
- [x] `PG-5.04.06` Ligera: `cargo test -p pseudolearn_runtime --lib network_redirect`; desde la CLI,
  `cargo test --bin pseudo network_address_policy`, `network_resolver` y `network_tls` (filtros), y el test ABI de HTTP;
  Clippy, `rustfmt --check` y `rust-checks` de la CLI.
- [ ] `PG-5.04.07` Pesada: `--only LIB.HTTP.POLICY` en `engine` y `aot`; batería de red de `E-PG-09` (§7.4).

### PG-5.05 · Sin reintento automático; estado incierto registrado

- [x] `PG-5.05.01` Especificación: semántica prevista de `H6`/`H7` integrada en la regla vigente `R5` de `LIB.HTTP`;
  edición oficial de `ENG.EXEC.EFFECT-COMMIT` (tabla de
  métodos) y de `ENG.EFFECT.TAPE` (sello `UncertainExternalState` también por red).
- [x] `PG-5.05.02` Casos: `POST` con corte declarado tras enviar ⇒ `Uncertain`, `Incierto = Verdadero`, cinta marcada
  no reproducible de forma autónoma; mismo corte en `GET` ⇒ `Failed`, `Incierto = Falso`; `DELETE` con corte ⇒
  `Uncertain`; un único efecto registrado por llamada en todos ellos (prueba de no reintento en el motor); tarea
  cancelada mientras espera un `POST` ⇒ `abandoned`.
- [x] `PG-5.05.03` Tests espejo: clasificación en `network_policy_tests.rs`; en la CLI, `physical_network_send_tests.rs`
  (servidor que cuenta conexiones: exactamente una por llamada).
- [x] `PG-5.05.04` Código: clasificación en runtime; envío en CLI `physical_network_send.rs` sin bucles de reintento.
- [x] `PG-5.05.05` README del motor y de la CLI.
- [x] `PG-5.05.06` Ligera: tests filtrados anteriores.
- [ ] `PG-5.05.07` Pesada: `--only ENG.EXEC.EFFECT-COMMIT,ENG.EFFECT.TAPE` en `engine` y `aot`; integración con
  `/cerrar-a-mitad` (§7.3).

### PG-5.06 · Adaptador nativo elegido con evidencia; adaptador Fetch con capacidades declaradas

- [x] `PG-5.06.01` Elección (iteración 4, antes de cualquier código del adaptador): evaluar los candidatos de D-PG5-17
  con la tabla de §3.4.8; requiere **autorización de la persona para descargar crates** (§9). Registrar en §11 versión
  exacta, licencia, resultado de cada criterio, crecimiento del binario y la fuente leída de la documentación de esa
  versión. Si ninguno cumple los obligatorios, detenerse y reportar.
- [x] `PG-5.06.02` Especificación: `A3`, `A4` en `RT.HOST.INTERFACE` o `API.EXECUTE` (negociación); `TOOL.CLI.RUN`
  (concesiones candidatas `--conceder red`/`--grant network`, `--origen <URL>`/`--origin <URL>` repetible,
  `--origen-local <URL>`/`--local-origin <URL>` para loopback de prueba, `--raiz-prueba <PEM>`/`--test-root <PEM>`;
  `--nativo` con `red` ⇒ error de uso código 2).
- [x] `PG-5.06.03` Tests espejo: CLI `physical_network_tests.rs` (despacho y conversión de errores con transporte
  falso), `execution_options` (opciones nuevas); web `fetch_host.test.mjs` con `fetch` falso (sin navegador).
- [x] `PG-5.06.04` Código: CLI `physical_network.rs` (puerto de transporte), `physical_network_send.rs`,
  `physical_network_reply.rs`, `physical_network_batch.rs` (D-PG5-21), integración en `physical_host.rs` y
  `physical_session.rs`; `architecture.yaml` y `deny.toml` de la CLI con la dependencia aprobada; web
  `crates/pseudolearn_wasm/browser/fetch_host.mjs` (`redirect: "manual"`, `credentials: "omit"`, `cache:
  "no-store"`, `AbortController` para el plazo, lectura por flujo con corte de bytes decodificados, mapeo de
  `TypeError` a `ConexionFallida`), declaración `A4` en la negociación del lado web.
- [x] `PG-5.06.05` README de la CLI (adaptador y opciones), del crate Wasm (adaptador Fetch y garantías declaradas) y
  del motor (negociación).
- [x] `PG-5.06.06` Ligera: `cargo check` y tests filtrados de la CLI; `cargo deny check` de la CLI (por cambio de
  dependencias, disparador de §7.1.4 adelantado porque bloquea la elección); `node --test fetch_host.test.mjs` sin
  navegador.
- [ ] `PG-5.06.07` Pesada: `E-PG-07` (§7.3) en nativo y en navegadores.

### PG-5.07 · Servidor de prueba local controlado; corpus sin Internet

- [x] `PG-5.07.01` Especificación: regla en `LIB.HTTP` o en el README de `pseudolearn_spec` (según dónde viva hoy la
  política de conformidad sin red; la iteración 1 lo decide leyendo `SEE.ORACLE.POLICY`): ningún caso del corpus
  abre sockets; el anfitrión falso es la única fuente de respuestas.
- [x] `PG-5.07.02` Casos: un negativo del corredor que demuestra que un caso que pidiera red real sin `anfitrion.http`
  recibe `PermisoDenegado` y no abre conexión.
- [x] `PG-5.07.03` Tests espejo: tests del propio servidor en `apps/pseudolearn_cli/xtask` (cada ruta de §7.3 responde
  lo guionizado; escucha solo en loopback; rechaza arrancar en otra interfaz).
- [x] `PG-5.07.04` Código: subcomando `http-test-server` del `xtask` de la CLI (puerto efímero impreso en la salida
  estándar, directorio de certificados generado bajo `target/`, rutas de §7.3); certificados de prueba generados en
  tiempo de ejecución, nunca versionados; `architecture.yaml` de la CLI (dependencias del `xtask`).
- [x] `PG-5.07.05` README de la CLI (cómo lanzar el servidor, rutas y garantías) y del crate Wasm (cómo lo usan las
  pruebas de navegador).
- [x] `PG-5.07.06` Ligera: `cargo test` del `xtask` de la CLI filtrado al servidor.
- [ ] `PG-5.07.07` Pesada: auditoría `rg -n "https?://" packages/pseudolearn_spec/specifications` sin direcciones
  fuera de loopback y de `*.test` de ejemplo; conformidad completa de §10.1 sin red (se ejecuta con la red del
  sistema disponible; el corredor no la usa).

### PG-5.08 · `PERF.ARTIFACT.SIZE` se mantiene

- [x] `PG-5.08.01` Especificación: sin cambios en `PERF.ARTIFACT.SIZE` (no se aumentan presupuestos para ocultar una
  regresión, `ADR-06`).
- [x] `PG-5.08.02` Casos: no aplica (medición, no comportamiento).
- [x] `PG-5.08.03` Tests: comprobación de grafo — `cargo tree --locked -e normal` en `packages/pseudolearn_engine`
  (crates `pseudolearn_api` sin `native`, `pseudolearn_wasm`) y en `apps/pseudolearn_app/native` no contiene la
  biblioteca HTTP elegida, `rustls`, `hyper` ni resolvedores DNS. Se amplió `isolation` en los archivos de reglas del
  motor y del puente para comprobar esta restricción. `apps/pseudolearn_app/native/Cargo.lock` se actualizó para fijar
  cuatro paquetes transitivos que faltaban del grafo actual del motor.
- [x] `PG-5.08.04` Código: ninguno.
- [x] `PG-5.08.05` README del motor y de la app (garantía de grafo).
- [x] `PG-5.08.06` Ligera: `cargo tree` anterior tras la iteración 4.
- [ ] `PG-5.08.07` Pesada: medición `PERF.ARTIFACT.SIZE` (biblioteca del puente `ios-arm64` ≤ 5 MiB, Wasm ≤ 900 KiB
  con Brotli) con el procedimiento del README de la app y del crate Wasm, comparada con `a1de5355`.

### PG-5.09 · Casos integradores de ENT-1

- [x] `PG-5.09.01` Especificación: crear `LIB.SCENARIO.FILE-JSON`, `LIB.SCENARIO.HTTP-TASKS` y
  `LIB.SCENARIO.BILINGUAL`, cada una con reglas que enuncian la composición observable (qué salida, terminación y
  cinta produce el programa en cada situación) y dependencias `usa` hacia las reglas que componen.
- [x] `PG-5.09.02` Casos, cada escenario con: camino feliz, **entrada vacía**, **permiso denegado**, **cancelación**
  y **agotamiento**:
  - `FILE-JSON`: lee `entrada.json`, valida con `AnalizarJson`, extrae campos y escribe `salida.json` con `TextoJson`;
    archivo vacío ⇒ `ErrorJson(FinInesperado)` informado con línea y columna; sin `archivos_escritura` ⇒
    `PermisoDenegado` sin escribir nada; cancelación del anfitrión durante la escritura ⇒ cinta `incomplete`;
    profundidad límite + 1 ⇒ `ProfundidadExcedida`.
  - `HTTP-TASKS`: tres recursos con tareas hijas; uno responde 500 (respuesta, no fallo), uno falla con
    `ConexionFallida` (fallo parcial en `FalloTareas` con `Primero` y `Canceladas`), uno correcto; respuesta vacía;
    sin permiso `red`; cancelación por fallo de hermana con la petición en vuelo ⇒ `abandoned`; `max_pending_network`
    agotado ⇒ `LimiteExcedido`. Además: posicionamiento en el pasado tras la petición sin reenviarla (`H13`, base de
    la sesión depurada de `PG-6B`).
  - `BILINGUAL`: biblioteca en `en` (módulo con `Publico` y JSON/texto) consumida por un programa `es` en un proyecto
    de dos módulos; misma salida con el programa traducido a `en`; entrada vacía; permiso denegado al leer;
    agotamiento de celdas. Sin genéricos entre módulos (`CF-PG5-03`).
- [x] `PG-5.09.03` Tests: ninguno nuevo de Rust (los casos del corpus no se duplican como tests, `AGENTS.md` §5).
- [x] `PG-5.09.04` Código: ninguno esperado; si un escenario no puede escribirse con lo existente, se detiene y se
  reporta (D-PG5-15).
- [x] `PG-5.09.05` README: ninguno salvo hallazgos.
- [x] `PG-5.09.06` Ligera: corpus (§7.1.1).
- [ ] `PG-5.09.07` Pesada: `--only` de los tres escenarios en `engine` y `aot` (con `CF-PG5-02` para tareas).

### PG-5.10 · `E-PG-07` y la parte de red de `E-PG-09`; métrica candidata de HTTP

- [x] `PG-5.10.01` Protocolos de §7.3 y §7.4 y definición candidata de `PERF.PG.HTTP` (§6.1) redactados en el README
  de `pseudolearn_bench_worker` antes de ejecutar nada; no se crea especificación `PERF.PG.HTTP` sin aprobación de la
  persona en `P6`.
- [x] `PG-5.10.02` Casos: no aplica (experimentos).
- [x] `PG-5.10.03` Tests: `pg_http_*_tests.rs` del trabajador (generación de cargas y resumen); registro de vectores
  de red con sus negativos (`network_vector_registry` en la CLI).
- [x] `PG-5.10.04` Código: `pseudolearn_bench_worker/src/pg_http_workloads.rs`, `pg_http_campaign.rs`,
  `pg_http_summary.rs`, `pg_http_growth.rs`; CLI `tests/network_security_vectors.rs`, `tests/network_vector_registry.rs`,
  `tests/network_adapter_contract.rs`; web `browser/http_contract.test.mjs`.
- [x] `PG-5.10.05` README del trabajador, de la CLI y del crate Wasm.
- [x] `PG-5.10.06` Ligera: tests unitarios del trabajador filtrados; `cargo check --tests` de la CLI.
- [ ] `PG-5.10.07` Pesada: ejecutar §7.3, §7.4 y §7.5 con procedencia.

---

## 5. Capas y archivos

`E` = `packages/pseudolearn_engine/crates`, `S` = `packages/pseudolearn_spec`, `C` = `apps/pseudolearn_cli`,
`A` = `apps/pseudolearn_app`, `W` = `E/pseudolearn_wasm/browser`. Antes de crear o tocar cada archivo la IA responde
por escrito, en su mensaje de trabajo, las tres preguntas de `AGENTS.md` §1 y confirma que el archivo cabe en los
límites de §1.2.9. Si un archivo existente superaría 300 líneas (250 en la app), la responsabilidad nueva va en un
archivo hermano nuevo.

| Archivos | Capa · imports permitidos / prohibidos | Dueño y motivo · puntos |
|---|---|---|
| Este archivo y `plan-ejecucion-proposito-general.md` | Documentación transitoria · nunca citada fuera de `docs/` | Planificación |
| `S/specifications/lib/`: nuevos `lib.core.bytes.md`, `lib.json.md`, `lib.http.md`, `lib.http.policy.md`, `lib.scenario.file-json.md`, `lib.scenario.http-tasks.md`, `lib.scenario.bilingual.md`; editados `lib.model.md`, `lib.core.text.md`, `lib.io.md` | Datos normativos · sin enlaces externos (`SPEC-SELF-CONTAINED`) | Biblioteca · `.01`–`.05`, `.09` |
| `S/specifications/{lang,eng,rt,api,tool,diag}/`: `lang.capability.model.md`, `lang.task.isolation.md`, `lang.profile.vocabulary.md`, `eng.limits.md`, `eng.effect.tape.md`, `eng.exec.effect-commit.md`, `rt.host.interface.md`, `api.execute.md`, `api.wire-format.md`, `api.project.manifest.md`, `tool.cli.run.md`, `tool.service.catalog.md`, `diag.catalog.md`, `diag.messages.md`; `features/` si un contrato nuevo debe declararse en un manifiesto de característica; `S/schemas/see-1.schema.json` | Datos normativos y de conformidad (`SPEC-BINDING-AS-DATA`) | Contratos de frontera, diagnósticos, ayuda |
| `S/crates/see_validation` (validador de facetas) y lector de `anfitrion.http` donde viva hoy `anfitrion` | Herramientas de `pseudolearn_spec` · según su `architecture.yaml` | `M1`–`M3`; `.02` |
| `S/conformance.yaml` y vínculos de conformidad del motor y la CLI | Datos de conformidad | Vínculos regla–código como datos |
| `E/pseudolearn_abi/src/`: `json_layout.rs`, `http_layout.rs`; ajustes en `effect_operation.rs`, `build.rs`, `io_error_layout.rs` | `abi` · sin dependencias internas | Disposiciones únicas VM/AOT y tabla generada · `.01`, `.02` |
| `E/pseudolearn_lexicon` (generado) | `lexicon` · regenerado | Nombres de tipos y miembros nuevos · `.01` |
| `E/pseudolearn_library/src/`: `text_search.rs`, `text_split.rs`, `text_replace.rs`, `bytes_operations.rs`, `json_parse.rs`, `json_parse_strings.rs`, `json_text.rs`, `json_query.rs`, `json_build.rs` y sus `_tests.rs` | `library` · `runtime`, `diagnostics`; **prohibida toda dependencia externa** (sin `serde_json` para analizar JSON del programa: el analizador es propio, determinista y con límites) | Funciones puras · `.01`, `.03` |
| `E/pseudolearn_runtime/src/`: `json_document.rs`, `http_values.rs`, `network_origin.rs`, `network_url.rs`, `network_headers.rs`, `network_policy.rs`, `network_redirect.rs`, `network_limits.rs` y sus `_tests.rs`; ajustes en `effect_authority.rs`, `local_effect.rs`, `host_validation.rs`, `tape_privacy.rs`, `io_error.rs`, `memory_host*.rs` | `runtime` · `abi`, `diagnostics`; prohibido `vm`, `codegen`; `#![forbid(unsafe_code)]`; **sin dependencias de red** | Valores, política y validación deterministas compartidos por VM y AOT · `.01`–`.05` |
| `E/pseudolearn_semantic/src/`: tipos incorporados nuevos y `transferability.rs` | `semantics` · sin `runtime` | Firmas y aislamiento · `.01`, `.02` |
| `E/pseudolearn_vm/src/machine/` y `E/pseudolearn_aot_rt/src/effects.rs` | `vm`, `aot_rt` · sin cambios de matriz | Despacho por la tabla generada · `.02` |
| `E/pseudolearn_api/src/`: `fake_host.rs`, `execution_effects.rs`, `tape_wire.rs`, `project_authority.rs`, `negotiation.rs`, `execution_prepare.rs`, `program_view_*` (tipos nuevos), `service_help*` (fichas) | `api` · las capas de su fila | Frontera pública · `.02`, `.03`, `.06` |
| `E/pseudolearn_bench_worker/src/`: `pg_http_workloads.rs`, `pg_http_campaign.rs`, `pg_http_summary.rs` y tests | `tooling` | Métrica candidata · `.10` |
| `C/src/`: `physical_network.rs`, `physical_network_send.rs`, `physical_network_reply.rs`, `physical_network_batch.rs`, `physical_network_address.rs`, `physical_network_resolver.rs`, `physical_network_tls.rs` y sus `_tests.rs`; ajustes en `physical_host.rs`, `physical_session.rs`, `execution_options.rs`, `options.rs`, `messages.rs`, `native_run_command.rs` | `pseudolearn_cli` · `pseudolearn_api` y las externas declaradas en su `architecture.yaml` (se añade la biblioteca HTTP aprobada) | Adaptador nativo y política de direcciones · `.04`–`.06` |
| `C/xtask/`: subcomando `http-test-server` | `xtask` (tooling) · dependencias declaradas en el archivo de reglas | Servidor de prueba · `.07` |
| `C/tests/`: `network_adapter_contract.rs`, `network_security_vectors.rs`, `network_vector_registry.rs` | Tests de caja negra | `E-PG-07`, `E-PG-09` |
| `W/`: `fetch_host.mjs`, `fetch_host.test.mjs`, `http_contract.test.mjs`; ajuste de `server.mjs` solo para enrutar al servidor Rust | Página de prueba del módulo Wasm · Node, Playwright Core | Adaptador web y `E-PG-07` |
| `A/lib/engine/rust/`: `rust_simulated_host.dart` (red denegada por omisión y respuestas declaradas por el ejercicio), proyecciones de tipos nuevos en `rust_wire_models.dart`/`rust_program_view_builder.dart`; tests en `A/test/engine/rust/` | `engine` → `model`, `ports`; sin widgets | `C09`, `R-19` |

---

## 6. Presupuestos de rendimiento y seguridad

### 6.1 Rendimiento y memoria (candidatos hasta `P6`)

| Magnitud | Presupuesto candidato | Control |
|---|---|---|
| Infraestructura inactiva en `PERF.SUITE.CORE` | Media geométrica ≤ 1,02× frente a `a1de5355` (cierre de `PG-4`) y misma forma por carga que en `PG-4` | Programas sin red ni JSON no tocan código nuevo: las operaciones nuevas solo se despachan desde la tabla generada |
| `PERF.PG.HTTP` · coste del motor por petición | Lineal en bytes de cuerpo (0 B, 1 KiB, 64 KiB, 1 MiB) y sin crecimiento superlineal; serialización y validación separadas del transporte | Anfitrión de memoria, sin sockets; regresión lineal |
| `PERF.PG.HTTP` · JSON | Análisis O(bytes) y memoria ≤ 2× el texto de entrada más una celda por nodo | Documentos generados de 1 KiB, 64 KiB y 1 MiB; anidación 1, 16 y 64 |
| Memoria del adaptador nativo con cuerpo ilimitado | Memoria residente máxima no proporcional al cuerpo: con `/infinito` y límite 1 MiB, pico ≤ 16 MiB por encima de la línea base del proceso | `/usr/bin/time -l` sobre la CLI |
| Cinta | Bytes de cinta lineales en bytes de respuesta | Medición en `pg_http` |
| `PERF.ARTIFACT.SIZE` | Topes vigentes sin cambios | `PG-5.08.07` |
| Binario `release` de la CLI | Informativo ≤ 4 MiB de crecimiento | `PG-5.06.01` |

### 6.2 Seguridad (STRIDE de la hoja de ruta §9.3)

- **Suplantación/alteración (HTTP S/T):** TLS validado por `rustls` con raíces del sistema o del paquete de raíces
  elegido más la raíz de prueba solo por configuración del anfitrión; certificado de otro host, caducado o autofirmado
  ⇒ `CertificadoInvalido`; sin redirecciones automáticas; retirada de credenciales en `Redirigida`.
- **Revelación/elevación (HTTP I/E):** capacidad por orígenes concedidos; SSRF con resolución única, comprobación de
  todas las direcciones y conexión fijada; sin proxies del entorno; sin cookies; credenciales redactadas en la cinta.
- **Denegación (HTTP D):** límites de cable, decodificado, cabeceras, pendientes, plazo y profundidad JSON; bomba
  `gzip` cortada por el límite decodificado; conexiones que no responden cortadas por plazo.
- **Repudio (HTTP R):** un efecto por llamada, sin reintento; `Uncertain` grabado; cancelación ⇒ `abandoned`.
- **Cinta (T/R/I):** reproducción coteja la petición completa (con `SecretHandle` para credenciales); la respuesta se
  guarda completa porque la reproducción la necesita, y eso se declara en el README de la API y en la ficha de
  `Enviar` (`K-13`).

---

## 7. Pruebas y experimentos

### 7.1 Política de pruebas: mínimas en las iteraciones 1–5, pesadas solo en la iteración 6

#### 7.1.1 Ligeras (las únicas permitidas en las iteraciones 1–5, y solo sobre lo tocado)

| Qué | Cuándo | Orden de referencia |
|---|---|---|
| Integridad del corpus | La iteración crea o edita especificaciones o casos | Desde `packages/pseudolearn_spec`: `cargo run --locked -p see_cli --bin see -- validate`; `… lock --check` (tras `lock --refresh <ID>` autorizado en `P1`); `… export --check`. Si se tocó Rust de `pseudolearn_spec`: `rust-checks all .` desde ese miembro |
| Compilación del crate tocado | Siempre que se toca Rust | `cargo check -p <crate>` desde su miembro |
| Tests unitarios filtrados | Solo módulos creados o tocados | `cargo test -p <crate> --lib <módulo>` o `--test <archivo>`; nunca sin filtro |
| Verificadores estáticos | Crates tocados | `rustfmt --edition 2024 --check <archivos tocados>`; `cargo clippy -p <crate> --all-targets -- -D warnings`; `cargo run --manifest-path ../pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command --bin rust-checks -- all .` |
| App | Solo archivos Dart tocados | Desde `apps/pseudolearn_app`: `dart analyze <archivos tocados>`; `dart run tool/check_limits.dart` |
| Adaptador web | Solo si se tocó `W/` | `node --test <archivo>.test.mjs` con `fetch` falso, sin navegador |

Regla de selección: la IA enumera en su informe de iteración **qué archivos tocó y qué orden ligera cubre cada uno**;
un archivo tocado sin orden que lo cubra es un fallo de la iteración. Lo que no se tocó no se prueba.

#### 7.1.2 Pesadas (solo en la iteración 6)

- `see conform --subject engine --only <ID>` y `--subject aot --only <ID>` de **todos** los contratos creados o
  editados (lista en §10.1), seguidos de `see differential`. `--only` admite **un único ID**: la notación `--only A,B`
  de este plan significa una invocación por ID.
- Propiedades de `LIB.JSON` (ida y vuelta).
- Pruebas de integración de la CLI contra el servidor local (§7.3) y batería adversaria de red (§7.4).
- `E-PG-07` en nativo y en Chromium, WebKit y Firefox (§7.3), si la persona autorizó instalar los navegadores.
- `PERF.SUITE.CORE` (regresión contra `a1de5355`), campaña `pg_http` (§7.5) y `PERF.ARTIFACT.SIZE` (`PG-5.08.07`).
- App: `flutter test test/architecture_test.dart`, tests espejo Dart tocados y `bash tool/test_bridge.sh`.
- Conjuntos de §7.1.4 cuyo disparador se activó.

#### 7.1.3 Nunca

`cargo xtask verify`, `cargo test --workspace`, `see conform` sin `--only`, `flutter test` de toda la carpeta, pruebas
contra Internet, y campañas de rendimiento fuera de la iteración 6.

#### 7.1.4 Disparadores cerrados de ampliación (se ejecutan en la iteración 6)

| Disparador | Ampliación máxima |
|---|---|
| Nombre de tipo incorporado o miembro nuevo en el vocabulario | `--only LANG.LEXICAL.KEYWORD`, `LANG.LEXICAL.IDENTIFIER`, `LANG.PROFILE.VOCABULARY`, `LANG.PROFILE.TRANSLATION` y tests de `pseudolearn_syntax` filtrados a identificadores (centinela `K-02`) |
| Cambio de `ErrorES` | `--only LIB.IO`, `LANG.CONTROL.CLEANUP` |
| Cambio de la tabla de operaciones o de `EffectValueKind` | Tests de `pseudolearn_abi`, `pseudolearn_vm` filtrados a efectos y `--only LANG.CAPABILITY.PURITY` |
| Cambio del JSON consumido por la app | Tests Dart del adaptador y `bash tool/test_bridge.sh` |
| Cambio de `Cargo.lock` o de dependencias de la CLI | `cargo deny check` de la CLI (se adelanta a la iteración 4, §4 `PG-5.06.06`) |
| Falla un test por causa en un crate vecino | Tests del módulo vecino, una vez |

#### 7.1.5 Riesgo aceptado

Aplazar la conformidad a la iteración 6 aumenta la probabilidad de descubrir errores tarde. Mitigaciones: casos
derivados en la iteración 1 antes de cualquier código; tests unitarios con feliz, infeliz y límite en cada módulo; y
subsanación con orden fijo en la iteración 6 (§10).

### 7.2 Matriz mínima de comportamiento (`TEST-BOTH-PATHS`)

| Punto | Feliz | Infeliz | Límite |
|---|---|---|---|
| `.01` | Cada función de texto, bytes y JSON | Trampas tipadas; facetas rotas rechazadas por `see validate` | Cadena vacía, `Bytes()`, profundidad = límite |
| `.02` | `GET`/`POST` con 200 | Sin permiso, origen fuera, URL y cabecera inválidas | Cuerpo vacío, 100/599, `101` |
| `.03` | Cuerpo en el límite | Límite + 1, pendientes + 1, plazo | Recorte silencioso de `ConLimiteRespuesta` |
| `.04` | Redirección 307 al mismo origen | `https`→`http`, IP numérica alternativa, origen nuevo no concedido | `location` relativa, cadena de tres |
| `.05` | Una conexión por llamada | `POST` cortado ⇒ `Uncertain` | `GET` cortado ⇒ `Failed` |
| `.06` | Contrato común nativo/web | TLS inválido nativo y web; proxy del entorno ignorado | Garantías declaradas `A4` |
| `.07` | Rutas del servidor | Arranque en interfaz no loopback rechazado | Puerto efímero |
| `.08` | Grafo sin red en motor y puente | — | Tamaños en el tope |
| `.09` | Tres escenarios | Permiso denegado, cancelación | Entrada vacía, agotamiento |
| `.10` | Cero escapes | Vector sin prueba hace fallar el registro | 1 000 vectores sembrados |

### 7.3 Experimento `E-PG-07` · HTTP portable con un contrato común

1. **Servidor** (`cargo xtask http-test-server`, D-PG5-20), en `127.0.0.1` con TLS de prueba y una variante sin TLS
   para origen local. Rutas guionizadas: `/texto` (200 texto), `/binario` (200 bytes no UTF-8), `/vacio` (204),
   `/estado/404`, `/estado/500`, `/eco` (devuelve método, cuerpo y cabeceras recibidas), `/redireccion/mismo`,
   `/redireccion/otro-origen`, `/redireccion/http`, `/grande` (cuerpo de límite + 1), `/infinito` (flujo sin fin),
   `/bomba-gzip` (pocos bytes de cable, muchos decodificados), `/lento` (no responde), `/cerrar-a-mitad` (corta tras
   recibir el cuerpo), `/json-profundo`, `/cabeceras-muchas`, `/contador` (cuenta conexiones por ruta para probar
   «sin reintento»). Certificados: raíz de prueba, hoja válida para `127.0.0.1`/`localhost`, hoja caducada, hoja
   para otro host y autofirmada.
2. **Nativo** (`C/tests/network_adapter_contract.rs`): ejecuta `pseudo ejecutar` con las concesiones de prueba
   contra cada ruta y compara salida, terminación y cinta con lo que deriva la regla. Incluye proxy del entorno
   apuntando a un puerto que registra conexiones (cero), cancelación en vuelo y concurrencia de tres peticiones.
3. **Web** (`W/http_contract.test.mjs`): las mismas peticiones vía `fetch_host.mjs` en Chromium, WebKit y Firefox.
4. **Comparación:** estado, cabeceras comunes (sin las que el navegador añade o retira) y cuerpo idénticos entre
   nativo y cada navegador para las rutas `/texto`, `/binario`, `/vacio`, `/estado/*`, `/eco`, `/grande`,
   `/json-profundo`; errores ambientales tipados (nativo distingue `CertificadoInvalido`; web declara
   `ConexionFallida`); **cero redirecciones seguidas**; memoria del nativo con `/infinito` dentro de §6.1.
5. **Criterio:** cero diferencias no declaradas en `A4`. Toda diferencia nueva se registra y, si no puede declararse
   como garantía ausente, se reporta a la persona antes de cerrar.
6. **Ejecución:** procesos largos en segundo plano con notificación, nunca bucles de sondeo; servidor detenido al
   terminar.

### 7.4 Experimento `E-PG-09` · parte de red

1. **Registro cerrado** (`C/tests/network_vector_registry.rs`), con el mismo diseño que el registro de `PG-3`:
   lista de vectores y prueba que bloquea cada uno; falla si falta un vector requerido o su prueba, con negativos de
   ambas condiciones.
2. **Vectores requeridos:** IP numérica alternativa (decimal, octal, hexadecimal, abreviada `127.1`), IPv4 mapeada en
   IPv6, `[::1]`, `0.0.0.0`, `169.254.169.254`, host con punto final, mayúsculas en el host, `usuario@host`, `%2e` en
   el host, puerto distinto del concedido, DNS que devuelve pública + privada, DNS que cambia entre dos resoluciones
   (rebinding), redirección a `http`, redirección a otro origen con `authorization` (debe retirarse), proxy del
   entorno, cabecera con CRLF, cabecera prohibida, certificado de otro host, caducado y autofirmado, bomba `gzip`,
   cuerpo infinito, servidor que nunca responde.
3. **Generación sembrada:** 1 000 combinaciones (semilla SplitMix64 en el test, nunca en el motor) de host, puerto,
   respuesta DNS falsa y cadena de redirecciones escrita por el programa.
4. **Criterio:** cero conexiones fuera del permiso (verificado por el resolvedor falso y por el registro de conexiones
   del servidor), cero credenciales reenviadas a otro origen, cero reintentos, cinta sin secretos en claro.

### 7.5 Campaña `pg_http` y regresión de `PERF.SUITE.CORE`

- `pg_http`: anfitrión de memoria, sin sockets; cargas de §6.1 (cuerpos 0 B–1 MiB, JSON 1 KiB–1 MiB y anidación
  1–64); al menos 10 procesos × 30 muestras por carga; IC bootstrap 95 %; separa coste de serialización/validación del
  motor del coste de transporte (que no existe en esta campaña).
- `PERF.SUITE.CORE`: control = binario de `a1de5355`; tratamiento = binario final de `PG-5`; protocolo
  `PERF.PROTOCOL`, mismo hardware (Mac M2 de referencia), revisión Git, toolchain y semilla.

### 7.6 Procedencia

Cada campaña y prueba pesada registra en §11: orden exacta, revisión Git, `rustc --version`, hardware, fecha, semillas,
muestras, versiones de navegadores, ruta local ignorada de los datos crudos y resumen con SHA-256. Los datos crudos no se
versionan.

---

## 8. Riesgos y señales tempranas

| Riesgo | Señal temprana | Mitigación |
|---|---|---|
| `K-07` Permiso ampliado por ruta, DNS o redirección | Un vector de §7.4 conecta; `Redirigida` conserva `authorization` entre orígenes | Política única en runtime; resolución fijada en la CLI; registro cerrado de vectores |
| `K-09` Dependencias TLS/HTTP exceden tamaño o memoria | `cargo tree` del motor o del puente muestra `rustls`/`hyper`; memoria crece con `/infinito` | Constancia 4; adaptador en la CLI; lectura por flujo con corte |
| `K-02` Nombre nuevo invalida un programa 2026 | Un caso léxico vigente cambia de resultado | Nombres con sufijo (`RedCap`), centinela léxico en iteración 6 |
| `K-06` Reproducción repite un `POST` | El servidor `/contador` cuenta conexiones durante una reproducción | `H13`; prueba explícita en `HTTP-TASKS` |
| `K-13` Cinta revela credenciales | `authorization` aparece en claro en una cinta | `SecretHandle`; prueba en `PG-5.02.02` y en §7.4 |
| `K-15` Agotamiento del anfitrión | OOM o cuelgue con `/bomba-gzip`, `/infinito`, `/lento` | Límites de §3.4.6 y plazo |
| `PG5-R01` Deriva de facetas es/en | Una identidad con firma distinta por perfil | Validador `M1`–`M3` con negativo |
| `PG5-R02` Diferencias web no declaradas | `E-PG-07` encuentra una diferencia fuera de `A4` | Declarar o reportar antes de cerrar |
| `PG5-R03` API de la biblioteca HTTP distinta de lo supuesto | Una opción del criterio no existe en la versión elegida | `PG-5.06.01` lee la documentación de la versión exacta antes de codificar |
| `PG5-R04` Conformidad tardía | Muchos fallos en la iteración 6 | Casos en iteración 1; subsanación con orden fijo |
| `PG5-R05` Disco lleno | `df` < 15 GiB | §13 antes de cada iteración y de toda compilación `release` |

---

## 9. Dependencias de la persona

| Momento | Qué necesita la IA de la persona |
|---|---|
| Antes de todo | Revisión de este plan (`PG-5.C02`) y autorización para iniciar la fase (`PG-5.C01`) en un mensaje nuevo |
| Cada iteración de §10 | Autorización explícita en mensaje nuevo; puede autorizar varias juntas, y entonces la IA se detiene solo en los puntos `P` |
| `P1` (fin de la iteración 1, antes de anclar) | Confirmar nombres de §3.3, límites de §3.4.6, nanosegundos (D-PG5-10), `CF-PG5-01` y `CF-PG5-03`; aportar `revisado_por`; autorizar `lock --refresh` de los IDs editados |
| Iteración 4, antes de `PG-5.06.01` | Autorizar la descarga de los crates candidatos (red) y, si la licencia elegida no está en `deny.toml`, autorizar su inclusión |
| Iteración 6, antes de `E-PG-07` web | Autorizar la descarga e instalación de los navegadores de Playwright (WebKit y Firefox; Chromium si no está) y su tamaño aproximado; sin esa autorización, `E-PG-07` web se registra como diferido por la persona |
| §13 | Confirmación solo de los elementos marcados «consultar» |
| `P6` | Aprobar o rechazar la métrica candidata `PERF.PG.HTTP`; revisar `E-PG-07` y `E-PG-09`; autorizar commit y push de cierre |

---

## 10. Orden de ejecución y puntos de control

Antes de **cada** iteración: (1) `git status` limpio o solo con cambios de la fase; (2) `git branch --show-current`
debe ser `feature/agregar-ruta-de-especificacion`; (3) protocolo de disco de §13.

| Iteración | Contenido | Verificación al cerrar (solo §7.1.1 sobre lo tocado) | Punto de control |
|---|---|---|---|
| **1 · Corpus** | Lectura pendiente de §2; tareas `.01` y `.02` de todos los puntos; `CF-PG5-04` | Integridad del corpus | **`P1`**: confirmaciones de §9; solo entonces `lock --refresh` |
| **2 · Biblioteca pura** | `PG-5.01.03`–`.06`: tabla generada, léxico, texto, bytes, JSON, disposición JSON, tipos y transferibilidad, validador de facetas, fichas | Tests filtrados de `library`, `abi`, `runtime` (`json_document`), `semantic`, `see_validation`; Clippy y `rust-checks` | `P2`: informe breve y parada |
| **3 · Red en el motor** | `PG-5.02` y `PG-5.03` en el motor; configuración CLI correspondiente cuando la tarea la incluya | Tests filtrados de los crates afectados; Clippy, rustfmt local y `rust-checks`; integridad y exportación del corpus | `P3`: informe breve y parada |
| **4 · Adaptador nativo y servidor** | `PG-5.06.01` (elección con autorización), `PG-5.04`/`.05`/`.06` en la CLI, `PG-5.07` (servidor), `PG-5.08.06` (`cargo tree`) | `cargo check`, tests filtrados de la CLI y del `xtask`, `cargo deny check`, Clippy y `rust-checks` de la CLI | `P4`: informe breve y parada |
| **5 · Web, app y trabajador** | `fetch_host.mjs` y su test sin navegador; app (anfitrión simulado, proyección, fichas visibles); `pg_http` y registro de vectores (código, no ejecución); `--nativo` con red rechazado | `node --test` del adaptador; `dart analyze` y `check_limits.dart` de lo tocado; tests unitarios filtrados del trabajador; `cargo check --tests` de la CLI | `P5`: informe breve y parada |
| **6 · Conformidad pesada, experimentos y cierre** | Todas las tareas `.07`; §7.3, §7.4, §7.5; disparadores de §7.1.4; cierre común `PG-5.C01`–`C13`; commit y push | Todas las pesadas en verde | **`P6`**: la persona revisa y autoriza commit y push |

**Orden fijo de subsanación en la iteración 6.** Si una prueba pesada falla: (1) reproducir el caso aislado (con
`--only` y, si hace falta aislar un caso, la petición JSONL al adaptador, como en `PG-4`); (2) decidir si el error está
en el código o en el caso; si está en el caso, **no** se cambia el esperado sin derivarlo de nuevo de la regla e
informar a la persona (`SPEC-INDEPENDENT-ORACLE`); (3) corregir; (4) repetir solo lo que falló; (5) al final, repetir
una vez la selección pesada completa de §10.1. Una divergencia AOT cuya única causa sea `nativeTasksUnsupported` se
registra bajo `CF-PG5-02` y no bloquea la secuencia: se continúa con el siguiente ID.

### 10.1 Selección pesada de la iteración 6

Contratos para `--only` (engine y aot): `LIB.MODEL`, `LIB.CORE.TEXT`, `LIB.CORE.BYTES`, `LIB.JSON`, `LIB.HTTP`,
`LIB.HTTP.POLICY`, `LIB.IO`, `LIB.SCENARIO.FILE-JSON`, `LIB.SCENARIO.HTTP-TASKS`, `LIB.SCENARIO.BILINGUAL`,
`LANG.CAPABILITY.MODEL`, `LANG.TASK.ISOLATION`, `LANG.PROFILE.VOCABULARY`, `ENG.LIMITS`, `ENG.EFFECT.TAPE`,
`ENG.EXEC.EFFECT-COMMIT`, `RT.HOST.INTERFACE`, `API.EXECUTE`, `API.WIRE-FORMAT`, `API.PROJECT.MANIFEST`,
`TOOL.SERVICE.CATALOG` (sujeto `service`), `TOOL.CLI.RUN` (sujeto de la CLI), `DIAG.CATALOG`, más los centinelas de
§7.1.4 activados. Desde `packages/pseudolearn_spec`, **por cada ID, en este orden**:

1. `cargo run --locked -p see_cli --bin see -- conform --subject engine --only <ID>`
2. `cargo run --locked -p see_cli --bin see -- conform --subject aot --only <ID>` (omitir si el contrato no declara
   `aot` en `sujetos`)
3. `cargo run --locked -p see_cli --bin see -- differential` (omitir si se omitió el paso 2)

El resultado de cada paso se copia a §11 antes del siguiente ID, porque cada `conform` reescribe la evidencia local;
la evidencia previa con hash obsoleto se conserva con sufijo de fecha antes de regenerar. Después: propiedades de
`LIB.JSON`; desde `apps/pseudolearn_cli`, `cargo test --locked --test network_adapter_contract`, `--test
network_security_vectors`, `--test network_vector_registry` y `--test security_vectors` (regresión de archivos);
desde `W/`, `pnpm exec playwright test` o la orden documentada en su README para `http_contract.test.mjs`; desde
`packages/pseudolearn_engine`, `cargo run --release -p pseudolearn_bench_worker -- <subcomando pg_http>` según su
README y la regresión `PERF.SUITE.CORE`; desde `apps/pseudolearn_app`, `flutter test test/architecture_test.dart`,
`flutter test test/engine/rust/<archivo>_test.dart` por archivo tocado y `bash tool/test_bridge.sh`;
`PERF.ARTIFACT.SIZE`.

---

## 11. Resumen de ejecución

| Tarea | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| `PG-5.01` | Completa, incluida la pesada `.07` (2026-10-29); sin commit ni push | `.07`: `conform` de `engine` y `aot` por ID con `differential` tras cada par: `LIB.MODEL` (24 obs.), `LIB.CORE.TEXT` (72), `LIB.CORE.BYTES` (20), `LIB.JSON` (64), `LANG.TASK.ISOLATION` (100); `TOOL.SERVICE.CATALOG` en `service` (11, 0 divergencias, porque el contrato declara solo ese sujeto). Centinela léxico en ambos sujetos: `LANG.LEXICAL.KEYWORD`, `LANG.LEXICAL.IDENTIFIER`, `LANG.PROFILE.VOCABULARY`, `LANG.PROFILE.TRANSLATION`, 0 divergencias. `engine`: 0 divergencias en todo. `aot`: 16 divergencias, todas `nativeTasksUnsupported` (`LIB.MODEL#C5`, `LIB.JSON#C16`, `LANG.TASK.ISOLATION#C1` y `#C19`), registradas bajo `CF-PG5-02`. Propiedades de `engine` regeneradas: 28 de 31 cumplen, incluida `LIB.JSON#P1`. Ligeras de lo tocado: `rustfmt --check`, Clippy `-D warnings` y `rust-checks all .` en `pseudolearn_ir`, `pseudolearn_syntax` y `see_generators`; `see validate` (194), `lock --check`, `export --check`; 6 tests de `type_checker_effects_tests`, 3 de `postfix_parser_tests` | Subsanación (orden fijo de §10): (1) `LIB.SCENARIO.HTTP-TASKS#C7` usaba `Propagar` en `Main`; (2) el generador de propiedades usaba el campo `number`; (3) `jsonKindNumber` pasó de `Numero`/`Number` a `JsonNumero`/`JsonNumber` (reservaba `numero` en `PERF.SUITE.CORE#C3/C4`); (4) `jsonErrorLineField`/`jsonErrorColumnField` pasaron a `JsonLinea`/`JsonColumna` y `jsonLine`/`jsonColumn` (reservaban `columna` en `PERF.SUITE.CORE#C5/C6/C15/C16`), y el parser admite esos campos tras el punto; (5) `fallible` de `json_real`, `json_array`, `json_object`, `json_keys`, `json_with_element` y `json_with_field` pasó a `false`, porque la regla y las firmas de §3.3.3 los definen como trampa, no como `Resultado`; (6) el verificador de RI exigía celdas `f64`/`bool` para `OptionalReal`/`OptionalBoolean`, pero los variantes guardan palabras `i64`; (7) casos `LIB.JSON#C2,C3,C4,C6,C13,C14,C15` reescritos en el programa (nunca en el esperado: `\u` escapado, variables `array`/`object` renombradas, `Opcional` consultado con `Segun`); (8) `LIB.CORE.TEXT#T3` no tenía caso propio: añadidos `C17` y `C18` (límite de celdas con `Recortar`, derivados de `ENG.LIMITS#R2`); (9) vínculos `LIB.MODEL#M1`–`M4` pasan a `estructural`. Reanclados `LIB.MODEL`, `LIB.JSON`, `LIB.CORE.TEXT`, `LANG.PROFILE.VOCABULARY`, `LIB.SCENARIO.HTTP-TASKS`, `LIB.SCENARIO.FILE-JSON`. **Pendientes abiertos, no bloquean `.07`:** `IR.LOWERING#P1`–`P3` incumplen en `engine` (nunca tuvieron evidencia previa; no se probó que sean anteriores a `PG-5`); en `aot`, `MEM.IDENTITY#P1` y `MEM.MANAGED.UNOBSERVABLE#P1` fallan con `internalFault` al ejecutar `ConCampo` con `gc_stress` (reproducido a mano: `ConCampo("b", JsonEntero(9))` falla solo con `gc_stress`; la causa no está localizada), y `RT.ABI#P1/P2`, `RT.FAULT.REPORTING#P1` por `nativeTasksUnsupported`. Cada edición de especificación invalida `results/properties-*.json`, por lo que hubo que regenerarlas (~25 min). Respaldos `*.before-pg-5-01-07-2026-10-29.json` en `results/` |
| `PG-5.02` | Código, casos C1–C12 y verificaciones ligeras completados; conformidad pesada pendiente | Tests filtrados de ABI, runtime, semantic, project, API, `see_format`, `see_validation` y `see_conformance`; los casos de API atraviesan library e IR; `cargo check`, Clippy `--all-targets`, `rustfmt --check`, `rust-checks all .` de engine y spec; `see validate`, `see lock --check` y `see export --check` pasan | `LIB.HTTP` comienza `estable` con `Cesar Antonio Gutierrez Contreras` en `revisado_por`. Los vínculos engine/AOT quedan `pendiente` para P6; AOT R5 conserva `CF-PG5-02`. `LIB.HTTP#R6`/C8 mantienen un conflicto acotado a reproducir respuestas con credenciales. Sin commit ni push |
| `PG-5.03` | Implementación, casos y verificaciones ligeras completados; únicamente `.07` excluida; fase sin cierre verde | Pruebas filtradas de API HTTP (6), límites API (4), runtime (8), JSON (4), sintaxis, opciones de API y mapeo SEE (11); `cargo check`, Clippy y `rust-checks` del motor y la CLI; `see validate` (190), `see lock --check` y `see export --check` pasan | El verificador completo sigue bloqueado por fallos de `LIB.TIME#C1` y limpieza de colecciones C12. `cargo deny check` no pudo actualizar su base de avisos por falta de red. No se ejecutó `.07`; sin commit ni push |
| `PG-5.04` | Implementación y verificaciones ligeras completadas; `.07` excluida; fase sin cierre verde | 7 tests de runtime, 5 de política de direcciones, 7 del resolvedor, 1 de TLS y test ABI HTTP; `see validate` (191), `lock --check`, `export --check`, Clippy estricto, `rustfmt --check` y `rust-checks all .` de la CLI | La batería pesada y la conformidad de `LIB.HTTP.POLICY` siguen pendientes por exclusión explícita de `.07`. La configuración de TLS/resolvedor no se integra aún en transporte real; la elección de biblioteca pertenece a `PG-5.06.01`. Sin commit ni push |
| `PG-5.05` | Implementación ligera `.01`–`.06` completada en una iteración; `.07` excluida; fase sin cierre verde | 20 tests `network_*` de la CLI, tests filtrados de clasificación y cinta en runtime, corpus (191), `lock --check`, `export --check`, `cargo check`, Clippy, `rustfmt`, `rust-checks`, `cargo deny` y build release | Sin conformidad pesada, commit ni push; la salida a red sigue sin opciones de concesión en la CLI |
| `PG-5.06` | Implementación ligera de `.01`–`.06` completada en una iteración; `.07` excluida; fase sin cierre verde | Selección: Hyper 1.11.1 con HTTP/1 directo, Rustls 0.23.46 y `flate2` 1.1.10 con backend Rust; `cargo deny check` pasa sin ampliar licencias. Documentación consultada: [Hyper 1.11.1](https://docs.rs/hyper/1.11.1/hyper/client/conn/http1/fn.handshake.html), [reqwest 0.13.5](https://docs.rs/reqwest/0.13.5/reqwest/), [ureq 3.4.2](https://docs.rs/ureq/3.4.2/ureq/) y [flate2 1.1.10](https://docs.rs/flate2/1.1.10/flate2/). API: concurrencia fuera del orden de solicitud y cinta en orden de finalización (1 test), orden/reproducción de efectos (9) y negociación (3). Runtime: 6 tests de política y 4 de configuración. CLI: transporte, flujo, cancelación, proxy y matriz TLS (19), DNS (7), validación TLS (3), opciones (2), rechazo `--native` con red (2); Fetch (10). `see validate` (191), `lock --check`, `export --check`, `cargo check --all-targets`, Clippy estricto, `rustfmt --check`, `rust-checks all .` en engine y CLI; build `release` 17,886,160 → 17,998,784 bytes (+112,624; 0.11 MiB). | Se eligió Hyper porque expone el handshake sobre el `TcpStream` ya resuelto por el adaptador; la prueba con `HTTPS_PROXY` confirma cero conexiones al proxy. La matriz local acepta una raíz PEM declarada y rechaza certificados caducados, de host incorrecto y autofirmados; `/grande`, `/bomba-gzip`, `/lento`, redirección visible y cancelación también pasan. No se ejecutó `.07` (`E-PG-07`); sin commit ni push |
| `PG-5.07` | Implementación ligera `.01`–`.06` completada en una iteración; `.07` excluida; fase sin cierre verde | Servidor: 4 tests filtrados del `xtask` (rutas, loopback, transmisión continua, demora y TLS). Corpus: caso negativo añadido y `see validate` (191), `lock --check`, `export --check`. CLI: `cargo check`, Clippy estricto, `rustfmt --check`, `rust-checks all .` y `cargo deny check` | No se ejecutaron la auditoría de URL ni la conformidad completa de `.07`; sin commit ni push |
| `PG-5.08` | Implementación ligera `.01`–`.06` completada en una iteración; `.07` excluida; fase sin cierre verde | `PERF.ARTIFACT.SIZE` y el corpus siguen sin cambios. `cargo tree --locked -e normal` de `pseudolearn_api` sin `native`, `pseudolearn_wasm` y `pseudolearn_bridge` no contiene paquetes de HTTP, TLS ni resolución DNS; `rust-checks isolation` pasa en engine y app | El lock del puente se regeneró en modo offline por cuatro paquetes transitivos que faltaban del `serde_json` actual. No se ejecutó la medición `.07`; sin commit ni push |
| `PG-5.09` | | | |
| `PG-5.10` | Implementación ligera `.01`–`.06` completada en una iteración; `.07` excluida; fase sin cierre verde | 12 tests `pg_http_` del trabajador; 4 tests del verificador RI para celdas de referencias JSON; `cargo check --tests` y Clippy estricto de CLI; Clippy estricto de worker e IR; `rustfmt --check` y `rust-checks all .` en engine y CLI; `node --check` y 10 tests de `fetch_host.test.mjs` | La comprobación del worker encontró que el verificador RI rechazaba referencias JSON válidas en celdas `str`; se ajustó el contrato `JsonResult`/`OptionalJsonValue` y se documentó en el README de IR. No se ejecutaron los contratos contra servidor real, Playwright ni las campañas de §7.3–§7.5; `.07` y la aprobación de `PERF.PG.HTTP` quedan para P6. Sin commit ni push |
| Lectura pendiente de §2 | | | |
| Espacio liberado (§13) | Nivel 1 | Antes de la compilación `release`: `df -h /` mostró 22 GiB libres. `du -sh`: engine incremental 1.2 GiB, CLI incremental 980 MiB, spec target 1.0 GiB y, en la segunda medición, CLI incremental 231 MiB. Se retiraron esos incrementales y el `target` ya verificado de spec; `df -h /` quedó en 25 GiB antes y después del build. | Se liberaron aproximadamente 3.4 GiB de artefactos regenerables; no se borraron archivos versionados ni resultados |

Revisión Git de cierre: · Verificadores ejecutados: · Suites omitidas y por qué: · Pendientes justificados: ·
Puntos de §4 cumplidos:

### Registro de ejecución de P3 · 2026-10-29

- **Contexto:** la persona autorizó P3 y acotó el trabajo a `PG-5.02`–`PG-5.05` en el motor. La rama era
  `feature/agregar-ruta-de-especificacion`, el árbol estaba limpio y había 32 GiB libres. El corpus no contiene
  `LIB.HTTP`, `LIB.HTTP.POLICY` ni casos de HTTP para el anfitrión falso. El estado del plan mantiene pendiente P1:
  confirmar las formas candidatas y aportar `revisado_por` antes de anclar especificaciones.
- **Alternativas evaluadas:** (a) crear ahora las reglas y los casos a partir de §3 del plan y continuar; (b) escribir
  el motor directamente desde ese plan y resolver manualmente la tabla generada; (c) dejar sin aplicar los cambios
  dependientes de contratos ausentes, registrar el prerrequisito y detener P3. Se eligió **(c)**. La opción (a)
  anclaría contratos sin la revisión requerida por P1 y `SPEC-VERSION-FREEZE`; la opción (b) haría depender el
  comportamiento del plan transitorio, contradiría `SPEC-BEHAVIOR-TRUTH` y `SPEC-FIRST`, y editar a mano la tabla
  generada contradiría `GEN-NO-HAND-COPY`.
- **Impacto:** `PG-5.02`–`PG-5.05` siguen pendientes; no se modificó código ni README de paquetes y no se avanzó a P4.
  No se ejecutaron tests filtrados, Clippy ni `rust-checks` porque ningún crate pudo tocarse sin los contratos y casos
  previos. Las verificaciones pesadas de la iteración 6 también quedan pendientes. No se liberó espacio.
- **Verificación:** rama y limpieza de Git confirmadas antes del trabajo; búsquedas locales confirmaron que faltan las
  identidades HTTP y los casos del anfitrión falso; `df -h /` informó 32 GiB libres y `du -sh` informó 1.2 GiB de
  incrementales de engine, 359 MiB de spec y 0 B de rust_checks. La edición de este registro se limita al plan.
- **Pendiente para reanudar:** completar y revisar las reglas y casos previos al motor, resolver P1 (incluido
  `revisado_por`) y luego ejecutar P3 con el contrato anclado. La parada de esta ejecución queda en P3.

### Registro de reanudación de P3 · 2026-10-29 · PG-5.02

- **Contexto:** la instrucción más reciente acotó esta ejecución a `PG-5.02`; no se avanzó a `PG-5.03`–`.05` ni a
  P4. Rama `feature/agregar-ruta-de-especificacion`. El estado de `LIB.HTTP` no se pudo cerrar como contrato estable
  sin la revisión independiente requerida.
- **Decisión — tipos y RI:** se eligió `MetodoHttp` como enumerado contextual cerrado, con valor escalar en la ABI,
  y `effect_call` existente para llevar operaciones HTTP. Se descartaron palabras reservadas y nuevas instrucciones
  de RI: los nombres contextuales no rompen identificadores y la tabla de operaciones ya expresa el contrato.
  El impacto es una comprobación de tipos en RI para `HttpMethod` como `i64`. Se verificó al compilar y ejecutar los
  casos HTTP por la API.
- **Decisión — anfitrión y respuestas:** se eligió el proveedor de memoria con guiones `anfitrion.http` por método y
  URL, sin conexiones reales. Se descartó un cliente público de red en las pruebas para mantener determinismo y
  aislamiento local. Los estados completos, incluidos 4xx/5xx, se conservan en `RespuestaHttp`; los fallos de envío
  siguen siendo valores de error. Se verificó con C1–C9, cabeceras, bytes y pruebas de runtime/API.
- **Decisión — campos de límite y tiempo:** se conservaron `ConLimiteRespuesta` y `ConTiempoMaximo` como constructores
  inmutables del modelo solicitado; no se añadió recorte ni cancelación temporal, porque su comportamiento pertenece
  a `PG-5.03`. Se descartó adelantar esos límites. Los valores se codifican y sobreviven a la serialización de la
  petición; se verificó con `http_values_tests`.
- **Decisión — credenciales y cinta:** no se cambió la política general que redacta secretos y marca la cinta como
  no reproducible. `LIB.HTTP#R6` pide conservar la respuesta completa para reproducirla, mientras C8 exige
  `non_reproducible_redacted`; se deja sin aplicar la reproducción de respuestas secretas y se registra el conflicto
  para resolución editorial. Las pruebas verifican que no se filtre el valor y que respuestas sin secretos se
  reproduzcan sin anfitrión.
- **Conflicto de ciclo de vida:** `see validate` exige que una identidad nueva empiece `estable`, pero el ciclo de vida
  exige revisión independiente y el plan reserva `revisado_por` al nombre que aporte la persona. Se conserva
  `LIB.HTTP` en `experimental`; no se inventó un revisor ni se declara verde el validador. La única salida restante de
  `see validate` es `SEE-STATE`. `see export --check` sí pasa.
- **Impacto:** código y documentación de ABI, RI, runtime, biblioteca, semántica, proyecto, API y spec; permiso `red`,
  operaciones y tipos HTTP, política de orígenes y anfitrión falso. Las tareas HTTP concurrentes y la divergencia por
  petición alterada no tienen aún casos HTTP específicos; las reglas generales de tarea y reproducción no se
  reescribieron. No hubo cambios de redirección ni se aplicó P4. No hay commit ni push.
- **Verificación:** pasaron `cargo test` filtrados de `pseudolearn_abi`, `pseudolearn_runtime` (política, valores y
  efectos), `pseudolearn_semantic`, `pseudolearn_project`, API HTTP, `see_format` y `see_validation` (incluida la
  cobertura de identidades actualizada); Clippy de bibliotecas afectadas, Clippy de los targets HTTP modificados,
  `rustfmt --check` en archivos tocados, `rust-checks all .` para engine y spec, y `see export --check`. Clippy global
  `--all-targets` también intenta compilar `api/tests/native_benchmark.rs`, que depende de la feature `native`; el
  filtro del target HTTP pasa. No se ejecutó la selección pesada `.07` ni `cargo xtask verify`.
- **Decisión de parada:** `PG-5.02.03`–`.06` quedan verificadas; `.01` sigue bloqueada por el estado editorial y `.02`
  conserva los casos HTTP concurrentes y de divergencia como pendientes. `PG-5.02.07` queda para P6. Se detiene en P3,
  sin avanzar a `.03`–`.05`, P4, commit o push.

Revisión Git de cierre: rama correcta; cambios locales sin commit; sin push. Verificadores: los enumerados arriba.
Pendientes: conflicto `LIB.HTTP#R6`/C8 y suites pesadas `.07` de P6. Protocolo de disco: 27 GiB libres
en esta continuación; no se borraron cachés.

### Continuación de reanudación de P3 · 2026-10-29 · PG-5.02

- **Contexto:** se continuó sobre `feature/agregar-ruta-de-especificacion` con los cambios locales de PG-5.02 sin
  commit. La instrucción vigente se acotó solo a `PG-5.02`; no se trabajó en `PG-5.03`–`.05`, P4 ni P6.
- **Decisión — casos concurrentes y reproducción divergente:** se completaron C10 y C11 para cubrir, respectivamente,
  entregas fuera del orden de solicitud y divergencia por resumen de petición. Para C11 se eligió modificar el
  `request_digest` de `network_send` y recalcular el hash encadenado; corromper solo el payload o el hash habría medido
  corrupción de cinta, no una petición distinta. `alterar_solicitud` queda limitado al corredor de conformidad y no
  agrega una instrucción ni una opción de ejecución del producto. Se verificó con la prueba API de divergencia aislada
  y las pruebas de `see_conformance` sobre alteración.
- **Decisión — estado HTTP 101:** el cargador del anfitrión falso conserva el estado guionado y el runtime valida la
  respuesta al entregar `network_send`. Se descartó rechazar 101 al cargar la configuración porque impediría que el
  programa observe `RespuestaInvalida` como resultado del efecto externo. C12 verifica que una respuesta vacía 200 se
  entrega y que 101 se convierte en fallo reproducible; la secuencia esperada incluye los efectos de consola previos.
- **Impacto y README:** se actualizaron los README de ABI, runtime, proyecto, motor y los paquetes previamente
  afectados para explicar `Network`, el permiso `red`, los códigos HTTP y la frontera del anfitrión falso. Los casos
  C1–C12 se ejecutaron por la API sin sockets públicos.
- **Verificación:** pasaron tests filtrados de `pseudolearn_abi`, runtime (política, valores, efectos y configuración),
  API HTTP (6), semantic, project, `see_format`, `see_validation` (esquema y referencias) y `see_conformance` (16 de
  grabación). Pasaron `cargo check` de crates tocados, Clippy `--all-targets` de engine con la feature `native` y de
  spec, `rustfmt --check` de 61 fuentes Rust tocadas y `rust-checks all .` en ambos paquetes. `see export --check`
  pasó. `see validate` reportó únicamente `SEE-STATE`.
- **Conflictos y pendientes:** se mantiene el estado `experimental` porque no existe la revisión independiente exigida
  para publicar una identidad nueva como `estable`; no se asignó un revisor. `LIB.HTTP#R6` afirma que la respuesta
  completa con credenciales se conserva para reproducirla, mientras C8 espera `non_reproducible_redacted`; se conserva
  la política de redacción ya existente y se deja sin resolver solo la reproducción de respuestas secretas. `PG-5.02.07`
  y las demás verificaciones pesadas siguen reservadas a P6. La casilla ligera `.06` queda abierta por `SEE-STATE`.
- **Disco y parada:** `df -h /` informó 27 GiB libres; los incrementales medidos fueron 2.8 GiB (engine), 567 MiB
  (spec) y 0 B (rust_checks); `apps/pseudolearn_app/native/target` ocupa 1.9 GiB. Se superó el umbral de 25 GiB y no
  se borraron cachés. No se hizo commit ni push. La parada queda en P3.

### Corrección editorial de PG-5.02 · 2026-10-29

- **Contexto:** la persona aclaró que las especificaciones nuevas salen `estable` y `revisado_por` debe contener su
  nombre una vez cumplidos los requisitos. La reanudación anterior dejó `LIB.HTTP` experimental por interpretar de
  forma demasiado restrictiva la revisión independiente.
- **Decisión:** se verificó `git config user.name` (`Cesar Antonio Gutierrez Contreras`) y se registró ese nombre en
  `revisado_por`. `responsable-lenguaje` sigue como dueño, por lo que el validador reconoce al revisor como distinto.
  Se añadieron los vínculos estables para `engine` y `aot`; se marcaron `pendiente` hasta P6 en vez de afirmar
  conformidad pesada aún no ejecutada. AOT R5 queda pendiente de `CF-PG5-02` por las tareas que AOT no ejecuta.
  Se reanclaron sin subir versión ni añadir `cambio` los 12 IDs editados: `API.PROJECT.MANIFEST`, `API.WIRE-FORMAT`,
  `ENG.EFFECT.TAPE`, `ENG.EXEC.EFFECT-COMMIT`, `IR.INSTRUCTIONS`, `LANG.CAPABILITY.MODEL`, `LANG.TASK.ISOLATION`,
  `LIB.HTTP`, `LIB.IO`, `LIB.MODEL`, `RT.HOST.INTERFACE` y `TOOL.SERVICE.CATALOG`.
- **Alternativas:** se descartó conservar `experimental` y dejar abierto `SEE-STATE`, porque contradice la instrucción
  explícita de la persona. También se descartó marcar los vínculos `cumple` antes de las campañas `.07`; se usa el
  estado `pendiente` con su punto de resolución real.
- **Impacto y verificación:** `see validate` pasó para 190 especificaciones después de añadir estado, revisor y
  vínculos; `see lock --check` y `see export --check` también pasaron. No se alteró la regla `LIB.HTTP#R6` ni C8; su
  conflicto sobre la reproducción de respuestas con credenciales sigue aislado. No se avanzó de P3 ni se ejecutó `.07`.

### Registro de ejecución de P3 · 2026-10-29 · PG-5.03

- **Alcance:** se implementó `PG-5.03.01`–`.06` en una iteración sobre `feature/agregar-ruta-de-especificacion`.
  Solo se excluyó `.07`, según la instrucción de la persona; no se ejecutó conformidad pesada ni el servidor local.
- **Corpus:** `ENG.LIMITS#D2` fija los valores de `§3.4.6`; `R13` distingue `LimiteExcedido`, `TiempoAgotado` y
  `ProfundidadExcedida` como valores, no terminaciones, y prohíbe enviar solicitudes por encima del máximo pendiente.
  `LIB.HTTP#R7` y `C13`–`C24` cubren límites inclusivos, recorte, valores no positivos, bytes en el cable, cabeceras,
  exceso de pendientes, plazo GET/POST y normalización de respuestas excesivas. Se añadió `ENG.LIMITS#C37` para
  comprobar que un exceso de respuesta conserva la ejecución. El anclaje de `ENG.LIMITS` se refrescó bajo el
  congelamiento de versiones.
- **Implementación y documentación:** el runtime valida tamaños de petición/respuesta, cabeceras y límites de
  pendientes; la API conecta los límites configurables con la VM y el anfitrión; la CLI configura sus valores por
  omisión. `max_json_depth` llega a la VM y se aplica al parser JSON. Se actualizaron los README del motor, runtime,
  API, biblioteca, CLI y sintaxis.
- **Verificación ligera:** pasaron 6 tests de corpus HTTP, 4 de límites de API, 8 de runtime, 4 de profundidad JSON,
  los tests de opciones JSON de API y límites por omisión de CLI, los tests de sintaxis y 11 tests del mapeo SEE.
  También pasaron `cargo check`, Clippy estricto y `rust-checks all .` del motor y la CLI; `see validate` validó 190
  especificaciones, y pasaron `see lock --check` y `see export --check`.
- **Bloqueos de verificación general:** `cargo xtask verify` de engine pasó exportación, formato y Clippy, pero el
  test de limpieza de colecciones C12 falló: esperaba `utf8_invalido:Falso` y obtuvo `permiso_denegado:Falso`.
  La ejecución dirigida de `LIB.TIME#C1` también falló: esperaba `100` y obtuvo `permiso_denegado`. El diff no toca
  directamente el reloj ni las operaciones de colecciones; la causa sigue sin determinar y no se declara `PHASE-GREEN`
  hasta resolver ambas observaciones. `cargo deny check` no pudo actualizar su base de avisos por falta de red; la
  comprobación de licencias, fuentes y bans pasó con la base local.
- **Parada:** `PG-5.03.07` queda como única tarea excluida; no se hizo commit ni push y la parada permanece en P3.

### Registro de ejecución de PG-5.04 · 2026-10-29

- **Alcance:** se implementó `PG-5.04.01`–`.06` en una iteración sobre `feature/agregar-ruta-de-especificacion`.
  La persona confirmó `CF-PG5-01`: no hay seguimiento automático; `Redirigida` crea la siguiente petición y
  `Enviar` vuelve a validar el permiso. Se excluyó `.07` como se pidió.
- **Corpus y contratos:** se creó `LIB.HTTP.POLICY` con H2/H8/H9/H10 y casos C1–C8; `LIB.MODEL` incorpora la firma
  `Redirigida`, `TOOL.SERVICE.CATALOG` su ficha y `RT.HOST.INTERFACE` las obligaciones R8/R9. `LIB.IO` añade
  `RedireccionDenegada` como etiqueta ABI 16, sin renumerar etiquetas anteriores. Se editaron las especificaciones
  congeladas conservando identidad y versión; el lock local se refrescó y la exportación se regeneró. Las reglas de
  `LIB.HTTP.POLICY` y R8/R9 quedan pendientes de conformidad P6, no declaradas cumplidas.
- **Implementación y documentación:** runtime construye redirecciones explícitas, resuelve ubicaciones relativas,
  quita fragmentos, aplica las transformaciones de método/cuerpo y retira credenciales cuando cambia el origen.
  La CLI aporta política de host/IP, resolvedor sustituible que valida el conjunto completo y configuración TLS con
  validación obligatoria y raíces añadidas solo por el anfitrión. No se añadió cliente HTTP, conexión, seguimiento
  automático ni proxy ambiental; la integración con transporte se reserva a la elección de biblioteca de
  `PG-5.06.01`. Se actualizaron README de CLI, motor, runtime, biblioteca y ABI.
- **Verificación ligera:** pasaron 7 tests de runtime, 5 de política de direcciones, 7 del resolvedor, 1 de TLS y
  4 del test ABI HTTP; también `see validate` (191 especificaciones), `see lock --check`, `see export --check`,
  Clippy estricto de la CLI, `rustfmt --check` en engine y CLI y `rust-checks all .` de la CLI. `git diff --check`
  pasó. No se ejecutaron conformidad `--only LIB.HTTP.POLICY`, la batería E-PG-09 ni ninguna ruta de `.07`.
- **Pendientes y parada:** la comprobación real de TLS, proxy y conexión fijada a IP depende del adaptador y la batería
  de red. `.07` queda sin marcar; por ello no se declara `PHASE-GREEN` ni se cierra la fase. Rama correcta, cambios
  locales sin commit ni push.

### Registro de ejecución de PG-5.05 · 2026-10-29

- **Alcance:** se implementaron `.01`–`.06` en una sola iteración sobre `feature/agregar-ruta-de-especificacion`.
  Se excluyó `PG-5.05.07` de desarrollo y ejecución. La elección del transporte se adelantó con autorización
  expresa para evaluar `PG-5.06.01`; no se avanzó al resto de PG-5.06.
- **Corpus:** `LIB.HTTP` no contiene identidades `H6`/`H7`; se amplió la regla vigente `R5` y sus verificaciones,
  sin inventar reglas paralelas. `C25`–`C27` cubren corte de GET, corte de DELETE y cancelación de POST. `R5` de
  `ENG.EXEC.EFFECT-COMMIT` y sus casos `C8`–`C10` registran resultado, incertidumbre y un solo efecto. `R6` y
  `C16` de `ENG.EFFECT.TAPE` sellan `UncertainExternalState` cuando se abandona `network_send`. Se refrescó el
  lock y se regeneró la exportación conservando identidades y versiones.
- **Implementación:** runtime conserva GET/HEAD como no mutadores y POST/PUT/PATCH/DELETE como mutadores; la
  cancelación de un envío abandonado deja la cinta incierta. La CLI realiza un solo envío HTTP/1 por conexión, sin
  reintento, redirección, cookies ni proxy ambiental; mide la incertidumbre desde el primer byte HTTP escrito,
  limita la respuesta por flujo y aborta la tarea de conexión al cancelar. Rustls diferencia certificados inválidos
  de otros fallos TLS. Se extrajo `resolve_reference` en el resolvedor de redirecciones para cumplir el límite de
  anidamiento de `rust-checks` sin cambiar su comportamiento. Se actualizaron los README del motor y la CLI.
- **Decisión de transporte adelantada:** se seleccionó Hyper `1.11.1` con Tokio `1.54.1`, Rustls `0.23.46`,
  `tokio-rustls` `0.26.6` y raíces nativas `rustls-native-certs` `0.8.5`. La conexión directa de Hyper evita
  capas que agreguen reintentos, proxy o seguimiento. Las fuentes consultadas y la decisión quedaron en el README
  de la CLI. `cargo deny check` pasó con la base local; la persona autorizó agregar `ISC`. Se descartó
  `rustls-pemfile` por su aviso de mantenimiento; `rustls-pki-types` `1.15.1` analiza PEM. El único skip nuevo de
  versiones múltiples es `windows-sys@0.52.0`, requerido por `ring`.
- **Verificación ligera:** pasaron los 20 tests filtrados `network_*` de la CLI, incluidos cinco loopback de
  envío y cancelación, DNS/política y tres pruebas TLS; pasaron las pruebas filtradas de clasificación de métodos
  y de cinta del runtime. También pasaron `cargo check --all-targets`, Clippy estricto, `rustfmt --check`,
  `rust-checks all .` de CLI y runtime, `see validate` (191), `lock --check`, `export --check`, `cargo deny check`
  y `git diff --check`. La toolchain fue `1.99.0` en macOS arm64. Con 27 GiB libres, el build release pasó:
  17,886,160 bytes frente a 15,525,680 antes de añadir el transporte, crecimiento de 2,360,480 bytes (≈2.25 MiB).
- **Pendientes de la evaluación `.06.01`:** falta la prueba de integración del proxy ambiental y la matriz de
  servidor TLS local (certificado válido, vencido, de otro host y autofirmado), además del corte/plazo de respuesta
  por flujo. La selección está documentada, pero `.06.01` no se declara cerrada hasta medir esos criterios.
- **Parada:** `.07` permanece sin marcar y no se corrieron conformidad `--only`, baterías ni integración pesada. No
  se declara `PHASE-GREEN` ni se cierra la fase; rama correcta, cambios locales sin commit ni push.

---

## 12. Protocolo operativo para la IA ejecutora

Reglas que no admiten interpretación:

1. **No empezar sin autorización.** Si el mensaje de la persona no autoriza explícitamente una iteración de §10, no se
   escribe especificación ni código.
2. **Orden inamovible por tarea:** especificación → casos → tests → código → README → verificación ligera. No se
   escribe código de una regla cuyo caso no existe.
3. **Esperados derivados de la regla**, nunca copiados de la salida del motor.
4. **Identidades nuevas** del corpus: `estado: estable`, `version: 1.0.0`, sin `cambio`; `revisado_por` solo con el
   nombre que aporte la persona en `P1`. Identidades existentes: edición oficial, misma versión y estado, reanclaje
   autorizado (`SPEC-VERSION-FREEZE`).
5. **Edición quirúrgica.** Nunca reescribir una especificación con `json.load`/`json.dump` ni otro recorrido de ida y
   vuelta; editar solo los bloques afectados. Nunca `cargo fmt` sin `--check` sobre un miembro entero ni `dart format
   .`: formatear solo los archivos creados o tocados.
6. **Cero comentarios, cero `TODO`**, código en inglés, documentos en español. En Rust: sin `unwrap`, `expect`,
   `panic!`, `todo!`, `unimplemented!`, `unreachable!`, índices inseguros, aritmética implícita ni conversiones con
   pérdida; sin `#[allow]`, `#[expect]` ni comentarios de documentación. JavaScript del adaptador web: sin
   comentarios, mismas reglas de nombres en inglés.
7. **Límites:** contar líneas antes de guardar; dividir por responsabilidad si se superan (§1.2.9).
8. **Nombres:** archivos HTTP con prefijo `network_`/`http_`; nunca `request.rs` a secas ni `utils`/`helpers`.
9. **Generados:** exportación, léxico, tabla de operaciones y despacho se regeneran; nunca a mano.
10. **Sin red en el corpus ni en tests unitarios.** Solo las pruebas pesadas de integración usan sockets, y solo hacia
    el servidor local en loopback. Nunca se apunta una prueba a un dominio real.
11. **Dependencias:** ninguna dependencia nueva fuera de la CLI y su `xtask`; ninguna en el motor, Wasm o puente. La
    biblioteca HTTP solo se añade tras `PG-5.06.01` y autorización.
12. **Documentación de terceros:** antes de usar una opción de la biblioteca elegida, leer su documentación para la
    versión exacta fijada en `Cargo.lock`; registrar en el README de la CLI qué se tomó y qué se rechazó
    (`AGENTS.md` §3). No dar por existente una API recordada.
13. **Conflictos:** ante cualquier contradicción o semántica no cubierta por §3.4, detenerse, citar las fuentes y
    esperar.
14. **Pruebas:** solo §7.1.1 sobre lo tocado en las iteraciones 1–5; una ligera roja bloquea la iteración. Las pesadas
    solo en la iteración 6.
15. **Procesos largos:** compilaciones `release`, servidor de prueba y campañas en segundo plano con notificación;
    nunca bucles de sondeo que se autoconfirman ni confiar en el código de salida de una tubería con `| tail`.
16. **Registro:** cada iteración añade a §11 qué se ejecutó, su resultado, qué se omitió y por qué, y el espacio
    liberado.
17. **Git:** sin ramas nuevas, sin `git clean`, sin `--force`, sin atribución de IA; commit con la skill
    `commit-message` y push ordinario solo en la iteración 6 tras `P6`.
18. **Parada:** al cerrar cada iteración, informe breve y parada (`PHASE-STOP`).

---

## 13. Protocolo de espacio en disco

**Obligatorio** antes de cada iteración, antes de toda compilación `release`, antes de las campañas de §7.3–§7.5 y
siempre que una orden falle por falta de espacio. Objetivo: **al menos 25 GiB libres** en las iteraciones 1–5 y **al
menos 40 GiB** antes de la iteración 6.

### 13.1 Medir

`df -h /` y `du -sh` de los candidatos de §13.2; anotar ambos.

### 13.2 Liberar, en este orden, hasta alcanzar el objetivo

**Nivel 1 — sin coste práctico:** directorios `target/*/incremental` de todos los miembros Rust;
`xcrun simctl delete unavailable`; `~/Library/Developer/Xcode/DerivedData/*`; `~/Library/Logs/*`;
`npm cache clean --force`, `pnpm store prune`, `brew cleanup -s` (si existen); `apps/pseudolearn_app/build`;
`target` de miembros que la iteración no compila (por ejemplo `apps/pseudolearn_app/native/target` en las
iteraciones 1–4 y `packages/pseudolearn_benchmarks/ceiling/target`).

**Nivel 2 — coste de recompilación:** `cargo clean` en `packages/pseudolearn_engine`, `apps/pseudolearn_cli` y
`packages/pseudolearn_spec`; contenido de `~/Library/Caches/` con las aplicaciones cerradas; `rustup toolchain
uninstall stable` (todos los miembros fijan `1.99.0`, que nunca se borra); `flutter pub cache clean` solo si habrá red
para `flutter pub get`; `~/.cargo/registry/cache` (se vuelve a descargar con red: en la iteración 4 solo después de
fijar la dependencia en `Cargo.lock`).

**Consultar a la persona antes de borrar:** la papelera; `~/.cache/ms-playwright` u otras cachés de navegadores de
prueba (podrían ser de otros proyectos); `~/Library/pnpm`; herramientas ajenas al repositorio; cualquier carpeta cuyo
dueño no sea evidente.

### 13.3 Prohibido borrar

Cualquier archivo versionado; `.git`; `packages/pseudolearn_spec/results/`, `packages/pseudolearn_engine/results/` y
todo directorio ignorado con evidencias de fases; la toolchain `1.99.0`; `~/.cargo/bin`; `~/.rustup` salvo la
toolchain no fijada; `~/.ssh`, llaveros, credenciales y documentos personales. Nunca `git clean -fdx` ni borrados por
patrón sobre la raíz del repositorio o sobre `~`.

### 13.4 Registrar

Cada limpieza se anota en §11 (fila «Espacio liberado»): espacio antes y después y niveles aplicados.
