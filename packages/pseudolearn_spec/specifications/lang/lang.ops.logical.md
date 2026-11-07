---
{
  "formato": "see/1",
  "id": "LANG.OPS.LOGICAL",
  "titulo": "Operadores lógicos",
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
  "resumen": "Operadores lógicos.",
  "edicion": {
    "introducida_en": "2026"
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

# Operadores lógicos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "NO exige lógico y devuelve su negación. Y y O exigen lógicos y evalúan izquierda primero; Y no evalúa derecha si izquierda es falsa, O no evalúa derecha si izquierda es verdadera. El cortocircuito suprime efectos y fallos de la derecha, sin omitir su análisis de tipos.",
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
    "es": "Algoritmo P\nEscribir Falso Y (1 / 0 > 0), Verdadero O (1 / 0 > 0);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite false and (1 / 0 > 0), true or (1 / 0 > 0);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanFalse}}{{lexema:booleanTrue}}\n",
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
    "es": "Algoritmo P\n  Escribir 1 Y Verdadero;\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Write 1 And True;\nEndAlgorithm\n"
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
    "es": "Algoritmo Entrada\n  Definir edad Como Entero <- 15;\n  Definir tieneBoleto Como Logico <- Falso;\n  Si edad >= 13 Y edad <= 17 Entonces\n    Escribir \"Adolescente\";\n  FinSi\n  Si edad < 12 O tieneBoleto Entonces\n    Escribir \"Puede pasar\";\n  Sino\n    Escribir \"No puede pasar\";\n  FinSi\nFinAlgoritmo\n",
    "en": "Algorithm Entrance\n  Define age As Integer <- 15;\n  Define hasTicket As Boolean <- False;\n  If age >= 13 And age <= 17 Then\n    Write \"Adolescente\";\n  EndIf\n  If age < 12 Or hasTicket Then\n    Write \"Puede pasar\";\n  Else\n    Write \"No puede pasar\";\n  EndIf\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Adolescente\nNo puede pasar\n",
    "terminacion": "completed"
  }
}
```
