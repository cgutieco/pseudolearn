---
{
  "formato": "see/1",
  "id": "LANG.TYPES.CLASS",
  "titulo": "Tipos de clase",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Tipos de clase.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.PROFILE.MODEL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Tipos de clase

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los tipos de clase son nominales y admiten herencia simple. Una referencia de subclase es asignable a superclase; la dirección inversa requiere rechazo. Asignar o pasar por valor copia referencia. Igualdad compara identidad; no hay nulo escribible ni conversión implícita a texto.",
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
    "es": "Clase C\nFinClase\nAlgoritmo P\nDefinir a, b Como C;\na <- Nuevo C();\nb <- a;\nEscribir a = b;\nFinAlgoritmo\n",
    "en": "class C\nendClass\nalgorithm P\ndefine a, b as C;\na <- new C();\nb <- a;\nwrite a = b;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}\n",
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
    "es": "Clase C\nFinClase\nAlgoritmo P\nDefinir a Como C;\na <- Nuevo C();\nEscribir a;\nFinAlgoritmo\n",
    "en": "class C\nendClass\nalgorithm P\ndefine a as C;\na <- new C();\nwrite a;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "objectCannotBeWritten",
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
