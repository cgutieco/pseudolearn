---
id: procedimental.puras.es-bisiesto
leccion: procedimental.puras
tipo: resolver
nivel: brote
obligatorio: false
titulo: ¿Es bisiesto?, como función
---

::: enunciado
Lee un año y muestra «Es bisiesto» o «No es bisiesto». La regla es la de [la lección 1.2](ruta:imperativo.caminos).
:::

::: restriccion
La decisión va en una `Funcion EsBisiesto` que recibe el año y retorna un valor lógico.
:::

```programa rol=referencia
Funcion bisiesto <- EsBisiesto(anio Como Entero)
  Definir bisiesto Como Logico;
  bisiesto <- (anio mod 4 = 0 Y anio mod 100 <> 0) O anio mod 400 = 0;
FinFuncion

Algoritmo Principal
  Definir anio Como Entero;
  Leer anio;
  Si EsBisiesto(anio) Entonces
    Escribir "Es bisiesto";
  Sino
    Escribir "No es bisiesto";
  FinSi
FinAlgoritmo
```

```casos
visible | 2024 | Es bisiesto
visible | 2023 | No es bisiesto
oculto | 1900 | No es bisiesto
oculto | 2000 | Es bisiesto
oculto | 2100 | No es bisiesto
```

```aserciones
- declara-subprograma | EsBisiesto | 1 | Falta la función EsBisiesto, que recibe el año.
```

::: pistas
1. ¿Qué entra a la pieza y qué sale? ¿Qué tipo tiene lo que sale?
2. La condición es la de [la lección 1.2](ruta:imperativo.caminos); aquí va dentro de una función.
3. La función retorna verdadero o falso; el principal decide qué mostrar.
4. La caja del resultado es `Logico` y guarda la condición compuesta. Cierra con la variante.
:::

::: variante
Escribe `DiasDelAnio(anio)`, que retorna 366 o 365 usando `EsBisiesto`.
:::

::: docentes
Casos ocultos: las dos excepciones y 2100. Error frecuente: mostrar el texto dentro de la función, que el motor rechaza.
:::
