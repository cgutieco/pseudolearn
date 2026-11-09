---
id: exterior.http.precio-pesos
leccion: exterior.http
tipo: resolver
nivel: semilla
obligatorio: true
titulo: El precio en pesos
---

::: enunciado
Lee un precio en dólares y el tipo de cambio, y muestra el precio en pesos.
:::

::: restriccion
El cálculo lo hace una función pura, `PrecioEnPesos`, que recibe los dólares y el cambio.
:::

```programa rol=referencia
Funcion pesos <- PrecioEnPesos(dolares Como Entero, cambio Como Entero)
  Definir pesos Como Entero;
  pesos <- dolares * cambio;
FinFuncion

Algoritmo Precio
  Definir dolares Como Entero;
  Definir cambio Como Entero;
  Leer dolares;
  Leer cambio;
  Escribir PrecioEnPesos(dolares, cambio);
FinAlgoritmo
```

```casos
visible | 2 ; 20 | 40
visible | 0 ; 20 | 0
oculto | 3 ; 21 | 63
oculto | 1 ; 1 | 1
oculto | 10 ; 0 | 0
```

```aserciones
- declara-subprograma | PrecioEnPesos | 2 | Falta la función PrecioEnPesos, que recibe los dólares y el cambio.
```

::: pistas
1. ¿Qué cuenta convierte dólares en pesos?
2. Es la función de la lección: no sabe nada de redes.
3. Los pesos son los dólares por el cambio.
4. El algoritmo lee los dos números, llama a la función y muestra lo que devuelve. Cierra con la variante.
:::

::: variante
Agrega una función que redondee el precio hacia arriba a la decena más cercana.
:::

::: explicacion
La función se prueba sin red: es la parte del programa que la app sí puede comprobar. Un cambio 0 da 0 pesos; no tiene sentido real, pero la cuenta lo resuelve.
:::
