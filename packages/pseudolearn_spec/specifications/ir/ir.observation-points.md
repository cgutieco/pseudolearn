---
{
  "formato": "see/1",
  "id": "IR.OBSERVATION-POINTS",
  "titulo": "Puntos de observación de la RI",
  "dominio": "ri",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Qué instrucciones producen eventos, masa de sentencia y regla como si.",
  "depende_de": [
    {
      "id": "IR.INSTRUCTIONS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.TRACE.EVENTS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.LIMITS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Observation points"
}
---

# Puntos de observación de la RI

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los eventos de una ejecución observada son exactamente los que declaran las instrucciones ejecutadas en su campo de observación, en orden de ejecución, más un evento failure por la trampa que detiene la ejecución.",
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
  "operacion": "trace",
  "espera": {
    "salida": "",
    "terminacion": "completed",
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 2
      },
      {
        "clase": "statement_exited",
        "linea": 2
      },
      {
        "clase": "statement_entered",
        "linea": 3
      },
      {
        "clase": "statement_exited",
        "linea": 3
      },
      {
        "clase": "statement_entered",
        "linea": 4
      },
      {
        "clase": "decision",
        "linea": 4,
        "datos": {
          "rama": "afirmativa"
        }
      },
      {
        "clase": "statement_entered",
        "linea": 5
      },
      {
        "clase": "statement_exited",
        "linea": 5
      },
      {
        "clase": "decision",
        "linea": 4,
        "datos": {
          "rama": "negativa"
        }
      },
      {
        "clase": "statement_exited",
        "linea": 4
      }
    ]
  },
  "programa": "Algoritmo P\nDefinir Mutable i Como Entero <- 0;\ni <- 0;\nMientras i < 1 Hacer\ni <- i + 1;\nFinMientras\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La masa de sentencia de un bloque es el número de entradas a sentencia que contiene. El presupuesto de sentencias y la cancelación cuentan entradas a sentencia exactamente, cualquiera que sea la agrupación en bloques.",
  "verificacion": [
    "C2",
    "C3"
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
    "salida": "3\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nDefinir Mutable i Como Entero <- 0;\ni <- 0;\nMientras i < 3 Hacer\ni <- i + 1;\nFinMientras\nEscribir i;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "sentencias": 7
  }
}
```

```caso
{
  "id": "C3",
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
    "salida": "",
    "terminacion": "limit_reached",
    "limite": "sentencias"
  },
  "programa": "Algoritmo P\nDefinir Mutable i Como Entero <- 0;\ni <- 0;\nMientras i < 3 Hacer\ni <- i + 1;\nFinMientras\nEscribir i;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "sentencias": 6
  }
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Regla como si: una ejecución no observada solo conserva los efectos externos, la terminación y la primera trampa; puede omitir las instrucciones de observación siempre que la salida, la entrada consumida, los diagnósticos y la terminación coincidan con los de la ejecución observada.",
  "verificacion": [
    "P1"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R3",
  "generador": {
    "programas": "todos los casos execute y trace del corpus"
  },
  "propiedad": "La ejecución no observada y la observada producen la misma salida, entradas consumidas, diagnósticos y terminación.",
  "oraculo": "Ejecución observada del mismo sujeto.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```
