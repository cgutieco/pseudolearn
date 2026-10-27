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
  "texto": "La consulta de la capacidad Reloj produce instantes de tiempo lógicos grabados en la cinta, garantizando que repeticiones posteriores de la ejecución reproduzcan exactamente la misma secuencia temporal sin consultar el reloj físico del anfitrión.",
  "verificacion": [
    "C1"
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
  "rigor": [
    "estricto",
    "flexible"
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
    "permissions": [
      "reloj"
    ],
    "requested_permissions": [
      "reloj"
    ],
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
  "texto": "La operación sobre la capacidad Temporizador avanza el tiempo lógico del programa mediante la entrega determinista de eventos de temporizador, permitiendo pausas reproducibles y suspensiones de efecto coordinadas.",
  "verificacion": [
    "C2"
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
  "rigor": [
    "estricto",
    "flexible"
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
    "permissions": [
      "temporizador"
    ],
    "requested_permissions": [
      "temporizador"
    ],
    "grabar_y_reproducir": true
  }
}
```
