---
id: objetos.componer.empleados
leccion: objetos.componer
tipo: resolver
nivel: brote
obligatorio: true
titulo: Kiosk employees
---

::: enunciado
Read the name and the job of a person at the kiosk. If the job is `cashier`, they introduce themselves as «Hello, I am Ana and I work the till»; with any other job, as «Hello, I am Ana».
:::

::: restriccion
A class `Employee` with a method `Introduce` and a class `Cashier` that inherits from it and overrides it.
:::

```programa rol=referencia
Clase Employee
  Definir name Como Cadena;

  Metodo Constructor(n Como Cadena)
    Este.name <- n;
  FinMetodo

  Metodo Introduce() Como Cadena
    Retornar "Hello, I am " + Este.name;
  FinMetodo
FinClase

Clase Cashier Hereda De Employee
  Metodo Constructor(n Como Cadena)
    Super.Constructor(n);
  FinMetodo

  Metodo Introduce() Como Cadena
    Retornar Super.Introduce() + " and I work the till";
  FinMetodo
FinClase

Algoritmo Kiosk
  Definir name, job Como Cadena;
  Leer name;
  Leer job;
  Definir person Como Employee <- Nuevo Employee(name);
  Si job = "cashier" Entonces
    person <- Nuevo Cashier(name);
  FinSi
  Escribir person.Introduce();
FinAlgoritmo
```

```casos
visible | Ana ; cashier | Hello, I am Ana and I work the till
visible | Beto ; stocker | Hello, I am Beto
oculto | Caro ; cashiers | Hello, I am Caro
oculto | Dani ; cashier | Hello, I am Dani and I work the till
oculto | Eva ; courier | Hello, I am Eva
```

```aserciones
- declara-miembro | Cashier | Introduce | publico | The method Introduce is missing from the class Cashier.
```

::: pistas
1. What do both introductions have in common? What does the cashier add?
2. Look at the cashier of [the lesson](ruta:objetos.componer).
3. `Cashier` inherits from `Employee` and its `Introduce` uses the parent's with `Super`.
4. The main algorithm creates an `Employee` or a `Cashier` depending on the job, and asks it to introduce itself. Close with the variant.
:::

::: variante
Add a `Stocker` who introduces themselves as `Hello, I am Beto and I restock the shelves`.
:::

::: explicacion
Hidden cases: a similar but different job (`cashiers`), another cashier and another job. Frequent mistake: copying the greeting text instead of calling `Super`.
:::
