---
{
  "formato": "see/1",
  "id": "LIB.CORE.RANDOM",
  "titulo": "Fuente aleatoria explícita",
  "dominio": "biblioteca",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference"
  ],
  "resumen": "Fuente aleatoria explícita.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LIB.MODEL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Fuente aleatoria explícita

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "azar no recibe argumentos y produce real en [0,1). La fuente es inyectada con semilla explícita y una secuencia es reproducible para la misma fuente y semilla. El núcleo no consulta reloj ni azar global del anfitrión. El algoritmo de fuente y su compatibilidad pertenecen al contrato del runtime; no se deducen de una captura de reference.",
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
    "es": "Algoritmo P\nEscribir azar() >= 0.0 Y azar() < 1.0;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite random() >= 0.0 and random() < 1.0;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ],
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
    "es": "Algoritmo P\nEscribir azar() >= 0.0 Y azar() < 1.0;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite random() >= 0.0 and random() < 1.0;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ],
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
    "es": "Algoritmo P\nEscribir azar(1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite random(1);\nendAlgorithm\n"
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
