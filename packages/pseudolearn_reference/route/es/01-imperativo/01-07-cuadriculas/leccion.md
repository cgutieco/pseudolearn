---
id: imperativo.cuadriculas
numero: "1.7"
tipo: leccion
titulo: Tableros y cuadrículas
duracion: 30
problema_breve: ¿Quién ganó el tres en raya?
necesita: [imperativo.esquemas]
introduce: [matriz, bucle-anidado, concatenar]
usa: [arreglo, indice, esquema, bucle-contado, caso-borde, condicion-compuesta]
---

::: frase
Una matriz es un arreglo con filas y columnas, y cada casilla se encuentra con dos números.
:::

## El problema {#problema}

::: problema
En el recreo juegan al tres en raya. Al terminar, el tablero se anota fila por fila: **0** para una casilla vacía, **1** para X y **2** para O.

**¿Quién ganó?**
:::

## Inténtalo {#intentalo}

::: intento
Decide quién ganó con este tablero, anotado fila por fila: 1, 2, 1 / 2, 1, 2 / 2, 1, 1.
:::

::: respuesta
Gana X, por la diagonal que va de la esquina de arriba a la izquierda a la de abajo a la derecha: las tres casillas tienen 1.
:::

## Entender {#entender fase=1}

::: ficha
- entra: nueve números, fila por fila: 0 vacío, 1 X y 2 O.
- sale: «Gana X», «Gana O» o «Nadie».
- relacion: gana quien completa una fila, una columna o una de las dos diagonales.
- ejemplo: el tablero de la consigna → Gana X, por una diagonal.
- ejemplo: un tablero sin tres en raya → Nadie.
- ejemplo: un tablero vacío → Nadie.
:::

Hay ocho formas de ganar: tres filas, tres columnas y dos diagonales. Una casilla vacía no gana aunque haya tres seguidas: el tablero vacío es el caso borde.

## Planear {#planear fase=2}

```figura id=ruta-matriz-coordenadas
pie: Cada casilla tiene una fila y una columna. En una diagonal la fila es igual a la columna; en la otra, suman 2.
```

1. Lee los nueve números en su casilla.
2. Revisa cada fila, cada columna y las dos diagonales: es el esquema de buscar, ocho veces.
3. Si alguna tiene tres casillas iguales y no vacías, ganó quien está en ellas.

## La herramienta nueva {#herramienta}

Una [[def:matriz|matriz]] es un arreglo de dos dimensiones: cada casilla se encuentra con dos índices, la fila y la columna. Los dos empiezan en 0.

```figura-especificacion seccion=tipos.arreglos figura=arreglo-casillas
```

Para recorrer una matriz entera se usa un [[def:bucle-anidado|bucle anidado]]: un bucle por las filas y, adentro, otro por las columnas de cada fila.

Para mostrar una fila en una sola línea conviene [[def:concatenar|concatenar]]: unir textos con `+` para formar uno nuevo. Un número se convierte en texto con `ConvertirATexto`.

```programa id=dibujar-tablero titulo="Dibujar el tablero" ejecutar
Algoritmo DibujarTablero
  Dimension tablero[3, 3] Como Entero;
  tablero[0, 0] <- 1;
  tablero[0, 1] <- 2;
  tablero[0, 2] <- 1;
  tablero[1, 0] <- 2;
  tablero[1, 1] <- 1;
  tablero[1, 2] <- 2;
  tablero[2, 0] <- 2;
  tablero[2, 1] <- 1;
  tablero[2, 2] <- 1;
  Para f <- 0 Hasta 2 Hacer
    Definir linea Como Cadena <- "";
    Para c <- 0 Hasta 2 Hacer
      Segun tablero[f, c] Hacer
        1:
          linea <- linea + "X";
        2:
          linea <- linea + "O";
        De Otro Modo:
          linea <- linea + ".";
      FinSegun
    FinPara
    Escribir linea;
  FinPara
FinAlgoritmo
```

```salida
XOX
OXO
OXX
```

::: especificacion
- tipos.arreglos
- expresiones.concatenacion
:::

## Escribir {#escribir fase=3}

```programa id=tres-en-raya titulo="Tres en raya" ejecutar
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

```entrada
1
2
1
2
1
2
2
1
1
```

```salida
Gana X
```

## Probar {#probar fase=4}

| Tablero | A mano | El programa |
|---|---|---|
| 1, 1, 1 / 2, 2, 0 / 0, 0, 0 | gana X por una fila | Gana X |
| 2, 1, 1 / 2, 1, 0 / 2, 0, 0 | gana O por una columna | Gana O |
| 1, 2, 1 / 2, 1, 2 / 2, 1, 1 | gana X por una diagonal | Gana X |
| 2, 0, 1 / 0, 1, 0 / 1, 0, 2 | gana X por la otra diagonal | Gana X |
| 1, 2, 1 / 1, 2, 2 / 2, 1, 1 | nadie | Nadie |

## Mejorar {#mejorar fase=5}

En una frase: «El programa guarda el tablero en una matriz y revisa las ocho líneas en busca de tres casillas iguales».

Para un tablero de 4 × 4 cambian los límites de los bucles y la fila de la segunda diagonal. Si el tamaño estuviera en una caja con nombre, sería un solo cambio.

## Lo que aprendiste {#aprendiste}

::: resumen
- {matriz} Una matriz guarda datos en filas y columnas; cada casilla tiene dos índices.
- {bucle-anidado} Un bucle anidado recorre todas las columnas de cada fila.
- {concatenar} Concatenar es unir textos para formar uno nuevo.
:::

## Practica {#practica}

::: practica
- imperativo.cuadriculas.filas-texto
- imperativo.cuadriculas.suma-filas
- imperativo.cuadriculas.raya-romper
- imperativo.cuadriculas.negativo
- imperativo.cuadriculas.cuadrado-magico
- imperativo.cuadriculas.casillas
:::

::: profundizar titulo="Tropiezos frecuentes"
- **Confundir fila con columna.** La fila va primero. Señala `[0, 2]` en la figura antes de escribir.
- **Índices desde 1.** El centro de un tablero de 3 × 3 es `[1, 1]`.
- **Revisar solo filas.** Prueba un tablero ganado por una columna y otro por la segunda diagonal.
:::

::: siguiente
Pienso un número entre 1 y 100. ¿Cuántas preguntas necesitas para adivinarlo? ¿Hay una forma mejor que probar uno por uno?
:::
