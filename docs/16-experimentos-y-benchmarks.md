# 16 · Experimentos y benchmarks

> **Estado:** investigación, no normativo. Ningún experimento se ha ejecutado salvo las mediciones
> preliminares del [anexo A](anexos/A-experimentos-reproducibles.md). Cada experimento declara qué
> decisión informa y qué resultado la inclinaría en cada sentido.

Responde a V-22, V-43 y V-71 (experimentos y benchmarks necesarios para resolver incertidumbres).

---

## 1. Catálogo

Coste relativo: **B** (días), **M** (semanas), **A** (meses).

<a id="e-01"></a>

### E-01 · Arnés de rendimiento y línea base institucionalizados

- **Pregunta.** ¿Cuál es, con método estadístico, el rendimiento actual por familia de carga?
- **Método.** Convertir el arnés del anexo A en un paquete de benchmarks del monorepo (ubicación a
  decidir con [D-10](17-riesgos-preguntas-y-decisiones.md#d-10)), con el protocolo de §2 y los
  programas de Are We Fast Yet portados a PseudoLearn en lo que el lenguaje actual permita.
- **Métricas.** Tiempo por micro-paso, por iteración y por programa; memoria pico; coste de
  observación; tres objetivos (nativo, JS, Wasm).
- **Informa.** Línea N0 de [05](05-rendimiento-motor-y-compilacion.md) §2.2; todas las comparaciones
  posteriores.
- **Coste.** B.

<a id="e-02"></a>

### E-02 · Techo semántico

- **Pregunta.** ¿Cuánto cuesta la **semántica** de PseudoLearn (desbordamiento comprobado, índices
  comprobados, cadenas por punto de código, sin nulo, memoria administrada), con independencia de la
  calidad del compilador?
- **Hipótesis.** El coste semántico en cargas numéricas y de objetos es menor que 1,5× frente a Go
  idiomático; en cadenas puede ser mayor.
- **Método.** Traducir **a mano** un subconjunto de Are We Fast Yet a C (con recolector conservador o
  arenas) y a Go con la semántica de PseudoLearn; comparar con Rust y Go idiomáticos y con Rust con
  comprobación de desbordamiento activada.
- **Criterio.** Si el techo semántico supera N2 en alguna familia, se revisa la semántica de esa
  familia antes de invertir en backend.
- **Informa.** [D-07](17-riesgos-preguntas-y-decisiones.md#d-07), [D-06](17-riesgos-preguntas-y-decisiones.md#d-06),
  HIP-05.
- **Coste.** M.

<a id="e-03"></a>

### E-03 · VM de bytecode en Dart

- **Pregunta.** ¿Cuánto gana una VM de registros en Dart frente al intérprete de tareas, con y sin
  observación?
- **Método.** Prototipo para el subconjunto procedimental (sin objetos), enteros nativos donde el
  objetivo lo permita; misma suite que E-01; conformidad contra el intérprete actual.
- **Criterio.** Ganancia ≥ 10× sin observación y latencia por paso observado ≤ 1 ms en un dispositivo
  móvil modesto → la VM es viable como motor de la app. Si no, valorar VM en lenguaje de sistemas por FFI.
- **Informa.** [D-05](17-riesgos-preguntas-y-decisiones.md#d-05), [06](06-ejecucion-pedagogica-y-app.md) §3.3.
- **Coste.** M.

<a id="e-04"></a>

### E-04 · Representación de enteros por objetivo

- **Pregunta.** ¿Se puede conservar el determinismo de 64 bits usando enteros nativos en nativo y Wasm,
  y `BigInt` solo en JavaScript?
- **Método.** Variante de `PseudoInteger` con implementación por objetivo; corpus de bordes numéricos
  (desbordamiento, división truncada, potencia, módulo con negativos) ejecutado en los tres objetivos.
- **Criterio.** Paridad total del corpus y ganancia medible en nativo.
- **Informa.** [05](05-rendimiento-motor-y-compilacion.md) §3.5.
- **Coste.** B.

<a id="e-05"></a>

### E-05 · Primer backend: emisión de C frente a traducción a Go

- **Pregunta.** ¿Qué primer backend llega antes y mejor a N2?
- **Método.** Dos prototipos desde la misma RI mínima (subconjunto procedimental + objetos), medidos con
  la suite; tiempo de desarrollo registrado; tamaño de binario; tiempo de compilación; calidad de
  depuración.
- **Criterio.** Rendimiento dentro de N2 + coste de mantenimiento + experiencia de depuración.
- **Informa.** [D-06](17-riesgos-preguntas-y-decisiones.md#d-06).
- **Coste.** A.

<a id="e-06"></a>

### E-06 · Instantáneas incrementales

- **Pregunta.** ¿Cuánto reduce el coste de observación transmitir solo diferencias?
- **Método.** Implementar deltas en el núcleo actual detrás del contrato `ENG.TRACE.SNAPSHOT`; medir con
  la suite y con recursión profunda; verificar que el estado reconstruido es idéntico.
- **Criterio.** Coste de observación ≤ 1,3× en recursión profunda.
- **Coste.** B.

<a id="e-07"></a>

### E-07 · Reproducción determinista

- **Pregunta.** ¿Se puede ejecutar rápido, grabar solo semilla y entradas, y reproducir exactamente
  cualquier tramo en el motor observable?
- **Método.** Grabación en el intérprete sin observador; reproducción con observador desde puntos de
  control cada N sentencias; comparar trazas. Extensión: recolección en puntos deterministas (IN-2).
- **Métricas.** Tamaño de la grabación; tiempo de reposicionamiento a un paso arbitrario; igualdad de
  trazas.
- **Informa.** [06](06-ejecucion-pedagogica-y-app.md) §3.2; ejecución hacia atrás.
- **Coste.** M.

<a id="e-08"></a>

### E-08 · Front-end sin pérdida y viabilidad del reanálisis completo

- **Pregunta.** ¿Permite el front-end Rust de Clepsidra reanalizar por completo cada edición dentro
  del presupuesto de latencia del editor, conservando texto y diagnósticos?
- **Método.** Árbol postorden sin pérdida y análisis léxico, sintáctico y semántico completo, sin
  incrementalidad. Medir p50/p95 por edición reproducible en archivos de 1 000, 10 000 y 50 000 líneas,
  en español e inglés y con rigor estricto y flexible; incluir ediciones válidas e incompletas,
  posiciones al inicio, centro y final, Unicode y cambios de nombres con muchos usos. Registrar el
  coste por etapa, el total, los bytes, tokens, nodos y la memoria máxima muestreada. Las cargas se
  preparan fuera del intervalo y los resultados se validan después. Seguir `PERF.PROTOCOL` y publicar
  datos crudos y procedencia. El protocolo detallado está en el
  [plan de R4](plan-nucleo-rust/10-plan-r4-frontend.md).
- **Criterio.** p95 ≤ 16 ms de análisis completo por edición en 10 000 líneas en el hardware de
  referencia. Se informa por carga y configuración, sin ocultar los casos lentos en un agregado.
  `PERF.FRONTEND.THROUGHPUT` se mide por separado: su umbral no demuestra p95. Un incumplimiento
  refuta la hipótesis de reanálisis completo para esa carga y exige una decisión documentada para R7;
  no autoriza añadir incrementalidad ni cambiar umbrales en silencio. El experimento queda completo
  con resultados válidos aunque refute la hipótesis; los requisitos normativos de rendimiento siguen
  siendo exigibles según el corpus.
- **Informa.** Estrategia de incrementalidad e identidad entre ediciones de R7; no reabre la decisión
  Rust de ADR-001.
- **Coste.** M.

<a id="e-09"></a>

### E-09 · Calidad del autocompletado

- **Pregunta.** ¿Cuánto compensa el autocompletado la verbosidad (HIP-02)?
- **Método.** Corpus: ejemplos y soluciones de la base de conocimiento en ambos perfiles. Truncar cada
  programa en cada token; pedir candidatos; medir si el token real está entre los k primeros; simular
  pulsaciones con y sin autocompletado.
- **Métricas.** Precisión @1 y @5; ahorro de pulsaciones; validez de plantillas; latencia.
- **Coste.** B (con el servicio de lenguaje existente).

<a id="e-10"></a>

### E-10 · Presupuesto de palabras reservadas

- **Pregunta.** ¿Cuántos nombres reales retira cada palabra clave propuesta?
- **Método.** Corpus de identificadores: base de conocimiento, programas de estudiantes con
  consentimiento (si la app lo permite y la política de privacidad lo cubre), y repositorios públicos en
  español de otros lenguajes. Contar colisiones con la normalización de cada perfil.
- **Informa.** [D-13](17-riesgos-preguntas-y-decisiones.md#d-13); regla EST-09.
- **Coste.** B.

<a id="e-11"></a>

### E-11 · Ciclos y acíclicidad en programas reales

- **Pregunta.** ¿Con qué frecuencia forman ciclos los programas? ¿Qué fracción de tipos es acíclica por
  su grafo de campos?
- **Método.** Instrumentar el intérprete para detectar ciclos en el montón al final de cada ejecución;
  análisis estático del grafo de tipos sobre el corpus.
- **Informa.** [D-04](17-riesgos-preguntas-y-decisiones.md#d-04), IN-3.
- **Coste.** B.

<a id="e-12"></a>

### E-12 · Prototipos de gestión de memoria

- **Pregunta.** ¿Qué rinde mejor con la semántica de PseudoLearn: marcado y barrido sin movimiento, un
  diseño tipo Immix, o conteo con recolector de ciclos?
- **Método.** Tres variantes del runtime de E-02/E-05 sobre la suite; métricas de rendimiento, pausas y
  memoria pico.
- **Coste.** A.

<a id="e-13"></a>

### E-13 · Aprendibilidad de modelos y visualizaciones

- **Pregunta.** ¿Mejora la comprensión del aliasing, las closures y la memoria con las visualizaciones
  propuestas (alcanzabilidad, entornos capturados)? ¿Es aprendible un subconjunto de propiedad para el
  perfil de PseudoLearn?
- **Método.** Estudio con estudiantes (con consentimiento informado y revisión ética según la
  institución), instrumento inspirado en el *Ownership Inventory* de Crichton et al. (2023), grupos con y
  sin visualización.
- **Informa.** [D-04](17-riesgos-preguntas-y-decisiones.md#d-04), IN-1.
- **Coste.** A.

<a id="e-14"></a>

### E-14 · Localización y forma de las construcciones nuevas

- **Pregunta.** ¿Se leen mejor las formas propuestas (§8 de [03](03-identidad-bilingue-y-gramatica.md))
  que sus alternativas? ¿Ayuda el autocompletado translingüe? ¿Cómo afecta la mezcla de idiomas entre
  módulos?
- **Método.** Estudios de lectura y escritura con tareas cortas, a la manera de Stefik y Siebert
  (TOCE 2013); medir precisión y tiempo.
- **Informa.** HIP-03, HIP-08, [D-13](17-riesgos-preguntas-y-decisiones.md#d-13),
  [D-21](17-riesgos-preguntas-y-decisiones.md#d-21).
- **Coste.** M.

<a id="e-15"></a>

### E-15 · Producto mínimo del sistema de especificaciones

- **Pregunta.** ¿Encuentra el sistema defectos reales con un coste de autoría aceptable?
- **Método.** Migrar tres secciones de `language-spec.md` (estructuras de control, subprogramas,
  orientación a objetos) al formato de [11](11-especificaciones-ejecutables-diseno.md) con ejecutor
  contra el núcleo. Registrar tiempo de autoría por regla y defectos encontrados.
- **Criterio de éxito.** Detecta **sin buscarlos** al menos H-02, H-05, H-06, H-18 y H-37 (o sus
  equivalentes en las secciones migradas); tiempo medio de autoría por regla de minutos, no horas;
  falsos positivos del clasificador de cambios documentados.
- **Informa.** [D-09](17-riesgos-preguntas-y-decisiones.md#d-09), [D-10](17-riesgos-preguntas-y-decisiones.md#d-10).
- **Coste.** M.

<a id="e-16"></a>

### E-16 · Fortaleza de los casos frente a errores compartidos

- **Pregunta.** ¿Matan los casos de especificación a los mutantes del núcleo? ¿Hay reglas cuya
  alteración no detecta ningún caso?
- **Método.** Pruebas de mutación sobre `semantic/` y `evaluation/`; mutación del corpus (alterar
  reglas y valores esperados) y ejecución del ejecutor.
- **Métricas.** Puntuación de mutación; reglas no detectadas.
- **Coste.** M.

<a id="e-17"></a>

### E-17 · Paridad entre objetivos y motores

- **Pregunta.** ¿Se comportan igual nativo, JavaScript y Wasm (y, cuando existan, VM y AOT)?
- **Método.** Ejecutar el corpus de conformidad y programas generados aleatoriamente (bien tipados, a la
  manera de Csmith) en todos los objetivos; comparar salidas, diagnósticos y trazas. Variante EMI:
  eliminar código no ejecutado para unas entradas y comparar.
- **Informa.** H-27; política de independencia de oráculos.
- **Coste.** M.

<a id="e-18"></a>

### E-18 · Gramática formal y generación para editores

- **Pregunta.** ¿Puede la gramática formal generar gramáticas de tree-sitter por perfil equivalentes al
  parser de referencia?
- **Método.** Gramática formal del subconjunto actual; generación; comparación de árboles sobre el corpus
  y sobre programas truncados.
- **Coste.** M.

<a id="e-19"></a>

### E-19 · Eliminación de código y tamaño

- **Pregunta.** ¿Cuánto pesan, en tamaño y arranque, las interpretaciones TS-3 a TS-6 de «evitar el
  tree shaking»?
- **Método.** Con el primer backend, compilar programas típicos con y sin eliminación; medir tamaño de
  binario, tamaño de descarga web y arranque.
- **Informa.** [D-08](17-riesgos-preguntas-y-decisiones.md#d-08).
- **Coste.** B (una vez existe backend).

<a id="e-20"></a>

### E-20 · Arranque y latencia de la cadena de herramientas

- **Pregunta.** ¿Qué latencia tienen `pseudo ejecutar hola` y `pseudo compilar` por backend?
- **Método.** hyperfine en máquinas de referencia, frío y caliente.
- **Coste.** B.

<a id="e-21"></a>

### E-21 · Lenguaje del front-end

- **Pregunta.** Solo si E-08 falla: ¿cuánto rendiría el mismo front-end en un lenguaje de sistemas?
- **Método.** Prototipo del lexer y del parser en el lenguaje candidato; misma medición que E-08.
- **Coste.** M.

---

## 2. Protocolo de benchmarks reproducibles

### 2.1 Qué se mide y contra qué

| Familia                          | Programas                                                                            | Referencias                                                                 |
|----------------------------------|--------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| Programas (P, M)                 | Are We Fast Yet; subconjunto del Benchmarks Game; cargas del dominio                 | Go y Rust, en versión de misma semántica y en versión idiomática            |
| Compilador (C)                   | Paquetes sintéticos de 10³ a 10⁵ líneas; corpus real                                 | Versiones anteriores de la propia cadena                                    |
| Servicio de lenguaje (L)         | Trazas de edición grabadas (inserciones, borrados, pegados)                          | Versiones anteriores                                                        |
| App (L, O)                       | Programas de la base de conocimiento ejecutados paso a paso                          | Versiones anteriores; presupuesto de 16 ms por fotograma                    |
| Arranque y tamaño (L, B)         | «Hola mundo», CLI típica, servicio mínimo                                            | Go y Rust                                                                   |

### 2.2 Entorno

- Máquinas de referencia **declaradas** (modelo de CPU, memoria, sistema, versión del firmware cuando
  importe): como mínimo una macOS arm64, una Linux x86-64 y una Windows x86-64.
- Escalado de frecuencia y modos de ahorro desactivados o fijados; sin otras cargas; mismo usuario y
  mismas variables de entorno (Mytkowicz et al., ASPLOS 2009, mostraron que el tamaño del entorno y el
  orden de enlazado pueden sesgar resultados).
- Cadenas de herramientas **ancladas** por versión exacta; scripts de construcción versionados.

### 2.3 Medición

- **Varias invocaciones de proceso** (≥ 10) y **varias iteraciones dentro de cada proceso** (≥ 30 en
  cargas con calentamiento).
- **Detección de estado estable** por puntos de cambio (Barrett et al., OOPSLA 2017); si no se alcanza,
  se reporta así, no se descarta.
- Tiempo de pared y de CPU; memoria pico (RSS); para recolectores, pausas.

### 2.4 Estadística

- Intervalos de confianza al 95 % por prueba (Georges, Buytaert y Eeckhout, OOPSLA 2007; Kalibera y
  Jones, ISMM 2013 para el diseño de repeticiones).
- Media geométrica de cocientes por familia, con intervalo por remuestreo (*bootstrap*).
- Tamaño del efecto, no solo significación.

### 2.5 Publicación

- Todos los resultados crudos, incluidos los desfavorables y los que no alcanzan estado estable.
- Versión exacta de cada componente y de cada referencia.
- Las comparaciones de «misma semántica» y de «semántica nativa» siempre juntas.
- Ninguna afirmación del tipo «tan rápido como Rust» sin nivel, familia, plataforma e intervalo.

### 2.6 Amenazas a la validez

| Amenaza                                                             | Mitigación                                                           |
|---------------------------------------------------------------------|----------------------------------------------------------------------|
| Las referencias en Go o Rust están mal escritas                     | Revisión por alguien con experiencia en ese lenguaje; usar versiones publicadas de Are We Fast Yet cuando existan |
| Micro-pruebas que no representan programas reales                   | Cargas del dominio y programas reales del corpus                     |
| Optimización dirigida a la suite                                    | Suite congelada por versión; cargas nuevas añadidas sin aviso previo |
| Calentamiento y ruido                                               | §2.3                                                                 |
| Sesgos de entorno                                                   | §2.2                                                                 |
