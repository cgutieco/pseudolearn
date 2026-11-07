---
id: subprogramas.parametros
numero: "7.2"
tipo: concepto
titulo: Parámetros
anclas: [LANG.SUBPROGRAM.PARAMETERS#R1]
fichas: [help.parameter-mode, help.argument-list]
diagnosticos: [duplicateParameterName]
terminos: [parámetro, argumento, paso por valor]
---

::: frase
Los parámetros son las variables de entrada de un subprograma: reciben, en cada llamada, una **copia** de los valores que se le pasan.
:::

## Cómo funciona {#funciona}

Cada parámetro lleva un nombre y un tipo obligatorio. En la llamada, los **argumentos** se asignan a los parámetros en orden. Sin ninguna marca, el paso es **por valor**: el parámetro es una variable nueva con una copia del argumento, y cambiarla no afecta a quien llamó.

```programa id=copia-parametro titulo="El parámetro es una copia" ejecutar
SubProceso Incrementar(n Como Entero Por Referencia)
  n <- n + 1;
FinSubProceso

SubProceso Copia(n Como Entero)
  n <- n + 1;
FinSubProceso

Proceso Principal
  Definir x Como Entero <- 5;
  Copia(x);
  Escribir x;
  Incrementar(x);
  Escribir x;
FinProceso
```

```salida
5
6
```

```figura id=paso-valor
pie: Por valor, el subprograma recibe su propia caja con una copia. Por referencia, su parámetro es otro nombre para la caja de quien llama.
paso: `Copia(x)` crea una caja nueva `n` con un 5 copiado. Cambiarla deja `x` como estaba.
paso: `Incrementar(x)` no crea caja: `n` señala a la caja de `x`, y sumarle 1 cambia `x`.
```

| Marca | Qué recibe el subprograma |
|---|---|
| ninguna o `Por Valor` | una copia del valor |
| `Por Referencia` | la variable misma |

La marca va **después del tipo** y afecta solo a ese parámetro. Los arreglos se pasan siempre por referencia: marcarlos `Por Valor` es un error.

::: resumen
- Cada parámetro tiene nombre y tipo.
- Por defecto se pasa una copia: cambiarla no afecta fuera.
- `Por Referencia` comparte la variable de quien llama.
- Los arreglos van siempre por referencia.
:::

::: vease
- [Parámetros por referencia](#subprogramas.referencia)
- [Llamadas](#subprogramas.llamada)
:::
