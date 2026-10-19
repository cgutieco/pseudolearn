# 08 · Decisiones, riesgos y cambios de reglas

> **Estado:** las decisiones asumidas y las propuestas asignadas a R0 están aprobadas por la persona
> responsable el 2026-10-14. Los cambios de reglas de R0 se aplican en esta fase. Las decisiones y
> modificaciones de otras fases conservan su dependencia y requieren autorización de esa fase.

---

## 1. Decisiones

### 1.1 Tomadas en conversación (2026-10-13)

| ID      | Decisión                                                                                                   | Sustituye o resuelve                    |
|---------|------------------------------------------------------------------------------------------------------------|-----------------------------------------|
| ADR-001 | Núcleo completo en Rust (A2), con el núcleo Dart en paralelo como `reference` hasta completar la paridad     | D-05; REC-05 (A3) queda descartada       |
| —       | El foco del proyecto es el lenguaje; la app es un consumidor                                                | Matiz de D-02 y D-03                     |
| —       | Las especificaciones ejecutables son la fuente de verdad; orden especificación → casos → tests → código     | D-09 en su forma R2                      |
| —       | Los tests del núcleo Dart dejan de ser normativos; el corpus los sustituye como oráculo                      | —                                        |
| —       | Código en inglés, documentación y especificaciones en español; nombres semánticos; cero comentarios        | `LANG-EN-CODE`, `LANG-ES-DOCS`, `QUALITY-NO-COMMENTS`; nueva `QUALITY-SEMANTIC-NAMES` |
| —       | Se podan las funciones a medias y el código muerto: lo que no tiene especificación no se porta              | Catálogo de poda |

### 1.2 Asumidas de la investigación («el resto de la documentación es coherente»), aprobadas en R0

| ID   | Recomendación que el plan asume                                                       | Fase que la necesita |
|------|----------------------------------------------------------------------------------------|----------------------|
| D-02 | PseudoLearn es destino, con el orden de desempate de [04](../04-filosofia-y-modelo-del-lenguaje.md) §1.2 | R2 |
| D-03 | Propósito general en sentido (a): aplicaciones, herramientas, servicios, bibliotecas   | R3 (`RT.HOST.INTERFACE`) |
| D-04 | Memoria administrada por trazado; `Registro` como tipo valor en el futuro              | R3 (`MEM.*`)         |
| D-11 | Ediciones por paquete; la vigente es la primera numerada                               | R2 (`LANG.EDITION.MODEL`) |
| D-18 | Se especifica el contrato de observación                                              | R3 (`ENG.*`)         |
| D-20 | Identificadores de especificación en inglés ASCII; títulos en español                  | R1                   |
| D-22 | Los hallazgos se resuelven como casos. Con la reescritura se resuelven **en Rust**; en `reference` quedan como `exento` | R2 |
| D-23 | Verificación local de todos los miembros; comprobaciones remotas puntuales manuales y autorizadas                                | R0                   |

### 1.3 Nuevas, propuestas por este plan

| ID     | Pregunta                                                       | Propuesta                                                                                    | Ver                                           | Fase |
|--------|----------------------------------------------------------------|----------------------------------------------------------------------------------------------|-----------------------------------------------|------|
| D-P01  | ¿En qué lenguaje se escribe `see`? (revisa D-10)               | Rust, en `packages/pseudolearn_spec`, sin depender de ningún miembro                          | [05](05-sistema-de-especificaciones.md) §1    | R0   |
| D-P02  | ¿Primer backend nativo? (resuelve D-06)                        | Cranelift; la RI se diseña para admitir LLVM; E-NR1 en R6 decide si se añade                  | [00](00-adr-001-nucleo-en-rust.md) §2         | R0   |
| D-P03  | ¿Cómo habla `see` con los sujetos?                             | `see-protocol/1`: JSON por líneas sobre la entrada y salida estándar                          | [05](05-sistema-de-especificaciones.md) §3    | R1   |
| D-P04  | ¿Cómo se expresan las capas en Rust?                           | Un crate por capa; `architecture.yaml` declara las dependencias permitidas                    | [04](04-arquitectura-del-workspace-rust.md) §2 | R0  |
| D-P05  | ¿Cómo llegan los datos del corpus al código?                   | Exportación JSON versionada y verificada, más `build.rs`                                      | [04](04-arquitectura-del-workspace-rust.md) §5 | R1  |
| D-P06  | ¿Nombres de los sujetos?                                       | `reference`, `engine`, `aot`, `service`, `cli`, `app`, `see`                                  | [02](02-modelo-de-especificaciones.md) §4     | R1   |
| D-P07  | ¿Qué pasa con los emisores (Python, Rust) y los diagramas de la app? | Se decide en R8: o consumen una vista del árbol especificada en `API.*`, o se retiran     | [03](03-catalogo-de-especificaciones.md) §4   | R8   |
| D-P08  | ¿Nombre y ubicación de la CLI?                                 | Binario `pseudo` en `apps/pseudolearn_cli`                                                    | [04](04-arquitectura-del-workspace-rust.md) §7 | R0  |
| D-P09  | ¿Dónde viven los tests de Rust?                                | Caja negra en `tests/` espejo de `src/`; unidad interna en `<módulo>_tests.rs` hermano        | [01](01-principios-y-reglas.md) §7            | R0   |
| D-P10  | ¿Cómo se justifica `unsafe` sin comentarios?                   | Crates permitidos, funciones de ≤ 10 líneas con nombre de invariante, tabla en el `README.md` | [01](01-principios-y-reglas.md) §4            | R0   |
| D-P11  | ¿Lista inicial de dependencias externas?                       | La de [01](01-principios-y-reglas.md) §9, confirmada crate a crate en cada fase               | [01](01-principios-y-reglas.md) §9            | R1+  |
| D-P12  | ¿Se congelan los cambios del lenguaje durante la reescritura?  | Sí: ninguna construcción nueva hasta R9; solo correcciones especificadas                      | [03](03-catalogo-de-especificaciones.md) §5   | R0   |

### 1.4 Abiertas que bloquean una fase del plan

| ID   | Pregunta                                                     | Bloquea                       |
|------|--------------------------------------------------------------|-------------------------------|
| D-13 | Palabras reservadas: vocabulario contextual, `Y`/`O`         | R2 (`LANG.LEXICAL.KEYWORD`)   |
| D-14 | NFC y `ñ` en el perfil estricto                              | R2 (`LANG.SOURCE.ENCODING`, `LANG.LEXICAL.IDENTIFIER`) |
| D-07 | Nivel de rendimiento aceptado como «muy optimizado»; R3 fija umbrales provisionales (D-R3-03). Para R6 la resuelve D-R6-01 | Umbrales definitivos de R5 y R6 |
| D-01 | Licencia                                                     | Política de `cargo-deny`; si algún crate se publica |

D-17 y D-21 quedan resueltas por D-R3-01 y D-R3-02 (§1.5).

### 1.5 Decisiones de R3

Fuente: mensaje de autorización de R3 de la persona responsable del 2026-10-14, que ordena ejecutar
R3 según el plan [09](09-plan-r3-motor-clepsidra.md) sin modificar ninguna recomendación; y, para
D-R3-02, la conversación del 2026-10-14 que aprobó la frontera de idioma, incluida la regla de que el
alias de una orden no decide el idioma de interfaz.

| ID       | Decisión aprobada                                                                                     | Resuelve |
|----------|-------------------------------------------------------------------------------------------------------|----------|
| D-R3-01  | Los límites son recursos del entorno con unidades deterministas (marcos, entradas a sentencia, celdas) y mínimos garantizados de 1 000 marcos y 2²² celdas. Profundidad y celdas producen fallo del programa; sentencias y tiempo, `limit_reached`. Valores por omisión: app 1 000 marcos; CLI 100 000 marcos sin presupuesto de sentencias | D-17 |
| D-R3-02  | Español canónico en órdenes y opciones, inglés como alias total; vocabulario autodeclarado por la palabra de apertura; idioma de interfaz por bandera > entorno > preferencias > sistema > español, nunca por el archivo ni por la forma de la orden | D-21 |
| D-R3-03  | Umbrales provisionales: VM sin observar ≥ 10× la línea base (media geométrica AWFY-core), objetivo 30×, ninguna prueba < 5×; paso observado p95 ≤ 1 ms en el dispositivo modesto y ≤ 0,1 ms en M2; sobrecoste del gemelo rápido con observador en pausa ≤ 2 %; front-end ≥ 10⁶ líneas/s en M2; biblioteca móvil ≤ 3 MiB por ABI; Wasm ≤ 600 KiB con brotli | D-07 (provisional) |
| D-R3-04  | E-02 usa Rust idiomático como sustituto de C, sin Go en la verificación local                          | Desviación de E-02 |
| D-R3-05  | `API.EXECUTE` incluye la consulta en un instante pasado como capacidad negociada `seek`                 | — |
| D-R3-06  | Se aprueban los cambios sobre la arquitectura de [04](04-arquitectura-del-workspace-rust.md): árbol postorden, código gemelo, línea temporal, runtime sin `unsafe` y `salsa` aplazado a R7 | Decisiones propuestas de 04 §3 |
| D-R3-07  | Se elevan a objetivo la transferencia AOT → VM (R6), la frontera grabable en `RT.HOST.INTERFACE` desde R3 y LLVM como nivel de *release* tras E-NR1 | — |

Quedan fuera del plan, para después de R9: D-08 (eliminación de código), D-12 (ámbitos de bloque),
D-15, D-16, D-19 y D-24.

---

### 1.6 Decisiones de R5

Aprobadas el 2026-10-15 por el mensaje «Implementa R5 de 07-fases.md en una sola iteración».
La autorización confirma las recomendaciones del plan ejecutable y exige elegir sin consultas adicionales.

| ID | Decisión | Elección aprobada y fundamento | Alternativa descartada o de reserva |
|---|---|---|---|
| D-R5-01 | ¿Cómo se trata la deuda de R4 (§6.1)? | **Decidida el 2026-10-15 por la persona responsable:** R4 se mantiene cerrada; la deuda se resuelve como tareas de R5 (bloque BF, §4.10), reescribiendo el front-end donde conviene, con evidencia `r5-frontend-*.json` y un apartado propio en el informe de R5 | Reabrir R4 (descartada por la persona responsable) |
| D-R5-02 | ¿Se sustituye el montón paginado por el montón plano (T11)? | **Sí.** Explica la mayor parte de RC-01; simplifica R6 | Conservar páginas con trampas inmediatas: 2,07× en la ablación |
| D-R5-03 | ¿Puntos de control diferenciales sin barrera y programados por coste (T20–T21)? | **Sí,** con ε = 1 % objetivo y 2 % de puerta (`PERF.VM.THROUGHPUT#R2`); tarjetas como peldaño medido | Barrera de época o de tarjetas en todo el gemelo rápido: 1,5–1,8× en nativo |
| D-R5-04 | ¿Trampas inmediatas en la VM y diferidas solo en superinstrucciones puras (T14)? | **Sí.** La bandera en memoria cuesta 10–50 % en la ablación | Regiones puras materializadas en la RI y comprobación diferida general |
| D-R5-05 | ¿Representación de ausencia de T12? | **Sí:** centinelas por tipo y definición solo para enteros, con cota densa y máscara | Etiqueta de definición por valor (contradice «sin etiquetas») o bitmap para todo tipo |
| D-R5-06 | ¿Aclaración de las raíces y del conteo de cadenas en `ENG.LIMITS#D1`? | **Sí,** como corrección clasificada sin cambio de comportamiento para programas que no alcanzan el límite | Contar lo que quede en registros: no determinista entre motores |
| D-R5-07 | ¿Bancos crecientes (T18)? | **Sí,** sujeto a la trazadora de B3.3 | Bancos fijos por plataforma: profundidad dependiente de la plataforma |
| D-R5-08 | ¿Funciones trascendentes y potencia real con redondeo correcto (T23)? | **Sí.** Es la única definición independiente de la plataforma y derivable por un oráculo independiente. Implementación propia en Rust seguro, sin dependencia nueva | Fijar en el contrato el algoritmo de una `libm` pura en Rust (por ejemplo, el *crate* `libm`) con valores capturados y revisados: determinista, pero el contrato dependería de una implementación |
| D-R5-09 | ¿Cancelación y guarda de tiempo también en evaluaciones de condición y pruebas de bucle? | **Sí.** Sin ello un bucle sin sentencias no se puede detener | Dejar el contrato como está: viola el propósito de `ENG.EXEC.MODEL#R3` |
| D-R5-10 | ¿Formato de reales con dígitos mínimos de ida y vuelta? | **Sí,** si B1.4 confirma que el corpus no lo fija ya | Número fijo de decimales: pierde información y cambia salidas existentes |
| D-R5-11 | ¿Generador de programas bien tipados y capacidad `gc_stress` en SEE? | **Sí.** Varias propiedades de R3 lo exigen; vive en SEE para no importar el motor | Programas generados dentro del motor: el sujeto se probaría a sí mismo |
| D-R5-12 | ¿Cómo se mide `PERF.VM.*`? | **Trabajador de medición en el motor** (`pseudolearn_bench_worker`, herramienta) que ejecuta en proceso y emite muestras; orquestación y estadística con el arnés Dart de `pseudolearn_benchmarks`, el mismo que midió `reference` | Medición en `ceiling` (prohibido importar el motor) o desde `pseudo ejecutar` (incluye arranque y E/S) |
| D-R5-13 | ¿Herramienta de mutación para E-16? | **`cargo-mutants` con versión exacta**, como herramienta auxiliar local auditada; no es una cadena nueva ni dependencia de ningún crate | Mutador propio en `xtask`: más código que mantener sin ganancia |
| D-R5-14 | ¿Objetivo `wasm32-wasip1` y ejecución con WASI de Node para E-17? | **Sí.** Añade un objetivo a la cadena Rust fijada y usa Node, ya presente; no instala cadenas nuevas | Esperar a `pseudolearn_wasm` de R8: dejaría el determinismo Wasm sin verificar en la fase que lo produce |
| D-R5-15 | ¿Medición provisional M3 de latencia de retroceso y reinterpretación de E-06 (§7.2)? | **Sí,** M3 p95 ≤ 50 ms en Apple M2, provisional como el resto de `PERF.VM.*` | Sin métrica: la línea temporal no tendría criterio de aceptación |
| D-R5-16 | ¿Superinstrucciones con validación fuera de muestra y sin PGO? | **Sí.** PGO añadiría `llvm-tools` a la cadena y haría el binario dependiente de un perfil; queda como último peldaño de RR-01 con decisión explícita | Elegirlas solo con AWFY-core |
| D-R5-17 | ¿Hipótesis C solo si E-02R y la trazadora muestran ≥ 10 % en `arrays`? | **Sí** (§3.3) | Implementarla siempre: complejidad sin ganancia demostrada |
| D-R5-18 | ¿Criterio de elección del recolector de E-12 (§7.3)? | **Sí,** con las tres variantes medidas y la perdedora fuera del motor | Elegir sin medir |
| D-R5-19 | ¿Contrato de límites de análisis (§6.4)? | **Sí:** profundidad de anidación mínima garantizada (propuesta: 256 niveles), diagnóstico propio con tramo y sin agotar la pila; el valor se fija en BF.1 con casos de borde | Reutilizar los límites de ejecución de `ENG.LIMITS`, que miden otra cosa |


### 1.7 Decisiones de R6

Aprobada el 2026-10-18 por la persona responsable, sobre la alternativa recomendada en [17](17-informe-analisis-rendimiento-r6.md) §9.

| ID | Decisión | Elección aprobada y fundamento | Alternativa descartada o de reserva |
|---|---|---|---|
| D-R6-01 | ¿Cómo se resuelve D-07 para `PERF.AOT.LEVEL#R1`? | **Umbral por niveles con techo semánticamente equivalente.** (1) Nivel Cranelift: razón geométrica por familia ≤ 1,70× frente a V1F. (2) Nivel optimizado futuro (optimizador intermedio propio o backend de *release*): ≤ 1,30× frente a **V1F-S**, variante experimental del techo que añade el rastreo de valores indefinidos y la recolección con límite de celdas vivas del motor; V1F se conserva intacto para comparar con las campañas anteriores. Se registra en el corpus como cambio clasificado de `PERF.AOT.LEVEL` y `PERF.SUITE.AWFY-CORE`. Fundamento: V1F no hace el mismo trabajo semántico (17 §6.1); el 1,30× nació en R5 como cota de representación entre núcleos manuales (17 §6.2); con Cranelift y cambios generales lo mejor medido es 1,5–1,7× por familia (17 §2.6) | Mantener 1,30× frente a V1F para Cranelift: exige optimización de nivel LLVM y cambios estructurales (17 §9) |
| D-R6-02 | ¿Qué cambios de 17 §4 se implementan para cerrar el nivel Cranelift? | **S1–S6**, en una sola iteración, con S3 limitado a accesos cuyo camino rápido sea completo y sin el camino lento terminal de celdas (17 §6.4) | S7–S9 quedan para el nivel optimizado y requieren decisión propia (RN-11) |

| D-R6-03 | ¿Se cierra R6 pese a los criterios pendientes? | **Sí, por autorización explícita de la persona responsable el 2026-10-19**, con commit y push sin coautoría. S1–S6 están implementadas y los verificadores locales están verdes, pero no se cumplieron todos los casos: arreglos y recursiva incumplen 1,70×. El cierre acepta esa deuda, sin certificar el nivel Cranelift ni modificar umbrales o exenciones. Faltan optimizaciones de arquitectura o microarquitectura y demostrar la causa de Permute; su selección requiere trabajo autorizado aparte. Informe y evidencia en [18](18-informe-implementacion-s1-s6-r6.md). R7 no se inicia | Mantener abierta la fase hasta satisfacer todos los criterios; descartado por la autorización posterior de cierre |

## 2. Riesgos

Escala como en [17](../17-riesgos-preguntas-y-decisiones.md) §3: probabilidad e impacto en Baja, Media
o Alta.

| ID    | Riesgo                                                                                       | P | I | Mitigación                                                                                                          | Señal temprana                                              |
|-------|----------------------------------------------------------------------------------------------|---|---|---------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------|
| RN-01 | **Segundo sistema:** la reescritura acumula mejoras y nunca alcanza la paridad                 | M | A | Alcance = paridad (D-P12); la matriz como medida de avance; construcciones nuevas solo después de R9                | Especificaciones `LANG` nuevas que no vienen de `language-spec.md` |
| RN-02 | **Coste de autoría** de ≈159 especificaciones (R-05 de la investigación)                      | A | A | Piloto con medición (E-15); `see new` con plantillas; admitir `experimental` para avanzar; priorizar por el grafo    | Más de una hora por regla en el piloto                      |
| RN-03 | **Consagrar los defectos del núcleo Dart** al escribir casos mirando lo que hace               | M | A | Origen `escrito`; `capturado` con revisor; los hallazgos H-xx como `exento` en `reference`                           | Muchos `capturado` en una especificación                    |
| RN-04 | **Curva de Rust** con una sola persona                                                        | A | M | Empezar por `see`; los lints estrictos enseñan; la arquitectura por crates limita el alcance de cada error          | R1 se alarga más que R2                                     |
| RN-05 | **Observar a través de FFI** es demasiado caro para el paso a paso                            | M | A | Lotes de eventos, consulta por referencia, estado incremental; E-NR2 en R8; se mide en R5 sin puente                | `PERF.VM.STEP-LATENCY` al límite ya en R5                   |
| RN-06 | **Recolector con `unsafe`** con errores de memoria                                            | M | A | Sin movimiento; `unsafe` confinado; `cargo miri test` sobre `pseudolearn_runtime` en la CI; propiedades con recolección forzada | Fallos intermitentes en propiedades `MEM`             |
| RN-07 | **`pseudo build` exige un enlazador** en la máquina de quien compila                          | A | M | `RT.LINKING` lo declara; diagnóstico claro si falta; evaluar distribuir `lld` en R6                                | —                                                           |
| RN-08 | **La app y el núcleo divergen** durante la transición (la app sigue con Dart hasta R8)          | M | M | Congelación del lenguaje (D-P12); la app no cambia de motor hasta que `engine` cumpla todo `LANG`                   | Cambios en la base de conocimiento que dependen de construcciones nuevas |
| RN-09 | **Fricción entre las reglas del proyecto y las convenciones de Rust** (`T`, `'a`, `|x|`, `// SAFETY:`) | A | B | Aceptada a sabiendas; los lints corrigen pronto; la política de `unsafe` sustituye el comentario | Excepciones pedidas con frecuencia                          |
| RN-10 | **Tamaño** de la biblioteca en móvil y del Wasm                                               | M | M | Sin Cranelift ni servicio pesado en móvil; `PERF.ARTIFACT.SIZE`; `opt-level = "z"` evaluado para Wasm               | Crecimiento por encima del presupuesto en R5                |
| RN-11 | **Cranelift no alcanza** el nivel acordado                                                     | M | M | RI compatible con LLVM; E-NR1; LLVM como backend de «release» opcional                                              | Informe de R6                                               |
| RC-01 | La tabla de páginas y la barrera de época cuestan demasiado en cargas de objetos                | M | A | E-02 V2/V1 decide antes de R5; alternativa: montón directo con `unsafe` acotado y tarjetas sucias                     | V2/V1 > 1,30 en una familia                                 |
| RC-02 | Los gemelos rápido y sondeado divergen                                                         | B | A | Se generan desde la misma RI con una sola función parametrizada; conformidad diferencial interna obligatoria         | Un caso que difiere entre gemelos                           |
| RC-03 | Memoria de puntos de control en ejecuciones largas                                            | M | M | Raleo exponencial y presupuesto configurable; `API.STATE.QUERY` declara el horizonte retenido                        | E-06 en R5                                                  |
| RC-04 | El árbol postorden dificulta la identidad de nodo de R7                                       | M | M | El servicio de R7 deriva la identidad o construye su estructura incremental encima                                   | E-08 en R4                                                  |
| RC-05 | LLVM asigna mal registros en un `match` de despacho grande                                     | M | M | Manejadores pequeños, estado en variables locales, superinstrucciones; alternativa: despacho por familias           | `PERF.VM.THROUGHPUT` al empezar R5                          |
| RC-06 | Los bancos de tamaño fijo ocupan memoria en Wasm y móvil                                       | M | B | 2¹⁸ ranuras en Wasm y móvil, 2²⁰ en escritorio; el mínimo de 1 000 marcos se cumple en ambos                         | `PERF.ARTIFACT.SIZE`, RSS en E-06                           |
| RN-12 | **El núcleo Dart deja de compilar** con versiones nuevas de Dart antes de R9                  | B | M | Fijar la versión del SDK para el sujeto `reference`; es solo un oráculo                                             | Avisos de obsolescencia del SDK                             |

---

### Riesgos de R5

RC-01: resuelto por E-02R. 27 000 muestras, diez procesos y treinta iteraciones.
V2R/V1F ≤ 1,276 por núcleo, límite superior de IC 95 % ≤ 1,280;
V3R/V2R ≤ 1,003 por familia. Datos crudos y procedencia en
`packages/pseudolearn_benchmarks/results/e02r/`; evaluación reproducible en
`packages/pseudolearn_spec/results/r5-e02r.json`. La puerta sobre VM real se conserva.

| ID | Riesgo | P | I | Señal | Escalera de subsanación dentro de R5 |
|---|---|---|---|---|---|
| RR-01 | Despacho lento o mala asignación de registros en el `match` generado (hereda RC-05) | M | A | B3.3 proyecta < 30×; B7.7 < 10× o algún programa < 5× | 1) manejadores pequeños con rutas frías fuera de línea; 2) formas registro-inmediato; 3) superinstrucciones adicionales del perfil; 4) estado caliente en variables locales y bancos en porciones locales al marco; 5) despacho por familias en dos niveles; 6) bancos de tamaño de tipo monomorfizados; 7) PGO con decisión explícita (D-R5-16) |
| RR-02 | Observador en pausa > 2 % | M | A | E-02R V3R/V2R > 1,05; E-06 M4 > 2 % | 1) recalibrar κ y `Q_min`; 2) copiar sin comparar lo asignado desde el último punto; 3) particionar el montón por antigüedad y comparar solo bloques de objetos mutables; 4) gemelo de grabación con tarjetas (V3R-tarjetas) monomorfizado aparte, solo cuando hay observador |
| RR-03 | Latencia de retroceso alta con montones grandes | M | M | E-06 M3 > 50 ms | 1) densificación perezosa más agresiva alrededor del cursor; 2) intervalo máximo absoluto además del proporcional; 3) caché de la VM de reproducción con su propio deshacer para retrocesos consecutivos; 4) peldaño 4 de RR-02 |
| RR-04 | Memoria de la línea temporal (sombra + segmentos) | M | M | RSS > 2,5× el montón vivo; horizonte demasiado corto | 1) raleo exponencial más fuerte con fusión de segmentos; 2) compresión de segmentos (bloques con diferencia por palabra); 3) excluir el texto (ya excluido) y el espacio libre; 4) presupuesto por anfitrión con horizonte declarado |
| RR-05 | Divergencia entre gemelos o al cambiar de gemelo (hereda RC-02) | B | A | Un caso o una semilla con diferencia | Generación por una sola función parametrizada; contraejemplo reducido se convierte en test espejo; corrección antes de seguir |
| RR-06 | Diferencias entre plataformas (matemática, formato, NaN en Wasm, iteración de tablas *hash*) | M | A | E-17 o B3.4 | Redondeo correcto (T23); formato propio; centinelas leídos como bits; solo `BTreeMap` o tablas con orden fijo en salidas; cada diferencia corregida en la fase |
| RR-07 | Conteo de celdas inexacto (raíces, cadenas compartidas, temporales) | M | A | Propiedad de conteo frente al oráculo nocional | Mapas nocionales por punto seguro; aclaración D-R5-06; contraejemplos como casos del corpus derivados de la regla |
| RR-08 | Camino de asignación lento (Storage 1,51× en la ablación) | M | M | E-02R Storage > 1,30 | 1) avance en bloques puestos a cero; 2) cabecera escrita con una sola operación; 3) listas por clase sin búsqueda; 4) variante Immix de E-12 |
| RR-09 | La deuda heredada de R4 es mayor de lo inventariado y retrasa `lowering` | A | A | BF.8 no se alcanza | Inventario completo en B0.3; reescritura por pasadas con tests espejo; BF en paralelo con E-02R; B2 no empieza sin la puerta BF.8 |
| RR-15 | El análisis no alcanza 10⁶ líneas/s ni p95 ≤ 16 ms | M | M | BF.6 | 1) eliminar asignaciones por token y por diagnóstico; 2) comparar lexemas por identidad del hash perfecto, sin cadenas; 3) NFC solo fuera del camino ASCII; 4) presentación de mensajes solo en el borde; 5) arenas con capacidad reservada por tamaño de fuente; 6) pasadas semánticas fusionadas donde el perfil lo justifique |
| RR-10 | Pánicos o `INTERNAL-FAULT` con programas raros | M | A | B7.6 | Generador, mutación y verificador de bytecode; cada hallazgo, test espejo y corrección |
| RR-11 | Alcance de R5 (once capas, cinco experimentos) excede la iteración | A | M | Retraso relativo entre bloques | El plan no recorta alcance: la fase sigue abierta hasta cumplir. Prioriza el camino crítico (B1 → B3 → B4 → B5) y paraleliza solo lo que no comparte archivos |
| RR-12 | El módulo Wasm supera el presupuesto ya en R5 | M | M | E-17 publica > 600 KiB con brotli | 1) `opt-level = "z"` y LTO para Wasm; 2) tablas generadas compactas; 3) separar el formato de texto de la RI y la narración de la CLI del módulo de ejecución por *features* |
| RR-13 | Artefactos de generación de código nativo distorsionan las mediciones (§2.3 ᵃ) | M | B | Cocientes sin causa en llamadas | Medir la VM real; rutas frías fuera del bucle; informar sin ocultar |
| RR-14 | La reproducción repite un efecto externo o cambia la continuación | B | A | `API.EXECUTE#P1` | VM de reproducción separada; salida suprimida por cursor; entradas desde la cinta; propiedad con semilla |


## 3. Cambios de reglas por fase

### 3.1 `AGENTS.md`

| Sección | Cambio propuesto                                                                                                      |
|---------|-----------------------------------------------------------------------------------------------------------------------|
| §2      | **Nuevas:** `SPEC-BEHAVIOR-TRUTH` (el comportamiento observable vive en el corpus), `SPEC-FIRST` (especificación → casos → tests → código), `SPEC-NO-ORPHAN-RULE`, `SPEC-BINDING-AS-DATA` (los vínculos regla–código viven en archivos de conformidad, nunca en el código), `SPEC-CHANGE-CLASSIFIED`, `SPEC-INDEPENDENT-ORACLE`, `QUALITY-SEMANTIC-NAMES`, `QUALITY-NO-PANIC` |
| §2      | **Modificadas:** `DOC-README-TRUTH` se acota a arquitectura, operación y porqué de la implementación (contrato R2). `QUALITY-NO-COMMENTS` añade las formas de Rust, la ausencia de excepción de docstring en Rust, la política de `unsafe` y `rust-checks comments` como verificador. `LANG-ES-DOCS` incluye el corpus de especificaciones |
| §3      | **Precedencia:** (1) la persona; (2) `AGENTS.md`; (3) el corpus de especificaciones para el comportamiento y el `README.md` del paquete para la arquitectura, que tienen ámbitos disjuntos (si chocan, la afirmación está mal clasificada y se reporta); (4) `language-spec.md` mientras quede algo sin migrar; (5) terceros |
| §4      | Cero comentarios también en Rust; `#[allow]` prohibido en código                                                        |
| §5      | Tests de Rust: ubicación (D-P09); los casos de conformidad no se duplican como tests                                     |
| §8      | Skills nuevas y modificadas (§3.3)                                                                                       |
| §9      | Quinta cadena de herramientas: `cargo` y `rustup` para `pseudolearn_spec`, `pseudolearn_engine`, `pseudolearn_rust_checks`, `pseudolearn_cli` y el puente de la app |

**Resolución aprobada en R0.** `AGENTS.md` declara cinco cadenas; la quinta corresponde a Rust.

### 3.2 `README.md` raíz

- §1 y §3.1–3.3: mapa con los miembros nuevos y las aristas nuevas (CLI → núcleo, app → puente →
  núcleo, `see` → sujetos por proceso, núcleo ← exportación del corpus).
- §1.3: la CI deja de estar fuera de alcance (D-23).
- §1.5: cerrar el pendiente de CI; añadir «retiro del núcleo Dart (R9)».
- §2.1, §2.2 y §2.5: requisitos y comandos de los miembros Rust.

### 3.3 Skills

| Skill                      | Cambio                                                                                                         | Fase |
|----------------------------|----------------------------------------------------------------------------------------------------------------|------|
| `spec-authoring` (nueva)   | Cómo escribir, clasificar y estabilizar una especificación; el flujo de [06](06-flujo-de-trabajo.md)            | R1   |
| `rust-code-quality` (nueva) o ampliación de `code-quality` | Nombres semánticos, cero comentarios en Rust, sin pánicos, `unsafe`, tests        | R0   |
| `language-spec-authoring`  | Se sustituye por `spec-authoring` para `LANG`; el criterio de desempate pasa a D-02 (C-01)                      | R2   |
| `layer-boundaries`         | Lee también `architecture.yaml` de workspaces Rust (crates como capas)                                          | R0   |
| `diagnostics-authoring`    | Reescrita: un diagnóstico nace en `DIAG.CATALOG` y llega al código por exportación                              | R4   |
| `ast-node-authoring`       | Reescrita para el árbol sin pérdida: los nodos se generan de `LANG.SYNTAX.GRAMMAR`                              | R4   |
| `phase-gate`               | Añade «matriz de conformidad sin regresiones» y `see validate` a la comprobación de cierre                       | R1   |
| `package-docs`             | Admite citar identificadores de especificación; el historial vive en el corpus (C-02)                          | R1   |
| `commit-message`           | Ámbitos de los miembros nuevos; nombrar la especificación en el cuerpo                                          | R0   |

### 3.4 Otros documentos

- `packages/pseudolearn_core/README.md`: estado «sujeto `reference`, congelado» (R0) y «retirado» (R9).
- `packages/pseudolearn_core/docs/language-spec.md`: tabla de correspondencia y migración (R2).
- `docs/README.md`: enlace a este plan (hecho en el mismo cambio que crea el plan).
- `docs/14` y `docs/17`: **no se reescriben**. Son investigación con fecha. La resolución de D-05,
  D-06 y D-10 queda en este plan y, al aprobarse, en `AGENTS.md` y en el `README.md` raíz.

La instrucción de la persona responsable del 2026-10-14 reserva GitHub Actions para despliegues
productivos y comprobaciones puntuales manuales. D-23 no exige verificaciones automáticas en push/PR.
E-01 tiene autorización explícita para usar runners remotos y completar su matriz de métricas.

## Evidencia E-02 de R3

La captura final local contiene 12.000 muestras. La representación requiere revisión antes de autorizar R5 (RC-01); no se rediseña durante R3.

| Familia | V1/V0 [IC 95 %] | V2/V1 [IC 95 %] | V3/V2 [IC 95 %] | Revisar antes de R5 |
|---|---|---|---|---|
| arrays | 2.3099 [2.1023, 2.7506] | 4.0548 [3.2911, 5.5906] | 0.9946 [0.7455, 1.1965] | Sí |
| numeric | 1.7158 [1.6864, 1.7382] | 2.0575 [1.9962, 2.1611] | 1.0045 [0.9735, 1.0266] | Sí |
| objects | 1.1139 [1.0882, 1.1609] | 3.6046 [3.4272, 3.7087] | 1.1092 [1.0992, 1.1232] | Sí |
| recursive | 2.7728 [2.7524, 2.8071] | 2.5893 [2.5514, 2.6174] | 1.1206 [1.1021, 1.1463] | Sí |


La evidencia completa, incluidas las muestras iniciales con instrumentación insuficiente, se conserva en
`packages/pseudolearn_benchmarks/results/e02/`. El informe declara qué mide el experimento y sus límites.
