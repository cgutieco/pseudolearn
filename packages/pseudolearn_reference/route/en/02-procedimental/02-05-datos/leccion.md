---
id: procedimental.datos
numero: "2.5"
tipo: leccion
titulo: Giving data a shape
duracion: 40
problema_breve: The group's contact list
necesita: [procedimental.recursion]
introduce: [registro, campo, enumerado, vector, diccionario, clave]
usa: [arreglo, indice, subprograma, esquema, caso-borde]
---

::: frase
Choosing how to keep the data is half the solution.
:::

## The problem {#problema}

::: problema
The group's contact list keeps, for each classmate, their **name**, their **phone number** and their **birthday month**. New classmates join every year. You have to be able to **find someone's phone number by their name** and know **how many have birthdays each month**.

**How should the contact list be kept?**
:::

## Try it {#intentalo}

::: intento
Draw three ways of keeping five contacts: three separate rows of cells, a row of cards with the three things together, and a list where you look up by name. Which one answers each question more easily?
:::

::: respuesta
The three separate rows force you to keep three lists aligned: if a name is added and the phone forgotten, everything shifts. The row of cards keeps each classmate's values together. The list by name finds a phone without walking through everything. And counting by month needs one more list, from month to amount.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** The contacts and a name to search go in; a phone and a count per month come out.
- **What does it look like?** The three separate rows are the parallel arrays of the kiosk till, in [the project of Part I](ruta:imperativo.proyecto).
- **Which parts does it split into?** You have to choose the shape of each piece of data according to the question it has to answer.

```figura id=ruta-forma-de-datos
pie: The same contact list kept in three ways. Each one answers a different question more easily.
```

## The new tool {#herramienta}

A [[def:registro|record]] groups the data of one thing; each value is a [[def:campo|field]], and it is read with a dot: `ana.telefono`.

```figura-especificacion seccion=tipos.registros figura=registro-copia
```

```programa id=producto titulo="A kiosk product" ejecutar
```

```salida
Jugo 3
```

An [[def:enumerado|enumeration]] is a type with a closed list of named values, like the days of the week: there is no eighth day that can be written by mistake.

A [[def:vector|vector]] is a list that can grow: it starts empty and elements are added with `append`. It is useful when you do not know how much data there will be.

A [[def:diccionario|dictionary]] keeps values that are found by a [[def:clave|key]], like a phone looked up by name. It remembers the order in which the keys were added.

```figura-especificacion seccion=tipos.diccionarios figura=diccionario
```

::: especificacion
- tipos.registros
- tipos.enumerados
- tipos.vectores
- tipos.diccionarios
:::

## Write {#escribir fase=3}

```programa id=agenda titulo="The contact list" ejecutar
```

```entrada
Ana
555-1234
5
Beto
555-9876
11
Caro
555-4567
5
Dani
555-2222
3
Caro
```

```salida
Caro: 555-4567
Mes 5: 2
Mes 11: 1
Mes 3: 1
```

The vector of records answers the search; the dictionary from month to amount answers the count.

## Test {#probar fase=4}

| Searched | Expected | Why |
|---|---|---|
| Caro | her phone | a name that is there |
| Eva | No está | a name that is not there |
| a repeated name | the first phone | the rule: the first one is returned |

## Improve {#mejorar fase=5}

In one sentence: «The contact list keeps one card per classmate and counts the birthdays per month».

If the email of each contact has to be added, with records you add a field and a read. With three separate rows, you would have to add a fourth row and make sure they all stay aligned.

## What you learned {#aprendiste}

::: resumen
- {registro,campo} A record groups the data of one thing; each value is a field.
- {enumerado} An enumeration is a type with a closed list of named values.
- {vector} A vector is a list that can grow.
- {diccionario,clave} A dictionary keeps values that are found by a key.
:::

## Practise {#practica}

::: practica
- procedimental.datos.que-forma
- procedimental.datos.votos-predecir
- procedimental.datos.linea-ticket
- procedimental.datos.votacion
- procedimental.datos.paralelos-a-registros
- procedimental.datos.buscar-telefono
:::

::: profundizar titulo="Common pitfalls"
- **Choosing the shape before looking at the questions.** List the questions the program has to answer before drawing the shape.
- **A record with one field per contact.** A record describes a single thing; many things go in a vector.
- **Confusing key with value.** Here, the name is the key and the phone the value: you search by what you know.
:::

::: siguiente
The sign-up for a workshop asks for the age. Someone writes «twelve», another «-3». How does a program fail well?
:::
