# 07 · Fases de implementación

> **Estado:** R0 aprobada para implementación; R1–R9 pendientes de autorización individual. Ninguna fase empieza sin un mensaje explícito de la persona responsable
> (`PHASE-STOP`), y ninguna se cierra sin sus verificadores en verde (`PHASE-GREEN`, skill
> `phase-gate`). No hay fechas: el repositorio no da información para estimarlas con honestidad
> ([15](../15-evolucion-y-hoja-de-ruta.md) §3).

---

## 1. Mapa

```
R0 Fundación
 └► R1 Sistema de especificaciones
     └► R2 Especificación del lenguaje vigente ──────────────┐
         └► R3 Especificación del motor y sus fronteras      │  (todo especificado antes
             └► R4 Front-end en Rust                         │   de escribir el motor)
                 └► R5 RI, VM, runtime y biblioteca  ◄───────┘
                     ├► R6 Backend nativo (Cranelift)
                     └► R7 Servicio de lenguaje y herramientas
                         └► R8 Puente con la app y la web
                             └► R9 Paridad y retiro del núcleo Dart
                                 └► Evolución del lenguaje (ediciones A y B, paquetes)
```

- R6 y R7 pueden avanzar en paralelo tras R5.
- R8 necesita R7, porque la app usa el servicio de lenguaje para el editor. No necesita R6.

| Fase | Produce especificaciones | Produce código del motor | Sujeto que avanza  |
|------|--------------------------|--------------------------|--------------------|
| R0   | No                       | No                       | —                  |
| R1   | `SEE.*`                  | No (solo `see`)          | `see`, `reference` |
| R2   | `LANG`, `DIAG`, `LIB`    | No                       | `reference`        |
| R3   | `ENG`, `MEM`, `IR`, `API`, `RT` común, `TOOL.CLI` básico, `PERF` base | No | `reference` (línea base) |
| R4   | Ajustes                  | Sí: front-end            | `engine` (estático), `cli` |
| R5   | Ajustes                  | Sí: ejecución            | `engine`           |
| R6   | `RT` nativo, `PERF.AOT.LEVEL` | Sí: backend         | `aot`              |
| R7   | `TOOL.SERVICE.*` y resto de `TOOL` | Sí: servicio   | `service`, `cli`   |
| R8   | `APP.*`                  | Puente                   | `app`              |
| R9   | Estabilización final     | Limpieza                 | todos              |

---

## 2. Fases

### R0 · Fundación

- [ ] **Fase terminada:** tareas obligatorias completas, verificadores verdes y push confirmado.

- **Objetivo.** Dejar el monorepo listo para un miembro Rust, sin escribir aún ni una especificación ni
  el motor.
- **Contenido.**
  - [x] Aprobar este plan y las decisiones de [08](08-decisiones-riesgos-y-cambios-de-reglas.md) §1.
  - [x] Aplicar los cambios de reglas aprobados ([08](08-decisiones-riesgos-y-cambios-de-reglas.md) §3):
     `AGENTS.md` (§2, §3, §8, §9), `README.md` raíz (§1.3, §2, §3), skills.
  - [x] Instalar la cadena Rust y fijarla.
  - [ ] Crear `packages/pseudolearn_rust_checks` con sus verificadores y un caso negativo por verificador.
  - [ ] **CI** (D-23) que ejecute los verificadores de los cinco miembros actuales y de los nuevos.
  - [x] Congelar `packages/pseudolearn_core`: se declara en su `README.md` como sujeto `reference`.
- **Criterios de aceptación.**
  - [ ] La CI falla ante una violación deliberada en cada verificador de `pseudolearn_rust_checks`
     (comentario, nombre corto, abreviatura, función larga, `unwrap`, dependencia no declarada,
     `unsafe` sin fila).
  - [ ] La CI ejecuta los verificadores de todos los miembros existentes en cada cambio.
  - [x] `AGENTS.md` y el `README.md` raíz reflejan la quinta cadena y ADR-001.
- [ ] **Experimentos.** E-01: línea base de rendimiento del núcleo Dart (`PERF.BASELINE.REFERENCE` se
  escribe en R3, pero los datos se toman aquí).

### R1 · Sistema de especificaciones

- [ ] **Experimentos:** E-15.

- [ ] **Fase terminada:** tareas obligatorias completas, verificadores verdes y push confirmado.

- **Depende de.** R0.
- **Contenido.**
  - [ ] `SEE.FORMAT`, `SEE.IDENTITY` y `SEE.LIFECYCLE` en `borrador`, revisadas a mano
     ([02](02-modelo-de-especificaciones.md) §7).
  - [ ] `packages/pseudolearn_spec` con `see` en su producto mínimo:
     - `new`, `validate`, `graph`, `lock`, `diff`, `impact`;
     - `conform` con `analyze` y `execute`;
     - `matrix`, `export`.
  - [ ] El resto de `SEE.*` hasta `experimental`.
  - [ ] Adaptador `reference` en Dart.
  - [ ] **Piloto (E-15):** tres especificaciones completas, con casos y contrastadas con `reference`:
     `LANG.TYPES.INTEGER`, `LANG.CONTROL.FOR` y `LANG.SYNTAX.RECOVERY`.
- **Criterios de aceptación.**
  - [ ] `see validate` rechaza, con un caso negativo en `fixtures/` cada uno:
     - identificador duplicado;
     - regla huérfana;
     - valor `capturado` sin revisor;
     - hash que no coincide con la versión;
     - ciclo de dependencias;
     - caso de `LANG` sin el segundo perfil ni exclusión.
  - [ ] `see conform --subject reference` ejecuta los casos piloto en los dos perfiles y produce la matriz.
  - [ ] El piloto detecta H-05, H-06 y H-37 sin buscarlos expresamente. Si no los detecta, se escribe un
     informe con el porqué y se ajusta el formato antes de R2.
  - [ ] Se mide el coste de autoría (minutos por regla) del piloto. Es el dato que decide si el ritmo de R2
     es viable (R-05).
  - [ ] `cargo xtask verify` en verde en `pseudolearn_spec`.

### R2 · Especificación del lenguaje vigente

- [ ] **Experimentos:** E-10 y E-14.

- [ ] **Fase terminada:** tareas obligatorias completas, verificadores verdes y push confirmado.

- **Depende de.** R1 y E-15 aprobado.
- **Contenido.**
  - [ ] Las especificaciones `LANG`, `DIAG` y `LIB` de [03](03-catalogo-de-especificaciones.md) §2.2–2.4,
     en el orden del grafo de §3 de ese documento.
  - [ ] `LANG.SYNTAX.GRAMMAR`: la gramática formal que `language-spec.md` §14 dejó pendiente. Se escribe
     **al final de R2**, cuando las construcciones están especificadas.
  - [ ] Poda: `LANG.PROFILE.INSTITUTIONAL` como `rechazada` y la tabla de
     [03](03-catalogo-de-especificaciones.md) §4 completada con lo que aparezca al contrastar.
  - [ ] Decisiones del lenguaje que la migración obliga a tomar: D-13 (palabras reservadas), D-14 (NFC),
     D-20 confirmada.
  - [ ] Tabla de correspondencia `language-spec.md` § → identificadores, verificada mecánicamente
     ([11](../11-especificaciones-ejecutables-diseno.md) §13.4).
- **Criterios de aceptación.**
  - [ ] Toda sección de `language-spec.md` tiene correspondencia en el corpus. `language-spec.md` pasa a
     ser un índice que remite al corpus o desaparece, según D-09.
  - [ ] Todas las especificaciones de R2 en `experimental` o `estable`, con casos en los dos perfiles.
  - [ ] Toda divergencia con `reference` está clasificada: especificación corregida, `exento` con
     hallazgo, o decisión registrada.
  - [ ] Ninguna línea de código del motor Rust escrita.

### R3 · Especificación del motor y sus fronteras

- [ ] **Experimentos:** E-02.

- [ ] **Fase terminada:** tareas obligatorias completas, verificadores verdes y push confirmado.

- **Depende de.** R2 (las especificaciones de `ENG` citan `LANG`).
- **Contenido.**
  - [ ] `ENG.*` (contrato de observación, D-18).
  - [ ] `ENG.LIMITS` (D-17) como primera decisión de la fase.
  - [ ] `MEM.*` (D-04).
  - [ ] `IR.*`: el catálogo de instrucciones se escribe a partir de lo que exigen `LANG` y `LIB`.
  - [ ] `API.*`.
  - [ ] `RT.HOST.INTERFACE`.
  - [ ] `TOOL.CLI.CONVENTIONS`, `TOOL.CLI.CHECK`, `TOOL.CLI.RUN`, `TOOL.CLI.IR`,
     `TOOL.SERVICE.LOSSLESS-TREE`.
  - [ ] `PERF.PROTOCOL`, `PERF.BASELINE.REFERENCE`, `PERF.SUITE.AWFY-CORE`, `PERF.VM.*`,
     `PERF.FRONTEND.THROUGHPUT`, `PERF.ARTIFACT.SIZE`, con umbrales provisionales (D-07).
  - [ ] Primeros `README.md` de `pseudolearn_engine` y de cada crate de R4–R5, con las decisiones de
     [04](04-arquitectura-del-workspace-rust.md) §3. Los crates siguen vacíos: la regla «sin `README.md`
     no hay código» se cumple antes de la primera línea.
- **Criterios de aceptación.**
  - [ ] Las especificaciones de R3 en `experimental`. Las que `reference` puede ejecutar
     (`ENG.EXEC.MODEL`, `ENG.TRACE.EVENTS`, `ENG.INPUT`) están contrastadas.
  - [ ] El catálogo de `IR.INSTRUCTIONS` cubre cada operación que aparece en una regla de `LANG` o `LIB`.
     `see` lo comprueba con una tabla de cobertura `regla → instrucciones`.
  - [ ] `PERF.BASELINE.REFERENCE` publicada con el protocolo.
  - [ ] **Hito «núcleo especificado».** El corpus del alcance de la reescritura está en `experimental` o
     superior. Desde aquí se escribe código del motor.

### R4 · Front-end en Rust

- [ ] **Experimentos:** E-08.

- [ ] **Fase terminada:** tareas obligatorias completas, verificadores verdes y push confirmado.

- **Depende de.** R3.
- **Contenido.**
  - [ ] Crates `source`, `diagnostics`, `lexicon`, `syntax`, `semantic`, `api` (solo `API.ANALYZE`,
     `API.ERRORS`, `API.WIRE-FORMAT`, `API.VERSIONING`, `API.MODEL`) y `conformance`.
  - [ ] Generación desde la exportación del corpus (vocabulario, catálogo de diagnósticos, gramática).
  - [ ] `apps/pseudolearn_cli` con `pseudo check`.
  - [ ] Orden interno: `source` → `lexicon` → léxico de `syntax` → parser con recuperación → `semantic`
     (nombres) → `semantic` (tipos).
- **Criterios de aceptación.**
  - [ ] `engine` en `cumple` para todos los casos de análisis (`analyze`) de `LANG` y `DIAG` en los dos
     perfiles y los dos rigores.
  - [ ] `TOOL.SERVICE.LOSSLESS-TREE` en `cumple`: reimprimir el árbol da exactamente el texto en todo el
     corpus, comentarios incluidos.
  - [ ] `PERF.FRONTEND.THROUGHPUT` medido y comparado con la línea base.
  - [ ] Prueba de robustez: ninguna entrada (texto vacío, binario, Unicode descompuesto, anidación
     extrema) produce un pánico. `DIAG.ENGINE.INTERNAL-FAULT` nunca aparece en el corpus.
  - [ ] `cargo xtask verify` en verde.

### R5 · RI, VM, runtime y biblioteca

- [ ] **Experimentos:** E-06, E-12, E-16 y E-17.

- [ ] **Fase terminada:** tareas obligatorias completas, verificadores verdes y push confirmado.

- **Depende de.** R4.
- **Contenido.**
  - [ ] Crates `ir`, `lowering`, `abi`, `runtime`, `library` y `vm`.
  - [ ] El resto de `api`: `API.EXECUTE` y `API.STATE.QUERY`.
  - [ ] `pseudo run` y `pseudo ir`.
  - [ ] Orden interno:
     - RI y su verificador;
     - traducción a RI de lo procedural;
     - VM no observada;
     - runtime con aritmética comprobada;
     - biblioteca;
     - arreglos;
     - subprogramas;
     - objetos y recolector;
     - modo observado y eventos;
     - estado observable incremental;
     - `ENG.LIMITS`.
- **Criterios de aceptación.**
  - [ ] `engine` en `cumple` en **todo** el corpus de `LANG`, `DIAG`, `LIB`, `ENG`, `MEM`, `IR` y `API`.
  - [ ] Conformidad diferencial con `reference`: las salidas y las trazas coinciden en todo lo que ambos
     ejecutan, salvo los `exento`.
  - [ ] `PERF.VM.THROUGHPUT` y `PERF.VM.STEP-LATENCY` medidos. La VM no observada, al menos un orden de
     magnitud por encima del intérprete Dart en la suite (umbral provisional; se fija en D-07).
  - [ ] `MEM.MANAGED.UNOBSERVABLE#Q1` en `cumple`: la misma salida con recolección forzada en cada
     asignación y sin ella.
  - [ ] Robustez: ningún pánico con programas generados por las propiedades.

### R6 · Backend nativo (Cranelift)

- [ ] **Experimentos:** E-NR1.

- [ ] **Fase terminada:** tareas obligatorias completas, verificadores verdes y push confirmado.

- **Depende de.** R5.
- **Contenido.**
  - [ ] `RT.ABI`, `RT.FAULT.REPORTING`, `RT.PROCESS`, `RT.LINKING`, `TOOL.CLI.BUILD` y `PERF.AOT.LEVEL`,
     especificadas **al empezar la fase** y antes de su código.
  - [ ] Crate `codegen`.
  - [ ] `runtime` como `staticlib`.
  - [ ] `pseudo build`.
  - [ ] Sujeto `aot`.
- **Criterios de aceptación.**
  - [ ] `aot` en `cumple` en todo `LANG`, `LIB` y `MEM` ejecutables (salidas, diagnósticos de ejecución,
     terminación), salvo lo `exento` de observación.
  - [ ] Las reglas de ejecución de `LANG` pasan a `estable` con **dos sujetos Rust** (`engine` y `aot`) más
     `reference`.
  - [ ] Informe de `PERF.AOT.LEVEL` publicado según el protocolo, **incluidos los resultados
     desfavorables**, con la decisión sobre LLVM.
  - [ ] Los builds móviles y Wasm no incluyen Cranelift: verificado por el tamaño y por las *features*
     activadas.

### R7 · Servicio de lenguaje y herramientas

- [ ] **Experimentos:** E-09 y E-20.

- [ ] **Fase terminada:** tareas obligatorias completas, verificadores verdes y push confirmado.

- **Depende de.** R5 (puede ir en paralelo con R6).
- **Contenido.**
  - [ ] Las especificaciones `TOOL.SERVICE.*`, `TOOL.FORMAT.STYLE`, `TOOL.TRANSLATE.ROUND-TRIP`,
     `TOOL.LSP.CAPABILITIES`, `TOOL.CLI.FORMAT` y `TOOL.CLI.TRANSLATE`, al empezar la fase.
  - [ ] Crate `service` con análisis incremental.
  - [ ] `pseudo format`, `pseudo translate` y `pseudo lsp`.
  - [ ] Extensión mínima de VS Code (opcional en esta fase).
- **Criterios de aceptación.**
  - [ ] `service` en `cumple`.
  - [ ] Doble traducción idéntica al original en todo el corpus.
  - [ ] Formateo idempotente.
  - [ ] Latencias de `PERF.*` del servicio cumplidas en el hardware de referencia.

### R8 · Puente con la app y la web

- [ ] **Experimentos:** E-NR2.

- [ ] **Fase terminada:** tareas obligatorias completas, verificadores verdes y push confirmado.

- **Depende de.** R7.
- **Contenido.**
  - [ ] Especificaciones `APP.*`.
  - [ ] Crate `pseudolearn_bridge` y código Dart generado.
  - [ ] Adaptador `RustCoreEngine` en la capa `engine/` de la app.
  - [ ] `pseudolearn_wasm`.
  - [ ] Flujos de publicación con la cadena Rust.
  - [ ] Decisión D-P07 sobre los emisores y diagramas de la app.
- **Criterios de aceptación.**
  - [ ] La app ejecuta con `RustCoreEngine` en todas las plataformas que distribuye.
  - [ ] `APP.EXEC.PACE` y `APP.EXEC.SNAPSHOT-VIEW` en `cumple`; arreglos y grafo de objetos visibles (H-10,
     H-11).
  - [ ] `Fib(20)` y los ejercicios de la base de conocimiento corren completos en la app (H-14).
  - [ ] `PERF.VM.STEP-LATENCY` cumplido a través del puente en el dispositivo más modesto.
  - [ ] `PERF.ARTIFACT.SIZE` cumplido.

### R9 · Paridad y retiro del núcleo Dart

- [ ] **Fase terminada:** tareas obligatorias completas, verificadores verdes y push confirmado.

- **Depende de.** R8 (y R6 si se quiere cerrar con `aot` estable).
- **Contenido.**
  - [ ] Pasar a `estable` lo que quede en `experimental`.
  - [ ] Retirar `DartCoreEngine` de la app.
  - [ ] Retirar `packages/pseudolearn_core` del monorepo: su historia queda en git.
  - [ ] El sujeto `reference` pasa a `retirado` en el corpus. Sus resultados se conservan como «ya no
     aplica».
  - [ ] Actualizar `AGENTS.md` §9, el `README.md` raíz y las skills que nombran el núcleo Dart.
- **Criterios de aceptación.**
  - [ ] Ninguna referencia al núcleo Dart en la app ni en la CI.
  - [ ] Matriz sin `pendiente` en el alcance de la reescritura.
  - [ ] Informe final: la matriz, las métricas de rendimiento y lo que se podó.

### Después de R9 · Evolución del lenguaje

Las fases F4, F7 y F8 de [15](../15-evolucion-y-hoja-de-ruta.md) se retoman sobre el núcleo Rust. Cada
construcción nueva entra con el flujo de [06](06-flujo-de-trabajo.md): especificación → casos → tests →
código.

---

## 3. Contrato de seguimiento y cierre

Las casillas describen evidencia, no intención. Una tarea se marca solamente después de implementarla
y verificarla. Las listas anidadas de una tarea forman parte de su aceptación. Cada experimento de la
tabla se registra como tarea de la fase correspondiente.

Toda observación pertinente que pueda resolverse dentro del alcance se resuelve en esa misma fase.
Solo se difiere trabajo ajeno al alcance o dependiente de otra fase: se declara el motivo, la fase
destinataria y la condición que permitirá resolverlo. Un fallo de aceptación no es un pendiente válido
para cerrar la fase (`PHASE-GREEN`).

Al terminar cada fase se hacen commits coherentes y push ordinario a su rama remota, sin force push,
sin trailers `Co-authored-by` ni atribución de autoría a IA. Se verifica la igualdad de HEAD local y
remoto, y el resultado verde de CI. La publicación inicial permite ejecutar CI; el informe y las
casillas definitivas se publican después de reunir la evidencia. No se avanza a otra fase sin un
mensaje nuevo de autorización (`PHASE-STOP`).

### Plantilla de informe por fase

- **Implementación:** tareas terminadas, responsabilidades y decisiones.
- **Pruebas:** comandos, cantidades y resultados reales; fallos o exclusiones con motivo.
- **Verificadores:** resultado individual y evidencia de los casos negativos.
- **Observaciones:** hallazgos y resolución dentro de la fase.
- **Pendientes:** ninguno, o motivo, fase destinataria y condición de resolución por cada pendiente.
- **Publicación:** rama, commit publicado, igualdad local/remoto y ejecución de CI.

## 4. Experimentos por fase

| Fase | Experimento                                   | Pregunta                                                       | Ver                                  |
|------|-----------------------------------------------|----------------------------------------------------------------|--------------------------------------|
| R0   | E-01                                          | Línea base del núcleo Dart                                     | [16](../16-experimentos-y-benchmarks.md#e-01) |
| R1   | E-15                                          | ¿El sistema detecta defectos con un coste de autoría aceptable? | [16](../16-experimentos-y-benchmarks.md#e-15) |
| R2   | E-10, E-14                                    | Presupuesto de palabras reservadas; forma de construcciones    | [16](../16-experimentos-y-benchmarks.md) |
| R3   | E-02                                          | Techo semántico: cuánto cuesta la semántica comprobada en nativo | [16](../16-experimentos-y-benchmarks.md#e-02) |
| R4   | E-08                                          | Front-end sin pérdida e incremental                            | [16](../16-experimentos-y-benchmarks.md#e-08) |
| R5   | E-06, E-12, E-16, E-17                        | Instantáneas incrementales; recolector; fortaleza de los casos; paridad nativo/Wasm | [16](../16-experimentos-y-benchmarks.md) |
| R6   | E-NR1 (nuevo): Cranelift frente a LLVM        | ¿Alcanza Cranelift el nivel de D-07?                            | [08](08-decisiones-riesgos-y-cambios-de-reglas.md) §1 |
| R7   | E-09, E-20                                    | Calidad del autocompletado; arranque y latencia                | [16](../16-experimentos-y-benchmarks.md) |
| R8   | E-NR2 (nuevo): coste de observar a través de FFI | ¿Lotes de eventos y consulta por referencia bastan?          | [08](08-decisiones-riesgos-y-cambios-de-reglas.md) §1 |
