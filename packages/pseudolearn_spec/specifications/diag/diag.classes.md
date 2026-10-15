---
{
  "formato": "see/1",
  "id": "DIAG.CLASSES",
  "titulo": "Clases de diagnóstico",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Clases de diagnóstico.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "DIAG.MODEL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Clases de diagnóstico

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Errores léxicos, sintácticos, semánticos y de ejecución describen la restricción que falla. El análisis sintáctico recupera estructura, pero las fases semánticas no corren si hay errores léxicos o sintácticos; no se producen cascadas semánticas sobre un árbol inválido.",
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
    "es": "Algoritmo P\nDefinir Como Entero;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine as integer;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedIdentifierInDeclaration",
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
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir 1 + Verdadero;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1 + true;\nendAlgorithm\n"
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
    "es": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los símbolos cuya resolución o declaración es inválida no generan diagnósticos derivados de inicialización ni firma. Se conservan errores independientes; una declaración duplicada no altera la aridad declarada para producir un error adicional sobre una llamada originalmente compatible.",
  "verificacion": [
    "C4",
    "C5"
  ]
}
```

```caso
{
  "id": "C4",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto"
  ],
  "programas": {
    "es": "SubProceso f() Como Entero\nRetornar missing;\nFinSubProceso\nAlgoritmo P\nEscribir f();\nFinAlgoritmo\n",
    "en": "subroutine f() as integer\nreturn missing;\nendSubroutine\nalgorithm P\nwrite f();\nendAlgorithm\n"
  },
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "undeclaredVariable",
        "severidad": "error"
      }
    ]
  },
  "origen": "derivado"
}
```

```caso
{
  "id": "C5",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso f(x Como Entero, x Como Entero)\nEscribir x;\nFinSubProceso\nAlgoritmo P\nf(1, 2);\nFinAlgoritmo\n",
    "en": "subroutine f(x as integer, x as integer)\nwrite x;\nendSubroutine\nalgorithm P\nf(1, 2);\nendAlgorithm\n"
  },
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
  "origen": "derivado"
}
```
