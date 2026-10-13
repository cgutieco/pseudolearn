# 06 · Ejecución pedagógica, observación e integración con la app

> **Estado:** investigación, no normativo. La definición de «paso observable» y el contrato de
> observación son **propuestas** que requieren decisión ([D-18](17-riesgos-preguntas-y-decisiones.md#d-18)).

Responde a V-24 a V-29 y retoma los hallazgos H-10, H-12 y H-14 del
[diagnóstico](02-diagnostico-del-sistema-actual.md).

---

## 1. Qué es un «paso»

### 1.1 Hoy

**[COMPROBADO]** Hay tres nociones de paso mezcladas:

1. El **micro-paso** del núcleo: una tarea de la máquina (`Interpreter.step()`); evaluar `a + b` son
   varios. Es un detalle de implementación: cambia si se reorganiza el intérprete.
2. El **paso didáctico** de la app: avanzar hasta que cambie el foco de sentencia o la profundidad de
   bloque (`StepSettlement`), construido **encima** de los micro-pasos.
3. El **tope de seguridad**, contado en micro-pasos (10 000), es decir, en una unidad que no significa
   nada para quien programa.

**[INFERENCIA]** Si mañana el núcleo se reescribe como VM de bytecode, la unidad (1) desaparece, el
tope (3) cambia de significado y la app (2) solo sigue funcionando si los eventos que la alimentan se
conservan. Lo que la app necesita no es el micro-paso: son los **eventos observables**.

### 1.2 Propuesta: el paso observable como contrato del lenguaje

Se define, en la especificación, un **alfabeto de eventos observables** ligado a construcciones del
texto fuente, no al motor:

| Evento observable                       | Se produce                                                     | Lleva                                                        |
|-----------------------------------------|----------------------------------------------------------------|--------------------------------------------------------------|
| Entrada a sentencia                     | Antes de ejecutar cualquier sentencia                          | Identidad del nodo, estado observable                        |
| Salida de sentencia                     | Al completarse la sentencia                                    | Identidad del nodo, estado observable                        |
| Decisión                                | Al evaluar la condición de `Si`, `Mientras`, `Hasta Que`, `Segun`, `Para` | Rama tomada                                       |
| Llamada y retorno                       | Al entrar y salir de un subprograma, método, constructor o closure | Callee, argumentos ligados, valor devuelto              |
| Salida y entrada de datos               | En `Escribir` y en `Leer`                                      | Texto                                                        |
| Contrato comprobado (propuesto, [04](04-filosofia-y-modelo-del-lenguaje.md) §4.13) | Al evaluar `Requiere` o `Asegura` | Resultado                                                |
| Fallo                                   | Al detenerse por un defecto del programa                       | Diagnóstico                                                  |

Un **paso observable** es el intervalo entre dos eventos consecutivos de este alfabeto. La app define
sus ritmos (siguiente sentencia, saltar bloque, salir de bloque, hasta el final) **sobre eventos**, y
los límites de seguridad en unidades con sentido (sentencias ejecutadas, tiempo, memoria). Esto ya
coincide casi con los eventos actuales del núcleo; la propuesta es **elevarlos de API a contrato
especificado y versionado**, de modo que cualquier motor (intérprete actual, VM nueva, reproductor) se
pruebe contra él.

**Qué no es observable** (y por tanto puede cambiar sin romper nada, F-11 de
[04](04-filosofia-y-modelo-del-lenguaje.md)): el número de micro-pasos, el orden interno de evaluación
de subexpresiones **sin efectos** (las que tienen efectos ya tienen orden normativo, §6.5 y §10.6 de
la especificación), el momento en que se libera memoria, el coste de cada paso.

### 1.3 «Paso» cuando el compilador transforma el programa

Un compilador optimizante fusiona sentencias, mueve cálculos fuera de bucles, elimina variables y
mantiene valores en registros. La literatura de depuración de código optimizado (Hennessy, 1982; Adl-
Tabatabai y Gross, 1996) describe los síntomas: variables «no actuales», sentencias que no tienen un
punto propio en el código máquina, órdenes aparentes distintos.

**Posición propuesta:** en código optimizado **no hay pasos**. El contrato que el compilador cumple es
el de la regla «como si» (*as-if*) respecto de los eventos **externos** (salida, entrada, fallos,
terminación). Los pasos existen solo donde se observa, y para observar hay tres vías (§3). Esta
separación evita prometer que el binario optimizado sea paso a paso, cosa que ningún lenguaje de
alto rendimiento promete.

---

## 2. Qué se debe poder inspeccionar

### 2.1 La máquina nocional de PseudoLearn como especificación

Sorva (TOCE 2013), a partir de du Boulay (1986), llama **máquina nocional** al modelo idealizado del
ordenador que un lenguaje presenta a quien aprende. Python Tutor (Guo, SIGCSE 2013) la hizo visible
con marcos y objetos. **[INFERENCIA]** La máquina nocional de PseudoLearn existe hoy implícita en la
app y en las instantáneas del núcleo, con huecos (arreglos invisibles, objetos como referencias vivas).
Se propone **especificarla** como el **modelo de estado observable**: es a la vez el contrato de
observación de los motores y el objeto de enseñanza.

Contenido mínimo del estado observable:

| Elemento                     | Hoy                                          | Propuesta                                                                                           |
|------------------------------|----------------------------------------------|-----------------------------------------------------------------------------------------------------|
| Pila de llamadas             | Marcos con nombre y receptor                  | Igual, con argumentos ligados y marca de los parámetros por referencia (alias de qué celda)          |
| Variables escalares          | Sí                                            | Igual; estado «sin valor» explícito (ya existe)                                                     |
| Arreglos                     | **No** (H-10)                                 | Sí, como objetos del montón con identidad, dimensiones y celdas                                      |
| Objetos                      | Identidad; campos solo del receptor           | Grafo de objetos alcanzables desde los marcos, con identidad estable y campos                        |
| Referencias y aliasing       | Identidad `Clase#id`                          | Aristas del grafo; dos nombres que apuntan al mismo objeto se ven como dos flechas al mismo nodo     |
| Closures (propuesto)         | —                                            | Objeto función con su entorno capturado visible                                                      |
| Memoria                      | —                                            | Objetos inalcanzables marcados como tales hasta que el modelo de memoria los retire ([09](09-gestion-de-memoria.md)) |
| Valores formateados          | `toString()` de Dart en la traza (H-25)      | Una sola función de representación, la de §7.1 de la especificación, para salida, traza y diagramas  |

**Propiedad clave:** una instantánea es un **valor inmutable**. La de hoy referencia objetos vivos
(H-10): sirve para el paso actual y falla en cuanto se quiere historia, comparación entre pasos o
retroceso.

### 2.2 Coste de observar

**[COMPROBADO]** Construir la instantánea completa en cada evento cuesta de 1,3× a 4,6× (crece con la
profundidad de pila). **Propuesta:** instantáneas **incrementales** (cada evento lleva solo lo que
cambió; el estado se reconstruye acumulando), con instantáneas completas periódicas como puntos de
control. El contrato especifica el estado reconstruido, no la forma de transmitirlo. Se mide con
[E-06](16-experimentos-y-benchmarks.md#e-06).

---

## 3. Uno o varios motores

### 3.1 Opciones

| Opción | Descripción                                                                                       | Semántica (riesgo de divergencia) | Mantenimiento     | Velocidad sin observar | Experiencia de aprendizaje                      | Viable en iOS |
|--------|---------------------------------------------------------------------------------------------------|-----------------------------------|-------------------|------------------------|-------------------------------------------------|---------------|
| O1     | **Un motor interpretado** (lo actual, mejorado)                                                   | Ninguno                           | Bajo              | Baja                   | Excelente                                       | Sí            |
| O2     | **Un compilador con modo depuración** (como C o Rust: `-O0` y depurador)                          | Bajo                              | Medio             | Alta                   | Media: los pasos dependen del modo              | **No** (habría que compilar fuera del dispositivo) |
| O3     | **Dos motores, una semántica**: VM observable + compilador AOT, verificados contra la misma especificación | Medio, mitigado por conformidad diferencial | Alto | Alta                   | Excelente en la VM                              | Sí (la VM)    |
| O4     | **Un motor escalonado** que desoptimiza al observar (JIT, Self 1992)                              | Bajo                              | Muy alto          | Alta                   | Excelente                                       | **No** (requiere JIT) |
| O5     | **Ejecutar rápido y reproducir** de forma determinista en el motor observable                     | Medio (como O3)                   | Medio             | Alta                   | Excelente, y permite **ir hacia atrás**         | Sí            |
| O6     | **Intérprete de referencia generado de la especificación** (como SpecTec para Wasm)               | Lo reduce: tercer oráculo independiente | Alto al inicio | Baja                 | No es para la app; es para verificar             | —             |

### 3.2 La oportunidad del determinismo (O5)

**[COMPROBADO]** El núcleo es determinista: sin reloj, con aleatoriedad sembrada, sin concurrencia, con
la entrada como único dato externo (`provideInput`). **[INFERENCIA]** Con esa propiedad, una ejecución
queda determinada por el programa, la semilla y la secuencia de entradas. Un programa ejecutado en el
motor rápido puede **grabar solo eso** y el motor observable puede **reproducir exactamente** cualquier
tramo, con puntos de control para no reejecutar desde el principio. Es la técnica de los depuradores
de grabación y reproducción (rr; O'Callahan et al., USENIX ATC 2017), pero mucho más barata porque las
fuentes de no determinismo ya están acotadas por diseño. Consecuencias:

- Observar deja de tener que coincidir con ejecutar: se corre a velocidad nativa y se inspecciona
  donde haga falta.
- La **ejecución hacia atrás**, excluida hoy en la app (§1.3), se vuelve barata: retroceder es
  reproducir hasta el paso anterior desde el punto de control más cercano.
- **Condición:** toda fuente nueva de no determinismo (tiempo, concurrencia, E/S de archivos o red)
  tiene que pasar por una frontera grabable. Es una restricción de diseño de la biblioteca estándar y
  del modelo de concurrencia (F-08 de [04](04-filosofia-y-modelo-del-lenguaje.md)).

Se valida con [E-07](16-experimentos-y-benchmarks.md#e-07).

### 3.3 Recomendación

**O3 + O5, con O1 como oráculo**: una VM observable (sucesora del intérprete de tareas) para la app,
la web e iOS; un compilador AOT para ejecutar programas; reproducción determinista como puente entre
ambos; y el intérprete actual conservado como **oráculo de referencia** en la conformidad hasta que la
VM lo iguale. O6 queda como horizonte de investigación si la divergencia entre motores resulta ser el
riesgo dominante.

**Qué me haría cambiar de opinión:** que E-03 muestre que la VM observable rinde lo suficiente para
todos los usos (entonces O1 mejorado basta y el AOT puede esperar), o que la conformidad diferencial
encuentre divergencias persistentes entre motores (entonces un único motor escalonado sin JIT, con el
AOT generando código instrumentable, merece reevaluarse).

---

## 4. Conservar el significado y comprobar coherencia

### 4.1 La relación que debe conservarse

- **Sin observar:** misma secuencia de eventos externos (salidas, entradas pedidas, fallos con su
  código y tramo, terminación) para cada entrada.
- **Observando:** misma secuencia de eventos observables y mismos estados observables reconstruidos.
- **Entre perfiles:** un programa traducido de español a inglés produce la **misma traza** salvo los
  lexemas (relación metamórfica propia de PseudoLearn; los tests de paridad vigentes ya la comprueban
  en parte).

### 4.2 Cómo se comprueba

| Técnica                                             | Origen                                                    | Aplicación a PseudoLearn                                                                     |
|-----------------------------------------------------|-----------------------------------------------------------|----------------------------------------------------------------------------------------------|
| Conformidad por casos de especificación             | test262 (ECMAScript), suite oficial de Wasm               | Cada regla con casos; se ejecutan en todos los motores ([11](11-especificaciones-ejecutables-diseno.md)) |
| Pruebas diferenciales entre implementaciones        | McKeeman (1998); JEST (Park et al., ICSE 2021)             | VM, AOT, intérprete de referencia y objetivos (nativo, JS, Wasm) sobre el mismo corpus       |
| Generación aleatoria de programas bien tipados      | Csmith (Yang et al., PLDI 2011)                           | El lenguaje es pequeño y tipado: un generador es factible y encuentra errores de los motores |
| Equivalencia módulo entradas (EMI)                  | Le, Afshari y Su (PLDI 2014)                              | Eliminar código no ejecutado para unas entradas no debe cambiar la salida                   |
| Relaciones metamórficas                             | Pruebas metamórficas                                      | Traducción entre perfiles; renombrado de variables; reordenación de declaraciones de nivel superior |
| Validación de la traducción                         | Pnueli, Siegel y Singerman (1998)                         | Horizonte para el compilador AOT                                                             |

### 4.3 El caso de la observación con optimización

Si en el futuro se quisiera observar código optimizado directamente (por ejemplo, perfiles de
rendimiento en programas reales), la técnica es la **desoptimización** en puntos de observación
(Hölzle, Chambers y Ungar, 1992): el código optimizado conserva metadatos para reconstruir el estado
observable en esos puntos. Requiere que el AOT emita esos metadatos (análogos a la información de
depuración DWARF). Se deja como horizonte; O5 cubre el caso pedagógico sin ese coste.

---

## 5. Integración con la app

### 5.1 Qué consume la app

| Capacidad                                | Hoy                                     | Propuesta                                                                                         |
|------------------------------------------|-----------------------------------------|---------------------------------------------------------------------------------------------------|
| Análisis y diagnósticos                  | `CoreProgramAnalyzer` sobre el núcleo   | Servicio de lenguaje compartido con los editores externos ([07](07-herramientas-y-autocompletado.md)) |
| Ejecución observada                      | Intérprete de tareas, micro-lotes       | VM observable con contrato de eventos; instantáneas incrementales                                  |
| Ejecución completa                       | El mismo intérprete, tope de 10 000 micro-pasos | VM en modo no observado, con límites en unidades con sentido (tiempo, sentencias, memoria) y posibilidad de reproducir para observar |
| Historia y retroceso                     | No                                      | Reproducción determinista desde puntos de control                                                  |
| Diagramas y traza                        | Proyecciones en `engine/`               | Igual, alimentadas por el estado observable especificado                                           |
| Código equivalente (Python, Rust)        | Emisores en `engine/export/`            | Se conserva como contraste pedagógico; no es el camino a nativo                                    |

### 5.2 Restricciones de la app que habría que revisar

- **Sin `Isolate`** (`README.md` de la app, §1.3): ejecutar programas largos sin observar en un isolate
  separado, transmitiendo salida, es la forma natural de quitar el tope sin bloquear la interfaz. Es
  una decisión de la app que esta investigación no toma.
- **Tope de 10 000 micro-pasos**: debería convertirse en un límite de recursos en unidades
  observables y depender del modo (observado o no).
- **Visualizaciones**: añadir arreglos, grafo de objetos, entornos de closures, módulos y tipos
  genéricos a medida que existan.

### 5.3 Qué gana la experiencia de aprendizaje

- Ejercicios con datos grandes (que hoy chocan con el tope) se ejecutan completos y luego se
  inspeccionan donde haga falta.
- La comparación «el mismo algoritmo en la máquina nocional y como programa real» se vuelve una
  actividad: la misma traza externa, dos motores.
- La ejecución hacia atrás deja de ser una exclusión por coste.
