---
id: imperativo.caminos.descuentos
leccion: imperativo.caminos
tipo: clasificar
nivel: arbol
obligatorio: false
titulo: Which discount applies?
---

::: enunciado
The bookshop has this rule: a student who spends 10 pesos or more gets a 10 % discount; whoever has a birthday that day gets 15 %; if both apply, the larger one wins. Place each customer in their discount.
:::

```categorias
- No discount
- 10 %
- 15 %
```

```elementos
- Student, spends 12, no birthday | 10 %
- Not a student, spends 12, birthday | 15 %
- Student, spends 8, no birthday | No discount
- Student, spends 20, birthday | 15 %
- Not a student, spends 5, no birthday | No discount
```

::: explicacion
A decision table with three rows (student, spending 10 or more, birthday) puts the five cases in order. The birthday always wins when it applies, because it is the larger; the 10 % needs both conditions at once.
:::
