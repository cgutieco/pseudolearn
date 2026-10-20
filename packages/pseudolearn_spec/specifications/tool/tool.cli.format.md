---
{
  "formato": "see/1",
  "id": "TOOL.CLI.FORMAT",
  "titulo": "Orden formatear de la CLI",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "0.1.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "cli"
  ],
  "resumen": "pseudo formatear aplica el formato canónico a archivos de código fuente.",
  "depende_de": [
    {
      "id": "TOOL.CLI.CONVENTIONS",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.CLI.MESSAGES",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.FORMAT.STYLE",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Format CLI command",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ],
  "cambio": {
    "clase": "editorial",
    "impacto_usuarios": "Contrato existente respaldado; no cambia su comportamiento observable.",
    "impacto_implementaciones": "Se conserva la versión numérica y las exenciones explícitas de cada sujeto.",
    "justificacion": "Promoción revisada con evidencias vigentes y verificadores locales ejecutados.",
    "revisado_por": "revision-independiente-automatizada-r9"
  }
}
---

# Orden formatear de la CLI

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "pseudo formatear <archivo> (alias format) imprime en stdout el programa formateado con código de salida 0. Con --escribir (alias --write y -w) actualiza el archivo en disco e informa en stdout.",
  "verificacion": [
    "C1"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Con --verificar (alias --check), no escribe el código formateado en stdout ni modifica el archivo: devuelve 0 si el archivo ya está en forma canónica y 1 con mensaje en stderr si requiere formateo.",
  "verificacion": [
    "C2",
    "C3"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Si el archivo contiene errores sintácticos o no existe, devuelve el código de salida correspondiente (1 para errores del programa, 2 para archivo faltante) sin modificar el archivo en disco.",
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
    "salida": "Algoritmo Principal\n  Definir x Como Entero;\nFinAlgoritmo\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "formatear",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "algoritmo Principal\ndefinir x como entero\nfinalgoritmo\n"
    }
  }
}
```

```caso
{
  "id": "C2",
  "regla": "R2",
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
    "salida": "",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "formatear",
      "--verificar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo Principal\n  Definir x Como Entero;\nFinAlgoritmo\n"
    }
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R2",
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
    "salida_error": "pseudo: el archivo requiere formateo: p.pseudo\n"
  },
  "cli": {
    "argumentos": [
      "formatear",
      "--verificar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "algoritmo Principal\ndefinir x como entero\nfinalgoritmo\n"
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
    "codigo_salida": 1,
    "salida": ""
  },
  "cli": {
    "argumentos": [
      "formatear",
      "invalido.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "invalido.pseudo": "Algoritmo SinFin\n"
    }
  }
}
```
