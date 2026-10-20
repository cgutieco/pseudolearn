---
{
  "formato": "see/1",
  "id": "APP.EXEC.PACE",
  "titulo": "Ritmos de ejecución",
  "dominio": "app",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-aplicacion"
  ],
  "sujetos": [
    "app"
  ],
  "resumen": "Los cuatro controles didácticos fijan eventos de parada, no velocidades temporales.",
  "depende_de": [
    {
      "id": "API.EXECUTE",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "API.STATE.QUERY",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.TRACE.STEP",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.TRACE.EVENTS",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.INPUT",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.LIMITS",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Execution paces",
  "cambio": {
    "clase": "verificacion_anadida",
    "impacto_usuarios": "Se conserva la versión numérica por autorización y no se añaden construcciones.",
    "impacto_implementaciones": "Sujetos retirados, alcance de casos y verificaciones de contratos existentes explícitos.",
    "justificacion": "Migración autorizada; la evidencia histórica, AOT y de plataforma conserva sus límites.",
    "revisado_por": "revision-independiente-automatizada"
  }
}
---

# Ritmos de ejecución

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada ritmo se evalúa tras cada evento y se detiene inmediatamente si la ejecución termina o solicita entrada. nextStatement se detiene en el primer evento posterior que cambia el foco proyectado: statement_entered de una sentencia ejecutable que no sea contenedor, decision, call o return. statement_exited, output e input_received no cambian el foco por sí solos. overBlock se detiene en el primer cambio de foco cuyo nodo no es el nodo enfocado inicialmente y cuya profundidad de bloque no excede la inicial. outOfBlock se detiene en el primer cambio de foco cuya profundidad no excede la profundidad inicial menos uno y cuyo nodo no es el bloque contenedor inicial. toEnd continúa hasta terminación, límite o cancelación. El adaptador deriva identidad y profundidad estructurales de source y API.PROGRAM.VIEW; no usa líneas como identidad. Si no se alcanza la condición, la ejecución continúa por lotes cooperativos de hasta 25 eventos y devuelve el control al planificador entre lotes.",
  "verificacion": ["C1", "C2", "C3", "C4"]
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {"scenario": "pace", "input": {"pace": "nextStatement", "program": "Algoritmo P\nEscribir 1;\nEscribir 2;\nFinAlgoritmo\n", "from_line": 2}},
  "espera": {"aplicacion": {"stop_event": "statement_entered", "line": 3}}
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {"scenario": "pace", "input": {"pace": "overBlock", "program": "Algoritmo P\nSi Verdadero Entonces\nEscribir 1;\nFinSi\nEscribir 2;\nFinAlgoritmo\n", "from_line": 2}},
  "espera": {"aplicacion": {"stop_event": "statement_entered", "line": 5}}
}
```

```caso
{
  "id": "C3",
  "regla": "R1",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {"scenario": "pace", "input": {"pace": "outOfBlock", "program": "SubProceso Uno()\nEscribir 1;\nFinSubProceso\nAlgoritmo P\nUno();\nEscribir 2;\nFinAlgoritmo\n", "from_line": 2}},
  "espera": {"aplicacion": {"stop_event": "statement_entered", "line": 6}}
}
```

```caso
{
  "id": "C4",
  "regla": "R1",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {"scenario": "pace", "input": {"pace": "toEnd", "program": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"}},
  "espera": {"aplicacion": {"termination": "completed", "output": "1\n"}}
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los cuatro ritmos producen la misma salida, terminación, entrada consumida y orden de efectos que la misma ejecución hasta el mismo punto observable. Cambiar el ritmo solo cambia el evento donde se devuelve el control a la interfaz.",
  "verificacion": ["C5"]
}
```

```caso
{
  "id": "C5",
  "regla": "R2",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {"scenario": "pace", "input": {"programs": {"es": "Algoritmo P\nDefinir a, b, c, i Como Entero;\na <- 0;\nb <- 1;\nPara i <- 1 Hasta 20 Hacer\nc <- a + b;\na <- b;\nb <- c;\nFinPara\nEscribir a;\nFinAlgoritmo\n", "en": "algorithm P\ndefine a, b, c, i as integer;\na <- 0;\nb <- 1;\nfor i <- 1 to 20 do\nc <- a + b;\na <- b;\nb <- c;\nendFor\nwrite a;\nendAlgorithm\n"}, "paces": ["nextStatement", "overBlock", "outOfBlock", "toEnd"]}},
  "espera": {"aplicacion": {"output": "6765\n", "termination": "completed", "pace_results_equal": true}}
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "El adaptador procesa lotes cooperativos de hasta 25 eventos y devuelve el control al planificador entre lotes, sin perder ni duplicar eventos. Pausa, entrada y cancelación se observan entre lotes. La cancelación conserva los eventos y efectos ya completados y no produce eventos ni efectos posteriores a la respuesta de cancelación.",
  "verificacion": ["C6", "C7"]
}
```

```caso
{
  "id": "C6",
  "regla": "R3",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {"scenario": "pace", "input": {"pace": "toEnd", "batch_size": 25, "program": "Algoritmo P\nDefinir i Como Entero;\ni <- 0;\nMientras Verdadero Hacer\ni <- i + 1;\nFinMientras\nFinAlgoritmo\n", "cancel_after_batches": 2}},
  "espera": {"aplicacion": {"termination": "cancelled", "events_ordered": true, "completed_effects_match_events": true, "no_events_after_cancel": true}}
}
```

```caso
{
  "id": "C7",
  "regla": "R3",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {"scenario": "pace", "input": {"pace": "toEnd", "program": "Algoritmo P\nDefinir x Como Entero;\nEscribir \"antes\";\nLeer x;\nEscribir x;\nFinAlgoritmo\n", "inputs": ["5"]}},
  "espera": {"aplicacion": {"first_stop": "awaiting_input", "after_input": {"termination": "completed", "output": "antes\n5\n"}}}
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "El presupuesto de trabajo y tiempo de una ejecución es independiente del ritmo visual. toEnd no elimina los límites del anfitrión; al alcanzarlos devuelve limit_reached con los eventos y efectos completados hasta ese punto.",
  "verificacion": ["C8", "C9"]
}
```

```caso
{
  "id": "C8",
  "regla": "R4",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {"scenario": "pace", "input": {"pace": "toEnd", "statement_limit": 3, "program": "Algoritmo P\nDefinir i Como Entero;\ni <- 0;\nMientras i < 100 Hacer\ni <- i + 1;\nFinMientras\nFinAlgoritmo\n"}},
  "espera": {"aplicacion": {"termination": "limit_reached", "statement_limit": 3}}
}
```

```caso
{
  "id": "C9",
  "regla": "R4",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {"scenario": "pace", "input": {"pace": "toEnd", "program": "Algoritmo P\nDefinir x Como Real;\nx <- 1.0 / 0.0;\nEscribir x;\nFinAlgoritmo\n"}},
  "espera": {"aplicacion": {"termination": "failed", "code": "divisionByZero", "events_before_failure_preserved": true, "later_events_absent": true}}
}
```
