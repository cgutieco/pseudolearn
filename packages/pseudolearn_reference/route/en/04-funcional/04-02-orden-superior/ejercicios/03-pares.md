---
id: funcional.orden-superior.pares
leccion: funcional.orden-superior
tipo: resolver
nivel: brote
obligatorio: true
titulo: Only the even ones
---

::: enunciado
Read numbers until a 0 and show the list of the even ones, in the order they arrived, such as `[4, 2]`.
:::

::: restriccion
A function `Filter` that receives the vector and a condition, and a function `IsEven` that is passed to it as a value.
:::

```programa rol=referencia
Funcion even <- IsEven(x Como Entero)
  Definir even Como Logico;
  even <- x mod 2 = 0;
FinFuncion

Funcion chosen <- Filter(v Como Vector<Entero>, condition Como Funcion(Entero) Como Logico)
  Definir chosen Como Vector<Entero> <- Vector();
  Para Cada item En v Hacer
    Si condition(item) Entonces
      chosen.Agregar(item);
    FinSi
  FinPara
FinFuncion

Algoritmo Evens
  Definir numbers Como Vector<Entero> <- Vector();
  Definir number Como Entero;
  Leer number;
  Mientras number <> 0 Hacer
    numbers.Agregar(number);
    Leer number;
  FinMientras
  Escribir Filter(numbers, IsEven);
FinAlgoritmo
```

```casos
```

```aserciones
- declara-subprograma | Filter | 2 | The function Filter, which receives the vector and the condition, is missing.
```

::: pistas
1. Does the result have the same length as the numbers read?
2. It is the `Filter` of [the lesson](ruta:funcional.orden-superior), with another condition.
3. Keep the numbers in a vector; the condition is a function that says whether a number is even.
4. `Write Filter(numbers, IsEven);` after reading. Close with the variant.
:::

::: variante
Show the sum of the even ones with `Reduce`.
:::

::: explicacion
Hidden cases: no even number, 0 straight away and negative even numbers. Frequent mistake: passing `IsEven(x)`, which is a value and not the function.
:::
