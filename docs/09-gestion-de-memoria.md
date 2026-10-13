# 09 · Gestión de memoria

> **Estado:** investigación, no normativo. La recomendación es una **propuesta** sujeta a
> [D-04](17-riesgos-preguntas-y-decisiones.md#d-04) y a los experimentos E-11 a E-13. Las cifras
> externas proceden de sus autores y no se han reproducido.

Responde a V-40 a V-44.

---

## 1. De qué parte la decisión

La visión expresa valoraciones personales sobre Go y Rust (P-05). Se tratan como motivación; la
decisión parte de lo que **ya es el lenguaje**, comprobado en el código:

| Hecho comprobado                                                                                   | Fuente                                                     |
|----------------------------------------------------------------------------------------------------|------------------------------------------------------------|
| Los objetos son referencias; asignar o pasar un objeto comparte la instancia (aliasing enseñado)    | §11.8 de la especificación; tests `oop_aliasing_*`         |
| Se pueden formar **ciclos** de referencias y el programa es válido (H-35)                           | Sonda I del anexo A                                         |
| Los arreglos no son valores: siempre se pasan por referencia y no se asignan enteros                 | §9.1 y §10.3 de la especificación                          |
| No hay nulo; una variable de clase empieza «sin instanciar»                                         | §11.5 de la especificación                                 |
| No hay destructores ni finalizadores; nada observa cuándo deja de existir un objeto                  | Ausencia en la especificación y en el núcleo               |
| No hay concurrencia                                                                                 | `README.md` del núcleo §3.5                                |
| La identidad de objeto es visible (`Clase#id`) y se enseña                                          | `README.md` del núcleo §6.4; traza de la app               |

**[INFERENCIA]** Estos hechos ya descartan o encarecen varios modelos antes de discutir rendimiento:
cualquier modelo que rechace el aliasing libre de objetos mutables, o que cambie el significado de
asignar un objeto, rompe programas válidos y la pedagogía central del lenguaje.

---

## 2. Criterios de evaluación

| Criterio                         | Qué se pregunta                                                                                     |
|----------------------------------|-----------------------------------------------------------------------------------------------------|
| Garantía de seguridad            | ¿Imposibilita uso tras liberación, doble liberación, lectura no inicializada?                        |
| Aprendibilidad                   | ¿Qué evidencia hay de lo que cuesta aprenderlo?                                                    |
| Expresividad                     | ¿Admite grafos, ciclos, referencias hacia atrás, observadores?                                     |
| Rendimiento                      | Rendimiento sostenido, pausas, memoria adicional                                                    |
| Destrucción determinista         | ¿Se sabe cuándo se libera un recurso (archivo, conexión)?                                           |
| Closures                         | ¿Qué pasa con entornos capturados que sobreviven a su marco?                                        |
| Concurrencia                     | ¿Coste en presencia de hilos? ¿Ayuda a evitar carreras?                                            |
| Interoperabilidad                | ¿Cómo convive con C y con otros runtimes (FFI, punteros estables)?                                  |
| Observación pedagógica           | ¿Qué se puede mostrar en la traza y la máquina nocional?                                           |
| Portabilidad                     | Nativo, Wasm (con y sin Wasm GC), app                                                               |
| Compatibilidad                   | ¿Conserva el significado de los programas válidos hoy?                                              |
| Coste de implementación          | Trabajo y riesgo para un equipo pequeño                                                             |

---

## 3. Modelos

### 3.1 Recolección por trazado

- **Go.** Recolector concurrente, sin movimiento, marcado tricolor y barrido; el *pacer* ajusta el ciclo;
  `GOGC` y, desde Go 1.19, `GOMEMLIMIT`. **[HECHO EXTERNO]** Go 1.26 activa por omisión el recolector
  «Green Tea», experimental en 1.25, con una reducción estimada del 10 % al 40 % del coste de recolección
  en programas que lo usan intensamente (notas de versión de Go 1.26).
- **JVM y .NET.** Generacionales y con movimiento (G1, ZGC, Shenandoah), con pausas de sub-milisegundo
  en las variantes concurrentes, a cambio de barreras y memoria adicional.
- **Investigación.** Immix (Blackburn y McKinley, PLDI 2008) organiza el montón en regiones y líneas,
  combinando marcado y copia oportunista. LXR (Zhao, Blackburn y McKinley, PLDI 2022) usa **conteo de
  referencias dentro de un montón Immix** con trazado concurrente ocasional para ciclos, y en su
  evaluación supera a G1 y a Shenandoah en rendimiento y latencia de cola. MMTk ofrece estos
  recolectores como biblioteca para runtimes.
- **Garantías.** Seguridad de memoria; ciclos recogidos; sin destrucción determinista; memoria
  adicional típica para que el recolector tenga margen.

### 3.2 Conteo de referencias

- **Swift (ARC).** Destrucción inmediata y determinista de objetos acíclicos; los ciclos **se fugan**
  salvo referencias `weak`/`unowned` escritas a mano; coste de operaciones atómicas con hilos.
- **CPython.** Conteo más un recolector de ciclos.
- **Perceus** (Reinking, Xie, de Moura y Leijen, PLDI 2021). Inserción precisa de operaciones de conteo
  en Koka, con **reutilización** de memoria que permite actualización en el sitio («funcional pero en
  el sitio»); garantiza no retener basura **para programas sin ciclos**.
- **Lean 4** (Ullrich y de Moura, IFL 2019). Conteo con referencias prestadas y reutilización; el
  fragmento verificable no puede crear ciclos y el runtime no los detecta.
- **Nim (ORC)** combina conteo con un recolector de ciclos y permite marcar tipos como acíclicos para
  saltárselo.
- **Teoría.** Bacon, Cheng y Rajan (OOPSLA 2004) muestran que trazado y conteo son **duales** y que los
  recolectores optimizados de ambos tipos acaban siendo híbridos.

### 3.3 Propiedad y préstamos (Rust)

- **Garantías.** Seguridad de memoria y ausencia de carreras de datos sin recolector; destrucción
  determinista.
- **Coste de aprendizaje, con evidencia.** Crichton, Gray y Krishnamurthi (OOPSLA 2023, *SIGPLAN
  Research Highlight*) documentan que quienes aprenden Rust no logran conectar la semántica estática
  (el verificador de préstamos) con la dinámica (qué fallaría en ejecución); su nueva pedagogía mejora
  un 9 % de media su inventario de conocimientos. Es evidencia de que el modelo **se puede enseñar
  mejor**, y también de que es difícil.
- **Expresividad.** Grafos, ciclos y observadores exigen `Rc`/`RefCell`, arenas o índices.
- **Compatibilidad con PseudoLearn.** **Incompatible**: rechazaría programas válidos que comparten
  objetos mutables por dos nombres, que es justo lo que la app enseña.

### 3.4 Semántica de valores mutables (Swift, Hylo)

- **Idea** (Racordon et al., *Journal of Object Technology*, 2022). Las referencias son de segunda clase
  (solo en fronteras de función); no hay estado mutable compartido; razonamiento local; copia bajo
  demanda (*copy-on-write*) para contenedores.
- **Compatibilidad.** **Incompatible** como modelo único: asignar un objeto pasaría a copiarlo y el
  aliasing desaparecería. **Compatible y valiosa como segunda categoría** de tipos (`Registro`,
  [04](04-filosofia-y-modelo-del-lenguaje.md) §3.3).

### 3.5 Regiones y arenas

- MLKit (Tofte y Talpin, 1997) infiere regiones; Cyclone (Grossman et al., PLDI 2002) las expone con
  tipos. Las arenas son una técnica habitual en Rust, Zig y C.
- **Para PseudoLearn:** útiles como optimización interna (asignación por fase o por subprograma con
  análisis de escape), no como modelo que quien aprende tenga que manejar.

### 3.6 Referencias generacionales (Vale)

- **Idea.** Cada referencia recuerda la generación del objeto; al liberar, la generación cambia; cada
  desreferencia comprueba que coincida. El autor reporta un sobrecoste del 2 % al 10,84 % en una prueba
  de su propio lenguaje (no reproducido, una sola carga).
- **Compatibilidad.** Requiere un **dueño único** que decide cuándo liberar; una referencia que
  sobrevive detiene el programa al usarse. Cambia el significado de programas válidos con propiedad
  compartida. **Incompatible** como modelo único.

### 3.7 Propiedad opcional sobre memoria administrada

- Swift añade tipos no copiables (`~Copyable`, SE-0390) y parámetros `borrowing`/`consuming`
  (SE-0377) sobre ARC; Java trabaja en clases de valor (Valhalla); .NET tiene `Span` y `ref struct`.
- **Patrón:** un modelo sencillo por omisión y un subconjunto con más control para código crítico.
  Encaja con los niveles de [04](04-filosofia-y-modelo-del-lenguaje.md) §1.3, en sentido inverso: un
  nivel avanzado opcional.

### 3.8 Recolector del anfitrión

Si el backend traduce a Go, usa el recolector de Go; en la web, Wasm 3.0 (septiembre de 2025) incluye
recolección gestionada por el motor; la VM en Dart usa el de Dart. **[INFERENCIA]** Esto permite
**posponer** la implementación de un recolector propio sin posponer la decisión semántica.

---

## 4. Efectos sobre el resto del lenguaje

| Aspecto                    | Trazado                                         | Conteo (sin ciclos)                                  | Conteo + ciclos                         | Propiedad (Rust)                                  | Valores mutables                       |
|----------------------------|-------------------------------------------------|------------------------------------------------------|-----------------------------------------|---------------------------------------------------|----------------------------------------|
| Objetos con aliasing       | Natural                                         | Natural                                              | Natural                                 | Rechazado salvo `Rc<RefCell<…>>`                   | Desaparece                              |
| Ciclos (H-35)              | Recogidos                                       | **Fugas**                                            | Recogidos                               | Requieren técnicas explícitas                     | Imposibles por construcción             |
| Closures que capturan `Este` | Sin problema                                  | Ciclo objeto ↔ closure: fuga (por eso Swift tiene `[weak self]`) | Recogido                 | Reglas de captura y tiempos de vida               | Captura por copia                       |
| Concurrencia               | Recolector concurrente; carreras posibles sin otra disciplina | Conteo atómico costoso                  | Ídem                                    | Ausencia de carreras por tipos (`Send`, `Sync`)    | Ausencia de carreras por falta de compartición |
| Interoperabilidad con C    | Sencilla si no mueve objetos; con movimiento exige fijarlos | Sencilla                                  | Sencilla                                | Sencilla                                          | Sencilla                                |
| Destrucción determinista   | No (recursos con bloques explícitos)            | Sí                                                   | Sí para acíclicos                        | Sí                                                | Sí                                      |
| Observación pedagógica     | Alcanzabilidad visible (objetos «inalcanzables») | Contadores visibles                                  | Contadores y ciclos visibles             | Movimientos y préstamos visibles (rico, exigente)  | Copias visibles                         |
| Portabilidad               | Wasm GC, Go, Dart, runtime propio               | Runtime propio; Wasm lineal                          | Runtime propio                           | Runtime propio                                    | Runtime propio                          |
| Compatibilidad con hoy     | **Total**                                       | Semántica sí; memoria crece con ciclos               | **Total**                               | **No**                                            | **No**                                  |

---

## 5. Propuesta: memoria administrada con tipos valor

1. **Semántica.** La memoria es administrada; ningún programa puede observar cuándo se recupera un
   objeto (sin finalizadores; referencias débiles solo si su efecto es determinista o no existen).
   Esto mantiene F-04 y F-08: el resultado no depende del recolector.
2. **Dos categorías de datos.** `Clase` (referencia, aliasing, identidad) y `Registro` más primitivos y
   enumerados (valor, copia, sin identidad). Los valores no pasan por el recolector cuando no escapan.
3. **Recursos con liberación explícita y estructurada** (bloque del estilo de `using` en C# o `with` en
   Python, con forma de PseudoLearn), porque el recolector no es determinista.
4. **Implementación por etapas.** VM: recolector de Dart. Web: Wasm GC. Nativo: recolector del anfitrión
   si se traduce a Go; si el runtime es propio, empezar por un recolector preciso **sin movimiento**
   (simplifica interoperabilidad y observación), y evaluar un diseño tipo Immix o LXR solo si E-12 lo
   justifica.
5. **Optimizaciones previstas:** análisis de escape para asignar en pila, arreglos de valores planos,
   eliminación de comprobaciones redundantes.
6. **Propiedad opcional en el horizonte**, evaluada con E-13, nunca por omisión.

**Qué me haría cambiar de opinión:**

- Si E-11 muestra que los programas reales casi nunca forman ciclos y que el conteo con reutilización
  (tipo Perceus) rinde claramente mejor, un híbrido conteo + recolector de ciclos (como Nim ORC) sería
  preferible por su liberación inmediata.
- Si la comunidad objetivo incluye sistemas sin recolector (A-01 amplio), la propiedad dejaría de ser
  opcional en ese subconjunto.
- Si E-13 muestra que una visualización de propiedad hace el modelo de Rust aprendible para el perfil
  de quien usa PseudoLearn, la balanza pedagógica cambiaría.

---

## 6. Innovaciones posibles

Cada propuesta declara el problema que resuelve, la evidencia que falta y el experimento que la
validaría o refutaría.

| ID   | Propuesta                                                                                                                                | Problema que resuelve mejor                                                           | Evidencia que falta                                                                                     | Experimento |
|------|------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|-------------|
| IN-1 | **Memoria como parte de la máquina nocional:** la traza muestra alcanzabilidad; un objeto que pierde su última referencia aparece como inalcanzable antes de desaparecer | La recolección es invisible para quien aprende y las fugas lógicas (retener sin querer) no se entienden | Si ver la alcanzabilidad mejora la comprensión del aliasing y de las fugas                               | [E-13](16-experimentos-y-benchmarks.md#e-13) |
| IN-2 | **Recolección en puntos deterministas en modo observación** (por ejemplo, al final de cada sentencia)                                     | La reproducción y la enseñanza necesitan que «cuándo desaparece» sea reproducible     | Coste del modo observado; si aporta algo frente a mostrar solo alcanzabilidad                            | [E-07](16-experimentos-y-benchmarks.md#e-07) |
| IN-3 | **Conteo o trazado elegido por tipo según acíclicidad demostrable:** si el grafo de tipos de campos no puede cerrar un ciclo, conteo con liberación inmediata; si puede, trazado | Liberación inmediata donde es segura y recolección de ciclos donde hace falta | Qué fracción de tipos reales es acíclica (Nim permite marcar tipos acíclicos a mano; aquí se deduciría) | [E-11](16-experimentos-y-benchmarks.md#e-11), [E-12](16-experimentos-y-benchmarks.md#e-12) |
| IN-4 | **Contrato de memoria especificado y ejecutable:** reglas como «ningún programa observa la recolección» o «un registro se copia al asignar» con casos de conformidad | La deriva entre motores en lo que respecta a identidad y copia                        | Ninguna técnica; es aplicación del sistema de especificaciones                                           | [E-15](16-experimentos-y-benchmarks.md#e-15) |

IN-1 e IN-3 son **hipótesis**; IN-2 es barata si se adopta la reproducción determinista
([06](06-ejecucion-pedagogica-y-app.md) §3.2); IN-4 es la aplicación directa de
[11](11-especificaciones-ejecutables-diseno.md) (ejemplo en [12](12-especificaciones-ejecutables-ejemplos.md)).
