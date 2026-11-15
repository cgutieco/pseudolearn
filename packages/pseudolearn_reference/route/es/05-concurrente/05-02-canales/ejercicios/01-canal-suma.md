---
id: concurrente.canales.canal-suma
leccion: concurrente.canales
tipo: predecir
nivel: semilla
obligatorio: true
titulo: La suma que llega por partes
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
SubProceso Suspendible Producir(fila Como Canal<Entero>)
  Para valor <- 4 Hasta 6 Hacer
    Definir aceptado Como Logico <- Aguardar fila.Enviar(valor);
    Si No aceptado Entonces
      Escribir "canal cerrado";
    FinSi
  FinPara
  fila.Cerrar();
FinSubProceso

SubProceso Suspendible Sumar(fila Como Canal<Entero>)
  Definir total Como Entero <- 0;
  Repetir
    Segun Aguardar fila.Recibir() Hacer
      Algo(valor): total <- total + valor;
      Nada: Salir;
    FinSegun
  Hasta Que Falso
  Escribir total;
FinSubProceso

Algoritmo CanalSuma
  Definir fila Como Canal<Entero> <- Canal(2);
  Tareas
    Lanzar Producir(fila);
    Lanzar Sumar(fila);
  FinTareas
FinAlgoritmo
```

```salida
15
```

::: explicacion
El productor envía 4, 5 y 6 y cierra. El consumidor suma cada mensaje y, cuando `Recibir` da `Nada`, sale del bucle y escribe 15.
:::
