---
id: funcional.tipos-dominio.avanzar
leccion: funcional.tipos-dominio
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Avanzar con sus errores
---

::: enunciado
Un pedido empieza pendiente o cancelado: lee `pendiente`, o `cancelado` seguido del motivo. Después lee cuántas veces hay que avanzarlo, con el repartidor `Sol` y la hora 14. Muestra la descripción final, o el primer motivo por el que no se pudo avanzar, como «No se puede: está cancelado: lluvia».
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

SubProceso Avanzar(pedido Como Pedido, repartidor Como Cadena, hora Como Entero) Como Resultado<Pedido, Cadena>
  Segun pedido Hacer
    Pedido.Pendiente: Retornar Exito(Pedido.EnCamino(repartidor));
    Pedido.EnCamino(quien): Retornar Exito(Pedido.Entregado(quien, hora));
    Pedido.Entregado(quien, cuando): Retornar Error("ya lo entregó " + quien + " a las " + ConvertirATexto(cuando));
    Pedido.Cancelado(motivo): Retornar Error("está cancelado: " + motivo);
  FinSegun
FinSubProceso

Algoritmo Avances
  Definir inicio, motivo Como Cadena;
  Definir veces Como Entero;
  Leer inicio;
  Definir pedido Como Pedido <- Pedido.Pendiente;
  Si inicio = "cancelado" Entonces
    Leer motivo;
    pedido <- Pedido.Cancelado(motivo);
  FinSi
  Leer veces;
  Definir fallo Como Cadena <- "";
  Para paso <- 1 Hasta veces Hacer
    Si fallo = "" Entonces
      Segun Avanzar(pedido, "Sol", 14) Hacer
        Exito(siguiente): pedido <- siguiente;
        Error(razon): fallo <- razon;
      FinSegun
    FinSi
  FinPara
  Si fallo = "" Entonces
    Escribir Describir(pedido);
  Sino
    Escribir "No se puede: ", fallo;
  FinSi
FinAlgoritmo
```

```casos
visible | pendiente ; 1 | En camino con Sol
visible | pendiente ; 2 | Entregado por Sol a las 14
oculto | pendiente ; 0 | Pendiente
oculto | pendiente ; 3 | No se puede: ya lo entregó Sol a las 14
oculto | cancelado ; lluvia ; 1 | No se puede: está cancelado: lluvia
oculto | cancelado ; sin stock ; 0 | Cancelado: sin stock
```

::: pistas
1. ¿Desde qué estados se puede avanzar? ¿Qué pasa con los otros?
2. Es el `Avanzar` de [la lección](ruta:funcional.tipos-dominio), repetido varias veces.
3. Avanza mientras no haya fallado; el primer error se guarda y ya no se avanza más.
4. Un bucle que llama a `Avanzar` y atiende el `Resultado`; al final, la descripción o el motivo. Cierra con la variante.
:::

::: variante
Agrega `Cancelar(pedido, motivo)`, que solo cancela pedidos pendientes o en camino.
:::

::: docentes
Casos ocultos: cero avances, avanzar más de la cuenta, avanzar uno cancelado y uno cancelado sin avances.
:::
