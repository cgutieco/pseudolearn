---
id: imperativo.contado.suma-digitos
leccion: imperativo.contado
tipo: resolver
nivel: arbol
obligatorio: false
titulo: The sum of the digits
---

::: enunciado
Read a non-negative whole number and show the sum of its digits. The program shows only the number.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. By hand with 1234: how do you separate the last digit? How do you keep the rest of the number?
2. Sharing out in tens separates the last digit from the others. Look at sharing out in [lesson 0.2](ruta:inicio.nombres).
3. Do you know how many digits the number has? That decides the way of repeating.
4. While there are digits left: add `n mod 10` and keep `n div 10`. Close with the variant.
:::

::: variante
Show how many digits the number has. What happens with 0?
:::

::: docentes
You do not know beforehand how many digits there are: `While` goes. 0 makes zero passes and adds 0, which is right.
:::
