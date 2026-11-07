# 12 — Parte II: Procedimental y modular

**Lema:** Divide y vencerás.

**Propósito de la parte:** que la persona parta un problema grande en piezas con nombre, entienda qué ve cada pieza, separe
el cálculo de la entrada y salida, use recursión, elija la forma de sus datos y haga que sus programas fallen bien. Siete
lecciones y un proyecto, unas cuatro horas.

Desde aquí, fases 1 y 2 condensadas (`fase=1-2`) con las preguntas de 03 §3: ¿qué entra y qué sale?, ¿a qué se parece?,
¿en qué partes se divide?

---

## 2.1 Dividir el problema — `procedimental.dividir`

| Campo | Valor |
|---|---|
| Tipo | `apertura` · 35 min · semilla a árbol |
| Necesita | `imperativo.proyecto` |
| Introduce | `programacion-procedimental`, `descomposicion`, `arbol-de-descomposicion`, `subprograma`, `llamada`, `parametro`, `valor-de-retorno` |

**Propósito.** La persona descompone un problema en un árbol de subproblemas y escribe cada uno como un subprograma con
parámetros y valor de retorno.

**Frase.** Un problema grande se vuelve fácil cuando se parte en problemas chicos, cada uno con su nombre.

**Problema.** La profesora tiene las tres notas de cada uno de sus **4 alumnos**. Quiere un boletín con el **promedio** de
cada alumno, si **aprobó** (promedio de 6 o más) y quién tuvo el **mejor promedio**. **¿Cómo se organiza un programa así sin
perderse?**

**Inténtalo.** Calcular a mano con Ana 8, 9, 10; Beto 5, 6, 4; Caro 6, 6, 6; Dani 7, 8, 6. Respuesta: 9, 5, 6 y 7; aprueban
Ana, Caro (borde) y Dani; mejor promedio: Ana.

**Un paradigma nuevo (breve).**

- Pregunta: ¿y si un programa grande se armara con piezas chicas, cada una con un nombre y una tarea?
- Metáfora: un libro de recetas que dice «prepara la salsa (página 12)». Deja de valer en que una pieza de programa
  recibe datos distintos cada vez que se la usa.
- Historia: en 1949, en la computadora EDSAC de Cambridge, David Wheeler ideó cómo saltar a un trozo de programa y volver,
  la base de los subprogramas. En 1960, ALGOL 60 los formalizó con parámetros.
- Costo: hay que decidir dónde cortar y qué datos pasar a cada pieza.

**Entender y planear.** Las tres preguntas. Figura `ruta-arbol-boletin` (ancla de descomposición): Boletín → leer notas,
calcular el promedio, decidir el estado, buscar el mejor. Definición de descomposición y de árbol de descomposición.

**Herramienta nueva.** Subprograma, llamada, parámetro y valor de retorno con la figura de la Especificación
`subprogramas.declaracion#subprograma-caja`. En esta lección todos los subprogramas son `SubProceso`; `Funcion` llega en
2.3.

| Id | Programa | Salida |
|---|---|---|
| `doble` | `SubProceso Doble(x Como Entero) Como Entero` que retorna `x * 2`; escribe `Doble(21)` | `42` |

Enlaces: `subprogramas.declaracion`, `subprogramas.parametros`, `subprogramas.llamada`, `subprogramas.retornar`.

**3. Escribir.** `boletin`: `Promedio(a, b, c)`, `Estado(promedio)` y el algoritmo principal, que lee 4 nombres con sus notas
y lleva el mejor hasta ahora. Cada línea: `Ana: 9.0 aprobado`; al final `Mejor promedio: Ana`.

**4. Probar.** Cada subprograma por separado con un programa de casos (`Promedio(6, 6, 6)`, `Estado(6.0)`, `Estado(5.9)`) y
el boletín completo con los datos del Inténtalo.

**5. Mejorar.** La escuela sube la nota para aprobar a 7: cambia una sola línea, dentro de `Estado`.

**Resumen.**

- `{programacion-procedimental}` La programación procedimental arma un programa con subprogramas que se llaman entre sí.
- `{descomposicion,arbol-de-descomposicion}` Descomponer es partir un problema en subproblemas; el árbol de descomposición los
  dibuja de lo general a lo particular.
- `{subprograma,llamada}` Un subprograma es un trozo de programa con nombre; llamarlo es pedirle que se ejecute.
- `{parametro,valor-de-retorno}` Los parámetros son los datos que recibe; el valor de retorno es lo que devuelve.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `excursion` | clasificar | semilla | sí | Ubicar seis tareas de organizar una excursión bajo «transporte», «comida» o «permisos»: contratar el bus, juntar autorizaciones, comprar agua, fijar el horario de salida, armar los sándwiches, avisar a las familias | Transporte: bus, horario. Comida: agua, sándwiches. Permisos: autorizaciones, avisar |
| `sumar-tres` | predecir | semilla | — | `SubProceso Sumar3(x)` retorna `x + 3`; escribe `Sumar3(Sumar3(1))` | `7` |
| `area` | resolver | semilla | sí | Lee el largo y el ancho de un rectángulo y muestra su área | Restricción: el cálculo va en un subprograma `AreaRectangulo` de dos parámetros (aserción de firma). Visibles: 3, 4 → 12; 5, 5 → 25. Ocultos: 0, 9 → 0; 1, 1 → 1; 10, 7 → 70 |
| `propina-partes` | modificar | brote | sí | Reescribe la calculadora de propinas de 1.1 con un subprograma para el total y otro para la parte de cada uno, sin cambiar lo que muestra | Aserciones de firma `TotalConPropina` (1) y `ParteDeCadaUno` (2). Casos de `propina-segura` |
| `buen-nombre-sub` | explicar | semilla | — | ¿Cómo conviene llamar al subprograma que dice si un año es bisiesto? `Calcular`, `Bisiesto`, `EsBisiesto`, `Hacer` | `EsBisiesto`: se lee como una pregunta |
| `boletin-chico` | resolver | árbol | — | Tres alumnos con dos notas cada uno: muestra `Nombre: promedio estado` por alumno y `Mejor promedio: Nombre` | Visibles y ocultos con un empate (gana el primero leído, regla del enunciado) y un 6.0 justo |

**Para docentes.** Un subprograma que hace dos cosas; nombres que no dicen qué hace; olvidar `Retornar`.

**Siguiente.** «Un subprograma recibe el saldo de una tarjeta y lo duplica. Al volver, el saldo sigue igual. ¿Qué ve cada
parte del programa?»

---

## 2.2 Lo que cada parte ve — `procedimental.ambito`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 30 min · semilla a árbol |
| Necesita | `procedimental.dividir` |
| Introduce | `ambito`, `paso-por-valor`, `paso-por-referencia`, `pila-de-llamadas`, `marco` |
| Pieza | 5 |

**Propósito.** La persona predice qué variables existen en cada punto, distingue paso por valor y por referencia y usa la
pila de llamadas para seguir un programa con subprogramas.

**Frase.** Cada llamada trabaja con sus propias cajas, salvo que se le preste una caja de quien llama.

**Problema.** En el día del estudiante, el kiosco duplica el saldo de cada tarjeta del comedor. El programa llama a
`Duplicar(saldo)`, que hace `saldo <- saldo * 2`. Con un saldo de 10, al volver el programa sigue mostrando **10**. **¿Por
qué no cambió, y cuál es la mejor forma de arreglarlo?**

**Inténtalo.** Predecir la salida antes de leer la respuesta. Respuesta: 10; el subprograma duplicó **su copia**.

**Entender y planear.** Las tres preguntas. Lo que entra a `Duplicar` es una copia del valor.

**Herramienta nueva.** Ámbito; paso por valor (figura `subprogramas.parametros#paso-valor`); paso por referencia (figura
`subprogramas.referencia#referencia-salida`); pila de llamadas y marco (figura `subprogramas.llamada#llamada-marcos`, pieza 5).

| Id | Programa | Salida |
|---|---|---|
| `valor-y-referencia` | `A(x)` y `B(x Por Referencia)` asignan 10; con `n` en 5 se llama `A(n)`, se escribe `n`, se llama `B(n)`, se escribe `n` | `5` ⏎ `10` |

Enlaces: `subprogramas.ambito`, `subprogramas.parametros`, `subprogramas.referencia`, `subprogramas.llamada`.

**3. Escribir.** Dos arreglos: `duplicar-retorno` (`Duplicar` retorna el doble y quien llama decide guardarlo) y
`duplicar-referencia` (por referencia). Los dos muestran 20.

**4. Probar.** Seguir la pila en `duplicar-retorno`: qué marcos hay en cada línea.

**5. Mejorar.** Comparar las dos soluciones: con retorno, quien lee la llamada ve que `saldo` cambia (`saldo <-
Duplicar(saldo)`); con referencia, el cambio queda escondido en la llamada. Preferir el retorno salvo que haya que devolver
más de un valor.

**Resumen.**

- `{ambito}` El ámbito es la parte del programa donde existe un nombre; las variables de un subprograma no existen afuera.
- `{paso-por-valor,paso-por-referencia}` Por valor, el subprograma recibe una copia; por referencia, trabaja con la caja de
  quien llama.
- `{pila-de-llamadas,marco}` Cada llamada abre un marco con sus cajas encima de la pila y lo cierra al volver.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `cinco-diez` | predecir | semilla | sí | El programa `valor-y-referencia` con otros números (`n` en 3, asignan 7) | `3` ⏎ `7` |
| `cambiar-figuritas` | encontrar-error | brote | sí | `Intercambiar(a, b)` no intercambia: lee dos números y debería mostrarlos al revés | Visibles: 3, 8 → `8 3`; 1, 1 → `1 1`. Ocultos: 0, 5; -2, 4; 9, 0 |
| `ordenar-dos` | resolver | brote | sí | Un subprograma `OrdenarDos` deja el menor en la primera variable y el mayor en la segunda; el principal lee dos y muestra `menor mayor` | Aserción de firma. Visibles: 9, 4 → `4 9`; 2, 7 → `2 7`. Ocultos: 5, 5; -1, -3 → `-3 -1`; 0, 10 |
| `quien-existe` | clasificar | semilla | — | En la línea marcada de un programa con dos subprogramas, ubicar cada nombre en «existe aquí» o «no existe aquí» | Según el programa que escribe el agente |
| `retorno-o-referencia` | comparar | brote | — | Para «calcular el doble de un precio», ¿retornar o pasar por referencia? | Retornar; justificación por opción |

**Para docentes.** «El parámetro y la variable de afuera son la misma porque se llaman igual»; usar referencia para todo;
creer que las variables de un subprograma sobreviven entre llamadas.

**Siguiente.** «Un subprograma que calcula un precio también lo pregunta y lo muestra. ¿Por qué eso impide usarlo en otro
cálculo y probarlo?»

---

## 2.3 Funciones que no tocan nada — `procedimental.puras`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 30 min · semilla a árbol |
| Necesita | `procedimental.ambito` |
| Introduce | `efecto`, `funcion-pura` |

**Propósito.** La persona separa el cálculo de la entrada y salida, escribe funciones puras y sabe que el motor comprueba
su pureza.

**Frase.** Una función pura solo recibe datos y devuelve un resultado: no pregunta, no muestra y no cambia nada de afuera.

**Problema.** El kiosco tiene un subprograma `PrecioFinal` que **pregunta** el descuento, lo aplica y **muestra** el precio.
Ahora hay que sumar el precio final de tres productos. Cada llamada vuelve a preguntar, la pantalla se llena de mensajes y el
resultado no se puede sumar. **¿Cómo se escribe para poder usarlo en cualquier cálculo y probarlo con una tabla?**

**Inténtalo.** Marcar en el programa dado qué líneas preguntan, cuáles muestran y cuáles calculan.

**Entender y planear.** Las tres preguntas. Separar en una pieza que calcula y otra que pregunta y muestra.

**Herramienta nueva.** Efecto (leer, escribir, cambiar algo de afuera) y función pura con `Funcion`. Figura
`ruta-maquina-pura` y figura de la Especificación `subprogramas.pureza#pureza-grafo`. Un programa que no compila porque una
`Funcion` escribe, con su diagnóstico real (cerca `diagnosticos`), sin explicar la regla: se enlaza.

| Id | Programa | Salida |
|---|---|---|
| `cuadrado` | `Funcion Cuadrado(x Como Entero) Como Entero` retorna `x * x`; escribe `Cuadrado(3) + Cuadrado(4)` | `25` |

Enlace: `subprogramas.pureza`.

**3. Escribir.** `precio-final-puro`: `Funcion ConDescuento(precio, porcentaje)` y un algoritmo que pregunta una vez y muestra
el total de tres productos.

**4. Probar.** Tabla de casos de `ConDescuento` con un programa de casos: sin pedir nada a nadie.

**5. Mejorar.** El mismo cálculo ahora sirve para el ticket y para el resumen del día sin cambios.

**Resumen.**

- `{efecto}` Un efecto es leer, mostrar o cambiar algo fuera del subprograma.
- `{funcion-pura}` Una función pura no tiene efectos: con los mismos datos devuelve siempre lo mismo, y el motor lo comprueba.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `puro-o-no` | clasificar | semilla | sí | Calcular el IVA de un precio; mostrar un mensaje; leer la edad; decidir si un año es bisiesto; cambiar una variable recibida por referencia | Pura: 1 y 4. Con efecto: 2, 3 y 5 |
| `suma-cuadrados` | predecir | semilla | — | `Cuadrado(2) + Cuadrado(Cuadrado(2))` | `20` |
| `funcion-que-escribe` | encontrar-error | brote | sí | Una `Funcion Iva` que escribe un mensaje antes de retornar y por eso el programa no compila | Referencia: el mensaje se mueve al algoritmo. Casos con precios |
| `separar` | modificar | brote | sí | Un `SubProceso` que lee el precio, calcula y muestra; reescríbelo con una `Funcion` que solo calcula | Aserción: declara una `Funcion` de un parámetro (el agente confirma que el catálogo de aserciones la distingue; si no, lo reporta). Casos iguales a los de la versión inicial |
| `es-bisiesto` | resolver | brote | — | Una `Funcion EsBisiesto` y un algoritmo que lee un año | Casos de 1.2 |
| `por-que-pura` | explicar | árbol | — | ¿Por qué es más fácil probar una función pura? Opciones: es más corta; con los mismos datos da siempre lo mismo y no hay que preparar nada; el motor la ejecuta más rápido | La segunda |

**Para docentes.** «Pura significa sin variables»; poner `Escribir` adentro «para ver qué pasa»; confundir pura con corta.

**Siguiente.** «Para mover una torre de discos de un poste a otro hay que mover primero una torre más chica. ¿Puede un
subprograma usarse a sí mismo?»

---

## 2.4 Problemas que se contienen a sí mismos — `procedimental.recursion`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 35 min · semilla a árbol |
| Necesita | `procedimental.puras` |
| Introduce | `recursion`, `caso-base`, `caso-recursivo` |

**Propósito.** La persona reconoce problemas que contienen una versión más chica de sí mismos y los resuelve con un caso
base y un caso recursivo que se acerca a él.

**Frase.** Un subprograma recursivo resuelve un problema pidiéndose a sí mismo una versión más chica, hasta llegar a una que
ya sabe resolver.

**Problema.** La torre de Hanói: tres discos de distinto tamaño apilados en el poste A, del más grande abajo al más chico
arriba. Hay que pasarlos al poste C moviendo un disco por vez y sin poner nunca uno grande sobre uno chico. **¿Qué
movimientos hay que hacer, y cuántos son?**

**Inténtalo.** Resolverlo con tres monedas de distinto tamaño. Respuesta: 7 movimientos.

**Entender y planear.** Las tres preguntas. Para mover 3 discos de A a C: mover 2 de A a B, mover el grande a C, mover 2 de
B a C. Mover 1 disco es directo. Figura `ruta-hanoi`.

**Herramienta nueva.** Recursión, caso base y caso recursivo con la figura `ruta-munecas` y la figura de la Especificación
`subprogramas.recursion#recursion-pila`.

| Id | Programa | Salida |
|---|---|---|
| `factorial` | `Funcion Factorial(n)`: 1 si `n = 0`; si no, `n * Factorial(n - 1)`; escribe `Factorial(5)` | `120` |

Enlaces: `subprogramas.recursion`, `motor.limites`.

**3. Escribir.** `hanoi`: `SubProceso Hanoi(n, origen, destino, auxiliar)` escribe `Mover disco 1 de A a C` y así. Con 3:
1 A→C, 2 A→B, 1 C→B, 3 A→C, 1 B→A, 2 B→C, 1 A→C.

**4. Probar.** Con 1 disco (1 movimiento) y con 0 (ninguno, caso borde). Contar movimientos para 1 a 5 discos: 1, 3, 7, 15,
31.

**5. Mejorar.** Costo: cada disco más duplica los movimientos; con 20 discos son más de un millón. Comparar con un bucle
cuando el problema no se ramifica (factorial).

**Resumen.**

- `{recursion}` Un subprograma recursivo se llama a sí mismo con un problema más chico.
- `{caso-base,caso-recursivo}` El caso base se resuelve sin llamarse; el caso recursivo tiene que acercarse a él.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `factorial-4` | predecir | semilla | sí | `Factorial(4)` | `24` |
| `suma-sin-fin` | encontrar-error | brote | sí | `SumaHasta(n)` retorna `n + SumaHasta(n - 1)` y no termina | Referencia con caso base. Visibles: 3 → 6; 1 → 1. Ocultos: 0 → 0; 10 → 55; 100 → 5050 |
| `potencia` | resolver | brote | sí | Lee una base y un exponente no negativo y muestra la potencia | Restricción: sin bucles (aserción «no contiene» bucles). Visibles: 2, 10 → 1024; 5, 0 → 1. Ocultos: 3, 3 → 27; 1, 100 → 1; 10, 1 → 10 |
| `cifras` | resolver | árbol | — | Cuenta las cifras de un número no negativo | Visibles: 1234 → 4; 7 → 1. Ocultos: 0 → 1; 100000 → 6; 10 → 2 |
| `fibonacci` | comparar | brote | — | Calcular el término 30 de Fibonacci: ¿recursivo directo o con un bucle? | Con un bucle: el recursivo repite cálculos y hace más de un millón de llamadas |
| `munecas` | explicar | semilla | — | En las muñecas que se abren una dentro de otra, ¿cuál es el caso base? | La más chica, que no se abre |

**Para docentes.** Olvidar el caso base; un caso recursivo que no se achica; creer que la recursión es siempre mejor.

**Siguiente.** «Los contactos del curso tienen nombre, teléfono y mes de cumpleaños. ¿Cómo se guarda algo que tiene varias
partes?»

---

## 2.5 Darle forma a los datos — `procedimental.datos`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 40 min · semilla a árbol |
| Necesita | `procedimental.recursion` |
| Introduce | `registro`, `campo`, `enumerado`, `vector`, `diccionario`, `clave` |

**Propósito.** La persona elige la forma de sus datos según las preguntas que el programa tiene que responder.

**Frase.** Elegir cómo guardar los datos es la mitad de la solución.

**Problema.** La agenda del curso guarda, de cada compañero, su **nombre**, su **teléfono** y su **mes de cumpleaños**. Cada
año se suman compañeros nuevos. Hay que poder **buscar el teléfono de alguien por su nombre** y saber **cuántos cumplen
años cada mes**. **¿Cómo conviene guardar la agenda?**

**Inténtalo.** Dibujar tres formas de guardar cinco contactos y decir cuál responde más fácil cada pregunta.

**Entender y planear.** Las tres preguntas. Figura `ruta-forma-de-datos`: arreglos paralelos, vector de registros y
diccionario por nombre.

**Herramienta nueva.** Registro y campo (figura `tipos.registros#registro-copia`), enumerado, vector que crece y diccionario
con clave (figura `tipos.diccionarios#diccionario`). Programa mínimo con un registro del kiosco:

| Id | Programa | Salida |
|---|---|---|
| `producto` | `Registro Producto` con nombre y precio; un jugo de 3 pesos; escribe `Jugo 3` | `Jugo 3` |

Enlaces: `tipos.registros`, `tipos.enumerados`, `tipos.vectores`, `tipos.diccionarios`.

**3. Escribir.** `agenda`: vector de registros `Contacto`, diccionario mes → cantidad; lee contactos y responde una búsqueda.

**4. Probar.** Buscar un nombre que está, uno que no y uno repetido (regla: se devuelve el primero).

**5. Mejorar.** Agregar «correo» a cada contacto: con registros cambia una línea; con arreglos paralelos, todo el programa.

**Resumen.**

- `{registro,campo}` Un registro agrupa datos de una misma cosa; cada dato es un campo.
- `{enumerado}` Un enumerado es un tipo con una lista cerrada de valores con nombre.
- `{vector}` Un vector es una lista que puede crecer.
- `{diccionario,clave}` Un diccionario guarda valores que se buscan por una clave.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `que-forma` | clasificar | semilla | sí | Los datos de un producto; los días de la semana; las ventas del día que van llegando; el precio de cada producto buscado por nombre; las 7 temperaturas de una semana | Registro; enumerado; vector; diccionario; arreglo |
| `votos-predecir` | predecir | semilla | — | Un diccionario: `d["Ana"] <- 3`, `d["Beto"] <- 5`, `d["Ana"] <- d["Ana"] + 1`; escribe `d["Ana"]` | `4` |
| `linea-ticket` | resolver | semilla | sí | Lee nombre, precio y cantidad de un producto, guárdalos en un registro y muestra `Jugo x 3 = 9` | Visibles y ocultos con cantidad 0 y precio 1 |
| `votacion` | resolver | brote | sí | Se votan delegados escribiendo nombres hasta `fin`. Muestra el ganador y sus votos; si hay empate, gana el primero en orden alfabético | Visibles: Ana, Beto, Ana, fin → `Ana 2`. Ocultos: empate Beto, Ana → `Ana 1`; un solo voto; `fin` directo → `Sin votos` |
| `paralelos-a-registros` | modificar | árbol | — | Un programa con arreglos paralelos de nombres y precios; reescríbelo con un vector de registros sin cambiar lo que muestra | Aserción: contiene un registro. Casos de la versión inicial |
| `buscar-telefono` | resolver | árbol | — | Lee 4 contactos (nombre, teléfono, mes) y luego un nombre; muestra su teléfono o `No está` | Ocultos: nombre ausente; nombre del último; nombre repetido |

El agente verifica en la Especificación el orden de recorrido de un diccionario antes de fijar la regla de empate de
`votacion`.

**Para docentes.** Elegir la estructura antes de mirar las preguntas; un registro con un campo por cada contacto; confundir
clave con valor.

**Siguiente.** «La inscripción a un taller pide la edad. Alguien escribe "doce", otro "-3". ¿Cómo falla bien un programa?»

---

## 2.6 Cuando algo puede fallar — `procedimental.fallos`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 35 min · semilla a árbol |
| Necesita | `procedimental.datos` |
| Introduce | `valor-opcional`, `resultado-con-error`, `propagar`, `validar` |

**Propósito.** La persona representa la falta de un valor y los errores esperables como datos, valida entradas y decide
dónde atender cada error.

**Frase.** Un programa falla bien cuando un error esperable es una respuesta con motivo, no una caída.

**Problema.** La inscripción a un taller pide la edad (de 6 a 18 años) **como texto**. Llegan respuestas como «12», «doce»,
«-3», «150» y una vacía. El programa no puede caerse y tiene que decir **por qué** rechaza cada una. **¿Cómo se escribe?**

**Inténtalo.** Decidir qué responder a cada entrada. Respuesta: aceptada; no es un número; fuera de rango; fuera de rango;
no es un número.

**Entender y planear.** Las tres preguntas. Figura `ruta-filtro-validacion`.

**Herramienta nueva.** Valor que puede faltar (`Opcional`), resultado con error (`Resultado`) y propagar (`Propagar`), con la
figura de la Especificación `tipos.opcional-resultado#opcional-resultado`. La conversión de texto a número sale de
`biblioteca.conversion`: el agente identifica la función que corresponde y cómo informa un texto inválido. Si no devuelve
`Opcional` ni `Resultado`, la lección escribe una función de validación propia y lo reporta.

| Id | Programa | Salida |
|---|---|---|
| `dividir-seguro` | `Funcion DividirSeguro(a, b)` devuelve un `Resultado`; un `Segun` muestra el valor o el motivo, con 10 y 0 | `No se puede dividir entre 0` |

Enlaces: `tipos.opcional-resultado`, `biblioteca.conversion`, `control.segun`.

**3. Escribir.** `inscripcion`: `Funcion ValidarEdad(texto) Como Resultado<Entero, Cadena>` con los dos motivos, y un
algoritmo que lee y muestra `Inscripción aceptada: 12` o `Rechazada: no es un número`.

**4. Probar.** Las cinco entradas del Inténtalo y los bordes 6 y 18.

**5. Mejorar.** Agregar un tercer motivo (`vacía`) cambia solo `ValidarEdad`.

**Resumen.**

- `{valor-opcional}` Un valor que puede faltar se representa como algo que puede no tener nada adentro.
- `{resultado-con-error,propagar}` Un resultado con error trae el valor o el motivo del fallo; propagar devuelve el error a
  quien llamó.
- `{validar}` Validar es comprobar una entrada antes de usarla.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `segun-resultado` | predecir | semilla | sí | `DividirSeguro(9, 3)` y `DividirSeguro(1, 0)` mostrados con `Segun` | `3` ⏎ `No se puede dividir entre 0` |
| `opcional-o-resultado` | clasificar | semilla | — | Buscar un contacto que puede no estar; convertir texto en número diciendo por qué falló; dividir avisando si el divisor es 0; el primer número par de una lista | Opcional: 1 y 4. Resultado: 2 y 3 |
| `division` | resolver | brote | sí | Lee dos números y muestra el cociente o `No se puede dividir entre 0` | Aserción: declara `DividirSeguro`. Visibles y ocultos con 0 en el numerador |
| `mes-romper` | romperlo | brote | sí | Una validación de mes que acepta `mes >= 0 Y mes <= 12` | Visibles: 5 → válido; 13 → inválido. Rompe: 0 |
| `fecha` | resolver | árbol | — | Lee día y mes (año no bisiesto) y muestra `válida`, `día fuera de rango` o `mes fuera de rango` | Visibles: 31, 4 → día fuera de rango; 15, 13 → mes fuera de rango. Ocultos: 29, 2 → día fuera; 31, 12 → válida; 30, 4 → válida; 0, 5 → día fuera |
| `caer-o-avisar` | explicar | semilla | — | ¿Por qué es mejor responder «no es un número» que dejar que el programa se detenga? | Opción correcta: quien lo usa sabe qué corregir y el programa sigue |

**Para docentes.** Validar demasiado tarde; un motivo genérico («error»); atender el error en el lugar equivocado.

**Siguiente.** «El programa del kiosco ya tiene 400 líneas y dos compañeros quieren trabajar a la vez. ¿Cómo se parte en
archivos?»

---

## 2.7 Programas grandes — `procedimental.modulos`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 25 min · semilla y brote |
| Necesita | `procedimental.fallos` |
| Introduce | `modulo`, `importar`, `visibilidad` |

**Propósito.** La persona parte un programa en módulos por responsabilidad, decide qué es público y entiende las
dependencias entre módulos.

**Frase.** Un módulo junta lo que cambia por el mismo motivo y muestra hacia afuera solo lo necesario.

**Problema.** El programa del kiosco tiene inventario, ventas y tickets mezclados en un solo archivo de 400 líneas. Dos
compañeros quieren trabajar a la vez, y un subprograma `Total` del ticket choca con otro `Total` de las ventas. **¿Cómo se
reparte en partes que no se pisen?**

**Inténtalo.** Agrupar diez nombres de subprogramas del kiosco en tres montones.

**Entender y planear.** Las tres preguntas. Figura `ruta-kiosco-modulos`: dependencias sin ciclos.

**Herramienta nueva.** Módulo, importar y visibilidad con la figura de la Especificación `programas.modulos#paquete-modulos`.
Enlaces: `programas.modulos`, `programas.estructura`.

**3. Escribir.** Si el compilador ejecuta proyectos de varios módulos (lo comprueba el agente con la sección
`programas.modulos`), un proyecto `kiosco-modulos` con `inventario`, `ventas` y `principal`. Si no, la lección muestra la
estructura con la figura y bloques de código no ejecutados (`programa` sin `ejecutar`), y se declara como pendiente.

**4. Probar.** Cada módulo se prueba solo, a través de lo que exporta.

**5. Mejorar.** Mover un subprograma auxiliar a privado no rompe a nadie; volverlo público lo convierte en un compromiso.

**Resumen.**

- `{modulo,importar}` Un módulo es un archivo con una responsabilidad; importar es usar lo que otro módulo ofrece.
- `{visibilidad}` La visibilidad decide qué se puede usar desde afuera: lo público es un compromiso, lo privado se puede
  cambiar.

**Ejercicios.** Ninguno ejecuta código de la persona (excepción de 03 §6.1).

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `a-que-modulo` | clasificar | semilla | sí | Ubicar `AgregarStock`, `QuitarStock`, `Importe`, `ConDescuento`, `LineaDeTicket`, `CerrarTicket` en inventario, ventas o tickets | Inventario: 1, 2. Ventas: 3, 4. Tickets: 5, 6 |
| `publico-privado` | clasificar | brote | sí | Del módulo de ventas: `Vender`, `ConDescuento`, `RedondearCentavos` (auxiliar), `ValidarCodigo` (auxiliar) | Público: 1, 2. Privado: 3, 4 |
| `orden-dependencias` | ordenar | brote | sí | Ordenar los módulos de modo que cada uno solo use a los anteriores | `inventario`, `ventas`, `tickets`, `principal` (orden exacto de la cerca `pasos`) |
| `un-archivo` | comparar | semilla | — | Un archivo grande o varios módulos, para dos personas que trabajan a la vez | Módulos; justificación por opción |
| `ciclo` | explicar | brote | — | Si `ventas` importa `tickets` y `tickets` importa `ventas`, ¿qué problema hay? | Dependencia circular: ninguno se entiende sin el otro |

**Para docentes.** Módulos por tipo de construcción en vez de por responsabilidad; todo público.

**Siguiente.** «Hora de rehacer el kiosco con todo esto.»

---

## P·II Proyecto: el kiosco en partes — `procedimental.proyecto`

| Campo | Valor |
|---|---|
| Tipo | `proyecto` · 60 min · árbol |
| Necesita | `procedimental.modulos` |

**Propósito.** Rehacer la caja con subprogramas, funciones puras, registros y errores con motivo, sobre un solo archivo.

**Problema.** La caja ahora también lleva el **stock**. Cada producto empieza con un stock conocido: jugo 10, sándwich 5,
alfajor 8, agua 12, fruta 6. Una venta que pide más de lo que queda se **rechaza con su motivo**, igual que un código que no
existe. Al cerrar se muestran el ticket, el total con descuento y el **stock que queda** de cada producto. **¿Cómo es la caja
nueva?**

**Inténtalo.** Ventas 1 × 3, 2 × 6, 2 × 5, 9 × 1, fin. Respuesta: jugo aceptado (quedan 7); sándwich × 6 rechazado (solo hay
5); sándwich × 5 aceptado (quedan 0); código 9 inválido. Total 9 + 25 = 34; con descuento 31.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `kiosco-ficha` | clasificar | árbol | sí | Ubicar cada dato del enunciado | Como en P·I, con el stock inicial como dato fijo y el stock final como salida |
| `kiosco-arbol` | clasificar | árbol | sí | Ubicar ocho tareas en las ramas de un árbol de descomposición dado (leer venta, validar, calcular importe, actualizar stock, escribir línea, descuento, cierre, stock final) | Según el árbol del enunciado |
| `kiosco-plan` | ordenar | árbol | sí | Ordenar los pasos del plan en lenguaje natural: preparar el stock inicial; leer el primer código; mientras no sea 0: validar código, leer cantidad, validar stock, descontar stock y acumular, escribir la línea o el rechazo, leer el siguiente; calcular el descuento; escribir el cierre y el stock final | Orden exacto |
| `kiosco-partes` | resolver | árbol | sí | El programa completo | Las aserciones «al menos tres funciones puras y un registro» no existen en el catálogo cerrado de aserciones de la app; se reemplazan por la `restriccion` escrita y por casos que distinguen (un rechazo por stock y uno por código en el mismo día, con el motivo exacto en la salida). Ocultos: venta que deja el stock en 0 justo; venta de 0 unidades; todo rechazado; día sin ventas |
