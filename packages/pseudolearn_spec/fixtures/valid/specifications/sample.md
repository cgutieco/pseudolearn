---
{
  "formato": "see/1",
  "id": "LANG.TEST.SAMPLE",
  "titulo": "Corpus de prueba",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Tipo entero.",
  "depende_de": [],
  "edicion": {
    "introducida_en": "2026"
  },
  "revisado_por": [
    "independent-reviewer"
  ]
}
---

# Prueba

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El caso escribe uno.",
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
    "flexible"
  ],
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed",
    "diagnosticos": []
  },
  "origen": "derivado",
  "programas": {
    "es": "Algoritmo P\n Escribir 1\nFinAlgoritmo\n",
    "en": "algorithm P\n write 1\nendAlgorithm\n"
  }
}
```
