---
id: exterior.archivos.linea-pruebas
leccion: exterior.archivos
tipo: disenar-pruebas
nivel: arbol
obligatorio: false
titulo: The tests of the line
---

::: enunciado
Do not write code. Write between two and four lines for the exercise of reading a line, with the right answer for each one, so that any wrong version fails at least one.
:::

```programa rol=referencia
Funcion message <- StockFromLine(line Como Cadena)
  Definir message Como Cadena;
  Segun PosicionDe(line, ";") Hacer
    Algo(cut):
      message <- Subcadena(line, 0, cut - 1) + " has " + Subcadena(line, cut + 1, Longitud(line) - 1);
    Nada: message <- "Invalid line";
  FinSegun
FinFuncion

Algoritmo ReadLine
  Definir line Como Cadena;
  Leer line;
  Escribir StockFromLine(line);
FinAlgoritmo
```

```programa rol=mutante id=sin-revisar
Funcion message <- StockFromLine(line Como Cadena)
  Definir message Como Cadena;
  Segun PosicionDe(line, ";") Hacer
    Algo(cut):
      message <- Subcadena(line, 0, cut - 1) + " has " + Subcadena(line, cut + 1, Longitud(line) - 1);
    Nada: message <- line + " has ";
  FinSegun
FinFuncion

Algoritmo ReadLine
  Definir line Como Cadena;
  Leer line;
  Escribir StockFromLine(line);
FinAlgoritmo
```

```programa rol=mutante id=ultimo-corte
Funcion message <- StockFromLine(line Como Cadena)
  Definir message Como Cadena;
  Definir cut Como Entero <- -1;
  Para position <- 0 Hasta Longitud(line) - 1 Hacer
    Si Subcadena(line, position, position) = ";" Entonces
      cut <- position;
    FinSi
  FinPara
  Si cut = -1 Entonces
    message <- "Invalid line";
  Sino
    message <- Subcadena(line, 0, cut - 1) + " has " + Subcadena(line, cut + 1, Longitud(line) - 1);
  FinSi
FinFuncion

Algoritmo ReadLine
  Definir line Como Cadena;
  Leer line;
  Escribir StockFromLine(line);
FinAlgoritmo
```

```programa rol=mutante id=sin-stock
Funcion message <- StockFromLine(line Como Cadena)
  Definir message Como Cadena;
  Segun PosicionDe(line, ";") Hacer
    Algo(cut):
      message <- Subcadena(line, 0, cut - 1) + " has ";
    Nada: message <- "Invalid line";
  FinSegun
FinFuncion

Algoritmo ReadLine
  Definir line Como Cadena;
  Leer line;
  Escribir StockFromLine(line);
FinAlgoritmo
```

```casos
visible | juice;10 | juice has 10
```

```casos-solucion minimo=2 maximo=4
juice;10 | juice has 10
water | Invalid line
x;y;3 | x has y;3
```

::: pistas
1. Think of possible errors: not checking whether there is a semicolon, cutting somewhere else, forgetting a part.
2. You need a line without a semicolon.
3. You need a line with two semicolons.
4. «juice;10», «water» and «x;y;3» uncover the three wrong versions. Close with the variant.
:::

::: variante
Which of your lines could you remove without letting any wrong version escape?
:::

::: explicacion
Wrong versions: it does not check the semicolon, it cuts at the last one and it shows the name without the stock. Without a line with two semicolons, the second one survives.
:::
