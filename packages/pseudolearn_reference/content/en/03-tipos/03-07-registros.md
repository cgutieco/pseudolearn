---
id: tipos.registros
numero: "3.7"
tipo: tipo
titulo: Records
anclas: [LANG.TYPES.RECORD]
fichas: [help.record, help.pgl01.record_array_element]
diagnosticos: [recordCannotBeWritten, argumentCountMismatch, recursiveRecordContainment, recordWithoutFields]
terminos: [record, field, copy by value]
---

::: frase
A record groups several named pieces of data into a single value, like a card with its sections; assigning it copies it whole.
:::

## How to write it {#escribe}

```forma
Record «Name»
  Define «field» As «type»;
  …
EndRecord
```

```railes produccion=recordUnit
```

## How it works {#funciona}

A **record** is declared outside the algorithm, with a name and its **fields**. After that it is used like any other type: it is built by writing its name with one value per field, in the order they were declared, and each field is read or changed with a dot.

```programa id=alumno titulo="A student's card"
```

## It is copied by value {#copia}

A record is a **value**, not a reference. Assigning it, passing it to a subroutine or returning it copies all its fields. Changing the copy does not change the original.

```programa id=copia titulo="Each variable has its own card"
```

```figura id=registro-copia
pie: Assigning a record makes a copy. Both cards start equal, but from then on they change separately.
```

Two records of the same type are equal if all their fields are. A record cannot contain itself, directly or indirectly.

::: limite
- At least one field; at most 65535 leaves (fields that are not records, counting nested ones).
- A record with more than 1024 leaves cannot be an array element.
- Allowed fields: primitive types, enumerations, classes and other records.
- Writing a whole record is not allowed; its fields are written.
:::

::: errores
A record is not written in one go:

```programa id=escribir-registro titulo="Writing the whole card"
```

And building one needs a value per field:

```programa id=faltan titulo="A field is missing"
```
:::

::: nota
In the Spanish profile `y` cannot be the name of a field: it is the reserved word for "and", and reserved words ignore case.
:::

::: por-dentro
In the machine, a record takes several consecutive slots, one per leaf. Copying it means copying those slots, without creating anything on the heap. That is why small records are as fast as loose variables.

```ri programa=alumno
```
:::

::: resumen
- A record groups named fields into a single value.
- It is built with one value per field and accessed with a dot.
- It is copied when assigned, passed or returned.
- Two records are equal if all their fields are.
:::

::: vease
- [Class](#objetos.clase)
- [Copying objects](#objetos.copia)
- [Designators](#declaraciones.designadores)
:::
