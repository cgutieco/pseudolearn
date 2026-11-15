---
id: inicio.errores.promedio-dos
leccion: inicio.errores
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: The average of two marks
---

::: enunciado
The program reads two marks and shows their average. With 7 and 8 it shows 7. Find the error and fix it.
:::

```programa rol=inicial
Algoritmo Average
  Definir first Como Entero;
  Definir second Como Entero;
  Leer first;
  Leer second;
  Escribir (first + second) div 2;
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Average
  Definir first Como Entero;
  Definir second Como Entero;
  Leer first;
  Leer second;
  Escribir (first + second) / 2;
FinAlgoritmo
```

```casos
visible | 7 ; 8 | 7.5
visible | 6 ; 6 | 6.0
oculto | 10 ; 9 | 9.5
oculto | 0 ; 1 | 0.5
oculto | 5 ; 8 | 6.5
```

::: pistas
1. Is it a compile error, a runtime error or a logic error? How do you know?
2. Do the worked example with 7 and 8. Which part of 7.5 was lost?
3. There are two ways of dividing. Look at the difference in [the Specification](especificacion:expresiones.division).
4. Change `div` for `/`: `Write (first + second) / 2;`. Close with the variant.
:::

::: variante
With 6 and 6 the fixed program shows `6.0`, not `6`. Why? (Because `/` always gives a number with decimals.)
:::

::: explicacion
It is a logic error: it compiles, finishes and shows a number. The 6 and 6 case is the one that does not uncover it; that is why you need more than one case.
:::
