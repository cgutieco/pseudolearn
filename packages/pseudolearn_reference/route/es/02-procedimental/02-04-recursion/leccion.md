---
id: procedimental.recursion
numero: "2.4"
tipo: leccion
titulo: Problemas que se contienen a sí mismos
duracion: 35
problema_breve: La torre de Hanói
necesita: [procedimental.puras]
introduce: [recursion, caso-base, caso-recursivo]
usa: [subprograma, llamada, parametro, pila-de-llamadas, marco, funcion-pura, bucle, costo]
---

::: frase
Un subprograma recursivo resuelve un problema pidiéndose a sí mismo una versión más chica, hasta llegar a una que ya sabe resolver.
:::

## El problema {#problema}

::: problema
La torre de Hanói: **tres discos** de distinto tamaño están apilados en el poste **A**, del más grande abajo al más chico arriba. Hay que pasarlos al poste **C** moviendo **un disco por vez** y sin poner nunca un disco grande sobre uno chico. El poste **B** sirve de ayuda.

**¿Qué movimientos hay que hacer, y cuántos son?**
:::

## Inténtalo {#intentalo}

::: intento
Resuélvelo con tres monedas de distinto tamaño sobre tres papeles marcados A, B y C.
:::

::: respuesta
Son **7** movimientos: el chico de A a C, el mediano de A a B, el chico de C a B, el grande de A a C, el chico de B a A, el mediano de B a C y el chico de A a C.
:::

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Entra la cantidad de discos; salen los movimientos, en orden.
- **¿A qué se parece?** A sí mismo. Para mover 3 discos de A a C hay que mover antes los 2 de arriba a B, y eso es el mismo problema con un disco menos.
- **¿En qué partes se divide?** Se divide en tres: mover 2 discos de A a B, mover el grande de A a C y mover los 2 de B a C. Mover un solo disco es directo.

```figura id=ruta-hanoi
pie: Para mover la torre de tres, primero se mueve una torre de dos fuera del camino.
paso: El disco chico va de A a C.
paso: El mediano va de A a B.
paso: El chico va de C a B: la torre de dos está en B.
paso: El grande va de A a C.
paso: El chico va de B a A.
paso: El mediano va de B a C.
paso: El chico va de A a C: la torre entera está en C.
```

## La herramienta nueva {#herramienta}

Un subprograma que se llama a sí mismo usa [[def:recursion|recursión]]. Tiene dos partes: el [[def:caso-base|caso base]], que se resuelve sin llamarse, y el [[def:caso-recursivo|caso recursivo]], que se llama con un problema más chico y tiene que acercarse al caso base.

```figura id=ruta-munecas
pie: Cada muñeca contiene una más chica, hasta la última, que ya no se abre: es el caso base.
paso: Se abre la muñeca grande: adentro hay una más chica.
paso: Se abre la siguiente: otra más chica.
paso: La más chica no se abre: es el caso base.
paso: Se cierran de adentro hacia afuera, con el resultado.
```

```programa id=factorial titulo="El factorial" ejecutar
Funcion r <- Factorial(n Como Entero)
  Definir r Como Entero;
  Si n = 0 Entonces
    r <- 1;
  Sino
    r <- n * Factorial(n - 1);
  FinSi
FinFuncion

Algoritmo Principal
  Escribir Factorial(5);
FinAlgoritmo
```

```salida
120
```

Cada llamada abre su propio marco en la pila, y los marcos se cierran de arriba hacia abajo cuando el caso base devuelve su resultado:

```figura-especificacion seccion=subprogramas.recursion figura=recursion-pila
```

::: especificacion
- subprogramas.recursion
- motor.limites
:::

## Escribir {#escribir fase=3}

```programa id=hanoi titulo="La torre de Hanói" ejecutar
SubProceso Hanoi(n Como Entero, origen Como Cadena, destino Como Cadena, auxiliar Como Cadena)
  Si n > 0 Entonces
    Hanoi(n - 1, origen, auxiliar, destino);
    Escribir "Mover disco ", n, " de ", origen, " a ", destino;
    Hanoi(n - 1, auxiliar, destino, origen);
  FinSi
FinSubProceso

Algoritmo Torre
  Hanoi(3, "A", "C", "B");
FinAlgoritmo
```

```salida
Mover disco 1 de A a C
Mover disco 2 de A a B
Mover disco 1 de C a B
Mover disco 3 de A a C
Mover disco 1 de B a A
Mover disco 2 de B a C
Mover disco 1 de A a C
```

El caso base es una torre de 0 discos: no hay nada que mover. El caso recursivo mueve una torre de `n - 1` discos, que se acerca al caso base en cada llamada.

## Probar {#probar fase=4}

Con 1 disco hay un solo movimiento; con 0, ninguno: es el caso borde que el caso base resuelve. Contando movimientos:

| Discos | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| Movimientos | 1 | 3 | 7 | 15 | 31 |

Cada disco más duplica los movimientos y suma uno.

## Mejorar {#mejorar fase=5}

En una frase: «Para mover una torre, se mueve la torre de arriba fuera del camino, se mueve el disco grande y se vuelve a poner encima la torre de arriba».

El costo crece rápido: con 20 discos son más de un millón de movimientos. La recursión no siempre es la mejor opción: el factorial no se ramifica, y un bucle lo resuelve igual de claro sin abrir un marco por cada número.

## Lo que aprendiste {#aprendiste}

::: resumen
- {recursion} Un subprograma recursivo se llama a sí mismo con un problema más chico.
- {caso-base,caso-recursivo} El caso base se resuelve sin llamarse; el caso recursivo tiene que acercarse a él.
:::

## Practica {#practica}

::: practica
- procedimental.recursion.factorial-4
- procedimental.recursion.suma-sin-fin
- procedimental.recursion.potencia
- procedimental.recursion.cifras
- procedimental.recursion.fibonacci
- procedimental.recursion.munecas
:::

::: profundizar titulo="Tropiezos frecuentes"
- **Olvidar el caso base.** El programa se llama sin fin hasta que el motor lo detiene por profundidad. El ejercicio de encontrar el error lo muestra.
- **Un caso recursivo que no se achica.** Di, en cada llamada, qué número se acerca a cero.
- **«La recursión es siempre mejor».** Hanói la necesita; el factorial no. Compara las dos versiones.
:::

::: siguiente
Los contactos del curso tienen nombre, teléfono y mes de cumpleaños. ¿Cómo se guarda algo que tiene varias partes?
:::
