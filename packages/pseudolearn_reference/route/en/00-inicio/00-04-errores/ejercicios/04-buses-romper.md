---
id: inicio.errores.buses-romper
leccion: inicio.errores
tipo: romperlo
nivel: brote
obligatorio: true
titulo: Breaking the bus program
---

::: enunciado
This program computes how many 40-seat buses are needed. With 95 pupils it says 3, which is right. Find a number of pupils for which it gets it wrong.
:::

```programa rol=defectuoso
```

```programa rol=referencia
```

```casos
```

```rompe
```

::: pistas
1. Do worked examples with several numbers. When do you need exactly a whole number of buses?
2. Think about the edge cases: what happens right when the pupils fill the buses with nobody left over?
3. Remember Beto in [the first lesson](ruta:inicio.primer-problema): adding 1 «in case some are left» fails when none are left.
4. With 80 pupils the program says 3 and 2 are needed. Close with the variant.
:::

::: variante
Find another number that breaks it, and a third one greater than 100. (Any multiple of 40: 40, 120, 160.)
:::

::: docentes
Any multiple of 40 breaks the program. Ask them to explain why before typing the input.
:::
