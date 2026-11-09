---
{
  "formato": "see/1",
  "id": "LANG.SUBPROGRAM.BY-REFERENCE",
  "titulo": "Argumentos por referencia",
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
  "resumen": "Argumentos por referencia.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.SUBPROGRAM.PARAMETERS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.DECL.DESIGNATOR",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Argumentos por referencia

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un parámetro por referencia exige un designador de tipo exacto. El índice de un elemento se fija una vez al llamar. Un arreglo completo solo se admite para parámetro arreglo compatible en elemento y dimensiones. Dos parámetros pueden referir la misma casilla; no se prohíbe aliasing. Un índice inválido falla antes de entrar al cuerpo. Un parámetro por referencia que no es arreglo ni registro es de salida cuando su subprograma le da valor antes de toda lectura en todos los caminos y en todo fin del cuerpo, sin pasarlo antes a otro parámetro por referencia que no sea también de salida; los parámetros de un subprograma recursivo, directa o mutuamente, no son de salida. En una llamada directa por nombre, a Super o a un constructor, el argumento de un parámetro de salida puede no tener valor y lo tiene después de la llamada; el de un parámetro por referencia que no es de salida se lee y debe tener valor (variableUsedUninitialized en el argumento). En una llamada mediante un valor función o a un método con despacho dinámico todo argumento por referencia debe tener valor. La clasificación es un dato del análisis y no cambia la firma.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6",
    "C7",
    "C8",
    "C9",
    "C10",
    "C11"
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
    "es": "SubProceso f(value Como Entero Por Referencia)\nvalue <- value + 1;\nFinSubProceso\nAlgoritmo P\nDefinir x Como Entero <- 1;\nf(x);\nEscribir x;\nFinAlgoritmo\n",
    "en": "subroutine f(value as integer by reference)\nvalue <- value + 1;\nendSubroutine\nalgorithm P\ndefine x as integer <- 1;\nf(x);\nwrite x;\nendAlgorithm\n"
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
    "es": "SubProceso f(value Como Entero Por Referencia)\nvalue <- value + 1;\nFinSubProceso\nAlgoritmo P\nf(1);\nFinAlgoritmo\n",
    "en": "subroutine f(value as integer by reference)\nvalue <- value + 1;\nendSubroutine\nalgorithm P\nf(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "byReferenceArgumentRequiresDesignator",
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
    "es": "SubProceso f(value Como Entero Por Referencia)\nvalue <- value + 1;\nFinSubProceso\nAlgoritmo P\nDimension a[1] Como Entero;\na[0] <- 4;\nf(a[0]);\nEscribir a[0];\nFinAlgoritmo\n",
    "en": "subroutine f(value as integer by reference)\nvalue <- value + 1;\nendSubroutine\nalgorithm P\ndimension a[1] as integer;\na[0] <- 4;\nf(a[0]);\nwrite a[0];\nendAlgorithm\n"
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
  "id": "C4",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso Fijar(n Como Entero Por Referencia)\nn <- 7;\nFinSubProceso\nAlgoritmo P\nDefinir a Como Entero;\nFijar(a);\nEscribir a;\nFinAlgoritmo\n",
    "en": "subroutine Fijar(n as integer by reference)\nn <- 7;\nendSubroutine\nalgorithm P\ndefine a as integer;\nFijar(a);\nwrite a;\nendAlgorithm\n"
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
  "id": "C5",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso Doble(n Como Entero Por Referencia)\nn <- n * 2;\nFinSubProceso\nAlgoritmo P\nDefinir a Como Entero;\nDoble(a);\nEscribir a;\nFinAlgoritmo\n",
    "en": "subroutine Doble(n as integer by reference)\nn <- n * 2;\nendSubroutine\nalgorithm P\ndefine a as integer;\nDoble(a);\nwrite a;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableUsedUninitialized",
        "severidad": "error",
        "argumentos": {
          "cause": "noAssignment",
          "lexeme": "a"
        }
      }
    ]
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
    "es": "SubProceso Contar(k Como Entero, n Como Entero Por Referencia)\nSi k > 0 Entonces\nContar(k - 1, n);\nFinSi\nn <- k;\nFinSubProceso\nAlgoritmo P\nDefinir a Como Entero;\nContar(2, a);\nEscribir a;\nFinAlgoritmo\n",
    "en": "subroutine Contar(k as integer, n as integer by reference)\nif k > 0 then\nContar(k - 1, n);\nendIf\nn <- k;\nendSubroutine\nalgorithm P\ndefine a as integer;\nContar(2, a);\nwrite a;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableUsedUninitialized",
        "severidad": "error",
        "argumentos": {
          "cause": "noAssignment",
          "lexeme": "a"
        }
      }
    ]
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
    "es": "SubProceso Par(k Como Entero, n Como Entero Por Referencia)\nSi k > 0 Entonces\nImpar(k - 1, n);\nFinSi\nn <- 0;\nFinSubProceso\nSubProceso Impar(k Como Entero, n Como Entero Por Referencia)\nSi k > 0 Entonces\nPar(k - 1, n);\nFinSi\nn <- 1;\nFinSubProceso\nAlgoritmo P\nDefinir a Como Entero;\nPar(2, a);\nEscribir a;\nFinAlgoritmo\n",
    "en": "subroutine Par(k as integer, n as integer by reference)\nif k > 0 then\nImpar(k - 1, n);\nendIf\nn <- 0;\nendSubroutine\nsubroutine Impar(k as integer, n as integer by reference)\nif k > 0 then\nPar(k - 1, n);\nendIf\nn <- 1;\nendSubroutine\nalgorithm P\ndefine a as integer;\nPar(2, a);\nwrite a;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableUsedUninitialized",
        "severidad": "error",
        "argumentos": {
          "cause": "noAssignment",
          "lexeme": "a"
        }
      }
    ]
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso Fijar(n Como Entero Por Referencia)\nn <- 7;\nFinSubProceso\nAlgoritmo P\nDefinir f Como SubProceso(Entero Por Referencia) <- Fijar;\nDefinir a Como Entero;\nf(a);\nEscribir a;\nFinAlgoritmo\n",
    "en": "subroutine Fijar(n as integer by reference)\nn <- 7;\nendSubroutine\nalgorithm P\ndefine f as subroutine(integer by reference) <- Fijar;\ndefine a as integer;\nf(a);\nwrite a;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableUsedUninitialized",
        "severidad": "error",
        "argumentos": {
          "cause": "noAssignment",
          "lexeme": "a"
        }
      }
    ]
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase Caja\nMetodo Fijar(n Como Entero Por Referencia)\nn <- 7;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir c Como Caja <- Nuevo Caja();\nDefinir a Como Entero;\nc.Fijar(a);\nEscribir a;\nFinAlgoritmo\n",
    "en": "class Caja\nmethod Fijar(n as integer by reference)\nn <- 7;\nendMethod\nendClass\nalgorithm P\ndefine c as Caja <- new Caja();\ndefine a as integer;\nc.Fijar(a);\nwrite a;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableUsedUninitialized",
        "severidad": "error",
        "argumentos": {
          "cause": "noAssignment",
          "lexeme": "a"
        }
      }
    ]
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso Llenar(v[] Como Entero)\nv[0] <- 5;\nv[1] <- 6;\nFinSubProceso\nAlgoritmo P\nDimension a[2] Como Entero;\nLlenar(a);\nEscribir a[0], a[1];\nFinAlgoritmo\n",
    "en": "subroutine Llenar(v[] as integer)\nv[0] <- 5;\nv[1] <- 6;\nendSubroutine\nalgorithm P\ndimension a[2] as integer;\nLlenar(a);\nwrite a[0], a[1];\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "56\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso Tal(c Como Logico, n Como Entero Por Referencia)\nSi c Entonces\nn <- 1;\nFinSi\nFinSubProceso\nAlgoritmo P\nDefinir a Como Entero;\nTal(Verdadero, a);\nEscribir a;\nFinAlgoritmo\n",
    "en": "subroutine Tal(c as boolean, n as integer by reference)\nif c then\nn <- 1;\nendIf\nendSubroutine\nalgorithm P\ndefine a as integer;\nTal(true, a);\nwrite a;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableUsedUninitialized",
        "severidad": "error",
        "argumentos": {
          "cause": "noAssignment",
          "lexeme": "a"
        }
      }
    ]
  }
}
```
