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
6. **Seguridad estructural.** Cero `unsafe` fuera de los puentes generados. La velocidad sale del diseño,
   no de saltarse las comprobaciones de Rust.
7. **Lo que no se mide no se afirma.** Cada técnica nombra la métrica de `PERF.*` que la
   valida, y el resultado se publica aunque la refute.
8. **Las escrituras no pagan la observación.** Las diferencias se calculan en los puntos de control;
   el camino rápido no lleva barreras por página, escritura ni bandera de trampa.
9. **La observación tiene presupuesto.** La densidad de puntos depende de la masa de sentencia y del
   tamaño del estado; el reloj no programa puntos.
10. **La máquina nocional conserva su exactitud.** Mapas estáticos separan raíces, definición y variables
    observables del contenido accidental de los registros.

Fuera de alcance de producto: construcciones nuevas, concurrencia, reloj libre, efectos no grabables y JIT.
Fuera de alcance técnico: motor durante la especificación, dependencias de UI, Cargo raíz y unsafe fuera de puentes generados.

| Pendiente | Dependencia | Fase |
|---|---|---|
| ir y verificador → lowering procedural → bytecode rápido → vm → runtime → library → arreglos → subprogramas → objetos y recolector → gemelo sondeado → límites → timeline → api ejecución → CLI ejecutar/ri | Análisis conforme | R5 |
| codegen: Cranelift, trampas diferidas y transferencia AOT → VM mediante marco canónico; LLVM como nivel release tras medición | E-NR1, RT.ABI | R6 |
| service: incrementalidad sobre postorden; salsa sujeto a E-08 | Análisis medido | R7 |
| wasm: bancos de 2¹⁸ ranuras; puentes generados | API completa | R8 |

## 2. Guía operativa y ciclo de vida

El workspace contiene las capas de análisis estático implementadas en Rust: `pseudolearn_source`, `pseudolearn_diagnostics`, `pseudolearn_lexicon`, `pseudolearn_syntax`, `pseudolearn_semantic`, `pseudolearn_api` y `pseudolearn_conformance`.
Comandos de compilación y verificación:
- Verificación completa del motor: `cargo xtask verify`.
- Compilación optimizada: `cargo build --release`.
- Pruebas unitarias y de integración: `cargo test --workspace`.
- Conformidad desde `packages/pseudolearn_spec`: `cargo run -p see_cli --bin see -- conform --subject engine --operation analyze`.
- Medición E-08 vigente en `packages/pseudolearn_benchmarks/results/e08r/` y su comprobación en
  `packages/pseudolearn_spec/results/r5-frontend-e08.json`; la captura histórica anterior se conserva.
Plataformas soportadas: macOS (arm64/x86_64), Linux y Windows. No hay secretos ni despliegue propio: los consumidores distribuyen sus artefactos.

## 3. Arquitectura y modelo del sistema

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
| 4 | pseudolearn_bytecode | Traduce la RI verificada a bytecode gemelo con asignación bicameral de registros | ir, source |
| 4 | pseudolearn_runtime | Gestiona los valores de ejecución en un montón plano determinista | abi, diagnostics |
| 5 | pseudolearn_library | Implementa las funciones incorporadas sobre valores del runtime | runtime, diagnostics |
| 6 | pseudolearn_vm | Ejecuta bytecode verificado emitiendo eventos observables | bytecode, runtime, library, diagnostics |
| 7 | pseudolearn_timeline | Reconstruye el estado observable de cualquier instante mediante puntos de control | vm, runtime, bytecode, diagnostics |
| 8 | pseudolearn_api | Ofrece operaciones públicas totales sobre recursos del núcleo | source, abi, diagnostics, lexicon, syntax, semantic, ir, lowering, bytecode, runtime, library, vm, timeline |
| 9 | pseudolearn_conformance | Adapta la API al protocolo de conformidad por procesos | api |


texto → source → syntax (árbol sin pérdida) → semantic (HIR) → lowering → ir verificada → bytecode → vm → timeline → api → consumidor.
El backend nativo consume la misma RI. diagnostics y lexicon suministran datos generados a las etapas.

crates contiene las capas documentadas y el trabajador de medición; specification-export aloja datos cuando exista el consumidor.
Prohibido que una capa importe consumidores, UI, el núcleo Dart o see como crate. La exportación del corpus es una dependencia de datos, no de código.
Concurrencia: una ejecución y su línea temporal se procesan secuencialmente; el anfitrión orquesta ejecuciones independientes.
codegen, service y wasm se declaran con sus carpetas al empezar sus fases; no son capas presentes del modo declarativo.

## 4. Decisiones de diseño y fundamentos técnicos

La arquitectura explota el determinismo para separar ejecución rápida de reconstrucción observable.

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

Problema: produce un hir tipado desde la resolución estática. Elección: Arenas con índices tipados (`SymbolId`, `TypeId`, `ScopeId`) en columnas; resolución de nombres y después de tipos; HIR tipado con la clase de valor de cada expresión; desvirtualización por jerarquía de clases en mundo cerrado.
Alternativas descartadas: Arenas con índices tipados evitan referencias enlazadas y sus tiempos de vida. Se rechaza Rc<RefCell<…>> por coste y errores dinámicos de préstamo.

### ir

Problema: define la representación intermedia verificada. Elección: CFG SSA con parámetros de bloque; clases de valor; celdas; `observe` con masa de sentencia; pureza derivada de efectos; verificador; formato textual con ida y vuelta; catálogo generado de la exportación de `IR.INSTRUCTIONS`.
Alternativas descartadas: SSA con parámetros de bloque permite compartir semántica con Cranelift. Las banderas pegajosas de IEEE 754 inspiran acumulación de trampas; se rechaza perder la primera trampa o hacer visible un efecto posterior.

### lowering

Problema: traduce el hir a representación intermedia observable. Elección: HIR → RI; orden de evaluación normativo; inserción de puntos de observación y cálculo de masa por bloque; paso por referencia como celda.
Alternativas descartadas: La RI tipada deriva del orden de evaluación del corpus; se rechaza optimizar antes de conservar los observables y sus nodos fuente.

### bytecode

Problema: traduce la ri verificada a bytecode gemelo con asignación bicameral de registros. Elección: Salida de SSA con copias paralelas; asignación de registros **por clase** sobre dos ventanas; generación **gemela** (rápida y sondeada) con una sola función parametrizada; tabla de correspondencia de puntos de observación; superinstrucciones elegidas por frecuencia de bigramas; `enum Instruction` de 8 bytes con operandos de 16 bits; código acolchado a potencia de dos; verificador de bytecode; despacho generado en `build.rs`.
Alternativas descartadas: Lua 5 y SPARC inspiran ventanas solapadas; el verificador de la JVM inspira verificar una vez. CPython inspira generar el catálogo. Self inspira el cambio de código en punto seguro; se descartan JIT, desoptimización y selección manual de superinstrucciones.

### runtime

Problema: gestiona los valores de ejecución en un montón plano determinista. Elección: Montón contiguo `Vec<u64>` con asas directas `u32`, cero reservado; asignación por avance en bloques puestos a cero y reutilización determinista; recolector preciso sin movimiento con **marcas laterales** y **disparo determinista** por celdas; límite de celdas exacto (cota superior = vivas tras la última recolección + asignadas desde entonces; si la cota supera el límite, se recolecta y se decide con el valor exacto); texto UTF-8 con indicador ASCII y migas cada 64 puntos de código; aritmética comprobada; azar xoshiro256\*\* con SplitMix64; `#![forbid(unsafe_code)]`.
Alternativas descartadas: V8 y JVM inspiran asas comprimidas; Swift inspira migas para texto UTF-8. Se rechaza conteo de referencias por ciclos, movimiento por identidad e unsafe en el runtime. Immix, LXR y Perceus son alternativas medibles sin adopción técnica.

### library

Problema: implementa las funciones incorporadas sobre valores del runtime. Elección: Funciones incorporadas sobre los valores del runtime, sin estado global; azar desde la capacidad inyectada.
Alternativas descartadas: LIB.MODEL y LIB.CORE definen firmas y efectos. Se rechazan reloj global, azar no inyectado y conversiones de tipos implícitas.

### vm

Problema: ejecuta bytecode verificado emitiendo eventos observables. Elección: Bancos escalar (`u64`) y de referencias (`u32`) crecientes con longitud potencia de dos, con acceso `bank.get(index & MASK)`; ventanas solapadas para los argumentos; crecimiento en llamadas y comprobación independiente de la profundidad; **combustible por bloque** con caída exacta al gemelo sondeado; cambio de gemelo en O(1); trampas como `Result` de manejadores pequeños `#[inline(always)]`.
Alternativas descartadas: Lua 5 inspira ventanas de registros; Ertl y Gregg inspiran superinstrucciones; Rohou, Swamy y Seznec apoyan medir match con tabla de saltos. Se descartan computed goto y ensamblador. La seguridad sale de máscaras y verificación previa.

### timeline

Problema: reconstruye el estado observable de cualquier instante mediante puntos de control. Elección: Cinta de entradas; puntos de control diferenciales (sombra del montón, segmentos de deshacer por bloques de 64 palabras, bancos por marca de agua, registros, azar, cursor de salida) por masa de sentencia ejecutada, con **raleo exponencial** y presupuesto; consulta por instante = restaurar + reproducir con el gemelo sondeado; caché de vistas; deltas desde el búfer de escrituras del gemelo sondeado.
Alternativas descartadas: rr inspira grabar solo el no determinismo y reproducir; Python Tutor y Sorva inspiran la máquina nocional observable. Se rechazan grabación del sistema operativo, copia completa por evento y tope fijo de pasos.

### api

Problema: ofrece operaciones públicas totales sobre recursos del núcleo. Elección: Recursos con identificador; operaciones totales que devuelven `Result`; captura de defectos internos como `DIAG.ENGINE.INTERNAL-FAULT`; codificaciones JSON canónica y binaria columnar; negociación de capacidades; renderizado en el idioma de interfaz pedido.
Alternativas descartadas: El corpus API define recursos y codificaciones; se rechaza un objeto por evento en FFI y copiar todo el estado en cada paso.

### conformance

Problema: adapta la api al protocolo de conformidad por procesos. Elección: Binario del protocolo `see-protocol/1` sobre la API, con las capacidades `analyze`, `execute`, `observe`, `ir` y `cli` (esta última a través del binario `pseudo`).
Alternativas descartadas: SEE.ADAPTER.PROTOCOL define JSONL y negociación. Se rechaza importar internos del motor o declarar observe sin soportar eventos.

Problema: seguridad sin ramas por acceso. Elección: bancos potencia de dos, índices enmascarados y código acolchado tras verificación de operandos y saltos.
Alternativa descartada: unsafe en el bucle caliente.
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
la observación no reescribe marcos suspendidos. La VM entrega una salida de servicio al agotar
combustible; la capa superior decide cancelación, punto de control o reproducción.
Alternativas descartadas: raíces como prefijo completo del banco, retorno ligado a un gemelo y
acumulación de banderas de trampa fuera de expresiones puras fusionadas.

`crates/pseudolearn_bench_worker` es una herramienta de medición que solo importa la API pública.
Genera cargas desde la exportación, ejecuta análisis en proceso y emite muestras después del intervalo.
La orquestación conserva diez procesos, treinta muestras, procedencia y métricas de proceso.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios ni atributos doc/allow/expect. Cada archivo tiene una responsabilidad; los límites y nombres viven en architecture.yaml.
Todos los crates presentes prohíben unsafe. Solo pseudolearn_wasm generado está autorizado por la política del miembro al incorporarse.
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
Los umbrales provisionales y la línea base viven en PERF; resultados desfavorables de E-02 se conservan y condicionan R5.

## 7. Verificación, testing y aseguramiento de calidad

| Puerta | Evidencia exigida |
|---|---|
| layers declarativo | README por capa, ninguna carpeta huérfana ni fuente prematura |
| cargo xtask verify al implementar | Formato, Clippy, tests, dependencias, cadena y seis verificadores |
| see conform engine | Casos de análisis y ejecución según la fase, ambos perfiles y rigores |
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
