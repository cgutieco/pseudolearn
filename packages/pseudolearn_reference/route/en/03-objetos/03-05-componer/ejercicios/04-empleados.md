---
id: objetos.componer.empleados
leccion: objetos.componer
tipo: resolver
nivel: brote
obligatorio: true
titulo: Kiosk employees
---

::: enunciado
Read the name and the job of a person at the kiosk. If the job is `cajero` (cashier), they introduce themselves as «Hola, soy Ana y atiendo la caja»; with any other job, as «Hola, soy Ana».
:::

::: restriccion
A class `Empleado` with a method `Presentarse` and a class `Cajero` that inherits from it and overrides it.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-miembro | Cajero | Presentarse | publico | The method Presentarse is missing from the class Cajero.
```

::: pistas
1. What do both introductions have in common? What does the cashier add?
2. Look at the cashier of [the lesson](ruta:objetos.componer).
3. `Cajero` inherits from `Empleado` and its `Presentarse` uses the parent's with `Super`.
4. The main algorithm creates an `Empleado` or a `Cajero` depending on the job, and asks it to introduce itself. Close with the variant.
:::

::: variante
Add a `Repositor` who introduces themselves as `Hola, soy Beto y repongo los estantes`.
:::

::: docentes
Hidden cases: a similar but different job (`cajera`), another cashier and another job. Frequent mistake: copying the greeting text instead of calling `Super`.
:::
