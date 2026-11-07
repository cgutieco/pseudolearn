---
id: tareas.efectos
numero: "11.4"
tipo: concepto
titulo: Effects and capabilities
anclas: [LANG.CAPABILITY.MODEL#R1, LANG.CAPABILITY.MODEL#R2, LANG.CAPABILITY.MODEL#R3, LANG.CAPABILITY.MODEL#R4]
fichas: [construction.capabilities, help.pg501.request_console, help.pg501.console_write, help.pgs07.console_set_exit_code, help.pgs07.console_write_error]
diagnosticos: [incompatiblePropagationType]
terminos: [capability, effect, host]
---

::: frase
To touch the outside world —the console, files, the clock, the network— a program asks for a **capability**: a key that gives access to one single thing.
:::

## How it works {#funciona}

A **capability** is an opaque value that stands for a specific permission. There is one family per resource:

| Capability | What for |
|---|---|
| `Console` | writing to the output and the error output, setting the exit code |
| `Arguments` | reading the program's arguments |
| `Environment` | reading environment variables |
| `DirCap`, `FileCap` | folders and files |
| `Clock`, `Timer` | the time and waits |
| `NetworkCap` | HTTP requests |

They are requested with a `request…` function and return a `Result`: the host grants the family if it supports it, or returns an `IoError`. With `Propagate` the error is simply returned to the caller.

```figura id=capacidades-llaves
pie: The program does not touch the host directly: every resource is used through its key, which the host handed over when asked.
```

```programa id=consola titulo="Warning through the error output"
```

Capabilities cannot be forged or manipulated: each one carries a slot, a generation and some rights. They can be **narrowed** —a subdirectory, a single web origin— but never widened. Closing a capability invalidates it: using it afterwards gives the error `CapacidadCerrada`.

::: limite
- Effects are only performed from a `Subroutine` or the algorithm, never from a [`Function`](#subprogramas.pureza).
- Analysis does not ask the host: which families it supports is discovered when running.
:::

::: resumen
- A capability is the key to an outside resource.
- It is requested with `request…` and arrives as a `Result`.
- It can be narrowed but not widened; once closed, it no longer works.
:::

::: vease
- [Files](#biblioteca.archivos)
- [Time](#biblioteca.tiempo)
- [HTTP](#biblioteca.http)
- [Purity](#subprogramas.pureza)
:::
