---
id: imperativo.mientras.alcancia-pruebas
leccion: imperativo.mientras
tipo: disenar-pruebas
nivel: arbol
obligatorio: false
titulo: The money box tests
---

::: enunciado
Do not write code. Write four prices with the right answer for each one, so that any wrong version of the money box fails at least one of them.
:::

```programa rol=referencia
```

```programa rol=mutante id=menor-o-igual
```

```programa rol=mutante id=ahorro-en-cero
```

```programa rol=mutante id=suma-antes
```

```programa rol=mutante id=dia-en-cero
```

```casos
```

```casos-solucion minimo=4 maximo=4
```

::: pistas
1. Write the worked examples of the card. Which ones are edge cases?
2. Imagine possible errors: a condition that is off by one, a box that starts wrong, two lines in another order. Which price uncovers them?
3. You need a price that is gathered exactly and one that is enough on the first day.
4. 50, 54, 2 and 1000, with their answers from the lesson, uncover every wrong version. Close with the variant.
:::

::: variante
Which of the four prices could you remove without letting any wrong version escape? (Try it: the app tells you which one survives.)
:::

::: docentes
Wrong versions: `<=` in the condition, the money box starting at 0, adding before increasing what is saved each day, and the day starting at 0. A set without an exact price (such as 54) and without one less than or equal to 2 does not detect the first one.
:::
