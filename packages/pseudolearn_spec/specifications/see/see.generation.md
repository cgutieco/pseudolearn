---
{
  "formato": "see/1",
  "id": "SEE.GENERATION",
  "titulo": "Exportación para consumidores",
  "dominio": "proceso",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Exportación para consumidores.",
  "depende_de": [],
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Exportación para consumidores

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La exportación JSON contiene contratos, hashes e índices de áreas; --check rechaza una copia desactualizada.",
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
  "clase": "sistema",
  "texto": "La exportación incluye recursos normativos de vocabulario, funciones, diagnósticos y gramática. El vocabulario consumidor, incluidos alias y función por identidad, se deriva del corpus; --check rechaza cualquier artefacto desactualizado.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas felices e infelices en las capas responsables y verificación local completa."
}
```
