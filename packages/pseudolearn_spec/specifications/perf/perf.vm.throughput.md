---
{
  "formato": "see/1",
  "id": "PERF.VM.THROUGHPUT",
  "titulo": "Rendimiento de la VM sin observar",
  "dominio": "rendimiento",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-rendimiento"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Aceleración de la ejecución no observada frente a la línea base.",
  "depende_de": [
    {
      "id": "PERF.SUITE.AWFY-CORE",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "PERF.BASELINE.REFERENCE",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Unobserved VM throughput"
}
---

# Rendimiento de la VM sin observar

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La ejecución no observada de la suite AWFY-core es al menos diez veces más rápida que la línea base en media geométrica, ninguna prueba es menos de cinco veces más rápida y el objetivo es treinta veces.",
  "verificacion": [
    "M1",
    "M2",
    "M3"
  ]
}
```

```medicion
{
  "id": "M1",
  "metrica": "aceleracion_media_geometrica",
  "unidad": "veces",
  "suite": "PERF.SUITE.AWFY-CORE",
  "comparador": ">=",
  "umbral": 10,
  "provisional": true,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```

```medicion
{
  "id": "M2",
  "metrica": "aceleracion_minima_por_programa",
  "unidad": "veces",
  "suite": "PERF.SUITE.AWFY-CORE",
  "comparador": ">=",
  "umbral": 5,
  "provisional": true,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```

```medicion
{
  "id": "M3",
  "metrica": "aceleracion_objetivo_media_geometrica",
  "unidad": "veces",
  "suite": "PERF.SUITE.AWFY-CORE",
  "comparador": ">=",
  "umbral": 30,
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
  "texto": "Ejecutar con un observador conectado pero en pausa cuesta como máximo un 2 % más que ejecutar sin observador.",
  "verificacion": [
    "M4"
  ]
}
```

```medicion
{
  "id": "M4",
  "metrica": "sobrecoste_observador_en_pausa",
  "unidad": "porcentaje",
  "suite": "PERF.SUITE.AWFY-CORE",
  "comparador": "<=",
  "umbral": 2,
  "provisional": true,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```
