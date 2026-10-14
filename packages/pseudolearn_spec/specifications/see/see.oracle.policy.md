---
{
  "formato": "see/1",
  "id": "SEE.ORACLE.POLICY",
  "titulo": "Independencia del oráculo",
  "dominio": "proceso",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Independencia del oráculo.",
  "depende_de": []
}
---

# Independencia del oráculo

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada caso declara origen; capturado exige revisor independiente de la captura.",
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
  "texto": "La comparación preserva salida exacta, terminación y multiconjunto completo de diagnósticos, incluidos los tramos declarados; no normaliza fallos del sujeto.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones ni cambia el sujeto congelado.
