# E-PG-12 · Material y evidencia dinámica

## 1. Alcance y oráculo

Esta campaña cubre la proyección de tareas de PG-B: identidad de tareas que comparten subprograma, espera frente a avance,
error recuperable, canal lleno, `Elegir` empatado, cancelación del anfitrión y revisión nueva. La evidencia estática de PG-A
(interfaces, `Resultado`, captura, iteración) vive en [e-pg-12-estatico-evidencia.md](e-pg-12-estatico-evidencia.md) y no se
mezcla con esta. Ninguna prueba automatizada se presenta como comprensión pedagógica.

Las fuentes están en `apps/pseudolearn_app/test/fixtures/task_scenes/`, un archivo por escena e idioma
(`<escena>_es.pseudo` con el perfil `classicSpanish` y `<escena>_en.pseudo` con `english`). El test
`apps/pseudolearn_app/test/engine/rust/task_scenes_protocol_test.dart` las ejecuta por FRB real, con la compuerta de
efectos en manual, en ambos perfiles. Desde la reformulación de PG-B no existe ningún anfitrión simulado: la espera que la
compuerta manual resuelve la responde el anfitrión real del puente, y las escenas con red usan un servidor HTTP de loopback
del propio test (`rust_real_task_host_test.dart`).

### 1.1 Inventario de escenas y oráculo derivado de las reglas

Esperado derivado de la regla antes de ejecutar; el protocolo automatizado compara cada fila con lo que informa el motor y
ningún esperado se copió de la salida.

| Escena | Estímulo | Esperado según la regla | Regla |
|---|---|---|---|
| `identities` | Dos tareas llaman a `Worker`; con argumento 1 espera un temporizador y con 2 escribe | La tarea 1 queda sin terminar con el efecto `request_timer` pendiente, la tarea 2 completa, la raíz espera en la unión, la salida es `2`; al resolver el efecto la salida es `2`, `1` y ambas completan. Las dos comparten el nombre de subprograma y sus resultados difieren | `ENG.TASK.AGENDA#R1/R2`, `LANG.TASK.SUSPENSION#R5/R8` |
| `failure` | Una hija espera en un canal y otra devuelve `Error` | Primer error por terminación: la que espera queda `cancelled`, la que falla completa con `outcome = error`, la raíz completa y no hay salida | `LANG.TASK.SCOPE#R6–R16` |
| `channel` | Un productor envía tres valores a un canal de capacidad 1 mientras la raíz espera recibir | El primer envío entrega al receptor en espera, el segundo se encola y el tercero espera por capacidad (`task_suspended` con causa `channel_send`); la salida conserva el orden `81`, `82`, `83` | `LANG.TASK.CHANNEL#R2–R6` |
| `select` | `Elegir` sobre un canal cerrado con dos ramas listas | Gana la primera rama textual: salida `81`, sin `82` | `LANG.TASK.CHANNEL#R7/R8` |
| `cancellation` | Un efecto pendiente anidado dos tareas por debajo se corta desde el anfitrión | La terminación es `cancelled`; la raíz queda cancelada por el anfitrión y las dos hijas interrumpidas por él; la salida es solo `before` (las limpiezas de usuario no se ejecutan) y la cinta queda incompleta | `LANG.TASK.SCOPE#R6–R13`, `RT.HOST.INTERFACE#R4` |
| `live_timer` | Una hija espera el temporizador real (50 ms) y la hermana imprime | La hermana imprime `sibling` antes de que el temporizador responda; después `timer` y `done`; ambas completan y la unión termina; la reproducción de la cinta grabada no llama al anfitrión | `LANG.TASK.SUSPENSION#R5/R8`, `ENG.EFFECT.TAPE#R1`–`R6`, `RT.HOST.INTERFACE#R3` |
| `live_fetch` | Una hija hace GET a un servidor de loopback que tarda 100 ms y la hermana imprime | `sibling`, `200`, `done`; el servidor recibe una petición; la reproducción no abre el anfitrión ni repite la petición | `LIB.HTTP#R1`, `ENG.EXEC.EFFECT-ORDER#R4/R5` |
| `live_http` | Temporizador de 50 ms y GET de 100 ms en dos hijas más una hermana | `sibling`, `timer`, `200`, `done` (el temporizador responde antes porque dura menos); los dos resultados entran en una misma tanda y toda la historia sigue consultable | `ENG.EXEC.EFFECT-ORDER#R4/R5`, `ENG.TRACE.EVENTS#R8` |
| `live_order` | Dos GET, `/slow` tarda 150 ms y `/fast` 100 ms | `fast`, `slow`, `done`: el resultado llega en orden distinto al de petición, la cinta lo marca con `delivery_seq` y se reproduce igual | `API.EXECUTE#R6`, `ENG.EXEC.EFFECT-ORDER#R4/R5` |
| `revision` | Se ejecuta `identities`, se cambia un argumento y se ejecuta de nuevo | El recurso, la revisión y el identificador de ejecución cambian; la salida nueva es `5`; todos los eventos retenidos pertenecen a la revisión nueva | `ENG.TRACE.EVENTS#R2`, `API.WIRE-FORMAT#R4` |

Observación derivada de la corrida: una tarea que espera un efecto no aparece como `suspended` en la punta cuando se pide
el efecto; el motor la informa en `running` y la raíz en `suspended` en la unión. El estado `waiting` de la consulta de
estado se lee en el evento `task_suspended` de esa tarea, y la pregunta humana 2 («¿cuál espera y por qué?») debe basarse
en la tabla de tareas y en ese evento, no en la punta de la ejecución.

### 1.2 Guion con evento exacto de cada pregunta

Los números de evento son los de la traza de `identities` en español observada por el protocolo: 0–7 crean y dejan lista cada
hija, 8 es `task_suspended` de la raíz en la unión, 9 reanuda a la tarea 1, 14 es `task_suspended` de la tarea 1 con causa
`effect`, 15 reanuda a la tarea 2 y 21 es su salida `2`. El inglés tiene la misma forma. Los eventos posteriores a la
resolución del efecto (entrega y fin) se fijan al preparar cada sesión leyendo la traza completa; este documento no los
adelanta.

| Pregunta | Evento a mostrar | Respuesta derivada |
|---|---|---|
| 1. ¿Qué tarea ejecuta? | Evento 15 (`task_resumed`, tarea 2) | La tarea 2; la raíz y la tarea 1 no ejecutan |
| 2. ¿Cuál espera y por qué? | Evento 14 (`task_suspended`, tarea 1, causa `effect`) | La tarea 1, por el temporizador que pidió; la raíz espera la unión |
| 3. ¿Qué valores corresponden a cada hija del mismo subprograma? | Evento 21 (`output`, tarea 2) | La tarea 2 trabajó con 2 y ya imprimió `2`; la tarea 1 conserva 1 |
| 4. ¿Entregar el efecto ya ejecutó la continuación? | Evento de entrega del efecto a la tarea 1 (índice por fijar en la sesión) | No: la entrega deja lista a la tarea; la continuación corre cuando la agenda la reanuda |
| 5. ¿Por qué no terminó la unión? | Eventos 8 a 21 | La tarea 1 no terminó |
| 6. ¿Por qué un canal lleno causa espera y cuándo progresa? | `task_suspended` con causa `channel_send` de `channel` | El envío sin capacidad espera hasta que un receptor libere un lugar |
| 7. ¿Cuál es la diferencia entre cancelación y error? | Escenas `failure` y `cancellation` | El error es un resultado recuperable de una hija; la cancelación del anfitrión corta sin limpiezas |
| 8. ¿La pantalla demuestra instrucciones simultáneas en varios núcleos? | Toda la escena | No: muestra una agenda cooperativa y un eje lógico de eventos |

## 2. Comprobaciones automatizadas

La campaña automatizada se ejecuta en este orden:

1. `task_scenes_protocol_test.dart`: seis escenas por perfil (12 pruebas) contra el puente nativo, y `rust_real_task_host_test.dart`: las cuatro escenas `live_*` por perfil (8 pruebas) con servidor HTTP de loopback y temporizador real, con reproducción de la cinta grabada y contador de llamadas al anfitrión que no cambia.
2. `rust_task_bridge_integration_test.dart`: integración de ejecución, consulta de una tarea suspendida, entradas rechazadas y
   liberación de recursos.
3. `task_projection_summary_test.dart`: el arnés rechaza muestra incompleta, menos procesos, resultado divergente,
   configuración de reloj distinta, tiempo no medido, manifiesto ausente o incompleto y escenas que no declaran el anfitrión
   real (`host` distinto de `real`, claves o valores con «simulat», identidad o hash ausentes, lista vacía).
4. Los tests de proyección, estado, cubit y vistas de PG-B.02 a PG-B.07 ya verifican identidad, geometría, tabla,
   navegación y semántica accesible.

Estos tests demuestran que la proyección no mezcla identidades y que el estado vigente es el del motor; no prueban que una
persona entienda la pantalla.

## 3. Material para el estudio humano

### Preparación y asignación

- Reclutar al menos 12 principiantes con consentimiento gestionado por la persona responsable. Este repositorio no recluta
  ni contiene datos de participantes.
- No iniciar sesiones sin consentimiento ni pedir datos identificables al guardar resultados. El código de participante se
  asigna fuera del repositorio.
- Separar el perfil del documento de la lengua de interfaz. Asignar tres plazas a cada una de las cuatro celdas (perfil
  es/en × interfaz es/en) e informar el denominador por celda, sin combinarlas.
- Mostrar la escena `identities` con el idioma asignado; las demás escenas se presentan como su evento exacto.
- Contrabalancear con los mismos diez órdenes de la evidencia estática, sustituyendo T1–T5 por Q1–Q5 (abajo), y repetir los
  órdenes 1 y 2 para las plazas 11 y 12. Registrar el orden realmente usado.

| Orden | Secuencia | Orden | Secuencia |
|---:|---|---:|---|
| 1 | Q1, Q2, Q5, Q3, Q4 | 6 | Q4, Q3, Q5, Q2, Q1 |
| 2 | Q2, Q3, Q1, Q4, Q5 | 7 | Q5, Q4, Q1, Q3, Q2 |
| 3 | Q3, Q4, Q2, Q5, Q1 | 8 | Q1, Q5, Q2, Q4, Q3 |
| 4 | Q4, Q5, Q3, Q1, Q2 | 9 | Q2, Q1, Q3, Q5, Q4 |
| 5 | Q5, Q1, Q4, Q2, Q3 | 10 | Q3, Q2, Q4, Q1, Q5 |

### Preguntas y clave previa

Cada pregunta vale dos puntos, uno por proposición. La meta candidata de al menos 80 % se informa para la pregunta de espera
frente a paralelismo, por idioma de interfaz y por perfil, sin promediarla con las demás.

| Pregunta | Español | English | Respuesta esperada |
|---|---|---|---|
| Q1 | ¿Qué tarea está ejecutando en este evento y cuál está esperando? | Which task is running at this event and which one is waiting? | Ejecuta la tarea mostrada por `task_resumed`; espera la que muestra `task_suspended`, y la raíz espera la unión |
| Q2 | ¿Qué valor tiene cada hija del mismo subprograma? | Which value does each child of the same subprogram have? | Cada hija tiene su propio valor; coinciden el subprograma y el nombre, no los valores |
| Q3 | Si se entrega el resultado de un efecto, ¿ya se ejecutó lo que sigue? ¿Por qué no terminó la unión? | If an effect result is delivered, has the next code already run? Why has the join not finished? | No; la tarea solo queda lista. La unión espera a todas las hijas |
| Q4 | ¿Por qué se detiene el emisor de un canal lleno y cuándo continúa? | Why does the sender of a full channel stop, and when does it continue? | Espera capacidad; continúa cuando un receptor libera un lugar |
| Q5 | ¿Cuál es la diferencia entre cancelar y fallar? ¿La pantalla muestra instrucciones en varios núcleos a la vez? | What is the difference between cancelling and failing? Does the screen show instructions on several cores at once? | La cancelación del anfitrión corta sin limpiezas; el error es un resultado de una hija. No: es una agenda cooperativa con eje lógico |

### Hoja vacía de captura

Evidencia de participantes: [ ] Doce sesiones consentidas y registradas. Estado actual: **Diferido**.

| Código seudónimo | Consentimiento verificado fuera del repositorio | Experiencia inicial | Perfil es/en | Interfaz es/en | Orden |
|---|---|---|---|---|---|
|  | Sí / no |  |  |  |  |

| Pregunta | Respuesta anonimizada | Puntaje 0–2 | Ayuda solicitada | Tiempo, si aplica |
|---|---|---:|---|---:|
| Q1 |  |  |  |  |
| Q2 |  |  |  |  |
| Q3 |  |  |  |  |
| Q4 |  |  |  |  |
| Q5 |  |  |  |  |

## 4. Resultado y procedencia

La parte automatizada se completó; la evidencia humana queda **Diferido** conforme a la decisión del 2026-10-22, que declara
complementarios y no bloqueantes los estudios con participantes de E-PG-08/10/12 (alcance literal: E-PG-12 sin distinguir su
parte estática o dinámica). No se recibieron participantes, consentimiento ni respuestas; no se afirma comprensión ni eficacia
pedagógica, y la meta candidata de al menos 80 % no se evalúa. El kit de §3 queda listo.

### Registro automatizable

| Campo | Resultado |
|---|---|
| Fecha local | 2026-11-03, America/Lima (PG-B.26; reemplaza la campaña del 2026-11-02 sobre `d762c471`, conservada en `build/task-projection-pg-b-09/`) |
| Revisión base | `e6c397bc8442d89f8c3dc3170084ceffb7d872ec` más los cambios sin confirmar de PG-B.25/.26, identificados por `working_tree_diff_sha256` (excluye `docs/`) en el manifiesto |
| Host/build | Mac14,3, macOS 27.0.1, 8 CPUs lógicas, 16 GiB; Flutter 3.47.5, Dart 3.13.4, modo test (no Release) |
| Procesos / iteraciones | 10 procesos independientes / 30 muestras por carga y proceso; 1500 muestras |
| Resolución del reloj | Ticks monotónicos calibrados por proceso; resolución mínima observada de 41 ticks (aprox. 41 ns) |
| Manifiesto y resumen | `e-pg-12-dinamico-manifiesto.json` (versionado); el resumen recalculable `resumen.json` se regenera con el procedimiento del README de la app (SHA-256 de esta corrida `6db3b6f26b22a6c96075ece4b6943c21ff045e8a0ed412ca48e894edc2767a1a`) |
| Crudos | `apps/pseudolearn_app/build/task-projection/raw/` (`process-01.jsonl` a `process-10.jsonl` y sus `.log`); salida regenerable, fuera de git y de `docs/` |
| Estimadores | p50 y p95 por rango más cercano; IC bootstrap del 95 % (10 000 remuestreos, semilla 20261102) sobre medias por proceso; sin descartes |
| Límites | No mide rasterización ni dispositivo; modo test; el candidato de 50 ms no es un presupuesto aprobado |

Resultados descriptivos por carga (ms, 300 muestras por carga). «Puro» proyecta la ventana ya leída a flujo y estructura;
«integrado» lee la ventana al motor, decodifica y proyecta el flujo. Son intervalos distintos y no se suman:

| Tareas | Ventana pedida | Eventos retenidos | Visibles | Carriles | Puro p50 / p95 | Integrado p50 / p95 | IC95 medias integrado | RSS máx. muestreado (B) |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 0 | 100 | 3 | 3 | 1 | 0.013 / 0.106 | 0.082 / 0.384 | 0.103–0.113 | 241,483,776 |
| 1 | 100 | 15 | 15 | 2 | 0.018 / 0.138 | 0.305 / 0.379 | 0.319–0.325 | 241,483,776 |
| 10 | 100 | 114 | 100 | 11 | 0.043 / 0.089 | 1.819 / 1.992 | 1.851–1.88 | 241,483,776 |
| 100 | 100 | 1104 | 100 | 15 | 0.058 / 0.116 | 2.552 / 2.779 | 2.578–2.648 | 242,253,824 |
| 100 | 4096 | 1104 | 1104 | 101 | 0.377 / 1.091 | 21.619 / 23.592 | 21.737–21.958 | 242,532,352 |

Lectura y límites de la medición:

- El caso de 100 eventos y 100 tareas del candidato no es literalmente alcanzable: cada tarea creada consume cuatro eventos
  en la raíz, así que una ventana de 100 eventos muestra 15 carriles. Las cien tareas son visibles solo con la ventana máxima
  de 4096 eventos (1104 retenidos, 101 carriles): su p95 puro es 1.091 ms y el integrado 23.592 ms. Con la ventana de 100
  eventos el p95 integrado es 2.779 ms. Ambos están por debajo del candidato de 50 ms en este host y en modo test; eso no es
  una aprobación del umbral, que corresponde a la persona.
- La mayor parte del coste integrado está en la lectura y decodificación, no en la proyección: la proyección pura de la
  ventana máxima es unas veinte veces menor.
- La RSS es del proceso Flutter completo (arranque y runner incluidos); es una cota inferior del pico y no se atribuye a una
  etapa. No se midió la latencia de detención ni la rasterización: quedan como medición pendiente.
- No se compara con una implementación previa porque no existe una proyección de tareas equivalente anterior; se informa el
  coste absoluto.
- No se buscaron puntos de cambio: con modo test y un host compartido no se afirma estado estacionario.

