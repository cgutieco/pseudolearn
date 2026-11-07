---
id: control.salir
numero: "6.7"
tipo: construccion
titulo: "Salir de un bucle"
anclas: [LANG.CONTROL.EXIT#R1]
fichas: [construction.break]
diagnosticos: [breakOutsideLoop]
terminos: [salida anticipada]
---

::: frase
`Salir` termina en el acto el bucle que lo contiene, aunque su condición todavía permita seguir.
:::

## Cómo se escribe {#escribe}

```forma
Salir;
```

```railes produccion=breakStatement contextuales=Salir
```

::: partes
- `Salir` es una sentencia simple y termina con `;`.
- Solo vale dentro de `Mientras`, `Repetir`, `Para` o `Para Cada`.
:::

## Cómo funciona {#funciona}

`Salir` abandona el bucle **más interior** que lo contiene y el programa sigue después de su cierre. Es útil cuando se busca algo: en cuanto aparece, no hace falta seguir mirando.

```programa id=primero-mayor titulo="Buscar el primero que cumple" ejecutar
Algoritmo Buscar
  Dimension numeros[5] Como Entero;
  Para i <- 0 Hasta 4 Hacer
    numeros[i] <- (i + 1) * 7;
  FinPara
  Para Cada n En numeros Hacer
    Si n > 15 Entonces
      Escribir "Primero mayor que 15: ", n;
      Salir;
    FinSi
    Escribir "Reviso ", n;
  FinPara
FinAlgoritmo
```

```salida
Reviso 7
Reviso 14
Primero mayor que 15: 21
```

```figura id=salir-corte
pie: `Salir` corta el bucle en la tercera vuelta. Las casillas 28 y 35 nunca se visitan.
```

Si dentro del bucle hay limpiezas registradas con [`Diferir`](#control.diferir), se ejecutan al salir. No existe una palabra para «saltar a la vuelta siguiente».

::: errores
```programa id=salir-fuera titulo="Salir fuera de un bucle" ejecutar
Algoritmo FueraBucle
  Salir;
FinAlgoritmo
```

```diagnosticos
breakOutsideLoop
```
:::

::: por-dentro
`Salir` es un salto directo al bloque que sigue al bucle. En la representación intermedia se ve como un `jump` dentro del bloque de la rama verdadera.

```ri programa=primero-mayor
```
:::

::: resumen
- `Salir` termina el bucle más interior.
- Solo vale dentro de un bucle.
- Ejecuta las limpiezas pendientes del bucle.
:::

::: vease
- [Para Cada](#control.para-cada)
- [Diferir](#control.diferir)
- [Retornar](#subprogramas.retornar)
:::
