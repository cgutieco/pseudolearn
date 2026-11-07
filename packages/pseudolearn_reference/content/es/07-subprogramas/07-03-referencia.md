---
id: subprogramas.referencia
numero: "7.3"
tipo: concepto
titulo: Parámetros por referencia
anclas: [LANG.SUBPROGRAM.BY-REFERENCE#R1]
fichas: [help.parameter-mode]
diagnosticos: [byReferenceArgumentRequiresDesignator, variableUsedUninitialized]
terminos: [paso por referencia, parámetro de salida, alias]
---

::: frase
Un parámetro `Por Referencia` es otro nombre para la variable de quien llama: lo que el subprograma le hace, se lo hace a ella.
:::

## Cómo funciona {#funciona}

Como el subprograma recibe una variable y no un valor, el argumento tiene que ser un [designador](#declaraciones.designadores) del **tipo exacto**: una variable, una casilla o un atributo. Un literal o una operación no sirven.

El uso típico es devolver **más de un resultado**:

```programa id=dividir-dos titulo="Dos resultados por referencia" ejecutar
SubProceso Dividir(a Como Entero, b Como Entero, cociente Como Entero Por Referencia, resto Como Entero Por Referencia)
  cociente <- a div b;
  resto <- a mod b;
FinSubProceso

Proceso Principal
  Definir c, r Como Entero;
  Dividir(17, 5, c, r);
  Escribir c, " ", r;
FinProceso
```

```salida
3 2
```

```figura id=referencia-salida
pie: `cociente` y `resto` no tienen caja propia: son flechas hacia `c` y `r`. Al asignarles, se llenan las cajas de quien llama.
```

`c` y `r` no tenían valor antes de la llamada, y no es un error: el motor detecta que `Dividir` les da valor **antes de leerlos** en todos sus caminos. Esos parámetros son **de salida**. Si el subprograma leyera el parámetro antes de asignarlo, el argumento tendría que llegar con valor.

::: limite
- El índice de una casilla pasada por referencia se calcula una sola vez, al llamar. Un índice inválido falla antes de entrar al subprograma.
- Dos parámetros pueden referirse a la misma variable; no está prohibido.
- En los subprogramas recursivos ningún parámetro se considera de salida.
:::

::: errores
```programa id=referencia-literal titulo="Un literal por referencia" ejecutar
SubProceso Incrementar(n Como Entero Por Referencia)
  n <- n + 1;
FinSubProceso

Proceso Principal
  Incrementar(5);
FinProceso
```

```diagnosticos
byReferenceArgumentRequiresDesignator
```
:::

::: resumen
- `Por Referencia` comparte la variable de quien llama.
- El argumento debe ser un designador del tipo exacto.
- Sirve para devolver varios resultados.
- Si el subprograma asigna antes de leer, el argumento puede llegar sin valor.
:::

::: vease
- [Parámetros](#subprogramas.parametros)
- [Designadores](#declaraciones.designadores)
- [Variables sin valor](#declaraciones.sin-valor)
:::
