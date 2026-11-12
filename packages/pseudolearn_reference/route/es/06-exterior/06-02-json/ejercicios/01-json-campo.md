---
id: exterior.json.json-campo
leccion: exterior.json
tipo: predecir
nivel: semilla
obligatorio: true
titulo: ¿Cuántas claves?
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
Algoritmo Claves
  Segun AnalizarJson('{"jugo": 10, "agua": 12}') Hacer
    Exito(inventario): Escribir inventario.Longitud();
    Error(problema): Escribir problema.Codigo;
  FinSegun
FinAlgoritmo
```

```salida
2
```

::: explicacion
El texto es un objeto con dos claves, jugo y agua. `Longitud` de un objeto cuenta sus claves.
:::
