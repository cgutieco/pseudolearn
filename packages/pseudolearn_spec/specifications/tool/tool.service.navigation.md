---
{
  "formato": "see/1",
  "id": "TOOL.SERVICE.NAVIGATION",
  "titulo": "Navegación de código y referencias",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "service"
  ],
  "resumen": "Definición, referencias, resaltado y rename sobre identidades semánticas de documento y proyecto.",
  "depende_de": [
    {
      "id": "LANG.DECL.VARIABLE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.SUBPROGRAM.CALL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.CLASS.DECLARATION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.SERVICE.INCREMENTAL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Code navigation service",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Navegación de código y referencias

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Dada una posición de cursor sobre un uso o declaración de variable, constante, parámetro, subproceso, función, clase, campo o método, el servicio devuelve el rango exacto de su declaración en el alcance correspondiente. En un proyecto, la identidad atraviesa archivos y respeta módulos, visibilidad, alias y reexportaciones.",
  "verificacion": [
    "C1",
    "C3"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Dada una posición sobre un símbolo, devuelve en orden de aparición todos los rangos de los documentos del proyecto que referencian ese mismo símbolo semántico, sin confundirlo con símbolos homónimos de otros alcances. Incluye archivos cerrados del snapshot y nunca expone referencias a miembros privados no visibles.",
  "verificacion": [
    "C2"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El resaltado de documento devuelve las ocurrencias del símbolo bajo el cursor clasificando cada una como lectura o escritura/declaración.",
  "verificacion": [
    "C4"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "prepareRename identifica solo el lexema del símbolo y devuelve su rango exacto y placeholder. Antes de rename, el cliente materializa cada fuente cerrada que vaya a editar con su contenido y versión vigentes, y vuelve a calcular prepareRename y referencias sobre esas revisiones sincronizadas. rename acepta únicamente identificadores válidos y no reservados en los perfiles de los archivos afectados, comprueba colisiones semánticas en todos los alcances afectados y compara las revisiones antes de crear ediciones. Una propuesta aceptada contiene exclusivamente textDocument/documentChanges versionados para todos los documentos afectados; una colisión, versión antigua, modificación concurrente o garantía transaccional ausente rechaza la propuesta completa sin mutar fuentes.",
  "verificacion": ["C5", "C6", "C8"]
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
  "operacion": "service",
  "espera": {
    "servicio": {
      "definicion": {
        "start": { "line": 2, "column": 11 },
        "end": { "line": 2, "column": 16 }
      }
    }
  },
  "servicio": {
    "suboperacion": "definition",
    "documento": "Algoritmo Principal\n  Definir total Como Entero;\n  total <- 10;\n  Escribir total;\nFinAlgoritmo\n",
    "posicion": { "line": 4, "column": 13 }
  }
}
```

```caso
{
  "id": "C2",
  "regla": "R2",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "referencias": [
        {
          "start": { "line": 2, "column": 11 },
          "end": { "line": 2, "column": 12 }
        },
        {
          "start": { "line": 3, "column": 3 },
          "end": { "line": 3, "column": 4 }
        }
      ]
    }
  },
  "servicio": {
    "suboperacion": "references",
    "documento": "SubProceso Uno()\n  Definir i Como Entero;\n  i <- 1;\nFinSubProceso\n\nSubProceso Dos()\n  Definir i Como Entero;\n  i <- 2;\nFinSubProceso\n",
    "posicion": { "line": 3, "column": 3 }
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "definicion": {
        "start": { "line": 2, "column": 10 },
        "end": { "line": 2, "column": 15 }
      }
    }
  },
  "servicio": {
    "suboperacion": "definition",
    "documento": "Clase Punto\n  Metodo Mover()\n  FinMetodo\nFinClase\n\nAlgoritmo Principal\n  Definir p Como Punto;\n  p.Mover();\nFinAlgoritmo\n",
    "posicion": { "line": 8, "column": 6 }
  }
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
  "operacion": "service",
  "espera": {
    "servicio": {
      "destacados": [
        {
          "rango": {
            "start": { "line": 2, "column": 3 },
            "end": { "line": 2, "column": 4 }
          },
          "tipo": "write"
        },
        {
          "rango": {
            "start": { "line": 3, "column": 12 },
            "end": { "line": 3, "column": 13 }
          },
          "tipo": "read"
        }
      ]
    }
  },
  "servicio": {
    "suboperacion": "highlight",
    "documento": "Algoritmo Principal\n  x <- 1;\n  Escribir x;\nFinAlgoritmo\n",
    "posicion": { "line": 2, "column": 3 }
  }
}
```

```caso
{
  "id": "C5",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "prepare_range": {
        "start": {"line": 1, "character": 16},
        "end": {"line": 1, "character": 21}
      },
      "rename_edits": 2
    }
  },
  "servicio": {
    "suboperacion": "lsp",
    "mensajes": [
      {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"es","capabilities":{"workspace":{"workspaceEdit":{"documentChanges":true,"failureHandling":"transactional"}}}}},
      {"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///rename-es.pseudo","languageId":"pseudolearn","version":1,"text":"Algoritmo Principal\\nDefinir Mutable total Como Entero <- 0;\\nEscribir total;\\nFinAlgoritmo\\n"}}},
      {"jsonrpc":"2.0","id":2,"method":"textDocument/prepareRename","params":{"textDocument":{"uri":"file:///rename-es.pseudo"},"position":{"line":1,"character":16}}},
      {"jsonrpc":"2.0","id":3,"method":"textDocument/rename","params":{"textDocument":{"uri":"file:///rename-es.pseudo"},"position":{"line":1,"character":16},"newName":"suma"}}
    ],
    "proyeccion": "rename"
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {"servicio":{"rename_rejected":true}},
  "servicio": {"suboperacion":"lsp","mensajes":[{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"es","capabilities":{"workspace":{"workspaceEdit":{"documentChanges":true,"failureHandling":"transactional"}}}}},{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///rename-es.pseudo","languageId":"pseudolearn","version":1,"text":"Algoritmo Principal\\nDefinir Mutable total Como Entero <- 0;\\nEscribir total;\\nFinAlgoritmo\\n"}}},{"jsonrpc":"2.0","id":2,"method":"textDocument/rename","params":{"textDocument":{"uri":"file:///rename-es.pseudo"},"position":{"line":1,"character":16},"newName":"Mientras"}}],"proyeccion":"rename_rejected"}
}
```

```caso
{
  "id": "C7",
  "regla": "R4",
  "perfiles": ["en"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {"servicio":{"prepare_range":{"start":{"line":1,"character":15},"end":{"line":1,"character":20}},"rename_edits":2}},
  "servicio": {"suboperacion":"lsp","mensajes":[{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"en","capabilities":{"workspace":{"workspaceEdit":{"documentChanges":true,"failureHandling":"transactional"}}}}},{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///rename-en.pseudo","languageId":"pseudolearn","version":1,"text":"algorithm Main\\ndefine mutable total as integer <- 0;\\nwrite total;\\nendAlgorithm\\n"}}},{"jsonrpc":"2.0","id":2,"method":"textDocument/prepareRename","params":{"textDocument":{"uri":"file:///rename-en.pseudo"},"position":{"line":1,"character":15}}},{"jsonrpc":"2.0","id":3,"method":"textDocument/rename","params":{"textDocument":{"uri":"file:///rename-en.pseudo"},"position":{"line":1,"character":15},"newName":"sum"}}],"proyeccion":"rename"}
}
```

```caso
{
  "id": "C8",
  "regla": "R4",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {"servicio":{"rename_edits":2,"document_versions":{"file:///app/main.pseudo":3,"file:///geo/vector.pseudo":8}}},
  "servicio": {"suboperacion":"lsp","mensajes":[{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"es","capabilities":{"workspace":{"workspaceEdit":{"documentChanges":true,"failureHandling":"transactional"}}}}},{"jsonrpc":"2.0","method":"pseudolearn/workspaceSnapshot","params":{"project":{"project_id":7,"revision_id":1,"packages":[{"name":"app","root":"app","kind":"application","entries":["app/main"],"dependencies":{"geo":"geo"}},{"name":"geo","root":"geo","kind":"library","entries":[],"dependencies":{}}],"files":[{"path":"app/main","source_id":1,"text":"Importar geo.vector.Double;\\nAlgoritmo Main\\nEscribir Double(2);\\nFinAlgoritmo\\n"},{"path":"geo/vector","source_id":2,"text":"Publico SubProceso Double(value Como Entero) Como Entero\\nRetornar value * 2;\\nFinSubProceso\\n"}]},"uris":{"app/main":"file:///app/main.pseudo","geo/vector":"file:///geo/vector.pseudo"}}},{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///app/main.pseudo","languageId":"pseudolearn","version":3,"text":"Importar geo.vector.Double;\\nAlgoritmo Main\\nEscribir Double(2);\\nFinAlgoritmo\\n"}}},{"jsonrpc":"2.0","id":2,"method":"textDocument/references","params":{"textDocument":{"uri":"file:///app/main.pseudo"},"position":{"line":2,"character":9},"context":{"includeDeclaration":true}}},{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///geo/vector.pseudo","languageId":"pseudolearn","version":8,"text":"Publico SubProceso Double(value Como Entero) Como Entero\\nRetornar value * 2;\\nFinSubProceso\\n"}}},{"jsonrpc":"2.0","id":3,"method":"textDocument/prepareRename","params":{"textDocument":{"uri":"file:///app/main.pseudo"},"position":{"line":2,"character":9}}},{"jsonrpc":"2.0","id":4,"method":"textDocument/references","params":{"textDocument":{"uri":"file:///app/main.pseudo"},"position":{"line":2,"character":9},"context":{"includeDeclaration":true}}},{"jsonrpc":"2.0","id":5,"method":"textDocument/rename","params":{"textDocument":{"uri":"file:///app/main.pseudo"},"position":{"line":2,"character":9},"newName":"Twice"}}],"proyeccion":"transactional_rename_with_materialized_sources"}
}
```
