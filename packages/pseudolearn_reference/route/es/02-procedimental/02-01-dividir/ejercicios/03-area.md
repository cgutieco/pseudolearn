---
id: procedimental.dividir.area
leccion: procedimental.dividir
tipo: resolver
nivel: semilla
obligatorio: true
titulo: El área del rectángulo
---

::: enunciado
Lee el largo y el ancho de un rectángulo y muestra su área. El programa muestra solo el número.
:::

::: restriccion
El cálculo va en un subprograma `AreaRectangulo` que recibe el largo y el ancho.
:::

```programa rol=referencia
SubProceso AreaRectangulo(largo Como Entero, ancho Como Entero) Como Entero
  Retornar largo * ancho;
FinSubProceso

Algoritmo Area
  Definir largo, ancho Como Entero;
  Leer largo;
  Leer ancho;
  Escribir AreaRectangulo(largo, ancho);
FinAlgoritmo
```

```casos
visible | 3 ; 4 | 12
visible | 5 ; 5 | 25
oculto | 0 ; 9 | 0
oculto | 1 ; 1 | 1
oculto | 10 ; 7 | 70
```

```aserciones
- declara-subprograma | AreaRectangulo | 2 | El cálculo va en un subprograma AreaRectangulo con dos parámetros.
```

::: pistas
1. ¿Qué datos necesita el cálculo? Esos son los parámetros.
2. Mira cómo está escrito `Doble` en [la lección](ruta:procedimental.dividir).
3. El subprograma retorna el área; el algoritmo principal lee y muestra.
4. `SubProceso AreaRectangulo(largo Como Entero, ancho Como Entero) Como Entero` con `Retornar largo * ancho;`. Cierra con la variante.
:::

::: variante
Agrega un subprograma `PerimetroRectangulo` y muestra también el perímetro.
:::

::: explicacion
La aserción comprueba que exista `AreaRectangulo` con dos parámetros. Error frecuente: leer los datos dentro del subprograma, que entonces no recibe nada.
:::
