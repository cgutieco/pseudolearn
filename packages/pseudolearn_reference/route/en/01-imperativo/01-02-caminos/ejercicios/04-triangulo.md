---
id: imperativo.caminos.triangulo
leccion: imperativo.caminos
tipo: resolver
nivel: brote
obligatorio: true
titulo: Which triangle is it?
---

::: enunciado
Read three sides, in whole centimetres, and show `equilateral` if all three are equal, `isosceles` if only two are, `scalene` if they are all different, or «not a triangle» if those sides cannot make one. A triangle can be made when each side is less than the sum of the other two.
:::

```programa rol=referencia
Algoritmo Triangle
  Definir a Como Entero;
  Definir b Como Entero;
  Definir c Como Entero;
  Leer a;
  Leer b;
  Leer c;
  Si a >= b + c O b >= a + c O c >= a + b Entonces
    Escribir "not a triangle";
  Sino
    Si a = b Y b = c Entonces
      Escribir "equilateral";
    Sino
      Si a = b O b = c O a = c Entonces
        Escribir "isosceles";
      Sino
        Escribir "scalene";
      FinSi
    FinSi
  FinSi
FinAlgoritmo
```

```casos
visible | 3 ; 3 ; 3 | equilateral
visible | 3 ; 4 ; 5 | scalene
oculto | 2 ; 2 ; 3 | isosceles
oculto | 1 ; 2 ; 3 | not a triangle
oculto | 5 ; 1 ; 1 | not a triangle
oculto | 2 ; 3 ; 2 | isosceles
```

::: pistas
1. Build a decision table: which questions do you need to ask, and which cases tell them apart?
2. There is a question that goes before all the others: if it is not a triangle, it makes no sense to ask how many sides are equal.
3. For isosceles, any pair of equal sides will do: there are three possible pairs.
4. First «not a triangle» with three comparisons joined by `Or`; then equilateral; then isosceles; the rest is scalene. Close with the variant.
:::

::: variante
Add `right-angled` when the square of the longest side is the sum of the squares of the other two. (With 3, 4 and 5.)
:::

::: explicacion
Hidden cases: equal sides in different positions (2, 3, 2) and impossible triangles with the long side first (5, 1, 1). Frequent mistake: checking isosceles only with `a = b`.
:::
