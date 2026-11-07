---
id: objetos.invariantes.tarjeta-pruebas
leccion: objetos.invariantes
tipo: disenar-pruebas
nivel: brote
obligatorio: true
titulo: The card tests
---

::: enunciado
A program reads the initial balance, an amount to charge and an amount to load, and shows the result of charging, the result of loading and the final balance. Write between 3 and 4 test cases so that any wrong version of the card fails at least one.
:::

```programa rol=referencia
```

```programa rol=mutante id=sin-cobro-justo
```

```programa rol=mutante id=permite-negativo
```

```programa rol=mutante id=carga-negativa
```

```casos
```

```casos-solucion minimo=3 maximo=4
```

::: pistas
1. Write the card's invariant. At which edges can it break?
2. Look at the table of cases in [the lesson](ruta:objetos.invariantes).
3. You need a charge of exactly the balance, a charge of one more and a negative load.
4. 30, 30 and 10; 30, 31 and 10; 30, 5 and -5, with their answers. Close with the variant.
:::

::: variante
Which case would you add for an error that charged negative amounts?
:::

::: docentes
Wrong versions: it does not allow charging exactly the balance, it allows going negative and it accepts negative loads. Each case of the solution uncovers one.
:::
