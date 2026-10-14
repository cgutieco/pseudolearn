---
{
  "formato": "see/1",
  "id": "IR.TEST.TEXT",
  "titulo": "Fixture",
  "dominio": "ri",
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
    "ri": {
      "aceptada": true,
      "regla": "IR.WELL-FORMEDNESS#R1"
    }
  },
  "operacion": "ir",
  "programa_ri": "module {}\n"
}
```
