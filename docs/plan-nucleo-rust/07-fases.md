# 07 · Fases de implementación

> **Estado:** R0, R1, R2 y R3 completadas; R4–R9 pendientes de autorización individual. R3 tiene evidencia de cierre en §9 y plan
> ejecutado en [09](09-plan-r3-motor-clepsidra.md). Ninguna fase empieza sin un mensaje explícito de la persona responsable
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

- [x] **Fase terminada:** tareas obligatorias completas, verificadores verdes y push confirmado.

- **Objetivo.** Dejar el monorepo listo para un miembro Rust, sin escribir aún ni una especificación ni
  el motor.
- **Contenido.**
  - [x] Aprobar este plan y las decisiones de [08](08-decisiones-riesgos-y-cambios-de-reglas.md) §1.
  - [x] Aplicar los cambios de reglas aprobados ([08](08-decisiones-riesgos-y-cambios-de-reglas.md) §3):
     `AGENTS.md` (§2, §3, §8, §9), `README.md` raíz (§1.3, §2, §3), skills.
  - [x] Instalar la cadena Rust y fijarla.
  - [x] Crear `packages/pseudolearn_rust_checks` con sus verificadores y un caso negativo por verificador.
  - [x] **Comprobación remota manual** (D-23) que ejecute los verificadores de los cinco miembros
    actuales y de los nuevos cuando la persona autorice una comprobación puntual.
  - [x] Congelar `packages/pseudolearn_core`: se declara en su `README.md` como sujeto `reference`.
- **Criterios de aceptación.**
  - [x] La CI falla ante una violación deliberada en cada verificador de `pseudolearn_rust_checks`
     (comentario, nombre corto, abreviatura, función larga, `unwrap`, dependencia no declarada,
     `unsafe` sin fila).
  - [x] Los verificadores de todos los miembros se ejecutan en local; la comprobación remota manual
    permite confirmar resultados y obtener métricas en otros sistemas.
  - [x] `AGENTS.md` y el `README.md` raíz reflejan la quinta cadena y ADR-001.
- [x] **Experimentos.** E-01: línea base de rendimiento del núcleo Dart (`PERF.BASELINE.REFERENCE` se
  escribe en R3, pero los datos se toman aquí).

### R1 · Sistema de especificaciones

- [x] **Experimentos:** E-15.

- [x] **Fase terminada:** tareas obligatorias completas, verificadores verdes y push confirmado.

- **Depende de.** R0.
- **Contenido.**
  - [x] `SEE.FORMAT`, `SEE.IDENTITY` y `SEE.LIFECYCLE` en `borrador`, revisadas a mano
     ([02](02-modelo-de-especificaciones.md) §7).
  - [x] `packages/pseudolearn_spec` con `see` en su producto mínimo:
     - `new`, `validate`, `graph`, `lock`, `diff`, `impact`;
     - `conform` con `analyze` y `execute`;
     - `matrix`, `export`.
  - [x] El resto de `SEE.*` hasta `experimental`.
  - [x] Adaptador `reference` en Dart.
  - [x] **Piloto (E-15):** tres especificaciones completas, con casos y contrastadas con `reference`:
     `LANG.TYPES.INTEGER`, `LANG.CONTROL.FOR` y `LANG.SYNTAX.RECOVERY`.
- **Criterios de aceptación.**
  - [x] `see validate` rechaza, con un caso negativo en `fixtures/` cada uno:
     - identificador duplicado;
     - regla huérfana;
     - valor `capturado` sin revisor;
     - hash que no coincide con la versión;
     - ciclo de dependencias;
     - caso de `LANG` sin el segundo perfil ni exclusión.
  - [x] `see conform --subject reference` ejecuta los casos piloto en los dos perfiles y produce la matriz.
  - [x] El piloto detecta H-05, H-06 y H-37 sin buscarlos expresamente. Si no los detecta, se escribe un
     informe con el porqué y se ajusta el formato antes de R2.
  - [x] Se mide el coste de autoría (minutos por regla) del piloto. Es el dato que decide si el ritmo de R2
     es viable (R-05).
  - [x] `cargo xtask verify` en verde en `pseudolearn_spec`.

### R2 · Especificación del lenguaje vigente

- [x] **Experimentos:** E-10 local y comprobaciones técnicas bilingües terminadas; estudio humano E-14 diferido por autorización explícita a la evolución posterior a R9.

- [x] **Fase terminada:** tareas obligatorias completas, verificadores locales verdes y push confirmado.

- **Depende de.** R1 y E-15 aprobado.
- **Contenido.**
  - [x] Las especificaciones `LANG`, `DIAG` y `LIB` de [03](03-catalogo-de-especificaciones.md) §2.2–2.4,
     en el orden del grafo de §3 de ese documento.
  - [x] `LANG.SYNTAX.GRAMMAR`: la gramática formal que `language-spec.md` §14 dejó pendiente. Se escribe
     **al final de R2**, cuando las construcciones están especificadas.
  - [x] Completar la tabla de poda de
     [03](03-catalogo-de-especificaciones.md) §4 completada con lo que aparezca al contrastar.
  - [x] Decisiones del lenguaje que la migración obliga a tomar: D-13 (palabras reservadas), D-14 (NFC),
     D-20 confirmada.
  - [x] Tabla de correspondencia `language-spec.md` § → identificadores, verificada mecánicamente
     ([11](../11-especificaciones-ejecutables-diseno.md) §13.4).
- **Criterios de aceptación.**
  - [x] Toda sección de `language-spec.md` tiene correspondencia en el corpus. `language-spec.md` pasa a
     ser un índice que remite al corpus o desaparece, según D-09.
  - [x] Las 85 especificaciones de R2 en `experimental`, con casos en los dos perfiles.
  - [x] Toda divergencia con `reference` está clasificada: especificación corregida, `exento` con
     hallazgo, o decisión registrada.
  - [x] Ninguna línea de código del motor Rust escrita.

### R3 · Especificación del motor y sus fronteras

> **Plan ejecutable:** [09 · Plan de R3 · Arquitectura «Clepsidra»](09-plan-r3-motor-clepsidra.md).
> R3 se ejecuta siguiendo sus pasos B0–B8 en una sola iteración. Esta fase se completa cuando todas las
> casillas del plan 09 están marcadas con evidencia y su cierre B8 está en verde; solo entonces, en el
> paso B8.6, se marcan las casillas de esta sección y se escribe el informe de R3. Si una casilla de
> aquí y un paso del plan 09 parecieran contradecirse, se reporta (`CONFLICT-REPORT`); el plan 09 detalla
> esta sección, no la sustituye.

- [x] **Experimentos:** E-02 (ampliado con las variantes V0–V3, plan 09 §4.4 y B4).

- [x] **Fase terminada:** tareas obligatorias completas, verificadores verdes y push confirmado.

- **Depende de.** R2 (las especificaciones de `ENG` citan `LANG`).
- **Contenido.**
  - [x] `ENG.*` (contrato de observación, D-18).
  - [x] `ENG.LIMITS` (D-17) como primera decisión de la fase.
  - [x] `MEM.*` (D-04).
  - [x] `IR.*`: el catálogo de instrucciones se escribe a partir de lo que exigen `LANG` y `LIB`.
  - [x] `API.*`.
  - [x] `RT.HOST.INTERFACE`.
  - [x] `TOOL.CLI.CONVENTIONS`, `TOOL.CLI.MESSAGES`, `TOOL.CLI.CHECK`, `TOOL.CLI.RUN`, `TOOL.CLI.IR`,
     `TOOL.SERVICE.LOSSLESS-TREE` (frontera de idioma, plan 09 §11).
  - [x] `PERF.PROTOCOL`, `PERF.BASELINE.REFERENCE`, `PERF.SUITE.AWFY-CORE`, `PERF.VM.*`,
     `PERF.FRONTEND.THROUGHPUT`, `PERF.ARTIFACT.SIZE`, con umbrales provisionales (D-07).
  - [x] Primeros `README.md` de `pseudolearn_engine` y de cada crate de R4–R5, con la arquitectura
     Clepsidra (plan 09 §3, §5 y §12) y las decisiones de [04](04-arquitectura-del-workspace-rust.md) §3 que
     el plan 09 conserva. Los crates siguen vacíos: la regla «sin `README.md`
     no hay código» se cumple antes de la primera línea.
- **Criterios de aceptación.**
  - [x] Las especificaciones de R3 en `experimental`. Las que `reference` puede ejecutar
     (`ENG.EXEC.MODEL`, `ENG.TRACE.EVENTS`, `ENG.INPUT`) están contrastadas.
  - [x] El catálogo de `IR.INSTRUCTIONS` cubre cada operación que aparece en una regla de `LANG` o `LIB`.
     `see` lo comprueba con una tabla de cobertura `regla → instrucciones`.
  - [x] `PERF.BASELINE.REFERENCE` publicada con el protocolo.
  - [x] **Hito «núcleo especificado».** El corpus del alcance de la reescritura está en `experimental` o
     superior. Desde aquí se escribe código del motor.

### R4 · Front-end en Rust

> **Plan detallado:** [10 · Plan de R4 · Front-end de Clepsidra](10-plan-r4-frontend.md).
> La preparación documental está redactada; R4 sigue pendiente de autorización explícita. Sus bloques
> B0–B8 detallan esta fase, sin sustituir sus criterios. Las casillas se marcan solo con evidencia del
> cierre B8. La CLI incluye `comprobar/check` y `preferencias/preferences`, según su README y la
> frontera de idioma aprobada en R3.

- [x] **Experimentos:** E-08 (registrado en `packages/pseudolearn_spec/results/r4-e08-throughput.json`).

- [x] **Fase terminada:** tareas obligatorias completas, verificadores verdes y push confirmado.

- **Depende de.** R3.
- **Contenido.**
  - [x] Crates `source`, `diagnostics`, `lexicon`, `syntax`, `semantic`, `api` (solo `API.ANALYZE`,
     `API.ERRORS`, `API.WIRE-FORMAT`, `API.VERSIONING`, `API.MODEL`) y `conformance`.
  - [x] Generación desde la exportación del corpus (vocabulario, catálogo de diagnósticos, gramática).
  - [x] `apps/pseudolearn_cli` con `pseudo check`, `pseudo comprobar`, `preferencias` y `--see-adapter`.
  - [x] Orden interno: `source` → `lexicon` → léxico de `syntax` → parser con recuperación → `semantic`
     (nombres) → `semantic` (tipos).
- **Criterios de aceptación.**
  - [x] `engine` en `cumple` para todos los casos de análisis (`analyze`) de `LANG` y `DIAG` en los dos
     perfiles y los dos rigores (492 observaciones, 0 regresiones).
  - [x] `TOOL.SERVICE.LOSSLESS-TREE` en `cumple`: reimprimir el árbol da exactamente el texto en todo el
     corpus, comentarios incluidos (P1 y P2 verificadas en `pseudolearn_syntax/tests/reprint_tests.rs`).
  - [x] `PERF.FRONTEND.THROUGHPUT` medido (1,8M líneas/s en 10 000 líneas, p95 5,9 ms < 16 ms en Apple M2).
  - [x] Prueba de robustez: ninguna entrada (texto vacío, binario, Unicode descompuesto, anidación
     extrema) produce un pánico. `DIAG.ENGINE.INTERNAL-FAULT` nunca aparece en el corpus.
  - [x] `cargo xtask verify` en verde en motor, CLI y corpus de especificaciones.

### R5 · RI, VM, runtime y biblioteca

> **Plan detallado:** [11 · Plan de R5 · «Remanso»](11-plan-r5-ejecucion-remanso.md).
> R5 autorizada el 2026-10-15 y en ejecución. B7 fue autorizado y continúa abierto por B7.4, E-16 y la
> verificación final; B8 aún no se inicia. Por decisión D-R5-01, la deuda encontrada en la evidencia de
> R4 se resuelve como tareas de R5 (bloque BF) y R4 se mantiene cerrada. El estado de implementación vigente
> se contrasta con el plan detallado y el árbol actual; el relevo 12 conserva únicamente valor histórico.
> B1, B2, B3, B4, B5 y B6 están cerrados según la evidencia registrada en el plan 11. Las casillas de
> R5 y la fase solo se marcan en el cierre B8.
>
> **Actualización 2026-10-17:** RFC-014 Etapa 5 está implementada, pero B7.4 conserva 198 diferencias clasificadas; Etapa 6 sincronizó README, plan 11 y este resumen. B7 y R5 siguen abiertos por B7.4, E-16 y la verificación final. El detalle y los resultados están en el plan 11.

- **Bloques cerrados:**
  - [x] B0: línea base, inventario de deuda y correspondencia de verificadores.
  - [x] E-02R: 27.000 muestras, criterios aprobados y RC-01 resuelto.
  - [x] BF: deuda heredada de R4 resuelta según la evidencia de análisis y HIR del plan 11.
  - [x] B1: RC-01, contratos, extensiones de SEE, generadores/oráculos y documentación de capas.
  - [x] B2: ABI, RI, verificador, lowering procedural y órdenes `pseudo ri`/`ir`; 19/19 observaciones
    `ir` en verde y verificaciones locales registradas en el plan 11.
  - [x] B3: bytecode y VM escalar verificados, despacho generado y biblioteca matemática con
    contraste racional masivo; trazadora emparejada a 76,7× sin PGO.
  - [x] B4: memoria y modelo de ejecución cerrados; montón plano, arena de texto, recolector SizeClasses,
    llamadas solapadas, celdas y herencia; evidencia en el relevo 13 y plan 11.
  - [x] B5: gemelo sondeado, eventos estructurados, formato columnar PLEV, alternancia de gemelos en O(1),
    servicio de combustible y límites de anfitrión, entrada interactiva y suspendible, y superinstrucciones
    puras fusionadas en bytecode y VM.
  - [x] B6: vistas inmutables de estado, deltas incrementales, puntos de control diferenciales con sombra de montón de 64 palabras y segmentos de deshacer, programación por coste, raleo exponencial con fusión, retroceso determinista con VM de reproducción y experimento E-06.

- **B4, B5 y B6 cerrados:** B4 completó memoria, recolector y modelo de ejecución. B5 implementó los gemelos
  emparejados rápido y sondeado con formato columnar PLEV y búfer de deltas, alternancia en O(1), combustible
  exacto con retrocesos de sondeo, límites de tiempo, memoria y pila de llamadas, entrada interactiva
  suspendible y cinta por lotes, y superinstrucciones puras fusionadas con preservación estricta del orden de
  efectos. B6 implementó la línea temporal consultable con vistas de estado inmutables, deltas, puntos de control,
  raleo con fusión, retroceso determinista y E-06 aprobado. La conformidad integrada `execute` y las propiedades
  completas de observación se acreditan en B7.3, después de `API.EXECUTE`, sin anticipar `cumple`. R5 sigue
  abierta; B7 está en ejecución y B8 no se ha iniciado.
- [ ] **Bloques pendientes:** B7 (B7.4 y E-16 sin cerrar, además de la puerta de verificación) y B8.
- [x] **E-12 realizado:** 10.800 muestras y recolector seleccionado; evidencia en el plan 11 y relevo 13.
- [x] **E-06 realizado:** 8 métricas de línea temporal y retroceso verificadas; evidencia en el plan 11 y `results/r5-e06.json`.
- [x] **E-17 realizado:** `passed`, cero divergencias en la comparación nativo/Wasm; evidencia en
  `packages/pseudolearn_spec/results/r5-e17.json` y el plan 11.
- [ ] **Experimento pendiente:** E-16, con campaña parcial: VM conserva 820 mutantes sin ejecutar y 3
  expirados, y la campaña de `pseudolearn_library` no se ha iniciado.

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
remoto y las verificaciones locales en verde. Cuando una fase requiere una comprobación remota
autorizada, también se exige su resultado verde. Los workflows de comprobación son manuales;
publicar un commit no los dispara. El informe y las
casillas definitivas se publican después de reunir la evidencia. No se avanza a otra fase sin un
mensaje nuevo de autorización (`PHASE-STOP`).

### Prohibición estricta de referencias a la carpeta `docs` y sus fases (`DOC-NO-TRANSIENT-REFS`)

Está terminantemente prohibido referenciar cualquier documento, sección, plan o fase de la carpeta `docs/` en cualquier otra parte del monorepo fuera de esa carpeta. Ningún archivo externo —ya sean especificaciones del lenguaje o del motor, contratos canónicos, código fuente o archivos `README.md` de paquetes y crates— puede citar nombres de fases (por ejemplo, `R0`, `R4`, `R5`), planes o identificadores documentales transitorios.

Ejemplos claros de violaciones inadmisibles corregidas incluyen:
- Citar fases en metadatos de especificaciones, como `"revisado_por": "autorización de la fase R5 en la conversación"` o `"revisado_por": "autorización de la fase R5; autoría automatizada"`. Estas líneas quedan expresamente prohibidas por referenciar el contenido transitorio de las fases de `docs/`.
- Citar fases en los archivos `README.md` de crates o herramientas (por ejemplo, en `packages/pseudolearn_engine/crates/pseudolearn_runtime/README.md` donde se citaba `R5` en el texto y en las columnas de tablas de pendientes). Todo `README.md` y especificación debe ser estrictamente autosustentable; sus pendientes y compromisos se expresan exclusivamente en términos de componentes técnicos e invariantes del software.

### Política de versiones de especificaciones hasta la finalización del lenguaje

Las versiones numéricas de todas las especificaciones a partir de ahora **ya no van a cambiar ni incrementarse**. En el futuro, cuando el lenguaje esté 100% terminado, todas las especificaciones se homologarán a una sola versión base unificada, que será la `1.0.0`.

Esto **no significa que las especificaciones no puedan modificarse**: las especificaciones **sí pueden cambiar, corregirse y evolucionar** durante el desarrollo del lenguaje cada vez que sea necesario afinar o ajustar su filosofía o sus reglas normativas. Lo que cambia es la disciplina de versionado y registro:

1. **Evolución sin versionado incremental:** Cualquier modificación, corrección o cambio en la filosofía de una especificación se asume directamente como la versión oficial vigente del contrato normativo, sin subir su número de versión.
2. **Prohibición del bloque `"cambio"` durante el desarrollo:** Quedan eliminados y prohibidos los bloques `"cambio": { ... }` (con sus campos de `clase`, `impacto_usuarios`, `impacto_implementaciones`, `justificacion` y `revisado_por`) en los archivos de especificación. Ninguna especificación documenta un historial de cambios intermedios ni citas a fases o autorizaciones transitorias en sus metadatos; el contrato en el cuerpo describe el comportamiento normativo actual.
3. **Reactivación posterior al 100% del lenguaje:** Únicamente después de que se declare que el lenguaje está 100% completo y todas sus especificaciones se homologuen a `1.0.0`, se reactivará formalmente el uso de los bloques `"cambio": { ... }`, momento a partir del cual las especificaciones volverán a registrar cambios formales e incrementos de versión.

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


## 5. Informe de ejecución R0 · 2026-10-14

**Estado: R0 completada, con verificación local y comprobación remota puntual en verde.** Implementación y evidencia local publicadas en
`origin/feature/agregar-ruta-de-especificacion`. R1 no está autorizada ni iniciada.

### Implementación

- Seguimiento con casillas y contrato de cierre, observaciones y push sin coautoría.
- ADR-001 y decisiones de R0 aprobadas; reglas y skills alineadas; núcleo Dart congelado como `reference`.
- Rust 1.99.0 fijado, Clippy y rustfmt instalados, cargo-deny 0.20.2; workspace por crates para reglas,
  fuentes, verificadores, CLI y tooling. Comandos `layers`, `comments`, `names`, `limits`, `unsafe`,
  `attributes`, `all` y comprobación de versiones de cadena.
- Workflow manual para comprobaciones puntuales de todos los miembros y mediciones E-01 en tres
  sistemas operativos; verificación local como flujo habitual.
- Arnés independiente con suma, Fibonacci, burbuja, objetos, Sieve y Permute; seis cargas por modo,
  diez procesos por objetivo y treinta repeticiones. Datos locales: 10.800 muestras únicas,
  30 procesos y 36 grupos. Resultados y entorno en `packages/pseudolearn_benchmarks/results/macos-local/`.
- E-01 remota completa: 32.400 muestras únicas, 90 procesos y 108 grupos entre macOS, Linux y
  Windows. Se validaron procedencia limpia, intervalos, métricas de proceso y paridad de micro-pasos
  en las seis cargas, los dos modos y los tres objetivos. Evidencia en
  `packages/pseudolearn_benchmarks/results/ci-r0-complete/`, incluido su manifiesto de captura.

### Pruebas

| Miembro o suite | Resultado local |
|---|---|
| Núcleo Dart | 772 tests en verde |
| App Flutter | 1.948 tests en verde |
| Marca | 88 tests en verde |
| Backend | 71 tests en verde |
| Frontend, unidad y componentes | 198 tests en verde |
| Frontend, e2e/accesibilidad/visual | 60 tests en verde |
| Verificadores Rust | 39 tests en verde, incluidos casos negativos |
| Arnés E-01 | 23 tests en verde |

### Verificadores

- Núcleo: análisis estricto y `check_limits.dart`, en verde.
- App: análisis estricto, límites, contenido y sistema de diseño, en verde local.
- Marca: comprobación de artefactos y límites, en verde.
- Backend: formato, lint, tipos, arquitectura y tests, en verde.
- Frontend: `check:all` y las tres suites Playwright, en verde.
- Rust: `cargo xtask verify`, en verde; incluye formato, Clippy, tests, los seis verificadores,
  anclaje de versiones y auditoría de avisos/licencias/duplicados/fuentes. Ningún aviso ignorado.
- Arnés: formato, análisis estricto, límites, comentarios y capas, en verde.

### Observaciones y resolución

- La auditoría rechazó `unsafe-libyaml` sin mantenimiento. Se sustituyó su cadena por serde-saphyr 2;
  se conservó la prohibición de avisos ignorados y de versiones duplicadas.
- Las firmas heredadas de traits externos no se pueden renombrar: los nombres impuestos por el
  contrato no son declaraciones propias. Sus bindings y genéricos sí se verifican.
- Se añadieron pruebas para atributos condicionales, declaraciones, aliases y `unsafe` en traits y
  bloques extranjeros para cerrar los huecos detectados durante la revisión.
- Playwright no tenía Chromium instalado; se instaló. Cuatro referencias de inicio y versiones no
  reflejaban el contenido actual: se inspeccionaron, actualizaron y verificaron sin ampliar tolerancia.
- La primera CI ejecutó todos los miembros y verificó Rust, núcleo, marca, backend y web. Flutter
  informó **1.772 tests pasados y 176 goldens fallidos** en macOS 26. El entorno local macOS 27 pasa
  los 1.948. El workflow usa ahora `xcode-27`, con macOS 27.0.1, para conservar comparación exacta;
  la corrección está confirmada por el reintento remoto: suite y verificadores de Flutter en verde,
  sin cambiar los goldens de Flutter.
- E-01 conserva todas las muestras: 13 de los 36 grupos locales tienen candidatos de puntos de
  cambio. No se declara estabilidad demostrada ni se eliminan muestras. RSS es pico muestreado y CPU
  la última lectura acumulada del proceso; los runners compartidos no controlan frecuencia ni carga.
- La recolección local empezó antes de los commits de la implementación y registra `dirty: true`;
  se conserva esa procedencia real. El recolector captura ahora procedencia antes de compilar, y el
  resumen puede recalcularse sobre datos crudos sin cambiar mediciones.

### Pendientes y publicación

No quedan pendientes obligatorios de R0. El protocolo normativo y `PERF.BASELINE.REFERENCE`
pertenecen a R3, después de completar R2 y autorizar R3. Los datos iniciales necesarios están conservados.

El [reintento completo, intento 2](https://github.com/cgutieco/pseudolearn/actions/runs/38519149526/attempts/2)
terminó en verde: nueve jobs, incluidos los tres sistemas de medición. La persona hizo público el
repositorio y autorizó esta comprobación puntual. Los goldens de Flutter pasan en macOS 27 sin cambios
ni tolerancia adicional. La verificación habitual es local; el workflow remoto solo se dispara a mano.

Las ejecuciones anteriores quedaron bloqueadas por facturación; ese bloqueo ya no impidió el
reintento. Se conservan los datos parciales anteriores para no borrar resultados desfavorables.
No se modificó la facturación ni se relajaron verificadores.

El reloj de JavaScript produjo duraciones en múltiplos de 1.000 microsegundos en los tres runners;
una muestra de objetos sin observador en macOS figura como cero, con 2.039 micro-pasos ejecutados.
Se conserva el valor real como duración inferior a la resolución observada, sin atribuir coste cero
al programa ni reemplazarlo por una duración inventada. Los intervalos por grupo siguen siendo
positivos. Esta limitación de precisión acompaña los datos para el protocolo de R3.

| Runner | Muestras únicas | Procesos | Grupos | Grupos con candidatos de cambio |
|---|---:|---:|---:|---:|
| macos-26 | 10.800 | 30 | 36 | 31 |
| ubuntu-24.04 | 10.800 | 30 | 36 | 15 |
| windows-2025 | 10.800 | 30 | 36 | 27 |

Todas las muestras se conservan, incluidas las inestables; no se declara estabilidad demostrada.
La publicación usa push ordinario a `origin/feature/agregar-ruta-de-especificacion`, sin coautoría de
IA. El informe final incluye comprobación manual del commit publicado sin repetir E-01, porque las
fuentes del arnés y del núcleo coinciden con el commit medido. R1 no se inicia.

Se preservan también los artefactos de la CI cancelada en
`packages/pseudolearn_benchmarks/results/ci-initial-cancelled/`, con un manifiesto de captura.
macOS conserva los tres objetivos completos; Linux y Windows son parciales. El conjunto no
completa la matriz de E-01:

| Runner | Muestras | Procesos | Completo |
|---|---:|---:|---|
| macos-26 | 10800 | 30 | Sí |
| ubuntu-24.04 | 6480 | 18 | No |
| windows-2025 | 3960 | 11 | No |


## 6. Informe de ejecución R1 · 2026-10-14

**Estado: R1 completada, con verificaciones locales en verde e implementación publicada.**
La rama es `origin/codex/implement-r1`; R2 requiere un mensaje nuevo y aprobación de E-15.

### Implementación

- `packages/pseudolearn_spec`: workspace de once capas de producto y xtask; Rust exacto y reglas
  compartidas sin excepciones. Esquema JSON `see/1`, lector Markdown/YAML, escritura canónica,
  referencias, ciclo de vida, versión, clasificación declarada, grafo e impacto transitivo.
- CLI: `new`, `validate`, `graph`, `lock`, `diff`, `impact`, `conform`, `matrix`, `export` y `feature`.
  Lock conserva historia y SHA-256 normativo; diff consulta revisiones Git sin modificar el checkout;
  los artefactos generados tienen comprobación de vigencia.
- Corpus: los tres contratos de arranque `SEE.FORMAT`, `SEE.IDENTITY` y `SEE.LIFECYCLE` en borrador,
  revisados estructuralmente a mano contra el plan. No se atribuye revisión humana independiente ni
  estabilidad. Los otros doce contratos SEE están en experimental, con vínculos a sus pruebas.
- Adaptador Dart en `tool/`, con responsabilidades separadas y uso exclusivo de API pública.
  Negocia `analyze` y `execute`, serializa diagnósticos completos y presencia real del árbol,
  recibe entradas/semilla y limita micro-pasos. Las peticiones inválidas son respuestas JSON;
  el ejecutor trata EOF, JSON inválido, versión incompatible y bloqueo como errores operativos.
- Piloto: tres especificaciones experimentales, diez reglas y veintidós casos. Programas explícitos
  en ambos perfiles; los rigores se declaran por caso. Vocabulario independiente de piloto,
  traducción que preserva literales/comentarios y marcadores de salida comprobados.
- README raíz y del núcleo actualizados; workflow de comprobación manual preparado para instalar
  Dart antes de verificar todos los miembros Rust. No se escribe motor Rust ni se modifica `lib/`
  del sujeto congelado.

### Pruebas

| Comando o suite | Resultado |
|---|---|
| `cargo xtask verify` en `pseudolearn_spec` | Verde, 40 tests Rust |
| `dart test --reporter expanded` en el núcleo | 778 tests, incluidos los seis nuevos del adaptador y compilación JS/Wasm |
| `dart analyze --fatal-infos --fatal-warnings` en el núcleo | Sin incidencias |
| `dart run tool/check_limits.dart` en el núcleo | Verde |
| `see conform --subject reference` | 82 observaciones, 72 cumplen y 10 divergen con exención justificada |

Las pruebas Rust incluyen programas vacíos, esquemas incompletos, Unicode, literales y comentarios,
identificadores con prefijos/sufijos parecidos a palabras reservadas, grafos profundos sin recursión,
bordes enteros, salida exacta, multiplicidad de diagnósticos, tramos, EOF y timeout. La CLI tiene
pruebas de creación sin sobrescritura, artefactos desactualizados y diff desde un miembro anidado
en un repositorio Git. Los casos del corpus no se duplican como tests del motor Dart.

### Verificadores

| Puerta | Evidencia |
|---|---|
| Formato Rust y Clippy estricto | Verdes, sin atributos de excepción |
| `rust-checks layers` | Capas, miembros y dependencias declarados |
| `rust-checks comments` | Sin comentarios de código |
| `rust-checks names` | Nombres conformes |
| `rust-checks limits` | Todos los límites en verde |
| `rust-checks unsafe` | Ningún crate autorizado ni uso de unsafe |
| `rust-checks attributes` | Sin doc, allow ni expect |
| `rust-checks toolchain` | Versiones exactas de los miembros coherentes |
| `cargo deny check` | Avisos, prohibiciones, licencias y fuentes en verde; sin avisos ignorados |
| `see validate` | 18 especificaciones válidas |
| `see lock --check` | Anclaje generado vigente |
| `see export --check` | Exportación generada vigente |
| Regresión de conformidad | Ningún vínculo cumple exigible falla |

Cada uno de los seis rechazos obligatorios tiene fixture y comprobación del ID del error:
`duplicate` → `SEE-DUPLICATE`, `orphan` → `SEE-ORPHAN`, `captured` → `SEE-CAPTURE`,
`hash` → `SEE-HASH`, `cycle` → `SEE-CYCLE`, `missing-profile` → `SEE-PROFILE`.
Además se comprueban referencias inexistentes, rangos incompatibles, campos desconocidos y fuerza
normativa inválida. Los fixtures quedan fuera del recorrido ordinario del corpus.

### Observaciones y resolución

- La comparación genérica detecta **H-37**: cuatro observaciones sin la advertencia de modificación
  del control; **H-06**: dos observaciones con `expectedExpression` duplicado; **H-05**: cuatro
  observaciones con árbol nulo para texto vacío. `conformance.yaml` los declara exentos con hallazgo
  y resolución en R4. La matriz conserva `incumple` medido junto a `exento`; no oculta el defecto.
- E-15 no se presenta como experimento ciego: los ejemplos del plan describían esos hallazgos antes
  de la autoría. El ejecutor carece de ramas especiales para encontrarlos. Su detección deriva de
  expectativas independientes y comparación ordinaria de observables.
- La primera ejecución mezclaba rango de valores con aceptación del literal del extremo negativo.
  Se conservaron sus resultados en `results/first-reference.json` y se reformularon tres casos con
  `-9223372036854775807 - 1`, aislando la aritmética del reconocimiento léxico. No se cambió el sujeto
  ni se adaptó el resultado esperado a una captura. Un caso de recuperación observa solo el árbol;
  la unicidad de diagnósticos pertenece a otra regla.
- El formato permite observar árboles y programas explícitos por perfil, además de diagnósticos,
  salida y terminación. Esto evita que la representación del adaptador borre H-05 o que la longitud
  de un lexema obligue a inventar tramos idénticos entre perfiles.
- E-15 registra **2,003 minutos brutos por regla** de autoría automatizada: ventana UTC de 09:24:36
  a 09:44:37,880638 (Lima), diez reglas. Incluye pausas de implementación y verificación; es una cota
  bruta del coste automatizado, no tiempo humano aislado. La procedencia y fórmula están en
  `packages/pseudolearn_spec/results/e15.json`. La viabilidad de autoría humana no se infiere de ese dato.
- El clasificador distingue editorial, cambio de esperado y retirada en pruebas controladas; los
  cambios de texto se remiten a revisión. No se mide ni afirma una tasa estadística de falsos positivos.
- Las pruebas encontraron traducción parcial de un identificador; se corrige consumiendo tokens
  completos. La auditoría rechazó dependencias internas sin versión; se fijan sin relajar políticas.
  El análisis Dart encontró tres avisos de llaves; se corrigen y se repite la verificación completa.

### Pendientes y publicación

No quedan tareas obligatorias de implementación de R1. La generación y reducción de propiedades N3
corresponden a la segunda iteración del sistema al incorporar propiedades en R2/R3; el vocabulario
completo se migra en R2; sujetos Rust y observación del motor pertenecen a sus fases autorizadas.
No hay aprobación de E-15 para empezar R2 ni se inicia esa fase.

La implementación está publicada en `origin/codex/implement-r1`, commit
`2edd2aecfab3758757844c85ba5f1b29937357dd`. `git ls-remote` confirmó ese mismo HEAD remoto después de
un push ordinario. Este informe y las casillas de cierre se publican en la misma rama; la igualdad
local/remoto se comprueba de nuevo al terminar. No hay force push ni trailers de coautoría.

No se ejecuta GitHub Actions: R1 exige verificación local y no pide comprobación remota obligatoria.
El workflow permanece manual. La primera revisión automática del push rechazó el destino por no
verificado; la consulta de solo lectura confirmó el repositorio público y permisos ADMIN, y el
reintento fue aprobado y terminó correctamente.

## 7. Informe de ejecución R2 · 2026-10-14

**Estado: R2 completada, con verificaciones locales en verde y publicación autorizada y confirmada.**

### Implementación

- Regla `DOC-NO-TRANSIENT-REFS` documentada antes de implementar: archivos externos no citan documentos o secciones de la investigación transitoria de la raíz. Enlaces internos y documentación de paquetes conservan su ámbito. Puerta local con rechazos deliberados de enlaces, rutas, citas y README raíz.
- Corpus de R2: 85 contratos LANG/DIAG/LIB experimentales, 98 reglas y 265 casos derivados, incluido el piloto ampliado. La gramática abstracta se escribe después de las construcciones; sus referencias, delimitadores y alcanzabilidad se verifican.
- Fuente normativa bilingüe de 73 tokens, 18 funciones y 160 fichas de diagnóstico. Los recursos consumidores, incluidos alias, se generan desde el corpus y se comprueba su vigencia. No hay copias manuales.
- Correspondencia mecánica de las 71 secciones originales hacia contratos existentes. La especificación antigua es un índice y conserva su proyección educativa, verificada por Flutter.
- Palabras reservadas y alfabeto vigentes conservados; NFC en nombres y reconocimiento léxico, sin modificar contenido de literales ni posiciones originales. Identificadores de contratos en inglés ASCII y documentación normativa en español.
- SEE admite objetos normativos de definición, semilla explícita con signo de 64 bits y comparación ordenada de diagnósticos. El protocolo conserva see/1 y see-protocol/1. Los cambios de contratos existentes tienen versión y clasificación de impacto; el lock conserva historia.
- Adaptador reference corregido mediante API pública: transmite una vez el resultado de tipos que incluye resolución, sin deduplicar diagnósticos reales; conserva advertencias de entrada mediante observador. Ningún archivo de lib/ Dart ni motor Rust modificado o creado.

### Pruebas

| Suite o comando | Resultado |
|---|---|
| cargo xtask verify de pseudolearn_spec | Verde; 54 tests Rust |
| cargo xtask verify de pseudolearn_rust_checks | Verde; 39 tests Rust |
| dart test del núcleo | Verde; 782 tests, incluidos objetivos JS/Wasm y 10 del adaptador |
| flutter test de la app | Verde; 1.948 tests, incluida cobertura educativa |
| see conform --subject reference | 1.016 observaciones: 930 cumplen, 86 divergen con exención específica |

### Verificadores

- Rustfmt, Clippy estricto, capas, comentarios, nombres, límites, unsafe, atributos y versión exacta de cadena en verde. Auditoría de avisos, licencias, duplicados y fuentes en verde, sin excepciones.
- see validate: 100 contratos válidos; todos los contratos R2 experimentales. Lock y exportación vigentes, incluidos catálogos y vocabulario derivados. Matriz sin reglas sin vínculo ni regresiones exigibles.
- DOC-NO-TRANSIENT-REFS en verde. Casos negativos de lexemas, firmas, marcadores, tipos de argumentos, severidad, gramática y correspondencia documental en verde.
- Núcleo Dart: análisis estricto y límites en verde. App Flutter: análisis estricto, límites, contenido y sistema de diseño en verde.

### Observaciones y resolución

- El primer contraste contenía un error de autoría: el alias español Algoritmo no se tradujo en los programas ingleses. Se corrigieron programas a partir del vocabulario oficial, conservando resultados iniciales en results/r2-first-reference.json; no se cambiaron esperados para copiar salidas del sujeto. Otros casos se aislaron según higiene, rigor y severidad definidos por reglas.
- La inspección confirmó que el resultado de tipos contiene diagnósticos de resolución; concatenar ambas listas duplicaba evidencia. La corrección del adaptador no elimina duplicados emitidos por el parser y conserva el hallazgo de recuperación.
- Las 86 divergencias se clasifican en 23 reglas exentas y 14 hallazgos permanentes, documentados en el README de SEE y results/r2-findings.json. Incluyen recuperación y cierre de bloques, BOM/NFC, carácter suplementario contado como UTF-16, chequeo estático de miembros y contexto de objetos, inicialización flexible, inferencia estricta y cascadas sobre símbolos inválidos. La matriz conserva incumplimiento medido, casos y motivo; el motor Rust R4 resolverá las obligaciones sin modificar reference.
- E-10 mide candidatos de declaraciones y controles contados en 172 ejemplos locales. Se registra procedencia, presupuesto por perfil y ausencia de colisiones en esa muestra editorial; no se infiere representatividad humana ni conveniencia de cambiar Y/O. Se reproduce con see budget.
- E-14 no atribuye precisión ni tiempos humanos a comprobaciones técnicas. Su estudio de construcciones nuevas requiere la evolución posterior a R9, formas aprobadas, participantes y tareas disponibles. Método, motivo y condición están en results/e14.json.

### Pendientes y publicación

No quedan tareas obligatorias de implementación o verificación local de R2. El estudio humano E-14 se difiere según autorización explícita, y los defectos del sujeto congelado se resuelven en R4; ambas cosas mantienen evidencia y condición de resolución. Las propiedades generativas se incorporan al sistema cuando un contrato las requiera, sin declarar ninguna propiedad no ejecutada como cumplida.

Rama codex/implement-r2. La publicación usa push ordinario, sin coautoría ni atribución de IA. No se ejecuta GitHub Actions: R2 no requiere comprobación remota obligatoria y los workflows son manuales. R3 no se inicia.

La implementación está en el commit 9506885; el informe de verificación local se publicó en e7dc881c83441eb426d212e08ae54aaa33b59c70. La persona autorizó explícitamente publicar el contenido de R2 en su repositorio público. El push ordinario a origin/codex/implement-r2 terminó correctamente y git ls-remote confirmó ese mismo HEAD remoto. El cierre documental se publica en la misma rama y la igualdad de HEAD se comprueba después del push final.

Los dos rechazos automáticos anteriores quedan resueltos por la verificación del destino y la autorización explícita; no se evitó ningún rechazo ni se utilizó force push. No quedan pendientes obligatorios de R2. R3 requiere un mensaje nuevo de autorización.

## 8. Rama única de continuidad

R1 y R2 se integran por fast-forward en feature/agregar-ruta-de-especificacion, conservando todos sus commits. La rama base es la única rama de trabajo y publicación para los cambios posteriores. La implementación y las verificaciones de R2 permanecen vigentes; no se modifica el código ni el corpus al integrar. La igualdad de HEAD local/remoto se comprueba después de publicar esta integración. R3 no se inicia.

## 9. Informe de ejecución R3 · 2026-10-14

**Implementación.** R3 completa sus bloques B0–B8. El corpus incorpora 39 especificaciones de motor,
memoria, RI, API, anfitrión, herramientas y rendimiento, con 130 reglas finales, 172 casos,
30 propiedades, 15 mediciones, 74 instrucciones y 87 entradas de cobertura regla → instrucciones.
`PERF.BASELINE.REFERENCE` 0.2.0 publica la suite AWFY-core además de E-01; la clasificación, impacto,
lock y exportación quedan vigentes. `see` soporta trace, ir, cli, mediciones, instrucciones,
cobertura, cancelación, presupuesto y negociación observe, con rechazos negativos por ID.
El adaptador reference observa la API pública; el núcleo Dart permanece congelado.

El experimento Rust ceiling implementa los diez algoritmos en V0–V3 y valida sus 80 combinaciones
(dos tamaños por cuatro variantes). El arnés Dart consume programas y controles de la exportación,
sin copiarlos. La arquitectura Clepsidra, las quince capas de R4–R5 y la CLI tienen README
autosustentables. Las reglas declarativas comprueban README y carpetas, dependencias y ausencia de
fuentes prematuras. Se declaran las dependencias de generación de catálogos sin rowan ni salsa.
No hay Cargo.toml ni fuentes Rust en el motor o en la CLI.

**Pruebas.** 950 tests en verde: pseudolearn_spec 80; pseudolearn_rust_checks 41; ceiling 14;
pseudolearn_core 789; pseudolearn_benchmarks 26. Las salidas reales y sus hashes están en
`packages/pseudolearn_spec/results/r3-verification.json`. Frente a B0, los 930 casos que cumplían
siguen cumpliendo: 1.156 observaciones actuales, 1.034 cumple y 122 divergencias conservadas y
clasificadas; cero regresiones exigibles. La comparación por identidad completa se guarda en
`results/r3-regressions.json` del miembro SEE.

AWFY reference conserva 6.000 muestras (diez procesos, treinta iteraciones, diez programas, dos modos)
en `packages/pseudolearn_benchmarks/results/macos-r3-awfy/`, con captura previa a compilación,
hashes de fuentes, métricas de proceso y bootstrap del 95 %. E-02 conserva 12.000 muestras finales
en `results/e02/` del mismo miembro; todas las muestras V3 tienen al menos un punto de control.
El reloj de E-02 observa un mínimo de 41 ns. Los candidatos de cambio, la carga externa y la
precisión limitada forman parte de los informes; no se afirma estacionariedad ni rendimiento de VM.

**Verificadores.**

| Puerta | Resultado |
|---|---|
| cargo fmt --all --check | Verde en los tres miembros Rust ejecutables |
| Clippy estricto | Verde en los tres miembros Rust ejecutables |
| cargo test --workspace | Verde: 80 + 41 + 14 tests |
| rust-checks comments, names, limits, layers, unsafe y attributes | Todos verdes, con sus casos negativos |
| rust-checks toolchain | Anclajes exactos coincidentes |
| rust-checks layers del motor declarativo | Quince carpetas documentadas; sin fuentes o manifiestos |
| cargo deny check | Advisories, bans, licenses y sources verdes; dos avisos de permisos de licencia sin uso en ceiling |
| see validate | 139 especificaciones válidas |
| see lock --check y see export --check | Vigentes |
| see matrix | Sin huecos de cobertura de RI; evidencia r3-matrix.json |
| see conform --subject reference | Sin regresiones exigibles; exenciones y resultados crudos conservados |
| dart analyze y verificadores de límites/capas | Verdes en núcleo y arnés |
| DOC-NO-TRANSIENT-REFS | Verde, incluidos sus casos negativos y las evidencias finales |

Flutter no necesita una comprobación adicional: no cambia código ni recurso consumido por la app.
La comprobación de conformidad tiene 124 especificaciones del alcance de la reescritura en
experimental; los tres borradores SEE de arranque no pertenecen a ese alcance. Queda acreditado
el hito «núcleo especificado», sin iniciar código del motor.

**Observaciones resueltas.** La primera captura E-02 no tomaba puntos de control en Storage y Towers.
Se conserva íntegra en `results/e02/initial/`; la corrección consulta el reloj en llamadas y exige
un punto real por muestra V3, con test de regresión. Las capturas no se mezclan. Las trampas diferidas
preservan el primer fallo e impiden efectos posteriores; las lecturas potencialmente fallidas respetan
ese fallo previo. La barrera de época conserva las páginas compartidas inmutables y los puntos guardan
la región activa de ambos bancos. Todas las salidas se contrastan con el corpus, no se capturan de
una variante para convertirlas en esperado.

Se conservan las decisiones observables: Escribir es atómico si una expresión falla
(ENG.EXEC.EFFECT-ORDER#R2), el fallo de operador señala su símbolo (IR.SOURCE-MAP) e int.mod del
mínimo entre −1 devuelve cero por la identidad de LANG.OPS.DIVISION. Los hallazgos reference de
fragmentación de salida, petición de entrada, Segun sin rama y Retornar quedan exentos con
resolución en R5. La autoría B1–B2 conserva su ventana original; la publicación de la línea base
se declara aparte y no infiere tiempo humano.

**Decisiones y pendientes justificados.** Las hipótesis de rendimiento permanecen provisionales.
La representación V2 supera el umbral de revisión 1,30 en todas las familias:

| Familia | V2/V1 | IC 95 % |
|---|---|---|
| arrays | 4.0548 | [3.2911, 5.5906] |
| numeric | 2.0575 | [1.9962, 2.1611] |
| objects | 3.6046 | [3.4272, 3.7087] |
| recursive | 2.5893 | [2.5514, 2.6174] |

RC-01 exige revisar la representación de memoria **antes de autorizar R5**, según el criterio
aprobado de E-02. La hipótesis V3/V2 ≤ 1,10 tampoco queda confirmada de forma general: objetos y
recursión la superan. R3 publica el resultado desfavorable y conserva el diseño; no lo ajusta para
mejorar los números. Las alternativas se miden en esa revisión previa. Las prestaciones de VM,
recolección completa, Unicode y front-end se verifican en sus fases; E-02 no las demuestra.
No queda una tarea obligatoria abierta de R3. Los pendientes de implementación pertenecen a R4–R8,
con sus dependencias y condiciones en el README del motor; los hallazgos reference mantienen sus
resoluciones declaradas en R4 o R5.

**Publicación.** Rama `feature/agregar-ruta-de-especificacion`. La implementación y evidencia se
publican mediante push ordinario en `2df395d1682d1c2f73078f9495d2af8e29c2919a`; `git ls-remote` confirma igualdad
con HEAD local. El informe y las casillas se publican en el commit posterior
`docs(docs): close R3 with verified execution evidence`, seguido de una segunda comprobación de
igualdad local/remoto. No se solicita ni ejecuta un workflow remoto manual: este cierre exige las
verificaciones locales. No hay force push, ramas adicionales ni trailers de coautoría.

**Parada.** R3 cerrada. R4 conserva sus casillas pendientes y necesita un mensaje nuevo de autorización.
