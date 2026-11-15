---
id: motor.efectos
numero: "13.4"
tipo: motor
titulo: Orden de los efectos y la cinta
anclas: [ENG.EXEC.EFFECT-ORDER#R1, ENG.EXEC.EFFECT-ORDER#R2, ENG.EXEC.EFFECT-ORDER#R3, ENG.EXEC.EFFECT-ORDER#R4, ENG.EXEC.EFFECT-ORDER#R5, ENG.EXEC.EFFECT-COMMIT#R1, ENG.EXEC.EFFECT-COMMIT#R2, ENG.EXEC.EFFECT-COMMIT#R3, ENG.EXEC.EFFECT-COMMIT#R4, ENG.EXEC.EFFECT-COMMIT#R5, ENG.EFFECT.TAPE#R1, ENG.EFFECT.TAPE#R2, ENG.EFFECT.TAPE#R3, ENG.EFFECT.TAPE#R4, ENG.EFFECT.TAPE#R5, ENG.EFFECT.TAPE#R6]
diagnosticos: [divisionByZero]
terminos: [efecto, cinta, reproducción]
---

::: frase
Todo lo que un programa hace hacia fuera ocurre en el orden del programa y queda anotado en una **cinta**, con la que la ejecución se puede reproducir sin volver a tocar el mundo.
:::

## Cómo funciona {#funciona}

Los **efectos observables** son la salida, la entrada, las operaciones con capacidades, el fallo y la terminación. Ocurren exactamente en el orden que fijan las reglas del lenguaje. Los cálculos sin efectos se pueden reordenar por dentro, pero nunca de forma que se note.

Una sentencia que falla **no produce efectos parciales**. `Escribir` calcula todas sus expresiones antes de escribir nada:

```programa id=sin-parcial titulo="Un Escribir que no llega a escribir" ejecutar termina=failed
Algoritmo SinParcial
  Definir cero Como Entero <- 0;
  Escribir "antes";
  Escribir "uno ", 1 div cero;
FinAlgoritmo
```

```salida
antes
```

```diagnosticos
divisionByZero
```

Cada efecto pasa por dos fases: **pedido**, cuando sus argumentos ya están calculados y recibe un número de secuencia, y **resuelto**, cuando el anfitrión contesta. El resultado es *confirmado*, *fallido* o *incierto*; las lecturas nunca quedan inciertas.

```figura id=cinta-efectos
pie: Cada efecto se anota en la cinta con su número, su tarea y su resultado. Reproducir la cinta da la misma ejecución sin consultar al anfitrión.
```

La **cinta** guarda la identidad de la ejecución —código, perfil, semilla, límites— y una entrada por efecto, encadenadas con un resumen criptográfico. Al reproducir, se comprueba que todo coincide; los datos secretos se guardan redactados.

::: resumen
- Los efectos ocurren en el orden del programa.
- Una sentencia que falla no deja efectos a medias.
- Cada efecto se pide, se resuelve y se anota en la cinta.
- La cinta permite reproducir la ejecución exactamente.
:::

::: vease
- [Efectos y capacidades](#tareas.efectos)
- [Determinismo](#vision.determinismo)
:::
