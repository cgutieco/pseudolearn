---
{
  "formato": "see/1",
  "id": "LANG.SYNTAX.ANALYSIS-LIMITS",
  "titulo": "Límite portable de anidación del análisis",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "La profundidad de análisis se limita explícitamente sin agotar la pila del anfitrión.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.SYNTAX.GRAMMAR",
      "version": ">=0.2.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "DIAG.CATALOG",
      "version": ">=0.4.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "cambio": {
    "clase": "restriccion",
    "impacto_usuarios": "Hace explícito el límite de recursos del análisis; ninguna construcción nueva.",
    "impacto_implementaciones": "Contar construcciones anidadas antes de descender y emitir el diagnóstico propio sin cascadas.",
    "justificacion": "Garantizar rechazo total y portable antes de agotar la pila.",
    "revisado_por": "autorización de la fase R5; autoría automatizada"
  }
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
  "texto": "Se admiten hasta D1.nesting construcciones simultáneamente anidadas. Cada paréntesis de agrupación, operador unario, potencia cuyo operando derecho contiene otra potencia y sentencia compuesta abre un nivel; unidades y listas no añaden un nivel. El primer nivel que excede la cota produce analysisNestingLimitExceeded, clase syntax, severidad error en ambos rigores, argumento limit y tramo del símbolo o apertura que lo excede. Se conserva el árbol recuperable, no se agregan cierres derivados del rechazo y ninguna profundidad agota la pila del anfitrión. El valor es un recurso del análisis, independiente de ENG.LIMITS.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6",
    "C7",
    "C8"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
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
          "limit": "256"
        }
      }
    ]
  },
  "rigor": [
    "estricto",
    "flexible"
  ],
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
  "rigor": [
    "estricto",
    "flexible"
  ],
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
          "limit": "256"
        }
      }
    ]
  },
  "rigor": [
    "estricto",
    "flexible"
  ],
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
  "rigor": [
    "estricto",
    "flexible"
  ],
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
          "limit": "256"
        }
      }
    ]
  },
  "rigor": [
    "estricto",
    "flexible"
  ],
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
  "rigor": [
    "estricto",
    "flexible"
  ],
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
          "limit": "256"
        }
      }
    ]
  },
  "rigor": [
    "estricto",
    "flexible"
  ],
  "etiquetas": [
    "limite",
    "blocks"
  ]
}
```
