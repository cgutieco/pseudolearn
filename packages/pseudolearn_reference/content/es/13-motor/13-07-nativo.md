---
id: motor.nativo
numero: "13.7"
tipo: motor
titulo: Código nativo y anfitrión
anclas: [RT.ABI#R1, RT.ABI#R2, RT.ABI#R3, RT.ABI#R4, RT.ABI#R5, RT.LINKING#R1, RT.LINKING#R2, RT.LINKING#R3, RT.LINKING#R4, RT.LINKING#R5, RT.HOST.INTERFACE#R1, RT.HOST.INTERFACE#R2, RT.HOST.INTERFACE#R3, RT.HOST.INTERFACE#R4, RT.HOST.INTERFACE#R5, RT.HOST.INTERFACE#R6, RT.HOST.INTERFACE#R7, RT.HOST.INTERFACE#R8, RT.HOST.INTERFACE#R9, RT.FAULT.REPORTING#R1, RT.FAULT.REPORTING#R2, RT.FAULT.REPORTING#R3]
diagnosticos: [divisionByZero]
terminos: [ejecutable, anfitrión, enlace]
---

::: frase
Un programa también se puede compilar a un ejecutable nativo que se comporta exactamente igual que en la máquina virtual: la misma salida, los mismos fallos, los mismos mensajes.
:::

## Cómo funciona {#funciona}

`pseudo compilar` traduce la representación intermedia a código nativo y lo enlaza con el **runtime** de PseudoLearn en un único ejecutable: Mach-O en macOS, ELF estático en Linux y `.exe` en Windows. No hace falta tener instalado un compilador ni un enlazador: PseudoLearn trae el suyo, y los archivos intermedios se borran siempre al terminar.

```figura id=compilar-nativo
pie: La misma representación intermedia alimenta la máquina virtual y el compilador nativo. Las dos ejecuciones son indistinguibles.
```

Dentro del ejecutable, cada valor cruza la frontera con la misma codificación que en la máquina virtual: enteros de 64 bits, reales binary64, lógicos como 0 o 1 y asas de 32 bits para textos, arreglos y objetos. El recolector solo examina las raíces registradas, así que ningún objeto vivo se pierde.

El **anfitrión** —la app, la terminal o el ejecutable— entrega la entrada y la salida, concede las capacidades y decide el orden de entrega de los efectos pendientes, que queda grabado en la cinta. La fuente aleatoria es la misma en todos: `xoshiro256**` iniciado desde la semilla con SplitMix64.

```programa id=fallo-nativo titulo="Un fallo con la salida previa conservada" ejecutar termina=failed
Algoritmo FalloNativo
  Definir cero Como Entero <- 0;
  Escribir "calculando";
  Escribir 10 div cero;
FinAlgoritmo
```

```salida
calculando
```

```diagnosticos
divisionByZero
```

Compilado, este programa escribe `calculando` en la salida estándar y después informa el fallo, con el mismo código y la misma posición, en la salida de error. Ningún fallo del lenguaje se convierte en una señal del sistema operativo.

::: resumen
- `pseudo compilar` produce un ejecutable nativo autónomo.
- El ejecutable se comporta igual que la máquina virtual.
- Los fallos se informan con su diagnóstico, sin señales del sistema.
:::

::: vease
- [Las capas del motor](#motor.capas)
- [Orden de los efectos](#motor.efectos)
:::
