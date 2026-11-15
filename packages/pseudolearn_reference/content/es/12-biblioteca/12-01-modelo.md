---
id: biblioteca.modelo
numero: "12.1"
tipo: concepto
titulo: Cómo está organizada la biblioteca
anclas: [LIB.MODEL#R1, LIB.MODEL#M1, LIB.MODEL#M2, LIB.MODEL#M3, LIB.MODEL#M4, LIB.SCENARIO.BILINGUAL#R1]
diagnosticos: [undeclaredSubroutine]
terminos: [función incorporada, operación, familia]
---

::: frase
La biblioteca son las funciones que trae el lenguaje: cada una tiene una identidad fija, un nombre en cada perfil y una firma que no cambia con el idioma.
:::

## Cómo funciona {#funciona}

Hay dos clases de símbolos:

- **funciones incorporadas**, que se llaman por su nombre: `Longitud(t)`, `rc(x)`, `AnalizarJson(texto)`;
- **operaciones**, que se llaman sobre un receptor con un punto: `consola.EscribirError(texto)`, `fecha.FormatoIso()`.

Cada símbolo pertenece a una **familia**: texto, bytes, números, colecciones, entrada y salida, tiempo, JSON, red o tareas. El [Apéndice D](#apendice.funciones) las lista todas.

```figura id=familias-biblioteca
pie: Las familias de la biblioteca. Las de la izquierda calculan; las de la derecha necesitan una capacidad del anfitrión.
```

Un símbolo tiene **una sola identidad**: su nombre español, su nombre inglés y sus alias nombran lo mismo con la misma firma. `ConvertirANumero` es un alias de `AReal`:

```programa id=alias-biblioteca titulo="Dos nombres, una función" ejecutar
Algoritmo Alias
  Escribir AReal("2.5"), " ", ConvertirANumero("2.5");
FinAlgoritmo
```

```salida
2.5 2.5
```

Ningún nombre de la biblioteca coincide con una palabra reservada, y los nombres de la biblioteca **no** están reservados: un subprograma propio con el mismo nombre oculta al incorporado en todo el texto.

Como cada símbolo tiene identidad propia, un proyecto puede mezclar módulos escritos en perfiles distintos: un módulo en inglés que llama a `length` y otro en español que llama a `Longitud` usan la misma función.

::: resumen
- Funciones incorporadas por nombre; operaciones sobre un receptor.
- Cada símbolo tiene una identidad, nombres en ambos perfiles y alias.
- Las familias de entrada, salida, tiempo y red necesitan capacidades.
:::

::: vease
- [Catálogo de funciones](#apendice.funciones)
- [Efectos y capacidades](#tareas.efectos)
:::
