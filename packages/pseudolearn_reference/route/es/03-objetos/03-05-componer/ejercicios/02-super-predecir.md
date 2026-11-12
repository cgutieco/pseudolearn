---
id: objetos.componer.super-predecir
leccion: objetos.componer
tipo: predecir
nivel: semilla
obligatorio: false
titulo: El saludo del cajero
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
Clase Empleado
  Definir nombre Como Cadena;

  Metodo Constructor(n Como Cadena)
    Este.nombre <- n;
  FinMetodo

  Metodo Presentarse() Como Cadena
    Retornar "Hola, soy " + Este.nombre;
  FinMetodo
FinClase

Clase Cajero Hereda De Empleado
  Metodo Constructor(n Como Cadena)
    Super.Constructor(n);
  FinMetodo

  Metodo Presentarse() Como Cadena
    Retornar Super.Presentarse() + " y atiendo la caja";
  FinMetodo
FinClase

Algoritmo Saludos
  Definir caja Como Empleado <- Nuevo Cajero("Eva");
  Escribir caja.Presentarse();
  Definir mostrador Como Empleado <- Nuevo Empleado("Fede");
  Escribir mostrador.Presentarse();
FinAlgoritmo
```

```salida
Hola, soy Eva y atiendo la caja
Hola, soy Fede
```

::: explicacion
`caja` es un `Cajero`: se ejecuta su `Presentarse`, que llama con `Super` al de `Empleado` y le agrega su parte. `mostrador` es un `Empleado` y usa el método original.
:::
