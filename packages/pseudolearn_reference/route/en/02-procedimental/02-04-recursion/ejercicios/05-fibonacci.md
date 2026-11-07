---
id: procedimental.recursion.fibonacci
leccion: procedimental.recursion
tipo: comparar
nivel: brote
obligatorio: false
titulo: Term 30
---

::: enunciado
In the series 0, 1, 1, 2, 3, 5, 8, … each term is the sum of the two before. You have to compute term 30. Which way suits?
:::

```opciones
- [ ] With direct recursion: term `n` is term `n - 1` plus term `n - 2`. | Each call opens two more calls, and the same terms are computed again and again: more than a million calls.
- [x] With a loop that carries the last two terms. | Thirty passes are enough, and each term is computed only once.
- [ ] It makes no difference, because both give the same result. | They give the same, but one takes thirty steps and the other more than a million.
```

::: explicacion
Direct recursion branches: term 30 asks for 29 and 28, 29 asks for 28 again, and so on. A loop remembers the last two terms and repeats nothing.
:::
