---
id: procedimental.recursion.suma-sin-fin
leccion: procedimental.recursion
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: La suma que no termina
---

::: enunciado
Este programa lee un número no negativo y debería mostrar la suma de 1 hasta ese número. Pero nunca termina bien. Encuentra el error y corrígelo.
:::

```programa rol=inicial
Funcion total <- SumaHasta(n Como Entero)
  Definir total Como Entero;
  total <- n + SumaHasta(n - 1);
FinFuncion

Algoritmo Principal
  Definir n Como Entero;
  Leer n;
  Escribir SumaHasta(n);
FinAlgoritmo
```

```programa rol=referencia
Funcion total <- SumaHasta(n Como Entero)
  Definir total Como Entero;
  Si n = 0 Entonces
    total <- 0;
  Sino
    total <- n + SumaHasta(n - 1);
  FinSi
FinFuncion

Algoritmo Principal
  Definir n Como Entero;
  Leer n;
  Escribir SumaHasta(n);
FinAlgoritmo
```

```casos
visible | 3 | 6
visible | 1 | 1
oculto | 0 | 0
oculto | 10 | 55
oculto | 100 | 5050
```

::: pistas
1. ¿Es un error al compilar, al ejecutar o de lógica? ¿Qué dice el motor?
2. Compara con el factorial de [la lección](ruta:procedimental.recursion). ¿Qué parte le falta a esta función?
3. ¿Cuál es la suma más chica que ya sabes sin calcular nada?
4. Si `n` es 0, la suma es 0; si no, `n + SumaHasta(n - 1)`. Cierra con la variante.
:::

::: variante
Escribe `SumaPares(n)`, la suma de los pares desde 2 hasta `n`.
:::

::: docentes
Sin caso base, la función se llama con -1, -2, … hasta que el motor la detiene por profundidad. El caso 100 comprueba que la referencia no agote los marcos.
:::
