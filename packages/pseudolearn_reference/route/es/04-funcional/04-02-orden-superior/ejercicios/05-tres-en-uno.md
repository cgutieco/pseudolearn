---
id: funcional.orden-superior.tres-en-uno
leccion: funcional.orden-superior
tipo: modificar
nivel: brote
obligatorio: false
titulo: Tres en uno
---

::: enunciado
Este programa lee cinco precios y muestra tres listas: los precios con 1 peso más, duplicados y con 1 peso menos. Tiene tres recorridos casi iguales. Reescríbelo con un solo recorrido que reciba la operación, sin cambiar lo que muestra.
:::

::: restriccion
Una función `Mapear` que recibe el vector y la operación, y tres funciones chicas que se le pasan.
:::

```programa rol=inicial
Algoritmo Precios
  Definir precios Como Vector<Entero> <- Vector();
  Definir leido Como Entero;
  Para i <- 1 Hasta 5 Hacer
    Leer leido;
    precios.Agregar(leido);
  FinPara
  Definir cambiados Como Vector<Entero> <- Vector();
  Para Cada precio En precios Hacer
    cambiados.Agregar(precio + 1);
  FinPara
  Escribir cambiados;
  cambiados <- Vector();
  Para Cada precio En precios Hacer
    cambiados.Agregar(precio * 2);
  FinPara
  Escribir cambiados;
  cambiados <- Vector();
  Para Cada precio En precios Hacer
    cambiados.Agregar(precio - 1);
  FinPara
  Escribir cambiados;
FinAlgoritmo
```

```programa rol=referencia
Funcion siguiente <- MasUno(x Como Entero)
  Definir siguiente Como Entero;
  siguiente <- x + 1;
FinFuncion

Funcion doble <- Doble(x Como Entero)
  Definir doble Como Entero;
  doble <- x * 2;
FinFuncion

Funcion anterior <- MenosUno(x Como Entero)
  Definir anterior Como Entero;
  anterior <- x - 1;
FinFuncion

Funcion nuevos <- Mapear(v Como Vector<Entero>, f Como Funcion(Entero) Como Entero)
  Definir nuevos Como Vector<Entero> <- Vector();
  Para Cada elemento En v Hacer
    nuevos.Agregar(f(elemento));
  FinPara
FinFuncion

Algoritmo Precios
  Definir precios Como Vector<Entero> <- Vector();
  Definir leido Como Entero;
  Para i <- 1 Hasta 5 Hacer
    Leer leido;
    precios.Agregar(leido);
  FinPara
  Escribir Mapear(precios, MasUno);
  Escribir Mapear(precios, Doble);
  Escribir Mapear(precios, MenosUno);
FinAlgoritmo
```

```casos
visible | 3 ; 5 ; 2 ; 1 ; 2 | [4, 6, 3, 2, 3] ⏎ [6, 10, 4, 2, 4] ⏎ [2, 4, 1, 0, 1]
visible | 0 ; 0 ; 0 ; 0 ; 0 | [1, 1, 1, 1, 1] ⏎ [0, 0, 0, 0, 0] ⏎ [-1, -1, -1, -1, -1]
oculto | 10 ; 20 ; 30 ; 40 ; 50 | [11, 21, 31, 41, 51] ⏎ [20, 40, 60, 80, 100] ⏎ [9, 19, 29, 39, 49]
oculto | 1 ; 1 ; 1 ; 1 ; 1 | [2, 2, 2, 2, 2] ⏎ [2, 2, 2, 2, 2] ⏎ [0, 0, 0, 0, 0]
```

```aserciones
- declara-subprograma | Mapear | 2 | Falta la función Mapear, que recibe el vector y la operación.
```

::: pistas
1. ¿Qué línea cambia entre los tres recorridos?
2. Repasa el `Mapear` de [la lección](ruta:funcional.orden-superior).
3. Cada operación es una función de un número; el recorrido es uno solo.
4. Tres llamadas: `Mapear(precios, MasUno)`, `Mapear(precios, Doble)` y `Mapear(precios, MenosUno)`. Cierra con la variante.
:::

::: variante
Agrega un cuarto vector con los precios al cuadrado. ¿Cuántas líneas escribiste?
:::

::: docentes
La aserción comprueba que exista `Mapear`. Los casos son los del programa inicial: lo que se muestra no cambia.
:::
