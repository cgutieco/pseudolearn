---
id: biblioteca.consola
numero: "12.6"
tipo: construccion
titulo: "`Leer` y `Escribir`"
anclas: [LANG.IO.INPUT#R1, LANG.IO.OUTPUT#R1]
fichas: [help.input, help.output]
diagnosticos: [readValueTypeMismatch, invalidReadTarget, unexpectedModifierPosition]
terminos: [entrada, salida]
---

::: frase
`Escribir` muestra valores en la salida y `Leer` pide valores a quien usa el programa: son la forma más sencilla de hablar con el exterior.
:::

## Cómo se escribe {#escribe}

```forma
Escribir «expresión», «expresión» ⟦Sin Saltar⟧;
Leer «destino», «destino»;
```

```railes produccion=output
```

```railes produccion=input
```

::: partes
- `Escribir` evalúa cero o más expresiones separadas por comas, de izquierda a derecha.
- `Sin Saltar` es opcional y va al final: evita el salto de línea.
- `Leer` pide un valor para cada [designador](#declaraciones.designadores), uno a uno y en orden.
:::

## Cómo funciona {#funciona}

`Escribir` pega las representaciones de sus valores **sin separador** y termina con un salto de línea, salvo con `Sin Saltar`. Un `Escribir` vacío escribe una línea en blanco.

`Leer` convierte cada entrada según el tipo del destino. Si la entrada no encaja, avisa con `readValueTypeMismatch` y **vuelve a pedir** el mismo valor sin tocar la variable. Desde que `Leer` da valor a una variable, esa variable tiene valor a efectos de la [comprobación de inicialización](#declaraciones.sin-valor).

```programa id=suma-leida titulo="Pedir dos números" ejecutar
Algoritmo Suma
  Definir a, b Como Entero;
  Escribir "Primer número: " Sin Saltar;
  Leer a;
  Escribir "Segundo número: " Sin Saltar;
  Leer b;
  Escribir a, " + ", b, " = ", a + b;
  Escribir;
  Escribir "fin";
FinAlgoritmo
```

```entrada
3
4
```

```salida
Primer número: Segundo número: 3 + 4 = 7

fin
```

```figura id=leer-escribir
pie: `Leer` toma valores de la entrada, uno por destino. `Escribir` pone texto en la salida, en una línea salvo con `Sin Saltar`.
```

Si no hay entrada disponible, la ejecución espera. En la app aparece un campo para escribir; en la terminal se lee la entrada estándar.

::: errores
```programa id=sin-saltar-mal titulo="Sin Saltar en medio" ejecutar
Algoritmo Mal
  Escribir Sin Saltar "a";
FinAlgoritmo
```

```diagnosticos
unexpectedModifierPosition
```
:::

::: por-dentro
`Escribir` se traduce en una instrucción de salida por expresión y una de salto final. `Leer` es una instrucción que suspende la ejecución hasta que el anfitrión entrega un valor.

```ri programa=suma-leida
```
:::

::: resumen
- `Escribir` une valores sin separador y salta de línea, salvo `Sin Saltar`.
- `Leer` pide un valor por destino y lo convierte al tipo.
- Una entrada inválida se vuelve a pedir con una advertencia.
:::

::: vease
- [Severidad](#diagnosticos.severidad)
- [Concatenación](#expresiones.concatenacion)
- [Efectos y capacidades](#tareas.efectos)
:::
