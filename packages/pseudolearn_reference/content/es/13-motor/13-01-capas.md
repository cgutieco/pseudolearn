---
id: motor.capas
numero: "13.1"
tipo: motor
titulo: Las capas del motor
anclas: [IR.LOWERING#R1, IR.LOWERING#R2, IR.LOWERING#R3]
terminos: [representación intermedia, máquina virtual, compilación]
---

::: frase
El motor procesa un programa en capas: cada una recibe el resultado de la anterior, lo comprueba o lo transforma y se lo pasa a la siguiente.
:::

## Cómo funciona {#funciona}

```figura id=capas-motor
pie: Del texto a la ejecución. Las tres primeras capas analizan; la representación intermedia es el punto donde se separan la máquina virtual y el código nativo.
```

| Capa | Recibe | Entrega |
|---|---|---|
| léxico | texto | fichas: palabras, números, signos |
| sintaxis | fichas | árbol del programa |
| semántica | árbol | árbol con tipos y nombres resueltos |
| representación intermedia | árbol comprobado | bloques de instrucciones simples |
| máquina virtual o código nativo | representación intermedia | la ejecución |

La **representación intermedia** (RI) es la pieza central. Cada sentencia se marca con una entrada y una salida, y cada decisión con su rama: así la ejecución puede contar exactamente lo que pasa. Traducir a la RI **no cambia el significado**: ejecutarla da las mismas salidas, en el mismo orden, que dicta el lenguaje.

```programa id=pequeno titulo="Un programa pequeño" ejecutar
Algoritmo Pequeno
  Definir n Como Entero <- 2;
  Si n > 1 Entonces
    Escribir "grande";
  FinSi
FinAlgoritmo
```

```salida
grande
```

```ri programa=pequeno
```

::: resumen
- El motor trabaja en capas: léxico, sintaxis, semántica, RI y ejecución.
- La RI marca sentencias y decisiones para que la ejecución sea observable.
- Traducir a la RI conserva el significado.
:::

::: vease
- [El viaje de un programa](#vision.viaje)
- [Observar la ejecución](#motor.observacion)
- [Código nativo](#motor.nativo)
:::
