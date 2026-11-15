---
id: imperativo.contado.hay-par
leccion: imperativo.contado
tipo: rastrear
nivel: brote
obligatorio: false
titulo: Is there an even one?
---

::: enunciado
Complete the pass table: the value of each box at the end of each pass.
:::

```programa rol=objeto id=traza
Algoritmo HasEven
  Definir hasEven Como Logico <- Falso;
  Definir x Como Entero <- 0;
  Para i <- 1 Hasta 4 Hacer
    x <- i * 3;
    Si x mod 2 = 0 Entonces
      hasEven <- Verdadero;
    FinSi
  FinPara
  Escribir hasEven;
FinAlgoritmo
```

```salida
Verdadero
```

```vueltas marca=9 columnas=i,x,hasEven
1 | 1 | ?3 | ?Falso
2 | 2 | ?6 | ?Verdadero
3 | 3 | ?9 | ?Verdadero
4 | 4 | ?12 | ?Verdadero
```

::: explicacion
`hasEven` starts as false and changes the first time an even number appears, on pass 2. After that it never changes again, even though `x` is odd on pass 3.
:::
