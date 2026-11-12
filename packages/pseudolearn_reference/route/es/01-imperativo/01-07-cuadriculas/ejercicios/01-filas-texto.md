---
id: imperativo.cuadriculas.filas-texto
leccion: imperativo.cuadriculas
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Dos filas de productos
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
Algoritmo FilasTexto
  Para f <- 1 Hasta 2 Hacer
    Definir linea Como Cadena <- "";
    Para c <- 1 Hasta 3 Hacer
      Si c > 1 Entonces
        linea <- linea + " ";
      FinSi
      linea <- linea + ConvertirATexto(f * c);
    FinPara
    Escribir linea;
  FinPara
FinAlgoritmo
```

```salida
1 2 3
2 4 6
```

::: explicacion
El bucle de afuera da dos vueltas, una por fila; en cada una, el de adentro da tres y arma la línea con `f * c`. La fila 1 multiplica por 1 y la fila 2 por 2.
:::
