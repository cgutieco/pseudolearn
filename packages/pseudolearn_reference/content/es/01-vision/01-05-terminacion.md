---
id: vision.terminacion
numero: "1.5"
tipo: concepto
titulo: Cómo termina un programa
anclas: [ENG.EXEC.MODEL#R1, ENG.EXEC.MODEL#R3, ENG.INPUT#R1, RT.PROCESS#R2]
diagnosticos: [divisionByZero]
terminos: [terminación, suspensión]
---

::: frase
Toda ejecución acaba en uno de seis estados: terminó bien, falló, espera una entrada, espera al mundo exterior, fue cancelada o agotó un límite.
:::

## Cómo funciona {#funciona}

Cuando un programa deja de avanzar, el motor dice exactamente por qué. Ese motivo se llama **terminación** y siempre es uno de estos seis:

| Terminación | Qué significa | ¿Puede seguir? |
|---|---|---|
| `completed` | El proceso llegó a su `FinProceso` | No: terminó |
| `failed` | Un fallo de ejecución lo detuvo | No |
| `awaiting_input` | Un `Leer` necesita un valor que aún no llegó | Sí, al recibirlo |
| `awaiting_effect` | Espera la respuesta de un archivo, reloj o red | Sí, al recibirla |
| `cancelled` | Quien lo ejecutaba lo detuvo | No |
| `limit_reached` | Agotó un presupuesto de sentencias, memoria o profundidad | No |

```figura id=terminaciones
pie: Desde «ejecutando» se llega a uno de seis estados. Dos de ellos son pausas de las que se puede volver.
```

El caso normal es `completed`:

```programa id=bien titulo="Termina con normalidad" ejecutar
Proceso Bien
  Escribir "Fin del programa";
FinProceso
```

```salida
Fin del programa
```

Un fallo de ejecución detiene el programa en la sentencia exacta. Lo que ya se escribió se conserva:

```programa id=falla titulo="Termina por un fallo" ejecutar termina=failed
Proceso Falla
  Definir divisor Como Entero <- 0;
  Escribir "Antes del fallo";
  Escribir 10 div divisor;
  Escribir "Esto nunca se escribe";
FinProceso
```

```salida
Antes del fallo
```

```diagnosticos
divisionByZero
```

Si un `Leer` no recibe valor, el programa queda en pausa. El editor te pide el dato y la ejecución continúa donde se quedó:

```programa id=espera titulo="Espera una entrada" ejecutar termina=awaiting_input
Proceso Espera
  Definir edad Como Entero <- 0;
  Escribir "¿Cuántos años tienes?";
  Leer edad;
  Escribir "El año que viene tendrás ", edad + 1;
FinProceso
```

```salida
¿Cuántos años tienes?
```

::: limite
Las terminaciones `completed`, `failed`, `cancelled` y `limit_reached` son definitivas: después de ellas no ocurre ningún efecto más. Las pausas `awaiting_input` y `awaiting_effect` se reanudan exactamente en la sentencia donde se detuvieron.
:::

::: resumen
- Seis terminaciones posibles; solo `completed` significa que todo fue bien.
- Un fallo detiene el programa en la sentencia exacta y conserva lo ya escrito.
- `awaiting_input` y `awaiting_effect` son pausas que se reanudan.
:::

::: vease
- [Errores, advertencias y fallos](#vision.errores)
- [Orden de los efectos y la cinta](#motor.efectos)
- [Límites de ejecución](#motor.limites)
:::
