---
id: imperativo.cuadriculas.cuadrado-magico
leccion: imperativo.cuadriculas
tipo: resolver
nivel: arbol
obligatorio: false
titulo: El cuadrado mágico
---

::: enunciado
Lee 9 números, fila por fila, de una cuadrícula de 3 × 3. Es mágica si todas las filas, todas las columnas y las dos diagonales suman lo mismo. Muestra «Es mágico» o «No es mágico».
:::

```programa rol=referencia
Algoritmo CuadradoMagico
  Dimension m[3, 3] Como Entero;
  Para f <- 0 Hasta 2 Hacer
    Para c <- 0 Hasta 2 Hacer
      Leer m[f, c];
    FinPara
  FinPara
  Definir objetivo Como Entero <- m[0, 0] + m[0, 1] + m[0, 2];
  Definir esMagico Como Logico <- Verdadero;
  Para i <- 0 Hasta 2 Hacer
    Si m[i, 0] + m[i, 1] + m[i, 2] <> objetivo Entonces
      esMagico <- Falso;
    FinSi
    Si m[0, i] + m[1, i] + m[2, i] <> objetivo Entonces
      esMagico <- Falso;
    FinSi
  FinPara
  Si m[0, 0] + m[1, 1] + m[2, 2] <> objetivo Entonces
    esMagico <- Falso;
  FinSi
  Si m[0, 2] + m[1, 1] + m[2, 0] <> objetivo Entonces
    esMagico <- Falso;
  FinSi
  Si esMagico Entonces
    Escribir "Es mágico";
  Sino
    Escribir "No es mágico";
  FinSi
FinAlgoritmo
```

```casos
visible | 2 ; 7 ; 6 ; 9 ; 5 ; 1 ; 4 ; 3 ; 8 | Es mágico
visible | 1 ; 2 ; 3 ; 4 ; 5 ; 6 ; 7 ; 8 ; 9 | No es mágico
oculto | 8 ; 1 ; 6 ; 3 ; 5 ; 7 ; 4 ; 9 ; 2 | Es mágico
oculto | 5 ; 5 ; 5 ; 5 ; 5 ; 5 ; 5 ; 5 ; 5 | Es mágico
oculto | 2 ; 7 ; 6 ; 9 ; 5 ; 1 ; 4 ; 8 ; 3 | No es mágico
```

::: pistas
1. ¿Cuántas sumas hay que comparar? ¿Con qué número compararlas?
2. Es el tres en raya de [la lección](ruta:imperativo.cuadriculas) con sumas en lugar de casillas iguales.
3. Toma la suma de la primera fila como objetivo; una sola suma distinta basta para que no sea mágico.
4. Una caja lógica arranca en verdadero y cambia si alguna fila, columna o diagonal no suma el objetivo. Cierra con la variante.
:::

::: variante
Exige además que los nueve números sean distintos.
:::

::: docentes
El último caso oculto tiene filas y diagonales que suman 15 pero dos columnas que no: descubre a quien no revisa las columnas.
:::
