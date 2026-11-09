---
id: concurrente.elegir.pedido-resolver
leccion: concurrente.elegir
tipo: resolver
nivel: brote
obligatorio: true
titulo: El pedido de fruta
---

::: enunciado
Lee el stock de Norte, de Sur y de Oeste. Si alguno tiene 0, muestra «Pedido suspendido: » y el motivo, por ejemplo «Norte no tiene stock»; si no, muestra «Pedido confirmado: » y la suma de los tres.
:::

::: restriccion
Cada proveedor se consulta en su propia tarea, que devuelve un `Resultado`: `Exito` con el stock o `Error` con el motivo. El primer error suspende el pedido.
:::

```programa rol=referencia
SubProceso Suspendible Consultar(nombre Como Cadena, stock Como Entero) Como Resultado<Entero, Cadena>
  Si stock = 0 Entonces
    Retornar Error(nombre + " no tiene stock");
  FinSi
  Retornar Exito(stock);
FinSubProceso

Algoritmo Pedido
  Definir norte Como Entero;
  Definir sur Como Entero;
  Definir oeste Como Entero;
  Leer norte;
  Leer sur;
  Leer oeste;
  Tareas fallo
    Lanzar Consultar("Norte", norte);
    Lanzar Consultar("Sur", sur);
    Lanzar Consultar("Oeste", oeste);
  FinTareas
  Segun fallo Hacer
    Algo(problema): Escribir "Pedido suspendido: ", problema.Primero;
    Nada: Escribir "Pedido confirmado: ", norte + sur + oeste;
  FinSegun
FinAlgoritmo
```

```casos
visible | 5 ; 3 ; 2 | Pedido confirmado: 10
visible | 0 ; 3 ; 2 | Pedido suspendido: Norte no tiene stock
oculto | 1 ; 1 ; 1 | Pedido confirmado: 3
oculto | 4 ; 4 ; 0 | Pedido suspendido: Oeste no tiene stock
oculto | 9 ; 0 ; 9 | Pedido suspendido: Sur no tiene stock
```

```aserciones
- declara-subprograma | Consultar | 2 | Falta el subprograma Consultar, que recibe el nombre y el stock.
```

::: pistas
1. ¿Qué tiene que devolver cada consulta cuando hay stock, y qué cuando no?
2. Es como el programa de la lección: tres tareas en un ámbito `Tareas fallo`, y la que devuelve `Error` corta a las demás.
3. Después de `FinTareas`, `fallo` es `Nada` si todas dieron `Exito`, o `Algo` con un informe cuyo `Primero` es el motivo.
4. Con un `Segun` sobre `fallo`, muestra la suspensión con el motivo o la confirmación con la suma. Cierra con la variante.
:::

::: variante
Muestra también cuántos proveedores tenían stock cuando el pedido se confirma.
:::

::: explicacion
Los casos tienen como mucho un proveedor sin stock, así que el motivo no depende de los turnos de la agenda. Cuando un proveedor falla, el ámbito cancela a las consultas que siguen vivas; el ejercicio no pregunta cuántas.
:::
