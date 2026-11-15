---
id: exterior.json.valido-o-no
leccion: exterior.json
tipo: resolver
nivel: brote
obligatorio: true
titulo: ¿Es JSON?
---

::: enunciado
Lee un texto y analízalo como JSON. Si es válido, muestra «Válido: » y su tipo; si no, muestra el código del error, « en la columna » y la columna donde se detectó.
:::

```programa rol=referencia
Algoritmo ValidoONo
  Definir texto Como Cadena;
  Leer texto;
  Segun AnalizarJson(texto) Hacer
    Exito(valor): Escribir "Válido: ", valor.Tipo();
    Error(problema): Escribir problema.Codigo, " en la columna ", problema.JsonColumna;
  FinSegun
FinAlgoritmo
```

```casos
visible | {"a": 1} | Válido: Objeto
visible | {"a": 1,} | SintaxisInvalida en la columna 9
oculto | [] | Válido: Arreglo
oculto | { | FinInesperado en la columna 2
oculto | {"a" 1} | SintaxisInvalida en la columna 6
```

```aserciones
- contiene | seleccion-multiple | El programa elige qué mostrar con un Segun sobre el resultado del análisis.
```

::: pistas
1. ¿Qué devuelve `AnalizarJson`?
2. Un `Resultado`: `Exito` con el valor o `Error` con un informe.
3. El valor dice su tipo con `Tipo()`; el informe tiene `Codigo` y `JsonColumna`.
4. Un `Segun` con las dos ramas escribe cada mensaje. Cierra con la variante.
:::

::: variante
Muestra también la línea del error, además de la columna.
:::

::: explicacion
Las columnas son las que da el motor: cuentan desde 1 y marcan el primer carácter que no encaja. Una llave sin cerrar es `FinInesperado`: el texto terminó antes de tiempo.
:::
