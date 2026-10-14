---
{
  "formato": "see/1",
  "id": "TOOL.TEST.CLI",
  "titulo": "Fixture",
  "dominio": "herramienta",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "cli"
  ],
  "resumen": "Violación deliberada.",
  "depende_de": []
}
---

# Fixture

```definicion
{
  "id": "D1",
  "termino": "cliConventions",
  "texto": "Convenciones.",
  "valor": {
    "codigos_salida": {
      "0": "éxito"
    },
    "aperturas": [
      "algorithm"
    ]
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
    "codigo_salida": 9
  },
  "operacion": "cli",
  "cli": {
    "argumentos": [
      "comprobar"
    ]
  }
}
```
