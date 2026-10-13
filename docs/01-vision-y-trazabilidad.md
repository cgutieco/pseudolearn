# 01 · Visión organizada y matriz de trazabilidad

> **Estado:** investigación, no normativo. Organiza la visión expresada por la persona responsable del
> proyecto el 2026-10-13 y traza cada exigencia hasta el lugar de esta documentación que la responde.
> Nada de lo aquí escrito está aprobado.

---

## 1. La visión en una frase y sus cinco tensiones

**Visión.** PseudoLearn pasa de ser un lenguaje didáctico con su entorno de aprendizaje a ser un
lenguaje de propósito general, bilingüe, con una comunidad que programa en español, sin abandonar la
forma de pseudocódigo con la que la gente aprendió algoritmos, y con una implementación que aspira a
la precisión, la seguridad y el rendimiento de Rust o Go y a la coherencia orientada a objetos de
Dart, gobernada por especificaciones ejecutables y versionadas.

La investigación encontró que la visión no es una lista de características sino un sistema con cinco
tensiones internas. Cada documento las retoma; aquí solo se nombran:

| Tensión                                   | Polo A                                                           | Polo B                                                                      | Dónde se trabaja |
|-------------------------------------------|------------------------------------------------------------------|-----------------------------------------------------------------------------|------------------|
| **T1 · Puente o destino**                 | El lenguaje prepara para el siguiente (criterio vigente de desempate) | El lenguaje es el destino: no hay «siguiente»                               | [04](04-filosofia-y-modelo-del-lenguaje.md), [C-01](17-riesgos-preguntas-y-decisiones.md#c-01) |
| **T2 · Verbosidad legible o expresividad** | Palabras completas, cierres explícitos, una forma por concepto   | Construcciones de propósito general (genéricos, closures, módulos, errores) | [03](03-identidad-bilingue-y-gramatica.md), [04](04-filosofia-y-modelo-del-lenguaje.md) |
| **T3 · Observar o correr**                | Cada paso visible, determinista, explicable                      | Optimización agresiva que reordena, elimina y fusiona                       | [05](05-rendimiento-motor-y-compilacion.md), [06](06-ejecucion-pedagogica-y-app.md) |
| **T4 · Una lengua o dos comunidades**     | Bilingüismo como identidad                                       | Riesgo de fragmentar bibliotecas, ejemplos y ayuda                          | [03](03-identidad-bilingue-y-gramatica.md) |
| **T5 · Contrato o documentación**         | Especificaciones como base verificable                           | `README.md` como fuente de verdad vigente (`DOC-README-TRUTH`)               | [10](10-especificaciones-ejecutables-fundamentos.md)–[12](12-especificaciones-ejecutables-ejemplos.md), [C-03](17-riesgos-preguntas-y-decisiones.md#c-03) |

---

## 2. Clasificación epistémica de lo expresado

La visión mezcla exigencias, preferencias e hipótesis. Confundirlas es la forma más rápida de
confirmar intuiciones sin evidencia (lo que la propia visión prohíbe). La clasificación es una
lectura de esta investigación y puede corregirse.

### 2.1 Exigencias (V-xx)

Se numeran siguiendo el orden del encargo. Una exigencia es algo que la visión pide que exista o que
se investigue.

**Visión general**

- **V-01** Convertir PseudoLearn en un lenguaje de propósito general.
- **V-02** Comunidad especialmente orientada a quienes programan en español.
- **V-03** Conservar el origen pedagógico como parte esencial de la identidad.
- **V-04** Continuidad: quien aprendió pseudocódigo puede construir software real sin abandonar su
  forma de expresar algoritmos.
- **V-05** Aspirar a precisión, seguridad y rendimiento comparables a Rust o Go.
- **V-06** Aspirar a una orientación a objetos tan coherente y agradable como la de Dart.
- **V-07** Tratar Rust, Go y Dart como aspiraciones: investigar qué aprender, qué diferencias importan
  y qué combinaciones son viables, sin copiar arquitecturas.

**Sintaxis e identidad bilingüe**

- **V-08** Conservar la sencillez y el estilo del pseudocódigo vigente, en español y en inglés.
- **V-09** Aceptar más verbosidad que Dart, priorizando legibilidad y naturalidad en español.
- **V-10** Gramática precisa y comportamiento inequívoco.
- **V-11** Construcciones futuras en el estilo existente; lo no implementado no está excluido.
- **V-12** Investigar coherencia entre idiomas, ambigüedades, vocabulario, identificadores,
  diagnósticos y evolución de la gramática.
- **V-13** No suponer un estándar universal de pseudocódigo; separar convenciones externas de
  decisiones propias.

**Filosofía y modelo**

- **V-14** Una filosofía base para decidir qué pertenece al lenguaje y cómo se comporta.
- **V-15** Investigar modelo de objetos, sistema de tipos y características de propósito general:
  clases, interfaces, closures y sus interacciones, más lo que la investigación justifique.
- **V-16** Para cada propuesta: problema que resuelve, costes, consecuencias pedagógicas, encaje.
- **V-17** Evitar deuda de compatibilidad; gobernar cambios, deprecaciones, versiones y migraciones
  sin prometer anticipar el futuro.

**Rendimiento, motor y compilación**

- **V-18** Compilar programas a código nativo con rendimiento comparable a Rust o Go en escenarios
  definidos y medibles.
- **V-19** Investigar estrategias sin presuponer AOT, JIT, interpretación, VM, backend ni lenguaje de
  implementación.
- **V-20** Evaluar la JIT de JavaScript como idea, separando lo transferible.
- **V-21** Separar: rendimiento de programas; rendimiento y recursos del compilador y herramientas;
  latencia de arranque e interacción; costes de memoria, depuración e instrumentación; diferencias
  entre plataformas y cargas.
- **V-22** Definir qué significa cumplir la aspiración y cómo comprobarlo con benchmarks
  reproducibles, sin inventar resultados.
- **V-23** Distinguir compilar a nativo el motor anfitrión de compilar a nativo los programas.

**Ejecución pedagógica e integración**

- **V-24** Soporte directo del lenguaje en la app, incluida la ejecución paso a paso.
- **V-25** Coexistencia de alto rendimiento, depuración y observación pedagógica.
- **V-26** Conservar el significado al optimizar y verificar coherencia entre formas de ejecución.
- **V-27** Inspección de variables, objetos, referencias, llamadas y memoria; visualizaciones
  existentes.
- **V-28** Definir qué es un «paso» cuando el compilador transforma el programa.
- **V-29** Comparar motor único y motores separados por sus consecuencias.

**Autocompletado y herramientas**

- **V-30** Autocompletado eficaz, contextual y fiable que compense la verbosidad.
- **V-31** Detectar cierres, palabras clave posibles y construcciones pertinentes, en español e inglés.
- **V-32** Repartir responsabilidades entre lenguaje, motor de análisis, protocolos y editores,
  incluido el código incompleto o incorrecto.
- **V-33** Integración con VS Code, la familia IntelliJ y otros entornos; compartir capacidades con la
  app; separar lo estandarizable de lo específico.
- **V-34** No confundir autocompletado determinista con sugerencias de IA.

**Monorepos, módulos e imports**

- **V-35** Soporte nativo y sencillo para monorepos.
- **V-36** Aliases de rutas con comodidad comparable a `paths` de TypeScript.
- **V-37** Separar lo que resuelve el lenguaje de lo que resuelve su ecosistema: módulos, paquetes,
  dependencias, resolución, compilación, distribución, coherencia entre editores.
- **V-38** Aclarar «evitar el tree shaking»: interpretaciones, consecuencias, tensiones; sin
  descartarlo ni sustituirlo en silencio.
- **V-39** No suponer que aliases, monorepos y tree shaking son el mismo problema.

**Gestión de memoria**

- **V-40** Un modelo fácil de aprender, pensar y usar, sin renunciar a rendimiento ambicioso.
- **V-41** Estudiar Go y Rust sin tomar valoraciones personales como conclusiones.
- **V-42** Investigar modelos, garantías y compromisos, y sus efectos sobre objetos, closures, ciclos,
  concurrencia, interoperabilidad y observación pedagógica.
- **V-43** Considerar tecnologías existentes e innovaciones; toda propuesta nueva con problema, evidencia
  faltante y experimentos.
- **V-44** No elegir por popularidad ni por promesas abstractas de velocidad.

**Especificaciones ejecutables**

- **V-45** Un sistema de especificaciones ejecutables, estructuradas y versionadas que gobierne el
  lenguaje y la app.
- **V-46** Contratos precisos y comprobables; no solo documentación, tests ni prompts.
- **V-47** Poder especificar closures, clases, interfaces, memoria, motor y comportamientos de la app,
  interconectados o independientes.
- **V-48** Definir qué significa que una especificación sea ejecutable.
- **V-49** Definir «el código ejecuta las especificaciones» y «los tests ejecutan las especificaciones».
- **V-50** Expresar reglas, invariantes, precondiciones, resultados, errores y casos límite.
- **V-51** Normalizar la estructura y comprobar la validez.
- **V-52** Identificar y versionar cada especificación.
- **V-53** Declarar dependencias y anclar versiones.
- **V-54** Detectar cambios y advertir a especificaciones y consumidores afectados.
- **V-55** Distinguir cambios compatibles, incompatibles y que requieren revisión.
- **V-56** Conectar especificaciones, implementación, pruebas y documentación.
- **V-57** Evitar que implementación y pruebas compartan un error que aparente conformidad.
- **V-58** Representar comportamientos propuestos sin confundirlos con contratos aprobados.
- **V-59** Delimitar qué garantías se comprueban y cuáles quedan fuera.
- **V-60** Evaluar enfoques existentes, incluido SDD; justificar un sistema propio si se propone.
- **V-61** Decidir si corresponde un paquete independiente, sus responsabilidades, y cómo evitar
  dependencias circulares y fuentes duplicadas.
- **V-62** Especificaciones como base arquitectónica verificable del ecosistema.
- **V-63** Analizar la evolución del contrato «el `README.md` es la fuente de verdad», sin cambiar las
  reglas vigentes ni declarar resuelta la transición.

**Método y entrega**

- **V-64** Inspeccionar el repositorio (documentación, implementación y pruebas) antes de recomendar.
- **V-65** Distinguir lo implementado y comprobado, lo documentado sin comprobar, las exigencias, las
  preferencias, las hipótesis y las decisiones pendientes.
- **V-66** Registrar las exclusiones vigentes como antecedentes, sin implementar ni modificar contratos.
- **V-67** Fuentes primarias con enlaces, fechas y límites; hechos separados de inferencias.
- **V-68** Para cada decisión importante: alternativas, ventajas, costes, riesgos, madurez y evidencia;
  recomendaciones con las condiciones que harían cambiar de opinión.
- **V-69** Documentar ambigüedades con interpretaciones y seguir; reportar conflictos según las reglas
  del repositorio.
- **V-70** Markdown en español en `docs/`, con índice y enlaces relativos, sin repetir contenido.
- **V-71** Contenido mínimo: visión y trazabilidad, diagnóstico, investigación comparativa,
  arquitecturas candidatas, recomendaciones, especificaciones en profundidad, ejemplos marcados como
  propuesta, estrategia de evolución, hoja de ruta con dependencias y criterios de aceptación,
  experimentos y benchmarks, riesgos y decisiones, fuentes.
- **V-72** No confirmar intuiciones automáticamente; no entregar solo un resumen ni rellenar.
- **V-73** Libertad para proponer cambios en la arquitectura del monorepo.
- **V-74** Usar las skills de arquitectura y documentación como apoyo, sin forzar el formato ADR y sin
  presentar recomendaciones como decisiones aprobadas.

### 2.2 Preferencias y referencias personales (P-xx)

Son legítimas como motivación y no se tratan como evidencia.

| ID   | Preferencia o referencia                                             | Cómo se trata                                                                 |
|------|----------------------------------------------------------------------|-------------------------------------------------------------------------------|
| P-01 | Rust y Go como referencias de rendimiento y seguridad                | Se convierten en una definición medible ([05](05-rendimiento-motor-y-compilacion.md)) |
| P-02 | Dart como referencia de orientación a objetos agradable              | Se descompone en rasgos concretos y se evalúa cada uno ([04](04-filosofia-y-modelo-del-lenguaje.md)) |
| P-03 | La JIT de JavaScript como idea                                       | Se separan técnicas transferibles de las que resuelven otro problema ([05](05-rendimiento-motor-y-compilacion.md)) |
| P-04 | `paths` de TypeScript como medida de comodidad                       | Se toma la comodidad y se rechaza su incoherencia entre herramientas ([08](08-modulos-paquetes-y-monorepos.md)) |
| P-05 | Valoraciones personales de la memoria en Go y Rust                   | Se contrastan con evidencia de aprendibilidad y rendimiento ([09](09-gestion-de-memoria.md)) |
| P-06 | SDD como candidato para las especificaciones                         | Se evalúa con las herramientas reales de 2025 ([10](10-especificaciones-ejecutables-fundamentos.md)) |
| P-07 | El deseo de «evitar el tree shaking»                                 | Se tratan seis interpretaciones ([08](08-modulos-paquetes-y-monorepos.md))   |
| P-08 | VS Code y la familia IntelliJ como entornos nombrados                | Se trabajan junto a los demás vía protocolos ([07](07-herramientas-y-autocompletado.md)) |

### 2.3 Hipótesis implícitas en la visión (HIP-xx)

Cada una tiene en algún documento la evidencia disponible y el experimento que la resolvería.

| ID     | Hipótesis                                                                                  | Evidencia hoy                                                                                     | Se trabaja en |
|--------|--------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|---------------|
| HIP-01 | Un mismo lenguaje sirve a quien aprende y a software real sin bifurcarse                   | Parcial: Python y Hedy (gradual) muestran caminos; ningún caso de pseudocódigo                    | [04](04-filosofia-y-modelo-del-lenguaje.md) |
| HIP-02 | El autocompletado compensa la verbosidad                                                   | Plausible, no medida para pseudocódigo                                                            | [07](07-herramientas-y-autocompletado.md), [E-09](16-experimentos-y-benchmarks.md#e-09) |
| HIP-03 | Programar en la lengua materna facilita aprender y adoptar                                 | A favor para aprender en bloques (Scratch, Dasgupta y Hill 2017); barreras documentadas (Guo 2018); adopción profesional sin evidencia | [03](03-identidad-bilingue-y-gramatica.md) |
| HIP-04 | Un lenguaje bilingüe sostiene una sola comunidad                                           | Mixta: 1C:Enterprise lo sostiene; AppleScript abandonó sus dialectos                             | [03](03-identidad-bilingue-y-gramatica.md) |
| HIP-05 | La semántica pedagógica (desbordamiento comprobado, cadenas por punto de código, sin nulo) admite rendimiento tipo Rust o Go | Desconocida; medible                                                                              | [E-02](16-experimentos-y-benchmarks.md#e-02) |
| HIP-06 | El paso a paso y el alto rendimiento pueden compartir semántica                            | Precedentes de desoptimización (Self, 1992) y depuración de código optimizado                     | [06](06-ejecucion-pedagogica-y-app.md) |
| HIP-07 | Especificaciones ejecutables reducen la interpretación arbitraria y la deuda               | A favor: SpecTec (Wasm), JEST (ECMAScript); el diagnóstico muestra el coste de no tenerlas (H-02 a H-07) | [10](10-especificaciones-ejecutables-fundamentos.md) |
| HIP-08 | El estilo de pseudocódigo escala a módulos, genéricos, closures y concurrencia sin perder legibilidad | Sin evidencia; requiere propuestas concretas y prueba con personas                                | [03](03-identidad-bilingue-y-gramatica.md), [E-14](16-experimentos-y-benchmarks.md#e-14) |

---

## 3. Ambigüedades e interpretaciones adoptadas

La regla del encargo es documentar la ambigüedad y seguir con el análisis que no dependa de ella.

| ID   | Expresión                                    | Interpretaciones posibles                                                                                                  | Interpretación de trabajo                                                                                      | Decide |
|------|----------------------------------------------|----------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------|--------|
| A-01 | «Propósito general»                           | (a) cualquier dominio, incluidos sistemas y embebidos; (b) aplicaciones, servicios, herramientas y bibliotecas; (c) scripting | (b) para la primera versión; (a) queda como horizonte que no condiciona decisiones tempranas                     | [D-03](17-riesgos-preguntas-y-decisiones.md#d-03) |
| A-02 | «Comparable a Rust o Go»                      | Rust y Go no rinden igual entre sí; puede significar «como el más lento de los dos», «entre ambos» o «como Rust»             | Una banda definida por cargas y factores, con niveles ([05](05-rendimiento-motor-y-compilacion.md))           | [D-07](17-riesgos-preguntas-y-decisiones.md#d-07) |
| A-03 | «Precisión»                                   | Precisión numérica; precisión semántica (sin ambigüedad); exactitud diagnóstica                                             | Las tres, separadas                                                                                             | —      |
| A-04 | «Seguridad»                                   | Seguridad de memoria; de tipos; ausencia de carreras de datos; seguridad de la cadena de suministro                        | Las cuatro, con garantías declaradas por separado ([04](04-filosofia-y-modelo-del-lenguaje.md), [08](08-modulos-paquetes-y-monorepos.md), [09](09-gestion-de-memoria.md)) | —      |
| A-05 | «Orientación a objetos coherente como Dart»  | Todo es objeto; interfaces implícitas; mixins; modificadores de clase; constructores con nombre; seguridad ante nulos       | Rasgos evaluados uno a uno; no se adopta el paquete entero                                                     | [D-16](17-riesgos-preguntas-y-decisiones.md#d-16) |
| A-06 | «Comunidad»                                   | Usuarios de la app; programadores que publican bibliotecas; contribuidores al compilador                                    | Las tres, con requisitos distintos de licencia y herramientas                                                  | [D-01](17-riesgos-preguntas-y-decisiones.md#d-01) |
| A-07 | «Soporte nativo de monorepos»                 | En la sintaxis del lenguaje; en el gestor de paquetes; en el compilador                                                    | En el manifiesto y el resolutor, compartidos por compilador, editores y app ([08](08-modulos-paquetes-y-monorepos.md)) | [D-19](17-riesgos-preguntas-y-decisiones.md#d-19) |
| A-08 | «Evitar el tree shaking»                      | Seis lecturas ([08](08-modulos-paquetes-y-monorepos.md))                                                                    | Ninguna adoptada: requiere respuesta                                                                           | [D-08](17-riesgos-preguntas-y-decisiones.md#d-08) |
| A-09 | «Especificaciones que gobiernen la aplicación» | Comportamientos observables; también diseño visual y textos                                                                | Comportamientos observables y contratos con el núcleo; el diseño visual sigue en su fuente actual               | [D-09](17-riesgos-preguntas-y-decisiones.md#d-09) |
| A-10 | «Completamente versionadas»                   | Versión por corpus; por especificación; por regla                                                                           | Por especificación, con identidad estable por regla ([11](11-especificaciones-ejecutables-diseno.md))        | —      |
| A-11 | «Bilingüe»                                    | Dos perfiles cerrados; mezcla dentro de un archivo; mezcla entre paquetes                                                   | Un perfil por archivo, mezcla entre módulos y paquetes ([03](03-identidad-bilingue-y-gramatica.md))           | [D-21](17-riesgos-preguntas-y-decisiones.md#d-21) |

---

## 4. Matriz de trazabilidad

Columnas: **Dónde** (documento y sección principal), **Tipo de respuesta** (D = diagnóstico,
I = investigación comparativa, P = propuesta, E = experimento, X = decisión pendiente),
**Estado** (Cubierta: la investigación da respuesta completa dentro de su alcance; Condicionada: la
respuesta depende de un experimento o decisión).

| Exigencia | Dónde                                                                                                     | Tipo     | Estado                      |
|-----------|-----------------------------------------------------------------------------------------------------------|----------|-----------------------------|
| V-01      | [04](04-filosofia-y-modelo-del-lenguaje.md) §1–3; [13](13-arquitecturas-candidatas.md)                    | I, P, X  | Condicionada a D-02, D-03   |
| V-02      | [03](03-identidad-bilingue-y-gramatica.md) §1–2; [17](17-riesgos-preguntas-y-decisiones.md) D-01          | I, X     | Condicionada a D-01         |
| V-03      | [04](04-filosofia-y-modelo-del-lenguaje.md) §1; [06](06-ejecucion-pedagogica-y-app.md)                    | P        | Cubierta                    |
| V-04      | [04](04-filosofia-y-modelo-del-lenguaje.md) §1.3 (niveles de lenguaje); [03](03-identidad-bilingue-y-gramatica.md) §6 | P, E | Condicionada a E-14  |
| V-05      | [05](05-rendimiento-motor-y-compilacion.md); [09](09-gestion-de-memoria.md); [04](04-filosofia-y-modelo-del-lenguaje.md) §4 | I, P, E | Condicionada a E-02, D-07 |
| V-06      | [04](04-filosofia-y-modelo-del-lenguaje.md) §3                                                            | I, P, X  | Condicionada a D-16         |
| V-07      | Transversal; tablas «qué se toma / qué se rechaza» en 03, 04, 05, 08, 09                                   | I        | Cubierta                    |
| V-08      | [03](03-identidad-bilingue-y-gramatica.md) §3, §7                                                         | P        | Cubierta                    |
| V-09      | [03](03-identidad-bilingue-y-gramatica.md) §3; [07](07-herramientas-y-autocompletado.md)                  | P        | Cubierta                    |
| V-10      | [03](03-identidad-bilingue-y-gramatica.md) §5 (gramática formal); [10](10-especificaciones-ejecutables-fundamentos.md) | P | Cubierta              |
| V-11      | [03](03-identidad-bilingue-y-gramatica.md) §7 (propuestas de forma); [04](04-filosofia-y-modelo-del-lenguaje.md) | P | Cubierta                  |
| V-12      | [03](03-identidad-bilingue-y-gramatica.md) §2–6                                                           | D, I, P  | Condicionada a D-13, D-14, D-21 |
| V-13      | [03](03-identidad-bilingue-y-gramatica.md) §1                                                             | I        | Cubierta                    |
| V-14      | [04](04-filosofia-y-modelo-del-lenguaje.md) §1                                                            | P        | Condicionada a D-02         |
| V-15      | [04](04-filosofia-y-modelo-del-lenguaje.md) §3–4                                                          | I, P     | Condicionada a D-12, D-15, D-16 |
| V-16      | [04](04-filosofia-y-modelo-del-lenguaje.md) §4 (ficha por característica)                                 | I        | Cubierta                    |
| V-17      | [04](04-filosofia-y-modelo-del-lenguaje.md) §5; [11](11-especificaciones-ejecutables-diseno.md) §6        | I, P, X  | Condicionada a D-11         |
| V-18      | [05](05-rendimiento-motor-y-compilacion.md) §4–6                                                          | I, P, E  | Condicionada a E-02, E-05   |
| V-19      | [05](05-rendimiento-motor-y-compilacion.md) §3                                                            | I        | Cubierta                    |
| V-20      | [05](05-rendimiento-motor-y-compilacion.md) §3.4                                                          | I        | Cubierta                    |
| V-21      | [05](05-rendimiento-motor-y-compilacion.md) §1                                                            | I, P     | Cubierta                    |
| V-22      | [05](05-rendimiento-motor-y-compilacion.md) §2; [16](16-experimentos-y-benchmarks.md) §2                  | P, E     | Condicionada a D-07         |
| V-23      | [05](05-rendimiento-motor-y-compilacion.md) §1.1; [02](02-diagnostico-del-sistema-actual.md) §3.4         | D, I     | Cubierta                    |
| V-24      | [06](06-ejecucion-pedagogica-y-app.md) §5                                                                 | P        | Cubierta                    |
| V-25      | [06](06-ejecucion-pedagogica-y-app.md) §3–4                                                               | I, P     | Condicionada a E-07         |
| V-26      | [06](06-ejecucion-pedagogica-y-app.md) §4; [10](10-especificaciones-ejecutables-fundamentos.md) §5        | P, E     | Condicionada a E-17         |
| V-27      | [06](06-ejecucion-pedagogica-y-app.md) §2; [02](02-diagnostico-del-sistema-actual.md) H-10                | D, P     | Cubierta                    |
| V-28      | [06](06-ejecucion-pedagogica-y-app.md) §1                                                                 | P, X     | Condicionada a D-18         |
| V-29      | [06](06-ejecucion-pedagogica-y-app.md) §3; [13](13-arquitecturas-candidatas.md)                           | I        | Cubierta                    |
| V-30      | [07](07-herramientas-y-autocompletado.md) §4                                                              | D, P, E  | Condicionada a E-09         |
| V-31      | [07](07-herramientas-y-autocompletado.md) §4.2                                                            | P        | Cubierta                    |
| V-32      | [07](07-herramientas-y-autocompletado.md) §2–3                                                            | I, P     | Cubierta                    |
| V-33      | [07](07-herramientas-y-autocompletado.md) §5                                                              | I, P     | Cubierta                    |
| V-34      | [07](07-herramientas-y-autocompletado.md) §6                                                              | P        | Cubierta                    |
| V-35      | [08](08-modulos-paquetes-y-monorepos.md) §4                                                               | I, P     | Condicionada a D-19         |
| V-36      | [08](08-modulos-paquetes-y-monorepos.md) §5                                                               | I, P     | Condicionada a D-19         |
| V-37      | [08](08-modulos-paquetes-y-monorepos.md) §1–3                                                             | I        | Cubierta                    |
| V-38      | [08](08-modulos-paquetes-y-monorepos.md) §6                                                               | I, X     | Condicionada a D-08         |
| V-39      | [08](08-modulos-paquetes-y-monorepos.md) §1                                                               | I        | Cubierta                    |
| V-40      | [09](09-gestion-de-memoria.md) §1, §5                                                                     | I, P     | Condicionada a D-04         |
| V-41      | [09](09-gestion-de-memoria.md) §3.1–3.3                                                                   | I        | Cubierta                    |
| V-42      | [09](09-gestion-de-memoria.md) §4                                                                         | I        | Cubierta                    |
| V-43      | [09](09-gestion-de-memoria.md) §6                                                                         | P, E     | Condicionada a E-11, E-12, E-13 |
| V-44      | [09](09-gestion-de-memoria.md) §2 (criterios)                                                             | I        | Cubierta                    |
| V-45      | [11](11-especificaciones-ejecutables-diseno.md)                                                           | P        | Condicionada a D-09, D-10   |
| V-46      | [10](10-especificaciones-ejecutables-fundamentos.md) §1–2                                                 | I        | Cubierta                    |
| V-47      | [12](12-especificaciones-ejecutables-ejemplos.md)                                                         | P        | Cubierta                    |
| V-48      | [10](10-especificaciones-ejecutables-fundamentos.md) §2                                                   | P        | Cubierta                    |
| V-49      | [10](10-especificaciones-ejecutables-fundamentos.md) §3                                                   | P        | Cubierta                    |
| V-50      | [11](11-especificaciones-ejecutables-diseno.md) §3                                                        | P        | Cubierta                    |
| V-51      | [11](11-especificaciones-ejecutables-diseno.md) §4                                                        | P        | Cubierta                    |
| V-52      | [11](11-especificaciones-ejecutables-diseno.md) §5                                                        | P        | Condicionada a D-20         |
| V-53      | [11](11-especificaciones-ejecutables-diseno.md) §7                                                        | P        | Cubierta                    |
| V-54      | [11](11-especificaciones-ejecutables-diseno.md) §8                                                        | P        | Cubierta                    |
| V-55      | [11](11-especificaciones-ejecutables-diseno.md) §6                                                        | P        | Cubierta                    |
| V-56      | [11](11-especificaciones-ejecutables-diseno.md) §9                                                        | P        | Cubierta                    |
| V-57      | [10](10-especificaciones-ejecutables-fundamentos.md) §5; [11](11-especificaciones-ejecutables-diseno.md) §10 | I, P  | Cubierta                    |
| V-58      | [11](11-especificaciones-ejecutables-diseno.md) §2                                                        | P        | Cubierta                    |
| V-59      | [10](10-especificaciones-ejecutables-fundamentos.md) §6                                                   | I        | Cubierta                    |
| V-60      | [10](10-especificaciones-ejecutables-fundamentos.md) §4                                                   | I        | Cubierta                    |
| V-61      | [11](11-especificaciones-ejecutables-diseno.md) §11                                                       | P, X     | Condicionada a D-10         |
| V-62      | [11](11-especificaciones-ejecutables-diseno.md) §12; [13](13-arquitecturas-candidatas.md)                 | P        | Condicionada a D-09         |
| V-63      | [11](11-especificaciones-ejecutables-diseno.md) §13; [17](17-riesgos-preguntas-y-decisiones.md) C-02, C-03 | I, X    | Condicionada a D-09         |
| V-64      | [02](02-diagnostico-del-sistema-actual.md); [anexo A](anexos/A-experimentos-reproducibles.md)             | D        | Cubierta                    |
| V-65      | Etiquetas de [convenciones](README.md#convenciones-de-lectura), aplicadas en todos los documentos          | —        | Cubierta                    |
| V-66      | [02](02-diagnostico-del-sistema-actual.md) §7                                                             | D        | Cubierta                    |
| V-67      | [18](18-fuentes.md)                                                                                       | I        | Cubierta                    |
| V-68      | Tablas de alternativas en 03–09, 13; [14](14-recomendaciones.md)                                          | I, P     | Cubierta                    |
| V-69      | §3 de este documento; [17](17-riesgos-preguntas-y-decisiones.md) §1                                       | X        | Cubierta                    |
| V-70      | [Índice](README.md)                                                                                       | —        | Cubierta                    |
| V-71      | Índice y documentos 01–18                                                                                  | —        | Cubierta                    |
| V-72      | Hipótesis HIP-xx y su evidencia; [14](14-recomendaciones.md) «qué me haría cambiar de opinión»              | —        | Cubierta                    |
| V-73      | [13](13-arquitecturas-candidatas.md) §5 (disposición del monorepo)                                         | P        | Condicionada a D-05, D-10   |
| V-74      | Estado «propuesta» en cada documento; decisiones solo en [17](17-riesgos-preguntas-y-decisiones.md)        | —        | Cubierta                    |

**Lectura de la matriz.** Ninguna exigencia queda sin lugar. 26 de 74 dependen de una decisión o de un
experimento: esa es la medida honesta de lo que esta investigación no puede cerrar sola.
