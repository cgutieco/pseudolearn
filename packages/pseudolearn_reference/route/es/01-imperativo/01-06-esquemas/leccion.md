---
id: imperativo.esquemas
numero: "1.6"
tipo: leccion
titulo: Buscar, contar y filtrar
duracion: 35
problema_breve: Las olas de calor
necesita: [imperativo.arreglos]
introduce: [esquema, seguidor]
usa: [arreglo, recorredor, contador, acumulador, mejor-hasta-ahora, bandera, salida-anticipada, caso-borde]
---

::: frase
Casi todo problema con una colección es una combinación de unos pocos esquemas que ya conoces.
:::

## El problema {#problema}

::: problema
El kiosco registró la máxima de **14 días seguidos**. Una **ola de calor** son **3 o más días seguidos por encima de 30 grados**.

**¿Cuántas olas hubo, y cuántos días duró la más larga?**
:::

## Inténtalo {#intentalo}

::: intento
Resuélvelo a mano con estas máximas: 28, 31, 32, 33, 29, 31, 30, 31, 32, 31, 35, 27, 31, 32.
:::

::: respuesta
Las rachas de días por encima de 30 duran 3, 1, 4 y 2 días. Solo dos llegan a 3: hubo **2 olas**, y la más larga duró **4 días**.

El 30 no cuenta: tiene que ser **más** de 30. Por eso el séptimo día corta la racha.
:::

## Entender {#entender fase=1}

::: ficha
- entra: 14 temperaturas, una por día.
- sale: cuántas olas hubo y cuántos días duró la más larga.
- relacion: una ola es una racha de 3 o más días seguidos por encima de 30.
- ejemplo: el de la consigna → 2 olas, la más larga de 4.
- ejemplo: los tres últimos días por encima de 30 → la ola termina con los datos y también cuenta.
- ejemplo: una racha de exactamente 3 días → es una ola.
:::

Los dos últimos ejemplos son casos borde. El primero es el que más se olvida: una ola que todavía no se cortó cuando se terminan los datos.

## Planear {#planear fase=2}

Muchos problemas con colecciones se resuelven con las mismas pocas formas. Cada una es un [[def:esquema|esquema]]:

```figura id=ruta-esquemas
pie: Seis esquemas sobre la misma colección. Casi todo problema combina dos o tres.
```

| Esquema | Qué hace | Lo viste en |
|---|---|---|
| Recorrer | visita cada dato | los días calurosos |
| Contar | cuenta los que cumplen algo | los aprobados |
| Acumular | junta los datos en un total | el promedio |
| Buscar | encuentra el primero que cumple y se detiene | el primo |
| Filtrar | se queda con los que cumplen | los días calurosos |
| Transformar | cambia cada dato por otro | — |

Este problema combina tres: contar los días de la racha, contar las olas y quedarse con la más larga. Para la racha hace falta una caja que recuerde lo que pasó en los días anteriores:

::: roles
- seguidor | ruta-rol-seguidor | Recuerda el dato anterior, o la racha que se viene formando, para compararlo con el actual.
:::

Un [[def:seguidor|seguidor]] lleva la cuenta de la racha: sube con cada día caluroso y vuelve a 0 cuando la racha se corta.

```figura id=ruta-racha
pie: La racha sube con cada día de más de 30 y vuelve a 0 al cortarse. Al cortarse, se decide si fue una ola.
paso: Días 1 a 4: la racha llega a 3 y se corta con el 29. Es la primera ola.
paso: Días 5 y 6: una racha de 1 día; no es ola.
paso: Día 7: el 30 corta la racha, porque no es más de 30.
paso: Días 8 a 11: una racha de 4 días. Es la segunda ola, y la más larga.
paso: Día 12: el 27 la corta.
paso: Días 13 y 14: una racha de 2 que termina con los datos. Se revisa después del bucle: no es ola.
```

## La herramienta nueva {#herramienta}

No hay construcción nueva: se combinan las que ya conoces. Un seguidor también puede recordar solo el dato anterior. Por ejemplo, para contar cuántas veces un día fue más caluroso que el anterior:

```programa id=subidas titulo="¿Cuántas veces subió?" ejecutar
Algoritmo Subidas
  Dimension t[4] Como Entero;
  t[0] <- 20;
  t[1] <- 22;
  t[2] <- 21;
  t[3] <- 25;
  Definir subidas Como Entero <- 0;
  Para i <- 1 Hasta 3 Hacer
    Si t[i] > t[i - 1] Entonces
      subidas <- subidas + 1;
    FinSi
  FinPara
  Escribir subidas;
FinAlgoritmo
```

```salida
2
```

## Escribir {#escribir fase=3}

```programa id=olas titulo="Las olas de calor" ejecutar
Algoritmo Olas
  Dimension t[14] Como Entero;
  Para i <- 0 Hasta 13 Hacer
    Leer t[i];
  FinPara
  Definir racha Como Entero <- 0;
  Definir olas Como Entero <- 0;
  Definir masLarga Como Entero <- 0;
  Para Cada temperatura En t Hacer
    Si temperatura > 30 Entonces
      racha <- racha + 1;
    Sino
      Si racha >= 3 Entonces
        olas <- olas + 1;
        Si racha > masLarga Entonces
          masLarga <- racha;
        FinSi
      FinSi
      racha <- 0;
    FinSi
  FinPara
  Si racha >= 3 Entonces
    olas <- olas + 1;
    Si racha > masLarga Entonces
      masLarga <- racha;
    FinSi
  FinSi
  Escribir "Olas: ", olas;
  Escribir "La más larga: ", masLarga;
FinAlgoritmo
```

```entrada
28
31
32
33
29
31
30
31
32
31
35
27
31
32
```

```salida
Olas: 2
La más larga: 4
```

Fíjate en el `Si` que está **después** del bucle: cierra la última racha, la que todavía no se cortó cuando se terminaron los datos.

## Probar {#probar fase=4}

| Caso | A mano | El programa |
|---|---|---|
| El de la consigna | 2 olas, la más larga de 4 | Olas: 2 ⏎ La más larga: 4 |
| Los tres últimos días por encima de 30 | 1 ola de 3 | Olas: 1 ⏎ La más larga: 3 |
| Ningún día por encima de 30 | 0 olas | Olas: 0 ⏎ La más larga: 0 |
| Una racha de exactamente 3 | 1 ola de 3 | Olas: 1 ⏎ La más larga: 3 |

## Mejorar {#mejorar fase=5}

En una frase: «El programa sigue la racha de días calurosos, cuenta las que llegan a 3 y recuerda la más larga».

¿Y si una ola pasara a ser de 4 o más días? Hay que cambiar el 3 en dos lugares. Si el 3 estuviera en una caja con nombre, como `diasDeOla`, se cambiaría en uno solo.

## Lo que aprendiste {#aprendiste}

::: resumen
- {esquema} Recorrer, contar, acumular, buscar, filtrar y transformar son esquemas que se combinan para resolver problemas con colecciones.
- {seguidor} Un seguidor recuerda el dato anterior o una racha para compararla con el actual.
:::

## Practica {#practica}

::: practica
- imperativo.esquemas.que-esquema
- imperativo.esquemas.primer-siete
- imperativo.esquemas.olas-romper
- imperativo.esquemas.primer-desaprobado
- imperativo.esquemas.sin-lluvia
- imperativo.esquemas.buscar-pruebas
:::

::: profundizar titulo="Tropiezos frecuentes"
- **Olvidar la última racha.** Es el error más común. El ejercicio de romper lo pone en evidencia con una ola al final.
- **Reiniciar la racha en el lugar equivocado.** Ponerla en 0 antes de revisar si fue una ola la pierde.
- **Querer un esquema nuevo para cada problema.** Nombra los esquemas que combina un problema antes de escribir.
:::

::: siguiente
Un tablero de tres en raya no es una fila de datos: tiene filas y columnas. ¿Cómo se guarda y se recorre?
:::
