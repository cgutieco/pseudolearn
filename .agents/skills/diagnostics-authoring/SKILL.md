---
name: diagnostics-authoring
description: Añadir o modificar un diagnóstico del núcleo del lenguaje sin romper su independencia del idioma. Usar cuando el lexer, el parser, el chequeador de tipos o el evaluador tengan que reportar un problema. Cubre la forma del diagnóstico, los tipos de argumento, la política de severidad y los tests obligatorios.
---

# Diagnósticos

## La regla de la que sale todo lo demás

**El núcleo no produce texto legible.** El lexer, el parser, el chequeador y el evaluador emiten
estructuras: un código, un span y argumentos tipados. La composición a texto ocurre en la capa de
presentación de diagnósticos.

Si estás a punto de escribir una frase destinada a una persona en cualquier capa que no sea la de
diagnósticos, pará: es un fallo de arquitectura, no un atajo.

Consecuencia práctica que conviene tener presente: **los tests se escriben contra códigos, no contra
frases**, y por eso no se rompen al retocar una traducción.

## Qué llevar en cada diagnóstico

- **Código.** Una entrada de la enumeración de códigos. Específico, no genérico: «se esperaba el cierre
  de este bloque» enseña, «error de sintaxis» no.
- **Severidad.** No se decide aquí. Viene de la política inyectada, que es una tabla de código a
  severidad. Escribir la severidad a mano en el sitio de emisión rompe que el modo estricto y el
  flexible sean datos en vez de ramas.
- **Span principal.** Donde la persona tiene que mirar. Lo más estrecho que siga siendo útil.
- **Spans relacionados.** Donde está el origen del problema, si es otro sitio: dónde se abrió el bloque
  sin cerrar, dónde se declaró la variable cuyo tipo no cuadra. **Es la diferencia entre un diagnóstico
  correcto y uno que enseña.** Si al describir el problema en voz alta dices «porque allí…», ese «allí»
  es un span relacionado.
- **Argumentos.** Solo de los tipos previstos, nunca texto libre de mensaje.

## Elegir el tipo de argumento

Un mensaje pertenece a dos ejes a la vez: la prosa sigue el idioma de la interfaz, y las palabras clave
siguen el perfil de sintaxis activo. El tipo de argumento es lo que declara a qué eje pertenece cada
valor. Sin esta separación, la combinación «interfaz en español con palabras clave en inglés» produce
mensajes incoherentes.

| Si el valor es…                                         | Usá                                        | Al presentar                                |
|---------------------------------------------------------|--------------------------------------------|---------------------------------------------|
| una palabra clave del lenguaje                          | argumento de token                         | se resuelve contra el léxico activo         |
| un tipo primitivo del lenguaje                          | argumento de tipo                          | se resuelve contra el léxico activo         |
| un término de prosa: «variable», «función», «parámetro» | argumento de término, desde la enumeración | se traduce al idioma de la interfaz         |
| texto que escribió la persona: el nombre de su variable | argumento de lexema                        | nunca se traduce                            |
| un número: un índice, un tamaño                         | argumento numérico                         | se formatea según la configuración regional |

**El argumento de lexema es el único texto libre admisible**, y no es un mensaje: es lo que escribió el
estudiante. Si te encuentras metiendo una palabra española o inglesa en un argumento de lexema, el tipo
que necesitabas era otro.

## Al añadir un código nuevo

1. Añadí la entrada a la enumeración de códigos.
2. Declará qué argumentos requiere ese código.
3. Añadí su plantilla en la capa de presentación, para cada idioma soportado.
4. Añadí la entrada a la política de severidad de **cada** política de rigor, estricta y flexible.
5. Escribí el test de emisión: el caso que lo dispara produce ese código, con ese span y esos
   argumentos.
6. Escribí el caso límite si lo hay: qué pasa al principio del archivo, al final, con la construcción
   vacía.

El test que recorre la enumeración completa de códigos te avisará si te salta el paso 3 o el 4. No lo
uses como sustituto de hacerlos.

## Errores frecuentes

- **Un código genérico reutilizado en cinco sitios.** Cada situación distinta que la persona puede
  arreglar de una forma distinta merece su propio código.
- **El span de todo el archivo o de toda la sentencia** cuando el problema es un token.
- **Escribir la severidad a mano** en el sitio de emisión.
- **Un diagnóstico lanzado como excepción.** Un fallo esperable es un valor de retorno; ninguna
  excepción cruza la frontera pública del paquete.
- **Perder el span relacionado** por comodidad, dejando a la persona sin saber dónde empezó el
  problema.
- **Añadir una marca de comportamiento al diagnóstico** —que bloquea tal cosa, que se muestra en tal
  sitio—. El diagnóstico describe qué pasó; quién lo consume decide qué hacer.
