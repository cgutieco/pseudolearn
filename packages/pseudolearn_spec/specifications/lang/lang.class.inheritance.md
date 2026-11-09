---
{
  "formato": "see/1",
  "id": "LANG.CLASS.INHERITANCE",
  "titulo": "Herencia simple",
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
  "resumen": "Herencia simple.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.CLASS.DECLARATION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
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
    "C2",
    "C3",
    "C4"
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
    "es": "Clase A\nFinClase\nClase B Hereda De A\nFinClase\nAlgoritmo P\nDefinir x Como A <- Nuevo B();\nFinAlgoritmo\n",
    "en": "class A\nendClass\nclass B inherits from A\nendClass\nalgorithm P\ndefine x as A <- new B();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
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
    "es": "Clase A Hereda De B\nFinClase\n\nClase B Hereda De A\nFinClase\n\nAlgoritmo P\n\nFinAlgoritmo\n",
    "en": "Class A Inherits From B\nEndClass\n\nClass B Inherits From A\nEndClass\n\nAlgorithm P\n\nEndAlgorithm\n"
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
    "es": "Clase A\nFinClase\nClase B\nFinClase\nClase C Hereda De A, B\nFinClase\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "class A\nendClass\nclass B\nendClass\nclass C inherits from A, B\nendClass\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "multipleInheritanceNotSupported",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase Animal\n  Metodo Comer()\n    Escribir \"Ñam\";\n  FinMetodo\nFinClase\n\nClase Perro Hereda De Animal\n  Metodo Ladrar()\n    Escribir \"Guau\";\n  FinMetodo\nFinClase\n\nAlgoritmo Granja\n  Definir toby Como Perro <- Nuevo Perro();\n  toby.Comer();\n  toby.Ladrar();\nFinAlgoritmo\n",
    "en": "Class Animal\n  Method Eat()\n    Write \"Ñam\";\n  EndMethod\nEndClass\n\nClass Dog Inherits From Animal\n  Method Bark()\n    Write \"Guau\";\n  EndMethod\nEndClass\n\nAlgorithm Farm\n  Define toby As Dog <- New Dog();\n  toby.Eat();\n  toby.Bark();\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Ñam\nGuau\n",
    "terminacion": "completed"
  }
}
```
