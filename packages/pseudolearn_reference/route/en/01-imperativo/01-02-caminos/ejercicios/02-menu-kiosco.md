---
id: imperativo.caminos.menu-kiosco
leccion: imperativo.caminos
tipo: resolver
nivel: semilla
obligatorio: true
titulo: The kiosk menu
---

::: enunciado
Read a kiosk product code and show its name and price: 1 is `Juice 3`, 2 is `Sandwich 5`, 3 is `Cookie 2`, 4 is `Water 1` and 5 is `Fruit 2`. For any other code, show «Does not exist».
:::

```programa rol=referencia
Algoritmo Menu
  Definir code Como Entero;
  Leer code;
  Segun code Hacer
    1:
      Escribir "Juice 3";
    2:
      Escribir "Sandwich 5";
    3:
      Escribir "Cookie 2";
    4:
      Escribir "Water 1";
    5:
      Escribir "Fruit 2";
    De Otro Modo:
      Escribir "Does not exist";
  FinSegun
FinAlgoritmo
```

```casos
visible | 1 | Juice 3
visible | 9 | Does not exist
oculto | 2 | Sandwich 5
oculto | 5 | Fruit 2
oculto | 0 | Does not exist
```

::: pistas
1. How many paths are there? Which value decides which one is taken?
2. When a single value chooses among many values, there is a tool that says it better than a staircase of questions. It is in [the lesson](ruta:imperativo.caminos).
3. Do not forget the path for codes that do not exist.
4. `Switch code Do` with one option per code and `Otherwise:` for `Does not exist`. Close with the variant.
:::

::: variante
Codes 4 and 5 start costing the same. Can you join them in a single option? (Yes: `4, 5:` if they show the same text.)
:::

::: explicacion
The hidden cases test the ends of the list and 0. Frequent mistake: forgetting the path for codes that do not exist, which leaves the program showing nothing.
:::
