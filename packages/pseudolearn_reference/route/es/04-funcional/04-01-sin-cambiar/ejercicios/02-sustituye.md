---
id: funcional.sin-cambiar.sustituye
leccion: funcional.sin-cambiar
tipo: predecir
nivel: brote
obligatorio: true
titulo: Sustituye
---

::: enunciado
Calcula paso a paso, reemplazando cada llamada por su resultado, y escribe exactamente lo que muestra este programa.
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

Algoritmo Sustituir
  Escribir Linea(4, 2) + ConDescuento(Linea(10, 3));
FinAlgoritmo
```

```salida
35
```

::: explicacion
`Linea(4, 2)` es 8 y `Linea(10, 3)` es 30. `ConDescuento(30)` es 30 - 3, es decir 27. 8 + 27 da 35.
:::
