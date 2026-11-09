---
{
  "formato": "see/1",
  "id": "LANG.CONTROL.IF",
  "titulo": "Condicional",
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
  "resumen": "Condicional.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.BOOLEAN",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Condicional

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Si exige condición lógica y Entonces; Sino es opcional y equivale a cuerpo vacío si se omite. Ejecuta solo la rama elegida. Los cuerpos pueden ser vacíos y anidados; una cadena se expresa anidando Si en Sino. Rama contraria duplicada o cierre ausente es sintáctico.",
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
    "es": "Algoritmo P\nSi Verdadero Entonces\nEscribir 1;\nSino\nEscribir 2;\nFinSi\nFinAlgoritmo\n",
    "en": "algorithm P\nif true then\nwrite 1;\nelse\nwrite 2;\nendIf\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
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
    "es": "Algoritmo P\nSi Falso Entonces\nFinSi\nFinAlgoritmo\n",
    "en": "algorithm P\nif false then\nendIf\nendAlgorithm\n"
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
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\n  Si 1 Entonces\n  FinSi\nFinAlgoritmo\n",
    "en": "Algorithm P\n  If 1 Then\n  EndIf\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "nonBooleanCondition",
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
    "es": "Algoritmo P\nSi Verdadero\nFinSi\nFinAlgoritmo\n",
    "en": "algorithm P\nif true\nendIf\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedThenKeyword",
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
    "es": "Algoritmo Mayoria\n  Definir edad Como Entero <- 15;\n  Si edad >= 18 Entonces\n    Escribir \"Adulto\";\n  Sino\n    Escribir \"Menor\";\n  FinSi\nFinAlgoritmo\n",
    "en": "Algorithm Adulthood\n  Define age As Integer <- 15;\n  If age >= 18 Then\n    Write \"Adulto\";\n  Else\n    Write \"Menor\";\n  EndIf\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Menor\n",
    "terminacion": "completed"
  }
}
```
