---
{
  "formato": "see/1",
  "id": "API.PROGRAM.VIEW",
  "titulo": "Vista pública del programa",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "engine",
    "app"
  ],
  "resumen": "Proyección inmutable y portable para diagramas, emisores y comprobaciones estructurales.",
  "depende_de": [
    {
      "id": "API.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "API.ANALYZE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "refina"
    },
    {
      "id": "API.ERRORS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.SOURCE.POSITION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.SYNTAX.GRAMMAR",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.CLASS.INHERITANCE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Public program view"
}
---

# Vista pública del programa

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una sesión que negocia program_view devuelve una proyección de solo lectura asociada a una revisión inmutable del documento. La proyección contiene las unidades de nivel superior en orden de fuente, con clase, nombre y tramo; los nodos disponibles de declaraciones, sentencias, expresiones, tipos y símbolos resueltos; las relaciones de composición entre ellos; y las relaciones de herencia, miembros y sobrescritura. Cada relación de miembro identifica el nodo público que la representa. Diagramas, emisores Python y Rust y comprobaciones estructurales consumen esta misma proyección. No expone índices, direcciones ni disposiciones privadas del CST, HIR o bytecode, y no obliga al consumidor a volver a analizar el texto.",
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
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "vista_programa": {
      "units": [
        {
          "kind": "algorithm",
          "name": "P",
          "order": 0,
          "span": {
            "start": {
              "line": 1,
              "column": 1
            }
          }
        }
      ],
      "node_kinds_include": [
        "declaration",
        "statement",
        "expression",
        "symbol",
        "type"
      ],
      "child_order": "source"
    }
  },
  "programa": "Algoritmo P\nDefinir total Como Entero <- 2 + 3;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "vista_programa": {
      "units": [
        {
          "kind": "class",
          "name": "Base",
          "order": 0
        },
        {
          "kind": "class",
          "name": "Hija",
          "order": 1
        },
        {
          "kind": "algorithm",
          "name": "P",
          "order": 2
        }
      ],
      "inheritance": [
        {
          "class": "Hija",
          "base": "Base"
        }
      ],
      "methods": [
        {
          "class": "Hija",
          "name": "valor",
          "overrides": "Base.valor"
        }
      ],
      "members": [
        {
          "class": "Base",
          "name": "valor",
          "kind": "method",
          "visibility": "public",
          "arity": 0
        },
        {
          "class": "Hija",
          "name": "valor",
          "kind": "method",
          "visibility": "public",
          "arity": 0
        }
      ]
    }
  },
  "programa": "Clase Base\nMetodo valor() Como Entero\nRetornar 1;\nFinMetodo\nFinClase\nClase Hija Hereda De Base\nMetodo valor() Como Entero\nRetornar 2;\nFinMetodo\nFinClase\nAlgoritmo P\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La vista incluye revision_id opaco y una lista nodes. Cada nodo declara node_id opaco único dentro de esa revisión, kind de categoría y syntax_kind estable de la construcción del lenguaje, span con desplazamientos UTF-8 de inicio inclusivo y fin exclusivo codificados como cadenas decimales, y posiciones start/end de línea y columna desde uno medidas en puntos de código Unicode. Cada nodo incluye child_node_ids y child_roles en el mismo orden; cada relación child_roles identifica node_id y el papel sintáctico de esa relación. Puede incluir parent_node_id. Los nodos parameter incluyen dimensions con la cantidad de dimensiones declaradas. Los miembros field incluyen type con el lexema de su tipo declarado y dimensions con la cantidad de dimensiones declaradas. Toda referencia resuelve a un nodo de la misma vista. Los nodos de expresión declaran semántica independiente del perfil: los de operaciones binarias incluyen operators con la identidad canónica de cada operador entre operandos consecutivos (add, subtract, multiply, divide, integer_divide, modulo, power, equal, not_equal, less_than, less_than_or_equal, greater_than, greater_than_or_equal, and, or); los unarios incluyen operator (negate, positive, not); los literales incluyen literal con type (integer, real, string, character, boolean) y value; una llamada a función incorporada no oculta por un subprograma homónimo incluye builtin con la identidad canónica de la función; un acceso con receptor de superclase incluye receiver con valor super y, si nombra al constructor, super_constructor verdadero; cada array de una declaración de dimensiones es un nodo dimensioned; los subprogramas declaran los roles signature y body; las salidas sin salto de línea incluyen without_newline verdadero; y los tipos primitivos incluyen primitive con su identidad canónica. Una edición produce una revisión nueva y no promete conservar identificadores. Las variantes incluyen syntax_kind variant_construction, variant_pattern, propagation y discard_statement; variant identifica some/none/success/error, type_constructor identifica optional/result y sus hijos tienen rol type_argument. Las declaraciones locales inicializadas incluyen initialized verdadero y mutable lógico; sus hijos declaran roles binding, type e initializer. Los patrones declaran el rol binding; construcciones, propagación y descarte declaran payload. No se exponen temporales de disposición. Un enumerado (enum_unit) incluye enum_identity igual a su node_id y enum_members con los nombres de sus miembros en orden; un registro (record_unit) incluye record_identity igual a su node_id y record_fields con los node_id de sus campos record_field; un literal de función (function_literal) incluye closure_identity igual a su node_id y captured_bindings con los node_id de las declaraciones que captura. Toda relación nombra solo nodos de la misma vista y procedencia: una referencia a un nodo de otra revisión o fuente no se emite.",
  "verificacion": [
    "C3",
    "C5",
    "C7",
    "C8",
    "C9",
    "C10"
  ]
}
```

```caso
{
  "id": "C3",
  "regla": "R2",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "vista_programa": {
      "node_ids_unique": true,
      "references_same_revision": true,
      "nodes_include": [
        {
          "kind": "statement",
          "span": {
            "start_byte": "12",
            "end_byte": "28",
            "start": {
              "line": 2,
              "column": 1
            },
            "end": {
              "line": 2,
              "column": 14
            }
          }
        }
      ]
    }
  },
  "programa": "Algoritmo P\nEscribir \"🧩\";\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C5",
  "regla": "R2",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "vista_programa": {
      "syntax_kinds_include": [
        "conditional",
        "while_loop",
        "output"
      ],
      "child_roles_include": [
        {
          "syntax_kind": "conditional",
          "role": "else_body"
        }
      ]
    }
  },
  "programa": "Algoritmo P\nSi verdadero Entonces\nMientras falso Hacer\nEscribir 1;\nFinMientras\nSino\nEscribir 2;\nFinSi\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C6",
  "regla": "R2",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "vista_programa": {
      "members": [
        {
          "class": "Caja",
          "name": "saldo",
          "kind": "field",
          "type": "Entero",
          "dimensions": 0
        },
        {
          "class": "Caja",
          "name": "matriz",
          "kind": "field",
          "type": "Entero",
          "dimensions": 2
        },
        {
          "class": "Caja",
          "name": "ajustar",
          "kind": "method",
          "visibility": "public",
          "arity": 1
        }
      ],
      "nodes_include": [
        {
          "syntax_kind": "parameter",
          "dimensions": 3
        }
      ]
    }
  },
  "programa": "Clase Caja\nDefinir saldo Como Entero;\nDimension matriz[2, 3] Como Entero;\nMetodo ajustar(monto[,,] Como Entero)\nFinMetodo\nFinClase\nAlgoritmo P\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C7",
  "regla": "R2",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "vista_programa": {
      "nodes_include": [
        {
          "syntax_kind": "postfix",
          "builtin": "squareRoot"
        },
        {
          "syntax_kind": "addition",
          "operators": [
            "add"
          ]
        },
        {
          "syntax_kind": "unary",
          "operator": "negate"
        },
        {
          "syntax_kind": "literal",
          "literal": {
            "type": "integer",
            "value": "4"
          }
        },
        {
          "syntax_kind": "output",
          "without_newline": true
        },
        {
          "syntax_kind": "type",
          "primitive": "real"
        }
      ]
    }
  },
  "programa": "Algoritmo P\nDefinir x Como Real <- Raiz(4) + -1;\nEscribir x Sin Saltar;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Liberar el documento o crear una revisión posterior invalida la vista anterior y sus asociaciones de eventos. create_document admite previous_document para crear la revisión sucesora: el documento anterior se libera solo después de validar la solicitud y crear el nuevo. Un destino previo inválido produce error de uso sin alterar los documentos existentes. Consultar una identidad de nodo con otra revisión devuelve un error de uso, no un nodo coincidente por reutilización de índice.",
  "verificacion": [
    "C4",
    "P1"
  ]
}
```

```caso
{
  "id": "C4",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {
    "scenario": "boundary",
    "input": {
      "document_revision": 2,
      "node_revision": 1,
      "operation": "query_node"
    }
  },
  "espera": {
    "aplicacion": {
      "error": "usage",
      "unrelated_resources_unchanged": true
    }
  },
  "sujetos": [
    "app"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R3",
  "generador": {"programas": "pares de documentos mínimos idénticos válidos en ambos perfiles; las identidades se regeneran en cada muestra"},
  "propiedad": "Un nodo consulta su documento propio; la misma identidad falla en otro documento, en una revisión sucesora explícita y tras liberar el original. Un destino previo inválido se rechaza sin alterar documentos. El segundo documento conserva íntegra su vista.",
  "oraculo": "Asociación exclusiva de las identidades a su revisión, incluso para fuentes idénticas.",
  "justificacion": "Comprueba la API pública de los sujetos activos sin depender del modelo de presentación."
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
  "programas": {
    "es": "Algoritmo Main\nDefinir Mutable outcome Como Resultado<Entero, Cadena> <- Exito(2);\nSegun outcome Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem;\nFinSegun\noutcome <- Error(\"bad\");\nDescartar outcome;\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine mutable outcome as result<integer, string> <- success(2);\nswitch outcome do\nsuccess(value): write value;\nfailure(problem): write problem;\nendSwitch\noutcome <- failure(\"bad\");\ndiscard outcome;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "vista_programa": {
      "syntax_kinds_include": [
        "variant_construction",
        "variant_pattern",
        "discard_statement"
      ],
      "nodes_include": [
        {
          "syntax_kind": "declaration",
          "mutable": true,
          "initialized": true
        },
        {
          "syntax_kind": "type",
          "type_constructor": "result"
        },
        {
          "syntax_kind": "variant_construction",
          "variant": "success"
        },
        {
          "syntax_kind": "variant_pattern",
          "variant": "error"
        },
        {
          "syntax_kind": "discard_statement",
          "discard": true
        }
      ]
    }
  }
}
```

## Colecciones e interfaces

La vista pública incluye interface_unit, interface_signature, realization, type_parameter, type_parameters, type_arguments, for_each_loop, iteration_bindings, break_statement y defer_statement. Sus hijos distinguen firmas, interfaces realizadas, restricciones, vínculos, colección, cuerpo y limpieza. interface_identity, realized_interfaces y constraint_interface referencian identidades opacas de nodo de la revisión. No exponen valores de tipo interfaz ni tablas de despacho. Las realizaciones explícitas se atribuyen a la declaración que las contiene; la satisfacción heredada pertenece a la semántica.

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
  "programas": {
    "es": "Enumerado Color\nRojo, Verde\nFinEnumerado\nRegistro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo Main\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde\nendEnum\nrecord Punto\ndefine x, z as integer;\nendRecord\nalgorithm Main\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "vista_programa": {
      "syntax_kinds_include": [
        "enum_unit",
        "record_unit",
        "record_field"
      ],
      "nodes_include": [
        {
          "syntax_kind": "enum_unit",
          "enum_members": [
            "Rojo",
            "Verde"
          ]
        }
      ]
    }
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
  "programas": {
    "es": "SubProceso make(value Como Entero) Como SubProceso() Como Entero\nDefinir captured Como Entero <- value;\nRetornar SubProceso() Como Entero\nRetornar captured;\nFinSubProceso;\nFinSubProceso\nAlgoritmo Main\nFinAlgoritmo\n",
    "en": "subroutine make(value as integer) as subroutine() as integer\ndefine captured as integer <- value;\nreturn subroutine() as integer\nreturn captured;\nendSubroutine;\nendSubroutine\nalgorithm Main\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "vista_programa": {
      "syntax_kinds_include": [
        "function_literal"
      ]
    }
  }
}
```
