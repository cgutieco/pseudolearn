# Plan de ejecución de PseudoLearn hacia un lenguaje de propósito general

## Decisiones posteriores de la persona · 2026-10-22–2026-10-24

Este registro actualiza las recomendaciones y puertas previas que lo contradigan; las opciones anteriores
se conservan como rastro de análisis, no como instrucciones vigentes.

- ADR-05, CF-03 y PG-0.06: se mantiene exclusivamente la edición 2026 antes de la primera publicación.
  Se permiten cambios necesarios documentados, incluso incompatibles; no se crea una edición GP.
- CF-02 y CF-19: contratos nuevos en estable 1.0.0, sin campo `cambio`; correcciones oficiales sobre
  la misma identidad y versión. Congelamiento hasta reapertura explícita. Los contratos existentes
  se auditan antes de cambiar estados; CF-12 no se corrige automáticamente.
- PG-0 admite una excepción acotada de implementación para SEE, contratos de proceso, tests y README
  necesarios para aplicar esta política; no autoriza cambios de semántica ni del motor.
- PG-0.05 queda diferido por autorización expresa a PG-7.07. Se mantienen derechos reservados;
  elegir y verificar licencia abierta es obligatorio antes del cierre final o publicación.
- Las pruebas con dispositivos físicos y los estudios con participantes de E-PG-08/10/12 son
  complementarios y no bloquean cierres. Se registrará su ausencia sin afirmar cobertura física
  ni eficacia pedagógica. Las comprobaciones automatizables de calidad y rendimiento siguen obligatorias.
- El 2026-10-24 la persona fijó el alcance de verificación por fase: ejecutar las pruebas de corpus,
  espejo y consumidor que prueban el comportamiento modificado, no todas las suites del miembro por
  defecto. Ampliar la campaña solo cuando el cambio cruce esas fronteras, una prueba dirigida falle o
  la evidencia disponible no cubra el riesgo; registrar la selección y lo omitido sin presentar una
  suite parcial como suite completa. Las especificaciones nuevas se escriben directamente en estado
  `estable` `1.0.0`; una vez fijados texto normativo y casos derivados se implementan contra esa regla,
  sin una fase intermedia de promoción de estado.
- D-xx y TS-3 sin origen verificable se reconstruyen como propuestas nuevas; no se presume aprobación histórica.
- Se permiten referencias internas entre documentos de docs/; ningún archivo externo dependerá de ellos.
- El 2026-10-30 la persona confirmó para PG-6A que cada cambio es la versión oficial aunque sea
  incompatible. Se conserva el retiro de migradores y retrocompatibilidad decidido en PG-2;
  la extensión no añade el comando migrar que figuraba en la propuesta inicial.

- El 2026-11-02 la persona decidió que el lenguaje no viene bloqueado ni simulado en ninguna plataforma: autoridad
  plena por omisión sin concesiones, anfitriones reales en CLI, extensión y app, cero simulación en producto y eliminación
  de raíz de lo que quede muerto. Aceptó D-01–D-19 del [análisis del 2026-11-02](analisis-lenguaje-completo-sin-simulacion.md). Sustituye, sin desmarcar casillas, a PG-3.03 («denegación
  por defecto»), PG-5.04 (política SSRF), PG-5.07 en lo relativo a concesiones, PG-6B.05 (capacidades web explícitas) y
  PG-B.04 (efectos simulados, retirado). Reformula PG-B y PG-7 y añade PG-L, PG-S y PG-N; el compilador nativo completo
  se implementa en su propia fase. Lo que un lenguaje de propósito general necesita y hoy falta o está a medias entra en
  fases; no se publica nada que se sienta como prueba de concepto.

El detalle operativo está en [el plan de PG-0](fase-pg-0-plan-ejecucion.md).
La petición directa de implementar PG-0 revisó y autorizó el plan. PG-0 quedó cerrada el 2026-10-22 con
verificaciones en verde, tras autorizar la persona el reanclaje de seis identidades y la ejecución fuera del
sandbox de las campañas de app y rendimiento. La autorización del 2026-10-22 cubrió `PG-H.04`; la del 2026-10-23 cubre `PG-H.05` a `PG-H.12` y el cierre
común en una iteración. PG-H quedó cerrada el 2026-10-23 por decisión de la persona. El mensaje del
2026-10-23 «Implementa en una iteración `PG-1.01 · Identidad de fuente de extremo a extremo`» autoriza
ese punto de PG-1, sin iniciar ni cerrar la fase completa; los puntos `.02` en adelante requieren
autorización explícita propia. Los mensajes del 2026-10-23 y 2026-10-24 autorizaron en iteraciones
separadas PG-1.02–PG-1.13, con cierre limitado a los puntos pedidos; no autorizan el cierre común C01–C13.


Documento transitorio de la carpeta documental de la raíz. Convierte las fases de la
[hoja de ruta](../hoja-de-ruta-proposito-general.md) en listas de puntos verificables. Es autosustentable dentro de
`docs/`: ningún código, corpus, README ni archivo fuera de `docs/` puede citarlo, ni a él ni a los planes de fase que se
creen a su lado (`DOC-NO-TRANSIENT-REFS`).

## 1. Qué contiene y qué no

- **Contiene**, por fase, los puntos generales que deben cumplirse para darla por completada: el *qué*.
- **No contiene** la forma de implementarlos: el *cómo*. Cada fase tendrá su propio plan detallado,
  `fase-<id>-plan-ejecucion.md`, en esta misma carpeta. El plan de PG-0 existe y su fase está cerrada.
- **No autoriza** ninguna fase. Cada una empieza solo con una autorización explícita de la persona en un mensaje nuevo
  (`PHASE-STOP`), y su cierre exige `PHASE-GREEN`.
- **No sustituye** al corpus (comportamiento observable) ni a los README de paquete (arquitectura y por qué). Lo que una
  fase decida se traslada a esos dueños en el mismo cambio, sin citar este plan.

Identificadores: los de la hoja de ruta (ENT-1, PG-x, C-xx, CF-xx, R-xx, K-xx, E-PG-xx, ADR-xx, FUT-xx) se usan con el
mismo significado. Cada punto de este plan tiene un ID estable `<fase>.<nn>` (por ejemplo `PG-1.04`) que el plan detallado
y el resumen usan para referirse a él. Un ID nunca se reutiliza: si un punto se retira, se marca como retirado en el
resumen con su motivo y se conserva.

## 2. Cómo se marca el avance

### 2.1 Casillas

- `- [ ]` pendiente, o no cumplido.
- `- [x]` cumplido **y** con evidencia registrada en el resumen de la fase.

Solo hay dos estados de casilla. Los matices (no cumplido, diferido, no aplica, retirado) se escriben en la tabla de
resumen, nunca cambiando la casilla a `[x]`. Una casilla no se marca por haber escrito código: se marca cuando la
evidencia que exige el punto existe y es reproducible.

### 2.2 Estados del resumen

| Estado | Significado | Requisito para usarlo |
|---|---|---|
| Cumplido | El punto se satisface | Evidencia concreta: comando y resultado, ruta, ID de caso o regla, hash, commit |
| No cumplido | Se intentó y no se satisface | Motivo técnico, dato observado y consecuencia para la fase |
| Diferido | Se pospone a otra fase o a una decisión | Aprobación explícita de la persona, con su mensaje citado, y fase o condición de destino |
| No aplica | El punto no corresponde | Justificación verificable; nunca para ocultar trabajo que sí debía hacerse |
| Retirado | El punto deja de existir | Decisión de la persona y motivo; el ID se conserva |

Una fase está **completada** solo si todos sus puntos están en *Cumplido*, o en *Diferido*/*No aplica*/*Retirado* con
la aprobación correspondiente, y todos los puntos de cierre común están en *Cumplido*. Un solo *No cumplido* deja la fase
abierta.

### 2.3 Quién marca

La IA a cargo de la fase marca casillas y redacta el resumen. No puede marcar como cumplidos los puntos que dependen de
la persona (decisiones, autorizaciones, dispositivos físicos, participantes humanos, cuentas o publicación): los deja
pendientes con la nota «requiere a la persona» hasta que esta aporte la decisión o la evidencia. Si al ejecutar
aparece un conflicto entre fuentes, se reporta (`CONFLICT-REPORT`) y se espera; no se resuelve en silencio.

## 3. Orden de las fases

Una fase puede iniciarse cuando todas sus dependencias están completadas y la persona lo autoriza. El DAG muestra qué
fases son técnicamente independientes, pero no autoriza ejecutarlas en paralelo.

| Fase | Nombre | Depende de | Plan detallado previsto |
|---|---|---|---|
| PG-0 | Decisiones y línea base | — | `fase-pg-0-plan-ejecucion.md` |
| PG-H | Catálogo y ayuda temprana | PG-0 | `fase-pg-h-plan-ejecucion.md` |
| PG-1 | Identidad y proyectos | PG-0 | `fase-pg-1-plan-ejecucion.md` |
| PG-2 | Tipos y abstracción | PG-1 | `fase-pg-2-plan-ejecucion.md` |
| PG-3 | Capacidades y cinta | PG-1 | `fase-pg-3-plan-ejecucion.md` |
| PG-4 | Tareas aisladas | PG-2, PG-3 | `fase-pg-4-plan-ejecucion.md` |
| PG-5 | Biblioteca y HTTP | PG-2, PG-3, PG-4 | `fase-pg-5-plan-ejecucion.md` |
| PG-6A | Servicio y extensión inicial | PG-1, PG-2, PG-H | `fase-pg-6a-plan-ejecucion.md` |
| PG-6B | Depuración y web | PG-4, PG-5, PG-6A | `fase-pg-6b-plan-ejecucion.md` |
| PG-A | App y sintaxis estática | PG-1, PG-2, PG-H | `fase-pg-a-plan-ejecucion.md` |
| PG-B | Lenguaje completo con anfitriones reales y app con tareas observables | PG-A, PG-3, PG-4, PG-5, PG-6B | `fase-pg-b-plan-ejecucion.md` |
| PG-L | Lenguaje sin restricciones de construcción | PG-B (bloque de corpus) | `fase-pg-l-plan-ejecucion.md` |
| PG-S | Biblioteca estándar de producción | PG-B, PG-L | `fase-pg-s-plan-ejecucion.md` |
| PG-N | Compilador nativo completo | PG-B, PG-L, PG-S | `fase-pg-n-plan-ejecucion.md` |
| PG-7 | Erradicación, calificación y distribución del lenguaje completo | PG-B, PG-L, PG-S, PG-N | `fase-pg-7-plan-ejecucion.md` |

ENT-1 se considera entregado únicamente cuando PG-7 está completada. Las secciones §4.13–§4.15 (PG-L, PG-S, PG-N) se
numeran después de PG-7 para no renumerar referencias existentes; el orden de ejecución es el de esta tabla.

## 4. Fases y puntos de cierre

### 4.0 Cierre común a todas las fases

Cada fase repite estos puntos como casillas propias `<fase>.Cnn`, que se marcan fase por fase; aquí solo se definen.

- `C01` Autorización explícita de la persona para iniciar la fase, en un mensaje nuevo, registrada en el resumen.
- `C02` Plan detallado `fase-<id>-plan-ejecucion.md` creado según §5, revisado por la persona antes de escribir código.
- `C03` Orden `SPEC-FIRST` respetado en cada punto: especificación estable `1.0.0` → casos derivados → tests → código,
  sin etapa previa de promoción de estado, sin esperados capturados del motor (`SPEC-INDEPENDENT-ORACLE`) y respetando
  el congelamiento (`SPEC-VERSION-FREEZE`, decisión de CF-19).
- `C04` Cada regla nueva tiene casos o propiedades (`SPEC-NO-ORPHAN-RULE`) y sus vínculos viven en archivos de
  conformidad (`SPEC-BINDING-AS-DATA`).
- `C05` Pruebas dirigidas de camino feliz, infeliz y límites para cada pieza modificada, en carpetas espejo
  (`TEST-BOTH-PATHS`, `TEST-MIRROR`); no exige ejecutar todas las suites del miembro.
- `C06` Capas nuevas declaradas en el archivo de reglas antes de su código; ningún import fuera de la matriz
  (`LAYER-DECLARED`, `LAYER-DIRECTION`) y límites `SIZE-*` respetados.
- `C07` Cero comentarios y cero `TODO` en código; código e identificadores en inglés; documentos en español
  (`QUALITY-NO-COMMENTS`, `LANG-EN-CODE`, `LANG-ES-DOCS`); en Rust, sin pánicos ni `unsafe` fuera de lo declarado.
- `C08` README de cada miembro afectado y su archivo de reglas actualizados en el mismo cambio, autosuficientes y sin
  citar `docs/` (`DOC-README-TRUTH`, `DOC-NO-TRANSIENT-REFS`, `DOC-NO-ORPHAN-DECISION`).
- `C09` Fichas de ayuda y datos de proyección para app de toda construcción nueva de la fase, o justificación de que la
  fase no añade sintaxis (C-16, R-19).
- `C10` Riesgos K-xx asociados revisados con su señal temprana, y experimentos E-PG-xx asociados ejecutados con
  procedencia (plataforma, hashes, semilla, muestras crudas) o diferidos por la persona.
- `C11` Pruebas necesarias para demostrar el comportamiento modificado y verificadores directamente afectados en verde,
  con selección, salida y suites omitidas registradas (`PHASE-GREEN`).
- `C12` Commit con el formato de la skill `commit-message`, sin atribución de autoría de IA, en
  `feature/agregar-ruta-de-especificacion`, y push ordinario comprobado (`GIT-SINGLE-BRANCH`).
- `C13` Resumen de la fase completo, informe a la persona y parada hasta nueva autorización (`PHASE-STOP`).

### 4.1 PG-0 · Decisiones y línea base

Objetivo: fijar las decisiones que bloquean al resto y medir el estado real antes de cambiar nada. Requisitos R-04, R-12,
R-18; riesgos K-01, K-02, K-12; conflictos CF-01–CF-20.

Puntos a cumplir:

- [x] `PG-0.01` CF-19 decidido: contratos nuevos estables 1.0.0, sin campo `cambio` ni revisión atribuida;
  la revisión independiente es requisito de validación. Congelamiento de los existentes intacto.
- [x] `PG-0.02` Cada conflicto CF-01–CF-18 tiene registrado su tratamiento concreto y si queda resuelto, pendiente o
  diferido a una fase nombrada.
- [x] `PG-0.03` CF-12 (`estado_agregado` del manifiesto de características) clasificado, sin cambiar estados sin
  autorización.
- [x] `PG-0.04` Procedencia de las decisiones D-xx resuelta: la persona aporta el origen, o quedan registradas como
  propuestas nuevas (CF-04).
- [x] `PG-0.05` Diferimiento autorizado a PG-7.07; se conservan derechos reservados hasta elegir y auditar una licencia.
- [x] `PG-0.06` Se conserva como única edición la de 2026 antes de la primera publicación; no se crea una edición GP.
  Se admiten cambios necesarios, incluso incompatibles, documentando su impacto y preservando su esencia.
- [x] `PG-0.07` Línea base de conformidad actual de los sujetos engine, aot, service, cli y app, con procedencia completa
  (fuentes, binario, configuración, plataforma).
- [x] `PG-0.08` Línea base de rendimiento de `PERF.AOT.LEVEL` y `PERF.ARTIFACT.SIZE` según `PERF.PROTOCOL` en una
  plataforma identificada, resolviendo CF-06.
- [x] `PG-0.09` Discrepancias actuales clasificadas como incumplimiento aplicable, deuda, retirado o exento, sin alterar
  esperados para obtener verde (CF-05).
- [x] `PG-0.10` Catálogo candidato de clases de capacidad del host y política de oráculos independientes, definidos como
  insumo de PG-3.
- [x] `PG-0.11` Controles, máquinas, dispositivos físicos y necesidad de participantes de E-PG-01–E-PG-12 fijados, y
  marcados los que dependen de la persona.
- [x] `PG-0.12` Matriz de trazabilidad punto base → R-xx → C-xx → fase → paquete sin huecos, y camino crítico
  recalculado.

Fuera de alcance: cualquier cambio de sintaxis, semántica o implementación.

Plan detallado: `fase-pg-0-plan-ejecucion.md`, revisado, ejecutado y cerrado el 2026-10-22.

Cierre común (definiciones en §4.0):

- [x] `PG-0.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [x] `PG-0.C02` Plan detallado creado según §5 y revisado por la petición directa de implementación.
- [x] `PG-0.C03` SPEC-FIRST y congelamiento respetados.
- [x] `PG-0.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [x] `PG-0.C05` Tests feliz, infeliz y límite en carpetas espejo.
- [x] `PG-0.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [x] `PG-0.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [x] `PG-0.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [x] `PG-0.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [x] `PG-0.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [x] `PG-0.C11` Tests y verificadores de los miembros afectados en verde.
- [x] `PG-0.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [x] `PG-0.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-0

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| PG-0.01 CF-19 | Cumplido | SEE.LIFECYCLE/GENERATION/VERSIONING y tests | Identidades nuevas estables 1.0.0 sin cambio; validación exige revisión independiente |
| PG-0.02 Conflictos | Cumplido | Matriz CF-01–20 en el plan detallado | Todos tienen tratamiento, estado y dueño; CF-20 queda reservado a PG-6A |
| PG-0.03 CF-12 | Cumplido | `see feature language-2026` frente al manifiesto | Discrepancia reportada; estados no modificados |
| PG-0.04 Procedencia | Cumplido | D-xx/TS-3 en el plan detallado | NV conservado; propuestas no atribuidas al pasado |
| PG-0.05 Licencia | Diferido | Mensaje del 2026-10-22; PG-7.07 | Derechos reservados hasta elección y auditoría antes de cierre final/publicación |
| PG-0.06 Edición | Cumplido | ADR-05, CF-03, C-03 y README SEE | 2026 es edición única; se permiten incompatibilidades prepublicación documentadas |
| PG-0.07 Conformidad | Cumplido | Campaña de cierre de los cinco sujetos con procedencia, propiedades antes que casos | Cero regresiones exigibles; las «reglas sin casos» de la primera campaña eran evidencia de propiedades no combinada |
| PG-0.08 Rendimiento | Cumplido | Paired 10×30 en Apple M2; ios-arm64 2 985 792 B; Wasm Brotli 530 599 B | PERF.AOT.LEVEL y PERF.ARTIFACT.SIZE cumplen en esta plataforma; CF-06 resuelto por medición |
| PG-0.09 Discrepancias | Cumplido | Registro de CF-12, ancla local y campaña de cierre en el plan detallado | CF-05/06 resueltos con evidencia; CF-12 sigue solo clasificado |
| PG-0.10 Capacidades/oráculos | Cumplido | Catálogo del plan detallado | Propuesta sin código; oráculos separados de VM/AOT |
| PG-0.11 Experimentos | Cumplido | Matriz E-PG-01–12 del plan detallado | Recursos y ausencia de hardware/personas registrados |
| PG-0.12 Trazabilidad | Cumplido | Cruce base/R/C/fase/paquete y camino crítico ponderado | Pesos ordinales S/M/L/XL en dos escalas; empates PG-2/PG-3 y PG-6B/PG-B; no es calendario |

Revisión Git de cierre: commit de cierre con push ordinario comprobado a la rama única. Verificadores: `cargo xtask verify` integral de SEE en verde (formato, Clippy, tests de todo el workspace, cargo-deny, rust-checks, validate, export, propiedades y conformidad engine), `see lock --check` en verde tras el reanclaje autorizado y `cargo xtask verify` del motor en verde en esta misma fase, sin cambios posteriores del motor. Licencia diferida a PG-7.07; físicos/humanos complementarios; CF-12 sigue sin corrección automática.

### 4.2 PG-H · Catálogo y ayuda temprana

Objetivo: ayuda granular de la edición 2026 como datos compartidos por API, LSP y app. Requisitos R-17, R-18, R-20;
capacidad C-16; riesgos K-16, K-17; experimento E-PG-11; ADR-13.

Puntos a cumplir:

- [x] `PG-H.01` Especificación del catálogo de ayuda en el corpus: esquema, identidad de ficha, roles, disponibilidad por
  edición/rigor, anclajes y exportación.
- [x] `PG-H.02` Contrato público de consulta de ayuda: entrada (documento, revisión, posición y unidad de coordenadas,
  idioma, detalle), respuesta estructurada y rechazo de revisión obsoleta.
- [x] `PG-H.03` Reglas de resolución por posición especificadas con casos: fronteras del token, lexemas compuestos,
  Hacer y Hasta por contexto, comentarios, literales, código incompleto y nombres sombreados.
- [x] `PG-H.04` Fichas es/en para el 100 % de keywords, operadores, incorporadas y roles pedagógicos activos de 2026, o
  exclusión tipada justificada.
- [x] `PG-H.05` El contenido útil de la ayuda incrustada actualmente en el servicio queda migrado a datos, sin pérdida de
  información.
- [x] `PG-H.06` Ejemplos vinculados a reglas o casos, válidos por perfil y rigor, con esperados derivados de la regla.
- [x] `PG-H.07` Verificador del catálogo con casos negativos: ficha huérfana, vínculo roto, forma retirada, ejemplo
  inválido, traducción ausente.
- [x] `PG-H.08` El servicio resuelve identidad y rol desde el árbol sintáctico; LSP ofrece hover y un comando de explicar
  sintaxis; la API ofrece la respuesta estructurada.
- [x] `PG-H.09` La app consume la misma consulta por su puente, con acceso por teclado y táctil sin romper la colocación
  del cursor ni la navegación.
- [x] `PG-H.10` Ningún consumidor contiene prosa normativa local, parser ni reconocimiento por expresiones regulares.
- [x] `PG-H.11` Render seguro: Markdown saneado, sin HTML ejecutable, comandos ni enlaces arbitrarios.
- [x] `PG-H.12` E-PG-11 ejecutado e informado con sus criterios de éxito o descarte.

Fuera de alcance: fichas de sintaxis que aún no existe.

Plan detallado: [fase-pg-h-plan-ejecucion.md](fase-pg-h-plan-ejecucion.md), preparado por solicitud
de la persona y actualizado al cierre de PG-0 el 2026-10-22. Dependencia PG-0 satisfecha; `.01`–`.04`
están completos. La revisión integral del plan sigue pendiente; `.05`–`.12` requieren autorización propia.

Cierre común (definiciones en §4.0):

- [x] `PG-H.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [x] `PG-H.C02` Plan detallado creado según §5 y revisado por la persona.
- [x] `PG-H.C03` SPEC-FIRST y congelamiento respetados.
- [x] `PG-H.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [x] `PG-H.C05` Tests feliz, infeliz y límite en carpetas espejo.
- [x] `PG-H.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [x] `PG-H.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [x] `PG-H.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [x] `PG-H.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [x] `PG-H.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [x] `PG-H.C11` Tests y verificadores de los miembros afectados en verde.
- [x] `PG-H.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [x] `PG-H.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-H

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| PG-H.01–.08 | Cumplido | Detalle en `fase-pg-h-plan-ejecucion.md` | Contratos, casos, tests y puertas de engine y spec en verde. |
| PG-H.09 | Cumplido con salvedad | Suite de Flutter, conformidad `app` y puente real | Sin humo en simulador ni cobertura física. |
| PG-H.10–.11 | Cumplido | Auditoría de consumidores y pruebas adversarias | Sin copias de prosa; texto inerte en todos los renderizadores. |
| PG-H.12 | Cumplido con salvedad | Campaña `pg-h-campaign-2026-10-23` | p95 caliente 2,299 ms (criterio 20 ms); la app no se compara en esa campaña; margen iOS 0,32 %. |

Revisión Git de cierre: `935c9d5` y los commits documentales posteriores · Verificadores ejecutados: engine, spec, app y `native/`, leídos en sus registros · Pendientes justificados: humo en simulador, comparación de la app en E-PG-11, revisión independiente de las reglas añadidas, causa de los candidatos a punto de cambio · Decisiones de la persona: aceptó los cambios, incluida la regla de literales booleanos y las reglas añadidas, y cerró PG-H el 2026-10-23.

### 4.3 PG-1 · Identidad y proyectos

Objetivo: pasar de «un texto es un programa» a proyectos multiarchivo con identidad de fuente, módulos, manifiesto,
edición y perfiles. Requisitos R-01–R-04, R-14, R-18; capacidades C-01, C-02, C-03; riesgos K-02, K-03; experimentos
E-PG-01, E-PG-02; ADR-01, ADR-04, ADR-05.

Puntos a cumplir:

- [x] `PG-1.01` Identidad de fuente especificada: proyecto, revisión, archivo y tramo, propagada a diagnósticos, vistas
  públicas, RI, trampas AOT, eventos y formatos de intercambio con protocolo versionado.
- [x] `PG-1.02` Módulo = archivo; paquete por manifiesto; workspace local; una entrada por aplicación; bibliotecas sin
  algoritmo obligatorio.
- [x] `PG-1.03` Import nominal, alias, público/privado (privado por defecto en la edición 2026), export y reexport
  explícitos; sin comodines; sin efectos al importar.
- [x] `PG-1.04` Ciclos entre módulos y paquetes rechazados con la cadena completa en el diagnóstico.
- [x] `PG-1.05` Manifiesto declarativo, no ejecutable y con esquema versionado; permisos efectivos = intersección de lo
  solicitado y lo concedido externamente.
- [x] `PG-1.06` Lock reproducible: orden canónico, identidad de origen y contenido, hash verificado antes de compilar,
  funcionamiento sin red con lock y caché completos, sin scripts de terceros.
- [x] `PG-1.07` Perfil por archivo bajo la única edición 2026, imports cruzados es↔en, alias obligatorio ante nombre reservado
  en destino y discrepancia de perfil diagnosticada con ambas procedencias.
- [x] `PG-1.08` Orden de diagnósticos de proyecto especificado, independiente del sistema de archivos y del cliente.
- [x] `PG-1.09` Rutas portables: colisiones por caja/NFC rechazadas y sin escape de la raíz mediante enlaces simbólicos.
- [x] `PG-1.10` Alfabeto español en identificadores del perfil estricto de 2026, conservando NFC.
- [x] `PG-1.11` Programas sueltos 2026 intactos: corpus 2026 sin cambios de esperados.
- [x] `PG-1.12` CLI comprueba, ejecuta y compila un proyecto de tres módulos, dos perfiles y una biblioteca local desde
  otro directorio, con el mismo resultado observable en VM y AOT.
- [x] `PG-1.13` E-PG-01 y la parte de proyecto de E-PG-02 ejecutados; métricas candidatas de perfiles, proyecto y
  resolución medidas.

Fuera de alcance: registro público, rangos de versiones, compilación separada y carga dinámica.

Plan detallado: [fase-pg-1-plan-ejecucion.md](fase-pg-1-plan-ejecucion.md), preparado el 2026-10-23
por solicitud de la persona. Las autorizaciones del 2026-10-23 cubrieron PG-1.01 a PG-1.07. Las
autorizaciones del 2026-10-24 cubrieron PG-1.08 a PG-1.11 en iteraciones separadas; la revisión de
cuatro contratos estables resolvió las salvedades de .08/.09. PG-1.08–.13 están cumplidos (.12 y .13 con
salvedades registradas en el plan detallado). El cierre común C01–C13 sigue pendiente.

Cierre común (definiciones en §4.0):

- [ ] `PG-1.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [ ] `PG-1.C02` Plan detallado creado según §5 y revisado por la persona.
- [ ] `PG-1.C03` SPEC-FIRST y congelamiento respetados.
- [ ] `PG-1.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [ ] `PG-1.C05` Pruebas dirigidas feliz, infeliz y límite para las piezas modificadas, en carpetas espejo.
- [ ] `PG-1.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [ ] `PG-1.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [ ] `PG-1.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [ ] `PG-1.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [ ] `PG-1.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [ ] `PG-1.C11` Pruebas necesarias y verificadores directamente afectados en verde, con selección y omisiones registradas.
- [ ] `PG-1.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [ ] `PG-1.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-1

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| PG-1.08–.11 | Cumplido | Orden/portabilidad revisados; alfabeto español estricto y archivo suelto compatibles | Contratos estables 1.0.0 revisados y reanclados solo cuando cambió el contenido; corpus sin cambiar esperados previos |

Revisión Git del alcance autorizado `.08`–`.11`: commit de implementación `d751f63` publicado por push ordinario
en `feature/agregar-ruta-de-especificacion`; el registro de cierre de esta iteración se publica en el commit documental
siguiente. Verificadores, cobertura dirigida y omisiones están registrados en el plan detallado. El cierre
común C01–C13 permanece abierto.

### 4.4 PG-2 · Tipos y abstracción

Objetivo: el sistema de tipos y de abstracción incorporado a la edición 2026, con la misma representación en VM y AOT. Requisitos
R-05–R-08, R-17; capacidades C-04, C-05, C-06; riesgos K-04, K-05; experimentos E-PG-03, E-PG-04, E-PG-10; ADR-06,
ADR-07.

Puntos a cumplir:

- [x] `PG-2.01` Constantes evaluadas con pureza y presupuesto, y enumerados con comprobación estática.
- [x] `PG-2.02` Registros por valor con disposición común, rechazo de tamaño infinito y raíces de campos.
- [x] `PG-2.03` `Opcional<T>` y `Resultado<T,E>`, con descarte de Resultado rechazado y propagación visible.
- [x] `PG-2.04` `Segun` exhaustivo con patrones básicos sobre literales, enumerados y variantes.
- [x] `PG-2.05` Vínculos inmutables por defecto, mutación explícita e inicialización en la declaración.
- [x] `PG-2.06` Ámbitos léxicos de bloque en la edición 2026.
- [x] `PG-2.07` Funciones como valores y clausuras con captura verificada y entornos en el mapa de raíces.
- [x] `PG-2.08` Genéricos de primer orden con límite tipado de instanciación.
- [x] `PG-2.09` Interfaces nominales mínimas como restricciones, sin herencia múltiple de implementación.
- [x] `PG-2.10` `Vector` y `Diccionario` con orden observable definido e invalidación durante la iteración especificada.
- [x] `PG-2.11` `Para Cada`, salida anticipada y limpieza ejecutada exactamente una vez en cada salida.
- [x] `PG-2.12` El verificador de RI rechaza disposiciones inválidas, con casos negativos.
- [x] `PG-2.13` VM y AOT coinciden con los oráculos en todas las construcciones nuevas.
- [x] `PG-2.14` Diagnósticos pedagógicos de ADR-07 con código y argumentos iguales en es/en.
- [~] `PG-2.15` (retirado el 2026-10-26 por la decisión de la persona del 2026-10-25: sin migradores ni retrocompatibilidad) Migración asistida para cambios incompatibles de 2026 cuando corresponda: diff revisable, nunca sobrescritura silenciosa, e intervención
  manual diagnosticada cuando no se preserva la semántica.
- [x] `PG-2.16` Vista pública del programa con identidades de interfaz, realización, restricción, captura, variante e
  iteración.
- [x] `PG-2.17` E-PG-03 y E-PG-04 ejecutados; E-PG-10 con resultados aportados por la persona o diferido por ella;
  métricas candidatas de tipos, colecciones, clausuras y limpieza medidas.

Fuera de alcance: metaprogramación, tipos de orden superior, especialización por el usuario y sobrecarga compleja.

Plan detallado: [fase-pg-2-plan-ejecucion.md](fase-pg-2-plan-ejecucion.md), preparado el 2026-10-24 por solicitud
de la persona y pendiente de su revisión. Deja constancia de que ninguna iteración ejecuta las pruebas de todo el
monorepo: solo las acotadas a lo desarrollado, porque hay ejecuciones de más de 10 minutos que alargan una fase más
de hora y media.

Cierre común (definiciones en §4.0):

- [x] `PG-2.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [x] `PG-2.C02` Plan detallado creado según §5 y revisado por la persona.
- [x] `PG-2.C03` SPEC-FIRST y congelamiento respetados.
- [x] `PG-2.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [x] `PG-2.C05` Pruebas dirigidas feliz, infeliz y límite para las piezas modificadas, en carpetas espejo.
- [x] `PG-2.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [x] `PG-2.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [x] `PG-2.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [~] `PG-2.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [x] `PG-2.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [x] `PG-2.C11` Pruebas necesarias y verificadores directamente afectados en verde, con selección y omisiones registradas.
- [x] `PG-2.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [x] `PG-2.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-2

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| PG-2.01–.05, .09–.12, .14, .16 | Cumplido | Registros de iteración en el plan detallado §11 | Cerrados en sus iteraciones |
| PG-2.06, .07, .08 | Cumplido | Centinela de archivo suelto (7 contratos, engine, 0 divergencias); `LANG.SUBPROGRAM.SCOPE`, `LANG.TYPES.FUNCTION` y `LANG.TYPES.GENERIC` en engine y aot sin divergencias; tests de captura, raíces y recolección forzada en ambos gemelos; medición de instancias y bytes de E-PG-03 | `LANG.TYPES.FUNCTION` no declara propiedades: la recolección se prueba con ejecución forzada en VM y AOT |
| PG-2.13 | Cumplido | `--only` y `see differential` por cada contrato de PG-2: 0 divergencias, 0 diferencias sin resolver | Dos regresiones halladas y resueltas (oráculo de `LANG.DECL.UNINITIALIZED#C4` autorizado por la persona; vínculo aot de `LANG.CONTROL.FOR#R4` a `exento`) |
| PG-2.15 | Retirado | Decisión de la persona del 2026-10-25 | Sin migradores ni retrocompatibilidad |
| PG-2.17 | Cumplido | Campañas E-PG-03 y E-PG-04 del 2026-10-26, `pg-2-17-protocolos-y-materiales.md` §5; E-PG-10 diferido por la persona | E-PG-03 cumple (recorrido 1,00–1,01×); E-PG-04 llamada indirecta 1,14× en estimación puntual con intervalo 0,85–1,52 que supera 1,25 |

Revisión Git de cierre: commit de cierre de PG-2 en `feature/agregar-ruta-de-especificacion` (ver `git log`) · Verificadores ejecutados: `see validate` (175), `lock --check`, `export --check`; `conform --only` y `differential` por contrato; tests dirigidos de abi, semantic, lowering, ir, bytecode, vm, api y bench_worker; Clippy `-D warnings` en api y bench_worker; `rust-checks all` en engine y spec · Pendientes justificados: `PG-2.C09` (fichas de ayuda de genéricos, tipos función y clausuras: no existen, el catálogo solo trae interfaz, vector, diccionario, `Para Cada` y limpieza), intervalo de confianza de la llamada indirecta por encima del umbral, carga de 100 combinaciones sustituida por 60 por el límite de 64 instancias, `cargo deny`/tamaño iOS/Wasm no medidos (sin disparador), `PG-2.16.03/.06` sin Dart (payload aditivo), `variantes y clases genéricas` fuera de edición · Decisiones de la persona: E-PG-10 diferido; Mac M2 como máquina de referencia; cambio del esperado de `LANG.DECL.UNINITIALIZED#C4` a `bindingOutsideScope`; cierre con commit y push

### 4.5 PG-3 · Capacidades y cinta

Objetivo: efectos explícitos, grabables y reproducibles sin autoridad externa. Requisitos R-08, R-09, R-13; capacidad
C-07; riesgos K-06, K-07, K-13; experimentos E-PG-05, E-PG-09; ADR-02.

Puntos a cumplir:

- [x] `PG-3.01` CF-07 especificado: frontera lógica de commit y estado externo incierto, con casos.
- [x] `PG-3.02` CF-11 resuelto: la persona revisa la formulación de fallo controlado frente a caída del host.
- [x] `PG-3.03` Capacidades de consola, argumentos, archivos relativos a capacidad, reloj registrado y temporizadores
  lógicos; denegación por defecto.
- [x] `PG-3.04` Identidad de ejecución ampliada y esquema versionado de la cinta con todos los datos de cada efecto y su
  orden de entrega.
- [x] `PG-3.05` Tres modos distintos: ejecutar en vivo y grabar, ejecutar desde cinta, consultar historia; reproducir y
  retroceder nunca tocan disco ni red.
- [x] `PG-3.06` Cinta divergente, truncada o alterada rechazada con error de reproducción, sin consultar al anfitrión.
- [x] `PG-3.07` Contrato de suspensión por efecto pendiente, distinto de la espera de entrada.
- [x] `PG-3.08` Análisis de efectos transitivos en compilación: una función pura no puede esconder E/S.
- [x] `PG-3.09` Errores de E/S portables, separación de bytes y texto UTF-8, y limpieza en retorno, propagación y salida.
- [x] `PG-3.10` Privacidad de la cinta: secretos por referencia, retención y presupuesto de bytes definidos, y cinta
  incompleta marcada como no reproducible.
- [x] `PG-3.11` Conformidad con anfitrión falso de resultados derivados, sin red ni disco reales.
- [x] `PG-3.12` AOT comparte cinta y determinismo de salida sin anunciar observación ni retroceso.
- [x] `PG-3.13` E-PG-05 y la parte de archivos de E-PG-09 ejecutados; sobrecoste de infraestructura inactiva dentro del
  presupuesto candidato.

Fuera de alcance: HTTP, tareas concurrentes y reejecución con efectos reales desde el pasado.

Plan detallado: [fase-pg-3-plan-ejecucion.md](fase-pg-3-plan-ejecucion.md), creado y revisado por la persona el
2026-10-26. Deja constancia de que todas las soluciones son a medida para la arquitectura de PseudoLearn, que en ninguna
iteración ni en el cierre se ejecutan las pruebas de todo el monorepo (solo las pruebas acotadas a lo desarrollado) y
que `apps/pseudolearn_app` evoluciona de forma sincronizada con la sintaxis y semántica nuevas de la fase.

Cierre común (definiciones en §4.0):

- [x] `PG-3.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [x] `PG-3.C02` Plan detallado creado según §5 y revisado por la persona.
- [x] `PG-3.C03` SPEC-FIRST y congelamiento respetados.
- [x] `PG-3.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [x] `PG-3.C05` Pruebas dirigidas feliz, infeliz y límite para las piezas modificadas, en carpetas espejo.
- [x] `PG-3.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [x] `PG-3.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [x] `PG-3.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [x] `PG-3.C09` Fichas de ayuda, datos de proyección de la sintaxis nueva y evolución sincronizada de `apps/pseudolearn_app`.
- [x] `PG-3.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [x] `PG-3.C11` Pruebas necesarias y verificadores directamente afectados en verde, con selección y omisiones registradas.
- [x] `PG-3.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única. Commit `4bdbd52`, publicado con push ordinario a `feature/agregar-ruta-de-especificacion` y comprobado contra `origin`.
- [x] `PG-3.C13` Resumen completo, informe a la persona y parada. Informe final entregado al terminar la iteración del 2026-10-27 (ver §11.4 del plan detallado); la fase sigue abierta y rige `PHASE-STOP`.

#### Resumen de PG-3

Estado a 2026-10-27: todos los puntos de la fase están cumplidos con evidencia ejecutada en esta iteración (plan detallado §11.9); todas las casillas de cierre están marcadas, incluida `PG-3.C12` (commit `4bdbd52`). Rige `PHASE-STOP`: no se inicia PG-4 sin autorización nueva.

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| `PG-3.01`, `PG-3.02`, `PG-3.07` | Cumplido | Conformidad `engine` y `aot` sin divergencias en `ENG.EXEC.EFFECT-COMMIT`, `ENG.EXEC.EFFECT-ORDER`, `ENG.EXEC.MODEL`, `RT.HOST.INTERFACE` y `API.EXECUTE`; pruebas de `pseudolearn_api` y `flutter test` de efectos | Casos reescritos al formato de cable implementado; la cancelación en `awaiting_effect` sella la cinta `incomplete` |
| `PG-3.03` | Cumplido | `LANG.CAPABILITY.MODEL` y `TOOL.SERVICE.CATALOG` sin divergencias; `tests/capability_help.rs` | Fichas bilingües de capacidades y `Bytes` resueltas en el hover |
| `PG-3.04`–`PG-3.06` | Cumplido | `ENG.EFFECT.TAPE` `C1`–`C12` en `engine` y `aot`; `capability_kind` con vocabulario cerrado (`EffectOperation::capability_family`) | La cinta truncada por presupuesto se rechaza como no reproducible |
| `PG-3.08` | Cumplido | `LANG.CAPABILITY.PURITY`; 18 pruebas de `pseudolearn_semantic` | — |
| `PG-3.09` | Cumplido | `LIB.IO`, `LIB.TIME`, `LIB.MODEL`, `LANG.CONTROL.CLEANUP`, `IR.INSTRUCTIONS`, `API.PROGRAM.VIEW` sin divergencias; proyección `builtin_type`, `capability_type`, `effect_operation` en la API y la app | El README de `pseudolearn_library` no cambia: `Bytes` y `ErrorES` no viven en ese miembro |
| `PG-3.10` | Cumplido | Casos `C8`–`C12` de `ENG.EFFECT.TAPE` y `C19` de `ENG.LIMITS`, también en `aot`; pruebas de privacidad y presupuesto | — |
| `PG-3.11`, `PG-3.12` | Cumplido | Corredor SEE con anfitrión falso; `pseudo run --nativo` con cinta en ambos sentidos | — |
| `PG-3.13` | Cumplido | `pg-tape`: 338, 557 y 740 B por efecto, crecimiento lineal; E-PG-05 media 1,0001 dentro del presupuesto revisado; E-PG-09 con 7 de 7 vectores bloqueados y registro cerrado de ocho | Presupuesto revisado por la persona el 2026-10-27; codificación de la carga de cinta sigue siendo seis veces su tamaño |

Revisión Git de cierre: commit `4bdbd52` publicado en la rama única · Verificadores ejecutados: `see validate` (181), `lock --check`, `export --check`; `see conform` en `engine`, `aot` y `service` por contrato; pruebas dirigidas de `abi`, `runtime`, `semantic`, `timeline`, `vm`, `lowering`, `service`, `aot_rt`, `api` (native), la CLI, `see_conformance`, `see_validation` y `bench_worker` (`pg_tape`); `rust-checks all` del motor, de las especificaciones y de la CLI; Clippy `-D warnings` del motor, de las especificaciones y de la CLI; `dart analyze`, límites y `flutter test` de efectos y proyección · Pendientes justificados: divergencias previas de `TOOL.SERVICE.HOVER` y `TOOL.LSP.CAPABILITIES` por programas sin inicializador; `workloads_tests` de `pseudolearn_bench_worker` no termina en 28 minutos en release; cuelgue puntual de `pseudo run --nativo`; serialización de la carga de cinta (§11.9) · Decisiones de la persona: el corpus manda sobre el vocabulario de la cinta (2026-10-27); presupuesto de E-PG-05 revisado (2026-10-27); cierre de los puntos restantes en esta iteración.

### 4.6 PG-4 · Tareas aisladas

Objetivo: asincronía y concurrencia estructurada sin mutación compartida y con agenda lógica reproducible. Requisitos
R-06, R-10, R-12; capacidad C-09; riesgos K-05, K-08; experimento E-PG-06; ADR-03.

Puntos a cumplir:

- [x] `PG-4.01` Funciones suspendibles y espera explícita, con identidad sintáctica bilingüe.
- [x] `PG-4.02` Ámbitos de tareas obligatorios: unión al salir, ningún hijo abandonado y cancelación cooperativa.
- [x] `PG-4.03` Política de fallos: el primero por orden lógico cancela a los hermanos y los demás se conservan
  asociados.
- [x] `PG-4.04` Canales con capacidad explícita, cierre y contrapresión; elección simultánea resuelta por orden
  normativo.
- [x] `PG-4.05` Bloqueo sin tareas ejecutables ni efectos pendientes diagnosticado, distinto de la espera de efecto.
  Implementados `.01`–`.06` de PG-4.03, PG-4.04 y PG-4.05 en una iteración conjunta; pruebas ligeras y
  verificadores en verde. Sus puntos `.07` pesados se ejecutaron en `engine` sin divergencias; la parte AOT
  queda como pendiente justificado. Decisiones y evidencia en el resumen de la fase PG-4.
- [x] `PG-4.06` Aislamiento transitivo: captura o envío de una referencia mutable rechazado incluso a través de alias,
  ciclos, registros, clausuras o parámetros por referencia; instantánea inmutable explícita con coste declarado.
- [x] `PG-4.07` Planificador lógico con identidades monotónicas, desempate definido y puntos de cesión por masa de
  sentencia compartidos por VM y AOT.
- [x] `PG-4.08` Continuaciones con disposición y mapas de raíces comunes; el GC recorre marcos suspendidos, entornos y
  mensajes pendientes.
- [x] `PG-4.09` Límites de tareas y de colas como terminaciones definidas.
- [x] `PG-4.10` 10 000 agendas sembradas reproducen sus observables, con cero diferencias.
- [x] `PG-4.11` Eventos de tarea observables (identidad, padre, espera, reanudación, canal) disponibles para la app.
- [x] `PG-4.12` E-PG-06 ejecutado; métrica candidata de tareas medida; async nativo en AOT no se anuncia si falla.

Fuera de alcance: paralelismo CPU, actores públicos, tareas desprendidas y mutex en el lenguaje.

Plan detallado: [fase-pg-4-plan-ejecucion.md](fase-pg-4-plan-ejecucion.md), creado el 2026-10-27 a petición de la
persona y revisado (`PG-4.C02`). Deja constancia de que el diseño es a medida del lenguaje, de que las
iteraciones 1 a 4 solo ejecutan verificaciones ligeras y las pruebas pesadas se ejecutan únicamente en la iteración
final, y del protocolo obligatorio para liberar espacio en disco. Crear el plan no inicia la fase (`PG-4.C01`).

Cierre común (definiciones en §4.0):

- [x] `PG-4.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [x] `PG-4.C02` Plan detallado creado según §5 y revisado por la persona.
- [x] `PG-4.C03` SPEC-FIRST y congelamiento respetados.
- [x] `PG-4.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [x] `PG-4.C05` Tests feliz, infeliz y límite en carpetas espejo.
- [x] `PG-4.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [x] `PG-4.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [x] `PG-4.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [x] `PG-4.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [x] `PG-4.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [x] `PG-4.C11` Tests y verificadores de los miembros afectados en verde.
- [x] `PG-4.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [x] `PG-4.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-4

Estado a 2026-10-28: la persona declaró cerrada la fase con los pendientes justificados en el plan detallado
(§11); todas las casillas de puntos y de cierre común están marcadas. Rige `PHASE-STOP`: no se inicia PG-5 sin
autorización nueva.

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| `PG-4.01` | Cumplido | 7 contratos en `engine`: 246 observaciones, 0 divergencias; `pseudolearn_syntax` 59 tests | — |
| `PG-4.02`, `PG-4.03` | Cumplido en `engine`; AOT diferido | `LANG.TASK.SCOPE` 132 y `LANG.CONTROL.CLEANUP` 52 observaciones, 0 divergencias | AOT rechaza con `nativeTasksUnsupported` (`SEE-RECORDING`); depende de `PG-4.12.04` |
| `PG-4.04`, `PG-4.05` | Cumplido en `engine`; AOT diferido | CHANNEL 84, LIB.MODEL 20, TRACE.EVENTS 69, AGENDA 52 y EXEC.MODEL 60 observaciones, 0 divergencias | Divergencias AOT por tareas nativas no construidas |
| `PG-4.06`–`PG-4.09` | Cumplido en `engine`; AOT diferido | ISOLATION 100, AGENDA 52, IR 43, MEMORY 16, LIMITS 117, SNAPSHOT 24 e INCREMENTAL 4 observaciones, 0 divergencias | Reglas AOT siguen `pendiente`; `RT.ABI` sin evidencia válida en AOT |
| `PG-4.10` | Cumplido en VM; comparación AOT diferida | E-PG-06: 10 000 semillas, 1 250 por familia, 0 divergencias; `tasks-0-10000.json` SHA-256 `d3364c0d…b724` | — |
| `PG-4.11` | Cumplido | Engine, service, CLI y app en verde (TRACE.EVENTS 69, PROGRAM.VIEW 27, WIRE-FORMAT 7); bridge 20, arquitectura 37, clases de evento 5 | — |
| `PG-4.12` | Cumplido con pendientes justificados | E-PG-06 ejecutado; PERF medida: 1,2192×, IC 95 % `[1,2119; 1,2243]`, manifiesto SHA-256 `fc9a4e12…1667` | `.12.04` no construido: async nativo en AOT no se anuncia; presupuesto PERF 1,02× no alcanzado |

Revisión Git de cierre: commit `a1de5355`, publicado con push ordinario a `feature/agregar-ruta-de-especificacion` y
sincronizado con `origin` · Verificadores ejecutados: `cargo test --locked --workspace`, Clippy `-D warnings`,
`rust-checks all` y `toolchain`, `cargo deny check`, `see validate` (187), `lock --check`, `export --check`;
conformidad `engine` en 26 contratos (1 151 observaciones, 0 divergencias); `dart analyze` y `check_limits.dart` ·
Pendientes justificados: soporte de tareas nativas en AOT (`PG-4.12.04`) y los `.07` AOT que dependen de él;
presupuesto de `PERF.SUITE.CORE` no cumplido; `cargo fmt --all --check` con diferencias previas ajenas · Decisiones
de la persona: continuar todas las tareas pesadas pese a fallos de conformidad (2026-10-28); cierre de la fase con
los pendientes justificados en el plan detallado (2026-10-28).

### 4.7 PG-5 · Biblioteca y HTTP

Objetivo: biblioteca estándar bilingüe y cliente HTTP seguro sobre adaptadores nativos y web. Requisitos R-07–R-13;
capacidades C-07, C-08, C-10; riesgos K-07, K-09; experimentos E-PG-07, E-PG-09; ADR-02, ADR-06.

Puntos a cumplir:

- [x] `PG-5.01` Biblioteca de texto, bytes, números vigentes, colecciones, E/S, tiempo, JSON y tareas, con un símbolo
  canónico y facetas es/en generadas.
- [x] `PG-5.02` Cliente HTTP/HTTPS: métodos explícitos, estado, cabeceras, cuerpo de texto o binario, y 4xx/5xx como
  respuesta, no como error.
- [x] `PG-5.03` Límites de bytes comprimidos y descomprimidos, profundidad JSON, peticiones pendientes y tiempo externo.
- [x] `PG-5.04` TLS no desactivable por código ordinario, redirecciones solo dentro del permiso, credenciales retiradas al
  cambiar de origen, proxies del entorno no heredados y política contra SSRF.
- [x] `PG-5.05` Sin reintento automático de operaciones no idempotentes; estado incierto registrado.
- [x] `PG-5.06` Adaptador nativo elegido tras validar licencia, tamaño, plataformas y permisos; adaptador Fetch con
  capacidades web declaradas.
- [x] `PG-5.07` Servidor de prueba local controlado; el corpus no depende de Internet.
- [x] `PG-5.08` `PERF.ARTIFACT.SIZE` se mantiene: sin dependencias de red en el módulo móvil fuera de presupuesto.
- [x] `PG-5.09` Casos integradores de ENT-1 relativos a archivos, JSON, HTTP con tareas y biblioteca bilingüe en
  verde, incluidos entrada vacía, permiso denegado, cancelación y agotamiento.
- [x] `PG-5.10` E-PG-07 y la parte de red de E-PG-09 ejecutados; métrica candidata de HTTP medida.

Fuera de alcance: servidor HTTP, sockets arbitrarios, FFI y matemática ampliada sin demanda.

Plan detallado: [fase-pg-5-plan-ejecucion.md](fase-pg-5-plan-ejecucion.md), creado el 2026-10-28 a petición de la
persona y revisado por ella (`PG-5.C02`). Deja constancia de que el diseño es a medida del propósito educativo
y legible del lenguaje, de que las iteraciones 1 a 5 solo ejecutan verificaciones ligeras sobre lo programado y las
pruebas pesadas se ejecutan únicamente en la iteración 6, de que la red real no entra en el corpus ni en el núcleo, y
del protocolo para liberar espacio en disco. Crear el plan no inicia la fase (`PG-5.C01`).

Cierre común (definiciones en §4.0):

- [x] `PG-5.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [x] `PG-5.C02` Plan detallado creado según §5 y revisado por la persona.
- [x] `PG-5.C03` SPEC-FIRST y congelamiento respetados.
- [x] `PG-5.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [x] `PG-5.C05` Tests feliz, infeliz y límite en carpetas espejo.
- [x] `PG-5.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [x] `PG-5.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [x] `PG-5.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [x] `PG-5.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [x] `PG-5.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [x] `PG-5.C11` Tests y verificadores de los miembros afectados en verde.
- [x] `PG-5.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [x] `PG-5.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-5

Estado a 2026-10-30: la persona declaró cerrada la fase con los pendientes justificados en el plan detallado
(§11); todas las casillas de puntos y de cierre común están marcadas. Rige `PHASE-STOP`: no se inicia PG-6A sin
autorización nueva.

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| `PG-5.01`, `PG-5.02` | Cumplido en `engine`; AOT con residuo de tareas | `LIB.MODEL` 24, `LIB.CORE.TEXT` 72, `LIB.CORE.BYTES` 20, `LIB.JSON` 64, `LIB.HTTP` 112 y `LIB.IO` 72 observaciones, 0 divergencias en `engine` | Divergencias AOT solo por `nativeTasksUnsupported` (`CF-PG5-02`) |
| `PG-5.03`–`PG-5.05` | Cumplido | `ENG.LIMITS` 129, `LIB.HTTP.POLICY` 32, `ENG.EFFECT.TAPE` 64 y `ENG.EXEC.EFFECT-COMMIT` 40 observaciones, 0 divergencias; integración nativa contra el servidor local (4 suites), `POST` cortado incierto, `GET` cortado no | Se corrigieron el destino de la petición y la validación previa a conectar |
| `PG-5.06`, `PG-5.07` | Cumplido con pendiente justificado | Hyper 1.11.1 con Rustls 0.23.46; Chromium y WebKit coinciden con el contrato nativo; auditoría de URL sin direcciones fuera de loopback y `*.test` | Firefox de Playwright 1.64 no se lanza en el equipo |
| `PG-5.08` | Cumplido | `ios-arm64` 4,294,592 bytes (≤ 5 MiB) y Wasm 772,804 bytes con Brotli (≤ 900 KiB) | Perfiles `wasm-release` y `[profile.release]` del puente; topes sin cambios |
| `PG-5.09` | Cumplido | `FILE-JSON` 18, `HTTP-TASKS` 23 y `BILINGUAL` 15 observaciones, 0 divergencias en `engine` | `BILINGUAL` solo en `engine`; `HTTP-TASKS` en AOT depende de tareas nativas |
| `PG-5.10` | Cumplido con pendiente justificado | `pg_http`: 10 procesos × 30 muestras, crecimiento lineal (R² ≥ 0,99999); `PERF.SUITE.CORE` 1,0443× frente a `a1de5355` | Presupuesto 1,02× no alcanzado; `PERF.PG.HTTP` pendiente de aprobación |

Revisión Git de cierre: commit `c9414002`, publicado con push ordinario a `feature/agregar-ruta-de-especificacion` y
sincronizado con `origin` · Verificadores ejecutados: conformidad `engine` en los IDs de la selección pesada, `service` y
`cli`; `see validate` (194), `lock --check`, `export --check`; Clippy `-D warnings`, `rustfmt --check` y `rust-checks all`
en motor, CLI y `xtask`; bridge 20, arquitectura de la app 20, `fetch_host` 10 y `browser.test.mjs` 4 · Pendientes
justificados: Firefox no lanzable; `PERF.SUITE.CORE` 1,0443×; tareas nativas en AOT (`CF-PG5-02`); `IR.LOWERING#P1`–`P3`
y `TOOL.CLI.IR#P1`; aprobación de `PERF.PG.HTTP` · Decisiones de la persona: cierre de la fase con los pendientes
justificados en el plan detallado (2026-10-30).

### 4.8 PG-6A · Servicio y extensión inicial

Objetivo: servicio de proyecto completo y extensión VS Code de escritorio instalable. Requisitos R-03, R-14, R-15, R-18,
R-20; capacidades C-11, C-12; riesgos K-03, K-10; experimento E-PG-02; ADR-08, ADR-09.

Puntos a cumplir:

- [x] `PG-6A.01` La persona decide CF-20 y la ruta del miembro nuevo en `apps/`, su cadena de herramientas y la licencia
  de la extensión.
- [x] `PG-6A.02` README y archivo de reglas del miembro nuevo escritos antes de su código, con verificador de comentarios
  propio y su caso negativo.
- [x] `PG-6A.03` Servicio de workspace: instantánea de proyecto, archivos cerrados, invalidación por dependencia y
  resincronización ante pérdida de eventos.
- [x] `PG-6A.04` LSP anuncia solo lo implementado: carpetas y configuración de workspace, diagnósticos relacionados,
  rename con prepareRename atómico y versionado, referencias, símbolos, tokens semánticos, formato y cancelación.
- [x] `PG-6A.05` Contrato de configuración declarativo con precedencia definida y sin secretos en archivos versionados.
- [x] `PG-6A.06` Gramática de resaltado generada desde el corpus, con verificador de obsolescencia (`GEN-NO-HAND-COPY`).
- [x] `PG-6A.07` Extensión de escritorio: cliente LSP, comandos de comprobar, ejecutar, detener, entrada, elegir entrada,
  formatear y traducir; ningún parser normativo en el cliente; nada se ejecuta al abrir un proyecto.
  El migrador queda retirado por la decisión de la persona reconfirmada el 2026-10-30: solo versión oficial,
  sin retrocompatibilidad aunque haya cambios incompatibles.
- [x] `PG-6A.08` Ayuda de PG-H integrada en hover y en el comando de explicar.
- [x] `PG-6A.09` Resultados equivalentes desde dos clientes LSP distintos.
- [x] `PG-6A.10` E-PG-02 completo, con sesiones de 100 archivos/10 000 líneas, Unicode/UTF-16 y ediciones obsoletas.
- [x] `PG-6A.11` VSIX instalado desde cero ejecuta un proyecto sencillo.

Fuera de alcance: publicación en Marketplace, DAP y variante web.

Plan detallado: [fase-pg-6a-plan-ejecucion.md](fase-pg-6a-plan-ejecucion.md), creado por encargo documental
el 2026-10-30. La persona cerró PG-6A por decisión expresa el 2026-10-31 con los pendientes justificados allí.
E-PG-02 se ejecutó, pero sus umbrales no se cumplen y `PERF.PG.SERVICE` no se aprueba. La repetición parcial del
2026-10-31 conserva cuatro grupos extendidos por encima de 100 ms (§11.4 del plan detallado). `PHASE-GREEN` no se
declara porque SEE sigue exigiendo revisión independiente; PG-6B permanece sin iniciar.

Cierre común (definiciones en §4.0):

- [x] `PG-6A.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [x] `PG-6A.C02` Plan detallado creado según §5 y revisado por la persona.
- [x] `PG-6A.C03` SPEC-FIRST y congelamiento respetados.
- [x] `PG-6A.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [x] `PG-6A.C05` Tests feliz, infeliz y límite en carpetas espejo.
- [x] `PG-6A.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [x] `PG-6A.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [x] `PG-6A.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [x] `PG-6A.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [x] `PG-6A.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [x] `PG-6A.C11` Tests y verificadores de los miembros afectados en verde.
- [x] `PG-6A.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [x] `PG-6A.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-6A

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| `PG-6A.01`–`.02` | Cumplido | Decisión CF-20; README, reglas y miembro de extensión documentados en el plan detallado | Cierre por decisión expresa de la persona, 2026-10-31 |
| `PG-6A.03`–`.06` | Cumplido | Servicio de workspace, capacidades LSP, configuración y gramática generada; pruebas y verificadores de los miembros afectados | La revisión SEE independiente sigue pendiente para validar/reanclar corpus |
| `PG-6A.07`–`.09` | Cumplido | Extensión de escritorio, comandos y comparación de clientes documentados en §11 del plan detallado | Sin publicación en Marketplace; fuera de alcance |
| `PG-6A.10` | Cumplido: campaña ejecutada; métrica no aprobada | Corrida E-PG-02 y seguimiento parcial con datos crudos en `packages/pseudolearn_spec/results/pg-6a-e-pg-02-incremental-2026-10-31/` | Cuatro grupos de `files-1000-extended` siguen sobre 100 ms; `PERF.PG.SERVICE` no se aprueba |
| `PG-6A.11` | Cumplido con pendientes justificados | Instalación limpia y ejecución de proyecto registradas en §11.4 del plan detallado | Sin instalación en el perfil habitual de VS Code |
| `PG-6A.C01`–`.13` | Cerrado por decisión expresa | Autorización, revisión del plan, tests/verificadores, commits e informe registrados en el plan detallado | `PHASE-GREEN` no declarado; la validación SEE requiere revisión independiente |

Revisión Git de cierre: 2026-10-31, cierre expreso registrado en el plan detallado. Seguimiento local posterior:
`4030ecf6`, `836d4d5c`, `04ca8b48`, `b924310c`; sin push en esta intervención. Verificadores: suites dirigidas,
Clippy y `rust-checks all` en los miembros afectados. Pendientes: cuatro grupos E-PG-02 extendidos incumplen el
umbral y SEE exige revisión independiente. Decisión de la persona: cerrar PG-6A; no iniciar PG-6B.

### 4.9 PG-6B · Depuración y web

Objetivo: depuración interoperable en escritorio, variante web de la extensión y evaluación telefónica honesta.
Requisitos R-09, R-15, R-16; capacidades C-08, C-12, C-13; riesgos K-10, K-11; experimento E-PG-08; ADR-08, ADR-10.

Puntos a cumplir:

- [x] `PG-6B.01` Ubicación y capa del adaptador DAP decididas y declaradas; el servicio no importa VM ni DAP.
- [x] `PG-6B.02` DAP de escritorio con el mínimo de ADR-08: evaluate puro, tareas como hilos lógicos, revisión y
  horizonte respetados, StepBack solo en VM y nunca anunciado en AOT.
- [x] `PG-6B.03` Retroceder o consultar el pasado nunca reenvía HTTP ni reescribe archivos.
- [x] `PG-6B.04` Variante web: servicio en un Worker y ejecución en otro Worker separado, con borde LSP aprobado, lotes
  cancelables y enteros i64 sin pérdida.
- [x] `PG-6B.05` Capacidades web explícitas (Fetch, sistema de archivos del editor) y capacidades ausentes visibles.
- [x] `PG-6B.06` Pruebas en host de navegador en los navegadores documentados.
- [ ] `PG-6B.07` (Diferido, «no evaluado físicamente») E-PG-08 en Safari iPhone y Chrome Android físicos, con resultados aportados por la persona.
- [x] `PG-6B.08` Informe móvil que distingue cobertura real de limitaciones, y la persona decide CF-14.
- [x] `PG-6B.09` Métrica candidata web medida y `PERF.ARTIFACT.SIZE` respetado.

Fuera de alcance: IDE propio, ejecución remota y AOT en teléfono.

Plan detallado: [fase-pg-6b-plan-ejecucion.md](fase-pg-6b-plan-ejecucion.md), preparado el 2026-10-31
por petición expresa; la petición directa posterior autorizó PG-6B completa. La persona cerró la fase por decisión expresa el 2026-11-01. Distingue capacidades existentes de entregas propuestas, contratos/casos, fronteras DAP/Wasm,
pruebas de host, medición web y evidencia física complementaria.

Cierre común (definiciones en §4.0):

- [x] `PG-6B.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [x] `PG-6B.C02` Plan detallado creado según §5 y revisado por la persona.
- [x] `PG-6B.C03` SPEC-FIRST y congelamiento respetados.
- [x] `PG-6B.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [x] `PG-6B.C05` Tests feliz, infeliz y límite en carpetas espejo.
- [x] `PG-6B.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [x] `PG-6B.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [x] `PG-6B.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [x] `PG-6B.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [x] `PG-6B.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [x] `PG-6B.C11` Tests y verificadores de los miembros afectados en verde.
- [x] `PG-6B.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [x] `PG-6B.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-6B

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| `PG-6B.01`–`.03` | Cumplido | Capas e imports, DAP VM con `TOOL.DAP` C10–C15, historia sin efectos repetidos | — |
| `PG-6B.04`–`.06` | Cumplido | Workers, LSP con contraste Rust, capacidades web, Chromium y WebKit aprobados | Firefox no arranca: «no evaluado», nunca aprobado |
| `PG-6B.07` | Diferido | Kit físico de 32 combinaciones y analizador; `.07` sin ensayos | Decisión del 2026-10-22, reafirmada el 2026-11-01; «no evaluado físicamente» |
| `PG-6B.08` | Cumplido | `informe-movil-pg-6b.md`; CF-14 decidido por la persona (opción 1) el 2026-11-01 | Sin cobertura móvil física |
| `PG-6B.09` | Cumplido | 5400 intentos válidos, Brotli 844 844 B ≤ `PERF.ARTIFACT.SIZE#R1` | Aceptación de `PERF.PG.WEB` pendiente de la persona |
| `PG-6B.C01`–`.13` | Cerrado por decisión expresa | Plan detallado §11 | `PHASE-GREEN` no declarado |

Revisión Git de cierre: `98ea6f42` más el commit de cierre del 2026-11-01 · Verificadores ejecutados: `cargo xtask verify`, `cargo test` de la CLI, vitest y `check:*` de la extensión, `see conform` de `engine` y `cli` (con propiedades), Chromium y WebKit · Pendientes justificados: Firefox, ensayos físicos (`07.07`), `PERF.PG.WEB`, deuda heredada de `pseudolearn_spec` y PG-6A · Decisiones de la persona: cerrar PG-6B y CF-14 con la opción 1 (Cesar Antonio Gutierrez Contreras, 2026-11-01); no iniciar PG-A, PG-B ni PG-7.

### 4.10 PG-A · App y sintaxis estática

Objetivo: la app enseña la sintaxis nueva con un solo archivo editable y vistas fieles. Requisitos R-03, R-05–R-08,
R-17–R-20; capacidad C-15; riesgos K-18, K-19; experimento E-PG-12 (parte estática); ADR-12.

Puntos a cumplir:

- [x] `PG-A.01` Modo de archivo único con preludio fijado por edición, como operación pública del núcleo comprobable
  desde CLI y conformidad; sin manifiesto ni imports obligatorios, y sin migrar archivos 2026 al abrirlos.
- [x] `PG-A.02` Modelos de dominio para interfaz, realización, restricción genérica, variante, captura, iteración y ámbito.
- [x] `PG-A.03` Interfaz con marca, realización con línea discontinua y triángulo hueco, y contrato incumplido visible
  como inválido.
- [x] `PG-A.04` Matriz de cobertura construcción → vista (ordinograma, estructograma, tipos, tabla y ayuda) con
  verificador y caso negativo; ningún nodo desconocido cae en una forma genérica.
- [x] `PG-A.05` Imports o exports pegados se analizan y explican sin resolverse, descargarse ni ejecutarse.
- [x] `PG-A.06` Código equivalente: cada destino declara equivalencia comprobada, explicación ilustrativa o no
  disponibilidad (CF-18).
- [x] `PG-A.07` Pruebas de identidades, relaciones, geometría y accesibilidad, más pruebas con el puente real.
- [x] `PG-A.08` Ayuda de PG-H disponible para cada construcción nueva.
- [x] `PG-A.09` Parte estática de E-PG-12 con resultados aportados por la persona o diferida por ella.

Fuera de alcance: gestor de proyectos, edición gráfica inversa y control de rebobinado.

Plan detallado: [fase-pg-a-plan-ejecucion.md](fase-pg-a-plan-ejecucion.md), preparado el 2026-11-01
por petición expresa. Autorizaciones posteriores habilitaron los puntos de implementación de forma
individual; el mensaje del 2026-11-02 completó PG-A.09. El estudio humano de E-PG-12 está Diferido por
decisión previa del 2026-10-22; la evidencia automatizada está consolidada en los artefactos enlazados
desde el plan detallado. El 2026-11-02 Cesar Antonio Gutierrez Contreras decidió cerrar PG-A y autorizó
commit y push en la rama única. El cierre se registra por decisión expresa; `PHASE-GREEN` no se declara
por las puertas SEE/Rust pendientes y porque la suite completa no se repitió al cierre.

Cierre común (definiciones en §4.0):

- [x] `PG-A.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [x] `PG-A.C02` Plan detallado creado según §5 y revisado por la persona.
- [x] `PG-A.C03` SPEC-FIRST y congelamiento respetados.
- [x] `PG-A.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [x] `PG-A.C05` Tests feliz, infeliz y límite en carpetas espejo.
- [x] `PG-A.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [x] `PG-A.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [x] `PG-A.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [x] `PG-A.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [x] `PG-A.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [x] `PG-A.C11` Tests y verificadores de los miembros afectados en verde.
- [x] `PG-A.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [x] `PG-A.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-A

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| PG-A.01–.09 | Cumplido | Plan detallado §11; último alcance PG-A.09 ejecutado con campaña automatizada de 900 muestras | Estudio humano E-PG-12 diferido por decisión del 2026-10-22 |
| PG-A.C01–C13 | Cerrado por decisión expresa | Mensaje de Cesar Antonio Gutierrez Contreras, 2026-11-02; cierre, commit y push registrados | `PHASE-GREEN` no declarado; SEE/Rust y suite completa pendientes según plan detallado |

Revisión Git de cierre: 2026-11-02 · Verificadores: análisis Flutter, límites, contenido, diseño, cobertura 78/78, arquitectura/cobertura (24), selección focalizada (96), puente (20), `see validate` (196), `see export --check` y conformidad app (88 observaciones, 0 divergencias) · Pendientes justificados: `SEE-HASH` en `API.ANALYZE@1.0.0`, `SEE-STALE` en conformidad engine, dos `SIZE-NESTING` Rust, suite completa Flutter no repetida al cierre, smoke de plataforma y estudio humano E-PG-12 diferido · Decisiones de la persona: Cesar Antonio Gutierrez Contreras cerró PG-A por decisión expresa y autorizó commit/push · Commit/push: `feature/agregar-ruta-de-especificacion`, push ordinario comprobado.

### 4.11 PG-B · Lenguaje completo con anfitriones reales y app con tareas observables

Objetivo: todo programa válido se ejecuta con autoridad plena y efectos reales en CLI, extensión (escritorio y web) y
app (macOS, iOS, Windows), sin concesiones ni simulación; la app enseña tareas y efectos reales sin falsear causalidad.
Reformulada el 2026-11-02 ([análisis del 2026-11-02](analisis-lenguaje-completo-sin-simulacion.md), §B.2). Requisitos R-10–R-12, R-19, R-20; C-15; K-18/K-19; E-PG-12 dinámico.

Puntos de la versión anterior (ejecutados en iteraciones autorizadas según §11 del plan detallado; se marcan al cierre de la fase, tras reverificarse en PG-B.25/.26):

- [x] `PG-B.01` Evento global seleccionado más foco, pila y estado por tarea; dos tareas sobre el mismo subprograma no
  comparten marcos.
- [x] `PG-B.02` Tres proyecciones: flujo local por tarea con marcas de espera, estructura de creación y unión, y ventana
  paginada de eventos y estados.
- [x] `PG-B.03` Paso global y paso por tarea con la semántica de ADR-12, sin congelar otras tareas ni alterar el
  planificador.
- [x] `PG-B.04` **Retirado el 2026-11-02** (efectos simulados); la identidad de entradas por tarea y solicitud sigue vigente.
- [x] `PG-B.05` Las mismas entradas y la misma cinta producen las mismas proyecciones.
- [x] `PG-B.06` Cancelación, error, canal lleno y bloqueo representados por su camino normativo.
- [x] `PG-B.07` Ningún temporizador de presentación decide la agenda; los pintores no esperan efectos.
- [x] `PG-B.08` Pruebas con el puente real y no solo con dobles.
- [x] `PG-B.09` Parte dinámica de E-PG-12 automatizada; estudio humano diferido por la persona; métrica candidata medida.

Puntos de la reformulación:

- [x] `PG-B.10` Autoridad plena por omisión en el corpus: sin denegación, intersección ni manifiesto de permisos.
- [x] `PG-B.11` Red a cualquier destino `http`/`https`, TLS validado, sin política SSRF; diferencias del navegador como errores tipados.
- [x] `PG-B.12` Reloj y temporizador reales en vivo; semilla de entropía grabada; reproducción desde cinta.
- [x] `PG-B.13` Archivos con rutas del sistema; atenuación solo voluntaria.
- [x] `PG-B.14` Argumentos de ejecución reales.
- [x] `PG-B.15` Anfitrión de memoria solo como doble de prueba del corpus; casos rederivados y reanclaje.
- [x] `PG-B.16` Runtime y API sin autoridad por concesión; doble de prueba inalcanzable desde producto.
- [x] `PG-B.17` Cinta con tiempo real y semilla.
- [x] `PG-B.18` CLI con anfitrión físico completo por omisión en el crate compartido `pseudolearn_host`; opciones de concesión eliminadas.
- [x] `PG-B.19` Extensión de escritorio y DAP con autoridad plena, argumentos y carpeta de trabajo.
- [x] `PG-B.20` Extensión web con anfitrión real: Fetch sin orígenes, archivos del workspace, reloj, temporizador y argumentos.
- [x] `PG-B.21` Capa y puerto de anfitrión en la app, declarados antes del código.
- [x] `PG-B.22` Anfitrión real en el puente de la app, con medición previa de `PERF.ARTIFACT.SIZE`.
- [x] `PG-B.23` Configuración de plataforma iOS, macOS y Windows.
- [x] `PG-B.24` Eliminación de raíz de la simulación de la app.
- [x] `PG-B.25` Reverificación de tareas observables con anfitrión real.
- [x] `PG-B.26` E-PG-12 dinámico regenerado sin simulación.
- [x] `PG-B.27` Aceptación: archivo único que consulta la API de Rick y Morty sin configurar nada, por plataforma; Windows rotulado «no verificado».
- [x] `PG-B.28` Selector de rigor en la app.
- [x] `PG-B.29` Control para reproducir una ejecución en la app.
- [x] `PG-B.30` Receptor localizado en la tabla de traza y cobertura completa de diagramas.

Fuera de alcance: app Flutter web; clases abstractas, miembros estáticos, visibilidad protegida, excepciones, servidor
HTTP, sockets, procesos hijos, FFI y registro de paquetes (D-11, D-16–D-19).

Plan detallado: [fase-pg-b-plan-ejecucion.md](fase-pg-b-plan-ejecucion.md), reescrito el 2026-11-02 para revisión.
La reescritura no autoriza implementar: C01 y C02 siguen pendientes.

Cierre común (definiciones en §4.0):

- [x] `PG-B.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [x] `PG-B.C02` Plan detallado creado según §5 y revisado por la persona.
- [x] `PG-B.C03` SPEC-FIRST y congelamiento respetados.
- [x] `PG-B.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [x] `PG-B.C05` Tests feliz, infeliz y límite en carpetas espejo.
- [x] `PG-B.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [x] `PG-B.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [x] `PG-B.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [x] `PG-B.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [x] `PG-B.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [x] `PG-B.C11` Tests y verificadores de los miembros afectados en verde.
- [x] `PG-B.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [x] `PG-B.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-B

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| PG-B.01–PG-B.26, PG-B.28–PG-B.30 | Cumplido | §11.1–§11.17 del plan detallado; suite Flutter 2673/0 fallos; `see conform` motor y app sin divergencias | PG-B.04 retirado |
| PG-B.27 | Cumplido | §11.18: CLI, extensión de escritorio, web Chromium y WebKit, app macOS y app iOS simulador con `200 / Rick Sanchez / Alive`; Windows rotulado «no verificable» | Apps sin pulsar la interfaz |

Revisión Git de cierre: `8da720b5`, push ordinario comprobado · Verificadores ejecutados: ver §11.16–§11.18 · Pendientes justificados: ninguno · Decisiones de la persona: aprobación de la descarga de Playwright (2026-11-03)

### 4.12 PG-7 · Erradicación, calificación y distribución del lenguaje completo

Objetivo: demostrar que el 100 % del lenguaje corre en todos sus backends y plataformas, sin restos de la política
anterior, y dejarlo listo para distribuir. Requisitos R-01–R-20; capacidad C-14; riesgos K-01, K-12 y revisión final.

- [ ] `PG-7.01` Conformidad completa de todos los sujetos sin regresiones no exentas, con procedencia.
- [ ] `PG-7.02` Presupuestos de rendimiento candidatos aceptados o rechazados por la persona, con medición reproducible; incluye `PERF.SUITE.CORE` y los límites de recurso por omisión.
- [ ] `PG-7.03` Las 16 capacidades C-01–C-16 cumplen su criterio de salida, con C-07 y C-08 según la autoridad plena.
- [ ] `PG-7.04` Trazabilidad bidireccional sin huecos: punto base, requisito, capacidad, fase y paquete.
- [ ] `PG-7.05` Casos negativos de K-05, K-06, K-13 y de la atenuación voluntaria (K-07 reformulado) reproducibles y revisados; riesgos residuales aceptados por la persona.
- [ ] `PG-7.06` Documentación de uso bilingüe del entregable, con los límites reales de cada plataforma.
- [ ] `PG-7.07` Licencia implantada y licencias de dependencias y artefactos comprobadas.
- [ ] `PG-7.08` Artefactos por plataforma verificables con hashes y límites de plataforma documentados.
- [ ] `PG-7.09` Todos los casos integradores de ENT-1 en verde.
- [ ] `PG-7.10` Publicación en canales externos solo con aprobación explícita de la persona, o registrada como no realizada.
- [ ] `PG-7.11` Informe final de ENT-1 y propuesta de qué capacidad futura FUT-xx evaluar, sin activarla.
- `PG-7.12` **Retirado** el 2026-11-02 antes de existir: el compilador nativo completo es la fase PG-N.
- [ ] `PG-7.13` CLI y extensión para Windows x64, implementados; «no verificado» sin ejecución real.
- [ ] `PG-7.14` Barrido de eliminación de raíz con verificador mecánico y caso negativo.
- [ ] `PG-7.15` Reconciliación documental: este plan (incluida §5.4), hoja de ruta y planes de fase.
- [ ] `PG-7.16` Aceptación final de la persona en la app y en las demás plataformas.
- [ ] `PG-7.17` Cero vínculos de conformidad `pendiente` sin fase viva; fichas para toda celda de cobertura.
- [ ] `PG-7.18` Depuración en la extensión web con el contrato `TOOL.DAP`.
- [ ] `PG-7.19` Latencia del servicio de lenguaje de E-PG-02 dentro de umbral, o umbral nuevo aprobado por la persona.

Fuera de alcance: FUT-01–FUT-14 y lo descartado en D-16–D-19.

Plan detallado: `fase-pg-7-plan-ejecucion.md`, pendiente de crear al iniciar la fase. Contenido de referencia en el
[análisis del 2026-11-02](analisis-lenguaje-completo-sin-simulacion.md), §B.3.

Cierre común (definiciones en §4.0):

- [ ] `PG-7.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [ ] `PG-7.C02` Plan detallado creado según §5 y revisado por la persona.
- [ ] `PG-7.C03` SPEC-FIRST y congelamiento respetados.
- [ ] `PG-7.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [ ] `PG-7.C05` Tests feliz, infeliz y límite en carpetas espejo.
- [ ] `PG-7.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [ ] `PG-7.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [ ] `PG-7.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [ ] `PG-7.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [ ] `PG-7.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [ ] `PG-7.C11` Tests y verificadores de los miembros afectados en verde.
- [ ] `PG-7.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [ ] `PG-7.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-7

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| | | | |

Revisión Git de cierre: · Verificadores ejecutados: · Pendientes justificados: · Decisiones de la persona:

### 4.13 PG-L · Lenguaje sin restricciones de construcción

Objetivo: que toda construcción de la edición 2026 se combine con las demás sin diagnósticos de «no soportado».
Origen: [análisis del 2026-11-02](analisis-lenguaje-completo-sin-simulacion.md), §A.8.1 y §B.3a.

- [ ] `PG-L.01` Registros como elemento de arreglo y vector, campo de clase, parámetro y resultado de métodos y constructores, y por referencia.
- [ ] `PG-L.02` Visibilidad y exportación de constantes, enumerados y registros entre módulos.
- [ ] `PG-L.03` Genéricos exportables entre módulos.
- [ ] `PG-L.04` Clases genéricas y variantes genéricas de usuario.
- [ ] `PG-L.05` Comprobación de plantillas genéricas sin instanciar y símbolo de plantilla en el servicio.
- [ ] `PG-L.06` Liberación de memoria por ámbito de bloque.
- [ ] `PG-L.07` App y extensión con diagramas, traza, ayuda y resaltado para todo lo anterior.

Plan detallado: `fase-pg-l-plan-ejecucion.md`, pendiente de crear al iniciar la fase.

Cierre común (definiciones en §4.0):

- [ ] `PG-L.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [ ] `PG-L.C02` Plan detallado creado según §5 y revisado por la persona.
- [ ] `PG-L.C03` SPEC-FIRST y congelamiento respetados.
- [ ] `PG-L.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [ ] `PG-L.C05` Tests feliz, infeliz y límite en carpetas espejo.
- [ ] `PG-L.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [ ] `PG-L.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [ ] `PG-L.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [ ] `PG-L.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [ ] `PG-L.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [ ] `PG-L.C11` Tests y verificadores de los miembros afectados en verde.
- [ ] `PG-L.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [ ] `PG-L.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-L

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| | | | |

Revisión Git de cierre: · Verificadores ejecutados: · Pendientes justificados: · Decisiones de la persona:

### 4.14 PG-S · Biblioteca estándar de producción

Objetivo: cubrir lo que cualquier lenguaje de propósito general trae, con identidad única, facetas es/en y fichas.
Origen: [análisis del 2026-11-02](analisis-lenguaje-completo-sin-simulacion.md), §A.8.2 y §B.3b.

- [x] `PG-S.01` Mayúsculas y minúsculas de texto.
- [x] `PG-S.02` Ordenar, invertir y buscar en colecciones.
- [x] `PG-S.03` Mínimo, máximo, piso, techo y funciones trigonométricas y logarítmicas faltantes.
- [x] `PG-S.04` Archivos: listar, existir, borrar, renombrar, crear directorio y añadir.
- [x] `PG-S.05` Fecha y hora de calendario con zona horaria e ISO 8601.
- [x] `PG-S.06` Variables de entorno de solo lectura.
- [x] `PG-S.07` Código de salida y salida de error.
- [x] `PG-S.08` Formato de números en texto.
- [x] `PG-S.09` Cada operación en VM, extensión web y app de las tres plataformas.

Plan detallado: [fase-pg-s-plan-ejecucion.md](fase-pg-s-plan-ejecucion.md), redactado el 2026-11-04; la persona ordenó su ejecución completa y confirmó los casos de PG-S.01 (G2) el 2026-11-05.

Cierre común (definiciones en §4.0):

- [x] `PG-S.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [x] `PG-S.C02` Plan detallado creado según §5 y revisado por la persona.
- [x] `PG-S.C03` SPEC-FIRST y congelamiento respetados.
- [x] `PG-S.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [x] `PG-S.C05` Tests feliz, infeliz y límite en carpetas espejo.
- [x] `PG-S.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [x] `PG-S.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [x] `PG-S.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [x] `PG-S.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [ ] `PG-S.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [ ] `PG-S.C11` Tests y verificadores de los miembros afectados en verde.
- [ ] `PG-S.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [ ] `PG-S.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-S

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| PG-S.01–.08 | Cumplidos | [Plan detallado](fase-pg-s-plan-ejecucion.md), §11 e informes `informe-pg-s-*.md` | `PERF.AOT.LEVEL#R1` absoluto y estacionariedad no certificados (ya fallaban en la base); `error_ranges` sin interpretar en el protocolo de editor ni en la frontera Wasm |
| PG-S.09 | Cumplido con alcance acotado | [Informe](informe-pg-s-09.md) | Ejecutado en CLI, Chromium, WebKit, app macOS y simulador iOS (en la app solo el programa puro); Windows, Firefox y dispositivos físicos no verificados; la app no muestra el código de salida |
| Sujeto nativo | Pendiente | `conformance-aot.yaml` | Vínculos `pendiente` con `resuelve_en` `PG-N.08` |

Revisión Git de cierre: aún sin commit de cierre ni push comprobado · Verificadores ejecutados: `see validate/lock/export --check`, conformidad del motor por regla, pruebas dirigidas de motor, CLI, extensión y app, Chromium y WebKit · Pendientes justificados: PS-E04 (igualdad de tablas Unicode nativo/Wasm), PG-N.08, Windows/Firefox, suite completa del monorepo y `cargo xtask verify` · Decisiones de la persona: nombres de S.01 confirmados el 2026-11-05; presupuesto `PERF.AOT.LEVEL` sin cambios.

### 4.15 PG-N · Compilador nativo completo

Objetivo: que `pseudo build` y `pseudo run --nativo` ejecuten todo programa válido con la misma salida, efectos y cinta
que la VM en macOS, Linux y Windows, sin exigir herramientas al usuario. Origen: [análisis del 2026-11-02](analisis-lenguaje-completo-sin-simulacion.md), §B.3c.

- [ ] `PG-N.01` `RT.PROCESS` y `RT.ABI` reescritas para autoridad plena, semilla de entropía, código de salida y salida de error.
- [ ] `PG-N.02` Contrato de continuación nativa y raíces de recolección.
- [ ] `PG-N.03` Funciones suspendibles, ámbitos de tareas, unión, cancelación y limpieza en código nativo.
- [ ] `PG-N.04` Agenda nativa y canales con la misma semántica que la VM.
- [ ] `PG-N.05` Recolector sobre marcos suspendidos, continuaciones, mensajes y canales.
- [ ] `PG-N.06` Efectos concurrentes y cinta con el mismo orden de entrega que la VM.
- [ ] `PG-N.07` Runtime nativo enlazado con `pseudolearn_host`: archivos, red, reloj, temporizador, argumentos y entorno reales.
- [ ] `PG-N.08` Biblioteca de PG-S y construcciones de PG-L en código nativo; vínculos de módulos, perfil y JSON acreditados.
- [ ] `PG-N.09` Enlazador incluido: `pseudo build` sin compilador de C instalado; `.exe` en Windows.
- [ ] `PG-N.10` Destinos macOS arm64/x86_64, Linux x64 y Windows x64; Windows «no verificado» sin ejecución real.
- [ ] `PG-N.11` Diferencial VM/AOT con cero diferencias, incluidas las 10 000 agendas de E-PG-06.
- [ ] `PG-N.12` `PERF.AOT.LEVEL` mantenido con tareas presentes.
- [ ] `PG-N.13` Eliminación de `nativeTasksUnsupported` y de todo pendiente declarado de tareas nativas.

Plan detallado: `fase-pg-n-plan-ejecucion.md`, pendiente de crear al iniciar la fase.

Cierre común (definiciones en §4.0):

- [ ] `PG-N.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [ ] `PG-N.C02` Plan detallado creado según §5 y revisado por la persona.
- [ ] `PG-N.C03` SPEC-FIRST y congelamiento respetados.
- [ ] `PG-N.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [ ] `PG-N.C05` Tests feliz, infeliz y límite en carpetas espejo.
- [ ] `PG-N.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [ ] `PG-N.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [ ] `PG-N.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [ ] `PG-N.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [ ] `PG-N.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [ ] `PG-N.C11` Tests y verificadores de los miembros afectados en verde.
- [ ] `PG-N.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [ ] `PG-N.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-N

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| | | | |

Revisión Git de cierre: · Verificadores ejecutados: · Pendientes justificados: · Decisiones de la persona:

## 5. Reglas para crear cada `fase-<id>-plan-ejecucion.md`

### 5.1 Nombre, lugar y momento

- Ruta: esta misma carpeta. Nombre exacto: `fase-<id>-plan-ejecucion.md`, con `<id>` en minúsculas tomado de la tabla
  de §3 (`pg-0`, `pg-h`, `pg-1` … `pg-6a`, `pg-6b`, `pg-a`, `pg-b`, `pg-l`, `pg-s`, `pg-n`, `pg-7`).
- Nunca empieza por dígitos y nunca se llama `README.md`: la puerta de referencias transitorias identifica los documentos
  de `docs/` por su nombre y por su prefijo numérico.
- Se crea al iniciar la fase, después de la autorización de la persona y antes de cualquier especificación o código.
  Crearlo no autoriza ejecutarlo: la persona lo revisa primero (punto `C02`).
- Se escribe en español. Los identificadores de código, rutas y comandos se citan tal cual.

### 5.2 Lectura obligatoria antes de redactarlo

1. `AGENTS.md`, el README raíz y la sección de la fase en la hoja de ruta, con sus ADR, riesgos y experimentos.
2. El README y el archivo de reglas (`architecture.yaml` o `architecture.json`) de cada miembro que la fase toque.
3. Las especificaciones del corpus relacionadas y su estado actual.
4. El código actual que la fase va a cambiar, para describir el punto de partida real y no uno supuesto.

El plan registra qué se leyó y en qué revisión Git, y responde por cada archivo nuevo o modificado las tres preguntas de
`AGENTS.md` §1: capa, imports permitidos y prohibidos, y archivo dueño de la responsabilidad.

### 5.3 Secciones obligatorias

1. **Metadatos**: fase, fecha, revisión Git inicial y autorización de la persona citada.
2. **Punto de partida**: estado actual verificado, con rutas e IDs.
3. **Decisiones de diseño**: para cada decisión no fijada por la hoja de ruta, opciones, criterio, elección y condición
   de reversión. Cada decisión se trasladará después a su README dueño (`DOC-NO-ORPHAN-DECISION`). Una decisión que
   cambia una aprobación previa o choca con otra fuente se reporta y se espera.
4. **Desglose por punto**: cada punto `<fase>.nn` de §4 se descompone en tareas con casilla e ID propio
   (`<fase>.nn.mm`), en orden especificación → casos → tests → código → documentación → verificación. Ningún punto
   queda sin tareas y ninguna tarea queda sin punto de origen.
5. **Capas y archivos**: archivos nuevos y modificados por capa, con las respuestas de §5.2.
6. **Presupuestos**: rendimiento y seguridad que la fase debe respetar o medir (§5.4), con el control de cada medición.
7. **Pruebas y experimentos**: casos felices, infelices y límite de los comportamientos modificados; negativos de cada
   verificador nuevo; protocolo de los experimentos E-PG-xx de la fase. La matriz distingue corpus, tests espejo,
   consumidores y verificadores directamente afectados; una suite completa solo se añade cuando el riesgo o una falla
   dirigida lo requiera.
8. **Riesgos**: K-xx de la fase y riesgos nuevos, con su señal temprana.
9. **Dependencias de la persona**: decisiones, dispositivos, participantes, cuentas o permisos necesarios y en qué
   momento.
10. **Orden de ejecución y puntos de control**: en qué momentos se detiene a verificar antes de seguir.
11. **Resumen de ejecución**: misma tabla y estados de §2.2, por tarea, más la revisión Git de cierre, las pruebas y
    verificadores ejecutados, la razón de las suites omitidas, los pendientes justificados y qué puntos de §4 quedaron
    cumplidos.

Al cerrar la fase, el resumen de §4 de este plan se completa a partir del resumen del plan detallado.

### 5.4 Recomendaciones para un lenguaje optimizado, rápido y seguro

Estas recomendaciones orientan el diseño detallado; no sustituyen a las reglas del corpus ni a las de cada paquete.

**Rendimiento**

- Medir antes de afirmar: toda afirmación de coste lleva línea base, control semántico equivalente y protocolo
  `PERF.PROTOCOL`. Los nombres `PERF.PG.*` son candidatos hasta que la persona los apruebe.
- Conservar las ventajas existentes: representación común VM/AOT, bancos tipados sin etiquetas por valor, RI verificada y
  mundo cerrado que permite desvirtualizar. Un diseño que obligue a etiquetar todos los valores o a abrir el mundo
  necesita ADR propio.
- Preferir decisiones que se resuelven en compilación (monomorfización acotada, patrones exhaustivos, efectos analizados)
  a comprobaciones en ejecución, y medir el crecimiento de código y de tiempo de compilación que causen.
- Mantener la infraestructura inactiva fuera del camino caliente: la suite pura no debe pagar por efectos, tareas u
  observación que no usa.
- No optimizar fuera de alcance: las optimizaciones sin cambio observable son FUT-04 y requieren autorización propia.

**Seguridad**

- Autoridad plena por omisión (decisión de la persona del 2026-11-02): ninguna capacidad se deniega por política ni
  requiere concesión; la atenuación es voluntaria y no amplificable; no se heredan proxies ni credenciales ambientales;
  TLS siempre validado.
- Fallos esperables como valores tipados; ningún pánico ni excepción cruza una frontera pública. En Rust, las reglas de
  `QUALITY-NO-PANIC` y `unsafe` solo donde el archivo de reglas lo declara, con su invariante documentada.
- Límites para todo lo que crece: combustible, instancias genéricas, tareas, colas, bytes, profundidad y tiempo externo,
  todos con terminación definida.
- Cada frontera nueva tiene su prueba adversaria derivada de §9 de la hoja de ruta (STRIDE) antes de darse por cerrada.

**Determinismo y pedagogía**

- Todo lo observable se deriva de entradas completas: fuentes, configuración, semilla, límites y cinta. Ningún reloj
  físico, orden de disco ni orden de llegada decide un observable.
- Toda construcción nueva nace con su ficha de ayuda es/en, su fila de cobertura de vistas y sus diagnósticos en ambos
  perfiles.

**Mantenibilidad**

- Una responsabilidad por archivo, variantes como datos y no como condicionales sobre configuración, y dependencias
  invertidas para que la lógica se pruebe sin infraestructura real.
- Artefactos generados nunca editados a mano (`GEN-NO-HAND-COPY`); cada verificador nuevo con su caso negativo.
- Nada de abstracciones para fases futuras (`SCOPE-YAGNI`).

### 5.5 Prohibiciones del plan detallado

- No fija sintaxis final por su cuenta: puede proponer candidatas rotuladas como tales; la forma final la decide el
  corpus.
- No contiene código de producción ni fragmentos destinados a copiarse: el código se escribe en su miembro, después de la
  especificación.
- No introduce requisitos, capacidades o fases fuera de la hoja de ruta sin aprobación de la persona.
- No marca puntos dependientes de la persona ni presenta pruebas automatizadas como evidencia humana o física.
- No es citado desde fuera de `docs/`.

### 5.6 Plantilla mínima

```markdown
# Fase <ID> · <Nombre> — plan de ejecución

## 0. Metadatos
Fase: · Fecha de inicio: · Revisión Git inicial: · Autorización de la persona:

## 1. Punto de partida
## 2. Lectura realizada
- [ ] AGENTS.md y README raíz
- [ ] README y reglas de: <miembros>
- [ ] Especificaciones: <IDs>

## 3. Decisiones de diseño
| Decisión | Opciones | Criterio | Elección | Reversión |
|---|---|---|---|---|

## 4. Desglose por punto
### <ID>.01 · <título del punto>
- [ ] `<ID>.01.01` Especificación: …
- [ ] `<ID>.01.02` Casos: …
- [ ] `<ID>.01.03` Tests: …
- [ ] `<ID>.01.04` Código: …
- [ ] `<ID>.01.05` README y reglas: …
- [ ] `<ID>.01.06` Verificación: …

## 5. Capas y archivos
## 6. Presupuestos de rendimiento y seguridad
## 7. Pruebas y experimentos
## 8. Riesgos
## 9. Dependencias de la persona
## 10. Orden de ejecución y puntos de control

## 11. Resumen de ejecución
| Tarea | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|

Revisión Git de cierre: · Verificadores ejecutados: · Pendientes justificados: · Puntos de §4 cumplidos:
```

## 6. Resumen global

La IA a cargo actualiza esta tabla al cerrar cada fase.

| Fase | Estado | Plan detallado creado | Revisión Git de cierre | Puntos pendientes o diferidos |
|---|---|---|---|---|
| PG-0 | Cerrada · PG-0.01–.12 | Sí, C02 revisado | 2026-10-22 | Diferimientos autorizados registrados en §4.1 del plan de PG-0; licencia abierta diferida a PG-7.07 |
| PG-H | Cerrada · PG-H.01–.12 | Sí | 2026-10-23 | Pendientes declarados: humo en simulador, comparación de la app en E-PG-11, causa de los puntos de cambio y margen de iOS |
| PG-1 | PG-1.01–.07 cumplidos · fase en curso | Sí, revisión integral pendiente | Sin cierre de fase | PG-1.08–.13 y cierre común sin autorizar; PG-1.C01/C02 pendientes |
| PG-2 | Cerrada · PG-2.01–.17 (`.15` retirado) | Sí | 2026-10-26 | `PG-2.C09` justificado; E-PG-10 diferido por la persona; intervalo de E-PG-04 informado |
| PG-3 | En curso · PG-3.08, PG-3.11 y PG-3.12 cumplidos; resto abierto | Sí, C02 revisado (2026-10-26); revisión integral pendiente | Sin cierre de fase | `PG-3.C12` pendiente por revisión previa; E-PG-05 cumple el presupuesto por carga revisado el 2026-10-27; sin commit |
| PG-4 | Cerrada · PG-4.01–.12 | Sí | 2026-10-28 · `a1de5355` | Tareas nativas en AOT (`PG-4.12.04`) y sus `.07`; presupuesto de `PERF.SUITE.CORE` no alcanzado |
| PG-5 | Cerrada · PG-5.01–.10 | Sí, C02 revisado | 2026-10-30 · `c9414002` | Firefox no lanzable; presupuesto de `PERF.SUITE.CORE` no alcanzado; tareas nativas en AOT; aprobación de `PERF.PG.HTTP` |
| PG-6A | Cerrada por decisión expresa · PG-6A.01–.11 y cierre común | Sí | 2026-10-31 · cierre registrado en el plan detallado | E-PG-02 no aprobada: cuatro grupos extendidos siguen sobre 100 ms; SEE requiere revisión independiente; `PHASE-GREEN` no declarado |
| PG-6B | En implementación integrada · PG-6B.01–.09 | Sí, petición directa de implementación revisa y autoriza C02 | Sin cierre | Desarrollo continuo y campaña final única autorizados el 2026-10-31; físicos/revisión SEE y decisiones diferidas conservados |
| PG-A | Cerrada por decisión expresa · PG-A.01–.09 y cierre común | Sí | 2026-11-02 · cierre expreso y push ordinario en rama única | `PHASE-GREEN` no declarado; SEE/Rust pendientes, suite completa no repetida al cierre y estudio humano E-PG-12 diferido |
| PG-B | Reformulada el 2026-11-02 · PG-B.01–.03, .05–.09 ejecutados; .04 retirado; .10–.30 sin iniciar | Sí, reescrito; C02 pendiente | | C01/C02; parada en PG-B.22.01 si el puente supera `PERF.ARTIFACT.SIZE` |
| PG-L | Sin iniciar | No | | |
| PG-S | Implementada, sin cierre formal · PG-S.01–.09 y C01–C09 | Sí | | C10–C13 pendientes: PS-E04, suite completa, commit/push de cierre, parada; se ejecutó antes de cerrar PG-L por decisión expresa de la persona |
| PG-N | Sin iniciar | No | | |
| PG-7 | Sin iniciar · reformulada el 2026-11-02 | No | | |
