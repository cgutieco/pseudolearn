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
  "texto": "Una sesión que negocia program_view devuelve una proyección de solo lectura asociada a una revisión inmutable del documento. La proyección contiene las unidades de nivel superior en orden de fuente, con clase, nombre y tramo; los nodos disponibles de declaraciones, sentencias, expresiones, tipos y símbolos resueltos; las relaciones de composición entre ellos; y las relaciones de herencia, miembros y sobrescritura. Cada relación de miembro identifica el nodo público que la representa. Diagramas, emisores Python y Rust y comprobaciones estructurales consumen esta misma proyección. No expone índices, direcciones ni disposiciones privadas del CST, HIR o bytecode, y no obliga al consumidor a volver a analizar el texto. Las llamadas resueltas a Ordenar, Invertir, PosicionDe, Contiene de vector y Claves de diccionario incluyen collection_operation con identidad contextual vectorSort, vectorReverse, vectorIndexOf, vectorContains o dictionaryKeys; no se infiere del lexema.",
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
  "texto": "La vista incluye revision_id opaco y una lista nodes. Cada nodo declara node_id opaco único dentro de esa revisión, kind de categoría y syntax_kind estable de la construcción del lenguaje, span con desplazamientos UTF-8 de inicio inclusivo y fin exclusivo codificados como cadenas decimales, y posiciones start/end de línea y columna desde uno medidas en puntos de código Unicode. Cada nodo incluye child_node_ids y child_roles en el mismo orden; cada relación child_roles identifica node_id y el papel sintáctico de esa relación. Puede incluir parent_node_id. Los nodos parameter incluyen dimensions con la cantidad de dimensiones declaradas. Los miembros field incluyen type con el lexema de su tipo declarado y dimensions con la cantidad de dimensiones declaradas. Toda referencia resuelve a un nodo de la misma vista. Los nodos de expresión declaran semántica independiente del perfil: los de operaciones binarias incluyen operators con la identidad canónica de cada operador entre operandos consecutivos (add, subtract, multiply, divide, integer_divide, modulo, power, equal, not_equal, less_than, less_than_or_equal, greater_than, greater_than_or_equal, and, or); los unarios incluyen operator (negate, positive, not); los literales incluyen literal con type (integer, real, string, character, boolean) y value; una llamada a función incorporada no oculta por un subprograma homónimo incluye builtin con la identidad canónica de la función; una llamada de capacidad o de bytes resuelta a capabilityLibrary incluye effect_operation con su identidad canónica (request_console, request_arguments, request_directory, request_clock, request_timer, console_write, arguments_values, directory_derive, file_open, directory_close, file_read_bytes, file_read_text, file_write_bytes, file_write_text, file_close, clock_now, timer_wait, bytes_new, bytes_length, bytes_at, bytes_utf8); un acceso con receptor de superclase incluye receiver con valor super y, si nombra al constructor, super_constructor verdadero; cada array de una declaración de dimensiones es un nodo dimensioned; los subprogramas declaran los roles signature y body; las salidas sin salto de línea incluyen without_newline verdadero; los tipos primitivos incluyen primitive con su identidad canónica; los tipos incorporados de entrada y salida incluyen builtin_type (bytes o io_error); y los tipos de capacidades explícitas incluyen capability_type (console, arguments, directory, file, clock, timer), sin adjuntar identidades sintéticas de clase o registro al nodo type. Una edición produce una revisión nueva y no promete conservar identificadores. Las variantes incluyen syntax_kind variant_construction, variant_pattern, propagation y discard_statement; variant identifica some/none/success/error, type_constructor identifica optional/result y sus hijos tienen rol type_argument. Las declaraciones locales con valor inicial incluyen initialized verdadero; sus hijos declaran roles binding, type e initializer. Los patrones declaran el rol binding; construcciones, propagación y descarte declaran payload. No se exponen temporales de disposición. Un enumerado (enum_unit) incluye enum_identity igual a su node_id y enum_members con los nombres de sus miembros en orden; un registro (record_unit) incluye record_identity igual a su node_id y record_fields con los node_id de sus campos record_field; un literal de función (function_literal) incluye closure_identity igual a su node_id y captured_bindings con los node_id de las declaraciones que captura. Toda relación nombra solo nodos de la misma vista y procedencia: una referencia a un nodo de otra revisión o fuente no se emite.",
  "verificacion": [
    "C3",
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
  "id": "C3",
  "regla": "R2",
  "perfiles": [
    "es"
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
  "programas": {
    "es": "Algoritmo Main\nDefinir outcome Como Resultado<Entero, Cadena> <- Exito(2);\nSegun outcome Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem;\nFinSegun\noutcome <- Error(\"bad\");\nDescartar outcome;\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine outcome as result<integer, string> <- success(2);\nswitch outcome do\nsuccess(value): write value;\nfailure(problem): write problem;\nendSwitch\noutcome <- failure(\"bad\");\ndiscard outcome;\nendAlgorithm\n"
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

```caso
{
  "id": "C11",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Bytes, ErrorES>\nDefinir dir Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar dir.Abrir(\"a\", \"lectura\");\nDiferir\nDescartar file.Cerrar();\nFinDiferir\nDefinir empty Como Bytes <- Bytes();\nRetornar Exito(empty);\nFinSubProceso\nAlgoritmo Main\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<Bytes, IoError>\ndefine dir as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate dir.open(\"a\", \"read\");\ndefer\ndiscard file.close();\nendDefer\ndefine empty as Bytes <- Bytes();\nreturn success(empty);\nendSubroutine\nalgorithm Main\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "vista_programa": {
      "syntax_kinds_include": [
        "defer_statement"
      ],
      "nodes_include": [
        {
          "syntax_kind": "type",
          "builtin_type": "bytes"
        },
        {
          "syntax_kind": "type",
          "builtin_type": "io_error"
        },
        {
          "syntax_kind": "type",
          "capability_type": "directory"
        },
        {
          "syntax_kind": "type",
          "capability_type": "file"
        },
        {
          "syntax_kind": "postfix",
          "effect_operation": "request_directory"
        },
        {
          "syntax_kind": "postfix",
          "effect_operation": "file_open"
        },
        {
          "syntax_kind": "postfix",
          "effect_operation": "file_close"
        },
        {
          "syntax_kind": "postfix",
          "effect_operation": "bytes_new"
        }
      ]
    }
  }
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La vista proyecta como nodos explícitos las construcciones de tareas: task_scope, spawn_statement, spawn_expression, await_expression, select_statement y receive_branch. Los tipos incorporados de tareas incluyen builtin_type (task, channel, immutable o task_failure) y las unidades declaradas suspendibles incluyen suspendable verdadero. task_scope declara los roles failure_binding y body, select_statement el rol branch y receive_branch los roles binding, channel y body. Ninguna construcción de tareas se proyecta como un nodo genérico de proceso.",
  "verificacion": [
    "C12"
  ]
}
```

```caso
{
  "id": "C12",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso Suspendible Work(stream Como Canal<Entero>) Como Resultado<Entero, Cadena>\nSegun Aguardar stream.Recibir() Hacer\nAlgo(value): Escribir value;\nNada: Escribir 0;\nFinSegun\nRetornar Exito(1);\nFinSubProceso\nAlgoritmo Main\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas problem\nDefinir job Como Tarea<Entero> <- Lanzar Work(stream);\nLanzar Work(stream);\nFinTareas\nDescartar problem;\nElegir\nRecibir first Desde stream:\nEscribir 1;\nRecibir second Desde stream:\nEscribir 2;\nFinElegir\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work(stream as channel<integer>) as result<integer, string>\nswitch await stream.receive() do\nsome(value): write value;\nnone: write 0;\nendSwitch\nreturn success(1);\nendSubroutine\nalgorithm Main\ndefine stream as channel<integer> <- channel(1);\ntasks problem\ndefine job as task<integer> <- spawn Work(stream);\nspawn Work(stream);\nendTasks\ndiscard problem;\nselect\nreceive first from stream:\nwrite 1;\nreceive second from stream:\nwrite 2;\nendSelect\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "vista_programa": {
      "syntax_kinds_include": [
        "task_scope",
        "spawn_statement",
        "spawn_expression",
        "await_expression",
        "select_statement",
        "receive_branch"
      ],
      "nodes_include": [
        {
          "syntax_kind": "type",
          "builtin_type": "task"
        },
        {
          "syntax_kind": "type",
          "builtin_type": "channel"
        },
        {
          "syntax_kind": "subroutine",
          "suspendable": true
        }
      ]
    }
  }
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La vista mantiene las relaciones estáticas mediante node_id de la misma revisión y fuente. Cada clase expone realizaciones explícitas e heredadas con clase, contrato resuelto si existe, declaración de origen, origen explicit o inherited, estado valid o invalid y códigos diagnósticos; un destino sin resolver solo puede citar su nodo sintáctico y no usa su nombre como identidad. Una realización heredada es invalid si una sobrescritura incompatible diagnosticada por el análisis redefine en la cadena de herencia una operación de ese contrato; el diagnóstico se vincula por el tramo del método y el tramo relacionado de la firma del contrato, y origin_node_id identifica el método que sobrescribe. El nodo method_member de ese origen expone method_signature_span, el rango de su encabezado calculado desde la estructura sintáctica. Una realización heredada sin esa incidencia permanece valid. Cada parámetro genérico expone sus restricciones y node_id del contrato, o invalidez diagnóstica si el contrato no existe. Las variantes conservan su discriminante y relacionan la carga por los papeles de sus hijos; none no inventa una carga. Las clausuras exponen cada vínculo de origen con modo value y no exponen direcciones ni un entorno materializado. Cada for_each enlaza colección, vínculos, cuerpo y dueño de ámbito. Herencia, sobrescritura y miembros incluyen node_id de clase y de destino cuando ambos nodos están disponibles; las etiquetas textuales existentes se conservan por compatibilidad. Ningún dato estático incorpora disposiciones, temporales ni estado de ejecución.",
  "verificacion": [
    "C13",
    "C14",
    "C15",
    "C16",
    "C43"
  ]
}
```

```caso
{
  "id": "C16",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir counter Como Entero <- 1;\nDefinir callback Como SubProceso() Como Entero <- SubProceso() Como Entero\nRetornar counter;\nFinSubProceso;\ncounter <- 2;\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine counter as integer <- 1;\ndefine callback as subroutine() as integer <- subroutine() as integer\nreturn counter;\nendSubroutine;\ncounter <- 2;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "diagnosticos": [
      {
        "codigo": "mutableClosureCapture",
        "severidad": "error"
      }
    ],
    "vista_programa": {
      "closures_without_captures": true
    }
  }
}
```

```caso
{
  "id": "C13",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Interfaz Readable\nMetodo readValue() Como Entero;\nFinInterfaz\nClase Reader Realiza Readable\nMetodo readValue() Como Entero\nRetornar 7;\nFinMetodo\nFinClase\nClase Writer Realiza Readable\nMetodo readValue() Como Entero\nRetornar 8;\nFinMetodo\nFinClase\nClase Child Hereda De Reader\nFinClase\nSubProceso readOnce<T: Readable>(value Como T) Como Entero\nRetornar value.readValue();\nFinSubProceso\nSubProceso make(value Como Entero) Como SubProceso() Como SubProceso() Como Entero\nDefinir captured Como Entero <- value;\nRetornar SubProceso() Como SubProceso() Como Entero\nRetornar SubProceso() Como Entero\nRetornar captured;\nFinSubProceso;\nFinSubProceso;\nFinSubProceso\nAlgoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nPara Cada value En values Hacer\nPara Cada nested En values Hacer\nEscribir nested;\nFinPara\nFinPara\nDefinir result Como Resultado<Entero, Cadena> <- Exito(1);\nSegun result Hacer\nExito(item): Escribir item;\nError(problem): Escribir problem;\nFinSegun\nFinAlgoritmo\n",
    "en": "interface Readable\nmethod readValue() as integer;\nendInterface\nclass Reader implements Readable\nmethod readValue() as integer\nreturn 7;\nendMethod\nendClass\nclass Writer implements Readable\nmethod readValue() as integer\nreturn 8;\nendMethod\nendClass\nclass Child extends Reader\nendClass\nsubroutine readOnce<T: Readable>(value as T) as integer\nreturn value.readValue();\nendSubroutine\nsubroutine make(value as integer) as subroutine() as subroutine() as integer\ndefine captured as integer <- value;\nreturn subroutine() as subroutine() as integer\nreturn subroutine() as integer\nreturn captured;\nendSubroutine;\nendSubroutine;\nendSubroutine\nalgorithm Main\ndefine values as vector<integer> <- vector();\nfor each value in values do\nfor each nested in values do\nwrite nested;\nendFor\nendFor\ndefine outcome as result<integer, string> <- success(1);\nswitch outcome do\nsuccess(item): write item;\nfailure(problem): write problem;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "vista_programa": {
      "relations_same_revision_and_source": true,
      "realizations_include": [
        {
          "origin": "explicit",
          "status": "valid"
        },
        {
          "origin": "inherited",
          "status": "valid"
        }
      ],
      "constraints_include": [
        {
          "status": "valid"
        }
      ],
      "iterations_include": [
        "collection_node_id",
        "bindings_node_id",
        "body_node_id",
        "scope_owner_node_id"
      ],
      "variants_include_payload_roles": true,
      "captures_include": [
        {
          "mode": "value"
        }
      ]
    }
  }
}
```

```caso
{
  "id": "C14",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Interfaz Needed\nMetodo run() Como Entero;\nFinInterfaz\nClase Broken Realiza Needed\nFinClase\nClase Missing Realiza Absent\nFinClase\nSubProceso use<T: Absent>(item Como T)\nFinSubProceso\nAlgoritmo Main\nFinAlgoritmo\n",
    "en": "interface Needed\nmethod run() as integer;\nendInterface\nclass Broken implements Needed\nendClass\nclass Missing implements Absent\nendClass\nsubroutine use<T: Absent>(item as T)\nendSubroutine\nalgorithm Main\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "vista_programa": {
      "realizations_include": [
        {
          "origin": "explicit",
          "status": "invalid",
          "diagnostics": [
            "interfaceMethodMissing"
          ]
        },
        {
          "origin": "explicit",
          "status": "invalid",
          "interface_node_id": null,
          "diagnostics": [
            "unknownInterface"
          ]
        }
      ],
      "constraints_include": [
        {
          "status": "invalid",
          "interface_node_id": null,
          "diagnostics": [
            "unknownInterface"
          ]
        }
      ],
      "relations_same_revision_and_source": true
    }
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Interfaz Marker\nFinInterfaz\nClase Marked Realiza Marker\nFinClase\nAlgoritmo Main\nDefinir absent Como Opcional<Entero> <- Nada;\nDescartar absent;\nDefinir values Como Vector<Entero> <- Vector();\nPara Cada item En values Hacer\nEscribir item;\nFinPara\nFinAlgoritmo\n",
    "en": "interface Marker\nendInterface\nclass Marked implements Marker\nendClass\nalgorithm Main\ndefine absent as optional<integer> <- none;\ndiscard absent;\ndefine values as vector<integer> <- vector();\nfor each item in values do\nwrite item;\nendFor\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "vista_programa": {
      "realizations_include": [
        {
          "origin": "explicit",
          "status": "valid"
        }
      ],
      "variants_without_payload": true,
      "iterations_include": [
        "collection_node_id",
        "bindings_node_id",
        "body_node_id",
        "scope_owner_node_id"
      ]
    }
  }
}
```

## Representación de contratos en el diagrama de clases

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El consumidor del diagrama de clases representa una interfaz como una caja con el estereotipo «interface», su nombre y una fila por operación con la forma «+ nombre(parámetros): retorno». No tiene atributos ni se instancia, y permanece visible aunque nadie la realice.",
  "verificacion": [
    "C17"
  ]
}
```

```caso
{"id": "C17", "regla": "R6", "perfiles": ["en"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "class_diagram", "input": {"program": "interface Readable\nmethod readValue() as integer;\nendInterface\nalgorithm Main\nendAlgorithm\n", "profile": "en"}}, "espera": {"aplicacion": {"boxes": [{"name": "Readable", "stereotype": "«interface»", "rows": ["+ readValue(): integer"]}], "relations": []}}}
```

```regla
{
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada realización explícita válida se representa como una relación de realización dirigida desde la clase hacia el contrato, distinta de la herencia. La realización heredada válida no se dibuja de nuevo: la relación de herencia la transporta. Una realización heredada inválida por incompatibleMethodOverride sí se representa desde la subclase hacia el contrato. El contrato ocupa un nivel superior al de sus realizaciones, de modo que las cajas se listan de arriba abajo.",
  "verificacion": [
    "C18",
    "C19",
    "C20",
    "C41",
    "C46"
  ]
}
```

```caso
{"id": "C18", "regla": "R7", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "class_diagram", "input": {"program": "Interfaz Legible\nMetodo obtener() Como Entero;\nFinInterfaz\nClase Lector Realiza Legible\nMetodo obtener() Como Entero\nRetornar 1;\nFinMetodo\nFinClase\nAlgoritmo Principal\nFinAlgoritmo\n", "profile": "es"}}, "espera": {"aplicacion": {"boxes": [{"name": "Legible", "stereotype": "«interface»", "rows": ["+ obtener(): Entero"]}, {"name": "Lector", "rows": ["+ obtener(): Entero"]}], "relations": [{"kind": "realization", "from": "Lector", "to": "Legible", "valid": true, "diagnostics": []}]}}}
```

```caso
{"id": "C19", "regla": "R7", "perfiles": ["en"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "class_diagram", "input": {"program": "interface Readable\nmethod readValue() as integer;\nendInterface\nclass Reader implements Readable\nmethod readValue() as integer\nreturn 7;\nendMethod\nendClass\nclass Writer implements Readable\nmethod readValue() as integer\nreturn 8;\nendMethod\nendClass\nalgorithm Main\nendAlgorithm\n", "profile": "en"}}, "espera": {"aplicacion": {"relations": [{"kind": "realization", "from": "Reader", "to": "Readable", "valid": true}, {"kind": "realization", "from": "Writer", "to": "Readable", "valid": true}]}}}
```

```caso
{"id": "C20", "regla": "R7", "perfiles": ["en"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "class_diagram", "input": {"program": "interface Readable\nmethod readValue() as integer;\nendInterface\nclass Reader implements Readable\nmethod readValue() as integer\nreturn 7;\nendMethod\nendClass\nclass Child extends Reader\nendClass\nalgorithm Main\nendAlgorithm\n", "profile": "en"}}, "espera": {"aplicacion": {"relations": [{"kind": "generalization", "from": "Child", "to": "Reader", "valid": true}, {"kind": "realization", "from": "Reader", "to": "Readable", "valid": true}]}}}
```

```caso
{"id": "C41", "regla": "R7", "perfiles": ["en"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "class_diagram", "input": {"program": "interface Readable\nmethod readValue() as integer;\nendInterface\nclass Base\nmethod readValue() as integer\nreturn 1;\nendMethod\nendClass\nclass Child extends Base implements Readable\nendClass\nalgorithm Main\nendAlgorithm\n", "profile": "en"}}, "espera": {"aplicacion": {"relations": [{"kind": "generalization", "from": "Child", "to": "Base", "valid": true}, {"kind": "realization", "from": "Child", "to": "Readable", "valid": true, "diagnostics": []}]}}}
```

```regla
{
  "id": "R8",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Toda realización inválida, explícita o heredada, se representa con una relación inválida, los códigos del diagnóstico del análisis y el nodo de origen correspondiente. La realización heredada por incompatibleMethodOverride usa como origen el nodo del método sobrescrito de forma incompatible. Su relación es discontinua, usa color de error y guiones cortos, y lleva una etiqueta que empieza por ! e incluye el código; la semántica accesible anuncia que es inválida y sus códigos. Un contrato desconocido no crea relación ni caja: aparece como una fila de incidencia en la clase que cita la referencia escrita y el diagnóstico, y conserva el nodo de esa referencia. La invalidez no depende solo del color.",
  "verificacion": [
    "C21",
    "C22",
    "C42",
    "C44",
    "C45",
    "C47"
  ]
}
```

```caso
{"id":"C21","regla":"R8","perfiles":["en"],"origen":"derivado","operacion":"app","aplicacion":{"scenario":"class_diagram","input":{"program":"interface Needed\nmethod run() as integer;\nendInterface\nclass Broken implements Needed\nendClass\nalgorithm Main\nendAlgorithm\n","profile":"en"}},"espera":{"aplicacion":{"relations":[{"kind":"realization","from":"Broken","to":"Needed","valid":false,"diagnostics":["interfaceMethodMissing"],"has_origin":true}],"invalid_accessible_relations":[{"kind":"realization","from":"Broken","to":"Needed","diagnostics":["interfaceMethodMissing"],"has_source_range":true,"hit_target_width":24.0,"hit_target_height":24.0}]}}}
```

```caso
{"id": "C22", "regla": "R8", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "class_diagram", "input": {"program": "Clase Faltante Realiza Ausente\nFinClase\nAlgoritmo Principal\nFinAlgoritmo\n", "profile": "es"}}, "espera": {"aplicacion": {"boxes": [{"name": "Faltante", "rows": ["! Ausente (unknownInterface)"]}], "relations": []}}}
```

```caso
{"id":"C42","regla":"R8","perfiles":["es"],"origen":"derivado","operacion":"app","aplicacion":{"scenario":"class_diagram","input":{"program":"Interfaz Legible\nMetodo obtener() Como Entero;\nFinInterfaz\nClase Lector Realiza Legible\nMetodo obtener(extra Como Entero) Como Entero\nRetornar extra;\nFinMetodo\nFinClase\nAlgoritmo Principal\nFinAlgoritmo\n","profile":"es"}},"espera":{"aplicacion":{"relations":[{"kind":"realization","from":"Lector","to":"Legible","valid":false,"diagnostics":["interfaceMethodSignatureMismatch"],"has_origin":true}],"invalid_accessible_relations":[{"kind":"realization","from":"Lector","to":"Legible","diagnostics":["interfaceMethodSignatureMismatch"],"has_source_range":true,"hit_target_width":24.0,"hit_target_height":24.0}]}}}
```

```caso
{"id":"C43","regla":"R5","perfiles":["es","en"],"programas":{"es":"Interfaz Readable\nMetodo readValue() Como Entero;\nFinInterfaz\nClase Reader Realiza Readable\nMetodo readValue() Como Entero\nRetornar 7;\nFinMetodo\nFinClase\nClase Child Hereda De Reader\nMetodo readValue(extra Como Entero) Como Entero\nRetornar extra;\nFinMetodo\nFinClase\nAlgoritmo Main\nFinAlgoritmo\n","en":"interface Readable\nmethod readValue() as integer;\nendInterface\nclass Reader implements Readable\nmethod readValue() as integer\nreturn 7;\nendMethod\nendClass\nclass Child extends Reader\nmethod readValue(extra as integer) as integer\nreturn extra;\nendMethod\nendClass\nalgorithm Main\nendAlgorithm\n"},"origen":"derivado","operacion":"analyze","espera":{"arbol":"presente","vista_programa":{"realizations_include":[{"origin":"inherited","status":"invalid","diagnostics":["incompatibleMethodOverride"]}],"nodes_include":[{"syntax_kind":"method_member","method_signature_span":{"start":{"line":10},"end":{"line":10}}}],"relations_same_revision_and_source":true}}}
```

```caso
{"id":"C44","regla":"R8","perfiles":["es"],"origen":"derivado","operacion":"app","aplicacion":{"scenario":"class_diagram","input":{"program":"Interfaz Readable\nMetodo readValue() Como Entero;\nFinInterfaz\nClase Reader Realiza Readable\nMetodo readValue() Como Entero\nRetornar 7;\nFinMetodo\nFinClase\nClase Child Hereda De Reader\nMetodo readValue(extra Como Entero) Como Entero\nRetornar extra;\nFinMetodo\nFinClase\nAlgoritmo Main\nFinAlgoritmo\n","profile":"es"}},"espera":{"aplicacion":{"relations":[{"kind":"generalization","from":"Child","to":"Reader","valid":true},{"kind":"realization","from":"Reader","to":"Readable","valid":true},{"kind":"realization","from":"Child","to":"Readable","valid":false,"diagnostics":["incompatibleMethodOverride"],"has_origin":true}],"invalid_accessible_relations":[{"kind":"realization","from":"Child","to":"Readable","diagnostics":["incompatibleMethodOverride"],"has_source_range":true,"hit_target_width":24.0,"hit_target_height":24.0}]}}}
```

```caso
{"id":"C45","regla":"R8","perfiles":["en"],"origen":"derivado","operacion":"app","aplicacion":{"scenario":"class_diagram","input":{"program":"interface Readable\nmethod readValue() as integer;\nendInterface\nclass Reader implements Readable\nmethod readValue() as integer\nreturn 7;\nendMethod\nendClass\nclass Child extends Reader\nmethod readValue(extra as integer) as integer\nreturn extra;\nendMethod\nendClass\nalgorithm Main\nendAlgorithm\n","profile":"en"}},"espera":{"aplicacion":{"relations":[{"kind":"generalization","from":"Child","to":"Reader","valid":true},{"kind":"realization","from":"Reader","to":"Readable","valid":true},{"kind":"realization","from":"Child","to":"Readable","valid":false,"diagnostics":["incompatibleMethodOverride"],"has_origin":true}],"invalid_accessible_relations":[{"kind":"realization","from":"Child","to":"Readable","diagnostics":["incompatibleMethodOverride"],"has_source_range":true,"hit_target_width":24.0,"hit_target_height":24.0}]}}}
```

```caso
{"id":"C46","regla":"R7","perfiles":["en"],"origen":"derivado","operacion":"app","aplicacion":{"scenario":"class_diagram","input":{"program":"interface Readable\nmethod readValue() as integer;\nendInterface\nclass Reader implements Readable\nmethod readValue() as integer\nreturn 7;\nendMethod\nendClass\nclass Child extends Reader\nmethod readValue() as integer\nreturn 8;\nendMethod\nendClass\nalgorithm Main\nendAlgorithm\n","profile":"en"}},"espera":{"aplicacion":{"relations":[{"kind":"generalization","from":"Child","to":"Reader","valid":true},{"kind":"realization","from":"Reader","to":"Readable","valid":true}]}}}
```

```caso
{"id":"C47","regla":"R8","perfiles":["en"],"origen":"derivado","operacion":"app","aplicacion":{"scenario":"class_diagram","input":{"program":"interface Readable\nmethod readValue() as integer;\nendInterface\nclass Reader implements Readable\nmethod readValue() as integer\nreturn 7;\nendMethod\nendClass\nclass Child extends Reader\nmethod readValue() as integer\nreturn 8;\nendMethod\nendClass\nclass Grandchild extends Child\nmethod readValue(extra as integer) as integer\nreturn extra;\nendMethod\nendClass\nalgorithm Main\nendAlgorithm\n","profile":"en"}},"espera":{"aplicacion":{"relations":[{"kind":"generalization","from":"Child","to":"Reader","valid":true},{"kind":"generalization","from":"Grandchild","to":"Child","valid":true},{"kind":"realization","from":"Reader","to":"Readable","valid":true},{"kind":"realization","from":"Grandchild","to":"Readable","valid":false,"diagnostics":["incompatibleMethodOverride"],"has_origin":true}],"invalid_accessible_relations":[{"kind":"realization","from":"Grandchild","to":"Readable","diagnostics":["incompatibleMethodOverride"],"has_source_range":true,"hit_target_width":24.0,"hit_target_height":24.0}]}}}
```

```regla
{
  "id": "R9",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una restricción de parámetro genérico sobre un contrato conocido se representa como una relación de uso, distinta de la realización, desde una caja «subprogram» del subprograma que la declara hacia el contrato, etiquetada con el nombre del parámetro. No se crean valores de interfaz.",
  "verificacion": [
    "C23"
  ]
}
```

```caso
{"id": "C23", "regla": "R9", "perfiles": ["en"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "class_diagram", "input": {"program": "interface Readable\nmethod readValue() as integer;\nendInterface\nsubroutine readOnce<T: Readable>(value as T) as integer\nreturn value.readValue();\nendSubroutine\nalgorithm Main\nendAlgorithm\n", "profile": "en"}}, "espera": {"aplicacion": {"boxes": [{"name": "Readable", "stereotype": "«interface»", "rows": ["+ readValue(): integer"]}, {"name": "readOnce", "stereotype": "«subprogram»", "rows": ["+ readOnce<T: Readable>(value: T): integer"]}], "relations": [{"kind": "usage", "from": "readOnce", "to": "Readable", "valid": true, "label": "T"}]}}}
```

## Salidas, limpiezas y su representación en ordinograma y estructograma

```regla
{
  "id": "R10",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La vista expone en cada nodo break_statement, return_statement y propagation el atributo control_exit con kind break, return o propagation; target_node_id del bucle interior que Salir termina o de la unidad o función literal que Retornar y Propagar abandonan, o null si la salida no tiene destino válido; y cleanups, los node_id de las sentencias Diferir ya registradas en los ámbitos abandonados en el orden en que se ejecutan, del ámbito interior al exterior y en orden inverso de registro dentro de cada uno. Cada lista de sentencias que registra limpiezas expone normal_cleanups en el orden de su fin normal, y cada defer_statement expone cleanup_scope_node_id. Una salida dentro de un cuerpo diferido no tiene destino ni limpiezas. Los datos son estáticos y no evalúan expresiones.",
  "verificacion": [
    "C24",
    "C25"
  ]
}
```

```caso
{"id": "C24", "regla": "R10", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "control_flow", "input": {"program": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nDiferir\nEscribir 0;\nFinDiferir\nPara Cada value En values Hacer\nDiferir\nEscribir value;\nFinDiferir\nSi value = 2 Entonces\nSalir;\nFinSi\nFinPara\nFinAlgoritmo\n", "profile": "es", "notation": "flowchart", "unit": "Main"}}, "espera": {"aplicacion": {"exits": [{"kind": "break", "target": "for_each_loop", "cleanup_lines": [7]}], "normal_cleanups": [{"lines": [3]}, {"lines": [7]}]}}}
```

```caso
{"id": "C25", "regla": "R10", "perfiles": ["en"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "control_flow", "input": {"program": "subroutine First() as optional<integer>\nreturn none;\nendSubroutine\nsubroutine Second() as optional<string>\ndefer\nwrite 0;\nendDefer\ndefine value as integer <- propagate First();\nreturn some(\"done\");\nendSubroutine\nalgorithm Main\nendAlgorithm\n", "profile": "en", "notation": "flowchart", "unit": "Second"}}, "espera": {"aplicacion": {"exits": [{"kind": "return", "target": "subroutine", "cleanup_lines": []}, {"kind": "propagation", "target": "subroutine", "cleanup_lines": [5]}, {"kind": "return", "target": "subroutine", "cleanup_lines": [5]}], "normal_cleanups": [{"lines": [5]}]}}}
```

```regla
{
  "id": "R11",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Ordinograma y estructograma distinguen cada salida. La salida normal sigue el flujo. Salir lleva por una arista de ruptura a un conector rotulado con el fin del bucle que termina, y ese bucle repite el mismo conector tras su salida normal; en el estructograma es una celda de salida. Retornar es un terminal o una celda de salida. Propagar añade a su sentencia una arista lateral hacia un terminal de fallo propagado; en el estructograma la celda de su sentencia lo anota. Diferir se dibuja como registro con su cuerpo al costado, unido por una arista de registro y sin flujo que lo atraviese; en el estructograma, como bloque con cabecera. Las limpiezas se rotulan por las líneas de sus sentencias Diferir en el orden de control_exit en cada salida anticipada y de normal_cleanups en un paso al final de su ámbito cuando ese final es alcanzable. El dibujo no evalúa las limpiezas.",
  "verificacion": [
    "C26",
    "C27",
    "C28"
  ]
}
```

```caso
{"id": "C26", "regla": "R11", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "control_flow", "input": {"program": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nDiferir\nEscribir 0;\nFinDiferir\nPara Cada value En values Hacer\nDiferir\nEscribir value;\nFinDiferir\nSi value = 2 Entonces\nSalir;\nFinSi\nFinPara\nFinAlgoritmo\n", "profile": "es", "notation": "flowchart", "unit": "Main"}}, "espera": {"aplicacion": {"nodes": [{"shape": "startEnd", "text": "Inicio"}, {"shape": "process", "text": "Definir values Como Vector<Entero> <- Vector()"}, {"shape": "preparation", "text": "Diferir"}, {"shape": "inputOutput", "text": "Escribir 0"}, {"shape": "preparation", "text": "Para Cada value En values Hacer"}, {"shape": "preparation", "text": "Diferir"}, {"shape": "inputOutput", "text": "Escribir value"}, {"shape": "decision", "text": "¿value = 2?"}, {"shape": "process", "text": "Salir — limpiezas: línea 7"}, {"shape": "exitConnector", "text": "Fin del bucle (línea 6)"}, {"shape": "subprogram", "text": "Limpiezas al terminar: línea 7"}, {"shape": "exitConnector", "text": "Fin del bucle (línea 6)"}, {"shape": "subprogram", "text": "Limpiezas al terminar: línea 3"}, {"shape": "startEnd", "text": "Fin"}], "unsupported": [], "edges": [{"kind": "cleanupRegistration", "from": "Diferir", "to": "Escribir 0"}, {"kind": "cleanupRegistration", "from": "Diferir", "to": "Escribir value"}, {"kind": "breakExit", "from": "Salir — limpiezas: línea 7", "to": "Fin del bucle (línea 6)"}]}}}
```

```caso
{"id": "C27", "regla": "R11", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "control_flow", "input": {"program": "SubProceso First() Como Opcional<Entero>\nRetornar Nada;\nFinSubProceso\nSubProceso Second() Como Opcional<Cadena>\nDiferir\nEscribir 0;\nFinDiferir\nDefinir v Como Entero <- Propagar First();\nRetornar Algo(\"listo\");\nFinSubProceso\nAlgoritmo Main\nFinAlgoritmo\n", "profile": "es", "notation": "flowchart", "unit": "Second"}}, "espera": {"aplicacion": {"nodes": [{"shape": "startEnd", "text": "Inicio"}, {"shape": "preparation", "text": "Diferir"}, {"shape": "inputOutput", "text": "Escribir 0"}, {"shape": "process", "text": "Definir v Como Entero <- Propagar First()"}, {"shape": "startEnd", "text": "Propaga el fallo — limpiezas: línea 5"}, {"shape": "startEnd", "text": "Retornar Algo(\"listo\") — limpiezas: línea 5"}, {"shape": "startEnd", "text": "Fin"}], "unsupported": [], "edges": [{"kind": "cleanupRegistration", "from": "Diferir", "to": "Escribir 0"}, {"kind": "propagationExit", "from": "Definir v Como Entero <- Propagar First()", "to": "Propaga el fallo — limpiezas: línea 5"}]}}}
```

```caso
{"id": "C28", "regla": "R11", "perfiles": ["en"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "control_flow", "input": {"program": "algorithm Main\ndefine values as vector<integer> <- vector();\nfor each value in values do\ndefer\nwrite value;\nendDefer\nbreak;\nendFor\nendAlgorithm\n", "profile": "en", "notation": "structogram", "unit": "Main"}}, "espera": {"aplicacion": {"nodes": [{"shape": "cellProcess", "text": "define values as vector<integer> <- vector()"}, {"shape": "cellLoopHeader", "text": "for each value in values do"}, {"shape": "cellLoopHeader", "text": "defer"}, {"shape": "cellProcess", "text": "write value"}, {"shape": "cellExit", "text": "break — cleanups: line 4"}], "unsupported": []}}}
```

## Registros, enumerados y parámetros de tipo en el diagrama de clases

```regla
{
  "id": "R12",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El diagrama de clases representa cada registro como una caja «record» con una fila «nombre: tipo» por campo declarado, cada enumerado como una caja «enumeration» con una fila por miembro en orden de fuente, cada variante declarada como una caja «variant» con una fila por alternativa en orden de fuente, escrita nombre o nombre(campo: tipo, …), y cada subprograma con parámetros de tipo como una caja «subprogram» con su firma, aunque sus parámetros no tengan restricción. La cabecera de una clase, interfaz, registro o variante con parámetros de tipo añade al nombre la lista escrita entre < y >, con cada restricción como parámetro: contrato. Un campo de clase de tipo registro es una fila «nombre: tipo» sin relación de asociación. La herencia de una base genérica y la realización de una interfaz genérica se rotulan con los argumentos de tipo escritos. Registros, enumerados y variantes se listan en orden de fuente después de clases e interfaces. Cada fila conserva el nodo de su declaración para navegar al rango exacto. No se crean relaciones, instancias ni pasos ejecutables para registros, enumerados ni variantes.",
  "verificacion": [
    "C29",
    "C30",
    "C61",
    "C62"
  ]
}
```

```caso
{"id": "C29", "regla": "R12", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "class_diagram", "input": {"program": "Enumerado Color\nRojo, Verde\nFinEnumerado\nRegistro Punto\nDefinir x, z Como Entero;\nFinRegistro\nSubProceso identity<T>(value Como T) Como T\nRetornar value;\nFinSubProceso\nAlgoritmo Main\nFinAlgoritmo\n", "profile": "es"}}, "espera": {"aplicacion": {"boxes": [{"name": "Color", "stereotype": "«enumeration»", "rows": ["Rojo", "Verde"]}, {"name": "Punto", "stereotype": "«record»", "rows": ["+ x: Entero", "+ z: Entero"]}, {"name": "identity", "stereotype": "«subprogram»", "rows": ["+ identity<T>(value: T): T"]}], "relations": []}}}
```

```caso
{"id": "C30", "regla": "R12", "perfiles": ["en"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "class_diagram", "input": {"program": "record Pair\ndefine left as integer;\ndefine right as string;\nendRecord\nenum Level\nlow, high\nendEnum\nalgorithm Main\nendAlgorithm\n", "profile": "en"}}, "espera": {"aplicacion": {"boxes": [{"name": "Pair", "stereotype": "«record»", "rows": ["+ left: integer", "+ right: string"]}, {"name": "Level", "stereotype": "«enumeration»", "rows": ["low", "high"]}], "relations": []}}}
```

```caso
{"id": "C61", "regla": "R12", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "class_diagram", "input": {"program": "Registro Punto\nDefinir x Como Entero;\nFinRegistro\nClase Base<T>\nDefinir dato Como T;\nDefinir origen Como Punto;\nFinClase\nClase Hija<T> Hereda De Base<T>\nMetodo obtener() Como T\nRetornar Este.dato;\nFinMetodo\nFinClase\nVariante Forma\nAlternativa Circulo(radio Como Entero)\nAlternativa Vacia\nFinVariante\nAlgoritmo Main\nFinAlgoritmo\n", "profile": "es"}}, "espera": {"aplicacion": {"boxes": [{"name": "Base<T>", "stereotype": null, "rows": ["+ dato: T", "+ origen: Punto"]}, {"name": "Punto", "stereotype": "«record»", "rows": ["+ x: Entero"]}, {"name": "Forma", "stereotype": "«variant»", "rows": ["Circulo(radio: Entero)", "Vacia"]}, {"name": "Hija<T>", "stereotype": null, "rows": ["+ obtener(): T"]}], "relations": [{"kind": "generalization", "from": "Hija<T>", "to": "Base<T>", "valid": true, "label": "<T>"}]}}}
```

```caso
{"id": "C62", "regla": "R12", "perfiles": ["en"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "class_diagram", "input": {"program": "interface Printable\nmethod show() as string;\nendInterface\ninterface Measurable<T>\nmethod measure() as T;\nendInterface\nclass Fixed<T: Printable> implements Measurable<T>\ndefine datum as T;\nmethod measure() as T\nreturn this.datum;\nendMethod\nendClass\nalgorithm Main\nendAlgorithm\n", "profile": "en"}}, "espera": {"aplicacion": {"boxes": [{"name": "Printable", "stereotype": "«interface»", "rows": ["+ show(): string"]}, {"name": "Measurable<T>", "stereotype": "«interface»", "rows": ["+ measure(): T"]}, {"name": "Fixed<T: Printable>", "stereotype": null, "rows": ["+ datum: T", "+ measure(): T"]}], "relations": [{"kind": "realization", "from": "Fixed<T: Printable>", "to": "Measurable<T>", "valid": true, "label": "<T>"}]}}}
```

## Cobertura sintáctica de las vistas del consumidor

```regla
{
  "id": "R13",
  "fuerza": "DEBE",
  "clase": "estructural",
  "texto": "El consumidor que dibuja la vista declara como datos una matriz de cobertura con una fila por construcción, su papel público, sus formas, el anclaje de regla con versión y una celda por vista: ordinograma, estructograma, estructura, foco, estado y ayuda. Cada celda es exacta, extensión declarada o no aplicable, y las dos últimas exigen motivo; una ayuda exacta nombra una ficha del catálogo de ayuda. Su verificador rechaza una forma pública sin fila con COV-MISSING-ROW, una forma desconocida con COV-STALE-ROW, una fila o forma repetida con COV-DUPLICATE, un papel distinto del público con COV-ROLE, una celda sin motivo con COV-NO-REASON, una construcción ejecutable no aplicable en ordinograma o estructograma con COV-HIDDEN-CONTROL, una ayuda exacta sin ficha existente con COV-HELP, un anclaje inexistente con COV-RULE y una prueba inexistente con COV-EVIDENCE. La matriz vigente frente al inventario vigente no produce rechazos.",
  "verificacion": [
    "C31",
    "C32",
    "C33",
    "C34",
    "C35",
    "C36",
    "C37",
    "C38"
  ]
}
```

```caso
{"id": "C31", "regla": "R13", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "syntax_coverage", "input": {"mutation": "none"}}, "espera": {"aplicacion": {"codes": []}}}
```

```caso
{"id": "C32", "regla": "R13", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "syntax_coverage", "input": {"mutation": "remove_row"}}, "espera": {"aplicacion": {"codes": ["COV-MISSING-ROW"]}}}
```

```caso
{"id": "C33", "regla": "R13", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "syntax_coverage", "input": {"mutation": "unknown_form"}}, "espera": {"aplicacion": {"codes": ["COV-STALE-ROW"]}}}
```

```caso
{"id": "C34", "regla": "R13", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "syntax_coverage", "input": {"mutation": "duplicate_row"}}, "espera": {"aplicacion": {"codes": ["COV-DUPLICATE"]}}}
```

```caso
{"id": "C35", "regla": "R13", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "syntax_coverage", "input": {"mutation": "change_role"}}, "espera": {"aplicacion": {"codes": ["COV-ROLE"]}}}
```

```caso
{"id": "C36", "regla": "R13", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "syntax_coverage", "input": {"mutation": "drop_reason"}}, "espera": {"aplicacion": {"codes": ["COV-NO-REASON"]}}}
```

```caso
{"id": "C37", "regla": "R13", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "syntax_coverage", "input": {"mutation": "missing_help"}}, "espera": {"aplicacion": {"codes": ["COV-HELP"]}}}
```

```caso
{"id": "C38", "regla": "R13", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "syntax_coverage", "input": {"mutation": "hide_control"}}, "espera": {"aplicacion": {"codes": ["COV-HIDDEN-CONTROL"]}}}
```

```regla
{
  "id": "R14",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cuando ordinograma o estructograma no pueden representar fielmente una forma de un programa, el consumidor no entrega ningún diagrama de ese programa como válido: devuelve un resultado no soportado que nombra las formas por su syntax_kind público y la superficie muestra un mensaje localizado que las enumera en lugar del lienzo. Propagar dentro de la cabecera de un control es una de esas formas.",
  "verificacion": [
    "C39",
    "C40"
  ]
}
```

```caso
{"id": "C39", "regla": "R14", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "control_flow", "input": {"program": "SubProceso First() Como Opcional<Entero>\nRetornar Nada;\nFinSubProceso\nSubProceso Second() Como Opcional<Entero>\nSi Propagar First() > 0 Entonces\nEscribir 1;\nFinSi\nRetornar Algo(1);\nFinSubProceso\nAlgoritmo Main\nFinAlgoritmo\n", "profile": "es", "notation": "flowchart", "unit": "Second"}}, "espera": {"aplicacion": {"nodes": [], "unsupported": ["propagation"], "edges": []}}}
```

```caso
{"id": "C40", "regla": "R14", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "control_flow", "input": {"program": "SubProceso First() Como Opcional<Entero>\nRetornar Nada;\nFinSubProceso\nSubProceso Second() Como Opcional<Entero>\nSi Propagar First() > 0 Entonces\nEscribir 1;\nFinSi\nRetornar Algo(1);\nFinSubProceso\nAlgoritmo Main\nFinAlgoritmo\n", "profile": "es", "notation": "structogram", "unit": "Second"}}, "espera": {"aplicacion": {"nodes": [], "unsupported": ["propagation"]}}}
```

```regla
{
  "id": "R15",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un documento que se analiza solo no enlaza dependencias: cada Importar y Exportar produce moduleSyntaxOutsideProject y ninguna de las dos lee disco, red ni paquetes. Cuando ese es el único error del documento, program_view conserva las demás unidades y expone dependencies, con una fila por directiva en orden de fuente que contiene dependency_id estable para la revisión y la fuente, kind import o export, visibility local para Importar y exported para Exportar, path con los segmentos de la ruta tal como están escritos, alias o null, status unlinked, diagnostic con el código moduleSyntaxOutsideProject y span exacto de la directiva. La vista no crea nodos para los segmentos de la ruta. Una ruta vacía, incompleta, con escape o absoluta es un error sintáctico adicional: no hay vista ni filas de dependencia. El texto del documento no cambia.",
  "verificacion": [
    "C48",
    "C49",
    "C50",
    "C51"
  ]
}
```

```regla
{
  "id": "R16",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El consumidor muestra cada dependencia sin enlazar con su ruta, alias, tipo y estado, y al seleccionarla navega al span exacto de su directiva sin modificar el texto. Mientras exista una dependencia sin enlazar la ejecución y la exportación permanecen bloqueadas y no se presenta ningún proyecto como resuelto. Construir las vistas, consultar ayuda o exportar un documento con dependencias no invoca ninguna operación distinta de analizar, leer la vista y liberar.",
  "verificacion": [
    "C48",
    "C51",
    "C52"
  ]
}
```

```caso
{"id": "C48", "regla": "R15", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "dependencies", "input": {"program": "Importar geo.Punto Como P;\nExportar geo.formas.Circulo;\nAlgoritmo Main\nEscribir 1;\nFinAlgoritmo\n", "profile": "es"}}, "espera": {"aplicacion": {"structure": true, "dependencies": [{"kind": "importation", "path": ["geo", "Punto"], "alias": "P", "status": "unlinked", "diagnostic": "moduleSyntaxOutsideProject", "text": "Importar geo.Punto Como P;"}, {"kind": "exportation", "path": ["geo", "formas", "Circulo"], "alias": null, "status": "unlinked", "diagnostic": "moduleSyntaxOutsideProject", "text": "Exportar geo.formas.Circulo;"}], "units": ["Main"], "execution_started": false, "export_available": false, "operations_beyond_static": []}}}
```

```caso
{"id": "C49", "regla": "R15", "perfiles": ["en"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "dependencies", "input": {"program": "import geo.Point as P;\nexport geo.shapes.Circle;\nalgorithm Main\nwrite 1;\nendAlgorithm\n", "profile": "en"}}, "espera": {"aplicacion": {"structure": true, "dependencies": [{"kind": "importation", "path": ["geo", "Point"], "alias": "P", "status": "unlinked", "diagnostic": "moduleSyntaxOutsideProject", "text": "import geo.Point as P;"}, {"kind": "exportation", "path": ["geo", "shapes", "Circle"], "alias": null, "status": "unlinked", "diagnostic": "moduleSyntaxOutsideProject", "text": "export geo.shapes.Circle;"}], "units": ["Main"], "execution_started": false, "export_available": false, "operations_beyond_static": []}}}
```

```caso
{"id": "C50", "regla": "R15", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "dependencies", "input": {"program": "Importar geo.;\nAlgoritmo Main\nFinAlgoritmo\n", "profile": "es"}}, "espera": {"aplicacion": {"structure": false, "dependencies": [], "units": [], "execution_started": false, "export_available": false, "operations_beyond_static": []}}}
```

```caso
{"id": "C51", "regla": "R15", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "dependencies", "input": {"program": "Importar pseudolearn_app.lib.main;\nAlgoritmo Main\nFinAlgoritmo\n", "profile": "es"}}, "espera": {"aplicacion": {"structure": true, "dependencies": [{"kind": "importation", "path": ["pseudolearn_app", "lib", "main"], "alias": null, "status": "unlinked", "diagnostic": "moduleSyntaxOutsideProject", "text": "Importar pseudolearn_app.lib.main;"}], "units": ["Main"], "execution_started": false, "export_available": false, "operations_beyond_static": []}}}
```

```caso
{"id": "C52", "regla": "R16", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "dependencies", "input": {"program": "Algoritmo Main\nEscribir 1;\nFinAlgoritmo\n", "profile": "es"}}, "espera": {"aplicacion": {"structure": true, "dependencies": [], "units": ["Main"], "execution_started": true, "export_available": true, "operations_beyond_static": []}}}
```

```regla
{
  "id": "R17",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El consumidor ofrece código equivalente para un destino solo si cada construcción del programa pertenece al subconjunto comprobado de ese destino, es decir, el que una prueba diferencial ejecuta en el motor y en la traducción con la misma salida. Si una construcción queda fuera, sea una unidad que ningún emisor representa, una sentencia sin traducción, una lectura cuyo destino no tiene conversión comprobada (input:<tipo>), una incorporada, un operador, un literal, un tipo o una salida booleana sin equivalente comprobado, el resultado para ese destino es no disponible: no entrega ningún programa parcial y nombra cada construcción por su identidad pública con el rango exacto de su origen. Un error de análisis sigue siendo un error de análisis. La superficie muestra un mensaje localizado con las construcciones y la línea de la primera. La disponibilidad se decide por destino y las traducciones no se compilan ni ejecutan en el producto.",
  "verificacion": [
    "C53",
    "C54",
    "C55",
    "C56",
    "C57",
    "C60"
  ]
}
```

```regla
{
  "id": "R18",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada revisión de la fuente reemplaza el resultado de exportación anterior: si la revisión nueva no está disponible o tiene un error de análisis no permanece visible el código de la revisión anterior ni sus líneas de foco.",
  "verificacion": [
    "C58",
    "C59"
  ]
}
```

```caso
{"id": "C53", "regla": "R17", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "export_support", "input": {"program": "Proceso P\n  Definir x Como Logico <- Falso;\n  Escribir \"antes\";\n  Leer x;\n  Escribir \"despues\";\nFinProceso\n", "target": "python", "profile": "es"}}, "espera": {"aplicacion": {"status": "unavailable", "constructs": ["input:boolean"], "first_line": 4, "code_visible": false, "focused_lines": 0, "ready": false}}}
```

```caso
{"id": "C54", "regla": "R17", "perfiles": ["en"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "export_support", "input": {"program": "algorithm Main\n  define x as boolean <- false;\n  read x;\nendAlgorithm\n", "target": "python", "profile": "en"}}, "espera": {"aplicacion": {"status": "unavailable", "constructs": ["input:boolean"], "first_line": 3, "code_visible": false, "focused_lines": 0, "ready": false}}}
```

```caso
{"id": "C55", "regla": "R17", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "export_support", "input": {"program": "Proceso P\n  Escribir 2 ^ 3;\nFinProceso\n", "target": "rust", "profile": "es"}}, "espera": {"aplicacion": {"status": "unavailable", "constructs": ["operator:power"], "first_line": 2, "code_visible": false, "focused_lines": 0, "ready": false}}}
```

```caso
{"id": "C56", "regla": "R17", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "export_support", "input": {"program": "Proceso P\n  Segun 1 Hacer\n    1:\n      Escribir \"uno\";\n  FinSegun\nFinProceso\n", "target": "python", "profile": "es"}}, "espera": {"aplicacion": {"status": "unavailable", "constructs": ["labels", "switch"], "first_line": 2, "code_visible": false, "focused_lines": 0, "ready": false}}}
```

```caso
{"id": "C57", "regla": "R17", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "export_support", "input": {"program": "Funcion Doble(x Como Entero) Como Entero\n  Retornar x * 2;\nFinFuncion\nProceso P\n  Escribir Doble(2);\nFinProceso\n", "target": "python", "profile": "es"}}, "espera": {"aplicacion": {"status": "ready", "constructs": [], "first_line": null, "code_visible": true, "focused_lines": 0, "ready": true}}}
```

```caso
{"id": "C58", "regla": "R18", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "export_support", "input": {"previous": "Proceso P\n  Escribir 1;\nFinProceso\n", "program": "Proceso P\n  Definir x Como Logico <- Falso;\n  Leer x;\nFinProceso\n", "target": "python", "profile": "es"}}, "espera": {"aplicacion": {"status": "unavailable", "constructs": ["input:boolean"], "first_line": 3, "code_visible": false, "focused_lines": 0, "ready": false}}}
```

```caso
{"id": "C59", "regla": "R18", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "export_support", "input": {"previous": "Proceso P\n  Escribir 1;\nFinProceso\n", "program": "Proceso P\n  Escribir ;\n", "target": "python", "profile": "es"}}, "espera": {"aplicacion": {"status": "analysisError", "constructs": [], "first_line": null, "code_visible": false, "focused_lines": 0, "ready": false}}}
```

```caso
{"id": "C60", "regla": "R17", "perfiles": ["es"], "origen": "derivado", "operacion": "app", "aplicacion": {"scenario": "export_support", "input": {"program": "Proceso P\n  Escribir 3 > 2;\nFinProceso\n", "target": "python", "profile": "es"}}, "espera": {"aplicacion": {"status": "unavailable", "constructs": ["boolean_output"], "first_line": 2, "code_visible": false, "focused_lines": 0, "ready": false}}}
```
