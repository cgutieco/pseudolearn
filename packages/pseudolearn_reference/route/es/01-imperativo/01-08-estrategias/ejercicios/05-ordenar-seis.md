---
id: imperativo.estrategias.ordenar-seis
leccion: imperativo.estrategias
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Ordenar seis números
---

::: enunciado
Lee 6 números y muéstralos de menor a mayor, uno por línea.
:::

```programa rol=referencia
Algoritmo OrdenarSeis
  Dimension v[6] Como Entero;
  Para i <- 0 Hasta 5 Hacer
    Leer v[i];
  FinPara
  Para i <- 0 Hasta 4 Hacer
    Definir menor Como Entero <- i;
    Para j <- i + 1 Hasta 5 Hacer
      Si v[j] < v[menor] Entonces
        menor <- j;
      FinSi
    FinPara
    Definir guardado Como Entero <- v[i];
    v[i] <- v[menor];
    v[menor] <- guardado;
  FinPara
  Para Cada n En v Hacer
    Escribir n;
  FinPara
FinAlgoritmo
```

```casos
visible | 5 ; 3 ; 8 ; 1 ; 9 ; 2 | 1 ⏎ 2 ⏎ 3 ⏎ 5 ⏎ 8 ⏎ 9
visible | 1 ; 2 ; 3 ; 4 ; 5 ; 6 | 1 ⏎ 2 ⏎ 3 ⏎ 4 ⏎ 5 ⏎ 6
oculto | 6 ; 5 ; 4 ; 3 ; 2 ; 1 | 1 ⏎ 2 ⏎ 3 ⏎ 4 ⏎ 5 ⏎ 6
oculto | 4 ; 4 ; 1 ; 4 ; 1 ; 1 | 1 ⏎ 1 ⏎ 1 ⏎ 4 ⏎ 4 ⏎ 4
oculto | -2 ; 0 ; -5 ; 3 ; 3 ; -1 | -5 ⏎ -2 ⏎ -1 ⏎ 0 ⏎ 3 ⏎ 3
```

::: pistas
1. Ordena a mano 5, 3, 8, 1, 9, 2 eligiendo cada vez el menor de los que faltan.
2. Es el programa de selección de [la lección](ruta:imperativo.estrategias), con un número más.
3. Para cada posición desde la primera, busca el menor de lo que queda e intercámbialo con el de esa posición.
4. Dos bucles anidados: el de afuera recorre las posiciones de 0 a 4; el de adentro busca el menor desde la siguiente. Cierra con la variante.
:::

::: variante
Muéstralos de mayor a menor cambiando un solo signo.
:::

::: explicacion
Casos ocultos: orden inverso, repetidos y negativos. Error frecuente: intercambiar dentro del bucle de adentro, que ordena pero hace muchos más intercambios.
:::
