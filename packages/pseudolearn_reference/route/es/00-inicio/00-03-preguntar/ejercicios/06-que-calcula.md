---
id: inicio.preguntar.que-calcula
leccion: inicio.preguntar
tipo: explicar
nivel: semilla
obligatorio: false
titulo: ¿Para qué sirve?
---

::: enunciado
Elige la frase que mejor explica qué resuelve este programa.
:::

```programa rol=objeto id=misterio
Algoritmo Misterio
  Definir largo Como Entero;
  Definir ancho Como Entero;
  Leer largo;
  Leer ancho;
  Escribir largo * ancho;
FinAlgoritmo
```

```entrada
4
3
```

```salida
12
```

```opciones
- [ ] Multiplica dos números. | Describe cómo lo hace, no qué resuelve.
- [x] Calcula el área de un rectángulo a partir de su largo y su ancho. | Habla del problema y usa los nombres de las cajas.
- [ ] Suma dos números. | Es falsa: el programa multiplica.
```

::: explicacion
Los nombres `largo` y `ancho` cuentan qué problema resuelve el programa. Una buena explicación habla de eso, no de la operación.
:::
