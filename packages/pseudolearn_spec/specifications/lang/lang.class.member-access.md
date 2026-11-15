---
{
  "formato": "see/1",
  "id": "LANG.CLASS.MEMBER-ACCESS",
  "titulo": "Acceso a miembros",
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
    "engine",
    "aot"
  ],
  "resumen": "Acceso a miembros.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.CLASS.FIELDS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.CLASS.METHODS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Acceso a miembros

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El punto permite acceso encadenado sobre expresiones. Un atributo es designador; una llamada a método no. Se resuelve contra el tipo estático cuando se conoce y se respeta visibilidad. Miembro inexistente es semántico con tipo conocido o fallo de ejecución con tipo desconocido. Un receptor se evalúa una vez.",
  "verificacion": [
    "C1",
    "C2",
    "C3"
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
    "es": "Clase C\nPrivado Definir value Como Entero;\nMetodo Constructor(value Como Entero)\nEste.value <- value;\nFinMetodo\nMetodo get() Como Entero\nRetornar Este.value;\nFinMetodo\nFinClase\nAlgoritmo P\nEscribir Nuevo C(2).get();\nFinAlgoritmo\n",
    "en": "class C\nprivate define value as integer;\nmethod constructor(value as integer)\nthis.value <- value;\nendMethod\nmethod get() as integer\nreturn this.value;\nendMethod\nendClass\nalgorithm P\nwrite new C(2).get();\nendAlgorithm\n"
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
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase C\n  Privado Definir value Como Entero;\n  Metodo Constructor(value Como Entero)\n    Este.value <- value;\n  FinMetodo\n  Metodo get() Como Entero\n    Retornar Este.value;\n  FinMetodo\nFinClase\n\nAlgoritmo P\n  Escribir Nuevo C(2).missing();\nFinAlgoritmo\n",
    "en": "Class C\n  Private Define value As Integer;\n  Method Constructor(value As Integer)\n    This.value <- value;\n  EndMethod\n  Method get() As Integer\n    Return This.value;\n  EndMethod\nEndClass\n\nAlgorithm P\n  Write New C(2).missing();\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "undefinedMember",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase Libro\n  Definir titulo Como Cadena;\n  Definir paginas Como Entero;\n  Metodo Duplicar() Como Entero\n    Retornar Este.paginas * 2;\n  FinMetodo\nFinClase\n\nAlgoritmo Biblioteca\n  Definir favorito Como Libro <- Nuevo Libro();\n  favorito.titulo <- \"Momo\";\n  favorito.paginas <- 250;\n  Escribir favorito.titulo;\n  Escribir favorito.Duplicar();\nFinAlgoritmo\n",
    "en": "Class Book\n  Define title As String;\n  Define pages As Integer;\n  Method Double() As Integer\n    Return This.pages * 2;\n  EndMethod\nEndClass\n\nAlgorithm Library\n  Define favorite As Book <- New Book();\n  favorite.title <- \"Momo\";\n  favorite.pages <- 250;\n  Write favorite.title;\n  Write favorite.Double();\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Momo\n500\n",
    "terminacion": "completed"
  }
}
```
