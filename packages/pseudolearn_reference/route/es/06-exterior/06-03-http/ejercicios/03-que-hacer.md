---
id: exterior.http.que-hacer
leccion: exterior.http
tipo: resolver
nivel: brote
obligatorio: true
titulo: Qué mostrar
---

::: enunciado
Lee un código de estado y un tipo de cambio. Si el código es 200, muestra «Precio: » y el precio en pesos de una fruta de 2 dólares; si no, muestra «Servicio no disponible (» con el código y «)».
:::

::: restriccion
El mensaje lo arma una función pura, `QueMostrar`, que recibe el código y el cambio.
:::

```programa rol=referencia
Funcion mensaje <- QueMostrar(codigo Como Entero, cambio Como Entero)
  Definir mensaje Como Cadena;
  Si codigo = 200 Entonces
    mensaje <- "Precio: " + ATexto(2 * cambio);
  Sino
    mensaje <- "Servicio no disponible (" + ATexto(codigo) + ")";
  FinSi
FinFuncion

Algoritmo QueHacer
  Definir codigo Como Entero;
  Definir cambio Como Entero;
  Leer codigo;
  Leer cambio;
  Escribir QueMostrar(codigo, cambio);
FinAlgoritmo
```

```casos
visible | 200 ; 20 | Precio: 40
visible | 503 ; 20 | Servicio no disponible (503)
oculto | 404 ; 1 | Servicio no disponible (404)
oculto | 200 ; 0 | Precio: 0
oculto | 201 ; 5 | Servicio no disponible (201)
```

```aserciones
- declara-subprograma | QueMostrar | 2 | Falta la función QueMostrar, que recibe el código y el cambio.
- contiene | condicional | La función decide con un Si según el código.
```

::: pistas
1. ¿Qué dos caminos tiene el mensaje?
2. Uno es el precio y el otro, el aviso con el código.
3. La condición compara el código con 200, exactamente como pide el enunciado.
4. Convierte los números en texto con `ATexto` para unirlos al mensaje. Cierra con la variante.
:::

::: variante
Acepta como bien cualquier código del 200 al 299.
:::

::: explicacion
El caso 201 confirma que la consigna pide exactamente 200. El ejercicio de romper de esta lección muestra por qué conviene aceptar todo el rango.
:::
