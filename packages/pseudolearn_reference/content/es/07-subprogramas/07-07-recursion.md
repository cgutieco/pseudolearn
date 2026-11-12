---
id: subprogramas.recursion
numero: "7.7"
tipo: concepto
titulo: Recursión
anclas: [LANG.SUBPROGRAM.RECURSION#R1]
diagnosticos: [recursionDepthExceeded]
terminos: [recursión, caso base]
---

::: frase
Un subprograma recursivo se llama a sí mismo con un problema más pequeño, hasta llegar a un caso tan simple que se resuelve sin llamarse.
:::

## Cómo funciona {#funciona}

Toda recursión tiene dos partes:

- el **caso base**, que responde sin llamarse;
- el **caso recursivo**, que se llama con un problema más pequeño y usa su respuesta.

```programa id=factorial titulo="El factorial" ejecutar
SubProceso Factorial(n Como Entero) Como Entero
  Si n <= 1 Entonces
    Retornar 1;
  FinSi
  Retornar n * Factorial(n - 1);
FinSubProceso

Algoritmo Principal
  Escribir Factorial(5);
FinAlgoritmo
```

```salida
120
```

Cada llamada tiene **su propio marco**, con su propio `n`. Las llamadas se apilan hasta el caso base y después se resuelven de arriba abajo.

```figura id=recursion-pila
pie: `Factorial(4)` apila cuatro marcos, cada uno con su `n`. El de arriba resuelve primero y entrega su valor al de abajo.
paso: Se llama `Factorial(4)`, que necesita `Factorial(3)`.
paso: Se apilan marcos hasta `Factorial(1)`, el caso base.
paso: El caso base devuelve 1 y su marco desaparece.
paso: Cada marco multiplica y devuelve: 2, 6 y por fin 24.
```

No hace falta declarar nada por adelantado, y dos subprogramas pueden llamarse entre sí:

```programa id=par-impar titulo="Recursión mutua" ejecutar
SubProceso EsPar(n Como Entero) Como Logico
  Si n = 0 Entonces
    Retornar Verdadero;
  FinSi
  Retornar EsImpar(n - 1);
FinSubProceso

SubProceso EsImpar(n Como Entero) Como Logico
  Si n = 0 Entonces
    Retornar Falso;
  FinSi
  Retornar EsPar(n - 1);
FinSubProceso

Algoritmo Principal
  Escribir EsPar(10), " ", EsImpar(7);
FinAlgoritmo
```

```salida
Verdadero Verdadero
```

::: limite
Una recursión sin caso base no se queda colgada ni rompe nada: el motor la detiene con `recursionDepthExceeded` al alcanzar su [límite de profundidad](#motor.limites). La app admite al menos 1000 marcos.
:::

::: errores
```programa id=sin-caso-base titulo="Sin caso base" ejecutar termina=failed
SubProceso SinFin(n Como Entero) Como Entero
  Retornar SinFin(n + 1);
FinSubProceso

Algoritmo Principal
  Escribir SinFin(0);
FinAlgoritmo
```

```diagnosticos
recursionDepthExceeded
```
:::

::: resumen
- Un subprograma recursivo se llama a sí mismo con un problema menor.
- Necesita un caso base que responda sin llamarse.
- Cada llamada tiene su propio marco.
- Sin caso base, el motor la detiene al agotar la profundidad.
:::

::: vease
- [Llamadas](#subprogramas.llamada)
- [Límites del motor](#motor.limites)
:::
