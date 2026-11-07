---
id: imperativo.decidir
numero: "1.1"
tipo: apertura
titulo: Decidir
duracion: 25
problema_breve: El precio de la entrada al cine
necesita: [inicio.errores]
introduce: [paradigma, programacion-imperativa, condicion, valor-logico, comparacion, decision, instruccion-actual, particion-de-casos]
usa: [caso-borde, caso-de-prueba, ficha-del-problema, leer-dato, error-de-ejecucion]
pieza: 3
---

::: frase
Un programa decide haciendo una pregunta que solo se responde con verdadero o falso, y sigue un camino según la respuesta.
:::

## El problema {#problema}

::: problema
En el cine de la escuela, los menores de **12 años** pagan **5 pesos** y los demás pagan **8**.

**¿Cuánto paga cada persona, según su edad?**
:::

## Inténtalo {#intentalo}

::: intento
Di cuánto pagan personas de 10, 11, 12 y 30 años.
:::

::: respuesta
Pagan 5, 5, 8 y 8. El 12 es el que más se equivoca: «menores de 12» no incluye al 12.
:::

## Un paradigma nuevo {#paradigma}

Lo que vienes haciendo desde la Unidad 0 tiene nombre. Un [[def:paradigma|paradigma]] es una forma de organizar un programa: qué piezas usa y cómo piensa quien lo escribe. El primero que vas a estudiar es la [[def:programacion-imperativa|programación imperativa]]: el programa es una lista de órdenes que van cambiando lo que hay en la memoria.

::: paradigma
- pregunta: ¿y si un programa fuera una lista de órdenes que van cambiando lo que hay en la memoria?
- metafora: una receta de cocina, con pasos en orden que transforman los ingredientes. Deja de valer en un punto: una receta no pregunta nada, y un programa sí puede hacerlo.
- historia: en 1945, John von Neumann describió una computadora que guarda el programa en su memoria, junto con los datos. En 1957, el equipo de John Backus publicó FORTRAN, uno de los primeros lenguajes que permitían escribir esas órdenes con fórmulas.
- costo: para saber qué vale una caja hay que seguir el orden de las órdenes, una por una.
:::

## Entender {#entender fase=1}

Entra la edad; sale el precio. Las edades posibles se parten en dos regiones: las que pagan 5 y las que pagan 8. Entre las dos hay un borde, entre 11 y 12.

```figura id=ruta-particion-edad
pie: Dos regiones y un borde. Cada región necesita un caso; el borde, uno de cada lado.
```

Dividir así las entradas es hacer una [[def:particion-de-casos|partición de casos]]: cada región se prueba con un ejemplo a mano, y cada borde con dos, uno a cada lado.

::: ficha
- entra: la edad, en años enteros.
- sale: el precio de la entrada.
- relacion: si la edad es menor que 12, el precio es 5; si no, 8.
- ejemplo: 10 → 5 (región de los que pagan 5).
- ejemplo: 11 → 5 y 12 → 8 (los dos lados del borde).
- ejemplo: 30 → 8 (región de los que pagan 8).
:::

## Planear {#planear fase=2}

1. Pregunta la edad.
2. Si es menor que 12, el precio es 5.
3. Si no, el precio es 8.

## La herramienta nueva {#herramienta}

Una [[def:condicion|condición]] es una pregunta que el programa se hace y que solo tiene dos respuestas posibles. Cada respuesta es un [[def:valor-logico|valor lógico]]: `Verdadero` o `Falso`. Las preguntas más comunes son [[def:comparacion|comparaciones]]: `<`, `<=`, `>`, `>=`, `=` y `<>` (distinto).

Con una condición, el programa toma una [[def:decision|decisión]]: `Si` la condición es verdadera, ejecuta un camino; `Sino`, el otro. Nunca los dos.

```figura-especificacion seccion=control.si figura=si-ordinograma
```

```programa id=alcanza titulo="¿Alcanza la plata?" ejecutar
Algoritmo Alcanza
  Definir dinero Como Entero <- 10;
  Si dinero >= 12 Entonces
    Escribir "Alcanza";
  Sino
    Escribir "No alcanza";
  FinSi
FinAlgoritmo
```

```salida
No alcanza
```

Para seguir un programa con decisiones conviene imaginar un dedo que señala la [[def:instruccion-actual|instrucción actual]], la que se está ejecutando. En una decisión, el dedo salta por encima del camino que no se toma.

```figura id=ruta-dedo-decision
pie: La rama que no se ejecuta queda atenuada: el dedo nunca pasa por ella.
paso: El dedo empieza en la primera instrucción: se declara la caja de la edad.
paso: Se lee la edad: llega 30.
paso: El dedo llega a la condición. ¿30 es menor que 12? Falso.
paso: El dedo salta la rama de `Entonces` y entra en la de `Sino`.
paso: Se muestra «Paga 8» y el dedo sale de la decisión.
```

::: especificacion
- control.si
- expresiones.comparacion
- tipos.primitivos
:::

## Escribir {#escribir fase=3}

```programa id=cine titulo="El precio del cine" ejecutar
Algoritmo Cine
  Definir edad Como Entero;
  Leer edad;
  Si edad < 12 Entonces
    Escribir "Paga 5";
  Sino
    Escribir "Paga 8";
  FinSi
FinAlgoritmo
```

```entrada
11
```

```salida
Paga 5
```

## Probar {#probar fase=4}

| Edad | Región | A mano | El programa |
|---|---|---|---|
| 10 | paga 5 | 5 | Paga 5 |
| 11 | borde, lado de 5 | 5 | Paga 5 |
| 12 | borde, lado de 8 | 8 | Paga 8 |
| 30 | paga 8 | 8 | Paga 8 |

Cuatro casos cubren las dos regiones y los dos lados del borde. Probar con 40, 50 y 60 no agregaría nada: están en la misma región que 30.

## Mejorar {#mejorar fase=5}

En una frase: «El programa cobra 5 a quien tiene menos de 12 años y 8 a los demás».

Ahora la calculadora de propinas de [la lección anterior](ruta:inicio.errores) puede dejar de caerse con 0 amigos:

```programa id=propina-segura titulo="La propina, sin caerse" ejecutar
Algoritmo Propina
  Definir cuenta Como Entero;
  Definir amigos Como Entero;
  Leer cuenta;
  Leer amigos;
  Si amigos = 0 Entonces
    Escribir "No hay quien pague";
  Sino
    Escribir "Cada uno paga: ", techo((cuenta + cuenta div 10) / amigos);
  FinSi
FinAlgoritmo
```

```entrada
100
0
```

```salida
No hay quien pague
```

Antes, el caso raro era una caída. Ahora es una respuesta.

## Lo que aprendiste {#aprendiste}

::: resumen
- {paradigma,programacion-imperativa} Un paradigma es una forma de organizar un programa; en la programación imperativa, el programa es una lista de órdenes que cambian la memoria.
- {condicion,valor-logico,comparacion} Una condición es una pregunta cuya respuesta es un valor lógico: `Verdadero` o `Falso`. Las comparaciones son condiciones.
- {decision,instruccion-actual} Una decisión ejecuta solo uno de los caminos; la instrucción actual salta el otro.
- {particion-de-casos} Una partición de casos divide las entradas en regiones; se prueba un caso por región y los dos lados de cada borde.
:::

## Practica {#practica}

::: practica
- imperativo.decidir.par-impar-predecir
- imperativo.decidir.par-impar
- imperativo.decidir.cine-romper
- imperativo.decidir.zonas-cine
- imperativo.decidir.cine-pruebas
- imperativo.decidir.estacionamiento
:::

::: docentes
- **«Se ejecutan las dos ramas».** Usa la figura del dedo y pide que lo sigan con el lápiz en el programa del cine.
- **«Menor que 12 incluye al 12».** La partición lo desarma: el 12 está del otro lado del borde.
- **Un número usado como condición.** El motor lo rechaza con un diagnóstico; enlaza [la sección](especificacion:control.si) y sigue.
:::

::: siguiente
Los jueves todos pagan 4. ¿Cómo se combinan dos preguntas, y en qué orden se hacen?
:::
