---
id: funcional.orden-superior.maximo-reducir
leccion: funcional.orden-superior
tipo: resolver
nivel: arbol
obligatorio: false
titulo: The greatest, by reducing
---

::: enunciado
Read numbers until a 0 and show the greatest. If no number arrived, show «No numbers».
:::

::: restriccion
The greatest is computed with `Reduce` and a function `Greater` of two numbers.
:::

```programa rol=referencia
Funcion biggest <- Greater(a Como Entero, b Como Entero)
  Definir biggest Como Entero <- a;
  Si b > a Entonces
    biggest <- b;
  FinSi
FinFuncion

Funcion accumulated <- Reduce(v Como Vector<Entero>, f Como Funcion(Entero, Entero) Como Entero, initial Como Entero)
  Definir accumulated Como Entero <- initial;
  Para Cada item En v Hacer
    accumulated <- f(accumulated, item);
  FinPara
FinFuncion

Algoritmo Maximum
  Definir numbers Como Vector<Entero> <- Vector();
  Definir number Como Entero;
  Leer number;
  Mientras number <> 0 Hacer
    numbers.Agregar(number);
    Leer number;
  FinMientras
  Si numbers.Longitud() = 0 Entonces
    Escribir "No numbers";
  Sino
    Escribir Reduce(numbers, Greater, numbers[0]);
  FinSi
FinAlgoritmo
```

```casos
visible | 3 ; 8 ; 2 ; 0 | 8
visible | 5 ; 0 | 5
oculto | -7 ; -2 ; -9 ; 0 | -2
oculto | 0 | No numbers
oculto | 4 ; 4 ; 4 ; 0 | 4
```

```aserciones
- declara-subprograma | Reduce | 3 | The function Reduce, which receives the vector, the function and the initial value, is missing.
```

::: pistas
1. Which value does the greatest have to start with? Does 0 work?
2. It is the `Reduce` of [the lesson](ruta:funcional.orden-superior), with another function.
3. `Greater(a, b)` returns the greater of the two; the initial value is the first number read.
4. If the vector is empty, show the message; otherwise, `Reduce(numbers, Greater, numbers[0])`. Close with the variant.
:::

::: variante
Also show the smallest, without writing another walk.
:::

::: explicacion
Starting at 0 fails with all negatives: that is why the initial value is the first number. Hidden cases: all negative, none and repeats.
:::
