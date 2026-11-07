---
id: expresiones.concatenacion
numero: "4.6"
tipo: concepto
titulo: Concatenación
anclas: [LANG.OPS.CONCATENATION#R1]
fichas: [help.builtin-concatenate]
diagnosticos: [cannotConcatenateNumberWithText]
terminos: [concatenación]
---

::: frase
`+` entre textos los pega uno detrás de otro: `"Hola, " + "Ana"` es `"Hola, Ana"`.
:::

## Cómo funciona {#funciona}

El mismo signo `+` que suma números **concatena** textos. Acepta cualquier combinación de `Cadena` y `Caracter`, y el resultado es siempre una `Cadena`: incluso dos caracteres sueltos forman una cadena de longitud 2.

```figura id=concatenar
pie: Cada pieza se copia a continuación de la anterior, de izquierda a derecha, y forma una cadena nueva.
```

```programa id=saludo titulo="Pegar textos" ejecutar
Algoritmo Saludo
  Definir nombre Como Cadena <- "Ana";
  Escribir "Hola, " + nombre + '!';
  Escribir 'a' + 'b', " ", Longitud('a' + 'b');
FinAlgoritmo
```

```salida
Hola, Ana!
ab 2
```

La concatenación **no convierte** números ni lógicos a texto. Para meter un número en un mensaje hay dos caminos: convertirlo con `ConvertirATexto`, o separar las piezas con comas en `Escribir`.

```programa id=con-numero titulo="Un número dentro de un texto" ejecutar
Algoritmo ConNumero
  Definir edad Como Entero <- 12;
  Escribir "Tienes " + ConvertirATexto(edad) + " años";
  Escribir "Tienes ", edad, " años";
FinAlgoritmo
```

```salida
Tienes 12 años
Tienes 12 años
```

::: errores
```programa id=texto-mas-numero titulo="Sumar un texto y un número" ejecutar
Algoritmo TextoMasNumero
  Escribir "Edad: " + 5;
FinAlgoritmo
```

```diagnosticos
cannotConcatenateNumberWithText
```
:::

::: resumen
- `+` entre textos o caracteres los concatena y da una `Cadena`.
- No convierte números: usa `ConvertirATexto` o comas en `Escribir`.
- Tiene la misma precedencia que la suma.
:::

::: vease
- [Texto](#biblioteca.texto)
- [Conversión](#biblioteca.conversion)
- [Precedencia y asociatividad](#expresiones.precedencia)
:::
