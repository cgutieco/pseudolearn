---
{
  "formato": "see/1",
  "id": "LANG.CLASS.INHERITANCE",
  "titulo": "Herencia simple",
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
  "resumen": "Herencia simple.",
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

# Herencia simple

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una clase puede heredar de una sola superclase declarada en cualquier orden. Hereda miembros y participa en subtipado nominal. Superclase inexistente y ciclo directo/indirecto son errores semánticos; varias superclases son sintácticas. No se admite sombra de atributo heredado.",
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
    "es": "Clase A\nFinClase\nClase B Hereda De A\nFinClase\nAlgoritmo P\nDefinir x Como A;\nx <- Nuevo B();\nFinAlgoritmo\n",
    "en": "class A\nendClass\nclass B inherits from A\nendClass\nalgorithm P\ndefine x as A;\nx <- new B();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "completed"
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
    "es": "Clase A Hereda De B\nFinClase\nClase B Hereda De A\nFinClase\nAlgoritmo P\n\nFinAlgoritmo\n",
    "en": "class A inherits from B\nendClass\nclass B inherits from A\nendClass\nalgorithm P\n\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "circularInheritance",
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
