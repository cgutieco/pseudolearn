---
id: exterior.archivos.orden-diferir
leccion: exterior.archivos
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Three cleanups
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
Algoritmo DeferOrder
  Diferir
    Escribir "1";
  FinDiferir
  Diferir
    Escribir "2";
  FinDiferir
  Diferir
    Escribir "3";
  FinDiferir
  Escribir "end";
FinAlgoritmo
```

```salida
end
3
2
1
```

::: explicacion
The deferred orders are kept and run on leaving, in reverse order: the last one written is the first one run. That is why «end» comes first.
:::
