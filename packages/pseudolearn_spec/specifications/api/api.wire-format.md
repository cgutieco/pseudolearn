---
{
  "formato": "see/1",
  "id": "API.WIRE-FORMAT",
  "titulo": "Formato de intercambio",
  "dominio": "motor",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Un esquema con JSON canónico y lotes binarios columnares.",
  "depende_de": [
    {
      "id": "API.MODEL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.TRACE.EVENTS",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Wire format"
}
---

# Formato de intercambio

```definicion
{
  "id": "D1",
  "termino": "esquema de intercambio",
  "texto": "Claves ASCII en inglés y snake_case, independientes del idioma de interfaz. Diagnóstico: code, class, severity, span {start, end} con line y column, related y arguments. Resultado de análisis: tree y diagnostics. Resultado de ejecución: output, termination {kind, code, limit}, diagnostics y events. Evento: class, line y data. Las mismas formas son las respuestas de see-protocol/1."
}
```

```definicion
{
  "id": "D2",
  "termino": "lote binario de eventos",
  "texto": "Encabezado de 16 bytes: firma ASCII PLEV, versión u16 igual a 1, reservado u16 igual a 0 y número de eventos n como u64. Siguen cuatro columnas de n elementos en little endian: clase u8 (posición de la clase en el alfabeto de ENG.TRACE.EVENTS), línea u32, profundidad de marco u32 y desplazamiento u32 en el pool. El pool final es la concatenación UTF-8 de los datos de cada evento en JSON canónico, precedida por su longitud total u32."
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El JSON canónico es UTF-8, sin espacios entre símbolos, con las claves de cada objeto ordenadas por puntos de código y con los números enteros en decimal exacto.",
  "verificacion": [
    "C1"
  ]
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 1,
    "json": {
      "files": [
        {
          "path": "p.pseudo",
          "diagnostics": [
            {
              "code": "undeclaredVariable",
              "class": "semantic",
              "severity": "error",
              "span": {
                "start": {
                  "line": 2,
                  "column": 10
                },
                "end": {
                  "line": 2,
                  "column": 15
                }
              },
              "related": [],
              "arguments": {
                "lexeme": "total"
              }
            }
          ]
        }
      ]
    },
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "--json",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir total;\nFinAlgoritmo\n"
    }
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los lotes de eventos se codifican en el binario columnar de D2. Decodificar un lote binario produce los mismos eventos que su codificación JSON, y codificar y decodificar en cualquiera de las dos formas devuelve el valor original.",
  "verificacion": [
    "P1"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R2",
  "generador": {
    "lotes": "trazas de los casos trace del corpus partidas en lotes"
  },
  "propiedad": "decodificar(codificar(x)) = x en las dos codificaciones y las dos decodificaciones coinciden.",
  "oraculo": "Igualdad estructural de los eventos.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```
