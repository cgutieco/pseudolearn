---
id: inicio.preguntar.vuelto
leccion: inicio.preguntar
tipo: resolver
nivel: brote
obligatorio: true
titulo: The kiosk change
---

::: enunciado
The kiosk sells biscuits at 2 pesos. Read the value of the note and the number of biscuits, in that order, and show the change. The program shows only the number.
:::

```programa rol=referencia
Algoritmo Change
  Definir note Como Entero;
  Definir amount Como Entero;
  Leer note;
  Leer amount;
  Escribir note - amount * 2;
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
1. Use the card from the previous exercise and add two worked examples.
2. Two values go in: two boxes and two reads, as in [the lesson](ruta:inicio.preguntar).
3. The change is what was paid minus what the biscuits cost.
4. `Write note - amount * 2;`. Close with the variant.
:::

::: variante
The price goes up to 3 pesos. How many lines did you have to change? If it was more than one, keep the price in a box with a name.
:::

::: explicacion
Frequent mistake: reading in the opposite order to the statement. The cases with 0 change check that nothing extra was subtracted.
:::
