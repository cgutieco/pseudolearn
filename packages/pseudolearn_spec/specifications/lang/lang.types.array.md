---
{
  "formato": "see/1",
  "id": "LANG.TYPES.ARRAY",
  "titulo": "Tipo arreglo",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference"
  ],
  "resumen": "Tipo arreglo.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.INTEGER",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Tipo arreglo

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El tipo arreglo incluye tipo de elemento y número de dimensiones, no tamaños. Un arreglo no es un valor asignable, comparable, imprimible ni retornable. Solo el nombre como argumento de parámetro arreglo permite acceso al arreglo completo; sus elementos sí son designadores.",
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
    "es": "Algoritmo P\nDimension a[1] Como Entero;\na[0] <- 2;\nEscribir a[0];\nFinAlgoritmo\n",
    "en": "algorithm P\ndimension a[1] as integer;\na[0] <- 2;\nwrite a[0];\nendAlgorithm\n"
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
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDimension a[1] Como Entero;\nEscribir a;\nFinAlgoritmo\n",
    "en": "algorithm P\ndimension a[1] as integer;\nwrite a;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "arrayCannotBeUsedAsValue",
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
