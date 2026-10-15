---
{
  "formato": "see/1",
  "id": "PERF.VM.STEP-LATENCY",
  "titulo": "Latencia de paso observado",
  "dominio": "rendimiento",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-rendimiento"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Percentil 95 del tiempo de un paso observado.",
  "depende_de": [
    {
      "id": "PERF.PROTOCOL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Observed step latency"
}
---

# Latencia de paso observado

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El percentil 95 de la latencia de avanzar un paso observado, incluida la consulta del estado del paso, es como máximo 1 ms en el dispositivo más modesto soportado y 0,1 ms en Apple M2, que lo sustituye mientras no hay puente.",
  "verificacion": [
    "M1",
    "M2"
  ]
}
```

```medicion
{
  "id": "M1",
  "metrica": "latencia_paso_p95",
  "unidad": "ms",
  "suite": "PERF.SUITE.AWFY-CORE",
  "comparador": "<=",
  "umbral": 1,
  "provisional": true,
  "plataformas": [
    "dispositivo-modesto"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```

```medicion
{
  "id": "M2",
  "metrica": "latencia_paso_p95",
  "unidad": "ms",
  "suite": "PERF.SUITE.AWFY-CORE",
  "comparador": "<=",
  "umbral": 0.1,
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
  "clase": "semantica",
  "texto": "El percentil 95 de posicionarse en un evento elegido al azar de AWFY-core y consultar su estado es como máximo 50 ms en Apple M2. La posición consultada pertenece al horizonte retenido; la operación no altera la continuación presente.",
  "verificacion": [
    "M3"
  ]
}
```

```medicion
{
  "id": "M3",
  "metrica": "latencia_retroceso_consulta_p95",
  "unidad": "ms",
  "suite": "PERF.SUITE.AWFY-CORE",
  "comparador": "<=",
  "umbral": 50,
  "provisional": true,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```
