---
id: imperativo.cuadriculas.raya-romper
leccion: imperativo.cuadriculas
tipo: romperlo
nivel: brote
obligatorio: true
titulo: Una raya que se escapa
---

::: enunciado
Este programa de tres en raya acierta con el tablero de la lección. Encuentra un tablero con el que se equivoque.
:::

```programa rol=defectuoso
Algoritmo TresEnRaya
  Dimension t[3, 3] Como Entero;
  Para f <- 0 Hasta 2 Hacer
    Para c <- 0 Hasta 2 Hacer
      Leer t[f, c];
    FinPara
  FinPara
  Definir ganador Como Entero <- 0;
  Para i <- 0 Hasta 2 Hacer
    Si t[i, 0] <> 0 Y t[i, 0] = t[i, 1] Y t[i, 1] = t[i, 2] Entonces
      ganador <- t[i, 0];
    FinSi
    Si t[0, i] <> 0 Y t[0, i] = t[1, i] Y t[1, i] = t[2, i] Entonces
      ganador <- t[0, i];
    FinSi
  FinPara
  Si t[1, 1] <> 0 Y t[0, 0] = t[1, 1] Y t[1, 1] = t[2, 2] Entonces
    ganador <- t[1, 1];
  FinSi
  Segun ganador Hacer
    1:
      Escribir "Gana X";
    2:
      Escribir "Gana O";
    De Otro Modo:
      Escribir "Nadie";
  FinSegun
FinAlgoritmo
```

```programa rol=referencia
Algoritmo TresEnRaya
  Dimension t[3, 3] Como Entero;
  Para f <- 0 Hasta 2 Hacer
    Para c <- 0 Hasta 2 Hacer
      Leer t[f, c];
    FinPara
  FinPara
  Definir ganador Como Entero <- 0;
  Para i <- 0 Hasta 2 Hacer
    Si t[i, 0] <> 0 Y t[i, 0] = t[i, 1] Y t[i, 1] = t[i, 2] Entonces
      ganador <- t[i, 0];
    FinSi
    Si t[0, i] <> 0 Y t[0, i] = t[1, i] Y t[1, i] = t[2, i] Entonces
      ganador <- t[0, i];
    FinSi
  FinPara
  Si t[1, 1] <> 0 Y t[0, 0] = t[1, 1] Y t[1, 1] = t[2, 2] Entonces
    ganador <- t[1, 1];
  FinSi
  Si t[1, 1] <> 0 Y t[0, 2] = t[1, 1] Y t[1, 1] = t[2, 0] Entonces
    ganador <- t[1, 1];
  FinSi
  Segun ganador Hacer
    1:
      Escribir "Gana X";
    2:
      Escribir "Gana O";
    De Otro Modo:
      Escribir "Nadie";
  FinSegun
FinAlgoritmo
```

```casos
visible | 1 ; 2 ; 1 ; 2 ; 1 ; 2 ; 2 ; 1 ; 1 | Gana X
```

```rompe
2 ; 0 ; 1 ; 0 ; 1 ; 0 ; 1 ; 0 ; 2
0 ; 0 ; 2 ; 0 ; 2 ; 0 ; 2 ; 1 ; 1
```

::: pistas
1. Cuenta las formas de ganar que revisa este programa. ¿Son ocho?
2. Compara con la figura de la lección: ¿qué línea del tablero no revisa?
3. Arma un tablero en el que alguien gane solo por esa línea.
4. Con X en las casillas [0, 2], [1, 1] y [2, 0], el programa dice «Nadie». Cierra con la variante.
:::

::: variante
Arma un tablero en el que este programa diga el ganador correcto aunque la otra diagonal esté completa. (Uno que también tenga una fila completa del mismo jugador.)
:::

::: explicacion
Al programa le falta la diagonal de la esquina de arriba a la derecha a la de abajo a la izquierda. Lo rompe cualquier tablero ganado solo por esa diagonal.
:::
