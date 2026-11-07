# Plan — Nueva ruta de aprendizaje de PseudoLearn

Estado: aprobado. **Manda el plan de ejecución** [`plan-ejecucion-ruta-aprendizaje/`](plan-ejecucion-ruta-aprendizaje/):
donde este documento y aquel difieran, rige el plan de ejecución. Lecciones de muestra: carpeta
[`ruta-aprendizaje-ejemplos/`](ruta-aprendizaje-ejemplos/).

La ruta actual se reemplaza **por completo, sin retrocompatibilidad**: no se conservan identificadores de
módulo, de ejercicio ni progreso guardado. Los ejemplos, ilustraciones y diagramas actuales se
reaprovechan solo si encajan en una lección nueva sin forzarla.

---

## 1. Diagnóstico de la ruta actual

| Hallazgo | Evidencia | Consecuencia |
|---|---|---|
| Ordenada por construcciones | Pistas A, B y C: tipos → entrada y salida → selección → bucles → arreglos → subprogramas → clases; el mismo orden que el índice de la especificación | Duplica la Especificación con menos detalle y no enseña a resolver problemas |
| Conceptos usados antes de explicarse | La máquina nocional se menciona en el primer módulo y se explica a medias en el segundo | Quien empieza de cero se pierde en la primera página |
| Ejercicios que dictan la solución | `CON-A2-E3`: «falta la línea que calcula el perímetro… escribe su perímetro» | El alumno traduce una frase a una línea; no analiza, no diseña y no prueba |
| Explicaciones duplicadas | La ruta reexplica sintaxis y reglas que ya explica la Especificación ilustrada | Dos textos que derivan y se contradicen |
| Un paradigma y medio | Procedural más una introducción a objetos | El lenguaje ya soporta funcional (`Funcion` pura, clausuras, variantes) y concurrente (tareas, canales), y la ruta no los enseña |

---

## 2. Principios

### 2.1 Cero conocimiento previo, comprobable

La ruta supone que la persona **no sabe nada**: ni qué es un programa, ni qué es una variable, ni cómo
funciona una computadora. Cada término se introduce una sola vez, cuando hace falta, y nunca antes.

- **Cada término tiene una lección dueña.** Es la única lección que lo explica. La lista de términos de
  cada lección está en §5.
- **Cada lección declara lo que introduce y lo que usa.** Una lección solo puede usar términos
  introducidos en lecciones anteriores o en ella misma. Un verificador del contenido rechaza una lección
  que usa un término antes de su lección dueña; así no se repite lo que pasó con la máquina nocional.
- **La primera aparición de un término se marca** como definición. Las siguientes, no.

### 2.2 Cero explicaciones duplicadas

Cada cosa se explica en un solo lugar. Las demás apariciones **enlazan**, no reexplican.

| Pregunta | Dueño | Qué hace la otra parte |
|---|---|---|
| ¿Cómo se escribe exactamente? ¿Qué reglas, límites y errores tiene? | Especificación ilustrada | La ruta muestra un ejemplo mínimo y enlaza a la sección (`Especificación §6.3`) |
| ¿Cuándo conviene usarlo? ¿Cómo se piensa el problema? ¿Qué estrategia aplico? | Ruta de aprendizaje | La Especificación enlaza a la lección en «Véase también» |
| Un concepto ya visto en otra lección de la ruta | Su lección dueña | Se muestra una **tarjeta de recuerdo**: una línea generada desde la lección dueña y un enlace. No se redacta de nuevo |
| Una figura que la Especificación ya tiene (un `Si` paso a paso, la pila de llamadas) | Especificación ilustrada | La ruta la incrusta por referencia; no la redibuja |

La ruta solo dibuja figuras propias para lo que la Especificación no cubre: herramientas de
razonamiento (ficha del problema, árbol de descomposición, roles de variables, tabla por vuelta) y los
problemas de cada lección.

### 2.3 La máquina nocional en piezas, cuando hace falta

La idea de «qué hace la computadora por dentro» no se explica de una vez al principio, como hace el libro
de Joyanes, ni a medias en el capítulo 2, como hace la ruta actual. Se construye en siete piezas; cada pieza
la introduce la primera lección que la necesita para resolver su problema:

| Pieza | Lección dueña | Qué se agrega a la imagen |
|---|---|---|
| 1. Instrucciones en orden | 0.1 | La computadora lee las instrucciones de arriba abajo, una a la vez |
| 2. Memoria como cajas con nombre | 0.2 | Las cajas guardan un valor; asignar reemplaza el que había |
| 3. El dedo que señala | 1.1 | Hay una instrucción actual; una decisión hace saltar el dedo |
| 4. Una fila por vuelta | 1.3 | En un bucle la misma instrucción se ejecuta con valores distintos |
| 5. La pila de llamadas | 2.2 | Cada llamada abre su propio juego de cajas encima del anterior |
| 6. Objetos y flechas | 3.3 | Una caja puede guardar una flecha a un objeto; dos flechas al mismo objeto |
| 7. La agenda | 5.1 | Varias tareas se turnan para avanzar |

Lo que va más abajo (representación intermedia, bytecode, recolector) no está en la ruta: cada lección
termina con un desplegable «Bajo el capó» que enlaza a la Parte XIII de la Especificación.

### 2.4 Resultados rápidos

El primer programa se ejecuta en los primeros cinco minutos de la lección 0.1. Ninguna lección empieza
con teoría: empieza con un problema.

### 2.5 Se organiza por habilidades, no por construcciones

Cada lección arranca con **un problema que la persona todavía no sabe resolver bien**. La construcción
nueva llega como la herramienta que lo resuelve. El título de una lección nombra la habilidad
(«Repetir mientras haga falta»), no la palabra reservada (`Mientras`).

### 2.6 Público

Hay una sola ruta para cualquier persona desde los 10 años, con capas que se eligen leer, igual que en la
Especificación ilustrada:

| Capa | Para quién | Forma |
|---|---|---|
| Cuerpo | Cualquiera | Frases cortas, una idea por párrafo, figura antes que fórmula |
| Profundizar | Quien quiere más | Desplegable; el cuerpo nunca depende de él |
| Bajo el capó | Curiosos | Desplegable oscuro que enlaza a la Parte XIII de la Especificación |
| Para docentes | Docentes | Confusiones frecuentes y preguntas para la clase |

Los ejercicios tienen tres niveles sobre el mismo concepto: **semilla** (primaria o primer contacto),
**brote** (secundaria) y **árbol** (avanzado). El tono es el de la Especificación ilustrada: tuteo,
español neutro y sin infantilizar.

---

## 3. El método: el ciclo PseudoLearn

La sección 2.1 del libro de Joyanes, «Fases en la resolución de problemas», se toma como base y se
convierte en un hábito que se practica en **todas** las lecciones y ejercicios, no en un capítulo que se lee
una vez:

| Fase | Equivale en Joyanes | Pregunta que se hace la persona | Herramienta visual |
|---|---|---|---|
| **1. Entender** | Análisis del problema | ¿Qué me dan? ¿Qué me piden? ¿Lo sé resolver a mano con dos o tres ejemplos? | Ficha del problema |
| **2. Planear** | Diseño del algoritmo, refinamiento por pasos | ¿En qué partes se divide? ¿A qué problema que ya resolví se parece? | Árbol de descomposición, esquemas, roles de variables |
| **3. Escribir** | Codificación | ¿Cómo dice esto el lenguaje? | Editor con el plan al costado; enlaces a la Especificación |
| **4. Probar** | Compilación, ejecución, verificación y depuración | ¿Da lo mismo que mis ejemplos a mano? ¿Qué entrada lo rompería? | Casos propios (normal, borde, raro), traza, predecir antes de ejecutar |
| **5. Mejorar** | Documentación y mantenimiento | ¿Lo puedo explicar en una frase? ¿Qué pasa si cambia el pedido? | Explicación en una frase, cambio de requisito, comparación con otra solución |

Qué se tomó del libro y qué no:

- **Se tomó** la secuencia de fases, la idea de refinamiento por pasos y la importancia de verificar.
- **Se rechazó** presentar las fases una sola vez como lista administrativa, y abrir el libro con el
  funcionamiento de la máquina antes de que la persona haya ejecutado nada.

**Andamiaje que se desvanece.** En la Unidad 0 y la Parte I las cinco fases son visibles y la lección las
recorre en orden. A partir de la Parte II, Entender y Planear se condensan en una sola fase con una lista corta de
preguntas, que cada parte amplía con la pregunta propia de su paradigma. Los proyectos vuelven a las cinco fases
separadas y completas. El detalle vigente está en el andamiaje de
[`plan-ejecucion-ruta-aprendizaje/03-pedagogia-y-estilo.md`](plan-ejecucion-ruta-aprendizaje/03-pedagogia-y-estilo.md) §3.

---

## 4. Herramientas de razonamiento

Cada herramienta tiene **una lección dueña** que la enseña y una figura ancla que se repite igual en todas
las lecciones que la usan.

| Herramienta | Lección dueña | Qué entrena |
|---|---|---|
| Ficha del problema (entra, sale, relación, ejemplos a mano) | 0.3 | Analizar antes de escribir |
| Ejemplos resueltos a mano | 0.1 | Descubrir el algoritmo observando lo que uno hace |
| Casos de prueba (normal, borde, raro) | 0.4 | Pensar como quien busca el error |
| Partición de casos y tabla de decisión | 1.1 y 1.2 | Que ninguna situación quede sin respuesta |
| Roles de variables: contador, acumulador, más-buscado, bandera, seguidor, recorredor | 1.3 a 1.6 | Reconocer para qué sirve cada variable |
| Tabla por vuelta y pregunta de invariante («¿qué es cierto al terminar cada vuelta?») | 1.3 | Razonar sobre bucles sin ejecutarlos |
| Esquemas: recorrer, contar, acumular, buscar, filtrar, transformar, centinela | 1.3 a 1.6 | Reconocer formas de problemas; antesala de los patrones de diseño |
| Contar pasos | 1.8 | Comparar estrategias por su costo |
| Árbol de descomposición | 2.1 | Dividir un problema grande |
| Tarjetas de responsabilidad | 3.6 | Decidir a quién le toca cada tarea |

Los roles de variables provienen del trabajo de Jorma Sajaniemi sobre cómo razonan los principiantes. Se
toman los roles y se rechaza su notación y su vocabulario técnico.

---

## 5. Estructura

Un **problema hilo**, **el kiosco de la escuela**, recorre la ruta: vender, cobrar, llevar el inventario y
atender pedidos. Se resuelve una vez por paradigma. Comparar las versiones es la mejor forma de entender qué
cambia de un paradigma a otro.

Cada parte de paradigma **abre** con cuatro preguntas (qué pregunta se hace el paradigma, su metáfora, qué
problema resolvió en la historia y qué cuesta usarlo) y **cierra** con el kiosco resuelto en ese paradigma.

En la columna «Introduce» están los términos de los que esa lección es dueña. «Esp.» lista los ids de
sección de la Especificación ilustrada (`packages/pseudolearn_reference/content/es/`) a los que enlaza.

### Unidad 0 — Empezar de cero

| Lección | Problema | Introduce | Esp. |
|---|---|---|---|
| **0.1 Tu primer problema** | ¿Cuántas pizzas pedir para la fiesta? | problema, programa, instrucción, ejecutar, salida, texto frente a cálculo, operaciones, función ya hecha (`techo`), el ciclo PseudoLearn, ejemplo a mano; pieza 1 | `programas.estructura`, `biblioteca.consola`, `expresiones.aritmeticos`, `expresiones.division`, `biblioteca.matematicas` |
| **0.2 Darle nombre a los datos** | Los invitados cambian de número cada día | variable, valor, tipo (`Entero`, `Real`, `Cadena`), declarar, asignar; pieza 2 | `declaraciones.definir`, `tipos.primitivos`, `declaraciones.asignacion`, `expresiones.division` |
| **0.3 Preguntar antes de calcular** | Una calculadora de propinas que sirva para cualquier cuenta | entrada, `Leer`, ficha del problema | `biblioteca.consola`, `tipos.primitivos` |
| **0.4 Cuando algo sale mal** | El programa de un compañero da un resultado raro | error al compilar, error al ejecutar, error de lógica, diagnóstico, caso de prueba, caso borde | `vision.errores`, `diagnosticos.anatomia`, `vision.terminacion` |

### Parte I — Imperativo y estructurado: «darle órdenes a una máquina con memoria»

| Lección | Problema | Introduce | Esp. |
|---|---|---|---|
| **1.1 Decidir** | Precio de la entrada al cine según la edad | condición, `Logico`, comparación, `Si`, partición de casos; pieza 3 | `control.si`, `expresiones.comparacion`, `tipos.primitivos` |
| **1.2 Muchos caminos** | ¿Este año es bisiesto? | condiciones compuestas, tabla de decisión, `Segun`, orden de las preguntas | `expresiones.logicos`, `expresiones.precedencia`, `control.segun`, `control.si` |
| **1.3 Repetir mientras haga falta** | La alcancía de Lucía | bucle, vuelta, condición de continuar, `Mientras`, roles contador y acumulador, centinela, bucle infinito, tabla por vuelta, invariante; pieza 4 | `control.mientras`, `motor.limites` |
| **1.4 Repetir un número conocido de veces** | ¿Este número es primo? | `Para`, `Repetir`, roles bandera y más-buscado, elegir el bucle, `Salir` | `control.para`, `control.repetir`, `control.salir` |
| **1.5 Muchos datos con un solo nombre** | Las temperaturas del mes | arreglo, índice desde cero, recorrer, `Para Cada`, rol recorredor | `tipos.arreglos`, `control.para-cada` |
| **1.6 Buscar, contar y filtrar** | Olas de calor | esquemas sobre colecciones, rol seguidor | — |
| **1.7 Tableros y cuadrículas** | Tres en raya | matriz, recorrido por filas y columnas | `tipos.arreglos`, `expresiones.concatenacion` |
| **1.8 Más de una manera** | Adivina el número en pocos intentos | estrategia, fuerza bruta, búsqueda binaria, contar pasos, ordenar | — |
| **Proyecto I** | El kiosco, versión imperativa | — | — |

### Parte II — Procedimental y modular: «divide y vencerás»

| Lección | Problema | Introduce | Esp. |
|---|---|---|---|
| **2.1 Dividir el problema** | El boletín de notas de un curso | árbol de descomposición, subprograma, llamada, parámetro, `Retornar` | `subprogramas.declaracion`, `subprogramas.parametros`, `subprogramas.llamada`, `subprogramas.retornar` |
| **2.2 Lo que cada parte ve** | Dos subprogramas que se pisan los datos | ámbito, paso por valor y por referencia; pieza 5 | `subprogramas.ambito`, `subprogramas.parametros`, `subprogramas.referencia`, `subprogramas.llamada` |
| **2.3 Funciones que no tocan nada** | Una fórmula que da distinto cada vez | `Funcion`, función pura, efecto | `subprogramas.pureza` |
| **2.4 Problemas que se contienen a sí mismos** | Fractales y la torre de Hanói | recursión, caso base | `subprogramas.recursion`, `motor.limites` |
| **2.5 Darle forma a los datos** | La agenda de contactos | registro, enumerado, vector, diccionario | `tipos.registros`, `tipos.enumerados`, `tipos.vectores`, `tipos.diccionarios` |
| **2.6 Cuando algo puede fallar** | Un formulario que recibe datos inválidos | `Opcional`, `Resultado`, `Propagar` | `tipos.opcional-resultado`, `biblioteca.conversion`, `control.segun` |
| **2.7 Programas grandes** | El kiosco no cabe en un archivo | módulo, `Importar` | `programas.modulos`, `programas.estructura` |
| **Proyecto II** | El kiosco, versión procedimental | — | — |

### Parte III — Orientación a objetos: «cosas que saben y hacen»

| Lección | Problema | Introduce | Esp. |
|---|---|---|---|
| **3.1 Cosas que saben y hacen** | Variables sueltas que deberían ir juntas | paradigma, objeto, clase, atributo, método, constructor, `Nuevo` | `objetos.clase`, `objetos.metodos`, `objetos.constructor` |
| **3.2 Proteger lo que debe ser cierto** | Un saldo que alguien deja en negativo | encapsulamiento, invariante de clase, visibilidad | `objetos.clase`, `objetos.metodos` |
| **3.3 Dos nombres, un objeto** | Copié el pedido, cambié la copia y cambió el original | identidad, alias, copia; pieza 6 | `objetos.copia` |
| **3.4 Contratos** | Cobrar en efectivo, con tarjeta o con vale | interfaz, polimorfismo, despacho dinámico | `objetos.interfaces`, `objetos.herencia` |
| **3.5 Heredar o componer** | Productos con y sin fecha de vencimiento | herencia, composición, `Super` | `objetos.herencia`, `objetos.ausentes` |
| **3.6 ¿A quién le toca?** | El kiosco con muchas clases | responsabilidad, tarjetas de responsabilidad | — |
| **Proyecto III** | El kiosco, versión orientada a objetos | — | — |

### Parte IV — Funcional: «calcular sin cambiar nada»

| Lección | Problema | Introduce | Esp. |
|---|---|---|---|
| **4.1 Calcular sin cambiar nada** | La caja cobró una cosa y el ticket dice otra | programación funcional, inmutabilidad, transparencia referencial, núcleo puro y borde con efectos | `subprogramas.pureza`, `vision.analizar-ejecutar` |
| **4.2 Funciones que reciben funciones** | Aplicar la misma regla a cada producto | función como valor, mapear, filtrar, reducir (construidas por la persona) | `tipos.funciones`, `tipos.vectores`, `subprogramas.pureza` |
| **4.3 Funciones que recuerdan** | Descuentos configurables | clausura | `tipos.funciones` |
| **4.4 Datos que no pueden estar mal** | Un pedido «entregado» sin hora de entrega | variante, `Segun` por patrones, genérico, `Inmutable` | `tipos.variantes`, `control.segun`, `tipos.genericos`, `tipos.inmutable` |
| **4.5 Cara a cara** | El kiosco en tres paradigmas | criterios para elegir un paradigma | — |
| **Proyecto IV** | El kiosco, versión funcional | — | — |

### Parte V — Concurrente: «varias cosas a la vez»

| Lección | Problema | Introduce | Esp. |
|---|---|---|---|
| **5.1 Varias cosas a la vez** | Tres cocineros y una sola cocina | tarea, `Tareas`, `Lanzar`, `Aguardar`; pieza 7 | `tareas.suspendible`, `tareas.ambitos`, `motor.agenda` |
| **5.2 Pasarse mensajes** | La cocina y el mostrador | canal, aislamiento, productor y consumidor | `tareas.canales` |
| **5.3 Lo primero que llegue** | Consultar dos proveedores a la vez | `Elegir`, fallo, cancelación | `tareas.canales`, `tareas.ambitos` |

### Parte VI — El mundo exterior

| Lección | Problema | Introduce | Esp. |
|---|---|---|---|
| **6.1 Guardar para mañana** | El inventario se borra al cerrar | archivo, capacidad, `Diferir` | `biblioteca.archivos`, `control.diferir`, `tareas.efectos` |
| **6.2 Datos que se entienden entre programas** | Exportar el inventario | JSON | `biblioteca.json`, `expresiones.concatenacion` |
| **6.3 Hablar con internet** | Consultar el tipo de cambio | HTTP | `biblioteca.http`, `biblioteca.json` |
| **Proyecto final** | El kiosco completo | — | — |

**Paradigmas que entran:** imperativo y estructurado, procedimental y modular, orientado a objetos,
funcional y concurrente por mensajes. **No entran** el lógico, porque el lenguaje no lo soporta, ni el
orientado a eventos, porque no tiene construcciones propias en el lenguaje y solo se vería de nombre
(`SCOPE-YAGNI`). Los patrones de diseño quedan para un release posterior; la lección 3.6 y los esquemas de la
Parte I preparan el terreno.

**Orden de las partes.** Las funciones puras aparecen en la Parte II (lección 2.3) y la Parte IV se apoya en
ellas sin reexplicarlas. Objetos va antes que funcional porque el problema que motiva la Parte IV, el estado
compartido que cambia sin aviso, se siente con más fuerza después de haber trabajado con objetos.

---

## 6. Anatomía de una lección

Bloques fijos, en este orden. El verificador rechaza una lección a la que le falta un bloque obligatorio.

| Bloque | Obligatorio | Contenido |
|---|---|---|
| Cabecera | sí | Unidad, duración estimada, «Necesitas» (lecciones previas enlazadas), «Vas a aprender» (los términos de los que es dueña) |
| El problema | sí | Una situación concreta, sin pistas de cómo se resuelve |
| Inténtalo | sí | Resolver a mano o predecir antes de leer; la respuesta queda oculta |
| 1. Entender | sí | Ficha del problema (desde la 0.3) |
| 2. Planear | sí | Pasos en palabras, árbol, esquema o roles |
| La herramienta nueva | si introduce construcción | Para qué sirve, un ejemplo mínimo ejecutado y el enlace a la Especificación. Nunca reglas, límites ni errores que la Especificación ya explica |
| 3. Escribir | sí | La solución ejecutada con el motor |
| 4. Probar | sí | Casos normal, borde y raro; traza o tabla |
| 5. Mejorar | sí | Un cambio de requisito o una comparación |
| Lo que aprendiste | sí | Puntos en lenguaje llano |
| Practica | sí | Al menos cinco ejercicios de al menos tres tipos y dos niveles |
| Bajo el capó | opcional | Enlace a la Parte XIII de la Especificación |
| Para docentes | recomendado | Confusiones frecuentes |
| Siguiente | sí | Qué problema deja abierto esta lección y qué lección lo resuelve |

Desde la Parte II, «Entender» y «Planear» se condensan en una lista de preguntas; los proyectos los mantienen
separados (§3, andamiaje que se desvanece).

---

## 7. Ejercicios

**Regla:** un ejercicio plantea un problema, nunca dicta los pasos. El enunciado no nombra la construcción
ni el rol de variable que hace falta; descubrirlo es el ejercicio.

| Tipo | Qué hace la persona | Cómo se corrige |
|---|---|---|
| Predecir | Dice qué va a mostrar un programa antes de ejecutarlo | Respuesta exacta |
| Rastrear | Completa la tabla por vuelta | Celda por celda, contra la traza del motor |
| Ordenar | Ordena bloques de código mezclados (problemas de Parsons) | Ejecución contra casos |
| Encontrar el error | Corrige el programa de un compañero | Casos ocultos |
| Romperlo | Busca una entrada que haga fallar un programa que pasa los casos visibles | El motor ejecuta la entrada en el programa defectuoso y en la referencia, y compara |
| Diseñar las pruebas | Escribe casos para un enunciado | Los casos deben distinguir la referencia de varias versiones con errores sembrados |
| Modificar | Adapta un programa a un requisito nuevo | Casos ocultos |
| Resolver | Escribe la solución desde cero | Casos ocultos |
| Comparar | Elige entre dos soluciones y justifica | Opción más justificación guiada |
| Clasificar | Ubica casos en categorías (por ejemplo, núcleo puro o borde) | Respuesta exacta por elemento |
| Explicar | Resume un programa en una frase | Opción múltiple entre frases candidatas |

**Pistas en escalera.** Cada ejercicio tiene cuatro pistas que se abren una a una:

1. Una pregunta sobre el problema.
2. Un problema parecido ya resuelto en la ruta.
3. El esqueleto como bloques para ordenar.
4. La solución de referencia, y para cerrar el ejercicio, una variante obligatoria.

**Repaso espaciado e intercalado.** Desde la lección 1.3, cada sesión de práctica incluye uno o dos
ejercicios de lecciones anteriores mezclados con los nuevos, sin anunciar de qué lección vienen.

---

## 8. Implicaciones técnicas

- **Formato de ejercicio.** El actual (`crear` y `completar`, casos visibles y ocultos) solo cubre resolver,
  modificar y encontrar el error. Predecir, rastrear, ordenar, romperlo, diseñar las pruebas y comparar
  necesitan tipos nuevos en el manifiesto y evaluadores en la app.
- **Términos e índice de dependencias.** Cada lección declara `introduce` y `usa`. El verificador comprueba el
  orden (§2.1) y que cada término tenga exactamente una lección dueña.
- **Enlaces a la Especificación.** Apuntan a identificadores de sección estables (`control.mientras`), no a números ni títulos; el
  verificador rechaza un enlace a una sección inexistente.
- **Tarjetas de recuerdo.** Se generan desde el bloque «Lo que aprendiste» de la lección dueña; no se
  escriben a mano (`GEN-NO-HAND-COPY`).
- **Programas.** Se ejecutan con el motor al construir, igual que en la Especificación ilustrada; una salida
  que cambia hace fallar la construcción.
- **Dependencia con la Especificación ilustrada.** La ruta enlaza a secciones que todavía no existen. O se
  publican juntas, o la ruta muestra los enlaces a secciones no publicadas como texto sin enlace.

---

## 9. Fases propuestas

| Fase | Alcance |
|---|---|
| RA-0 | Este plan y tres lecciones de muestra (0.1, 1.3 y 4.1) |
| RA-1 | Formato fuente de lección, términos, verificador de dependencias y de enlaces |
| RA-2 | Tipos de ejercicio nuevos y sus evaluadores |
| RA-3 | Unidad 0 y Parte I completas en la app |
| RA-4 | Partes II y III |
| RA-5 | Partes IV, V y VI |

Cada fase se cierra con `PHASE-GREEN` y espera autorización nueva (`PHASE-STOP`).

---

## 10. Preguntas abiertas

1. **¿Las fases Entender y Planear se califican** (la app revisa la ficha del problema) **o solo guían?** La
   propuesta es que guíen en la Unidad 0 y se califiquen solo en los proyectos.
2. **¿La ruta se publica antes, junto con la Especificación ilustrada o después de ella?** Determina cómo
   se muestran los enlaces a secciones todavía no escritas (§8).
3. **¿Se confirma el kiosco de la escuela como problema hilo?**
