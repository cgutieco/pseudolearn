---
id: imperativo.cuadriculas.suma-filas
leccion: imperativo.cuadriculas
tipo: resolver
nivel: semilla
obligatorio: true
titulo: La suma de cada fila
---

::: enunciado
Lee los 9 números de una cuadrícula de 3 × 3, fila por fila, y muestra la suma de cada fila, una por línea.
:::

```programa rol=referencia
Algoritmo SumaFilas
  Dimension m[3, 3] Como Entero;
  Para f <- 0 Hasta 2 Hacer
    Para c <- 0 Hasta 2 Hacer
      Leer m[f, c];
    FinPara
  FinPara
  Para f <- 0 Hasta 2 Hacer
    Definir suma Como Entero <- 0;
    Para c <- 0 Hasta 2 Hacer
      suma <- suma + m[f, c];
    FinPara
    Escribir suma;
  FinPara
FinAlgoritmo
```

```casos
visible | 1 ; 2 ; 3 ; 4 ; 5 ; 6 ; 7 ; 8 ; 9 | 6 ⏎ 15 ⏎ 24
visible | 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 0 ⏎ 0 ⏎ 0
oculto | 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 | 3 ⏎ 3 ⏎ 3
oculto | 9 ; 0 ; 0 ; 0 ; 9 ; 0 ; 0 ; 0 ; 9 | 9 ⏎ 9 ⏎ 9
oculto | -1 ; 1 ; 0 ; 2 ; 2 ; 2 ; 5 ; 0 ; 0 | 0 ⏎ 6 ⏎ 5
```

::: pistas
1. ¿Cuántas sumas tienes que mostrar? ¿Cuántos números entran en cada una?
2. Guarda la cuadrícula en una matriz, como el tablero de [la lección](ruta:imperativo.cuadriculas).
3. Para cada fila, la suma empieza en 0 y junta las tres columnas.
4. Un bucle por las filas; adentro, la suma en 0 y un bucle por las columnas; al terminar cada fila, se muestra. Cierra con la variante.
:::

::: variante
Muestra también la suma de cada columna.
:::

::: explicacion
Error frecuente: poner la suma en 0 una sola vez, antes de todos los bucles, que acumula las filas anteriores: 6, 21, 45.
:::
