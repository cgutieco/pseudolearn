---
id: inicio.primer-problema.ana-y-beto
leccion: inicio.primer-problema
tipo: comparar
nivel: brote
obligatorio: false
titulo: Two solutions that look the same
---

::: enunciado
Ana and Beto solved the pizza problem. Ana wrote `ceil(23 * 3 / 8)` and Beto wrote `23 * 3 div 8 + 1`. With 23 people, both show 9. With which of these numbers of people do they give different results?
:::

```opciones
- [ ] 23 people | With 23 both show 9: it is exactly the case they already tried.
- [x] 16 people | That is 48 slices, an exact division: Ana orders 6 and Beto orders 7, one too many.
- [ ] 30 people | That is 90 slices: Ana orders 12 and so does Beto, because slices are left over.
- [ ] 47 people | That is 141 slices: both order 18, because the division is not exact.
```

::: explicacion
Beto adds 1 «just in case something is left over». When the division is exact nothing is left over, and he orders one pizza too many. Any number of people whose slices divide exactly by 8 breaks his solution.
:::

::: docentes
It is the first contact with the idea of looking for the case that breaks a solution, which lesson 0.4 develops. Ask the group for another number that also breaks it: 8, 24 or 32.
:::
