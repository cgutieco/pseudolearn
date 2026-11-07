---
id: control.para-cada
numero: "6.6"
tipo: construccion
titulo: "Recorrer colecciones con `Para Cada`"
anclas: [LANG.CONTROL.FOR-EACH#R1, LANG.CONTROL.FOR-EACH#R2]
fichas: [construction.for_each]
diagnosticos: [collectionModifiedDuringIteration, immutableBindingAssignment]
terminos: [recorrido, elemento]
---

::: frase
`Para Cada` visita uno a uno los elementos de un vector, un arreglo o un diccionario, sin índices.
:::

## Cómo se escribe {#escribe}

```forma
Para Cada «elemento» En «colección» Hacer
  «instrucciones»
FinPara
Para Cada «clave», «valor» En «diccionario» Hacer
  «instrucciones»
FinPara
```

```railes produccion=forEachLoop contextuales=Cada,En
```

::: partes
- `Para Cada` abre el recorrido.
- «elemento» es un nombre nuevo que en cada vuelta vale el elemento visitado. No se puede asignar.
- `En` separa los nombres de la colección.
- «colección» es un `Vector`, un arreglo de una dimensión o, con dos nombres, un `Diccionario`.
- `FinPara` cierra el recorrido.
:::

## Cómo funciona {#funciona}

La colección se calcula una vez. Después se visita cada elemento en orden: de la posición 0 en adelante para vectores y arreglos, y en orden de inserción para diccionarios. Una colección vacía no ejecuta el cuerpo.

```programa id=lista-compra titulo="Recorrer un vector" ejecutar
Algoritmo Mochila
  Definir lista Como Vector<Cadena> <- Vector();
  lista.Agregar("pan");
  lista.Agregar("leche");
  lista.Agregar("huevos");
  Para Cada producto En lista Hacer
    Escribir "- ", producto;
  FinPara
FinAlgoritmo
```

```salida
- pan
- leche
- huevos
```

```figura id=para-cada-recorrido
pie: El recorrido avanza por las casillas en orden. En cada vuelta, `producto` vale una copia del elemento visitado.
paso: Primera vuelta: `producto` vale `"pan"`.
paso: Segunda vuelta: `producto` vale `"leche"`.
paso: Tercera vuelta: `producto` vale `"huevos"`. No quedan más y el recorrido termina.
```

Con un diccionario se piden dos nombres, la clave y el valor:

```programa id=recorrer-edades titulo="Recorrer un diccionario" ejecutar
Algoritmo Edades
  Definir edades Como Diccionario<Cadena, Entero> <- Diccionario();
  edades["Ana"] <- 12;
  edades["Leo"] <- 11;
  Para Cada nombre, edad En edades Hacer
    Escribir nombre, ": ", edad;
  FinPara
FinAlgoritmo
```

```salida
Ana: 12
Leo: 11
```

::: limite
Durante el recorrido la colección no puede cambiar de **estructura**: añadir o quitar elementos detiene el programa con `collectionModifiedDuringIteration`, aunque se haga a través de otro nombre. Reemplazar el valor de un elemento existente sí está permitido.
:::

::: errores
```programa id=modificar-recorrido titulo="Añadir mientras se recorre" ejecutar termina=failed
Algoritmo Modificar
  Definir lista Como Vector<Entero> <- Vector();
  lista.Agregar(1);
  lista.Agregar(2);
  Para Cada n En lista Hacer
    lista.Agregar(n);
  FinPara
FinAlgoritmo
```

```diagnosticos
collectionModifiedDuringIteration
```
:::

::: por-dentro
El recorrido guarda la versión de la colección al empezar y la compara antes de cada avance. Si no coincide, se produce la trampa.

```ri programa=lista-compra
```
:::

::: resumen
- `Para Cada` visita todos los elementos en orden, sin índices.
- Con diccionarios se escriben dos nombres: clave y valor.
- El nombre del elemento no se puede asignar.
- Cambiar la estructura de la colección durante el recorrido es un fallo.
:::

::: vease
- [Para](#control.para)
- [Vectores](#tipos.vectores)
- [Diccionarios](#tipos.diccionarios)
:::
