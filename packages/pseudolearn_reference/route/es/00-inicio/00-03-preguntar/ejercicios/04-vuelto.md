---
id: inicio.preguntar.vuelto
leccion: inicio.preguntar
tipo: resolver
nivel: brote
obligatorio: true
titulo: El vuelto del kiosco
---

::: enunciado
El kiosco vende alfajores a 2 pesos. Lee el valor del billete y la cantidad de alfajores, en ese orden, y muestra el vuelto. El programa muestra solo el número.
:::

```programa rol=referencia
Algoritmo Vuelto
  Definir billete Como Entero;
  Definir cantidad Como Entero;
  Leer billete;
  Leer cantidad;
  Escribir billete - cantidad * 2;
FinAlgoritmo
```

```casos
visible | 10 ; 3 | 4
visible | 20 ; 10 | 0
oculto | 5 ; 2 | 1
oculto | 100 ; 1 | 98
oculto | 2 ; 1 | 0
```

::: pistas
1. Usa la ficha del ejercicio anterior y agrega dos ejemplos a mano.
2. Hay dos datos que entran: dos cajas y dos lecturas, como en [la lección](ruta:inicio.preguntar).
3. El vuelto es lo que pagó menos lo que cuestan los alfajores.
4. `Escribir billete - cantidad * 2;`. Cierra con la variante.
:::

::: variante
El precio sube a 3 pesos. ¿Cuántas líneas tuviste que cambiar? Si fueron más de una, guarda el precio en una caja con nombre.
:::

::: explicacion
Error frecuente: leer en el orden inverso al enunciado. Los casos con vuelto 0 comprueban que no se restó de más.
:::
