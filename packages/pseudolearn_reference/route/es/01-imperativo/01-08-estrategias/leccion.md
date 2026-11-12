---
id: imperativo.estrategias
numero: "1.8"
tipo: leccion
titulo: Más de una manera
duracion: 35
problema_breve: Adivinar un número en pocas preguntas
necesita: [imperativo.cuadriculas]
introduce: [estrategia, fuerza-bruta, busqueda-binaria, costo, ordenamiento-por-seleccion]
usa: [arreglo, indice, bucle, contador, invariante, caso-borde, salida-anticipada, esquema]
---

::: frase
Dos programas correctos pueden tardar muy distinto; contar sus pasos dice cuál conviene.
:::

## El problema {#problema}

::: problema
Juegan a adivinar: alguien piensa un número del **1 al 100**; tú dices un número y te responden «mayor», «menor» o «acertaste».

**¿Qué forma de jugar adivina en la menor cantidad de intentos, aun en el peor caso?**
:::

## Inténtalo {#intentalo}

::: intento
Juega en parejas con papel. Prueben distintas formas de elegir el próximo número y anoten cuántos intentos hicieron falta.
:::

::: respuesta
Conviene empezar por 50 y quedarse siempre con la mitad que puede tener el número: nunca hacen falta más de **7** intentos. Probar uno por uno, del 1 en adelante, puede necesitar **100**.
:::

## Entender {#entender fase=1}

::: ficha
- entra: el número secreto, para que el programa simule el juego.
- sale: cuántos intentos hicieron falta.
- relacion: cada respuesta deja una parte de los números posibles; se cuenta hasta acertar.
- ejemplo: secreto 37 → se dice 50, 25 y 37: 3 intentos.
- ejemplo: secreto 100 → 7 intentos.
- ejemplo: secreto 1 → 6 intentos.
:::

1 y 100 son los bordes: son los que más lejos están de la primera pregunta.

## Planear {#planear fase=2}

Una [[def:estrategia|estrategia]] es una forma de resolver un problema. Hay más de una para este juego:

- Probar del 1 en adelante, uno por uno, es [[def:fuerza-bruta|fuerza bruta]]: prueba todas las posibilidades hasta dar con la respuesta.
- Decir siempre el número del medio de lo que queda y descartar la mitad que no puede tenerlo es una [[def:busqueda-binaria|búsqueda binaria]].

```figura id=ruta-busqueda-binaria
pie: En cada paso se mira el del medio y se tacha la mitad que no puede contener el buscado.
paso: Se mira el del medio. El buscado es mayor: se tacha la mitad izquierda.
paso: Se mira el del medio de lo que queda. El buscado es menor: se tacha la parte derecha.
paso: Quedan pocos. Se mira el del medio otra vez.
paso: Lo encuentra. Con 15 números, nunca hacen falta más de 4 pasos.
```

El plan de la búsqueda binaria:

1. Lo posible va de `bajo` a `alto`: al principio, de 1 a 100.
2. Di el del medio.
3. Si el secreto es mayor, lo posible empieza después del medio; si es menor, termina antes.
4. Repite hasta acertar.

## La herramienta nueva {#herramienta}

No hay construcción nueva. Lo nuevo es medir. El [[def:costo|costo]] de un algoritmo se estima contando sus pasos en el peor caso: un contador más dentro del bucle alcanza.

```figura id=ruta-pasos-crecen
pie: Con diez veces más datos, la fuerza bruta tarda diez veces más; la búsqueda binaria, apenas unos pasos más.
```

La búsqueda binaria exige que los datos estén ordenados. Si no lo están, hay que ordenarlos primero. El [[def:ordenamiento-por-seleccion|ordenamiento por selección]] lleva al frente, una y otra vez, el menor de los que faltan:

```figura id=ruta-seleccion
pie: Cada vuelta del bucle de afuera elige el menor de la parte desordenada y lo lleva al frente.
paso: Los cinco números, desordenados.
paso: El menor de todos, el 1, pasa al frente.
paso: El menor de los que faltan, el 3, ya está en el segundo lugar.
paso: Después el 5 al tercero.
paso: Y el 8 al cuarto. El último ya queda en su lugar.
```

## Escribir {#escribir fase=3}

```programa id=adivinar titulo="Adivinar por mitades" ejecutar
Algoritmo Adivinar
  Definir secreto Como Entero;
  Leer secreto;
  Definir bajo Como Entero <- 1;
  Definir alto Como Entero <- 100;
  Definir medio Como Entero;
  Definir intentos Como Entero <- 0;
  Repetir
    medio <- (bajo + alto) div 2;
    intentos <- intentos + 1;
    Si medio < secreto Entonces
      bajo <- medio + 1;
    Sino
      Si medio > secreto Entonces
        alto <- medio - 1;
      FinSi
    FinSi
  Hasta Que medio = secreto
  Escribir "Intentos: ", intentos;
FinAlgoritmo
```

```entrada
37
```

```salida
Intentos: 3
```

La misma idea sirve para buscar en un arreglo ordenado. Este programa busca un número entre quince y cuenta los pasos:

```programa id=buscar-ordenado titulo="Búsqueda binaria en un arreglo" ejecutar
Algoritmo BuscarOrdenado
  Dimension v[15] Como Entero;
  Para i <- 0 Hasta 14 Hacer
    v[i] <- i * 3 + 2;
  FinPara
  Definir buscado Como Entero;
  Leer buscado;
  Definir bajo Como Entero <- 0;
  Definir alto Como Entero <- 14;
  Definir posicion Como Entero <- -1;
  Definir pasos Como Entero <- 0;
  Mientras bajo <= alto Y posicion = -1 Hacer
    Definir medio Como Entero <- (bajo + alto) div 2;
    pasos <- pasos + 1;
    Si v[medio] = buscado Entonces
      posicion <- medio;
    Sino
      Si v[medio] < buscado Entonces
        bajo <- medio + 1;
      Sino
        alto <- medio - 1;
      FinSi
    FinSi
  FinMientras
  Escribir "Posición: ", posicion, " en ", pasos, " pasos";
FinAlgoritmo
```

```entrada
26
```

```salida
Posición: 8 en 4 pasos
```

Y así se ordenan cinco números con selección:

```programa id=seleccion titulo="Ordenar por selección" ejecutar
Algoritmo Seleccion
  Dimension v[5] Como Entero;
  Para i <- 0 Hasta 4 Hacer
    Leer v[i];
  FinPara
  Para i <- 0 Hasta 3 Hacer
    Definir menor Como Entero <- i;
    Para j <- i + 1 Hasta 4 Hacer
      Si v[j] < v[menor] Entonces
        menor <- j;
      FinSi
    FinPara
    Definir guardado Como Entero <- v[i];
    v[i] <- v[menor];
    v[menor] <- guardado;
  FinPara
  Para Cada n En v Hacer
    Escribir n;
  FinPara
FinAlgoritmo
```

```entrada
5
3
8
1
9
```

```salida
1
3
5
8
9
```

## Probar {#probar fase=4}

| Secreto | A mano | El programa |
|---|---|---|
| 1 | 50, 25, 12, 6, 3, 1 | Intentos: 6 |
| 100 | 50, 75, 88, 94, 97, 99, 100 | Intentos: 7 |
| 50 | 50 | Intentos: 1 |

El invariante de la búsqueda binaria es la frase que la hace correcta: «si el número está, está entre `bajo` y `alto`». Cada vuelta achica ese intervalo sin dejar afuera al secreto.

## Mejorar {#mejorar fase=5}

En una frase: «Adivinar por mitades nunca necesita más de 7 intentos para 100 números, porque cada respuesta descarta la mitad».

Vuelve al primo de [la lección 1.4](ruta:imperativo.contado). Si un número tiene un divisor mayor que su raíz, también tiene uno menor. Alcanza con probar mientras `d * d <= n`:

```programa id=primo-rapido titulo="El primo, con menos divisiones" ejecutar
Algoritmo PrimoRapido
  Definir n Como Entero;
  Leer n;
  Definir esPrimo Como Logico <- n >= 2;
  Definir divisiones Como Entero <- 0;
  Definir d Como Entero <- 2;
  Mientras d * d <= n Y esPrimo Hacer
    divisiones <- divisiones + 1;
    Si n mod d = 0 Entonces
      esPrimo <- Falso;
    FinSi
    d <- d + 1;
  FinMientras
  Escribir esPrimo, " con ", divisiones, " divisiones";
FinAlgoritmo
```

```entrada
97
```

```salida
Verdadero con 8 divisiones
```

Con 97, de 95 divisiones a 8.

## Lo que aprendiste {#aprendiste}

::: resumen
- {estrategia,fuerza-bruta} Una estrategia es una forma de resolver un problema; la fuerza bruta prueba todas las posibilidades.
- {busqueda-binaria} La búsqueda binaria descarta la mitad en cada paso, pero necesita datos ordenados.
- {costo} El costo de un algoritmo se estima contando sus pasos en el peor caso.
- {ordenamiento-por-seleccion} El ordenamiento por selección lleva al frente, una y otra vez, el menor de los que faltan.
:::

## Practica {#practica}

::: practica
- imperativo.estrategias.intentos-100
- imperativo.estrategias.guia-telefonica
- imperativo.estrategias.binaria
- imperativo.estrategias.binaria-romper
- imperativo.estrategias.ordenar-seis
- imperativo.estrategias.seleccion-tabla
:::

::: profundizar titulo="Tropiezos frecuentes"
- **«El más rápido es el que tiene menos líneas».** La búsqueda binaria es más larga que la de uno por uno y mucho más rápida. Cuenta los pasos con 1000 datos.
- **Búsqueda binaria sobre datos sin ordenar.** Con un arreglo desordenado, la búsqueda puede no encontrar un número que sí está.
- **El medio que no avanza.** Cuando al descartar se deja el medio dentro del intervalo, el bucle puede no terminar: lo muestra el ejercicio de romper.
:::

::: siguiente
Llegó el momento de juntar todo lo aprendido en la caja del kiosco.
:::
