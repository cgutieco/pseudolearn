---
id: funcional.clausuras.captura-cambiante
leccion: funcional.clausuras
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: A backpack that changes
---

::: enunciado
This program reads an amount and a number, and should show the number plus the amount using a manufactured adder. But it does not even start. Find the error and fix it.
:::

```programa rol=inicial
Funcion made <- MakeAdder(amount Como Entero)
  Definir base Como Entero <- amount;
  Definir made Como Funcion(Entero) Como Entero <- Funcion(x Como Entero) Como Entero
    Retornar x + base;
  FinFuncion;
  base <- 0;
FinFuncion

Algoritmo Sums
  Definir n, x Como Entero;
  Leer n;
  Leer x;
  Definir add Como Funcion(Entero) Como Entero <- MakeAdder(n);
  Escribir add(x);
FinAlgoritmo
```

```programa rol=referencia
Funcion made <- MakeAdder(amount Como Entero)
  Definir made Como Funcion(Entero) Como Entero <- Funcion(x Como Entero) Como Entero
    Retornar x + amount;
  FinFuncion;
FinFuncion

Algoritmo Sums
  Definir n, x Como Entero;
  Leer n;
  Leer x;
  Definir add Como Funcion(Entero) Como Entero <- MakeAdder(n);
  Escribir add(x);
FinAlgoritmo
```

```casos
```

::: pistas
1. What does the diagnostic say? Which value is the manufactured function trying to take along?
2. Look at the backpack rule in [the lesson](ruta:funcional.clausuras).
3. The box `base` is reassigned after creating the function. Is that box needed?
4. Capture `amount` directly, which does not change, and remove the reassignment. Close with the variant.
:::

::: variante
Write `MakeSubtractor(amount)` with the same shape.
:::

::: explicacion
The engine rejects capturing a variable that is reassigned later, because the function would not know which value to use. The fix captures the parameter, which does not change.
:::
