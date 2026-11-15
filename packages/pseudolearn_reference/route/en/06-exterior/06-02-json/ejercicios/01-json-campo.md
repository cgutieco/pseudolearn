---
id: exterior.json.json-campo
leccion: exterior.json
tipo: predecir
nivel: semilla
obligatorio: true
titulo: How many keys?
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
Algoritmo CountKeys
  Segun AnalizarJson('{"juice": 10, "water": 12}') Hacer
    Exito(inventory): Escribir inventory.Longitud();
    Error(report): Escribir report.Codigo;
  FinSegun
FinAlgoritmo
```

```salida
2
```

::: explicacion
The text is an object with two keys, juice and water. The length of an object counts its keys.
:::
