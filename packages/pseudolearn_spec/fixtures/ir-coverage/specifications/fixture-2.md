---
{
  "formato": "see/1",
  "id": "LANG.TEST.SAMPLE",
  "titulo": "Fixture",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "reference"
  ],
  "resumen": "Violación deliberada.",
  "depende_de": [],
  "edicion": {
    "introducida_en": "2026"
  }
}
---

# Fixture

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
    "es",
    "en"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "espera": {
    "terminacion": "completed"
  },
  "programas": {
    "es": "Algoritmo P\nFinAlgoritmo\n",
    "en": "algorithm P\nendAlgorithm\n"
  },
  "operacion": "execute"
}
```
