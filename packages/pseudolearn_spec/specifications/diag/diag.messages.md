---
{
  "formato": "see/1",
  "id": "DIAG.MESSAGES",
  "titulo": "Presentación bilingüe de diagnósticos",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Presentación bilingüe de diagnósticos.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "DIAG.CATALOG",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Presentación bilingüe de diagnósticos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La capa de presentación resuelve plantilla por idioma de interfaz y sustituye argumentos tipados. El idioma de prosa es independiente del vocabulario del programa. Nunca traduce nombres del usuario; tokens usan lexema activo. Cada plantilla usa exactamente sus argumentos requeridos; no quedan marcadores sin resolver. Los mensajes describen el problema y la acción pertinente sin texto del anfitrión. taskDeadlock presenta los sitios de suspensión como ubicaciones relacionadas en orden de identidad de tarea; los fallos de ámbito y canal usan las plantillas bilingües del catálogo.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4"
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
  "programas": {
    "es": "Algoritmo P\nEscribir 1 + Verdadero;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1 + true;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleOperandTypes",
        "severidad": "error"
      }
    ]
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  "programas": {
    "es": "Algoritmo P\nEscribir Aguardar 1;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite await 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "awaitOperandInvalid",
        "severidad": "error"
      }
    ]
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "id": "C4",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nSegun Aguardar stream.Recibir() Hacer\nNada: Escribir 0;\nAlgo(value): Escribir value;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine stream as channel<integer> <- channel(1);\nswitch await stream.receive() do\nnone: write 0;\nsome(value): write value;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "taskDeadlock"
    }
  }
}
```
