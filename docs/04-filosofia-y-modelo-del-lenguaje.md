# 04 · Filosofía y modelo del lenguaje

> **Estado:** investigación, no normativo. Los principios, fichas y mecanismos de este documento son
> **propuestas**. Las decisiones que requieren aprobación se registran en
> [17](17-riesgos-preguntas-y-decisiones.md); la semántica vigente sigue siendo la de
> `language-spec.md`.

Responde a V-01, V-03 a V-06 y V-14 a V-17.

---

## 1. Filosofía base

### 1.1 Principios como preguntas verificables

`AGENTS.md` (§6) ya expresa los principios de ingeniería como preguntas. Se propone lo mismo para el
diseño del lenguaje: cada principio es una pregunta que una especificación nueva debe responder por
escrito. La columna «Origen» separa lo que ya rige (aunque implícito) de lo que se propone.

| ID   | Principio                                   | Pregunta que debe responder cada construcción nueva                                                                      | Origen                                                    |
|------|---------------------------------------------|--------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------|
| F-01 | **Sin fallo silencioso**                    | ¿Puede un error de quien programa convertirse en un programa que corre y da un resultado equivocado? Si sí, se rechaza o se diagnostica | Vigente: prueba del eje (§2.1), sin truncamiento implícito, desbordamiento detectado |
| F-02 | **Una forma por concepto**                  | ¿Introduce una segunda manera de expresar algo que ya tiene forma?                                                       | Vigente: §8.4, §10                                         |
| F-03 | **Explícito donde cambia estado o identidad** | ¿Queda a la vista quién crea un objeto, quién modifica qué y por qué camino?                                              | Vigente: `Nuevo`, `Este`, `Por Referencia`                |
| F-04 | **El significado no depende de cómo se ejecute** | ¿Puede cambiar el resultado observable entre intérprete, compilador, optimización u observación?                      | Vigente para objetivos (§12.2); propuesto para motores     |
| F-05 | **Lo que se enseña es lo que corre**        | ¿Existe una versión «didáctica» con otro significado? Solo se admiten subconjuntos (restricciones), nunca significados alternativos | Propuesto (generaliza el invariante del eje de rigor) |
| F-06 | **Fallas esperables como valores; fallos del programa como diagnóstico** | ¿Es un fallo que el programa debe manejar (entrada inválida) o un defecto (índice fuera de rango)? | Vigente en el núcleo (§5.5 del `README.md`); propuesto para el lenguaje |
| F-07 | **Coste visible**                           | ¿Esconde la construcción copias, asignaciones de memoria o esperas que quien programa no puede ver?                     | Propuesto                                                  |
| F-08 | **Determinismo por defecto**                | ¿Introduce no determinismo (tiempo, concurrencia, azar sin semilla)? Si sí, ¿está marcado en el tipo o en la API?         | Vigente en el núcleo (§6.5); propuesto para el lenguaje    |
| F-09 | **Bilingüe por construcción**               | ¿Depende algo del plano abstracto de un idioma?                                                                           | Vigente (§2.7)                                             |
| F-10 | **Evolución gobernada**                     | ¿Tiene especificación con estado, edición, clase de cambio y migración?                                                   | Propuesto (§5)                                             |
| F-11 | **Lo observable es contrato; lo demás no** | ¿Qué de esta construcción puede observar un programa, una traza o una herramienta? Solo eso se promete                    | Propuesto ([06](06-ejecucion-pedagogica-y-app.md))        |

### 1.2 Puente o destino: el criterio de desempate

**[COMPROBADO]** La skill `language-spec-authoring` fija como criterio de desempate «la que prepara
mejor para el lenguaje real… Este lenguaje existe para que el salto siguiente sea corto». Decisiones
vigentes como el límite de recursión de 1 000 (porque es el de Python) o la base cero se justifican con
ese criterio.

**[INFERENCIA]** Si PseudoLearn es el destino (V-04), el criterio pierde su referente: no hay «lenguaje
real» siguiente al que preparar. Mantenerlo produciría decisiones que imitan a otros lenguajes sin
razón propia. Se propone, para cuando la persona responsable decida
([D-02](17-riesgos-preguntas-y-decisiones.md#d-02), [C-01](17-riesgos-preguntas-y-decisiones.md#c-01)),
un orden de desempate:

1. F-01 (sin fallo silencioso).
2. Legibilidad para quien aprende, medida o argumentada con evidencia.
3. Coherencia con construcciones ya especificadas (EST-01 a EST-10 de [03](03-identidad-bilingue-y-gramatica.md)).
4. Familiaridad para quien llega de otros lenguajes (el criterio vigente, degradado a cuarto lugar).
5. Coste de implementación y rendimiento.

### 1.3 Niveles del lenguaje: continuidad sin bifurcación

La visión pide que quien aprendió pueda seguir sin abandonar su forma de expresar algoritmos (V-04),
y el riesgo es que el lenguaje completo abrume a quien empieza.

**Precedentes.** Hedy cambia la sintaxis entre niveles (por ejemplo, las comillas aparecen en un nivel
posterior), de modo que un programa de nivel 1 deja de ser válido en el nivel 3. Racket ofrece
«lenguajes de enseñanza» (`htdp/bsl`, `isl`, …) como subconjuntos con mejores mensajes. Pyret, también
de origen pedagógico, incorpora pruebas al lenguaje.

**Propuesta.** **Niveles como subconjuntos**, gobernados por el mismo invariante que el eje de rigor:
un nivel solo puede invalidar programas, nunca cambiar lo que calculan (F-05). Un ejercicio de la app
declara su nivel; el compilador profesional usa el nivel completo. El perfil de rigor y el nivel son
ejes distintos: el rigor exige disciplina (declarar, inicializar); el nivel restringe vocabulario y
construcciones (sin genéricos, sin closures). Ventaja frente a Hedy: todo programa de un nivel es un
programa válido del lenguaje completo, con el mismo significado; es la garantía de continuidad.

---

## 2. Qué significa «propósito general» (A-01)

Se propone medir «propósito general» por **lo que se puede construir**, no por la lista de
características. Escenarios de referencia para la primera versión (interpretación de trabajo, a
confirmar en [D-03](17-riesgos-preguntas-y-decisiones.md#d-03)):

| Escenario                                     | Capacidades que exige                                                                                      | Estado hoy |
|-----------------------------------------------|------------------------------------------------------------------------------------------------------------|------------|
| Herramienta de línea de órdenes              | Argumentos, archivos, salida de error, códigos de salida, cadenas Unicode, colecciones, errores tipados       | No         |
| Procesamiento de datos (CSV, JSON)           | Colecciones genéricas, registros, iteración, cadenas eficientes, biblioteca de formatos                      | No         |
| Biblioteca reutilizable                      | Módulos, visibilidad de módulo, paquetes, versiones, documentación                                          | No         |
| Servicio de red sencillo                     | E/S asíncrona o concurrencia, red, tiempo, errores                                                          | No         |
| Programa didáctico interactivo (actual)      | Lo que existe                                                                                               | Sí         |

Fuera de la primera versión: sistemas operativos, controladores, embebidos sin sistema operativo,
tiempo real estricto. No se excluyen del futuro; se excluyen de las decisiones tempranas para no
pagar su coste (por ejemplo, gestión manual de memoria) antes de tiempo.

---

## 3. Modelo de objetos

### 3.1 El modelo vigente

**[COMPROBADO]** Herencia simple; visibilidad pública o privada a la clase (la subclase no ve lo
privado); `Este` obligatorio; despacho dinámico siempre; `Super` estático; un único constructor
nombrado por token; sin nulo (variable «sin instanciar»); igualdad por identidad; `Copiar` superficial;
aliasing enseñado explícitamente.

### 3.2 Qué aporta Dart y qué se toma

La visión pide una orientación a objetos «tan coherente y agradable como la de Dart» (P-02). Se
descompone en rasgos:

| Rasgo de Dart                                         | Qué resuelve                                         | Para PseudoLearn                                                                                     |
|-------------------------------------------------------|------------------------------------------------------|------------------------------------------------------------------------------------------------------|
| Todo es un objeto (incluidos números)                 | Modelo uniforme                                      | **Se toma como modelo mental**, no como representación: un `Entero` responde a métodos, pero se compila como valor |
| Interfaz implícita de cada clase                      | Cualquier clase sirve de contrato                    | **Se rechaza**: confunde clase e interfaz a quien aprende; Dart necesitó modificadores (`interface`, `base`, `final`) para controlarlo |
| Mixins                                                | Reutilizar comportamiento sin herencia múltiple       | **Se pospone**: la composición y los métodos por defecto en interfaces cubren casi todo              |
| Modificadores de clase (`sealed`, `final`, `base`, `interface`) | Controlar extensión entre bibliotecas         | **Se toman dos**: `Sellada` (exhaustividad en `Segun`) y clases cerradas a extensión fuera del módulo |
| Constructores con nombre y `factory`                   | Varios modos de crear                                | **Alternativa**: subprogramas de módulo que crean (`NuevoCirculoUnitario()`), sin sobrecarga         |
| Seguridad ante nulos sólida (Dart 2.12, 2021)          | Eliminar el error de nulo                            | **Ya está**: no hay nulo; falta `Opcional De T` (H-34)                                               |
| Métodos de extensión                                  | Añadir métodos a tipos ajenos                        | **Se pospone**: ambigüedad de resolución para quien aprende                                          |
| Sistema de tipos sólido                               | Lo que el chequeo acepta no falla por tipo           | **Se toma** como requisito (ya se cumple)                                                            |

### 3.3 Propuestas sobre el modelo

1. **Clase (referencia) y Registro (valor).** Dos tipos de agregados con semántica de asignación
   distinta: la clase comparte (aliasing, lo que ya se enseña), el registro copia. Es la distinción de
   C# (`class`/`struct`) y Swift. Da al compilador valores sin asignación en el montón
   ([09](09-gestion-de-memoria.md)) y a la pedagogía un contraste explícito.
2. **Interfaces nominales explícitas** (`Interfaz`, `Implementa`), con métodos por defecto en un
   segundo paso. Decisión en [D-16](17-riesgos-preguntas-y-decisiones.md#d-16).
3. **Herencia simple conservada**; se añade `Sellada` para jerarquías cerradas con `Segun` exhaustivo.
4. **Marca de sobrescritura opcional con aviso.** La especificación vigente (§11.7) la rechaza. En
   propósito general, renombrar un método de la superclase rompe en silencio una sobrescritura
   (problema de la clase base frágil, Mikhajlov y Sekerinski, 1998). Se propone evaluar un aviso de
   clase C cuando falta la marca, sin volverla obligatoria (cambio compatible).
5. **Visibilidad de módulo** además de la de clase, para bibliotecas.
6. **Sin métodos estáticos**: su lugar lo ocupan subprogramas y constantes de módulo (exclusión vigente
   compatible).

---

## 4. Fichas de características

Cada ficha responde a V-16: problema, costes, pedagogía, encaje e interacciones. La recomendación no
es una decisión.

<a id="ambitos"></a>

### 4.1 Ámbitos de bloque

- **Problema.** Hoy una variable declarada en un `Si` o un `Mientras` vive en todo el subprograma
  (H-36). Sin ámbitos de bloque, una closure creada en un bucle captura siempre la misma variable.
- **Coste.** Cambio **incompatible**: un programa que lee tras el bloque una variable declarada dentro
  deja de ser válido, y uno que declara dentro de un bucle y lee el valor de la iteración anterior
  cambia de significado (la variable sería nueva en cada iteración). Requiere edición y migración.
- **Pedagogía.** Ámbitos de bloque son lo que el estudiante encuentra en todos los lenguajes de la
  familia C y en Python no; la tabla de prueba de escritorio tendría que mostrar entrada y salida de
  ámbitos.
- **Encaje.** Cumple EST-01 (el bloque ya tiene apertura y cierre).
- **Recomendación.** Introducir con una edición, **antes** de closures. Decisión
  [D-12](17-riesgos-preguntas-y-decisiones.md#d-12).

<a id="closures"></a>

### 4.2 Funciones como valores y closures

- **Problema.** Callbacks, ordenación con criterio, iteradores, composición: sin funciones como
  valores, cada uno exige una interfaz y una clase, que es lo que obliga a Java previo a 8.
- **Decisiones de semántica que hay que tomar** (todas observables, por tanto normativas):

| Pregunta                                                            | Opciones                                                           | Precedentes                                                         | Recomendación                                                                                                   |
|---------------------------------------------------------------------|--------------------------------------------------------------------|---------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| ¿Qué se captura?                                                    | La variable (celda) o una copia de su valor                        | Variable: JavaScript, Python, C#, Go, Dart. Valor: C++ `[=]`, Rust `move`, listas de captura de Swift | **La variable**, coherente con el modelo de celdas vigente y con lo que el estudiante verá en otros lenguajes |
| ¿Variable de bucle por iteración o por bucle?                       | Una por bucle (Go < 1.22, C# < 5) o una por iteración              | Go 1.22 (publicado en febrero de 2024, anunciado en 2023) y C# 5 (2012) **cambiaron** a por iteración porque la otra era el error más frecuente | `Para Cada` declara variable nueva por iteración; el `Para` clásico usa una variable existente (§8.5) y capturarla en una closure que escapa da **aviso** |
| ¿Puede una closure que escapa capturar un parámetro `Por Referencia`? | Sí (exige que la celda del llamador sobreviva) o no               | Swift prohíbe capturar `inout` en closures que escapan               | **No**: error semántico con código propio; sin esa regla, un modelo de memoria sin recolector produciría referencias colgantes |
| ¿Captura `Este` en métodos?                                         | Implícita o explícita                                              | Swift exige `self` explícito en closures que escapan (relajado en parte por SE-0269)               | Implícita, porque `Este.` ya es obligatorio en todo acceso a miembro y por tanto siempre visible                |
| ¿Son comparables las funciones?                                     | Por identidad o no comparables                                     | Go: no comparables                                                   | **No comparables**: la identidad de una closure depende de la implementación                                  |
| ¿Cómo se ve en la traza?                                            | —                                                                  | Python Tutor muestra marcos y objetos función                        | El entorno capturado es un objeto visible con identidad, como una instancia                                    |

- **Coste.** Conversión de closures y análisis de escape en el compilador; en el intérprete, entornos
  en el montón. Interactúa con memoria: bajo conteo de referencias, una closure que captura `Este` y se
  guarda en un atributo crea un ciclo (por eso Swift tiene `[weak self]`); bajo recolección por
  trazado, no ([09](09-gestion-de-memoria.md)).
- **Pedagogía.** La captura por variable es el concepto más difícil de los tres (closures, objetos,
  aliasing) y el que la visualización resuelve mejor: la traza puede dibujar la flecha de la closure a
  su entorno.
- **Dependencias.** Ámbitos de bloque (4.1), tipos función, subprogramas anidados (exclusión vigente
  §10.1 de la especificación).

### 4.3 Genéricos

- **Problema.** Colecciones tipadas (`Lista De Entero`), algoritmos reutilizables. Sin ellos la
  biblioteca estándar no puede existir sin conversiones inseguras.
- **Alternativas de implementación.** Borrado (Java): pierde el tipo en ejecución. Reificación (C#,
  Dart): conserva el tipo. Monomorfización (Rust, C++): rendimiento máximo, más código y compilación
  más lenta. Plantillas con diccionarios (Go 1.18, «GC shape stenciling»): compromiso.
- **Recomendación.** Tipos y subprogramas parametrizados, restricciones por interfaz
  (`T Implementa Comparable`), invariancia (sin anotaciones de varianza al principio), sin tipos de
  orden superior. Semántica **reificada** (el tipo existe en ejecución y se ve en la traza);
  implementación por monomorfización para tipos valor y representación compartida para referencias.
  Featherweight Go (Griesemer et al., OOPSLA 2020) es un buen modelo de qué es suficiente.
- **Pedagogía.** Se presentan tarde (nivel avanzado, §1.3); un nivel inicial usa colecciones ya
  instanciadas.

### 4.4 Interfaces

- **Problema.** Polimorfismo sin herencia; contratos entre módulos; bibliotecas extensibles.
- **Alternativas.** Nominales explícitas (Java, C#, Kotlin); estructurales implícitas (Go); traits con
  implementación externa (Rust, Swift); interfaz implícita de clase (Dart).
- **Recomendación.** Nominales explícitas: el estudiante ve en la cabecera qué promete cada clase
  (F-03). Las estructurales de Go facilitan el desacoplamiento pero permiten implementar una interfaz
  por accidente, y su diagnóstico («no implementa porque falta X») aparece lejos. Decisión
  [D-16](17-riesgos-preguntas-y-decisiones.md#d-16).
- **Interacciones.** Genéricos (restricciones), despacho (tablas de métodos por interfaz), diagramas
  de clases (la app ya dibuja herencia; tendría que dibujar realización).

<a id="errores"></a>

### 4.5 Errores

- **Vigente.** Sin excepciones de usuario; los fallos esperables del motor son estados tipados; los
  errores de ejecución detienen el programa con diagnóstico.
- **Alternativas.**

| Modelo                                          | Precedentes                                 | A favor                                                         | En contra                                                       |
|-------------------------------------------------|---------------------------------------------|-----------------------------------------------------------------|-----------------------------------------------------------------|
| Excepciones no comprobadas                      | Python, Dart, C#, JavaScript                | Código directo                                                  | El error no se ve en la firma; flujo de control oculto (contra F-03) |
| Excepciones comprobadas                         | Java                                        | El error en la firma                                            | Fricción documentada; se envuelven y se silencian               |
| Resultado como tipo + propagación explícita     | Rust (`Result`, `?`), Swift (`throws` tipado, SE-0413) | Error visible, coste predecible, sin desenrollado              | Más verboso; requiere tipos suma                                |
| Valores múltiples                               | Go                                          | Simple                                                          | Se ignoran errores fácilmente (contra F-01)                     |
| Manejadores de efectos                          | Koka                                        | Generalidad                                                     | Inmaduro para quien aprende                                     |

- **Recomendación.** Distinguir, como Joe Duffy en el modelo de errores de Midori (2016),
  **errores recuperables** (tipo `Resultado De T, E` con propagación explícita por palabra, p. ej.
  `edad <- Intentar LeerEdad(texto)`) de **defectos del programa** (índice fuera de rango, desbordamiento,
  precondición violada), que detienen la ejecución con diagnóstico y no se capturan dentro del
  lenguaje. Es la extensión natural de lo vigente (clase A de severidad). Decisión
  [D-15](17-riesgos-preguntas-y-decisiones.md#d-15).

### 4.6 Opcionales, enumerados y coincidencia de patrones

- **Problema.** Sin nulo, las estructuras recursivas usan banderas (H-34). Los enumerados están
  excluidos hoy.
- **Recomendación.** `Opcional De T` (con `Nada`) y `Enumeracion` como tipos suma; `Segun` extendido
  a coincidencia sobre variantes, con **exhaustividad comprobada** (coherente con las clases selladas
  del propio núcleo). Coste bajo, beneficio alto (F-01).

### 4.7 Constantes e inmutabilidad

- **Problema.** Las constantes con nombre están excluidas; una biblioteca no puede exportar `PI`.
- **Recomendación.** `Constante` a nivel de módulo y local, con valor inicial obligatorio. Registros
  inmutables por defecto se evaluarán con E-14 (la mutabilidad es lo que el estudiante espera; la
  inmutabilidad es lo que facilita concurrencia).

### 4.8 Enteros, reales y cadenas

| Tema                  | Vigente                                            | Propuesta para propósito general                                                                                          |
|-----------------------|----------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------|
| Desbordamiento entero | Diagnóstico de ejecución (64 bits)                 | **Se conserva** (F-01). En nativo cuesta una rama por operación; Rust lo hace en depuración. Aritmética envolvente solo con funciones explícitas |
| Tamaños de entero     | Uno (64 bits)                                      | Se mantiene uno como `Entero`; tipos de tamaño fijo (`Entero8`, `Byte`) solo en biblioteca de bajo nivel, más adelante      |
| Precisión arbitraria  | Rechazada                                          | `EnteroGrande` como tipo de biblioteca, no por defecto                                                                    |
| Reales no finitos     | Diagnóstico de ejecución                           | Se conserva por defecto; cálculo científico podría necesitar un modo IEEE completo: decisión aplazada                     |
| Cadenas               | Puntos de código; acceso por posición O(n) declarado irrelevante | Almacenamiento UTF-8, iteración por punto de código, acceso por posición mediante iteradores; decidir si el carácter es punto de código o grupo de grafemas (Swift usa grafemas) |

### 4.9 Módulos y estado global

- **Vigente.** Sin globales; un archivo, un algoritmo.
- **Recomendación.** Módulo = archivo; constantes y subprogramas de módulo; **sin variables globales
  mutables** (se conserva la regla, que además facilita concurrencia y pruebas). Detalle en
  [08](08-modulos-paquetes-y-monorepos.md).

### 4.10 Salida anticipada de bucles

- **Vigente.** `Interrumpir`, `Continuar` e `Ir A` excluidos por programación estructurada; `Retornar`
  permitido en cualquier punto.
- **Observación [INFERENCIA].** La exclusión es inconsistente con admitir varios `Retornar`: ambos son
  salidas estructuradas de una construcción con nombre. Visual Basic ofrece `Exit For`/`Exit Do`,
  que nombran la construcción de la que se sale y encajan con EST-01.
- **Propuesta a evaluar.** `Salir Para`, `Salir Mientras` (y su equivalente de «siguiente iteración»),
  sin etiquetas arbitrarias. Decisión [D-24](17-riesgos-preguntas-y-decisiones.md#d-24).

### 4.11 Límites de recursos

- **Vigente.** Profundidad de llamada de 1 000 como regla del lenguaje (§10.8), con el argumento de que
  cambiarla cambiaría lo que el programa hace (prueba del eje).
- **Propuesta.** Tratar el agotamiento de pila como el de memoria: un **fallo de recurso** con
  diagnóstico, nunca un comportamiento indefinido. El lenguaje garantiza un mínimo y el entorno de
  ejecución declara su límite (la app conserva 1 000 por coherencia con los ejercicios). La
  especificación debe fijar también un tope de tamaño de arreglo o tratarlo como fallo de recurso
  (H-09). Decisión [D-17](17-riesgos-preguntas-y-decisiones.md#d-17).

### 4.12 Concurrencia (horizonte)

- **Alternativas.** Hilos y cerrojos; gorrutinas y canales (Go); `async`/`await` (C#, JavaScript, Dart,
  Rust); actores (Erlang, Swift); concurrencia estructurada (Trio; Kotlin; Swift `TaskGroup`); ausencia
  de carreras garantizada por tipos (Rust `Send`/`Sync`, modo Swift 6, capacidades de Pony).
- **Recomendación.** Posponer hasta tener memoria y módulos; cuando llegue, concurrencia **estructurada**
  (toda tarea termina dentro del bloque que la creó) con comunicación por mensajes y datos inmutables
  compartidos. En la app, un planificador **determinista y reproducible** para observar intercalados
  (idea original evaluable con E-07: el determinismo vigente se extiende a la concurrencia observada).

### 4.13 Contratos y pruebas dentro del lenguaje

- **Problema.** El núcleo «enseña precondiciones» (`README.md` del núcleo, §1.3) pero el lenguaje no
  tiene forma de escribirlas.
- **Precedentes.** Eiffel (*Design by Contract*, Meyer 1992), Dafny, Pyret (bloques `check:` y `where:`
  en un lenguaje de origen pedagógico), Zig y Rust (pruebas en el propio archivo).
- **Propuesta.**

```
SubProceso RaizEntera(n Como Entero) Como Entero
    Requiere n >= 0
    Asegura Resultado * Resultado <= n
    ...
FinSubProceso

Prueba "raíz de cuadrados perfectos"
    Comprobar RaizEntera(16) = 4
FinPrueba
```

  `Requiere` y `Asegura` se comprueban en ejecución (siempre en modo observación; en modo optimizado
  según política) y aparecen en la traza; una violación es un defecto del programa (4.5). `Prueba`
  convierte ejemplos en verificaciones, igual que el sistema de especificaciones lo hace para el
  propio lenguaje ([10](10-especificaciones-ejecutables-fundamentos.md)): **el mismo modelo mental en
  ambos niveles**.
- **Coste.** Tres palabras nuevas (contextuales tras una cabecera) y una semántica de comprobación.

### 4.14 Lo que se recomienda seguir excluyendo

Herencia múltiple, sobrecarga de métodos y de operadores, reflexión sin restricciones, macros,
apuntadores explícitos, visibilidad protegida, métodos de extensión y perfiles definidos por usuarios.
Cada exclusión simplifica herramientas, diagnósticos y el contrato de eliminación de código
([08](08-modulos-paquetes-y-monorepos.md) §6).

---

## 5. Gobierno de la evolución

### 5.1 Qué se versiona

**[INFERENCIA]** Hoy hay dos números (núcleo y app) atados por una regla (`README.md` raíz §4.4). Un
lenguaje de propósito general necesita separar al menos:

| Número                          | Qué promete                                                    | Quién lo consume                     |
|---------------------------------|----------------------------------------------------------------|--------------------------------------|
| **Edición del lenguaje**        | Conjunto de reglas incompatibles con la edición anterior       | Cada paquete, en su manifiesto        |
| **Versión del lenguaje**        | Adiciones compatibles dentro de una edición                    | Paquetes que usan lo nuevo            |
| **Versión de la cadena de herramientas** | Compilador, servidor de lenguaje, formateador         | Usuarios y entornos                   |
| **Versión de la biblioteca estándar** | API                                                      | Paquetes                              |
| **Versión de cada especificación** | Contrato de una regla o familia de reglas                    | Implementaciones, pruebas, documentación ([11](11-especificaciones-ejecutables-diseno.md)) |
| **Versión de la app**           | Producto                                                       | Personas                              |

### 5.2 Mecanismos existentes

| Mecanismo                                            | Qué permite                                                                                    | Lección                                                                                   |
|------------------------------------------------------|------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|
| Ediciones de Rust (RFC 2052; 2015/2018/2021/2024)    | Cambios incompatibles por paquete, con paquetes de ediciones distintas enlazados juntos; migración con `cargo fix` | La edición es local al paquete; la interoperación entre ediciones es obligatoria          |
| Promesa de compatibilidad de Go + `GODEBUG` (Go 1.21, 2023) | Comportamiento por versión declarada en `go.mod`; anulaciones con fecha de caducidad    | Incluso arreglar un fallo es incompatible para alguien (ley de Hyrum)                     |
| Cambio de variable de bucle en Go 1.22 (2024)        | Cambio semántico condicionado a `go 1.22` en `go.mod`                                           | Un cambio de significado puede hacerse sin romper a nadie si va atado a la versión declarada |
| Versionado de lenguaje en Dart (por paquete; anulación por biblioteca con `// @dart = x.y`) | Migración gradual a seguridad ante nulos                       | La granularidad por archivo hizo posible migrar ecosistemas enteros                       |
| PEP 387 (Python) y `__future__`                      | Política de deprecación con avisos previos                                                     | Los avisos deben existir al menos una versión antes de retirar                            |
| JEP 12 (Java) y etapas de TC39 con test262           | Funcionalidades en vista previa, desactivadas por omisión                                     | Lo experimental se separa por mecanismo, no por documentación                              |

### 5.3 Propuesta

1. **Ediciones** declaradas en el manifiesto del paquete (anulación por archivo para migraciones). Los
   cambios incompatibles solo entran con edición nueva; paquetes de ediciones distintas se enlazan
   juntos porque convergen en el plano abstracto y en la representación intermedia.
2. **Migración automática obligatoria** para todo cambio incompatible, construida sobre el árbol sin
   pérdida ([07](07-herramientas-y-autocompletado.md)): `pseudo migrar` reescribe el programa y explica
   cada cambio en el idioma del perfil.
3. **Ciclo de deprecación** atado a los estados de especificación ([11](11-especificaciones-ejecutables-diseno.md) §2):
   una regla «obsoleta» emite aviso durante al menos una edición antes de retirarse.
4. **Promesa acotada.** Un programa válido en la edición N conserva su significado observable con toda
   cadena de herramientas que soporte N. Se excluyen explícitamente: correcciones de seguridad, lo no
   observable (micro-pasos, coste de observación, rendimiento) y lo marcado experimental.
5. **Cambios de comportamiento no atables a edición** (arreglos de fallos con dependientes): mecanismo
   tipo `GODEBUG`, con caducidad declarada.
6. **Los ejercicios de la app declaran edición y nivel**, de modo que el contenido pedagógico no se
   rompe al evolucionar el lenguaje.

**Lo que no se puede prometer.** Que ninguna decisión futura obligue a una edición nueva, que la ley
de Hyrum no aplique a algo que hoy parece interno, ni que la migración automática cubra todos los
casos (Rust y Dart documentan migraciones con intervención manual).
