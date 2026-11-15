---
id: procedimental.dividir.sumar-tres
leccion: procedimental.dividir
tipo: predecir
nivel: semilla
obligatorio: false
titulo: Una llamada dentro de otra
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
SubProceso Sumar3(x Como Entero) Como Entero
  Retornar x + 3;
FinSubProceso

Algoritmo Principal
  Escribir Sumar3(Sumar3(1));
FinAlgoritmo
```

```salida
7
```

::: explicacion
Primero se resuelve la llamada de adentro: `Sumar3(1)` retorna 4. Después, la de afuera recibe ese 4 y retorna 7.
:::
