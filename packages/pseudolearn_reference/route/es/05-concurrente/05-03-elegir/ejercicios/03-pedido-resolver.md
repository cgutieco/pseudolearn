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
Cada proveedor se revisa en su propia tarea, que devuelve el motivo si no tiene stock o un texto vacío si tiene.
:::

```programa rol=referencia
SubProceso Suspendible Revisar(nombre Como Cadena, stock Como Entero) Como Cadena
  Si stock = 0 Entonces
    Retornar nombre + " no tiene stock";
  FinSi
  Retornar "";
FinSubProceso

Algoritmo Pedido
  Definir norte Como Entero;
  Definir sur Como Entero;
  Definir oeste Como Entero;
  Leer norte;
  Leer sur;
  Leer oeste;
  Tareas
    Definir deNorte Como Tarea<Cadena> <- Lanzar Revisar("Norte", norte);
    Definir deSur Como Tarea<Cadena> <- Lanzar Revisar("Sur", sur);
    Definir deOeste Como Tarea<Cadena> <- Lanzar Revisar("Oeste", oeste);
    Definir motivo Como Cadena <- Aguardar deNorte + Aguardar deSur + Aguardar deOeste;
    Si motivo = "" Entonces
      Escribir "Pedido confirmado: ", norte + sur + oeste;
    Sino
      Escribir "Pedido suspendido: ", motivo;
    FinSi
  FinTareas
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
- declara-subprograma | Revisar | 2 | Falta el subprograma Revisar, que recibe el nombre y el stock.
```

::: pistas
1. ¿Qué tiene que decir cada revisión cuando hay stock, y qué cuando no?
2. Es como la bandeja de la lección 5.1: tres tareas, y el algoritmo aguarda las tres.
3. Si cada tarea devuelve el motivo o un texto vacío, unir los tres textos da el motivo del problema, o un texto vacío si no hubo ninguno.
4. Con un `Si` sobre ese texto, muestra la confirmación con la suma o la suspensión con el motivo. Cierra con la variante.
:::

::: variante
Muestra también cuántos proveedores tenían stock cuando el pedido se confirma.
:::

::: docentes
Los casos tienen como mucho un proveedor sin stock. Las tareas de este ejercicio no terminan con `Error`: en la app, el comprobador avanza paso a paso y, con el motor actual, cancelar tareas hermanas que siguen vivas detiene el programa. Por eso la cancelación se practica en los dos ejercicios de predecir y en el programa de la lección.
:::
