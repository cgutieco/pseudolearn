---
id: funcional.proyecto.reporte
leccion: funcional.proyecto
tipo: resolver
nivel: arbol
obligatorio: true
titulo: The day's report
---

::: enunciado
Read the day's sales, code and amount, until a 0, and show the report with the exact format of the lesson: the total, the total with discount, how many sales were over 5 pesos and the star product, or «Ninguno» if there were no sales. In a tie of units, the product with the lowest code wins.
:::

::: restriccion
The calculation uses three functions, `Mapear`, `Filtrar` and `Reducir`, that receive another function as a value; the main algorithm only reads and shows.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | Mapear | 2 | The function Mapear, which receives the list and the operation, is missing.
- declara-subprograma | Filtrar | 2 | The function Filtrar, which receives the list and the condition, is missing.
- declara-subprograma | Reducir | 3 | The function Reducir, which receives the list, the operation and the initial value, is missing.
```

::: pistas
1. Go back to your classification: which jobs belong to the core?
2. They are the three pieces of [lesson 4.2](ruta:funcional.orden-superior) and the factory of [lesson 4.3](ruta:funcional.clausuras), over a list of sales.
3. `Mapear` gives the amounts, `Reducir` adds them, `Filtrar` keeps those over 5; for the star, a factory that counts the units of a code.
4. The main algorithm reads the sales into a list and shows four expressions that compose the functions. Close with the variant.
:::

::: variante
Add the average amount per sale, without walking through the sales again.
:::

::: docentes
The assertions check the three functions; that they show nothing is guaranteed by the engine, because they are pure. Hidden cases: all sales of 5 pesos or less, a tie (the lowest code wins), a single big sale and large amounts.
:::
