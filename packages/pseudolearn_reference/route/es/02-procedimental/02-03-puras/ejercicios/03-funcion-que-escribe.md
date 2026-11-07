---
id: procedimental.puras.funcion-que-escribe
leccion: procedimental.puras
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: La función que habla
---

::: enunciado
Este programa lee un precio y debería mostrar `IVA: ` seguido del 21 % del precio, redondeado hacia abajo. Pero ni siquiera empieza. Encuentra el error y corrígelo.
:::

```programa rol=inicial
Funcion impuesto <- Iva(precio Como Entero)
  Definir impuesto Como Entero;
  Escribir "Calculando el IVA";
  impuesto <- precio * 21 div 100;
FinFuncion

Algoritmo Principal
  Definir precio Como Entero;
  Leer precio;
  Escribir "IVA: ", Iva(precio);
FinAlgoritmo
```

```programa rol=referencia
Funcion impuesto <- Iva(precio Como Entero)
  Definir impuesto Como Entero;
  impuesto <- precio * 21 div 100;
FinFuncion

Algoritmo Principal
  Definir precio Como Entero;
  Leer precio;
  Escribir "IVA: ", Iva(precio);
FinAlgoritmo
```

```casos
visible | 100 | IVA: 21
visible | 50 | IVA: 10
oculto | 0 | IVA: 0
oculto | 200 | IVA: 42
oculto | 7 | IVA: 1
```

::: pistas
1. ¿Es un error al compilar, al ejecutar o de lógica? Lee el diagnóstico.
2. Mira la función que muestra en [la lección](ruta:procedimental.puras).
3. El mensaje no forma parte del cálculo: puede ir afuera o desaparecer.
4. Quita el `Escribir` de la función; si quieres el mensaje, ponlo en el algoritmo principal. Cierra con la variante.
:::

::: variante
Agrega una función `ConIva` que use `Iva` y retorne el precio con el impuesto incluido.
:::

::: docentes
El motor rechaza el programa porque una `Funcion` no puede mostrar nada. La corrección deja la función pura y, si hace falta, mueve el mensaje al algoritmo principal.
:::
