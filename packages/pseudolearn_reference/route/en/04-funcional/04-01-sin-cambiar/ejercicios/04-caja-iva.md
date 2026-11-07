---
id: funcional.sin-cambiar.caja-iva
leccion: funcional.sin-cambiar
tipo: modificar
nivel: arbol
obligatorio: false
titulo: The till with VAT
---

::: enunciado
Another kiosk till works, but nobody dares to change it. Rewrite it as a core that only computes and an edge that reads and shows. It has to show the same for any purchase.
:::

::: restriccion
The VAT and the discount are pure functions; the main algorithm composes both in a single expression.
:::

```programa rol=inicial
```

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | ConIva | 1 | The function ConIva, which receives the total, is missing.
- declara-subprograma | ConDescuento | 1 | The function ConDescuento, which receives the total, is missing.
```

::: pistas
1. How many different calculations does `CobrarConIva` do? Which of its lines touches the world?
2. You already have one of the calculations: it is the discount of [the lesson](ruta:funcional.sin-cambiar).
3. A function `ConIva` and, in the main algorithm, a single expression that composes both.
4. `Write "Total: ", ConDescuento(ConIva(compra));`. Close with the variant.
:::

::: variante
VAT becomes a value that is read. Which functions change?
:::

::: docentes
The order of the composition matters: `ConIva(ConDescuento(100))` gives another result. That this shows in a single line is the point of the exercise.
:::
