---
{
  "formato": "see/1",
  "id": "LANG.ARRAY.DIMENSION",
  "titulo": "Dimensionamiento de arreglos",
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
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Dimensionamiento de arreglos.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.ARRAY",
      "version": ">=1.0.0, <2.0.0",
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
  "texto": "Dimension nombre[d₁, …] Como tipo declara nombre, dimensiones y tipo en una sola sentencia. Sin Como tipo, Dimension adopta una variable ya declarada con Definir en el mismo ámbito, sin valor inicial y sin ningún uso entre las dos sentencias: pasa a ser un arreglo del tipo declarado con esas dimensiones y desde ahí tiene valor. Si el nombre no cumple esas condiciones, es dimensionWithoutType, error, con origen relacionado en la declaración cuando existe. En los campos de clase el tipo sigue siendo obligatorio. Las dimensiones son expresiones enteras que se evalúan al ejecutar. Tamaño cero es válido; negativo falla. No se admite lista vacía ni declaración duplicada. No se fija un máximo semántico de tamaño: recursos pertenecen al contrato del motor.",
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
    "C10",
    "C11",
    "C12"
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
    "es": "Algoritmo P\n  Dimension a[-1] Como Entero;\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Dimension a[-1] As Integer;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "negativeArraySize"
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
    "es": "Algoritmo P\nDimension a[2, 3] Como Entero;\na[1, 2] <- 7;\nEscribir a[1, 2];\nFinAlgoritmo\n",
    "en": "algorithm P\ndimension a[2, 3] as integer;\na[1, 2] <- 7;\nwrite a[1, 2];\nendAlgorithm\n"
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
  "id": "C5",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir v Como Real;\nDimension v[3];\nv[0] <- 1.5;\nv[2] <- 2;\nEscribir v[0] + v[2];\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine v as real;\ndimension v[3];\nv[0] <- 1.5;\nv[2] <- 2;\nwrite v[0] + v[2];\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3.5\n",
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
    "es": "Algoritmo P\nDefinir v Como Entero;\nDimension v[0];\nEscribir \"vacio\";\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine v as integer;\ndimension v[0];\nwrite \"vacio\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "vacio\n",
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
    "es": "Algoritmo P\n  Dimension w[3];\n  Escribir 1;\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Dimension w[3];\n  Write 1;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "dimensionWithoutType",
        "severidad": "error",
        "argumentos": {
          "lexeme": "w"
        }
      }
    ]
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
    "es": "Algoritmo P\nDefinir v Como Entero <- 1;\nDimension v[3];\nEscribir 1;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine v as integer <- 1;\ndimension v[3];\nwrite 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "dimensionWithoutType",
        "severidad": "error",
        "argumentos": {
          "lexeme": "v"
        }
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
    "es": "Algoritmo P\nDefinir v Como Entero;\nv <- 2;\nDimension v[3];\nEscribir 1;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine v as integer;\nv <- 2;\ndimension v[3];\nwrite 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "dimensionWithoutType",
        "severidad": "error",
        "argumentos": {
          "lexeme": "v"
        }
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
    "es": "Algoritmo P\nDefinir v Como Entero;\nSi Verdadero Entonces\nDimension v[3];\nFinSi\nEscribir 1;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine v as integer;\nif true then\ndimension v[3];\nendIf\nwrite 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "dimensionWithoutType",
        "severidad": "error",
        "argumentos": {
          "lexeme": "v"
        }
      }
    ]
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir m Como Entero;\nDimension m[2, 3];\nm[1, 2] <- 7;\nEscribir m[1, 2];\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine m as integer;\ndimension m[2, 3];\nm[1, 2] <- 7;\nwrite m[1, 2];\nendAlgorithm\n"
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
  "id": "C12",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo Notas\n  Dimension notas[3] Como Entero;\n  notas[0] <- 7;\n  notas[1] <- 9;\n  notas[2] <- 8;\n  Escribir notas[0] + notas[1] + notas[2];\nFinAlgoritmo\n",
    "en": "Algorithm Grades\n  Dimension grades[3] As Integer;\n  grades[0] <- 7;\n  grades[1] <- 9;\n  grades[2] <- 8;\n  Write grades[0] + grades[1] + grades[2];\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "24\n",
    "terminacion": "completed"
  }
}
```
