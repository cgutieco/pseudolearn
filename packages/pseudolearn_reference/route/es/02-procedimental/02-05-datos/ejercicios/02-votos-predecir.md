---
id: procedimental.datos.votos-predecir
leccion: procedimental.datos
tipo: predecir
nivel: semilla
obligatorio: false
titulo: Los votos de Ana
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
Algoritmo Votos
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
La clave `"Ana"` empieza con 3; la última línea lee ese 3, le suma 1 y guarda 4 en la misma clave. Los 5 de Beto no se tocan.
:::
