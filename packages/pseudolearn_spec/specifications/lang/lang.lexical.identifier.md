---
{
  "formato": "see/1",
  "id": "LANG.LEXICAL.IDENTIFIER",
  "titulo": "Identificadores",
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
  "resumen": "Identificadores.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.SOURCE.ENCODING",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Identificadores

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un nombre empieza por letra o guion bajo y continúa con letras, dígitos o guion bajo. Estricto admite letras ASCII; flexible añade ñ, vocales españolas acentuadas y ü, en ambas cajas. El alfabeto se comprueba después de NFC. Un nombre de un carácter es válido. Los nombres se comparan exactamente después de NFC; la política de palabras clave solo interviene para excluir nombres reservados.",
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
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero;\nx <- 1;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer;\nx <- 1;\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
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
    "es": "Algoritmo P\nDefinir _x2 Como Entero;\n_x2 <- 2;\nEscribir _x2;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine _x2 as integer;\n_x2 <- 2;\nwrite _x2;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
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
    "es": "Algoritmo P\nDefinir año Como Entero;\naño <- 3;\nEscribir año;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine año as integer;\naño <- 3;\nwrite año;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n",
    "terminacion": "completed"
  },
  "rigor": [
    "flexible"
  ]
}
```

```caso
{
  "id": "C4",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir @;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite @;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "unrecognizedCharacter",
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
  "id": "C5",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir value, Value Como Entero;\nvalue <- 1;\nValue <- 2;\nEscribir value, Value;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine value, Value as integer;\nvalue <- 1;\nValue <- 2;\nwrite value, Value;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "12\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```
