---
{
  "formato": "see/1",
  "id": "PERF.BASELINE.REFERENCE",
  "titulo": "Línea base del núcleo de referencia",
  "dominio": "rendimiento",
  "estado": "experimental",
  "version": "0.2.0",
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
  "titulo_en": "Reference baseline",
  "cambio": {
    "clase": "ampliacion",
    "impacto_usuarios": "Publica la línea base de los diez programas AWFY-core en ambos modos sin cambiar su comportamiento.",
    "impacto_implementaciones": "La puerta de rendimiento de la VM compara los mismos tamaños con esta serie nativa local, además de conservar E-01.",
    "justificacion": "La comparación por suite necesita una medición de reference para cada uno de los diez programas normativos.",
    "revisado_por": "autoría automatizada; no revisión humana independiente"
  }
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

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "La línea base de la suite AWFY-core conserva diez procesos independientes y treinta iteraciones por programa y modo, con los tamaños de medición normativos y salida validada. Los tiempos se miden en el mismo Apple M2 local que E-02, con ejecutable nativo de Dart. El conjunto results/macos-r3-awfy de pseudolearn_benchmarks publica captura previa a compilación, hashes de fuentes, muestras crudas, métricas de proceso y resumen recalculable; no se mezcla con E-01 ni con otros equipos.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "El arnés consume la exportación de PERF.SUITE.AWFY-CORE, valida la terminación y salida de los diez programas y conserva 6000 muestras en sus dos modos."
}
```

## Línea base AWFY-core (nativo, Apple M2)

Los programas se analizan con el perfil español flexible, antes del intervalo medido.
Los intervalos del 95 % se calculan sobre diez medias de proceso. El calentamiento y los candidatos
de cambio permanecen en las muestras; no se afirma estacionariedad. La memoria es el máximo
muestreado del proceso y la CPU su última lectura acumulada, sin atribución por programa.

| Programa | Sin observar, µs [IC 95 %] | Observado, µs [IC 95 %] |
|---|---|---|
| sieve | 11066.4 [10953.4, 11185.3] | 15090.7 [14929.2, 15259.7] |
| permute | 57075.8 [56311.6, 57891.8] | 168182.6 [166768.8, 169627.9] |
| queens | 11275.0 [11182.3, 11370.5] | 27722.0 [27441.4, 28002.9] |
| towers | 9752.1 [9614.5, 9931.0] | 46627.9 [45717.7, 47835.2] |
| list | 32396.2 [31710.9, 33104.0] | 143026.0 [139590.2, 147151.9] |
| storage | 9206.3 [9103.5, 9315.5] | 26237.9 [25955.7, 26573.5] |
| bounce | 41008.2 [40505.1, 41603.8] | 66637.2 [65373.1, 68020.5] |
| mandelbrot | 164687.1 [162219.5, 167312.0] | 272717.1 [268156.0, 277622.2] |
| nbody | 21293.7 [21060.7, 21568.3] | 30598.4 [30265.7, 31029.8] |
| richards | 170130.0 [168102.9, 172965.9] | 346444.2 [343200.2, 350629.1] |

La procedencia está en `pseudolearn_benchmarks/results/macos-r3-awfy/capture.json`; las muestras en
`raw.json`, las métricas de proceso en `processes.json` y el resumen recalculable en `summary.json` de ese conjunto.
