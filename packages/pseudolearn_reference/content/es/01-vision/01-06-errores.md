---
id: vision.errores
numero: "1.6"
tipo: concepto
titulo: Errores, advertencias y fallos
anclas: [DIAG.CLASSES#R1, DIAG.SEVERITY.POLICY#R1, DIAG.MODEL#R1, LANG.TYPES.CHECKING-LEVELS#R1]
diagnosticos: [missingStatementTerminator, undeclaredVariable, variableDeclaredNeverUsed, arrayIndexOutOfRange]
terminos: [diagnóstico, error, advertencia, fallo]
---

::: frase
El motor avisa con diagnósticos: los errores impiden ejecutar, las advertencias no, y los fallos ocurren mientras el programa se ejecuta.
:::

## Cómo funciona {#funciona}

Cada aviso del motor es un **diagnóstico**. Todos tienen la misma forma: un código estable, una severidad, la posición exacta en el texto y un mensaje en el idioma de la interfaz. El código no cambia con el idioma; por eso puedes buscarlo en el catálogo.

Los diagnósticos se clasifican por **cuándo** se descubren:

| Clase | Cuándo aparece | Ejemplo |
|---|---|---|
| léxica | al partir el texto en piezas | un carácter que no existe en el lenguaje |
| sintáctica | al agrupar las piezas | falta un punto y coma |
| semántica | al comprobar nombres y tipos | una variable que nadie definió |
| de ejecución | mientras el programa se ejecuta | un índice fuera del arreglo |

Y por **severidad**: un **error** impide ejecutar el programa; una **advertencia** señala algo sospechoso pero deja ejecutar; una **información** solo informa.

```figura id=clases-diagnostico
pie: Las clases de diagnóstico a lo largo del viaje del programa. Las tres primeras se descubren antes de ejecutar.
```

Un error sintáctico:

```programa id=sin-punto titulo="Falta el punto y coma" ejecutar
Proceso SinPunto
  Escribir "hola"
FinProceso
```

```diagnosticos
missingStatementTerminator
```

Un error semántico:

```programa id=sin-definir titulo="Una variable que no existe" ejecutar
Proceso SinDefinir
  Escribir total;
FinProceso
```

```diagnosticos
undeclaredVariable
```

Una advertencia: el programa se ejecuta igualmente.

```programa id=sin-uso titulo="Una variable que sobra" ejecutar
Proceso SinUso
  Definir usada Como Entero <- 3;
  Definir sobrante Como Entero;
  Escribir usada;
FinProceso
```

```salida
3
```

```diagnosticos
variableDeclaredNeverUsed
```

Un fallo de ejecución: el análisis no podía saber que el índice 3 no existe.

```programa id=fuera titulo="Un índice fuera del arreglo" ejecutar termina=failed
Proceso Fuera
  Dimension notas[3] Como Entero;
  notas[0] <- 7;
  notas[1] <- 9;
  notas[2] <- 6;
  Escribir notas[3];
FinProceso
```

```diagnosticos
arrayIndexOutOfRange
```

## Sin cascadas {#cascadas}

Si el análisis léxico o sintáctico encuentra un error, las comprobaciones semánticas no se ejecutan sobre el árbol roto. Así un solo descuido no se multiplica en decenas de mensajes que no explican nada.

::: resumen
- Un diagnóstico tiene código, severidad, posición y mensaje traducido.
- Clases: léxica, sintáctica, semántica y de ejecución.
- Los errores impiden ejecutar; las advertencias no.
- Los fallos de ejecución dependen de valores concretos.
:::

::: vease
- [Modelo de diagnóstico](#diagnosticos.modelo)
- [Catálogo de diagnósticos](#apendice.diagnosticos)
- [Cómo termina un programa](#vision.terminacion)
:::
