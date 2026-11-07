---
id: imperativo.contado.nota-mas-alta
leccion: imperativo.contado
tipo: resolver
nivel: brote
obligatorio: true
titulo: La nota más alta
---

::: enunciado
Lee 5 notas, de 0 a 10, y muestra la más alta. El programa muestra solo el número.
:::

```programa rol=referencia
Algoritmo NotaMasAlta
  Definir nota Como Entero;
  Definir mayor Como Entero;
  Leer mayor;
  Para i <- 2 Hasta 5 Hacer
    Leer nota;
    Si nota > mayor Entonces
      mayor <- nota;
    FinSi
  FinPara
  Escribir mayor;
FinAlgoritmo
```

```casos
visible | 4 ; 9 ; 7 ; 9 ; 2 | 9
visible | 1 ; 1 ; 1 ; 1 ; 1 | 1
oculto | 0 ; 0 ; 0 ; 0 ; 10 | 10
oculto | 10 ; 0 ; 0 ; 0 ; 0 | 10
oculto | 5 ; 6 ; 7 ; 8 ; 9 | 9
```

::: pistas
1. ¿Sabes cuántas notas son? Eso decide qué forma de repetir conviene.
2. Hace falta una caja que recuerde la más alta vista hasta ahora. Repasa sus roles en [la lección](ruta:imperativo.contado).
3. ¿Con qué valor empieza esa caja? Piensa en un dato que seguro sirve.
4. Lee la primera nota en la caja de la mayor; después, cuatro vueltas que leen y reemplazan si la nueva es mayor. Cierra con la variante.
:::

::: variante
Muestra también en qué posición, del 1 al 5, apareció la más alta por primera vez.
:::

::: docentes
Casos ocultos: la mayor al final y al principio. Error frecuente: empezar la mayor en 0, que acierta con notas de 0 a 10 pero falla con temperaturas bajo cero.
:::
