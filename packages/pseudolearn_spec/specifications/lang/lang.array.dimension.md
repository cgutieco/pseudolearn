---
{
  "formato": "see/1",
  "id": "LANG.ARRAY.DIMENSION",
  "titulo": "Dimensionamiento de arreglos",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Dimensionamiento de arreglos.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.ARRAY",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Dimensionamiento de arreglos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Dimension declara nombre, dimensiones y tipo en una sola sentencia. Las dimensiones son expresiones enteras; estricto exige expresiones constantes formadas por literales y operadores, sin identificadores. Flexible permite tamaños de ejecución. Tamaño cero es válido; negativo falla. No se admite lista vacía ni declaración duplicada. No se fija un máximo semántico de tamaño: recursos pertenecen al contrato del motor.",
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
    "es": "Algoritmo P\nDimension a[0] Como Entero;\nFinAlgoritmo\n",
    "en": "algorithm P\ndimension a[0] as integer;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
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
    "es": "Algoritmo P\nDimension a[-1] Como Entero;\nFinAlgoritmo\n",
    "en": "algorithm P\ndimension a[-1] as integer;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "negativeArraySize"
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
    "es": "Algoritmo P\nDimension a[] Como Entero;\nFinAlgoritmo\n",
    "en": "algorithm P\ndimension a[] as integer;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "emptyDimensionList",
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
  "id": "C4",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDimension a[2, 3] Como Entero;\na[1, 2] <- 7;\nEscribir a[1, 2];\nFinAlgoritmo\n",
    "en": "algorithm P\ndimension a[2, 3] as integer;\na[1, 2] <- 7;\nwrite a[1, 2];\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```
