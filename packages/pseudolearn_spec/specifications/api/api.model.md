---
{
  "formato": "see/1",
  "id": "API.MODEL",
  "titulo": "Recursos de la API del núcleo",
  "dominio": "motor",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Documentos, análisis y ejecuciones como recursos con identificador.",
  "depende_de": [
    {
      "id": "ENG.EXEC.MODEL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "DIAG.MODEL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Core API resources"
}
---

# Recursos de la API del núcleo

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La API expone tres recursos con identificador opaco, estable durante la sesión: documento (texto, vocabulario, rigor y versión), análisis (de una versión de un documento) y ejecución (de un análisis sin errores). Cada recurso se crea, se consulta y se libera; liberar un documento libera sus análisis y ejecuciones.",
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
    "secuencias": "secuencias generadas de crear, consultar y liberar recursos"
  },
  "propiedad": "Toda consulta de un recurso vivo responde y toda consulta de un recurso liberado devuelve un error de uso.",
  "oraculo": "Modelo de estados de los recursos.",
  "justificacion": "La ejecuta el sujeto engine en R4 y R5."
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El núcleo devuelve códigos y argumentos tipados; la presentación de prosa en un idioma de interfaz es un parámetro opcional del borde que no altera ningún otro dato de la respuesta.",
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
    "programas": "casos analyze del corpus",
    "idiomas": [
      "es",
      "en",
      "sin idioma"
    ]
  },
  "propiedad": "Las respuestas en distintos idiomas de interfaz solo difieren en los campos de prosa.",
  "oraculo": "Respuesta sin idioma de interfaz.",
  "justificacion": "La ejecuta el sujeto engine en R4."
}
```
