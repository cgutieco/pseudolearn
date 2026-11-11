---
id: procedimental.puras.separar
leccion: procedimental.puras
tipo: modificar
nivel: brote
obligatorio: true
titulo: Separating the calculation
---

::: enunciado
This program asks for a price and shows the price with 21 % VAT, all inside the same piece. Rewrite it so that the calculation goes in a piece that only computes, without changing what it shows.
:::

::: restriccion
The calculation goes in a `Function WithVat` that receives the price; the main algorithm reads and shows.
:::

```programa rol=inicial
SubProceso ShowWithVat()
  Definir price Como Entero;
  Leer price;
  Escribir price + price * 21 div 100;
FinSubProceso

Algoritmo Main
  ShowWithVat();
FinAlgoritmo
```

```programa rol=referencia
Funcion total <- WithVat(price Como Entero)
  Definir total Como Entero;
  total <- price + price * 21 div 100;
FinFuncion

Algoritmo Main
  Definir price Como Entero;
  Leer price;
  Escribir WithVat(price);
FinAlgoritmo
```

```casos
visible | 100 | 121
visible | 50 | 60
oculto | 0 | 0
oculto | 200 | 242
oculto | 7 | 8
```

```aserciones
- declara-subprograma | WithVat | 1 | The piece WithVat, which receives the price and returns the price with VAT, is missing.
```

::: pistas
1. Mark which lines ask, which ones show and which ones compute.
2. It is the same fix as the discounted price in [the lesson](ruta:procedimental.puras).
3. The new piece receives the price and returns the result; the main algorithm does the reading and the writing.
4. `Function total <- WithVat(price As Integer)` with the calculation inside, and the main algorithm reads, calls and shows. Close with the variant.
:::

::: variante
Use `WithVat` to show the total with VAT of two products read.
:::

::: explicacion
The assertion checks that `WithVat` exists with one parameter; that it is a `Function`, and therefore pure, is checked by the engine itself when compiling it. The cases are those of the initial program: what is shown does not change.
:::
