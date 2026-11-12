---
id: procedimental.ambito.cambiar-figuritas
leccion: procedimental.ambito
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: El intercambio que no intercambia
---

::: enunciado
El programa lee dos números y debería mostrarlos al revés, usando `Intercambiar`. Pero los muestra en el mismo orden. Encuentra el error y corrígelo.
:::

```programa rol=inicial
SubProceso Intercambiar(a Como Entero, b Como Entero)
  Definir guardado Como Entero <- a;
  a <- b;
  b <- guardado;
FinSubProceso

Algoritmo Principal
  Definir primero, segundo Como Entero;
  Leer primero;
  Leer segundo;
  Intercambiar(primero, segundo);
  Escribir primero, " ", segundo;
FinAlgoritmo
```

```programa rol=referencia
SubProceso Intercambiar(a Como Entero Por Referencia, b Como Entero Por Referencia)
  Definir guardado Como Entero <- a;
  a <- b;
  b <- guardado;
FinSubProceso

Algoritmo Principal
  Definir primero, segundo Como Entero;
  Leer primero;
  Leer segundo;
  Intercambiar(primero, segundo);
  Escribir primero, " ", segundo;
FinAlgoritmo
```

```casos
visible | 3 ; 8 | 8 3
visible | 1 ; 1 | 1 1
oculto | 0 ; 5 | 5 0
oculto | -2 ; 4 | 4 -2
oculto | 9 ; 0 | 0 9
```

::: pistas
1. ¿Qué cajas cambia `Intercambiar`? ¿Son las mismas que lee el principal?
2. Repasa el saldo que no se duplicaba en [la lección](ruta:procedimental.ambito).
3. Aquí no alcanza con retornar: hay que devolver dos valores.
4. Marca los dos parámetros con `Por Referencia`. Cierra con la variante.
:::

::: variante
Escribe `OrdenarTres`, que deja tres números de menor a mayor usando `Intercambiar`.
:::

::: explicacion
El subprograma intercambia sus copias. Como hay que devolver dos valores, la solución presta las dos cajas. El caso 1 y 1 no descubre el error: por eso hacen falta más casos.
:::
