---
id: procedimental.ambito.cinco-diez
leccion: procedimental.ambito
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Copia o caja prestada
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
SubProceso A(x Como Entero)
  x <- x + 4;
FinSubProceso

SubProceso B(x Como Entero Por Referencia)
  x <- x + 4;
FinSubProceso

Algoritmo Principal
  Definir n Como Entero <- 3;
  A(n);
  Escribir n;
  B(n);
  Escribir n;
FinAlgoritmo
```

```salida
3
7
```

::: explicacion
`A` recibe una copia y le suma 4 a la copia: `n` sigue en 3. `B` trabaja con la caja misma de `n`: al volver, `n` vale 7.
:::
