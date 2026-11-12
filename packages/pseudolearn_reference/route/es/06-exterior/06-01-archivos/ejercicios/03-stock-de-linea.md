---
id: exterior.archivos.stock-de-linea
leccion: exterior.archivos
tipo: resolver
nivel: brote
obligatorio: true
titulo: Leer una línea
---

::: enunciado
Lee una línea del archivo, como «jugo;10», y muestra «jugo tiene 10». Si la línea no tiene punto y coma, muestra «Línea inválida». Si tiene más de uno, el nombre es lo que va antes del primero.
:::

::: restriccion
El texto lo arma una función pura, `StockDeLinea`, que recibe la línea.
:::

```programa rol=referencia
Funcion mensaje <- StockDeLinea(linea Como Cadena)
  Definir mensaje Como Cadena;
  Segun PosicionDe(linea, ";") Hacer
    Algo(corte):
      mensaje <- Subcadena(linea, 0, corte - 1) + " tiene " + Subcadena(linea, corte + 1, Longitud(linea) - 1);
    Nada: mensaje <- "Línea inválida";
  FinSegun
FinFuncion

Algoritmo LeerLinea
  Definir linea Como Cadena;
  Leer linea;
  Escribir StockDeLinea(linea);
FinAlgoritmo
```

```casos
visible | jugo;10 | jugo tiene 10
visible | agua | Línea inválida
oculto | fruta;0 | fruta tiene 0
oculto | x;y;3 | x tiene y;3
oculto | té;1 | té tiene 1
```

```aserciones
- declara-subprograma | StockDeLinea | 1 | Falta la función StockDeLinea, que recibe la línea.
```

::: pistas
1. ¿Qué separa el nombre del stock?
2. `PosicionDe` dice dónde está el primer punto y coma, o `Nada` si no hay.
3. Con esa posición, `Subcadena` corta lo de antes y lo de después.
4. Un `Segun` sobre la posición elige entre el mensaje y «Línea inválida». Cierra con la variante.
:::

::: variante
Haz que la función devuelva «Línea inválida» también cuando el nombre está vacío.
:::

::: explicacion
Es la inversa de `LineaStock`. «x;y;3» confirma que el corte es en el primer punto y coma: lo de después queda entero, aunque tenga otro.
:::
