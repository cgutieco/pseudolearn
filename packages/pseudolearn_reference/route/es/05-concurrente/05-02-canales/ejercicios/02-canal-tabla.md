---
id: concurrente.canales.canal-tabla
leccion: concurrente.canales
tipo: rastrear
nivel: brote
obligatorio: false
titulo: Rastrea al consumidor
---

::: enunciado
Completa la tabla de la tarea que suma: el mensaje recibido y el total, una fila por mensaje.
:::

```programa rol=objeto id=traza
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
  Definir valor Como Entero <- 0;
  Repetir
    Segun Aguardar fila.Recibir() Hacer
      Algo(recibido):
        valor <- recibido;
        total <- total + valor;
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

```vueltas marca=19 columnas=valor,total
1 | 4 | ?4
2 | ?5 | ?9
3 | ?6 | ?15
```

::: explicacion
Cada mensaje se suma al total: 4, después 4 + 5 = 9 y al final 9 + 6 = 15. Los mensajes llegan en el orden en que se enviaron.
:::
