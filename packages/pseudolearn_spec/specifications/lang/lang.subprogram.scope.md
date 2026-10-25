---
{
  "formato": "see/1",
  "id": "LANG.SUBPROGRAM.SCOPE",
  "titulo": "Ámbitos y nombres",
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
  "resumen": "Ámbitos y nombres.",
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

# Ámbitos y nombres

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada algoritmo, subprograma y método tiene ámbito propio, sin variables globales. Cada rama de Si y Segun y cada cuerpo de Mientras, Para y Repetir introduce un ámbito léxico. Los vínculos son visibles desde su declaración hasta el cierre; el inicializador no puede leer el vínculo que declara. Repetir conserva el ámbito durante Hasta Que. Los bloques hermanos pueden repetir nombres. Duplicar un nombre en el mismo ámbito es error; ocultar un vínculo exterior es legal con bindingShadowsOuter como advertencia y origen relacionado. Usar un vínculo cuyo ámbito terminó produce bindingOutsideScope con origen relacionado; un nombre desconocido produce undeclaredVariable. Parámetros son locales. Las cabeceras de clases y subprogramas se registran antes de sus cuerpos; se permiten llamadas posteriores y recursión mutua. Un subprograma y variable homónimos en un ámbito se rechazan. Una declaración de subprograma con nombre de función incorporada la oculta en todo el texto. Una clausura conserva los valores inmutables capturados después del cierre del ámbito, nunca el marco.",
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
    "C12",
    "C13"
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

```caso
{
  "id": "C4",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nSi Verdadero Entonces\nDefinir value Como Entero <- 1;\nEscribir value;\nFinSi\nEscribir value;\nFinAlgoritmo\n",
    "en": "algorithm P\nif true then\ndefine value as integer <- 1;\nwrite value;\nendIf\nwrite value;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "bindingOutsideScope",
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
  "id": "C5",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nSi Verdadero Entonces\nDefinir value Como Entero <- 1;\nEscribir value;\nSi Verdadero Entonces\nDefinir next Como Entero <- value + 1;\nSi Verdadero Entonces\nEscribir next;\nFinSi\nFinSi\nFinSi\nSi Verdadero Entonces\nDefinir value Como Entero <- 3;\nEscribir value;\nFinSi\nFinAlgoritmo\n",
    "en": "algorithm P\nif true then\ndefine value as integer <- 1;\nwrite value;\nif true then\ndefine next as integer <- value + 1;\nif true then\nwrite next;\nendIf\nendIf\nendIf\nif true then\ndefine value as integer <- 3;\nwrite value;\nendIf\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n2\n3\n",
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
  "id": "C6",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nSi Verdadero Entonces\nFinSi\nFinAlgoritmo\n",
    "en": "algorithm P\nif true then\nendIf\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
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
  "id": "C7",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nRepetir\nDefinir ready Como Logico <- Verdadero;\nHasta Que ready\nFinAlgoritmo\n",
    "en": "algorithm P\nrepeat\ndefine ready as boolean <- true;\nuntil ready\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
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
  "id": "C8",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nPara index <- 1 Hasta 1 Con Paso 1 Hacer\nEscribir index;\nFinPara\nEscribir index;\nFinAlgoritmo\n",
    "en": "algorithm P\nfor index <- 1 to 1 step 1 do\nwrite index;\nendFor\nwrite index;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "bindingOutsideScope",
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
  "id": "C9",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso display(value Como Entero)\nSi Verdadero Entonces\nDefinir value Como Entero <- 2;\nEscribir value;\nFinSi\nEscribir value;\nFinSubProceso\nAlgoritmo P\ndisplay(1);\nFinAlgoritmo\n",
    "en": "subroutine display(value as integer)\nif true then\ndefine value as integer <- 2;\nwrite value;\nendIf\nwrite value;\nendSubroutine\nalgorithm P\ndisplay(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n1\n",
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
  "id": "C10",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir value Como Entero <- 1;\nSi Verdadero Entonces\nDefinir value Como Entero <- 2;\nEscribir value;\nFinSi\nEscribir value;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine value as integer <- 1;\nif true then\ndefine value as integer <- 2;\nwrite value;\nendIf\nwrite value;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "bindingShadowsOuter",
        "severidad": "advertencia"
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
  "id": "C11",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir value Como Entero <- 1;\nDefinir value Como Entero <- 2;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine value as integer <- 1;\ndefine value as integer <- 2;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "duplicateVariableDeclaration",
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
  "id": "C12",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nSi Verdadero Entonces\nConstante value Como Entero <- 10;\nEscribir value;\nFinSi\nSi Verdadero Entonces\nConstante value Como Entero <- 20;\nEscribir value;\nFinSi\nFinAlgoritmo\n",
    "en": "algorithm P\nif true then\nconstant value as integer <- 10;\nwrite value;\nendIf\nif true then\nconstant value as integer <- 20;\nwrite value;\nendIf\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "10\n20\n",
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
  "id": "C13",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir value;\nDefinir value Como Entero <- 1;\nEscribir value;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite value;\ndefine value as integer <- 1;\nwrite value;\nendAlgorithm\n"
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
    "estricto",
    "flexible"
  ]
}
```
