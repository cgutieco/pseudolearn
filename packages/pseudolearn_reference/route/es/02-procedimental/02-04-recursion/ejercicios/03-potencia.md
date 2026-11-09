---
id: procedimental.recursion.potencia
leccion: procedimental.recursion
tipo: resolver
nivel: brote
obligatorio: true
titulo: La potencia
---

::: enunciado
Lee una base y un exponente no negativo, en ese orden, y muestra la base elevada al exponente. El programa muestra solo el número.
:::

::: restriccion
Sin bucles: la potencia se calcula con una función que se llama a sí misma.
:::

```programa rol=referencia
Funcion r <- Potencia(base Como Entero, exponente Como Entero)
  Definir r Como Entero;
  Si exponente = 0 Entonces
    r <- 1;
  Sino
    r <- base * Potencia(base, exponente - 1);
  FinSi
FinFuncion

Algoritmo Principal
  Definir base, exponente Como Entero;
  Leer base;
  Leer exponente;
  Escribir Potencia(base, exponente);
FinAlgoritmo
```

```casos
visible | 2 ; 10 | 1024
visible | 5 ; 0 | 1
oculto | 3 ; 3 | 27
oculto | 1 ; 100 | 1
oculto | 10 ; 1 | 10
```

```aserciones
- no-contiene | bucle-condicional | Sin bucles: la potencia se calcula con recursión.
- no-contiene | bucle-condicional-posterior | Sin bucles: la potencia se calcula con recursión.
- no-contiene | bucle-contado | Sin bucles: la potencia se calcula con recursión.
```

::: pistas
1. ¿Cuánto vale cualquier número elevado a 0? ¿Y elevado a 1?
2. Se parece al factorial de [la lección](ruta:procedimental.recursion): una multiplicación por una versión más chica.
3. `base` elevado a `exponente` es `base` por `base` elevado a `exponente - 1`.
4. Si el exponente es 0, el resultado es 1; si no, `base * Potencia(base, exponente - 1)`. Cierra con la variante.
:::

::: variante
Hazla más rápida: si el exponente es par, `Potencia(base, exponente)` es el cuadrado de `Potencia(base, exponente div 2)`.
:::

::: explicacion
Las aserciones rechazan cualquier bucle. Casos ocultos: exponente 1, base 1 con exponente grande y exponente 0 en los visibles.
:::
