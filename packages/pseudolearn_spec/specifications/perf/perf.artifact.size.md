---
{
  "formato": "see/1",
  "id": "PERF.ARTIFACT.SIZE",
  "titulo": "Tamaño de los artefactos",
  "dominio": "rendimiento",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-rendimiento"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Presupuesto de tamaño de la biblioteca móvil y del Wasm.",
  "depende_de": [
    {
      "id": "PERF.PROTOCOL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Artifact size"
}
---

# Tamaño de los artefactos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La biblioteca móvil del núcleo ocupa como máximo 3 MiB por ABI y el módulo Wasm como máximo 600 KiB comprimido con brotli.",
  "verificacion": [
    "M1",
    "M2"
  ]
}
```

```medicion
{
  "id": "M1",
  "metrica": "tamano_biblioteca_movil",
  "unidad": "MiB",
  "suite": "artefactos de release",
  "comparador": "<=",
  "umbral": 3,
  "provisional": true,
  "plataformas": [
    "ios-arm64",
    "android-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```

```medicion
{
  "id": "M2",
  "metrica": "tamano_wasm_brotli",
  "unidad": "KiB",
  "suite": "artefactos de release",
  "comparador": "<=",
  "umbral": 600,
  "provisional": true,
  "plataformas": [
    "wasm32"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```
