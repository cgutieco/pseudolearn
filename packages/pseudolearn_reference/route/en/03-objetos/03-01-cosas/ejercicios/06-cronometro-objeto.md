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
A class `Stopwatch` with a method `Advance(seconds)` and another `Reading()` that returns the text.
:::

```programa rol=referencia
Clase Stopwatch
  Definir total Como Entero;

  Metodo Constructor()
    Este.total <- 0;
  FinMetodo

  Metodo Advance(seconds Como Entero)
    Este.total <- Este.total + seconds;
  FinMetodo

  Metodo Reading() Como Cadena
    Definir hours Como Entero <- Este.total div 3600;
    Definir minutes Como Entero <- Este.total mod 3600 div 60;
    Retornar ConvertirATexto(hours) + " h " + ConvertirATexto(minutes) + " min " + ConvertirATexto(Este.total mod 60) + " s";
  FinMetodo
FinClase

Algoritmo Race
  Definir watch Como Stopwatch <- Nuevo Stopwatch();
  Definir seconds Como Entero;
  Leer seconds;
  watch.Advance(seconds);
  Leer seconds;
  watch.Advance(seconds);
  Escribir watch.Reading();
FinAlgoritmo
```

```casos
visible | 3600 ; 125 | 1 h 2 min 5 s
visible | 30 ; 30 | 0 h 1 min 0 s
oculto | 0 ; 0 | 0 h 0 min 0 s
oculto | 59 ; 0 | 0 h 0 min 59 s
oculto | 3600 ; 0 | 1 h 0 min 0 s
oculto | 86399 ; 0 | 23 h 59 min 59 s
```

```aserciones
- declara-miembro | Stopwatch | Advance | publico | The public method Advance is missing from the class Stopwatch.
- declara-miembro | Stopwatch | Reading | publico | The public method Reading is missing from the class Stopwatch.
```

::: pistas
1. What does the stopwatch have to remember between one call and another?
2. The format is that of the stopwatch of [lesson 0.2](ruta:inicio.nombres); the state is kept like the counter of [the lesson](ruta:objetos.cosas).
3. An attribute with the total of seconds; `Advance` adds; `Reading` shares out into hours, minutes and seconds.
4. `Reading` builds the text with `toText` and concatenation. Close with the variant.
:::

::: variante
Add `Reset()`, which sets the stopwatch back to 0.
:::

::: explicacion
Hidden cases: the stopwatch without moving, just before the minute, an exact hour and the last second of the day.
:::
