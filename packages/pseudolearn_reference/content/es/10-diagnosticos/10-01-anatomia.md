---
id: diagnosticos.anatomia
numero: "10.1"
tipo: concepto
titulo: Anatomía de un diagnóstico
anclas: [DIAG.MODEL#R1, DIAG.MESSAGES#R1, DIAG.CATALOG#R1, DIAG.CATALOG#R2]
diagnosticos: [incompatibleTypesInAssignment]
terminos: [código, tramo, argumento]
---

::: frase
Un diagnóstico no es una frase: es un dato con un código estable, una clase, una severidad y una posición. El mensaje que lees se construye después, en tu idioma.
:::

## Cómo funciona {#funciona}

Cada diagnóstico tiene estas partes:

| Parte | Qué es |
|---|---|
| código | un nombre estable, igual en todos los idiomas |
| clase | léxico, sintáctico, semántico o de ejecución |
| severidad | error, advertencia o información |
| tramo | dónde empieza y dónde acaba en el texto |
| relacionados | otros tramos que ayudan a entenderlo |
| argumentos | los datos concretos: un nombre, un tipo, un número |

```figura id=anatomia-diagnostico
pie: El mismo diagnóstico visto como dato y como mensaje. El mensaje se construye con una plantilla del idioma de la interfaz y los argumentos.
```

```programa id=texto-en-entero titulo="Un diagnóstico con argumentos" ejecutar
Algoritmo Mezcla
  Definir total Como Entero <- "diez";
  Escribir total;
FinAlgoritmo
```

```diagnosticos
incompatibleTypesInAssignment
```

El dato no lleva texto. Para mostrarlo, la interfaz busca la plantilla del código en su idioma y sustituye los argumentos. Por eso la prosa del mensaje puede estar en inglés mientras el programa está en perfil español: los nombres del usuario nunca se traducen, y las palabras del lenguaje salen en el perfil activo.

El [Apéndice C](#apendice.diagnosticos) recoge todos los códigos con su clase, su severidad y su mensaje.

::: resumen
- Un diagnóstico es un dato: código, clase, severidad, tramo y argumentos.
- El mensaje se construye después, con la plantilla del idioma.
- El código no cambia con el idioma.
:::

::: vease
- [Severidad](#diagnosticos.severidad)
- [Errores, advertencias y fallos](#vision.errores)
- [Catálogo de diagnósticos](#apendice.diagnosticos)
:::
