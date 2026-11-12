---
{
  "formato": "see/1",
  "id": "PERF.TEST.THROUGHPUT",
  "titulo": "Fixture",
  "dominio": "rendimiento",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Violación deliberada.",
  "depende_de": []
}
---

# Fixture

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Regla de fixture.",
  "verificacion": [
    "M1"
  ]
}
```

```medicion
{
  "id": "M1",
  "metrica": "throughput",
  "unidad": "operaciones/s",
  "suite": "PERF.SUITE.CORE",
  "comparador": ">=",
  "umbral": 1,
  "provisional": true,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R9"
}
```
