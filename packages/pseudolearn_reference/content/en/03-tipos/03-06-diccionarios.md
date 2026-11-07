---
id: tipos.diccionarios
numero: "3.6"
tipo: tipo
titulo: Dictionaries
anclas: [LANG.TYPES.DICTIONARY]
fichas: [construction.dictionary, help.pgs02.dictionary_keys]
diagnosticos: [missingDictionaryKey, invalidDictionaryKeyType]
terminos: [dictionary, key, value]
---

::: frase
A dictionary stores key-value pairs: you look up by the key and get the value, like in a phone book.
:::

## How to write it {#escribe}

```forma
Define «name» As dictionary<«key type», «value type»> <- dictionary();
«name»[«key»] <- «value»;
«name»[«key»]
«name».find(«key»)
```

## How it works {#funciona}

Writing `d[k] <- v` stores the value `v` under the key `k`: if the key did not exist, it is added at the end; if it already existed, its value is replaced without moving it. Reading `d[k]` returns the value of that key. Dictionaries **remember insertion order**: when written or when their keys are requested, they come out in the order they were added.

```programa id=edades titulo="An address book of ages"
```

```figura id=diccionario
pie: Each key points to a value. Replacing the value of a key does not move it from its place.
```

## Looking up without failing {#buscar}

Reading a key that does not exist is a failure. When you do not know whether it is there, use `find`: it returns `Some(value)` or `None`, and you handle it with `Switch`.

```programa id=buscar titulo="Asking before reading"
```

::: limite
- Allowed keys: `Integer`, `Character`, `String`, `Boolean` or an enumeration. Strings are compared character by character, without normalising.
- It is a shared reference, like a vector, with the same memory limits.
- `remove(key)` returns `Some(value)` if it removed it or `None` if it was not there; removing and inserting again places the key at the end.
:::

::: errores
Reading a missing key stops the program:

```programa id=ausente titulo="A key that is not there"
```

And not every type works as a key:

```programa id=clave-real titulo="A real key"
```
:::

::: por-dentro
The engine keeps the entries in order in a list and maintains a separate hash index to find them quickly. When it grows or accumulates gaps from removals, it reorganises the index without changing the order of the entries. That is why the output order does not depend on the machine.

```ri programa=buscar
```
:::

::: resumen
- A dictionary associates keys with values.
- `d[k] <- v` inserts or replaces; `d[k]` reads and fails if the key is missing.
- `find` returns `Some` or `None` and never fails.
- It keeps insertion order.
:::

::: vease
- [Vectors](#tipos.vectores)
- [Optional and Result](#tipos.opcional-resultado)
- [Switch](#control.segun)
:::
