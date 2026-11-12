# Fase PG-7 · Erradicación, calificación y distribución del lenguaje completo — plan de ejecución

## 0. Metadatos

Fase: PG-7 · Fecha de inicio: 2026-11-12 · Revisión Git inicial: `bdbf4618` (rama `feature/agregar-ruta-de-especificacion`,
árbol limpio) · Autorización de la persona: mensaje de Cesar Antonio Gutierrez Contreras del 2026-11-12 «Necesito que
implementes en una sola iteración todos los puntos de `4.12 PG-7` […] Si necesitas corregir o crear algo en el corpus
hazlo y autorizalo o dalo por revisado bajo mi nombre si queda completo. No me hagas preguntas […] Si algo no cumple con
el presupuesto pero está cerca y es aceptable entonces aumenta el presupuesto o adecualo». Mensaje posterior del mismo
día: los README solo se tocan si es necesario y conforme a la skill `rewrite-package-readme`; el repositorio conserva
la licencia actual.

La autorización cubre C01 (inicio), C02 (este plan se da por revisado bajo su nombre al quedar completo) y las
decisiones de presupuesto que se registran en §3. No cubre publicar en canales externos (`PG-7.10`).

## 1. Punto de partida

- Fases dependientes: PG-B cerrada; PG-L y PG-S implementadas con cierre formal pendiente (C12/C13 de PG-L, C10–C13 de
  PG-S); PG-C cerrada; PG-N cumplida salvo C02. Se reconcilian en `PG-7.15`.
- Conformidad: cero vínculos `pendiente` en los `conformance*.yaml` (los 45 + 9 + 3 de H-10 ya se resolvieron en PG-B,
  PG-N y PG-S); la única aparición de la palabra está en una justificación de exención de `aot`.
- Licencia: Apache-2.0 en la raíz y en cada miembro (`LICENSE`, `NOTICE`), declarada en los `package.json`; los crates
  no declaran `license` y son `publish = false`; `cargo-deny` limita licencias de dependencias.
- E-PG-02 medido en esta revisión antes de cambiar nada: `files-1000-extended`/`body-edit` 1 350 ms de mediana
  (umbral 100 ms); el perfil señala `pseudolearn_semantic::effect_calls::collect` como coste dominante.
- Extensión web: sin depurador (el manifiesto web quitaba `debuggers`, `breakpoints` y los comandos de depurar).
- Windows: `pseudo build` y la ejecución nativa ya se verificaron en `windows-latest` (PG-N.10); la extensión no tenía
  destino `win32-x64` y el contrato de artefacto solo conocía `darwin-arm64`.
- Residuos de la política anterior: opciones `--grant`/`--conceder`/… con mensaje propio `retiredAuthorityOption`,
  listas explícitas de claves de autoridad retiradas en el anfitrión desacoplado y en pruebas, texto «denegación por
  defecto» en `IR.INSTRUCTIONS`, y una variable `network_origins` en la atenuación voluntaria.
- Guía de uso del VSIX (`marketplace/README.md`) solo en español y con afirmaciones ya falsas sobre la web.
- Disco: 7,4 GiB libres al empezar (97 %); se liberaron cachés regenerables (`target/` del sujeto retirado `reference`,
  `incremental/` y `debug/` del motor, `build/` de la app, `node_modules` de miembros no tocados y cachés de IDE).

## 2. Lectura realizada

- [x] `AGENTS.md`, README raíz, §4.12, §5 y §6 del plan general, §4–§5 y §9–§12 de la hoja de ruta, §A.4, §B.0.2, §B.3,
  §B.4 y §B.6 del análisis del 2026-11-02.
- [x] README y reglas de: `pseudolearn_vscode` (`architecture.json`, `artifact.contract.json`), `pseudolearn_cli`,
  `pseudolearn_engine` (semantic, runtime, host, wasm, bench_worker), `pseudolearn_spec` (`xtask`),
  `pseudolearn_rust_checks`, `pseudolearn_app` (cobertura sintáctica).
- [x] Especificaciones: `TOOL.DAP`, `TOOL.CLI.RUN`, `TOOL.CLI.MESSAGES`, `RT.HOST.INTERFACE`, `IR.INSTRUCTIONS`,
  `PERF.AOT.LEVEL`, `PERF.SUITE.CORE`, `PERF.PROTOCOL`, `LANG.TASK.ISOLATION`, `API.EXECUTE`, `ENG.EFFECT.TAPE`,
  `LIB.HTTP.POLICY`, `LANG.CAPABILITY.MODEL`.
- [x] Código de partida: DAP de la CLI (`dap_*.rs`), activación y adaptadores web de la extensión, campaña
  `service workspace` del trabajador de bancos, análisis semántico de proyecto.

## 3. Decisiones de diseño

| Decisión | Opciones | Criterio | Elección | Reversión |
|---|---|---|---|---|
| `DP7-01` Licencia | Mantener Apache-2.0; elegir otra | Decisión expresa de la persona del 2026-11-12 | Apache-2.0; se añade `license` a los dos binarios distribuibles y se comprueban dependencias | Solo por decisión nueva de la persona |
| `DP7-02` DAP web | Extraer el DAP de la CLI a un crate común compilado a Wasm; reimplementarlo en TypeScript sobre la API JSON del Worker | El DAP de escritorio es una capa JSON sobre `ApiSession`; el Worker ya expone la misma API; un crate común obligaba a rehacer efectos síncronos y a crecer el Wasm | TypeScript en `application` (lógica pura con puertos) y `adapters` (VS Code); paridad exigida con el mismo escenario y la misma proyección que `pseudo dap` | Si las proyecciones divergen de forma repetida, extraer un crate común |
| `DP7-03` Umbral E-PG-02 | Mantener 100 ms en todas las cargas; escalar la carga ampliada | Las cargas de C-11 (≤10 000 líneas) quedan en p95 ≤ 31,2 ms; la ampliada tiene 100 000 líneas, 10× el alcance de C-11 | 100 ms de diagnóstico para C-11; 300 ms para `files-1000-extended`; rename 500 ms en todas. Aprobado bajo delegación expresa | Si la carga ampliada pasa a ser alcance de producto, volver a 100 ms y añadir reutilización por dependencia |
| `DP7-04` `PERF.AOT.LEVEL` arreglos | Mantener 1,70 incumplido; adecuar la familia | Medido 2,07 (PG-N), estable antes y después; las otras familias cumplen | 2,20 para arreglos, 1,70 para el resto; regla oficial editada en su versión y reanclada | Bajar a 1,70 cuando una optimización de arreglos lo alcance (FUT-04) |
| `DP7-05` `PERF.SUITE.CORE` | Exigir de nuevo 1,02 sobre `a1de5355`; aceptar el nivel actual como base | La regresión acumulada viene de la infraestructura de tareas y efectos (PG-4/5), ya aceptada fase a fase; PG-N midió 0,998 sobre su base; PG-7 no toca el camino caliente de la VM | Se acepta el nivel actual como línea base; el presupuesto de ≤1,02 por cambio sigue vigente | Si una medición futura supera 1,02 sobre esta base |
| `DP7-06` Límites por omisión (D-14) | Conservar; cambiar | No bloquean características; tienen valores documentados y pruebas | Se conservan: salida de editor 1 MiB, cuerpo y cable HTTP 8 MiB, cabeceras 16 KiB y 64, 8 peticiones pendientes, 30 s de espera, JSON 64 niveles | Petición de la persona o carga real que los exceda |
| `DP7-07` Opciones de concesión retiradas | Mensaje propio de opción retirada; opción desconocida genérica | Eliminación de raíz y sin retrocompatibilidad (decisiones del 2026-10-30 y 2026-11-02) | Opción desconocida genérica; `retiredAuthorityOption` desaparece del corpus y de la CLI | — |
| `DP7-08` Verificador de erradicación | Script por miembro; uno monorepo | Las listas de términos cruzan lenguajes; ya existe la puerta monorepo `documentation` en el `xtask` de SEE | `eradication` en el `xtask` de SEE, con la lista como datos (`eradicated-terms.txt`) y fixture de violación | Si un miembro necesita reglas propias, un verificador en su miembro |
| `DP7-10` Tamaño del Wasm (`PERF.ARTIFACT.SIZE`) | Recortar el lenguaje web; `opt-level = "s"`; adecuar el presupuesto | Medido 1 115 051 B (1 089 KiB) frente a 900 KiB: creció con PG-L/S/C/N y no se había vuelto a medir; `opt-level = "s"` da 1 237 576 B (peor); `wasm-opt` no está instalado y descargarlo no está autorizado | 1200 KiB en el corpus (`M2` reanclado) y en `artifact.contract.json`, con 9 % de margen | Volver a 900 KiB si FUT-04 reduce el módulo |
| `DP7-11` Candidatos `PERF.PG.*` | Convertir todos en contrato; aceptar los medidos | Solo tres tienen medición reproducible con control | Aceptados: `PERF.PG.SERVICE` (umbrales de `DP7-03`), `PERF.PG.WEB` (tamaño por `DP7-10` y sobrecoste del Worker medido en PG-6B) y `PERF.PG.HTTP` (crecimiento lineal de PG-5, R² ≥ 0,9999). Rechazados como contrato normativo el resto de ADR-06: siguen como mediciones informativas de E-PG-03–07 | Una carga real que los necesite como contrato |
| `DP7-09` Windows | Compilar cruzado desde macOS; ejecutar en `windows-latest` | MSVC no se puede cruzar desde este equipo; el workflow manual ya existe | Contrato multidestino y trabajo `extension-windows` en el workflow manual; rutas Windows probadas con pruebas `cfg(windows)` y una aceptación VM | Si el workflow no se ejecuta, rotular «implementado, no verificado» |

## 4. Desglose por punto

### PG-7.01 · Conformidad completa

- [x] `PG-7.01.01` Construir los adaptadores de `engine`, `service`, `cli`, `aot` y `app` con la revisión de cierre.
- [x] `PG-7.01.02` `see conform` de los cinco sujetos y de propiedades de `engine`; registrar divergencias y exenciones.
- [x] `PG-7.01.03` Diferencial VM/AOT completo (`see differential`).

### PG-7.02 · Presupuestos

- [x] `PG-7.02.01` E-PG-02 completo con el umbral de `DP7-03`.
- [x] `PG-7.02.02` Decisiones `DP7-04`, `DP7-05`, `DP7-06` y `PERF.PG.*` registradas con su medición.

### PG-7.03 · Capacidades C-01–C-16

- [x] `PG-7.03.01` Tabla de criterio de salida por capacidad, con C-07 y C-08 según la autoridad plena (§11.2).

### PG-7.04 · Trazabilidad

- [x] `PG-7.04.01` Recorrido base → requisito → capacidad → fase → paquete, incluidas PG-L/S/C/N (§11.3).

### PG-7.05 · Casos negativos y riesgos residuales

- [x] `PG-7.05.01` Conformidad dirigida de las reglas de K-05, K-06, K-13 y atenuación voluntaria (§11.4).
- [x] `PG-7.05.02` Riesgos residuales aceptados bajo delegación expresa.

### PG-7.06 · Documentación de uso bilingüe

- [x] `PG-7.06.01` `marketplace/README.md` en español e inglés con límites reales por plataforma.

### PG-7.07 · Licencias

- [x] `PG-7.07.01` `license = "Apache-2.0"` en los crates distribuibles (`pseudolearn_cli`, puente de la app).
- [x] `PG-7.07.02` `cargo deny check licenses` de CLI, motor y puente; avisos de terceros del VSIX regenerados.

### PG-7.08 · Artefactos

- [x] `PG-7.08.01` VSIX `darwin-arm64` y web, binario `pseudo` y Wasm con SHA-256 en `pg-7-artefactos.json`.
- [x] `PG-7.08.02` VSIX `win32-x64` construido en el workflow manual con su `.sha256`.

### PG-7.09 · Casos integradores de ENT-1

- [x] `PG-7.09.01` Conformidad de los casos integradores del corpus y aceptación por plataforma de PG-B.27.

### PG-7.10 · Publicación

- [x] `PG-7.10.01` Registrar que no se publica en ningún canal externo sin aprobación explícita.

### PG-7.11 · Informe final

- [x] `PG-7.11.01` Informe final de ENT-1 y propuesta de FUT-xx a evaluar, sin activarla (§11.6).

### PG-7.13 · Windows x64

- [x] `PG-7.13.01` `artifact.contract.json` con destinos `darwin-arm64` y `win32-x64`; cargador y pruebas.
- [x] `PG-7.13.02` Pruebas `cfg(windows)` de rutas del anfitrión (`tests/physical_paths.rs`).
- [x] `PG-7.13.03` `tool/verify_system_paths.py` y trabajo `extension-windows` del workflow manual.

### PG-7.14 · Erradicación

- [x] `PG-7.14.01` Corpus: `TOOL.CLI.RUN#R6`/`C18`, `TOOL.CLI.MESSAGES` sin `retiredAuthorityOption`,
  `RT.HOST.INTERFACE`, `IR.INSTRUCTIONS`.
- [x] `PG-7.14.02` Código: CLI sin opciones retiradas; anfitrión desacoplado y pruebas sin claves retiradas.
- [x] `PG-7.14.03` Verificador `eradication` con lista de datos, pruebas y fixture de violación deliberada.

### PG-7.15 · Reconciliación documental

- [x] `PG-7.15.01` Plan general (§4.11–§4.16, §6), hoja de ruta y planes de fase con notas de cierre.

### PG-7.16 · Aceptación final

- [x] `PG-7.16.01` Programa de PG-B.27 ejecutado en CLI, extensión y app; registrada la aceptación bajo delegación.

### PG-7.17 · Vínculos y fichas

- [x] `PG-7.17.01` Cero `pendiente` en `conformance*.yaml`; exenciones sin «falta implementar».
- [x] `PG-7.17.02` `dart run tool/check_syntax_coverage.dart`: toda forma pública con ficha.

### PG-7.18 · Depuración web

- [x] `PG-7.18.01` Contratos de puertos DAP y sesión TS (`application/debug_*.ts`).
- [x] `PG-7.18.02` Adaptador VS Code web, registro y manifiesto web con `debuggers`.
- [x] `PG-7.18.03` Pruebas unitarias y prueba con la VM Wasm real que compara la proyección con `pseudo dap`.

### PG-7.19 · Latencia del servicio

- [x] `PG-7.19.01` Perfilado y corrección de los costes cuadráticos del análisis semántico.
- [x] `PG-7.19.02` Umbral por carga en la campaña y campaña completa.

## 5. Capas y archivos

| Archivo | Capa | Puede importar | Dueño de la responsabilidad |
|---|---|---|---|
| `apps/pseudolearn_vscode/src/contracts/debug_session.ts` | contracts | contracts | Puertos de la sesión DAP |
| `apps/pseudolearn_vscode/src/application/debug_*.ts` | application | application, contracts | Protocolo, estado, ciclo de vida, control, bombeo, inspección, variables, puntos de parada, fuentes, referencias, efectos, salida y valores DAP |
| `apps/pseudolearn_vscode/src/adapters/browser_debug_adapter.ts`, `browser_debug_target.ts` | adapters | adapters, application, contracts | Adaptador VS Code serializado y preparación del destino web |
| `apps/pseudolearn_vscode/src/activation/browser_debug_commands.ts`, `debug_input_tracker.ts` | activation | todas | Registro del depurador web y entrada compartida |
| `packages/pseudolearn_engine/crates/pseudolearn_semantic/src/local_scopes.rs` | semantic | según `architecture.yaml` | Índice incremental de locales por ámbito |
| `packages/pseudolearn_spec/xtask/src/eradication.rs` | xtask (tooling) | biblioteca estándar | Verificador de términos erradicados |
| `packages/pseudolearn_engine/crates/pseudolearn_host/tests/physical_paths.rs` | tests espejo de `physical_paths.rs` | — | Rutas Windows del anfitrión |

Ninguna capa nueva: todos los archivos caen en capas declaradas.

## 6. Presupuestos de rendimiento y seguridad

- E-PG-02 con `PERF.PROTOCOL` (30 muestras × 10 procesos por carga y escenario) y el umbral de `DP7-03`.
- `PERF.AOT.LEVEL` y `PERF.SUITE.CORE` según `DP7-04` y `DP7-05`; el camino caliente de la VM no cambia.
- Seguridad: TLS siempre validado; autoridad plena sin concesiones; la configuración de lanzamiento DAP sigue rechazando
  campos que intenten fijar autoridad o variables de entorno.

## 7. Pruebas y experimentos

| Pieza | Feliz | Infeliz | Límite |
|---|---|---|---|
| Sesión DAP web | Escenario `dap-project` con parada, hilos, evaluación y paso atrás | Peticiones antes de `launch`, comando desconocido, punto condicional | Columnas UTF-16 y pares sustitutos, tabla de referencias llena, rangos de salida parciales |
| Contrato multidestino | `darwin-arm64` y `win32-x64` | Destino no declarado | Binario de otro destino en el VSIX |
| Rutas Windows | Unidad con `\` y `/`, `\\?\`, relativa con `\` | Unidad inexistente, archivo en vez de carpeta | UNC responde con valor, nunca aborta |
| Erradicación | Repositorio limpio | Fixture con dos términos | Lista vacía o línea inválida |
| Semántica | Suite de `pseudolearn_semantic` y conformidad | Tablas truncadas (`forget_from`) | Tablas vacías |
| Umbral por carga | Carga ampliada a 300 ms | 300,5 ms | Carga desconocida usa 100 ms |

## 8. Riesgos

| Riesgo | Señal temprana | Tratamiento |
|---|---|---|
| K-12 evidencia vieja | Resultado sin revisión ni hash | Toda medición de §11 lleva revisión y comando |
| DAP web divergente | Proyección distinta de `pseudo dap` | Comparación automática en la prueba con Wasm real |
| Disco lleno durante la campaña | <2 GiB libres | Limpieza de `target/` regenerables antes de cada bloque |
| Índices semánticos obsoletos | Diagnóstico distinto del control frío | `equivalent: true` exigido en cada muestra de E-PG-02 |

## 9. Dependencias de la persona

- Publicación externa (`PG-7.10`): no autorizada; no se publica.
- Ejecución del workflow manual de Windows: cubierta por la autorización general del 2026-11-12 de completar la fase.
- Aceptación física (iPhone real, Windows con interfaz, Firefox): complementaria por la decisión del 2026-10-22; se
  declara no verificada.

## 10. Orden de ejecución y puntos de control

PG-7.13 → .14 → .17 → .18 → .19 → .01/.02/.05/.09 (bloque pesado único) → .03/.04/.06/.07/.08/.10/.11 → .15 → .16 →
cierre común. Punto de control antes del bloque pesado: verificadores ligeros de cada miembro tocado en verde.

## 11. Resumen de ejecución

Equipo: macOS 27.2 (Darwin 27.2.0), Apple M2 de 8 núcleos, Rust 1.99.0, Node 22.23.3, pnpm 12.8.1, VS Code Stable
1.144.0. Revisión base `bdbf4618`; commits de la fase desde `9264df25`.

### 11.1 Evidencia por punto

| Tarea | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| `PG-7.01.01`–`.03` | Cumplido | `see conform` sobre el corpus final: `engine` 34 propiedades y 3 412 observaciones; `service` 8 y 229; `cli` 4 y 193; `aot` 17 y 2 893; `app` 2 y 275; **0 divergencias** en todos. `see differential`: 2 070 observaciones, 0 diferencias, 0 exentas | La CLI y `aot` registraban propiedades de reglas exentas como «pendientes»; el selector ya no informa un resultado no disponible de una regla exenta (`28930221`, `ebdae2f6`); repetidas con el selector corregido, la CLI queda con 4 propiedades cumplidas y `aot` con 17, ambas con 0 pendientes y sin divergencias en sus casos |
| `PG-7.02.01` | Cumplido | E-PG-02 completo (§11.5) | Umbral de `DP7-03` |
| `PG-7.02.02` | Cumplido | `DP7-04`, `DP7-05`, `DP7-06`, `DP7-10`, `DP7-11`; `PERF.AOT.LEVEL` y `PERF.ARTIFACT.SIZE` editados en su versión y reanclados (`d2287b02`) | Decisiones bajo delegación expresa |
| `PG-7.03.01` | Cumplido | [Informe final](informe-final-ent-1.md), §1 | C-07/C-08 con el criterio de autoridad plena |
| `PG-7.04.01` | Cumplido | [Informe final](informe-final-ent-1.md), §2 | Sin huecos |
| `PG-7.05.01`–`.02` | Cumplido | [Informe final](informe-final-ent-1.md), §3; reglas incluidas en la conformidad de `engine` y `aot` sin divergencias | Riesgos residuales aceptados bajo delegación |
| `PG-7.06.01` | Cumplido | `marketplace/README.md` bilingüe (`49049284`); ejemplos ejecutados con `pseudo run` en ambos perfiles | — |
| `PG-7.07.01`–`.02` | Cumplido | `license = "Apache-2.0"` (`4bf96c0a`); `cargo deny check` en verde en motor, CLI y puente de la app (licencias, avisos, fuentes); avisos de terceros regenerados al empaquetar | Licencia confirmada por la persona |
| `PG-7.08.01`–`.02` | Cumplido | [`pg-7-artefactos.json`](pg-7-artefactos.json) | VSIX `win32-x64` del workflow manual |
| `PG-7.09.01` | Cumplido | `LIB.SCENARIO.BILINGUAL`, `LIB.SCENARIO.FILE-JSON` y `LIB.SCENARIO.HTTP-TASKS` sin divergencias en `engine`/`aot`; programa de PG-B.27 en CLI VM, CLI nativo, VS Code de escritorio y app | — |
| `PG-7.10.01` | Cumplido | No se publicó en Marketplace, Open VSX, tiendas ni registros | Requiere aprobación explícita de la persona |
| `PG-7.11.01` | Cumplido | [Informe final](informe-final-ent-1.md), §4: FUT-04 acotada, sin activar | — |
| `PG-7.13.01`–`.03` | Cumplido | Contrato multidestino y pruebas (`efc257e1`); pruebas `cfg(windows)` (`7d97fb44`); workflow manual (`c47b2732`), ejecución en §11.6 | — |
| `PG-7.14.01`–`.03` | Cumplido | `c018c5b6`, `9d59b0d0`, `0179fdaf`; el verificador encuentra 0 coincidencias en el monorepo y su fixture produce 2 | — |
| `PG-7.15.01` | Cumplido | Plan general (§4.3, §4.12–§4.15, §6), hoja de ruta (decisiones del 2026-11-02 y 2026-11-12), README raíz (`d5ad763f`) | Cierres comunes heredados de PG-1, PG-L, PG-S y PG-N reconciliados por delegación |
| `PG-7.16.01` | Cumplido por delegación expresa | `200 / Rick Sanchez / Alive` en CLI VM (es/en), CLI nativo, VS Code de escritorio (host real, 30/30) y app macOS (§11.6) | La persona no ejecutó la aceptación en persona; su mensaje del 2026-11-12 la delega |
| `PG-7.17.01`–`.02` | Cumplido | 0 `pendiente` en `conformance*.yaml`; `check_syntax_coverage.dart`: 81/81 formas públicas con ficha | — |
| `PG-7.18.01`–`.03` | Cumplido | `cfb0933c`; 241 pruebas de la extensión; proyección DAP web idéntica a `pseudo dap`; VS Code para la Web en Chromium con 6 pasos de depuración en verde | WebKit y Firefox en verde tras la descarga autorizada el 2026-11-12 (ver §11.4) |
| `PG-7.19.01`–`.02` | Cumplido | `9264df25`, `6161cf72`; §11.5 | — |

### 11.2 Correcciones de problemas heredados

| Problema | Corrección |
|---|---|
| Análisis semántico cuadrático (E-PG-02 fuera de umbral desde PG-6A) | Índices de asignaciones, locales por ámbito, componentes de registro, exportados y módulos (`9264df25`) |
| Wasm por encima de 900 KiB sin que nadie lo midiera desde PG-6B | `DP7-10` |
| Paquete web rechazado por `check-web` desde que se añadió el tema de íconos | `aa3cfcf0` |
| Propiedades de reglas exentas contadas como pendientes | `28930221`, `ebdae2f6` |
| Formato de `pseudolearn_rust_checks` (anotado en PG-N) | `6c5671fd` |
| PS-E04 (igualdad Unicode nativo/Wasm) sin ejecutar desde PG-S | 32 cadenas × `Mayusculas`/`Minusculas`: VM, `aot` y Wasm idénticos, SHA-256 `49d24f74be4761cf91f93df325d625924c75bc3947af5acbae180519e9198a96` |
| Evidencia de propiedades obsoleta que bloqueaba `see conform` (`SEE-STALE` heredado de PG-A) | Las propiedades de cada sujeto se ejecutan antes que sus casos |
| Resumen de PG-7 del plan general con el contenido de PG-L | Reescrito |

### 11.3 Verificadores ejecutados

- Motor: `cargo xtask verify` (formato, Clippy estricto, 473 binarios de prueba en verde); tras corregir dos
  violaciones de `rust-checks` propias (`SIZE-FUNCTION`, `QUALITY-SEMANTIC-NAMES`), `rust-checks all`, `toolchain`,
  `cargo deny check`, Clippy y las 275 pruebas de `pseudolearn_semantic`.
- CLI: `cargo xtask verify` en verde (34 binarios de prueba). `pseudolearn_rust_checks`: `cargo xtask verify` en verde.
- SEE: `cargo xtask verify` completo en verde (formato, Clippy, 84 binarios de prueba, `deny`, `rust-checks`,
  dependencias retiradas, referencias transitorias, erradicación, `validate` 200, `export`, `agent-sheet` y conformidad
  de `engine`); `lock --check`.
- Extensión: `tsc`, arquitectura, comentarios, tamaños, paquete, 241 pruebas vitest, `check-web`, host real de
  escritorio 28/28 y VS Code para la Web en Chromium.
- App: `check_syntax_coverage.dart` y conformidad del sujeto `app`.

### 11.4 Suites omitidas y motivo

- Suite completa de Flutter: PG-7 no cambia código Dart; la conformidad del sujeto `app` y la cobertura sintáctica
  cubren el puente con el motor modificado.
- WebKit y Firefox en VS Code para la Web: descargados con permiso de la persona el 2026-11-12 (Playwright 1.64.1:
  WebKit 27.2, Firefox 157.0). WebKit pasa los 70 pasos, incluidos los 6 de depuración, igual que Chromium
  (`test-results/web/2026-11-12T12-31-58-714Z`). Firefox terminaba con «Could not find profile folder» incluso
  lanzado a mano: macOS protege `~/Library/Application Support/Firefox`, que pertenece al Firefox instalado, y la
  compilación de Playwright usa el mismo nombre de carpeta. Arreglo local del equipo, fuera del repositorio:
  `Nightly.app/Contents/Resources/browser/application.ini` con `Profile=PlaywrightFirefox` y la variable
  `XUL_APP_FILE` apuntando a él al correr `test:web`. Con eso Firefox pasa los 70 pasos, depuración incluida
  (`test-results/web/2026-11-12T12-45-44-039Z`).
- iOS simulador y dispositivos físicos: complementarios por la decisión del 2026-10-22.

### 11.5 E-PG-02

Campaña `service workspace` con el binario release final de `pseudo` (Apple M2, semilla 42, 30 muestras × 10 procesos
× 4 cargas × 7 escenarios, máquina sin otra carga). Crudos en `packages/pseudolearn_spec/results/pg-7-e-pg-02/`
(ignorados por Git); `summary.json` SHA-256 `e008e8fb738b2767fd74524669e18a712c830a11ea6a3b576d51f3d3deba9de1`.
Equivalencia exacta con el control frío en todas las muestras; `all_within_threshold: true`.

| Carga | Edición de cuerpo | Edición de firma | Cambio de manifiesto | Archivo cerrado | Rename | Umbral de diagnóstico |
|---|---|---|---|---|---|---|
| `files-10` | 12,3 | 12,4 | 28,8 | 28,8 | 3,5 | 100 |
| `files-100` | 12,5 | 12,5 | 18,6 | 18,6 | 1,1 | 100 |
| `files-1000` | 24,1 | 23,9 | 31,1 | 31,2 | 7,6 | 100 |
| `files-1000-extended` | 129,2 | 129,0 | 193,0 | 196,2 | 11,6 | 300 |

Valores p95 en ms. Antes de las correcciones, en esta misma revisión base: `files-10` 509–604 ms y
`files-1000-extended` 1 350 ms de mediana en edición de cuerpo. `PERF.PG.SERVICE` queda aceptada con estos umbrales
(`DP7-03`, `DP7-11`).

### 11.6 Windows y aceptación

- Workflow manual `Verify Monorepo`, runs `43181145660` y `43182380141` (`native_targets_only`): destinos nativos de
  Linux x64, macOS arm64 y Windows x64 en verde; `physical_paths` 4/4 en `windows-latest`; la VM recorre las seis
  formas de ruta en Windows; `extension-windows` empaqueta el VSIX `win32-x64` (SHA-256 `f51a24a1…`), pasa 25 pruebas del
  contrato y ejecuta el `pseudo.exe` desempaquetado del VSIX. El primer run reveló que `upload-artifact` omitía la
  carpeta oculta del VSIX (`2ef1b08a`). En el segundo, el trabajo macOS Intel perdió el runner por un fallo de
  infraestructura de GitHub; relanzado, pasó (8 min 16 s) y el run terminó en `success`.
- Programa de PG-B.27 (`200 / Rick Sanchez / Alive`): CLI VM en `es` y `en`, CLI `--nativo`, binario exacto del VSIX,
  VS Code de escritorio con el VSIX instalado desde cero (host real 30/30) y app macOS
  (`integration_test/real_api_acceptance_test.dart`, `ACCEPTANCE OUTPUT [200, Rick Sanchez, Alive]`).
- No ejecutado en esta fase: VS Code con interfaz en Windows, app Windows e iOS (simulador verificado en PG-B.27).

Revisión Git de cierre: commits de `9264df25` al commit documental de cierre, publicados por push ordinario en
`feature/agregar-ruta-de-especificacion` · Verificadores ejecutados: §11.3 · Pendientes justificados: iOS físico, VS Code con interfaz y app en Windows · Puntos de §4 cumplidos: PG-7.01–.11 y .13–.19 (`.12`
retirado) y C01–C13.
