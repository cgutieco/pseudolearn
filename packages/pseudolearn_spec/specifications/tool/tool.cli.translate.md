---
{
  "formato": "see/1",
  "id": "TOOL.CLI.TRANSLATE",
  "titulo": "Orden traducir de la CLI",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "cli"
  ],
  "resumen": "pseudo traducir convierte código fuente entre perfiles es y en.",
  "depende_de": [
    {
      "id": "TOOL.CLI.CONVENTIONS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.CLI.MESSAGES",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.TRANSLATE.ROUND-TRIP",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Translate CLI command",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Orden traducir de la CLI

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "pseudo traducir <archivo> --hacia <es|en> (alias translate, --to) emite en stdout (o en la ruta indicada por -o, --salida o --output) el programa traducido al perfil destino con código de salida 0.",
  "verificacion": [
    "C1",
    "C2"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Si el programa contiene un identificador que colisiona con una palabra reservada del perfil destino o tiene errores de análisis, escribe el diagnóstico correspondiente en stderr y termina con código 1.",
  "verificacion": [
    "C3"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Si falta la opción requerida --hacia (alias --to) o su valor no es un perfil válido (es o en), escribe el mensaje de error de uso en stderr y termina con código 2.",
  "verificacion": [
    "C4"
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
    "salida": "Algorithm Principal\n  Write 1;\nEndAlgorithm\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "traducir",
      "--hacia",
      "en",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo Principal\n  Escribir 1;\nFinAlgoritmo\n"
    }
  }
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "en"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "Algoritmo Principal\n  Escribir 1;\nFinAlgoritmo\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "translate",
      "--to",
      "es",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algorithm Principal\n  Write 1;\nEndAlgorithm\n"
    }
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R2",
  "perfiles": [
    "en"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 1,
    "salida": ""
  },
  "cli": {
    "argumentos": [
      "translate",
      "--to",
      "es",
      "colision.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "colision.pseudo": "Algorithm Colision\n  Define fin As Integer;\nEndAlgorithm\n"
    }
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 2,
    "salida": "",
    "salida_error": "pseudo: falta la opción requerida --hacia (--to)\n"
  },
  "cli": {
    "argumentos": [
      "traducir",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nFinAlgoritmo\n"
    }
  }
}
```
