---
id: imperativo.caminos.menu-kiosco
leccion: imperativo.caminos
tipo: resolver
nivel: semilla
obligatorio: true
titulo: The kiosk menu
---

::: enunciado
Read a kiosk product code and show its name and price: 1 is `Jugo 3`, 2 is `Sándwich 5`, 3 is `Alfajor 2`, 4 is `Agua 1` and 5 is `Fruta 2`. For any other code, show «No existe».
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. How many paths are there? Which value decides which one is taken?
2. When a single value chooses among many values, there is a tool that says it better than a staircase of questions. It is in [the lesson](ruta:imperativo.caminos).
3. Do not forget the path for codes that do not exist.
4. `Switch codigo Do` with one option per code and `Otherwise:` for `No existe`. Close with the variant.
:::

::: variante
Codes 4 and 5 start costing the same. Can you join them in a single option? (Yes: `4, 5:` if they show the same text.)
:::

::: docentes
The hidden cases test the ends of the list and 0. Frequent mistake: forgetting the path for codes that do not exist, which leaves the program showing nothing.
:::
