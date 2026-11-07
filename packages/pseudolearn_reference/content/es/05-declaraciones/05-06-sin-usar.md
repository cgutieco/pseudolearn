---
id: declaraciones.sin-usar
numero: "5.6"
tipo: concepto
titulo: Variables sin usar
anclas: [LANG.DECL.UNUSED#R1]
diagnosticos: [variableDeclaredNeverUsed, variableAssignedNeverRead]
terminos: [advertencia]
---

::: frase
Una variable que se declara y nunca se usa, o que se escribe y nunca se lee, produce una advertencia: el programa funciona, pero algo sobra.
:::

## Cómo funciona {#funciona}

El motor distingue dos descuidos:

| Situación | Advertencia |
|---|---|
| declarada y nunca usada | `variableDeclaredNeverUsed` |
| asignada pero nunca leída | `variableAssignedNeverRead` |

Las dos son **advertencias**: no impiden ejecutar. Suelen señalar un nombre mal escrito, un cálculo que se olvidó mostrar o un resto de una versión anterior.

```programa id=limpieza titulo="Dos variables que sobran" ejecutar
Proceso Limpieza
  Definir usada Como Entero <- 1;
  Definir olvidada Como Entero;
  Definir escrita Como Entero;
  escrita <- 5;
  Escribir usada;
FinProceso
```

```salida
1
```

```diagnosticos
variableDeclaredNeverUsed
variableAssignedNeverRead
```

```figura id=higiene
pie: Tres variables y su uso. Solo la primera se escribe y se lee.
```

Los parámetros y los subprogramas que nadie usa tienen sus propias advertencias, con la misma idea.

::: resumen
- Declarar y no usar, o escribir y no leer, produce una advertencia.
- Las advertencias no impiden ejecutar.
- Suelen señalar un error de nombre o un cálculo olvidado.
:::

::: vease
- [Severidad](#diagnosticos.severidad)
- [Declarar variables con Definir](#declaraciones.definir)
:::
