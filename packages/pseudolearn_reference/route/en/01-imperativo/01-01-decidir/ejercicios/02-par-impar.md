---
id: imperativo.decidir.par-impar
leccion: imperativo.decidir
tipo: resolver
nivel: semilla
obligatorio: true
titulo: Even or odd
---

::: enunciado
Read a whole number and show `even` or `odd`.
:::

```programa rol=referencia
Algoritmo EvenOdd
  Definir number Como Entero;
  Leer number;
  Si number mod 2 = 0 Entonces
    Escribir "even";
  Sino
    Escribir "odd";
  FinSi
FinAlgoritmo
```

```casos
visible | 4 | even
visible | 7 | odd
oculto | 0 | even
oculto | 1 | odd
oculto | -3 | odd
```

::: pistas
1. Build the partition: what are the two regions? Is there a number that makes you hesitate?
2. A number is even if nothing is left over when you share it out in twos. Look at what is left over when sharing in [lesson 0.2](ruta:inicio.nombres).
3. The condition compares what is left over with 0.
4. `If number mod 2 = 0 Then` shows `even`; otherwise, `odd`. Close with the variant.
:::

::: variante
Show `multiple of 3` or `not a multiple of 3`. (With 9: multiple; with 10: not.)
:::

::: explicacion
Hidden cases: 0 is even, 1 is odd and -3 checks negatives. In PseudoLearn, `-3 mod 2` is -1, which is not 0: the solution with `= 0` works; one with `= 1` fails on -3.
:::
