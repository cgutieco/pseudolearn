---
id: lectura.ediciones
numero: "0.6"
tipo: concepto
titulo: Ediciones
anclas: [LANG.EDITION.MODEL#R1, LANG.EDITION.MODEL#R2, LANG.PROFILE.STRICTNESS#R1]
terminos: [edición, preludio]
---

::: frase
Una edición es una versión cerrada del lenguaje; esta especificación describe la edición 2026.
:::

## Cómo funciona {#funciona}

El lenguaje cambia con el tiempo, pero cada **edición** fija un conjunto de reglas que no se mueve. La edición vigente se llama **2026**. Un programa escrito para 2026 se analiza y se ejecuta siempre igual.

La edición no se escribe dentro del programa ni depende del perfil. Cambiar de español a inglés no activa construcciones de otras ediciones.

```figura id=edicion
pie: La edición 2026 reúne una sola gramática, una sola política de tipos y un preludio fijo de símbolos incorporados.
```

## El preludio {#preludio}

Todo programa de la edición 2026 ve desde el principio un **preludio**: un conjunto fijo de funciones y tipos incorporados, como `Longitud` o `Opcional`. No hace falta importarlo y no se lee de ningún archivo del ordenador. Si declaras un subprograma con el mismo nombre que una función incorporada, el tuyo la oculta.

```programa id=preludio titulo="Usar el preludio sin importar nada" ejecutar
Proceso Preludio
  Escribir Longitud("PseudoLearn");
  Escribir rc(81);
FinProceso
```

```salida
11
9.0
```

El preludio declara nombres, nunca permisos. Para leer un archivo o usar la red hace falta pedir una capacidad al entorno, como se explica en la Parte XII.

## Reglas comunes de la edición {#reglas}

La edición 2026 aplica una sola gramática: toda sentencia simple termina en punto y coma, cada parámetro declara su tipo y los índices empiezan en cero. No hay un «modo flexible» ni opciones que cambien el significado de un programa.

::: resumen
- La edición vigente es 2026.
- Una edición no se escribe en el programa y no depende del perfil.
- El preludio da funciones y tipos sin importar nada, pero no da permisos.
- Una sola gramática y una sola política de tipos para todos.
:::

::: vease
- [Estrictez](#programas.estrictez)
- [Permisos y capacidades](#biblioteca.permisos)
- [Funciones incorporadas](#apendice.funciones)
:::
