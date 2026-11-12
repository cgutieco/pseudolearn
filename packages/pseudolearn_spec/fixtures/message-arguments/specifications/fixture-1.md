---
{
  "formato": "see/1",
  "id": "TOOL.TEST.MESSAGES",
  "titulo": "Fixture",
  "dominio": "herramienta",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "cli"
  ],
  "resumen": "Violación deliberada.",
  "depende_de": []
}
---

# Fixture

```definicion
{
  "id": "D1",
  "termino": "cliMessages",
  "texto": "Mensajes.",
  "valor": {
    "missingFile": {
      "mensajes": {
        "es": "No existe {ruta}.",
        "en": "Missing {path}."
      },
      "argumentos": [
        "ruta"
      ],
      "tipos_argumentos": {
        "ruta": "lexema"
      }
    }
  }
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Regla de fixture.",
  "verificacion": [
    "revision_humana"
  ]
}
```
