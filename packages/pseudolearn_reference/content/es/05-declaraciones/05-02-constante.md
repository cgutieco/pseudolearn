---
id: declaraciones.constante
numero: "5.2"
tipo: construccion
titulo: "Valores fijos con `Constante`"
anclas: [LANG.DECL.CONSTANT#R1, LANG.DECL.CONSTANT#R2, LANG.DECL.CONSTANT#R3, LANG.DECL.CONSTANT#R4]
fichas: [help.constant]
diagnosticos: [constantReassigned, constantNotEvaluable, constantDivisionByZero, constantArithmeticOverflow, circularConstantDefinition, constantBudgetExceeded, expectedConstantInitializer, expectedConstantName]
terminos: [constante]
---

::: frase
Una `Constante` da nombre a un valor que nunca cambia, y el motor lo calcula antes de ejecutar.
:::

## Cómo se escribe {#escribe}

```forma
Constante «NOMBRE» Como «tipo» <- «valor»;
```

::: partes
- `Constante` abre la declaración. Puede ir fuera de todo algoritmo, en el módulo, o dentro de un cuerpo.
- «NOMBRE» es un identificador. Escribirlo en mayúsculas es una costumbre, no una regla.
- «tipo» es `Entero`, `Real`, `Logico`, `Caracter`, `Cadena` o un enumerado.
- `<-` y el «valor» son obligatorios.
:::

## Cómo funciona {#funciona}

El motor calcula el valor de cada constante **al analizar el programa**. Usarla equivale a escribir su valor: no ocupa una caja en la memoria y no se puede cambiar.

```programa id=factura titulo="Constantes de una factura" ejecutar
Constante IVA Como Real <- 0.21;
Constante SEMANA Como Entero <- 7 * 24;
Algoritmo Factura
  Constante SALUDO Como Cadena <- "Total: ";
  Definir base Como Real <- 100.0;
  Escribir SALUDO, base * (1 + IVA), " (", SEMANA, " horas)";
FinAlgoritmo
```

```salida
Total: 121.0 (168 horas)
```

```figura id=constante-sustituye
pie: El motor sustituye cada constante por su valor antes de ejecutar. En memoria solo quedan las variables.
paso: El programa tal como se escribe.
paso: Al analizar, `SEMANA` se calcula una vez: `7 * 24` = 168.
paso: Cada uso de la constante se convierte en su valor. La variable `base` sí ocupa memoria.
```

El valor se calcula con un subconjunto de las expresiones: literales, otras constantes, miembros de enumerado, paréntesis, signos, `NO`, `+ - * / div mod`, comparaciones, `Y`, `O` y concatenación. No admite variables, llamadas a funciones ni potencia.

::: limite
- El cálculo entero se comprueba en 64 bits: desbordar es `constantArithmeticOverflow` y dividir entre cero es `constantDivisionByZero`, ambos antes de ejecutar.
- El cálculo tiene un presupuesto de 10000 pasos y de 65536 bytes por texto. Un texto de exactamente 65536 bytes cabe.
- Una constante que depende de sí misma, directa o indirectamente, es `circularConstantDefinition`.
:::

::: errores
Una constante no admite asignación:

```programa id=cambiar-constante titulo="Intentar cambiar una constante" ejecutar
Constante LIMITE Como Entero <- 10;
Algoritmo Cambiar
  LIMITE <- 20;
  Escribir LIMITE;
FinAlgoritmo
```

```diagnosticos
constantReassigned
```

Y su valor tiene que poder calcularse sin ejecutar nada:

```programa id=constante-potencia titulo="Una potencia en una constante" ejecutar
Constante POT Como Entero <- 2 ^ 3;
Algoritmo Potencia
  Escribir POT;
FinAlgoritmo
```

```diagnosticos
constantNotEvaluable
```
:::

::: por-dentro
En la representación intermedia no hay rastro de `SEMANA` ni de `IVA`: en su lugar aparecen directamente 168 y 0.21 como constantes de la instrucción.

```ri programa=factura
```
:::

::: resumen
- `Constante` nombra un valor fijo con inicializador obligatorio.
- Se calcula al analizar, con un subconjunto de operaciones.
- No ocupa memoria y no se puede asignar.
- Puede declararse en el módulo o dentro de un cuerpo.
:::

::: vease
- [Declarar variables con Definir](#declaraciones.definir)
- [Módulos](#programas.modulos)
- [Enumerados](#tipos.enumerados)
:::
