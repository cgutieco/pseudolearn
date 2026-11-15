---
id: funcional.cara-a-cara.mismo-ticket
leccion: funcional.cara-a-cara
tipo: predecir
nivel: semilla
obligatorio: false
titulo: El mismo ticket
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra la versión funcional del kiosco.
:::

```programa rol=objeto id=prediccion
Funcion importe <- Linea(precio Como Entero, cantidad Como Entero)
  Definir importe Como Entero;
  importe <- precio * cantidad;
FinFuncion

Funcion monto <- ConDescuento(total Como Entero)
  Definir monto Como Entero;
  monto <- total - total div 10;
FinFuncion

Algoritmo KioscoFuncional
  Definir total Como Entero <- Linea(3, 3) + Linea(5, 2);
  Escribir "Total: ", total;
  Escribir "Con descuento: ", ConDescuento(total);
FinAlgoritmo
```

```salida
Total: 19
Con descuento: 18
```

::: explicacion
3 jugos de 3 y 2 sándwiches de 5 suman 19; con el descuento de 1 peso cada 10, quedan 18. Las otras dos versiones muestran exactamente lo mismo: cambian cómo se piensa, no qué se calcula.
:::
