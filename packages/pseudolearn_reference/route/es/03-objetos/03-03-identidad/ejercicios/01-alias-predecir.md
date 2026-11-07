---
id: objetos.identidad.alias-predecir
leccion: objetos.identidad
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Dos nombres para un contador
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
Clase Contador
  Definir valor Como Entero;

  Metodo Constructor()
    Este.valor <- 0;
  FinMetodo

  Metodo Incrementar()
    Este.valor <- Este.valor + 1;
  FinMetodo

  Metodo Actual() Como Entero
    Retornar Este.valor;
  FinMetodo
FinClase

Algoritmo Alias
  Definir a Como Contador <- Nuevo Contador();
  Definir b Como Contador <- a;
  b.Incrementar();
  Escribir a.Actual();
FinAlgoritmo
```

```salida
1
```

::: explicacion
`b <- a` no crea un contador nuevo: `a` y `b` apuntan al mismo. Incrementar por `b` cambia el único contador que hay.
:::
