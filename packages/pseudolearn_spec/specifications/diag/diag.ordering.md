---
{
  "formato": "see/1",
  "id": "DIAG.ORDERING",
  "titulo": "Orden de diagnósticos",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Orden de diagnósticos.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "DIAG.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Orden de diagnósticos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El orden público es independiente del orden de descubrimiento y del idioma de interfaz. En un proyecto, cada diagnóstico con fuente se ordena por nombre de paquete normalizado a NFC y minúsculas Unicode, segmentos de módulo normalizados en NFC conservando caja, fase léxica, sintáctica y semántica, posición original, extensión y código. Las demás clases siguen en orden de clase después de esas fases y usan posición, extensión y código. La severidad, los argumentos tipados y la secuencia de ubicaciones relacionadas desempatan sin usar prosa ni identificadores opacos; relacionados conserva su orden significativo. Los diagnósticos sin fuente van después de los que tienen fuente y usan las mismas claves locales. En una fuente sin proyecto se conserva la misma clave local. No se elimina multiplicidad para ocultar una cascada: cada diagnóstico permitido aparece una vez por situación. La comparación puede ser por multiconjunto cuando el caso no observa orden.",
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
    "es": "Algoritmo P\nDefinir Como Entero;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine as integer;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedIdentifierInDeclaration",
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
    "es": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir @;\nEscribir $;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite @;\nwrite $;\nendAlgorithm\n"
  },
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
  "origen": "derivado"
}
```
