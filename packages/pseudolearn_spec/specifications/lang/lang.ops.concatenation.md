---
{
  "formato": "see/1",
  "id": "LANG.OPS.CONCATENATION",
  "titulo": "Concatenación",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Concatenación.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.TEXT",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.TYPES.CHARACTER",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Concatenación

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "+ concatena cadena y carácter en sus cuatro combinaciones; el resultado es cadena. No convierte número ni lógico a texto. Usa el mismo nivel de precedencia que la suma, y evalúa operandos de izquierda a derecha.",
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
    "es": "Algoritmo P\nEscribir \"a\" + \"b\", \"ab\" + \"c\", \"\" + \"\";\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite \"a\" + \"b\", \"ab\" + \"c\", \"\" + \"\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ababc\n",
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
    "es": "Algoritmo P\nEscribir \"ab\" + 2;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite \"ab\" + 2;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "cannotConcatenateNumberWithText",
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
