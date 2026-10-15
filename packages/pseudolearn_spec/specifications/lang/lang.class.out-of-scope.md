---
{
  "formato": "see/1",
  "id": "LANG.CLASS.OUT-OF-SCOPE",
  "titulo": "Diagnósticos de construcciones ajenas a la edición",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Diagnósticos de construcciones ajenas a la edición.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.CLASS.DECLARATION",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ],
  "cambio": {
    "clase": "ampliacion",
    "impacto_usuarios": "Sin cambios en el lenguaje ni en el código admitido.",
    "impacto_implementaciones": "Activa el sujeto engine en R4 manteniendo reference.",
    "justificacion": "Habilitar la verificación de conformidad estática del nuevo motor en Rust.",
    "revisado_por": "autoría automatizada; no revisión humana independiente"
  }
}
---

# Diagnósticos de construcciones ajenas a la edición

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Interfaces, clases abstractas, miembros estáticos, visibilidad protegida, genéricos y manejo de excepciones no son construcciones de la edición vigente. En posición estructural inequívoca sus formas reconocibles producen diagnóstico pedagógico específico. Estas palabras no se añaden al vocabulario reservado y pueden ser nombres en posiciones ordinarias.",
  "verificacion": [
    "C1",
    "C2"
  ]
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nInterfaz X\nFinInterfaz\nFinAlgoritmo\n",
    "en": "algorithm P\nInterfaz X\nFinInterfaz\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "unsupportedInterfaceConstruct",
        "severidad": "error"
      }
    ]
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir interface Como Entero;\ninterface <- 2;\nEscribir interface;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine interface as integer;\ninterface <- 2;\nwrite interface;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```
