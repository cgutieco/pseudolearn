---
formato: see/1
id: LIB.CORE.BYTES
titulo: Secuencias binarias inmutables
dominio: biblioteca
estado: estable
version: "1.0.0"
duenos:
- responsable-lenguaje
sujetos:
- engine
- aot
resumen: Conversión UTF-8 y operaciones puras sobre bytes.
titulo_en: Immutable byte sequences
edicion:
  introducida_en: "2026"
depende_de:
- id: LIB.MODEL
  version: ">=1.0.0, <2.0.0"
  tipo: requiere
- id: LANG.TASK.ISOLATION
  version: ">=1.0.0, <2.0.0"
  tipo: usa
revisado_por:
- Cesar Antonio Gutierrez Contreras
---

# Secuencias binarias inmutables

```regla
{
  "id": "B1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Bytes es inmutable y transferible. BytesDesdeTexto codifica los puntos de código como UTF-8 sin BOM. Segmento y Unir devuelven secuencias nuevas. Segmento fuera de rango atrapa con bytesRangeOutOfBounds en el sitio de la llamada.",
  "verificacion": [
    "C2",
    "C3",
    "C4",
    "C5"
  ]
}
```

```regla
{
  "id": "B2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Bytes() y Segmento(0, 0) producen una secuencia vacía. La longitud de Bytes() es cero. Un segmento de inicio cero y cantidad igual a la longitud devuelve todos los octetos en el mismo orden.",
  "verificacion": [
    "C1",
    "C2"
  ]
}
```

```caso
{
  "id": "C1",
  "regla": "B2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir empty Como Bytes <- Bytes();\nDefinir zero Como Bytes <- empty.Segmento(0, 0);\nEscribir empty.Longitud(), \":\", zero.Longitud();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine empty as Bytes <- Bytes();\ndefine zero as Bytes <- empty.segment(0, 0);\nwrite empty.length(), \":\", zero.length();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0:0\n",
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
  "regla": "B2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir source Como Bytes <- BytesDesdeTexto(\"ab\");\nDefinir all Como Bytes <- source.Segmento(0, source.Longitud());\nEscribir all.Longitud(), \":\", all.En(0), \":\", all.En(1);\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine source as Bytes <- bytesFromText(\"ab\");\ndefine all as Bytes <- source.segment(0, source.length());\nwrite all.length(), \":\", all.at(0), \":\", all.at(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2:97:98\n",
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
  "regla": "B1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir source Como Bytes <- BytesDesdeTexto(\"a\");\nsource.Segmento(1, 1);\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine source as Bytes <- bytesFromText(\"a\");\nsource.segment(1, 1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "bytesRangeOutOfBounds"
    }
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
  "regla": "B1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir source Como Bytes <- BytesDesdeTexto(\"ab\");\nDefinir left Como Bytes <- Bytes();\nDefinir first Como Bytes <- left.Unir(source);\nDefinir second Como Bytes <- source.Unir(left);\nEscribir first.Longitud(), \":\", first.En(0), \":\", first.En(1);\nEscribir second.Longitud(), \":\", second.En(0), \":\", second.En(1);\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine source as Bytes <- bytesFromText(\"ab\");\ndefine left as Bytes <- Bytes();\ndefine first as Bytes <- left.join(source);\ndefine second as Bytes <- source.join(left);\nwrite first.length(), \":\", first.at(0), \":\", first.at(1);\nwrite second.length(), \":\", second.at(0), \":\", second.at(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2:97:98\n2:97:98\n",
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
  "id": "C5",
  "regla": "B1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir value Como Bytes <- BytesDesdeTexto(\"😀\");\nEscribir value.Longitud(), \":\", value.En(0), \":\", value.En(1), \":\", value.En(2), \":\", value.En(3);\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine value as Bytes <- bytesFromText(\"😀\");\nwrite value.length(), \":\", value.at(0), \":\", value.at(1), \":\", value.at(2), \":\", value.at(3);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "4:240:159:152:128\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```
