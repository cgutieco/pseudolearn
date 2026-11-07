---
id: objetos.cosas.alcancia-objeto
leccion: objetos.cosas
tipo: resolver
nivel: semilla
obligatorio: true
titulo: The money box as an object
---

::: enunciado
Read coin deposits until a 0 and show the total gathered. The program shows only the number.
:::

::: restriccion
A class `Alcancia` with a public method `Depositar(monedas)` and another `Total()`; the main algorithm only reads, deposits and shows.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-miembro | Alcancia | Depositar | publico | The public method Depositar is missing from the class Alcancia.
```

::: pistas
1. What does a money box know? What does it know how to do?
2. It is the dictated money box of [lesson 1.3](ruta:imperativo.mientras), with the total box kept inside an object, like the counter of [the lesson](ruta:objetos.cosas).
3. An attribute for what was gathered, which starts at 0 in the constructor; `Depositar` adds and `Total` returns it.
4. The main algorithm creates the money box, deposits each value until 0 and shows `Total()`. Close with the variant.
:::

::: variante
Add a method `Romper()` that returns the total and leaves the money box at 0.
:::

::: docentes
The assertion checks that `Depositar` exists and is public. Frequent mistake: adding in the main algorithm and using the class only to keep the number.
:::
