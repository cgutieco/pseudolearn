---
id: inicio.errores
numero: "0.4"
tipo: leccion
titulo: Cuando algo sale mal
duracion: 25
problema_breve: Tres calculadoras de propinas que fallan
necesita: [inicio.preguntar]
introduce: [error-de-compilacion, error-de-ejecucion, error-de-logica, diagnostico, caso-de-prueba, caso-borde]
usa: [entrada, ficha-del-problema, ejemplo-a-mano, programa, ejecutar]
---

::: frase
Un programa puede fallar de tres maneras, y la más peligrosa es la que no da ningún aviso.
:::

## El problema {#problema}

::: problema
Tu compañero escribió tres versiones de la calculadora de propinas. La primera, el motor ni siquiera la acepta. La segunda funciona hasta que alguien escribe **0 amigos**. La tercera siempre muestra un número, pero con cuenta **120** y **4 amigos** dice que cada uno paga **3**.

**¿Qué le pasa a cada una, y cómo lo hubieras descubierto tú?**
:::

## Inténtalo {#intentalo}

::: intento
Lee las tres versiones que aparecen más abajo, en «Escribir», antes de ejecutarlas. Anota qué sospechas de cada una.
:::

::: respuesta
A la primera le falta un punto y coma al final de una línea. La segunda divide entre la cantidad de amigos, y dividir entre 0 no tiene respuesta. La tercera calcula solo la propina, `cuenta div 10`, y se olvidó de sumar la cuenta: 12 entre 4 da 3.
:::

## Entender {#entender fase=1}

Lo que se pide no es un programa nuevo. Es clasificar las fallas y encontrar un método para descubrirlas antes de que las descubra otra persona.

## Planear {#planear fase=2}

Para cada versión, tres preguntas en orden:

1. ¿El motor la acepta?
2. ¿Termina, o se detiene en el camino?
3. Lo que muestra, ¿coincide con el ejemplo a mano?

## La herramienta nueva {#herramienta}

Cada pregunta del plan descubre una clase de falla distinta.

- Un [[def:error-de-compilacion|error al compilar]] es un texto que el motor no puede entender: el programa no llega a empezar.
- Un [[def:error-de-ejecucion|error al ejecutar]] aparece en el camino: el programa empieza, pero se detiene en una instrucción que no puede hacer.
- Un [[def:error-de-logica|error de lógica]] no detiene nada: el programa termina y muestra un resultado equivocado. El motor no lo puede ver, porque hizo exactamente lo que dice el texto.

```figura id=ruta-tres-errores
pie: Los dos primeros los avisa el motor. El tercero solo lo descubres tú, comparando con tus ejemplos.
paso: El bus no arranca: un error al compilar. El motor lo avisa antes de empezar.
paso: El bus se rompe en el camino: un error al ejecutar. El motor lo avisa cuando pasa.
paso: El bus llega, pero a otra ciudad: un error de lógica. Nadie avisa.
```

Cuando el motor encuentra un error, escribe un [[def:diagnostico|diagnóstico]]: dice dónde está el problema (línea y columna), con un código y un mensaje.

```figura-especificacion seccion=diagnosticos.anatomia figura=anatomia-diagnostico
```

::: especificacion
- vision.errores
- diagnosticos.anatomia
- vision.terminacion
:::

## Escribir {#escribir fase=3}

No hay solución nueva: se ejecutan las tres versiones.

```programa id=propina-a titulo="Versión A" ejecutar
Algoritmo Propina
  Definir cuenta Como Entero;
  Definir amigos Como Entero;
  Escribir "¿Cuánto es la cuenta?";
  Leer cuenta;
  Escribir "¿Cuántos amigos pagan?"
  Leer amigos;
  Definir total Como Entero <- cuenta + cuenta div 10;
  Escribir "Cada uno paga: ", techo(total / amigos);
FinAlgoritmo
```

```diagnosticos
missingStatementTerminator
```

El diagnóstico señala la línea 6, donde falta el punto y coma, y el programa no llega a preguntar nada.

```programa id=propina-b titulo="Versión B, con 0 amigos" ejecutar termina=failed
Algoritmo Propina
  Definir cuenta Como Entero;
  Definir amigos Como Entero;
  Escribir "¿Cuánto es la cuenta?";
  Leer cuenta;
  Escribir "¿Cuántos amigos pagan?";
  Leer amigos;
  Definir total Como Entero <- cuenta + cuenta div 10;
  Escribir "Cada uno paga: ", techo(total / amigos);
FinAlgoritmo
```

```entrada
100
0
```

```salida
¿Cuánto es la cuenta?
¿Cuántos amigos pagan?
```

```diagnosticos
divisionByZero
```

La versión B empieza bien: pregunta los dos datos. Se detiene en la última instrucción, al dividir entre 0.

```programa id=propina-c titulo="Versión C" ejecutar
Algoritmo Propina
  Definir cuenta Como Entero;
  Definir amigos Como Entero;
  Escribir "¿Cuánto es la cuenta?";
  Leer cuenta;
  Escribir "¿Cuántos amigos pagan?";
  Leer amigos;
  Definir total Como Entero <- cuenta div 10;
  Escribir "Cada uno paga: ", techo(total / amigos);
FinAlgoritmo
```

```entrada
120
4
```

```salida
¿Cuánto es la cuenta?
¿Cuántos amigos pagan?
Cada uno paga: 3
```

La versión C termina sin quejarse. Si no tuvieras el ejemplo a mano (33), aceptarías el 3.

## Probar {#probar fase=4}

Un [[def:caso-de-prueba|caso de prueba]] es una entrada con la salida que esperas, sacada de un ejemplo a mano. Elegirlos bien es un oficio: los casos más útiles son los [[def:caso-borde|casos borde]], que están justo en el límite donde un programa apurado se equivoca.

```figura id=ruta-recta-casos
pie: Un caso de cada zona: el normal descubre errores de lógica; el borde y el raro, los que esperan en las orillas.
```

| Caso | Cuenta y amigos | Esperado | Versión B | Versión C |
|---|---|---|---|---|
| Normal | 120 y 4 | 33 | 33 | 3 ✗ |
| Borde | 100 y 1 | 110 | 110 | 10 ✗ |
| Raro | 100 y 0 | un aviso | se detiene ✗ | se detiene ✗ |

El caso normal descubre la versión C. El raro descubre la B, y también la C.

## Mejorar {#mejorar fase=5}

En una frase: «Antes de dar por bueno un programa, lo pruebo con un caso normal, uno borde y uno raro, y comparo con mis ejemplos a mano».

El caso raro todavía no tiene solución: para avisar «no hay quien pague» en lugar de detenerse, el programa tendría que decidir. Queda abierto.

## Lo que aprendiste {#aprendiste}

::: resumen
- {error-de-compilacion,error-de-ejecucion,error-de-logica} Un error al compilar impide empezar; uno al ejecutar detiene el programa en el camino; uno de lógica da un resultado equivocado sin aviso.
- {diagnostico} Un diagnóstico dice dónde está el problema, con un código y un mensaje.
- {caso-de-prueba,caso-borde} Un caso de prueba es una entrada con su salida esperada; un caso borde está justo en el límite donde un programa apurado se equivoca.
:::

## Practica {#practica}

::: practica
- inicio.errores.tres-cajones
- inicio.errores.se-detiene
- inicio.errores.promedio-dos
- inicio.errores.buses-romper
- inicio.errores.buses-pruebas
- inicio.errores.donde-se-corrige
:::

::: docentes
- **«Si compila, está bien».** La versión C compila y termina. Pide que la prueben antes de mostrar el ejemplo a mano.
- **«El error está en la línea que marca el motor».** A veces está justo antes: en la versión A, el punto y coma falta al final de la línea 6.
- **Probar solo con el ejemplo del enunciado.** Pide siempre un caso borde y uno raro.
:::

::: siguiente
Hasta ahora cada programa hace siempre lo mismo. ¿Y si, según el dato, hay que hacer cosas distintas, como avisar que no se puede dividir entre 0 amigos?
:::
