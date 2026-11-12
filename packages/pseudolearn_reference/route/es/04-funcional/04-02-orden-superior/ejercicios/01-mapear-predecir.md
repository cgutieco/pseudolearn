---
id: funcional.orden-superior.mapear-predecir
leccion: funcional.orden-superior
tipo: predecir
nivel: semilla
obligatorio: true
titulo: El doble de cada uno
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
Funcion doble <- Doble(x Como Entero)
  Definir doble Como Entero;
  doble <- x * 2;
FinFuncion

Funcion nuevos <- Mapear(v Como Vector<Entero>, f Como Funcion(Entero) Como Entero)
  Definir nuevos Como Vector<Entero> <- Vector();
  Para Cada elemento En v Hacer
    nuevos.Agregar(f(elemento));
  FinPara
FinFuncion

Algoritmo Dobles
  Definir v Como Vector<Entero> <- Vector();
  v.Agregar(1);
  v.Agregar(2);
  v.Agregar(3);
  Para Cada x En Mapear(v, Doble) Hacer
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
`Mapear` aplica `Doble` a cada elemento y arma un vector nuevo del mismo largo: 2, 4 y 6. El vector `v` queda igual.
:::
