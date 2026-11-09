---
id: funcional.orden-superior.pares
leccion: funcional.orden-superior
tipo: resolver
nivel: brote
obligatorio: true
titulo: Solo los pares
---

::: enunciado
Lee números hasta un 0 y muestra la lista de los que son pares, en el orden en que llegaron, como `[4, 2]`.
:::

::: restriccion
Una función `Filtrar` que recibe el vector y una condición, y una función `EsPar` que se le pasa como dato.
:::

```programa rol=referencia
Funcion par <- EsPar(x Como Entero)
  Definir par Como Logico;
  par <- x mod 2 = 0;
FinFuncion

Funcion elegidos <- Filtrar(v Como Vector<Entero>, condicion Como Funcion(Entero) Como Logico)
  Definir elegidos Como Vector<Entero> <- Vector();
  Para Cada elemento En v Hacer
    Si condicion(elemento) Entonces
      elegidos.Agregar(elemento);
    FinSi
  FinPara
FinFuncion

Algoritmo Pares
  Definir numeros Como Vector<Entero> <- Vector();
  Definir numero Como Entero;
  Leer numero;
  Mientras numero <> 0 Hacer
    numeros.Agregar(numero);
    Leer numero;
  FinMientras
  Escribir Filtrar(numeros, EsPar);
FinAlgoritmo
```

```casos
visible | 3 ; 4 ; 7 ; 2 ; 0 | [4, 2]
visible | 10 ; 20 ; 0 | [10, 20]
oculto | 1 ; 3 ; 5 ; 0 | []
oculto | 0 | []
oculto | -4 ; -3 ; 6 ; 0 | [-4, 6]
```

```aserciones
- declara-subprograma | Filtrar | 2 | Falta la función Filtrar, que recibe el vector y la condición.
```

::: pistas
1. ¿El resultado tiene el mismo largo que los números leídos?
2. Es el `Filtrar` de [la lección](ruta:funcional.orden-superior), con otra condición.
3. Guarda los números en un vector; la condición es una función que dice si un número es par.
4. `Escribir Filtrar(numeros, EsPar);` después de leer. Cierra con la variante.
:::

::: variante
Muestra la suma de los pares con `Reducir`.
:::

::: explicacion
Casos ocultos: ningún par, el 0 directo y negativos pares. Error frecuente: pasar `EsPar(x)`, que es un valor y no la función.
:::
