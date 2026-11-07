---
id: funcional.sin-cambiar
numero: "4.1"
tipo: apertura
titulo: Calcular sin cambiar nada
duracion: 30
problema_breve: El ticket que dice otra cosa
necesita: [objetos.proyecto]
introduce: [programacion-funcional, inmutabilidad, transparencia-referencial, nucleo-puro]
usa: [paradigma, paso-por-referencia, funcion-pura, efecto, programacion-imperativa, programacion-orientada-a-objetos]
---

::: frase
La programación funcional arma los programas con cálculos que no modifican nada: reciben valores y devuelven valores nuevos. Así, para saber qué vale algo, basta con leer de dónde sale.
:::

## El problema {#problema}

::: problema
Un cliente del kiosco compra **3 jugos** de 3 pesos y **2 sándwiches** de 5 pesos. Por cada 10 pesos de compra se descuenta 1 peso. La caja le cobra **18** pesos, pero el ticket que se lleva dice **17**. Nadie tocó el ticket a mano.

**¿Qué pasó, y cómo se escribe la caja para que no pueda volver a pasar?**
:::

```programa id=caja-referencia titulo="La caja del kiosco" ejecutar
SubProceso AplicarDescuento(total Como Entero Por Referencia)
  total <- total - total div 10;
FinSubProceso

Algoritmo Caja
  Definir total Como Entero <- 0;
  total <- total + 3 * 3;
  total <- total + 5 * 2;
  AplicarDescuento(total);
  Escribir "Cobrado: ", total;
  AplicarDescuento(total);
  Escribir "Ticket: ", total;
FinAlgoritmo
```

```salida
Cobrado: 18
Ticket: 17
```

## Inténtalo {#intentalo}

::: intento
Encuentra el error leyendo, sin ejecutar. Después responde algo más difícil: ¿qué vale `total` justo antes del último `Escribir`? Fíjate en qué tuviste que leer para contestar.
:::

::: respuesta
El segundo `AplicarDescuento` vuelve a aplicar el descuento. Como `total` se pasa por referencia, cada llamada cambia la caja original: 19 se vuelve 18 y después 17.

Para saber qué vale `total` antes del último `Escribir` tuviste que leer todas las líneas anteriores, en orden, y contar cuántas veces se cambió. Ese es el problema de fondo: cuando una caja cambia muchas veces, su valor depende de la historia completa del programa. Con diez líneas se puede seguir; con mil, no.
:::

::: recuerda termino=paso-por-referencia
:::

## Un paradigma nuevo {#paradigma}

::: recuerda termino=paradigma
:::

Hasta ahora resolviste problemas dando órdenes que cambian cajas y armando objetos que guardan su estado y lo cambian con sus métodos. Las dos formas tienen algo en común: el programa avanza cambiando cosas. La [[def:programacion-funcional|programación funcional]] propone lo contrario.

::: paradigma
- pregunta: ¿y si nada cambiara? ¿Y si cada valor se calculara una sola vez, a partir de otros, y después quedara fijo?
- metafora: una hoja de cálculo. La celda del total es una fórmula sobre otras celdas: nadie le resta algo al total; si cambia un precio, el total se vuelve a calcular. Deja de valer en un punto: una hoja recalcula sola, y un programa calcula una vez lo que se le pide.
- historia: del cálculo lambda de Alonzo Church, en 1936, una teoría matemática sobre qué se puede calcular, anterior a las computadoras. Lisp, de John McCarthy, lo llevó a la programación en 1958.
- costo: el mundo sí cambia: leer un dato, mostrar un ticket o guardar un archivo son cambios. No desaparecen; se ponen aparte, en un lugar pequeño y fácil de vigilar.
:::

::: recuerda termino=funcion-pura
:::

Ya conoces la pieza con la que se construye todo esto. Esta parte de la ruta enseña a construir programas enteros con ella.

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Entran los precios y las cantidades; sale lo que se cobra, y el ticket muestra lo mismo.
- **¿A qué se parece?** A una fórmula: precio por cantidad, se suman las líneas, se descuenta.
- **¿Qué parte es cálculo y qué parte toca el mundo?** Calcular el total es cálculo puro. Mostrarlo en el ticket toca el mundo.

La tercera pregunta lleva a la idea central de esta parte. El programa se divide en dos zonas: un [[def:nucleo-puro|núcleo puro]], donde va todo lo que se puede calcular, y un borde con efectos, lo más delgado posible, donde se lee y se muestra.

```figura id=ruta-nucleo-borde
pie: Todo lo que se puede calcular va al centro, en funciones puras. Lo que toca el mundo queda en el borde, y el borde es lo más delgado posible.
```

## Escribir {#escribir fase=3}

```programa id=caja-funcional titulo="La caja, versión funcional" ejecutar
Funcion importe <- Linea(precio Como Entero, cantidad Como Entero)
  Definir importe Como Entero;
  importe <- precio * cantidad;
FinFuncion

Funcion monto <- ConDescuento(total Como Entero)
  Definir monto Como Entero;
  monto <- total - total div 10;
FinFuncion

Algoritmo Caja
  Definir aPagar Como Entero <- ConDescuento(Linea(3, 3) + Linea(5, 2));
  Escribir "Cobrado: ", aPagar;
  Escribir "Ticket: ", aPagar;
  Escribir "Doble descuento: ", ConDescuento(ConDescuento(19));
FinAlgoritmo
```

```salida
Cobrado: 18
Ticket: 18
Doble descuento: 17
```

Tres cosas cambiaron:

- Ninguna caja cambia después de recibir su valor: `aPagar` se calcula una sola vez y nunca más se le asigna nada. Trabajar así es [[def:inmutabilidad|inmutabilidad]]: en vez de modificar un valor, se calcula uno nuevo.
- El descuento no se aplica: se calcula. `ConDescuento` recibe un monto y devuelve otro; el que recibió queda igual.
- Si quieres dos descuentos, se ve. La última línea los pide a propósito; en la versión anterior el doble descuento estaba escondido en el orden de las líneas.

::: especificacion
- subprogramas.pureza
:::

## Probar {#probar fase=4}

En la versión con cajas que cambian, para saber cuánto vale `total` había que seguir la historia del programa. Aquí alcanza con reemplazar cada llamada por lo que devuelve, como en una cuenta de matemática:

```figura id=ruta-sustitucion
pie: Cada paso reemplaza una llamada por su resultado. Funciona porque las funciones son puras.
paso: La expresión, tal como está escrita.
paso: Las dos llamadas a la línea se reemplazan por 9 y 10.
paso: 9 + 10 es 19.
paso: La llamada al descuento se reemplaza por su cálculo, con 19.
paso: 19 entre 10 cabe una vez: el descuento es 1.
paso: El resultado: 18. No hizo falta saber qué pasó antes en el programa.
```

Que una llamada se pueda reemplazar por su resultado en cualquier lugar del programa, sin que nada cambie, es la [[def:transparencia-referencial|transparencia referencial]]. Por eso el núcleo es fácil de probar: cada función se prueba sola, con una tabla de casos.

```programa id=casos-descuento titulo="Casos del descuento" ejecutar
Funcion monto <- ConDescuento(total Como Entero)
  Definir monto Como Entero;
  monto <- total - total div 10;
FinFuncion

Algoritmo Casos
  Escribir ConDescuento(19), " ", ConDescuento(9), " ", ConDescuento(10), " ", ConDescuento(0);
FinAlgoritmo
```

```salida
18 9 9 0
```

9 es el caso borde: con menos de 10 pesos no hay descuento. 10 es el primer monto con descuento.

## Mejorar {#mejorar fase=5}

En una frase: «La caja calcula lo que se cobra en un núcleo de funciones puras, y solo el borde lo muestra».

Compara las dos cajas. No hay una mejor en todo: esa es la idea de tener varios paradigmas.

| | Cajas que cambian | Núcleo puro |
|---|---|---|
| ¿Qué vale el total en una línea? | depende de todo lo anterior | lo dice la expresión que lo calcula |
| ¿Importa el orden de las líneas? | sí, y mucho | solo en el borde |
| Probar una parte | preparar el estado, ejecutar y revisar | una tabla de entrada y salida |
| Un saldo que sube y baja todo el día | natural | hay que pensarlo como una serie de valores nuevos |

La última fila es honesta: algunos problemas se piensan mejor como algo que cambia. La lección 4.5 pone los tres paradigmas cara a cara.

## Lo que aprendiste {#aprendiste}

::: resumen
- {programacion-funcional} La programación funcional arma programas con funciones puras que reciben valores y devuelven valores nuevos.
- {inmutabilidad} Con inmutabilidad, en vez de modificar un valor, se calcula uno nuevo.
- {transparencia-referencial} Con transparencia referencial, una llamada se puede reemplazar por su resultado sin cambiar el programa.
- {nucleo-puro} El núcleo puro guarda el cálculo; leer y mostrar quedan en un borde delgado con efectos.
:::

## Practica {#practica}

::: practica
- funcional.sin-cambiar.nucleo-o-borde
- funcional.sin-cambiar.sustituye
- funcional.sin-cambiar.ticket-puro
- funcional.sin-cambiar.caja-iva
- funcional.sin-cambiar.cual-probar
:::

::: docentes
- **«Si no cambia nada, no hace nada».** El programa sí muestra cosas: lo hace desde el borde. Pide marcar en la caja funcional qué líneas son borde.
- **Confundir inmutable con constante escrita a mano.** `aPagar` se calcula; lo que no hace es cambiar después.
- **Creer que hay que elegir un paradigma para siempre.** La tabla de cierre muestra que cada uno hace fácil algo distinto.
:::

::: siguiente
Tres bucles del kiosco recorren la misma lista y solo cambian en una operación. ¿Se puede escribir el bucle una vez y pasarle la operación?
:::
