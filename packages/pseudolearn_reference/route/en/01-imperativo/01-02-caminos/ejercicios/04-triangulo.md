---
id: imperativo.caminos.triangulo
leccion: imperativo.caminos
tipo: resolver
nivel: brote
obligatorio: true
titulo: Which triangle is it?
---

::: enunciado
Read three sides, in whole centimetres, and show `equilátero` (equilateral) if all three are equal, `isósceles` if only two are, `escaleno` (scalene) if they are all different, or «no es triángulo» if those sides cannot make one. A triangle can be made when each side is less than the sum of the other two.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. Build a decision table: which questions do you need to ask, and which cases tell them apart?
2. There is a question that goes before all the others: if it is not a triangle, it makes no sense to ask how many sides are equal.
3. For isosceles, any pair of equal sides will do: there are three possible pairs.
4. First «no es triángulo» with three comparisons joined by `Or`; then equilateral; then isosceles; the rest is scalene. Close with the variant.
:::

::: variante
Add `rectángulo` (right-angled) when the square of the longest side is the sum of the squares of the other two. (With 3, 4 and 5.)
:::

::: docentes
Hidden cases: equal sides in different positions (2, 3, 2) and impossible triangles with the long side first (5, 1, 1). Frequent mistake: checking isosceles only with `a = b`.
:::
