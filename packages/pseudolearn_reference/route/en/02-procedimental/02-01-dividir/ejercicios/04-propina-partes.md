---
id: procedimental.dividir.propina-partes
leccion: procedimental.dividir
tipo: modificar
nivel: brote
obligatorio: true
titulo: The tip in parts
---

::: enunciado
This program computes how much each friend pays, with the tip included. Rewrite it in two named pieces: one that computes the total with the tip and another that computes each one's share, without changing what it shows.
:::

::: restriccion
Use a subprogram `TotalWithTip` that receives the bill and another `ShareOfEach` that receives the total and the friends.
:::

```programa rol=inicial
Algoritmo Tip
  Definir bill Como Entero;
  Definir friends Como Entero;
  Leer bill;
  Leer friends;
  Si friends = 0 Entonces
    Escribir "Nobody is there to pay";
  Sino
    Escribir "Each one pays: ", techo((bill + bill div 10) / friends);
  FinSi
FinAlgoritmo
```

```programa rol=referencia
SubProceso TotalWithTip(bill Como Entero) Como Entero
  Retornar bill + bill div 10;
FinSubProceso

SubProceso ShareOfEach(total Como Entero, friends Como Entero) Como Entero
  Retornar techo(total / friends);
FinSubProceso

Algoritmo Tip
  Definir bill Como Entero;
  Definir friends Como Entero;
  Leer bill;
  Leer friends;
  Si friends = 0 Entonces
    Escribir "Nobody is there to pay";
  Sino
    Escribir "Each one pays: ", ShareOfEach(TotalWithTip(bill), friends);
  FinSi
FinAlgoritmo
```

```casos
visible | 120 ; 4 | Each one pays: 33
visible | 100 ; 0 | Nobody is there to pay
oculto | 100 ; 3 | Each one pays: 37
oculto | 100 ; 1 | Each one pays: 110
oculto | 0 ; 5 | Each one pays: 0
```

```aserciones
- declara-subprograma | TotalWithTip | 1 | The subprogram TotalWithTip, which receives the bill, is missing.
- declara-subprograma | ShareOfEach | 2 | The subprogram ShareOfEach, which receives the total and the friends, is missing.
```

::: pistas
1. Which sum does the program do in a single line? Into which two parts can it be cut?
2. Look at the report card in [the lesson](ruta:procedimental.dividir): each sum has its subprogram.
3. One receives the bill and returns the total; the other receives the total and the friends and returns the share.
4. `ShareOfEach(TotalWithTip(bill), friends)` replaces the long sum. Close with the variant.
:::

::: variante
Change the tip to 15 %. How many lines did you touch?
:::

::: explicacion
The cases are those of the original calculator: what it shows does not change. The assertions check both names and how many parameters each one receives.
:::
