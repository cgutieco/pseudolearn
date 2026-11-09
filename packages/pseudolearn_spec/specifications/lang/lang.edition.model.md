---
{
  "formato": "see/1",
  "id": "LANG.EDITION.MODEL",
  "titulo": "Edición del lenguaje",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "revisado_por": [
    "César Antonio Gutiérrez Contreras"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Edición del lenguaje.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.PROFILE.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LIB.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.CAPABILITY.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ]
}
---

# Edición del lenguaje

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La edición vigente se identifica como 2027 en metadatos del corpus. La edición no es una sentencia ni una bandera del perfil. Ninguna construcción de ediciones futuras se admite por cambiar idioma.",
  "verificacion": [
    "C1",
    "C2"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El preludio estándar de 2027 es fijo y está formado solo por los símbolos incorporados declarados por LIB.MODEL y los tipos intrínsecos declarados por los contratos de lenguaje. No se lee del entorno, del directorio de trabajo ni de paquetes instalados y no requiere un archivo adicional. La colisión de nombres sigue el contrato dueño de cada símbolo; un subprograma homónimo oculta una función libre incorporada. El preludio declara símbolos, nunca permisos: todo efecto requiere una capacidad solicitada al anfitrión.",
  "verificacion": [
    "C3",
    "C4"
  ]
}
```

```caso
{
  "id": "C3",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Longitud(\"ab\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite length(\"ab\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso Longitud() Como Entero\nRetornar 9;\nFinSubProceso\nAlgoritmo P\nEscribir Longitud();\nFinAlgoritmo\n",
    "en": "subroutine length() as integer\nreturn 9;\nendSubroutine\nalgorithm P\nwrite length();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "9\n",
    "terminacion": "completed"
  }
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
    "es": "Algoritmo P\nEscribir 2027;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 2027;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2027\n",
    "terminacion": "completed"
  }
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
    "es": "Algoritmo P\nInterfaz X\nFinInterfaz\nFinAlgoritmo\n",
    "en": "algorithm P\ninterface X\nendInterface\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "interfaceInsideAlgorithm",
        "severidad": "error"
      }
    ]
  }
}
```
