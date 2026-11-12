---
id: imperativo.estrategias.binaria
leccion: imperativo.estrategias
tipo: resolver
nivel: brote
obligatorio: true
titulo: Buscar por mitades
---

::: enunciado
Lee 10 números ordenados de menor a mayor y después un número buscado. Muestra la posición del buscado, de 0 a 9, o -1 si no está. Descarta la mitad que no puede tenerlo en cada paso.
:::

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
visible | 1 ; 2 ; 3 ; 4 ; 5 ; 6 ; 7 ; 8 ; 9 ; 10 ; 7 | 6
visible | 2 ; 4 ; 6 ; 8 ; 10 ; 12 ; 14 ; 16 ; 18 ; 20 ; 5 | -1
oculto | 2 ; 4 ; 6 ; 8 ; 10 ; 12 ; 14 ; 16 ; 18 ; 20 ; 2 | 0
oculto | 2 ; 4 ; 6 ; 8 ; 10 ; 12 ; 14 ; 16 ; 18 ; 20 ; 20 | 9
oculto | 2 ; 4 ; 6 ; 8 ; 10 ; 12 ; 14 ; 16 ; 18 ; 20 ; 1 | -1
oculto | 2 ; 4 ; 6 ; 8 ; 10 ; 12 ; 14 ; 16 ; 18 ; 20 ; 21 | -1
```

::: pistas
1. ¿Qué dos posiciones marcan lo que todavía puede contener al buscado?
2. Es el juego de adivinar de [la lección](ruta:imperativo.estrategias), sobre un arreglo.
3. Repite mientras lo posible no esté vacío y no lo hayas encontrado. ¿Qué haces con el medio si no es el buscado?
4. Con `bajo` y `alto`, mira `v[medio]`: si es menor, `bajo <- medio + 1`; si es mayor, `alto <- medio - 1`. Cierra con la variante.
:::

::: variante
Muestra también cuántos pasos hicieron falta. Con 10 datos, ¿cuál es el máximo?
:::

::: explicacion
Casos ocultos: el buscado en los dos extremos, menor que todos y mayor que todos. Error frecuente: dejar el medio dentro del intervalo, que en algunos casos no termina.
:::
