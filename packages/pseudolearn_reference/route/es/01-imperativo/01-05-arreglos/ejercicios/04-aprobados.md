---
id: imperativo.arreglos.aprobados
leccion: imperativo.arreglos
tipo: resolver
nivel: brote
obligatorio: false
titulo: ¿Cuántos aprobaron?
---

::: enunciado
Lee 6 notas, de 0 a 10, y muestra cuántas son 6 o más. El programa muestra solo el número.
:::

```programa rol=referencia
Algoritmo Aprobados
  Dimension notas[6] Como Entero;
  Definir aprobados Como Entero <- 0;
  Para i <- 0 Hasta 5 Hacer
    Leer notas[i];
  FinPara
  Para Cada nota En notas Hacer
    Si nota >= 6 Entonces
      aprobados <- aprobados + 1;
    FinSi
  FinPara
  Escribir aprobados;
FinAlgoritmo
```

```casos
visible | 6 ; 5 ; 7 ; 10 ; 2 ; 6 | 4
visible | 5 ; 5 ; 5 ; 5 ; 5 ; 5 | 0
oculto | 6 ; 6 ; 6 ; 6 ; 6 ; 6 | 6
oculto | 0 ; 0 ; 0 ; 0 ; 0 ; 10 | 1
oculto | 10 ; 10 ; 10 ; 10 ; 10 ; 10 | 6
```

::: pistas
1. ¿Cuál es el borde entre aprobar y no aprobar? ¿De qué lado está el 6?
2. Guarda las notas y recórrelas; para cada una, una pregunta.
3. Una caja cuenta las que cumplen. Si no necesitas la posición, puedes recorrer sin índice.
4. Recorre con `Para Cada` y suma 1 cuando la nota es 6 o más. Cierra con la variante.
:::

::: variante
Muestra también el promedio de las aprobadas, o «Nadie aprobó».
:::

::: explicacion
El borde es el 6, que aprueba. Casos ocultos: todos en el borde y ninguno aprobado. Error frecuente: `> 6`.
:::
