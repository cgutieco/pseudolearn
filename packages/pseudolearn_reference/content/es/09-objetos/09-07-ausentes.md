---
id: objetos.ausentes
numero: "9.7"
tipo: concepto
titulo: Lo que no existe en las clases
anclas: [LANG.CLASS.OUT-OF-SCOPE#R1]
diagnosticos: [unsupportedAbstractConstruct, unsupportedStaticConstruct, unsupportedProtectedConstruct, unsupportedExceptionConstruct]
terminos: [construcción ausente]
---

::: frase
PseudoLearn deja fuera, a propósito, algunas piezas de otros lenguajes de objetos, y cuando las reconoce lo explica con un mensaje propio.
:::

## Cómo funciona {#funciona}

Estas construcciones **no forman parte** de la edición actual:

| Construcción | Diagnóstico |
|---|---|
| clases y métodos abstractos | `unsupportedAbstractConstruct` |
| miembros estáticos | `unsupportedStaticConstruct` |
| visibilidad protegida | `unsupportedProtectedConstruct` |
| manejo de excepciones con bloques | `unsupportedExceptionConstruct` |

```figura id=ausentes
pie: Las cuatro construcciones que se reconocen para explicar que no existen, y lo que PseudoLearn ofrece en su lugar.
```

El motor reconoce sus formas típicas **solo en posición de estructura** —por ejemplo, una palabra más en la cabecera de una clase— y da un mensaje pedagógico en vez de un error genérico. Esas palabras **no son reservadas**: se pueden usar como nombres en cualquier otro sitio.

```programa id=estatico titulo="Un miembro estático" ejecutar
Clase Contador
  Estatico Definir total Como Entero;
FinClase

Algoritmo Mal
FinAlgoritmo
```

```diagnosticos
unsupportedStaticConstruct
```

Para los errores esperables, el lenguaje usa valores: [Opcional y Resultado](#tipos.opcional-resultado). Para compartir datos entre objetos, se pasan como parámetros.

::: resumen
- No hay clases abstractas, miembros estáticos, protegido ni excepciones.
- Sus formas típicas producen un mensaje propio.
- Esas palabras siguen siendo nombres válidos.
:::

::: vease
- [Clases y atributos](#objetos.clase)
- [Opcional y Resultado](#tipos.opcional-resultado)
:::
