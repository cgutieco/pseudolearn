---
{
  "formato": "see/1",
  "id": "TOOL.CLI.IR",
  "titulo": "Orden ri",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "cli"
  ],
  "resumen": "pseudo ri imprime la RI de un programa.",
  "depende_de": [
    {
      "id": "TOOL.CLI.MESSAGES",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "IR.TEXT-FORMAT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "IR command",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Orden ri

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "pseudo ri analiza el archivo y, sin errores, escribe en la salida estándar la RI canónica de IR.TEXT-FORMAT, aceptada por IR.WELL-FORMEDNESS, con código 0. Con errores escribe los diagnósticos en la salida de error y termina con código 1.",
  "verificacion": [
    "C1",
    "C2",
    "P1"
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ri",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
    }
  }
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 1,
    "salida": "",
    "salida_error": "p.pseudo:2:10: error: Variable no declarada: total [undeclaredVariable]\n"
  },
  "cli": {
    "argumentos": [
      "ir",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir total;\nFinAlgoritmo\n"
    }
  }
}
```

```propiedad
{
  "id": "P1",
  "regla": "R1",
  "generador": {
    "programas": "todos los programas válidos del corpus"
  },
  "propiedad": "La salida de pseudo ri es aceptada por el verificador y su reimpresión es idéntica.",
  "oraculo": "Verificador de IR.WELL-FORMEDNESS y formato canónico.",
  "justificacion": "La ejecuta el sujeto cli en R5."
}
```
