# pseudolearn_engine

## 1. Qué es y qué no es

Núcleo estático y determinista de PseudoLearn, con arquitectura Remanso. Sirve a CLI, Flutter, Wasm y servicio de lenguaje mediante una API pública única.

1. **Ejecutar y observar son actividades distintas.** El motor ejecuta siempre a velocidad completa;
   observar es reconstruir, sobre un tramo, lo que la ejecución hizo. Nada que solo sirva para observar
   puede costar en el camino rápido.
2. **El determinismo es un recurso.** Como una ejecución queda definida por programa, configuración,
   semilla y cinta de entradas, el motor puede reproducir en lugar de registrar. Toda decisión interna
   que introduzca no determinismo, como recolectar por tiempo o identificar por dirección, está
   prohibida.
3. **Verificar una vez, no comprobar nunca.** Lo que se puede demostrar antes de ejecutar (tipos, rangos
   de registros, destinos de salto) se demuestra en el verificador. La representación hace imposible
   el resto sin ramas: potencias de dos y máscaras.
4. **Los tipos estáticos se cobran en ejecución.** Ningún valor lleva etiqueta de tipo. La clase de valor
   de cada registro (escalar o referencia) se conoce al compilar y decide en qué banco vive.
5. **Una sola disciplina para todos los motores.** VM y AOT comparten RI, disposición de marco,
   disposición de objetos y raíces del recolector. Una diferencia de representación entre motores es
   una divergencia esperando a ocurrir.
6. **Seguridad estructural.** Cero `unsafe` fuera de los puentes generados y de la frontera ABI del backend
   nativo (`pseudolearn_aot_rt`). La velocidad sale del diseño, no de saltarse las comprobaciones de Rust.
7. **Lo que no se mide no se afirma.** Cada técnica nombra la métrica de `PERF.*` que la
   valida, y el resultado se publica aunque la refute.
8. **Las escrituras no pagan la observación.** Las diferencias se calculan en los puntos de control;
   el camino rápido no lleva barreras por página, escritura ni bandera de trampa.
9. **La observación tiene presupuesto.** La densidad de puntos depende de la masa de sentencia y del
   tamaño del estado; el reloj no programa puntos.
10. **La máquina nocional conserva su exactitud.** Mapas estáticos separan raíces, definición y variables
    observables del contenido accidental de los registros.

Fuera de alcance de producto: construcciones nuevas, concurrencia, reloj libre, efectos no grabables y JIT.
Fuera de alcance técnico: motor durante la especificación, dependencias de UI, Cargo raíz y unsafe fuera de puentes generados y de `pseudolearn_aot_rt`.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| codegen: Cranelift permanece como backend release; trampas inmediatas con bloque frío compartido con identidad por sitio de fallo; sin transferencia AOT → VM porque `aot` está exento de observación; evaluar alternativas según costes residuales medidos | E-NR1, RT.ABI | R6 |
| wasm: bancos crecientes con máscara; puentes generados | API completa | R8 |

## 2. Guía operativa y ciclo de vida

El workspace contiene el motor de ejecución completo de R5, con todos sus bloques (B0–B8) cerrados.
La conformidad integrada, el diferencial de 0 no resueltas con reference, y los cuatro experimentos
E-06, E-12, E-16 y E-17 están verificados en verde.

El sujeto `aot` (código nativo generado por `pseudolearn_codegen` y ejecutado como proceso real) se declara en `conformance-aot.yaml` y se contrasta con `see conform --subject aot` desde `packages/pseudolearn_spec`; su adaptador es `pseudo --see-adapter aot` de la CLI, no `pseudolearn_conformance`, porque enlazar y lanzar ejecutables es capacidad de la CLI. Anuncia `execute` y `gc_stress` y está exento de observación e inspección paso a paso. Sus reglas se vinculan como `cumple` cuando el corpus las mide, `exento` cuando solo las verifican casos de análisis, de representación intermedia o de traza, y `pendiente` cuando ningún ejecutor de propiedades las cubre aún. El rendimiento del código nativo se mide con `cargo run --release -p pseudolearn_bench_worker -- paired <directorio-nuevo>` (README del trabajador).

El motor ejecuta enteros, reales, control, subprogramas, referencias, texto, arreglos, celdas, objetos,
copia superficial, recolección determinista y azar con semilla. La API conserva entradas y eventos,
cambia entre los gemelos rápido y sondeado, y expone `execute` mediante `ExecutionResource` y
`CheckpointStore`.

La medición final de AWFY-core en macOS ARM64 obtuvo media geométrica de 30,026× y mínimo de 19,866×,
con cero muestras descartadas. El resumen y los resultados por carga están en
[`macos-r5-vm`](../pseudolearn_benchmarks/results/macos-r5-vm/summary.json).
Comandos de compilación y verificación:
- Verificación completa del motor: `cargo xtask verify`.
- Compilación optimizada: `cargo build --release`.
- Pruebas unitarias y de integración: `cargo test --workspace`.
- Conformidad desde `packages/pseudolearn_spec`: `cargo run -p see_cli --bin see -- conform --subject engine --operation analyze`.
- Medición E-08 vigente en `packages/pseudolearn_benchmarks/results/e08r/` y su comprobación en
  `packages/pseudolearn_spec/results/r5-frontend-e08.json`; la captura histórica anterior se conserva.
Plataformas soportadas: macOS (arm64/x86_64), Linux y Windows. No hay secretos ni despliegue propio: los consumidores distribuyen sus artefactos.

## 3. Arquitectura y modelo del sistema

`pseudolearn_native_probe` es tooling sin consumidores de producto: enlaza el objeto medido, el runtime AOT y los núcleos V1F de ceiling. Solo este trabajador recibe la dependencia externa por ruta `ceiling_kernels`; ceiling no importa el motor. Su única conversión insegura presta los bytes de configuración de C durante la llamada.

Un crate por capa; Cargo impide ciclos y el verificador contrasta dependencias con architecture.yaml.
Los niveles siguientes solo importan los anteriores permitidos explícitamente.

| Nivel | Crate | Responsabilidad | Imports internos permitidos |
|---|---|---|---|
| 0 | pseudolearn_source | Representa el texto fuente original con posiciones verificadas | — |
| 0 | pseudolearn_abi | Declara la disposición compartida de los valores de ejecución | — |
| 1 | pseudolearn_diagnostics | Representa diagnósticos mediante códigos con argumentos tipados | source |
| 1 | pseudolearn_lexicon | Expone vocabularios bilingües generados desde el corpus | source |
| 2 | pseudolearn_syntax | Construye un árbol sintáctico sin pérdida para cualquier texto | source, diagnostics, lexicon |
| 3 | pseudolearn_semantic | Produce un HIR tipado desde la resolución estática | source, diagnostics, lexicon, syntax |
| 3 | pseudolearn_ir | Define la representación intermedia verificada | source, abi |
| 4 | pseudolearn_lowering | Traduce el HIR a representación intermedia observable | semantic, ir, diagnostics |
| 4 | pseudolearn_bytecode | Traduce RI verificada a representación de bytecode y gemelos | ir, source |
| 4 | pseudolearn_runtime | Proporciona aritmética comprobada, montón, arreglos, objetos, texto y recolección | abi, diagnostics |
| 5 | pseudolearn_library | Implementa conversiones, redondeo e intrínsecos matemáticos correctamente redondeados | runtime, diagnostics |
| 6 | pseudolearn_aot_rt | Frontera `extern "C"` entre código nativo generado y runtime: contexto `#[repr(C)]`, asignación, acceso a memoria, celdas, texto, matemática, azar, E/S y fallos con sitio | source, abi, diagnostics, runtime, library |
| 7 | pseudolearn_codegen | Genera el objeto nativo del sujeto `aot` con Cranelift: las 74 operaciones de la RI, con acceso a memoria en línea, despacho virtual, pila de raíces y trampa fría compartida con identidad por sitio; en modo ejecutable añade `main` y los metadatos | ir, diagnostics, aot_rt |
| 6 | pseudolearn_service | Proporciona análisis incremental por unidad, autocompletado bilingüe, hover, formateo canónico, traducción y sesión LSP | source, diagnostics, lexicon, syntax, semantic |
| 6 | pseudolearn_vm | Ejecuta bytecode verificado y devuelve terminación, servicio o trampa tipada | bytecode, runtime, library, diagnostics, vm_dispatch (compilación) |
| 7 | pseudolearn_timeline | Reconstruye el estado observable de cualquier instante mediante puntos de control | vm, runtime, bytecode, diagnostics |
| 8 | pseudolearn_api | Ofrece operaciones públicas totales sobre recursos del núcleo | source, abi, diagnostics, lexicon, syntax, semantic, ir, lowering, bytecode, runtime, library, vm, timeline, service, codegen, aot_rt |
| 9 | pseudolearn_conformance | Adapta la API al protocolo de conformidad por procesos | api |
| tooling | pseudolearn_vm_tracer | Mide directamente la VM y prepara bytecode antes del intervalo medido | api, bytecode, vm |
| tooling | pseudolearn_vm_dispatch | Genera la forma de despacho de la VM desde la tabla de formas y `IR.INSTRUCTIONS` | ninguna |
| tooling | pseudolearn_math_probe | Evalúa la biblioteca matemática sobre los argumentos del contraste de SEE | library |


texto → source → syntax (árbol sin pérdida) → semantic (HIR) → lowering → ir verificada → bytecode → vm → timeline → api → consumidor.
El backend nativo consume la misma RI; pseudolearn_service consume el árbol sintáctico y el análisis semántico. diagnostics y lexicon suministran datos generados a las etapas.

`crates` contiene las capas documentadas y las herramientas internas; `specification-export` aloja datos cuando exista el consumidor.
Prohibido que una capa importe consumidores, UI, el núcleo Dart o see como crate. La exportación del corpus es una dependencia de datos, no de código.
Concurrencia: una ejecución y su línea temporal se procesan secuencialmente; el anfitrión orquesta ejecuciones independientes.
`pseudolearn_aot_rt` es una hoja que importa source, abi, diagnostics, runtime y library; `pseudolearn_runtime` no importa `pseudolearn_library`, por lo que la frontera con la biblioteca matemática no puede vivir en el runtime. `pseudolearn_codegen` importa ir, diagnostics y `pseudolearn_aot_rt` (desplazamientos del contexto y tipos de sitio de fallo) y depende de `cranelift-codegen`, `cranelift-frontend`, `cranelift-module`, `cranelift-object` y `target-lexicon`; solo `pseudolearn_api` lo importa, para exponer la construcción de objetos ejecutables a la CLI, y el adaptador `aot`. pseudolearn_service reside en el nivel 6 y alimenta a pseudolearn_api; wasm se declara con su carpeta al abordar su hito.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: los consumidores móviles y Wasm no compilan programas nativos. Elección: la API desactiva AOT por omisión y expone sus módulos y dependencias nativas solo con la feature `native`; la CLI y el trabajador AOT la activan explícitamente. Se descarta confiar en la eliminación de símbolos del enlazador, porque no elimina Cranelift del grafo de compilación.


La arquitectura explota el determinismo para separar ejecución rápida de reconstrucción observable.
La VM despacha sobre instrucciones inmutables del bytecode verificado sin clonarlas en cada paso;
los errores de ejecución siguen rutas frías separadas del despacho habitual.

### source

Problema: representa el texto fuente original con posiciones verificadas. Elección: `SourceText` con los bytes originales; índice de inicios de línea; conversión perezosa de desplazamiento de byte a columna en puntos de código; detección de BOM; NFC solo para comparar nombres, con camino rápido ASCII.
Alternativas descartadas: Unicode aporta UTF-8 y NFC para comparar identificadores; se rechaza normalizar el texto almacenado porque perdería posiciones originales.

### abi

Problema: declara la disposición compartida de los valores de ejecución. Elección: Disposición de valores, cabeceras de objeto (clase o tipo de arreglo, ordinal), mapas de referencias por clase y forma del marco bicameral, como constantes y tipos compartidos.
Alternativas descartadas: V8 y JVM inspiran referencias comprimidas. La disposición canónica permite banco de referencias como pila sombra; se rechazan marcos distintos por motor.

### diagnostics

Problema: representa diagnósticos mediante códigos con argumentos tipados. Elección: `Diagnostic { code, class, severity, span, related, arguments }`; `enum DiagnosticCode` generado; plantillas bilingües generadas; ordenación de `DIAG.ORDERING`.
Alternativas descartadas: El corpus DIAG aporta el catálogo y las plantillas. Se rechaza traducir lexemas del usuario o mezclar idioma de interfaz con vocabulario.

### lexicon

Problema: expone vocabularios bilingües generados desde el corpus. Elección: Tablas generadas de vocabulario y funciones por perfil; **hash perfecto** generado en `build.rs`; normalización de caja y acentos por perfil; identidades de apertura de nivel superior para autodeclarar el vocabulario.
Alternativas descartadas: El hash perfecto generado reconoce palabras sin búsquedas con asignaciones. Se rechaza copiar el vocabulario o usar la grafía de la orden para inferir idioma.

### syntax

Problema: construye un árbol sintáctico sin pérdida para cualquier texto. Elección: Lexer por tabla de 256 clases de byte; tokens en columnas (`kinds: Vec<TokenKind>`, `starts: Vec<u32>`) con la trivia como tokens; parser de descenso recursivo con recuperación por conjuntos de sincronización; **árbol postorden** `Node { kind: u16, first_token: u32, subtree_size: u32 }`; vistas tipadas generadas de `LANG.SYNTAX.GRAMMAR`.
Alternativas descartadas: Carbon y Zig inspiran tokens en columnas y postorden; se rechaza el árbol verde/rojo rowan por asignaciones e indirecciones. El descenso recursivo facilita recuperación explícita; se descartan LALR y PEG para mantener sus decisiones visibles.

### semantic

Problema: produce un hir tipado desde la resolución estática. Elección: Columnas con índices tipados (`LocalId`, `FunctionId`, `ExpressionId`, `TypeId`); registro de firmas, jerarquía, ámbitos por unidad, tipos y flujo; HIR tipado con la clase de valor de cada expresión; desvirtualización por jerarquía de clases en mundo cerrado.
Alternativas descartadas: Arenas con índices tipados evitan referencias enlazadas y sus tiempos de vida. Se rechaza Rc<RefCell<…>> por coste y errores dinámicos de préstamo.

### ir

Problema: define la representación intermedia verificada. Elección: CFG SSA con parámetros de bloque; clases de valor; celdas; `observe` con masa de sentencia; pureza derivada de efectos; verificador; formato textual con ida y vuelta; catálogo generado de la exportación de `IR.INSTRUCTIONS`.
Alternativas descartadas: SSA con parámetros de bloque permite compartir semántica con Cranelift. Las banderas pegajosas de IEEE 754 inspiran acumulación de trampas; se rechaza perder la primera trampa o hacer visible un efecto posterior.

### lowering

Problema: traduce el hir a representación intermedia observable. Elección: HIR → RI; orden de evaluación normativo; inserción de puntos de observación y cálculo de masa por bloque; paso por referencia escalar como celda y parámetros arreglo como asas compartidas, porque el arreglo completo no se asigna.
Alternativas descartadas: La RI tipada deriva del orden de evaluación del corpus; se rechaza optimizar antes de conservar los observables y sus nodos fuente.

### bytecode

La implementación compila RI verificada en los gemelos y valida sus destinos, clases y puntos de retorno.
El código se rellena a potencia de dos, y `SuperInstruction::CompareBranch` se activa por omisión.

Problema: traduce la ri verificada a bytecode gemelo con asignación bicameral de registros. Elección: Salida de SSA con copias paralelas; asignación de registros **por clase** sobre dos ventanas; generación **gemela** (rápida y sondeada) con una sola función parametrizada; tabla de correspondencia de puntos de observación; superinstrucciones elegidas por frecuencia de bigramas; `enum Instruction` de 8 bytes con operandos de 16 bits; código acolchado a potencia de dos; verificador de bytecode; despacho generado en `build.rs`.
Alternativas descartadas: Lua 5 y SPARC inspiran ventanas solapadas; el verificador de la JVM inspira verificar una vez. CPython inspira generar el catálogo. Self inspira el cambio de código en punto seguro; se descartan JIT, desoptimización y selección manual de superinstrucciones.

### runtime (B4 aceptada)

El runtime cubre aritmética comprobada, montón plano, objetos, arreglos, mapas de definición de enteros,
raíces exactas por punto seguro, texto, recolección no móvil y azar con estado explícito. Cada asignación
guarda forma y metadatos en una cabecera común en banda; no consulta `BTreeMap<Handle, Allocation>` en
el camino de lectura y escritura. `BlockRecord` conserva dirección, tamaño físico y celdas lógicas para
recolección y diferenciales. Las lecturas y escrituras obtienen sus metadatos de la cabecera y del diseño
de clase indexado. Los diferenciales del montón cubren solo palabras usadas. Las asas pueden reutilizar
una dirección física sin reutilizar su identidad ordinal. `#![forbid(unsafe_code)]` rige en este crate.
Alternativas descartadas: V8 y JVM inspiran asas comprimidas; Swift inspira migas para texto UTF-8. Se rechaza conteo de referencias por ciclos, movimiento por identidad e unsafe en el runtime. Immix, LXR y Perceus son alternativas medibles sin adopción técnica.

### library (B4 aceptada)

La biblioteca implementa conversiones, truncamiento, redondeo, valor absoluto, raíz cuadrada y las
trascendentes con redondeo correcto. `Copiar` comparte referencias, conserva ciclos y ausencia y no
ejecuta constructores; el azar llega por la capacidad sembrada del anfitrión.

Problema: implementa las funciones incorporadas sobre valores del runtime. Elección: Funciones incorporadas sobre los valores del runtime, sin estado global; azar desde la capacidad inyectada.
Alternativas descartadas: LIB.MODEL y LIB.CORE definen firmas y efectos. Se rechazan reloj global, azar no inyectado y conversiones de tipos implícitas.

### vm (B7)

La VM ejecuta valores escalares y referencias, texto, arreglos, celdas, objetos, llamadas virtuales,
`Copiar`, formato de salida y azar. B5 conserva el gemelo sondeado, eventos, cambio de gemelo y entrada.

Problema: ejecuta bytecode verificado emitiendo eventos observables. Elección: Bancos escalar (`u64`) y de referencias (`u32`) crecientes con longitud potencia de dos, con acceso `bank.get(index & MASK)`; ventanas solapadas para los argumentos; crecimiento en llamadas y comprobación independiente de la profundidad; **combustible por bloque** con caída exacta al gemelo sondeado; cambio de gemelo en O(1); trampas como `Result` de manejadores pequeños `#[inline(always)]`.
Alternativas descartadas: Lua 5 inspira ventanas de registros; Ertl y Gregg inspiran superinstrucciones; Rohou, Swamy y Seznec apoyan medir match con tabla de saltos. Se descartan computed goto y ensamblador. La seguridad sale de máscaras y verificación previa.

Los accesos a campos por valor usan `object.load` (`O49`) y `object.store` (`O50`); los argumentos por
referencia conservan celdas administradas. El cargador resuelve los desplazamientos de campo y
decodifica los accesos directos a campos y arreglos 1D como formas de operación propias, evitando
la búsqueda de `MemoryOp` por instrucción. Los arreglos de rango mayor usan búferes de pila para los
índices, dentro del rango máximo del bytecode. El runtime valida de una vez la cabecera de objetos y
arreglos 1D para reutilizar el tipo, rango y desplazamiento ya comprobados durante cada acceso.

Las llamadas virtuales guardan los destinos por clase en una tabla plana calculada al cargar el
programa. La VM consulta `Heap::needs_collection` antes de construir raíces; solo recorre los bancos
cuando la política o el presupuesto pueden iniciar una recolección. `CompareBranch` está activa por
omisión al compilar bytecode. `LoadedProgram` comparte su contenido inmutable con `Arc`; la máquina
posee ese contenido y permanece viva entre lotes de API sin referencias autorreferenciales. Las
imágenes conservan solo los bancos de ventanas activas, los límites se mantienen al entrar y retornar
llamadas, y los deltas de bancos y marcos comparan desde el primer índice modificado. Estas decisiones
mantienen comprobaciones de límites y tipos sin reservas dinámicas
por acceso normal. En la campaña `AWFY-core` de macOS ARM64, el motor obtuvo
30,026× de media geométrica y 19,866× de mínimo frente a `macos-r3-awfy`, con cero muestras
descartadas; los detalles por programa se guardan en
`packages/pseudolearn_benchmarks/results/macos-r5-vm/`.

### timeline

Problema: reconstruye el estado observable de cualquier instante mediante puntos de control. Elección: Cinta de entradas; puntos de control diferenciales (sombra del montón, segmentos de deshacer por bloques de 64 palabras, bancos de ventanas activas, registros, azar, cursor de salida) por masa de sentencia ejecutada, con **raleo exponencial** y presupuesto; consulta por instante = restaurar + reproducir con el gemelo sondeado; caché de vistas de marcos, variables y cortes de arreglos.
Alternativas descartadas: rr inspira grabar solo el no determinismo y reproducir; Python Tutor y Sorva inspiran la máquina nocional observable. Se rechazan grabación del sistema operativo, copia completa por evento, deltas de vista duplicados y tope fijo de pasos.

### matemática y memoria observables

Problema: el último bit de una trascendente y el signo de cero cambian la salida. Elección: redondeo
correcto mediante aproximación acotada y reevaluación adaptativa, oráculo racional independiente y
formato mínimo de ida y vuelta. Ziv, CRlibm y CORE-MATH inspiran el método; se rechaza libm del anfitrión.
El texto comparte apéndice conservando prefijos; Go y CPython inspiran apéndice sin conteo de referencias.
Las migas conservan UTF-8. El mapa por clase compone con herencia sin mover campos heredados.
Young y Daly inspiran densidad de puntos derivada del coste; HPC inspira comparación exacta con sombra.
Se rechazan reloj para programar puntos, hashes con falsos negativos y protección de páginas del SO.
Hölzle aporta tarjetas como alternativa medida y no como barrera por defecto.

### api

Problema: ofrece operaciones públicas totales sobre recursos del núcleo. Elección: Recursos con identificador; operaciones totales que devuelven `Result`; captura de defectos internos como `DIAG.ENGINE.INTERNAL-FAULT`; codificaciones JSON canónica y binaria columnar; negociación de capacidades; renderizado en el idioma de interfaz pedido. `ExecutionResource` conserva la máquina viva y delega los checkpoints a `pseudolearn_timeline::CheckpointStore`; las consultas reproducen en una máquina temporal desde el checkpoint más cercano.

La compilación para `execute` conserva los diagnósticos `Warning` del análisis cuando no hay errores; si
la compilación falla, la respuesta mantiene los diagnósticos de error ordenados.
Alternativas descartadas: El corpus API define recursos y codificaciones; se rechaza un objeto por evento en FFI, copiar todo el estado en cada lote y mantener un segundo almacén de snapshots completos.

### conformance

Problema: adapta la api al protocolo de conformidad por procesos. Elección: Binario del protocolo `see-protocol/1` sobre la API, con las capacidades `analyze`, `execute`, `observe`, `ir`, `service` y `cli` (esta última a través del binario `pseudo`).
Alternativas descartadas: SEE.ADAPTER.PROTOCOL define JSONL y negociación. Se rechaza importar internos del motor o declarar observe sin soportar eventos.

### service

Problema: proporcionar herramientas de edición de alta respuesta (autocompletado sensible al contexto, navegación, información emergente, formateo canónico, traducción y servidor LSP) sin dependencias externas masivas ni duplicar el árbol sintáctico.
Elección: sesión de documento (`DocumentSession`) que aplica ediciones por rango, reconstruye árbol, análisis e índice de símbolos y calcula las huellas de firma y de cuerpo de cada unidad para informar qué unidades cambiaron; autocompletado determinista derivado de los tokens anteriores al cursor, el análisis semántico y el vocabulario; formateador y traductor sobre los tokens sin pérdida del analizador, con ortografía canónica tomada del vocabulario generado; servidor LSP sin entrada ni salida propias, con ciclo de vida, sincronización incremental y posiciones UTF-16. El detalle de cada decisión vive en el README del crate.
Alternativas descartadas: frameworks externos de cómputo incremental (Salsa, Rowan), por dependencias pesadas y duplicación del árbol; reutilizar resultados semánticos entre ediciones, porque exige desplazar los intervalos posteriores a cada edición y la latencia medida de la reconstrucción completa cumple el presupuesto hasta diez mil líneas; formatear o traducir por líneas de texto, que no distingue cadenas, comentarios ni sombreado de funciones estándar.

Problema: una máscara puede convertir un índice inválido en otro registro válido. Elección: bancos con capacidad creciente en potencias de dos y acceso indexado comprobado después de validar bytecode; el relleno de capacidad no amplía la ventana lógica.
Alternativa descartada: enmascarar índices de bytecode, porque puede ocultar un operando fuera de ventana.
Problema: validar resultados no debe introducir E/S cruda en el camino medido. Elección: la VM acumula la salida en memoria y la devuelve al llamador; el tracer valida el resultado después del intervalo.
Alternativa descartada: escribir en stdout o en archivos desde la VM.
Problema: límites portables. Elección: combustible por masa de sentencia con caída exacta al código sondeado, celdas alcanzables y marcos activos.
Alternativa descartada: usar bytes o reloj para decidir fallos deterministas.
Problema: memoria retenida. Elección: presupuesto y raleo exponencial de puntos de control con horizonte declarado.
Alternativa descartada: guardar instantáneas ilimitadas o truncar silenciosamente.
Problema: recursos exactos sin recolección por asignación. Elección: cota de vivas tras recolección más nuevas asignadas; al superar el límite se recolecta y se decide con las vivas exactas.
Alternativa descartada: fallar sobre la cota aproximada.
Problema: marco común entre AOT y VM. Elección: banco de referencias como pila sombra y bloques fríos de transferencia en puntos seguros.
Alternativa descartada: representar objetos y raíces de forma distinta por backend.

Problema: el recolector y la consulta de estado no pueden contar temporales muertos como raíces.
Elección: mapas nocionales por punto seguro, ranuras de origen por variable y definición de enteros
separada del valor. Reales, lógicos, caracteres y referencias usan centinelas fuera de su dominio.
Los puntos de retorno identifican una continuación canónica con posición en cada gemelo; cambiar
la observación no reescribe marcos suspendidos. La reproducción empieza en modo `Fast` y cae a
`Probed` solo cuando necesita reconstruir estado o eventos. La VM entrega una salida de servicio al
agotar combustible; la capa superior decide cancelación, punto de control o reproducción.
Alternativas descartadas: raíces como prefijo completo del banco, retorno ligado a un gemelo y
acumulación de banderas de trampa fuera de expresiones puras fusionadas.

`crates/pseudolearn_bench_worker` es la herramienta de medición de API pública y solo importa esa API.
La trazadora de la VM es una herramienta interna distinta: compila antes de medir y llama a la VM
directamente para ejecutar las mismas cargas que `reference`; no llama a la API de ejecución ni se mezcla
con el trabajador público. Ambas conservan procedencia, muestras por proceso y validación de resultados
según el protocolo de rendimiento.

### Resultados de cierre de B7

AWFY-core se midió contra `macos-r3-awfy` con diez cargas y sin PGO.

| Carga | Aceleración |
|---|---:|
| `sieve` | 35,178× |
| `permute` | 30,440× |
| `queens` | 20,449× |
| `towers` | 35,338× |
| `list` | 33,393× |
| `storage` | 19,866× |
| `bounce` | 25,971× |
| `mandelbrot` | 60,261× |
| `nbody` | 23,372× |
| `richards` | 31,726× |
| **Media geométrica** | **30,026×** |

E-06 pasó sus criterios registrados. El agregado de retroceso cumple aunque una carga individual
excede el presupuesto:

| Métrica | Resultado | Criterio | Estado |
|---|---:|---|---|
| M2 paso observado y consulta | p95 0,001125 ms | ≤ 0,1 ms | Pasa |
| M3 retroceso | p95 agregado 32,868 ms; `storage-10` 59,020 ms | ≤ 50 ms | Pasa agregado; carga individual excedida |
| M4 sobrecoste en pausa | 1,007× | ≤ 1,02× | Pasa |
| E06-DELTA | 1,191× | ≤ 1,3× | Pasa |
| E06-DEPTH | 3,34×10⁻⁶ ns/marco | Dentro del margen de 4,46×10⁻⁶ | Pasa |
| E06-STACK | 3 231 ranuras con 100 222 marcos | ≤ 1,5× el caso superficial más un bloque | Pasa |
| E06-RETENTION | 72 577 ranuras, 64 puntos, horizonte 1 024 | ≤ 1 048 576 ranuras; 64 puntos | Pasa |
| E06-RSS | 1,637× de huella viva; 173 817 856 bytes extra | ≤ 2,5× | Pasa |

Evidencia: [`r5-e06.json`](../pseudolearn_spec/results/r5-e06.json).

E-16 sigue parcial; el puntaje mide mutantes viables cazados y no es un puntaje final de cada crate.

| Crate | Cazados / encontrados | Estado |
|---|---:|---|
| `pseudolearn_timeline` | 124 / 151 (100 % viables) | Completo |
| `pseudolearn_lowering` | 311 / 330 (100 % viables) | Completo |
| `pseudolearn_bytecode` | 337 / 384 (100 % viables) | Completo |
| `pseudolearn_runtime` | 563 / 607 (100 % viables) | Completo |
| `pseudolearn_vm` | 198 / 201 ejecutados viables; 820 sin probar; 3 expiraciones | Parcial |
| `pseudolearn_library` | Sin campaña | No iniciada |

Evidencia: [`r5-e16.json`](../pseudolearn_spec/results/r5-e16.json).

E-17 pasó sobre binarios nativos y Wasm finales: 968 peticiones del corpus, 10 000 programas generados,
10 000 pares EMI, 48 casos de frontera de formato y cero diferencias en seis funciones matemáticas con
un millón de argumentos cada una. El módulo Wasm mide 2 179 619 bytes y 480 752 bytes con Brotli.
Evidencia: [`r5-e17.json`](../pseudolearn_spec/results/r5-e17.json).

| B7.4 diferencial | Resultado |
|---|---:|
| Observaciones comparadas | 1 180 |
| Coincidencias | 888 |
| Diferencias exentas | 94 |
| Diferencias de span o avisos sin contratar | 198 |
| Diferencias no resueltas en salida, terminación o códigos de error | 0 |

La clasificación de las 198 observaciones sin contratar separa cambios de span y cambios en diagnósticos
no error (presencia, código, severidad o span):

| Clase | Observaciones |
|---|---:|
| Solo span | 154 |
| Solo diagnósticos no error | 24 |
| Ambos | 20 |
| **Total** | **198** |

En total, 174 observaciones tienen spans distintos y 44 cambian diagnósticos no error. Solo 12 difieren
exclusivamente en `end_col`; las demás diferencias de span también alcanzan columnas de inicio o líneas.
La clasificación descarta que las diferencias restantes sean únicamente precisión benigna de columna,
por lo que B7.4 permanece abierto. Evidencia: [`r5-differential.json`](../pseudolearn_spec/results/r5-differential.json).

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios ni atributos doc/allow/expect. Cada archivo tiene una responsabilidad; los límites y nombres viven en architecture.yaml.
Todos los crates presentes prohíben unsafe salvo `pseudolearn_aot_rt`, que lo confina a dos funciones auditadas en su README. `pseudolearn_wasm` generado queda autorizado por la política del miembro al incorporarse. Como `[workspace.lints.rust] unsafe_code = "forbid"` no admite excepciones por crate, `pseudolearn_aot_rt` declara su propia tabla `[lints]` con `unsafe_code = "allow"` y la misma lista de lints de Clippy que el workspace.
Errores esperables como Result; DIAG.ENGINE.INTERNAL-FAULT captura defectos internos en la frontera.
No se copian datos del corpus: build.rs genera vocabulario, gramática, diagnósticos y despacho desde la exportación verificada.
Las carpetas generated son salidas del generador; los límites no justifican dividir lógica arbitrariamente ni modificar generados a mano.

## 6. Decisiones de producto que condicionan el código

El comportamiento observable lo define el corpus. Una ejecución queda determinada por programa, perfil, rigor, semilla, límites y cinta de entradas.
Toda capacidad del anfitrión es grabable. La salida del programa nunca se traduce; la prosa de herramientas sigue el idioma de interfaz.
El camino rápido no ejecuta instrucciones de observación. Ambos gemelos comparten registros y marco; cambiar entre ellos solo cambia el contador de programa.
El montón usa palabras contiguas y asas u32 directas; la identidad es ordinal, nunca dirección.
Texto UTF-8, indicador ASCII y migas cada 64 puntos de código. Recolector preciso sin movimiento, marcas laterales y disparo por celdas.
Los bancos crecen por duplicación en llamadas; el límite de marcos es independiente del tamaño del banco.
Los umbrales provisionales y la línea base viven en PERF; resultados desfavorables de E-02 se conservan y condicionan el motor de ejecución.

## 7. Verificación, testing y aseguramiento de calidad

La política de licencias admite las que usan las dependencias presentes; no conserva permisos preventivos sin consumidor, para que la auditoría no produzca avisos ignorados. Cranelift aporta `Apache-2.0 WITH LLVM-exception` y `foldhash` aporta `Zlib`. `cranelift-object` activa `gimli`, que depende de `hashbrown` 0.16 mientras `cranelift-codegen` e `indexmap` usan 0.17; la política de versiones duplicadas exime solo `hashbrown@0.16.1`.

| Puerta | Evidencia exigida |
|---|---|
| layers declarativo | README por capa, ninguna carpeta huérfana ni fuente prematura |
| cargo xtask verify al implementar | Formato, Clippy, tests, dependencias, cadena y seis verificadores |
| see conform engine | Casos de análisis y ejecución según el contrato, ambos perfiles y rigores |
| see conform aot | Casos de ejecución contra el binario real, ambos perfiles y rigores, y propiedades con recolección forzada |
| Diferencial de gemelos | Igualdad de salida, fallos y estado observable |
| PERF | Medición local contra referencia con todos los resultados |

Tests espejo de src/, internos en archivos hermanos, nunca casos del corpus duplicados.
Camino válido e inválido: texto vacío, binario, Unicode descompuesto, profundidad extrema, colecciones vacías, bordes numéricos e identificadores de un carácter.
Los verificadores tienen casos negativos. Ningún pánico con programas del corpus o generados.
Se compara cada etapa con PERF.BASELINE.REFERENCE; toda degradación se informa en el mismo cambio.

## 8. Fuentes consultadas y genealogía conceptual

Unicode aporta UTF-8 y NFC para comparar identificadores; se rechaza normalizar el texto almacenado porque perdería posiciones originales.

El corpus DIAG aporta el catálogo y las plantillas. Se rechaza traducir lexemas del usuario o mezclar idioma de interfaz con vocabulario.

El hash perfecto generado reconoce palabras sin búsquedas con asignaciones. Se rechaza copiar el vocabulario o usar la grafía de la orden para inferir idioma.

Carbon y Zig inspiran tokens en columnas y postorden; se rechaza el árbol verde/rojo rowan por asignaciones e indirecciones. El descenso recursivo facilita recuperación explícita; se descartan LALR y PEG para mantener sus decisiones visibles.

Arenas con índices tipados evitan referencias enlazadas y sus tiempos de vida. Se rechaza Rc<RefCell<…>> por coste y errores dinámicos de préstamo.

SSA con parámetros de bloque permite compartir semántica con Cranelift. Las banderas pegajosas de IEEE 754 inspiran acumulación de trampas; se rechaza perder la primera trampa o hacer visible un efecto posterior.

La RI tipada deriva del orden de evaluación del corpus; se rechaza optimizar antes de conservar los observables y sus nodos fuente.

Lua 5 y SPARC inspiran ventanas solapadas; el verificador de la JVM inspira verificar una vez. CPython inspira generar el catálogo. Self inspira el cambio de código en punto seguro; se descartan JIT, desoptimización y selección manual de superinstrucciones.

V8 y JVM inspiran referencias comprimidas. La disposición canónica permite banco de referencias como pila sombra; se rechazan marcos distintos por motor.

V8 y JVM inspiran asas comprimidas; Swift inspira migas para texto UTF-8. Se rechaza conteo de referencias por ciclos, movimiento por identidad e unsafe en el runtime. Immix, LXR y Perceus son alternativas medibles sin adopción técnica.

LIB.MODEL y LIB.CORE definen firmas y efectos. Se rechazan reloj global, azar no inyectado y conversiones de tipos implícitas.

Lua 5 inspira ventanas de registros; Ertl y Gregg inspiran superinstrucciones; Rohou, Swamy y Seznec apoyan medir match con tabla de saltos. Se descartan computed goto y ensamblador. La seguridad sale de máscaras y verificación previa.

rr inspira grabar solo el no determinismo y reproducir; Python Tutor y Sorva inspiran la máquina nocional observable. Se rechazan grabación del sistema operativo, copia completa por evento y tope fijo de pasos.

El corpus API define recursos y codificaciones; se rechaza un objeto por evento en FFI y copiar todo el estado en cada paso.

SEE.ADAPTER.PROTOCOL define JSONL y negociación. Se rechaza importar internos del motor o declarar observe sin soportar eventos.
