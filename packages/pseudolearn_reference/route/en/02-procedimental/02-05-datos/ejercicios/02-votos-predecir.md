---
id: procedimental.datos.votos-predecir
leccion: procedimental.datos
tipo: predecir
nivel: semilla
obligatorio: false
titulo: Ana's votes
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
Algoritmo Votes
  Definir d Como Diccionario<Cadena, Entero> <- Diccionario();
  d["Ana"] <- 3;
  d["Beto"] <- 5;
  d["Ana"] <- d["Ana"] + 1;
  Escribir d["Ana"];
FinAlgoritmo
```

```salida
4
```

::: explicacion
The key `"Ana"` starts with 3; the last line reads that 3, adds 1 and stores 4 under the same key. Beto's 5 is not touched.
:::
