---
id: funcional.clausuras.captura-cambiante
leccion: funcional.clausuras
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: Una mochila que cambia
---

::: enunciado
Este programa lee una cantidad y un número, y debería mostrar el número más la cantidad usando un sumador fabricado. Pero ni siquiera empieza. Encuentra el error y corrígelo.
:::

```programa rol=inicial
Funcion fabricada <- CrearSumador(cantidad Como Entero)
  Definir base Como Entero <- cantidad;
  Definir fabricada Como Funcion(Entero) Como Entero <- Funcion(x Como Entero) Como Entero
    Retornar x + base;
  FinFuncion;
  base <- 0;
FinFuncion

Algoritmo Sumas
  Definir n, x Como Entero;
  Leer n;
  Leer x;
  Definir sumar Como Funcion(Entero) Como Entero <- CrearSumador(n);
  Escribir sumar(x);
FinAlgoritmo
```

```programa rol=referencia
Funcion fabricada <- CrearSumador(cantidad Como Entero)
  Definir fabricada Como Funcion(Entero) Como Entero <- Funcion(x Como Entero) Como Entero
    Retornar x + cantidad;
  FinFuncion;
FinFuncion

Algoritmo Sumas
  Definir n, x Como Entero;
  Leer n;
  Leer x;
  Definir sumar Como Funcion(Entero) Como Entero <- CrearSumador(n);
  Escribir sumar(x);
FinAlgoritmo
```

```casos
visible | 3 ; 4 | 7
visible | 10 ; 1 | 11
oculto | 0 ; 5 | 5
oculto | -2 ; 2 | 0
oculto | 100 ; 100 | 200
```

::: pistas
1. ¿Qué dice el diagnóstico? ¿Qué valor intenta llevarse la función fabricada?
2. Repasa la regla de la mochila en [la lección](ruta:funcional.clausuras).
3. La caja `base` se reasigna después de crear la función. ¿Hace falta esa caja?
4. Captura directamente `cantidad`, que no cambia, y quita la reasignación. Cierra con la variante.
:::

::: variante
Escribe `CrearRestador(cantidad)` con la misma forma.
:::

::: docentes
El motor rechaza capturar una variable que después se reasigna, porque la función no sabría qué valor usar. La corrección captura el parámetro, que no cambia.
:::
