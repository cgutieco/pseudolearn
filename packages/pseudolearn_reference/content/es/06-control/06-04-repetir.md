---
id: control.repetir
numero: "6.4"
tipo: construccion
titulo: "El bucle `Repetir`"
anclas: [LANG.CONTROL.REPEAT#R1]
fichas: [help.repeat]
diagnosticos: [nonBooleanCondition, unclosedRepeatStatement]
terminos: [bucle posterior]
---

::: frase
`Repetir` ejecuta el cuerpo primero y pregunta después: se repite **hasta que** la condición sea verdadera, y siempre da al menos una vuelta.
:::

## Cómo se escribe {#escribe}

```forma
Repetir
  «instrucciones»
Hasta Que «condición»
```

::: partes
- `Repetir` abre el bucle.
- «instrucciones» es el cuerpo.
- `Hasta Que` cierra el bloque: no hay `FinRepetir`.
- «condición» es una expresión `Logico`. Cuando es `Verdadero`, el bucle **termina**.
:::

## Cómo funciona {#funciona}

Es el reflejo de [`Mientras`](#control.mientras): la pregunta va al final y su sentido es el contrario. `Mientras` sigue con `Verdadero`; `Repetir` **para** con `Verdadero`.

```programa id=dado titulo="Tirar hasta sacar un 6" ejecutar
Algoritmo Dado
  Definir tirada Como Entero;
  Definir intentos Como Entero <- 0;
  Repetir
    tirada <- Azar(6) + 1;
    intentos <- intentos + 1;
  Hasta Que tirada = 6
  Escribir "Salió el 6 en el intento ", intentos;
FinAlgoritmo
```

```salida
Salió el 6 en el intento 3
```

El resultado es siempre el mismo porque el azar del motor es [determinista](#biblioteca.azar) con la semilla de este libro.

```figura id=repetir-ciclo
pie: En `Repetir` el cuerpo va antes que la pregunta. Aunque la condición ya se cumpla, el cuerpo se ejecuta una vez.
```

Como el cuerpo va primero, lo que asigna sirve para la condición y vale después del bucle: una variable sin valor inicial que el cuerpo asigna queda con valor.

```programa id=una-vez titulo="Una vuelta aunque la condición ya se cumpla" ejecutar
Algoritmo UnaVez
  Definir n Como Entero <- 10;
  Repetir
    Escribir "Vuelta con n = ", n;
    n <- n + 1;
  Hasta Que n > 5
FinAlgoritmo
```

```salida
Vuelta con n = 10
```

::: errores
```programa id=repetir-numero titulo="Hasta Que con un número" ejecutar
Algoritmo RepetirNumero
  Definir n Como Entero <- 3;
  Repetir
    n <- n - 1;
  Hasta Que n
FinAlgoritmo
```

```diagnosticos
nonBooleanCondition
```
:::

::: por-dentro
El cuerpo es el primer bloque y la condición va al final, con un salto hacia atrás cuando todavía es falsa.

```ri programa=una-vez
```
:::

::: nota
Traduce `cuenta-atras` de `Mientras` a `Repetir`. Hay que invertir la condición, y con `n` en 0 desde el principio la versión con `Repetir` escribe un 0 que la otra no escribe.
:::

::: resumen
- `Repetir` ejecuta el cuerpo y después pregunta.
- Termina cuando la condición es `Verdadero`.
- Siempre da al menos una vuelta.
- `Hasta Que` cierra el bloque.
:::

::: vease
- [Mientras](#control.mientras)
- [Variables sin valor](#declaraciones.sin-valor)
- [Azar](#biblioteca.azar)
:::
