---
{
  "formato": "see/1",
  "id": "LANG.ARRAY.ACCESS",
  "titulo": "Acceso a arreglos",
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
  "resumen": "Acceso a arreglos.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.ARRAY.DIMENSION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Acceso a arreglos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los índices son enteros cero basados; cada dimensión de tamaño N admite 0 a N-1. Un solo par de corchetes contiene todos los índices, evaluados izquierda a derecha y una vez. El número coincide con dimensiones. Lista vacía y corchetes encadenados son sintácticos; índice no entero o cantidad incorrecta son semánticos; fuera de rango es de ejecución.",
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
    "es": "Algoritmo P\nDimension a[1] Como Entero;\na[0] <- 7;\nEscribir a[0];\nFinAlgoritmo\n",
    "en": "algorithm P\ndimension a[1] as integer;\na[0] <- 7;\nwrite a[0];\nendAlgorithm\n"
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

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDimension a[0] Como Entero;\nEscribir a[0];\nFinAlgoritmo\n",
    "en": "algorithm P\ndimension a[0] as integer;\nwrite a[0];\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "arrayIndexOutOfRange"
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
    "es": "Algoritmo P\nDimension a[1] Como Entero;\nEscribir a[-1];\nFinAlgoritmo\n",
    "en": "algorithm P\ndimension a[1] as integer;\nwrite a[-1];\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "arrayIndexOutOfRange"
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
    "es": "Algoritmo P\nDimension a[1, 1] Como Entero;\na[0][0] <- 1;\nFinAlgoritmo\n",
    "en": "algorithm P\ndimension a[1, 1] as integer;\na[0][0] <- 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "chainedArrayAccess",
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
