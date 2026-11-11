---
id: procedimental.fallos.division
leccion: procedimental.fallos
tipo: resolver
nivel: brote
obligatorio: true
titulo: A division that warns
---

::: enunciado
Read two whole numbers and show the whole quotient of the first by the second, or «Cannot divide by 0».
:::

::: restriccion
The division goes in a subprogram `SafeDivide` that receives both numbers and returns the quotient or the reason.
:::

```programa rol=referencia
SubProceso SafeDivide(a Como Entero, b Como Entero) Como Resultado<Entero, Cadena>
  Si b = 0 Entonces
    Retornar Error("Cannot divide by 0");
  FinSi
  Retornar Exito(a div b);
FinSubProceso

Algoritmo Division
  Definir a, b Como Entero;
  Leer a;
  Leer b;
  Segun SafeDivide(a, b) Hacer
    Exito(quotient): Escribir quotient;
    Error(reason): Escribir reason;
  FinSegun
FinAlgoritmo
```

```casos
visible | 10 ; 2 | 5
visible | 7 ; 0 | Cannot divide by 0
oculto | 0 ; 5 | 0
oculto | 0 ; 0 | Cannot divide by 0
oculto | 9 ; 4 | 2
```

```aserciones
- declara-subprograma | SafeDivide | 2 | The subprogram SafeDivide, which receives both numbers, is missing.
```

::: pistas
1. Which input has to give a reason instead of a number?
2. Look at dividing without crashing in [the lesson](ruta:procedimental.fallos).
3. The subprogram returns a success or an error; the main algorithm handles them with a `Switch`.
4. `SafeDivide` returns `Failure` if the divisor is 0 and `Success(a div b)` otherwise. Close with the variant.
:::

::: variante
Add a second reason: «The dividend is negative».
:::

::: explicacion
Hidden cases: 0 in the numerator (it is valid) and 0 by 0 (it is an error). Frequent mistake: checking the numerator instead of the divisor.
:::
