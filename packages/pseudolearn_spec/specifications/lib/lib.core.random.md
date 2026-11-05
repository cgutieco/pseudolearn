---
{
  "formato": "see/1",
  "id": "LIB.CORE.RANDOM",
  "titulo": "Fuente aleatoria explícita",
  "dominio": "biblioteca",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Fuente aleatoria explícita.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LIB.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Fuente aleatoria explícita

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Azar(n) recibe un entero n y produce un entero uniforme en [0, n); un límite n menor o igual que cero termina con el fallo invalidRandomBound. Aleatorio(a, b) recibe dos enteros y produce un entero uniforme en [a, b], ambos incluidos; un inicio mayor que el final termina con invalidRandomRange. AzarReal() no recibe argumentos y produce un real en [0,1). Las tres leen la misma fuente, inyectada con semilla explícita: una secuencia es reproducible para la misma fuente y semilla. La reducción de una palabra de la fuente a un intervalo descarta las palabras del resto final del rango y reduce las demás por módulo, de modo que ningún entero tiene más probabilidad que otro. El núcleo no consulta reloj ni azar global del anfitrión. El algoritmo de fuente y su compatibilidad pertenecen al contrato del runtime; no se deducen de una captura de reference. La cantidad y el tipo de los argumentos se comprueban estáticamente.",
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
    "C12"
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
    "es": "Algoritmo P\nEscribir AzarReal() >= 0.0 Y AzarReal() < 1.0;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite randomReal() >= 0.0 and randomReal() < 1.0;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}\n",
    "terminacion": "completed"
  },
  "semilla": 42
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
    "es": "Algoritmo P\nEscribir AzarReal() >= 0.0 Y AzarReal() < 1.0;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite randomReal() >= 0.0 and randomReal() < 1.0;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}\n",
    "terminacion": "completed"
  },
  "semilla": 0
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
    "es": "Algoritmo P\nEscribir Azar();\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite random();\nendAlgorithm\n"
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
    "es": "Algoritmo P\nEscribir Azar(1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite random(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0\n",
    "terminacion": "completed"
  },
  "semilla": 3
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
    "es": "Algoritmo P\nEscribir Azar(0);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite random(0);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "invalidRandomBound"
    }
  },
  "semilla": 3
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
    "es": "Algoritmo P\nEscribir Azar(-1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite random(-1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "invalidRandomBound"
    }
  },
  "semilla": 3
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
    "es": "Algoritmo P\nEscribir Aleatorio(5, 5);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite randomBetween(5, 5);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5\n",
    "terminacion": "completed"
  },
  "semilla": 3
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
    "es": "Algoritmo P\nEscribir Aleatorio(3, 1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite randomBetween(3, 1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "invalidRandomRange"
    }
  },
  "semilla": 3
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
    "es": "Algoritmo P\nDefinir dentro Como Logico <- Verdadero;\nDefinir v, w Como Entero;\nPara i <- 1 Hasta 200 Hacer\nv <- Azar(6);\nw <- Aleatorio(-2, 2);\nSi v < 0 O v >= 6 Entonces\ndentro <- Falso;\nFinSi\nSi w < -2 O w > 2 Entonces\ndentro <- Falso;\nFinSi\nFinPara\nEscribir dentro;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine inside as boolean <- true;\ndefine v, w as integer;\nfor i <- 1 to 200 do\nv <- random(6);\nw <- randomBetween(-2, 2);\nif v < 0 or v >= 6 then\ninside <- false;\nendIf\nif w < -2 or w > 2 then\ninside <- false;\nendIf\nendFor\nwrite inside;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}\n",
    "terminacion": "completed"
  },
  "semilla": 7
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
    "es": "Algoritmo P\nEscribir Aleatorio(1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite randomBetween(1);\nendAlgorithm\n"
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
  }
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
    "es": "Algoritmo P\nEscribir AzarReal(1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite randomReal(1);\nendAlgorithm\n"
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
  }
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
    "es": "Algoritmo P\nEscribir Azar(1.5);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite random(1.5);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleArgumentType",
        "severidad": "error"
      }
    ]
  }
}
```
