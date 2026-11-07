---
id: procedimental.fallos
numero: "2.6"
tipo: leccion
titulo: When something can fail
duracion: 35
problema_breve: Signing up for the workshop
necesita: [procedimental.datos]
introduce: [valor-opcional, resultado-con-error, propagar, validar]
usa: [subprograma, funcion-pura, error-de-ejecucion, caso-borde, seleccion-multiple, diccionario]
---

::: frase
A program fails well when an expected error is an answer with a reason, not a crash.
:::

## The problem {#problema}

::: problema
The sign-up for a workshop asks for the age, from **6 to 18 years**, written **as text**. Answers arrive such as «12», «doce» (twelve), «-3», «150» and an empty one. The program cannot stop and has to say **why** it rejects each one.

**How is it written?**
:::

## Try it {#intentalo}

::: intento
Decide what to answer to each of the five replies.
:::

::: respuesta
«12» is accepted. «doce» is not a number. «-3» and «150» are numbers, but they are out of range. The empty reply is not a number.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** A text goes in; the accepted age or the reason for the rejection comes out.
- **What does it look like?** The tip calculator that stopped with 0 friends, in [lesson 0.4](ruta:inicio.errores): an odd value should not bring the program down.
- **Which parts does it split into?** It splits into two filters in a row: first, is it a number?; then, is it in range?

```figura id=ruta-filtro-validacion
pie: Each filter lets through what meets it and diverts what does not, with its reason.
```

## The new tool {#herramienta}

An [[def:valor-opcional|optional value]] is a value that may be missing: an `Optional` is `Some(value)` or `None`. Looking up a key in a dictionary gives back one, as in the contact list of [the previous lesson](ruta:procedimental.datos).

A [[def:resultado-con-error|result with error]] is a `Result`: it brings `Success(value)` or `Failure(reason)`. Whoever receives it has to handle both cases, with a `Switch`.

```figura-especificacion seccion=tipos.opcional-resultado figura=opcional-resultado
```

```programa id=dividir-seguro titulo="Dividing without crashing" ejecutar
```

```salida
No se puede dividir entre 0
```

When a subprogram receives a `Result` it does not know how to handle, it can [[def:propagar|propagate]] the error: `Propagate` takes out the value if it was a success and, if it was an error, gives it straight back to whoever called. The details are in [the Specification](especificacion:tipos.opcional-resultado).

To [[def:validar|validate]] is to check an input before using it. To turn a text into a number there is `toInteger`, but with a text that is not a number it stops the program. That is why, before converting, the sign-up checks with its own function that the text is a number.

::: especificacion
- tipos.opcional-resultado
- biblioteca.conversion
- control.segun
:::

## Write {#escribir fase=3}

```programa id=inscripcion titulo="The sign-up" ejecutar
```

```entrada
doce
```

```salida
Rechazada: no es un número
```

`EsNumero` is a pure function: it walks through the text and checks that each character is a digit, with a minus sign allowed at the start. `ValidarEdad` applies the two filters in order and returns the reason of the first one that fails.

## Test {#probar fase=4}

| Text | Expected | Why |
|---|---|---|
| 12 | Inscripción aceptada: 12 | normal case |
| doce | Rechazada: no es un número | not a number |
| -3 | Rechazada: fuera de rango | negative number |
| 150 | Rechazada: fuera de rango | number too large |
| (empty) | Rechazada: no es un número | nothing to convert |
| 6 and 18 | accepted | the edges of the range |

## Improve {#mejorar fase=5}

In one sentence: «The program checks that the age is a number and that it is in range, and if not, says which of the two failed».

What if the empty reply had its own reason, «empty»? A filter is added at the start of `ValidarEdad`, and the rest of the program does not change.

## What you learned {#aprendiste}

::: resumen
- {valor-opcional} A value that may be missing is represented as something that may have nothing inside.
- {resultado-con-error,propagar} A result with error brings the value or the reason for the failure; propagating gives the error back to whoever called.
- {validar} Validating is checking an input before using it.
:::

## Practise {#practica}

::: practica
- procedimental.fallos.segun-resultado
- procedimental.fallos.opcional-o-resultado
- procedimental.fallos.division
- procedimental.fallos.mes-romper
- procedimental.fallos.fecha
- procedimental.fallos.caer-o-avisar
:::

::: docentes
- **Validating too late.** Converting before checking stops the program with «doce». The order of the filters matters.
- **A reason that says nothing.** «Error» tells nobody what to fix. Ask for one reason per filter.
- **Handling the error in the wrong place.** Whoever knows what to show is the main algorithm; the validation only reports.
:::

::: siguiente
The kiosk program already has 400 lines and two classmates want to work at the same time. How is it split into files?
:::
