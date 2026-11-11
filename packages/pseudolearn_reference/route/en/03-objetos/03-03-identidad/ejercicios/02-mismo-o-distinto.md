---
id: objetos.identidad.mismo-o-distinto
leccion: objetos.identidad
tipo: clasificar
nivel: semilla
obligatorio: false
titulo: The same or different?
---

::: enunciado
At the end of this program, does each pair of names point at the same `Counter` or at two different ones?

```programa id=pares titulo="Four counters… or fewer"
Clase Counter
  Definir valor Como Entero;

  Metodo Constructor()
    Este.valor <- 0;
  FinMetodo

  Metodo Increment()
    Este.valor <- Este.valor + 1;
  FinMetodo

  Metodo Current() Como Entero
    Retornar Este.valor;
  FinMetodo
FinClase

Algoritmo Pairs
  Definir a Como Counter <- Nuevo Counter();
  Definir b Como Counter <- a;
  Definir c Como Counter <- Nuevo Counter();
  Definir d Como Counter <- Copiar(c);
  Definir e Como Counter <- b;
FinAlgoritmo
```
:::

```categorias
- The same counter
- Different counters
```

```elementos
- `a` and `b` | The same counter
- `a` and `e` | The same counter
- `a` and `c` | Different counters
- `c` and `d` | Different counters
```

::: explicacion
Assigning copies the arrow: `b` and `e` end up pointing at `a`'s counter. `New` and `copy` create new counters.
:::
