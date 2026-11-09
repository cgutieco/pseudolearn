---
{
  "formato": "see/1",
  "id": "LANG.SUBPROGRAM.PARAMETERS",
  "titulo": "Parámetros",
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
  "resumen": "Parámetros.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.SUBPROGRAM.DECLARATION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Parámetros

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada parámetro tiene nombre, tipo obligatorio y dimensiones opcionales mediante [] [,]. La marca Por Valor o Por Referencia va después del tipo y solo alcanza ese parámetro. Sin marca se pasa por valor; arreglo se pasa por referencia y marcarlo Por Valor es error semántico. Cero parámetros es válido. Nombre duplicado o marcas repetidas se rechazan.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5"
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
    "es": "SubProceso f(value Como Entero) Como Entero\nRetornar value + 1;\nFinSubProceso\nAlgoritmo P\nEscribir f(2);\nFinAlgoritmo\n",
    "en": "subroutine f(value as integer) as integer\nreturn value + 1;\nendSubroutine\nalgorithm P\nwrite f(2);\nendAlgorithm\n"
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
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso f()\n  Escribir 1;\nFinSubProceso\n\nAlgoritmo P\n  f(1);\nFinAlgoritmo\n",
    "en": "Subroutine f()\n  Write 1;\nEndSubroutine\n\nAlgorithm P\n  f(1);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "argumentCountMismatch",
        "severidad": "error"
      }
    ]
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
    "es": "SubProceso f(x Como Entero, x Como Entero)\n  Escribir x;\nFinSubProceso\n\nAlgoritmo P\n  f(1, 2);\nFinAlgoritmo\n",
    "en": "Subroutine f(x As Integer, x As Integer)\n  Write x;\nEndSubroutine\n\nAlgorithm P\n  f(1, 2);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "duplicateParameterName",
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
    "es": "SubProceso Duplicar(numero Como Entero Por Referencia)\n  numero <- numero * 2;\nFinSubProceso\n\nAlgoritmo Puntaje\n  Definir puntos Como Entero <- 5;\n  Duplicar(puntos);\n  Escribir puntos;\nFinAlgoritmo\n",
    "en": "Subroutine Double(number As Integer By Reference)\n  number <- number * 2;\nEndSubroutine\n\nAlgorithm Score\n  Define points As Integer <- 5;\n  Double(points);\n  Write points;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "10\n",
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
    "es": "SubProceso Duplicar(numero Como Entero Por Valor)\n  numero <- numero * 2;\n  Escribir numero;\nFinSubProceso\n\nAlgoritmo Puntaje\n  Definir puntos Como Entero <- 5;\n  Duplicar(puntos);\n  Escribir puntos;\nFinAlgoritmo\n",
    "en": "Subroutine Double(number As Integer By Value)\n  number <- number * 2;\n  Write number;\nEndSubroutine\n\nAlgorithm Score\n  Define points As Integer <- 5;\n  Double(points);\n  Write points;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "10\n5\n",
    "terminacion": "completed"
  }
}
```
