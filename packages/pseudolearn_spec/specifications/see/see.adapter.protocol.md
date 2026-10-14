---
{
  "formato": "see/1",
  "id": "SEE.ADAPTER.PROTOCOL",
  "titulo": "Protocolo por proceso",
  "dominio": "proceso",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Protocolo por proceso.",
  "depende_de": []
}
---

# Protocolo por proceso

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una sesión negocia see-protocol/1 y anuncia sujeto, versión, capacidades, perfiles y rigores; cada petición tiene una respuesta JSON por línea del mismo kind.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "EOF, JSON inválido, versión incompatible y bloqueo producen error operativo; capacidad ausente produce no aplicable.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones ni cambia el sujeto congelado.
