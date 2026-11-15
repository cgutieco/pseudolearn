---
{
  "formato": "see/1",
  "id": "LANG.OPS.COMPARISON",
  "titulo": "Comparaciones",
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
  "resumen": "Comparaciones.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.RELATIONS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Comparaciones

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Orden e igualdad numéricos amplían entero a real si hace falta. Textos y caracteres admiten comparación compatible; lógicos solo igualdad. Objetos admiten igualdad por identidad. Los arreglos no se comparan. Los valores de un mismo enumerado y los registros de un mismo tipo admiten igualdad y desigualdad, sin orden. Igualdad entre reales produce advertencia realEqualityComparison, sin cambiar el valor.",
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
    "es": "Algoritmo P\nEscribir 2 < 3, 2 = 2, \"ab\" < \"cd\";\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 2 < 3, 2 = 2, \"ab\" < \"cd\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}{{lexema:booleanTrue}}{{lexema:booleanTrue}}\n",
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
    "es": "Algoritmo P\n  Escribir Verdadero < Falso;\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Write True < False;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "noOrderBetweenBooleans",
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
    "es": "Algoritmo P\n  Escribir 2.0 = 2.0;\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Write 2.0 = 2.0;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "realEqualityComparison",
        "severidad": "warning"
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
    "es": "Algoritmo Calificacion\n  Definir nota Como Entero <- 7;\n  Si nota >= 6 Entonces\n    Escribir \"Aprobado\";\n  Sino\n    Escribir \"Reprobado\";\n  FinSi\n  Si nota <> 10 Entonces\n    Escribir \"Puedes mejorar\";\n  FinSi\nFinAlgoritmo\n",
    "en": "Algorithm Grading\n  Define grade As Integer <- 7;\n  If grade >= 6 Then\n    Write \"Aprobado\";\n  Else\n    Write \"Reprobado\";\n  EndIf\n  If grade <> 10 Then\n    Write \"Puedes mejorar\";\n  EndIf\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Aprobado\nPuedes mejorar\n",
    "terminacion": "completed"
  }
}
```
