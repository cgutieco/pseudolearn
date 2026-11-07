---
id: tipos.diccionarios
numero: "3.6"
tipo: tipo
titulo: Diccionarios
anclas: [LANG.TYPES.DICTIONARY]
fichas: [construction.dictionary, help.pgs02.dictionary_keys]
diagnosticos: [missingDictionaryKey, invalidDictionaryKeyType]
terminos: [diccionario, clave, valor]
---

::: frase
Un diccionario guarda parejas de clave y valor: buscas por la clave y obtienes el valor, como en una agenda de teléfonos.
:::

## Cómo se escribe {#escribe}

```forma
Definir «nombre» Como Diccionario<«tipo clave», «tipo valor»> <- Diccionario();
«nombre»[«clave»] <- «valor»;
«nombre»[«clave»]
«nombre».Buscar(«clave»)
```

## Cómo funciona {#funciona}

Escribir `d[k] <- v` guarda el valor `v` con la clave `k`: si la clave no existía, la añade al final; si ya existía, reemplaza su valor sin moverla. Leer `d[k]` devuelve el valor de esa clave. Los diccionarios **recuerdan el orden de inserción**: al escribirlos o pedir sus claves, salen en el orden en que se añadieron.

```programa id=edades titulo="Una agenda de edades" ejecutar
Algoritmo Edades
  Definir edades Como Diccionario<Cadena, Entero> <- Diccionario();
  edades["Ana"] <- 12;
  edades["Luis"] <- 11;
  edades["Ana"] <- 13;
  Escribir edades, " ", edades.Longitud();
  Escribir edades["Ana"], " ", edades.Claves();
FinAlgoritmo
```

```salida
{"Ana": 13, "Luis": 11} 2
13 ["Ana", "Luis"]
```

```figura id=diccionario
pie: Cada clave apunta a un valor. Reemplazar el valor de una clave no la mueve de su sitio.
```

## Buscar sin fallar {#buscar}

Leer una clave que no existe es un fallo. Cuando no sabes si está, usa `Buscar`: devuelve `Algo(valor)` o `Nada`, y lo tratas con `Segun`.

```programa id=buscar titulo="Preguntar antes de leer" ejecutar
Algoritmo Buscar
  Definir edades Como Diccionario<Cadena, Entero> <- Diccionario();
  edades["Ana"] <- 12;
  Segun edades.Buscar("Eva") Hacer
    Algo(edad): Escribir "tiene ", edad;
    Nada: Escribir "no está";
  FinSegun
FinAlgoritmo
```

```salida
no está
```

::: limite
- Claves admitidas: `Entero`, `Caracter`, `Cadena`, `Logico` o un enumerado. Las cadenas se comparan carácter a carácter, sin normalizar.
- Es una referencia compartida, como un vector, con los mismos límites de memoria.
- `Eliminar(clave)` devuelve `Algo(valor)` si la borró o `Nada` si no estaba; borrar y volver a insertar coloca la clave al final.
:::

::: errores
Leer una clave ausente detiene el programa:

```programa id=ausente titulo="Una clave que no está" ejecutar termina=failed
Algoritmo Ausente
  Definir d Como Diccionario<Cadena, Entero> <- Diccionario();
  Escribir d["nadie"];
FinAlgoritmo
```

```diagnosticos
missingDictionaryKey
```

Y no cualquier tipo sirve como clave:

```programa id=clave-real titulo="Una clave real" ejecutar
Algoritmo ClaveReal
  Definir d Como Diccionario<Real, Entero>;
FinAlgoritmo
```

```diagnosticos
invalidDictionaryKeyType
```
:::

::: por-dentro
El motor guarda las entradas en orden en una lista y mantiene aparte un índice por dispersión para encontrarlas rápido. Al crecer o al acumular huecos por borrados, reorganiza el índice sin cambiar el orden de las entradas. Por eso el orden de salida no depende de la máquina.

```ri programa=buscar
```
:::

::: resumen
- Un diccionario asocia claves con valores.
- `d[k] <- v` inserta o reemplaza; `d[k]` lee y falla si no está.
- `Buscar` devuelve `Algo` o `Nada` y nunca falla.
- Conserva el orden de inserción.
:::

::: vease
- [Vectores](#tipos.vectores)
- [Opcional y Resultado](#tipos.opcional-resultado)
- [Segun](#control.segun)
:::
