---
{
  "formato": "see/1",
  "id": "APP.EXEC.CONFIGURATION",
  "titulo": "Configuración de ejecución: argumentos y reproducción",
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
  "resumen": "El análisis y la ejecución usan el único lenguaje, y la reproducción usa solo la cinta grabada.",
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
  "titulo_en": "Execution configuration: arguments and replay"
}
---

# Configuración de ejecución: argumentos y reproducción

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La aplicación analiza y ejecuta un programa con el único lenguaje de la edición, sin ajuste de configuración que relaje sus reglas. Un programa con terminador de sentencia omitido no se ejecuta, porque su análisis tiene un error; el mismo programa con su terminador se ejecuta con su salida. Un Para sin Con Paso se ejecuta con paso 1, igual que en el motor.",
  "verificacion": [
    "C1",
    "C2",
    "C3"
  ]
}
```

```caso
{"id": "C1", "regla": "R1", "perfiles": ["es"], "origen": "derivado", "revisado_por": "Cesar Antonio Gutierrez Contreras", "operacion": "app", "aplicacion": {"scenario": "configuration", "input": {"program": "Algoritmo P\nEscribir 1\nFinAlgoritmo\n"}}, "espera": {"aplicacion": {"output": "", "termination": "failed"}}}
```

```caso
{"id": "C2", "regla": "R1", "perfiles": ["es"], "origen": "derivado", "revisado_por": "Cesar Antonio Gutierrez Contreras", "operacion": "app", "aplicacion": {"scenario": "configuration", "input": {"program": "Algoritmo P\n  Para counter <- 1 Hasta 3 Hacer\n    Escribir counter Sin Saltar;\n  FinPara\n  Escribir \"\";\nFinAlgoritmo\n"}}, "espera": {"aplicacion": {"output": "123\n", "termination": "completed"}}}
```

```caso
{"id": "C3", "regla": "R1", "perfiles": ["es"], "origen": "derivado", "revisado_por": "Cesar Antonio Gutierrez Contreras", "operacion": "app", "aplicacion": {"scenario": "configuration", "input": {"program": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"}}, "espera": {"aplicacion": {"output": "1\n", "termination": "completed"}}}
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
{"id": "C4", "regla": "R2", "perfiles": ["es"], "origen": "derivado", "revisado_por": "Cesar Antonio Gutierrez Contreras", "operacion": "app", "aplicacion": {"scenario": "configuration", "input": {"program": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n", "replay": true}}, "espera": {"aplicacion": {"output": "1\n", "termination": "completed"}}}
```

```caso
{"id": "C5", "regla": "R2", "perfiles": ["es"], "origen": "derivado", "revisado_por": "Cesar Antonio Gutierrez Contreras", "operacion": "app", "aplicacion": {"scenario": "configuration", "input": {"program": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n", "replay": true, "replay_program": "Algoritmo P\nEscribir 2;\nFinAlgoritmo\n"}}, "espera": {"aplicacion": {"termination": "failed", "rejection": "identityMismatch"}}}
```

