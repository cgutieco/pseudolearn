---
{
  "formato": "see/1",
  "id": "LANG.TYPES.CHARACTER",
  "titulo": "Tipo carácter",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "0.2.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Tipo carácter.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.LEXICAL.CHARACTER-LITERAL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Tipo carácter

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Carácter representa un valor escalar Unicode. Es distinto de cadena, aunque ambos se concatenan como texto. El código de un carácter suplementario es un único entero; los sustitutos UTF-16 no son caracteres válidos.",
  "verificacion": [
    "C1",
    "C2"
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
    "es": "Algoritmo P\nEscribir CodigoDe(\"😀\"), CaracterDesde(65);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite charCode(\"😀\"), charFromCode(65);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "128512A\n",
    "terminacion": "completed"
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
    "es": "Algoritmo P\nEscribir CaracterDesde(55296);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite charFromCode(55296);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "invalidCharacterCode"
    }
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```
