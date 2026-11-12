---
id: imperativo.arreglos.al-reves
leccion: imperativo.arreglos
tipo: resolver
nivel: semilla
obligatorio: true
titulo: Al revés
---

::: enunciado
Lee 5 números y muéstralos en el orden inverso, uno por línea.
:::

```programa rol=referencia
Algoritmo AlReves
  Dimension numeros[5] Como Entero;
  Para i <- 0 Hasta 4 Hacer
    Leer numeros[i];
  FinPara
  Para i <- 4 Hasta 0 Con Paso -1 Hacer
    Escribir numeros[i];
  FinPara
FinAlgoritmo
```

```casos
visible | 1 ; 2 ; 3 ; 4 ; 5 | 5 ⏎ 4 ⏎ 3 ⏎ 2 ⏎ 1
visible | 7 ; 7 ; 7 ; 7 ; 7 | 7 ⏎ 7 ⏎ 7 ⏎ 7 ⏎ 7
oculto | 0 ; 1 ; 0 ; 1 ; 0 | 0 ⏎ 1 ⏎ 0 ⏎ 1 ⏎ 0
oculto | 9 ; 8 ; 7 ; 6 ; 5 | 5 ⏎ 6 ⏎ 7 ⏎ 8 ⏎ 9
oculto | -1 ; 2 ; -3 ; 4 ; -5 | -5 ⏎ 4 ⏎ -3 ⏎ 2 ⏎ -1
```

::: pistas
1. ¿Puedes empezar a mostrar antes de haber leído el último número?
2. Guarda los cinco en un arreglo, como las temperaturas de [la lección](ruta:imperativo.arreglos).
3. Para mostrarlos al revés, el índice tiene que ir del último al primero.
4. Un bucle que lee de 0 a 4 y otro que muestra de 4 a 0 `Con Paso -1`. Cierra con la variante.
:::

::: variante
Muestra solo los que están en posiciones pares: 0, 2 y 4.
:::

::: explicacion
Casos ocultos: números repetidos que hacen parecer correcto un programa que no invierte (7, 7, 7) y negativos. Error frecuente: empezar el segundo bucle en 5.
:::
