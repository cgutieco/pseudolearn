---
id: funcional.clausuras.multiplicador
leccion: funcional.clausuras
tipo: resolver
nivel: brote
obligatorio: true
titulo: Un multiplicador fabricado
---

::: enunciado
Lee un factor y después números hasta un 0. Muestra cada número multiplicado por el factor, uno por línea.
:::

::: restriccion
Una fábrica `CrearMultiplicador(factor)` que devuelve la función que multiplica.
:::

```programa rol=referencia
Funcion fabricada <- CrearMultiplicador(factor Como Entero)
  Definir fabricada Como Funcion(Entero) Como Entero <- Funcion(x Como Entero) Como Entero
    Retornar x * factor;
  FinFuncion;
FinFuncion

Algoritmo Multiplicar
  Definir factor, numero Como Entero;
  Leer factor;
  Definir multiplicar Como Funcion(Entero) Como Entero <- CrearMultiplicador(factor);
  Leer numero;
  Mientras numero <> 0 Hacer
    Escribir multiplicar(numero);
    Leer numero;
  FinMientras
FinAlgoritmo
```

```casos
visible | 3 ; 1 ; 2 ; 5 ; 0 | 3 ⏎ 6 ⏎ 15
visible | 2 ; 10 ; 0 | 20
oculto | 0 ; 4 ; 7 ; 0 | 0 ⏎ 0
oculto | -1 ; 5 ; -2 ; 0 | -5 ⏎ 2
oculto | 10 ; 3 ; 0 | 30
```

```aserciones
- declara-subprograma | CrearMultiplicador | 1 | Falta la fábrica CrearMultiplicador, que recibe el factor.
```

::: pistas
1. ¿Qué dato tiene que recordar la función que multiplica?
2. Es el sumador de [la lección](ruta:funcional.clausuras), con otra operación.
3. La fábrica recibe el factor y devuelve una función de un número que lo usa.
4. Fabrica la función una vez, antes del bucle, y aplícala a cada número leído. Cierra con la variante.
:::

::: variante
Fabrica dos multiplicadores y muestra cada número por los dos.
:::

::: explicacion
Casos ocultos: factor 0 y factor -1. Error frecuente: fabricar la función dentro del bucle, que funciona pero repite trabajo.
:::
