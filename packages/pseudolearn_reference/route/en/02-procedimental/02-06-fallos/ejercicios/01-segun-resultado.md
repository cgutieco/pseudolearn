---
id: procedimental.fallos.segun-resultado
leccion: procedimental.fallos
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Success or reason
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
SubProceso SafeDivide(a Como Entero, b Como Entero) Como Resultado<Entero, Cadena>
  Si b = 0 Entonces
    Retornar Error("Cannot divide by 0");
  FinSi
  Retornar Exito(a div b);
FinSubProceso

Algoritmo Division
  Segun SafeDivide(9, 3) Hacer
    Exito(quotient): Escribir quotient;
    Error(reason): Escribir reason;
  FinSegun
  Segun SafeDivide(1, 0) Hacer
    Exito(quotient): Escribir quotient;
    Error(reason): Escribir reason;
  FinSegun
FinAlgoritmo
```

```salida
3
Cannot divide by 0
```

::: explicacion
The first call returns `Success(3)` and the `Switch` shows the quotient. The second returns `Failure` with the reason, and the `Switch` shows the reason. The program stops at neither.
:::
