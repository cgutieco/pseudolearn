---
{
  "formato": "see/1",
  "id": "API.PROGRAM.VIEW",
  "titulo": "Vista pública del programa",
  "dominio": "motor",
  "estado": "experimental",
  "version": "0.4.0",
  "duenos": ["responsable-motor"],
  "sujetos": ["engine", "app"],
  "resumen": "Proyección inmutable y portable para diagramas, emisores y comprobaciones estructurales.",
  "depende_de": [
    {"id": "API.MODEL", "version": ">=0.1.0, <1.0.0", "tipo": "usa"},
    {"id": "API.ANALYZE", "version": ">=0.1.0, <1.0.0", "tipo": "refina"},
    {"id": "API.ERRORS", "version": ">=0.1.0, <1.0.0", "tipo": "usa"},
    {"id": "LANG.SOURCE.POSITION", "version": ">=0.1.0, <1.0.0", "tipo": "usa"},
    {"id": "LANG.SYNTAX.GRAMMAR", "version": ">=0.1.0, <1.0.0", "tipo": "usa"},
    {"id": "LANG.CLASS.INHERITANCE", "version": ">=0.1.0, <1.0.0", "tipo": "usa"}
  ],
  "titulo_en": "Public program view",
  "cambio": {
    "clase": "ampliacion",
    "impacto_usuarios": "Diagramas, emisores y comprobaciones pueden distinguir ramas, seguir cada miembro hasta su nodo y conservar tramos de unidad.",
    "impacto_implementaciones": "Cada relación de hijo declara su papel; los miembros y parámetros exponen tipo y dimensiones cuando corresponda, y cada miembro de clase incluye una identidad que resuelve en la misma vista.",
    "justificacion": "Los consumidores deben proyectar representaciones fieles desde una vista compartida sin volver a analizar el texto ni depender de la estructura privada del CST.",
    "revisado_por": "persona-responsable"
  }
}
---

# Vista pública del programa

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una sesión que negocia program_view devuelve una proyección de solo lectura asociada a una revisión inmutable del documento. La proyección contiene las unidades de nivel superior en orden de fuente, con clase, nombre y tramo; los nodos disponibles de declaraciones, sentencias, expresiones, tipos y símbolos resueltos; las relaciones de composición entre ellos; y las relaciones de herencia, miembros y sobrescritura. Cada relación de miembro identifica el nodo público que la representa. Diagramas, emisores Python y Rust y comprobaciones estructurales consumen esta misma proyección. No expone índices, direcciones ni disposiciones privadas del CST, HIR o bytecode, y no obliga al consumidor a volver a analizar el texto.",
  "verificacion": ["C1", "C2"]
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "vista_programa": {
      "units": [{"kind": "algorithm", "name": "P", "order": 0, "span": {"start": {"line": 1, "column": 1}}}],
      "node_kinds_include": ["declaration", "statement", "expression", "symbol", "type"],
      "child_order": "source"
    }
  },
  "programa": "Algoritmo P\nDefinir total Como Entero;\ntotal <- 2 + 3;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "vista_programa": {
      "units": [
        {"kind": "class", "name": "Base", "order": 0},
        {"kind": "class", "name": "Hija", "order": 1},
        {"kind": "algorithm", "name": "P", "order": 2}
      ],
      "inheritance": [{"class": "Hija", "base": "Base"}],
      "methods": [{"class": "Hija", "name": "valor", "overrides": "Base.valor"}],
      "members": [
        {"class": "Base", "name": "valor", "kind": "method", "visibility": "public", "arity": 0},
        {"class": "Hija", "name": "valor", "kind": "method", "visibility": "public", "arity": 0}
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
  "texto": "La vista incluye revision_id opaco y una lista nodes. Cada nodo declara node_id opaco único dentro de esa revisión, kind de categoría y syntax_kind estable de la construcción del lenguaje, span con desplazamientos UTF-8 de inicio inclusivo y fin exclusivo codificados como cadenas decimales, y posiciones start/end de línea y columna desde uno medidas en puntos de código Unicode. Cada nodo incluye child_node_ids y child_roles en el mismo orden; cada relación child_roles identifica node_id y el papel sintáctico de esa relación. Puede incluir parent_node_id. Los nodos parameter incluyen dimensions con la cantidad de dimensiones declaradas. Los miembros field incluyen type con el lexema de su tipo declarado y dimensions con la cantidad de dimensiones declaradas. Toda referencia resuelve a un nodo de la misma vista. Una edición produce una revisión nueva y no promete conservar identificadores.",
  "verificacion": ["C3", "C5"]
}
```

```caso
{
  "id": "C3",
  "regla": "R2",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
      "vista_programa": {
      "node_ids_unique": true,
      "references_same_revision": true,
      "nodes_include": [{"kind": "statement", "span": {"start_byte": "12", "end_byte": "28", "start": {"line": 2, "column": 1}, "end": {"line": 2, "column": 14}}}]
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
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "vista_programa": {
      "syntax_kinds_include": ["conditional", "while_loop", "output"],
      "child_roles_include": [{"syntax_kind":"conditional","role":"else_body"}]
    }
  },
  "programa": "Algoritmo P\nSi verdadero Entonces\nMientras falso Hacer\nEscribir 1;\nFinMientras\nFinSi\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C6",
  "regla": "R2",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "vista_programa": {
      "members": [
        {"class": "Caja", "name": "saldo", "kind": "field", "type": "Entero", "dimensions": 0},
        {"class": "Caja", "name": "matriz", "kind": "field", "type": "Entero", "dimensions": 2}
      ],
      "nodes_include": [
        {"syntax_kind": "parameter", "dimensions": 3}
      ]
    }
  },
  "programa": "Clase Caja\nDefinir saldo Como Entero;\nDimension matriz[2, 3] Como Entero;\nMetodo ajustar(monto[,,] Como Entero)\nFinMetodo\nFinClase\nAlgoritmo P\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Liberar el documento o crear una revisión posterior invalida la vista anterior y sus asociaciones de eventos. Consultar una identidad de nodo con otra revisión devuelve un error de uso, no un nodo coincidente por reutilización de índice.",
  "verificacion": ["C4"]
}
```

```caso
{
  "id": "C4",
  "regla": "R3",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {"scenario": "boundary", "input": {"document_revision": 2, "node_revision": 1, "operation": "query_node"}},
  "espera": {"aplicacion": {"error": "usage", "unrelated_resources_unchanged": true}}
}
```
