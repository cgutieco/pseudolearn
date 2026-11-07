---
{
  "formato": "see/1",
  "id": "LANG.SUBPROGRAM.DECLARATION",
  "titulo": "Declaración de subprogramas",
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
  "resumen": "Declaración de subprogramas.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.DECL.VARIABLE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Declaración de subprogramas

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "SubProceso exige nombre y paréntesis aun sin parámetros; su tipo de retorno es opcional y admite primitivo o clase, nunca arreglo. Sin tipo no devuelve valor. Unidades son hermanas del algoritmo y su orden no restringe llamadas. Cuerpo vacío es válido; nombres duplicados y anidamiento se rechazan. Funcion r <- nombre(parámetros) declara una función con variable de retorno: el cuerpo debe declarar r con Definir en su nivel superior (returnVariableNotDeclared en otro caso) y el tipo de retorno es el de r; la cabecera no lleva Como tipo. La firma es la misma que la de la forma SubProceso equivalente, de modo que la función se llama, se pasa como valor y se usa en recursión igual.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6",
    "C7"
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
    "es": "SubProceso f()\nEscribir 1;\nFinSubProceso\nAlgoritmo P\nf();\nFinAlgoritmo\n",
    "en": "subroutine f()\nwrite 1;\nendSubroutine\nalgorithm P\nf();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
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
    "es": "SubProceso f\nFinSubProceso\nAlgoritmo P\n\nFinAlgoritmo\n",
    "en": "subroutine f\nendSubroutine\nalgorithm P\n\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedSubroutineLeftParenthesis",
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
    "es": "Funcion r <- Mayor(a Como Entero, b Como Entero)\nDefinir r Como Entero;\nSi a > b Entonces\nr <- a;\nSino\nr <- b;\nFinSi\nFinFuncion\nAlgoritmo P\nEscribir Mayor(3, 9), Mayor(4, 2);\nFinAlgoritmo\n",
    "en": "function r <- Larger(a as integer, b as integer)\ndefine r as integer;\nif a > b then\nr <- a;\nelse\nr <- b;\nendIf\nendSubroutine\nalgorithm P\nwrite Larger(3, 9), Larger(4, 2);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "94\n",
    "terminacion": "completed"
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
    "es": "Funcion r <- Doble(a Como Entero)\nr <- a * 2;\nFinFuncion\nAlgoritmo P\nEscribir Doble(2);\nFinAlgoritmo\n",
    "en": "function r <- Twice(a as integer)\nr <- a * 2;\nendSubroutine\nalgorithm P\nwrite Twice(2);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "returnVariableNotDeclared",
        "severidad": "error",
        "argumentos": {
          "lexeme": "r"
        }
      },
      {
        "codigo": "undeclaredVariable",
        "severidad": "error",
        "argumentos": {
          "lexeme": "r"
        }
      }
    ]
  }
}
```

```caso
{
  "id": "C5",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Funcion r <- Mayor(a Como Entero, b Como Entero)\nDefinir r Como Entero;\nSi a > b Entonces\nr <- a;\nSino\nr <- b;\nFinSi\nFinFuncion\nAlgoritmo P\nDefinir g Como SubProceso(Entero, Entero) Como Entero <- Mayor;\nEscribir g(5, 1);\nFinAlgoritmo\n",
    "en": "function r <- Larger(a as integer, b as integer)\ndefine r as integer;\nif a > b then\nr <- a;\nelse\nr <- b;\nendIf\nendSubroutine\nalgorithm P\ndefine g as subroutine(integer, integer) as integer <- Larger;\nwrite g(5, 1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso Saludar(nombre Como Cadena)\n  Escribir \"Hola, \", nombre;\nFinSubProceso\n\nAlgoritmo Bienvenida\n  Saludar(\"Ana\");\n  Saludar(\"Luis\");\nFinAlgoritmo\n",
    "en": "Subroutine Greet(name As String)\n  Write \"Hola, \", name;\nEndSubroutine\n\nAlgorithm Welcome\n  Greet(\"Ana\");\n  Greet(\"Luis\");\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Hola, Ana\nHola, Luis\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C7",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso Doble(numero Como Entero) Como Entero\n  Retornar numero * 2;\nFinSubProceso\n\nAlgoritmo Calcular\n  Escribir Doble(21);\nFinAlgoritmo\n",
    "en": "Subroutine Twice(number As Integer) As Integer\n  Return number * 2;\nEndSubroutine\n\nAlgorithm Compute\n  Write Twice(21);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "42\n",
    "terminacion": "completed"
  }
}
```
