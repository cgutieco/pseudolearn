---
id: imperativo.estrategias.seleccion-tabla
leccion: imperativo.estrategias
tipo: rastrear
nivel: arbol
obligatorio: false
titulo: Rastrear la selección
---

::: enunciado
Completa la tabla: lo que guarda cada casilla de `v` al terminar cada vuelta del recorrido de afuera.
:::

```programa rol=objeto id=traza
Algoritmo Seleccion
  Dimension v[4] Como Entero;
  v[0] <- 4;
  v[1] <- 3;
  v[2] <- 2;
  v[3] <- 1;
  Para i <- 0 Hasta 2 Hacer
    Definir menor Como Entero <- i;
    Para j <- i + 1 Hasta 3 Hacer
      Si v[j] < v[menor] Entonces
        menor <- j;
      FinSi
    FinPara
    Definir guardado Como Entero <- v[i];
    v[i] <- v[menor];
    v[menor] <- guardado;
  FinPara
  Escribir v[0], v[1], v[2], v[3];
FinAlgoritmo
```

```salida
1234
```

```vueltas marca=17 inicio=7 columnas=v[0],v[1],v[2],v[3]
antes | 4 | 3 | 2 | 1
1 | ?1 | ?3 | ?2 | ?4
2 | ?1 | ?2 | ?3 | ?4
3 | ?1 | ?2 | ?3 | ?4
```

::: explicacion
La primera vuelta lleva el 1 al frente intercambiándolo con el 4. La segunda lleva el 2 al segundo lugar. En la tercera, el 3 ya está en su lugar y el intercambio no cambia nada.
:::
