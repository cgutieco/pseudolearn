---
id: objetos.invariantes.termostato
leccion: objetos.invariantes
tipo: resolver
nivel: arbol
obligatorio: false
titulo: The classroom thermostat
---

::: enunciado
The classroom thermostat starts at 20 degrees and can never go above 30 or below 16. Read orders, `+` to go up a degree and `-` to go down, until the word `end`, and show the final degrees.
:::

::: restriccion
A class `Thermostat` with private degrees and the methods `Raise`, `Lower` and `Degrees`.
:::

```programa rol=referencia
Clase Thermostat
  Privado Definir degrees Como Entero;

  Metodo Constructor()
    Este.degrees <- 20;
  FinMetodo

  Metodo Raise()
    Si Este.degrees < 30 Entonces
      Este.degrees <- Este.degrees + 1;
    FinSi
  FinMetodo

  Metodo Lower()
    Si Este.degrees > 16 Entonces
      Este.degrees <- Este.degrees - 1;
    FinSi
  FinMetodo

  Metodo Degrees() Como Entero
    Retornar Este.degrees;
  FinMetodo
FinClase

Algoritmo Classroom
  Definir device Como Thermostat <- Nuevo Thermostat();
  Definir command Como Cadena;
  Leer command;
  Mientras command <> "end" Hacer
    Si command = "+" Entonces
      device.Raise();
    Sino
      device.Lower();
    FinSi
    Leer command;
  FinMientras
  Escribir device.Degrees();
FinAlgoritmo
```

```casos
visible | + ; + ; end | 22
visible | - ; end | 19
oculto | + ; + ; + ; + ; + ; + ; + ; + ; + ; + ; + ; + ; end | 30
oculto | - ; - ; - ; - ; - ; - ; end | 16
oculto | end | 20
oculto | + ; + ; + ; + ; + ; + ; + ; + ; + ; + ; + ; + ; - ; end | 29
```

```aserciones
- declara-miembro | Thermostat | degrees | privado | The degrees of the thermostat have to be private.
```

::: pistas
1. What always has to be true of the thermostat?
2. It is the card of [the lesson](ruta:objetos.invariantes): each method looks after the invariant.
3. `Raise` only goes up if it has not reached 30 yet; `Lower`, if it has not reached 16.
4. A private attribute that starts at 20 and two methods that check the limit before changing it. Close with the variant.
:::

::: variante
Add `Set(degrees)`, which accepts only values inside the range.
:::

::: explicacion
Hidden cases: going up past 30, going down past 16, no orders and going down after touching the ceiling.
:::
