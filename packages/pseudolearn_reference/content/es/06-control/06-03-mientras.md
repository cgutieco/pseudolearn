---
id: control.mientras
numero: "6.3"
tipo: construccion
titulo: "El bucle `Mientras`"
anclas: [LANG.CONTROL.WHILE#R1]
fichas: [help.while]
diagnosticos: [nonBooleanCondition, unclosedWhileStatement, expectedDoKeyword]
terminos: [bucle, iteración]
---

::: frase
`Mientras` repite un bloque **mientras** una condición sea verdadera, y la mira antes de cada vuelta, incluida la primera.
:::

## Cómo se escribe {#escribe}

```forma
Mientras «condición» Hacer
  «instrucciones»
FinMientras
```

```railes produccion=whileLoop
```

::: partes
- `Mientras` abre el bucle.
- «condición» es una expresión `Logico`.
- `Hacer` separa la condición del cuerpo. Es obligatoria.
- «instrucciones» es el cuerpo. Puede estar vacío.
- `FinMientras` cierra el bucle.
:::

## Cómo funciona {#funciona}

Cada **iteración** empieza comprobando la condición. Si es `Verdadero`, se ejecuta el cuerpo y se vuelve arriba. Si es `Falso`, el bucle termina y el programa sigue después de `FinMientras`. Si la condición es falsa desde el principio, el cuerpo no se ejecuta **ninguna** vez.

```programa id=cuenta-atras titulo="Cuenta atrás" ejecutar
Algoritmo CuentaAtras
  Definir n Como Entero <- 3;
  Mientras n > 0 Hacer
    Escribir n;
    n <- n - 1;
  FinMientras
  Escribir "¡Despegue!";
FinAlgoritmo
```

```salida
3
2
1
¡Despegue!
```

```figura id=mientras-ciclo
pie: La pregunta va antes del cuerpo. Con `n` en 0 la respuesta es `Falso` y se sale por la derecha.
paso: `n` vale 3: la condición es verdadera y se ejecuta el cuerpo.
paso: El cuerpo escribe 3 y deja `n` en 2. Se vuelve a la pregunta.
paso: Tras tres vueltas `n` vale 0: la condición es falsa y el bucle termina.
```

Algo dentro del cuerpo tiene que acercar la condición a `Falso`. Si nada la cambia, el bucle no termina nunca. Según dónde se ejecute, lo corta un [límite](#motor.limites) de pasos o de tiempo del anfitrión, o sigue hasta que lo detengas.

::: errores
```programa id=mientras-numero titulo="Una condición numérica" ejecutar
Algoritmo MientrasNumero
  Definir n Como Entero <- 3;
  Mientras n Hacer
    n <- n - 1;
  FinMientras
FinAlgoritmo
```

```diagnosticos
nonBooleanCondition
```
:::

::: por-dentro
Un `Mientras` son tres bloques: la cabecera con la condición, el cuerpo que salta de vuelta a la cabecera y la salida. Fíjate en el salto hacia atrás al final del cuerpo.

```ri programa=cuenta-atras
```
:::

::: docentes
El error típico es olvidar actualizar la variable de la condición. Pide predecir qué pasa si se borra `n <- n - 1;`, y deja que lo comprueben en la app, que corta la ejecución al alcanzar su límite.
:::

::: resumen
- `Mientras` comprueba antes de cada vuelta.
- Puede ejecutar el cuerpo cero veces.
- El cuerpo debe acercar la condición a `Falso`.
:::

::: vease
- [Repetir](#control.repetir)
- [Para](#control.para)
- [Salir de un bucle](#control.salir)
:::
