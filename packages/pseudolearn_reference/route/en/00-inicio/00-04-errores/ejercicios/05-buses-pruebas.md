---
id: inicio.errores.buses-pruebas
leccion: inicio.errores
tipo: disenar-pruebas
nivel: arbol
obligatorio: false
titulo: Cases for the buses
---

::: enunciado
Write between 2 and 4 test cases for the 40-seat bus program, so that any wrong version fails at least one of them.
:::

```programa rol=referencia
```

```programa rol=mutante id=sin-redondeo
```

```programa rol=mutante id=uno-de-mas
```

```programa rol=mutante id=redondeo-cercano
```

```casos
```

```casos-solucion minimo=2 maximo=4
```

::: pistas
1. A case uncovers a wrong version if, with that input, the version shows something else. Which inputs tell one version from another?
2. Think about the zones: pupils that fill the buses exactly, and pupils left over by a little or by a lot.
3. You need at least one case where the division is exact and another where a few are left over.
4. 95 → 3 uncovers the one that does not round; 80 → 2 uncovers the one that adds one too many. Close with the variant.
:::

::: variante
Is there a single input that uncovers all three wrong versions at once? (No: 81 → 3 uncovers two of them, but not the one that adds one too many.)
:::

::: docentes
Wrong versions: no rounding, one too many, and rounding to the nearest. Rounding to the nearest falls with any case where a few are left over, such as 81 or 95.
:::
