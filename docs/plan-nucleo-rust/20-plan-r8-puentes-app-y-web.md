# Plan de ejecución de R8 · Puentes con la app y la web

> **Estado:** propuesta de ejecución, pendiente de autorización de R8. Fecha: 2026-10-19.
> Rama única: `feature/agregar-ruta-de-especificacion` (`GIT-SINGLE-BRANCH`).
> Este encargo autoriza redactar el plan; no iniciar su implementación ni publicar aplicaciones.
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
| D-R8-01 | D-P07: emisores Python/Rust y diagramas usan AST Dart | Conservar las funciones actuales mediante una vista pública de programa, inmutable y especificada en `API.*`; compartirla entre diagramas, emisores y comprobaciones estructurales. Alternativa: retirar funciones con autorización explícita | B1, B3, B5 |
| D-R8-02 | Puertos síncronos y micro-lotes en hilo principal frente al transporte generado | Validar una superficie síncrona acotada para consultas y avance con presupuesto. Si la herramienta obliga a asincronía o hilos, presentar el cambio de contrato y README antes de alterar puertos o composición | B2–B4 |
| D-R8-03 | Android aparece en el plan de arquitectura, pero no en plataformas actuales de la app; `PERF.ARTIFACT.SIZE#M1` también lo nombra | Confirmar si se exige biblioteca Android medible sin app distribuida o se amplía el producto. No declarar la medición Android «no aplicable» ni añadir una plataforma unilateralmente | B1, B6, B8 |
| D-R8-04 | Wasm obligatorio frente a ausencia de `web/` Flutter | Entregar `pseudolearn_wasm` y un consumidor mínimo de prueba en navegador. Decidir por separado si R8 debe incluir andamiaje Flutter web y sus adaptadores de persistencia/autenticación | B1, B7 |
| D-R8-05 | Código generado puede contener comentarios, atributos o `unsafe` incompatibles con las reglas actuales | Inspeccionar una generación de prueba fuera del producto; someter cualquier excepción mínima al contrato de reglas y documentarla. No borrar comentarios de código generado ni ampliar exenciones de forma global | B2, B3, B7 |
| D-R8-06 | Versiones congeladas y prohibición de bloque `cambio` en 07 §3 frente a `SPEC-CHANGE-CLASSIFIED` | Mantener versiones existentes y proponer clasificación e impacto en evidencia separada de revisión, sin bloque `cambio`; confirmar su compatibilidad antes de editar contratos | B1 |
| D-R8-07 | Reformulación de `TOOL.SERVICE.INCREMENTAL#R2` durante R7 pendiente de ratificación | Obtener resolución sobre el contrato que consumirá la app. No añadir reutilización semántica como requisito implícito de R8 | B1, B5 |
| D-R8-08 | Dispositivo más modesto requerido por la aceptación, sin modelo fijado aquí | Fijar dispositivo físico, SO, modo release y acceso a medición antes de cerrar el protocolo. El simulador y Apple M2 no sustituyen esa evidencia tras incorporar el puente | B0, B8 |

Las decisiones de producto corresponden a la persona responsable. Las elecciones de versión de
`flutter_rust_bridge`, generador, cargokit y `wasm-bindgen` se verifican en documentación oficial al
ejecutar B2, se fijan de manera compatible y se registran con sus alternativas en los README. Este plan
no prescribe versiones no contrastadas ni supone que una receta de integración existente siga vigente.

## 4. Contratos que deben existir antes de implementar

### 4.1. Cuatro contratos `APP.*` del catálogo

Los nombres de reglas y casos siguientes son una propuesta de autoría, no contratos ya vigentes.
Cada regla debe tener casos o propiedades ejecutables y cada observable debe ser obtenible de la app.

Los cuatro ritmos actuales son `StepPace.nextStatement`, `overBlock`, `outOfBlock` y `toEnd`, definidos
en `lib/application/execution/step_pace.dart`. No son cuatro velocidades temporales: determinan dónde
se detiene el avance. B1 debe conservar esa distinción al relacionarlos con los eventos de la VM.

| Contrato nuevo | Reglas propuestas | Casos mínimos y oráculo |
|---|---|---|
| `APP.ENGINE.BOUNDARY` | R1: solo `engine/` consume la API y transportes; R2: ambos adaptadores satisfacen los puertos sin lógica de lenguaje en la app; R3: recursos y fallos tienen ciclo de vida definido | Rechazo deliberado de import Rust/generado en dominio o aplicación; liberación, cierre repetido, identificador inválido, versión incompatible y fallo interno. Verificador estructural con caso negativo y pruebas de frontera |
| `APP.EXEC.PACE` | R1: fijar los cuatro ritmos existentes a partir de eventos observables; R2: mismo resultado y orden de efectos con cualquier ritmo; R3: micro-lotes cooperativos y pausa/entrada/cancelación sin pérdida; R4: presupuesto de ejecución distinto del ritmo visual | `Fib(20)`, bucles, subprocesos, recursión, entrada válida/inválida/agotada, error y bucle no terminante cancelado. Esperados derivados de `ENG.*` y `API.EXECUTE`; no copiar contadores accidentales del intérprete Dart |
| `APP.EXEC.SNAPSHOT-VIEW` | R1: primitivas y arreglos con forma e índices; R2: objetos con identidad, campos, herencia, alias y ciclos; R3: estado coherente con el evento seleccionado y límites de retención; R4: paginación y truncamiento explícitos | Arreglo vacío y multidimensional, arreglo de objetos, dos alias, autorreferencia y ciclo mutuo, ausencia, campos heredados, salida de ámbito, recursión y consulta fuera del horizonte. Validar valores y relaciones, no solo una captura visual |
| `APP.EDITOR.COMPLETION` | R1: consumir `TOOL.SERVICE.COMPLETION`; R2: convertir posiciones correctamente; R3: no aplicar una respuesta de revisión antigua; R4: conservar perfil e idioma de interfaz independientes | Documentos incompletos, miembros, ámbitos y sombreado, cierres, plantillas bilingües válidas, cursor con UTF-8/UTF-16 y ediciones consecutivas. Comparar proyecciones con consultas reales del servicio |

Crear los archivos correspondientes en `packages/pseudolearn_spec/specifications/app/`, con sujeto
`app`, estado `experimental` y versión inicial conforme a la política resuelta en B1. Registrar sujeto,
adaptador y vínculos donde SEE los resuelve realmente; no suponer que basta añadir un YAML.

### 4.2. Extensiones de API y rendimiento

1. Auditar `API.MODEL`, `API.ANALYZE`, `API.EXECUTE`, `API.STATE.QUERY`, `API.ERRORS`,
   `API.VERSIONING` y `API.WIRE-FORMAT`: identificar operaciones, errores y capacidades que ya existen.
2. Si se aprueba conservar emisores y diagramas, especificar la vista de programa antes de crearla.
   Debe describir unidades, sentencias, expresiones, relaciones de clases, identificadores y tramos;
   su representación pública no expone índices internos del CST, HIR o bytecode como contrato duradero.
   La vista es una proyección del motor, no un segundo parser en Dart.
3. Definir identidad de nodos por revisión y asociación evento–fuente–diagrama. Una edición invalida
   ejecuciones o escenas anteriores mediante una política explícita; no reutilizar índices por coincidencia.
4. Especificar enteros de 64 bits sin pérdida en Dart/JavaScript, identificadores opacos, Unicode,
   propiedad y vigencia de buffers, cursores de paginación y liberación de recursos.
5. Extender sujetos o mediciones de `PERF.VM.STEP-LATENCY` y `PERF.ARTIFACT.SIZE` para que SEE pueda
   observar la frontera real. No marcar `app` en `cumple` por una medición exclusiva del sujeto `engine`.
6. Generar lock, exportación y recursos consumidores mediante sus herramientas. No editar artefactos
   generados a mano (`GEN-NO-HAND-COPY`). Registrar clasificación, impacto y revisión según D-R8-06.

Los presupuestos actuales son ≤1 ms p95 para avanzar y consultar estado en dispositivo modesto,
≤0,1 ms en Apple M2 como sustituto mientras no existe puente, ≤50 ms p95 para posicionarse y consultar
estado retenido en M2, ≤3 MiB por ABI móvil y ≤600 KiB de Wasm comprimido con Brotli. B1 debe precisar
qué mediciones son normativas para cada transporte; no trasladar automáticamente la sustitución M2
a una app que ya tiene puente, ni elevar umbrales después de medir.

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

- [ ] Confirmar rama y árbol de trabajo; conservar cambios ajenos. Registrar revisión y herramientas.
- [ ] Leer README y reglas de cada miembro afectado, incluidos verificadores y arnés si se modifican.
- [ ] Repetir verificaciones base de motor, SEE y app; separar fallos heredados de los nuevos.
- [ ] Inventariar todos los puertos y consumidores de Dart, recursos de ejercicios y flujos de publicación.
- [ ] Preparar matriz de hardware/runners: iOS físico y simulador, macOS arm64/x86_64, Windows x64 y navegador.
- [ ] Presentar D-R8-01 a D-R8-08 con alternativas, impacto y evidencia disponible.

**Puerta:** línea base reproducible y decisiones de alcance resueltas antes del bloque dependiente.
La falta de dispositivo o runner no se convierte en test aprobado ni en cierre con exclusión tácita.

### B1 · Especificaciones y casos antes del producto

- [ ] Redactar los cuatro `APP.*`, sus dependencias, casos felices, infelices y límites.
- [ ] Precisar los cuatro ritmos a partir de la app vigente y la unidad observable de Rust.
- [ ] Incorporar la vista pública decidida en D-P07 y las garantías de transporte faltantes en `API.*`.
- [ ] Definir sujetos, métricas y ámbito de Android/web; fijar protocolo y unidades de tamaños.
- [ ] Revisar esperados independientemente del adaptador; registrar clasificación e impacto.
- [ ] Actualizar lock/exportación con los generadores y añadir casos negativos al soporte nuevo de SEE.

**Puerta:** `see validate`, `see lock --check`, `see export --check` verdes; ninguna regla huérfana.
Una implementación pendiente permanece pendiente, con casos que todavía no pasan; no se falsea `cumple`.

### B2 · Prueba de viabilidad del transporte

- [ ] Contrastar documentación oficial y fijar versiones compatibles de herramientas y librerías.
- [ ] Generar una prueba desechable en un directorio temporal para inspeccionar imports, comentarios,
      atributos, `unsafe`, hilos y comportamiento síncrono; resolver D-R8-02 y D-R8-05.
- [ ] Probar negociación, un documento, un avance y una consulta con enteros extremos y Unicode.
- [ ] Medir una primera ida y vuelta y un lote real; comprobar que no incorpora Cranelift.
- [ ] Documentar en README la elección de transporte, vida de buffers y alternativas descartadas.

**Puerta:** camino Rust → Dart → dominio verificable en macOS y viabilidad de los otros objetivos.
Un conflicto de política o un coste incompatible se reporta antes de extender el producto.

### B3 · Puente nativo y generación reproducible

- [ ] Crear `native/` con README, reglas, toolchain, manifiesto, auditoría y pruebas propias.
- [ ] Exponer sesiones, recursos y operaciones de la API; transportar errores tipados y capacidades reales.
- [ ] Generar enlaces en `lib/engine/bridge/`; versionar lo consumido por el build según la política del repo.
- [ ] Añadir una orden documentada de regeneración y comprobación de árbol limpio, también desde un checkout limpio.
- [ ] Verificar liberación, identificadores inválidos, cancelación repetida, fallo interno y límites.
- [ ] Cubrir decodificación inválida, lote truncado, versión desconocida y buffers caducados.

**Puerta:** verificaciones Rust y Dart pertinentes verdes; el verificador detecta un enlace generado
deliberadamente desactualizado y rechaza un import del puente desde una capa prohibida.

### B4 · Adaptadores de ejecución y proyección de estado

- [ ] Implementar adaptadores segregados de análisis y `ProgramExecution` sobre la sesión Rust.
- [ ] Convertir tramos y diagnósticos preservando código, severidad, argumentos y perfil.
- [ ] Conectar los cuatro ritmos a eventos; desacoplar espera visual y presupuesto de trabajo.
- [ ] Consumir lotes y deltas; consultar arreglos y objetos de forma paginada sin snapshots Dart paralelos.
- [ ] Proyectar forma de arreglos, alias, ciclos y referencias ausentes con identificadores coherentes.
- [ ] Integrar entrada, parada, fallo, finalización y límites sin bloquear la respuesta del planificador.

**Puerta:** pruebas del adaptador y widgets con el puente real; `Fib(20)` termina en cada ritmo,
arreglos y grafo de objetos son inspeccionables y un bucle no terminante puede cancelarse.

### B5 · Servicio de lenguaje y consumidores restantes

- [ ] Conectar completado al servicio Rust, con revisión de documento y conversión UTF-16/UTF-8.
- [ ] Reutilizar vocabulario generado; eliminar tablas duplicadas en el camino Rust.
- [ ] Adaptar diagramas, emisores y aserciones estructurales a la vista pública aprobada.
- [ ] Ejecutar comprobaciones de ejercicios mediante Rust, sin usar el núcleo Dart como respaldo.
- [ ] Crear conjuntos de composición Dart/Rust estáticos; mantener el dominio libre de ambos transportes.
- [ ] Verificar equivalencia observable de los puertos con sus diferencias conocidas contrastadas con el corpus.

**Puerta:** todos los ejercicios ejecutables de la base de conocimiento clasificados y ejecutados;
plantillas válidas en ambos perfiles; diagnósticos, diagramas y exportación respetan D-P07.
No basta una muestra de ejercicios elegida por conveniencia ni un `all_passed` sin resultados individuales.

### B6 · Integración y builds de las plataformas nativas

- [ ] iOS: integrar biblioteca de dispositivo y simulador, empaquetado y enlace según herramienta validada.
- [ ] macOS: construir y cargar arm64/x86_64 con recursos y firma de biblioteca incluidos.
- [ ] Windows x64: construir, cargar y empaquetar DLL y dependencias en instalador, portable y MSIX.
- [ ] Resolver Android conforme a D-R8-03; si se exige, compilar y medir las ABI aprobadas.
- [ ] Asegurar que el empaquetado funciona sin un checkout de desarrollo ni Rust instalado en el equipo usuario.
- [ ] Ejecutar humo funcional en cada objetivo; distinguir build cruzado, simulación y ejecución real.

**Puerta:** arranque, análisis, completado, ejecución, entrada y consulta de estructuras por plataforma.
Un binario compilado sin ejecución en su objetivo no satisface «la app ejecuta».

### B7 · Módulo Wasm y consumidor real en navegador

- [ ] Crear `pseudolearn_wasm` con README, capa declarada y superficie pública equivalente.
- [ ] Compilar a `wasm32-unknown-unknown` sin `native`; generar enlaces y paquete de consumo reproducible.
- [ ] Añadir consumidor mínimo de prueba que cargue el artefacto final en navegador y consulte el servicio.
- [ ] Verificar ejecución, entrada, cancelación entre lotes, liberación, Unicode y extremos de enteros.
- [ ] Comprobar crecimiento de memoria, invalidación de vistas y límite de memoria sin corrupción silenciosa.
- [ ] Contrastar nativo/Wasm por observables del corpus; conservar diferencias y semillas reproducibles.
- [ ] Si D-R8-04 exige Flutter web, crear su andamiaje y adaptadores y repetir pruebas sobre esa app.

**Puerta:** pruebas en navegador del paquete final y cero diferencias contractuales no resueltas.
El Wasm de E-17 o una ejecución exclusiva en un runtime de consola no sustituye esta prueba del paquete web.

### B8 · Conformidad de app, experimento E-NR2 y tamaños

- [ ] Implementar el adaptador `app` de SEE con lanzador y vínculos a pruebas ejecutables de la app.
- [ ] Usar el transporte generado real para ejecución, estado y completado; no devolver constantes ni consultar
      directamente Rust para evitar la frontera que se pretende verificar.
- [ ] Conectar propiedades y mediciones a ejecutores; demostrar que detectan una proyección errónea deliberada.
- [ ] Ejecutar la campaña de §7 en dispositivo físico, escritorio y navegador según su alcance.
- [ ] Medir los binarios finales y guardar procedencia, datos crudos y resúmenes recalculables.

**Puerta:** `APP.*` en `cumple`, E-NR2 reproducible y todos los presupuestos aplicables satisfechos.
Una degradación se corrige y vuelve a medir; cambiar un umbral exige revisión explícita del contrato.

### B9 · Flujos de publicación, verificación final e informe

- [ ] Adaptar los workflows nativos existentes para instalar Rust exacto, objetivos y generadores fijados,
      verificar generación y empaquetar bibliotecas. Invalidar cachés con toolchain, locks y configuración.
- [ ] Mantener manuales las verificaciones remotas; no añadir ejecución automática por cada push/PR.
- [ ] Separar validación de build y publicación productiva: no invocar App Store, Store, CDN o despliegue
      web como efecto de una comprobación. Cualquier ejecución remota requerida necesita autorización.
- [ ] Ejecutar §8 y actualizar README de todos los componentes modificados en el mismo cambio técnico.
- [ ] Auditar toda la aceptación de §9 contra evidencias; resolver observaciones pertinentes dentro de R8.
- [ ] Publicar commits coherentes y push ordinario en la rama única cuando corresponda a la ejecución autorizada;
      comprobar igualdad de HEAD local/remoto, sin force push ni coautoría de IA.
- [ ] Publicar informe y casillas respaldadas por evidencia; detenerse antes de R9.

**Puerta:** `PHASE-GREEN` y publicación del cambio confirmadas. Si falta una plataforma, medición o
comprobación remota obligatoria, R8 permanece abierta. Este plan no marca ninguna tarea como ejecutada.

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
