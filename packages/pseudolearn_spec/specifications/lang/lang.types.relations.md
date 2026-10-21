---
{
  "formato": "see/1",
  "id": "LANG.TYPES.RELATIONS",
  "titulo": "Relaciones de tipos",
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
  "resumen": "Relaciones de tipos.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.REAL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.TYPES.CLASS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Relaciones de tipos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Igualdad de tipos, asignabilidad y ampliación numérica son relaciones diferentes. Se admite entero a real por ampliación y subclase a superclase por nominalidad. No se convierten implícitamente real a entero, lógico a número, cadena a carácter ni primitivos a texto. Parámetros por referencia exigen coincidencia exacta de tipo.",
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
    "es": "Algoritmo P\nDefinir value Como Real;\nvalue <- 2;\nEscribir value;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine value as real;\nvalue <- 2;\nwrite value;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2.0\n",
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
    "es": "Algoritmo P\nDefinir value Como Entero;\nvalue <- 2.5;\nEscribir value;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine value as integer;\nvalue <- 2.5;\nwrite value;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleTypesInAssignment",
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
