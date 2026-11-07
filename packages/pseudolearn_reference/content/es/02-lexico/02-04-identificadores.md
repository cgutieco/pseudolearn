---
id: lexico.identificadores
numero: "2.4"
tipo: concepto
titulo: Identificadores
anclas: [LANG.LEXICAL.IDENTIFIER#R1, LANG.SOURCE.ENCODING#R2]
terminos: [identificador, nombre]
---

::: frase
Un identificador es el nombre que tú eliges para una variable, un subprograma o un tipo: empieza por una letra o un guion bajo y distingue mayúsculas, minúsculas y tildes.
:::

## Cómo funciona {#funciona}

Un **identificador** empieza por una letra (incluidas ñ, las vocales con tilde y ü) o por un guion bajo. Después puede seguir con letras, dígitos o guiones bajos. Un nombre de una sola letra es válido.

```figura id=identificadores
pie: Qué puede ir al principio de un nombre y qué puede ir después. Los números pueden seguir, nunca empezar.
```

Los nombres se comparan **exactamente**: `edad` y `Edad` son dos variables distintas, igual que `ano` y `año`. Las palabras reservadas, en cambio, no distinguen mayúsculas ni tildes en el perfil español: da igual escribirlas en minúsculas, en mayúsculas o sin tilde.

```programa id=nombres titulo="Nombres que parecen iguales" ejecutar
Proceso Nombres
  Definir edad Como Entero <- 1;
  Definir Edad Como Entero <- 2;
  Definir año Como Entero <- 2026;
  Definir _total1 Como Entero <- edad + Edad;
  Escribir edad, " ", Edad, " ", año, " ", _total1;
FinProceso
```

```salida
1 2 2026 3
```

::: limite
Alfabeto inicial: letras ASCII, ñ, Ñ, vocales con tilde, ü, Ü y guion bajo. Alfabeto siguiente: el inicial más los dígitos del 0 al 9. No hay longitud máxima. Un nombre no puede coincidir con una palabra reservada del perfil.
:::

::: docentes
Que `edad` y `Edad` sean variables distintas sorprende a muchas personas, sobre todo porque las palabras reservadas sí ignoran las mayúsculas. Propón buscar el error en un programa que define `Total` y luego escribe `total`.
:::

::: resumen
- Empieza por letra o guion bajo; sigue con letras, dígitos o guiones bajos.
- Se admiten ñ, tildes y ü.
- Los nombres distinguen mayúsculas y tildes; las palabras reservadas españolas no.
:::

::: vease
- [Palabras reservadas](#lexico.palabras-reservadas)
- [Ámbito](#subprogramas.ambito)
:::
