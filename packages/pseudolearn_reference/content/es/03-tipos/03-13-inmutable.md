---
id: tipos.inmutable
numero: "3.13"
tipo: concepto
titulo: "`Inmutable` e `Instantanea`"
anclas: [LANG.TASK.ISOLATION#R4, LANG.TASK.ISOLATION#R5, LANG.TASK.ISOLATION#R7, LANG.TASK.ISOLATION#R6]
fichas: [help.snapshot_builtin, help.immutable_type]
diagnosticos: [immutableValueWrite, snapshotNotSupported]
terminos: [inmutable, instantánea, copia profunda]
---

::: frase
`Instantanea` hace una foto completa de un valor y la devuelve como `Inmutable`: se puede leer todo, pero nadie puede cambiarla.
:::

## Cómo funciona {#funciona}

Vectores, diccionarios y arreglos se comparten: si alguien los modifica, todos lo ven. A veces hace falta lo contrario, un valor que **no** pueda cambiar. `Instantanea(x)` copia `x` entero, con todo lo que contiene, y devuelve un `Inmutable` de ese tipo.

```programa id=congelar titulo="Una foto que no cambia" ejecutar
Proceso Congelar
  Definir notas Como Vector<Entero> <- Vector();
  notas.Agregar(7);
  Definir foto Como Inmutable<Vector<Entero>> <- Instantanea(notas);
  notas.Agregar(9);
  Escribir foto.Longitud(), " ", notas.Longitud(), " ", foto[0];
FinProceso
```

```salida
1 2 7
```

```figura id=instantanea
pie: La instantánea copia el contenido completo. Lo que le pase después al original no afecta a la foto.
```

Un `Inmutable` admite todas las lecturas, pero ninguna escritura ni método que modifique:

```programa id=escribir-foto titulo="Intentar cambiar la foto" ejecutar
Proceso EscribirFoto
  Definir notas Como Vector<Entero> <- Vector();
  Definir foto Como Inmutable<Vector<Entero>> <- Instantanea(notas);
  foto.Agregar(9);
FinProceso
```

```diagnosticos
immutableValueWrite
```

## Por qué existe {#por-que}

Las tareas concurrentes no pueden compartir vectores ni diccionarios, porque dos tareas podrían cambiarlos a la vez. Un `Inmutable` sí puede cruzar entre tareas: como nadie lo modifica, compartirlo es seguro.

::: limite
- `Instantanea` acepta primitivos, enumerados, registros, variantes, vectores, diccionarios y arreglos, y copia en profundidad conservando los alias internos.
- No acepta objetos de clase ni funciones: `snapshotNotSupported`.
- La copia cuenta para el límite de memoria del motor.
- `Copiar` hace una copia superficial y no da inmutabilidad.
:::

::: resumen
- `Instantanea(x)` copia todo y devuelve un `Inmutable`.
- Un `Inmutable` se lee pero no se modifica.
- Lo que cambie el original después no afecta a la instantánea.
- Los inmutables pueden pasar de una tarea a otra.
:::

::: vease
- [Ámbitos de tareas](#tareas.ambitos)
- [Copia, referencias e identidad](#objetos.copia)
:::
