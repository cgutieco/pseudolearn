---
{
  "formato": "see/1",
  "id": "APP.EXEC.CONFIGURATION",
  "titulo": "Configuración de ejecución: rigor y reproducción",
  "dominio": "app",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-aplicacion"
  ],
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "app"
  ],
  "resumen": "El rigor guardado en el documento gobierna análisis y ejecución, y la reproducción usa solo la cinta grabada.",
  "depende_de": [
    {
      "id": "API.EXECUTE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.EFFECT.TAPE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.PROFILE.STRICTNESS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Execution configuration: strictness and replay"
}
---

# Configuración de ejecución: rigor y reproducción

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El rigor de un documento se guarda con el documento y se usa tanto para analizar como para ejecutar su programa. El mismo programa con terminador de sentencia omitido no se ejecuta en rigor estricto, porque su análisis tiene un error, y se ejecuta con su salida en rigor flexible. Cambiar el rigor no cambia el significado de un programa que ambos rigores aceptan.",
  "verificacion": [
    "C1",
    "C2",
    "C3"
  ]
}
```

```caso
{"id": "C1", "regla": "R1", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "configuration", "input": {"program": "Algoritmo P\nEscribir 1\nFinAlgoritmo\n", "strictness": "strict"}}, "espera": {"aplicacion": {"output": "", "termination": "failed"}}}
```

```caso
{"id": "C2", "regla": "R1", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "configuration", "input": {"program": "Algoritmo P\nEscribir 1\nFinAlgoritmo\n", "strictness": "flexible"}}, "espera": {"aplicacion": {"output": "1\n", "termination": "completed"}}}
```

```caso
{"id": "C3", "regla": "R1", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "configuration", "input": {"program": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n", "strictness": "strict"}}, "espera": {"aplicacion": {"output": "1\n", "termination": "completed"}}}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Reproducir una ejecución envía al motor la cinta grabada por la ejecución anterior y la identidad actual de fuente y configuración, sin consultar al anfitrión. Si la identidad coincide, la reproducción produce la misma salida y terminación. Si la fuente cambió, el motor la rechaza con replay_identity_mismatch, la ejecución falla con ese rechazo tipado y la cinta grabada se conserva para otro intento.",
  "verificacion": [
    "C4",
    "C5"
  ]
}
```

```caso
{"id": "C4", "regla": "R2", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "configuration", "input": {"program": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n", "strictness": "strict", "replay": true}}, "espera": {"aplicacion": {"output": "1\n", "termination": "completed"}}}
```

```caso
{"id": "C5", "regla": "R2", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "configuration", "input": {"program": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n", "strictness": "strict", "replay": true, "replay_program": "Algoritmo P\nEscribir 2;\nFinAlgoritmo\n"}}, "espera": {"aplicacion": {"termination": "failed", "rejection": "identityMismatch"}}}
```

