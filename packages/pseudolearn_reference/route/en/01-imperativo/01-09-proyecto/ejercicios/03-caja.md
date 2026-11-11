---
id: imperativo.proyecto.caja
leccion: imperativo.proyecto
tipo: resolver
nivel: arbol
obligatorio: true
titulo: The kiosk till
---

::: enunciado
Write the till program. Read pairs of code and amount until code 0 and show the receipt with the exact format of the lesson: one line per sale such as `Juice x 3 = 9`, «Code 7 does not exist» if the code is invalid, and at the end `Total: `, `With discount: ` and `Best seller: ` with their value, or `Nobody` if there were no sales. In a tie of units, the product with the lowest code wins.
:::

```programa rol=referencia
Algoritmo Till
  Dimension names[5] Como Cadena;
  Dimension prices[5] Como Entero;
  Dimension units[5] Como Entero;
  names[0] <- "Juice";
  names[1] <- "Sandwich";
  names[2] <- "Cookie";
  names[3] <- "Water";
  names[4] <- "Fruit";
  prices[0] <- 3;
  prices[1] <- 5;
  prices[2] <- 2;
  prices[3] <- 1;
  prices[4] <- 2;
  Para i <- 0 Hasta 4 Hacer
    units[i] <- 0;
  FinPara
  Definir total Como Entero <- 0;
  Definir codigo Como Entero;
  Definir amount Como Entero;
  Leer codigo;
  Mientras codigo <> 0 Hacer
    Leer amount;
    Si codigo < 1 O codigo > 5 Entonces
      Escribir "Code ", codigo, " does not exist";
    Sino
      Definir lineTotal Como Entero <- prices[codigo - 1] * amount;
      Escribir names[codigo - 1], " x ", amount, " = ", lineTotal;
      total <- total + lineTotal;
      units[codigo - 1] <- units[codigo - 1] + amount;
    FinSi
    Leer codigo;
  FinMientras
  Escribir "Total: ", total;
  Escribir "With discount: ", total - total div 10;
  Definir best Como Entero <- -1;
  Para i <- 0 Hasta 4 Hacer
    Si units[i] > 0 Entonces
      Si best = -1 Entonces
        best <- i;
      Sino
        Si units[i] > units[best] Entonces
          best <- i;
        FinSi
      FinSi
    FinSi
  FinPara
  Si best = -1 Entonces
    Escribir "Best seller: Nobody";
  Sino
    Escribir "Best seller: ", names[best];
  FinSi
FinAlgoritmo
```

```casos
visible | 1 ; 3 ; 2 ; 2 ; 3 ; 1 ; 1 ; 1 ; 0 | Juice x 3 = 9 ⏎ Sandwich x 2 = 10 ⏎ Cookie x 1 = 2 ⏎ Juice x 1 = 3 ⏎ Total: 24 ⏎ With discount: 22 ⏎ Best seller: Juice
visible | 0 | Total: 0 ⏎ With discount: 0 ⏎ Best seller: Nobody
oculto | 2 ; 1 ; 7 ; 4 ; 4 ; 2 ; 0 | Sandwich x 1 = 5 ⏎ Code 7 does not exist ⏎ Water x 2 = 2 ⏎ Total: 7 ⏎ With discount: 7 ⏎ Best seller: Water
oculto | 3 ; 2 ; 1 ; 2 ; 0 | Cookie x 2 = 4 ⏎ Juice x 2 = 6 ⏎ Total: 10 ⏎ With discount: 9 ⏎ Best seller: Juice
oculto | 5 ; 1 ; 0 | Fruit x 1 = 2 ⏎ Total: 2 ⏎ With discount: 2 ⏎ Best seller: Fruit
oculto | 1 ; 1 ; 2 ; 1 ; 3 ; 1 ; 4 ; 1 ; 5 ; 1 ; 0 | Juice x 1 = 3 ⏎ Sandwich x 1 = 5 ⏎ Cookie x 1 = 2 ⏎ Water x 1 = 1 ⏎ Fruit x 1 = 2 ⏎ Total: 13 ⏎ With discount: 12 ⏎ Best seller: Juice
oculto | 2 ; 100 ; 4 ; 250 ; 0 | Sandwich x 100 = 500 ⏎ Water x 250 = 250 ⏎ Total: 750 ⏎ With discount: 675 ⏎ Best seller: Water
oculto | 9 ; 3 ; 0 | Code 9 does not exist ⏎ Total: 0 ⏎ With discount: 0 ⏎ Best seller: Nobody
```

::: pistas
1. Go back to your card: which boxes do you need to remember what happened all day?
2. It is the dictated money box of [lesson 1.3](ruta:imperativo.mientras), with arrays as in [lesson 1.5](ruta:imperativo.arreglos) and the best seller of [lesson 1.4](ruta:imperativo.contado).
3. Three parallel arrays: names, prices and units sold. The code minus 1 is the index.
4. Read the code; while it is not 0, read the amount, check, write the line and add; at the end, the total, the discount and the search for the best seller. Close with the variant.
:::

::: variante
Add to the closing how many valid sales there were and the average price per sale.
:::

::: explicacion
Hidden cases: an invalid code in the middle, a tie (cookie and juice with 2 units: juice wins, with the lowest code), a single sale, the five products, large amounts and a day whose only sale is invalid. Frequent mistake: searching for the best seller with `>=`, which in a tie picks the one with the highest code.
:::
