---
id: lectura.figuras
numero: "0.4"
tipo: concepto
titulo: How to read the figures
anclas: [ENG.STATE.SNAPSHOT#R1, ENG.TRACE.EVENTS#R1]
terminos: [figure, step, memory, trace]
---

::: frase
Figures show what the program text does not: memory, the order in which each part runs and what the engine records.
:::

## How it works {#funciona}

There are two kinds of figures. **Static** ones explain an idea with a single drawing. **Stepped figures** tell a run: below them are "Previous" and "Next" buttons and a text explaining each step.

Stepped figures come with **zones**. Each zone is a panel that grows as you move forward:

- **Memory**: the variables and their value at that moment.
- **Output**: what the program has already written.
- **Trace**: the events the engine recorded, such as "enters statement" or "decision".

```figura id=leer-figura
pie: A stepped figure. The drawing highlights the part being run; the zones below collect memory, output and trace.
paso: The engine creates the variable `total` with the value 0.
paso: It adds 5 and the total becomes 5.
paso: It writes the total. The output receives the line "5".
panel Memory 1: `total` = 0
panel Memory 2: `total` = 5
panel Output 3: 5
panel Trace 1: enters statement · line 2
panel Trace 2: enters statement · line 3
panel Trace 3: writes · 5
```

This is the program the figure tells:

```programa id=suma titulo="Add and write"
```

## Figure colours {#colores}

Figures use the same colours as the editor and switch by themselves with the light or dark theme. Solid boxes are values or instructions; dashed boxes are slots or things that do not exist yet. Red marks what fails or does not run; green, what ends well.

::: resumen
- Static figures explain an idea; stepped figures tell a run.
- The Memory, Output and Trace zones grow with each step.
- Colours follow the editor and the system theme.
:::

::: vease
- [The journey of a program](#vision.viaje)
- [Observation: trace and checkpoints](#motor.observacion)
:::
