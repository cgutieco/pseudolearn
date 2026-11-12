---
id: imperativo.estrategias.binaria-romper
leccion: imperativo.estrategias
tipo: romperlo
nivel: brote
obligatorio: true
titulo: El medio que no avanza
---

::: enunciado
Esta búsqueda por mitades encuentra el número del centro. Encuentra un número buscado con el que se equivoque. Los diez números son 1, 2, 3, 4, 5, 6, 7, 8, 9 y 10.
:::

```programa rol=defectuoso
Algoritmo Binaria
  Dimension v[10] Como Entero;
  Para i <- 0 Hasta 9 Hacer
    Leer v[i];
  FinPara
  Definir buscado Como Entero;
  Leer buscado;
  Definir bajo Como Entero <- 0;
  Definir alto Como Entero <- 9;
  Definir medio Como Entero;
  Definir posicion Como Entero <- -1;
  Mientras bajo <= alto Y posicion = -1 Hacer
    medio <- (bajo + alto) div 2;
    Si v[medio] = buscado Entonces
      posicion <- medio;
    Sino
      Si v[medio] < buscado Entonces
        bajo <- medio;
      Sino
        alto <- medio - 1;
      FinSi
    FinSi
  FinMientras
  Escribir posicion;
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Binaria
  Dimension v[10] Como Entero;
  Para i <- 0 Hasta 9 Hacer
    Leer v[i];
  FinPara
  Definir buscado Como Entero;
  Leer buscado;
  Definir bajo Como Entero <- 0;
  Definir alto Como Entero <- 9;
  Definir medio Como Entero;
  Definir posicion Como Entero <- -1;
  Mientras bajo <= alto Y posicion = -1 Hacer
    medio <- (bajo + alto) div 2;
    Si v[medio] = buscado Entonces
      posicion <- medio;
    Sino
      Si v[medio] < buscado Entonces
        bajo <- medio + 1;
      Sino
        alto <- medio - 1;
      FinSi
    FinSi
  FinMientras
  Escribir posicion;
FinAlgoritmo
```

```casos
visible | 1 ; 2 ; 3 ; 4 ; 5 ; 6 ; 7 ; 8 ; 9 ; 10 ; 5 | 4
```

```rompe
1 ; 2 ; 3 ; 4 ; 5 ; 6 ; 7 ; 8 ; 9 ; 10 ; 11
1 ; 2 ; 3 ; 4 ; 5 ; 6 ; 7 ; 8 ; 9 ; 10 ; 10
```

::: pistas
1. Compara las dos formas de achicar lo posible. ¿Cuál no deja afuera al medio?
2. Si el medio se queda dentro de lo posible, ¿siempre se achica el intervalo?
3. Prueba con un buscado mayor que todos.
4. Con 11, el intervalo queda en 8 y 9 para siempre y el programa no termina. Cierra con la variante.
:::

::: variante
Corrige la línea que no avanza.
:::

::: explicacion
Con un buscado a la derecha del medio, el programa hace `bajo <- medio`. Cuando `bajo` y `alto` quedan juntos, el medio es `bajo` y el intervalo ya no cambia: el bucle es infinito y el motor lo corta por límite.
:::
