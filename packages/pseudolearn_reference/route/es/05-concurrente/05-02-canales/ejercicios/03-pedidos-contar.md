---
id: concurrente.canales.pedidos-contar
leccion: concurrente.canales
tipo: resolver
nivel: brote
obligatorio: true
titulo: Contar los pedidos
---

::: enunciado
Lee cuántos pedidos prepara la cocina. La cocina los numera desde 1 y los pasa al mostrador, donde caben 2; el mostrador muestra «Entrego el pedido n» por cada uno y, al final, «Entregados: n».
:::

::: restriccion
La cocina es una tarea que envía los pedidos por un canal creado con `Canal(2)` y lo cierra al terminar; el mostrador recibe hasta que el canal se cierra.
:::

```programa rol=referencia
SubProceso Suspendible Cocinar(cantidad Como Entero, mostrador Como Canal<Entero>)
  Para pedido <- 1 Hasta cantidad Hacer
    Definir aceptado Como Logico <- Aguardar mostrador.Enviar(pedido);
    Si No aceptado Entonces
      Escribir "El mostrador cerró";
    FinSi
  FinPara
  mostrador.Cerrar();
FinSubProceso

Algoritmo Pedidos
  Definir cantidad Como Entero;
  Leer cantidad;
  Definir mostrador Como Canal<Entero> <- Canal(2);
  Tareas
    Lanzar Cocinar(cantidad, mostrador);
    Definir entregados Como Entero <- 0;
    Repetir
      Segun Aguardar mostrador.Recibir() Hacer
        Algo(pedido):
          Escribir "Entrego el pedido ", pedido;
          entregados <- entregados + 1;
        Nada: Salir;
      FinSegun
    Hasta Que Falso
    Escribir "Entregados: ", entregados;
  FinTareas
FinAlgoritmo
```

```casos
visible | 3 | Entrego el pedido 1 ⏎ Entrego el pedido 2 ⏎ Entrego el pedido 3 ⏎ Entregados: 3
visible | 1 | Entrego el pedido 1 ⏎ Entregados: 1
oculto | 0 | Entregados: 0
oculto | 2 | Entrego el pedido 1 ⏎ Entrego el pedido 2 ⏎ Entregados: 2
oculto | 7 | Entrego el pedido 1 ⏎ Entrego el pedido 2 ⏎ Entrego el pedido 3 ⏎ Entrego el pedido 4 ⏎ Entrego el pedido 5 ⏎ Entrego el pedido 6 ⏎ Entrego el pedido 7 ⏎ Entregados: 7
```

```aserciones
- declara-subprograma | Cocinar | 2 | Falta el subprograma Cocinar, que recibe la cantidad de pedidos y el canal.
```

::: pistas
1. ¿Quién produce y quién consume?
2. Es el programa del mostrador de la lección, con la cantidad de pedidos leída al principio.
3. La cocina envía de 1 hasta la cantidad leída y cierra el canal; el mostrador repite `Recibir` hasta que llegue `Nada`.
4. La cuenta se declara dentro del ámbito, antes del bucle que recibe. Cierra con la variante.
:::

::: variante
Haz que el mostrador muestre también el número del último pedido entregado.
:::

::: docentes
Con 0 pedidos la cocina cierra sin enviar nada y el primer `Recibir` da `Nada`. Con 7 pedidos el canal se llena varias veces y la cocina espera: la salida es la misma.
:::
