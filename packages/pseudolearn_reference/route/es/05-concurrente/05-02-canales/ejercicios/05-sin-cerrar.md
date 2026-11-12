---
id: concurrente.canales.sin-cerrar
leccion: concurrente.canales
tipo: encontrar-error
nivel: brote
obligatorio: false
titulo: El mostrador que no termina
---

::: enunciado
El programa entrega todos los pedidos, pero nunca muestra la cuenta final y el motor lo detiene. Encuentra el error y corrígelo.
:::

```programa rol=inicial
SubProceso Suspendible Cocinar(cantidad Como Entero, mostrador Como Canal<Entero>)
  Para pedido <- 1 Hasta cantidad Hacer
    Definir aceptado Como Logico <- Aguardar mostrador.Enviar(pedido);
    Si No aceptado Entonces
      Escribir "El mostrador cerró";
    FinSi
  FinPara
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
oculto | 5 | Entrego el pedido 1 ⏎ Entrego el pedido 2 ⏎ Entrego el pedido 3 ⏎ Entrego el pedido 4 ⏎ Entrego el pedido 5 ⏎ Entregados: 5
```

::: pistas
1. ¿Qué espera el mostrador después del último pedido?
2. El mostrador sale del bucle solo cuando `Recibir` da `Nada`.
3. `Recibir` da `Nada` cuando el canal se cerró y está vacío. ¿Quién lo cierra?
4. Falta `mostrador.Cerrar()` al final de la cocina. Cierra con la variante.
:::

::: variante
¿Qué pasaría si el mostrador cerrara el canal en vez de la cocina?
:::

::: explicacion
El motor termina con `taskDeadlock`: ninguna tarea puede avanzar. Es el error de olvidar cerrar el canal, el segundo de la lista de la lección.
:::
