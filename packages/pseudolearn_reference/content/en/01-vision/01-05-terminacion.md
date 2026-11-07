---
id: vision.terminacion
numero: "1.5"
tipo: concepto
titulo: How a program ends
anclas: [ENG.EXEC.MODEL#R1, ENG.EXEC.MODEL#R3, ENG.INPUT#R1, RT.PROCESS#R2]
diagnosticos: [divisionByZero]
terminos: [termination, suspension]
---

::: frase
Every run ends in one of six states: it finished well, it failed, it is waiting for input, it is waiting for the outside world, it was cancelled or it ran out of a limit.
:::

## How it works {#funciona}

When a program stops moving forward, the engine says exactly why. That reason is called the **termination** and it is always one of these six:

| Termination | What it means | Can it continue? |
|---|---|---|
| `completed` | The algorithm reached its `EndAlgorithm` | No: it finished |
| `failed` | A runtime failure stopped it | No |
| `awaiting_input` | A `Read` needs a value that has not arrived yet | Yes, once it receives it |
| `awaiting_effect` | It is waiting for an answer from a file, clock or network | Yes, once it receives it |
| `cancelled` | Whoever was running it stopped it | No |
| `limit_reached` | It ran out of a statement, memory or depth budget | No |

```figura id=terminaciones
pie: From "running" one of six states is reached. Two of them are pauses you can come back from.
```

The normal case is `completed`:

```programa id=bien titulo="Ends normally"
```

A runtime failure stops the program at the exact statement. What was already written is kept:

```programa id=falla titulo="Ends with a failure"
```

If a `Read` receives no value, the program pauses. The editor asks you for the data and the run continues where it stopped:

```programa id=espera titulo="Waits for input"
```

::: limite
The terminations `completed`, `failed`, `cancelled` and `limit_reached` are final: no more effects happen after them. The pauses `awaiting_input` and `awaiting_effect` resume at exactly the statement where they stopped.
:::

::: resumen
- Six possible terminations; only `completed` means everything went well.
- A failure stops the program at the exact statement and keeps what was already written.
- `awaiting_input` and `awaiting_effect` are pauses that resume.
:::

::: vease
- [Errors, warnings and failures](#vision.errores)
- [Effect failure, trap and host cut](#diagnosticos.fallos)
- [Execution limits](#motor.limites)
:::
