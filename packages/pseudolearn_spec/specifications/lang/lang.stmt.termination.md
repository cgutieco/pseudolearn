---
{
  "formato": "see/1",
  "id": "LANG.STMT.TERMINATION",
  "titulo": "Terminación de sentencias",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
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
  "resumen": "Terminación de sentencias.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.LEXICAL.WHITESPACE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Terminación de sentencias

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las sentencias simples terminan con punto y coma o fin de línea; estricto exige punto y coma incluso antes del cierre del bloque. Aperturas y cierres de bloques no lo exigen. Llamadas y retornos son simples. Líneas vacías no producen sentencias. Se admiten varias sentencias en una línea separadas por punto y coma.",
  "verificacion": [
    "C1",
    "C2",
    "C3"
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
    "es": "Algoritmo P\nEscribir 1; Escribir 2;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1; write 2;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n2\n",
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
    "es": "Algoritmo P\nEscribir 1\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "missingStatementTerminator",
        "severidad": "error"
      }
    ]
  },
  "rigor": [
    "estricto"
  ]
}
```

```caso
{
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\n\n\nEscribir 1\nFinAlgoritmo\n",
    "en": "algorithm P\n\n\nwrite 1\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  },
  "rigor": [
    "flexible"
  ]
}
```
