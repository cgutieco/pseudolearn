---
{
  "formato": "see/1",
  "id": "ENG.TEST.TRACE",
  "titulo": "Fixture",
  "dominio": "motor",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Violación deliberada.",
  "depende_de": []
}
---

# Fixture

```definicion
{
  "id": "D1",
  "termino": "traceEvents",
  "texto": "Alfabeto.",
  "valor": {
    "statement_entered": {
      "datos": []
    }
  }
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Regla de fixture.",
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
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "espera": {
    "eventos": [
      {
        "clase": "teleport",
        "linea": 1
      }
    ]
  },
  "programas": {
    "es": "Algoritmo P\nFinAlgoritmo\n"
  },
  "operacion": "trace"
}
```
