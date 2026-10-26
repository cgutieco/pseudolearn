---
{
  "formato": "see/1",
  "id": "PERF.ARTIFACT.SIZE",
  "titulo": "Tamaño de los artefactos",
  "dominio": "rendimiento",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-rendimiento"
  ],
  "sujetos": [
    "engine",
    "app"
  ],
  "resumen": "Presupuesto de tamaño de la biblioteca móvil y del Wasm.",
  "depende_de": [
    {
      "id": "PERF.PROTOCOL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Artifact size",
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ]
}
---

# Tamaño de los artefactos

```definicion
{
  "id": "D1",
  "termino": "unidades y artefacto medido",
  "texto": "KiB equivale a 1024 bytes y MiB a 1048576 bytes. La biblioteca nativa se mide por ABI tras enlace de release y eliminación de símbolos de depuración, antes de empaquetar Flutter; incluye pseudolearn_bridge y pseudolearn_api, y excluye Flutter, recursos de la app y datos de depuración. El módulo Wasm se mide tras optimización y se comprime en modo genérico Brotli con quality 11 y lgwin 22; se cuentan todos los bytes del flujo comprimido. No se incluyen el pegamento JavaScript, HTML, el consumidor mínimo ni sus fixtures. La medición nativa cubre ios-arm64."
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La biblioteca Rust del puente ocupa como máximo 5 MiB en ios-arm64 y el módulo Wasm como máximo 900 KiB según D1.",
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
  "umbral": 5,
  "provisional": false,
  "sujetos": ["app"],
  "plataformas": [
    "ios-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R2"
}
```

```medicion
{
  "id": "M2",
  "metrica": "tamano_wasm_brotli",
  "unidad": "KiB",
  "suite": "artefactos de release",
  "comparador": "<=",
  "umbral": 900,
  "provisional": false,
  "sujetos": ["engine"],
  "plataformas": [
    "wasm32"
  ],
  "protocolo": "PERF.PROTOCOL#R2"
}
```
