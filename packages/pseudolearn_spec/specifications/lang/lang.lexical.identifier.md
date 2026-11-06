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
  "texto": "Un nombre empieza por letra ASCII, letra española (ñ, vocal acentuada o ü) o guion bajo y continúa con esas letras, dígitos ASCII o guion bajo. Ambos perfiles aplican el mismo alfabeto. El alfabeto se comprueba sobre el nombre completo después de NFC; una forma descompuesta solo se admite si NFC la convierte a caracteres de este alfabeto. Un nombre de un carácter es válido. Los nombres se comparan exactamente después de NFC, con sensibilidad a caja y acentos; la política de palabras clave solo interviene para excluir nombres reservados.",
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

```definicion
{
  "id": "D1",
  "termino": "textmateIdentifier",
  "texto": "Alfabeto declarativo para resaltar candidatos a identificador; el consumidor no lo usa para decidir validez ni identidad.",
  "valor": {
    "start": "[A-Za-zñÑáéíóúüÁÉÍÓÚÜ_]",
    "continue": "[A-Za-zñÑáéíóúüÁÉÍÓÚÜ_0-9\\p{M}]"
  }
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
    "es": "Algoritmo P\nDefinir x Como Entero <- 1;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer <- 1;\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  }
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
    "es": "Algoritmo P\nDefinir _x2 Como Entero <- 2;\nEscribir _x2;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine _x2 as integer <- 2;\nwrite _x2;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
    "terminacion": "completed"
  }
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
    "es": "Algoritmo P\nDefinir año Como Entero <- 3;\nEscribir año;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine año as integer <- 3;\nwrite año;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n",
    "terminacion": "completed"
  }
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
  }
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
    "es": "Algoritmo P\nDefinir value Como Entero <- 1;\nDefinir Value Como Entero <- 0;\nValue <- 2;\nEscribir value, Value;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine value as integer <- 1;\ndefine Value as integer <- 0;\nValue <- 2;\nwrite value, Value;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "12\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir ñ Como Entero <- 1;\nDefinir Ñ Como Entero <- 0;\nDefinir áx Como Entero <- 0;\nDefinir Áx Como Entero <- 0;\nDefinir éx Como Entero <- 0;\nDefinir Éx Como Entero <- 0;\nDefinir íx Como Entero <- 0;\nDefinir Íx Como Entero <- 0;\nDefinir óx Como Entero <- 0;\nDefinir Óx Como Entero <- 0;\nDefinir úx Como Entero <- 0;\nDefinir Úx Como Entero <- 0;\nDefinir üx Como Entero <- 0;\nDefinir Üx Como Entero <- 0;\nDefinir ano Como Entero <- 0;\nDefinir año Como Entero <- 0;\nDefinir ax Como Entero <- 0;\nDefinir Ax Como Entero <- 0;\nÑ <- 2;\náx <- 3;\nÁx <- 4;\néx <- 5;\nÉx <- 6;\níx <- 7;\nÍx <- 8;\nóx <- 9;\nÓx <- 10;\núx <- 11;\nÚx <- 12;\nüx <- 13;\nÜx <- 14;\nano <- 15;\naño <- 16;\nax <- 17;\nAx <- 18;\nEscribir ñ, Ñ, áx, Áx, éx, Éx, íx, Íx, óx, Óx, úx, Úx, üx, Üx, ano, año, ax, Ax;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine ñ as integer <- 1;\ndefine Ñ as integer <- 0;\ndefine áx as integer <- 0;\ndefine Áx as integer <- 0;\ndefine éx as integer <- 0;\ndefine Éx as integer <- 0;\ndefine íx as integer <- 0;\ndefine Íx as integer <- 0;\ndefine óx as integer <- 0;\ndefine Óx as integer <- 0;\ndefine úx as integer <- 0;\ndefine Úx as integer <- 0;\ndefine üx as integer <- 0;\ndefine Üx as integer <- 0;\ndefine ano as integer <- 0;\ndefine año as integer <- 0;\ndefine ax as integer <- 0;\ndefine Ax as integer <- 0;\nÑ <- 2;\náx <- 3;\nÁx <- 4;\néx <- 5;\nÉx <- 6;\níx <- 7;\nÍx <- 8;\nóx <- 9;\nÓx <- 10;\núx <- 11;\nÚx <- 12;\nüx <- 13;\nÜx <- 14;\nano <- 15;\naño <- 16;\nax <- 17;\nAx <- 18;\nwrite ñ, Ñ, áx, Áx, éx, Éx, íx, Íx, óx, Óx, úx, Úx, üx, Üx, ano, año, ax, Ax;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "123456789101112131415161718\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C7",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir año Como Entero <- 0;\naño <- 7;\nEscribir año;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine año as integer <- 0;\naño <- 7;\nwrite año;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir ç;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite ç;\nendAlgorithm\n"
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
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir ́;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite ́;\nendAlgorithm\n"
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
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir año Como Entero <- 0;\nDefinir año Como Entero <- 1;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine año as integer <- 0;\ndefine año as integer <- 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "duplicateVariableDeclaration",
        "severidad": "error"
      }
    ]
  }
}
```
