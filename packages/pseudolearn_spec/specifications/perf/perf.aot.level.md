---
{
  "formato": "see/1",
  "id": "PERF.AOT.LEVEL",
  "titulo": "Nivel del código nativo",
  "dominio": "rendimiento",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-rendimiento"
  ],
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "aot"
  ],
  "resumen": "Razón por familia frente al techo nativo, aceleración sobre la VM y tiempo de emisión.",
  "depende_de": [
    {
      "id": "PERF.PROTOCOL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "PERF.SUITE.CORE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Native code level"
}
---

# Nivel del código nativo

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La media geométrica de cocientes de tiempos medianos por carga es como máximo 1,70 frente a V1F para el nivel Cranelift, en cada familia numérica, recursiva, de objetos y de arreglos. El intervalo nativo incluye ejecución y conciliación final; se conserva el tiempo de entrada por separado y se identifica la versión metodológica sin reinterpretar campañas históricas.",
  "verificacion": [
    "M1",
    "M2",
    "M3",
    "M4"
  ]
}
```

```medicion
{
  "id": "M1",
  "metrica": "razon_aot_techo_numeric",
  "unidad": "razon",
  "suite": "PERF.SUITE.CORE",
  "comparador": "<=",
  "umbral": 1.7,
  "provisional": false,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```

```medicion
{
  "id": "M2",
  "metrica": "razon_aot_techo_recursive",
  "unidad": "razon",
  "suite": "PERF.SUITE.CORE",
  "comparador": "<=",
  "umbral": 1.7,
  "provisional": false,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```

```medicion
{
  "id": "M3",
  "metrica": "razon_aot_techo_objects",
  "unidad": "razon",
  "suite": "PERF.SUITE.CORE",
  "comparador": "<=",
  "umbral": 1.7,
  "provisional": false,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```

```medicion
{
  "id": "M4",
  "metrica": "razon_aot_techo_arrays",
  "unidad": "razon",
  "suite": "PERF.SUITE.CORE",
  "comparador": "<=",
  "umbral": 1.7,
  "provisional": false,
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
  "texto": "Antes de medir, cada carga verifica que el ejecutable produce exactamente la salida esperada, y el código nativo supera en rendimiento a la máquina virtual en las diez cargas.",
  "verificacion": [
    "M5"
  ]
}
```

```medicion
{
  "id": "M5",
  "metrica": "aceleracion_minima_sobre_vm",
  "unidad": "razon",
  "suite": "PERF.SUITE.CORE",
  "comparador": ">=",
  "umbral": 1,
  "provisional": true,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La emisión del objeto en memoria, sin contar el enlazador del sistema, tarda como máximo 15 ms de mediana para cada carga de la suite.",
  "verificacion": [
    "M6"
  ]
}
```

```medicion
{
  "id": "M6",
  "metrica": "tiempo_emision_objeto",
  "unidad": "ms",
  "suite": "PERF.SUITE.CORE",
  "comparador": "<=",
  "umbral": 15,
  "provisional": true,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```

```lapida
{
  "id": "R4",
  "justificacion": "El nivel optimizado futuro no tiene backend ni plan vigente; Cranelift cumple R1 a R3."
}
```

```lapida
{
  "id": "M7",
  "justificacion": "Medición de R4 retirada con ella."
}
```

```lapida
{
  "id": "M8",
  "justificacion": "Medición de R4 retirada con ella."
}
```

```lapida
{
  "id": "M9",
  "justificacion": "Medición de R4 retirada con ella."
}
```

```lapida
{
  "id": "M10",
  "justificacion": "Medición de R4 retirada con ella."
}
```
