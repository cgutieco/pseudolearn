---
id: lexico.palabras-reservadas
numero: "2.5"
tipo: concepto
titulo: Palabras reservadas
anclas: [LANG.LEXICAL.KEYWORD#R1, LANG.PROFILE.VOCABULARY#R1, LANG.PROFILE.VOCABULARY#R2]
diagnosticos: [reservedLexemeUsedAsName]
terminos: [palabra reservada, alias, palabra contextual]
---

::: frase
Las palabras reservadas son las del propio lenguaje, como `Si` o `Mientras`; no puedes usarlas como nombre de una variable.
:::

## Cómo funciona {#funciona}

Cada perfil tiene su lista de **palabras reservadas**: las que forman las instrucciones (`Si`, `Mientras`, `Escribir`), los tipos (`Entero`, `Cadena`), los valores (`Verdadero`, `Falso`) y algunos operadores escritos con letras (`Y`, `O`, `NO`, `div`, `mod`). Algunas son de varias palabras, como `Con Paso`, `Hasta Que` o `Por Referencia`.

```figura id=familias-palabras
pie: Las palabras reservadas se agrupan por familia. El color de cada familia es el mismo que usa el editor.
```

Varias palabras tienen **alias**: otras grafías que el motor reconoce y trata igual. `Proceso` es alias de `Algoritmo` y `Mostrar` lo es de `Escribir`. El motor acepta los alias, pero al formatear o traducir los convierte a la forma principal.

```programa id=alias titulo="Alias aceptados" ejecutar
Proceso Alias
  Definir hecho Como Logico <- Verdadero;
  Mostrar "El alias funciona";
  Si NO hecho O hecho Entonces
    Escribir 7 mod 3;
  FinSi
FinProceso
```

```salida
El alias funciona
1
```

## Palabras contextuales {#contextuales}

Algunas palabras solo son especiales en un sitio concreto. Por ejemplo, `Cada` solo significa algo dentro de `Para Cada`, y `Agregar` solo como método de un vector. Fuera de esa posición son nombres corrientes. Se llaman **palabras contextuales** y no reservan el nombre.

::: errores
Usar una palabra reservada como nombre produce un error que dice cuál es:

```programa id=reservada titulo="Una variable llamada como una palabra reservada" ejecutar
Algoritmo Reservada
  Definir Si Como Entero <- 1;
FinAlgoritmo
```

```diagnosticos
reservedLexemeUsedAsName
```
:::

::: resumen
- Las palabras reservadas forman el lenguaje y no sirven como nombres.
- En español no distinguen mayúsculas ni tildes.
- Los alias se aceptan y se normalizan a la forma principal.
- Las palabras contextuales solo son especiales en su posición.
:::

::: vease
- [Palabras reservadas en español e inglés](#apendice.palabras)
- [Identificadores](#lexico.identificadores)
:::
