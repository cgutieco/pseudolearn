---
id: imperativo.cuadriculas.negativo
leccion: imperativo.cuadriculas
tipo: resolver
nivel: brote
obligatorio: false
titulo: El negativo de una imagen
---

::: enunciado
Una imagen de 4 × 4 está hecha de puntos blancos (0) y negros (1). Lee los 16 valores, fila por fila, y muestra la imagen invertida: cada blanco pasa a negro y cada negro a blanco. Una fila por línea, sin espacios.
:::

```programa rol=referencia
Algoritmo Negativo
  Dimension imagen[4, 4] Como Entero;
  Para f <- 0 Hasta 3 Hacer
    Para c <- 0 Hasta 3 Hacer
      Leer imagen[f, c];
    FinPara
  FinPara
  Para f <- 0 Hasta 3 Hacer
    Definir linea Como Cadena <- "";
    Para c <- 0 Hasta 3 Hacer
      linea <- linea + ConvertirATexto(1 - imagen[f, c]);
    FinPara
    Escribir linea;
  FinPara
FinAlgoritmo
```

```casos
visible | 0 ; 1 ; 1 ; 0 ; 1 ; 0 ; 0 ; 1 ; 1 ; 0 ; 0 ; 1 ; 0 ; 1 ; 1 ; 0 | 1001 ⏎ 0110 ⏎ 0110 ⏎ 1001
visible | 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 1111 ⏎ 1111 ⏎ 1111 ⏎ 1111
oculto | 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 | 0000 ⏎ 0000 ⏎ 0000 ⏎ 0000
oculto | 1 ; 0 ; 0 ; 0 ; 0 ; 1 ; 0 ; 0 ; 0 ; 0 ; 1 ; 0 ; 0 ; 0 ; 0 ; 1 | 0111 ⏎ 1011 ⏎ 1101 ⏎ 1110
oculto | 1 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 0111 ⏎ 1111 ⏎ 1111 ⏎ 1111
```

::: pistas
1. ¿Qué cuenta convierte 0 en 1 y 1 en 0?
2. Lee la imagen en una matriz con un bucle anidado, como en [la lección](ruta:imperativo.cuadriculas).
3. Cada fila se arma como un texto, pegando un dígito por columna.
4. `1 - imagen[f, c]` invierte cada punto; `ConvertirATexto` lo pega a la línea. Cierra con la variante.
:::

::: variante
Muestra la imagen dada vuelta de izquierda a derecha, como en un espejo, sin invertir los colores.
:::

::: explicacion
Casos ocultos: todo negro, la diagonal y un solo punto. Error frecuente: mostrar cada dígito con su propio `Escribir`, que pone uno por línea.
:::
