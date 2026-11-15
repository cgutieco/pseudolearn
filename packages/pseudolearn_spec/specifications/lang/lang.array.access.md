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
    "César Antonio Gutiérrez Contreras"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Acceso a arreglos.",
  "edicion": {
    "introducida_en": "2027"
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
    "C4",
    "C5",
    "C6"
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
    "es": "Algoritmo P\nDimension a[0] Como Entero;\nEscribir a[0];\nFinAlgoritmo\n",
    "en": "algorithm P\ndimension a[0] as integer;\nwrite a[0];\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "arrayIndexOutOfRange"
    }
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
    "es": "Algoritmo P\n  Dimension a[1] Como Entero;\n  Escribir a[-1];\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Dimension a[1] As Integer;\n  Write a[-1];\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "arrayIndexOutOfRange"
    }
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
    "es": "Algoritmo Temperaturas\n  Dimension temperaturas[3] Como Entero;\n  Definir posicion Como Entero <- 2;\n  temperaturas[0] <- 20;\n  temperaturas[1] <- 25;\n  temperaturas[2] <- 18;\n  Escribir temperaturas[0];\n  Escribir temperaturas[posicion];\nFinAlgoritmo\n",
    "en": "Algorithm Temperatures\n  Dimension temperatures[3] As Integer;\n  Define position As Integer <- 2;\n  temperatures[0] <- 20;\n  temperatures[1] <- 25;\n  temperatures[2] <- 18;\n  Write temperatures[0];\n  Write temperatures[position];\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "20\n18\n",
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
    "es": "Algoritmo Notas\n  Dimension notas[3] Como Entero;\n  notas[0] <- 7;\n  notas[1] <- 9;\n  notas[2] <- 8;\n  Escribir notas[3];\nFinAlgoritmo\n",
    "en": "Algorithm Grades\n  Dimension grades[3] As Integer;\n  grades[0] <- 7;\n  grades[1] <- 9;\n  grades[2] <- 8;\n  Write grades[3];\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "arrayIndexOutOfRange"
    }
  }
}
```
