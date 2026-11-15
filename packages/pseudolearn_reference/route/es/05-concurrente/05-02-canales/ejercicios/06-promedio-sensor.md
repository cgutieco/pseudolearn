---
id: concurrente.canales.promedio-sensor
leccion: concurrente.canales
tipo: resolver
nivel: arbol
obligatorio: false
titulo: El promedio del sensor
---

::: enunciado
Un sensor mide 5 temperaturas enteras. Léelas y muestra su promedio como número real, por ejemplo 24.0.
:::

::: restriccion
Una tarea lee las temperaturas y las envía por un canal; otra las recibe y calcula el promedio.
:::

```programa rol=referencia
SubProceso Suspendible Medir(sensor Como Canal<Entero>)
  Para medida <- 1 Hasta 5 Hacer
    Definir temperatura Como Entero;
    Leer temperatura;
    Definir aceptado Como Logico <- Aguardar sensor.Enviar(temperatura);
    Si No aceptado Entonces
      Escribir "El sensor se desconectó";
    FinSi
  FinPara
  sensor.Cerrar();
FinSubProceso

SubProceso Suspendible Promediar(sensor Como Canal<Entero>)
  Definir suma Como Entero <- 0;
  Definir medidas Como Entero <- 0;
  Repetir
    Segun Aguardar sensor.Recibir() Hacer
      Algo(temperatura):
        suma <- suma + temperatura;
        medidas <- medidas + 1;
      Nada: Salir;
    FinSegun
  Hasta Que Falso
  Escribir suma / medidas;
FinSubProceso

Algoritmo Sensor
  Definir sensor Como Canal<Entero> <- Canal(2);
  Tareas
    Lanzar Medir(sensor);
    Lanzar Promediar(sensor);
  FinTareas
FinAlgoritmo
```

```casos
visible | 20 ; 22 ; 24 ; 26 ; 28 | 24.0
visible | 10 ; 10 ; 10 ; 10 ; 10 | 10.0
oculto | 0 ; 0 ; 0 ; 0 ; 0 | 0.0
oculto | -5 ; 5 ; -5 ; 5 ; 0 | 0.0
oculto | 1 ; 2 ; 3 ; 4 ; 5 | 3.0
```

```aserciones
- contiene | bucle-condicional-posterior | El consumidor recibe en un bucle hasta que el canal se cierra.
```

::: pistas
1. ¿Quién es el productor y quién el consumidor?
2. Es la tubería de la lección: el productor envía y cierra; el consumidor recibe hasta `Nada`.
3. El consumidor guarda la suma y la cantidad de medidas, y al final divide con `/`, que da un real.
4. Cada tarea guarda sus propias cajas: la suma vive en el consumidor. Cierra con la variante.
:::

::: variante
Muestra también la temperatura más alta.
:::

::: explicacion
`/` entre enteros da un real, por eso 24 se muestra 24.0. Las temperaturas negativas prueban que la suma puede bajar; el caso de ceros, que no hay división entre cero porque siempre llegan 5 medidas.
:::
