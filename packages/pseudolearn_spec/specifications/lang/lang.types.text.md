---
{
  "formato": "see/1",
  "id": "LANG.TYPES.TEXT",
  "titulo": "Tipo cadena",
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
  "resumen": "Tipo cadena.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.LEXICAL.TEXT-LITERAL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Tipo cadena

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una cadena es una secuencia de puntos de código, distinta de carácter y arreglo. Su longitud no tiene cota semántica fija; puede ser vacía. Las posiciones son cero basadas. Su contenido no se normaliza y los grafemas compuestos cuentan por puntos de código.",
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
    "es": "Algoritmo P\nEscribir Longitud(\"\"), \":\", Longitud(\"año😀\"), \":\", Longitud(\"é\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite length(\"\"), \":\", length(\"año😀\"), \":\", length(\"é\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0:4:2\n",
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
    "es": "Algoritmo P\nEscribir CaracterEn(\"\", 0);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite charAt(\"\", 0);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "stringPositionOutOfRange"
    }
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```
