---
{
  "formato": "see/1",
  "id": "LANG.LEXICAL.WHITESPACE",
  "titulo": "Separación léxica",
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
  "resumen": "Separación léxica.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.SOURCE.ENCODING",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Separación léxica

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Espacio y tabulación separan tokens; indentación no tiene significado. El salto de línea termina sentencias simples cuando el rigor admite omitir el terminador. Un lexema multipalabra no cruza un salto de línea.",
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
    "es": "Algoritmo P\n\t Escribir\t1;\nFinAlgoritmo\n",
    "en": "algorithm P\n\t write\t1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
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
    "es": "Algoritmo P\nEscribir 1\nEscribir 2\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1\nwrite 2\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n2\n",
    "terminacion": "completed"
  },
  "rigor": [
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
    "es": "Algoritmo P\nEscribir 1 Sin\nSaltar;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1 Sin\nSaltar;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "analysisFailed"
    }
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```
