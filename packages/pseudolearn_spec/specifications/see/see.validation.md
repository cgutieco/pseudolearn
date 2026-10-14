---
{
  "formato": "see/1",
  "id": "SEE.VALIDATION",
  "titulo": "Validación por capas",
  "dominio": "proceso",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Validación por capas.",
  "depende_de": [],
  "cambio": {
    "clase": "ampliacion",
    "impacto_usuarios": "Se explicitan contratos existentes y casos límite sin añadir construcciones.",
    "impacto_implementaciones": "Los consumidores comprueban las reglas ampliadas; reference permanece congelado.",
    "justificacion": "Migración completa del lenguaje vigente y de sus recursos normativos.",
    "revisado_por": "autoría automatizada; no revisión humana independiente"
  }
}
---

# Validación por capas

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La validación rechaza esquema inválido, duplicados, referencias no resueltas, reglas huérfanas, capturas sin revisor, hashes mutados y perfiles incompletos.",
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
  "texto": "Los errores de lectura y configuración impiden afirmar que un corpus valida.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "La validación comprueba integridad de lexemas bilingües, firmas, marcadores de diagnósticos, tipos de argumento, políticas de severidad, gramática alcanzable y correspondencia completa de secciones hacia contratos existentes.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas felices e infelices en las capas responsables y verificación local completa."
}
```
