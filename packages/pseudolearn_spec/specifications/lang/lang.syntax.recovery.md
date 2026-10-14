---
{
  "formato": "see/1",
  "id": "LANG.SYNTAX.RECOVERY",
  "titulo": "Recuperación sintáctica",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference"
  ],
  "resumen": "Recuperación sintáctica.",
  "depende_de": [],
  "edicion": {
    "introducida_en": "2026"
  }
}
---

# Recuperación sintáctica

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una sentencia malformada produce como máximo un diagnóstico sintáctico principal; no se duplica al sincronizar.",
  "verificacion": [
    "C1",
    "C2"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El análisis devuelve un árbol también para el texto vacío o inválido.",
  "verificacion": [
    "C3",
    "C4",
    "C5"
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
  "rigor": [
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\n  Escribir 1 +\nFinAlgoritmo\n",
    "en": "algorithm P\n  write 1 +\nendAlgorithm\n"
  },
  "operacion": "analyze",
  "espera": {
    "diagnosticos": [
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      }
    ]
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\n  Escribir 1;\nFinAlgoritmo\n",
    "en": "algorithm P\n  write 1;\nendAlgorithm\n"
  },
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ]
}
```

```caso
{
  "id": "C3",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programa": "",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedAlgorithmStart",
        "severidad": "error"
      }
    ]
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
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
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nFinAlgoritmo\n",
    "en": "algorithm P\nendAlgorithm\n"
  },
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ]
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
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\n Escribir 1 +\nFinAlgoritmo\n",
    "en": "algorithm P\n write 1 +\nendAlgorithm\n"
  },
  "operacion": "analyze",
  "espera": {
    "arbol": "presente"
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ]
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones ni cambia el sujeto congelado.
