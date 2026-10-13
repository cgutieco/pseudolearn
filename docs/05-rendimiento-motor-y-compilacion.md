# 05 · Rendimiento, motor y compilación

> **Estado:** investigación, no normativo. Las cifras propias proceden del
> [anexo A](anexos/A-experimentos-reproducibles.md) (una máquina, sin protocolo estadístico) y se usan
> como órdenes de magnitud. Las cifras externas citan su fuente. Ningún número de este documento es
> una promesa de rendimiento.

Responde a V-05 y V-18 a V-23.

---

## 1. Dimensiones que no deben mezclarse

### 1.1 Compilar a nativo el motor no es compilar a nativo los programas

**[COMPROBADO]** El motor actual ya se ejecuta como código nativo: la app Flutter se compila AOT y
`dart compile exe` produce un binario nativo del núcleo. Aun así, el intérprete AOT rinde igual que el
JIT de la VM de Dart (≈74 frente a ≈73 ns por micro-paso, anexo A): la lentitud no está en cómo se
compiló el motor sino en **cuánto trabajo hace el motor por cada operación del programa** (despacho de
tareas, pila de operandos de tipo `Object`, `BigInt` por resultado, instantáneas). Compilar a nativo
los **programas PseudoLearn** significa que una suma del programa se convierta en una instrucción de
suma (más su comprobación de desbordamiento), sin motor intermedio. Son problemas distintos con
soluciones distintas (V-23).

### 1.2 Las dimensiones

| Código | Dimensión                                    | Métrica principal                                                           | Quién la sufre                         |
|--------|----------------------------------------------|-----------------------------------------------------------------------------|----------------------------------------|
| P      | Rendimiento de los programas                  | Tiempo de pared y de CPU en estado estable; memoria pico (RSS)              | Quien ejecuta software escrito en PseudoLearn |
| C      | Rendimiento del compilador y herramientas     | Líneas por segundo en análisis y en compilación; memoria del compilador     | Quien programa (ciclo editar-compilar) |
| L      | Latencia de arranque e interacción            | Arranque de un ejecutable; primera salida; latencia por pulsación del servidor de lenguaje; latencia por paso en la app | Quien programa y quien aprende |
| M      | Costes de memoria                             | RSS, tamaño del montón, pausas de recolección, fragmentación                | Servicios y dispositivos modestos      |
| O      | Coste de observación, depuración e instrumentación | Factor de ralentización con traza, con puntos de parada, con contratos   | Quien aprende y quien depura           |
| B      | Tamaño de los artefactos                      | Tamaño del ejecutable; tamaño del paquete web                              | Distribución, web, móvil               |
| X      | Diferencias entre plataformas y cargas        | Matriz de las anteriores por plataforma y por tipo de carga                 | Todos                                  |

Una mejora en una dimensión puede empeorar otra: la monomorfización mejora P y empeora C y B; el JIT
mejora P de procesos largos y empeora L y M; la observación completa empeora P en un factor de 1,3 a
4,6 (H-12).

### 1.3 Cargas de trabajo distintas

| Carga                                 | Dominada por                                    | Qué técnica la mueve más                             |
|---------------------------------------|-------------------------------------------------|------------------------------------------------------|
| Numérica en bucles                    | Aritmética, comprobaciones, acceso a arreglos   | Compilación nativa, eliminación de comprobaciones redundantes |
| Estructuras enlazadas y objetos       | Asignación, despacho, recolección               | Diseño del montón y del recolector, desvirtualización |
| Cadenas y texto                       | Representación de cadenas, Unicode              | Representación UTF-8, iteradores                     |
| E/S y servicios                       | Llamadas al sistema, concurrencia               | Biblioteca estándar y modelo de concurrencia         |
| Programas cortos de la app            | Latencia de arranque y de paso                  | Intérprete eficiente, análisis incremental           |

---

## 2. Qué significaría cumplir la aspiración

### 2.1 Por qué «comparable a Rust o Go» necesita definición

Rust y Go no rinden igual entre sí: en cargas intensivas de CPU Rust suele ser más rápido y en memoria
más compacto, mientras que Go compila más rápido y arranca igual de rápido. Además, sus semánticas
difieren de la de PseudoLearn: Rust en modo *release* **no** comprueba desbordamiento por omisión; Go
no lo comprueba nunca; PseudoLearn lo diagnostica siempre (§12.2 de la especificación). Comparar sin
igualar semántica mezcla calidad de implementación con coste de la semántica.

### 2.2 Propuesta de definición (hipótesis a aprobar en D-07)

**Dos comparaciones, siempre reportadas juntas:**

1. **Misma semántica:** las versiones de referencia en Rust y Go se escriben con desbordamiento
   comprobado, índices comprobados y la misma representación de cadenas que PseudoLearn. Mide la
   calidad de la implementación de PseudoLearn.
2. **Semántica nativa de cada lenguaje:** versiones idiomáticas de Rust (modo *release*) y Go. Mide lo
   que experimenta quien elige lenguaje.

**Niveles de cumplimiento** (los umbrales son hipótesis de partida, no compromisos):

| Nivel | Nombre                        | Criterio sobre la suite de referencia (§2.3), comparación de misma semántica                     |
|-------|-------------------------------|---------------------------------------------------------------------------------------------------|
| N0    | Línea base                    | Intérprete actual (≈500×–1900× frente a nativo en micro-pruebas)                                   |
| N1    | Interpretación eficiente      | Media geométrica ≤ 30× Go; latencia de paso en la app ≤ 1 ms                                       |
| N2    | Comparable a Go               | Media geométrica ≤ 1,5× Go; ninguna prueba > 3× Go; memoria pico ≤ 2× Go                           |
| N3    | Comparable a Rust             | Media geométrica ≤ 1,5× Rust con comprobaciones; ninguna prueba > 3×; memoria pico ≤ 2× Rust       |

Cada nivel se declara **por plataforma** (macOS arm64, Linux x86-64, Windows x86-64 como mínimo) y
**por familia de carga** (§1.3). Alcanzar N2 en carga numérica y no en estructuras enlazadas es un
resultado válido y debe reportarse así.

### 2.3 Suite de referencia

- **Are We Fast Yet** (Marr, Daloze y Mössenböck, DLS 2016): 14 pruebas diseñadas precisamente para
  comparar implementaciones de lenguajes distintos con un subconjunto común de características
  (objetos, arreglos, cierres, cadenas), portadas a varios lenguajes. Su subconjunto encaja casi
  exactamente con PseudoLearn más closures y colecciones.
- **Subconjunto del Computer Language Benchmarks Game**, con la advertencia conocida de que sus
  programas más rápidos explotan detalles de cada implementación.
- **Cargas propias del dominio**: los programas de la base de conocimiento ejecutados a escala,
  análisis de archivos de texto, procesamiento de CSV.
- **Pruebas de compilador** (dimensión C) y de servidor de lenguaje (dimensión L).

### 2.4 Cómo comprobarlo

El protocolo completo está en [16](16-experimentos-y-benchmarks.md) §2. En resumen: ejecución en
máquinas de referencia declaradas, varias invocaciones de proceso y varias iteraciones por proceso,
detección de estado estable (Barrett et al., OOPSLA 2017, mostraron que muchas combinaciones
VM-prueba nunca lo alcanzan), intervalos de confianza (Georges et al., OOPSLA 2007; Kalibera y Jones,
ISMM 2013), y publicación de todos los resultados, incluidos los desfavorables. **No se inventan ni se
extrapolan resultados**: hasta que exista un backend, el único dato propio es N0.

---

## 3. Estrategias de ejecución y compilación

### 3.1 Panorama

| Estrategia                                | Ejemplos                                              | Velocidad típica relativa | Arranque  | Complejidad | Observabilidad   | iOS        |
|-------------------------------------------|-------------------------------------------------------|---------------------------|-----------|-------------|------------------|------------|
| Intérprete de árbol o de tareas           | PseudoLearn actual; intérpretes didácticos            | Muy baja                   | Inmediato | Baja        | Total            | Sí         |
| VM de bytecode (pila o registros)         | CPython (pila), Ruby YARV (pila), Lua 5 (registros)   | Baja-media                 | Inmediato | Media       | Alta             | Sí         |
| Bytecode con superinstrucciones y *quickening* | CPython 3.11+ (especialización adaptativa)      | Media                      | Inmediato | Media       | Alta             | Sí         |
| JIT base (plantillas, *copy-and-patch*)   | CPython 3.13 (PEP 744, copy-and-patch), V8 Sparkplug   | Media                      | Rápido    | Media       | Media            | **No**     |
| JIT optimizante por métodos               | V8 Maglev y TurboFan, HotSpot C2                      | Alta                       | Calentamiento | Muy alta | Requiere desoptimización | **No** |
| JIT por trazas / meta-trazas              | TraceMonkey (2009), LuaJIT, PyPy (2009)               | Alta en bucles             | Calentamiento | Alta     | Baja             | **No**     |
| Evaluación parcial de intérpretes         | Truffle/Graal (Würthinger et al., PLDI 2017)          | Alta                       | Calentamiento | Alta (con dependencia de GraalVM) | Media | No en JIT |
| AOT con backend propio                    | Go, compilador AOT de Dart                            | Alta                       | Inmediato | Alta        | Con información de depuración | Sí |
| AOT con LLVM                              | Rust, Swift, Clang                                    | Muy alta                   | Inmediato | Media (backend ajeno) | Con DWARF | Sí |
| AOT con Cranelift                         | Wasmtime, `rustc_codegen_cranelift`                   | Alta                       | Inmediato | Media       | Con DWARF        | Sí         |
| Traducción a C                            | Nim, Vala                                             | Alta                       | Inmediato | Media       | Mapeo de líneas  | Sí         |
| Traducción a otro lenguaje con recolector | Lenguajes que compilan a Go o a la JVM                | La del anfitrión           | La del anfitrión | Media | La del anfitrión | Depende   |
| WebAssembly (con Wasm GC, estándar 3.0 de 2025) | Kotlin/Wasm, Dart a Wasm                       | Alta                       | Rápido    | Media       | Limitada         | Vía navegador |

«Velocidad típica relativa» es una síntesis cualitativa de la literatura citada, no una medición.

### 3.2 La pregunta previa: ¿qué tipo de lenguaje es PseudoLearn?

**[COMPROBADO]** PseudoLearn es **estático, nominal y fuertemente tipado**: el tipo de cada expresión
se conoce antes de ejecutar, salvo la inferencia por lectura en el perfil flexible (único punto
dinámico, §12.5 de la especificación). **[INFERENCIA]** Esto decide la estrategia más que cualquier
preferencia: la mayor parte de lo que hace rápidas a las JIT de JavaScript (especular tipos, descubrir
formas de objetos, cachés en línea para propiedades dinámicas) resuelve un problema que PseudoLearn no
tiene. Un compilador AOT ya conoce las formas de los objetos y los tipos de los operandos.

### 3.3 El caso del intérprete

Aunque el destino sea nativo, la app necesita un intérprete (§3.5 y [06](06-ejecucion-pedagogica-y-app.md)).
El salto del intérprete de tareas actual a una VM de bytecode tiene precedentes bien medidos: las VM
de registros ejecutan menos instrucciones que las de pila (Shi, Gregg, Beatty y Ertl, VEE 2005; Lua 5.0,
Ierusalimschy et al., 2005); el despacho por hilos y las superinstrucciones reducen el coste de
despacho (Ertl y Gregg, 2003). **[HIPÓTESIS]** Una VM de registros en Dart, con enteros nativos donde el
objetivo lo permita y sin instantáneas fuera del modo observación, podría ganar uno o dos órdenes de
magnitud sobre N0; se mide con [E-03](16-experimentos-y-benchmarks.md#e-03).

<a id="jit"></a>

### 3.4 La JIT de JavaScript: qué se transfiere y qué no (P-03)

| Técnica de las JIT de JavaScript                           | Problema que resuelve allí                                 | ¿Transferible a PseudoLearn?                                                                                          |
|------------------------------------------------------------|------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| Escalonamiento (intérprete → base → optimizante)            | Arrancar rápido y optimizar lo caliente                    | **Sí, como idea**: intérprete en la app, compilación nativa para ejecutar «en serio». No necesita JIT para aplicarse |
| Clases ocultas / mapas (Self, Chambers et al., 1989)        | Objetos de forma dinámica                                  | **No necesario**: las clases tienen forma fija conocida al compilar                                                   |
| Cachés en línea, polimórficas (Hölzle et al., 1991)         | Despacho de propiedades y métodos dinámicos                 | **Parcial**: útil para despacho por interfaz en un intérprete; en AOT se usan tablas de métodos                       |
| Especulación de tipos                                       | Tipos desconocidos hasta ejecutar                          | **No**: los tipos son estáticos                                                                                       |
| Desoptimización (Hölzle, Chambers y Ungar, PLDI 1992)       | Volver de código optimizado a uno observable                | **Sí, y es la más valiosa**: es la base para observar o depurar código optimizado ([06](06-ejecucion-pedagogica-y-app.md)) |
| Reemplazo en pila (OSR)                                     | Optimizar un bucle que ya está corriendo                    | Solo si hay JIT                                                                                                       |
| JIT por trazas                                              | Bucles calientes en código dinámico                        | Poco: el beneficio en código estático es menor y el comportamiento es menos predecible                                |

**Lo que no se transfiere y además cuesta:**

- **Calentamiento impredecible.** Barrett et al. (OOPSLA 2017) mostraron que, incluso en
  micro-pruebas deterministas, muchas combinaciones VM-prueba no alcanzan un estado estable.
  Contradice F-04 de [04](04-filosofia-y-modelo-del-lenguaje.md) en lo que respecta a tiempos
  observables por quien aprende.
- **Plataformas que prohíben generar código.** **[HECHO EXTERNO]** En iOS y iPadOS, las apps de
  terceros no pueden crear páginas de memoria ejecutables en tiempo de ejecución; desde 2024 Apple solo
  lo permite a motores de navegador alternativos en la UE mediante BrowserEngineKit. La app actual se
  distribuye en iOS: **una JIT no puede ser el motor pedagógico allí.**
- **Memoria y seguridad.** Una JIT añade memoria de código, páginas escribibles y ejecutables
  alternadas, y superficie de ataque.

**Conclusión [INFERENCIA].** Para un lenguaje estático con AOT disponible, una JIT no es el camino
principal al rendimiento. Queda como opción tardía para dos usos acotados: un modo interactivo de
escritorio (REPL, recarga en caliente) y la especialización por perfil (que la compilación guiada por
perfil, PGO, también ofrece en AOT). Una JIT base por *copy-and-patch* (Xu y Kjolstad, OOPSLA 2021) es la
variante de menor coste si algún experimento la justifica.

### 3.5 Determinismo numérico por objetivo

**[COMPROBADO]** El núcleo usa `BigInt` para garantizar el mismo rango de 64 bits en nativo, JavaScript
y Wasm (H-16). **[INFERENCIA]** El coste existe solo porque JavaScript carece de enteros de 64 bits:
en nativo y en Wasm (`i64`) el entero de 64 bits con comprobación de desbordamiento es una instrucción
más una rama. La propuesta es **elegir la representación por objetivo** sin cambiar la semántica: entero
nativo comprobado en nativo y en Wasm, `BigInt` (o pares de 32 bits) solo en JavaScript. La paridad se
verifica ejecutando el corpus de conformidad en los tres objetivos ([E-04](16-experimentos-y-benchmarks.md#e-04),
[E-17](16-experimentos-y-benchmarks.md#e-17)), no solo compilando (H-27).

---

## 4. Lenguaje de implementación del compilador y del runtime

**[INFERENCIA]** Todo backend nativo necesita un **runtime**: recolector de memoria, representación de
cadenas y colecciones, E/S, arranque. Ese runtime se escribe en un lenguaje de sistemas (C, Rust, Zig,
C++) o se toma prestado de un anfitrión que ya lo tiene (Go, Dart, JVM, .NET, Wasm GC). La idea de
«una sola cadena de herramientas» deja de existir en cuanto se compila a nativo con runtime propio.

| Lenguaje               | A favor                                                                                                   | En contra                                                                                                   |
|------------------------|-----------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| **Dart** (actual)      | Una cadena con la app; reutiliza el núcleo; AOT nativo; Wasm; el equipo lo domina                          | Sin bindings maduros a LLVM o Cranelift; el runtime nativo habría que escribirlo en otro lenguaje igualmente |
| **Rust**               | Cranelift nativo; ecosistema de compiladores (salsa, rowan, rust-analyzer como referencia); runtime seguro | Cadena nueva en el monorepo; integración con Flutter por FFI; curva de aprendizaje                           |
| **Go**                 | Compila rápido; runtime y recolector maduros si se traduce a Go                                            | Sin LLVM ni Cranelift nativos; generar código máquina propio es costoso                                     |
| **Zig**                | Interoperación C trivial; `zig cc` como compilador de C portable                                          | Lenguaje aún pre-1.0; ecosistema pequeño                                                                     |
| **C / C++**            | LLVM nativo; máximo control                                                                              | Seguridad de memoria del propio compilador (la misma razón por la que la industria se aleja, CISA 2023)     |
| **OCaml**              | Tradición en compiladores                                                                                | Ajeno al equipo y al monorepo                                                                               |
| **PseudoLearn** (autoalojado) | Demostración de propósito general; la comunidad contribuye en su lenguaje                           | Solo posible cuando el lenguaje esté maduro; requiere arranque (*bootstrap*)                                 |

Decisión en [D-05](17-riesgos-preguntas-y-decisiones.md#d-05); arquitecturas completas en
[13](13-arquitecturas-candidatas.md).

---

## 5. Backends nativos candidatos

| Backend                         | Tiempo hasta un primer binario | Techo de rendimiento | Coste de compilación | Dependencias para el usuario       | Control semántico | Depuración                  |
|---------------------------------|--------------------------------|----------------------|----------------------|------------------------------------|-------------------|-----------------------------|
| Traducción a C + runtime propio | Corto                          | Alto                 | El del compilador C  | Un compilador de C (o `zig cc` empaquetado) | Total (cuidando comportamiento indefinido de C) | `#line`, DWARF del compilador C |
| Traducción a Go                 | Muy corto                      | El de Go             | Rápido               | Cadena de Go                        | Medio (sin desbordamiento nativo; herencia emulada) | La de Go |
| LLVM IR + runtime propio        | Largo                          | Máximo               | Lento en optimizado  | Ninguna (enlazado estático de LLVM ≈ cientos de MB en el compilador) | Total | DWARF |
| Cranelift + runtime propio      | Medio                          | Alto (por debajo de LLVM) | Rápido          | Ninguna                             | Total             | DWARF parcial               |
| Wasm (+ Wasm GC)                | Medio                          | Alto en el navegador; AOT con Wasmtime | Rápido | Un motor Wasm                     | Alto              | Limitada                    |
| Backend propio a código máquina | Muy largo                      | Alto con mucho trabajo | Rápido             | Ninguna                             | Total             | DWARF propio                |

**[INFERENCIA]** La traducción a C o a Go permite medir el **techo semántico** (cuánto cuesta la
semántica de PseudoLearn: desbordamiento comprobado, cadenas por punto de código, recolector) antes de
invertir en un backend propio. Por eso el primer experimento de rendimiento no construye un backend:
traduce a mano un subconjunto de Are We Fast Yet a C y a Go con la semántica de PseudoLearn y lo
compara con Rust y Go idiomáticos ([E-02](16-experimentos-y-benchmarks.md#e-02)). Si el techo
semántico ya supera N2, ningún backend lo arreglará y lo que hay que revisar es la semántica.

---

## 6. Recomendación (propuesta)

1. **No elegir backend todavía.** Primero E-01 (arnés y línea base institucionalizados) y E-02 (techo
   semántico).
2. **Separar el front-end del motor** con una **representación intermedia tipada (RI) especificada
   como contrato** ([11](11-especificaciones-ejecutables-diseno.md)). El front-end (análisis, tipos,
   diagnósticos) es uno; los motores consumen la RI.
3. **Dos motores con una semántica** ([06](06-ejecucion-pedagogica-y-app.md)): una VM observable para
   la app, la web e iOS, y un compilador AOT para ejecutar programas. El intérprete de tareas actual se
   conserva como **oráculo de referencia** hasta que la VM pase la conformidad.
4. **Primer backend nativo por traducción** (a C o a Go según E-05), con la RI diseñada para poder pasar
   después a Cranelift o LLVM sin cambiar el front-end.
5. **Sin JIT** en la hoja de ruta inicial.
6. **Representación numérica por objetivo**, verificada por conformidad diferencial.

**Qué me haría cambiar de opinión:**

- Si E-02 muestra que la semántica vigente impide N2 (por ejemplo, cadenas por punto de código o
  comprobaciones), la discusión pasa a la semántica, no al backend.
- Si E-03 muestra que una VM en Dart no alcanza N1 en dispositivos modestos, el intérprete de la app
  debería escribirse en un lenguaje de sistemas y llamarse por FFI.
- Si la comunidad objetivo valora más el arranque inmediato y el modo interactivo que el rendimiento
  máximo, una JIT de escritorio subiría en prioridad.
- Si el equipo no puede sostener una segunda cadena de herramientas, la traducción a Go (que delega
  recolector y concurrencia) gana a la traducción a C.

---

## 7. Compilador, herramientas y latencia de interacción

**[COMPROBADO]** El análisis completo cuesta ≈12,7 ms a 1 000 líneas y ≈50 ms a 5 000, con el lexer
como etapa dominante y sin incrementalidad (H-21). Con 60 Hz de refresco, el presupuesto por
pulsación es de ≈16 ms.

Objetivos propuestos (hipótesis, a validar con E-08):

| Medida                                                      | Objetivo propuesto                       |
|-------------------------------------------------------------|------------------------------------------|
| Respuesta del servidor de lenguaje por pulsación (p95)      | ≤ 16 ms en archivos de 10 000 líneas     |
| Autocompletado (p95)                                        | ≤ 50 ms                                  |
| Análisis completo de un paquete de 100 000 líneas           | ≤ 2 s en frío; incremental en el resto  |
| Arranque de un ejecutable «hola mundo»                      | ≤ 20 ms                                  |
| Latencia por paso observado en la app                       | ≤ 1 ms con instantánea incremental       |

Técnicas: análisis incremental por consultas (salsa en rust-analyzer), árbol sin pérdida reutilizable
(rowan, árboles rojo-verde de Roslyn), lexer incremental, caché de resultados por módulo. Detalle en
[07](07-herramientas-y-autocompletado.md).

## 8. Plataformas

| Plataforma        | Ejecutar programas (producción) | Observar en la app        | Restricción relevante                                         |
|-------------------|----------------------------------|---------------------------|---------------------------------------------------------------|
| macOS arm64       | AOT nativo                       | VM observable              | —                                                             |
| Linux x86-64/arm64 | AOT nativo                      | (sin app hoy)              | —                                                             |
| Windows x86-64    | AOT nativo                       | VM observable              | Firma de binarios (pendiente declarado en la app)             |
| iOS / iPadOS      | No aplica (no se compila allí)   | VM observable              | Sin generación de código en ejecución                         |
| Android           | No aplica                        | VM observable              | Sin app hoy                                                   |
| Web               | Wasm                             | VM observable en Wasm      | Sin enteros de 64 bits en JavaScript; Wasm 3.0 los da y añade GC |
