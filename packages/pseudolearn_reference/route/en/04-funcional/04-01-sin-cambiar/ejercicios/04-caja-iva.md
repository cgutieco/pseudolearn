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
SubProceso ChargeWithVat(total Como Entero Por Referencia)
  total <- total + total * 18 div 100;
  total <- total - total div 10;
  Escribir "Total: ", total;
FinSubProceso

Algoritmo Till
  Definir purchase Como Entero;
  Leer purchase;
  ChargeWithVat(purchase);
FinAlgoritmo
```

```programa rol=referencia
Funcion discounted <- WithDiscount(total Como Entero)
  Definir discounted Como Entero;
  discounted <- total - total div 10;
FinFuncion

Funcion withTax <- WithVat(total Como Entero)
  Definir withTax Como Entero;
  withTax <- total + total * 18 div 100;
FinFuncion

Algoritmo Till
  Definir purchase Como Entero;
  Leer purchase;
  Escribir "Total: ", WithDiscount(WithVat(purchase));
FinAlgoritmo
```

```casos
visible | 100 | Total: 107
visible | 0 | Total: 0
oculto | 9 | Total: 9
oculto | 50 | Total: 54
oculto | 1000 | Total: 1062
```

```aserciones
- declara-subprograma | WithVat | 1 | The function WithVat, which receives the total, is missing.
- declara-subprograma | WithDiscount | 1 | The function WithDiscount, which receives the total, is missing.
```

::: pistas
1. How many different calculations does `ChargeWithVat` do? Which of its lines touches the world?
2. You already have one of the calculations: it is the discount of [the lesson](ruta:funcional.sin-cambiar).
3. A function `WithVat` and, in the main algorithm, a single expression that composes both.
4. `Write "Total: ", WithDiscount(WithVat(purchase));`. Close with the variant.
:::

::: variante
VAT becomes a value that is read. Which functions change?
:::

::: explicacion
The order of the composition matters: `WithVat(WithDiscount(100))` gives another result. That this shows in a single line is the point of the exercise.
:::
