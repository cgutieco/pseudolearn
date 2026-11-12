---
id: objetos.invariantes.termostato
leccion: objetos.invariantes
tipo: resolver
nivel: arbol
obligatorio: false
titulo: El termostato del aula
---

::: enunciado
El termostato del aula empieza en 20 grados y nunca puede pasar de 30 ni bajar de 16. Lee órdenes, `+` para subir un grado y `-` para bajarlo, hasta la palabra `fin`, y muestra los grados finales.
:::

::: restriccion
Una clase `Termostato` con los grados privados y los métodos `Subir`, `Bajar` y `Grados`.
:::

```programa rol=referencia
Clase Termostato
  Privado Definir grados Como Entero;

  Metodo Constructor()
    Este.grados <- 20;
  FinMetodo

  Metodo Subir()
    Si Este.grados < 30 Entonces
      Este.grados <- Este.grados + 1;
    FinSi
  FinMetodo

  Metodo Bajar()
    Si Este.grados > 16 Entonces
      Este.grados <- Este.grados - 1;
    FinSi
  FinMetodo

  Metodo Grados() Como Entero
    Retornar Este.grados;
  FinMetodo
FinClase

Algoritmo Aula
  Definir aparato Como Termostato <- Nuevo Termostato();
  Definir orden Como Cadena;
  Leer orden;
  Mientras orden <> "fin" Hacer
    Si orden = "+" Entonces
      aparato.Subir();
    Sino
      aparato.Bajar();
    FinSi
    Leer orden;
  FinMientras
  Escribir aparato.Grados();
FinAlgoritmo
```

```casos
visible | + ; + ; fin | 22
visible | - ; fin | 19
oculto | + ; + ; + ; + ; + ; + ; + ; + ; + ; + ; + ; + ; fin | 30
oculto | - ; - ; - ; - ; - ; - ; fin | 16
oculto | fin | 20
oculto | + ; + ; + ; + ; + ; + ; + ; + ; + ; + ; + ; + ; - ; fin | 29
```

```aserciones
- declara-miembro | Termostato | grados | privado | Los grados del termostato tienen que ser privados.
```

::: pistas
1. ¿Qué tiene que ser cierto siempre del termostato?
2. Es la tarjeta de [la lección](ruta:objetos.invariantes): cada método cuida el invariante.
3. `Subir` solo sube si todavía no llegó a 30; `Bajar`, si no llegó a 16.
4. Un atributo privado que empieza en 20 y dos métodos que comprueban el límite antes de cambiarlo. Cierra con la variante.
:::

::: variante
Agrega `Fijar(grados)`, que acepta solo valores dentro del rango.
:::

::: explicacion
Casos ocultos: subir más allá de 30, bajar más allá de 16, ninguna orden y bajar después de tocar el techo.
:::
