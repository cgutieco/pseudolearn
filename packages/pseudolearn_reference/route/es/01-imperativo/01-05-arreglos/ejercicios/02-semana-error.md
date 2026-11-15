---
id: imperativo.arreglos.semana-error
leccion: imperativo.arreglos
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: La semana que no termina bien
---

::: enunciado
El programa lee las 7 temperaturas de la semana y muestra su suma, pero se detiene antes de mostrarla. Encuentra el error y corrígelo.
:::

```programa rol=inicial
Algoritmo Semana
  Dimension temperaturas[7] Como Entero;
  Definir suma Como Entero <- 0;
  Para i <- 0 Hasta 7 Hacer
    Leer temperaturas[i];
    suma <- suma + temperaturas[i];
  FinPara
  Escribir suma;
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Semana
  Dimension temperaturas[7] Como Entero;
  Definir suma Como Entero <- 0;
  Para i <- 0 Hasta 6 Hacer
    Leer temperaturas[i];
    suma <- suma + temperaturas[i];
  FinPara
  Escribir suma;
FinAlgoritmo
```

```casos
visible | 1 ; 2 ; 3 ; 4 ; 5 ; 6 ; 7 | 28
visible | 20 ; 20 ; 20 ; 20 ; 20 ; 20 ; 20 | 140
oculto | 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 0
oculto | 30 ; 31 ; 32 ; 33 ; 34 ; 35 ; 36 | 231
oculto | -1 ; -1 ; -1 ; -1 ; -1 ; -1 ; -1 | -7
```

::: pistas
1. ¿Es un error al compilar, al ejecutar o de lógica? ¿En qué vuelta se detiene?
2. Cuenta las vueltas del bucle: ¿cuántas da, y cuántas casillas tiene el arreglo?
3. Si el arreglo tiene 7 casillas, ¿cuál es el último índice que existe?
4. El bucle tiene que ir de 0 a 6. Cierra con la variante.
:::

::: variante
Escribe el bucle para que funcione con cualquier tamaño, guardando el tamaño en una caja con nombre.
:::

::: explicacion
El bucle da 8 vueltas para 7 casillas: en la octava pide la casilla 7, que no existe, y el programa se detiene fuera de rango. Error frecuente: arreglarlo con un arreglo de 8.
:::
