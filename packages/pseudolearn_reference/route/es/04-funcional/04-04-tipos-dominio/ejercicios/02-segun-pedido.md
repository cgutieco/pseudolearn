---
id: funcional.tipos-dominio.segun-pedido
leccion: funcional.tipos-dominio
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Tres pedidos
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
Variante Pedido
  Alternativa Pendiente
  Alternativa EnCamino(repartidor Como Cadena)
  Alternativa Entregado(repartidor Como Cadena, hora Como Entero)
  Alternativa Cancelado(motivo Como Cadena)
FinVariante

Funcion texto <- Describir(pedido Como Pedido)
  Definir texto Como Cadena <- "";
  Segun pedido Hacer
    Pedido.Pendiente: texto <- "Pendiente";
    Pedido.EnCamino(quien): texto <- "En camino con " + quien;
    Pedido.Entregado(quien, hora): texto <- "Entregado por " + quien + " a las " + ConvertirATexto(hora);
    Pedido.Cancelado(motivo): texto <- "Cancelado: " + motivo;
  FinSegun
FinFuncion

Algoritmo Tres
  Escribir Describir(Pedido.Pendiente);
  Escribir Describir(Pedido.Entregado("Leo", 9));
  Escribir Describir(Pedido.Cancelado("lluvia"));
FinAlgoritmo
```

```salida
Pendiente
Entregado por Leo a las 9
Cancelado: lluvia
```

::: explicacion
El `Segun` de `Describir` elige la rama según la forma de cada pedido y lee sus datos: el repartidor y la hora del entregado, el motivo del cancelado.
:::
