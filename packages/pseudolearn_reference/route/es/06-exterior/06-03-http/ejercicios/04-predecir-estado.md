---
id: exterior.http.predecir-estado
leccion: exterior.http
tipo: predecir
nivel: semilla
obligatorio: false
titulo: ¿Bien o problema?
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
Funcion palabra <- ComoLeFue(codigo Como Entero)
  Definir palabra Como Cadena;
  Si codigo >= 200 Y codigo <= 299 Entonces
    palabra <- "bien";
  Sino
    palabra <- "problema";
  FinSi
FinFuncion

Algoritmo Estados
  Escribir ComoLeFue(204);
  Escribir ComoLeFue(301);
FinAlgoritmo
```

```salida
bien
problema
```

::: explicacion
204 está entre 200 y 299: salió bien, aunque la respuesta no traiga cuerpo. 301 queda fuera del rango: la función lo trata como problema.
:::
