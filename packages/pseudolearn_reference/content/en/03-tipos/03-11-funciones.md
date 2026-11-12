---
id: tipos.funciones
numero: "3.11"
tipo: tipo
titulo: Functions as values
anclas: [LANG.TYPES.FUNCTION#R1]
fichas: [help.function-literal]
diagnosticos: [mutableClosureCapture]
terminos: [function, closure, capture]
---

::: frase
A subroutine is also a value: it can be stored in a variable, passed as an argument or returned, and called later.
:::

## How to write it {#escribe}

```forma
Define «name» As Subroutine(«parameter types») ⟦As «return type»⟧
Subroutine(«parameters») ⟦As «return type»⟧
  «statements»
EndSubroutine
```

```anatomia
Define operacion As | a variable, declared like any other
Subroutine(Integer) | parameter types, in order
As Integer | type it returns; without this part it returns nothing
```

## How it works {#funciona}

The type of a function describes its parameters and its return, for example `Subroutine(Integer) As Integer`. Any subroutine with that shape is a value of that type. A function-typed variable is called as if it were the subroutine itself.

```programa id=aplicar titulo="Storing a subroutine in a variable"
```

## Anonymous functions and closures {#clausuras}

A function can be written in place, without a name: `Subroutine(x As Integer) As Integer … EndSubroutine`. If it uses outside variables, it **captures** them: it takes a copy of their value. That function with its copies is called a **closure**.

```programa id=multiplicador titulo="Multiplier factory"
```

```figura id=clausura
pie: Each closure carries its own copy of `factor`. That is why `doble` and `triple` do not interfere.
```

::: limite
- Only variables that are never reassigned after getting their value can be captured: that way the copy and the original cannot diverge.
- By-reference parameters cannot be captured.
- Functions are not written, not compared and do not cross between tasks.
:::

::: errores
Capturing a variable that changes afterwards is an error, because the closure would see one value and the rest of the program another:

```programa id=captura-mutable titulo="Capturing something that changes"
```
:::

::: por-dentro
A closure is a heap object holding the function's code and an **environment** with the captured copies. The environment outlives the subroutine that created it as long as someone can call the closure, and the collector frees it once nobody can.

```ri programa=multiplicador
```
:::

::: resumen
- A subroutine is a value of type `Subroutine(parameters) As return`.
- It can be stored, passed, returned and called.
- An anonymous function captures copies of the variables it uses.
- Only variables that do not change are captured.
:::

::: vease
- [Declaring subroutines](#subprogramas.declaracion)
- [Generics](#tipos.genericos)
:::
