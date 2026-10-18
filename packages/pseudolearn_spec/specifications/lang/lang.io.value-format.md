---
{
  "formato": "see/1",
  "id": "LANG.IO.VALUE-FORMAT",
  "titulo": "Formato de valores",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.3.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Formato de valores.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.RELATIONS",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Formato de valores

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Enteros se imprimen en decimal exacto sin agrupación. Reales finitos usan notación posicional, sin exponente y con al menos un decimal. Lógicos usan lexema canónico activo. Carácter y cadena se emiten sin comillas. ATexto devuelve exactamente la misma representación. Objetos y arreglos no tienen conversión implícita. Para un real se elige la secuencia decimal de menor cantidad de cifras significativas que, leída con redondeo al más cercano y empates al par, identifica el mismo binario64; entre secuencias mínimas se elige la más cercana al valor y, en empate, la de última cifra par. Se desarrolla en notación posicional y se añade .0 si no hay fracción. El cero negativo se conserva como -0.0.",
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
    "es": "Algoritmo P\nEscribir -12, \":\", 2.0, \":\", Verdadero, \":\", \"a\", \":\", \"ab\";\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite -12, \":\", 2.0, \":\", true, \":\", \"a\", \":\", \"ab\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "-12:2.0:{{lexema:booleanTrue}}:a:ab\n",
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
    "es": "Algoritmo P\nEscribir ATexto(2.0);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite toText(2.0);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2.0\n",
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
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDimension a[0] Como Entero;\nEscribir a;\nFinAlgoritmo\n",
    "en": "algorithm P\ndimension a[0] as integer;\nwrite a;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "arrayCannotBeUsedAsValue",
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
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "programas": {
    "es": "Algoritmo P\nEscribir 0.1 + 0.2, \":\", 1.0 / 10000000.0, \":\", -0.0;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 0.1 + 0.2, \":\", 1.0 / 10000000.0, \":\", -0.0;\nendAlgorithm\n"
  },
  "espera": {
    "salida": "0.30000000000000004:0.0000001:-0.0\n",
    "terminacion": "completed"
  },
  "id": "C4"
}
```
