---
id: funcional.tipos-dominio.describir-resolver
leccion: funcional.tipos-dominio
tipo: resolver
nivel: brote
obligatorio: true
titulo: Armar y describir un pedido
---

::: enunciado
Lee un código de estado y sus datos: 1 pendiente, sin datos; 2 en camino, con el repartidor; 3 entregado, con el repartidor y la hora; 4 cancelado, con el motivo. Arma el pedido y muestra su descripción, como en la lección: «En camino con Sol».
:::

::: restriccion
El pedido es una variante con una forma por estado, y la descripción es una función con un `Segun`.
:::

```programa rol=referencia
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

Algoritmo Pedidos
  Definir codigo Como Entero;
  Definir repartidor, motivo Como Cadena;
  Definir hora Como Entero;
  Definir pedido Como Pedido <- Pedido.Pendiente;
  Leer codigo;
  Segun codigo Hacer
    2:
      Leer repartidor;
      pedido <- Pedido.EnCamino(repartidor);
    3:
      Leer repartidor;
      Leer hora;
      pedido <- Pedido.Entregado(repartidor, hora);
    4:
      Leer motivo;
      pedido <- Pedido.Cancelado(motivo);
    De Otro Modo:
      pedido <- Pedido.Pendiente;
  FinSegun
  Escribir Describir(pedido);
FinAlgoritmo
```

```casos
visible | 2 ; Sol | En camino con Sol
visible | 1 | Pendiente
oculto | 3 ; Leo ; 9 | Entregado por Leo a las 9
oculto | 4 ; lluvia | Cancelado: lluvia
oculto | 3 ; Ana ; 23 | Entregado por Ana a las 23
```

::: pistas
1. ¿Qué datos lleva cada estado? ¿Cuántas formas tiene el pedido?
2. Usa la variante y `Describir` de [la lección](ruta:funcional.tipos-dominio).
3. Lee el código; según el código, lee los datos que corresponden y arma la forma.
4. Un `Segun codigo` que arma `Pedido.EnCamino`, `Pedido.Entregado` o `Pedido.Cancelado`, y al final `Describir`. Cierra con la variante.
:::

::: variante
Agrega el estado 5, devuelto con motivo. ¿Qué te avisa el motor?
:::

::: docentes
El catálogo de comprobaciones de la app no puede exigir una variante; lo pide la restricción. Casos ocultos: los cuatro estados.
:::
