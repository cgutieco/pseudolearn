---
{
  "formato": "see/1",
  "id": "LANG.OPS.LOGICAL",
  "titulo": "Operadores lógicos",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "0.2.0",
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
      "version": ">=0.1.0, <1.0.0",
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
    "C2"
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
    "es": "Algoritmo P\nEscribir 1 Y Verdadero;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1 and true;\nendAlgorithm\n"
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
