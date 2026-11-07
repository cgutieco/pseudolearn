---
id: funcional.clausuras.componer
leccion: funcional.clausuras
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Componer dos funciones
---

::: enunciado
Lee un número y muestra dos resultados, uno por línea: primero el doble del número más uno, y después el doble del número siguiente.
:::

::: restriccion
Una función `Componer(f, g)` que devuelve una función que aplica `g` y después `f`, usada con `MasUno` y `Doble` en los dos órdenes.
:::

```programa rol=referencia
Funcion siguiente <- MasUno(x Como Entero)
  Definir siguiente Como Entero;
  siguiente <- x + 1;
FinFuncion

Funcion doble <- Doble(x Como Entero)
  Definir doble Como Entero;
  doble <- x * 2;
FinFuncion

Funcion compuesta <- Componer(f Como Funcion(Entero) Como Entero, g Como Funcion(Entero) Como Entero)
  Definir compuesta Como Funcion(Entero) Como Entero <- Funcion(x Como Entero) Como Entero
    Retornar f(g(x));
  FinFuncion;
FinFuncion

Algoritmo Componer
  Definir x Como Entero;
  Leer x;
  Definir dobleMasUno Como Funcion(Entero) Como Entero <- Componer(MasUno, Doble);
  Definir dobleDelSiguiente Como Funcion(Entero) Como Entero <- Componer(Doble, MasUno);
  Escribir dobleMasUno(x);
  Escribir dobleDelSiguiente(x);
FinAlgoritmo
```

```casos
visible | 5 | 11 ⏎ 12
visible | 0 | 1 ⏎ 2
oculto | -3 | -5 ⏎ -4
oculto | 10 | 21 ⏎ 22
oculto | 1 | 3 ⏎ 4
```

```aserciones
- declara-subprograma | Componer | 2 | Falta la función Componer, que recibe dos funciones.
```

::: pistas
1. «El doble más uno» y «el doble del siguiente»: ¿qué se aplica primero en cada caso?
2. `Componer` es una fábrica, como el sumador de [la lección](ruta:funcional.clausuras), que lleva dos funciones en la mochila.
3. La función fabricada recibe `x` y retorna `f(g(x))`.
4. `Componer(MasUno, Doble)` da el doble más uno; `Componer(Doble, MasUno)`, el doble del siguiente. Cierra con la variante.
:::

::: variante
Usa `Componer` dos veces para armar «el doble del doble más uno».
:::

::: docentes
El orden importa: componer no es conmutativo. Casos ocultos: negativos, 10 y 1.
:::
