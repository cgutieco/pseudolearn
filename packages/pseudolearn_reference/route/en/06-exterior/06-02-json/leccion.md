---
id: exterior.json
numero: "6.2"
tipo: leccion
titulo: Data that programs understand
duracion: 30
problema_breve: The inventory for the school page
necesita: [exterior.archivos]
introduce: [json, serializar]
usa: [archivo, funcion-pura, concatenar, resultado-con-error]
---

::: frase
JSON is a way of writing data as text that any program knows how to read.
:::

## The problem {#problema}

::: problema
The school has a page that shows the kiosk inventory, but it cannot read «jugo;10»: it expects **JSON**. The five products with their stock have to be **exported**.

**How do you write the inventory so that another program understands it, and how do you check that it came out right?**
:::

## Try it {#intentalo}

::: intento
Write by hand the JSON of two products: juice with 10 and sandwich with 5.
:::

::: respuesta
`{"jugo": 10, "sandwich": 5}`. The braces enclose the object; each key goes between double quotes, followed by a colon and its value; the entries are separated by commas.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** The stock of the five products goes in; out comes a text that the school page knows how to read.
- **What does it look like?** The line «jugo;10» of the previous lesson, with other writing rules.
- **What can fail outside the program?** The text that arrives from outside can be broken.

## The new tool {#herramienta}

[[def:json|JSON]] writes data as text with objects between braces, lists between brackets, numbers, texts between quotes and logical values. Almost every program knows how to read it.

```figura-especificacion seccion=biblioteca.json figura=json-arbol
```

Turning a datum into text to save it or send it, so that it can be rebuilt, is [[def:serializar|serializing]]. On the other side, `parseJson` reads the text and gives back a `Result`: the rebuilt value or an error with its place. `jsonText` goes the way back.

```figura id=ruta-json-viaje
pie: The datum travels as text and is rebuilt the same on the other side.
```

```programa id=ficha-json titulo="Reading a record card" ejecutar
```

```salida
edad: 15
```

::: especificacion
- biblioteca.json
- expresiones.concatenacion
:::

## Write {#escribir fase=3}

```programa id=exportar titulo="Exporting the inventory" ejecutar
```

```salida
{"jugo": 10, "sandwich": 5, "alfajor": 8, "agua": 12, "fruta": 6}
Válido: 5 productos
```

`InventarioJson` is a pure function that builds the text with `ParJson`, one entry per product. The single quotes of `ParJson` let you write double quotes inside the text. The algorithm parses again what it wrote: if `parseJson` accepts it, the text is valid JSON.

## Test {#probar fase=4}

Normal case: the five products. Edge case: an inventory of a single product, without commas. Odd case: a text with one comma too many at the end. `parseJson` does not accept it and says where the problem is:

```programa id=json-roto titulo="One comma too many" ejecutar
```

```salida
InvalidSyntax en 1:13
```

## Improve {#mejorar fase=5}

In one sentence: «The inventory is written as JSON text with a pure function, and it is checked by parsing it again».

| | `jugo;10` | JSON |
|---|---|---|
| Who reads it | only a program that knows the rules of the `;` | almost any program |
| What it costs | inventing and explaining the rules | writing braces, quotes and commas without errors |

## What you learned {#aprendiste}

::: resumen
- {json} JSON writes data as text with objects, lists, numbers and texts; almost every program reads it.
- {serializar} Serializing is turning a datum into text to save it or send it, and being able to rebuild it.
:::

## Practise {#practica}

::: practica
- exterior.json.json-campo
- exterior.json.par-json
- exterior.json.valido-o-no
- exterior.json.formato
- exterior.json.json-clasificar
- exterior.json.dos-pares
:::

::: profundizar titulo="Common pitfalls"
- **Single quotes inside the JSON.** JSON only accepts double quotes; the single ones belong to the program that builds it.
- **The trailing comma.** It is the most common error, and `parseJson` marks it with line and column.
- **Believing that JSON is a kind of file.** It is a way of writing text: it can go in a file, in a message or in an answer from the internet.
:::

::: siguiente
The price of imported fruit depends on the day's exchange rate, and that datum is on the internet. How do you ask for it?
:::
