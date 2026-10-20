---
{
  "formato": "see/1",
  "id": "API.ANALYZE",
  "titulo": "Análisis",
  "dominio": "motor",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Texto, vocabulario y rigor producen tokens, diagnósticos ordenados y un esquema.",
  "depende_de": [
    {
      "id": "API.MODEL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "DIAG.ORDERING",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.PROFILE.MODEL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Analysis"
}
---

# Análisis

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Analizar recibe texto, vocabulario explícito y rigor, y devuelve los diagnósticos en el orden de DIAG.ORDERING, la presencia del árbol y todos los tokens léxicos en orden de fuente con su identidad y tramo. La respuesta conserva comentarios y caracteres Unicode sin normalizar, incluso si el análisis encuentra errores. El vocabulario no se deduce en la API.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4"
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
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos_ordenados": [
      {
        "codigo": "unrecognizedCharacter",
        "severidad": "error",
        "clase": "lexical",
        "argumentos": {
          "lexeme": "@"
        }
      },
      {
        "codigo": "unrecognizedCharacter",
        "severidad": "error",
        "clase": "lexical",
        "argumentos": {
          "lexeme": "$"
        }
      }
    ]
  },
  "programa": "Algoritmo P\nEscribir @;\nEscribir $;\nFinAlgoritmo\n",
  "perfil_base": "es"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "programa": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C3",
  "regla": "R1",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "tokens_include": [
      {"kind": "keyword", "keyword": "algorithm"},
      {"kind": "comment", "span": {"start": {"line": 2, "column": 1}, "end": {"line": 2, "column": 5}}},
      {"kind": "keyword", "keyword": "integerType"},
      {"kind": "operator", "span": {"start": {"line": 4, "column": 3}, "end": {"line": 4, "column": 5}}},
      {"kind": "integer_literal", "span": {"start": {"line": 4, "column": 6}, "end": {"line": 4, "column": 7}}},
      {"kind": "punctuation", "span": {"start": {"line": 4, "column": 7}, "end": {"line": 4, "column": 8}}}
    ]
  },
  "programa": "Algoritmo P\n// ñ\nDefinir n Como Entero;\nn <- 4;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C4",
  "regla": "R1",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "tokens_include": [
      {"kind": "comment", "span": {"start": {"line": 2, "column": 1}, "end": {"line": 2, "column": 5}}},
      {"kind": "invalid_character", "span": {"start": {"line": 4, "column": 1}, "end": {"line": 4, "column": 2}}}
    ]
  },
  "programa": "Algoritmo P\n// ñ\nFinAlgoritmo\n@\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El resultado incluye un esquema con las unidades de nivel superior (algoritmo, subprogramas y clases) con su nombre y tramo, en orden de aparición, también cuando hay errores recuperables.",
  "verificacion": [
    "P1"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R2",
  "generador": {
    "programas": "programas del corpus con y sin errores"
  },
  "propiedad": "El esquema lista cada unidad de nivel superior una vez en orden de aparición.",
  "oraculo": "Recorrido del texto por unidades.",
  "justificacion": "La ejecuta el sujeto engine en R4."
}
```
