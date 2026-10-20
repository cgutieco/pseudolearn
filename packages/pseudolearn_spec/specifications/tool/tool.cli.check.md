---
{
  "formato": "see/1",
  "id": "TOOL.CLI.CHECK",
  "titulo": "Orden comprobar",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "0.1.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "cli"
  ],
  "resumen": "pseudo comprobar sobre archivos y directorios.",
  "depende_de": [
    {
      "id": "TOOL.CLI.MESSAGES",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "API.ANALYZE",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Check command",
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

# Orden comprobar

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "pseudo comprobar analiza cada archivo indicado y cada archivo .pseudo de los directorios indicados, recursivamente y en orden lexicográfico de ruta. Escribe en la salida estándar una línea por diagnóstico, en el orden de DIAG.ORDERING, con la plantilla de su severidad y el mensaje de DIAG.MESSAGES en el idioma de interfaz. Sin diagnósticos no escribe nada.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5"
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
    "salida": "",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
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
    "codigo_salida": 0,
    "salida": "",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "check",
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
  "id": "C3",
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
    "salida": "p.pseudo:2:10: error: Variable no declarada: total [undeclaredVariable]\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir total;\nFinAlgoritmo\n"
    }
  }
}
```

```caso
{
  "id": "C4",
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
    "salida": "p.pseudo:2:10: error: Undeclared variable: total [undeclaredVariable]\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "--idioma",
      "en",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir total;\nFinAlgoritmo\n"
    }
  }
}
```

```caso
{
  "id": "C5",
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
    "salida": "src/b.pseudo:2:10: error: Variable no declarada: total [undeclaredVariable]\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "src"
    ],
    "entorno": {},
    "archivos": {
      "src/a.pseudo": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
      "src/b.pseudo": "Algoritmo P\nEscribir total;\nFinAlgoritmo\n",
      "src/notas.txt": "Escribir total;\n"
    }
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El código de salida es 1 si algún archivo tiene un diagnóstico de severidad error y 0 si solo hay advertencias o información. Un archivo o directorio ilegible es un error operativo con código 3 y ninguna ruta es un uso incorrecto con código 2.",
  "verificacion": [
    "C6",
    "C7",
    "C8",
    "C9"
  ]
}
```

```caso
{
  "id": "C6",
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
    "salida": "p.pseudo:2:9: advertencia: Variable declarada y nunca usada: x [variableDeclaredNeverUsed]\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nDefinir x Como Entero;\nFinAlgoritmo\n"
    }
  }
}
```

```caso
{
  "id": "C7",
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
    "codigo_salida": 2,
    "salida": "",
    "salida_error": "pseudo: falta el archivo de entrada\n"
  },
  "cli": {
    "argumentos": [
      "comprobar"
    ],
    "entorno": {}
  }
}
```

```caso
{
  "id": "C8",
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
    "codigo_salida": 3,
    "salida": "",
    "salida_error": "pseudo: no se puede leer falta.pseudo\n"
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "falta.pseudo"
    ],
    "entorno": {}
  }
}
```

```caso
{
  "id": "C9",
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
    "salida": "p.pseudo:2:10: advertencia: Variable no declarada: total [undeclaredVariable]\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "--rigor",
      "flexible",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir total;\nFinAlgoritmo\n"
    }
  }
}
```
