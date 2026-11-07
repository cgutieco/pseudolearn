---
id: funcional.orden-superior.maximo-reducir
leccion: funcional.orden-superior
tipo: resolver
nivel: arbol
obligatorio: false
titulo: El mayor, reduciendo
---

::: enunciado
Lee números hasta un 0 y muestra el mayor. Si no llegó ningún número, muestra «Sin números».
:::

::: restriccion
El mayor se calcula con `Reducir` y una función `Mayor` de dos números.
:::

```programa rol=referencia
Funcion grande <- Mayor(a Como Entero, b Como Entero)
  Definir grande Como Entero <- a;
  Si b > a Entonces
    grande <- b;
  FinSi
FinFuncion

Funcion acumulado <- Reducir(v Como Vector<Entero>, f Como Funcion(Entero, Entero) Como Entero, inicial Como Entero)
  Definir acumulado Como Entero <- inicial;
  Para Cada elemento En v Hacer
    acumulado <- f(acumulado, elemento);
  FinPara
FinFuncion

Algoritmo Maximo
  Definir numeros Como Vector<Entero> <- Vector();
  Definir numero Como Entero;
  Leer numero;
  Mientras numero <> 0 Hacer
    numeros.Agregar(numero);
    Leer numero;
  FinMientras
  Si numeros.Longitud() = 0 Entonces
    Escribir "Sin números";
  Sino
    Escribir Reducir(numeros, Mayor, numeros[0]);
  FinSi
FinAlgoritmo
```

```casos
visible | 3 ; 8 ; 2 ; 0 | 8
visible | 5 ; 0 | 5
oculto | -7 ; -2 ; -9 ; 0 | -2
oculto | 0 | Sin números
oculto | 4 ; 4 ; 4 ; 0 | 4
```

```aserciones
- declara-subprograma | Reducir | 3 | Falta la función Reducir, que recibe el vector, la función y el valor inicial.
```

::: pistas
1. ¿Con qué valor tiene que empezar el mayor? ¿Sirve el 0?
2. Es el `Reducir` de [la lección](ruta:funcional.orden-superior), con otra función.
3. `Mayor(a, b)` retorna el más grande de los dos; el valor inicial es el primer número leído.
4. Si el vector está vacío, muestra el aviso; si no, `Reducir(numeros, Mayor, numeros[0])`. Cierra con la variante.
:::

::: variante
Muestra también el menor, sin escribir otro recorrido.
:::

::: docentes
Empezar en 0 falla con todos negativos: por eso el inicial es el primer número. Casos ocultos: todos negativos, ninguno y repetidos.
:::
