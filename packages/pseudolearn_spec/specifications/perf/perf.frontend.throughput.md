---
{
  "formato": "see/1",
  "id": "PERF.FRONTEND.THROUGHPUT",
  "titulo": "Rendimiento del análisis",
  "dominio": "rendimiento",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-rendimiento"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Líneas por segundo y memoria del análisis completo.",
  "depende_de": [
    {
      "id": "PERF.PROTOCOL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Front-end throughput"
}
---

# Rendimiento del análisis

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El análisis completo (léxico, sintáctico y semántico) procesa al menos un millón de líneas por segundo en Apple M2 sobre el corpus concatenado y archivos generados de 10 000 líneas.",
  "verificacion": [
    "M1"
  ]
}
```

```medicion
{
  "id": "M1",
  "metrica": "lineas_por_segundo",
  "unidad": "líneas/s",
  "suite": "corpus y archivos generados de 10 000 líneas",
  "comparador": ">=",
  "umbral": 1000000,
  "provisional": true,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "Cada medición de rendimiento del análisis informa también la memoria máxima del proceso según PERF.PROTOCOL.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "El arnés del front-end registra la memoria máxima muestreada junto a cada muestra."
}
```
