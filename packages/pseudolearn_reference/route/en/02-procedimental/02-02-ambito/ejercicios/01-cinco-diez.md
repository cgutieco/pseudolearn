---
id: procedimental.ambito.cinco-diez
leccion: procedimental.ambito
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Copy or lent box
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
SubProceso A(x Como Entero)
  x <- x + 4;
FinSubProceso

SubProceso B(x Como Entero Por Referencia)
  x <- x + 4;
FinSubProceso

Algoritmo Main
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
`A` receives a copy and adds 4 to the copy: `n` stays at 3. `B` works with the very box of `n`: when it comes back, `n` is 7.
:::
