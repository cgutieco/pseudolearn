---
id: exterior.archivos.linea-pruebas
leccion: exterior.archivos
tipo: disenar-pruebas
nivel: arbol
obligatorio: false
titulo: The tests of the line
---

::: enunciado
Do not write code. Write between two and four lines for the exercise of reading a line, with the right answer for each one, so that any wrong version fails at least one.
:::

```programa rol=referencia
```

```programa rol=mutante id=sin-revisar
```

```programa rol=mutante id=ultimo-corte
```

```programa rol=mutante id=sin-stock
```

```casos
```

```casos-solucion minimo=2 maximo=4
```

::: pistas
1. Think of possible errors: not checking whether there is a semicolon, cutting somewhere else, forgetting a part.
2. You need a line without a semicolon.
3. You need a line with two semicolons.
4. «jugo;10», «agua» and «x;y;3» uncover the three wrong versions. Close with the variant.
:::

::: variante
Which of your lines could you remove without letting any wrong version escape?
:::

::: docentes
Wrong versions: it does not check the semicolon, it cuts at the last one and it shows the name without the stock. Without a line with two semicolons, the second one survives.
:::
