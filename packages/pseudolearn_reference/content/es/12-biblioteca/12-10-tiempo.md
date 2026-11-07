---
id: biblioteca.tiempo
numero: "12.10"
tipo: concepto
titulo: Tiempo y fechas
anclas: [LIB.TIME#R1, LIB.TIME#R2, LIB.TIME#R3, LIB.TIME#R4, LIB.TIME#R5, LIB.TIME#R6, LIB.TIME#R7, LIB.TIME#R8]
diagnosticos: [incompatiblePropagationType]
terminos: [instante, desplazamiento UTC, FechaHora]
---

::: frase
El reloj da instantes en nanosegundos, el temporizador espera, y `FechaHora` convierte un instante en año, mes, día y hora sin depender de la máquina.
:::

## Cómo funciona {#funciona}

Hay dos partes:

- **Con capacidad**: `Reloj` lee la hora del anfitrión (`Ahora`, `AhoraLocal`) y `Temporizador` espera un tiempo (`Esperar`). Cada lectura se graba, así que una ejecución repetida devuelve los mismos instantes.
- **Sin capacidad**: `FechaHora` es un valor que guarda un instante y un desplazamiento UTC. Se crea con `FechaHoraDe`, `FechaHoraUtc` o `AnalizarFechaHora`, y de él se sacan sus partes y su texto ISO 8601.

```figura id=fecha-hora
pie: Una `FechaHora` guarda un instante y un desplazamiento. Sus partes se calculan sobre la hora local que resulta de sumarlos.
```

```programa id=fechas titulo="Construir y mostrar fechas" ejecutar
Algoritmo Fechas
  Segun FechaHoraDe(2026, 11, 7, 18, 30, 0, 0, 3600) Hacer
    Algo(cita):
      Escribir cita.FormatoIso(), " ", cita.DiaDeLaSemana();
    Nada:
      Escribir "fecha inválida";
  FinSegun
  Segun FechaHoraDe(2026, 2, 30, 0, 0, 0, 0, 0) Hacer
    Algo(otra): Escribir otra.FormatoIso();
    Nada: Escribir "el 30 de febrero no existe";
  FinSegun
  Escribir FechaHoraUtc(0).FormatoIso();
FinAlgoritmo
```

```salida
2026-11-07T18:30:00+01:00 6
el 30 de febrero no existe
1970-01-01T00:00:00Z
```

`DiaDeLaSemana` sigue ISO 8601: 1 es lunes y 7 domingo. El calendario es el gregoriano sin segundos intercalares.

```programa id=pausa titulo="Medir una espera" ejecutar
SubProceso PausaCorta() Como Resultado<Entero, ErrorES>
  Definir reloj Como Reloj <- Propagar SolicitarReloj();
  Definir temporizador Como Temporizador <- Propagar SolicitarTemporizador();
  Definir antes Como Entero <- Propagar reloj.Ahora();
  Definir despues Como Entero <- Propagar temporizador.Esperar(2000000000);
  Retornar Exito(despues - antes);
FinSubProceso

Algoritmo Pausa
  Segun PausaCorta() Hacer
    Exito(nanosegundos): Escribir nanosegundos / 1000000000;
    Error(problema): Escribir problema.Codigo;
  FinSegun
FinAlgoritmo
```

```anfitrion
{"clock": [1781537400000000000], "grabar_y_reproducir": true}
```

```salida
2.0
```

::: limite
- Las fechas inválidas no fallan: `FechaHoraDe` devuelve `Nada`.
- El desplazamiento UTC va de -18 a +18 horas, en segundos.
:::

::: resumen
- `Reloj` y `Temporizador` son capacidades; sus lecturas se graban.
- `FechaHora` es un valor puro con instante y desplazamiento.
- Las partes y el texto ISO se calculan sin depender de la máquina.
:::

::: vease
- [Efectos y capacidades](#tareas.efectos)
- [Determinismo](#vision.determinismo)
:::
