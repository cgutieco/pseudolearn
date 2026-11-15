---
id: funcional.orden-superior.mapear-predecir
leccion: funcional.orden-superior
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Double each one
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
Funcion twice <- Double(x Como Entero)
  Definir twice Como Entero;
  twice <- x * 2;
FinFuncion

Funcion mapped <- Map(v Como Vector<Entero>, f Como Funcion(Entero) Como Entero)
  Definir mapped Como Vector<Entero> <- Vector();
  Para Cada item En v Hacer
    mapped.Agregar(f(item));
  FinPara
FinFuncion

Algoritmo Doubles
  Definir v Como Vector<Entero> <- Vector();
  v.Agregar(1);
  v.Agregar(2);
  v.Agregar(3);
  Para Cada x En Map(v, Double) Hacer
    Escribir x;
  FinPara
FinAlgoritmo
```

```salida
2
4
6
```

::: explicacion
`Map` applies `Double` to each element and builds a new vector of the same length: 2, 4 and 6. The vector `v` stays the same.
:::
