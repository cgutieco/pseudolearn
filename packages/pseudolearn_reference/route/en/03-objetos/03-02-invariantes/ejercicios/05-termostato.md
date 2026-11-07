---
id: objetos.invariantes.termostato
leccion: objetos.invariantes
tipo: resolver
nivel: arbol
obligatorio: false
titulo: The classroom thermostat
---

::: enunciado
The classroom thermostat starts at 20 degrees and can never go above 30 or below 16. Read orders, `+` to go up a degree and `-` to go down, until the word `fin`, and show the final degrees.
:::

::: restriccion
A class `Termostato` with private degrees and the methods `Subir`, `Bajar` and `Grados`.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-miembro | Termostato | grados | privado | The degrees of the thermostat have to be private.
```

::: pistas
1. What always has to be true of the thermostat?
2. It is the card of [the lesson](ruta:objetos.invariantes): each method looks after the invariant.
3. `Subir` only goes up if it has not reached 30 yet; `Bajar`, if it has not reached 16.
4. A private attribute that starts at 20 and two methods that check the limit before changing it. Close with the variant.
:::

::: variante
Add `Fijar(grados)`, which accepts only values inside the range.
:::

::: docentes
Hidden cases: going up past 30, going down past 16, no orders and going down after touching the ceiling.
:::
