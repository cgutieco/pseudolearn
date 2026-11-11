---
id: inicio.primer-problema.ascensor
leccion: inicio.primer-problema
tipo: explicar
nivel: semilla
obligatorio: false
titulo: What does this program solve?
---

::: enunciado
Choose the sentence that best explains what this program solves.
:::

```programa rol=objeto id=misterio
Algoritmo Mystery
  Escribir techo(130 / 50);
FinAlgoritmo
```

```salida
3
```

```opciones
- [ ] It divides 130 by 50. | It describes how it does it, not what it solves.
- [x] How many trips a lift that carries 50 kilos makes to take up 130 kilos of books. | It talks about the problem: each trip carries 50 kilos and the last one goes with what is left.
- [ ] How many times 50 fits in 130. | It is false: 50 fits twice in 130, but the program shows 3.
```

::: explicacion
A good explanation talks about the problem, not about the operations. Rounding up is the clue: the last trip goes even if it is not full.
:::
