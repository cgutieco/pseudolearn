---
id: procedimental.recursion.cifras
leccion: procedimental.recursion
tipo: resolver
nivel: arbol
obligatorio: false
titulo: How many digits?
---

::: enunciado
Read a non-negative whole number and show how many digits it has. The program shows only the number.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. Which numbers have a single digit? How many digits does 1234 have if you remove the last one?
2. Look at how the last digit is removed in [lesson 1.4](ruta:imperativo.contado), with the sum of the digits.
3. Base case: less than 10. Recursive case: one digit more than the number without the last one.
4. If `n < 10`, it has 1 digit; otherwise, `1 + Cifras(n div 10)`. Close with the variant.
:::

::: variante
Write the sum of the digits with recursion, without loops.
:::

::: explicacion
0 is the edge case: it has one digit. A solution with `If n = 0` as the base case counts 0 digits for 0.
:::
