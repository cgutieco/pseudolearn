---
{
  "formato": "see/1",
  "id": "LANG.SYNTAX.ANALYSIS-LIMITS",
  "titulo": "Límite portable de anidación del análisis",
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
    "app"
  ],
  "resumen": "La profundidad de análisis se limita explícitamente sin agotar la pila del anfitrión.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.SYNTAX.GRAMMAR",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "DIAG.CATALOG",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ]
}
---

# Límite portable de anidación del análisis

```definicion
{
  "id": "D1",
  "termino": "analysisLimits",
  "texto": "Límite portable común a todos los consumidores.",
  "valor": {
    "nesting": 256
  }
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "sintactica",
  "texto": "Se admiten hasta D1.nesting construcciones simultáneamente anidadas. Cada paréntesis de agrupación, lista de argumentos de una llamada, instanciación o lanzamiento, lista de índices, operador unario, potencia cuyo operando derecho contiene otra potencia y sentencia compuesta abre un nivel; cada eslabón de una cadena —operador binario encadenado, llamada, índice o acceso a miembro sucesivos, y tipo de retorno de un tipo función— abre además un nivel, de modo que la profundidad del árbol nunca supera la cota; las unidades y los elementos adicionales de una misma lista no añaden un nivel. El primer nivel que excede la cota produce analysisNestingLimitExceeded, clase syntax, severidad error, argumento limit numérico y tramo del símbolo o apertura que lo excede. Se conserva el árbol recuperable, no se agregan cierres derivados del rechazo y ninguna profundidad agota la pila del anfitrión. El valor es un recurso del análisis, independiente de ENG.LIMITS.",
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
    "C13",
    "C14",
    "C15",
    "C16"
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
    "es": "Algoritmo P\nEscribir ((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite ((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "etiquetas": [
    "limite",
    "parentheses"
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
    "es": "Algoritmo P\nEscribir (((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((1)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite (((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((1)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "analysisNestingLimitExceeded",
        "clase": "syntax",
        "severidad": "error",
        "argumentos": {
          "limit": 256
        }
      }
    ]
  },
  "etiquetas": [
    "limite",
    "parentheses"
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
    "es": "Algoritmo P\nEscribir - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 1;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "etiquetas": [
    "limite",
    "unary"
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
    "es": "Algoritmo P\nEscribir - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 1;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "analysisNestingLimitExceeded",
        "clase": "syntax",
        "severidad": "error",
        "argumentos": {
          "limit": 256
        }
      }
    ]
  },
  "etiquetas": [
    "limite",
    "unary"
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
    "es": "Algoritmo P\nEscribir 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "etiquetas": [
    "limite",
    "power"
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
    "es": "Algoritmo P\nEscribir 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1 ^ 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "analysisNestingLimitExceeded",
        "clase": "syntax",
        "severidad": "error",
        "argumentos": {
          "limit": 256
        }
      }
    ]
  },
  "etiquetas": [
    "limite",
    "power"
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
    "es": "Algoritmo P\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinAlgoritmo\n",
    "en": "algorithm P\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "etiquetas": [
    "limite",
    "blocks"
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
    "es": "Algoritmo P\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nSi Verdadero Entonces\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinSi\nFinAlgoritmo\n",
    "en": "algorithm P\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nif true then\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendIf\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "analysisNestingLimitExceeded",
        "clase": "syntax",
        "severidad": "error",
        "argumentos": {
          "limit": 256
        }
      }
    ]
  },
  "etiquetas": [
    "limite",
    "blocks"
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
    "es": "SubProceso F(x Como Entero) Como Entero\nRetornar x;\nFinSubProceso\nAlgoritmo P\nEscribir F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));\nFinAlgoritmo\n",
    "en": "function F(x as integer) as integer\nreturn x;\nend function\nalgorithm P\nwrite F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "etiquetas": [
    "limite",
    "calls"
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
    "es": "SubProceso F(x Como Entero) Como Entero\nRetornar x;\nFinSubProceso\nAlgoritmo P\nEscribir F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(1)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));\nFinAlgoritmo\n",
    "en": "function F(x as integer) as integer\nreturn x;\nend function\nalgorithm P\nwrite F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(F(1)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "analysisNestingLimitExceeded",
        "clase": "syntax",
        "severidad": "error",
        "argumentos": {
          "limit": 256
        }
      }
    ]
  },
  "etiquetas": [
    "limite",
    "calls"
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
    "es": "Algoritmo P\nDimension a[1] Como Entero;\na[0] <- 0;\nEscribir a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[0]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]];\nFinAlgoritmo\n",
    "en": "algorithm P\ndimension a[1] as integer;\na[0] <- 0;\nwrite a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[0]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]];\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "etiquetas": [
    "limite",
    "indices"
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
    "es": "Algoritmo P\nDimension a[1] Como Entero;\na[0] <- 0;\nEscribir a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[0]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]];\nFinAlgoritmo\n",
    "en": "algorithm P\ndimension a[1] as integer;\na[0] <- 0;\nwrite a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[a[0]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]];\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "analysisNestingLimitExceeded",
        "clase": "syntax",
        "severidad": "error",
        "argumentos": {
          "limit": 256
        }
      }
    ]
  },
  "etiquetas": [
    "limite",
    "indices"
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
    "es": "Algoritmo P\nEscribir 1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "etiquetas": [
    "limite",
    "cadenas"
  ]
}
```

```caso
{
  "id": "C14",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir 1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "analysisNestingLimitExceeded",
        "clase": "syntax",
        "severidad": "error",
        "argumentos": {
          "limit": 256
        }
      }
    ]
  },
  "etiquetas": [
    "limite",
    "cadenas"
  ]
}
```

```caso
{
  "id": "C15",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir a.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite a.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "etiquetas": [
    "limite",
    "cadenas"
  ]
}
```

```caso
{
  "id": "C16",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir a.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite a.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "analysisNestingLimitExceeded",
        "clase": "syntax",
        "severidad": "error",
        "argumentos": {
          "limit": 256
        }
      }
    ]
  },
  "etiquetas": [
    "limite",
    "cadenas"
  ]
}
```
