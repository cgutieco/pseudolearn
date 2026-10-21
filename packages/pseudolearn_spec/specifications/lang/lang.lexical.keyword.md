---
{
  "formato": "see/1",
  "id": "LANG.LEXICAL.KEYWORD",
  "titulo": "Palabras reservadas",
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
  "resumen": "Palabras reservadas.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.SOURCE.ENCODING",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Palabras reservadas

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los lexemas de tokens del vocabulario oficial, incluidos alias, son reservados bajo las políticas del perfil. Español ignora caja y acentos del vocabulario; inglés ignora caja y conserva acentos. Y/O y and/or son operadores reservados. No hay palabras contextuales ni escape de nombres en la edición vigente. Las funciones incorporadas no son reservadas. Un lexema reservado en una posición de nombre inequívoca produce reservedLexemeUsedAsName; en una expresión incompleta se informa el error de expresión.",
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
    "es": "Algoritmo P\nDefinir Mientras Como Entero;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine while as integer;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "reservedLexemeUsedAsName",
        "severidad": "error"
      }
    ]
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
    "es": "Algoritmo P\nDefinir sen Como Entero;\nsen <- 4;\nEscribir sen;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine sen as integer;\nsen <- 4;\nwrite sen;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "4\n",
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
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Verdadero Y NO Falso;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite true and not false;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```
