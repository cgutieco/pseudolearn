---
{
  "formato": "see/1",
  "id": "LANG.IO.INPUT",
  "titulo": "Entrada",
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
  "resumen": "Entrada.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.DECL.DESIGNATOR",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Entrada

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Leer requiere uno o más designadores y solicita valores de uno en uno, en orden. La conversión depende del tipo esperado. Una entrada inválida emite readValueTypeMismatch como advertencia y vuelve a pedir la misma posición sin modificarla. Sin entrada disponible la ejecución espera; un índice inválido del destino falla antes de pedir valor.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4"
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
    "es": "Algoritmo P\nDefinir x Como Entero;\nLeer x;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer;\nread x;\nwrite x;\nendAlgorithm\n"
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
  ],
  "entradas": [
    "7"
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
    "es": "Algoritmo P\nDefinir x Como Entero;\nLeer x;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer;\nread x;\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\n",
    "terminacion": "completed",
    "diagnosticos": [
      {
        "codigo": "readValueTypeMismatch",
        "severidad": "warning"
      }
    ]
  },
  "rigor": [
    "estricto",
    "flexible"
  ],
  "entradas": [
    "oops",
    "7"
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
    "es": "Algoritmo P\nDefinir x Como Entero;\nLeer x;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer;\nread x;\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "terminacion": "awaiting_input",
    "salida": ""
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
    "es": "Algoritmo P\nLeer;\nFinAlgoritmo\n",
    "en": "algorithm P\nread;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedReadTarget",
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
