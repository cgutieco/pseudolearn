---
{
  "formato": "see/1",
  "id": "LANG.CLASS.METHODS",
  "titulo": "Métodos de instancia",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Métodos de instancia.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.CLASS.FIELDS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.SUBPROGRAM.DECLARATION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Métodos de instancia

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Metodo declara un método dentro de clase con reglas de parámetros y retorno de subprogramas. Todos son de instancia. La visibilidad opcional es pública por defecto. No hay sobrecarga: nombres de atributos y métodos comparten espacio de miembros. Cuerpo y lista de parámetros pueden ser vacíos. Un método fuera de clase es sintáctico.",
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
    "es": "Clase C\nPrivado Definir value Como Entero;\nMetodo Constructor(value Como Entero)\nEste.value <- value;\nFinMetodo\nMetodo get() Como Entero\nRetornar Este.value;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir x Como C <- Nuevo C(7);\nEscribir x.get();\nFinAlgoritmo\n",
    "en": "class C\nprivate define value as integer;\nmethod constructor(value as integer)\nthis.value <- value;\nendMethod\nmethod get() as integer\nreturn this.value;\nendMethod\nendClass\nalgorithm P\ndefine x as C <- new C(7);\nwrite x.get();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\n",
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
    "es": "Algoritmo P\nMetodo f()\nFinMetodo\nFinAlgoritmo\n",
    "en": "algorithm P\nmethod f()\nendMethod\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "methodOutsideClass",
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
    "es": "Clase Calculadora\n  Metodo Sumar(a Como Entero, b Como Entero) Como Entero\n    Retornar a + b;\n  FinMetodo\nFinClase\n\nAlgoritmo Cuentas\n  Definir calc Como Calculadora <- Nuevo Calculadora();\n  Escribir calc.Sumar(2, 3);\nFinAlgoritmo\n",
    "en": "Class Calculator\n  Method Add(a As Integer, b As Integer) As Integer\n    Return a + b;\n  EndMethod\nEndClass\n\nAlgorithm Sums\n  Define calc As Calculator <- New Calculator();\n  Write calc.Add(2, 3);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5\n",
    "terminacion": "completed"
  }
}
```
