---
id: funcional.sin-cambiar.sustituye
leccion: funcional.sin-cambiar
tipo: predecir
nivel: brote
obligatorio: true
titulo: Substitute
---

::: enunciado
Compute step by step, replacing each call by its discounted, and write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
Funcion amount <- Line(price Como Entero, quantity Como Entero)
  Definir amount Como Entero;
  amount <- price * quantity;
FinFuncion

Funcion discounted <- WithDiscount(total Como Entero)
  Definir discounted Como Entero;
  discounted <- total - total div 10;
FinFuncion

Algoritmo Substitute
  Escribir Line(4, 2) + WithDiscount(Line(10, 3));
FinAlgoritmo
```

```salida
35
```

::: explicacion
`Line(4, 2)` is 8 and `Line(10, 3)` is 30. `WithDiscount(30)` is 30 - 3, that is 27. 8 + 27 gives 35.
:::
