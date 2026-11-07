---
id: funcional.tipos-dominio.registro-a-variante
leccion: funcional.tipos-dominio
tipo: modificar
nivel: brote
obligatorio: false
titulo: Del registro a la variante
---

::: enunciado
Este programa lee el estado de un envío como texto y, si hace falta, un dato más. Con cualquier estado que no conoce muestra «Pendiente», y así un error de tipeo como «entrgado» pasa desapercibido. Reescríbelo de modo que cada estado sea una forma con sus propios datos, y que haya una forma para los estados desconocidos, que muestra «Estado desconocido: » y el texto leído. Para los estados conocidos, lo que se muestra no cambia.
:::

::: restriccion
El envío es una variante con una forma por estado, y cada forma lleva solo sus datos.
:::

```programa rol=inicial
Registro Envio
  Definir estado, repartidor, motivo Como Cadena;
  Definir hora Como Entero;
FinRegistro

Algoritmo Envios
  Definir estado Como Cadena;
  Leer estado;
  Definir envio Como Envio <- Envio(estado, "", "", 0);
  Si estado = "en camino" Entonces
    Leer envio.repartidor;
    Escribir "En camino con ", envio.repartidor;
  Sino
    Si estado = "cancelado" Entonces
      Leer envio.motivo;
      Escribir "Cancelado: ", envio.motivo;
    Sino
      Escribir "Pendiente";
    FinSi
  FinSi
FinAlgoritmo
```

```programa rol=referencia
Variante Envio
  Alternativa Pendiente
  Alternativa EnCamino(repartidor Como Cadena)
  Alternativa Cancelado(motivo Como Cadena)
  Alternativa Desconocido(estado Como Cadena)
FinVariante

Funcion texto <- Describir(envio Como Envio)
  Definir texto Como Cadena <- "";
  Segun envio Hacer
    Envio.Pendiente: texto <- "Pendiente";
    Envio.EnCamino(quien): texto <- "En camino con " + quien;
    Envio.Cancelado(motivo): texto <- "Cancelado: " + motivo;
    Envio.Desconocido(estado): texto <- "Estado desconocido: " + estado;
  FinSegun
FinFuncion

Algoritmo Envios
  Definir estado, dato Como Cadena;
  Leer estado;
  Definir envio Como Envio <- Envio.Desconocido(estado);
  Si estado = "pendiente" Entonces
    envio <- Envio.Pendiente;
  FinSi
  Si estado = "en camino" Entonces
    Leer dato;
    envio <- Envio.EnCamino(dato);
  FinSi
  Si estado = "cancelado" Entonces
    Leer dato;
    envio <- Envio.Cancelado(dato);
  FinSi
  Escribir Describir(envio);
FinAlgoritmo
```

```casos
visible | en camino ; Sol | En camino con Sol
visible | entrgado | Estado desconocido: entrgado
oculto | cancelado ; lluvia | Cancelado: lluvia
oculto | pendiente | Pendiente
oculto | nada | Estado desconocido: nada
```

::: pistas
1. ¿Qué estados existen? ¿Qué dato necesita cada uno?
2. Repasa la variante del pedido en [la lección](ruta:funcional.tipos-dominio).
3. Una forma por estado conocido y otra para lo que no se reconoce, que guarda el texto.
4. Arma el envío según el texto y descríbelo con un `Segun` sobre sus formas. Cierra con la variante.
:::

::: variante
Agrega el estado entregado con su hora, sin tocar las otras formas.
:::

::: docentes
La versión con registro acepta cualquier texto como estado. La variante obliga a decidir qué hacer con lo que no se reconoce.
:::
