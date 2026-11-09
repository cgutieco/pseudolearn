---
id: objetos.invariantes.atributo-privado
leccion: objetos.invariantes
tipo: modificar
nivel: brote
obligatorio: true
titulo: The balance, inside
---

::: enunciado
In this program, the balance of the card is in view and the main algorithm changes it directly. Rewrite the card so that the balance is protected and the main algorithm only makes requests to it, without changing what it shows.
:::

::: restriccion
The attribute `saldo` of the class `Tarjeta` is private; the card offers methods to create it with its balance, charge and check the balance.
:::

```programa rol=inicial
```

```programa rol=referencia
```

```casos
```

```aserciones
- declara-miembro | Tarjeta | saldo | privado | The attribute saldo of the class Tarjeta has to be private.
```

::: pistas
1. Which lines of the main algorithm touch the balance directly? Those will have to become methods.
2. Look at the card of [the lesson](ruta:objetos.invariantes): constructor, `Cobrar` and `Saldo`.
3. Mark the attribute as private and move the charge check into a method.
4. The main algorithm creates the card with its balance, asks it to charge and shows `Saldo()`. Close with the variant.
:::

::: variante
Try, from the main algorithm, to set the balance directly. What does the engine say?
:::

::: explicacion
The assertion checks that `saldo` is private. The cases are those of the initial program: what is shown does not change, but now the rule lives in the class.
:::
