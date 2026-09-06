---
name: language-spec-authoring
description: Extender la especificación del lenguaje PseudoLearn cuando una fase añade construcciones. Usar antes de escribir cualquier parser, y cuando haya que decidir sintaxis que ninguna fuente consultada resuelve. Cubre la regla de especificar antes de implementar, la separación entre plano abstracto y lexemas, y qué hacer ante material de terceros contradictorio.
---

# Especificación del lenguaje

## La regla

**La construcción se especifica antes de que exista su parser.** Sin excepción.

La razón no es formalismo. Un parser escrito antes de la especificación **es** la especificación, con
dos defectos: nadie puede revisarla sin leer código, y las decisiones que quedaron implícitas —qué es
opcional, qué asocia hacia dónde, qué pasa en el caso vacío— no están decididas, están accidentadas. Al
segundo consumidor del árbol ya es tarde para cambiarlas.

Una sección de la especificación en estado pendiente significa que la construcción **no está decidida**,
no que esté decidida y sin escribir.

## Los dos planos, que no hay que confundir

- **Plano abstracto:** tipos de token y construcciones. Es lo que el árbol, el chequeador y el evaluador
  conocen. Es único, normativo, y no depende del idioma.
- **Plano superficial:** los lexemas concretos. Es un dato del perfil, y hay uno por idioma y por perfil
  institucional.

La especificación define el plano abstracto. Los lexemas de los ejemplos son ilustrativos del perfil de
referencia: cambiar de perfil cambia los lexemas, nunca la gramática.

Prueba de que lo estás haciendo bien: **si una regla de la especificación deja de ser cierta al cambiar
de idioma, la escribiste en el plano equivocado.**

## Al especificar una construcción

Cerrá explícitamente, para cada una:

1. **Su forma**, en términos de tipos de token y de las demás construcciones.
2. **Qué es opcional** y qué ocurre cuando se omite. El valor por defecto es parte de la
   especificación, no un detalle de implementación.
3. **La precedencia y la asociatividad**, si es un operador. Incluida la asociatividad de los unarios.
4. **Los casos límite:** el cuerpo vacío, la lista de cero elementos, el anidamiento consigo misma, el
   límite del rango.
5. **Lo que es un error**, y de qué clase: léxico, sintáctico, semántico o de ejecución. La misma
   construcción mal escrita puede fallar en fases distintas, y decidir en cuál es una decisión de
   diseño, no una consecuencia.
6. **Un ejemplo mínimo válido y uno mínimo inválido.** Si no podés escribir el inválido, no cerraste el
   punto 5.

## Cuando el material de terceros no resuelve algo

Ocurre a menudo: no hay ninguna gramática formal en el material consultado, y las notaciones
disponibles se contradicen entre sí en vocabulario, operadores y delimitadores.

El procedimiento:

1. **No inventes en silencio, y no reconcilies en silencio.** Ambas cosas producen una decisión que
   nadie revisó.
2. **Investigá si existe una notación con adopción real** para lo que necesitás. Vale la pena para
   construcciones grandes; no para un delimitador.
3. Si no la hay, **proponé la forma con su análisis** —qué opciones hay, qué enseña cada una, qué
   encontrará el estudiante al pasar a un lenguaje real— y esperá aprobación antes de implementar.
4. **Registralo.** La decisión va a la especificación, y lo que se tomó o se rechazó de material externo
   va a la sección de fuentes del README del paquete.

Criterio de desempate cuando dos formas son defendibles: **la que prepara mejor para el lenguaje real**.
Este lenguaje existe para que el salto siguiente sea corto, no para ser cómodo en sí mismo. Una
comodidad que enseñe un modelo mental que habrá que desaprender no es una comodidad.

## Al cambiar algo ya especificado

Un cambio en la especificación de una construcción que ya tiene parser afecta al parser, al chequeador,
al evaluador, al impresor y a los exportadores. Antes de tocarla: decí qué se rompe y esperá
confirmación. Nunca se cambia la especificación como efecto colateral de arreglar otra cosa.
