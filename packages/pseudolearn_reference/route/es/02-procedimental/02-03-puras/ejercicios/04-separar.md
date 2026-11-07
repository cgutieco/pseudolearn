---
id: procedimental.puras.separar
leccion: procedimental.puras
tipo: modificar
nivel: brote
obligatorio: true
titulo: Separar el cálculo
---

::: enunciado
Este programa pregunta un precio y muestra el precio con el 21 % de IVA, todo dentro de una misma pieza. Reescríbelo para que el cálculo quede en una pieza que solo calcula, sin cambiar lo que muestra.
:::

::: restriccion
El cálculo va en una `Funcion ConIva` que recibe el precio; el algoritmo principal lee y muestra.
:::

```programa rol=inicial
SubProceso MostrarConIva()
  Definir precio Como Entero;
  Leer precio;
  Escribir precio + precio * 21 div 100;
FinSubProceso

Algoritmo Principal
  MostrarConIva();
FinAlgoritmo
```

```programa rol=referencia
Funcion total <- ConIva(precio Como Entero)
  Definir total Como Entero;
  total <- precio + precio * 21 div 100;
FinFuncion

Algoritmo Principal
  Definir precio Como Entero;
  Leer precio;
  Escribir ConIva(precio);
FinAlgoritmo
```

```casos
visible | 100 | 121
visible | 50 | 60
oculto | 0 | 0
oculto | 200 | 242
oculto | 7 | 8
```

```aserciones
- declara-subprograma | ConIva | 1 | Falta la pieza ConIva, que recibe el precio y retorna el precio con IVA.
```

::: pistas
1. Marca qué líneas preguntan, cuáles muestran y cuáles calculan.
2. Es el mismo arreglo que el precio con descuento de [la lección](ruta:procedimental.puras).
3. La pieza nueva recibe el precio y retorna el resultado; el principal hace la lectura y la escritura.
4. `Funcion total <- ConIva(precio Como Entero)` con el cálculo adentro, y el principal lee, llama y muestra. Cierra con la variante.
:::

::: variante
Usa `ConIva` para mostrar el total con IVA de dos productos leídos.
:::

::: docentes
La aserción comprueba que exista `ConIva` con un parámetro; que sea una `Funcion`, y por lo tanto pura, lo comprueba el propio motor al compilarla. Los casos son los del programa inicial: lo que se muestra no cambia.
:::
