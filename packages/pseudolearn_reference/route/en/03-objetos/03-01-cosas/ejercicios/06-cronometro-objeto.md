---
id: objetos.cosas.cronometro-objeto
leccion: objetos.cosas
tipo: resolver
nivel: arbol
obligatorio: false
titulo: The stopwatch as an object
---

::: enunciado
Read two amounts of seconds, move a stopwatch forward with each one and show it in the format `1 h 2 min 5 s`.
:::

::: restriccion
A class `Cronometro` with a method `Avanzar(segundos)` and another `Lectura()` that returns the text.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-miembro | Cronometro | Avanzar | publico | The public method Avanzar is missing from the class Cronometro.
- declara-miembro | Cronometro | Lectura | publico | The public method Lectura is missing from the class Cronometro.
```

::: pistas
1. What does the stopwatch have to remember between one call and another?
2. The format is that of the stopwatch of [lesson 0.2](ruta:inicio.nombres); the state is kept like the counter of [the lesson](ruta:objetos.cosas).
3. An attribute with the total of seconds; `Avanzar` adds; `Lectura` shares out into hours, minutes and seconds.
4. `Lectura` builds the text with `ToText` and concatenation. Close with the variant.
:::

::: variante
Add `Reiniciar()`, which sets the stopwatch back to 0.
:::

::: docentes
Hidden cases: the stopwatch without moving, just before the minute, an exact hour and the last second of the day.
:::
