---
{
  "formato": "see/1",
  "id": "API.ERRORS",
  "titulo": "Errores de la API",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Todo resultado es un valor; ningún pánico cruza la frontera.",
  "depende_de": [
    {
      "id": "API.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "DIAG.ENGINE.INTERNAL-FAULT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "API errors",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Errores de la API

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Toda operación devuelve un valor: un resultado o un error de una familia. Las familias son uso (identificador desconocido, recurso liberado, operación inválida en el estado del recurso), versión (capacidad o edición no soportada) y fallo interno.",
  "verificacion": [
    "P1"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R1",
  "generador": {
    "operaciones": "todas las operaciones con argumentos válidos e inválidos"
  },
  "propiedad": "Cada operación devuelve un resultado o un error de una de las tres familias.",
  "oraculo": "Clasificación por familia de los argumentos generados.",
  "justificacion": "La ejecuta el sujeto engine en R4 y R5."
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Ningún pánico, excepción ni aborto cruza la frontera de la API. Un defecto interno se convierte en el fallo interno de DIAG.ENGINE.INTERNAL-FAULT, que es la última barrera y nunca aparece con programas del corpus.",
  "verificacion": [
    "P2"
  ]
}
```

```propiedad
{
  "id": "P2",
  "regla": "R2",
  "generador": {
    "inyeccion": "fallos inyectados en cada etapa interna"
  },
  "propiedad": "Cada fallo inyectado produce el fallo interno sin terminar el proceso anfitrión.",
  "oraculo": "Observación del proceso anfitrión.",
  "justificacion": "La ejecuta el sujeto engine en R4 y R5."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los errores de reproducción de cinta pertenecen a la familia de uso y comprenden los códigos replay_identity_mismatch, replay_divergence, replay_truncated_tape, replay_corrupted_tape y replay_non_reproducible. Todo error de reproducción describe la causa exacta sin realizar reintentos contra el anfitrión.",
  "verificacion": [
    "C1"
  ]
}
```

```caso
{
  "id": "C1",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "holamundo\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDefinir second Como ArchivoCap <- Propagar directory.Abrir(\"b\", \"lectura\");\nDefinir left Como Cadena <- Propagar file.LeerTexto();\nDefinir right Como Cadena <- Propagar second.LeerTexto();\nRetornar Exito(left + right);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<string, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\ndefine second as FileCap <- propagate directory.open(\"b\", \"read\");\ndefine left as string <- propagate file.readText();\ndefine right as string <- propagate second.readText();\nreturn success(left + right);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "archivos_lectura"
    ],
    "requested_permissions": [
      "archivos_lectura"
    ],
    "files": {
      "a": "hola",
      "b": "mundo"
    },
    "grabar_y_reproducir": true
  }
}
```
