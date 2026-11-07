# 10 — Unidad 0: Empezar de cero

**Propósito de la unidad:** que alguien que nunca programó pueda llevar un problema chico de la vida real hasta un
programa que lo resuelve, sabiendo comprobar si está bien. Cuatro lecciones, unos 80 minutos.

Las fichas siguen siempre el mismo orden. Los programas están en perfil español con `Algoritmo`. Las salidas son
derivadas a mano y se verifican con el motor (`RA-NUMBERS-ORACLE`). En la columna «Obl.», «sí» marca los ejercicios
obligatorios.

---

## 0.1 Tu primer problema — `inicio.primer-problema`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 15 min · niveles semilla a árbol |
| Necesita | — |
| Introduce | `problema`, `ejemplo-a-mano`, `programa`, `instruccion`, `ejecutar`, `salida`, `funcion-ya-hecha`, `ciclo-pseudolearn` |
| Pieza | 1 |
| Menciones cotidianas | `clase` («la clase de quinto») |
| Muestra | `docs/ruta-aprendizaje-ejemplos/0-1-tu-primer-problema.html` (tono y ejercicios; cambiar `Proceso` por `Algoritmo`) |

**Propósito.** Al terminar, la persona sabe que programar empieza por entender el problema, conoce los cinco pasos del
ciclo y ejecutó un programa que resuelve algo real.

**Por qué así.** La ruta anterior abría con definiciones y mencionaba la máquina nocional sin explicarla. Esta lección no
menciona memoria, variables ni tipos: solo instrucciones que se ejecutan en orden.

**Frase.** Programar es resolver un problema y después explicarle la solución a una computadora con tanta claridad que no
pueda equivocarse.

**Problema.** La clase de quinto organiza la fiesta de fin de curso en el kiosco de la escuela. Van **23 personas**. Cada
una come **3 porciones** de pizza, y cada pizza trae **8 porciones**. **¿Cuántas pizzas hay que pedir?**

**Inténtalo.** Resolverlo con lápiz y papel. Respuesta: 69 porciones; 8 pizzas dan 64, faltan 5; hay que pedir **9**. Si
dijiste 8, cinco personas se quedan sin comer; si dijiste 8,6, no se piden decimales de pizza.

**Definición de problema** (párrafo tras la respuesta): datos conocidos y una pregunta sin respuesta todavía.

**El ciclo PseudoLearn.** Figura `ruta-ciclo` y tabla de las cinco preguntas (muestra).

**1. Entender.** Lo que se sabe, lo que se pide, el detalle de que las pizzas se piden **enteras**. Definición de ejemplo
a mano. Tabla con dos ejemplos: 23 personas → 69 → 8 y sobran 5 → 9; 8 personas → 24 → 3 exactas → 3. El segundo enseña
que, si la división es exacta, no se pide una pizza de más.

**2. Planear.** Multiplicar personas por porciones; dividir entre 8; si hay decimales, redondear hacia arriba.

**3. Escribir.** Definición de programa e instrucción; ejecución de arriba abajo (figura `ruta-instrucciones-en-orden`,
pieza 1). Programas:

| Id | Programa | Salida |
|---|---|---|
| `hola` | `Algoritmo Hola` · `Escribir "Hola";` · `Escribir 2 + 3;` · `Escribir "2 + 3";` | `Hola` ⏎ `5` ⏎ `2 + 3` |
| `fiesta-1` | `Escribir "Porciones que hacen falta: ", 23 * 3;` · `Escribir "Pizzas: ", 23 * 3 / 8;` | `Porciones que hacen falta: 69` ⏎ `Pizzas: 8.625` |
| `fiesta-2` | igual, con `techo(23 * 3 / 8)` en la segunda línea | `… 69` ⏎ `Pizzas que hay que pedir: 9` |
| `fiesta-8` | `Escribir "Pizzas que hay que pedir: ", techo(8 * 3 / 8);` | `Pizzas que hay que pedir: 3` |

Puntos que explica la prosa: `Algoritmo` y `FinAlgoritmo` son el sobre del programa; `Escribir` produce la salida; entre
comillas se muestra tal cual y sin comillas se calcula; cada instrucción termina en `;`; `Escribir` puede mostrar varias
cosas separadas por comas; `techo` es una función ya hecha que devuelve el entero de arriba. La computadora hizo
exactamente lo pedido con `fiesta-1`: dividir.

Enlaces: `programas.estructura`, `biblioteca.consola`, `expresiones.aritmeticos`, `biblioteca.matematicas`.

**4. Probar.** Comparar con los dos ejemplos a mano (9 ✓, 3 ✓). El de 8 personas es el importante.

**5. Mejorar.** En una frase: «calcula cuántas pizzas enteras alcanzan para que todos coman». Cambio de requisito: 30
personas que comen 2 porciones obligan a buscar números dentro de las instrucciones. Ese problema queda abierto.

**Resumen.**

- `{problema}` Un problema tiene datos conocidos y una pregunta; antes de programar se lee la pregunta con cuidado.
- `{ejemplo-a-mano}` Un ejemplo a mano es un caso resuelto con lápiz y papel; sirve para descubrir la solución y para
  comprobarla.
- `{programa,instruccion,ejecutar}` Un programa es una lista de instrucciones que la computadora ejecuta de arriba abajo,
  exactamente como están escritas.
- `{salida}` La salida es lo que el programa muestra; entre comillas se muestra tal cual y lo demás se calcula.
- `{funcion-ya-hecha}` Una función ya hecha, como `techo`, recibe un valor y devuelve otro.
- `{ciclo-pseudolearn}` El ciclo PseudoLearn: entender, planear, escribir, probar y mejorar.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `que-aparece` | predecir | semilla | sí | ¿Qué muestra `Escribir "10 / 4";` y `Escribir 10 / 4;`? | `10 / 4` ⏎ `2.5` |
| `mesas` | resolver | semilla | sí | Las 23 personas se sientan en mesas de 4 sillas. ¿Cuántas mesas hay que armar para que nadie quede de pie? | Caso único: `6`. Variante: mesas de 6 → 4 |
| `bus-excursion` | encontrar-error | brote | sí | 95 alumnos, buses de 40 asientos. El compañero escribió `Escribir "Buses: ", 95 div 40;` y dice que hacen falta 2. ¿Tiene razón? Corrígelo | Inicial muestra `Buses: 2`; referencia con `techo(95 / 40)` muestra `Buses: 3`. Pista 2 enlaza `expresiones.division` |
| `ana-y-beto` | comparar | brote | — | Ana escribió `techo(23 * 3 / 8)` y Beto `23 * 3 div 8 + 1`; con 23 personas los dos dan 9. ¿Con cuál de estas cantidades de personas dan distinto: 23, 16, 30 o 47? | 16 (48 porciones: Ana 6, Beto 7). Explicación: cuando la división es exacta, Beto pide una de más; todo múltiplo de 8 lo rompe |
| `ascensor` | explicar | semilla | — | ¿Qué resuelve `Escribir techo(130 / 50);`? Opciones: dividir 130 entre 50; cuántos viajes hace un ascensor de 50 kilos para subir 130 kilos de libros; cuántas veces cabe 50 en 130 | La segunda. La primera describe cómo, no qué; la tercera es falsa (cabe 2 veces, el programa muestra 3) |
| `pintar-aula` | resolver | árbol | — | Las paredes suman 54 metros cuadrados; hay que dar dos manos; un litro cubre 10 metros cuadrados; la pintura viene en latas de 4 litros. ¿Cuántas latas hay que comprar? | Caso único: `3`. Variante: ¿cuántos litros sobran? (1.2) |

**Para docentes.** «La computadora entiende lo que quise decir» (usar `fiesta-1`); comillas olvidadas (el mensaje habla de
variables: decir solo «faltan las comillas»); saltarse los ejemplos a mano (el de 8 personas rompe a Beto).

**Bajo el capó.** Una frase y enlace a `vision.viaje`.

**Siguiente.** «¿Cómo escribir la fiesta para que cambiar la cantidad de invitados sea cambiar un solo número?»

---

## 0.2 Darle nombre a los datos — `inicio.nombres`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 20 min · semilla a árbol |
| Necesita | `inicio.primer-problema` |
| Introduce | `variable`, `valor`, `memoria`, `tipo-de-dato`, `declarar`, `asignar`, `division-entera` |
| Pieza | 2 |

**Propósito.** La persona guarda datos con nombre, entiende que la memoria son cajas cuyo valor se reemplaza al asignar y
reparte cantidades con cociente y resto.

**Por qué así.** Las variables llegan cuando el problema anterior las pide: cambiar un dato en un solo lugar. La idea de
que una caja **no se recalcula sola** se enseña con una figura, porque es la confusión más común de quien conoce las hojas
de cálculo.

**Frase.** Un programa recuerda datos guardándolos en cajas con nombre, y cada caja tiene un solo valor a la vez.

**Problema.** El kiosco anota cuántos invitados confirman: el lunes 23, el martes 30 y el miércoles 27. Cada uno come 3
porciones y cada pizza trae 8. El encargado quiere un programa donde, para cada día, **cambiar la cantidad de invitados
sea cambiar un solo número**. **¿Cómo tiene que estar escrito?**

**Inténtalo.** «Cuenta cuántas veces aparece el 23 en el programa de la fiesta de la lección anterior. ¿Qué pasa si
cambias uno y te olvidas de otro?» Respuesta: aparece dos veces en `fiesta-2`; si se cambia uno solo, las porciones dicen
una cosa y las pizzas otra. Hace falta un nombre para el dato.

**1. Entender.** Datos que cambian (invitados) y datos fijos (3 y 8). La pregunta es de diseño: dónde se escribe cada
dato. Ejemplos a mano: 23 → 9, 30 → techo(90/8 = 11,25) = 12, 27 → techo(81/8 = 10,125) = 11.

**2. Planear.** Escribir cada dato una sola vez, con un nombre; calcular a partir de los nombres.

**Herramienta nueva.** Definición de memoria, variable, valor, declarar y asignar. Figura de la Especificación
`declaraciones.definir#cajas-variables`. Tipo de dato: `Entero`, `Real` y `Cadena` (el lógico llega en 1.1). Programa
mínimo distinto de la solución:

| Id | Programa | Salida |
|---|---|---|
| `cumple` | `Definir edad Como Entero <- 10;` · `Escribir edad;` · `edad <- edad + 1;` · `Escribir edad;` | `10` ⏎ `11` |

La prosa explica `edad <- edad + 1`: no es una ecuación, es «calcula con el valor viejo y guarda el nuevo». Figura de la
Especificación `declaraciones.asignacion#intercambio`.

Segunda herramienta, repartir: `div` da cuántos enteros caben y `mod` lo que sobra.

| Id | Programa | Salida |
|---|---|---|
| `caramelos` | `Escribir 47 div 6, " ", 47 mod 6;` | `7 5` |

Figura de la Especificación `expresiones.division#reparto`. Enlaces: `declaraciones.definir`, `tipos.primitivos`,
`declaraciones.asignacion`, `expresiones.division`.

**3. Escribir.**

| Id | Programa | Salida |
|---|---|---|
| `fiesta-nombres` | `Definir invitados Como Entero <- 23;` · `Definir porcionesPorPersona Como Entero <- 3;` · `Definir porcionesPorPizza Como Entero <- 8;` · `Definir porciones Como Entero <- invitados * porcionesPorPersona;` · `Escribir "Pizzas que hay que pedir: ", techo(porciones / porcionesPorPizza);` | `Pizzas que hay que pedir: 9` |

Nombres que dicen qué guardan: la prosa compara `p` con `porcionesPorPizza`.

**4. Probar.** Cambiar solo la primera línea a 30 y a 27: 12 y 11, iguales a los ejemplos a mano. Figura
`ruta-caja-no-se-recalcula`: si se cambia `invitados` **después** de calcular `porciones`, `porciones` no cambia.

**5. Mejorar.** En una frase. Problema abierto: cada día hay que abrir el programa y editarlo; el encargado no programa.

**Resumen.**

- `{variable,valor,memoria}` La memoria son cajas con nombre; cada variable guarda un valor a la vez.
- `{declarar,tipo-de-dato}` Declarar crea la caja y fija su tipo de dato: `Entero`, `Real` o `Cadena`.
- `{asignar}` Asignar reemplaza el valor anterior, que se pierde; una caja no se recalcula sola.
- `{division-entera}` `div` dice cuántas veces cabe un número entero en otro y `mod` cuánto sobra.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `cajas` | predecir | semilla | sí | `a <- 5; b <- a; a <- 7; Escribir a, " ", b;` (con sus `Definir`) | `7 5` |
| `que-tipo` | clasificar | semilla | — | Ubicar cada valor en su tipo: `23`, `2.5`, `"Lucía"`, `0`, `"23"`, `8.0` | Entero: 23, 0. Real: 2.5, 8.0. Cadena: "Lucía", "23" (la trampa: entre comillas es texto) |
| `figuritas` | encontrar-error | brote | sí | Ana tiene 12 figuritas y Beto 7. Quieren intercambiar sus montones. El programa del compañero muestra que los dos terminan con 7. Corrígelo | Inicial: `ana <- beto; beto <- ana;` → `Ana: 7 Beto: 7`. Referencia con una caja auxiliar → `Ana: 7 Beto: 12` |
| `reparto-caramelos` | resolver | semilla | sí | Hay 47 caramelos para 6 amigos. Todos reciben la misma cantidad y lo que no alcanza queda en la bolsa. Muestra exactamente: `Cada amigo recibe 7 y sobran 5` | Caso único con esa salida |
| `cronometro` | resolver | árbol | — | El cronómetro marca 3725 segundos. Muéstralo como `1 h 2 min 5 s` | Caso único: `1 h 2 min 5 s`. Variante: 90061 segundos con días (`1 d 1 h 1 min 1 s`) |
| `buen-nombre` | explicar | semilla | — | ¿Qué nombre conviene a la caja que guarda cuántas porciones trae una pizza? `p`, `x`, `porcionesPorPizza`, `numero` | `porcionesPorPizza`; las otras no dicen qué guardan |

**Para docentes.** «La variable se actualiza sola como en una planilla» (figura de recálculo); «`x <- x + 1` es imposible»
(leerlo como «nuevo x es viejo x más 1»); «`"23"` es un número» (`que-tipo`).

**Siguiente.** «Para cada fiesta todavía hay que abrir el programa y cambiar un número. ¿Y si quien lo usa no sabe
programar?»

---

## 0.3 Preguntar antes de calcular — `inicio.preguntar`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 20 min · semilla a árbol |
| Necesita | `inicio.nombres` |
| Introduce | `entrada`, `leer-dato`, `ficha-del-problema` |

**Propósito.** La persona escribe programas que reciben sus datos al ejecutarse y analiza un problema con la ficha
(entra, sale, relación y ejemplos a mano) antes de escribir.

**Por qué así.** La ficha es la primera herramienta formal del ciclo. Se presenta cuando el problema la necesita: con
datos que llegan de afuera, conviene escribir qué entra y qué sale antes de pensar en el código.

**Frase.** Un programa útil no trae sus datos escritos adentro: los pregunta cada vez que se ejecuta.

**Problema.** Un grupo de amigos come en el comedor. A la cuenta le suman un 10 % de propina, y lo dividen en partes
iguales. Como nadie lleva monedas, cada uno paga un número **entero** de pesos, redondeando hacia arriba para que alcance.
La cuenta y la cantidad de amigos cambian cada vez. **¿Cuánto paga cada uno?**

**Inténtalo.** Calcular para una cuenta de 120 y 4 amigos. Respuesta: propina 12, total 132, cada uno **33**.

**1. Entender.** Figura `ruta-ficha` (ancla) y definición de ficha del problema. Ficha:

- Entra: la cuenta (pesos enteros) y la cantidad de amigos.
- Sale: lo que paga cada uno.
- Relación: total = cuenta + su décima parte; cada uno paga el total entre los amigos, redondeado hacia arriba.
- Ejemplos a mano: 120 y 4 → 33; 100 y 3 → total 110 → 36,67 → 37; 100 y 1 → 110.

La propina se calcula como `cuenta div 10` para trabajar con enteros. «Profundizar»: por qué no se usa `cuenta * 1.1`
(los reales no son exactos; enlace a `tipos.primitivos`).

**2. Planear.** Preguntar la cuenta; preguntar los amigos; calcular el total; dividir y redondear hacia arriba; mostrar.

**Herramienta nueva.** Definición de entrada y de leer un dato. Figura de la Especificación `biblioteca.consola#leer-escribir`.

| Id | Programa | Entrada | Salida |
|---|---|---|---|
| `saludo` | `Definir nombre Como Cadena;` · `Escribir "¿Cómo te llamas?";` · `Leer nombre;` · `Escribir "Hola, ", nombre;` | `Lucía` | `¿Cómo te llamas?` ⏎ `Hola, Lucía` |

Enlace: `biblioteca.consola`.

**3. Escribir.**

| Id | Programa | Entrada | Salida |
|---|---|---|---|
| `propina` | Pide la cuenta y los amigos con mensajes, `Definir total Como Entero <- cuenta + cuenta div 10;`, `Escribir "Cada uno paga: ", techo(total / amigos);` | `120` ⏎ `4` | `¿Cuánto es la cuenta?` ⏎ `¿Cuántos amigos pagan?` ⏎ `Cada uno paga: 33` |

**4. Probar.** Tabla con los tres ejemplos de la ficha y la salida del programa: 33, 37, 110. Observación sobre 37: tres
amigos pagan 111, uno más que el total; el redondeo hacia arriba siempre deja algo de más.

**5. Mejorar.** En una frase. Problema abierto: «¿Y si alguien escribe 0 amigos?». No se ejecuta en esta lección; se
anuncia como la pregunta de la siguiente.

**Resumen.**

- `{entrada,leer-dato}` Leer un dato detiene el programa hasta que alguien escribe un valor, y lo guarda en una variable.
- `{ficha-del-problema}` La ficha del problema anota qué entra, qué sale, la relación entre ambos y ejemplos a mano.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `orden-inverso` | predecir | semilla | — | Programa que lee `a` y `b` y escribe `b, " ", a`, con entradas 4 y 9 | `9 4` |
| `en-2030` | resolver | semilla | sí | Lee el año en que naciste y muestra cuántos años cumplirás en 2030 | Visibles: 2015 → 15; 2010 → 20. Ocultos: 2030 → 0; 1990 → 40; 2016 → 14 |
| `ficha-vuelto` | clasificar | semilla | sí | Enunciado: «El kiosco vende alfajores a 2 pesos. Un cliente paga con un billete y compra algunos alfajores. El kiosco abre a las 8. ¿Cuánto vuelto recibe?». Ubicar: precio del alfajor, billete, cantidad de alfajores, vuelto, hora de apertura | Entra: billete, cantidad. Sale: vuelto. Dato fijo: precio. No importa: hora de apertura |
| `vuelto` | resolver | brote | sí | El mismo problema: lee el billete y la cantidad, y muestra el vuelto | Visibles: 10 y 3 → 4; 20 y 10 → 0. Ocultos: 5 y 2 → 1; 100 y 1 → 98; 2 y 1 → 0 |
| `bici` | resolver | árbol | — | Lee la distancia en kilómetros y la velocidad en kilómetros por hora, y muestra cuántos minutos tarda, redondeando hacia arriba | Visibles: 10 y 15 → 40; 7 y 20 → 21. Ocultos: 3 y 9 → 20; 1 y 7 → 9; 5 y 12 → 25 |
| `que-calcula` | explicar | semilla | — | Programa que lee dos números y escribe su producto. Opciones: multiplica; el área de un rectángulo dados su largo y su ancho; suma dos números | La segunda (habla del problema). La tercera es falsa |

**Para docentes.** Leer con un tipo equivocado (escribir «doce» para un `Entero`); olvidar `Leer` y usar la variable;
pensar que `Leer` muestra algo.

**Siguiente.** «Tu compañero probó la calculadora de propinas con 0 amigos y algo salió muy mal. ¿Qué tipos de errores
existen y cómo se encuentran antes de que los encuentre otro?»

---

## 0.4 Cuando algo sale mal — `inicio.errores`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 25 min · semilla a árbol |
| Necesita | `inicio.preguntar` |
| Introduce | `error-de-compilacion`, `error-de-ejecucion`, `error-de-logica`, `diagnostico`, `caso-de-prueba`, `caso-borde` |

**Propósito.** La persona distingue las tres clases de error, lee un diagnóstico y diseña casos de prueba (normal, borde
y raro) para encontrar errores de lógica, que nadie más le va a señalar.

**Por qué así.** Probar es la fase del ciclo que más se saltea. Va antes de las decisiones y los bucles, para que desde
la Parte I cada lección tenga casos borde en su ficha.

**Frase.** Un programa puede fallar de tres maneras, y la más peligrosa es la que no da ningún aviso.

**Problema.** Tu compañero escribió tres versiones de la calculadora de propinas. Con la primera, el motor ni siquiera
la acepta. La segunda funciona hasta que alguien escribe 0 amigos. La tercera siempre muestra un número, pero con
cuenta 120 y 4 amigos dice que cada uno paga 3. **¿Qué le pasa a cada una y cómo lo hubieras descubierto tú?**

**Inténtalo.** Leer las tres versiones (programas `propina-a`, `propina-b`, `propina-c` de §3) y anotar qué sospechas de
cada una. Respuesta: a le falta un `;`; b divide entre 0; c calcula solo la propina (`cuenta div 10`) y olvidó sumar la
cuenta.

**1. Entender.** Qué se pide: clasificar fallas y encontrar un método para descubrirlas.

**2. Planear.** Para cada versión: ¿el motor la acepta? ¿termina? ¿lo que muestra coincide con el ejemplo a mano?

**Herramienta nueva.** Definiciones de error al compilar, al ejecutar y de lógica, con la figura `ruta-tres-errores`.
Diagnóstico: cómo se lee (lugar, código, mensaje) con la figura de la Especificación
`diagnosticos.anatomia#anatomia-diagnostico`. Enlaces: `vision.errores`, `diagnosticos.anatomia`, `vision.terminacion`.

**3. Escribir.** No hay solución nueva: se ejecutan las tres versiones.

| Id | Qué tiene | Resultado esperado |
|---|---|---|
| `propina-a` | La versión de 0.3 sin el `;` de una línea | No compila; el agente copia el código y la posición reales del diagnóstico |
| `propina-b` | La versión de 0.3, con entrada 100 y 0 | Falla al ejecutar con `divisionByZero` |
| `propina-c` | `Definir total Como Entero <- cuenta div 10;` | Con 120 y 4 muestra `Cada uno paga: 3` |

**4. Probar.** Definición de caso de prueba y de caso borde. Figura `ruta-recta-casos`: normal (120 y 4 → 33), borde (100
y 1 → 110), raro (100 y 0). Tabla que pasa los tres casos por las versiones b y c: el caso normal descubre c; el raro
descubre b.

**5. Mejorar.** El caso raro todavía no tiene arreglo: hace falta que el programa decida. Queda abierto.

**Resumen.**

- `{error-de-compilacion,error-de-ejecucion,error-de-logica}` Un error al compilar impide empezar; uno al ejecutar detiene
  el programa en el camino; uno de lógica da un resultado equivocado sin aviso.
- `{diagnostico}` Un diagnóstico dice dónde está el problema, con un código y un mensaje.
- `{caso-de-prueba,caso-borde}` Un caso de prueba es una entrada con su salida esperada; un caso borde está justo en el
  límite donde un programa apurado se equivoca.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `tres-cajones` | clasificar | semilla | sí | Cinco descripciones: «el motor marca la línea 4 antes de empezar»; «muestra 3 cuando debía mostrar 33»; «se detiene al dividir»; «falta cerrar unas comillas»; «calcula el promedio con la nota de Ana en lugar de la de Beto» | Compilar: 1 y 4. Ejecutar: 3. Lógica: 2 y 5 |
| `se-detiene` | predecir | semilla | — | `Escribir "Hola"; Escribir 10 div 0; Escribir "Chau";` | Solo `Hola`. Explicación: el programa se detiene en la segunda línea y la tercera nunca se ejecuta |
| `promedio-dos` | encontrar-error | brote | sí | El programa lee dos notas y muestra su promedio. Con 7 y 8 muestra 7 | Inicial con `div 2`; referencia con `/ 2`. Visibles: 7 y 8 → 7.5; 6 y 6 → 6.0. Ocultos: 10 y 9 → 9.5; 0 y 1 → 0.5; 5 y 8 → 6.5 |
| `buses-romper` | romperlo | brote | sí | Un programa calcula los buses de 40 asientos con `alumnos div 40 + 1`. Con 95 alumnos dice 3, que es correcto. Encuentra una cantidad de alumnos con la que se equivoque | Referencia `techo(alumnos / 40)`. Visible: 95 → 3. Rompe: 80, 40, 120 |
| `buses-pruebas` | disenar-pruebas | árbol | — | Escribe entre 2 y 4 casos para el programa de buses, de modo que cualquier versión equivocada falle alguno | Mutantes: `alumnos div 40`, `alumnos div 40 + 1`, `redon(alumnos / 40)`. Solución: 95 → 3 y 80 → 2 |
| `donde-arreglo` | explicar | semilla | — | Diagnóstico de `propina-a`. ¿Dónde se arregla? Opciones: en la línea y columna que indica; en la primera línea del programa; en cualquier `Escribir` | La primera |

**Para docentes.** «Si compila, está bien» (`propina-c`); «el error está en la línea que marca el motor» (a veces está
justo antes: mostrarlo con `propina-a`); probar solo con el ejemplo del enunciado.

**Siguiente.** «Hasta ahora, cada programa hace siempre lo mismo. ¿Y si, según el dato, hay que hacer cosas distintas,
como avisar que no se puede dividir entre 0 amigos?»
