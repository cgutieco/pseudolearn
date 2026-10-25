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
| PG-B | App y tareas observables | PG-A, PG-3, PG-4, PG-5 | `fase-pg-b-plan-ejecucion.md` |
| PG-7 | Calificación y distribución | PG-5, PG-6B, PG-B | `fase-pg-7-plan-ejecucion.md` |

ENT-1 se considera entregado únicamente cuando PG-7 está completada.

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

- [ ] `PG-2.01` Constantes evaluadas con pureza y presupuesto, y enumerados con comprobación estática.
- [ ] `PG-2.02` Registros por valor con disposición común, rechazo de tamaño infinito y raíces de campos.
- [ ] `PG-2.03` `Opcional<T>` y `Resultado<T,E>`, con descarte de Resultado rechazado y propagación visible.
- [ ] `PG-2.04` `Segun` exhaustivo con patrones básicos sobre literales, enumerados y variantes.
- [ ] `PG-2.05` Vínculos inmutables por defecto, mutación explícita e inicialización en la declaración.
- [ ] `PG-2.06` Ámbitos léxicos de bloque en la edición 2026.
- [ ] `PG-2.07` Funciones como valores y clausuras con captura verificada y entornos en el mapa de raíces.
- [ ] `PG-2.08` Genéricos de primer orden con límite tipado de instanciación.
- [ ] `PG-2.09` Interfaces nominales mínimas como restricciones, sin herencia múltiple de implementación.
- [ ] `PG-2.10` `Vector` y `Diccionario` con orden observable definido e invalidación durante la iteración especificada.
- [ ] `PG-2.11` `Para Cada`, salida anticipada y limpieza ejecutada exactamente una vez en cada salida.
- [ ] `PG-2.12` El verificador de RI rechaza disposiciones inválidas, con casos negativos.
- [ ] `PG-2.13` VM y AOT coinciden con los oráculos en todas las construcciones nuevas.
- [ ] `PG-2.14` Diagnósticos pedagógicos de ADR-07 con código y argumentos iguales en es/en.
- [ ] `PG-2.15` Migración asistida para cambios incompatibles de 2026 cuando corresponda: diff revisable, nunca sobrescritura silenciosa, e intervención
  manual diagnosticada cuando no se preserva la semántica.
- [ ] `PG-2.16` Vista pública del programa con identidades de interfaz, realización, restricción, captura, variante e
  iteración.
- [ ] `PG-2.17` E-PG-03 y E-PG-04 ejecutados; E-PG-10 con resultados aportados por la persona o diferido por ella;
  métricas candidatas de tipos, colecciones, clausuras y limpieza medidas.

Fuera de alcance: metaprogramación, tipos de orden superior, especialización por el usuario y sobrecarga compleja.

Plan detallado: [fase-pg-2-plan-ejecucion.md](fase-pg-2-plan-ejecucion.md), preparado el 2026-10-24 por solicitud
de la persona y pendiente de su revisión. Deja constancia de que ninguna iteración ejecuta las pruebas de todo el
monorepo: solo las acotadas a lo desarrollado, porque hay ejecuciones de más de 10 minutos que alargan una fase más
de hora y media.

Cierre común (definiciones en §4.0):

- [ ] `PG-2.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [ ] `PG-2.C02` Plan detallado creado según §5 y revisado por la persona.
- [ ] `PG-2.C03` SPEC-FIRST y congelamiento respetados.
- [ ] `PG-2.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [ ] `PG-2.C05` Pruebas dirigidas feliz, infeliz y límite para las piezas modificadas, en carpetas espejo.
- [ ] `PG-2.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [ ] `PG-2.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [ ] `PG-2.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [ ] `PG-2.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [ ] `PG-2.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [ ] `PG-2.C11` Pruebas necesarias y verificadores directamente afectados en verde, con selección y omisiones registradas.
- [ ] `PG-2.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [ ] `PG-2.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-2

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| | | | |

Revisión Git de cierre: · Verificadores ejecutados: · Pendientes justificados: · Decisiones de la persona:

### 4.5 PG-3 · Capacidades y cinta

Objetivo: efectos explícitos, grabables y reproducibles sin autoridad externa. Requisitos R-08, R-09, R-13; capacidad
C-07; riesgos K-06, K-07, K-13; experimentos E-PG-05, E-PG-09; ADR-02.

Puntos a cumplir:

- [ ] `PG-3.01` CF-07 especificado: frontera lógica de commit y estado externo incierto, con casos.
- [ ] `PG-3.02` CF-11 resuelto: la persona revisa la formulación de fallo controlado frente a caída del host.
- [ ] `PG-3.03` Capacidades de consola, argumentos, archivos relativos a capacidad, reloj registrado y temporizadores
  lógicos; denegación por defecto.
- [ ] `PG-3.04` Identidad de ejecución ampliada y esquema versionado de la cinta con todos los datos de cada efecto y su
  orden de entrega.
- [ ] `PG-3.05` Tres modos distintos: ejecutar en vivo y grabar, ejecutar desde cinta, consultar historia; reproducir y
  retroceder nunca tocan disco ni red.
- [ ] `PG-3.06` Cinta divergente, truncada o alterada rechazada con error de reproducción, sin consultar al anfitrión.
- [ ] `PG-3.07` Contrato de suspensión por efecto pendiente, distinto de la espera de entrada.
- [ ] `PG-3.08` Análisis de efectos transitivos en compilación: una función pura no puede esconder E/S.
- [ ] `PG-3.09` Errores de E/S portables, separación de bytes y texto UTF-8, y limpieza en retorno, propagación y salida.
- [ ] `PG-3.10` Privacidad de la cinta: secretos por referencia, retención y presupuesto de bytes definidos, y cinta
  incompleta marcada como no reproducible.
- [ ] `PG-3.11` Conformidad con anfitrión falso de resultados derivados, sin red ni disco reales.
- [ ] `PG-3.12` AOT comparte cinta y determinismo de salida sin anunciar observación ni retroceso.
- [ ] `PG-3.13` E-PG-05 y la parte de archivos de E-PG-09 ejecutados; sobrecoste de infraestructura inactiva dentro del
  presupuesto candidato.

Fuera de alcance: HTTP, tareas concurrentes y reejecución con efectos reales desde el pasado.

Plan detallado: `fase-pg-3-plan-ejecucion.md`, pendiente de crear al iniciar la fase.

Cierre común (definiciones en §4.0):

- [ ] `PG-3.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [ ] `PG-3.C02` Plan detallado creado según §5 y revisado por la persona.
- [ ] `PG-3.C03` SPEC-FIRST y congelamiento respetados.
- [ ] `PG-3.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [ ] `PG-3.C05` Tests feliz, infeliz y límite en carpetas espejo.
- [ ] `PG-3.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [ ] `PG-3.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [ ] `PG-3.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [ ] `PG-3.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [ ] `PG-3.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [ ] `PG-3.C11` Tests y verificadores de los miembros afectados en verde.
- [ ] `PG-3.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [ ] `PG-3.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-3

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| | | | |

Revisión Git de cierre: · Verificadores ejecutados: · Pendientes justificados: · Decisiones de la persona:

### 4.6 PG-4 · Tareas aisladas

Objetivo: asincronía y concurrencia estructurada sin mutación compartida y con agenda lógica reproducible. Requisitos
R-06, R-10, R-12; capacidad C-09; riesgos K-05, K-08; experimento E-PG-06; ADR-03.

Puntos a cumplir:

- [ ] `PG-4.01` Funciones suspendibles y espera explícita, con identidad sintáctica bilingüe.
- [ ] `PG-4.02` Ámbitos de tareas obligatorios: unión al salir, ningún hijo abandonado y cancelación cooperativa.
- [ ] `PG-4.03` Política de fallos: el primero por orden lógico cancela a los hermanos y los demás se conservan
  asociados.
- [ ] `PG-4.04` Canales con capacidad explícita, cierre y contrapresión; elección simultánea resuelta por orden
  normativo.
- [ ] `PG-4.05` Bloqueo sin tareas ejecutables ni efectos pendientes diagnosticado, distinto de la espera de efecto.
- [ ] `PG-4.06` Aislamiento transitivo: captura o envío de una referencia mutable rechazado incluso a través de alias,
  ciclos, registros, clausuras o parámetros por referencia; instantánea inmutable explícita con coste declarado.
- [ ] `PG-4.07` Planificador lógico con identidades monotónicas, desempate definido y puntos de cesión por masa de
  sentencia compartidos por VM y AOT.
- [ ] `PG-4.08` Continuaciones con disposición y mapas de raíces comunes; el GC recorre marcos suspendidos, entornos y
  mensajes pendientes.
- [ ] `PG-4.09` Límites de tareas y de colas como terminaciones definidas.
- [ ] `PG-4.10` 10 000 agendas sembradas reproducen sus observables, con cero diferencias.
- [ ] `PG-4.11` Eventos de tarea observables (identidad, padre, espera, reanudación, canal) disponibles para la app.
- [ ] `PG-4.12` E-PG-06 ejecutado; métrica candidata de tareas medida; async nativo en AOT no se anuncia si falla.

Fuera de alcance: paralelismo CPU, actores públicos, tareas desprendidas y mutex en el lenguaje.

Plan detallado: `fase-pg-4-plan-ejecucion.md`, pendiente de crear al iniciar la fase.

Cierre común (definiciones en §4.0):

- [ ] `PG-4.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [ ] `PG-4.C02` Plan detallado creado según §5 y revisado por la persona.
- [ ] `PG-4.C03` SPEC-FIRST y congelamiento respetados.
- [ ] `PG-4.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [ ] `PG-4.C05` Tests feliz, infeliz y límite en carpetas espejo.
- [ ] `PG-4.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [ ] `PG-4.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [ ] `PG-4.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [ ] `PG-4.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [ ] `PG-4.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [ ] `PG-4.C11` Tests y verificadores de los miembros afectados en verde.
- [ ] `PG-4.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [ ] `PG-4.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-4

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| | | | |

Revisión Git de cierre: · Verificadores ejecutados: · Pendientes justificados: · Decisiones de la persona:

### 4.7 PG-5 · Biblioteca y HTTP

Objetivo: biblioteca estándar bilingüe y cliente HTTP seguro sobre adaptadores nativos y web. Requisitos R-07–R-13;
capacidades C-07, C-08, C-10; riesgos K-07, K-09; experimentos E-PG-07, E-PG-09; ADR-02, ADR-06.

Puntos a cumplir:

- [ ] `PG-5.01` Biblioteca de texto, bytes, números vigentes, colecciones, E/S, tiempo, JSON y tareas, con un símbolo
  canónico y facetas es/en generadas.
- [ ] `PG-5.02` Cliente HTTP/HTTPS: métodos explícitos, estado, cabeceras, cuerpo de texto o binario, y 4xx/5xx como
  respuesta, no como error.
- [ ] `PG-5.03` Límites de bytes comprimidos y descomprimidos, profundidad JSON, peticiones pendientes y tiempo externo.
- [ ] `PG-5.04` TLS no desactivable por código ordinario, redirecciones solo dentro del permiso, credenciales retiradas al
  cambiar de origen, proxies del entorno no heredados y política contra SSRF.
- [ ] `PG-5.05` Sin reintento automático de operaciones no idempotentes; estado incierto registrado.
- [ ] `PG-5.06` Adaptador nativo elegido tras validar licencia, tamaño, plataformas y permisos; adaptador Fetch con
  capacidades web declaradas.
- [ ] `PG-5.07` Servidor de prueba local controlado; el corpus no depende de Internet.
- [ ] `PG-5.08` `PERF.ARTIFACT.SIZE` se mantiene: sin dependencias de red en el módulo móvil fuera de presupuesto.
- [ ] `PG-5.09` Casos integradores de ENT-1 relativos a archivos, JSON, HTTP con tareas y biblioteca bilingüe en
  verde, incluidos entrada vacía, permiso denegado, cancelación y agotamiento.
- [ ] `PG-5.10` E-PG-07 y la parte de red de E-PG-09 ejecutados; métrica candidata de HTTP medida.

Fuera de alcance: servidor HTTP, sockets arbitrarios, FFI y matemática ampliada sin demanda.

Plan detallado: `fase-pg-5-plan-ejecucion.md`, pendiente de crear al iniciar la fase.

Cierre común (definiciones en §4.0):

- [ ] `PG-5.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [ ] `PG-5.C02` Plan detallado creado según §5 y revisado por la persona.
- [ ] `PG-5.C03` SPEC-FIRST y congelamiento respetados.
- [ ] `PG-5.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [ ] `PG-5.C05` Tests feliz, infeliz y límite en carpetas espejo.
- [ ] `PG-5.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [ ] `PG-5.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [ ] `PG-5.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [ ] `PG-5.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [ ] `PG-5.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [ ] `PG-5.C11` Tests y verificadores de los miembros afectados en verde.
- [ ] `PG-5.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [ ] `PG-5.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-5

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| | | | |

Revisión Git de cierre: · Verificadores ejecutados: · Pendientes justificados: · Decisiones de la persona:

### 4.8 PG-6A · Servicio y extensión inicial

Objetivo: servicio de proyecto completo y extensión VS Code de escritorio instalable. Requisitos R-03, R-14, R-15, R-18,
R-20; capacidades C-11, C-12; riesgos K-03, K-10; experimento E-PG-02; ADR-08, ADR-09.

Puntos a cumplir:

- [ ] `PG-6A.01` La persona decide CF-20 y la ruta del miembro nuevo en `apps/`, su cadena de herramientas y la licencia
  de la extensión.
- [ ] `PG-6A.02` README y archivo de reglas del miembro nuevo escritos antes de su código, con verificador de comentarios
  propio y su caso negativo.
- [ ] `PG-6A.03` Servicio de workspace: instantánea de proyecto, archivos cerrados, invalidación por dependencia y
  resincronización ante pérdida de eventos.
- [ ] `PG-6A.04` LSP anuncia solo lo implementado: carpetas y configuración de workspace, diagnósticos relacionados,
  rename con prepareRename atómico y versionado, referencias, símbolos, tokens semánticos, formato y cancelación.
- [ ] `PG-6A.05` Contrato de configuración declarativo con precedencia definida y sin secretos en archivos versionados.
- [ ] `PG-6A.06` Gramática de resaltado generada desde el corpus, con verificador de obsolescencia (`GEN-NO-HAND-COPY`).
- [ ] `PG-6A.07` Extensión de escritorio: cliente LSP, comandos de comprobar, ejecutar, detener, entrada, elegir entrada,
  formatear, traducir y migrar; ningún parser normativo en el cliente; nada se ejecuta al abrir un proyecto.
- [ ] `PG-6A.08` Ayuda de PG-H integrada en hover y en el comando de explicar.
- [ ] `PG-6A.09` Resultados equivalentes desde dos clientes LSP distintos.
- [ ] `PG-6A.10` E-PG-02 completo, con sesiones de 100 archivos/10 000 líneas, Unicode/UTF-16 y ediciones obsoletas.
- [ ] `PG-6A.11` VSIX instalado desde cero ejecuta un proyecto sencillo.

Fuera de alcance: publicación en Marketplace, DAP y variante web.

Plan detallado: `fase-pg-6a-plan-ejecucion.md`, pendiente de crear al iniciar la fase.

Cierre común (definiciones en §4.0):

- [ ] `PG-6A.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [ ] `PG-6A.C02` Plan detallado creado según §5 y revisado por la persona.
- [ ] `PG-6A.C03` SPEC-FIRST y congelamiento respetados.
- [ ] `PG-6A.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [ ] `PG-6A.C05` Tests feliz, infeliz y límite en carpetas espejo.
- [ ] `PG-6A.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [ ] `PG-6A.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [ ] `PG-6A.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [ ] `PG-6A.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [ ] `PG-6A.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [ ] `PG-6A.C11` Tests y verificadores de los miembros afectados en verde.
- [ ] `PG-6A.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [ ] `PG-6A.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-6A

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| | | | |

Revisión Git de cierre: · Verificadores ejecutados: · Pendientes justificados: · Decisiones de la persona:

### 4.9 PG-6B · Depuración y web

Objetivo: depuración interoperable en escritorio, variante web de la extensión y evaluación telefónica honesta.
Requisitos R-09, R-15, R-16; capacidades C-08, C-12, C-13; riesgos K-10, K-11; experimento E-PG-08; ADR-08, ADR-10.

Puntos a cumplir:

- [ ] `PG-6B.01` Ubicación y capa del adaptador DAP decididas y declaradas; el servicio no importa VM ni DAP.
- [ ] `PG-6B.02` DAP de escritorio con el mínimo de ADR-08: evaluate puro, tareas como hilos lógicos, revisión y
  horizonte respetados, StepBack solo en VM y nunca anunciado en AOT.
- [ ] `PG-6B.03` Retroceder o consultar el pasado nunca reenvía HTTP ni reescribe archivos.
- [ ] `PG-6B.04` Variante web: servicio en un Worker y ejecución en otro Worker separado, con borde LSP aprobado, lotes
  cancelables y enteros i64 sin pérdida.
- [ ] `PG-6B.05` Capacidades web explícitas (Fetch, sistema de archivos del editor) y capacidades ausentes visibles.
- [ ] `PG-6B.06` Pruebas en host de navegador en los navegadores documentados.
- [ ] `PG-6B.07` E-PG-08 en Safari iPhone y Chrome Android físicos, con resultados aportados por la persona.
- [ ] `PG-6B.08` Informe móvil que distingue cobertura real de limitaciones, y la persona decide CF-14.
- [ ] `PG-6B.09` Métrica candidata web medida y `PERF.ARTIFACT.SIZE` respetado.

Fuera de alcance: IDE propio, ejecución remota y AOT en teléfono.

Plan detallado: `fase-pg-6b-plan-ejecucion.md`, pendiente de crear al iniciar la fase.

Cierre común (definiciones en §4.0):

- [ ] `PG-6B.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [ ] `PG-6B.C02` Plan detallado creado según §5 y revisado por la persona.
- [ ] `PG-6B.C03` SPEC-FIRST y congelamiento respetados.
- [ ] `PG-6B.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [ ] `PG-6B.C05` Tests feliz, infeliz y límite en carpetas espejo.
- [ ] `PG-6B.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [ ] `PG-6B.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [ ] `PG-6B.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [ ] `PG-6B.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [ ] `PG-6B.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [ ] `PG-6B.C11` Tests y verificadores de los miembros afectados en verde.
- [ ] `PG-6B.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [ ] `PG-6B.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-6B

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| | | | |

Revisión Git de cierre: · Verificadores ejecutados: · Pendientes justificados: · Decisiones de la persona:

### 4.10 PG-A · App y sintaxis estática

Objetivo: la app enseña la sintaxis nueva con un solo archivo editable y vistas fieles. Requisitos R-03, R-05–R-08,
R-17–R-20; capacidad C-15; riesgos K-18, K-19; experimento E-PG-12 (parte estática); ADR-12.

Puntos a cumplir:

- [ ] `PG-A.01` Modo de archivo único con preludio fijado por edición, como operación pública del núcleo comprobable
  desde CLI y conformidad; sin manifiesto ni imports obligatorios, y sin migrar archivos 2026 al abrirlos.
- [ ] `PG-A.02` Modelos de dominio para interfaz, realización, restricción genérica, variante, captura, iteración y ámbito.
- [ ] `PG-A.03` Interfaz con marca, realización con línea discontinua y triángulo hueco, y contrato incumplido visible
  como inválido.
- [ ] `PG-A.04` Matriz de cobertura construcción → vista (ordinograma, estructograma, tipos, tabla y ayuda) con
  verificador y caso negativo; ningún nodo desconocido cae en una forma genérica.
- [ ] `PG-A.05` Imports o exports pegados se analizan y explican sin resolverse, descargarse ni ejecutarse.
- [ ] `PG-A.06` Código equivalente: cada destino declara equivalencia comprobada, explicación ilustrativa o no
  disponibilidad (CF-18).
- [ ] `PG-A.07` Pruebas de identidades, relaciones, geometría y accesibilidad, más pruebas con el puente real.
- [ ] `PG-A.08` Ayuda de PG-H disponible para cada construcción nueva.
- [ ] `PG-A.09` Parte estática de E-PG-12 con resultados aportados por la persona o diferida por ella.

Fuera de alcance: gestor de proyectos, edición gráfica inversa y control de rebobinado.

Plan detallado: `fase-pg-a-plan-ejecucion.md`, pendiente de crear al iniciar la fase.

Cierre común (definiciones en §4.0):

- [ ] `PG-A.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [ ] `PG-A.C02` Plan detallado creado según §5 y revisado por la persona.
- [ ] `PG-A.C03` SPEC-FIRST y congelamiento respetados.
- [ ] `PG-A.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [ ] `PG-A.C05` Tests feliz, infeliz y límite en carpetas espejo.
- [ ] `PG-A.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [ ] `PG-A.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [ ] `PG-A.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [ ] `PG-A.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [ ] `PG-A.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [ ] `PG-A.C11` Tests y verificadores de los miembros afectados en verde.
- [ ] `PG-A.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [ ] `PG-A.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-A

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| | | | |

Revisión Git de cierre: · Verificadores ejecutados: · Pendientes justificados: · Decisiones de la persona:

### 4.11 PG-B · App y tareas observables

Objetivo: la app enseña asincronía, efectos y concurrencia sin falsear causalidad ni simultaneidad. Requisitos R-09–R-13,
R-19, R-20; capacidad C-15; riesgos K-18, K-19; experimento E-PG-12 (parte dinámica); ADR-12.

Puntos a cumplir:

- [ ] `PG-B.01` Evento global seleccionado más foco, pila y estado por tarea; dos tareas sobre el mismo subprograma no
  comparten marcos.
- [ ] `PG-B.02` Tres proyecciones: flujo local por tarea con marcas de espera, estructura de creación y unión, y ventana
  paginada de eventos y estados.
- [ ] `PG-B.03` Paso global y paso por tarea con la semántica de ADR-12, sin congelar otras tareas ni alterar el
  planificador.
- [ ] `PG-B.04` Escenarios de efectos simulados rotulados como tales, y entradas identificadas por tarea y solicitud.
- [ ] `PG-B.05` Las mismas entradas y la misma cinta producen las mismas proyecciones.
- [ ] `PG-B.06` Cancelación, error, canal lleno y bloqueo representados por su camino normativo.
- [ ] `PG-B.07` Ningún temporizador de presentación decide la agenda; los pintores no esperan efectos.
- [ ] `PG-B.08` Pruebas con el puente real y no solo con dobles.
- [ ] `PG-B.09` Parte dinámica de E-PG-12 con resultados aportados por la persona o diferida por ella; métrica candidata
  de proyección medida.

Fuera de alcance: E/S real sin concesión del host y retroceso de producto no aprobado.

Plan detallado: `fase-pg-b-plan-ejecucion.md`, pendiente de crear al iniciar la fase.

Cierre común (definiciones en §4.0):

- [ ] `PG-B.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [ ] `PG-B.C02` Plan detallado creado según §5 y revisado por la persona.
- [ ] `PG-B.C03` SPEC-FIRST y congelamiento respetados.
- [ ] `PG-B.C04` Reglas nuevas con casos o propiedades y vínculos como datos.
- [ ] `PG-B.C05` Tests feliz, infeliz y límite en carpetas espejo.
- [ ] `PG-B.C06` Capas declaradas, imports permitidos y límites de tamaño.
- [ ] `PG-B.C07` Sin comentarios ni TODO; código en inglés; Rust sin pánicos ni `unsafe` no declarado.
- [ ] `PG-B.C08` README y reglas de los miembros afectados actualizados, sin citar `docs/`.
- [ ] `PG-B.C09` Fichas de ayuda y datos de proyección de la sintaxis nueva, o justificación.
- [ ] `PG-B.C10` Riesgos revisados y experimentos con procedencia o diferidos por la persona.
- [ ] `PG-B.C11` Tests y verificadores de los miembros afectados en verde.
- [ ] `PG-B.C12` Commit sin atribución de IA y push ordinario comprobado a la rama única.
- [ ] `PG-B.C13` Resumen completo, informe a la persona y parada.

#### Resumen de PG-B

| Punto | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| | | | |

Revisión Git de cierre: · Verificadores ejecutados: · Pendientes justificados: · Decisiones de la persona:

### 4.12 PG-7 · Calificación y distribución

Objetivo: demostrar ENT-1 completo y dejarlo listo para distribuir. Requisitos R-01–R-20; capacidad C-14; riesgos K-01,
K-12 y revisión final de todos.

Puntos a cumplir:

- [ ] `PG-7.01` Conformidad completa de todos los sujetos sin regresiones no exentas, con procedencia.
- [ ] `PG-7.02` Presupuestos de rendimiento candidatos aceptados o rechazados por la persona, con medición reproducible.
- [ ] `PG-7.03` Las 16 capacidades C-01–C-16 cumplen su criterio de salida.
- [ ] `PG-7.04` Trazabilidad bidireccional sin huecos: punto base, requisito, capacidad, fase y paquete.
- [ ] `PG-7.05` Casos negativos de K-05, K-06, K-07 y K-13 reproducibles y revisados; riesgos residuales aceptados por la
  persona.
- [ ] `PG-7.06` Documentación de uso bilingüe del entregable.
- [ ] `PG-7.07` Licencia implantada y licencias de dependencias y artefactos comprobadas.
- [ ] `PG-7.08` Artefactos por plataforma verificables con hashes y capacidades negociadas documentadas.
- [ ] `PG-7.09` Todos los casos integradores de ENT-1 en verde.
- [ ] `PG-7.10` Publicación en canales externos solo con aprobación explícita de la persona, o registrada como no
  realizada.
- [ ] `PG-7.11` Informe final de ENT-1 y propuesta de qué capacidad futura FUT-xx evaluar, sin activarla.

Fuera de alcance: capacidades FUT-01–FUT-14.

Plan detallado: `fase-pg-7-plan-ejecucion.md`, pendiente de crear al iniciar la fase.

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

## 5. Reglas para crear cada `fase-<id>-plan-ejecucion.md`

### 5.1 Nombre, lugar y momento

- Ruta: esta misma carpeta. Nombre exacto: `fase-<id>-plan-ejecucion.md`, con `<id>` en minúsculas tomado de la tabla
  de §3 (`pg-0`, `pg-h`, `pg-1` … `pg-6a`, `pg-6b`, `pg-a`, `pg-b`, `pg-7`).
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

- Autoridad explícita: denegación por defecto, capacidades no amplificables y ningún acceso ambiental a `cwd`, variables
  de entorno, proxies o credenciales.
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
| PG-2 | Sin iniciar | Sí, pendiente de revisión (C02) | | D-PG2-01 resuelta el 2026-10-24: opción A, reemplazo en 2026 con migración asistida; lista de esperados por autorizar |
| PG-3 | Sin iniciar | No | | |
| PG-4 | Sin iniciar | No | | |
| PG-5 | Sin iniciar | No | | |
| PG-6A | Sin iniciar | No | | |
| PG-6B | Sin iniciar | No | | |
| PG-A | Sin iniciar | No | | |
| PG-B | Sin iniciar | No | | |
| PG-7 | Sin iniciar | No | | |
