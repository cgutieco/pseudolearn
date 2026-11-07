---
id: imperativo.esquemas.primer-desaprobado
leccion: imperativo.esquemas
tipo: resolver
nivel: brote
obligatorio: true
titulo: El primer desaprobado
---

::: enunciado
Lee 6 notas y muestra la posición, de 0 a 5, de la primera nota menor que 6. Si no hay ninguna, muestra -1.
:::

```programa rol=referencia
Algoritmo PrimerDesaprobado
  Dimension notas[6] Como Entero;
  Para i <- 0 Hasta 5 Hacer
    Leer notas[i];
  FinPara
  Definir posicion Como Entero <- -1;
  Para i <- 0 Hasta 5 Hacer
    Si notas[i] < 6 Entonces
      posicion <- i;
      Salir;
    FinSi
  FinPara
  Escribir posicion;
FinAlgoritmo
```

```casos
visible | 7 ; 8 ; 3 ; 9 ; 2 ; 6 | 2
visible | 6 ; 7 ; 8 ; 9 ; 10 ; 6 | -1
oculto | 5 ; 9 ; 9 ; 9 ; 9 ; 9 | 0
oculto | 6 ; 6 ; 6 ; 6 ; 6 ; 5 | 5
oculto | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 0
```

::: pistas
1. ¿Qué forma de resolver es esta: contar, buscar, filtrar? ¿Cuándo se puede dejar de mirar?
2. Repasa la tabla de formas de [la lección](ruta:imperativo.esquemas).
3. Empieza con la respuesta para «no hay ninguna» y cámbiala solo si encuentras una.
4. Arranca la posición en -1; recorre y, en la primera nota menor que 6, guarda la posición y sal. Cierra con la variante.
:::

::: variante
Muestra la posición de la última nota menor que 6. ¿Qué cambia en el recorrido?
:::

::: docentes
Casos ocultos: la primera en la posición 0, la última en la 5 y todas desaprobadas (gana la 0). Error frecuente: no salir del bucle, que devuelve la última y no la primera.
:::
