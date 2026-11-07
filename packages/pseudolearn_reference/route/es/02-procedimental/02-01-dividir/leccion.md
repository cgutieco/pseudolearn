---
id: procedimental.dividir
numero: "2.1"
tipo: apertura
titulo: Dividir el problema
duracion: 35
problema_breve: El boletín de la profesora
necesita: [imperativo.proyecto]
introduce: [programacion-procedimental, descomposicion, arbol-de-descomposicion, subprograma, llamada, parametro, valor-de-retorno]
usa: [paradigma, programacion-imperativa, mejor-hasta-ahora, ficha-del-problema, caso-borde]
---

::: frase
Un problema grande se vuelve fácil cuando se parte en problemas chicos, cada uno con su nombre.
:::

## El problema {#problema}

::: problema
La profesora tiene las tres notas de cada uno de sus **4 alumnos**. Quiere un boletín con el **promedio** de cada alumno, si **aprobó** (promedio de 6 o más) y quién tuvo el **mejor promedio**.

**¿Cómo se organiza un programa así sin perderse?**
:::

## Inténtalo {#intentalo}

::: intento
Calcula a mano el boletín con estas notas: Ana 8, 9 y 10; Beto 5, 6 y 4; Caro 6, 6 y 6; Dani 7, 8 y 6.
:::

::: respuesta
Los promedios son 9, 5, 6 y 7. Aprueban Ana, Caro y Dani; Caro justo en el borde, con 6. El mejor promedio es el de Ana.

Fíjate en cómo lo hiciste: no pensaste el boletín de una vez. Primero promediaste, después decidiste quién aprobaba y al final buscaste el mejor.
:::

## Un paradigma nuevo {#paradigma}

Hasta ahora escribiste programas como una sola lista de órdenes. La [[def:programacion-procedimental|programación procedimental]] arma un programa con piezas más chicas, cada una con un nombre y una tarea, que se piden ayuda unas a otras.

::: paradigma
- pregunta: ¿y si un programa grande se armara con piezas chicas, cada una con un nombre y una tarea?
- metafora: un libro de recetas que dice «prepara la salsa (página 12)». Deja de valer en un punto: una pieza de programa recibe datos distintos cada vez que se la usa.
- historia: en 1949, en la computadora EDSAC de Cambridge, David Wheeler ideó cómo saltar a un trozo de programa y volver, la base de los subprogramas. En 1960, ALGOL 60 los formalizó con parámetros.
- costo: hay que decidir dónde cortar y qué datos pasar a cada pieza.
:::

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Entran el nombre y las tres notas de cada alumno; salen una línea por alumno y el mejor promedio.
- **¿A qué se parece?** El promedio es la alcancía de [la lección 1.3](ruta:imperativo.mientras); el mejor es el mejor hasta ahora de [la lección 1.4](ruta:imperativo.contado).
- **¿En qué partes se divide?** Se divide en cuatro tareas que se pueden pensar por separado.

Partir un problema en subproblemas es una [[def:descomposicion|descomposición]]. Dibujada de lo general a lo particular, es un [[def:arbol-de-descomposicion|árbol de descomposición]]:

```figura id=ruta-arbol-boletin
pie: Cada rama es un problema más chico que se resuelve por separado.
paso: El problema completo: el boletín.
paso: Se parte en cuatro tareas: leer las notas, calcular el promedio, decidir el estado y buscar el mejor.
paso: Cada tarea es tan chica que ya sabes resolverla.
```

## La herramienta nueva {#herramienta}

Un [[def:subprograma|subprograma]] es un trozo de programa con nombre. Pedirle que se ejecute es hacer una [[def:llamada|llamada]]. Los datos que recibe son sus [[def:parametro|parámetros]], y lo que devuelve es su [[def:valor-de-retorno|valor de retorno]], que se indica con `Retornar`.

```figura-especificacion seccion=subprogramas.declaracion figura=subprograma-caja
```

```programa id=doble titulo="El doble" ejecutar
SubProceso Doble(x Como Entero) Como Entero
  Retornar x * 2;
FinSubProceso

Algoritmo Principal
  Escribir Doble(21);
FinAlgoritmo
```

```salida
42
```

El subprograma se escribe antes del algoritmo principal. La llamada `Doble(21)` le pasa 21 como `x`, y en su lugar queda lo que retorna.

::: especificacion
- subprogramas.declaracion
- subprogramas.parametros
- subprogramas.llamada
- subprogramas.retornar
:::

## Escribir {#escribir fase=3}

```programa id=boletin titulo="El boletín" ejecutar
SubProceso Promedio(a Como Entero, b Como Entero, c Como Entero) Como Real
  Retornar (a + b + c) / 3;
FinSubProceso

SubProceso Estado(promedio Como Real) Como Cadena
  Si promedio >= 6 Entonces
    Retornar "aprobado";
  FinSi
  Retornar "desaprobado";
FinSubProceso

Algoritmo Boletin
  Definir nombre Como Cadena;
  Definir n1, n2, n3 Como Entero;
  Definir mejorNombre Como Cadena <- "";
  Definir mejorPromedio Como Real <- -1.0;
  Para i <- 1 Hasta 4 Hacer
    Leer nombre;
    Leer n1;
    Leer n2;
    Leer n3;
    Definir p Como Real <- Promedio(n1, n2, n3);
    Escribir nombre, ": ", p, " ", Estado(p);
    Si p > mejorPromedio Entonces
      mejorPromedio <- p;
      mejorNombre <- nombre;
    FinSi
  FinPara
  Escribir "Mejor promedio: ", mejorNombre;
FinAlgoritmo
```

```entrada
Ana
8
9
10
Beto
5
6
4
Caro
6
6
6
Dani
7
8
6
```

```salida
Ana: 9.0 aprobado
Beto: 5.0 desaprobado
Caro: 6.0 aprobado
Dani: 7.0 aprobado
Mejor promedio: Ana
```

El algoritmo principal se lee casi como el árbol: lee, promedia, decide y busca el mejor. Los detalles de cada tarea están en su subprograma.

## Probar {#probar fase=4}

Cada subprograma se puede probar solo, antes que el boletín completo:

```programa id=probar-partes titulo="Probar cada parte" ejecutar
SubProceso Promedio(a Como Entero, b Como Entero, c Como Entero) Como Real
  Retornar (a + b + c) / 3;
FinSubProceso

SubProceso Estado(promedio Como Real) Como Cadena
  Si promedio >= 6 Entonces
    Retornar "aprobado";
  FinSi
  Retornar "desaprobado";
FinSubProceso

Algoritmo Pruebas
  Escribir Promedio(6, 6, 6);
  Escribir Estado(6.0);
  Escribir Estado(5.9);
FinAlgoritmo
```

```salida
6.0
aprobado
desaprobado
```

`Estado(6.0)` y `Estado(5.9)` son los dos lados del borde. Después, el boletín completo con los datos de la consigna da lo mismo que tu ejemplo a mano.

## Mejorar {#mejorar fase=5}

En una frase: «El programa calcula el promedio y el estado de cada alumno con dos subprogramas y recuerda el mejor».

La escuela sube la nota para aprobar a 7. Cambia una sola línea, dentro de `Estado`, y el resto del programa no se entera.

| | Una sola lista de órdenes | Con subprogramas |
|---|---|---|
| Para entenderlo | se lee todo de arriba abajo | se lee el principal y se entra a cada parte cuando hace falta |
| Para probarlo | solo el programa entero | cada parte por separado |
| Para cambiarlo | se busca en todo el programa | se cambia una parte |

## Lo que aprendiste {#aprendiste}

::: resumen
- {programacion-procedimental} La programación procedimental arma un programa con subprogramas que se llaman entre sí.
- {descomposicion,arbol-de-descomposicion} Descomponer es partir un problema en subproblemas; el árbol de descomposición los dibuja de lo general a lo particular.
- {subprograma,llamada} Un subprograma es un trozo de programa con nombre; llamarlo es pedirle que se ejecute.
- {parametro,valor-de-retorno} Los parámetros son los datos que recibe; el valor de retorno es lo que devuelve.
:::

## Practica {#practica}

::: practica
- procedimental.dividir.excursion
- procedimental.dividir.sumar-tres
- procedimental.dividir.area
- procedimental.dividir.propina-partes
- procedimental.dividir.buen-nombre-sub
- procedimental.dividir.boletin-chico
:::

::: docentes
- **Un subprograma que hace dos cosas.** Pide describirlo en una frase sin «y»; si no se puede, son dos subprogramas.
- **Nombres que no dicen qué hacen.** `Calcular` o `Procesar` no ayudan: el nombre es la mitad de la documentación.
- **Olvidar el retorno.** Un subprograma con tipo de retorno y sin `Retornar` no compila; el diagnóstico lo dice.
:::

::: siguiente
Un subprograma recibe el saldo de una tarjeta y lo duplica. Al volver, el saldo sigue igual. ¿Qué ve cada parte del programa?
:::
