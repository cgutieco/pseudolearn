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
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Parámetros.",
  "edicion": {
    "introducida_en": "2026"
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
  "texto": "Cada parámetro tiene nombre, dimensiones opcionales mediante [] [,] y tipo opcional sintácticamente, exigido en estricto. La marca Por Valor o Por Referencia va después del tipo y solo alcanza ese parámetro. Sin marca se pasa por valor; arreglo se pasa por referencia y marcarlo Por Valor es error semántico. Cero parámetros es válido. Nombre duplicado o marcas repetidas se rechazan.",
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
    "es": "SubProceso f(value Como Entero) Como Entero\nRetornar value + 1;\nFinSubProceso\nAlgoritmo P\nEscribir f(2);\nFinAlgoritmo\n",
    "en": "subroutine f(value as integer) as integer\nreturn value + 1;\nendSubroutine\nalgorithm P\nwrite f(2);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n",
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
    "es": "SubProceso f()\nEscribir 1;\nFinSubProceso\nAlgoritmo P\nf(1);\nFinAlgoritmo\n",
    "en": "subroutine f()\nwrite 1;\nendSubroutine\nalgorithm P\nf(1);\nendAlgorithm\n"
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
    "es": "SubProceso f(x Como Entero, x Como Entero)\nEscribir x;\nFinSubProceso\nAlgoritmo P\nf(1, 2);\nFinAlgoritmo\n",
    "en": "subroutine f(x as integer, x as integer)\nwrite x;\nendSubroutine\nalgorithm P\nf(1, 2);\nendAlgorithm\n"
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```
