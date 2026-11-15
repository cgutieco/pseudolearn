---
id: objetos.componer.super-predecir
leccion: objetos.componer
tipo: predecir
nivel: semilla
obligatorio: false
titulo: The cashier's greeting
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
Clase Employee
  Definir name Como Cadena;

  Metodo Constructor(employeeName Como Cadena)
    Este.name <- employeeName;
  FinMetodo

  Metodo Introduce() Como Cadena
    Retornar "Hello, I am " + Este.name;
  FinMetodo
FinClase

Clase Cashier Hereda De Employee
  Metodo Constructor(employeeName Como Cadena)
    Super.Constructor(employeeName);
  FinMetodo

  Metodo Introduce() Como Cadena
    Retornar Super.Introduce() + " and I work the till";
  FinMetodo
FinClase

Algoritmo Greetings
  Definir till Como Employee <- Nuevo Cashier("Eva");
  Escribir till.Introduce();
  Definir counter Como Employee <- Nuevo Employee("Fede");
  Escribir counter.Introduce();
FinAlgoritmo
```

```salida
Hello, I am Eva and I work the till
Hello, I am Fede
```

::: explicacion
`till` is a `Cashier`: its `Introduce` runs, which calls the one of `Employee` with `Super` and adds its part. `counter` is an `Employee` and uses the original method.
:::
