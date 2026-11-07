---
id: concurrente.tareas.bandeja
leccion: concurrente.tareas
tipo: resolver
nivel: brote
obligatorio: true
titulo: La bandeja
---

::: enunciado
Lee las porciones de jugos, de sándwiches y de frutas, y muestra el valor de la bandeja con el formato «Bandeja: 27 pesos». Los precios son 3, 5 y 2 pesos.
:::

::: restriccion
Cada plato se calcula en su propia tarea, lanzada con `Lanzar` dentro de un ámbito `Tareas`.
:::

```programa rol=referencia
SubProceso Suspendible Cocinar(precio Como Entero, porciones Como Entero) Como Entero
  Retornar precio * porciones;
FinSubProceso

Algoritmo Bandeja
  Definir jugos Como Entero;
  Definir sandwiches Como Entero;
  Definir frutas Como Entero;
  Leer jugos;
  Leer sandwiches;
  Leer frutas;
  Tareas
    Definir deJugos Como Tarea<Entero> <- Lanzar Cocinar(3, jugos);
    Definir deSandwiches Como Tarea<Entero> <- Lanzar Cocinar(5, sandwiches);
    Definir deFrutas Como Tarea<Entero> <- Lanzar Cocinar(2, frutas);
    Escribir "Bandeja: ", Aguardar deJugos + Aguardar deSandwiches + Aguardar deFrutas, " pesos";
  FinTareas
FinAlgoritmo
```

```casos
visible | 3 ; 2 ; 4 | Bandeja: 27 pesos
visible | 1 ; 1 ; 1 | Bandeja: 10 pesos
oculto | 0 ; 0 ; 0 | Bandeja: 0 pesos
oculto | 0 ; 2 ; 0 | Bandeja: 10 pesos
oculto | 10 ; 10 ; 10 | Bandeja: 100 pesos
```

```aserciones
- declara-subprograma | Cocinar | 2 | Falta el subprograma Cocinar, que recibe el precio y las porciones.
```

::: pistas
1. ¿Qué cálculo se repite tres veces con datos distintos?
2. Es el cocinero de la lección, sin el mensaje: recibe el precio y las porciones y devuelve el valor del plato.
3. Lanza tres tareas `Tarea<Entero>` y suma lo que entrega `Aguardar` de cada una.
4. La suma y el `Escribir` van dentro del ámbito, antes de `FinTareas`. Cierra con la variante.
:::

::: variante
Agrega un cuarto cocinero que prepara aguas de 2 pesos.
:::

::: docentes
La aserción exige el subprograma del cocinero. El caso de 0 porciones confirma que la bandeja igual espera a los tres; 10 porciones de cada plato prueban cantidades más grandes.
:::
