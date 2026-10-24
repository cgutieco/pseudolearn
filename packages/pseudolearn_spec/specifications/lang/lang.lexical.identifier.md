---
{
  "formato": "see/1",
  "id": "LANG.LEXICAL.IDENTIFIER",
  "titulo": "Identificadores",
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
  "resumen": "Identificadores.",
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

# Identificadores

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un nombre empieza por letra ASCII, letra española (ñ, vocal acentuada o ü) o guion bajo y continúa con esas letras, dígitos ASCII o guion bajo. Ambos rigores admiten el mismo alfabeto y ambos perfiles lo aplican. El alfabeto se comprueba sobre el nombre completo después de NFC; una forma descompuesta solo se admite si NFC la convierte a caracteres de este alfabeto. Un nombre de un carácter es válido. Los nombres se comparan exactamente después de NFC, con sensibilidad a caja y acentos; la política de palabras clave solo interviene para excluir nombres reservados.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6",
    "C7",
    "C8",
    "C9",
    "C10"
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

```caso
{
  "id": "C6",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "programas": {
    "es": "Algoritmo P\nDefinir ñ, Ñ, áx, Áx, éx, Éx, íx, Íx, óx, Óx, úx, Úx, üx, Üx, ano, año, ax, Ax Como Entero;\nñ <- 1;\nÑ <- 2;\náx <- 3;\nÁx <- 4;\néx <- 5;\nÉx <- 6;\níx <- 7;\nÍx <- 8;\nóx <- 9;\nÓx <- 10;\núx <- 11;\nÚx <- 12;\nüx <- 13;\nÜx <- 14;\nano <- 15;\naño <- 16;\nax <- 17;\nAx <- 18;\nEscribir ñ, Ñ, áx, Áx, éx, Éx, íx, Íx, óx, Óx, úx, Úx, üx, Üx, ano, año, ax, Ax;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine ñ, Ñ, áx, Áx, éx, Éx, íx, Íx, óx, Óx, úx, Úx, üx, Üx, ano, año, ax, Ax as integer;\nñ <- 1;\nÑ <- 2;\náx <- 3;\nÁx <- 4;\néx <- 5;\nÉx <- 6;\níx <- 7;\nÍx <- 8;\nóx <- 9;\nÓx <- 10;\núx <- 11;\nÚx <- 12;\nüx <- 13;\nÜx <- 14;\nano <- 15;\naño <- 16;\nax <- 17;\nAx <- 18;\nwrite ñ, Ñ, áx, Áx, éx, Éx, íx, Íx, óx, Óx, úx, Úx, üx, Üx, ano, año, ax, Ax;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "123456789101112131415161718\n",
    "terminacion": "completed"
  },
  "rigor": ["estricto", "flexible"]
}
```

```caso
{
  "id": "C7",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "programas": {
    "es": "Algoritmo P\nDefinir año Como Entero;\nan\u0303o <- 7;\nEscribir año;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine año as integer;\nan\u0303o <- 7;\nwrite año;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\n",
    "terminacion": "completed"
  },
  "rigor": ["estricto", "flexible"]
}
```

```caso
{
  "id": "C8",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "programas": {
    "es": "Algoritmo P\nEscribir ç;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite ç;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {"codigo": "unrecognizedCharacter", "severidad": "error"}
    ]
  },
  "rigor": ["estricto", "flexible"]
}
```

```caso
{
  "id": "C9",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "programas": {
    "es": "Algoritmo P\nEscribir \u0301;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite \u0301;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {"codigo": "unrecognizedCharacter", "severidad": "error"}
    ]
  },
  "rigor": ["estricto", "flexible"]
}
```

```caso
{
  "id": "C10",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "programas": {
    "es": "Algoritmo P\nDefinir año, an\u0303o Como Entero;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine año, an\u0303o as integer;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {"codigo": "duplicateVariableDeclaration", "severidad": "error"}
    ]
  },
  "rigor": ["estricto", "flexible"]
}
```
