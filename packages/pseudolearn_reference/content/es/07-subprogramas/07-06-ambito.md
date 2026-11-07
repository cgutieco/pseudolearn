---
id: subprogramas.ambito
numero: "7.6"
tipo: concepto
titulo: Ámbitos y nombres
anclas: [LANG.SUBPROGRAM.SCOPE#R1]
diagnosticos: [undeclaredVariable, bindingOutsideScope, bindingShadowsOuter]
terminos: [ámbito, vínculo, ocultación]
---

::: frase
Cada nombre existe solo dentro de su **ámbito**: desde donde se declara hasta el cierre del bloque que lo contiene.
:::

## Cómo funciona {#funciona}

PseudoLearn no tiene variables globales. Cada algoritmo, subprograma y método tiene su propio ámbito, y dentro de él cada rama de `Si` o `Segun` y cada cuerpo de bucle abre un ámbito más pequeño.

```figura id=ambitos-anidados
pie: Los ámbitos se anidan como cajas. Desde dentro se ve lo de fuera; desde fuera no se ve lo de dentro.
```

Un subprograma no ve las variables del algoritmo que lo llama. Si las necesita, hay que pasárselas como [parámetros](#subprogramas.parametros):

```programa id=sin-globales titulo="Un subprograma no ve las variables de otro" ejecutar
SubProceso VerTotal()
  Escribir total;
FinSubProceso

Proceso Principal
  Definir total Como Entero <- 10;
  VerTotal();
FinProceso
```

```diagnosticos
undeclaredVariable
```

Una variable declarada dentro de un bloque deja de existir al cerrarlo:

```programa id=fuera-ambito titulo="Usar una variable fuera de su bloque" ejecutar
Proceso FueraAmbito
  Definir n Como Entero <- 3;
  Si n > 0 Entonces
    Definir doble Como Entero <- n * 2;
    Escribir doble;
  FinSi
  Escribir doble;
FinProceso
```

```diagnosticos
bindingOutsideScope
```

Declarar dentro un nombre que ya existe fuera es válido, pero **oculta** el de fuera mientras dura el bloque, y produce una advertencia:

```programa id=ocultar titulo="Un nombre que oculta a otro" ejecutar
Proceso Ambitos
  Definir x Como Entero <- 1;
  Si x > 0 Entonces
    Definir x Como Entero <- 2;
    Escribir "dentro: ", x;
  FinSi
  Escribir "fuera: ", x;
FinProceso
```

```salida
dentro: 2
fuera: 1
```

```diagnosticos
bindingShadowsOuter
```

::: nota
Los nombres de los subprogramas y las clases se registran antes que sus cuerpos. Por eso un subprograma puede llamar a otro declarado más abajo, y dos subprogramas pueden llamarse entre sí.
:::

::: resumen
- No hay variables globales.
- Un nombre vive desde su declaración hasta el cierre de su bloque.
- Ocultar un nombre exterior es válido, con advertencia.
- Los subprogramas pueden llamarse en cualquier orden.
:::

::: vease
- [Parámetros](#subprogramas.parametros)
- [Declarar variables con Definir](#declaraciones.definir)
:::
