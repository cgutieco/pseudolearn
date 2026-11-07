---
id: procedimental.ambito.ordenar-dos
leccion: procedimental.ambito
tipo: resolver
nivel: brote
obligatorio: true
titulo: The smaller one first
---

::: enunciado
Read two numbers and show them as `smaller larger`, separated by a space.
:::

::: restriccion
A subprogram `OrdenarDos` receives both boxes and leaves the smaller in the first and the larger in the second; the main algorithm only reads, calls and shows.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | OrdenarDos | 2 | The subprogram OrdenarDos, which receives both boxes, is missing.
```

::: pistas
1. When do you have to change something and when not?
2. It is the swap of the previous exercise, done only when needed.
3. Both boxes have to come back changed: lend them.
4. If the first is greater than the second, swap them. Close with the variant.
:::

::: variante
Make `OrdenarDos` also return whether it had to swap.
:::

::: docentes
Hidden cases: equal, negatives and already sorted. Frequent mistake: passing the boxes by value, which shows the original order.
:::
