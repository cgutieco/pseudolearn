---
id: inicio.primer-problema.pintar-aula
leccion: inicio.primer-problema
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Painting the classroom
---

::: enunciado
The classroom walls add up to 54 square metres. They need two coats of paint. One litre covers 10 square metres and paint is sold in 4-litre tins. How many tins must be bought? The program shows only the number.
:::

```programa rol=inicial
Algoritmo Painting
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Painting
  Escribir techo(54 * 2 / 10 / 4);
FinAlgoritmo
```

```casos
visible | — | 3
```

::: pistas
1. What does «two coats» mean for the surface to cover?
2. Plan it in steps, like [the pizzas](ruta:inicio.primer-problema), with one more sum in the middle.
3. Total surface, then litres, then tins. In which of those steps do you need to round up?
4. `Write ceil(54 * 2 / 10 / 4);` shows 3. Close with the variant.
:::

::: variante
How many litres of paint are left after painting? (Answer: 1.2.)
:::

::: explicacion
Solution: 108 square metres, 10.8 litres, 2.7 tins, so 3 are bought. Frequent mistake: rounding the litres before dividing by 4, which also gives 3 here but fails with other sizes.
:::
