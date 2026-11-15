---
id: exterior.archivos.linea-stock
leccion: exterior.archivos
tipo: resolver
nivel: semilla
obligatorio: true
titulo: Una línea del archivo
---

::: enunciado
Lee el nombre de un producto y su stock, y muestra la línea que se guarda en el archivo: el nombre, un punto y coma y el stock, como «jugo;10».
:::

::: restriccion
La línea la arma una función pura, `LineaStock`, que recibe el nombre y el stock.
:::

```programa rol=referencia
Funcion linea <- LineaStock(nombre Como Cadena, stock Como Entero)
  Definir linea Como Cadena;
  linea <- nombre + ";" + ATexto(stock);
FinFuncion

Algoritmo LineaDelArchivo
  Definir nombre Como Cadena;
  Definir stock Como Entero;
  Leer nombre;
  Leer stock;
  Escribir LineaStock(nombre, stock);
FinAlgoritmo
```

```casos
visible | jugo ; 10 | jugo;10
visible | agua ; 0 | agua;0
oculto | fruta ; 6 | fruta;6
oculto | alfajor ; 125 | alfajor;125
oculto | té ; 1 | té;1
```

```aserciones
- declara-subprograma | LineaStock | 2 | Falta la función LineaStock, que recibe el nombre y el stock.
```

::: pistas
1. ¿Qué parte de la línea es fija y qué parte cambia?
2. Es la función de la lección: une el nombre, el punto y coma y el stock.
3. El stock es un número: conviértelo en texto con `ATexto` antes de unirlo.
4. El algoritmo lee, llama a la función y muestra lo que devuelve. Cierra con la variante.
:::

::: variante
Haz otra función que arme la línea con el precio además del stock: «jugo;10;3».
:::

::: explicacion
La función no abre ningún archivo: por eso se puede probar sola. Los casos incluyen stock 0, un número de tres cifras y un nombre con tilde.
:::
