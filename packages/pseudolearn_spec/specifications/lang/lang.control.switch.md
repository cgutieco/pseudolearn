---
{
  "formato": "see/1",
  "id": "LANG.CONTROL.SWITCH",
  "titulo": "Selección múltiple",
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
  "resumen": "Selección múltiple.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.RELATIONS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Selección múltiple

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Segun evalúa el selector una sola vez. Etiquetas son literales, admiten listas y no se repiten; entero con signo es literal. No hay caída entre ramas. De Otro Modo es opcional, única y última; cada rama exige dos puntos. Estricto admite etiquetas enteras; flexible añade carácter, cadena y lógico. Real se rechaza en ambos. Selector y etiquetas deben ser compatibles. Cero ramas y ninguna coincidencia son válidos.",
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
    "es": "Algoritmo P\nSegun 2 Hacer\n1, 2: Escribir 1;\nDe Otro Modo: Escribir 0;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\nswitch 2 do\n1, 2: write 1;\notherwise: write 0;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
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
    "es": "Algoritmo P\nSegun 2 Hacer\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\nswitch 2 do\nendSwitch\nendAlgorithm\n"
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
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nSegun 1 Hacer\n1: Escribir 1;\n1: Escribir 2;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\nswitch 1 do\n1: write 1;\n1: write 2;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "duplicateSwitchCaseLabel",
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

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Si el selector es un enumerado, las etiquetas son miembros nombre.miembro de ese mismo enumerado. Las ramas deben cubrir todos los miembros o incluir De Otro Modo. Una selección incompleta produce nonExhaustiveSwitch con los miembros faltantes en orden de declaración. Los duplicados son duplicateSwitchCaseLabel; un patrón después de De Otro Modo es unreachableSwitchPattern. Un enumerado vacío admite cero ramas y uno de un miembro exige cubrir ese miembro. Los errores de tipo o duplicación no generan errores derivados de exhaustividad. Las selecciones sobre literales conservan R1. Para variantes incorporadas, los patrones Nada, Algo(nombre), Exito(nombre) y Error(nombre) cubren su alternativa e introducen un vínculo inmutable de carga útil visible solo en esa rama. Los vínculos no usados reciben la advertencia habitual. No se permiten variantes de otra familia ni patrones anidados. De Otro Modo cubre las alternativas restantes. Cada rama de variante contiene un único patrón. Sus nombres pueden ocultar vínculos externos mientras se comprueba esa rama; no escapan de ella.",
  "verificacion": [
    "C4",
    "C5",
    "C6",
    "C7",
    "C8",
    "C9",
    "C10",
    "C11",
    "C12",
    "C13",
    "C14",
    "C15",
    "C16",
    "C17"
  ]
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
    "es": "Enumerado Color\nRojo, Verde\nFinEnumerado\nAlgoritmo P\nDefinir c Como Color <- Color.Verde;\nSegun c Hacer\nColor.Rojo: Escribir 1;\nColor.Verde: Escribir 2;\nFinSegun\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde\nendEnum\nalgorithm P\ndefine c as Color <- Color.Verde;\nswitch c do\nColor.Rojo: write 1;\nColor.Verde: write 2;\nendSwitch\nendAlgorithm\n"
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

```caso
{
  "id": "C5",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Enumerado Color\nRojo, Verde\nFinEnumerado\nAlgoritmo P\nDefinir c Como Color <- Color.Rojo;\nSegun c Hacer\nColor.Verde: Escribir 2;\nDe Otro Modo: Escribir 0;\nFinSegun\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde\nendEnum\nalgorithm P\ndefine c as Color <- Color.Rojo;\nswitch c do\nColor.Verde: write 2;\notherwise: write 0;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0\n",
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
  "id": "C6",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Enumerado Color\nRojo, Verde\nFinEnumerado\nAlgoritmo P\nDefinir c Como Color <- Color.Rojo;\nSegun c Hacer\nColor.Rojo: Escribir 1;\nColor.Rojo: Escribir 2;\nFinSegun\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde\nendEnum\nalgorithm P\ndefine c as Color <- Color.Rojo;\nswitch c do\nColor.Rojo: write 1;\nColor.Rojo: write 2;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "duplicateSwitchCaseLabel",
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
  "id": "C7",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Enumerado Color\nRojo, Verde\nFinEnumerado\nAlgoritmo P\nDefinir c Como Color <- Color.Rojo;\nSegun c Hacer\n1: Escribir 1;\nFinSegun\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde\nendEnum\nalgorithm P\ndefine c as Color <- Color.Rojo;\nswitch c do\n1: write 1;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleSwitchCaseType",
        "severidad": "error"
      }
    ]
  },
  "rigor": [
    "estricto"
  ]
}
```

```caso
{
  "id": "C8",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "programas": {
    "es": "Enumerado Color\nRojo, Verde\nFinEnumerado\nAlgoritmo P\nDefinir c Como Color <- Color.Rojo;\nSegun c Hacer\nColor.Rojo: Escribir 1;\nFinSegun\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde\nendEnum\nalgorithm P\ndefine c as Color <- Color.Rojo;\nswitch c do\nColor.Rojo: write 1;\nendSwitch\nendAlgorithm\n"
  },
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "nonExhaustiveSwitch",
        "severidad": "error",
        "argumentos": {
          "lexeme": "Color.Verde"
        }
      }
    ]
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "programas": {
    "es": "Enumerado Color\nRojo, Verde\nFinEnumerado\nAlgoritmo P\nDefinir c Como Color <- Color.Rojo;\nSegun c Hacer\nDe Otro Modo: Escribir 0;\nColor.Rojo: Escribir 1;\nFinSegun\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde\nendEnum\nalgorithm P\ndefine c as Color <- Color.Rojo;\nswitch c do\notherwise: write 0;\nColor.Rojo: write 1;\nendSwitch\nendAlgorithm\n"
  },
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "unreachableSwitchPattern",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "programas": {
    "es": "Enumerado Color\nRojo, Verde\nFinEnumerado\nAlgoritmo P\nDefinir c Como Color <- Color.Rojo;\nSegun c Hacer\nColor.Rojo: Escribir 1;\nColor.Verde: Escribir 2;\nFinSegun\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde\nendEnum\nalgorithm P\ndefine c as Color <- Color.Rojo;\nswitch c do\nColor.Rojo: write 1;\nColor.Verde: write 2;\nendSwitch\nendAlgorithm\n"
  },
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Enumerado Color\nRed, Green, Blue, White, Black\nFinEnumerado\nAlgoritmo Main\nDefinir Mutable value Como Entero <- 0;\nSegun Color.White Hacer\nColor.Red: value <- 1;\nColor.Green: value <- 2;\nColor.Blue: value <- 3;\nColor.White: value <- 4;\nColor.Black: value <- 5;\nFinSegun\nEscribir value;\nFinAlgoritmo\n",
    "en": "enum Color\nRed, Green, Blue, White, Black\nendEnum\nalgorithm Main\ndefine mutable value as integer <- 0;\nswitch Color.White do\nColor.Red: value <- 1;\nColor.Green: value <- 2;\nColor.Blue: value <- 3;\nColor.White: value <- 4;\nColor.Black: value <- 5;\nendSwitch\nwrite value;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "4\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R2",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir outcome Como Resultado<Entero, Cadena> <- Exito(2);\nSegun outcome Hacer\nExito(value): Escribir value;\nFinSegun\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "nonExhaustiveSwitch",
        "severidad": "error",
        "argumentos": {
          "lexeme": "Error"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El argumento diagnóstico contiene la grafía del constructor; la comprobación del otro perfil vive en C17."
  }
}
```

```caso
{
  "id": "C13",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir value Como Opcional<Entero> <- Nada;\nSegun value Hacer\nNada: Escribir 0;\nNada: Escribir 1;\nAlgo(found): Escribir found;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine value as optional<integer> <- none;\nswitch value do\nnone: write 0;\nnone: write 1;\nsome(found): write found;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "duplicateSwitchCaseLabel",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C14",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nSegun Algo(2) Hacer\nAlgo(value): Escribir 1;\nNada: Escribir 0;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\nswitch some(2) do\nsome(value): write 1;\nnone: write 0;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableDeclaredNeverUsed",
        "severidad": "warning"
      }
    ]
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Enumerado Empty\nFinEnumerado\nSubProceso Inspect(value Como Empty)\nSegun value Hacer\nFinSegun\nFinSubProceso\nAlgoritmo Main\n\nFinAlgoritmo\n",
    "en": "enum Empty\nendEnum\nsubroutine Inspect(value as Empty)\nswitch value do\nendSwitch\nendSubroutine\nalgorithm Main\n\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "unusedSubroutine",
        "severidad": "warning"
      }
    ]
  }
}
```

```caso
{
  "id": "C16",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Enumerado Only\nMember\nFinEnumerado\nAlgoritmo Main\nSegun Only.Member Hacer\nOnly.Member: Escribir 1;\nFinSegun\nFinAlgoritmo\n",
    "en": "enum Only\nMember\nendEnum\nalgorithm Main\nswitch Only.Member do\nOnly.Member: write 1;\nendSwitch\nendAlgorithm\n"
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
  "id": "C17",
  "regla": "R2",
  "perfiles": [
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "en": "algorithm Main\ndefine outcome as result<integer, string> <- success(2);\nswitch outcome do\nsuccess(value): write value;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "nonExhaustiveSwitch",
        "severidad": "error",
        "argumentos": {
          "lexeme": "failure"
        }
      }
    ]
  },
  "exclusiones": {
    "es": "El argumento diagnóstico contiene la grafía del constructor; la comprobación del otro perfil vive en C12."
  }
}
```
