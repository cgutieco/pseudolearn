# Plan de ejecución de R8 · Puentes con la app y la web

> **Estado:** B0–B3 ejecutados; B4 y B5 implementados y verificados localmente, con seguimiento de resaltado y unidad de foco; B6 implementado con validaciones de plataforma pendientes; B7 implementado y verificado; B8 implementado parcialmente, con una divergencia de contrato y E-NR2 pendiente; B9 implementado localmente, con publicación y validación remota de builds pendientes. Fecha: 2026-10-19.
> Rama única: `feature/agregar-ruta-de-especificacion` (`GIT-SINGLE-BRANCH`).
> Las autorizaciones cubrieron B3, B4, una iteración de B5, B6, una iteración de B7, una iteración de B8 y una iteración de B9. No se autorizó publicar aplicaciones.
>
> Detalla [R8 de 07-fases.md](07-fases.md#r8--puente-con-la-app-y-la-web). El corpus gobierna
> los observables; los README de los miembros gobiernan su arquitectura y operación. Las decisiones
> propuestas aquí deben trasladarse a esas fuentes al implementarlas, sin referencias a este documento.

## 1. Resultado esperado y límites

R8 conecta la aplicación Flutter con la VM y el servicio de lenguaje Rust mediante una frontera pública,
distribuye un módulo Wasm consumible en navegador y adapta los builds de publicación a Rust. El cierre
exige ejecutar la aplicación real, observar arreglos y objetos, completar `Fib(20)` y los ejercicios,
y medir el coste completo de la observación a través del puente.

Depende de R7 y, transitivamente, R5. No depende de R6: los puentes no activan la feature `native` de
`pseudolearn_api` y no incorporan Cranelift. La existencia del backend AOT no autoriza a introducirlo
en móvil, web o en el flujo didáctico de escritorio.

Queda fuera de alcance: construcciones nuevas del lenguaje, retiro del núcleo Dart y estabilización
global del corpus (R9), un playground en `apps/fe-pseudolearn`, nuevos canales comerciales y una
reescritura visual de la app. Consultar un estado histórico ya soportado por la API no exige añadir
controles de rebobinado a la interfaz: esa ampliación requiere un alcance explícito.

Los bloques de este documento son unidades de trabajo dentro de R8; sus puertas técnicas no son
autorizaciones para otras fases. R9 requiere un mensaje nuevo (`PHASE-STOP`).

## 2. Punto de partida inspeccionado

La inspección es documental y de código; no se han repetido las suites ni mediciones de fases anteriores
para redactar este plan. Las cifras publicadas en sus informes son antecedentes, no evidencia nueva.

| Pieza | Estado observado | Consecuencia para R8 |
|---|---|---|
| `packages/pseudolearn_engine` | Workspace con API, VM, timeline y servicio de lenguaje | Reutilizar estas implementaciones; ningún evaluador ni completador paralelo en Dart |
| `pseudolearn_api::ApiSession` | Recursos con identificador, negociación, avance, entrada, cancelación, consultas y liberación | Probar el ciclo completo a través del transporte, no solo funciones Rust directas |
| `pseudolearn_api::service` | Reexporta el servicio; `native` es optativa y `default = []` | Comprobar el grafo de dependencias de cada build de puente |
| `packages/pseudolearn_spec/specifications/` | Existen `API.*`, `TOOL.*` y presupuestos `PERF.*`; los cuatro `APP.*` del catálogo no existen todavía | Escribir contratos y casos antes de adaptar la app |
| `apps/pseudolearn_app/lib/domain/ports/` | Puertos segregados: `ProgramAnalyzer`, `ProgramExecution`, `ProgramExporter`, entre otros | `RustCoreEngine` designa la familia de adaptadores; no impone una interfaz monolítica nueva |
| `lib/engine/execution/core_program_execution.dart` | `CoreProgramExecution` consume el intérprete Dart mediante métodos síncronos | Resolver explícitamente la compatibilidad con el puente antes de modificar los puertos |
| `lib/engine/` | Análisis, edición, completado, ejecución, conocimiento, exportación y diagramas importan tipos del núcleo Dart | Migrar todos los consumidores del lenguaje, no únicamente `step()` |
| App por plataforma | README: iOS 16+, macOS 13+ arm64/x86_64 y Windows 10/11 x64; carpetas `ios/`, `macos/`, `windows/` | Ésta es la matriz mínima de ejecución de la app distribuida |
| Linux y web Flutter | Objetivos secundarios; README declara ausencia de andamiaje | El módulo Wasm es obligatorio; una app Flutter web completa requiere resolver su alcance |
| Android | El plan arquitectónico enumera ABI Android; el README de la app no lo enumera como plataforma actual | Reportar la diferencia y resolverla antes de comprometer distribución Android |
| Publicación | Workflows manuales de iOS, macOS y dos canales Windows; existe además uno web | Revisar el consumidor de cada workflow; la existencia del workflow web no demuestra una app Flutter web |
| R7 | Su informe reconoce reanálisis completo con huellas y una reformulación de `INCREMENTAL#R2` pendiente de ratificación | No prometer reutilización semántica por unidad ni dar esa ratificación por hecha |

La ubicación del nuevo plan es la documentación transitoria de raíz. No pertenece a una capa ejecutable,
no añade imports y tiene una responsabilidad: ordenar la ejecución verificable de R8. El índice conserva
la navegación y `07-fases.md` conserva el seguimiento de la fase.

## 3. Decisiones y conflictos que deben resolverse antes del código dependiente

`CONFLICT-REPORT` exige reportar las diferencias entre fuentes y esperar resolución cuando cambian el
trabajo. La planificación puede completarse dejando estas puertas explícitas; no las resuelve en silencio.

| ID | Decisión o tensión | Propuesta para revisión | Bloque dependiente |
|---|---|---|---|
| D-R8-01 | D-P07: emisores Python/Rust y diagramas usan AST Dart | **Resuelta:** conservar emisores, diagramas y comprobaciones estructurales mediante `API.PROGRAM.VIEW`, una vista pública inmutable que todos comparten | B1, B3, B5 |
| D-R8-02 | Puertos síncronos y micro-lotes en hilo principal frente al transporte generado | Validar una superficie síncrona acotada para consultas y avance con presupuesto. Si la herramienta obliga a asincronía o hilos, presentar el cambio de contrato y README antes de alterar puertos o composición | B2–B4 |
| D-R8-03 | Android aparece en el plan de arquitectura, pero no en plataformas actuales de la app; `PERF.ARTIFACT.SIZE#M1` también lo nombra | **Resuelta:** Android sigue en la hoja de ruta; R8 fija el límite futuro de su biblioteca nativa, pero no exige compilarla ni distribuir la app Flutter en Android | B1, B6, B8 |
| D-R8-04 | Wasm obligatorio frente a ausencia de `web/` Flutter | **Resuelta:** R8 entrega `pseudolearn_wasm` y un consumidor mínimo de navegador; no incorpora una app Flutter web | B1, B7 |
| D-R8-05 | Código generado puede contener comentarios, atributos o `unsafe` incompatibles con las reglas actuales | Inspeccionar una generación de prueba fuera del producto; someter cualquier excepción mínima al contrato de reglas y documentarla. No borrar comentarios de código generado ni ampliar exenciones de forma global | B2, B3, B7 |
| D-R8-06 | Versiones congeladas y prohibición de bloque `cambio` en 07 §3 frente a `SPEC-CHANGE-CLASSIFIED` | **Resuelta:** conservar versiones congeladas y registrar clasificación e impacto en evidencia separada, sin bloques `cambio` | B1 |
| D-R8-07 | Reformulación de `TOOL.SERVICE.INCREMENTAL#R2` durante R7 pendiente de ratificación | **Resuelta:** consumir el contrato incremental vigente sin exigir reutilización semántica ni crear deuda para ratificarla después | B1, B5 |
| D-R8-08 | Dispositivo más modesto requerido por la aceptación, sin modelo fijado aquí | Fijar dispositivo físico, SO, modo release y acceso a medición antes de cerrar el protocolo. El simulador y Apple M2 no sustituyen esa evidencia tras incorporar el puente | B0, B8 |

Las decisiones de producto corresponden a la persona responsable. Las elecciones de versión de
`flutter_rust_bridge`, generador, cargokit y `wasm-bindgen` se verifican en documentación oficial al
ejecutar B2, se fijan de manera compatible y se registran con sus alternativas en los README. Este plan
no prescribe versiones no contrastadas ni supone que una receta de integración existente siga vigente.

## 4. Contratos que deben existir antes de implementar

### 4.1. Cuatro contratos `APP.*` del catálogo

Los cuatro contratos de esta sección quedaron definidos en B1 como especificaciones experimentales.
Cada regla tiene casos ejecutables y cada observable queda ligado al comportamiento de la app, del
servicio Rust o de la API pública, según su responsable.

Los cuatro ritmos actuales son `StepPace.nextStatement`, `overBlock`, `outOfBlock` y `toEnd`, definidos
en `lib/application/execution/step_pace.dart`. No son cuatro velocidades temporales: determinan dónde
se detiene el avance. B1 conserva esa distinción al relacionarlos con los eventos de la VM.

| Contrato nuevo | Reglas | Casos mínimos y oráculo |
|---|---|---|
| `APP.ENGINE.BOUNDARY` | R1: solo `engine/` consume la API y transportes; R2: ambos adaptadores satisfacen los puertos sin lógica de lenguaje en la app; R3: recursos y fallos tienen ciclo de vida definido | Rechazo deliberado de import Rust/generado en dominio o aplicación; liberación, cierre repetido, identificador inválido, versión incompatible y fallo interno. Verificador estructural con caso negativo y pruebas de frontera |
| `APP.EXEC.PACE` | R1: fijar los cuatro ritmos existentes a partir de eventos observables; R2: mismo resultado y orden de efectos con cualquier ritmo; R3: micro-lotes cooperativos y pausa/entrada/cancelación sin pérdida; R4: presupuesto de ejecución distinto del ritmo visual | `Fib(20)`, bucles, subprocesos, recursión, entrada válida/inválida/agotada, error y bucle no terminante cancelado. Esperados derivados de `ENG.*` y `API.EXECUTE`; no copiar contadores accidentales del intérprete Dart |
| `APP.EXEC.SNAPSHOT-VIEW` | R1: primitivas y arreglos con forma e índices; R2: objetos con identidad, campos, herencia, alias y ciclos; R3: estado coherente con el evento seleccionado y límites de retención; R4: paginación y truncamiento explícitos | Arreglo vacío y multidimensional, arreglo de objetos, dos alias, autorreferencia y ciclo mutuo, ausencia, campos heredados, salida de ámbito, recursión y consulta fuera del horizonte. Validar valores y relaciones, no solo una captura visual |
| `APP.EDITOR.COMPLETION` | R1: consumir `TOOL.SERVICE.COMPLETION`; R2: convertir posiciones correctamente; R3: no aplicar una respuesta de revisión antigua; R4: conservar perfil e idioma de interfaz independientes | Documentos incompletos, miembros, ámbitos y sombreado, cierres, plantillas bilingües válidas, cursor con UTF-8/UTF-16 y ediciones consecutivas. Comparar proyecciones con consultas reales del servicio |

Los archivos viven en `packages/pseudolearn_spec/specifications/app/`, con sujeto `app` y estado
`experimental`. El manifiesto conserva las reglas en `pendiente` hasta que B8 tenga un adaptador
ejecutable; no existe aún un lanzador de SEE para la app.

### 4.2. Extensiones de API y rendimiento

1. La auditoría B1 revisó `API.MODEL`, `API.ANALYZE`, `API.EXECUTE`, `API.STATE.QUERY`, `API.ERRORS`,
   `API.VERSIONING` y `API.WIRE-FORMAT`, distinguiendo operaciones y capacidades existentes de las nuevas.
2. `API.PROGRAM.VIEW` conserva emisores y diagramas con una proyección de unidades, sentencias,
   expresiones, relaciones de clases, identificadores y tramos; no expone índices internos del CST,
   HIR o bytecode ni crea un segundo parser en Dart.
3. La vista liga nodos y eventos por revisión del documento. Una edición invalida ejecuciones o escenas
   anteriores; los consumidores no pueden reutilizar índices por coincidencia.
4. `API.WIRE-FORMAT` fija enteros de 64 bits sin pérdida en Dart/JavaScript, identificadores opacos,
   Unicode, propiedad y vigencia de buffers, cursores de paginación y liberación de recursos.
5. `PERF.VM.STEP-LATENCY` mide el coste completo del puente mediante el sujeto `app`. `PERF.ARTIFACT.SIZE`
   mide iOS arm64 con el sujeto `app` y Wasm con `engine`; Android queda como ABI futura y no bloquea R8.
6. B1 generó lock y exportación con sus herramientas, y registró clasificación e impacto en evidencia
   separada. No se editaron artefactos generados a mano (`GEN-NO-HAND-COPY`) ni se añadieron bloques `cambio`.

B1 fija ≤1 ms p95 para avanzar y consultar estado a través de la app en un dispositivo modesto,
≤0,1 ms en Apple M2 para el motor directo, y ≤50 ms p95 para posicionarse y consultar estado retenido
en M2. El tamaño máximo es ≤3 MiB para la biblioteca iOS arm64 y ≤600 KiB para Wasm comprimido con
Brotli; el límite de 3 MiB se aplicará a Android cuando esa ABI futura se implemente. No trasladar
automáticamente la sustitución M2 a una app que ya tiene puente ni elevar umbrales después de medir.

## 5. Arquitectura de integración propuesta

### 5.1. Propiedad y dirección de dependencias

| Ubicación | Responsabilidad y dependencias permitidas |
|---|---|
| `packages/pseudolearn_engine/crates/pseudolearn_api/` | Fachada y proyecciones públicas sobre capas del motor permitidas por su `architecture.yaml`; sin UI ni imports de la app |
| `apps/pseudolearn_app/native/` | Crate independiente `pseudolearn_bridge`, `staticlib`/`cdylib`, dependiente de `pseudolearn_api` por ruta; traducción de transporte y propiedad de sesiones, sin semántica duplicada |
| `apps/pseudolearn_app/lib/engine/bridge/` | Enlaces Dart generados y comprobados por regeneración; no editados a mano |
| `apps/pseudolearn_app/lib/engine/` | Adaptadores Rust de los puertos y conversión a modelos de dominio; sin tipos generados en sus contratos de salida |
| `domain/model`, `domain/ports` | Datos e interfaces independientes de Flutter, Dart core, Rust y plataforma |
| `application/` | Orquestación de ritmos y estado a través de puertos; no importa `engine/` ni el puente |
| `composition/` | Ensamblado estático del conjunto Dart o Rust, sin condicionales de selección distribuidos |
| `packages/pseudolearn_engine/crates/pseudolearn_wasm/` | Capa exterior que consume solo la API interna pública; expone transporte Wasm y declara dependencias externas autorizadas |

Antes de crear cada crate: README autosuficiente, reglas declarativas, toolchain exacto común y
verificadores del miembro. El crate anidado de la app tiene sus propias reglas Rust; no se incorpora
a un workspace Cargo raíz. Los verificadores Dart deben poder distinguir fuentes generadas mediante
rutas exactas aprobadas y mantener todos sus rechazos sobre código escrito a mano.

### 5.2. Flujo de ejecución y observación

1. El adaptador abre documento/análisis y negocia capacidades. La app conserva revisión e identidad
   de recursos; los errores se proyectan a resultados de dominio.
2. El motor inicia una sesión con perfil, rigor, semilla, límites y política de retención explícitos.
3. El planificador solicita avance acotado por trabajo y tiempo. Rust devuelve lotes del formato
   público; la app no recibe un objeto FFI por cada evento ni copia todo el montón en cada paso.
4. La proyección aplica deltas ordenados y consulta solo la parte visible del estado por identificador
   y página. El estado completo continúa siendo propiedad de Rust.
5. Entrada, pausa y cancelación actúan sobre esa misma sesión. El cambio de ritmo no reinicia ni
   vuelve a ejecutar efectos. Los puntos de consulta no alteran la continuación presente.
6. Al editar, cerrar o reiniciar, el dueño libera recursos en orden definido. Respuestas antiguas y
   buffers invalidados se rechazan; no pueden actualizar otro documento ni una ejecución nueva.

El transporte no introduce semántica distinta para nativo y Wasm. Su política de copias debe ser
explícita: una referencia lógica a un recurso no equivale a compartir un puntero Rust con Dart o JS.
En Wasm, un crecimiento de memoria puede invalidar vistas; conservarlas requiere una garantía de vida
o una copia controlada. Medir esa copia como parte del puente.

### 5.3. Convivencia de motores y migración completa

Conservar el conjunto Dart para contraste y reversión de composición hasta R9. El código actual usa
nombres como `CoreProgramExecution`; no asumir que existe una clase `DartCoreEngine` que deba renombrarse
en bloque. La composición Rust debe cubrir análisis, ejecución, completado/edición, vocabulario,
conocimiento, comprobación de ejercicios, diagramas y exportación conforme a D-P07.

Inventariar imports `package:pseudolearn_core/` por responsabilidad. Al terminar, los del adaptador
Dart pueden permanecer; ninguna ruta activa de la composición Rust debe invocarlos como respaldo.
Una prueba que solo sustituye la ejecución mientras analiza o verifica ejercicios con Dart no acredita
la integración Rust. Las discrepancias del sujeto congelado se comparan con el corpus, no se corrigen
modificando su implementación.

## 6. Secuencia de ejecución y puertas

### B0 · Línea base, inventario y disponibilidad de plataformas

- [x] Confirmar rama y árbol de trabajo; conservar cambios ajenos. Registrar revisión y herramientas.
- [x] Leer README y reglas de cada miembro afectado, incluidos verificadores y arnés si se modifican.
- [x] Repetir verificaciones base de motor, SEE y app; separar fallos heredados de los nuevos.
- [x] Inventariar todos los puertos y consumidores de Dart, recursos de ejercicios y flujos de publicación.
- [x] Preparar matriz de hardware/runners: iOS físico y simulador, macOS arm64/x86_64, Windows x64 y navegador.
- [x] Presentar D-R8-01 a D-R8-08 con alternativas, impacto y evidencia disponible.

**Puerta:** línea base reproducible y decisiones de alcance resueltas antes del bloque dependiente.
Las respuestas de 2026-10-19 resolvieron D-R8-01, D-R8-03, D-R8-04, D-R8-06 y D-R8-07, suficientes
para autorizar B1. D-R8-02 y D-R8-05 se resuelven en B2; D-R8-08 antes de la medición de B8. La falta
de dispositivo o runner no se convierte en test aprobado ni en cierre con exclusión tácita.

### B1 · Especificaciones y casos antes del producto

- [x] Redactar los cuatro `APP.*`, sus dependencias, casos felices, infelices y límites.
- [x] Precisar los cuatro ritmos a partir de la app vigente y la unidad observable de Rust.
- [x] Incorporar la vista pública decidida en D-P07 y las garantías de transporte faltantes en `API.*`.
- [x] Definir sujetos, métricas y ámbito de Android/web; fijar protocolo y unidades de tamaños.
- [x] Revisar esperados independientemente del adaptador; registrar clasificación e impacto.
- [x] Actualizar lock/exportación con los generadores y añadir casos negativos al soporte nuevo de SEE.

**Puerta:** `see validate`, `see lock --check`, `see export --check` verdes; ninguna regla huérfana.
Una implementación pendiente permanece pendiente, con casos que todavía no pasan; no se falsea `cumple`.

#### Registro de B1 · 2026-10-19

**Qué se construyó.** Se añadieron `API.PROGRAM.VIEW` y los cuatro contratos `APP.*`; se precisaron las
consultas paginadas, capacidades, formato de transporte, trazas y métricas. SEE ahora valida casos de
app, paginación y vistas del programa, con comprobaciones negativas. Se actualizaron los README de los
miembros y se registraron las reglas de app en `conformance.yaml`.

**Resultado de los tests.** `cargo test --workspace --quiet`: 166 pasaron, 0 fallaron y 0 se
omitieron, en 76 binarios de tests. `cargo xtask verify` volvió a ejecutar el workspace y terminó sin
fallos.

**Resultado de los verificadores.** `cargo xtask verify` aprobó `cargo-deny`, `rust-checks all`,
`rust-checks toolchain`, `see validate` (161 especificaciones), `see lock --check` y `see export --check`.
La conformidad de `reference` ejecutó 1181 observaciones y conservó 134 divergencias; el comando cerró
con código 0. `git diff --check` no reportó errores.

**Decisiones que conviene conocer.** Se conservarán emisores, diagramas y aserciones mediante una vista
inmutable. Android permanece en la hoja de ruta y no requiere distribuir Flutter para Android; la web
usará Wasm con un consumidor mínimo. Las versiones existentes permanecen congeladas y el impacto se
documenta en evidencia separada, sin bloques `cambio`. Se consume el contrato incremental vigente sin
exigir reutilización semántica. Los cinco contratos nuevos son experimentales; las reglas de app y las
capacidades de motor no implementadas continúan `pendiente`. La app aún no dispone de un lanzador de SEE;
su conformidad y ejecución real corresponden a bloques posteriores. D-R8-02/D-R8-05 esperan B2 y
D-R8-08 espera a la medición de B8.

La evidencia de clasificación, impacto y revisión independiente de esperados vive en
`packages/pseudolearn_spec/results/r8-b1-contract-changes.json`; el resumen producido por SEE está en
`packages/pseudolearn_spec/results/r8-b1-contract-diff.json`.

### B2 · Prueba de viabilidad del transporte

- [x] Contrastar documentación oficial y fijar versiones compatibles de herramientas y librerías.
- [x] Generar una prueba desechable en un directorio temporal para inspeccionar imports, comentarios,
      atributos, `unsafe`, hilos y comportamiento síncrono; resolver D-R8-02 y D-R8-05.
- [x] Probar negociación, un documento, un avance y una consulta con enteros extremos y Unicode.
- [x] Medir una primera ida y vuelta y un lote real; comprobar que no incorpora Cranelift.
- [x] Documentar en README la elección de transporte, vida de buffers y alternativas descartadas.

**Puerta:** camino Rust → Dart → dominio verificable en macOS y viabilidad de los otros objetivos.
Un conflicto de política o un coste incompatible se reporta antes de extender el producto.

#### Registro de B2 · 2026-10-19

La prueba desechable se generó con `flutter_rust_bridge_codegen 2.13.0`, `flutter_rust_bridge 2.13.0` y
`flutter_rust_bridge_hooks 2.13.0`, sobre Flutter `3.47.5`, Dart `3.13.4` y Rust `1.99.0`. Se seleccionó el
backend Native Assets. Para Wasm se fijan `wasm-bindgen` y `wasm-bindgen-cli` en `0.2.129`; no se usa Cargokit.

FRB requiere `Sync` para una sesión opaca. `ApiSession` no lo implementa porque contiene estado `Cell` del motor,
así que la prueba la mantuvo en un registro `thread_local` y expuso handles `u64` con funciones `#[frb(sync)]`.
La negociación, la creación de documento, análisis e inicio, el avance en lotes de 64 eventos y la consulta de
estado cruzaron Dart, FFI y `pseudolearn_api`. Se verificaron `i64::MIN`, `i64::MAX`, `u64::MAX`, edición aceptada
y rechazada, sesión inválida, doble cierre y salida Unicode (`ñ`, `🌍`). Un programa de 12 000 iteraciones completó
563 lotes y sus consultas. La primera llamada FFI midió 6 253 µs; los lotes midieron p50 80 µs y p95 95 µs en
macOS arm64. La biblioteca se compiló en release con `default-features = false`; `cargo tree` no mostró Cranelift.

El código generado contiene comentarios, `#![allow]`, bloques `unsafe` en las funciones de decodificación y
`unwrap` del codec. D-R8-05 queda resuelta con exención exclusiva para `native/src/frb_generated.rs` y
`lib/engine/bridge/**`; el código escrito a mano no hereda ninguna exención. D-R8-02 queda resuelta con llamadas
síncronas por micro-lote y una sesión confinada al hilo invocador. El codec transfiere un bloque serializado por
llamada; los valores se decodifican a datos dueños y ningún puntero permanece entre llamadas.

Flutter generó correctamente el hook Native Assets para macOS. El intento de `flutter build macos --debug` quedó
en la preparación del SDK macOS sin producir artefacto y se interrumpió; por eso este registro acredita el camino
Dart–FFI–API por compilación nativa directa, no un build completo de la app Flutter. El soporte del hook para los
demás destinos se documenta, pero iOS y Windows no se compilaron en esta prueba. La compilación de la app con el
hook y su matriz de plataformas siguen dentro de B3 y B6.

### B3 · Puente nativo y generación reproducible

- [x] Crear `native/` con README, reglas, toolchain, manifiesto, auditoría y pruebas propias.
- [x] Exponer sesiones, recursos y operaciones de la API; transportar errores tipados y capacidades reales.
- [x] Generar enlaces en `lib/engine/bridge/`; versionar lo consumido por el build según la política del repo.
- [x] Ejecutar la orden documentada de regeneración y comprobación de árbol limpio desde un checkout limpio.
- [x] Verificar liberación, identificadores inválidos, cancelación repetida, fallo interno y límites.
- [x] Cubrir decodificación inválida, lote truncado, versión desconocida y propiedad de buffers.

**Puerta:** verificaciones Rust y Dart pertinentes verdes; el verificador detecta un enlace generado
deliberadamente desactualizado y rechaza un import del puente desde una capa prohibida.

### B4 · Adaptadores de ejecución y proyección de estado

- [x] Implementar adaptadores segregados de análisis y `ProgramExecution` sobre la sesión Rust.
- [x] Convertir tramos y diagnósticos preservando código, severidad, argumentos y perfil.
- [x] Conectar los cuatro ritmos a eventos; desacoplar espera visual y presupuesto de trabajo.
- [x] Consumir lotes y deltas; consultar arreglos y objetos de forma paginada sin snapshots Dart paralelos. (el estado visible se consulta por evento; no se usan deltas ordenados porque la medición no lo exige)
- [x] Proyectar forma de arreglos, alias, ciclos y referencias ausentes con identificadores coherentes.
- [x] Integrar entrada, parada, fallo, finalización y límites sin bloquear la respuesta del planificador.

**Puerta:** pruebas del adaptador y widgets con el puente real; `Fib(20)` termina en cada ritmo,
arreglos y grafo de objetos son inspeccionables y un bucle no terminante puede cancelarse.

#### Registro de la iteración B3 · 2026-10-19

B3 añade `pseudolearn_bridge` con `flutter_rust_bridge` 2.13.0 y Native Assets. El registro de sesiones
confina `ApiSession` al hilo invocador; cada llamada transporta JSON por valor y no conserva buffers
entre llamadas. La generación Rust–Dart queda reproducible mediante `tool/bridge.sh`. La prueba Dart
cruza FFI contra la biblioteca compilada.

Pasaron `cargo fmt --check`, `cargo test --locked` (8 pruebas de integración),
`cargo clippy --all-targets --locked`, `cargo deny check`, `rust-checks all`, `bash tool/bridge.sh check`,
`bash tool/test_bridge.sh`, `dart run tool/check_limits.dart`, la prueba negativa de capas y los 1.949
tests de Flutter. El análisis estricto de Dart 3.13.4 con `--fatal-infos --fatal-warnings` no encontró
incidencias. Flutter compiló la biblioteca Native Assets para macOS; Xcode no completó
el build de la app porque falta un perfil de firma de desarrollo.

La regeneración se comprobó en el árbol de trabajo, no en un checkout limpio independiente. La prueba
negativa de generación detectó un enlace Dart alterado y lo regeneró; la prueba de capas rechazó el
import del puente desde dominio.

### Registro de B3 (cierre) y B4 · 2026-10-19

**Cierre de B3.** `bash tool/bridge.sh check` solo comparaba el árbol de trabajo antes y después de regenerar.
Se añadió `bash tool/bridge.sh clean-checkout`, que crea un árbol de trabajo limpio, aplica el estado a verificar,
instala dependencias, regenera y exige ausencia de diferencias. Su primera ejecución encontró un defecto real: el
`frb_generated.dart` versionado difería de la salida del generador (`final` frente a `var`, resultado de una pasada
posterior de `dart fix`). Se versionó la salida pura del generador y la comprobación termina sin diferencias.

**API Rust.** Cada evento de una sesión lleva `source` (revisión, nodo y tramo): `TraceEvent` registra el tramo de
la instrucción que lo emite y la API lo resuelve contra la vista del documento por coincidencia exacta de línea y
columna, no por línea. Se añadieron `program_view`, `query_node` y `query_page` (`array_cells`, `frame_variables`,
`object_fields`) con cursores opacos ligados a sesión, revisión, ejecución, consulta, destino, evento y tamaño, y se
anuncian las capacidades `program_view` y `state_pages`. La ejecución de un paso (`execute` con `state_page`) y el
análisis con `include_program_view` funcionan para el adaptador de conformidad.

**Adaptadores Dart** (`lib/engine/rust/`): transporte JSON con fallos tipados, `RustProgramAnalyzer`,
`RustProgramExecution` (foco, pila de bloques, salida, entrada, fallo y límites), filas de observación paginadas y
`buildRustEngineServices` en composición, sin respaldo del núcleo Dart.

**Pruebas y verificadores.** `cargo xtask verify` del motor (tests, Clippy estricto, reglas Rust, `cargo-deny`)
terminó en verde; 15 tests nuevos de API (`program_view`, `event_source`, `state_pages`). Las pruebas del puente
(`cargo test --locked`, 11 en total, Clippy estricto) y `bash tool/test_bridge.sh` (13 pruebas Dart por FFI real,
entre ellas `Fib(20)` terminando en los cuatro ritmos, arreglos y objetos inspeccionables, un bucle infinito
cancelado, entrada, fallo en ejecución y análisis) pasan. `flutter analyze --fatal-infos --fatal-warnings`,
`check_content` y `check_design_system` pasan. `conform --subject engine` ejecuta 1521 observaciones con una
divergencia: `API.STATE.QUERY#R4` C4. Las reglas `API.PROGRAM.VIEW#R1`, `#R2` y `ENG.TRACE.EVENTS#R2` pasan a `cumple`.

**Observaciones que requieren decisión.**
- `API.STATE.QUERY#R4` C4 espera `elements: [0, 1]` y el literal `opaque` como cursor, y C5 usa un cursor literal
  inexistente. Un cursor ligado a su consulta no puede ser el literal `opaque`; la regla permanece `pendiente` hasta
  que el corpus use una forma verificable.
- `check_limits` fallaba en el commit de B3 con seis violaciones (introducidas al reformatear), aunque su informe
  afirmaba que pasaba; quedaron corregidas en el seguimiento.

**Seguimiento de B4 (misma jornada).** Se cerraron: forma de arreglos (`dimensions` en `query_page`, `[2x3]` en la
app), etiqueta de tipo en `query_frame`, `locale` independiente del perfil, argumentos en `AppDiagnostic`, pruebas con
el puente real de arreglos multidimensionales, ciclos y alias, tipos de valor y diagnósticos por idioma, y las seis
violaciones de `check_limits` heredadas (`exercise_strip`, `editor_template_row`, `diagnostics_panel`, con
`components/diagnostics_list.dart` nuevo); `flutter test` pasa completo (1982 pruebas). Latencia de `step()` con el
puente real, biblioteca nativa en release sobre Apple M-series y VM de pruebas de Flutter (8000 pasos, sin protocolo
`PERF.PROTOCOL` ni dispositivo modesto): p50 20 µs, p95 84 µs, máximo 1 ms; en debug p95 298 µs. No sustituye la
medición de B8.

**Pendientes justificados de B4.** Resaltado de sintaxis y `unitId` de foco para diagramas (los aporta el servicio de
lenguaje y la vista de programa en B5), pruebas de widgets con el puente real, y la regla `API.STATE.QUERY#R4` por su
caso C4. La puerta de B4 queda parcialmente cumplida: adaptador y `ExecutionCubit` con el puente real sí; widgets no.

### B5 · Servicio de lenguaje y consumidores restantes

- [x] Conectar completado al servicio Rust, con revisión de documento y conversión UTF-16/UTF-8.
- [x] Reutilizar vocabulario generado; eliminar tablas duplicadas en el camino Rust.
- [x] Adaptar diagramas y aserciones estructurales a la vista pública aprobada.
- [x] Adaptar emisores Python y Rust a la vista pública aprobada.
- [x] Ejecutar comprobaciones de ejercicios mediante Rust, sin usar el núcleo Dart como respaldo.
- [x] Crear el conjunto de composición Dart estático; mantener el dominio libre de ambos transportes.
- [x] Completar el conjunto Rust e integrarlo en `AppDependencies` sin respaldo Dart.
- [x] Verificar equivalencia observable de los puertos con sus diferencias conocidas contrastadas con el corpus.

**Puerta:** todos los ejercicios ejecutables de la base de conocimiento clasificados y ejecutados;
plantillas válidas en ambos perfiles; diagnósticos, diagramas y exportación respetan D-P07.
No basta una muestra de ejercicios elegida por conveniencia ni un `all_passed` sin resultados individuales.

#### Registro de una iteración de B5 · 2026-10-19

Se conectaron el completado contextual y las plantillas al servicio Rust, con revisión del documento y conversión de
posiciones entre UTF-16 y UTF-8. El editor Rust consume el vocabulario generado para ambos perfiles. Los diagramas y
las aserciones estructurales leen `API.PROGRAM.VIEW`; la suite de referencia de ejercicios ejecuta los 190 casos
mediante el puente Rust y no usa el motor Dart como respaldo. La composición Dart quedó agrupada en
`DartEngineServices`. `RustEngineServices` agrupa los adaptadores disponibles, aunque todavía no incluye un emisor ni
una fuente de referencia de sintaxis, por lo que no construye una composición `AppDependencies` completa.

Pasaron `cargo xtask verify`, `flutter test --no-pub` (2193 pruebas), `flutter analyze --fatal-infos --fatal-warnings`,
`dart check_content.dart`, `dart check_limits.dart` y `git diff --check`. La prueba FFI recorrió 190/190 ejercicios
ejecutables en ambos perfiles.

La puerta sigue abierta: la exportación Python/Rust y la equivalencia observable de todos los puertos están pendientes.
Además, D-R8-01 asigna los emisores a `API.PROGRAM.VIEW`, pero la vista disponible no expone referencias de resolución
suficientes para traducir sin ambigüedad identificadores y funciones integradas. Ampliarla implica un conflicto con
D-R8-06: esta iteración amplió `API.VERSIONING` y `API.PROGRAM.VIEW`, incluyó bloques `cambio` y cambió sus versiones,
mientras D-R8-06 había resuelto congelarlas y registrar la clasificación fuera del corpus. Se conserva el cambio de
trabajo para revisión; hace falta decidir si se mantiene el contrato congelado y se busca otra implementación conforme,
o si se autoriza reclasificar y versionar las capacidades y referencias semánticas necesarias para completar B5.

#### Registro del cierre de B5 · 2026-10-19

**Resolución de decisiones.** El conflicto con D-R8-06 era aparente: la política de versiones permite modificar el
cuerpo de una especificación sin subir su versión ni usar bloques `cambio`. `API.PROGRAM.VIEW` y `API.VERSIONING`
volvieron a 0.1.0 sin bloque, se reancló su hash retirando las claves exactas de `history` y de los anclajes
activos, y su clasificación vive en `results/r8-b1-contract-changes.json`. Los bloques `cambio` de
`PERF.AOT.LEVEL` y `PERF.SUITE.AWFY-CORE` son anteriores y pertenecen a R6; no se tocaron.

**Qué se construyó.** El motor añade a `API.PROGRAM.VIEW` semántica independiente del perfil (operadores, literales,
función incorporada no oculta, receptor de superclase, salida sin salto, tipo primitivo, nodos `dimensioned` y roles
de subprogramas) y las operaciones `reference_vocabulary` y `diagnostic_template`. La app gana `RustProgramExporter`
(emisores Python y Rust sobre la vista), `RustSyntaxReferenceSource`, la interfaz `EngineServices` con las dos
composiciones estáticas y `buildRustLocalDependencies`. Un recorrido de importaciones prueba que ningún archivo
alcanzable desde la composición Rust importa `pseudolearn_core`.

**Defectos encontrados al contrastar.** Los diagramas Rust ignoraban toda sentencia compuesta (las fixtures
fabricadas las envolvían en un nodo que el motor no produce); los subprogramas no tenían roles de hijo y no
aparecían como unidades; el adaptador usaba rigor estricto frente al flexible de la composición Dart; los rótulos de
selector y de cabecera de bucle no usaban los lexemas del perfil; y las pruebas de `test/` cargaban una biblioteca
nativa `release` precompilada que nada recompilaba, así que el «190/190» anterior no probaba el código vigente. Se
añadió una prueba de frescura de esa biblioteca. En el corpus, el comparador de SEE exigía colecciones y roles que
sus propias pruebas no proporcionaban y el crate `see_conformance` incumplía `cargo fmt` y el límite de líneas;
los casos `C5` y `C6` de la vista nunca se habían ejecutado y tenían esperados incorrectos.

**Pruebas.** `cargo xtask verify` del motor: 859 pruebas, Clippy estricto, reglas Rust y `cargo-deny` en verde.
`cargo xtask verify` de SEE en verde (161 especificaciones, `lock --check`, `export --check`); `conform --subject
engine`: 1524 observaciones y una divergencia (`API.STATE.QUERY#R4` C4, ya conocida). `flutter test`: 2228 pruebas;
`flutter analyze --fatal-infos --fatal-warnings`, `check_limits`, `check_content`, `check_design_system` y
`bash tool/test_bridge.sh` (17 pruebas FFI) en verde.

**Puerta.** Los 190 ejercicios (95 por perfil) se clasifican (58 conductuales, 132 con aserciones estructurales,
ninguno no ejecutable) y se ejecutan uno a uno mediante Rust con resultado individual. Las plantillas del editor
forman programas cuyos únicos errores son marcadores de posición, en ambos perfiles. La suite de equivalencia
compara 362 programas: exportación idéntica en 724 comparaciones, mismos veredictos de ejercicios,
construcciones, marcadores de la referencia, teclas, unidades y formas de diagrama, con las diferencias conocidas
listadas en el README de la app (`unusedParameter` solo en Rust, rótulos con texto fuente, orden de listas de la
referencia, plantillas verificadas por el servicio).

**Pendientes justificados.** Resaltado de sintaxis y `unitId` de foco en la ruta Rust; el comparador de SEE para la
regla `API.STATE.QUERY#R4`; la clasificación de las pruebas de widgets con el puente real; y la decisión de producto
sobre las particularidades heredadas de los emisores (`.pow()`, `x as f64`). No se ejecutó una comprobación remota ni
se tocó B6. La regeneración del puente no cambió (`native/` sin modificaciones).

### B6 · Integración y builds de las plataformas nativas

- [ ] iOS: integrar biblioteca de dispositivo y simulador, empaquetado y enlace según herramienta validada.
- [ ] macOS: construir y cargar arm64/x86_64 con recursos y firma de biblioteca incluidos.
- [ ] Windows x64: construir, cargar y empaquetar DLL y dependencias en instalador, portable y MSIX.
- [x] Resolver Android conforme a D-R8-03; si se exige, compilar y medir las ABI aprobadas.
- [ ] Asegurar que el empaquetado funciona sin un checkout de desarrollo ni Rust instalado en el equipo usuario.
- [ ] Ejecutar humo funcional en cada objetivo; distinguir build cruzado, simulación y ejecución real.

**Puerta:** arranque, análisis, completado, ejecución, entrada y consulta de estructuras por plataforma.
Un binario compilado sin ejecución en su objetivo no satisface «la app ejecuta».

#### Registro de una iteración de B6 · 2026-10-19

**Qué se implementó.** Se comprobó la carga Native Assets en los builds de iOS y macOS y se reforzaron los
workflows manuales para seleccionar el toolchain fijado, ejercitar el puente, verificar arquitecturas y exigir que
el DLL viaje en el bundle de Windows, el MSIX, el instalador y el ZIP portable. El build macOS queda sin firma de
Xcode; su workflow incorpora el perfil restringido y firma el framework Rust y la app después del build. Android
queda en hoja de ruta conforme a D-R8-03: B6 no compila ni distribuye la app Flutter para Android.

**Evidencia local.** `cargo build --release --locked --lib` compiló `aarch64-apple-ios`, `aarch64-apple-ios-sim`,
`x86_64-apple-ios` y `x86_64-apple-darwin`. `flutter build macos --release --no-pub --no-version-check` produjo
`PseudoLearn.app` y `pseudolearn_bridge.framework` universales arm64/x86_64 con `Assets.car`. `flutter build ipa
--no-codesign --no-pub` produjo un archive iOS arm64 que contiene el framework Rust y los recursos. El humo
`integration_test/native_engine_smoke_test.dart` pasó en un simulador iPhone 18 Pro y cubrió análisis, completado,
entrada y consulta de un arreglo a través de la composición Rust.

**Verificaciones locales.** La suite del puente pasó con 18 pruebas contra el Native Asset Release de macOS;
`flutter analyze --fatal-infos --fatal-warnings`, `dart run tool/check_limits.dart`, `dart run tool/check_content.dart`,
`dart run tool/check_design_system.dart`, el formato Dart y `git diff --check` terminaron en verde. El smoke de
integración actualizado pasó en el simulador iPhone 18 Pro.

**Estado de la puerta.** El smoke de integración macOS no pudo compilar Debug porque Xcode requiere un perfil de
desarrollo que no está instalado; el build Release sí produce el bundle universal y su framework incluido, pero no
se considera prueba de ejecución de la app. Las comprobaciones CI de archivos, firmas y arquitecturas están
incorporadas a los workflows; no se ejecutaron porque esta iteración no despachó builds remotos. No se dispone de
runner Windows ni de un iPhone físico en este entorno. El archive iOS no sustituye la ejecución en un dispositivo.
Por ello las casillas de plataformas y la puerta de B6 continúan abiertas. La distribución Windows aún requiere
evidencia de ejecución en runner Windows. No se inició B7.

### B7 · Módulo Wasm y consumidor real en navegador

- [x] Crear `pseudolearn_wasm` con README, capa declarada y superficie pública equivalente.
- [x] Compilar a `wasm32-unknown-unknown` sin `native`; generar enlaces y paquete de consumo reproducible.
- [x] Añadir consumidor mínimo de prueba que cargue el artefacto final en navegador y consulte el servicio.
- [x] Verificar ejecución, entrada, cancelación entre lotes, liberación, Unicode y extremos de enteros.
- [x] Comprobar crecimiento de memoria, invalidación de vistas y límite de memoria sin corrupción silenciosa.
- [x] Contrastar nativo/Wasm por observables del corpus; conservar diferencias y semillas reproducibles.
- [x] Aplicar D-R8-04: consumidor web mínimo, sin Flutter web.

**Puerta:** pruebas en navegador del paquete final y cero diferencias contractuales no resueltas.
El Wasm de E-17 o una ejecución exclusiva en un runtime de consola no sustituye esta prueba del paquete web.

#### Registro de una iteración de B7 · 2026-10-19

**Qué se implementó.** Se añadió `pseudolearn_wasm`, que reenvía el protocolo JSON de `pseudolearn_api` por
cadenas y mantiene exactos los enteros de 64 bits. El paquete compila a `wasm32-unknown-unknown` con la
feature `native` desactivada, limita la memoria lineal a 256 MiB y genera los enlaces web con
`wasm-bindgen` 0.2.129. Una página mínima carga el paquete release en Chrome y ejecuta la comparación
contra una sonda nativa que mantiene una sesión para todo el trazo.

**Comparación observable.** Las respuestas nativas y Wasm coincidieron byte por byte en el trazo
determinista probado: completado del servicio; análisis; ejecución por lotes; programa y salida Unicode
con `ñ🌍`; entrada `i64::MAX`; semilla `i64::MIN`; liberación y consulta posterior; codificación con
`u64::MAX`; y cancelación de un bucle entre lotes con semilla 42. El caso inválido de JSON se rechazó
con excepción explícita. No se observaron diferencias contractuales en esos casos; las semillas y
solicitudes quedan fijadas en la prueba del navegador.

**Memoria y reproducibilidad.** Un programa con comentario de 8 MiB forzó crecimiento; se verificó que
la vista previa sobre la memoria quedó invalidada y que la sesión siguió respondiendo. Un intento de
superar los 256 MiB fue rechazado sin cambiar la longitud existente ni impedir una consulta posterior.
El generador se ejecutó dos veces y `diff -r` confirmó igualdad del paquete producido.

**Verificaciones locales.** `cargo xtask verify` terminó en verde: formato, Clippy, pruebas del
workspace, verificadores Rust, toolchain y `cargo deny`. `bash tool/wasm.sh test` compiló el artefacto
release, comprobó que el grafo Wasm no incorpora Cranelift ni el backend nativo, reprodujo el paquete
y pasó las tres pruebas en Chrome. `git diff --check` también terminó en verde.

**Estado de la puerta.** B7 queda implementado y verificado para el consumidor mínimo definido por
D-R8-04. B6 conserva su puerta abierta por ejecución y validaciones de plataforma pendientes. No se
iniciaron B8 ni B9.

### B8 · Conformidad de app, experimento E-NR2 y tamaños

- [x] Implementar el adaptador `app` de SEE con lanzador y vínculos a pruebas ejecutables de la app.
- [x] Usar el transporte generado real para ejecución, estado y completado; no devolver constantes ni consultar
      directamente Rust para evitar la frontera que se pretende verificar.
- [ ] Conectar propiedades y mediciones a ejecutores; demostrar que detectan una proyección errónea deliberada.
      Las propiedades API ya usan el transporte FRB y las pruebas negativas rechazan una proyección deliberadamente errónea; falta el ejecutor de E-NR2.
- [ ] Ejecutar la campaña de §7 en dispositivo físico, escritorio y navegador según su alcance.
- [x] Medir los binarios finales y guardar procedencia, hashes y resumen recalculable.

**Puerta:** `APP.*` en `cumple`, E-NR2 reproducible y todos los presupuestos aplicables satisfechos.
Una degradación se corrige y vuelve a medir; cambiar un umbral exige revisión explícita del contrato.

### Registro de B8 · 2026-10-19

**Qué se implementó.** `apps/pseudolearn_app/tool/see_app_adapter.dart` negocia SEE, abre el transporte
FRB generado y atiende análisis, escenarios APP y llamadas de propiedades API. Los escenarios de ritmo,
estado y completado consumen operaciones reales del transporte. SEE compara los cursores opacos por
presencia y la inclusión de candidatos sin fijar orden. Se añadieron pruebas negativas de comparación para
confirmar que una proyección de candidatos errónea falla. El capturador
`packages/pseudolearn_benchmarks/tool/capture_bridge_artifacts.dart` produce el informe de tamaños desde
builds existentes y verifica arquitectura, dSYM y límites.

**Resultado de conformidad.** `see conform --subject app` ejecutó 95 observaciones; 31/32 APP pasan.
`APP.EXEC.PACE#C9` espera `divisionByZero` en un programa que asigna `/` a un entero. El corpus define `/`
como productor de real (`LANG.OPS.DIVISION#R1`) y prohíbe la conversión implícita real→entero
(`LANG.TYPES.RELATIONS#R1`); la app reporta `incompatibleTypesInAssignment` antes de ejecutar. Es un conflicto
entre el caso y las reglas del corpus; se conserva el resultado y se deja la clasificación pendiente.
`see conform --subject app --operation properties` conectó las propiedades API al transporte, ejecutó 876
de 976 muestras de `API.WIRE-FORMAT#P1` y halló que la proyección de eventos omite `source` y sus tramos.
La evidencia de esa primera ejecución quedó en la revisión de B8; la corrección y el resultado actualizado
se registran en B9.

**Resultado de artefactos y navegador.** El framework iOS arm64 Release sin firma mide 2,802,880 bytes
(2.67 MiB) frente a 3 MiB y el Wasm Brotli Q11/lgwin22 mide 493,755 bytes (482.18 KiB) frente a 600 KiB.
Ambos pasan. El informe con revisión, estado del árbol, toolchain, rutas y hashes está en
`packages/pseudolearn_spec/results/r8-artifact-size.json`. `bash tool/wasm.sh test` pasó tres pruebas
de navegador en Chrome, incluida paridad con el API nativo y crecimiento de memoria.

**Resultado de dispositivo.** El iPhone 17 con iOS 27.0.1 fue confirmado y se construyó el Release
ios-arm64. `flutter drive --release` no está soportado por Flutter para integración nativa. En Profile el
build e instalación terminaron, pero el Dart VM Service no se descubrió por Wi-Fi y la app quedó en la
pantalla inicial según la captura aportada; la persona repetirá la prueba física después. El intento de
Profile para macOS requiere un perfil de firma que no está instalado. Ninguno de estos intentos cuenta como
medición E-NR2.

**Puerta y pendientes.** E-NR2 aún no dispone de ejecutor con diez procesos y treinta iteraciones por
variante; falta la campaña en hardware, escritorio y navegador con sus resúmenes estadísticos. La
propiedad API se resolvió durante B9; C9 permanece pendiente por el conflicto registrado. B8 permanece
abierta.

### B9 · Flujos de publicación, verificación final e informe

- [x] Adaptar los workflows nativos existentes para instalar Rust exacto, objetivos y generadores fijados,
      verificar generación y empaquetar bibliotecas. Invalidar cachés con toolchain, locks y configuración.
- [x] Mantener manuales las verificaciones remotas; no añadir ejecución automática por cada push/PR.
- [x] Separar validación de build y publicación productiva: no invocar App Store, Store, CDN o despliegue
      web como efecto de una comprobación. Cualquier ejecución remota requerida necesita autorización.
- [x] Ejecutar §8 localmente y actualizar README de todos los componentes modificados en el mismo cambio técnico.
- [x] Auditar toda la aceptación de §9 contra evidencias; resolver las observaciones locales pertinentes.
- [ ] Publicar commits coherentes y push ordinario en la rama única cuando corresponda a la ejecución autorizada;
      comprobar igualdad de HEAD local/remoto, sin force push ni coautoría de IA.
- [ ] Ejecutar el workflow manual de validación en runners macOS y Windows después del push.
- [x] Actualizar localmente el informe y las casillas respaldadas por evidencia; detenerse antes de R9.
- [ ] Publicar el informe actualizado en la rama remota.

**Puerta:** `PHASE-GREEN` y publicación del cambio confirmadas. Si falta una plataforma, medición o
comprobación remota obligatoria, R8 permanece abierta. B0–B5 se registran según la evidencia de cada bloque; B6 mantiene pendientes de plataforma, B7 está implementado y verificado, B8 conserva el conflicto C9 y E-NR2 pendiente, y B9 mantiene pendiente la publicación y verificación remota.

### Registro de una iteración de B9 · 2026-10-19

**Qué se implementó.** El composite action `.github/actions/setup-rust-bridge/action.yml` instala la versión
fijada de Rust, los targets requeridos y los generadores versionados; comprueba los bindings FRB. Su caché
se limita a descargas de Cargo y se invalida con toolchain, targets, manifests, locks y configuración de
generación. Los cuatro workflows productivos reutilizan esa preparación sin cambiar sus disparadores de
publicación. `.github/workflows/verify-native-builds.yml` es manual y solo de lectura: construye y prueba
los artefactos iOS, macOS y Windows, inspecciona las bibliotecas nativas y prueba sus paquetes; no publica.
Los README de app, puente y motor registran operación y decisiones.

La auditoría de `API.WIRE-FORMAT#P1` encontró que el codec de `pseudolearn_api` descartaba la fuente de
eventos al normalizar JSON y PLEV. El codec del API ahora conserva `source` (incluidos tramos) en ambos
formatos, valida su forma y cubre éxito, lote binario corrupto y Unicode/extremos numéricos. El cambio
queda documentado en los README del API y motor; `results/properties-app.json` conserva el resultado
reproducible de la propiedad.

**Resultado de los tests y conformidad.** La suite completa del app pasó 2.228 tests; los 18 tests FFI y
adaptadores pasaron después del cambio. `API.WIRE-FORMAT#P1` quedó en 1.852/1.852 muestras, `cumple`, semilla
42. El corpus SEE validó 161 especificaciones. `engine` reportó 1.524 observaciones, con el conflicto
`API.STATE.QUERY#R4/C4` descrito debajo; `service` 36/36 y `cli` 64/64. `aot` reportó 1.208 observaciones:
843 `cumple`, 357 `no aplicable` y 8 `pendiente`. El sujeto congelado `reference` conserva 1.181
observaciones y 134 divergencias. La app reportó 95 observaciones; permanece el conflicto
`APP.EXEC.PACE#R4/C9`: espera `divisionByZero` después de asignar `/` real a un entero, aunque el corpus
prohíbe esa conversión implícita.

**Verificaciones.** Pasaron `cargo xtask verify` de `pseudolearn_spec`, `pseudolearn_engine`,
`apps/pseudolearn_cli` y `packages/pseudolearn_rust_checks`; `dart test` (789 tests) y análisis/límites del núcleo;
`flutter analyze --fatal-infos --fatal-warnings`, los tres scripts del app, `flutter test` y
`bash tool/test_bridge.sh`; y `bash tool/wasm.sh test` (tres pruebas reales en Chrome). La propiedad se
repitió tras reconstruir la biblioteca nativa Release. Se validó sintaxis YAML localmente; `actionlint` y
PowerShell no están instalados en este host.

**Decisiones y pendientes.** `API.STATE.QUERY#R4/C4` espera `event=2` en un trazo de dos eventos, mientras
`C1` confirma índices desde cero al consultar `event=3` con cuatro eventos. Se reporta el conflicto y se
mantiene abierta la clasificación, sin cambiar a escondidas el caso ni el motor. La verificación de
workflows en runners Windows y macOS no se ha ejecutado. El push ordinario terminó con
`Permission denied (publickey)`; `gh auth status` informa que el token activo es inválido. Por ello no se
publicaron los commits, no se pudo despachar el workflow y no se compararon los HEAD remoto y local.
E-NR2 continúa sin la campaña requerida, la medición física no quedó aprobada y B6 mantiene validaciones
de plataforma pendientes. B9 no cierra R8 y no inicia R9.

#### Seguimiento local de B4/B5 · 2026-10-19

Se completaron dos pendientes de integración de la composición Rust. `API.ANALYZE` devuelve los tokens
léxicos ordenados con identidad y tramos; `RustProgramAnalyzer` los convierte a categorías de resaltado,
incluidos los tokens disponibles cuando el análisis recupera errores. `RustFocusTracker` deriva `unitId`
desde `API.PROGRAM.VIEW` para unidades ejecutables y miembros de clase, y conserva la identidad al entrar
en subprocesos. Se añadieron pruebas del analizador y de foco para ambos caminos.

Las verificaciones locales de la app pasaron: `flutter test --no-pub` (2.574 pruebas),
`flutter analyze --fatal-infos --fatal-warnings` y límites métricos. La biblioteca nativa Release se
reconstruyó antes de la suite. `cargo check` y los tests dirigidos de API, esquema y comparación SEE
pasaron; `API.ANALYZE` ejecutó diez observaciones sin divergencias. La conformidad de `app` ejecutó 95
observaciones y conserva una divergencia conocida en `APP.EXEC.PACE#R4/C9`; la conformidad completa de
`engine` ejecutó 1.526 observaciones y conserva una divergencia conocida en
`API.STATE.QUERY#R4/C4`. No se ejecutaron pruebas de app en plataformas distribuidas. Este seguimiento no
cierra B4, B5, B8 ni R8: E-NR2 continúa sin ejecutor, `APP.EXEC.PACE#C9` sigue en conflicto con las reglas
del corpus, y las puertas de plataforma y publicación permanecen abiertas.

### Registro de B0 · 2026-10-19

#### Revisión, herramientas y verificaciones

La revisión inspeccionada fue `f5c4d00397c33c796c2215c3c26d1043c169ff0f`, en
`feature/agregar-ruta-de-especificacion`, con el árbol limpio antes de ejecutar comandos. Se leyeron los
README y archivos de reglas de `pseudolearn_engine`, `pseudolearn_spec` y `pseudolearn_app`; no se modificaron
verificadores ni arneses.

| Herramienta | Versión o entorno observado |
|---|---|
| Git | 2.54.0 (Apple Git-157) |
| Rust y Cargo | 1.99.0, toolchain fijado por los miembros Rust afectados |
| cargo-deny | 0.20.2 |
| Flutter y Dart | Flutter 3.47.5; Dart 3.13.4 |
| Xcode y sistema | Xcode 27.0 (27A266a); macOS 27.0.1, host Darwin arm64 |
| Node.js y pnpm | Node.js 22.23.3; pnpm 12.8.1 |
| Navegador | Chrome 154.0.8037.99 |

| Miembro | Verificación ejecutada | Resultado observado |
|---|---|---|
| `packages/pseudolearn_engine` | `cargo xtask verify` | Aprobada; tests, Clippy, reglas Rust y `cargo-deny` terminaron en código 0. |
| `packages/pseudolearn_spec` | `cargo xtask verify` | Aprobada; 156 especificaciones validadas, lock y exportación vigentes; 1.180 observaciones de `reference` y 134 divergencias reportadas por SEE. El comando terminó en código 0. |
| `packages/pseudolearn_engine` contra SEE | `cargo run -p see_cli --bin see -- conform --subject engine` | 1.512 observaciones, cero divergencias; código 0. |
| `packages/pseudolearn_engine` contra SEE, filtro auxiliar | `cargo run -p see_cli --bin see -- conform --subject engine --operation analyze` | Código 1 con cinco `SEE-REGRESSION` por reglas sin observaciones en el subconjunto: `LANG.CONTROL.FOR@0.3.1#R1–R4` y `LANG.SOURCE.ENCODING@0.2.0#R2`. La corrida completa del motor sí pasa. Los resultados parciales que generó el filtro se restauraron al contenido de la revisión inspeccionada. |
| `apps/pseudolearn_app` | `flutter analyze --fatal-infos --fatal-warnings`; los tres scripts Dart del README; `flutter test` | Análisis y scripts aprobados; 1.948 tests aprobados. |

La primera invocación de Cargo y Dart desde el sandbox no podía escribir los locks/cachés globales requeridos;
se repitió con las rutas de Rust y Dart fijadas y el acceso necesario a esas cachés. No se atribuyen esos
errores de permisos a los paquetes. La conformidad `reference` conserva 134 divergencias como línea base
del sujeto congelado; no hubo cambios de código en esta ejecución.

#### Inventario de puertos y consumidores Dart

`apps/pseudolearn_app/lib/domain/ports/` contiene 33 puertos:

| Responsabilidad | Puertos |
|---|---|
| Núcleo de lenguaje y representación | `ProgramAnalyzer`, `ProgramConstructReader`, `ProgramExecution`, `ProgramExporter`, `CompletionSource`, `SourceEditor`, `ExerciseChecker`, `SyntaxReferenceSource`, `ClassDiagramBuilder`, `FlowchartBuilder`, `StructogramBuilder` |
| Documentos y conocimiento | `DocumentRepository`, `KnowledgeRepository` |
| Cuenta, enlaces y servicios externos | `AccountDeletionGateway`, `AuthGateway`, `IncomingLinkSource`, `LocalAccountDataPurger`, `ExternalUrlLauncher` |
| Progreso, sincronización y preferencias | `LocalProgressStore`, `ProgressHistory`, `ProgressSyncStore`, `RemoteDocumentStore`, `RemoteProgressStore`, `SyncCoordinator`, `SyncQueue`, `PreferencesStore` |
| Entorno y utilidades de aplicación | `AppVersionSource`, `Clock`, `ConnectivityMonitor`, `EditorKeySource`, `IdentifierGenerator`, `StoreReviewPrompt`, `TextEntryModality` |

La búsqueda de `package:pseudolearn_core/` encontró 39 archivos, todos bajo `lib/engine/`; dominio y
aplicación no importan el núcleo directamente. Los consumidores se agrupan así:

| Directorio | Archivos consumidores |
|---|---|
| `analysis/` | `core_program_analyzer.dart`, `program_analysis.dart` |
| `classdiagram/` | `class_attribute_reader.dart`, `class_model_extractor.dart`, `member_signature_printer.dart` |
| `completion/` | `profile_completion_source.dart` |
| `diagram/` | `block_builder.dart`, `executable_units.dart`, `flowchart_layout.dart`, `statement_caption.dart`, `type_lexeme.dart` |
| `editing/` | `lexicon_source_editor.dart`, `profile_key_source.dart` |
| `execution/` | `core_program_execution.dart`, `projecting_observer.dart`, `watch_row_projection.dart` |
| `exercise/` | `program_structure.dart`, `structural_assertion_checker.dart` |
| `export/` | `python_code_emitter.dart`, `python_expression_emitter.dart`, `python_statement_emitter.dart`, `rust_code_emitter.dart`, `rust_expression_emitter.dart`, `rust_statement_emitter.dart` |
| `knowledge/` | `builtin_signature_text.dart`, `engine_marker_resolver.dart`, `reference_tables.dart`, `syntax_reference_generator.dart` |
| `mapping/` | `compound_statement_index.dart`, `diagnostic_projection.dart`, `node_span_index.dart`, `profile_catalog.dart`, `span_projection.dart`, `unit_membership_index.dart` |
| `printing/` | `pseudocode_printer.dart`, `statement_printer.dart`, `structure_printer.dart` |
| `structogram/` | `structogram_builder.dart`, `structogram_layout.dart` |

Los contratos de análisis, ejecución, completado, edición, comprobación de ejercicios, exportación y diagramas
son puertos segregados existentes. Las firmas revisadas para análisis, ejecución, completado, edición y
construcción no declaran `Future`, `Stream` ni métodos `async`; la compatibilidad síncrona del transporte
sigue pendiente de probarse en B2. La app conserva además 172 ejemplos, 190 archivos de ejercicios y 30
módulos bajo `assets/knowledge/`; `check_content.dart` los validó.

#### Disponibilidad de hardware y runners

| Objetivo | Evidencia | Estado de B0 |
|---|---|---|
| iOS físico | Flutter detecta un iPhone conectado con iOS 27.0.1; el modelo no se expuso en la consulta disponible. | Dispositivo presente; aún no se sabe si satisface el requisito de “dispositivo modesto”. |
| iOS simulador | `xcrun simctl list devices available` no pudo conectar con CoreSimulator ni descubrir runtimes. El job `xcode-27` de la app ejecuta tests, pero no acredita por sí solo un arranque en simulador. | No disponible localmente; runner remoto de simulador por confirmar. |
| macOS arm64 | Host local Darwin arm64, Flutter anuncia macOS `darwin-arm64`; Xcode 27. | Disponible localmente. |
| macOS x86_64 | La app lo declara como objetivo. Los workflows `macos-15` y `xcode-27` no fijan ni registran arquitectura en sus pasos. | No confirmado; no excluirlo por falta de ejecución local. |
| Windows x64 | `push-production-windows-r2.yml` y `push-production-windows-store.yml` usan `windows-latest`; el repositorio no ofrece host Windows local. | Runner de publicación configurado; build/ejecución de la app no se ejecutaron desde B0. |
| Navegador | Chrome 154 está disponible; existe `push-production-web.yml`, pero construye y publica `apps/fe-pseudolearn` con pnpm. `apps/pseudolearn_app/web/` no existe. | Navegador disponible; la publicación web existente no es Flutter web ni un consumidor del Wasm de R8. |
| Android y Linux | No existen carpetas `android/` ni `linux/` en la app. | Alcance Android sigue en D-R8-03; Linux queda sin andamiaje. |

Los workflows productivos existentes son manuales para iOS, macOS, dos canales Windows y el sitio web. El
workflow `verify-monorepo.yml` ejecuta tests de la app en `xcode-27`, pruebas del frontend web en `macos-26`
y benchmarks Rust en macOS, Linux y Windows; no contiene una matriz de ejecución de la app Flutter para
simulador, macOS x86_64 o Windows.

#### Registro de decisiones de alcance

| ID | Alternativas y efecto | Evidencia disponible | Estado |
|---|---|---|---|
| D-R8-01 | Conservar diagramas, emisores y aserciones estructurales mediante una vista pública inmutable; o retirarlos con decisión explícita. Afecta B1, B3 y B5. | Hay 39 consumidores Dart del núcleo en 12 subdirectorios de `engine/` y puertos segregados para estas responsabilidades. | Resuelta: conservarlos mediante `API.PROGRAM.VIEW`; implementación en B3–B5. |
| D-R8-02 | Mantener una superficie síncrona acotada si el transporte lo permite; o cambiar puertos y composición si la herramienta obliga a asincronía/hilos. Afecta B2–B4. | FRB 2.13.0 generó funciones sync; la ruta Dart–FFI–`pseudolearn_api` ejecutó lotes de 64 con p95 de 95 µs. `ApiSession` no es `Sync`. | Resuelta: handles `u64` sobre un registro del hilo invocador; sin sesión opaca ni worker. |
| D-R8-03 | Medir una biblioteca Android sin distribuir app Flutter; o ampliar producto y distribución Android. Afecta B1, B6 y B8. | Android aparece como objetivo en arquitectura/performance, pero no en README, scaffold ni workflows de la app. | Resuelta: Android sigue en la hoja de ruta; R8 no exige compilarlo ni distribuir la app Flutter. |
| D-R8-04 | Entregar `pseudolearn_wasm` con consumidor mínimo de navegador; o incluir Flutter web y sus adaptadores de persistencia/autenticación. Afecta B1 y B7. | No hay `web/` en la app; el workflow web existente despliega otro producto (`apps/fe-pseudolearn`). | Resuelta: `pseudolearn_wasm` con consumidor mínimo; sin Flutter web. |
| D-R8-05 | Elegir generación compatible con las reglas actuales; o proponer una excepción mínima localizada si es técnicamente imprescindible. Afecta B2, B3 y B7. | La salida FRB 2.13.0 incluye comentarios, atributos `allow`, `unsafe` y `unwrap` de codec; `wasm-bindgen` requiere permitir `unsafe` en la macroexpansión. | Resuelta: excepciones exactas en `native/src/frb_generated.rs`, `lib/engine/bridge/**` y el crate `pseudolearn_wasm`; el adaptador Wasm escrito no usa `unsafe` y no hay permiso global. |
| D-R8-06 | Registrar clasificación e impacto en evidencia de revisión sin bloque `cambio`; o resolver formalmente la tensión con versiones/reglas antes de editar especificaciones. Afecta B1. | `SPEC-CHANGE-CLASSIFIED` obliga clasificación; el plan identifica tensión con versionado y §3 de `07-fases.md`. No se editaron contratos. | Resuelta: versiones congeladas; clasificación e impacto en evidencia separada, sin bloque `cambio`. |
| D-R8-07 | Consumir el comportamiento incremental vigente sin prometer reutilización semántica; o ratificar primero la reformulación de `TOOL.SERVICE.INCREMENTAL#R2`. Afecta B1 y B5. | El relevo de R7 declara pendiente su ratificación; B0 no la resuelve. | Resuelta: consumir el contrato vigente sin exigir reutilización semántica ni crear dependencia futura de ratificación. |
| D-R8-08 | Usar el iPhone detectado si se confirma que representa un dispositivo modesto; o fijar otro modelo físico. Se deben precisar modelo, SO, modo release y acceso a medición antes de B8. | La persona confirmó iPhone 17 con iOS 27.0.1 y autorizó medición Release. `flutter build ios --release --no-codesign` produjo el framework arm64; `flutter drive --release` no admite integración nativa y Profile instaló, pero no descubrió el VM Service por Wi-Fi. La captura posterior muestra la pantalla inicial. El simulador iOS y macOS x86_64 no quedaron disponibles localmente. | Selección y autorización confirmadas; calificación como dispositivo modesto y medición física siguen pendientes. |

**Resultado de la puerta:** B0 levantó la evidencia solicitada. Las decisiones pendientes no requeridas
por B1 continúan ligadas a B2 y B8; el dispositivo modesto, el simulador iOS y macOS x86_64 siguen sin
contar como pruebas aprobadas y no son criterios de la puerta documental de B1.

## 7. Protocolo reproducible de E-NR2

**Pregunta:** ¿los lotes y las consultas por recurso permiten observar desde la app dentro del presupuesto,
sin copiar el estado completo ni bloquear la interfaz? Medir comportamiento y coste por separado.

| Variante | Intervalo y propósito |
|---|---|
| Motor directo | Avance y consulta por la misma API, sin transporte; línea base en el mismo hardware |
| Puente mínimo | Ida y vuelta de carga conocida; separa coste fijo y tamaño transferido |
| Puente con lotes | Avance, transferencia, decodificación, aplicación de deltas y consulta del estado visible |
| Camino de app | Desde solicitud de paso hasta modelo visible preparado; medir además el fotograma para detectar bloqueos de renderizado |
| Navegador | Mismas operaciones con módulo Wasm final y enlaces JS, contabilizando copias de memoria |

Fijar antes de la captura tamaños de lote (propuesta inicial: 1, 16, 64 y 256 eventos), presupuesto de
trabajo, región visible consultada, políticas de retención y límites. Informar latencia por solicitud,
por paso visible y por evento procesado; dividir la duración de un lote entre eventos no demuestra
la latencia de una pulsación de paso individual.

**Cargas:** AWFY-core según su contrato; `Fib(20)`; arreglos multidimensionales; alias y ciclos;
recursión; salida abundante; entrada suspendida; ejecución larga y cancelación; consulta de un evento
retenido. Añadir documento de 10 000 líneas para medir completado a través del puente, sin reabrir la
decisión de R7 sobre reutilización semántica.

**Método:** aplicar `PERF.PROTOCOL`: al menos diez procesos/arranques independientes y treinta
iteraciones por proceso, semilla fija, estado nuevo, procedencia previa al build y validación de
salida/terminación fuera del intervalo. No incluir escritura de informes en el reloj; las transferencias
y conversiones del puente sí pertenecen al intervalo que se evalúa. Si el dispositivo requiere un
protocolo de lanzamientos distinto, especificarlo y revisarlo antes de capturar.

Publicar muestras, p50/p95, MAD/IQR, resolución del reloj, intervalos del 95 % según el contrato,
memoria máxima observada y candidatos de cambio sin descartar muestras. Emparejar variantes por
proceso y hardware; no obtener el coste FFI restando resultados de máquinas distintas. La sobrecarga
relativa es informativa: el presupuesto absoluto de paso y consulta sigue siendo la puerta normativa.

**Tamaños:** identificar por hash cada binario release, ABI, features y opciones de enlazado/strip.
Medir biblioteca móvil por ABI según la definición acordada en B1 y Wasm con versión/opciones Brotli
fijadas; no confundir el tamaño del instalador completo o de un archivo universal con el de una ABI.
Registrar por separado los enlaces Dart/JS y el tamaño del paquete descargable, aunque no sean la métrica
normativa. Verificar por metadatos/dependencias que los artefactos no incluyen el backend nativo.

**Evidencia propuesta:** datos crudos y manifiestos en
`packages/pseudolearn_benchmarks/results/r8-bridge/`; resumen de E-NR2, tamaños, matriz por plataforma
y verificación en `packages/pseudolearn_spec/results/`, con nombres `r8-bridge-enr2.json`,
`r8-artifact-size.json`, `r8-platforms.json` y `r8-verification.json`. Son destinos previstos: cada
informe debe ser producido por una orden del arnés documentada al implementarlo, no escrito a mano.
Guardar también intentos desfavorables, comandos, códigos de salida y hashes de entradas/artefactos.

## 8. Verificación exigida al ejecutar

Desde cada miembro afectado, usar sus comandos reales documentados. Los siguientes ya existen;
las órdenes del nuevo puente, de generación, navegador e integración deberán añadirse a sus README
antes de exigirlas como puerta. No se inventan subcomandos actuales para componentes aún ausentes.

| Miembro o ámbito | Comprobaciones |
|---|---|
| `packages/pseudolearn_engine` | `cargo xtask verify`; builds release sin `native` para puentes; regresión de features nativas para conservar CLI/AOT |
| `packages/pseudolearn_spec` | `cargo xtask verify`; `cargo run -p see_cli --bin see -- validate`, `lock --check`, `export --check` y `matrix` |
| Conformidad desde SEE | `cargo run -p see_cli --bin see -- conform --subject <sujeto>` para `engine`, `service`, `cli`, `aot`, `reference` y el nuevo `app`, con sus prerrequisitos; comparar por identidad, no solo por conteo |
| `apps/pseudolearn_cli` | `cargo xtask verify`, por regresión de fachada y servicio públicos |
| `packages/pseudolearn_rust_checks` | `cargo xtask verify`; aplicar reglas también a ambos puentes y ejecutar casos negativos de cualquier extensión |
| `apps/pseudolearn_app` | `flutter test`; `flutter analyze --fatal-infos --fatal-warnings`; `dart run tool/check_limits.dart`; `dart run tool/check_content.dart`; `dart run tool/check_design_system.dart` |
| Puente y Wasm nuevos | Formato, Clippy estricto, tests, capas, límites, nombres, comentarios, atributos, `unsafe`, toolchain y auditoría; pruebas reales de transporte y generación vigente |
| `packages/pseudolearn_benchmarks`, si cambia | `dart test`; `dart analyze --fatal-infos --fatal-warnings`; `dart run tool/check.dart`; verificaciones propias del submiembro Rust si se modifica |
| `packages/pseudolearn_core` congelado | Regresión de tests, análisis y límites del README; no modificar implementación para hacer coincidir el contraste |
| Integración multiplataforma | Arranque desde artefacto empaquetado, flujo de ejercicio y pruebas de estructuras/entrada/completado; informes de build y ejecución separados |
| Documentación | Puerta `DOC-NO-TRANSIENT-REFS`, incluida en el xtask de SEE, con casos negativos; enlaces nuevos válidos |

Los casos del corpus se ejecutan desde SEE; no se copian como tests Rust. Los tests del adaptador
verifican conversión, vida de recursos y fallos propios del transporte. Tests espejo de fuentes,
caminos feliz/infeliz y bordes: vacío, tamaño cero, profundidad, extremos numéricos, nombre de un
carácter, Unicode y programa vacío (`TEST-BOTH-PATHS`, `TEST-MIRROR`).

## 9. Trazabilidad de aceptación de R8

| Criterio de 07-fases.md | Trabajo | Evidencia necesaria |
|---|---|---|
| Especificaciones `APP.*` | B1, B8 | Contratos validados, vínculos por regla, observaciones reales y casos negativos |
| `pseudolearn_bridge` y Dart generado | B2–B3 | Builds, pruebas por transporte y regeneración sin diferencias |
| Adaptador `RustCoreEngine` | B4–B5 | Puertos cubiertos, composición Rust sin respaldo Dart, errores y liberación probados |
| `pseudolearn_wasm` | B7 | Paquete final cargado en navegador, paridad y casos de memoria/enteros |
| Flujos de publicación Rust | B6, B9 | Configuración reproducible y builds empaquetados por plataforma; ejecución remota autorizada cuando sea necesaria |
| D-P07 | B0–B1, B5 | Decisión explícita y consumidores conservados o retirados conforme a ella |
| App en plataformas distribuidas | B6 | Ejecución real en iOS, macOS arm64/x86_64 y Windows x64; ampliar solo por alcance acordado |
| Ritmos y estado de arreglos/objetos | B4, B8 | `APP.EXEC.PACE` y `APP.EXEC.SNAPSHOT-VIEW` en `cumple`, con pruebas visuales complementarias |
| `Fib(20)` y conocimiento | B4–B5 | Terminación y resultados por ejercicio, perfil y ritmo aplicable; fallos clasificados |
| Latencia por puente y E-NR2 | B8 | Captura en dispositivo modesto y comparación recalculable de variantes |
| Tamaños | B6–B8 | Mediciones de artefactos finales frente a `PERF.ARTIFACT.SIZE`, incluido ámbito Android resuelto |
| Fase terminada | B9 | Todas las puertas verdes, informe publicado y HEAD local/remoto iguales |

## 10. Riesgos y regla de cierre

| Riesgo | Señal | Respuesta dentro de R8 |
|---|---|---|
| El puente domina el coste de observar | Latencia crece con objetos/eventos transferidos | Reducir copias y proyecciones a lo visible, ajustar lotes y repetir E-NR2; conservar esperados |
| El lote rápido congela la interfaz | Cancelación o fotogramas incumplen su presupuesto | Acotar trabajo, ceder entre lotes y medir paso individual además del caudal |
| La vista de programa se convierte en un AST público accidental | Consumidores dependen de índices/variantes internas | Especificar esquema estable y proyectarlo desde API, con pruebas de capacidades y compatibilidad |
| Una parte de la app sigue usando Dart sin advertirlo | Ejercicios o diagramas pasan solo con el adaptador antiguo | Auditar imports y dependencias efectivas de composición; probar con el respaldo inaccesible |
| Pérdida de precisión o buffers inválidos en web | Divergencias de enteros o corrupción tras crecer memoria | Codificación sin pérdida, límites explícitos y pruebas del paquete final en navegador |
| Pruebas fabricadas como en el primer cierre de R7 | Respuestas constantes, JSON sin productor o propiedades vacías | Pruebas deliberadamente fallidas, ejecutores reales y reproducción de informes desde datos crudos |
| Falta hardware, firma o runner | Solo existe build local de una plataforma | Mantener abierta la aceptación afectada y solicitar acceso o ejecución puntual autorizada |
| Biblioteca excede presupuesto | Grafo contiene dependencias inesperadas o duplicadas | Revisar features y enlace; medir antes de proponer otro umbral |

El informe final distinguirá implementación, pruebas con cantidades y salidas reales, verificadores,
observaciones resueltas, decisiones y pendientes justificados, además de publicación y uso de CI.
Aplicar la skill `phase-gate` antes de declarar el cierre. Un requisito obligatorio incumplido no puede
aplazarse a R9 para marcar R8 como terminada. El retiro de Dart permanece pendiente hasta su fase.


## 10. Actualización autorizada durante el retiro de Dart

La autorización de R9 permite retirar la composición Dart y completar sus verificaciones locales sin
exigir en esta iteración campañas físicas, distribución ni workflows remotos. Las pruebas de plataforma
se realizarán después de R9 y, inicialmente, solo en macOS e iOS. Los criterios que requieren esos datos
no se marcan satisfechos: E-NR2, presupuesto de latencia por puente y experiencia física conservan su
pendiente. La deuda AOT aceptada permanece abierta y no permite estabilizar contratos incumplidos.

El ejecutor de solicitudes de E-NR2 vive en `packages/pseudolearn_benchmarks/tool/`: genera escenarios
con esperados independientes, ejecuta variantes directa, FFI y modelo de app, conserva crudos y verifica
la totalidad de operaciones. Su smoke comprueba corrección; no constituye campaña ni certifica plataformas.
Los fotogramas permanecen sin datos hasta la validación física. La captura de modelo Fib(20) configura
un presupuesto explícito de un millón de pasos; el límite interactivo predeterminado sigue en diez mil.
La prueba funcional rápida usa Fib(4), con resultado 3, sin sustituir la campaña pendiente.

El caso C9 emplea operandos y destino reales; la conformidad app renueva la evidencia del fallo y compara
estado conservado antes y después. Los datos anteriores de R8 permanecen como historia, con sus conflictos
y pendientes originales. Este seguimiento no convierte esas capturas en evidencia de la revisión actual.
