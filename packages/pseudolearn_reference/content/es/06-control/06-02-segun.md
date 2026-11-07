---
id: control.segun
numero: "6.2"
tipo: construccion
titulo: "Selección múltiple con `Segun`"
anclas: [LANG.CONTROL.SWITCH#R1, LANG.CONTROL.SWITCH#R2]
fichas: [help.switch]
diagnosticos: [nonExhaustiveSwitch, duplicateSwitchCaseLabel, incompatibleSwitchCaseType, unreachableSwitchPattern]
terminos: [selector, etiqueta, exhaustividad]
---

::: frase
`Segun` mira un valor una sola vez y salta directamente a la rama cuya etiqueta coincide.
:::

## Cómo se escribe {#escribe}

```forma
Segun «selector» Hacer
  «etiqueta», «etiqueta»:
    «instrucciones»
  ⟦De Otro Modo:
    «instrucciones»⟧
FinSegun
```

```railes produccion=switch
```

::: partes
- `Segun` abre la selección y «selector» es el valor que se mira: un entero, un enumerado o una variante.
- `Hacer` separa el selector de las ramas.
- Cada rama empieza con una o varias «etiquetas» separadas por comas y termina la cabecera con `:`.
- `De Otro Modo:` es opcional, única y va al final. Recoge lo que no coincide con ninguna etiqueta.
- `FinSegun` cierra la selección.
:::

## Cómo funciona {#funciona}

El selector se calcula **una vez**. Después se busca la rama con esa etiqueta, se ejecuta y se sale: no hay «caída» a la rama siguiente. Si ninguna coincide y no hay `De Otro Modo`, no se hace nada.

```programa id=dia-semana titulo="¿Hay clase hoy?" ejecutar
Algoritmo DiaSemana
  Definir dia Como Entero <- 6;
  Segun dia Hacer
    1, 2, 3, 4, 5:
      Escribir "Hay clase";
    6, 7:
      Escribir "Fin de semana";
    De Otro Modo:
      Escribir "Ese día no existe";
  FinSegun
FinAlgoritmo
```

```salida
Fin de semana
```

```figura id=segun-ramas
pie: El selector vale 6, así que el motor salta a la rama que contiene esa etiqueta. Las demás ni se miran.
paso: Se calcula el selector una sola vez: `dia` vale 6.
paso: El 6 está en la segunda rama: se ejecuta su `Escribir`.
paso: Al terminar la rama se sale del `Segun`, sin pasar por las demás.
```

Las etiquetas son **literales enteros** (con signo si hace falta) o **miembros de un enumerado**. Reales, caracteres, textos y lógicos no valen como selector. Una etiqueta no puede repetirse.

## Con enumerados {#enumerados}

Si el selector es un enumerado, las ramas tienen que cubrir **todos** sus miembros, o incluir `De Otro Modo`. Así el motor avisa cuando se añade un miembro nuevo y se olvida tratarlo.

```programa id=cruce titulo="Un semáforo incompleto" ejecutar
Enumerado Semaforo
  Rojo, Ambar, Verde
FinEnumerado
Algoritmo Cruce
  Definir luz Como Semaforo <- Semaforo.Ambar;
  Segun luz Hacer
    Semaforo.Rojo:
      Escribir "Para";
    Semaforo.Verde:
      Escribir "Pasa";
  FinSegun
FinAlgoritmo
```

```diagnosticos
nonExhaustiveSwitch
```

El mensaje nombra los miembros que faltan, en el orden en que se declararon. `Segun` también sirve para abrir variantes como `Opcional` y `Resultado`: está explicado en [Opcional y Resultado](#tipos.opcional-resultado).

::: errores
```programa id=etiqueta-repetida titulo="Una etiqueta repetida" ejecutar
Algoritmo Repetida
  Definir n Como Entero <- 1;
  Segun n Hacer
    1:
      Escribir "uno";
    1:
      Escribir "otra vez uno";
  FinSegun
FinAlgoritmo
```

```diagnosticos
duplicateSwitchCaseLabel
```

```programa id=segun-texto titulo="Un selector de texto" ejecutar
Algoritmo TextoSel
  Definir t Como Cadena <- "a";
  Segun t Hacer
    "a":
      Escribir "a";
  FinSegun
FinAlgoritmo
```

```diagnosticos
incompatibleSwitchCaseType
```
:::

::: por-dentro
El selector se guarda en un temporal y cada rama es una comparación con salto. Como no hay caída, al final de cada rama hay un salto directo al bloque que sigue a `FinSegun`.

```ri programa=dia-semana
```
:::

::: docentes
`Segun` y una cadena de `Si` anidados hacen lo mismo con valores concretos. Pide reescribir `dia-semana` con `Si` y comparar cuál se lee mejor y cuál detecta antes un olvido.
:::

::: resumen
- `Segun` calcula el selector una vez y ejecuta una sola rama.
- Etiquetas: enteros o miembros de enumerado, sin repetir.
- No hay caída entre ramas; `De Otro Modo` es opcional.
- Con enumerados, las ramas deben cubrir todos los miembros.
:::

::: vease
- [La decisión Si](#control.si)
- [Enumerados](#tipos.enumerados)
- [Opcional y Resultado](#tipos.opcional-resultado)
:::
