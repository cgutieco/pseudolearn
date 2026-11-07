---
{
  "formato": "see/1",
  "id": "LIB.TIME",
  "titulo": "Operaciones de tiempo y temporizador",
  "dominio": "biblioteca",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Consulta de reloj grabado y temporizador lógico determinista.",
  "titulo_en": "Time and timer operations",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.CAPABILITY.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-pg3"
  ]
}
---

# Operaciones de tiempo y temporizador

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "En vivo, cada consulta de Reloj lee el reloj del sistema del anfitrión y devuelve nanosegundos desde la época Unix. Cada lectura se graba en la cinta. En reproducción se devuelve la lectura grabada sin consultar al reloj físico; el tiempo de presentación nunca decide la agenda.",
  "verificacion": [
    "C1",
    "C3",
    "C18",
    "C19"
  ]
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "100\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nRetornar clock.Ahora();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine clock as Clock <- propagate requestClock();\nreturn clock.now();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "clock": [
      100,
      200
    ],
    "grabar_y_reproducir": true
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "En vivo, Temporizador espera la duración real solicitada en nanosegundos sin impedir que otras tareas listas avancen ni bloquear la interfaz. Al terminar entrega el instante real, que se graba en la cinta. La cancelación interrumpe la espera. En reproducción entrega el resultado grabado sin esperar tiempo físico.",
  "verificacion": [
    "C2",
    "C4",
    "C5"
  ]
}
```

```caso
{
  "id": "C2",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "50\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Temporizador <- Propagar SolicitarTemporizador();\nRetornar clock.Esperar(50);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine clock as Timer <- propagate requestTimer();\nreturn clock.wait(50);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "100\n200\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "recursos_abiertos": 0
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nDefinir first Como Entero <- Propagar clock.Ahora();\nEscribir first;\nRetornar clock.Ahora();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine clock as Clock <- propagate requestClock();\ndefine first as integer <- propagate clock.now();\nwrite first;\nreturn clock.now();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "clock": [
      100,
      200,
      300
    ],
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "100\n150\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 4,
      "recursos_abiertos": 0
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nDefinir timer Como Temporizador <- Propagar SolicitarTemporizador();\nDefinir first Como Entero <- Propagar clock.Ahora();\nEscribir first;\nRetornar timer.Esperar(50);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine clock as Clock <- propagate requestClock();\ndefine timer as Timer <- propagate requestTimer();\ndefine first as integer <- propagate clock.now();\nwrite first;\nreturn timer.wait(50);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "clock": [
      100
    ],
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C5",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2,
      "recursos_abiertos": 0
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir timer Como Temporizador <- Propagar SolicitarTemporizador();\nRetornar timer.Esperar(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine timer as Timer <- propagate requestTimer();\nreturn timer.wait(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "grabar_y_reproducir": true
  }
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "FechaHora es un valor opaco, inmutable y comparable por sus componentes que combina un instante, en nanosegundos desde la época Unix 1970-01-01T00:00:00Z como entero de 64 bits, y un desplazamiento UTC en segundos. El calendario es el gregoriano proléptico sin segundos intercalares. Los instantes representables van de 1677-09-21T00:12:43.145224192Z a 2262-04-11T23:47:16.854775807Z. FechaHoraUtc(instante) construye el valor con desplazamiento cero, Instante devuelve el instante y DesplazamientoUtc el desplazamiento. Es una función pura: no consulta al anfitrión ni se graba en la cinta.",
  "verificacion": [
    "C6",
    "C21"
  ]
}
```

```caso
{
  "id": "C6",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1970-01-01T00:00:00Z\n1970-01-01T00:00:00.000000001Z\n1969-12-31T23:59:59.999999999Z\n2262-04-11T23:47:16.854775807Z\n1677-09-21T00:12:43.145224192Z\n123 0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "Algoritmo P\nEscribir FechaHoraUtc(0).FormatoIso();\nEscribir FechaHoraUtc(1).FormatoIsoPreciso();\nEscribir FechaHoraUtc(-1).FormatoIsoPreciso();\nEscribir FechaHoraUtc(9223372036854775807).FormatoIsoPreciso();\nEscribir FechaHoraUtc(-9223372036854775807 - 1).FormatoIsoPreciso();\nEscribir FechaHoraUtc(123).Instante(), \" \", FechaHoraUtc(123).DesplazamientoUtc();\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite dateTimeUtc(0).isoFormat();\nwrite dateTimeUtc(1).isoFormatPrecise();\nwrite dateTimeUtc(-1).isoFormatPrecise();\nwrite dateTimeUtc(9223372036854775807).isoFormatPrecise();\nwrite dateTimeUtc(-9223372036854775807 - 1).isoFormatPrecise();\nwrite dateTimeUtc(123).instant(), \" \", dateTimeUtc(123).utcOffset();\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "FechaHoraDe(año, mes, día, hora, minuto, segundo, nanosegundo, desplazamiento) interpreta los componentes como hora local con el desplazamiento dado en segundos y devuelve Algo(FechaHora), o Nada ante cualquier componente inválido: mes fuera de 1 a 12, día fuera del mes según el calendario gregoriano proléptico (bisiesto si es divisible por 4 y no por 100, o si lo es por 400, de modo que 1900 y 2100 no lo son y 2000 sí), hora fuera de 0 a 23, minuto fuera de 0 a 59, segundo fuera de 0 a 59 (el segundo 60 se rechaza), nanosegundo fuera de 0 a 999999999, desplazamiento que no sea múltiplo de 60 o que quede fuera de -43200 a 50400 (de -12:00 a +14:00), o instante resultante fuera del rango de R3. Es una función pura y total: nunca falla ni se detiene.",
  "verificacion": [
    "C7",
    "C8",
    "C9",
    "C22"
  ]
}
```

```caso
{
  "id": "C7",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2024-02-29T12:30:45.123456789Z\nnone\nnone\n2000-02-29T00:00:00.000000000Z\nnone\nnone\nnone\nnone\nnone\nnone\nnone\nnone\nnone\nnone\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Presentar(valor Como Opcional<FechaHora>)\nSegun valor Hacer\nNada: Escribir \"none\";\nAlgo(fecha): Escribir fecha.FormatoIsoPreciso();\nFinSegun\nFinSubProceso\nAlgoritmo P\nPresentar(FechaHoraDe(2024, 2, 29, 12, 30, 45, 123456789, 0));\nPresentar(FechaHoraDe(2023, 2, 29, 0, 0, 0, 0, 0));\nPresentar(FechaHoraDe(1900, 2, 29, 0, 0, 0, 0, 0));\nPresentar(FechaHoraDe(2000, 2, 29, 0, 0, 0, 0, 0));\nPresentar(FechaHoraDe(2100, 2, 29, 0, 0, 0, 0, 0));\nPresentar(FechaHoraDe(2026, 4, 31, 0, 0, 0, 0, 0));\nPresentar(FechaHoraDe(2026, 0, 10, 0, 0, 0, 0, 0));\nPresentar(FechaHoraDe(2026, 13, 10, 0, 0, 0, 0, 0));\nPresentar(FechaHoraDe(2026, 1, 0, 0, 0, 0, 0, 0));\nPresentar(FechaHoraDe(2026, 1, 1, 24, 0, 0, 0, 0));\nPresentar(FechaHoraDe(2026, 1, 1, 0, 60, 0, 0, 0));\nPresentar(FechaHoraDe(2026, 1, 1, 0, 0, 60, 0, 0));\nPresentar(FechaHoraDe(2026, 1, 1, 0, 0, 0, 1000000000, 0));\nPresentar(FechaHoraDe(2026, 1, 1, 0, 0, 0, -1, 0));\nFinAlgoritmo\n",
    "en": "subroutine Show(value as optional<DateTime>)\nswitch value do\nnone: write \"none\";\nsome(moment): write moment.isoFormatPrecise();\nendSwitch\nendSubroutine\nalgorithm P\nShow(dateTimeOf(2024, 2, 29, 12, 30, 45, 123456789, 0));\nShow(dateTimeOf(2023, 2, 29, 0, 0, 0, 0, 0));\nShow(dateTimeOf(1900, 2, 29, 0, 0, 0, 0, 0));\nShow(dateTimeOf(2000, 2, 29, 0, 0, 0, 0, 0));\nShow(dateTimeOf(2100, 2, 29, 0, 0, 0, 0, 0));\nShow(dateTimeOf(2026, 4, 31, 0, 0, 0, 0, 0));\nShow(dateTimeOf(2026, 0, 10, 0, 0, 0, 0, 0));\nShow(dateTimeOf(2026, 13, 10, 0, 0, 0, 0, 0));\nShow(dateTimeOf(2026, 1, 0, 0, 0, 0, 0, 0));\nShow(dateTimeOf(2026, 1, 1, 24, 0, 0, 0, 0));\nShow(dateTimeOf(2026, 1, 1, 0, 60, 0, 0, 0));\nShow(dateTimeOf(2026, 1, 1, 0, 0, 60, 0, 0));\nShow(dateTimeOf(2026, 1, 1, 0, 0, 0, 1000000000, 0));\nShow(dateTimeOf(2026, 1, 1, 0, 0, 0, -1, 0));\nendAlgorithm\n"
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2025-12-31T23:59:59.999999999Z\n2026-01-01T00:00:00.000000000Z\n1677-09-21T00:12:43.145224192Z\nnone\n2262-04-11T23:47:16.854775807Z\nnone\nnone\nnone\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Presentar(valor Como Opcional<FechaHora>)\nSegun valor Hacer\nNada: Escribir \"none\";\nAlgo(fecha): Escribir fecha.FormatoIsoPreciso();\nFinSegun\nFinSubProceso\nAlgoritmo P\nPresentar(FechaHoraDe(2025, 12, 31, 23, 59, 59, 999999999, 0));\nEscribir FechaHoraUtc(FechaHoraUtc(1767225599999999999).Instante() + 1).FormatoIsoPreciso();\nPresentar(FechaHoraDe(1677, 9, 21, 0, 12, 43, 145224192, 0));\nPresentar(FechaHoraDe(1677, 9, 21, 0, 12, 43, 145224191, 0));\nPresentar(FechaHoraDe(2262, 4, 11, 23, 47, 16, 854775807, 0));\nPresentar(FechaHoraDe(2262, 4, 11, 23, 47, 16, 854775808, 0));\nPresentar(FechaHoraDe(1600, 1, 1, 0, 0, 0, 0, 0));\nPresentar(FechaHoraDe(2300, 1, 1, 0, 0, 0, 0, 0));\nFinAlgoritmo\n",
    "en": "subroutine Show(value as optional<DateTime>)\nswitch value do\nnone: write \"none\";\nsome(moment): write moment.isoFormatPrecise();\nendSwitch\nendSubroutine\nalgorithm P\nShow(dateTimeOf(2025, 12, 31, 23, 59, 59, 999999999, 0));\nwrite dateTimeUtc(dateTimeUtc(1767225599999999999).instant() + 1).isoFormatPrecise();\nShow(dateTimeOf(1677, 9, 21, 0, 12, 43, 145224192, 0));\nShow(dateTimeOf(1677, 9, 21, 0, 12, 43, 145224191, 0));\nShow(dateTimeOf(2262, 4, 11, 23, 47, 16, 854775807, 0));\nShow(dateTimeOf(2262, 4, 11, 23, 47, 16, 854775808, 0));\nShow(dateTimeOf(1600, 1, 1, 0, 0, 0, 0, 0));\nShow(dateTimeOf(2300, 1, 1, 0, 0, 0, 0, 0));\nendAlgorithm\n"
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2026-06-15T12:00:00.000000000+14:00\n2026-06-15T12:00:00.000000000-12:00\n2026-06-15T12:00:00.000000000+05:30\nnone\nnone\nnone\n2026-06-15T12:00:00.000000000Z\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Presentar(valor Como Opcional<FechaHora>)\nSegun valor Hacer\nNada: Escribir \"none\";\nAlgo(fecha): Escribir fecha.FormatoIsoPreciso();\nFinSegun\nFinSubProceso\nAlgoritmo P\nPresentar(FechaHoraDe(2026, 6, 15, 12, 0, 0, 0, 50400));\nPresentar(FechaHoraDe(2026, 6, 15, 12, 0, 0, 0, -43200));\nPresentar(FechaHoraDe(2026, 6, 15, 12, 0, 0, 0, 19800));\nPresentar(FechaHoraDe(2026, 6, 15, 12, 0, 0, 0, 50460));\nPresentar(FechaHoraDe(2026, 6, 15, 12, 0, 0, 0, -43260));\nPresentar(FechaHoraDe(2026, 6, 15, 12, 0, 0, 0, 30));\nPresentar(FechaHoraDe(2026, 6, 15, 12, 0, 0, 0, 0));\nFinAlgoritmo\n",
    "en": "subroutine Show(value as optional<DateTime>)\nswitch value do\nnone: write \"none\";\nsome(moment): write moment.isoFormatPrecise();\nendSwitch\nendSubroutine\nalgorithm P\nShow(dateTimeOf(2026, 6, 15, 12, 0, 0, 0, 50400));\nShow(dateTimeOf(2026, 6, 15, 12, 0, 0, 0, -43200));\nShow(dateTimeOf(2026, 6, 15, 12, 0, 0, 0, 19800));\nShow(dateTimeOf(2026, 6, 15, 12, 0, 0, 0, 50460));\nShow(dateTimeOf(2026, 6, 15, 12, 0, 0, 0, -43260));\nShow(dateTimeOf(2026, 6, 15, 12, 0, 0, 0, 30));\nShow(dateTimeOf(2026, 6, 15, 12, 0, 0, 0, 0));\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Anio, Mes, Dia, Hora, Minuto, Segundo y Nanosegundo devuelven los componentes de la hora local, es decir, del instante desplazado por el desplazamiento UTC; DiaDeLaSemana devuelve el día de la semana local según ISO 8601, de 1 para lunes a 7 para domingo. Instante y DesplazamientoUtc devuelven los dos componentes almacenados, de modo que el instante no cambia con el desplazamiento. Son funciones puras y totales.",
  "verificacion": [
    "C10",
    "C11",
    "C24",
    "C25",
    "C26",
    "C27"
  ]
}
```

```caso
{
  "id": "C10",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1970 1 1 4\n6\n3\n4\n3\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "Algoritmo P\nDefinir fecha Como FechaHora <- FechaHoraUtc(0);\nEscribir fecha.Anio(), \" \", fecha.Mes(), \" \", fecha.Dia(), \" \", fecha.DiaDeLaSemana();\nEscribir FechaHoraUtc(946684800000000000).DiaDeLaSemana();\nEscribir FechaHoraUtc(-1).DiaDeLaSemana();\nEscribir FechaHoraUtc(1709208000000000000).DiaDeLaSemana();\nEscribir FechaHoraUtc(1793750400000000000).DiaDeLaSemana();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine moment as DateTime <- dateTimeUtc(0);\nwrite moment.year(), \" \", moment.month(), \" \", moment.day(), \" \", moment.weekday();\nwrite dateTimeUtc(946684800000000000).weekday();\nwrite dateTimeUtc(-1).weekday();\nwrite dateTimeUtc(1709208000000000000).weekday();\nwrite dateTimeUtc(1793750400000000000).weekday();\nendAlgorithm\n"
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2024 3 10 1 2 3 4 19800 1710012723000000004\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Presentar(valor Como Opcional<FechaHora>)\nSegun valor Hacer\nNada: Escribir \"none\";\nAlgo(fecha): Escribir fecha.FormatoIsoPreciso();\nFinSegun\nFinSubProceso\nAlgoritmo P\nDefinir fecha Como Opcional<FechaHora> <- FechaHoraDe(2024, 3, 10, 1, 2, 3, 4, 19800);\nSegun fecha Hacer\nNada: Escribir \"none\";\nAlgo(valor): Escribir valor.Anio(), \" \", valor.Mes(), \" \", valor.Dia(), \" \", valor.Hora(), \" \", valor.Minuto(), \" \", valor.Segundo(), \" \", valor.Nanosegundo(), \" \", valor.DesplazamientoUtc(), \" \", valor.Instante();\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Show(value as optional<DateTime>)\nswitch value do\nnone: write \"none\";\nsome(moment): write moment.isoFormatPrecise();\nendSwitch\nendSubroutine\nalgorithm P\ndefine moment as optional<DateTime> <- dateTimeOf(2024, 3, 10, 1, 2, 3, 4, 19800);\nswitch moment do\nnone: write \"none\";\nsome(value): write value.year(), \" \", value.month(), \" \", value.day(), \" \", value.hour(), \" \", value.minute(), \" \", value.second(), \" \", value.nanosecond(), \" \", value.utcOffset(), \" \", value.instant();\nendSwitch\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "FormatoIso devuelve la hora local en ISO 8601 extendido AAAA-MM-DDThh:mm:ss seguido del desplazamiento, Z cuando es cero y +hh:mm o -hh:mm en otro caso, sin fracción de segundo: descarta los nanosegundos. FormatoIsoPreciso añade siempre nueve dígitos de fracción tras el segundo. El año siempre usa cuatro dígitos, la T y la Z son mayúsculas y el resultado nunca depende de la configuración regional.",
  "verificacion": [
    "C12",
    "C28"
  ]
}
```

```caso
{
  "id": "C12",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2026-06-15T12:30:45+05:30\n2026-06-15T12:30:45.120000000+05:30\n2026-06-15T12:30:45-12:00\n2026-06-15T12:30:45+14:00\n2026-06-15T12:30:45Z\n2026-06-15T12:30:45-09:30\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Presentar(valor Como Opcional<FechaHora>)\nSegun valor Hacer\nNada: Escribir \"none\";\nAlgo(fecha): Escribir fecha.FormatoIsoPreciso();\nFinSegun\nFinSubProceso\nAlgoritmo P\nDefinir fecha Como Opcional<FechaHora> <- FechaHoraDe(2026, 6, 15, 12, 30, 45, 120000000, 19800);\nSegun fecha Hacer\nNada: Escribir \"none\";\nAlgo(valor): Escribir valor.FormatoIso();\nEscribir valor.FormatoIsoPreciso();\nFinSegun\nSegun FechaHoraDe(2026, 6, 15, 12, 30, 45, 0, -43200) Hacer\nNada: Escribir \"none\";\nAlgo(valor): Escribir valor.FormatoIso();\nFinSegun\nSegun FechaHoraDe(2026, 6, 15, 12, 30, 45, 0, 50400) Hacer\nNada: Escribir \"none\";\nAlgo(valor): Escribir valor.FormatoIso();\nFinSegun\nSegun FechaHoraDe(2026, 6, 15, 12, 30, 45, 0, 0) Hacer\nNada: Escribir \"none\";\nAlgo(valor): Escribir valor.FormatoIso();\nFinSegun\nSegun FechaHoraDe(2026, 6, 15, 12, 30, 45, 0, -34200) Hacer\nNada: Escribir \"none\";\nAlgo(valor): Escribir valor.FormatoIso();\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Show(value as optional<DateTime>)\nswitch value do\nnone: write \"none\";\nsome(moment): write moment.isoFormatPrecise();\nendSwitch\nendSubroutine\nalgorithm P\ndefine moment as optional<DateTime> <- dateTimeOf(2026, 6, 15, 12, 30, 45, 120000000, 19800);\nswitch moment do\nnone: write \"none\";\nsome(value): write value.isoFormat();\nwrite value.isoFormatPrecise();\nendSwitch\nswitch dateTimeOf(2026, 6, 15, 12, 30, 45, 0, -43200) do\nnone: write \"none\";\nsome(value): write value.isoFormat();\nendSwitch\nswitch dateTimeOf(2026, 6, 15, 12, 30, 45, 0, 50400) do\nnone: write \"none\";\nsome(value): write value.isoFormat();\nendSwitch\nswitch dateTimeOf(2026, 6, 15, 12, 30, 45, 0, 0) do\nnone: write \"none\";\nsome(value): write value.isoFormat();\nendSwitch\nswitch dateTimeOf(2026, 6, 15, 12, 30, 45, 0, -34200) do\nnone: write \"none\";\nsome(value): write value.isoFormat();\nendSwitch\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "AnalizarFechaHora(texto) devuelve Algo(FechaHora) solo para las formas AAAA-MM-DD, que significa medianoche con desplazamiento cero, y AAAA-MM-DDThh:mm:ss con fracción opcional de uno a nueve dígitos tras el segundo y con desplazamiento opcional Z o ±hh:mm, que sin desplazamiento significa cero. Cualquier otra entrada devuelve Nada: vacía, con espacios, con T o Z en minúscula, sin segundos, con fracción sin dígitos o de más de nueve, con el segundo 60, con campos fuera del calendario gregoriano proléptico, con desplazamiento fuera de -12:00 a +14:00 o con minutos de desplazamiento mayores que 59, o con un instante fuera del rango de R3. Es una función pura y total.",
  "verificacion": [
    "C13",
    "C14",
    "C15",
    "C23"
  ]
}
```

```caso
{
  "id": "C13",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2026-06-15T00:00:00.000000000Z\n2026-06-15T12:30:45.000000000Z\n2026-06-15T12:30:45.000000000Z\n2026-06-15T12:30:45.000000000+05:30\n2026-06-15T12:30:45.000000000-12:00\n2026-06-15T12:30:45.500000000Z\n2026-06-15T12:30:45.123456789+14:00\n2024-02-29T23:59:59.000000000Z\n1677-09-21T00:12:43.145224192Z\n2262-04-11T23:47:16.854775807Z\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Presentar(valor Como Opcional<FechaHora>)\nSegun valor Hacer\nNada: Escribir \"none\";\nAlgo(fecha): Escribir fecha.FormatoIsoPreciso();\nFinSegun\nFinSubProceso\nAlgoritmo P\nPresentar(AnalizarFechaHora(\"2026-06-15\"));\nPresentar(AnalizarFechaHora(\"2026-06-15T12:30:45\"));\nPresentar(AnalizarFechaHora(\"2026-06-15T12:30:45Z\"));\nPresentar(AnalizarFechaHora(\"2026-06-15T12:30:45+05:30\"));\nPresentar(AnalizarFechaHora(\"2026-06-15T12:30:45-12:00\"));\nPresentar(AnalizarFechaHora(\"2026-06-15T12:30:45.5Z\"));\nPresentar(AnalizarFechaHora(\"2026-06-15T12:30:45.123456789+14:00\"));\nPresentar(AnalizarFechaHora(\"2024-02-29T23:59:59Z\"));\nPresentar(AnalizarFechaHora(\"1677-09-21T00:12:43.145224192Z\"));\nPresentar(AnalizarFechaHora(\"2262-04-11T23:47:16.854775807Z\"));\nFinAlgoritmo\n",
    "en": "subroutine Show(value as optional<DateTime>)\nswitch value do\nnone: write \"none\";\nsome(moment): write moment.isoFormatPrecise();\nendSwitch\nendSubroutine\nalgorithm P\nShow(parseDateTime(\"2026-06-15\"));\nShow(parseDateTime(\"2026-06-15T12:30:45\"));\nShow(parseDateTime(\"2026-06-15T12:30:45Z\"));\nShow(parseDateTime(\"2026-06-15T12:30:45+05:30\"));\nShow(parseDateTime(\"2026-06-15T12:30:45-12:00\"));\nShow(parseDateTime(\"2026-06-15T12:30:45.5Z\"));\nShow(parseDateTime(\"2026-06-15T12:30:45.123456789+14:00\"));\nShow(parseDateTime(\"2024-02-29T23:59:59Z\"));\nShow(parseDateTime(\"1677-09-21T00:12:43.145224192Z\"));\nShow(parseDateTime(\"2262-04-11T23:47:16.854775807Z\"));\nendAlgorithm\n"
  }
}
```

```caso
{
  "id": "C14",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "none\nnone\nnone\nnone\nnone\nnone\nnone\nnone\nnone\nnone\nnone\nnone\nnone\nnone\nnone\nnone\nnone\nnone\nnone\nnone\nnone\nnone\nnone\nnone\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Presentar(valor Como Opcional<FechaHora>)\nSegun valor Hacer\nNada: Escribir \"none\";\nAlgo(fecha): Escribir fecha.FormatoIsoPreciso();\nFinSegun\nFinSubProceso\nAlgoritmo P\nPresentar(AnalizarFechaHora(\"2026-13-01\"));\nPresentar(AnalizarFechaHora(\"2026-02-30\"));\nPresentar(AnalizarFechaHora(\"2026-01-01T25:00:00\"));\nPresentar(AnalizarFechaHora(\"\"));\nPresentar(AnalizarFechaHora(\" 2026-01-01\"));\nPresentar(AnalizarFechaHora(\"2026-01-01 \"));\nPresentar(AnalizarFechaHora(\"2026-01-01t00:00:00\"));\nPresentar(AnalizarFechaHora(\"2026-01-01T00:00:00z\"));\nPresentar(AnalizarFechaHora(\"2026-01-01T00:00:60Z\"));\nPresentar(AnalizarFechaHora(\"2026-01-01T00:00:00+14:30\"));\nPresentar(AnalizarFechaHora(\"2026-01-01T00:00:00-12:30\"));\nPresentar(AnalizarFechaHora(\"2026-01-01T00:00:00.Z\"));\nPresentar(AnalizarFechaHora(\"2026-01-01T00:00:00.1234567890Z\"));\nPresentar(AnalizarFechaHora(\"1600-01-01\"));\nPresentar(AnalizarFechaHora(\"2300-01-01\"));\nPresentar(AnalizarFechaHora(\"2026-01-01T00:00Z\"));\nPresentar(AnalizarFechaHora(\"2026-1-1\"));\nPresentar(AnalizarFechaHora(\"2023-02-29\"));\nPresentar(AnalizarFechaHora(\"2026-01-01T00:00:00+05:60\"));\nPresentar(AnalizarFechaHora(\"2026-01-01T00:00:00+0530\"));\nPresentar(AnalizarFechaHora(\"20260101\"));\nPresentar(AnalizarFechaHora(\"2026-01-01T00:00:00 Z\"));\nPresentar(AnalizarFechaHora(\"+2026-01-01\"));\nPresentar(AnalizarFechaHora(\"2026-01-01T00:00:00+05:30:00\"));\nFinAlgoritmo\n",
    "en": "subroutine Show(value as optional<DateTime>)\nswitch value do\nnone: write \"none\";\nsome(moment): write moment.isoFormatPrecise();\nendSwitch\nendSubroutine\nalgorithm P\nShow(parseDateTime(\"2026-13-01\"));\nShow(parseDateTime(\"2026-02-30\"));\nShow(parseDateTime(\"2026-01-01T25:00:00\"));\nShow(parseDateTime(\"\"));\nShow(parseDateTime(\" 2026-01-01\"));\nShow(parseDateTime(\"2026-01-01 \"));\nShow(parseDateTime(\"2026-01-01t00:00:00\"));\nShow(parseDateTime(\"2026-01-01T00:00:00z\"));\nShow(parseDateTime(\"2026-01-01T00:00:60Z\"));\nShow(parseDateTime(\"2026-01-01T00:00:00+14:30\"));\nShow(parseDateTime(\"2026-01-01T00:00:00-12:30\"));\nShow(parseDateTime(\"2026-01-01T00:00:00.Z\"));\nShow(parseDateTime(\"2026-01-01T00:00:00.1234567890Z\"));\nShow(parseDateTime(\"1600-01-01\"));\nShow(parseDateTime(\"2300-01-01\"));\nShow(parseDateTime(\"2026-01-01T00:00Z\"));\nShow(parseDateTime(\"2026-1-1\"));\nShow(parseDateTime(\"2023-02-29\"));\nShow(parseDateTime(\"2026-01-01T00:00:00+05:60\"));\nShow(parseDateTime(\"2026-01-01T00:00:00+0530\"));\nShow(parseDateTime(\"20260101\"));\nShow(parseDateTime(\"2026-01-01T00:00:00 Z\"));\nShow(parseDateTime(\"+2026-01-01\"));\nShow(parseDateTime(\"2026-01-01T00:00:00+05:30:00\"));\nendAlgorithm\n"
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0\n0\n0\n0\n0\n0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Vuelta(semilla Como Entero)\nSegun AnalizarFechaHora(FechaHoraUtc(semilla).FormatoIsoPreciso()) Hacer\nNada: Escribir \"none\";\nAlgo(vuelta): Escribir vuelta.Instante() - semilla;\nFinSegun\nFinSubProceso\nAlgoritmo P\nVuelta(-9000000000000000000);\nVuelta(-1);\nVuelta(0);\nVuelta(1);\nVuelta(1234567890123456789);\nVuelta(9000000000000000000);\nFinAlgoritmo\n",
    "en": "subroutine Back(seed as integer)\nswitch parseDateTime(dateTimeUtc(seed).isoFormatPrecise()) do\nnone: write \"none\";\nsome(back): write back.instant() - seed;\nendSwitch\nendSubroutine\nalgorithm P\nBack(-9000000000000000000);\nBack(-1);\nBack(0);\nBack(1);\nBack(1234567890123456789);\nBack(9000000000000000000);\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R8",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El receptor Reloj ofrece AhoraLocal(), una operación de efecto falible que lee el reloj del anfitrión como Ahora y devuelve una FechaHora cuyo instante es esa lectura y cuyo desplazamiento es el vigente en ese instante según la zona horaria del sistema del anfitrión, redondeado a minutos enteros hacia cero; incluye el horario de verano porque el instante determina el desplazamiento y no al revés. Se graba en la cinta bajo la capacidad clock; en reproducción se devuelve el valor grabado sin consultar ni al reloj ni a la zona del sistema. Los errores del anfitrión son ErrorES.",
  "verificacion": [
    "C16",
    "C17",
    "C20"
  ]
}
```

```caso
{
  "id": "C16",
  "regla": "R8",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2023-11-15T03:43:20.123456789+05:30\n19800\n100000000000\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "recursos_abiertos": 0,
      "estado_cinta": "reproducible",
      "efectos": [
        {
          "effect_seq": 1,
          "capability_kind": "clock",
          "operation": "request_clock",
          "outcome": "committed"
        },
        {
          "effect_seq": 2,
          "capability_kind": "clock",
          "operation": "clock_local_now",
          "outcome": "committed"
        },
        {
          "effect_seq": 4,
          "capability_kind": "clock",
          "operation": "clock_local_now",
          "outcome": "committed"
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nDefinir primera Como FechaHora <- Propagar clock.AhoraLocal();\nEscribir primera.FormatoIsoPreciso();\nDefinir segunda Como FechaHora <- Propagar clock.AhoraLocal();\nEscribir segunda.DesplazamientoUtc();\nRetornar Exito(segunda.Instante() - primera.Instante());\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine clock as Clock <- propagate requestClock();\ndefine first as DateTime <- propagate clock.localNow();\nwrite first.isoFormatPrecise();\ndefine second as DateTime <- propagate clock.localNow();\nwrite second.utcOffset();\nreturn success(second.instant() - first.instant());\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "clock": [
      1700000000123456789,
      1700000100123456789
    ],
    "offset_seconds": 19800,
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C17",
  "regla": "R8",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "fin_de_archivo\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nDefinir primera Como FechaHora <- Propagar clock.AhoraLocal();\nEscribir primera.FormatoIsoPreciso();\nDefinir segunda Como FechaHora <- Propagar clock.AhoraLocal();\nEscribir segunda.DesplazamientoUtc();\nRetornar Exito(segunda.Instante() - primera.Instante());\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine clock as Clock <- propagate requestClock();\ndefine first as DateTime <- propagate clock.localNow();\nwrite first.isoFormatPrecise();\ndefine second as DateTime <- propagate clock.localNow();\nwrite second.utcOffset();\nreturn success(second.instant() - first.instant());\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "clock": [],
    "offset_seconds": -18000
  }
}
```

```caso
{
  "id": "C18",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1781537400000000000\n2500000000\n2.5\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso MedirEspera() Como Resultado<Entero, ErrorES>\n  Definir reloj Como Reloj <- Propagar SolicitarReloj();\n  Definir antes Como Entero <- Propagar reloj.Ahora();\n  Definir despues Como Entero <- Propagar reloj.Ahora();\n  Escribir antes;\n  Retornar Exito(despues - antes);\nFinSubProceso\n\nAlgoritmo Cronometro\n  Segun MedirEspera() Hacer\n    Exito(nanosegundos):\n      Escribir nanosegundos;\n      Escribir nanosegundos / 1000000000;\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine MeasureWait() As Result<Integer, IoError>\n  Define clock As Clock <- Propagate requestClock();\n  Define before As Integer <- Propagate clock.now();\n  Define after As Integer <- Propagate clock.now();\n  Write before;\n  Return Success(after - before);\nEndSubroutine\n\nAlgorithm Stopwatch\n  Switch MeasureWait() Do\n    Success(nanoseconds):\n      Write nanoseconds;\n      Write nanoseconds / 1000000000;\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "clock": [
      1781537400000000000,
      1781537402500000000
    ],
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C19",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2.0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso PausaCorta() Como Resultado<Entero, ErrorES>\n  Definir reloj Como Reloj <- Propagar SolicitarReloj();\n  Definir temporizador Como Temporizador <- Propagar SolicitarTemporizador();\n  Definir antes Como Entero <- Propagar reloj.Ahora();\n  Definir despues Como Entero <- Propagar temporizador.Esperar(2000000000);\n  Retornar Exito(despues - antes);\nFinSubProceso\n\nAlgoritmo Pausa\n  Segun PausaCorta() Hacer\n    Exito(nanosegundos): Escribir nanosegundos / 1000000000;\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine ShortPause() As Result<Integer, IoError>\n  Define clock As Clock <- Propagate requestClock();\n  Define timer As Timer <- Propagate requestTimer();\n  Define before As Integer <- Propagate clock.now();\n  Define after As Integer <- Propagate timer.wait(2000000000);\n  Return Success(after - before);\nEndSubroutine\n\nAlgorithm Pause\n  Switch ShortPause() Do\n    Success(nanoseconds): Write nanoseconds / 1000000000;\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "clock": [
      1781537400000000000
    ],
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C20",
  "regla": "R8",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2026-06-15T12:30:00-05:00\n12\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso MostrarHoraLocal() Como Resultado<Entero, ErrorES>\n  Definir reloj Como Reloj <- Propagar SolicitarReloj();\n  Definir momento Como FechaHora <- Propagar reloj.AhoraLocal();\n  Escribir momento.FormatoIso();\n  Retornar Exito(momento.Hora());\nFinSubProceso\n\nAlgoritmo HoraDeMiCiudad\n  Segun MostrarHoraLocal() Hacer\n    Exito(hora): Escribir hora;\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine ShowLocalTime() As Result<Integer, IoError>\n  Define clock As Clock <- Propagate requestClock();\n  Define moment As DateTime <- Propagate clock.localNow();\n  Write moment.isoFormat();\n  Return Success(moment.hour());\nEndSubroutine\n\nAlgorithm MyCityTime\n  Switch ShowLocalTime() Do\n    Success(localHour): Write localHour;\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "clock": [
      1781544600000000000
    ],
    "offset_seconds": -18000,
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C21",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1970-01-01T00:00:00Z\n1970-01-02T00:00:00Z\n2026-06-15T15:30:00Z\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "Algoritmo ContarDesde1970\n  Definir unDia Como Entero <- 86400000000000;\n  Escribir FechaHoraUtc(0).FormatoIso();\n  Escribir FechaHoraUtc(unDia).FormatoIso();\n  Escribir FechaHoraUtc(1781537400000000000).FormatoIso();\nFinAlgoritmo\n",
    "en": "Algorithm CountFrom1970\n  Define oneDay As Integer <- 86400000000000;\n  Write dateTimeUtc(0).isoFormat();\n  Write dateTimeUtc(oneDay).isoFormat();\n  Write dateTimeUtc(1781537400000000000).isoFormat();\nEndAlgorithm\n"
  }
}
```

```caso
{
  "id": "C22",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2026-07-20T18:30:00-05:00\n---\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "Algoritmo Cumpleanos\n  Segun FechaHoraDe(2026, 7, 20, 18, 30, 0, 0, -18000) Hacer\n    Nada: Escribir \"---\";\n    Algo(fiesta): Escribir fiesta.FormatoIso();\n  FinSegun\n  Segun FechaHoraDe(2026, 2, 30, 18, 30, 0, 0, -18000) Hacer\n    Nada: Escribir \"---\";\n    Algo(fiesta): Escribir fiesta.FormatoIso();\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm Birthday\n  Switch dateTimeOf(2026, 7, 20, 18, 30, 0, 0, -18000) Do\n    None: Write \"---\";\n    Some(party): Write party.isoFormat();\n  EndSwitch\n  Switch dateTimeOf(2026, 2, 30, 18, 30, 0, 0, -18000) Do\n    None: Write \"---\";\n    Some(party): Write party.isoFormat();\n  EndSwitch\nEndAlgorithm\n"
  }
}
```

```caso
{
  "id": "C23",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "20/7/2026\n---\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "Algoritmo LeerFecha\n  Segun AnalizarFechaHora(\"2026-07-20T18:30:00-05:00\") Hacer\n    Nada: Escribir \"---\";\n    Algo(fecha): Escribir fecha.Dia(), \"/\", fecha.Mes(), \"/\", fecha.Anio();\n  FinSegun\n  Segun AnalizarFechaHora(\"20/07/2026\") Hacer\n    Nada: Escribir \"---\";\n    Algo(fecha): Escribir fecha.Dia(), \"/\", fecha.Mes(), \"/\", fecha.Anio();\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm ReadDate\n  Switch parseDateTime(\"2026-07-20T18:30:00-05:00\") Do\n    None: Write \"---\";\n    Some(date): Write date.day(), \"/\", date.month(), \"/\", date.year();\n  EndSwitch\n  Switch parseDateTime(\"20/07/2026\") Do\n    None: Write \"---\";\n    Some(date): Write date.day(), \"/\", date.month(), \"/\", date.year();\n  EndSwitch\nEndAlgorithm\n"
  }
}
```

```caso
{
  "id": "C24",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2026\n12\n31\n2027\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "Algoritmo FinDeAnio\n  Segun FechaHoraDe(2026, 12, 31, 22, 0, 0, 0, -18000) Hacer\n    Nada: Escribir \"---\";\n    Algo(fiesta):\n      Escribir fiesta.Anio();\n      Escribir fiesta.Mes();\n      Escribir fiesta.Dia();\n      Escribir FechaHoraUtc(fiesta.Instante()).Anio();\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm YearEnd\n  Switch dateTimeOf(2026, 12, 31, 22, 0, 0, 0, -18000) Do\n    None: Write \"---\";\n    Some(party):\n      Write party.year();\n      Write party.month();\n      Write party.day();\n      Write dateTimeUtc(party.instant()).year();\n  EndSwitch\nEndAlgorithm\n"
  }
}
```

```caso
{
  "id": "C25",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "9\n15\n30\n250000000\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "Algoritmo PartesDeLaHora\n  Segun AnalizarFechaHora(\"2026-07-20T09:15:30.25Z\") Hacer\n    Nada: Escribir \"---\";\n    Algo(carrera):\n      Escribir carrera.Hora();\n      Escribir carrera.Minuto();\n      Escribir carrera.Segundo();\n      Escribir carrera.Nanosegundo();\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm TimeParts\n  Switch parseDateTime(\"2026-07-20T09:15:30.25Z\") Do\n    None: Write \"---\";\n    Some(race):\n      Write race.hour();\n      Write race.minute();\n      Write race.second();\n      Write race.nanosecond();\n  EndSwitch\nEndAlgorithm\n"
  }
}
```

```caso
{
  "id": "C26",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "-18000\n1784556000000000000\n2026-07-20T14:00:00Z\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "Algoritmo HoraEnLima\n  Segun AnalizarFechaHora(\"2026-07-20T09:00:00-05:00\") Hacer\n    Nada: Escribir \"---\";\n    Algo(lima):\n      Escribir lima.DesplazamientoUtc();\n      Escribir lima.Instante();\n      Escribir FechaHoraUtc(lima.Instante()).FormatoIso();\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm TimeInLima\n  Switch parseDateTime(\"2026-07-20T09:00:00-05:00\") Do\n    None: Write \"---\";\n    Some(lima):\n      Write lima.utcOffset();\n      Write lima.instant();\n      Write dateTimeUtc(lima.instant()).isoFormat();\n  EndSwitch\nEndAlgorithm\n"
  }
}
```

```caso
{
  "id": "C27",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n7\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "Algoritmo DiaDeLaSemanaDeHoy\n  Segun AnalizarFechaHora(\"2026-07-20\") Hacer\n    Nada: Escribir \"---\";\n    Algo(lunes): Escribir lunes.DiaDeLaSemana();\n  FinSegun\n  Segun AnalizarFechaHora(\"2026-07-26\") Hacer\n    Nada: Escribir \"---\";\n    Algo(domingo): Escribir domingo.DiaDeLaSemana();\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm WeekdayCheck\n  Switch parseDateTime(\"2026-07-20\") Do\n    None: Write \"---\";\n    Some(monday): Write monday.weekday();\n  EndSwitch\n  Switch parseDateTime(\"2026-07-26\") Do\n    None: Write \"---\";\n    Some(sunday): Write sunday.weekday();\n  EndSwitch\nEndAlgorithm\n"
  }
}
```

```caso
{
  "id": "C28",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2026-07-20T09:15:30-05:00\n2026-07-20T09:15:30.250000000-05:00\n1970-01-01T00:00:00Z\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "Algoritmo DosFormatos\n  Segun AnalizarFechaHora(\"2026-07-20T09:15:30.25-05:00\") Hacer\n    Nada: Escribir \"---\";\n    Algo(llegada):\n      Escribir llegada.FormatoIso();\n      Escribir llegada.FormatoIsoPreciso();\n  FinSegun\n  Escribir FechaHoraUtc(0).FormatoIso();\nFinAlgoritmo\n",
    "en": "Algorithm TwoFormats\n  Switch parseDateTime(\"2026-07-20T09:15:30.25-05:00\") Do\n    None: Write \"---\";\n    Some(arrival):\n      Write arrival.isoFormat();\n      Write arrival.isoFormatPrecise();\n  EndSwitch\n  Write dateTimeUtc(0).isoFormat();\nEndAlgorithm\n"
  }
}
```
