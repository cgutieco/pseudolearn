---
id: objetos.cosas.maquina-resolver
leccion: objetos.cosas
tipo: resolver
nivel: brote
obligatorio: false
titulo: The sales of the two machines
---

::: enunciado
Each machine starts with 10 cans and charges 3 pesos per can. Read machine numbers, 1 or 2, one per sale, until a 0. A sale at a machine without cans is not made and is reported with «Machine 1 has no cans» (or 2). At the end show `Machine 1: ` and `Machine 2: ` with their cans and money, as in the lesson: `Machine 1: 8 cans, 6 pesos`.
:::

```programa rol=referencia
Clase Machine
  Definir stock, collected, price Como Entero;

  Metodo Constructor(cans Como Entero)
    Este.stock <- cans;
    Este.collected <- 0;
    Este.price <- 3;
  FinMetodo

  Metodo Sell() Como Logico
    Si Este.stock = 0 Entonces
      Retornar Falso;
    FinSi
    Este.stock <- Este.stock - 1;
    Este.collected <- Este.collected + Este.price;
    Retornar Verdadero;
  FinMetodo

  Metodo Status() Como Cadena
    Retornar ConvertirATexto(Este.stock) + " cans, " + ConvertirATexto(Este.collected) + " pesos";
  FinMetodo
FinClase

Algoritmo Kiosk
  Definir machineOne Como Machine <- Nuevo Machine(10);
  Definir machineTwo Como Machine <- Nuevo Machine(10);
  Definir number Como Entero;
  Leer number;
  Mientras number <> 0 Hacer
    Si number = 1 Entonces
      Si NO machineOne.Sell() Entonces
        Escribir "Machine 1 has no cans";
      FinSi
    Sino
      Si NO machineTwo.Sell() Entonces
        Escribir "Machine 2 has no cans";
      FinSi
    FinSi
    Leer number;
  FinMientras
  Escribir "Machine 1: ", machineOne.Status();
  Escribir "Machine 2: ", machineTwo.Status();
FinAlgoritmo
```

```casos
visible | 1 ; 1 ; 2 ; 0 | Machine 1: 8 cans, 6 pesos ⏎ Machine 2: 9 cans, 3 pesos
visible | 0 | Machine 1: 10 cans, 0 pesos ⏎ Machine 2: 10 cans, 0 pesos
oculto | 2 ; 2 ; 2 ; 0 | Machine 1: 10 cans, 0 pesos ⏎ Machine 2: 7 cans, 9 pesos
oculto | 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 0 | Machine 1 has no cans ⏎ Machine 1 has no cans ⏎ Machine 1: 0 cans, 30 pesos ⏎ Machine 2: 10 cans, 0 pesos
oculto | 1 ; 2 ; 1 ; 2 ; 0 | Machine 1: 8 cans, 6 pesos ⏎ Machine 2: 8 cans, 6 pesos
```

::: pistas
1. How many objects are needed? What decides which one is asked for the sale?
2. Use the machine class of [the lesson](ruta:objetos.cosas).
3. Create two machines; in the loop, the number read chooses which one to ask for `Sell()`.
4. While the number is not 0, if it is 1 sell at the first one and otherwise at the second; at the end show both states. Close with the variant.
:::

::: variante
Add a method `Load(cans)` and a code 3 that loads 5 cans into the machine with fewer.
:::

::: explicacion
Hidden cases: sales at a single machine, a machine that runs out of cans (the two extra sales only report) and alternating sales.
:::
