---
id: exterior.json.dos-pares
leccion: exterior.json
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Dos productos en JSON
---

::: enunciado
Lee dos productos, cada uno con su nombre y su stock, y muestra el texto JSON con los dos pares entre llaves, como {"jugo": 10, "agua": 12}.
:::

::: restriccion
Cada par lo arma una función pura, `ParJson`, que recibe el nombre y el stock.
:::

```programa rol=referencia
Funcion par <- ParJson(nombre Como Cadena, stock Como Entero)
  Definir par Como Cadena;
  par <- '"' + nombre + '": ' + ATexto(stock);
FinFuncion

Algoritmo DosPares
  Definir primero Como Cadena;
  Definir primerStock Como Entero;
  Definir segundo Como Cadena;
  Definir segundoStock Como Entero;
  Leer primero;
  Leer primerStock;
  Leer segundo;
  Leer segundoStock;
  Escribir "{", ParJson(primero, primerStock), ", ", ParJson(segundo, segundoStock), "}";
FinAlgoritmo
```

```casos
visible | jugo ; 10 ; agua ; 12 | {"jugo": 10, "agua": 12}
visible | a ; 0 ; b ; 0 | {"a": 0, "b": 0}
oculto | fruta ; 6 ; alfajor ; 8 | {"fruta": 6, "alfajor": 8}
oculto | té ; 1 ; sandwich ; 125 | {"té": 1, "sandwich": 125}
oculto | x ; 3 ; y ; 4 | {"x": 3, "y": 4}
```

```aserciones
- declara-subprograma | ParJson | 2 | Falta la función ParJson, que recibe el nombre y el stock.
```

::: pistas
1. ¿Qué parte se repite para cada producto?
2. Cada par es la clave entre comillas, dos puntos y el stock, sin llaves.
3. El algoritmo pone las llaves y la coma entre los dos pares.
4. Llama a `ParJson` dos veces y une todo en un solo `Escribir`. Cierra con la variante.
:::

::: variante
Extiéndelo a los cinco productos del kiosco, como en la lección.
:::

::: docentes
Separar el par del objeto permite reutilizar `ParJson` para cualquier cantidad de productos. Un nombre con tilde no cambia nada: JSON admite cualquier texto.
:::
