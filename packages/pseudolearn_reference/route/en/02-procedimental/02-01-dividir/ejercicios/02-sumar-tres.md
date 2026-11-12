---
id: procedimental.dividir.sumar-tres
leccion: procedimental.dividir
tipo: predecir
nivel: semilla
obligatorio: false
titulo: A call inside another
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
SubProceso AddThree(x Como Entero) Como Entero
  Retornar x + 3;
FinSubProceso

Algoritmo Main
  Escribir AddThree(AddThree(1));
FinAlgoritmo
```

```salida
7
```

::: explicacion
The inner call is solved first: `AddThree(1)` returns 4. Then the outer one receives that 4 and returns 7.
:::
