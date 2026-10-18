---
{
  "formato": "see/1",
  "id": "LANG.SUBPROGRAM.SCOPE",
  "titulo": "Ámbitos y nombres",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Ámbitos y nombres.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.SUBPROGRAM.DECLARATION",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Ámbitos y nombres

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada algoritmo, subprograma y método tiene su ámbito de variables; no hay globales ni ámbitos de bloque. Parámetros son locales. Cabeceras de clases y subprogramas se recogen antes de cuerpos; se permite llamar unidades posteriores y recursión mutua. Un subprograma y variable homónimos en un ámbito se rechazan. Una declaración de subprograma con nombre de función incorporada la oculta en todo el texto.",
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
    "es": "SubProceso f(value Como Entero) Como Entero\nRetornar value + 1;\nFinSubProceso\nAlgoritmo P\nEscribir f(4);\nFinAlgoritmo\n",
    "en": "subroutine f(value as integer) as integer\nreturn value + 1;\nendSubroutine\nalgorithm P\nwrite f(4);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5\n",
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
    "es": "SubProceso f() Como Entero\nRetornar missing;\nFinSubProceso\nAlgoritmo P\nEscribir f();\nFinAlgoritmo\n",
    "en": "subroutine f() as integer\nreturn missing;\nendSubroutine\nalgorithm P\nwrite f();\nendAlgorithm\n"
  },
  "origen": "derivado",
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
  "rigor": [
    "estricto"
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
    "es": "SubProceso f() Como Entero\nRetornar g();\nFinSubProceso\nSubProceso g() Como Entero\nRetornar 7;\nFinSubProceso\nAlgoritmo P\nEscribir f();\nFinAlgoritmo\n",
    "en": "subroutine f() as integer\nreturn g();\nendSubroutine\nsubroutine g() as integer\nreturn 7;\nendSubroutine\nalgorithm P\nwrite f();\nendAlgorithm\n"
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
