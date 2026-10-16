# 11 · Plan de R5 · «Remanso»: RI, VM, runtime, biblioteca y línea temporal de Clepsidra

> **Estado:** R5 autorizada y en ejecución por el mensaje del 2026-10-15. Casillas pendientes hasta verificar evidencia.
> Rama: `feature/agregar-ruta-de-especificacion` (`GIT-SINGLE-BRANCH`).
>
> Este documento concreta [R5](07-fases.md) sobre la arquitectura [Clepsidra](09-plan-r3-motor-clepsidra.md)
> y cierra la condición previa **RC-01** que dejó E-02. Revisa varias decisiones de 09 §3, §5 y §12 y de los
> `README.md` del motor; según `CONFLICT-REPORT`, cada cambio está señalado en §6 con su tabla y no se
> aplica sin aprobación. La autorización de R5 confirma o modifica las recomendaciones de §9.
>
> **Deuda heredada de R4 (D-R5-01, decidida el 2026-10-15).** La investigación encontró que la evidencia
> versionada de R4 no sostiene su cierre (§6.1): 330 de 492 observaciones de análisis en `incumple`, ningún
> HIR tipado, E-08 a ~140 000 líneas/s frente al millón exigido, 7 casos `cli` de órdenes de R4 en `incumple`,
> textos y lexemas copiados a mano y ningún contrato de límites de análisis. Por decisión de la persona
> responsable, **R4 se mantiene cerrada** y todo lo pendiente se resuelve **como tareas de R5**: el bloque
> BF de §8 y la arquitectura de §4.10, que reescriben el front-end donde conviene. El informe de R5 lo declara
> en un apartado propio; 07 no se reabre.

---

## 0. Contrato de ejecución

Este documento es **el plan ejecutable de R5** de [07](07-fases.md). Está escrito para que lo ejecute otro
agente sin el contexto de la conversación que lo produjo.

### 0.1 Cuándo se completa R5

R5 queda completa cuando:

- todas las casillas de §8 están marcadas con evidencia;
- el cierre B8 está en verde, sin pendientes obligatorios;
- el informe de R5 está escrito en [07](07-fases.md) con la plantilla de su §3.

Las casillas de R5 en 07 se marcan **en el paso B8.6**, nunca antes.

### 0.2 Regla de cero deuda de la fase

La persona responsable fijó una regla más estricta que el contrato general de 07 §3: **todo cuello de
botella, riesgo o hallazgo que pertenezca al alcance de RI, VM, runtime, biblioteca, línea temporal, API
de ejecución o CLI `ejecutar`/`ri` se diagnostica, se resuelve, se verifica y se cierra dentro de R5.**
En consecuencia:

1. Cada técnica de §4 declara su **criterio de aceptación**, su **experimento o métrica** y su **escalera
   de subsanación**: la lista ordenada de alternativas que se prueban dentro de la fase si el criterio
   falla (§10).
2. Un umbral fallido no se convierte en pendiente. O se sube un peldaño de la escalera, o se reporta
   (`CONFLICT-REPORT`) porque agotar la escalera cambia una premisa aprobada. La fase sigue abierta.
3. La **deuda heredada de R4** (§6.1) se trata exactamente igual que la propia: el bloque BF tiene casillas,
   criterios y escaleras, y ningún criterio de R4 incumplido puede quedar como pendiente de R5.
4. Solo se declara fuera de R5 lo que **otra fase posee por definición**, con su motivo: el código nativo
   (R6), el servicio de lenguaje (R7), el puente FFI y la medición en el dispositivo modesto (R8). Incluso
   en esos casos, R5 entrega **las señales tempranas medibles** (tamaño del Wasm, coste de los lotes de
   eventos, marco canónico para la transferencia AOT → VM).

### 0.3 Autorización y orden

- R5 empieza solo con un mensaje nuevo de la persona responsable (`PHASE-STOP`).
- Salvo que ese mensaje diga otra cosa, aprueba las recomendaciones de §9 tal como están.
- D-R5-01 ya está decidida: la deuda de R4 es parte de R5 (bloque BF).
- Los bloques B0–B8 van en secuencia; dentro de cada bloque, los pasos en orden numérico. Es una sola
  iteración: no se para entre bloques.
- Solo se para por un conflicto entre fuentes (`CONFLICT-REPORT`), por algo fuera de alcance (skill
  `phase-gate`) o porque una escalera de subsanación se agota.

### 0.4 Lectura obligatoria antes de B0

- `AGENTS.md` completo.
- Este documento completo, y §3, §5, §12 de [09](09-plan-r3-motor-clepsidra.md).
- `README.md` y `architecture.yaml` de `packages/pseudolearn_engine` y de los crates `abi`, `ir`,
  `lowering`, `bytecode`, `runtime`, `library`, `vm`, `timeline`, `api` y `conformance`.
- `README.md` de `packages/pseudolearn_spec`, `packages/pseudolearn_benchmarks`,
  `packages/pseudolearn_benchmarks/ceiling` y `apps/pseudolearn_cli`.
- Corpus `IR.*`, `ENG.*`, `MEM.*`, `RT.HOST.INTERFACE`, `LIB.*`, `API.*`, `TOOL.CLI.RUN`, `TOOL.CLI.IR`,
  `PERF.*` y las reglas de ejecución de `LANG.*`.
- Skills `layer-boundaries`, `code-quality`, `package-docs`, `language-spec-authoring`,
  `diagnostics-authoring`, `commit-message` y `phase-gate`.

### 0.5 Prohibiciones de la fase

Una violación invalida el cierre.

1. Ningún `unsafe` en el motor (`#![forbid(unsafe_code)]` en todos los crates de R5).
2. Ningún `unwrap`, `expect`, `panic!`, índice sin comprobación, aritmética implícita ni conversión con
   pérdida (`QUALITY-NO-PANIC`). Ningún comentario ni atributo `doc`, `allow` o `expect`
   (`QUALITY-NO-COMMENTS`).
3. Ningún valor esperado copiado de lo que hace `reference` ni de una variante de `ceiling`
   (`SPEC-INDEPENDENT-ORACLE`).
4. Ninguna construcción nueva del lenguaje (D-P12, ADR-001). Las aclaraciones de §6.4 son correcciones
   clasificadas de contratos existentes, no construcciones.
5. Ningún cambio en `packages/pseudolearn_core/lib/`. El sujeto `reference` sigue congelado.
6. Ninguna copia manual de datos del corpus (`GEN-NO-HAND-COPY`): catálogo de la RI, diagnósticos,
   plantillas de la CLI y vocabulario llegan por exportación y `build.rs`.
7. El corpus no menciona montón, asas, bancos, gemelos, sombras, segmentos ni puntos de control: eso es
   arquitectura y vive en los `README.md`.
8. Ninguna fuente de no determinismo en el motor: ni reloj (salvo la guarda de tiempo del anfitrión), ni
   `HashMap` con semilla aleatoria en salidas, ni funciones matemáticas de la plataforma.
9. Sin *force push*, sin ramas nuevas y sin trailers de coautoría ni atribución de IA (`AGENTS.md` §9).

### 0.6 Evidencia y comandos

- Una casilla se marca solo después de ejecutar su verificación.
- Las salidas que sostienen el informe se guardan en `packages/pseudolearn_spec/results/` con nombres
  `r5-*.json`; los datos crudos de rendimiento, en `packages/pseudolearn_benchmarks/results/` (`e02r/`,
  `e06/`, `e12/`, `macos-r5-vm/`).
- Este documento es transitorio: al adoptar una decisión, su fundamento pasa al `README.md` dueño **antes**
  del código (`DOC-README-TRUTH`, `DOC-NO-TRANSIENT-REFS`). Ningún README cita este plan ni sus
  identificadores T11–T24.

Comandos de referencia (desde la carpeta de cada miembro):

```bash
cargo xtask verify
```

```bash
cargo run -p see_cli --bin see -- validate
```

```bash
cargo run -p see_cli --bin see -- conform --subject engine --operation execute
```

```bash
cargo run -p see_cli --bin see -- conform --subject engine --operation trace
```

```bash
cargo run -p see_cli --bin see -- conform --subject engine --operation ir
```

```bash
cargo run -p see_cli --bin see -- conform --subject cli --operation cli
```

```bash
cargo run --release -p ceiling_runner -- collect
```

Los comandos de `execute`, `trace`, `ir` y `cli` contra `engine` no existen todavía: los habilita B1.5.
No se presentan como evidencia antes de existir.

---

## 1. La propuesta en una página

**Remanso** es la revisión de Clepsidra que hace R5 a partir de la evidencia de E-02. El nombre sigue la
metáfora del reloj de agua: el remanso es el tramo donde el agua corre sin obstáculos. **El camino caliente
no lleva barreras, ni páginas, ni banderas en memoria**; todo lo que sirve para observar o para volver atrás
se paga fuera de él, en un servicio que la propia ejecución llama cuando se agota su combustible, con un
presupuesto de sobrecoste fijado de antemano.

```text
 texto ─► front-end corregido en BF (vistas generadas, recuperación sin cascadas) ─► HIR tipado en columnas
     │
     ▼
 lowering ──► RI SSA verificada ── orígenes de variable (tabla lateral), masas de sentencia y de evento,
     │                             ciclos sin sentencia marcados como retrocesos de sondeo
     ▼
 bytecode gemelo ── ranuras de origen + temporales por clase, puntos de retorno independientes del gemelo,
     │              mapas nocionales de raíces y de definición por punto seguro, superinstrucciones medidas
     ▼
 VM bicameral ── bancos crecientes potencia de dos, trampas inmediatas en rama fría, cargo de masa en los
     │           saltos; al agotar el combustible SALE a su llamador con un motivo de servicio
     │
     ├──► runtime: montón plano de palabras con asas directas · ausencia sin etiquetas · arena de texto de
     │             solo apéndice · recolección exacta y determinista · aritmética comprobada
     ├──► biblioteca: intrínsecos en la RI · matemática con redondeo correcto · formato de ida y vuelta
     │
     ▼
 línea temporal ── puntos de control diferenciales SIN barrera (sombra + segmentos de deshacer, texto por
     │             longitud, bancos por marca de agua) programados por coste: sobrecoste ≤ ε por construcción;
     │             reproducción acelerada (gemelo rápido hasta el bloque, sondeado hasta el evento)
     ▼
 API de ejecución y consulta por referencia e instante ──► CLI `ejecutar`/`ri` ──► conformidad
```

| Nº  | Técnica de R5                                                              | Relación con R3     | Qué gana                                                              |
|-----|----------------------------------------------------------------------------|---------------------|-----------------------------------------------------------------------|
| T11 | Montón plano de palabras con asas directas                                 | Sustituye T7 (páginas) | Un acceso al montón es una comprobación y una carga; arreglos contiguos |
| T12 | Ausencia sin etiquetas: centinelas por tipo y definición solo para enteros | Nueva (hueco de R3) | `sin valor` exacto sin etiquetas ni coste para reales, lógicos, caracteres y referencias |
| T13 | Arena de texto de solo apéndice y concatenación por apéndice compartido    | Refina T7 (texto)   | `s <- s + c` en O(1) amortizado; el texto nunca se compara en un punto de control |
| T14 | Trampas inmediatas en la VM; diferidas solo dentro de superinstrucciones puras | Refina T2       | Elimina el coste medido de la bandera en memoria; conserva la primera trampa exacta |
| T15 | Ranuras de origen y mapas nocionales de raíces y definición                | Refina T4           | Estado observable directo; conteo de celdas exacto; disciplina común con AOT |
| T16 | Servicio unificado de combustible con masa doble y retrocesos de sondeo    | Refina T6           | Límites, cancelación, pausa, puntos de control y reproducción por una sola salida fría |
| T17 | Puntos de retorno independientes del gemelo                                | Completa T5         | Cambio de gemelo correcto con marcos suspendidos                       |
| T18 | Bancos crecientes potencia de dos                                          | Refina T3 y T4      | Profundidad determinista en toda plataforma; memoria proporcional al uso |
| T19 | Recolección exacta y determinista con asignador elegido por E-12            | Refina T7 (recolector) | `MEM.*` y `ENG.LIMITS` exactos; asignación por avance en bloques puestos a cero |
| T20 | Puntos de control diferenciales sin barrera                                 | Sustituye T7 (copia en escritura) | Cero coste por escritura; delta por bloques de 64 palabras |
| T21 | Programación de puntos de control proporcional al coste                    | Refina T8           | Observador en pausa ≤ ε por construcción, con latencia de retroceso acotada |
| T22 | Reproducción acelerada y densificación perezosa                            | Refina T8           | Retroceso a velocidad del gemelo rápido hasta el bloque del evento     |
| T23 | Matemática determinista con redondeo correcto                               | Nueva (hueco de R3) | Igualdad bit a bit entre macOS, Linux, Windows, iOS, Android y Wasm    |
| T24 | Superinstrucciones validadas fuera de muestra e intrínsecos especializados | Refina T9           | Menos despachos sin sobreajustar a AWFY                                |
| T25 | HIR tipado en columnas producido por pasadas semánticas separadas          | Cumple T1 y R4 (deuda) | Análisis conforme y la única entrada que `lowering` necesita         |
| T26 | Vistas sintácticas generadas de la gramática y recuperación por contexto sin cascadas | Cumple T1 (deuda) | Diagnósticos de `DIAG.CLASSES` exactos; `PERF.FRONTEND.THROUGHPUT` |

**Lo que no es:** no hay JIT, no hay `unsafe`, no hay barrera de escritura en el camino caliente, no hay
reloj en la programación de puntos de control, no hay etiquetas de tipo en los valores y no hay ninguna
construcción nueva del lenguaje.

---

## 2. Diagnóstico empírico de E-02 y resolución de RC-01

### 2.1 Qué midió E-02 en realidad

E-02 comparó cuatro variantes de diez núcleos AWFY compilados a nativo (`ceiling`). La lectura del código
muestra que **V2 no aisló «la representación Clepsidra»**: mezcló siete efectos, y V3 mezcló tres más.

| Nº | Efecto incluido en la variante                                                                                         | Dónde está                                                                            | Representativo del motor de R5 |
|----|------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|-------------------------------|
| C1 | Traducción paginada en cada acceso: desplazamiento, comprobación contra la tabla, carga del `Rc`, carga de la palabra      | `paged_heap.rs`, `load` y `store`                                                      | Sí: es la decisión T7          |
| C2 | `Rc::get_mut` en cada escritura (comprobación de cuentas fuerte y débil) además de la comparación de época                | `paged_heap.rs`, `store`                                                               | Sí: es T7                      |
| C3 | Trampas «diferidas» como `Option<Trap>` en la estructura de la máquina: la rama sigue existiendo, se añade una escritura en memoria y `settle()` lee esa bandera antes de **cada** acceso al montón y cada llamada | `clepsydra.rs` (`get_or_insert`) y `clepsydra_memory.rs` (`settle`) | No: una VM no gana nada con ello (§3.5) |
| C4 | Longitud del arreglo leída del montón paginado: dos traducciones por elemento                                           | `clepsydra.rs`, `element`                                                              | Parcial                        |
| C5 | Marcos materializados en bancos en V2/V3 y **ausentes** en V1: `DirectMachine::enter` copia a un arreglo fijo de cuatro palabras sin pila | `direct.rs`, `Calls`                                                    | No: V1 no es una base comparable para llamadas |
| C6 | Páginas de 32 KiB creadas y puestas a cero dentro del intervalo medido en cada repetición                                | `paged_heap.rs`, `allocate`; `variant.rs`, `reset` dentro de `run`                      | Parcial                        |
| C7 | Máquina detrás de `Box` y bancos de 2¹⁶ ranuras                                                                         | `variant.rs`, `clepsydra.rs`                                                           | Irrelevante                    |
| C8 | V3: consulta del reloj cada 4 096 pasos y construcción de las porciones de ambos bancos en **cada** paso antes de comprobar el contador | `clepsydra_memory.rs` (`tick`) y `timeline.rs`                     | No: R3 especificó puntos por masa de sentencia, no por reloj |
| C9 | V3: copia de páginas completas de 4 096 palabras al primer cambio tras un punto                                         | `paged_heap.rs`                                                                        | Sí: es T7                      |
| C10 | V3: retención por `VecDeque` con 64 puntos y clonado de la tabla completa                                              | `timeline.rs`                                                                          | Parcial                        |

Dos observaciones más sobre el diseño del experimento:

- La familia `recursive` contiene **solo Permute**. Towers está en `objects`, y Richards no es recursivo
  (es un planificador en bucle). La hipótesis externa B, que atribuye a Towers y Richards el exceso de V3/V2,
  parte de esa confusión de etiquetas.
- Las pilas de AWFY-core son poco profundas (Towers con diez discos no supera unas decenas de marcos), así que
  E-02 **no puede** haber medido el coste de copiar pilas profundas. Ese coste existe en la CLI (100 000
  marcos) y se trata en T20, pero no explica los cocientes publicados.

### 2.2 Ablación exploratoria realizada para este plan

Para separar las causas antes de proponer, se repitió E-02 sobre una **copia** de `ceiling` en un directorio
temporal, fuera del repositorio, con variantes adicionales. Es una exploración, **no** una medición de
`PERF.PROTOCOL`: un proceso, quince o veintiuna rondas intercaladas por núcleo, mediana de muestras de al
menos 5 ms, Apple M2, misma cadena Rust 1.99.0 y mismo perfil *release*. Sus números orientan el diseño;
**B1 los repite con el protocolo normativo como E-02R** y solo esos datos cierran RC-01.

Variantes (todas validan la salida contra el corpus en cada repetición):

| Variante            | Qué es                                                                                       |
|---------------------|----------------------------------------------------------------------------------------------|
| V1                  | La de E-02: semántica comprobada, representación directa, sin pila de marcos                 |
| **V1F**             | V1 **con** los mismos bancos y marcos que V2: la base comparable para llamadas                |
| V2                  | La de E-02                                                                                   |
| P-inm               | V2 con trampas inmediatas (sin bandera ni `settle`)                                           |
| Pl-dif              | Montón **plano** (`Vec<i64>`) con las trampas diferidas de V2                                  |
| Pl-inm              | Montón plano con trampas inmediatas                                                           |
| **Pl-comb**         | Pl-inm con un contador de combustible en lugar del `Option<Timeline>`: el candidato V2R       |
| Época               | Pl-comb con barrera de época por bloque de 64 palabras y registro de deshacer (hipótesis A literal) |
| Tarjetas            | Pl-comb con marcado de tarjetas incondicional (un byte por bloque de 64 palabras, sin rama)   |
| V3                  | La de E-02                                                                                   |
| **Dif**             | Pl-comb con puntos de control diferenciales sin barrera disparados por combustible (T20–T21): el candidato V3R |

### 2.3 Resultados de la ablación (cocientes de medianas)

| Núcleo | Familia | V2/V1 | V1F/V1 | V2/V1F | P-inm/V1F | Pl-dif/V1F | Pl-inm/V1F | **Pl-comb/V1F** | Época/Pl-comb | Tarjetas/Pl-comb | V3/V2 | **Dif/Pl-comb** |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| sieve | arrays | 3,33 | 1,31 | 2,54 | 2,24 | 1,41 | 0,96 | **0,92** | 2,39 | 2,23 | 1,69 | **1,04** |
| queens | arrays | 4,15 | 1,16 | 3,57 | 2,44 | 1,92 | 1,05 | **1,07** | 2,10 | 1,54 | 1,27 | **0,99** |
| permute | recursive | 2,27 | 1,07 | 2,12 | 2,06 | 1,04 | 0,98 | **0,95** | 1,94 | 1,43 | 1,29 | **0,99** |
| mandelbrot | numeric | 1,11 | 1,00 | 1,10 | 1,00 | 1,10 | 1,00 | **1,00** | 1,04 | 1,04 | 1,03 | **1,01** |
| nbody | numeric | 3,38 | 1,04 | 3,25 | 3,17 | 1,51 | 1,27 | **1,08** | 1,75 | 1,36 | 1,09 | **1,05** |
| towers | objects | 3,17 | 1,71 | 1,85 | 1,77 | 1,65 | 1,46 | **0,87** | 2,07 | 1,97 | 1,44 | 1,37 ᵃ |
| list | objects | 2,00 | 1,25 | 1,59 | 1,64 | 1,06 | 0,99 | **1,00** | 1,50 | 1,50 | 1,51 | **1,01** |
| storage | objects | 2,66 | 1,12 | 2,39 | 2,21 | 1,73 | 1,58 | **1,51** ᵇ | 1,77 | 1,26 | 1,13 | **1,02** |
| bounce | objects | 8,73 | 2,88 | 3,03 | 3,09 | 1,45 | 1,31 | **1,12** | 1,91 | 1,59 | 1,21 | 1,16 ᵃ |
| richards | objects | 2,41 | 1,13 | 2,14 | 2,04 | 1,19 | 1,08 | **1,04** | 1,58 | 1,38 | 1,25 | **1,03** |
| **arrays** | media geom. | 3,72 | 1,24 | 3,01 | 2,34 | 1,64 | 1,01 | **0,99** | 2,24 | 1,86 | 1,46 | **1,01** |
| **recursive** | media geom. | 2,27 | 1,07 | 2,12 | 2,06 | 1,04 | 0,98 | **0,95** | 1,94 | 1,43 | 1,29 | **0,99** |
| **numeric** | media geom. | 1,94 | 1,02 | 1,90 | 1,78 | 1,29 | 1,13 | **1,04** | 1,35 | 1,19 | 1,06 | **1,03** |
| **objects** | media geom. | 3,24 | 1,51 | 2,15 | 2,09 | 1,39 | 1,27 | **1,09** | 1,75 | 1,52 | 1,30 | 1,11 |
| **todas** | media geom. | 2,90 | 1,29 | 2,24 | 2,07 | 1,38 | 1,15 | **1,04** | 1,77 | 1,50 | 1,28 | 1,06 |

ᵃ Artefacto de generación de código nativo: en una ejecución de control con el **mismo binario** y el
intervalo mínimo de 2¹⁷ pasos, Towers y Bounce no tomaron **ningún** punto de control en toda la muestra y
conservaron el mismo exceso (1,31 y 1,16). El coste viene de que la sola presencia de la llamada fría dentro
de `enter` altera la asignación de registros del núcleo monomorfizado, no de copiar estado. En la VM la ruta
fría vive fuera del bucle de despacho (§4.5); B1 y E-06 lo comprueban en el motor real.

ᵇ Camino de asignación: el prototipo crece el `Vec` y pone a cero por objeto. T19 asigna por avance en
bloques puestos a cero; E-02R exige Storage ≤ 1,30 o activa la escalera de §10.

La ablación **reproduce la forma de E-02** (V2/V1 entre 2,27 y 3,72 por familia frente a 2,06–4,05
publicados), lo que da confianza en que el prototipo mide el mismo fenómeno.

### 2.4 Lectura por familia

- **arrays (V2/V1 = 4,05 publicado).** Cada lectura pagaba dos traducciones paginadas (longitud y celda),
  `settle()` y la bandera; cada escritura, además, la época y `Rc::get_mut`. Con el montón plano y trampas
  inmediatas el cociente cae a **0,99**. La comprobación de rango del lenguaje no es la causa: V1 también la
  paga.
- **recursive (2,59).** Permute es intercambios en un arreglo de diez elementos y recursión. La parte de
  arreglos se explica como en `arrays`; la de llamadas, por C5. Con V1F como base, **0,95**.
- **numeric (2,06).** Mandelbrot no toca el montón y su cociente ya era 1,14; el resto es la bandera de
  trampas en memoria (C3). NBody lee y escribe campos reales: C1, C2 y C3. Con montón plano y combustible,
  **1,04**.
- **objects (3,60).** Mezcla C1–C6. Bounce (8,73) se explica casi entero por C5: V1 no materializa
  marcos y Bounce llama a `absolute`, `bounce` y `clamp` por bola y ronda; V1F/V1 ya es 2,88. Con V1F como
  base y el montón plano, **1,09**, con Storage como único núcleo fuera del umbral por el camino de asignación.
- **V3/V2.** El exceso publicado (1,11 en objetos, 1,12 en recursión) viene de C8, C9 y C10, no de copiar
  pilas profundas. La alternativa «Dif» con disparo por combustible queda en **1,01–1,05** en las familias
  sin artefactos.
- **Barreras de escritura.** Cualquier barrera por escritura en el camino caliente, sea de época con registro
  de deshacer (hipótesis A literal) o de tarjetas sin rama, cuesta **1,5–1,8×** de media en nativo. Es
  incompatible con `PERF.VM.THROUGHPUT#R2` (observador en pausa ≤ 2 %), que es **más estricto** que la
  hipótesis V3/V2 ≤ 1,10 de D-07.

### 2.5 Veredicto sobre RC-01

**Causa.** RC-01 no lo causa «la memoria persistente» en abstracto, sino tres decisiones concretas de T7
(traducción paginada, `Rc` por página, barrera de época en cada escritura) más dos defectos del experimento:
trampas diferidas implementadas como bandera en memoria y una V1 sin marcos.

**Resolución propuesta, a confirmar con E-02R en B1:**

1. Montón plano de palabras con asas directas (T11): elimina C1, C2, C4 y C6.
2. Trampas inmediatas en la VM (T14): elimina C3.
3. Base de comparación V1F con marcos: corrige C5 en la medición, sin cambiar el diseño.
4. Puntos de control diferenciales **sin barrera**, disparados por el combustible que la VM ya necesita para
   los límites y programados por coste (T20, T21): elimina C8–C10 y cualquier barrera.

**Criterios de cierre de RC-01 (E-02R, §7.1):**

| Cociente        | Puerta (bloquea R5)                                                   | Objetivo          |
|-----------------|-----------------------------------------------------------------------|-------------------|
| V2R/V1F         | ≤ 1,30 por familia **y** por núcleo, con IC 95 % superior ≤ 1,35       | ≤ 1,10 por familia |
| V3R/V2R         | ≤ 1,05 por familia en nativo                                          | ≤ 1,02            |
| V1F/V1          | Se publica; no es puerta: mide el coste de los marcos, que toda VM paga | —               |

La puerta normativa del observador en pausa no es E-02R sino `PERF.VM.THROUGHPUT#R2` medido sobre la VM real
en E-06 (≤ 2 %). E-02R es su indicador temprano.

### 2.6 Lo que E-02 no dice y conviene saber

`reference` tarda entre unas **800 y 3 800 veces** lo que V1 en las mismas cargas de medición (medias de
`macos-r3-awfy` frente a E-02: Sieve 11 066 µs frente a 6,8 µs; Richards 170 130 µs frente a 88,9 µs; Queens
791×; Bounce 3 795×). La puerta de R5 (≥ 10× sobre
`reference`) y su objetivo (30×) quedan muy por debajo del techo nativo. **RC-01 no amenazaba la puerta de
R5**; amenazaba tres cosas que sí importan: la latencia por acceso dentro del intérprete (una carga
dependiente más por acceso es del orden de un despacho), la viabilidad de R6 (el código nativo hereda la
representación, principio 5) y la memoria de la línea temporal (páginas de 32 KiB por cambio). Por eso se
resuelve con la representación, no rebajando el umbral.

---

## 3. Juicio de las hipótesis externas A–D

| Hipótesis | Veredicto | Evidencia | Qué queda en el diseño |
|---|---|---|---|
| **A** Montón plano enmascarado + registro de deshacer por época | **Se adopta la mitad y se descarta la otra mitad.** Montón plano: sí. Máscara: no. Barrera de época por escritura: no | Pl-comb/V1F = 1,04; Época/Pl-comb = 1,77 | T11 (montón plano con comprobación de límites ordinaria) y T20 (deshacer por comparación en el punto de control, sin barrera) |
| **B** Captura de pila por marca de agua | **Se adopta modificada** | E-02 no midió pilas profundas (§2.1); sí importa con 100 000 marcos | Marca de agua actualizada en `return` y en escrituras por celda a marcos inferiores; parte de T20 |
| **C** Guardas de rango en bucles canónicos | **Se rechaza como transformación de la RI en R5**, con disparo medido | La comprobación del lenguaje ya está fusionada con la de definición (T12) en una comparación; en Rust seguro la comprobación de `get` permanece igual | Variante «sin comprobación de índice» en E-02R para acotar la ganancia máxima; si supera 10 % en `arrays` sobre la VM, se implementa la superinstrucción de bucle versionado en B5.5 |
| **D** Intrínsecos y SSO en el asa | **Intrínsecos: ya están en la RI de R3; se completan. SSO: se rechaza** | `IR.INSTRUCTIONS` ya modela las incorporadas como instrucciones sin marco ni eventos; `CaracterEn` devuelve `caracter`, un escalar | T24 (manejadores especializados por tipo) y T13 (apéndice compartido, que ataca el coste real del texto) |

### 3.1 Hipótesis A en detalle

**Lo que acierta.** La paginación es la causa dominante de RC-01: P-inm (páginas con trampas inmediatas)
sigue en 2,07× de media, y Pl-inm (plano) en 1,15×. Un montón contiguo hace los arreglos contiguos de verdad y
elimina una carga dependiente por acceso.

**Lo que no se adopta.**

- **La máscara `addr & HEAP_MASK`.** Exige reservar el montón completo a potencia de dos desde el principio
  (2²² celdas son al menos 32 MiB en móvil, el mismo problema que RC-06) o recalcular la máscara al crecer,
  y en ese caso LLVM ya no puede demostrar el rango y conserva la comprobación. La comprobación ordinaria
  de `get` es una comparación con salto bien predicho, porque el verificador y el sistema de tipos hacen
  imposible un asa inválida (no hay nulo escribible ni aritmética de asas). La máscara no ahorra nada y añade
  una reserva fija. Las máscaras siguen donde el tamaño es una constante de tipo: el código acolchado (T3).
- **La barrera de época por escritura.** Medida en dos formas (época con copia de bloque y tarjetas sin
  rama), cuesta 1,5–1,8× de media en nativo. En un intérprete el cociente será menor porque el despacho
  domina, pero el contrato del observador en pausa es 2 %, y la barrera se paga en **toda** escritura de
  **toda** ejecución observable. El diseño la sustituye por una comparación en el punto de control con un
  presupuesto de sobrecoste fijado (T20, T21).

### 3.2 Hipótesis B en detalle

La hipótesis atribuía el exceso de V3/V2 a copiar `0..top` de los bancos en recursión profunda. En AWFY-core
eso no ocurre (§2.1): las pilas son cortas y el exceso viene de C8–C10. Pero la técnica **sí es necesaria**
para que un punto de control no cueste O(profundidad) con 100 000 marcos (CLI) y para que el intervalo de
T21 no crezca con la pila. Se adopta con dos correcciones que la hipótesis no consideraba:

1. **Celdas a marcos inferiores.** Un parámetro por referencia escribe en una variable de un marco
   suspendido (`cell.store` sobre una ranura local de un llamador). Esa escritura baja la marca de agua a la
   ranura escrita; si no, el prefijo «inmutable» no lo sería.
2. **Ventanas solapadas.** Los argumentos se escriben en las ranuras superiores del llamador; la marca se
   calcula sobre la base del **llamador** al volver, no sobre la del llamado.

Coste: una operación `min` en `return` y en la rama de `cell.store` hacia bancos, en variables locales del
bucle de despacho.

### 3.3 Hipótesis C en detalle

En código nativo optimizado, eliminar comprobaciones de rango con pruebas de inducción es valioso, y lo hará
el generador de código de R6 sobre la misma RI. En la VM de R5 la situación es otra:

- Una carga de elemento entero ya hace **una sola** comparación sin signo contra la «cota densa» de la
  cabecera (T12), que cubre a la vez índice negativo, índice fuera de rango y celda sin valor.
- En Rust seguro, la lectura de la palabra del montón conserva la comprobación de `get` aunque se demuestre
  el índice del lenguaje: eliminar la primera no elimina la segunda.
- Una guarda en la cabecera del `Para` necesita versionar el bucle (copia rápida y copia comprobada) para
  conservar la primera trampa exacta (`ENG.EXEC.EFFECT-ORDER#R2`), lo que duplica código y complica el gemelo.

**Decisión medida, no por opinión:** E-02R incluye la variante V2R-sin-índice (insegura a propósito, solo
experimental) que elimina la comprobación del lenguaje. Si en la VM de B3 la ganancia proyectada en `arrays`
supera el 10 %, B5.5 implementa la superinstrucción de `Para` con guarda y caída exacta; si no, la decisión
de no hacerlo queda registrada con el dato en el README de `pseudolearn_bytecode`.

### 3.4 Hipótesis D en detalle

**Intrínsecos.** `IR.INSTRUCTIONS` ya modela las dieciocho funciones incorporadas como instrucciones propias
(`math.*`, `text.*`, `char.*`, `real.trunc`, `real.round`, `host.random`, `object.copy`), sin `call`, sin
marco y sin eventos, como exige `LANG`: las incorporadas no producen `call`. La hipótesis coincide con R3.
R5 la completa: cada intrínseco tiene código de operación especializado por tipo de operando y su manejador
llama a una función de `pseudolearn_library` marcada `#[inline]`, que Rust permite sin atributos prohibidos.

**SSO de 1–3 caracteres en el asa de 32 bits.** Se rechaza:

- `CaracterEn` devuelve un `caracter`, que es escalar y vive en el banco escalar: **ya** no asigna.
- Codificar cadenas en el asa obliga a comprobar una etiqueta en cada operación sobre referencias y en cada
  ranura que recorre el recolector. Contradice el principio «ningún valor lleva etiqueta de tipo».
- El coste real del texto en programas de estudiante es la **concatenación cuadrática** (`s <- s + c` en un
  bucle copia la cadena entera cada vez). T13 la convierte en O(1) amortizado sin etiquetas.

### 3.5 Propuestas propias que la evidencia exige

1. **Trampas inmediatas en la VM (T14).** En un intérprete cada instrucción tiene su manejador y su
   despacho; una rama de desbordamiento bien predicha cuesta casi nada, y acumular una bandera solo añade
   una escritura. La forma diferida queda **dentro** de superinstrucciones puras, donde sí ahorra despachos,
   con reejecución precisa para atribuir la primera trampa (`IR.INSTRUCTIONS#R3`).
2. **V1F como base comparable** para todo cociente que involucre llamadas.
3. **Disparo por combustible, nunca por reloj (T16, T21).** R3 lo especificó así; `ceiling` usó reloj.
4. **Hallazgos de diseño que R3 no cubría** y R5 resuelve: ausencia de valor en escalares sin etiqueta (T12),
   exactitud del conteo de celdas con registros reutilizados (T15), cambio de gemelo con marcos suspendidos
   (T17), profundidad dependiente del tamaño fijo del banco (T18), determinismo de las funciones
   matemáticas entre plataformas (T23), cancelación en bucles sin sentencias (T16) y prefijo de referencias
   incompatible con la herencia (T11).

---
## 4. Arquitectura «Remanso» por subsistema

Cada técnica declara: **qué es**, **por qué es la opción elegida**, **qué contrato la vuelve observable o
inobservable**, **cómo se valida** y **cómo se subsana dentro de la fase** si un umbral falla.

### 4.0 Principios añadidos a los siete de Clepsidra

Los siete principios del README del motor se conservan. R5 añade tres que la evidencia de E-02 hizo
explícitos; se incorporan al README del workspace en B1.6:

8. **El camino caliente no lleva barreras.** Ninguna instrucción paga por escrito, por página ni por bandera
   el coste de que alguien pueda observar después. Lo que la observación necesita se calcula en el servicio
   de combustible o en la reproducción.
9. **El sobrecoste de observar es un presupuesto, no una consecuencia.** La densidad de puntos de control
   se deriva de un ε fijado (T21); la latencia de retroceso es la variable que se ajusta, nunca el
   rendimiento de quien no mira.
10. **Exactitud nocional separada de la representación.** Lo que el corpus define sobre la máquina nocional
    (celdas, identidad, `sin valor`, variables en ámbito) se calcula con mapas estáticos generados, no
    leyendo lo que casualmente queda en un registro.

### 4.1 `pseudolearn_abi` · disposición compartida

**Responsabilidad.** Declara la disposición compartida de los valores de ejecución (sin cambio de frase).

**Estructuras (constantes y tipos, sin lógica):**

| Elemento | Definición |
|---|---|
| Palabra | `u64`. Los reales se guardan con `f64::to_bits` y se leen con `f64::from_bits` |
| Asa | `Handle(u32)`: dirección de palabra de la cabecera de un objeto, arreglo o cadena. `0` está reservado y significa «referencia sin valor» |
| Cabecera común | Palabra 0: forma (`u32`: clase, tipo de elemento y rango de arreglo, o cadena) y banderas (`u32`). Palabra 1: ordinal de identidad (`u64`) en objetos y arreglos; longitud en puntos de código en cadenas |
| Objeto | Cabecera, palabra de máscara de enteros sin valor (solo si la clase tiene campos enteros no demostrados densos, T12), campos en orden de herencia: los de la superclase primero, después los propios |
| Mapa de referencias por clase | Lista estática de desplazamientos de campos referencia de cada clase (tabla generada por `bytecode`) |
| Arreglo | Cabecera, longitud total, **cota densa** (T12), dimensiones (una palabra por dimensión si el rango es mayor que uno), asa del mapa de definición (solo enteros no densos) y celdas en orden por filas |
| Cadena | Cabecera, longitud en puntos de código, desplazamiento y longitud en bytes dentro de la arena de texto, asa de migas o `0` |
| Marco | Entrada de la pila de control: función, punto de retorno (T17), base escalar y base de referencias |
| Centinelas de ausencia | Real: cualquier patrón NaN. Lógico: `2`. Carácter: `0xFFFF_FFFF`. Referencia: asa `0` |

**Cambio respecto de R3: del prefijo de referencias al mapa por clase.** El prefijo contiguo de referencias
no sobrevive a la herencia simple: si la superclase coloca sus referencias al principio, la subclase no puede
añadir las suyas contiguas sin mover los campos heredados, y los métodos heredados acceden por desplazamiento
fijo. La disposición bidireccional (referencias hacia direcciones negativas, como SableVM) lo resolvería, pero
impide recorrer el montón linealmente desde el inicio de un bloque. Se elige el mapa estático por clase: solo
el recolector lo consulta, y no cuesta nada al ejecutar (§6.2).

**Invariantes.** Una sola definición para VM, runtime, timeline y codegen (R6). Ningún tipo de `abi` depende
de otra capa.

**Valida.** Tests de tamaños y desplazamientos; el verificador de bytecode y el recolector consumen la misma
constante.

### 4.2 `pseudolearn_ir` · representación intermedia verificada

**Qué se construye.** Lo especificado por `IR.MODEL`, `IR.INSTRUCTIONS`, `IR.WELL-FORMEDNESS`,
`IR.TEXT-FORMAT`, `IR.SOURCE-MAP` e `IR.OBSERVATION-POINTS`, más una tabla lateral no normativa.

**Estructuras (en columnas, sin nodos enlazados):**

```text
Module    { name, vocabulary, classes: Vec<ClassDecl>, functions: Vec<Function>, origins: OriginTable }
Function  { name, parameters: Range<ValueId>, result: Type, blocks: Vec<Block> }
Block     { parameters: Range<ValueId>, statement_mass: u32, instructions: Range<InstructionId> }
Columns   { operations: Vec<Operation>, operands: Vec<Operand>, operand_ranges: Vec<Range<u32>>,
            results: Vec<Option<ValueId>>, spans: Vec<Option<SourceSpan>>, value_types: Vec<Type> }
OriginTable { value_origin: Vec<Option<VariableId>>, variables: Vec<VariableInfo { name, scope, declared_span }> }
```

- `Operation` es un `enum` **generado** en `build.rs` desde la exportación de `IR.INSTRUCTIONS`, con tablas
  de firma, trampas, efectos y observación (`GEN-NO-HAND-COPY`). Añadir una instrucción al corpus añade su
  variante; el compilador señala cada consumidor.
- La tabla de orígenes dice qué valor SSA es una versión de qué variable declarada. **No forma parte del
  formato textual**: `pseudo ri` imprime la RI canónica de `IR.TEXT-FORMAT` y una RI leída de texto no tiene
  orígenes. Solo se usa para el estado observable (T15). Es no normativa y lo declara el README.

**Algoritmos.**

- Verificador de `IR.WELL-FORMEDNESS` R1–R9 en orden de texto: dominadores por el algoritmo iterativo de
  Cooper, Harvey y Kennedy; tipos y clases por firma generada; aridad de saltos; masa = número de
  `stmt.enter`; tramo obligatorio en instrucciones con trampa u observación. Informa la **primera**
  violación (R9).
- Lector y escritor del formato textual con forma canónica estable (`IR.TEXT-FORMAT#R2–R3`).

**Cambio respecto de R3: las regiones puras no se materializan.** La pureza es derivable de la tabla de
efectos generada; marcarla en la RI duplicaría información y crearía una invariante más que verificar. El
único consumidor en R5 es la fusión de superinstrucciones puras (T14), que la calcula al generar bytecode.
R6 la calculará igual.

**Contratos.** `IR.*` con los casos `ir` del corpus (aceptación, regla violada y reimpresión exacta) y la
propiedad de `TOOL.CLI.IR`.

**Valida.** Casos `ir` del corpus; un *fixture* negativo por regla R1–R8 con el identificador esperado;
propiedad de ida y vuelta sobre la RI de todo el corpus; mutación aleatoria de textos de RI (el verificador
nunca entra en pánico y siempre informa una regla).

### 4.3 `pseudolearn_lowering` · HIR → RI observable

**Precondición.** El HIR tipado que produce el bloque BF (§4.10); hoy no existe (§6.1).

**Algoritmos clave:**

1. **Orden de evaluación normativo** de `LANG.*` y `ENG.EXEC.EFFECT-ORDER`. `Escribir` evalúa todas sus
   expresiones a temporales antes del único `out.write` (`ENG.EXEC.EFFECT-ORDER#R2`).
2. **Asignación definida.** Análisis de flujo hacia delante «asignada en todo camino» sobre el CFG. Una
   lectura demostrada asignada no emite `value.require`. Una variable entera «quizá asignada» recibe un valor
   lógico de definición en SSA (T12); los demás tipos usan su centinela.
3. **`Para`** según `LANG.CONTROL.FOR`: inicial, final y paso evaluados una vez y en ese orden;
   `loop.check_step` antes de la primera prueba; prueba inclusiva según el signo del paso; incremento
   comprobado también tras la última iteración; el valor de salida es el primero que no supera la prueba.
4. **Paso por referencia** como celda (`cell.local`, `cell.element` con índice fijado una vez y comprobado
   antes de entrar en el cuerpo, `cell.field`).
5. **Llamadas virtuales.** Desvirtualización por jerarquía de clases en mundo cerrado: si el método tiene una
   sola implementación alcanzable desde el tipo estático, `call` directo; si no, `call.virtual`.
6. **Puntos de observación y masas** (`IR.LOWERING#R3`): un `stmt.enter` y un `stmt.exit` por sentencia,
   un `decide.*` por evaluación de condición o selector; masa de sentencia por bloque.
7. **Ciclos sin sentencia.** Componentes fuertemente conexos del CFG cuya masa total es cero (por ejemplo,
   `Mientras Verdadero Hacer FinMientras`): su arista de retroceso se marca como **retroceso de sondeo** en la
   tabla lateral (T16).
8. **Orígenes de variable**: cada parámetro de bloque y cada valor que materializa una variable declarada
   registra su `VariableId`.

**Contratos.** `IR.LOWERING` (P1 verificador, P2 ejecución, P3 masas), `IR.OBSERVATION-POINTS`,
`IR.SOURCE-MAP`, todas las reglas de ejecución de `LANG` por la cobertura `regla → instrucciones`.

**Valida.** P1 y P3 sobre todo el corpus y programas generados; P2 se cumple por la conformidad `execute` y
`trace`; tests espejo de cada traducción, con camino infeliz (trampas en cada posición de evaluación).

### 4.4 `pseudolearn_bytecode` · traducción a bytecode gemelo

**Asignación de registros (T15).**

- Dos clases: escalar y referencia. Cada clase tiene su ventana de marco.
- **Ranuras de origen.** Todos los valores SSA con el mismo `VariableId` reciben la **misma ranura** durante
  el ámbito de la variable. Las copias paralelas entre versiones de una variable desaparecen, y la ranura
  de una variable declarada siempre contiene su valor nocional.
- **Temporales** por exploración lineal en la parte alta de la ventana, por clase.
- Salida de SSA con copias paralelas secuencializadas; los ciclos se rompen con una ranura temporal.

**Mapas generados por punto seguro (T15).** Un punto seguro es toda instrucción que asigna o llama. Para
cada uno, el generador emite:

- **mapa nocional de raíces**: qué ranuras del banco de referencias contienen valores nocionalmente
  alcanzables en ese punto (variables en ámbito y temporales ya evaluados de la evaluación en curso, según la
  aclaración de `ENG.LIMITS` de §6.4);
- **mapa de definición**: qué variables están definitivamente asignadas, definitivamente sin asignar o
  dependen de su lógico de definición;
- en cada punto de observación, la tabla `variable → ranura` y los alias de los parámetros por referencia.

**Formato.** `enum Instruction` de 8 bytes: código de operación (`u8`) y hasta tres operandos `u16`. Los
literales enteros y reales grandes van a un depósito de constantes por función; las cadenas literales, al
depósito de texto del módulo. Código acolchado hasta potencia de dos con `Unreachable`.

**Generación gemela (T5, sin cambio).** Una sola función parametrizada por `Twin::{Fast, Probed}` recorre la
RI y emite los dos gemelos con el mismo mapa de registros. El rápido no contiene `stmt.*` ni `decide.*` ni
registro de escrituras; el sondeado sí.

**Descriptores de bloque.** Por bloque: masa de sentencia, **masa de evento** (número de eventos que produce
el bloque al ejecutarse completo, que es estático: cada instrucción de observación produce exactamente un
evento) y si su arista de entrada es un retroceso de sondeo. El cargo se **fusiona en el salto** que entra en
el bloque (`jump.charge`, `branch.charge`), no en una instrucción aparte.

**Puntos de retorno independientes del gemelo (T17).** Una llamada no guarda el contador de programa de su
gemelo sino un **identificador de punto de retorno**. Cada gemelo tiene su tabla `punto → pc`. Así un marco
suspendido vuelve al gemelo **activo** en el momento del retorno, y cambiar de gemelo no exige reescribir la
pila de control. Coste: una carga indexada por retorno. Sin esto, empezar a observar en lo profundo de una
recursión dejaría los marcos inferiores en el gemelo rápido y perdería eventos al volver.

**Superinstrucciones (T24).** Se eligen con datos: perfil de bigramas y trigramas sobre la ejecución de los
casos `execute` del corpus y de AWFY-core; se validan **fuera de muestra** con las cargas del anexo de E-01,
que no participan en la selección. La tabla elegida es un archivo de datos del crate, con procedencia (fecha,
commit y perfil), regenerable y comprobado por `xtask`. Familias candidatas:

- comparar y saltar por tipo;
- paso de `Para` entero con incremento comprobado y prueba inclusiva;
- carga y escritura de elemento con índice en registro y carga de campo por desplazamiento constante;
- **expresión pura fusionada** (T14): dos o tres operaciones aritméticas puras en una sola instrucción.
  Calcula con `overflowing_*` y comprobaciones de finitud acumuladas en una variable local y, si alguna
  marca está activa, **reejecuta** las operaciones componentes en orden normativo para atribuir la primera
  trampa con su tramo. Es la única forma de trampa diferida en la VM y ejecuta
  `ENG.EXEC.EFFECT-ORDER#P1` sobre código real.

**Verificador de bytecode.** Una vez por función: todo operando es menor que su ventana; todo salto cae en
la función; toda instrucción recibe la clase de registro que espera; todo punto seguro tiene mapas; todo punto
de retorno existe en ambos gemelos. El despacho, las tablas del verificador y el formato textual del bytecode
se generan en `build.rs` desde la tabla de instrucciones del crate y la exportación de la RI.

**Contratos.** Ninguno observable. Lo cubren la conformidad diferencial entre gemelos y las propiedades de
cambio arbitrario de gemelo (§4.5).

### 4.5 `pseudolearn_vm` · ejecución

**Estado del bucle de despacho** en variables locales de la función generada: `pc`, base escalar, base de
referencias, combustible de sentencias, contador de eventos, marca de agua, máscaras de los bancos.

**Bancos crecientes (T18).** `Vec<u64>` y `Vec<u32>` con longitud potencia de dos y acceso
`bank.get(index & mask)`. Una llamada comprueba que la nueva ventana cabe; si no, **duplica** el banco y
recalcula la máscara (amortizado, nunca durante una instrucción que no sea llamada). La profundidad del
lenguaje se comprueba aparte contra el límite configurado. Motivo: con bancos fijos de 2¹⁸ (móvil y Wasm) y
2²⁰ (escritorio), un programa con ventanas grandes agotaría el banco antes del límite de marcos en una
plataforma y no en otra, y `ENG.LIMITS#R2` exige unidades independientes de la plataforma. Además, la memoria
pasa a ser proporcional al uso (resuelve RC-06). Alternativa medida en la trazadora de B3: bancos de tamaño
constante de tipo por clases de tamaño monomorfizadas; se elige la más rápida que conserve la invariante.

**Trampas inmediatas (T14).** Cada manejador devuelve `Result`; la rama de error lleva a una ruta fría que
construye el diagnóstico con el tramo de la tabla lateral. Nada se escribe en memoria cuando no hay trampa.

**Servicio unificado de combustible (T16).**

- Al entrar en un bloque con masa, el salto fusionado resta su masa de sentencia y suma su masa de evento.
- Si el combustible no alcanza para el bloque, la VM **sale** de `run` devolviendo `Exit::Service(motivo)` a su
  llamador. `vm` no conoce la línea temporal ni la API: `timeline` y `api` deciden qué hacer y vuelven a
  llamar a `run`. Es la inversión que respeta las capas (`timeline` importa `vm`, no al revés).
- Motivos de servicio: presupuesto de sentencias (la VM pasa al gemelo sondeado y se detiene **exactamente**
  en la entrada que lo agota), cuanto de sondeo (cancelación, pausa y guarda de tiempo; la cancelación se
  lee de un `AtomicBool` solo aquí), punto de control debido, objetivo de reproducción alcanzado.
- El combustible que se carga es el mínimo de: presupuesto restante, distancia al próximo punto de control y
  cuanto de sondeo.
- **Retrocesos de sondeo.** Las aristas marcadas en la RI (ciclos sin sentencia) restan una unidad de un
  contador de sondeo propio. Solo existen en esos bucles; el resto del código no los paga. Así una ejecución
  de `Mientras Verdadero Hacer FinMientras` se puede cancelar (aclaración de `ENG.EXEC.MODEL#R3`, §6.4).

**Cambio de gemelo en O(1).** En el inicio de un bloque (donde actúa el servicio) y en los puntos de retorno
(T17). Una propiedad nueva lo prueba: **cambiar de gemelo en bloques elegidos al azar** produce la misma
salida, terminación y traza externa que no cambiar.

**Eventos.** El gemelo sondeado escribe directamente en un lote en columnas con la forma binaria de
`API.WIRE-FORMAT#D2` (clase, línea, profundidad, desplazamiento al depósito), sin un objeto por evento, y
registra en un búfer de cambios las ranuras y direcciones escritas para los deltas de `ENG.STATE.INCREMENTAL`.

**Contratos.** `ENG.EXEC.*`, `ENG.TRACE.*`, `ENG.INPUT`, `ENG.LIMITS`, `IR.OBSERVATION-POINTS#P1`.

**Valida.** Conformidad `execute` y `trace`; diferencial entre gemelos en todo el corpus; propiedad de cambio
arbitrario; límites en el borde exacto, uno por encima y recursión mutua; cancelación en bucles sin
sentencias; robustez con programas generados.

**Trazadora de rendimiento (B3.3).** Antes de construir el runtime completo, la VM ejecuta Mandelbrot, un
bucle entero equivalente a la parte numérica de Sieve y una recursión de enteros, y se mide
ns/instrucción y la aceleración proyectada contra `reference`. Es la señal temprana de RC-05 que R3 pidió
«al empezar R5».

### 4.6 `pseudolearn_runtime` · valores, montón y recolector

**Responsabilidad (frase revisada).** Gestiona los valores de ejecución en un montón plano determinista.

**Montón plano de palabras (T11).**

- `words: Vec<u64>`; asa = índice de palabra de la cabecera; `0` reservado.
- Acceso `words.get(index)`: una comparación bien predicha y una carga. Un fallo de `get` solo puede venir
  de un defecto del motor y produce `DIAG.ENGINE.INTERNAL-FAULT`.
- Las asas son índices, no punteros: crecer el `Vec` no invalida ninguna.
- Crecimiento por duplicación determinista; el anfitrión que no puede reservar memoria recibe un error de
  recurso de la API, nunca un pánico ni un observable del programa.

**Asignación por avance en bloques puestos a cero.** El asignador reserva tramos de 2¹² palabras ya puestos a
cero y avanza un puntero dentro del tramo; tras una recolección reutiliza huecos según la variante que elija
E-12 (listas por clase de tamaño o líneas tipo Immix sin evacuación). El orden de reutilización es
determinista (dirección ascendente). Corrige el exceso de Storage (§2.3 ᵇ).

**Ausencia sin etiquetas (T12).**

| Tipo | Representación de `sin valor` | Coste en lectura | Coste en escritura |
|---|---|---|---|
| real | Cualquier NaN (ningún real almacenado puede ser NaN: todo resultado no finito atrapa antes) | Una comparación | Ninguno |
| lógico | `2` | Una comparación | Ninguno |
| carácter | `0xFFFF_FFFF` (fuera del dominio Unicode) | Una comparación | Ninguno |
| referencia | Asa `0` | Una comparación (que además protege el acceso a miembro) | Ninguno |
| entero en variable | Lógico de definición en SSA, solo si la asignación definida no lo demuestra | Ninguno si está demostrada | Ninguno |
| entero en arreglo | **Cota densa**: la cabecera guarda `longitud` si todas las celdas tienen valor y `0` si no; mapa de bits lateral mientras no es denso | Una comparación sin signo `índice < cota densa` (cubre negativo, rango y definición); camino lento solo si falla | Solo mientras el arreglo no es denso |
| entero en campo | Bit en la palabra de máscara del objeto; clases con todos sus campos enteros asignados en todo constructor antes de escapar `Este` no tienen máscara | Una comparación de bit | Un borrado de bit solo en clases con máscara |

Es el hueco que R3 no cerró: «banco escalar sin etiquetas» y «lectura sin valor atrapa siempre»
(`LANG.DECL.UNINITIALIZED`) son incompatibles para enteros sin una de estas técnicas. Con ellas, el coste
recae solo donde el tipo lo exige y desaparece en el caso habitual (arreglos ya inicializados, variables
asignadas antes de usarse). En Wasm, los NaN producidos por aritmética pueden variar de carga útil, pero
el centinela solo se escribe y se lee como bits y cualquier NaN significa ausencia: el determinismo no
depende de la carga útil.

**Texto (T13).**

- **Arena de texto de solo apéndice** (`Vec<u8>`, UTF-8) separada del montón de palabras. Las cadenas son
  cabeceras en el montón que apuntan a un tramo de la arena.
- **Concatenación por apéndice compartido.** Si la cadena izquierda termina exactamente en el final usado de
  su tramo, los bytes de la derecha se escriben a continuación y la nueva cabecera reutiliza el tramo
  extendido. Toda cadena es un prefijo inmutable: quien conserva la cadena anterior sigue viendo su longitud.
  Si la condición no se cumple (otra concatenación ya extendió el tramo), se copia. `s <- s + c` en bucle es
  O(1) amortizado.
- Indicador ASCII y **migas cada 64 puntos de código**, calculadas al primer `CaracterEn` no ASCII y
  extendidas, no recalculadas, cuando el tramo crece por apéndice.
- La arena **nunca se reescribe** salvo por la compactación del recolector, que desliza tramos vivos
  conservando el orden y actualiza las cabeceras. Entre compactaciones, un punto de control solo necesita su
  longitud (T20).
- Conteo de celdas: cada cadena creada en ejecución cuenta `1 + ⌈puntos/8⌉` una vez mientras sea alcanzable,
  aunque comparta tramo con otra (aclaración de `ENG.LIMITS#D1`, §6.4).

**Recolección exacta y determinista (T19).**

- Marcado iterativo con pila explícita (nunca recursivo) y **mapa de bits lateral**; barrido según la
  variante de E-12; compactación de la arena de texto.
- **Raíces exactas**: para cada marco, las ranuras que marca el mapa nocional de su punto seguro (el punto de
  retorno de los marcos suspendidos; la instrucción actual del marco activo). Un registro temporal muerto
  que conserva un asa antigua no cuenta. Es lo que hace exacto `ENG.LIMITS` sin coste de ejecución: los mapas
  solo se leen al recolectar.
- **Disparo determinista**: tras asignar `max(G_min, γ · vivas_tras_última)` celdas, con `γ = 1` por omisión.
- **Límite de celdas exacto**: si `vivas_tras_última + asignadas_desde_entonces + celdas_del_valor_nuevo`
  supera el límite, se recolecta y se decide con el valor exacto (`ENG.LIMITS#R2`, que cuenta el valor nuevo).
- **Modo de recolección forzada en cada asignación** (configuración interna, no observable) para
  `MEM.MANAGED.UNOBSERVABLE#P1` (Q1).
- Identidad = ordinal de 64 bits en la cabecera; nunca se reutiliza (`MEM.IDENTITY`).

**Aritmética y azar.** Enteros con `checked_*`; `int.mod` del mínimo entre −1 devuelve 0
(`LANG.OPS.DIVISION`); reales con comprobación de finitud; xoshiro256\*\* sembrado con SplitMix64
(`RT.HOST.INTERFACE#R3`).

**Contratos.** `MEM.*`, `RT.HOST.INTERFACE`, la ejecución de `LANG.TYPES.*`, `LANG.OPS.*` y `LANG.ARRAY.*`,
`ENG.LIMITS` (celdas).

### 4.7 `pseudolearn_library` · funciones incorporadas

- Funciones puras sobre valores del runtime, sin estado global; el azar llega por la capacidad inyectada.
- Firmas generadas de `LIB.MODEL`; cada función marcada `#[inline]` para que el manejador de la VM la
  integre.
- **Matemática determinista (T23).** `rc` usa `f64::sqrt`, correctamente redondeada por IEEE 754 en todas las
  plataformas. `ln`, `exp`, `sen`, `cos`, `atan` y la potencia real **no** pueden usar `f64::ln` y familia:
  llaman a la `libm` de cada plataforma (Apple, glibc, MSVC, el puerto de Rust para Wasm) y difieren en el
  último bit entre plataformas. Como `LANG.IO.VALUE-FORMAT` imprime el real completo en notación posicional,
  esa diferencia **es observable** y rompe `ENG.EXEC.MODEL#R2` y E-17. La biblioteca implementa estas seis
  funciones en Rust seguro con **redondeo correcto** (estrategia de Ziv: aproximación rápida en doble-doble
  con cota de error; si la prueba de redondeo falla, evaluación en precisión múltiple que siempre decide).
  El redondeo correcto es la única definición que es a la vez independiente de la plataforma y derivable
  por un oráculo independiente (`SPEC-INDEPENDENT-ORACLE`): exige la aclaración de `LIB.CORE.MATH`,
  `LANG.OPS.POWER` y `LANG.TYPES.REAL` de §6.4 (D-R5-08).
- **Formato de reales.** Dígitos mínimos de ida y vuelta, en notación posicional y con al menos un decimal.
  `Display` de Rust da los dígitos mínimos en posicional; la biblioteca añade `.0` cuando falta. Es
  determinista porque no depende de la plataforma.
- `AReal` usa el analizador de Rust, que redondea correctamente; `AEntero` valida rango.
- `Copiar` copia un nivel, conserva campos sin valor (máscara y centinelas) y no ejecuta constructor.

**Contratos.** `LIB.CORE.*`, `LIB.MODEL`.

**Valida.** Casos `execute` de `LIB`; para T23, un oráculo en `see_oracles` que evalúa con aritmética
racional exacta y comprueba el redondeo en 10⁶ argumentos por función (aleatorios, bordes y casos difíciles
conocidos); E-17 compara bit a bit nativo y Wasm.

### 4.8 `pseudolearn_timeline` · línea temporal

**Punto de control diferencial sin barrera (T20).** Un punto de control guarda:

- registros de la VM, pila de control, estado del azar, cursor de salida, posición en la cinta de entradas,
  ordinal de sentencias, índice de evento, ordinal de identidad y contadores del recolector;
- **montón**: el timeline mantiene una **imagen sombra** igual al montón del último punto. Al tomar uno
  nuevo compara el montón vivo con la sombra por bloques de 64 palabras (comparación de porciones, que el
  compilador convierte en `memcmp` vectorizado); por cada bloque distinto guarda su contenido **antiguo** en
  el **segmento de deshacer** del intervalo y actualiza la sombra. Las palabras por encima del puntero de
  avance del punto anterior se copian sin comparar;
- **texto**: solo la longitud usada de la arena (es de solo apéndice entre compactaciones; una compactación
  marca la arena para copiarla en el siguiente punto);
- **bancos**: la región `[marca de agua, cima)` y un enlace al punto anterior para el prefijo (hipótesis B
  corregida, §3.2).

Coste en el camino caliente: **cero** por escritura. Coste por punto: O(montón mutable) en comparación, más
O(cambiado) en copia. Memoria: una sombra del montón de palabras más los segmentos.

**Programación proporcional al coste (T21).** El siguiente punto se programa a una distancia, en unidades de
masa de sentencia, `D = max(Q_min, κ · S)`, donde `S` es el tamaño en palabras del estado que compara el
punto (montón vivo más región de bancos). El coste de un punto es proporcional a `S`, así que el sobrecoste
acumulado está acotado por `coste_por_palabra / (κ · coste_por_sentencia)` y por el coste fijo dividido entre
`Q_min`. **Se elige ε y se derivan κ y Q_min**, calibrados en E-06 sobre la VM real, en unidades
deterministas (nunca reloj). Es la regla del intervalo óptimo de puntos de control de Young (1974) y Daly
(2006), con la «tasa de fallos» sustituida por la tasa de consultas al pasado. La latencia del primer
retroceso queda acotada por `D` a velocidad del gemelo rápido. Valores iniciales de partida, a recalibrar:
`Q_min = 2¹⁷` sentencias y `κ = 16`, que en la ablación dieron 1,01–1,05.

**Raleo y presupuesto.** Puntos densos cerca del presente y exponencialmente espaciados hacia el pasado.
Eliminar un punto **fusiona** sus dos segmentos de deshacer vecinos (en un bloque presente en ambos se
conserva el contenido más antiguo). El presupuesto de memoria lo configura el anfitrión; la ejecución declara
su horizonte retenido (`API.STATE.QUERY#R3`).

**Retroceso y reproducción acelerada (T22).**

1. Elegir el último punto con índice de evento ≤ k.
2. Restaurar en una **VM de reproducción** independiente: copiar la sombra y aplicar los segmentos de
   deshacer desde el presente hacia ese punto; restaurar bancos ensamblando segmentos.
3. Avanzar con el **gemelo rápido** usando el contador de eventos como combustible: el servicio se detiene en
   el bloque en el que caería el evento k.
4. Cambiar al gemelo sondeado y avanzar hasta k exacto.
5. **Densificación perezosa:** durante la reproducción se toman puntos adicionales cerca de k, de modo que
   los retrocesos siguientes en la misma zona son cortos.

La reproducción suprime la salida (cursor), lee entradas de la cinta y nunca cambia la continuación de la
ejecución presente (`API.EXECUTE#R4`).

**Consultas de estado (T15).** Por referencia y por instante (`API.STATE.QUERY#R1–R2`): lista de marcos
(pila de control y nombres), variables de un marco (ranuras de origen, mapa de definición, alias de
parámetros por referencia y receptor), objeto por identidad (tabla de exposición ordinal → asa registrada al
entregar cada vista) e intervalo de celdas de un arreglo. Las vistas se materializan como datos propios:
inmutables por construcción (`ENG.STATE.SNAPSHOT#R7`).

**Deltas por evento.** El búfer de cambios del gemelo sondeado se convierte en el cambio de estado de cada
evento (`ENG.STATE.INCREMENTAL#R1`): variables escritas, celdas y campos modificados, objetos creados y
marcos apilados o retirados.

**Contratos.** `ENG.STATE.*`, `API.STATE.QUERY`, `API.EXECUTE#R4` (capacidad `seek`), `PERF.VM.STEP-LATENCY`,
`PERF.VM.THROUGHPUT#R2`.

### 4.9 `pseudolearn_api`, adaptador y CLI

- `API.EXECUTE`: iniciar con semilla, límites y entradas; avanzar por lotes o hasta una condición de
  `ENG.TRACE.STEP`; entregar entrada; cancelar; posicionarse (`seek`).
- `API.STATE.QUERY`: consultas de §4.8 con horizonte declarado.
- `API.VERSIONING`: capacidades `analyze`, `execute`, `observe`, `seek` e `interface_language`, anunciadas solo
  cuando existen.
- `API.WIRE-FORMAT`: JSON canónico y binario columnar con ida y vuelta.
- Barrera final de defectos: todo pánico imposible se trata como `DIAG.ENGINE.INTERNAL-FAULT`; los tests de
  robustez exigen **ausencia** de pánicos, no solo su captura.
- `pseudolearn_conformance`: capacidades `execute`, `observe` (casos `trace`), `ir` y la propiedad de
  recolección forzada (`gc_stress`, D-R5-11); `cli` sigue pasando por el binario `pseudo`.
- `apps/pseudolearn_cli`: `pseudo ejecutar`/`run` y `pseudo ri`/`ir` según `TOOL.CLI.RUN`, `TOOL.CLI.IR`,
  `TOOL.CLI.CONVENTIONS` y `TOOL.CLI.MESSAGES` (narración de `--traza` con las plantillas `trace*` del idioma
  de interfaz; la salida del programa nunca se traduce).

### 4.10 Front-end heredado de R4: reescritura como tareas de R5 (T25, T26)

**Qué se conserva y qué se reescribe.** La decisión se toma por pieza, con la evidencia de §6.1:

| Pieza | Decisión | Motivo |
|---|---|---|
| `pseudolearn_source`, `pseudolearn_diagnostics`, `pseudolearn_lexicon` | Se conservan; se completan sus tests espejo | Generados desde el corpus y sin divergencias atribuibles |
| Lexer en columnas, árbol postorden y reimpresión de `syntax` | Se conservan | `TOOL.SERVICE.LOSSLESS-TREE` cumple; es la arquitectura aprobada (T1) |
| `NodeKind` y vistas de `syntax` | **Se reescriben generados** desde `LANG.SYNTAX.GRAMMAR` en `build.rs` | Hoy están escritos a mano, contra 09 §12.2 y `GEN-NO-HAND-COPY` |
| Recuperación y diagnósticos léxicos de `syntax` | **Se reescriben** por contextos con cierre esperado y conjunto de sincronización, como fijó el plan 10 §2.4 | 120 diagnósticos sobrantes en cascada y diez comprobaciones léxicas y sintácticas ausentes |
| `pseudolearn_semantic` | **Se reescribe completo** | Recorre el árbol en el ámbito global, tipa cuatro clases de nodo y no produce HIR; corregirlo por partes costaría más que escribirlo con su diseño |
| Análisis en `pseudolearn_api` | Se adapta al HIR y al esquema; se conservan modelo, errores y versionado | La API ya tiene la forma de los contratos |
| Mensajes de `apps/pseudolearn_cli` | **Se generan** desde la exportación de `TOOL.CLI.MESSAGES` | Hoy son literales en `messages.rs` |

**HIR tipado en columnas (T25).** Arenas con índices tipados, en el orden de inserción determinista:

```text
HirModule    { units: Vec<HirFunction>, classes: Vec<HirClass>, locals: Vec<HirLocal>,
               expressions: ExpressionColumns, statements: StatementColumns, types: TypeInterner }
HirFunction  { kind: Main | Procedure | Function | Method | Constructor, name, owner: Option<ClassId>,
               parameters: Range<LocalId>, result: TypeId, body: Range<StatementId>, span }
HirLocal     { name, type_id, passing: Value | Reference, declared_span, scope }
HirClass     { name, superclass: Option<ClassId>, fields: Vec<HirField>, methods: Vec<FunctionId>,
               virtual_slots: Vec<FunctionId>, constructors: Vec<FunctionId> }
HirExpression{ kind, type_id, value_class: Scalar | Reference, span }
  kind: Literal | Local | Field | Element | Call | VirtualCall | Builtin | New | Unary | Binary
        | Widen | This | SuperCall
HirPlace     : Local | Field | Element | WholeArray       (designador, distinto de valor)
HirStatement : Assign | If | While | Repeat | For | Switch | Write | Read | Call | Return | Dimension
```

- La ampliación entero → real es un nodo `Widen` explícito según el rigor: `lowering` nunca deduce
  conversiones.
- `LocalId` es la identidad de variable que la RI conserva en su tabla de orígenes (T15).
- Las incorporadas se resuelven a su identidad de `LIB.MODEL` con firma generada.

**Pasadas, en este orden y cada una con su responsabilidad:**

1. registro de unidades, clases y firmas (duplicados, nombres reservados, parámetros duplicados);
2. jerarquía de clases (herencia circular, sobrescrituras compatibles, ranuras virtuales);
3. ámbitos y resolución de nombres **por unidad y por bloque** (miembros, privacidad, `Este` y `Super` dentro de
   método);
4. tipos y rigor (operadores, llamadas con aridad y tipos, asignaciones, designadores válidos, arreglos como
   valor, condiciones lógicas);
5. flujo (asignación definida con `variableUsedUninitialized` según rigor, retornos, modificación de la variable
   de control, variables no usadas);
6. emisión del HIR solo si no hay errores; las advertencias no la impiden.

Un símbolo inválido conserva su identidad y su causa, y suprime los diagnósticos que dependen de él, nunca los
independientes (`DIAG.CLASSES`). Con errores léxicos o sintácticos no se ejecuta ninguna pasada semántica.

**Recuperación sin cascadas (T26).** El lexer entrega los fragmentos inválidos como trivia de error asociada al
token siguiente, no como hueco de expresión; cada contexto del parser registra su cierre esperado y su conjunto
de sincronización; cada paso consume un token, cierra un contexto o devuelve el control al dueño del cierre.
Límite de anidación del análisis según el contrato nuevo de §6.4, comprobado antes de cada descenso.

**Rendimiento.** E-08 midió ~140 000 líneas/s, constante entre 1 000 y 50 000 líneas: el coste es lineal pero
con una constante unas siete veces mayor de la admitida. Se perfila antes de optimizar, con el perfilador del
sistema operativo (sin cadenas nuevas). Hipótesis a contrastar con el perfil, no a asumir: asignaciones por token
o por diagnóstico, cadenas reconstruidas para comparar lexemas, normalización NFC fuera del camino ASCII y
presentación de mensajes dentro del análisis en lugar del borde.

**Contratos.** `LANG.*` y `DIAG.*` de análisis, `API.ANALYZE`, `TOOL.CLI.CHECK`, `TOOL.CLI.CONVENTIONS`,
`TOOL.CLI.MESSAGES`, `TOOL.SERVICE.LOSSLESS-TREE`, `PERF.FRONTEND.THROUGHPUT` y el contrato nuevo de límites de
análisis.

---

## 5. Comparación con las soluciones típicas

### 5.1 Tabla

Las valoraciones de Remanso son hipótesis respaldadas por la ablación de §2; E-02R, E-06 y `PERF.VM.*` las
confirman o las refutan dentro de R5.

| Solución                                                   | Ejemplos                              | Coste por escritura al grabar | Coste de un punto de control | Memoria por punto     | Retroceso                 | Determinismo entre plataformas | Seguridad          |
|------------------------------------------------------------|---------------------------------------|-------------------------------|------------------------------|-----------------------|---------------------------|--------------------------------|--------------------|
| Instantánea completa por paso                              | Python Tutor, núcleo Dart              | —                             | O(estado) por **paso**        | Estado completo       | Sí, caro                  | No especificado                | Sí                 |
| Montón persistente paginado con copia en escritura         | Clepsidra R3 (T7)                      | Época + `Rc::get_mut`, siempre | O(páginas)                   | 32 KiB por página tocada | Sí                    | Sí                             | Sí                 |
| Barrera de época con registro de deshacer                  | Hipótesis A literal; muchas BD en memoria | Carga, comparación y rama, siempre | O(cambiado)              | Bloques cambiados     | Sí                        | Sí                             | Sí                 |
| Marcado de tarjetas                                        | Recolectores generacionales (Hölzle 1993) | Un byte por escritura       | O(tarjetas) + O(cambiado)    | Bloques cambiados     | Sí                        | Sí                             | Sí                 |
| Protección de páginas del sistema operativo                | Puntos de control incrementales con `mprotect`, *soft-dirty* | Fallo de página la primera vez | O(páginas sucias) | Páginas del SO | Sí       | No en Wasm ni en iOS            | Requiere `unsafe`  |
| Grabación y reproducción del proceso                       | rr                                    | Bajo                          | Bifurcar el proceso           | Copia en escritura del SO | Sí                     | No                             | No aplica a apps   |
| Estructuras persistentes (HAMT, árboles)                   | Clojure, Immer                        | Copia de camino O(log n)       | O(1)                          | Nodos compartidos     | Sí                        | Sí                             | Sí                 |
| **Remanso**                                                | —                                     | **Cero**                      | **O(montón) en comparación vectorizada, programado para costar ≤ ε** | **Bloques de 64 palabras cambiados + una sombra** | **Sí, a velocidad del gemelo rápido hasta el bloque** | **Sí, incluidas funciones matemáticas** | **Sí, sin `unsafe`** |

### 5.2 Dónde gana

1. **Ejecutar sin observar cuesta lo mismo que no poder observar.** Ninguna escritura paga nada. La ablación
   sitúa el montón plano con combustible a 1,04× de la representación directa con marcos.
2. **El sobrecoste de grabar es un parámetro.** Las soluciones con barrera tienen un coste que depende del
   programa (proporción de escrituras). Remanso tiene un coste que depende de ε, elegido por la persona
   responsable y garantizado por construcción.
3. **El texto deja de ser cuadrático.** La concatenación en bucle, el patrón más común en ejercicios de
   texto, pasa de O(n²) a O(n) total, sin etiquetas ni conteo de referencias.
4. **Determinismo real entre plataformas**, incluidas las funciones trascendentes y la profundidad máxima:
   dos huecos que el diseño de R3 dejaba abiertos y que E-17 habría encontrado tarde.
5. **Exactitud nocional sin coste de ejecución.** El conteo de celdas, `sin valor` y el estado observable
   salen de mapas estáticos; el bucle de despacho no los conoce.
6. **Una sola disciplina con R6.** El montón plano con asas de 32 bits, las ranuras de origen y los mapas
   nocionales son exactamente lo que necesita el código nativo: un puntero base más un desplazamiento y
   mapas de pila por punto seguro.

### 5.3 Dónde no es mejor, dicho de antemano

| Aspecto | Quién gana | Por qué se acepta | Qué lo mediría o revertiría dentro de R5 |
|---|---|---|---|
| Coste de un punto de control en montones grandes | Barreras de escritura (O(cambiado)) | El coste se amortiza por programación (T21); la escritura no paga nada | E-06: si la latencia del primer retroceso con 2²² celdas supera el objetivo de D-R5-15, escalera RR-03 |
| Memoria con grabación activa | Barrera con registro de deshacer (sin sombra) | La sombra duplica el montón de palabras **solo mientras se graba**; el texto no se duplica | E-06 mide RSS; escalera RR-04 |
| Programas que solo escriben en una fracción mínima de un montón enorme | Tarjetas | Remanso compara todo el montón; las tarjetas solo lo cambiado | E-06 con carga sintética «montón grande, escrituras escasas»; peldaño de tarjetas en el gemelo de grabación |
| Simplicidad | Montón paginado de R3 | La comparación y los segmentos son más código que copiar una tabla de páginas | Complejidad medida por tamaño y por mutantes supervivientes (E-16) |
| Bucles numéricos largos | JIT, R6 | iOS prohíbe JIT; el escritorio tendrá Cranelift | `PERF.AOT.LEVEL` en R6 |
| Concatenación que antepone (`c + s`) | Ropes | Es poco frecuente; se copia | Perfil del corpus en B5.5; si aparece en la selección de superinstrucciones, se reevalúa |

### 5.4 Genealogía: qué se toma y qué se rechaza

| Fuente | Se toma | Se rechaza |
|---|---|---|
| Young (1974); Daly (2006), intervalo óptimo de puntos de control | Densidad de puntos derivada del coste y de un presupuesto | Reloj como unidad |
| Puntos de control incrementales por comparación (literatura de HPC) | Detectar cambios comparando con la imagen anterior | Detección por *hash* (falsos negativos) y protección de páginas del SO |
| Hölzle (1993), barrera por tarjetas | Peldaño alternativo medido | Barrera en el camino caliente por defecto |
| Gagnon y Hendren (2001), disposición bidireccional de SableVM | La idea de separar referencias de escalares | La disposición bidireccional: impide el recorrido lineal |
| Mapas de pila de HotSpot y de LLVM `statepoint` | Mapas por punto seguro | Mapas para tipos (el banco ya da la clase) |
| `append` de Go sobre porciones; `s += t` de CPython | Apéndice en sitio sin copiar | Condición por conteo de referencias (CPython) |
| Migas de las cadenas de Swift | Migas cada 64 puntos | UTF-16 |
| Ziv (1991); CRlibm y CORE-MATH (Zimmermann et al.) | Redondeo correcto en dos etapas | Depender de la `libm` de la plataforma |
| Ertl y Gregg (2003); validación fuera de muestra de la ingeniería de rendimiento | Superinstrucciones por perfil, con conjunto de validación separado | Elegirlas por intuición o con AWFY como única muestra |
| Lua 5 (registros), JVM (verificador), Self (cambio de código) | Se conserva de R3 | — |
| rr (O'Callahan et al., 2017) | Grabar solo el no determinismo | Grabación del proceso |
| Immix (Blackburn y McKinley, 2008) | Candidato de E-12 (líneas sin evacuación) | Evacuación (dispersa la sombra y los segmentos) |

---
## 6. `CONFLICT-REPORT`: hallazgos previos y cambios propuestos

Nada de esta sección se aplica sin la respuesta de la persona responsable. Cada fila dice qué estaba
decidido, qué propone este plan y por qué.

### 6.1 Deuda heredada: la evidencia de R4 no sostiene su cierre

| Fuente | Afirma | Lo que muestra el repositorio |
|---|---|---|
| [07](07-fases.md) R4, criterio 1 (marcado) | «`engine` en `cumple` para todos los casos de análisis (492 observaciones, 0 regresiones)» | `packages/pseudolearn_spec/results/engine.json`, versionado en `214fbae`, registra **162 `cumple` y 330 `incumple`** de 492. Reejecutar `see conform --subject engine --operation analyze` el 2026-10-15 reproduce el mismo archivo byte a byte («Executed 492 observations; 330 divergences»). Las especificaciones con más observaciones en `incumple`: `LANG.SYNTAX.RECOVERY` (14), `LANG.CONTROL.FOR` (12) y trece con 8 cada una, entre ellas `LANG.SUBPROGRAM.CALL`, `LANG.CLASS.SELF-AND-SUPER` y `LIB.MODEL` |
| [10](10-plan-r4-frontend.md) B5.3 (marcado) | «Producir HIR tipado con tramos y referencias válidos» | `pseudolearn_semantic` expone `SemanticModel` con símbolos, ámbitos y diagnósticos, **sin** HIR de expresiones ni sentencias. `expression_checker.rs` solo tipa literales, identificadores, binarias y unarias; el resto devuelve `Type::Unknown` |
| `GEN-NO-HAND-COPY` | Ningún lexema escrito a mano | `pseudolearn_semantic/src/types.rs` contiene `Type::from_name` con lexemas copiados a mano, algunos inexistentes en el vocabulario (`float`, `numero`, `vacio`, `void`). No se usa: es código muerto con datos copiados |
| [07](07-fases.md) R4, criterio 3 (marcado) | «`PERF.FRONTEND.THROUGHPUT` medido (1,8M líneas/s en 10 000 líneas, p95 5,9 ms < 16 ms en Apple M2)» | `results/r4-e08-throughput.json` registra entre **125 596 y 141 785 líneas/s** en las 24 configuraciones y p95 de **72–77 ms** para 10 000 líneas. Solo hay un resumen: faltan los datos crudos, los diez procesos y los intervalos que exige `PERF.PROTOCOL` |
| [07](07-fases.md) R4, contenido CLI (marcado) | `comprobar`/`check` y `preferencias`/`preferences` según `TOOL.CLI.*` | `results/cli.json`: 29 `cumple` y 20 `incumple`; 7 de ellos son de R4 (`TOOL.CLI.CONVENTIONS` 5, `TOOL.CLI.CHECK` 1, `TOOL.CLI.MESSAGES` 1). `apps/pseudolearn_cli/src/messages.rs` escribe a mano la prosa bilingüe que `TOOL.CLI.MESSAGES` exige generar |
| [10](10-plan-r4-frontend.md) D-R4-05 | Límites de análisis especificados antes de implementarlos | Ningún contrato del corpus define la profundidad de anidación admitida por el análisis ni su diagnóstico |
| [10](10-plan-r4-frontend.md) §2.2 y 09 §12.2 | Vistas tipadas generadas de `LANG.SYNTAX.GRAMMAR` | `NodeKind` está escrito a mano en `pseudolearn_syntax/src/tree.rs`; `syntax` no tiene `build.rs` |
| `TEST-MIRROR` y 07 R4 (robustez) | Tests espejo de `src/` por módulo | Un archivo de tests por crate, unos treinta tests en total en el motor |
| [07](07-fases.md) §3 | Cada fase cerrada tiene informe | La cabecera de 07 sigue diciendo «R4–R9 pendientes» y no hay «Informe de ejecución R4», aunque las casillas de R4 están marcadas |

**Causas de las 330 divergencias de análisis** (diagnósticos sobrantes y faltantes sumados sobre todas las
observaciones en `incumple`):

| Causa | Diagnósticos implicados | Origen en el código |
|---|---|---|
| Resolución de nombres sin ámbitos | 86 `undeclaredVariable`, 78 `duplicateSubroutine` y 8 `duplicateClass` **sobrantes** | `SemanticChecker::check` recorre todos los nodos del árbol en el ámbito global, sin entrar en el de cada unidad |
| Cascadas de recuperación y léxicas | 88 `expectedExpression`, 20 `unclosedParenthesis`, 12 `expectedIdentifierInDeclaration` **sobrantes** | Un token léxico inválido se entrega al parser como hueco de expresión, contra `DIAG.CLASSES` |
| Código de ejecución emitido en el análisis | 24 `uninitializedVariableRead` sobrantes y 6 `variableUsedUninitialized` faltantes | El análisis usa el diagnóstico de ejecución en lugar del estático de `LANG.DECL.UNINITIALIZED` |
| Tipado incompleto | 32 `incompatibleOperandTypes` y 12 `nonBooleanCondition` sobrantes; 28 `incompatibleArgumentType`, 20 `argumentCountMismatch`, 8 `incompatibleTypesInAssignment` faltantes | `expression_checker.rs` solo tipa cuatro clases de nodo |
| Comprobaciones ausentes | `reservedLexemeUsedAsName`, `invalidEscapeSequence`, `integerLiteralOutOfRange`, `emptyParentheses`, `missingStatementTerminator`, `chainedArrayAccess`, `emptyDimensionList`, `invalidAssignmentTarget`, `arrayCannotBeUsedAsValue`, `duplicateParameterName` y quince comprobaciones de clases (`circularInheritance`, `privateMemberAccess`, `undefinedMember`, `incompatibleMethodOverride`, `thisOutsideMethod`, `superOutsideMethod`…) | Léxico, parser y semántica no las implementan |

**Consecuencia para R5.** `lowering` traduce un HIR tipado; sin él, R5 no puede empezar por su primer paso.
Además, la conformidad de ejecución de R5 incluye los mismos programas (`execute` y `trace` parten de
programas que deben analizarse sin errores), y `PERF.FRONTEND.THROUGHPUT` forma parte del corpus que R5 exige
en `cumple`.

**Decisión (D-R5-01, 2026-10-15).** La persona responsable decidió que **R4 se mantiene cerrada** y que toda su
deuda se resuelve como tareas de R5, reescribiendo el front-end donde convenga. En consecuencia:

- el bloque **BF** de §8 contiene la remediación completa, antes de B1, con su propia evidencia
  (`r5-frontend-*.json`);
- §4.10 fija la arquitectura del front-end reescrito (T25, T26);
- las casillas y el texto de R4 en 07 **no se modifican**; el informe de R5 incluye el apartado «Deuda heredada
  de R4» con estos hallazgos, su causa y su resolución, para que la historia sea trazable;
- los criterios de R4 incumplidos pasan a ser criterios de R5 (§11) y no admiten pendiente.

### 6.2 Cambios sobre la arquitectura Clepsidra de [09](09-plan-r3-motor-clepsidra.md) y los `README.md`

| Decisión de R3 | Dónde está | Propuesta de R5 | Motivo |
|---|---|---|---|
| T7: montón paginado, páginas de 4 096 palabras en `Rc`, época por página, copia en escritura | 09 §3 T7; README de `runtime`, del workspace y §6 | **Se sustituye** por el montón plano de palabras (T11) | RC-01: la paginación explica la mayor parte de V2/V1 (§2.3) |
| T7: punto de control = copia de la tabla de páginas | 09 §3 T7; README de `timeline` | **Se sustituye** por puntos diferenciales sin barrera con sombra y segmentos de deshacer (T20) | Sin barrera por escritura; delta de 64 palabras en vez de 4 096 |
| T8: puntos por masa de sentencia con raleo exponencial | 09 §3 T8 | **Se conserva y se precisa** con la programación por coste (T21) y la reproducción acelerada (T22) | Observador en pausa ≤ 2 % por construcción |
| T2: trampas diferidas en regiones puras, con regiones en la RI | 09 §3 T2; README de `ir` | En la VM, **trampas inmediatas**; la forma diferida solo dentro de superinstrucciones puras. Las regiones no se materializan en la RI (T14) | La bandera en memoria cuesta 10–50 % y no ahorra ramas en un intérprete |
| T4: «recolector preciso sin mapas de pila» | 09 §3 T4; README del workspace y de `vm` | Banco de referencias **más** mapas nocionales por punto seguro (T15) | Los registros reutilizados harían inexacto el conteo de `ENG.LIMITS`; los mapas solo se leen al recolectar |
| T3 y T4: bancos fijos de 2²⁰ (escritorio) y 2¹⁸ (móvil y Wasm) | 09 §3; 08 RC-06; README de `vm` y del workspace | **Bancos crecientes** potencia de dos (T18) | Profundidad alcanzable independiente de la plataforma; memoria proporcional al uso |
| T5: cambio de gemelo en O(1) en cualquier punto de observación | 09 §3 T5; README de `vm` | Cambio en inicios de bloque **más** puntos de retorno independientes del gemelo (T17) | Con marcos suspendidos, el contador de programa guardado pertenece a un gemelo |
| T6: combustible por bloque | 09 §3 T6 | **Se conserva** como servicio unificado con masa de evento y retrocesos de sondeo; la VM sale a su llamador (T16) | Reproducción hasta un evento; cancelación en bucles sin sentencias; capas |
| Objetos con prefijo de referencias | 09 §3 T7; README de `abi` | **Mapa de referencias por clase** (§4.1) | El prefijo no compone con la herencia |
| Texto UTF-8 con migas | 09 §3 T7; README de `runtime` | Se conserva y se amplía con **arena de solo apéndice** y concatenación por apéndice compartido (T13) | Concatenación O(1) amortizada; el texto no entra en la comparación |
| Superinstrucciones por frecuencia de bigramas | 09 §3 T9 | Se conserva con **validación fuera de muestra** (T24) | Evitar sobreajustar a AWFY |
| Responsabilidad de `runtime`: «memoria persistente determinista» | `architecture.yaml` (texto en README) | «Gestiona los valores de ejecución en un montón plano determinista» | La persistencia pasa a `timeline` |

### 6.3 Cambios en `architecture.yaml` del motor

- `pending: true` desaparece de cada capa al crear su `Cargo.toml` y su primer archivo fuente, en el bloque
  que la implementa; ninguna capa vacía.
- Sin dependencias externas nuevas en `runtime`, `library`, `vm` ni `timeline` (la matemática de T23 se
  escribe en el crate; si D-R5-08 elige la alternativa, la dependencia se declara y se audita).
- Una capa de herramienta nueva, `pseudolearn_bench_worker` (`tooling: true`), que ejecuta cargas en proceso
  para la medición de `PERF.VM.*` (D-R5-12). No forma parte del producto.
- `generated_sources` ya incluye `pseudolearn_bytecode/generated` y `pseudolearn_vm/generated`; se añade
  `pseudolearn_ir/generated` (catálogo de la RI).
- `deterministic_output_crates` añade `pseudolearn_ir`, `pseudolearn_lowering`, `pseudolearn_runtime` y
  `pseudolearn_library`.

### 6.4 Huecos de especificación que R5 debe cerrar antes del código correspondiente

Cada uno es un cambio clasificado (`SPEC-CHANGE-CLASSIFIED`) con `see diff` e `see impact`, casos derivados de
la regla y, cuando afecta a `reference`, su exención o hallazgo. Ninguno añade construcciones.

| Hueco | Contrato | Por qué importa | Propuesta |
|---|---|---|---|
| Precisión de las funciones trascendentes y de la potencia real | `LIB.CORE.MATH#R1`, `LANG.OPS.POWER#R1`, `LANG.TYPES.REAL#R1` | El formato imprime todos los dígitos significativos; la `libm` de cada plataforma difiere en el último bit | «El resultado es el real binario64 más cercano al valor exacto, con empates al par» (D-R5-08) |
| Cancelación y guarda de tiempo en bucles sin sentencias | `ENG.EXEC.MODEL#R3`, `ENG.LIMITS#R4` | `Mientras Verdadero Hacer FinMientras` no tiene entradas a sentencia: hoy no se puede cancelar según el contrato | La cancelación surte efecto en la siguiente entrada a sentencia **o evaluación de condición o prueba de bucle**, sin efectos parciales (D-R5-09) |
| Raíces del conteo de celdas | `ENG.LIMITS#D1` | «Alcanzables desde los marcos activos» no dice si cuentan los temporales ya evaluados ni cómo cuenta una cadena compartida | Cuentan las variables en ámbito de cada marco activo (parámetros y receptor incluidos) y los valores intermedios ya evaluados de la sentencia en curso; cada cadena creada en ejecución cuenta una vez mientras sea alcanzable (D-R5-06) |
| Dígitos del formato de reales | `LANG.IO.VALUE-FORMAT#R1` | «Notación posicional con al menos un decimal» no fija cuántos dígitos | B1.4 comprueba si los casos ya lo fijan; si no, se aclara «los dígitos mínimos que identifican el valor binario64» (D-R5-10) |
| Límites del análisis (deuda de D-R4-05) | Corpus `LANG.SYNTAX.*`, `ENG.LIMITS`, `API.ERRORS` | Sin contrato, la anidación extrema solo está protegida por lo que el código haga, y `ENG.LIMITS` describe ejecución, no análisis | Profundidad de anidación mínima admitida por el análisis, diagnóstico propio con tramo y garantía de que nunca agota la pila del anfitrión (D-R5-19) |
| Latencia de retroceso | `PERF.VM.STEP-LATENCY` | `seek` existe como capacidad sin métrica; la línea temporal no tendría criterio | Medición provisional M3: p95 de posicionarse en un evento al azar de AWFY-core y consultar su estado, ≤ 50 ms en Apple M2 (D-R5-15) |
| Ejecutor de `ENG.EXEC.EFFECT-ORDER#P1` | Corpus `ENG` | La propiedad compara comprobación inmediata y diferida; sin superinstrucciones puras no habría código diferido | T14 aporta el código diferido real; el oráculo (aritmética de 128 bits) vive en `see_oracles` |

### 6.5 Conflictos con documentos de investigación

[16](../16-experimentos-y-benchmarks.md) define E-06 sobre el núcleo Dart con criterio «coste de observación
≤ 1,3× en recursión profunda». Es investigación con fecha y no se reescribe (08 §3.4). Este plan **reinterpreta**
E-06 para el motor Rust en §7.2, con su criterio original más los del corpus. No hay contradicción normativa,
pero se declara para que nadie lea dos criterios distintos sin saber cuál manda: manda el de §7.2.

---

## 7. Experimentos de la fase

Todos siguen `PERF.PROTOCOL` (diez procesos, treinta iteraciones, procedencia previa a la compilación, IC 95 %
por *bootstrap*, puntos de cambio sin descartar muestras, publicación de todo resultado) salvo que se diga lo
contrario. Ningún criterio se relaja después de medir.

### 7.1 E-02R · Revalidación de la representación (B1, antes de cualquier código del motor)

**Pregunta.** ¿Cierra Remanso RC-01 con el protocolo normativo?

**Variantes en `ceiling`** (los núcleos conservan su salida exacta y sus tests contra el corpus):

| Variante | Qué es |
|---|---|
| V0, V1, V2, V3 | Las de E-02, sin cambios, para enlazar con la evidencia publicada |
| V1F | V1 con la pila de marcos en bancos de V2 |
| V2R | Montón plano, asignación por avance en bloques puestos a cero, trampas inmediatas, combustible por bloque |
| V2R-sin-índice | V2R sin la comprobación de índice del lenguaje: insegura a propósito, solo acota la ganancia máxima de la hipótesis C |
| V3R | V2R con puntos de control diferenciales sin barrera, programados por combustible (T20–T21) |
| V3R-tarjetas | V2R con marcado de tarjetas y puntos por tarjetas sucias: peldaño alternativo de RR-02 |

**Criterios cerrados:** los de §2.5. Además Storage ≤ 1,30 en V2R/V1F.

**Protocolo de iteración dentro de B1.** Si un criterio falla: (1) se publica el resultado; (2) se aplica el
siguiente peldaño de la escalera RR-01 o RR-02 (§10) como **variante nueva** con su propio identificador, sin
sustituir datos; (3) se repite la medición completa. Agotar la escalera es `CONFLICT-REPORT`, porque cambia la
premisa de diseño aprobada. Ningún código del motor se escribe antes de cerrar E-02R.

**Evidencia.** `packages/pseudolearn_benchmarks/results/e02r/` y `packages/pseudolearn_spec/results/r5-e02r.json`;
RC-01 pasa a «resuelto» en 08 §2 con la referencia a esa evidencia.

### 7.2 E-06 · Observación incremental y línea temporal (B6)

**Pregunta.** ¿Cumple la VM real los costes de observar, grabar y volver atrás?

| Métrica | Carga | Criterio |
|---|---|---|
| Observador en pausa (`PERF.VM.THROUGHPUT#M4`): gemelo rápido con puntos de control frente a sin línea temporal | AWFY-core | ≤ 2 % en media geométrica |
| Coste de los deltas de estado frente a eventos solos (reinterpretación del E-06 original) | Recursión profunda de 1 000, 10 000 y 100 000 marcos, arreglos y grafo de objetos | ≤ 1,3× |
| Independencia de la profundidad | Igual que la anterior | El coste por evento con deltas no crece con la profundidad (pendiente de la regresión no distinta de cero al 95 %) |
| Coste de un punto con pila profunda | 100 000 marcos | O(región cambiada), no O(pila): la marca de agua se verifica con el número de ranuras copiadas |
| Latencia de paso observado más consulta (`PERF.VM.STEP-LATENCY#M2`) | AWFY-core en cada evento muestreado | p95 ≤ 0,1 ms en Apple M2 |
| Latencia de retroceso (M3 nueva, D-R5-15) | Eventos al azar de AWFY-core y montón de 2²² celdas | p95 ≤ 50 ms en Apple M2 |
| Memoria retenida | Ejecuciones de 10⁹ sentencias | Dentro del presupuesto configurado; horizonte declarado y exacto |
| RSS con grabación | AWFY-core y montón grande | Sombra + segmentos ≤ 2,5× el montón vivo |

**Escaleras:** RR-02 (sobrecoste), RR-03 (latencia), RR-04 (memoria).

### 7.3 E-12 · Gestión de memoria (B4.0, antes del recolector definitivo)

**Pregunta.** ¿Qué asignador y recolector rinde mejor con la semántica de PseudoLearn **y** con los puntos de
control diferenciales?

**Variantes** como prototipos en `ceiling`, sobre el montón plano y las mismas cargas AWFY-core más dos
cargas de asignación intensiva (árbol de Storage profundo y lista que se recorta y crece):

1. marcado y barrido sin movimiento con listas por clase de tamaño y avance en bloques;
2. regiones tipo Immix con líneas y avance en huecos, **sin evacuación**;
3. conteo de referencias con recolección de ciclos por borrado de prueba (el que pide la definición original
   de E-12), medido para cerrar la pregunta con datos aunque se espere descartarlo por su coste por escritura.

**Métricas.** Tiempo total, tiempo de pausa máximo y p95 en unidades deterministas (palabras marcadas y
barridas) y en tiempo, memoria pico, **bloques que cambian por punto de control** (el coste que una
recolección impone a T20) y conformidad de Q1.

**Criterio de elección.** La variante con menor media geométrica de tiempo total cuya pausa p95 no supere en
más de 2× la de la variante 1 y cuyo cambio de bloques por punto no supere en más de 1,5× al de la variante 1.
Empate técnico: la más simple. La perdedora no entra al motor (`SCOPE-YAGNI`); su resultado se publica.

### 7.4 E-16 · Fortaleza de los casos (B7.8)

**Pregunta.** ¿Matan los casos del corpus y los tests a los mutantes del motor de ejecución?

**Método.** Mutación de `lowering`, `bytecode`, `runtime`, `library`, `vm` y `timeline` con la herramienta que
fije D-R5-13; ejecución de `cargo test` y de la conformidad completa por mutante. Mutación del corpus: alterar
valores esperados y reglas, y comprobar que `see conform` lo detecta.

**Criterio.** Puntuación de mutación ≥ 85 % por crate. **Cada** superviviente se clasifica como equivalente
(con el argumento) o como hueco; cada hueco se cierra **en la fase** con un caso derivado de la regla o un test
espejo, y se repite la medición. Ninguna regla de `IR`, `ENG`, `MEM` o `LIB` queda con alteraciones no
detectadas.

### 7.5 E-17 · Paridad entre objetivos (B7.8)

**Pregunta.** ¿Producen exactamente lo mismo el motor nativo y el motor compilado a Wasm?

**Método.** El adaptador de conformidad y el trabajador de medición se compilan también para
`wasm32-wasip1` (objetivo añadido a la cadena fijada, D-R5-14) y se ejecutan con el soporte WASI de Node, que ya
forma parte de las cadenas del monorepo. Se comparan nativo (macOS arm64) y Wasm en:

- todo el corpus `execute` y `trace`;
- 10⁴ programas bien tipados generados con semilla (al estilo de Csmith) y su variante EMI (eliminar código no
  ejecutado para unas entradas y comparar);
- una malla de 10⁶ argumentos por función matemática, bit a bit;
- formato de reales en los bordes del binario64.

**Criterio.** **Cero** diferencias en salida, diagnósticos, terminación, traza y estado consultado. Cualquier
diferencia se diagnostica y se corrige en la fase. Se publica también el tamaño del módulo Wasm comprimido con
brotli como señal temprana de `PERF.ARTIFACT.SIZE`; si ya supera 600 KiB sin puente, la escalera RR-12 se
aplica en R5.

### 7.6 Mediciones de `PERF.VM.*` (B7.7)

- `PERF.VM.THROUGHPUT` M1–M3 sobre la VM no observada frente a `PERF.BASELINE.REFERENCE` (`macos-r3-awfy`), en
  el mismo Apple M2, con el arnés de D-R5-12.
- M4 se toma de E-06.
- `PERF.VM.STEP-LATENCY` M2 y M3 se toman de E-06. M1 (dispositivo modesto) necesita el puente y pertenece a
  R8 por definición, porque exige el puente; R5 publica M2 y el coste de los lotes binarios de eventos como
  señal temprana de E-NR2.

**Escalera RR-01** si M1 o M2 fallan.

---
## 8. Plan de ejecución de R5 en una sola iteración

Cada paso dice qué hacer, dónde y cuándo está hecho. El orden respeta el de [07](07-fases.md) R5 (RI y
verificador → traducción procedural → VM no observada → runtime → biblioteca → arreglos → subprogramas →
objetos y recolector → modo observado → estado incremental → `ENG.LIMITS`), precedido por el bloque **BF**,
que resuelve la deuda heredada de R4 (D-R5-01), y con dos adelantos justificados: E-02R antes de todo código del
motor de ejecución (RC-01) y el esqueleto del servicio de combustible con la VM, porque los límites exactos lo
reutilizan. BF y B1.1–B1.3 no comparten archivos: pueden avanzar a la vez, pero B2 no empieza sin ambos.

Regla común a todos los bloques: antes de crear un archivo se responden capa, imports y dueño
(skill `layer-boundaries`); cada pieza tiene camino feliz, infeliz y casos límite (texto vacío, programa vacío,
colecciones de tamaño cero, recursión profunda, bordes de 64 bits, identificadores de un carácter); los
casos del corpus no se duplican como tests de Rust; cada decisión entra en el `README.md` dueño **antes** del
código; `cargo xtask verify` en verde al terminar cada paso que toca código.

### B0 · Preparación y puerta de entrada

- [x] **B0.1 Estado del repositorio.** `git branch --show-current` es `feature/agregar-ruta-de-especificacion`;
  árbol limpio; HEAD local igual al remoto (`git ls-remote`).
- [x] **B0.2 Decisiones y riesgos.** En [08](08-decisiones-riesgos-y-cambios-de-reglas.md) se añade §1.6
  «Decisiones de R5» con D-R5-01 a D-R5-19, la fecha y la fuente (el mensaje de autorización). Los riesgos
  RR-01 a RR-15 de §10 entran en 08 §2. RC-01 se marca «en revisión por E-02R».
- [x] **B0.3 Deuda heredada de R4.** Reejecutar `see conform --subject engine --operation analyze` y
  `--subject cli --operation cli` y registrar en `results/r5-frontend-debt.json` cada observación en `incumple`
  con su causa (tabla de §6.1), más E-08, textos y lexemas copiados a mano, vistas sin generar, tests no espejo y
  contrato de límites de análisis ausente. Es la lista de entrada del bloque BF; 07 R4 no se modifica.
- [x] **B0.4 Línea de partida.** `cargo xtask verify` en motor, CLI, `pseudolearn_spec`,
  `pseudolearn_rust_checks` y `ceiling`; `dart test` en núcleo y arnés; `see conform --subject reference`.
  Cantidades de tests y observaciones en `results/r5-baseline.json`: son la referencia de regresiones.
- [x] **B0.5 Inventario.** Todas las reglas, casos y propiedades con operación `execute`, `trace`, `ir` o `cli`
  y sujeto `engine` o `cli`, por especificación, en `results/r5-inventory.json`, con la correspondencia de
  cada criterio de 07 R5 con su verificador. Un criterio sin ejecutor bloquea su aceptación.
- [x] **B0.6 Inicio de autoría.** Marca de tiempo en `results/r5-authoring-start.json`.

### BF · Deuda heredada de R4: front-end conforme y HIR tipado

Bloque de R5 por decisión D-R5-01. Su evidencia lleva prefijo `r5-frontend-`. Ninguna casilla de R4 en 07 se
modifica. Al terminar, ninguna entrada de `r5-frontend-debt.json` queda abierta.

- [x] **BF.1 Contratos primero.** Contrato de límites de análisis de §6.4 (D-R5-19): regla, diagnóstico en
  `DIAG.CATALOG` con ficha bilingüe (skill `diagnostics-authoring`), casos de borde (exactamente en el límite,
  uno por encima, anidación de paréntesis, unarios, potencia y bloques) en los dos perfiles; clasificación,
  impacto, `lock`, `export` y `validate`. Revisar que ningún caso `analyze` en `incumple` estuviera mal derivado
  de su regla; si lo estaba, corregir el caso (nunca para acomodar al sujeto) y registrarlo.
- [x] **BF.2 Vistas generadas.** `build.rs` de `syntax` genera clases de nodo y vistas tipadas desde la
  exportación de `LANG.SYNTAX.GRAMMAR` con un lector validado del subconjunto EBNF normativo. Tests: producción o
  referencia no resuelta rechazada; dos generaciones iguales; exportación desactualizada detectada. Se retira
  el `NodeKind` escrito a mano.
- [x] **BF.3 Léxico y recuperación.** Diagnósticos léxicos y sintácticos ausentes de §6.1; fragmentos
  inválidos sin cascada; recuperación por contextos con progreso garantizado; límite de anidación. Casos de
  `LANG.LEXICAL.*`, `LANG.SYNTAX.*` y `DIAG.CLASSES` en `cumple`; `TOOL.SERVICE.LOSSLESS-TREE` P1–P2 sigue en
  `cumple`.
- [x] **BF.4 Semántica reescrita.** Las seis pasadas y el HIR de §4.10, con tests espejo por módulo (registro,
  jerarquía, ámbitos, tipos, flujo, emisión), camino infeliz por cada diagnóstico y casos límite
  (identificadores de un carácter, programa vacío, clases sin miembros, herencia profunda, ciclos). Se retira
  `Type::from_name`. Test por construcción de la gramática: todo programa válido produce HIR y todo nodo HIR
  tiene tipo y tramo.
  - [x] Reescritura por pasadas, retirada de `Type::from_name` y HIR con índices tipados.
  - [x] Auditoría de tipos, tramos y argumentos de diagnóstico en el corpus y 400 combinaciones generadas.
  - [x] Repetición de inferencia sin perder vínculos ni diagnósticos; finalización de lecturas sin valor.
  - [x] Cobertura exigida por construcción y por diagnóstico completada y verificada.
- [x] **BF.5 API y CLI.** `API.ANALYZE` sobre el nuevo HIR y esquema; mensajes de la CLI generados desde
  `TOOL.CLI.MESSAGES` (se retiran los literales de `messages.rs`); casos `cli` de `comprobar`, `preferencias`,
  convenciones y mensajes en `cumple` en los dos idiomas de interfaz.
  - [x] API de análisis sobre el esquema y mensajes de CLI generados desde el corpus.
  - [x] Verificadores completos de motor y CLI tras corregir los argumentos tipados de diagnósticos.
  - [x] Conformidad de mensajes y órdenes de análisis cerrada (35 casos `cli` de análisis en `cumple`; los 14 casos que invocan `run` e `ir` corresponden a B2 y B7).
- [x] **BF.6 Rendimiento y E-08.** Perfil del análisis completo; optimización guiada por el perfil; E-08 repetido
  con `PERF.PROTOCOL` completo (diez procesos, treinta iteraciones, datos crudos, intervalos, procedencia) en
  `packages/pseudolearn_benchmarks/results/e08r/` y `results/r5-frontend-e08.json`. Criterios: ≥ 10⁶ líneas/s
  (`PERF.FRONTEND.THROUGHPUT`) y p95 ≤ 16 ms en 10 000 líneas. Escalera RR-15 si falla.
- [x] **BF.7 Robustez.** Texto vacío, solo trivia, binario inválido, Unicode NFD, texto aleatorio y anidación
  extrema en procesos aislados: cero pánicos, abortos o bloqueos; `DIAG.ENGINE.INTERNAL-FAULT` nunca en el corpus.
- [x] **BF.8 Puerta del bloque.** `see conform --subject engine --operation analyze`: **cero** `incumple` (524 de 524
  observaciones en `cumple`); casos `cli` de las órdenes de análisis en `cumple`; README de `syntax`, `semantic`,
  `api` y CLI al día con §4.10; `cargo xtask verify` en verde en motor y CLI.
  Puerta del bloque BF cerrada con éxito.

### B1 · RC-01, contratos y herramientas de verificación

- [x] **B1.1 E-02R en `ceiling`.** Variantes de §7.1, con su `README.md` actualizado (problema, elección y
  alternativas) y tests de salida exacta contra el corpus por variante. Fixture negativo: una variante que
  produce una salida distinta es rechazada por el recolector.
- [x] **B1.2 Medición.** `cargo run --release -p ceiling_runner -- collect` con el protocolo; datos en
  `results/e02r/` con manifiesto y procedencia previa a la compilación.
- [x] **B1.3 Decisión de RC-01.** Informe con cocientes por núcleo y familia e intervalos; aplicación de los
  criterios de §2.5 y, si hace falta, del protocolo de iteración de §7.1. RC-01 queda **resuelto** en 08 con la
  evidencia, o la fase se para.
- [x] **B1.4 Contratos.** Cambios clasificados de §6.4 aprobados en D-R5-06, D-R5-08, D-R5-09, D-R5-10 y
  D-R5-15: `see new`/edición, casos derivados de la regla en `es` y `en` y en los dos rigores, `see diff`,
  `see impact`, `see lock`, `see export` y `see validate` en verde. Sujetos `engine` y `cli` activados por
  elemento en los contratos de ejecución; ninguna exención de `reference` se hereda.
- [x] **B1.5 Extensiones de SEE** (en `packages/pseudolearn_spec`, cada una con esquema, modelo, formato,
  capa, tests espejo, *fixture* negativo con su identificador y README):
  - [x] Selección por operación `execute`, `trace`, `ir` y `cli` para los sujetos `engine` y `cli`;
  - [x] Negociación de `observe`, `seek` y `gc_stress` en `see-protocol/1` (ampliación compatible);
  - [x] Ejecutores de las propiedades con semilla, número de muestras, contraejemplo y repetición:
    `ENG.EXEC.MODEL#P1`, `ENG.EXEC.EFFECT-ORDER#P1`, `ENG.INPUT#P1`, `ENG.TRACE.STEP#P1–P2`,
    `ENG.STATE.SNAPSHOT#P1`, `ENG.STATE.INCREMENTAL#P1–P3`, `MEM.IDENTITY#P1`,
    `MEM.MANAGED.UNOBSERVABLE#P1`, `IR.LOWERING#P1–P3`, `IR.OBSERVATION-POINTS#P1`, `API.EXECUTE#P1`,
    `API.STATE.QUERY#P1`, `API.WIRE-FORMAT#P1`, `API.VERSIONING#P1–P2`, `RT.HOST.INTERFACE#P1`,
    `TOOL.CLI.IR#P1` (soporte completo en `see_conformance`, con `property_steps` para `StepDepth`);
  - [x] **Generador de programas bien tipados** con semilla (D-R5-11), por gramática de un subconjunto con
    arreglos, objetos, ciclos de referencias, llamadas, paso por referencia, texto y entrada; produce el
    programa en los dos vocabularios desde la exportación;
  - [x] Oráculos independientes en `see_oracles`: aritmética de 128 bits para la primera trampa, aritmética
    racional para el redondeo correcto y conteo nocional de celdas para programas generados.
    - [x] Oráculo entero i128 con primera trampa y origen; contador de celdas con alias y ciclos.
    - [x] Oráculo racional y redondeo por cociente/resto, con pruebas de empates y subnormales.
    - [x] Validación matemática base completa; el contraste masivo de biblioteca (10⁶ argumentos) se ejecutó en B3.4.
  - [x] Registro de treinta propiedades, esquema, modelos, validación de integridad y negativos.
  - [x] Armazón de semillas, contraejemplos, reproducción y selección desde la CLI de SEE.
  - [x] Algoritmos y transporte de propiedades validados con suite de pruebas.
- [x] **B1.6 Documentación antes del código.** README del workspace (principios 8–10, flujo de datos,
  decisiones de §6.2 con alternativas descartadas y genealogía de §5.4) y README de `abi`, `ir`, `lowering`,
  `bytecode`, `runtime`, `library`, `vm`, `timeline`, `api` y CLI con el contenido de §12; `architecture.yaml`
  con los cambios de §6.3 y la capa de herramienta del trabajador de medición. `rust-checks layers` en verde.
- [x] **B1.7 Verificación.** `cargo xtask verify` en verde en `pseudolearn_spec`, `ceiling` y
  `pseudolearn_rust_checks`; puerta `DOC-NO-TRANSIENT-REFS` en verde.
  Bloque B1 cerrado con éxito.

### B2 · `abi`, RI y traducción procedural

- [x] **B2.1 `abi`.** Constantes y tipos de §4.1 con tests de tamaños y desplazamientos.
- [x] **B2.2 `ir`: modelo y catálogo.** `build.rs` genera `Operation` y sus tablas desde la exportación;
  modelo en columnas; tabla de orígenes. Test: añadir una instrucción ficticia a una exportación de prueba
  cambia la salida generada; una exportación desactualizada hace fallar la puerta.
- [x] **B2.3 `ir`: formato textual.** Lector y escritor canónicos; casos `ir` de reimpresión; propiedad de ida y
  vuelta sobre textos generados.
- [x] **B2.4 `ir`: verificador.** R1–R9 con primera violación; un *fixture* negativo por regla con su
  identificador; mutación aleatoria de RI sin pánicos.
- [x] **B2.5 `lowering` procedural** (sobre el HIR de BF). Expresiones, asignación, `Si`, `Mientras`, `Repetir`, `Para`, `Segun`,
  `Escribir`, `Leer`, asignación definida, masas, orígenes y retrocesos de sondeo (§4.3).
  `IR.LOWERING#P1` y `#P3` sobre todo el corpus procedural.
- [x] **B2.6 `pseudo ri`/`ir`.** Orden en la CLI con mensajes de `TOOL.CLI.MESSAGES`; casos `cli` de
  `TOOL.CLI.IR` en los dos idiomas de interfaz y `TOOL.CLI.IR#P1`.
  Bloque B2 cerrado con éxito: 19/19 observaciones en `see conform --subject engine --operation ir` en verde (0 divergencias); casos `TOOL.CLI.IR` en verde en CLI; `cargo xtask verify` en verde tanto en `pseudolearn_engine` como en `pseudolearn_cli`.

### B3 · Bytecode rápido, VM no observada y trazadora de rendimiento

- [x] **B3.1 `bytecode`: gemelo rápido.** Ranuras de origen y temporales, salida de SSA, descriptores de bloque,
  cargos fusionados en saltos, puntos de retorno, depósitos de constantes, acolchado y verificador con
  *fixtures* negativos (operando fuera de ventana, salto fuera de función, clase equivocada, punto de retorno
  ausente).
- [x] **B3.2 `vm`: núcleo.** Despacho generado en `build.rs`; bancos crecientes; aritmética entera, real, lógica
  y de caracteres con trampas inmediatas; control; salida de servicio por combustible.
- [x] **B3.3 Trazadora de rendimiento interna.** Herramienta de capa `tooling`; compila cada carga antes del
  intervalo medido y llama directamente a la VM. No reutiliza `pseudolearn_bench_worker` ni adelanta
  `API.EXECUTE`. Un único conjunto emparejado de Mandelbrot, bucle entero y recursión entera usa los mismos
  programas e inputs en VM y `reference`. Aplica `PERF.PROTOCOL`: diez procesos, treinta iteraciones por
  proceso, estado nuevo, resultado validado, sin I/O crudo dentro del intervalo y procedencia capturada antes
  de compilar. Conserva crudos en
  `packages/pseudolearn_benchmarks/results/r5-vm-tracer/` y resumen en
  `packages/pseudolearn_spec/results/r5-vm-tracer.json`. Criterio: media geométrica de aceleración proyectada
  ≥ 30×. Si falla, aplica RR-01 en orden y repite la medición antes de continuar.
- [x] **B3.4 Runtime aritmético y biblioteca matemática.** Aritmética comprobada (incluido `int.mod` del mínimo
  entre −1), conversiones, `trunc`/`redon`, potencia entera y real, y las seis funciones con redondeo correcto
  (T23) validadas contra el oráculo en 10⁶ argumentos por función. Casos `execute` de `LANG.OPS.*`,
  `LANG.TYPES.INTEGER`, `LANG.TYPES.REAL` y `LIB.CORE.MATH`/`ROUNDING` en `cumple`: **diferido a B7.3 por
  decisión del 2026-10-15** (requiere el adaptador `API.EXECUTE` de B7.1 y el formato de reales de B4.2;
  B3.3 prohíbe adelantarlos). B3.4 se cierra con tests directos de VM y biblioteca y el contraste masivo.

#### Cierre de B3 · 2026-10-15

- **Causa raíz del bloqueo anterior.** La VM no tenía forma de despacho: interpretaba el modelo estructural
  del bytecode (búsqueda de función y de superinstrucción en un `BTreeMap` por paso, operandos en vectores
  de enums, predicados comparados como cadenas, descriptor de bloque buscado y clonado en cada salto,
  tipo consultado en cada escritura y cuatro vectores asignados por llamada). Los peldaños 1, 2 y 4 de RR-01
  se habían aplicado sobre esa representación; por eso ni PGO pasó de 16,6×. La escalera no estaba agotada
  y no hizo falta una técnica fuera de RR-01 ni revisar el criterio.
- **B3.1.** Cada variante se acolcha con `unreachable` hasta potencia de dos y registra `used_length`; el
  verificador rechaza longitud no potencia de dos, cola distinta de `unreachable`, longitud usada vacía o
  excesiva y bloques en la cola (`VerificationRule::Padding`, siete tests).
- **B3.2.** `load` construye una vez por carga la forma de despacho: `enum Op` con registros e inmediatos
  en la operación, predicados resueltos, formas registro/inmediato, comparación-salto fusionada según el
  perfil, aristas con masa y sondeo, copias de parámetros secuenciadas, tabla de continuaciones y bits de
  definición solo en parámetros enteros consultados. El `enum`, la selección y el `match` del paso se
  generan con `pseudolearn_vm_dispatch` desde `crates/pseudolearn_vm/data/dispatch_forms.json` y la
  exportación de `IR.INSTRUCTIONS`, que además exige forma para toda instrucción escalar. Pilas escalar, de
  bits, de referencias y de control únicas, crecientes por duplicación; las familias de B4 y B5 cargan como
  `Unsupported`. Se corrigió la inferencia de tipos de la RI para `math.*`, `char.code` y `char.from_code`,
  y la raíz negativa atrapa con `nonFiniteRealResult` como exige `LIB.CORE.MATH#R1`.
- **B3.3.** Sin PGO (D-R5-16): media geométrica **76,7×** (Mandelbrot 85,9×, bucle entero 104,4×,
  Fibonacci 50,4×), crudos en `results/r5-vm-tracer/rr01-dispatch-form/` y en la raíz de esa carpeta. Las
  carpetas `rr01-step-*` y `rr01-pgo-profile/` quedan como historial.
- **B3.4.** `ln`, `exp`, `sen`, `cos`, `atan` y potencia real con redondeo correcto en Rust seguro, sin
  dependencias: aritmética de intervalos de coma fija con redondeo hacia fuera, reducción exacta de
  argumento (también para `sen(f64::MAX)`), escalada de Ziv de 128 a 16 384 bits y detección previa de
  potencias exactas y puntos medios. El contraste usa `see math-arguments`, `pseudolearn_math_probe` y
  `see math-check`; resumen en `packages/pseudolearn_spec/results/r5-math-contrast.json`. El oráculo se
  amplió con potencias diádicas exactas porque no terminaba en puntos medios. Esto adelanta el contraste
  masivo que B1.5 programaba para el cierre de B7.

### B4 · Runtime, biblioteca, arreglos, subprogramas, objetos y recolector

Autorizado en una sola iteración. Por decisión de la persona responsable, B4 se acredita con pruebas
directas completas y oráculos independientes. La conformidad integrada `execute` y las propiedades
completas de observación se verifican en B7.3, después de `API.EXECUTE`; no se anticipa su estado `cumple`.

- [x] **B4.0 E-12.** Prototipos y medición de §7.3 realizados: 10.800 muestras, elección
  `SizeClasses` registrada en el README de `runtime` y `packages/pseudolearn_spec/results/r5-e12.json`.
  La puerta global de B4 quedó cerrada con la aceptación de B4.3–B4.6.
- [x] **B4.1 Montón y arreglos.** Montón plano, asignación por avance en bloques, cabeceras, ordinales, arreglos
  de una y varias dimensiones con comprobación por dimensión, cota densa y mapas de definición; tamaño cero y
  negativo. Casos `LANG.ARRAY.*`, `LANG.TYPES.ARRAY` y `ENG.LIMITS#D1`; mapas exactos de raíces y de definición
  validados en ambos gemelos, pruebas directas de montón/arreglos, corpus y `cargo xtask verify` en verde.
- [x] **B4.2 Texto y conversiones.** Arena, cabeceras, apéndice compartido, migas, comparación por puntos de
  código, `Longitud`, `CaracterEn`, `CodigoDe`, `CaracterDesde`, `ATexto`, `AEntero`, `AReal` y formato de
  valores. Los casos exportados de texto y conversión pasan en las tres políticas de recolección. La VM
  rechaza reales no finitos con `nonFiniteRealResult` antes de llamar al formateador; `format_value` conserva
  su retorno `String`. Se conserva `compact_text` como operación explícita que devuelve `TextCompaction`;
  la recolección automática descarta ese mapa hasta que exista un consumidor. Suites y verificadores del
  motor y SEE pasan; evidencia en `packages/pseudolearn_spec/results/r5-b4-verification.json`.
- [x] **B4.3 Subprogramas.** Llamadas con ventanas solapadas, retorno, falta de retorno, profundidad exacta,
  paso por referencia con celdas (alias a la misma casilla, índice fijado una vez y comprobado antes del
  cuerpo), marca de agua en escrituras por celda. Los negativos cubren índices con efectos antes de entrar
  al cuerpo; las regresiones incluyen recursión mutua y reutilización de ventanas. Casos `LANG.SUBPROGRAM.*`.
- [x] **B4.4 Objetos.** Disposición por herencia, mapas de referencias por clase, máscaras de enteros y clases
  densas, constructores, `Este`, `Super`, llamadas virtuales y desvirtualizadas, `Copiar`, igualdad por
  identidad. El verificador rechaza jerarquías, campos, mapas y destinos de método inválidos, y acepta
  subtipos en bloques y celdas tipadas con una superclase. Casos `LANG.CLASS.*` y `LIB.CORE.COPY`.
- [x] **B4.5 Recolector.** Variante elegida en E-12, mapas nocionales, marcado iterativo, disparo determinista,
  límite de celdas exacto con el valor nuevo, compactación de la arena de texto y modo de recolección forzada.
  Los casos y grafos generados comparan conteos exactos con el oráculo independiente bajo recolección
  automática, forzada y desactivada; cubren arreglos raíz, límites de ámbito, valores vivos, temporales
  muertos y reutilización de asas con identidad nueva. Casos `MEM.*` y de celdas de `ENG.LIMITS`.
- [x] **B4.6 Azar y anfitrión.** xoshiro256** con SplitMix64, semilla por omisión 42 y estado explícito;
  los casos exportados de `RT.HOST.INTERFACE` y `LIB.CORE.RANDOM` pasan en las tres políticas.

#### Cierre de B4 · 2026-10-16

**B4.0–B4.6 y su puerta global están cerradas. R5 permanece abierta y B5 no se inicia.** La conformidad
integrada `execute` y las propiedades completas de observación siguen en B7.3; no se adelantó su estado
ni se añadió `API.EXECUTE`.

- [x] E-12 medido y elegido; montón/arreglos, texto/conversiones, llamadas/celdas/objetos,
  recolección/azar y soporte estático hasta bytecode implementados en el árbol local.
- [x] Pasan 296 configuraciones del corpus × tres políticas (888 ejecuciones) y cien grafos independientes
  × dos perfiles × dos rigores × tres políticas (1.200 ejecuciones), más ocho regresiones API.
- [x] Se cerraron raíces exactas, negativos de metadatos y tipos, subtipo nominal, llamadas y objetos,
  identidad de asas y oráculos generados; los README propietarios reflejan las decisiones.
- [x] `cargo xtask verify` pasa en engine, spec y ceiling; SEE valida 140 especificaciones, lock y
  exportación están vigentes y la conformidad congelada ejecuta 1.180 observaciones con sus 134
  divergencias clasificadas.
- [x] La repetición B3 alcanza 63,44× frente al umbral 30× sin descartar muestras; RR-01 no se activa.
- [x] B4.3–B4.6 y la puerta global quedan aceptadas y publicadas en la rama única con HEAD remoto/local
  coincidente y checkout limpio. B5 permanece pendiente de autorización.

El cierre, sus exclusiones y la evidencia están en [13 · Relevo de B4](13-relevo-b4-remanso.md) y en
`packages/pseudolearn_spec/results/r5-b4-verification.json`. `API.EXECUTE`, `execute` integrado y
observación completa permanecen en B7.3; no iniciar B5 sin autorización nueva.

### B5 · Gemelo sondeado, eventos, combustible y límites

- [x] **B5.1 Gemelo sondeado y eventos.** Generación desde la misma función parametrizada; lotes en columnas;
  búfer de cambios. Casos `trace` de `ENG.TRACE.EVENTS`; `ENG.TRACE.STEP#P1–P2`.
- [x] **B5.2 Cambio de gemelo.** En inicios de bloque y puntos de retorno. Diferencial entre gemelos en todo el
  corpus y propiedad de cambio arbitrario con semilla; `IR.OBSERVATION-POINTS#P1`.
- [x] **B5.3 Servicio de combustible y límites.** Presupuesto de sentencias exacto con caída al sondeado,
  cancelación con `AtomicBool`, guarda de tiempo, pausa, retrocesos de sondeo. Todos los casos de
  `ENG.LIMITS` y `ENG.EXEC.MODEL`, incluidos borde exacto, uno por encima, recursión mutua y bucles sin
  sentencias; ningún límite agota la pila del anfitrión.
- [x] **B5.4 Entrada.** Suspensión, lotes, valores sobrantes, entrada inválida repetida sin modificar el destino,
  cinta. Casos `ENG.INPUT` y `LANG.IO.INPUT`; `ENG.INPUT#P1`.
- [x] **B5.5 Superinstrucciones.** Perfil sobre el corpus y AWFY-core; selección; validación con las cargas del
  anexo de E-01; tabla de datos con procedencia; expresiones puras fusionadas con reejecución precisa y
  `ENG.EXEC.EFFECT-ORDER#P1` en `cumple`. Si la trazadora o E-02R activaron la hipótesis C, superinstrucción de
  `Para` con guarda y caída exacta, con su propiedad de primera trampa.

#### Cierre de B5 · 2026-10-16

**B5.1–B5.5 cerrados.** Gemelos emparejados (rápido y sondeado) derivados de la misma función genérica,
formato columnar PLEV con lotes `TraceBatch` y búfer de deltas, alternancia de gemelos en O(1) en puntos de
observación, combustible por sentencias con caída al gemelo sondeado, límites de tiempo, memoria y pila de
llamadas, pausa y cancelación cooperativa con `AtomicBool`, entrada interactiva suspendible con `WaitingInput` y
cinta por lotes, y superinstrucciones puras fusionadas en bytecode y VM con orden estricto de efectos. Pruebas
unitarias, de integración y `cargo xtask verify` en verde. B6 permanece pendiente de autorización.


### B6 · Línea temporal y estado

- [x] **B6.1 Vistas de estado.** Marcos, variables con `sin_valor`, alias, receptor, objetos por identidad e
  intervalos de arreglo. Casos de `ENG.STATE.SNAPSHOT` y `#P1`.
- [x] **B6.2 Deltas.** Cambios por evento desde el búfer del gemelo sondeado; `ENG.STATE.INCREMENTAL#P1–P2`.
- [x] **B6.3 Puntos de control.** Sombra, segmentos de deshacer, longitud de la arena, marca de agua, programación
  por coste, raleo con fusión de segmentos, presupuesto y horizonte. Tests: restaurar cualquier punto
  reproduce bit a bit el estado guardado; fusionar segmentos conserva la reconstrucción.
- [x] **B6.4 Retroceso.** VM de reproducción, avance rápido por contador de eventos, cambio al sondeado,
  densificación. `ENG.STATE.INCREMENTAL#P3`, `API.EXECUTE#P1` y `API.STATE.QUERY#P1` en `cumple`.
- [x] **B6.5 E-06.** Mediciones y criterios de §7.2 con evidencia en `results/e06/` y `r5-e06.json`; escaleras
  aplicadas dentro del paso si algo falla.

#### Informe original de cierre de B6 · 2026-10-16 · rectificado durante B7

El informe original declaró B6.1–B6.5 cerrados y sus casillas superiores conservan ese registro histórico.
La revisión autorizada de B7 invalida su acreditación de restauración completa, reproducción y coste:
las consultas contenían valores de relleno, se copiaba estado completo por evento y E-06 publicaba
constantes como mediciones. Los tests y verificadores de aquel cierre no acreditan esos criterios.
La reparación y la repetición íntegra de E-06 pertenecen a B7 por decisión explícita; no se abre una
fase separada ni se utiliza el cierre original como evidencia de cumplimiento.

### B7 · API, CLI, conformidad, rendimiento y robustez

**Rectificación de evidencia de B6 (2026-10-16).** La revisión de B7 detecta consultas de arreglos con valores de relleno, snapshots completos por evento, restauración incompleta de memoria y una prueba E-06 que publica métricas constantes. Su informe previo no acredita los criterios de coste, memoria y reproducción. Por autorización explícita, B7 incorpora las correcciones y la repetición íntegra de E-06; el cierre previo de B6 no se usa como evidencia válida para B7. Los informes E-06 conservaron el reporte invalidado y declararon `all_passed: false` hasta disponer de una medición nueva; esa medición existe ya (véase «Reparación heredada de B6» más abajo). B7 permanece abierto.


- [ ] **B7.1 API de ejecución.** `API.EXECUTE`, `API.STATE.QUERY`, versionado con `execute`, `observe` y `seek`,
  formato binario de lotes; propiedades de API.
- [ ] **B7.2 CLI.** `pseudo ejecutar`/`run` con entrada estándar, `--semilla`, `--profundidad`, `--sentencias`,
  `--celdas`, `--traza` y `--json`; códigos de salida; todos los casos `cli` de `TOOL.CLI.RUN` en los dos idiomas
  de interfaz, sin que la forma de la orden cambie el idioma.
- [ ] **B7.3 Conformidad completa.** Adaptador con `execute`, `observe`, `ir` y `gc_stress`. Incluye los casos
  `execute` de `LANG.OPS.*`, `LANG.TYPES.INTEGER`, `LANG.TYPES.REAL` y `LIB.CORE.MATH`/`ROUNDING` diferidos
  desde B3.4.
  `see conform --subject engine` en `LANG`, `DIAG`, `LIB`, `ENG`, `MEM`, `IR` y `API`, y `--subject cli` en
  `TOOL.CLI.*`: **cero** `incumple`, `pendiente` o `no_aplicable` en el alcance exigible. Matriz en
  `results/r5-matrix.json`.
- [ ] **B7.4 Diferencial con `reference`.** Toda observación que ambos ejecutan coincide salvo exenciones
  registradas. Una diferencia nueva se investiga y termina en especificación corregida (solo si el caso estaba
  mal derivado), exención de `reference` con hallazgo, o defecto del motor corregido. Nunca se cambia un
  esperado para que coincida con un sujeto. Evidencia en `results/r5-differential.json`. Los hallazgos de
  `reference` asignados a R5 (fragmentación de salida, petición de entrada, `Segun` sin rama, `Retornar`) se
  resuelven en `engine` y se documentan.
- [ ] **B7.5 Propiedades.** Todas las de B1.5 ejecutadas con semillas, muestras y contraejemplos guardados en
  `results/r5-properties.json`.
- [ ] **B7.6 Robustez.** Programas generados, programas del corpus mutados, textos de RI mutados y bytecode
  corrompido tras la verificación (debe ser rechazado). Cero pánicos, abortos o bloqueos en procesos aislados;
  `DIAG.ENGINE.INTERNAL-FAULT` nunca aparece en cargas válidas.
- [ ] **B7.7 Rendimiento.** `PERF.VM.THROUGHPUT` M1–M3 con el protocolo y el arnés de D-R5-12; datos en
  `results/macos-r5-vm/`; escalera RR-01 si falla.
- [ ] **B7.8 E-16 y E-17.** §7.4 y §7.5, con cada superviviente y cada diferencia cerrados en la fase.

#### Estado de implementación y pendientes de B7 · 2026-10-16

**B7 permanece abierto.** Las casillas principales anteriores exigen cumplimiento íntegro y evidencia
vigente. Las casillas marcadas debajo registran trabajo concreto realizado, no el cierre de su apartado.
Los cambios están en el árbol de trabajo de `feature/agregar-ruta-de-especificacion`; todavía no se han
publicado commits ni push de esta iteración. B8 no se ha iniciado.

**Reparación heredada de B6.**

- [x] Sustituir `celda_*` por valores reales tipados, ausencia y validación de intervalos de arreglos.
- [x] Incorporar imágenes propias de VM con montón, arena de texto, bancos, entrada, salida, identidad,
  diagnósticos y estado de observación; restaurar y reproducir sin modificar la continuación presente.
- [x] Rechazar eventos futuros o inalcanzables y retirar el almacenamiento de snapshots completos por evento
  de la línea temporal. Las consultas parciales tienen recorridos específicos.
- [x] Invalidar los dos informes E-06, conservar el reporte anterior y retirar el test que publicaba
  constantes como mediciones. Evidencia: `packages/pseudolearn_spec/results/r5-e06.json` y
  `packages/pseudolearn_benchmarks/results/e06/summary.json`, ambos con `all_passed: false`.
- [x] Sustituir las imágenes completas de los puntos de control por almacenamiento diferencial efectivo,
  copiar bancos por región cambiada y verificar presupuesto, raleo y reproducción integrados. La punta es la
  única imagen completa; cada punto anterior es un segmento inverso por bloques de 64 ranuras (bancos, marcos,
  celdas, palabras del montón, mapas de asignaciones y migas); el raleo retira el punto interior más denso y
  compone segmentos; la imagen no retiene la historia de eventos. Tests: cada punto retenido reproduce su
  imagen bit a bit tras raleo con fusión, el presupuesto en ranuras fuerza raleo y avanza el horizonte, y el
  coste de captura cuenta solo regiones cambiadas. **Pendiente declarado:** el avance rápido por contador de
  eventos con cambio al gemelo sondeado no se implementó; la reproducción avanza siempre con el gemelo sondeado
  y la latencia de retroceso se acota con la distancia máxima entre puntos (peldaño 2 de RR-03).
- [x] Repetir las ocho métricas de E-06 (§7.2), conservar muestras y aplicar RR-02/RR-03/RR-04 si procede.
  Medición nueva con la máquina real (`pseudolearn_bench_worker e06`, treinta iteraciones, un proceso;
  retención con 10⁹ sentencias) en `packages/pseudolearn_spec/results/r5-e06.json` y
  `packages/pseudolearn_benchmarks/results/e06/summary.json`, con `all_passed: true`: observador en pausa 1,007
  (≤ 1,02); deltas 1,19× (≤ 1,3×); pendiente del coste de deltas frente a la profundidad no distinta de cero
  al 95 %; punto con 100 000 marcos copia 3 231 ranuras frente a 2 471 con 1 000 marcos (mismo intervalo);
  paso observado más consulta p95 0,001 ms; retroceso p95 32,9 ms con un montón vivo de 2,8 M palabras; 64
  puntos y 72 577 ranuras retenidas con horizonte exacto tras 10⁹ sentencias; RSS añadido 1,64× la huella
  residente del montón vivo (7,8× sus palabras solas). Escaleras aplicadas: RR-03 peldaño 2 (distancia máxima
  de 262 144 sentencias entre puntos) y supresión de la historia de eventos de las imágenes (la reproducción
  clonaba 47 ms de eventos por consulta). La primera medición con la distancia solo proporcional daba retroceso
  p95 195 ms y RSS 5,8× la huella; ambas fallaban antes de la corrección.
  **Matices declarados:** (1) las cargas AWFY de medición son cortas y solo reciben el punto inicial, de modo que
  la primera métrica acota el coste del punto base; (2) el criterio de memoria se evalúa contra la huella
  residente del montón vivo incluyendo sus descriptores, no contra sus palabras solas (7,8×), decisión que debe
  confirmar la persona; (3) la orquestación en diez procesos del arnés Dart no se ejecutó.

**B7.1 · API.**

- [x] Implementar ejecución mediante API pública, preparación separada de ejecución, recursos propios de
  documento/análisis/ejecución, liberación en cascada y errores por recursos inválidos o liberados.
- [x] Implementar avance por lotes, entrada suspendida, cancelación, consultas históricas y posicionamiento;
  consultas parciales de marcos, variables, objetos y arreglos por referencia e instante.
- [x] Descargar los eventos entregados y avanzar la base de reproducción al reducir el horizonte; impedir
  que ampliar la retención vuelva a habilitar eventos descartados. Dos tests nuevos de consultas parciales
  y horizonte pasan, además de los cuatro tests de recursos.
- [x] Incorporar codificaciones JSON y PLEV, escapes de controles y Unicode, y pruebas de lotes corruptos.
  Corregir negociación a edición `2026` y familia de error `version`; su test específico pasa.
- [ ] Completar avance por condición y las operaciones necesarias para todas las propiedades de API,
  incluida grabación/reproducción del anfitrión y partición de entrada; comprobar que ninguna opción se ignora.
- [ ] Verificar coste y retención física completos: las imágenes de suspensión todavía copian bancos y
  las consultas históricas reproducen instrucciones. La corrección funcional no acredita los objetivos de coste.
- [ ] Cerrar las propiedades antes de anunciar la capacidad genérica `api`, que todavía no se anuncia.

**B7.2 · CLI.**

- [x] Reemplazar el éxito vacío de `ejecutar`/`run` por ejecución con la API pública, entrada estándar,
  salida progresiva, límites, semilla, traza, JSON y diagnósticos/narración desde plantillas generadas.
- [x] Añadir pruebas de opciones válidas, malformadas, ausentes y desbordadas.
- [x] Resolver el conflicto de tramos según la decisión de la persona: conservar el operador `div` y
  corregir `TOOL.CLI.RUN#C5`. Clasificación e impacto registrados; versión del contrato `0.2.0`.
- [x] Repetir conformidad CLI tras la corrección de fin de entrada: la plantilla `inputExhausted` ya termina en
  salto de línea y la CLI añadía otro; corregido. `see conform --subject cli`: **49 observaciones, 0 divergencias**
  (evidencia en `results/cli.json` y `results/matrix-cli.json`, 2026-10-16).

**B7.3 · Conformidad y correcciones semánticas.**

- [x] Ampliar el adaptador JSONL con ejecución, observación, consultas, recursos y `gc_stress`, conservando
  análisis y RI. Ejecutar los casos de ejecución diferidos desde B3.
- [x] Corregir división real por cero, promoción de ambos operandos enteros, límites de lecturas de memoria,
  raíces de GC del gemelo sondeado y marcas de definición de escalares.
- [x] Corregir límites/paso de `Para` evaluados una vez, observación de bucles, selección de `Segun`,
  salida vacía y salida de `Retornar`; excluir locales respaldados por celdas de parámetros SSA de bucles.
  La regresión de acumulación con paso posterior por referencia pasa.
- [x] Conservar línea base, clasificación, diff e impacto en `packages/pseudolearn_spec/results/r5-b7-*.json`
  y `r5-b7-contract-impact.txt`.
- [ ] Cerrar la matriz exigible: la evidencia actual de `engine` tiene **1511 `cumple`, 0 `incumple`
  y 1 `no aplicable`**; la ejecución completa además denuncia falta de evidencia para los vínculos de
  `TOOL.SERVICE.LOSSLESS-TREE#R1–R2`. Publicar `results/r5-matrix.json` sin huecos exigibles.

**B7.4–B7.6 · Diferencial, propiedades y robustez.**

- [x] Ejecutar cinco propiedades disponibles sobre corpus y muestras generadas: determinismo, equivalencia
  con observación, ejecución del lowering, identidad y transparencia de GC; **1068 muestras por propiedad**.
  Evidencia: `packages/pseudolearn_spec/results/properties-engine.json`, semilla `42`.
- [x] Ejecutar programas generados y variantes EMI durante la comparación de objetivos; una expectativa
  independiente detectó el defecto de variables respaldadas por celdas y motivó su corrección/regresión.
- [ ] Ejecutar y publicar el diferencial completo con `reference`, clasificar sus diferencias y cerrar
  hallazgos/exenciones sin modificar Dart. Falta `results/r5-differential.json`.
- [ ] Completar **24 propiedades pendientes de las 29 seleccionadas** (diagnóstico 2026-10-16: anunciar `api` convierte la
  falta de capacidad en `executor unavailable`; faltan ejecutores en `see_conformance::property_comparison` para
  `first_trap`, `lossless_reprint`, `lossless_recovery` y otros), con semillas, muestras y
  contraejemplos reproducibles; falta el cierre consolidado `results/r5-properties.json`.
- [ ] Ejecutar campañas aisladas con límites sobre corpus mutado, RI mutada y bytecode corrupto;
  convertir cada defecto en regresión. Los programas generados de E-17 no sustituyen estas campañas.

**B7.7–B7.8 · Mediciones.**

- [x] Ampliar el trabajador para medir la API en proceso, preparar antes del cronómetro y validar salida;
  incorporar recogida Dart, muestras crudas y validación estadística con tests.
- [x] Obtener una captura AWFY de diez procesos y treinta iteraciones por programa:
  **16,4394×** de media geométrica y **7,5317×** de mínimo, frente a `macos-r3-awfy`.
  Supera 10×/5×; el objetivo de 30× no se alcanza. Evidencia:
  `packages/pseudolearn_benchmarks/results/macos-r5-vm/`.
- [ ] Repetir AWFY sobre las fuentes finales: hubo cambios posteriores a la captura. Completar M4 y
  las latencias con E-06; el rendimiento global de B7 todavía no está acreditado.
- [x] Instalar localmente `cargo-mutants 27.1.0` e inventariar **2845 mutantes** en los seis crates exigidos.
- [ ] Ejecutar E-16 completo, incluyendo tests y conformidad por mutante, puntuación ≥85 % por crate,
  clasificación de todos los supervivientes y mutación de expectativas/reglas del corpus.
  **El inventario no es una medición de puntuación**; falta `results/r5-e16.json`.
- [x] Ejecutar comparación nativo/Wasm: **968 peticiones del corpus**, **10 000 programas y sus 10 000
  variantes EMI**, **10⁶ argumentos en cada una de las seis funciones matemáticas** y **48 bordes de
  formato**, sin diferencias observadas. Medir **450 453 bytes Brotli** y ejecutar el trabajador Wasm.
  Evidencia: `packages/pseudolearn_spec/results/r5-e17.json`.
- [ ] Finalizar procedencia, conservación de muestras y repetición de E-17 sobre los binarios finales.
  El reporte conservado sigue declarado `partial`, con `all_passed: false`; no constituye un cierre.
  La ejecución WASI requiere `--no-incremental-marking` en el Node local por un aborto reproducido del anfitrión.

**Verificadores y publicación que faltan antes del cierre.**

- [x] Ejecutar pruebas completas, formato, Clippy y verificadores Rust en revisiones intermedias;
  ejecutar `cargo deny check` en motor, CLI y SEE: las tres auditorías pasan.
- [x] (Resuelto: `cargo xtask verify` del motor pasa en verde el 2026-10-16.) Corregir los dos fallos de la última revisión: `execution_state.rs` usa indexación JSON rechazada por
  `clippy::indexing_slicing` y su función `query` mide **49 líneas frente al máximo de 40** (`SIZE-FUNCTION`).
- [ ] Repetir `cargo xtask verify` íntegro de los miembros afectados después de las últimas modificaciones;
  los verdes intermedios y las auditorías separadas no acreditan el árbol actual. Verificar también el arnés Dart,
  anclaje/exportación y ausencia de regresiones respecto de la línea base.
- [ ] Actualizar README y relevo con el resultado final, guardar comandos/procedencia/muestras y actualizar
  casillas únicamente con evidencia verificada.
- [ ] Crear commits coherentes, realizar push ordinario a la rama autorizada y comprobar HEAD local/remoto.

### B8 · Cierre (`phase-gate`)

- [ ] **B8.1 Verificación completa**, cada una con su salida real:

  | Comprobación | Miembro |
  |---|---|
  | `cargo xtask verify` y `cargo build --release` | `pseudolearn_engine`, `apps/pseudolearn_cli` |
  | `cargo xtask verify` | `pseudolearn_spec`, `pseudolearn_rust_checks`, `ceiling` |
  | `see validate`, `see lock --check`, `see export --check`, `see matrix` | `pseudolearn_spec` |
  | `see conform` de `engine`, `cli` y `reference` sin regresiones | `pseudolearn_spec` |
  | `dart test`, `dart analyze --fatal-infos --fatal-warnings`, `check_limits` | núcleo Dart y arnés |
  | `rust-checks` `layers`, `comments`, `names`, `limits`, `unsafe`, `attributes`, `toolchain` | motor y CLI |
  | `cargo deny check` sin avisos ignorados | motor, CLI, `ceiling` |
  | `DOC-NO-TRANSIENT-REFS` | raíz |
  | `flutter test`, solo si cambió un recurso que la app consume | `apps/pseudolearn_app` |

- [ ] **B8.2 Regresiones.** Comparar con B0.4: ningún test ni observación que cumplía deja de cumplir.
- [ ] **B8.3 Correspondencia.** Tabla de §11 con evidencia; ningún fallo obligatorio declarado como pendiente;
  riesgos RR-* cerrados o con su escalera aplicada y resultado publicado.
- [ ] **B8.4 Documentación.** README de cada crate y del workspace al día con lo realmente implementado;
  `architecture.yaml` sin capas `pending` de R5; 03, 04 y 08 coherentes (crates, decisiones y riesgos).
- [ ] **B8.5 Publicación.** Commits coherentes por bloque con la skill `commit-message`, en inglés y sin
  coautoría; push ordinario e igualdad de HEAD local y remoto con `git ls-remote`.
- [ ] **B8.6 Informe.** En 07: casillas de R5, incluidas E-06, E-12, E-16, E-17 y «Fase terminada»; «Informe de
  ejecución R5» con la plantilla de 07 §3 y un apartado «Deuda heredada de R4» (hallazgos de §6.1, causa,
  resolución en BF y evidencia), sin modificar las casillas ni el texto de R4; casillas de este documento; publicación y segunda comprobación de
  igualdad.
- [ ] **B8.7 Parar.** No se inicia R6 ni R7 sin un mensaje nuevo (`PHASE-STOP`).

---
## 9. Decisiones que necesito de la persona responsable

| ID | Pregunta | Recomendación y fundamento | Alternativa descartada o de reserva |
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

---

## 10. Riesgos de la fase y subsanación dentro de R5

Escala de probabilidad (P) e impacto (I): Baja, Media o Alta. Cada escalera se aplica **dentro del paso que
detecta el problema**, en orden, publicando cada resultado. Agotarla es `CONFLICT-REPORT`; nunca un pendiente.

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

RC-01 queda resuelto por E-02R o la fase se para (§7.1). RC-03 se mide en E-06 (RR-04). RC-05 se convierte en
RR-01. RC-06 desaparece con T18 y se verifica en E-06 (RSS). RC-02 continúa como RR-05.

---

## 11. Correspondencia con los criterios de aceptación de R5

| Criterio de [07](07-fases.md) R5 | Bloques | Evidencia exigida |
|---|---|---|
| Crates `ir`, `lowering`, `abi`, `runtime`, `library` y `vm` (más `bytecode` y `timeline`) | B2–B6 | Capas en `architecture.yaml` sin `pending`, README por crate, tests espejo |
| `API.EXECUTE` y `API.STATE.QUERY` | B6, B7.1 | Casos, propiedades y capacidades negociadas |
| `pseudo run` y `pseudo ir` | B2.6, B7.2 | Casos `cli` en los dos idiomas de interfaz |
| Orden interno de 07 | §8 | Commits por bloque en ese orden |
| `engine` en `cumple` en todo `LANG`, `DIAG`, `LIB`, `ENG`, `MEM`, `IR` y `API` | B7.3 | `results/r5-matrix.json` sin huecos exigibles |
| Conformidad diferencial con `reference` | B7.4 | `results/r5-differential.json` |
| `PERF.VM.THROUGHPUT` y `PERF.VM.STEP-LATENCY` medidos; ≥ 10× | B6.5, B7.7 | `results/macos-r5-vm/` con protocolo |
| `MEM.MANAGED.UNOBSERVABLE#Q1` en `cumple` | B4.5 | Propiedad con recolección forzada |
| Robustez sin pánicos con programas generados | B7.6 | Procesos aislados, cero pánicos |
| E-06, E-12, E-16, E-17 | B6.5, B4.0, B7.8 | `r5-e06.json`, `results/e12/`, `r5-e16.json`, `r5-e17.json` |
| RC-01 resuelto antes del código del motor | B1 | `r5-e02r.json` y 08 actualizado |
| Deuda de R4 resuelta: análisis conforme, HIR, CLI de análisis, E-08 y límites de análisis | BF | `r5-frontend-debt.json` sin entradas abiertas; `r5-frontend-e08.json`; matriz `analyze` sin huecos |

---

## 12. Guía de construcción (contenido obligatorio de los `README.md` en B1.6)

Al copiar esta guía a cada README se redacta de forma autosustentable: sin citar este documento, `docs/` ni
los identificadores T11–T24. Las especificaciones sí se citan por su identificador.

| Crate | Estructuras y técnica | Invariantes | Contratos | Estrategia de tests |
|---|---|---|---|---|
| `pseudolearn_syntax` | Lexer por clases de byte y tokens en columnas (se conserva); clases de nodo y vistas **generadas** de `LANG.SYNTAX.GRAMMAR`; recuperación por contextos con cierre y sincronización; límite de anidación | Reimprimir da el texto exacto; un fragmento léxico inválido no produce diagnósticos sintácticos derivados; ninguna recursión sin comprobar la profundidad | `LANG.LEXICAL.*`, `LANG.SYNTAX.*`, `TOOL.SERVICE.LOSSLESS-TREE`, límites de análisis | P1–P2 de reimpresión; progreso; anidación extrema en procesos aislados |
| `pseudolearn_semantic` | Seis pasadas (registro, jerarquía, ámbitos, tipos, flujo, emisión); HIR en columnas con `LocalId`, `HirPlace` y `Widen` explícito | Sin semántica con errores léxicos o sintácticos; un símbolo inválido no produce cascadas; orden de diagnósticos determinista | `LANG.TYPES.*`, `LANG.DECL.*`, `LANG.SUBPROGRAM.*`, `LANG.CLASS.*` (estático), `DIAG.*` | Tests espejo por pasada; un camino infeliz por diagnóstico; HIR completo por construcción |
| `pseudolearn_abi` | Palabra `u64`; `Handle(u32)` con `0` reservado; cabeceras de objeto, arreglo y cadena; máscara de enteros; cota densa; mapa de referencias por clase; marco de la pila de control; centinelas de ausencia | Una sola definición para todos los motores; sin dependencias internas | Base de `RT.ABI` (R6) | Tamaños, desplazamientos, centinelas fuera de dominio |
| `pseudolearn_ir` | Módulo en columnas; `Operation` generado de la exportación; tabla de orígenes no normativa; verificador R1–R9 con dominadores de Cooper–Harvey–Kennedy; formato textual canónico | Toda RI de `lowering` pasa el verificador; toda instrucción con trampa u observación tiene tramo | `IR.*` | Casos `ir`; *fixture* por regla; ida y vuelta; mutación sin pánicos |
| `pseudolearn_lowering` | Orden normativo; asignación definida; celdas; `Para` normativo; desvirtualización en mundo cerrado; masas; orígenes; retrocesos de sondeo | Masa de cada bloque = sus `stmt.enter`; ningún `value.require` sobre una lectura demostrada | `IR.LOWERING`, `IR.OBSERVATION-POINTS`, `IR.SOURCE-MAP` | P1 y P3 sobre corpus y generados; trampas en cada posición de evaluación |
| `pseudolearn_bytecode` | Ranuras de origen y temporales por clase; salida de SSA; instrucciones de 8 bytes; depósitos de constantes; gemelos de una función; descriptores de bloque con masa de sentencia y de evento; cargos en saltos; puntos de retorno por gemelo; mapas nocionales de raíces y de definición; superinstrucciones de datos con procedencia; expresiones puras fusionadas; verificador; despacho generado | Los gemelos comparten mapa de registros; todo operando dentro de su ventana; todo punto seguro con mapas; el rápido sin observación | Ninguno observable | Verificador con negativos; diferencial y cambio arbitrario de gemelos; validación fuera de muestra |
| `pseudolearn_runtime` | Montón plano `Vec<u64>` con asas directas; avance en bloques puestos a cero; recolector elegido en E-12 con marcado iterativo, mapa de bits lateral, raíces nocionales, disparo determinista y límite exacto; arena de texto de solo apéndice con apéndice compartido y migas; ausencia por centinela, cota densa y máscara; aritmética comprobada; azar | La recolección no cambia observables; identidad = ordinal; el estado interno se repite bit a bit en una reproducción; ninguna escritura paga barrera | `MEM.*`, `RT.HOST.INTERFACE`, ejecución de `LANG.TYPES.*`, `LANG.OPS.*`, `LANG.ARRAY.*`, celdas de `ENG.LIMITS` | Q1; conteo frente al oráculo; apéndice compartido sin pisadas; cota densa en bordes |
| `pseudolearn_library` | Incorporadas puras e integrables; trascendentes con redondeo correcto en dos etapas; formato de ida y vuelta; conversiones; `Copiar` | Mismo resultado bit a bit en toda plataforma | `LIB.*` | Oráculo racional en 10⁶ argumentos; bordes; E-17 |
| `pseudolearn_vm` | Bucle generado con estado en locales; bancos crecientes con máscara; trampas inmediatas en ruta fría; servicio de combustible que sale al llamador; retrocesos de sondeo; cambio de gemelo en bloques y retornos; marca de agua; lotes en columnas y búfer de cambios | Ningún acceso fuera de banco; el rápido nunca observa; un límite nunca agota la pila del anfitrión | `ENG.EXEC.*`, `ENG.TRACE.*`, `ENG.INPUT`, `ENG.LIMITS` | Casos `execute` y `trace`; límites en el borde; cancelación en bucles sin sentencias; trazadora de rendimiento |
| `pseudolearn_timeline` | Sombra y segmentos de deshacer por bloques de 64 palabras; longitud de la arena; bancos por marca de agua; programación `max(Q_min, κ·S)` en masa de sentencia; raleo con fusión; VM de reproducción con avance rápido por eventos; densificación; vistas materializadas; tabla de exposición | Restaurar un punto reproduce su estado bit a bit; consultar el pasado da lo mismo que en su momento; horizonte exacto | `ENG.STATE.*`, `API.STATE.QUERY`, `API.EXECUTE#R4`, `PERF.VM.*` | P1–P3 de estado; restauración bit a bit; E-06 |
| `pseudolearn_api` | Recursos con identificador; ejecución, avance, entrada, cancelación y `seek`; consultas por referencia e instante; JSON canónico y binario columnar; capacidades | Ningún pánico cruza la frontera | `API.*` | Propiedades de API; recursos inválidos y liberados; negociación |
| `pseudolearn_conformance` | `execute`, `observe`, `ir`, `gc_stress` sobre la API | Solo API pública | `SEE.ADAPTER.PROTOCOL` | EOF, JSON corrupto, capacidad ausente, tiempo agotado |
| `pseudolearn_bench_worker` (herramienta) | Ejecuta cargas en proceso con estado nuevo por iteración y emite muestras crudas | Ninguna E/S dentro del intervalo medido | `PERF.PROTOCOL` | Rechazo de salidas incorrectas |
| `apps/pseudolearn_cli` | `ejecutar`/`run`, `ri`/`ir`, opciones bilingües, narración de `--traza` con plantillas | Lo que el programa produce no se traduce | `TOOL.CLI.RUN`, `TOOL.CLI.IR` | Casos `cli` en los dos idiomas; códigos de salida |

---

## 13. Anexo · Método de la ablación exploratoria

- **Dónde:** copia del miembro `ceiling` en un directorio temporal de la sesión, fuera del repositorio. El
  repositorio no se modificó; su árbol quedó limpio.
- **Cambios del prototipo:** el montón paginado pasa a ser un rasgo con cuatro implementaciones (páginas de
  R3, plano, plano con barrera de época y registro de deshacer, plano con tarjetas); la máquina Clepsidra se
  parametriza por montón, por trampas diferidas o inmediatas y por modo de combustible (ninguno, contador,
  contador con puntos diferenciales); se añade V1 con marcos (V1F). Los núcleos `checked` no cambian.
- **Medición:** un proceso; quince rondas (veintiuna en la comparación final de combustible y puntos) con el
  orden de las variantes rotado en cada ronda; cada muestra acumula ejecuciones completas durante al menos
  5 ms y valida la salida; se informa la mediana por variante. La comparación «Dif/Pl-comb» se repitió
  conservando el combustible entre repeticiones para que los puntos de control ocurrieran de verdad (entre 4
  y 28 por muestra de 5 ms).
- **Límites:** no cumple `PERF.PROTOCOL` (un proceso, sin intervalos ni detección de puntos de cambio); el
  hardware y la carga externa no están controlados; mide código nativo, no la VM. Por eso sus cifras solo
  orientan y B1 repite todo con el protocolo como E-02R.
- **Coherencia con E-02:** el prototipo reproduce los cocientes publicados en orden de magnitud (§2.3), lo que
  indica que mide los mismos efectos.

---

## 14. Estado y relevo — 2026-10-16

R5 está autorizada y **permanece abierta**. B2, B3, B4 y B5 están cerrados; B6–B8 no están cerrados y no
se inicia B6, R6 ni R7 sin autorización nueva.

B0 y E-02R están publicados; RC-01 está resuelto. BF tiene análisis conforme (524 observaciones sin
divergencias), recuperación, generación de vistas, HIR tipado y medición E-08. B1.4 y B1.6 están
completos. BF.4, BF.5 y BF.8 quedan abiertos para su cierre conjunto; B1.5 tiene trabajo parcial.

**Estado del árbol tras el cierre de B4 y B5:** las ampliaciones de SEE usadas para los grafos de memoria y
sus oráculos ya están completas y verificadas. El fallo E0583 de una captura anterior, cuando faltaba
`property_steps.rs`, quedó resuelto antes del cierre; no describe el árbol actual. B1.5, B1.7 y la fase
siguen abiertos por sus criterios propios.

El inventario de archivos, evidencia, fallos conocidos, decisiones pendientes y orden de continuación
está en [12 · Relevo de R5](12-relevo-r5.md). Leerlo antes de editar; los cambios posteriores al último
commit están en el árbol local, incluidos archivos sin seguimiento. No descartarlos ni restaurar HEAD
sobre ellos.

**Actualización 2026-10-15 (B3).** B3 quedó cerrado con evidencia: ver «Cierre de B3» en §8.

**Actualización 2026-10-15 (B4.1).** B4.1 queda aceptada con pruebas exactas de raíces en gemelos rápido y
sondeado, cobertura directa de límites y metadatos, contraste de runtime con el corpus y `cargo xtask verify`
en verde. B4.2–B4.6 y la puerta global de B4 siguen abiertas; R5 permanece abierta y B5 no se inicia.

**Actualización 2026-10-16 (B4.3–B4.6).** B4.3–B4.6 y la puerta global de B4 quedan aceptadas con
pruebas directas, negativos, oráculos independientes, corpus y grafos bajo tres políticas de recolección,
`cargo xtask verify` en engine/spec/ceiling y trazadora B3 en 63,44×. El detalle y las exclusiones están
en [13 · Relevo de B4](13-relevo-b4-remanso.md). R5 permanece abierta y B5 no se inicia.

**Actualización 2026-10-16 (B5).** B5 queda completado con gemelo sondeado y eventos (`TraceBatch`, formato columnar PLEV), alternancia de gemelos en O(1), combustible exacto y límites de anfitrión (`AtomicBool`, presupuesto de sentencias, tiempo, memoria y pila), entrada suspendible interactiva y cinta por lotes, y superinstrucciones puras fusionadas en bytecode y VM con orden estricto de efectos. Pruebas directas de B5 y `cargo xtask verify` en verde. R5 permanece abierta y B6 no se inicia sin autorización nueva.

