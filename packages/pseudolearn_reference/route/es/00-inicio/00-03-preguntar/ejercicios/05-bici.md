---
id: inicio.preguntar.bici
leccion: inicio.preguntar
tipo: resolver
nivel: arbol
obligatorio: false
titulo: En bici a la escuela
---

::: enunciado
Lee la distancia en kilómetros y la velocidad en kilómetros por hora, en ese orden, y muestra cuántos minutos tarda el viaje, redondeando hacia arriba. El programa muestra solo el número.
:::

```programa rol=referencia
Algoritmo Bici
  Definir distancia Como Entero;
  Definir velocidad Como Entero;
  Leer distancia;
  Leer velocidad;
  Escribir techo(distancia * 60 / velocidad);
FinAlgoritmo
```

```casos
visible | 10 ; 15 | 40
visible | 7 ; 20 | 21
oculto | 3 ; 9 | 20
oculto | 1 ; 7 | 9
oculto | 5 ; 12 | 25
```

::: pistas
1. A mano: 10 kilómetros a 15 por hora, ¿cuántas horas son? ¿Y cuántos minutos?
2. Una hora tiene 60 minutos. Llena la ficha con esa relación.
3. Pasa a minutos antes de dividir y redondea al final, con la función ya hecha de [la primera lección](ruta:inicio.primer-problema).
4. `Escribir techo(distancia * 60 / velocidad);`. Cierra con la variante.
:::

::: variante
Muestra el resultado como horas y minutos: con 25 kilómetros a 15 por hora, `1 h 40 min`.
:::

::: explicacion
Error frecuente: dividir primero y multiplicar por 60 después, que da lo mismo aquí pero acumula decimales. Otro: redondear las horas antes de pasar a minutos.
:::
