---
id: lexico.fin-de-sentencia
numero: "2.9"
tipo: concepto
titulo: Fin de sentencia
anclas: [LANG.STMT.TERMINATION#R1, LANG.LEXICAL.WHITESPACE#R1]
diagnosticos: [missingStatementTerminator]
terminos: [sentencia, punto y coma]
---

::: frase
Toda sentencia simple termina con punto y coma; las palabras que abren y cierran bloques, como `Si` o `FinMientras`, no lo llevan.
:::

## Cómo funciona {#funciona}

Una **sentencia simple** es una instrucción que no contiene otras: definir, asignar, escribir, leer, llamar o retornar. Cada una termina con `;`, también la última antes de un cierre.

Las **sentencias compuestas** contienen otras dentro: `Si`, `Segun`, `Mientras`, `Repetir`, `Para`. Sus líneas de apertura y cierre no llevan punto y coma; lo llevan las sentencias simples de dentro.

```figura id=punto-y-coma
pie: Punto y coma al final de cada sentencia simple; ninguno en las líneas de apertura y cierre de un bloque.
```

```programa id=terminacion titulo="Dónde va el punto y coma" ejecutar
Proceso Terminacion
  Definir i Como Entero <- 0;
  Mientras i < 2 Hacer
    Escribir "vuelta ", i;
    i <- i + 1;
  FinMientras
  Definir a Como Entero <- 1; Definir b Como Entero <- 2;
  Escribir a + b;
FinProceso
```

```salida
vuelta 0
vuelta 1
3
```

Varias sentencias pueden compartir línea si cada una lleva su punto y coma. Las líneas vacías no producen ninguna sentencia.

::: errores
Un punto y coma olvidado se detecta antes de ejecutar y el mensaje señala dónde debería estar:

```programa id=olvido titulo="Un punto y coma olvidado" ejecutar
Proceso Olvido
  Escribir "uno"
  Escribir "dos";
FinProceso
```

```diagnosticos
missingStatementTerminator
```
:::

::: resumen
- Las sentencias simples terminan con `;`.
- Las aperturas y cierres de bloque no lo llevan.
- Se admiten varias sentencias en una línea.
:::

::: vease
- [Espacios y saltos de línea](#lexico.espacios)
- [Terminación de sentencias](#declaraciones.terminacion)
:::
