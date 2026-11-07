---
id: inicio.preguntar
numero: "0.3"
tipo: leccion
titulo: Preguntar antes de calcular
duracion: 20
problema_breve: Dividir la cuenta del comedor
necesita: [inicio.nombres]
introduce: [entrada, leer-dato, ficha-del-problema]
usa: [variable, declarar, ejemplo-a-mano, salida, funcion-ya-hecha]
---

::: frase
Un programa útil no trae sus datos escritos adentro: los pregunta cada vez que se ejecuta.
:::

## El problema {#problema}

::: problema
Un grupo de amigos come en el comedor. A la cuenta le suman un **10 %** de propina y lo dividen en partes iguales. Como nadie lleva monedas, cada uno paga un número **entero** de pesos, redondeando hacia arriba para que alcance. La cuenta y la cantidad de amigos cambian cada vez.

**¿Cuánto paga cada uno?**
:::

## Inténtalo {#intentalo}

::: intento
Calcula a mano cuánto paga cada uno si la cuenta es de 120 pesos y son 4 amigos.
:::

::: respuesta
La propina es la décima parte de 120: 12. El total es 132. Entre 4 amigos, cada uno paga **33**.
:::

## Entender {#entender fase=1}

Esta vez los datos no los conoce quien escribe el programa: los sabe quien lo usa, en el comedor. Antes de pensar en instrucciones conviene anotar el problema en una [[def:ficha-del-problema|ficha del problema]]: qué entra, qué sale, cómo se relacionan y varios ejemplos a mano.

```figura id=ruta-ficha
pie: La ficha se llena antes de escribir. Si no puedes llenar una zona, todavía no entendiste el problema.
```

::: ficha
- entra: la cuenta, en pesos enteros, y la cantidad de amigos.
- sale: lo que paga cada uno.
- relacion: el total es la cuenta más su décima parte; cada uno paga el total entre los amigos, redondeado hacia arriba.
- ejemplo: 120 y 4 → total 132 → 33.
- ejemplo: 100 y 3 → total 110 → 36,67 → 37.
- ejemplo: 100 y 1 → total 110 → 110.
:::

La propina se calcula como `cuenta div 10`, para trabajar siempre con enteros.

::: profundizar titulo="¿Por qué no multiplicar por 1.1?"
Los números con decimales se guardan en la computadora de forma aproximada, y `100 * 1.1` puede dar un valor apenas distinto de 110. Con enteros no pasa. La explicación completa está en [la Especificación](especificacion:tipos.primitivos).
:::

## Planear {#planear fase=2}

1. Pregunta la cuenta.
2. Pregunta cuántos amigos pagan.
3. Calcula el total con la propina.
4. Divide entre los amigos y redondea hacia arriba.
5. Muestra el resultado.

## La herramienta nueva {#herramienta}

La [[def:entrada|entrada]] de un programa son los datos que recibe mientras se ejecuta. `Leer` sirve para [[def:leer-dato|leer un dato]]: detiene el programa hasta que alguien escribe un valor y lo guarda en una caja ya declarada.

```figura-especificacion seccion=biblioteca.consola figura=leer-escribir
```

```programa id=saludo titulo="Un saludo" ejecutar
Algoritmo Saludo
  Definir nombre Como Cadena;
  Escribir "¿Cómo te llamas?";
  Leer nombre;
  Escribir "Hola, ", nombre;
FinAlgoritmo
```

```entrada
Lucía
```

```salida
¿Cómo te llamas?
Hola, Lucía
```

`Leer` no muestra nada: por eso, antes de cada `Leer`, un `Escribir` le dice a la persona qué tiene que escribir.

::: especificacion
- biblioteca.consola
:::

## Escribir {#escribir fase=3}

```programa id=propina titulo="Dividir la cuenta" ejecutar
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
120
4
```

```salida
¿Cuánto es la cuenta?
¿Cuántos amigos pagan?
Cada uno paga: 33
```

## Probar {#probar fase=4}

| Cuenta | Amigos | A mano | El programa |
|---|---|---|---|
| 120 | 4 | 33 | 33 |
| 100 | 3 | 37 | 37 |
| 100 | 1 | 110 | 110 |

Fíjate en el segundo: tres amigos pagan 37 cada uno, 111 en total, un peso más que la cuenta. Redondear hacia arriba siempre deja algo de más, y eso es justo lo que pedía el problema.

## Mejorar {#mejorar fase=5}

En una frase: «El programa pregunta la cuenta y los amigos, y dice cuánto paga cada uno con la propina incluida».

Queda una pregunta incómoda: ¿y si alguien escribe 0 amigos? No lo ejecutes todavía; es el problema de la próxima lección.

## Lo que aprendiste {#aprendiste}

::: resumen
- {entrada,leer-dato} Al leer un dato, el programa se detiene hasta que alguien escribe un valor, y lo guarda en una variable.
- {ficha-del-problema} La ficha del problema anota qué entra, qué sale, la relación entre ambos y ejemplos a mano.
:::

## Practica {#practica}

::: practica
- inicio.preguntar.orden-inverso
- inicio.preguntar.en-2030
- inicio.preguntar.ficha-vuelto
- inicio.preguntar.vuelto
- inicio.preguntar.bici
- inicio.preguntar.que-calcula
:::

::: docentes
- **Un dato del tipo equivocado.** Responder «doce» cuando se espera un `Entero` detiene el programa. Muéstralo una vez y relaciónalo con los tipos de la lección anterior.
- **Olvidar leer el dato.** La caja se declara pero, sin `Leer`, nunca recibe el dato: el programa calcula con su valor inicial.
- **Creer que leer muestra algo.** `Leer` no muestra nada; el mensaje lo escribe el `Escribir` de antes.
:::

::: siguiente
Tu compañero probó la calculadora de propinas con 0 amigos y algo salió muy mal. ¿Qué tipos de fallas existen y cómo se encuentran antes de que las encuentre otro?
:::
