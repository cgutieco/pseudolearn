---
{
  "formato": "see/1",
  "id": "LANG.TYPES.BOOLEAN",
  "titulo": "Tipo lógico",
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
  "resumen": "Tipo lógico.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.PROFILE.VOCABULARY",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Tipo lógico

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El tipo lógico tiene exactamente dos valores. No es numérico, no admite orden y no se convierte implícitamente a número ni texto. Su representación visible es el lexema canónico del perfil activo.",
  "verificacion": [
    "C1",
    "C2",
    "C3"
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
    "es": "Algoritmo P\nEscribir Verdadero, Falso;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite true, false;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}{{lexema:booleanFalse}}\n",
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
    "es": "Algoritmo P\n  Escribir Verdadero + 1;\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Write True + 1;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleOperandTypes",
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
    "es": "Algoritmo Luz\n  Definir encendida Como Logico <- Verdadero;\n  Si encendida Entonces\n    Escribir \"Luz encendida\";\n  FinSi\n  encendida <- Falso;\n  Si encendida Entonces\n    Escribir \"Sigue encendida\";\n  Sino\n    Escribir \"Luz apagada\";\n  FinSi\nFinAlgoritmo\n",
    "en": "Algorithm Light\n  Define lit As Boolean <- True;\n  If lit Then\n    Write \"Luz encendida\";\n  EndIf\n  lit <- False;\n  If lit Then\n    Write \"Sigue encendida\";\n  Else\n    Write \"Luz apagada\";\n  EndIf\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Luz encendida\nLuz apagada\n",
    "terminacion": "completed"
  }
}
```
