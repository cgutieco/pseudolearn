---
id: biblioteca.tiempo
numero: "12.10"
tipo: concepto
titulo: Time and dates
anclas: [LIB.TIME#R1, LIB.TIME#R2, LIB.TIME#R3, LIB.TIME#R4, LIB.TIME#R5, LIB.TIME#R6, LIB.TIME#R7, LIB.TIME#R8]
diagnosticos: [incompatiblePropagationType]
terminos: [instant, UTC offset, DateTime]
---

::: frase
The clock gives instants in nanoseconds, the timer waits, and `DateTime` turns an instant into year, month, day and time without depending on the machine.
:::

## How it works {#funciona}

There are two parts:

- **With a capability**: `Clock` reads the host's time (`now`, `localNow`) and `Timer` waits for a while (`wait`). Every reading is recorded, so a repeated run returns the same instants.
- **Without a capability**: `DateTime` is a value that keeps an instant and a UTC offset. It is created with `dateTimeOf`, `dateTimeUtc` or `parseDateTime`, and its parts and ISO 8601 text are taken from it.

```figura id=fecha-hora
pie: A `DateTime` keeps an instant and an offset. Its parts are computed on the local time obtained by adding them.
```

```programa id=fechas titulo="Building and showing dates"
```

`weekday` follows ISO 8601: 1 is Monday and 7 Sunday. The calendar is the Gregorian one without leap seconds.

```programa id=pausa titulo="Measuring a wait"
```

::: limite
- Invalid dates do not fail: `dateTimeOf` returns `Nothing`.
- The UTC offset goes from -18 to +18 hours, in seconds.
:::

::: resumen
- `Clock` and `Timer` are capabilities; their readings are recorded.
- `DateTime` is a pure value with an instant and an offset.
- Parts and ISO text are computed without depending on the machine.
:::

::: vease
- [Effects and capabilities](#tareas.efectos)
- [Determinism](#vision.determinismo)
:::
