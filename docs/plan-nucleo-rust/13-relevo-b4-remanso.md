# Relevo de implementación de B4 · 2026-10-16

## Punto de parada y autoridad de este relevo

Este relevo describe el árbol después de aceptar B4.2. **B4 y R5 permanecen abiertas. B4.1 y B4.2 están
aceptadas; B4.3–B4.6 siguen pendientes. No iniciar B4.3 ni B5 sin autorización nueva.** El [relevo 12](12-relevo-r5.md) es histórico y sus
indicaciones de que aún no existe backend ya no describen el estado del repositorio.

La autorización y el alcance son los del [plan 11, B4](11-plan-r5-ejecucion-remanso.md#b4--runtime-biblioteca-arreglos-subprogramas-objetos-y-recolector)
y el plan de implementación aprobado en la conversación: B4.0–B4.6, incluidos los cambios necesarios en
HIR/lowering/RI/bytecode y las pruebas directas en API. Se acordó expresamente acreditar B4 mediante
pruebas directas y oráculos independientes. `API.EXECUTE`, conformidad integrada `execute`, observación
completa, reproducción y sus propiedades se acreditan en B7.3; **no marcar `cumple` por adelantado**.
Entrada suspendible y cinta siguen en sus bloques propietarios.

## Preservar el trabajo

- Rama actual y única autorizada: `feature/agregar-ruta-de-especificacion` (`GIT-SINGLE-BRANCH`).
- HEAD base de esta aceptación: `b8e47a5` (`feature/agregar-ruta-de-especificacion`). El commit de B4.2
  está publicado en esta misma rama; al cierre, HEAD local y remoto coinciden y el checkout está limpio.
- No ejecutar `git reset`, `git clean`, restauraciones generales ni cambiar de checkout. Continuar
  el árbol completo y revisar `git status --short`, incluidos los archivos `??`.
- No hay subagentes ni procesos de implementación que deban continuar trabajando en segundo plano.
- No hay dependencias externas nuevas de runtime, biblioteca o VM. La API usa esos crates como
  dependencias de desarrollo para las pruebas directas. SEE permanece fuera de los imports del motor.
- Las modificaciones de especificación observable no se han ampliado en este lote. Los nuevos
  generadores materializan datos a partir del corpus y del registro de propiedades existente.

## Estado por entrega

Las casillas siguientes distinguen trabajo realizado de aceptación final. Una casilla de implementación
no certifica la puerta global, el rendimiento o la publicación.

### B4.0 · Experimento E-12: realizado

- [x] Tres prototipos en `ceiling_kernels/src/collection/`: listas por tamaños, líneas sin evacuación
  y conteo de referencias con eliminación de ciclos por borrado de prueba.
- [x] Diez cargas AWFY-core más `storage-deep` y `list-churn`, controles y raíces comunes,
  recolección cada 4096 celdas asignadas y puntos cada 4096 operaciones.
- [x] Captura previa al build, diez procesos y treinta iteraciones: **10.800 muestras, ninguna descartada**.
  Tiempo, pausas, palabras marcadas/barridas, memoria y bloques modificados; resultados comprobados.
- [x] Selección conservada: **`SizeClasses`**. Es el único candidato elegible. `Lines` tiene razón
  temporal 0,97744, pero su p95 de pausa en `sieve` es 2,51807× (>2×). `ReferenceCounts` tiene razón
  1,12848 y excede la guarda de pausa en `permute`, `queens`, `richards` y `towers`.
- [x] Crudos y procedencia: `packages/pseudolearn_benchmarks/results/e12/`; resumen idéntico en
  `packages/pseudolearn_spec/results/r5-e12.json`. Se conserva la captura inicial descartada como
  `results/e12/initial-line-per-object/`: el primer candidato de líneas desperdiciaba una línea por
  objeto; se corrigió para empaquetar objetos y se repitió toda la medición. No usar la captura inicial
  para la selección final.
- [x] Tests, Clippy y `rust-checks all` de ceiling pasaron durante el desarrollo del experimento.
- [ ] Ejecutar y conservar la puerta final completa `cargo xtask verify` de ceiling.
- [x] Corregir el enlace relativo al resultado de E-12 en el README de runtime: desde ese crate es
  `../../../pseudolearn_spec/results/r5-e12.json`.

### B4.1 · Montón, arreglos y metadatos: aceptados

- [x] `runtime/src/heap/`: `Vec<u64>`, asas `u32`, cero reservado, crecimiento comprobado por
  duplicación desde bloques de 4096 palabras, listas libres deterministas y ordinales monotónicos.
  Tamaño físico y celdas nocionales se contabilizan por separado; errores de recurso, límite e internos
  son tipos distintos. Solo objetos y arreglos consumen ordinal de identidad.
- [x] `runtime/src/array.rs`: disposición por filas, dimensión individual, cero válido, negativos,
  producto comprobado, cota densa y mapa físico de definición para enteros; centinelas para otros tipos.
- [x] `runtime/src/cell.rs`: destinos estables por asa e índice, sin punteros a `Vec`.
- [x] ABI: cálculo compartido del inicio de campos para máscaras de más de 64 campos y sus tests.
- [x] RI/lowering: orígenes cualificados por función, encabezados de declaración, parámetros/receptor,
  promociones a celda y copias de asignación para evitar que dos variables compartan accidentalmente
  una ranura SSA de origen.
- [x] Bytecode: clases heredadas, mapas de referencias, ranuras de origen, mapas de raíces y definición
  por punto, conservados en los gemelos rápido y sondeado.
- [x] `root_liveness.rs`: vivacidad por CFG; los parámetros de bloque se sustituyen por argumentos
  de la arista. Los orígenes de variables se conservan mientras vive su marco.
- [x] Negativos de mapas ausentes, raíces fuera de ventana o de clase incorrecta, mapas de definición
  inválidos, posiciones inválidas, duplicados y metadatos de definición mal formados.
- [x] Raíces exactas verificadas por punto seguro en ambos gemelos: literales e intermedios vivos,
  temporales tras su última lectura, argumentos de bloque, ramas y retrocesos de bucle.
- [x] La auditoría conserva las consultas de descriptor en `BTreeMap`: las palabras se acceden directamente
  después de validar el asa; no hay una puerta de rendimiento que exija reemplazar esas consultas ni se
  introduce un umbral nuevo.
- [x] Pruebas dirigidas de `ir`, `bytecode`, `runtime` y `api`, contraste de `LANG.ARRAY.*`,
  `LANG.TYPES.ARRAY` y `ENG.LIMITS#D1` mediante el corpus, y `cargo xtask verify` completados en verde.

### B4.2 · Texto, conversiones y salida: aceptación completa

- [x] `runtime/src/text/{create,parts,indexed,compact}.rs`: arena UTF-8 por apéndice, cabeceras
  independientes e inmutables por prefijo, apéndice compartido al final y copia en bifurcaciones.
- [x] `String` mantiene el invariante UTF-8 sin revalidar todo el texto al leer; indicador ASCII,
  longitud en puntos, migas cada 64 puntos calculadas perezosamente y compartidas por tramo.
- [x] Migas auxiliares en el montón sin coste nocional; compactación ordenada de tramos vivos,
  actualización de cabeceras e invalidación de índices. `compact_text` expone explícitamente
  `TextCompaction`; la recolección automática descarta el mapa porque aún no existe un consumidor, y su
  notificación queda diferida hasta que lo haya. No se añade una API anticipada ni se implementa la línea temporal.
- [x] `library/src/{decimal,format}.rs`: conversiones y formato primitivo común; real posicional,
  decimal obligatorio, ida y vuelta y cero negativo; vocabulario lógico suministrado por el consumidor.
- [x] VM: constantes de texto precargadas, concatenación texto/carácter en las cuatro combinaciones,
  operaciones de texto/conversión, salida variádica acumulada antes de publicar y sin celdas nocionales.
- [x] Vocabulario lógico generado a partir de la exportación; no se copian lexemas manualmente.
- [x] Tests runtime recientes pasan: Unicode suplementario/descompuesto, límites de migas,
  dos concatenaciones desde un prefijo, auto-concatenación y extensión/compactación de índices compartidos.
- [x] Regresión directa de VM: finitos (incluido cero negativo) conservan el formato y `NaN` e infinitos
  producen `nonFiniteRealResult` antes de llegar a `format_value`; su retorno público `String` no cambia.
- [x] Los casos exportados pertinentes del corpus pasan con recolección automática, manual y desactivada.
  `cargo xtask verify` pasa en `pseudolearn_engine` y `pseudolearn_spec`.

### B4.3–B4.4 · Subprogramas y objetos: implementados; aceptación pendiente

- [x] Ventanas de argumentos solapadas, bancos propios crecientes, continuación y definición conservadas;
  limpieza de referencias y bits al reutilizar ventanas para evitar raíces residuales.
- [x] Profundidad incluye el marco principal; `RunOptions` permite semilla, profundidad, celdas,
  política de recolección e inspección interna. Envoltorios anteriores conservados. Valores actuales:
  semilla 42, profundidad 100.000 en la VM de bajo nivel y 2²² celdas; las pruebas del corpus usan
  profundidad 1000 por omisión.
- [x] Locales/campos/elementos por referencia: designador e índices evaluados una vez, comprobación
  al crear la celda, alias inmediatos y escrituras al banco propietario con marcas de agua.
- [x] `lowering/{places,address_taken,expressions_objects,constructor_flow,dispatch_targets,class_density}.rs`:
  constructores y argumentos por referencia, receptor, `Este`, `Super`, superconstructor implícito,
  métodos virtuales y selección directa cuando la jerarquía cerrada demuestra un solo destino.
- [x] Objetos: campos heredados antes de propios, mapas estáticos de referencias, prueba conservadora
  de inicialización densa, máscara física de enteros y `Copiar` superficial sin constructor con nueva identidad.
- [x] Trampas con código, tramo y argumentos tipados; falta de retorno usa
  `subroutineEndedWithoutReturn` y relaciona el encabezado de la función.
- [x] Cuatro regresiones directas recientes pasan en `api/tests/runtime_edges.rs`: alias con índices
  con efectos; raíces suspendidas durante crecimiento a 150 llamadas; profundidad exacta y uno por
  encima; constructor por referencia y `Super` sobre el mismo receptor. Las comparaciones usan tres políticas.
- [ ] Completar negativos y bordes de ventanas/celdas, índice inválido antes de entrar en el cuerpo,
  recursión mutua, llamadas repetidas que reutilizan ventanas, copia con ciclos/ausencia y escapado de `Este`
  antes de inicializar campos enteros de una subclase.
- [ ] La última modificación movió la compatibilidad nominal a `ir/src/assignability.rs` y la reutilizó
  en `CellStore`. Verificar con una variable de tipo base promovida a celda que recibe un objeto derivado.
  La compatibilidad de argumentos de bloque aún es igualdad exacta: auditar uniones por ramas de subtipos.
- [ ] Completar negativos de tipos de las instrucciones nuevas y metadatos de métodos/campos; no
  deducir corrección solo porque el lowering no produzca entradas inválidas.

### B4.5–B4.6 · Recolección, límites y azar: implementados; aceptación pendiente

- [x] Recolector elegido integrado: marcado iterativo con bits laterales, listas por tamaño,
  direcciones libres ascendentes, raíces del marco activo y continuaciones suspendidas.
- [x] Disparo `max(4096, vivas)` con γ=1; comprobación exacta de alcanzabilidad más el valor nuevo
  antes de sobrescribir, también sin recuperación. Metadatos auxiliares y literales no consumen celdas.
- [x] Modos automático, forzado y sin recuperación. Comparaciones directas entre los tres modos.
- [x] xoshiro256** y SplitMix64, semilla con signo reinterpretada en complemento a dos, estado explícito
  copiable/restaurable, sin reloj, entorno o estado global.
- [x] Generación independiente de cien grafos reproducibles con alias/ciclos/texto usando
  `see_oracles::cells`, semilla y cantidad del registro de propiedades existente.
- [x] SEE materializa fixtures mediante `runtime-fixtures`; API los consume por proceso externo.
  No se creó otro adaptador de conformidad ni se añadieron imports SEE al motor.
- [ ] Repetir la comparación completa del corpus y grafos sobre el árbol final; atender cualquier
  contraejemplo de raíces, límites, diagnóstico o política.
- [ ] Ampliar la comparación generada más allá del grafo de objetos actual: arreglos, alcance de
  variables sin usos futuros, intermedios vivos y temporales muertos. Revisar identidad al reutilizar asas.

## Pruebas y verificaciones: estado tras B4.2

La evidencia de B4.1 corresponde a su aceptación previa. Para B4.2, `cargo test -p pseudolearn_runtime -p
pseudolearn_library -p pseudolearn_vm` pasó, incluidos los tests de formato finito y la regresión directa
de reales no finitos. `cargo test -p pseudolearn_api --test runtime_corpus -- --nocapture` pasó: 296
configuraciones del corpus en tres políticas de recolección. `cargo xtask verify` pasó en el motor (formato,
Clippy estricto, workspace completo, `rust-checks all`, toolchain y `cargo deny`) y en SEE (validación,
lock, exportación, referencias documentales y conformidad reference).

Las consultas a descriptores de arreglo y campo mediante `BTreeMap` se revisaron frente a las puertas
vigentes. Se conservaron por no existir un umbral aplicable que requiera cambiarlas; no se añadió una
meta de rendimiento.

B4.3–B4.6 conservan la aceptación pendiente enumerada en este documento. Tampoco se ejecutaron para este
cierre las puertas globales completas de ceiling ni la regresión de rendimiento emparejada. La publicación
de B4.2 no cierra B4 ni sustituye esos requisitos.

## Orden concreto para retomar

1. B4.1 y B4.2 están aceptadas; no repetir sus cambios ni descartar evidencia existente.
2. Para cualquier continuación autorizada, leer los contratos dueños y resolver únicamente los
   criterios aún abiertos de B4.3–B4.6 con casos del corpus y oráculos independientes.
3. Ejecutar las verificaciones que corresponden a los bloques abiertos y completar la puerta global de
   B4, incluidos SEE, ceiling, corpus y referencias. No anticipar `execute` ni su estado `cumple`.
4. Repetir la trazadora emparejada de B3, ≥30×, y aplicar RR-01 si falla. La herramienta
   `packages/pseudolearn_benchmarks/tool/r5_vm_tracer.dart` escribe por defecto en
   `results/r5-vm-tracer/` y `packages/pseudolearn_spec/results/r5-vm-tracer.json`:
   **preservar los crudos de B3 antes de lanzarla**, separar la captura nueva y registrar procedencia
   antes del build. Esta regresión no sustituye a la medición completa de B7.
5. La evidencia de B4.2 está en `r5-b4-verification.json`; completar allí la cobertura, exclusiones,
   mediciones, negativos y verificadores globales antes de aceptar B4.
6. La aceptación global de B4 requiere sus puertas restantes y publicación coherente en la rama única.
   R5 y B4 permanecen abiertas; `PHASE-STOP` requiere autorización explícita antes de iniciar B4.3.

## Comandos útiles y precauciones del entorno

Cada miembro tiene su workspace; no hay Cargo en la raíz. Los comandos se ejecutan desde el workspace
indicado y usan la toolchain fijada por `rust-toolchain.toml`.

Desde `packages/pseudolearn_engine`:

```sh
cargo test -p pseudolearn_bytecode --test memory_metadata_tests --test verify_tests
cargo test -p pseudolearn_runtime
cargo test -p pseudolearn_api --test runtime_edges
cargo test -p pseudolearn_api --test runtime_corpus -- --nocapture
cargo clippy --workspace --all-targets -- -D warnings
cargo run --manifest-path ../pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command --bin rust-checks -- all .
cargo xtask verify
```

Desde `packages/pseudolearn_spec`:

```sh
cargo test -p see_conformance --test memory_fixtures --test runtime_fixtures
cargo run -p see_cli --bin see -- runtime-fixtures --root .
cargo run -p see_cli --bin see -- validate
cargo run -p see_cli --bin see -- lock --check
cargo run -p see_cli --bin see -- export --check
cargo xtask verify
```

Desde `packages/pseudolearn_benchmarks/ceiling`, ejecutar `cargo xtask verify`. La captura E-12 ya existe;
no repetirla salvo cambios en el experimento o evidencia que lo justifique. Las pruebas API lanzan Cargo
SEE mediante proceso `--offline`; este uso no es el futuro adaptador `API.EXECUTE`.

El sandbox bloqueó escrituras de la base RustSec bajo `~/.cargo/advisory-dbs` y lecturas de `sysctl`;
las operaciones correspondientes pueden requerir escalación. La captura E-12 escalada fue autorizada.
No hubo rechazo de aprobación automática que requiera resolución de la persona. No confundir un fallo
real de código/test con ese límite ambiental. Los logs en `/private/tmp` son auxiliares; la copia del
checkpoint y este relevo permiten continuar sin depender de ellos.
