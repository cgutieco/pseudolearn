---
id: inicio.preguntar.que-calcula
leccion: inicio.preguntar
tipo: explicar
nivel: semilla
obligatorio: false
titulo: What is it for?
---

::: enunciado
Choose the sentence that best explains what this program solves.
:::

```programa rol=objeto id=misterio
Algoritmo Mystery
  Definir length Como Entero;
  Definir width Como Entero;
  Leer length;
  Leer width;
  Escribir length * width;
FinAlgoritmo
```

```entrada
4
3
```

```salida
12
```

```opciones
- [ ] It multiplies two numbers. | It describes how it does it, not what it solves.
- [x] It computes the area of a rectangle from its length and its width. | It talks about the problem and uses the names of the boxes: `length` and `width`.
- [ ] It adds two numbers. | It is false: the program multiplies.
```

::: explicacion
The names `length` and `width` tell what problem the program solves. A good explanation talks about that, not about the operation.
:::
