---
id: motor.nativo
numero: "13.7"
tipo: motor
titulo: Native code and the host
anclas: [RT.ABI#R1, RT.ABI#R2, RT.ABI#R3, RT.ABI#R4, RT.ABI#R5, RT.LINKING#R1, RT.LINKING#R2, RT.LINKING#R3, RT.LINKING#R4, RT.LINKING#R5, RT.HOST.INTERFACE#R1, RT.HOST.INTERFACE#R2, RT.HOST.INTERFACE#R3, RT.HOST.INTERFACE#R4, RT.HOST.INTERFACE#R5, RT.HOST.INTERFACE#R6, RT.HOST.INTERFACE#R7, RT.HOST.INTERFACE#R8, RT.HOST.INTERFACE#R9, RT.FAULT.REPORTING#R1, RT.FAULT.REPORTING#R2, RT.FAULT.REPORTING#R3]
diagnosticos: [divisionByZero]
terminos: [executable, host, linking]
---

::: frase
A program can also be compiled to a native executable that behaves exactly as in the virtual machine: the same output, the same failures, the same messages.
:::

## How it works {#funciona}

`pseudo compilar` translates the intermediate representation to native code and links it with PseudoLearn's **runtime** into a single executable: Mach-O on macOS, static ELF on Linux and `.exe` on Windows. No compiler or linker needs to be installed: PseudoLearn brings its own, and intermediate files are always deleted at the end.

```figura id=compilar-nativo
pie: The same intermediate representation feeds the virtual machine and the native compiler. Both runs are indistinguishable.
```

Inside the executable, every value crosses the boundary with the same encoding as in the virtual machine: 64-bit integers, binary64 reals, booleans as 0 or 1 and 32-bit handles for texts, arrays and objects. The collector only examines registered roots, so no live object is lost.

The **host** —the app, the terminal or the executable— provides input and output, grants capabilities and decides the delivery order of pending effects, which is recorded on the tape. The random source is the same everywhere: `xoshiro256**` started from the seed with SplitMix64.

```programa id=fallo-nativo titulo="A failure with the previous output kept"
```

Compiled, this program writes `calculando` on standard output and then reports the failure, with the same code and position, on the error output. No language failure becomes an operating-system signal.

::: resumen
- `pseudo compilar` produces a standalone native executable.
- The executable behaves exactly like the virtual machine.
- Failures are reported with their diagnostic, without system signals.
:::

::: vease
- [The engine's layers](#motor.capas)
- [Effect order](#motor.efectos)
:::
