---
id: objetos.responsabilidades.mover-metodo
leccion: objetos.responsabilidades
tipo: modificar
nivel: brote
obligatorio: false
titulo: The amount in its place
---

::: enunciado
In this program, the till computes the amount of each sale with the product's price. Move that calculation to the product, which is the one that knows its price, without changing what the program shows.
:::

::: restriccion
`Producto` has a public method `Importe(cantidad)`, and the till asks it.
:::

```programa rol=inicial
```

```programa rol=referencia
```

```casos
```

```aserciones
- declara-miembro | Producto | Importe | publico | The public method Importe is missing from the class Producto.
```

::: pistas
1. Which data does the calculation of the amount need? Which piece has it?
2. Look at the cards of [the lesson](ruta:objetos.responsabilidades).
3. The product gains a method; the till stops multiplying and asks it.
4. `Method Importe(cantidad As Integer) As Integer` in `Producto`, and the till uses `producto.Importe(cantidad)`. Close with the variant.
:::

::: variante
Add a 10 % tax to the sandwiches. Which pieces did you change?
:::

::: explicacion
The assertion checks that `Producto` has `Importe`. The cases are those of the initial program: what is shown does not change, but the calculation goes where the information is.
:::
