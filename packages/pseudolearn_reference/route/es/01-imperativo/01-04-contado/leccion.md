---
id: imperativo.contado
numero: "1.4"
tipo: leccion
titulo: Repetir un número conocido de veces
duracion: 30
problema_breve: ¿Es primo este número?
necesita: [imperativo.mientras]
introduce: [bucle-contado, bucle-posterior, bandera, mejor-hasta-ahora, salida-anticipada]
usa: [bucle, vuelta, rol-de-variable, contador, acumulador, valor-logico, caso-borde, tabla-por-vuelta]
---

::: frase
Elegir el bucle es responder dos preguntas: ¿sé cuántas vueltas habrá? ¿La primera vuelta va siempre?
:::

## El problema {#problema}

::: problema
El club de matemática quiere un programa que diga si un número es **primo**: un número mayor que 1 que solo se puede dividir exacto entre 1 y entre sí mismo.

**¿Cómo lo averigua el programa?**
:::

## Inténtalo {#intentalo}

::: intento
Decide a mano si son primos 7, 9, 2 y 1.
:::

::: respuesta
7 sí. 9 no: 9 = 3 × 3. 2 sí: es el único primo par. 1 no: por definición, un primo tiene que ser mayor que 1.
:::

## Entender {#entender fase=1}

::: ficha
- entra: un número entero.
- sale: «Es primo» o «No es primo».
- relacion: es primo si es mayor que 1 y ningún número entre 2 y el anterior a él lo divide exacto.
- ejemplo: 7 → es primo.
- ejemplo: 9 → no es primo (lo divide 3).
- ejemplo: 2 → es primo (no hay divisores que probar).
- ejemplo: 1 → no es primo (no es mayor que 1).
:::

2 y 1 son los casos borde: con 2 no hay ningún divisor que probar, y 1 queda afuera por la definición.

## Planear {#planear fase=2}

1. Prueba cada posible divisor, de 2 hasta el número anterior.
2. Si alguno divide exacto, el número no es primo.

Hay que recordar si alguno dividió exacto, y esa caja tiene un rol nuevo:

::: roles
- bandera | ruta-rol-bandera | Empieza en un valor lógico y cambia una sola vez, cuando pasa algo: así recuerda que pasó.
:::

Una [[def:bandera|bandera]] arranca, por ejemplo, en «es primo» y baja la primera vez que aparece un divisor. Después de bajar, ya no vuelve a subir.

Esta vez se sabe de antemano cuántas vueltas habrá: una por cada divisor posible. Eso cambia qué bucle conviene.

## La herramienta nueva {#herramienta}

Un [[def:bucle-contado|bucle contado]] se usa cuando se sabe cuántas vueltas habrá. `Para` lleva su propio contador, que empieza en un valor y avanza hasta otro:

```figura-especificacion seccion=control.para figura=para-contador
```

```programa id=tabla-del-7 titulo="La tabla del 7" ejecutar
Algoritmo TablaDel7
  Para i <- 1 Hasta 3 Hacer
    Escribir 7 * i;
  FinPara
FinAlgoritmo
```

```salida
7
14
21
```

Un [[def:bucle-posterior|bucle que pregunta al final]] da siempre al menos una vuelta: `Repetir` ejecuta su cuerpo y recién después pregunta `Hasta Que`. Sirve, por ejemplo, para pedir un dato hasta que sea válido:

```figura-especificacion seccion=control.repetir figura=repetir-ciclo
```

```programa id=uno-a-diez titulo="Un número del 1 al 10" ejecutar
Algoritmo UnoADiez
  Definir n Como Entero;
  Repetir
    Leer n;
  Hasta Que n >= 1 Y n <= 10
  Escribir "Aceptado: ", n;
FinAlgoritmo
```

```entrada
0
15
7
```

```salida
Aceptado: 7
```

Para elegir entre los tres bucles alcanza con dos preguntas:

```figura id=ruta-elegir-bucle
pie: Primero, ¿sé cuántas vueltas? Después, ¿la primera vuelta va siempre?
```

Con los bucles contados aparece otro rol muy común: el [[def:mejor-hasta-ahora|mejor hasta ahora]], que guarda el valor más alto (o más bajo) visto hasta el momento.

::: roles
- mejor hasta ahora | ruta-rol-mejor-hasta-ahora | Guarda el valor más alto visto; cuando llega uno mayor, lo reemplaza. Empieza con el primer dato.
:::

```programa id=maxima titulo="La máxima de la semana" ejecutar
Algoritmo Maxima
  Definir temperatura Como Entero;
  Definir maxima Como Entero;
  Leer maxima;
  Para i <- 2 Hasta 5 Hacer
    Leer temperatura;
    Si temperatura > maxima Entonces
      maxima <- temperatura;
    FinSi
  FinPara
  Escribir "Máxima: ", maxima;
FinAlgoritmo
```

```entrada
20
23
19
25
22
```

```salida
Máxima: 25
```

Por último, a veces ya se sabe la respuesta antes de terminar las vueltas. Una [[def:salida-anticipada|salida anticipada]] con `Salir` corta el bucle en ese momento:

```figura-especificacion seccion=control.salir figura=salir-corte
```

::: especificacion
- control.para
- control.repetir
- control.salir
:::

## Escribir {#escribir fase=3}

```programa id=primo titulo="¿Es primo?" ejecutar
Algoritmo Primo
  Definir n Como Entero;
  Leer n;
  Definir esPrimo Como Logico <- n >= 2;
  Para d <- 2 Hasta n - 1 Hacer
    Si n mod d = 0 Entonces
      esPrimo <- Falso;
      Salir;
    FinSi
  FinPara
  Si esPrimo Entonces
    Escribir "Es primo";
  Sino
    Escribir "No es primo";
  FinSi
FinAlgoritmo
```

```entrada
9
```

```salida
No es primo
```

La bandera empieza en `n >= 2`: así el 1, el 0 y los negativos ya arrancan como no primos. Con 2, el bucle va de 2 hasta 1 y da cero vueltas: la bandera queda en verdadero, que es correcto.

## Probar {#probar fase=4}

| Número | A mano | El programa | Vueltas |
|---|---|---|---|
| 7 | primo | Es primo | 5 |
| 9 | no | No es primo | 2 |
| 2 | primo | Es primo | 0 |
| 1 | no | No es primo | 0 |

Con 97, que es primo, el bucle prueba los 95 divisores del 2 al 96. Guarda ese número: en la lección de las estrategias lo vas a mejorar.

## Mejorar {#mejorar fase=5}

En una frase: «El programa prueba los divisores uno por uno y se detiene en el primero que divide exacto».

Sin `Salir`, el 9 haría las 7 vueltas aunque desde la segunda ya se sabe la respuesta. Con `Salir` hace 2. Con números grandes, la diferencia se nota.

## Lo que aprendiste {#aprendiste}

::: resumen
- {bucle-contado} Un bucle contado se usa cuando se sabe cuántas vueltas habrá.
- {bucle-posterior} Un bucle que pregunta al final da siempre al menos una vuelta.
- {bandera} Una bandera es un valor lógico que cambia una sola vez para recordar que algo pasó.
- {mejor-hasta-ahora} El mejor hasta ahora guarda el valor más alto (o más bajo) visto; empieza con el primer dato.
- {salida-anticipada} Una salida anticipada corta el bucle cuando ya se conoce la respuesta.
:::

## Practica {#practica}

::: practica
- imperativo.contado.suma-cinco
- imperativo.contado.hay-par
- imperativo.contado.primo-romper
- imperativo.contado.nota-mas-alta
- imperativo.contado.que-bucle
- imperativo.contado.uno-a-diez-resolver
- imperativo.contado.suma-digitos
:::

::: docentes
- **El máximo que empieza en 0.** Funciona con temperaturas de verano y falla con datos negativos. Muéstralo con -3, -5 y -1.
- **La bandera que vuelve a cambiar en cada vuelta.** Asignarle el resultado de la división en cada vuelta deja solo la respuesta del último divisor. La tabla por vuelta lo muestra.
- **Usar un bucle contado cuando no se sabe cuántas vueltas habrá.** Pide que respondan las dos preguntas de la figura antes de escribir.
:::

::: siguiente
Para saber qué días hizo más calor que el promedio, primero hay que conocer el promedio, y para entonces los datos ya pasaron. ¿Dónde se guardan muchos datos?
:::
