---
id: imperativo.esquemas.olas-romper
leccion: imperativo.esquemas
tipo: romperlo
nivel: brote
obligatorio: true
titulo: Las olas que se escapan
---

::: enunciado
Este programa de olas de calor acierta con el caso de la lección. Encuentra 14 temperaturas con las que se equivoque.
:::

```programa rol=defectuoso
Algoritmo Olas
  Dimension t[14] Como Entero;
  Para i <- 0 Hasta 13 Hacer
    Leer t[i];
  FinPara
  Definir racha Como Entero <- 0;
  Definir olas Como Entero <- 0;
  Definir masLarga Como Entero <- 0;
  Para Cada temperatura En t Hacer
    Si temperatura > 30 Entonces
      racha <- racha + 1;
    Sino
      Si racha >= 3 Entonces
        olas <- olas + 1;
        Si racha > masLarga Entonces
          masLarga <- racha;
        FinSi
      FinSi
      racha <- 0;
    FinSi
  FinPara
  Escribir "Olas: ", olas;
  Escribir "La más larga: ", masLarga;
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Olas
  Dimension t[14] Como Entero;
  Para i <- 0 Hasta 13 Hacer
    Leer t[i];
  FinPara
  Definir racha Como Entero <- 0;
  Definir olas Como Entero <- 0;
  Definir masLarga Como Entero <- 0;
  Para Cada temperatura En t Hacer
    Si temperatura > 30 Entonces
      racha <- racha + 1;
    Sino
      Si racha >= 3 Entonces
        olas <- olas + 1;
        Si racha > masLarga Entonces
          masLarga <- racha;
        FinSi
      FinSi
      racha <- 0;
    FinSi
  FinPara
  Si racha >= 3 Entonces
    olas <- olas + 1;
    Si racha > masLarga Entonces
      masLarga <- racha;
    FinSi
  FinSi
  Escribir "Olas: ", olas;
  Escribir "La más larga: ", masLarga;
FinAlgoritmo
```

```casos
visible | 28 ; 31 ; 32 ; 33 ; 29 ; 31 ; 30 ; 31 ; 32 ; 31 ; 35 ; 27 ; 31 ; 32 | Olas: 2 ⏎ La más larga: 4
```

```rompe
28 ; 29 ; 28 ; 29 ; 28 ; 29 ; 28 ; 29 ; 28 ; 29 ; 28 ; 31 ; 32 ; 33
31 ; 31 ; 31 ; 31 ; 31 ; 31 ; 31 ; 31 ; 31 ; 31 ; 31 ; 31 ; 31 ; 31
```

::: pistas
1. Vuelve a la ficha de la lección. ¿Qué caso borde no prueba el ejemplo de la consigna?
2. Compara los dos programas. ¿Qué parte de la lección le falta a este?
3. Busca una ola que todavía no se cortó cuando se terminan los datos.
4. Con los tres últimos días por encima de 30, el bueno dice una ola de 3 y este dice 0. Cierra con la variante.
:::

::: variante
¿Qué muestra este programa si los 14 días están por encima de 30? (Olas: 0. El bueno dice una ola de 14.)
:::

::: docentes
Al programa le falta cerrar la última racha después del bucle. Lo rompe cualquier serie cuya última racha de 3 o más días llegue hasta el final.
:::
