---
id: imperativo.cuadriculas.filas-texto
leccion: imperativo.cuadriculas
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Two rows of products
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
Algoritmo TextRows
  Para r <- 1 Hasta 2 Hacer
    Definir line Como Cadena <- "";
    Para c <- 1 Hasta 3 Hacer
      Si c > 1 Entonces
        line <- line + " ";
      FinSi
      line <- line + ConvertirATexto(r * c);
    FinPara
    Escribir line;
  FinPara
FinAlgoritmo
```

```salida
1 2 3
2 4 6
```

::: explicacion
The outer loop makes two passes, one per row; in each, the inner one makes three and builds the line with `r * c`. Row 1 multiplies by 1 and row 2 by 2.
:::
