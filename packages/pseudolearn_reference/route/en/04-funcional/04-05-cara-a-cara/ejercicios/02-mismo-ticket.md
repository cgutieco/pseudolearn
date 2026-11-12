---
id: funcional.cara-a-cara.mismo-ticket
leccion: funcional.cara-a-cara
tipo: predecir
nivel: semilla
obligatorio: false
titulo: The same receipt
---

::: enunciado
Without running it, write exactly what the functional version of the kiosk shows.
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

Algoritmo FunctionalKiosk
  Definir total Como Entero <- Line(3, 3) + Line(5, 2);
  Escribir "Total: ", total;
  Escribir "With discount: ", WithDiscount(total);
FinAlgoritmo
```

```salida
Total: 19
With discount: 18
```

::: explicacion
3 juices at 3 and 2 sandwiches at 5 add up to 19; with the discount of 1 peso every 10, 18 is left. The other two versions show exactly the same: they change how it is thought of, not what is computed.
:::
