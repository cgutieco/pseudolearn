---
{
  "formato": "see/1",
  "id": "TOOL.TEST.SPANISH-NEUTRALITY",
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
    "sample": {
      "mensajes": {
        "es": "El vínculo es inmutable; usá Definir Mutable.",
        "en": "Binding is immutable; use define mutable."
      },
      "argumentos": [],
      "tipos_argumentos": {}
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
