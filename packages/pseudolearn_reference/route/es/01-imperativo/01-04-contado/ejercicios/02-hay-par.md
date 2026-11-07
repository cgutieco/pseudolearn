---
id: imperativo.contado.hay-par
leccion: imperativo.contado
tipo: rastrear
nivel: brote
obligatorio: false
titulo: ¿Hay algún par?
---

::: enunciado
Completa la tabla por vuelta: el valor de cada caja al terminar cada vuelta.
:::

```programa rol=objeto id=traza
Algoritmo HayPar
  Definir hayPar Como Logico <- Falso;
  Definir x Como Entero <- 0;
  Para i <- 1 Hasta 4 Hacer
    x <- i * 3;
    Si x mod 2 = 0 Entonces
      hayPar <- Verdadero;
    FinSi
  FinPara
  Escribir hayPar;
FinAlgoritmo
```

```salida
Verdadero
```

```vueltas marca=9 columnas=i,x,hayPar
1 | 1 | ?3 | ?Falso
2 | 2 | ?6 | ?Verdadero
3 | 3 | ?9 | ?Verdadero
4 | 4 | ?12 | ?Verdadero
```

::: explicacion
`hayPar` empieza en falso y cambia la primera vez que aparece un par, en la vuelta 2. Después no vuelve a cambiar, aunque `x` sea impar en la vuelta 3.
:::
