---
{
  "formato": "see/1",
  "id": "PERF.BASELINE.REFERENCE",
  "titulo": "Línea base del núcleo de referencia",
  "dominio": "rendimiento",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-rendimiento"
  ],
  "sujetos": [
    "reference"
  ],
  "resumen": "Mediciones publicadas del sujeto reference contra las que se comparan los motores.",
  "depende_de": [
    {
      "id": "PERF.PROTOCOL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "PERF.SUITE.AWFY-CORE",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Reference baseline"
}
---

# Línea base del núcleo de referencia

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La línea base E-01 de reference es la medición local en Apple M2 con el ejecutable nativo de Dart, diez procesos por objetivo y treinta iteraciones por carga y modo, conservada en pseudolearn_benchmarks/results/macos-local con su procedencia. Las mediciones remotas de macOS, Linux y Windows de results/ci-r0-complete son complementarias y no se comparan con mediciones locales.",
  "verificacion": [
    "M1",
    "M2",
    "M3",
    "M4",
    "M5",
    "M6"
  ]
}
```

```medicion
{
  "id": "M1",
  "metrica": "ns_por_micro_paso_sum",
  "unidad": "ns",
  "suite": "E-01 sum",
  "comparador": "<=",
  "umbral": 90.3,
  "provisional": false,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R6"
}
```

```medicion
{
  "id": "M2",
  "metrica": "ns_por_micro_paso_fibonacci",
  "unidad": "ns",
  "suite": "E-01 fibonacci",
  "comparador": "<=",
  "umbral": 86.6,
  "provisional": false,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R6"
}
```

```medicion
{
  "id": "M3",
  "metrica": "ns_por_micro_paso_bubble",
  "unidad": "ns",
  "suite": "E-01 bubble",
  "comparador": "<=",
  "umbral": 92.6,
  "provisional": false,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R6"
}
```

```medicion
{
  "id": "M4",
  "metrica": "ns_por_micro_paso_objects",
  "unidad": "ns",
  "suite": "E-01 objects",
  "comparador": "<=",
  "umbral": 110.3,
  "provisional": false,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R6"
}
```

```medicion
{
  "id": "M5",
  "metrica": "ns_por_micro_paso_sieve",
  "unidad": "ns",
  "suite": "E-01 sieve",
  "comparador": "<=",
  "umbral": 87.0,
  "provisional": false,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R6"
}
```

```medicion
{
  "id": "M6",
  "metrica": "ns_por_micro_paso_permute",
  "unidad": "ns",
  "suite": "E-01 permute",
  "comparador": "<=",
  "umbral": 93.0,
  "provisional": false,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R6"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "Las limitaciones de la línea base forman parte de ella: el reloj de JavaScript se observa en múltiplos de 1 ms y una duración inferior se conserva como dato menor que esa resolución; varios grupos tienen candidatos de punto de cambio y no se declara estacionariedad; los runners compartidos no controlan frecuencia ni carga.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Los resúmenes de E-01 conservan la resolución observada, los candidatos de cambio y las limitaciones del entorno."
}
```

## Línea base E-01 (nativo, Apple M2)

| Carga | Sin observar, µs [IC 95 %] | ns por micro-paso | Observada, µs [IC 95 %] | Estacionariedad |
|---|---|---|---|---|
| sum | 905.0 [877.9, 943.4] | 90.3 | 1121.1 [1087.4, 1168.8] | change_points_detected |
| fibonacci | 665.0 [660.4, 671.1] | 86.6 | 1844.0 [1833.2, 1857.6] | not_proven |
| bubble | 1879.6 [1862.7, 1899.9] | 92.6 | 2265.5 [2245.0, 2291.6] | not_proven |
| objects | 224.8 [221.1, 229.6] | 110.3 | 265.7 [259.4, 274.0] | change_points_detected |
| sieve | 29029.2 [28761.0, 29464.7] | 87.0 | 37483.1 [37041.8, 38074.7] | not_proven |
| permute | 57930.1 [57583.4, 58325.7] | 93.0 | 170053.4 [168861.6, 171634.8] | not_proven |
