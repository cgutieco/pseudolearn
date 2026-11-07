---
id: lectura.perfiles
numero: "0.5"
tipo: concepto
titulo: "Perfiles de sintaxis: español e inglés"
anclas: [LANG.PROFILE.MODEL#R1, LANG.PROFILE.TRANSLATION#R1]
terminos: [perfil, vocabulario, traducción]
---

::: frase
PseudoLearn tiene dos vocabularios con exactamente las mismas reglas: puedes programar en español o en inglés y el resultado es el mismo.
:::

## Cómo funciona {#funciona}

Un **perfil de sintaxis** es el idioma de las palabras del lenguaje. En el perfil español se escribe `Si … Entonces … FinSi`; en el inglés, `If … Then … EndIf`. Cambia el vocabulario y nada más: la precedencia, los tipos, la base de los índices y el orden en que se evalúa todo son iguales.

```figura id=perfiles-espejo
pie: El mismo programa en los dos perfiles. Cada palabra tiene su pareja exacta; los nombres y los textos no cambian.
```

El motor sabe **traducir** un programa de un perfil al otro. La traducción cambia solo las palabras del lenguaje; respeta los nombres que inventaste, los textos entre comillas y los comentarios.

```programa id=saludo titulo="Un programa en perfil español" ejecutar
Proceso Saludo
  Definir nombre Como Cadena <- "Ana";
  Si Longitud(nombre) > 2 Entonces
    Escribir "Hola, ", nombre;
  FinSi
FinProceso
```

```salida
Hola, Ana
```

Esta especificación puede leerse con cualquiera de los dos perfiles. Los programas se escriben una sola vez y el motor los traduce; por eso, en la edición inglesa los textos entre comillas siguen en español.

::: nota
El idioma de la interfaz y el perfil de sintaxis son cosas distintas. Puedes leer la especificación en español con los programas en perfil inglés, o al revés.
:::

## La única diferencia visible {#diferencia}

Hay un único lugar donde el perfil cambia lo que se ve al ejecutar: al escribir un valor lógico. En perfil español se escribe `Verdadero` y en perfil inglés `true`. Todo lo demás, incluidos los números, se escribe igual.

::: resumen
- Hay dos perfiles oficiales: español e inglés.
- Tienen las mismas reglas; solo cambian las palabras.
- El motor traduce de uno a otro sin tocar nombres, textos ni comentarios.
- Los valores lógicos se escriben con el vocabulario del perfil.
:::

::: vease
- [Perfiles de vocabulario y traducción](#programas.perfiles)
- [Palabras reservadas en español e inglés](#apendice.palabras)
:::
