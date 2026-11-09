---
id: imperativo.proyecto.caja
leccion: imperativo.proyecto
tipo: resolver
nivel: arbol
obligatorio: true
titulo: La caja del kiosco
---

::: enunciado
Escribe el programa de la caja. Lee pares de código y cantidad hasta el código 0 y muestra el ticket con el formato exacto de la lección: una línea por venta como `Jugo x 3 = 9`, «Código 7 no existe» si el código es inválido, y al final `Total: `, `Con descuento: ` y `Más vendido: ` con su valor, o `Ninguno` si no hubo ventas. En un empate de unidades gana el producto de menor código.
:::

```programa rol=referencia
Algoritmo Caja
  Dimension nombres[5] Como Cadena;
  Dimension precios[5] Como Entero;
  Dimension unidades[5] Como Entero;
  nombres[0] <- "Jugo";
  nombres[1] <- "Sándwich";
  nombres[2] <- "Alfajor";
  nombres[3] <- "Agua";
  nombres[4] <- "Fruta";
  precios[0] <- 3;
  precios[1] <- 5;
  precios[2] <- 2;
  precios[3] <- 1;
  precios[4] <- 2;
  Para i <- 0 Hasta 4 Hacer
    unidades[i] <- 0;
  FinPara
  Definir total Como Entero <- 0;
  Definir codigo Como Entero;
  Definir cantidad Como Entero;
  Leer codigo;
  Mientras codigo <> 0 Hacer
    Leer cantidad;
    Si codigo < 1 O codigo > 5 Entonces
      Escribir "Código ", codigo, " no existe";
    Sino
      Definir importe Como Entero <- precios[codigo - 1] * cantidad;
      Escribir nombres[codigo - 1], " x ", cantidad, " = ", importe;
      total <- total + importe;
      unidades[codigo - 1] <- unidades[codigo - 1] + cantidad;
    FinSi
    Leer codigo;
  FinMientras
  Escribir "Total: ", total;
  Escribir "Con descuento: ", total - total div 10;
  Definir mejor Como Entero <- -1;
  Para i <- 0 Hasta 4 Hacer
    Si unidades[i] > 0 Entonces
      Si mejor = -1 Entonces
        mejor <- i;
      Sino
        Si unidades[i] > unidades[mejor] Entonces
          mejor <- i;
        FinSi
      FinSi
    FinSi
  FinPara
  Si mejor = -1 Entonces
    Escribir "Más vendido: Ninguno";
  Sino
    Escribir "Más vendido: ", nombres[mejor];
  FinSi
FinAlgoritmo
```

```casos
visible | 1 ; 3 ; 2 ; 2 ; 3 ; 1 ; 1 ; 1 ; 0 | Jugo x 3 = 9 ⏎ Sándwich x 2 = 10 ⏎ Alfajor x 1 = 2 ⏎ Jugo x 1 = 3 ⏎ Total: 24 ⏎ Con descuento: 22 ⏎ Más vendido: Jugo
visible | 0 | Total: 0 ⏎ Con descuento: 0 ⏎ Más vendido: Ninguno
oculto | 2 ; 1 ; 7 ; 4 ; 4 ; 2 ; 0 | Sándwich x 1 = 5 ⏎ Código 7 no existe ⏎ Agua x 2 = 2 ⏎ Total: 7 ⏎ Con descuento: 7 ⏎ Más vendido: Agua
oculto | 3 ; 2 ; 1 ; 2 ; 0 | Alfajor x 2 = 4 ⏎ Jugo x 2 = 6 ⏎ Total: 10 ⏎ Con descuento: 9 ⏎ Más vendido: Jugo
oculto | 5 ; 1 ; 0 | Fruta x 1 = 2 ⏎ Total: 2 ⏎ Con descuento: 2 ⏎ Más vendido: Fruta
oculto | 1 ; 1 ; 2 ; 1 ; 3 ; 1 ; 4 ; 1 ; 5 ; 1 ; 0 | Jugo x 1 = 3 ⏎ Sándwich x 1 = 5 ⏎ Alfajor x 1 = 2 ⏎ Agua x 1 = 1 ⏎ Fruta x 1 = 2 ⏎ Total: 13 ⏎ Con descuento: 12 ⏎ Más vendido: Jugo
oculto | 2 ; 100 ; 4 ; 250 ; 0 | Sándwich x 100 = 500 ⏎ Agua x 250 = 250 ⏎ Total: 750 ⏎ Con descuento: 675 ⏎ Más vendido: Agua
oculto | 9 ; 3 ; 0 | Código 9 no existe ⏎ Total: 0 ⏎ Con descuento: 0 ⏎ Más vendido: Ninguno
```

::: pistas
1. Vuelve a tu ficha: ¿qué cajas necesitas para recordar lo de todo el día?
2. Es la alcancía dictada de [la lección 1.3](ruta:imperativo.mientras), con arreglos como en [la lección 1.5](ruta:imperativo.arreglos) y el más vendido de [la lección 1.4](ruta:imperativo.contado).
3. Tres arreglos paralelos: nombres, precios y unidades vendidas. El código menos 1 es el índice.
4. Lee el código; mientras no sea 0, lee la cantidad, valida, escribe la línea y suma; al final, el total, el descuento y la búsqueda del más vendido. Cierra con la variante.
:::

::: variante
Agrega al cierre cuántas ventas válidas hubo y el importe promedio por venta.
:::

::: explicacion
Casos ocultos: un código inválido en medio, un empate (alfajor y jugo con 2 unidades: gana el jugo, de menor código), una sola venta, los cinco productos, cantidades grandes y un día cuya única venta es inválida. Error frecuente: buscar el más vendido con `>=`, que en un empate elige el de mayor código.
:::
