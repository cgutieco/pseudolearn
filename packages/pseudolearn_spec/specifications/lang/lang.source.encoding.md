---
{
  "formato": "see/1",
  "id": "LANG.SOURCE.ENCODING",
  "titulo": "Codificación y normalización del texto fuente",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Codificación y normalización del texto fuente.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [],
  "cambio": {
    "clase": "ampliacion",
    "impacto_usuarios": "Sin cambios en el lenguaje ni en el código admitido.",
    "impacto_implementaciones": "Activa el sujeto engine en R4 manteniendo reference.",
    "justificacion": "Habilitar la verificación de conformidad estática del nuevo motor en Rust.",
    "revisado_por": "autoría automatizada; no revisión humana independiente"
  }
}
---

# Codificación y normalización del texto fuente

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El texto fuente es UTF-8 válido; se admite un BOM inicial que no es un token. LF, CRLF y CR separan líneas. Una secuencia inválida se informa como fallo de entrada, sin decodificación con pérdida.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El reconocimiento de lexemas y la identidad de nombres usan NFC. Los nombres son sensibles a mayúsculas y acentos después de NFC. La normalización no altera literales, comentarios, fuente original ni posiciones.",
  "verificacion": [
    "C5",
    "C6"
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
    "es": "Algoritmo P\n\nFinAlgoritmo\n",
    "en": "algorithm P\n\nendAlgorithm\n"
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
    "es": "﻿Algoritmo P\n\nFinAlgoritmo\n",
    "en": "﻿algorithm P\n\nendAlgorithm\n"
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
    "es": "Algoritmo P\r\n\r\nFinAlgoritmo\r\n",
    "en": "algorithm P\r\n\r\nendAlgorithm\r\n"
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
    "es": "Algoritmo P\r\rFinAlgoritmo\r",
    "en": "algorithm P\r\rendAlgorithm\r"
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
  "programas": {
    "es": "Algoritmo P\nDefinir año Como Entero;\naño <- 2;\nEscribir año;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine año as integer;\naño <- 2;\nwrite año;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
    "terminacion": "completed"
  },
  "rigor": [
    "flexible"
  ]
}
```

```caso
{
  "id": "C6",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir \"ã\", \"ñ\";\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite \"ã\", \"ñ\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ãñ\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```
