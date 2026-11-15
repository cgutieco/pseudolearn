---
id: imperativo.decidir.par-impar
leccion: imperativo.decidir
tipo: resolver
nivel: semilla
obligatorio: true
titulo: Par o impar
---

::: enunciado
Lee un número entero y muestra `par` o `impar`.
:::

```programa rol=referencia
Algoritmo ParImpar
  Definir numero Como Entero;
  Leer numero;
  Si numero mod 2 = 0 Entonces
    Escribir "par";
  Sino
    Escribir "impar";
  FinSi
FinAlgoritmo
```

```casos
visible | 4 | par
visible | 7 | impar
oculto | 0 | par
oculto | 1 | impar
oculto | -3 | impar
```

::: pistas
1. Arma la partición: ¿cuáles son las dos regiones? ¿Hay un número que te haga dudar?
2. Un número es par si al repartirlo de a 2 no sobra nada. Repasa lo que sobra al repartir en [la lección 0.2](ruta:inicio.nombres).
3. La condición compara lo que sobra con 0.
4. `Si numero mod 2 = 0 Entonces` muestra `par`; si no, `impar`. Cierra con la variante.
:::

::: variante
Muestra `múltiplo de 3` o `no es múltiplo de 3`. (Con 9: múltiplo; con 10: no.)
:::

::: explicacion
Casos ocultos: 0 es par, 1 es impar y -3 comprueba los negativos. En PseudoLearn, `-3 mod 2` vale -1, que no es 0: la solución con `= 0` funciona; una con `= 1` falla en -3.
:::
