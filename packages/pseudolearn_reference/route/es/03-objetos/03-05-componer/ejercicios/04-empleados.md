---
id: objetos.componer.empleados
leccion: objetos.componer
tipo: resolver
nivel: brote
obligatorio: true
titulo: Empleados del kiosco
---

::: enunciado
Lee el nombre y el puesto de una persona del kiosco. Si el puesto es `cajero`, se presenta como «Hola, soy Ana y atiendo la caja»; con cualquier otro puesto, como «Hola, soy Ana».
:::

::: restriccion
Una clase `Empleado` con un método `Presentarse` y una clase `Cajero` que hereda de ella y lo sobrescribe.
:::

```programa rol=referencia
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

Algoritmo Kiosco
  Definir nombre, puesto Como Cadena;
  Leer nombre;
  Leer puesto;
  Definir persona Como Empleado <- Nuevo Empleado(nombre);
  Si puesto = "cajero" Entonces
    persona <- Nuevo Cajero(nombre);
  FinSi
  Escribir persona.Presentarse();
FinAlgoritmo
```

```casos
visible | Ana ; cajero | Hola, soy Ana y atiendo la caja
visible | Beto ; repositor | Hola, soy Beto
oculto | Caro ; cajera | Hola, soy Caro
oculto | Dani ; cajero | Hola, soy Dani y atiendo la caja
oculto | Eva ; repartidor | Hola, soy Eva
```

```aserciones
- declara-miembro | Cajero | Presentarse | publico | Falta el método Presentarse en la clase Cajero.
```

::: pistas
1. ¿Qué tienen en común las dos presentaciones? ¿Qué agrega el cajero?
2. Repasa el cajero de [la lección](ruta:objetos.componer).
3. `Cajero` hereda de `Empleado` y su `Presentarse` usa el de la madre con `Super`.
4. El principal crea un `Empleado` o un `Cajero` según el puesto, y le pide presentarse. Cierra con la variante.
:::

::: variante
Agrega un `Repositor` que se presenta como `Hola, soy Beto y repongo los estantes`.
:::

::: docentes
Casos ocultos: un puesto parecido pero distinto (`cajera`), otro cajero y otro puesto. Error frecuente: copiar el texto del saludo en lugar de llamar a `Super`.
:::
