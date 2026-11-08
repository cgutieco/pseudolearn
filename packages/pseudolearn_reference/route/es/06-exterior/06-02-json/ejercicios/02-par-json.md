---
id: exterior.json.par-json
leccion: exterior.json
tipo: resolver
nivel: semilla
obligatorio: true
titulo: Un producto en JSON
---

::: enunciado
Lee el nombre de un producto y su stock, y muestra el texto JSON con ese único par entre llaves, como {"jugo": 10}.
:::

::: restriccion
El texto lo arma una función pura, `ParJson`, que recibe el nombre y el stock.
:::

```programa rol=referencia
Funcion par <- ParJson(nombre Como Cadena, stock Como Entero)
  Definir par Como Cadena;
  par <- '{"' + nombre + '": ' + ATexto(stock) + "}";
FinFuncion

Algoritmo Par
  Definir nombre Como Cadena;
  Definir stock Como Entero;
  Leer nombre;
  Leer stock;
  Escribir ParJson(nombre, stock);
FinAlgoritmo
```

```casos
visible | jugo ; 10 | {"jugo": 10}
visible | agua ; 0 | {"agua": 0}
oculto | fruta ; 6 | {"fruta": 6}
oculto | alfajor ; 125 | {"alfajor": 125}
oculto | sandwich ; 1 | {"sandwich": 1}
```

```aserciones
- declara-subprograma | ParJson | 2 | Falta la función ParJson, que recibe el nombre y el stock.
```

::: pistas
1. ¿Qué partes del texto son fijas y cuáles cambian?
2. Es como la línea «jugo;10» de la lección anterior, con llaves, comillas y dos puntos.
3. Un texto entre comillas simples puede llevar comillas dobles adentro.
4. Une la llave, la clave entre comillas, los dos puntos, el stock con `ATexto` y la llave final. Cierra con la variante.
:::

::: variante
Comprueba el resultado con `AnalizarJson` antes de mostrarlo.
:::

::: docentes
El espacio después de los dos puntos es parte del formato pedido. Los casos incluyen stock 0 y un número de tres cifras.
:::
