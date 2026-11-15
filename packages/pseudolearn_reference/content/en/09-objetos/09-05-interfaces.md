---
id: objetos.interfaces
numero: "9.5"
tipo: concepto
titulo: Interfaces
anclas: [LANG.TYPES.INTERFACE#R1, LANG.TYPES.INTERFACE#R2, LANG.TYPES.INTERFACE#R3]
fichas: [construction.interface]
diagnosticos: [interfaceMethodSignatureMismatch]
terminos: [interface, realization, constraint]
---

::: frase
An interface is a list of methods a class **promises** to have; it lets you write code that works with any class that keeps the promise.
:::

## How it works {#funciona}

`Interface` declares method signatures without bodies. A class **realizes** it explicitly with `Realizes`, and must then declare those methods with the exact signature.

```figura id=interfaz-promesa
pie: `Cuadrado` and `Circulo` realize `Figura`. `Describir` only knows the promise and accepts both.
```

Interfaces are not value types: no variables of an interface type are declared. They are used as a **constraint** on a generic type parameter: `T: Figura` accepts any class that realizes `Figura`.

```programa id=figuras titulo="An interface as a constraint"
```

Realization is **nominal**: a class that happens to have an `Area` method but does not declare `Realizes Figura` does not satisfy the interface. A class can realize several interfaces, separated by commas, and a subclass inherits the realizations of its superclass.

::: errores
```programa id=firma-interfaz titulo="A method that does not match the signature"
```
:::

::: resumen
- An interface declares signatures without bodies.
- A class satisfies it by saying so with `Realizes` and with exact signatures.
- It is used as a generic constraint, not as a variable type.
:::

::: vease
- [Generics](#tipos.genericos)
- [Inheritance and overriding](#objetos.herencia)
- [Purity](#subprogramas.pureza)
:::
