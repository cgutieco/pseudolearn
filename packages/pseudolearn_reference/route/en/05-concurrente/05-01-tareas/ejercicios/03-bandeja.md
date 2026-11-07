---
id: concurrente.tareas.bandeja
leccion: concurrente.tareas
tipo: resolver
nivel: brote
obligatorio: true
titulo: The tray
---

::: enunciado
Read the portions of juices, of sandwiches and of fruit, and show the value of the tray with the format «Bandeja: 27 pesos». The prices are 3, 5 and 2 pesos.
:::

::: restriccion
Each dish is computed in its own task, launched with `Spawn` inside a `Tasks` scope.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | Cocinar | 2 | The subprogram Cocinar, which receives the price and the portions, is missing.
```

::: pistas
1. Which calculation is repeated three times with different data?
2. It is the cook of the lesson, without the message: it receives the price and the portions and gives back the value of the dish.
3. Launch three `Task<Integer>` tasks and add up what `Await` hands over from each one.
4. The sum and the `Write` go inside the scope, before `EndTasks`. Close with the variant.
:::

::: variante
Add a fourth cook who makes waters of 2 pesos.
:::

::: docentes
The assertion requires the cook subprogram. The case of 0 portions confirms that the tray still waits for the three; 10 portions of each dish test larger amounts.
:::
