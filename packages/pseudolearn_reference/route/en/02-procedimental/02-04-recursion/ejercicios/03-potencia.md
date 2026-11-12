---
id: procedimental.recursion.potencia
leccion: procedimental.recursion
tipo: resolver
nivel: brote
obligatorio: true
titulo: The power
---

::: enunciado
Read a base and a non-negative exponent, in that order, and show the base raised to the exponent. The program shows only the number.
:::

::: restriccion
No loops: the power is computed with a function that calls itself.
:::

```programa rol=referencia
Funcion r <- Power(base Como Entero, exponent Como Entero)
  Definir r Como Entero;
  Si exponent = 0 Entonces
    r <- 1;
  Sino
    r <- base * Power(base, exponent - 1);
  FinSi
FinFuncion

Algoritmo Main
  Definir base, exponent Como Entero;
  Leer base;
  Leer exponent;
  Escribir Power(base, exponent);
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
- no-contiene | bucle-condicional | No loops: the power is computed with recursion.
- no-contiene | bucle-condicional-posterior | No loops: the power is computed with recursion.
- no-contiene | bucle-contado | No loops: the power is computed with recursion.
```

::: pistas
1. What is any number raised to 0? And raised to 1?
2. It looks like the factorial of [the lesson](ruta:procedimental.recursion): a multiplication by a smaller version.
3. `base` raised to `exponent` is `base` times `base` raised to `exponent - 1`.
4. If the exponent is 0, the result is 1; otherwise, `base * Power(base, exponent - 1)`. Close with the variant.
:::

::: variante
Make it faster: if the exponent is even, `Power(base, exponent)` is the square of `Power(base, exponent div 2)`.
:::

::: explicacion
The assertions reject any loop. Hidden cases: exponent 1, base 1 with a large exponent and exponent 0 among the visible ones.
:::
