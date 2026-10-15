---
{
  "formato": "see/1",
  "id": "LIB.CORE.TEXT",
  "titulo": "Funciones de texto y carácter",
  "dominio": "biblioteca",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Funciones de texto y carácter.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LIB.MODEL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.TYPES.CHARACTER",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ],
  "cambio": {
    "clase": "ampliacion",
    "impacto_usuarios": "Activa la comprobación del motor Rust sin cambiar programas válidos.",
    "impacto_implementaciones": "Actualiza contratos y casos derivados para ejecución portable y verificable.",
    "justificacion": "Eliminar ambigüedades antes de implementar la ejecución determinista.",
    "revisado_por": "autorización de la fase R5 en la conversación"
  }
}
---

# Funciones de texto y carácter

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Longitud cuenta puntos de código de cadena, también vacía. CaracterEn(cadena, índice) devuelve carácter cero basado o stringPositionOutOfRange. CodigoDe(caracter) devuelve su escalar Unicode. CaracterDesde(entero) exige [0,1114111] excluyendo [55296,57343] y falla con invalidCharacterCode fuera de ese dominio. No normalizan contenido.",
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
  "programas": {
    "es": "Algoritmo P\nEscribir Longitud(\"😀a\"), \":\", CaracterEn(\"😀a\", 0), \":\", CodigoDe(\"😀\"), \":\", CaracterDesde(128512);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite length(\"😀a\"), \":\", charAt(\"😀a\", 0), \":\", charCode(\"😀\"), \":\", charFromCode(128512);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2:😀:128512:😀\n",
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
    "es": "Algoritmo P\nEscribir CaracterEn(\"ab\", 2);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite charAt(\"ab\", 2);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "stringPositionOutOfRange"
    }
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
    "es": "Algoritmo P\nEscribir CaracterDesde(-1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite charFromCode(-1);\nendAlgorithm\n"
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

```caso
{
  "id": "C4",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir CaracterDesde(1114112);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite charFromCode(1114112);\nendAlgorithm\n"
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
