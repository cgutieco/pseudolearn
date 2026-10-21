---
{
  "formato": "see/1",
  "id": "PERF.AOT.LEVEL",
  "titulo": "Nivel del código nativo",
  "dominio": "rendimiento",
  "estado": "experimental",
  "version": "2.0.0",
  "duenos": [
    "responsable-rendimiento"
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
      "id": "PERF.SUITE.AWFY-CORE",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Native code level",
  "cambio": {
    "clase": "cambio_significado",
    "impacto_usuarios": "R1 exige solo el nivel Cranelift: razón por familia como máximo 1,70 frente a V1F. El nivel optimizado futuro, como máximo 1,30 frente a V1F-S, pasa a la regla R4.",
    "impacto_implementaciones": "Un backend que cumple 1,70 frente a V1F cumple R1 sin depender del denominador V1F-S. Las mediciones M7 a M10 se verifican en R4. Los arneses identifican nivel y denominador; no se reinterpretan campañas históricas.",
    "justificacion": "Una sola regla que mezclaba dos niveles impedía certificar el nivel Cranelift mientras el nivel optimizado no existe como backend; separarlas permite certificar cada nivel con su propia evidencia.",
    "revisado_por": "persona-responsable"
  }
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
  "suite": "PERF.SUITE.AWFY-CORE",
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
  "suite": "PERF.SUITE.AWFY-CORE",
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
  "suite": "PERF.SUITE.AWFY-CORE",
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
  "suite": "PERF.SUITE.AWFY-CORE",
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
  "suite": "PERF.SUITE.AWFY-CORE",
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
  "suite": "PERF.SUITE.AWFY-CORE",
  "comparador": "<=",
  "umbral": 15,
  "provisional": true,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```


```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La media geométrica de cocientes de tiempos medianos por carga es como máximo 1,30 frente a V1F-S para el nivel optimizado futuro, en cada familia numérica, recursiva, de objetos y de arreglos. V1F-S incorpora definición de valores y recolección forzada con límite de celdas vivas; el intervalo nativo incluye ejecución y conciliación final.",
  "verificacion": [
    "M7",
    "M8",
    "M9",
    "M10"
  ]
}
```

```medicion
{
  "id": "M7",
  "metrica": "razon_aot_optimizado_v1fs_numeric",
  "unidad": "razon",
  "suite": "PERF.SUITE.AWFY-CORE",
  "comparador": "<=",
  "umbral": 1.3,
  "provisional": true,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```

```medicion
{
  "id": "M8",
  "metrica": "razon_aot_optimizado_v1fs_recursive",
  "unidad": "razon",
  "suite": "PERF.SUITE.AWFY-CORE",
  "comparador": "<=",
  "umbral": 1.3,
  "provisional": true,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```

```medicion
{
  "id": "M9",
  "metrica": "razon_aot_optimizado_v1fs_objects",
  "unidad": "razon",
  "suite": "PERF.SUITE.AWFY-CORE",
  "comparador": "<=",
  "umbral": 1.3,
  "provisional": true,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```

```medicion
{
  "id": "M10",
  "metrica": "razon_aot_optimizado_v1fs_arrays",
  "unidad": "razon",
  "suite": "PERF.SUITE.AWFY-CORE",
  "comparador": "<=",
  "umbral": 1.3,
  "provisional": true,
  "plataformas": [
    "macos-arm64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```
