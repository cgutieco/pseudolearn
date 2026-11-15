---
id: imperativo.arreglos.calurosos-ordenar
leccion: imperativo.arreglos
tipo: ordenar
nivel: brote
obligatorio: false
titulo: Ordenar los días calurosos
---

::: enunciado
Las líneas de un programa que muestra los días más calurosos que el promedio están mezcladas. Ordénalas para que funcione.
:::

```programa rol=referencia
Algoritmo DiasCalurosos
  Dimension temperaturas[7] Como Entero;
  Definir suma Como Entero <- 0;
  Para i <- 0 Hasta 6 Hacer
    Leer temperaturas[i];
    suma <- suma + temperaturas[i];
  FinPara
  Definir promedio Como Real <- suma / 7;
  Para i <- 0 Hasta 6 Hacer
    Si temperaturas[i] > promedio Entonces
      Escribir "Día ", i;
    FinSi
  FinPara
FinAlgoritmo
```

```casos
visible | 20 ; 23 ; 19 ; 25 ; 22 ; 18 ; 26 | Día 1 ⏎ Día 3 ⏎ Día 4 ⏎ Día 6
oculto | 10 ; 10 ; 10 ; 10 ; 10 ; 10 ; 30 | Día 6
oculto | 30 ; 10 ; 10 ; 10 ; 10 ; 10 ; 10 | Día 0
```

::: explicacion
Primero se declara el arreglo y el acumulador; la primera pasada lee y suma; después se calcula el promedio; la segunda pasada compara cada día. El promedio no puede ir antes de la primera pasada.
:::
