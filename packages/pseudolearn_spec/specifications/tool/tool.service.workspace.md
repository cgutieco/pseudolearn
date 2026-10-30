---
{
  "formato": "see/1",
  "id": "TOOL.SERVICE.WORKSPACE",
  "titulo": "Sesión persistente de proyecto para el servicio",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "service"
  ],
  "resumen": "Sincronización persistente de snapshots de proyecto y overlays de documentos sin E/S.",
  "depende_de": [
    {
      "id": "API.PROJECT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.SERVICE.INCREMENTAL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ]
}
---

# Sesión persistente de proyecto para el servicio

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una sesión de workspace recibe un snapshot completo del proyecto como datos, conserva su identidad project_id y publica una revisión de servicio monotónica. Para cualquier secuencia de acciones, sus diagnósticos, errores de proyecto, imports y HIR son iguales al análisis frío del snapshot efectivo; las permutaciones de entrada equivalentes producen el mismo resultado.",
  "verificacion": ["C1", "C6", "P1"]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los documentos abiertos aportan overlays por ruta y versión, y prevalecen sobre el texto de disco recibido. El análisis mantiene visibles los módulos cerrados importados. Cerrar un documento restaura el texto del snapshot más reciente; si ese snapshot ya no contiene la ruta, quitar el overlay también quita el módulo. Las operaciones inválidas devuelven un error controlado y no alteran el estado.",
  "verificacion": ["C1", "C2", "C5"]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "update_snapshot exige una revisión de proyecto mayor; resynchronize acepta la revisión actual o una mayor. Ambas comparan el contenido completo de cada archivo y las entradas de dependencias entregadas por el llamador, sin usar tamaño ni fecha de modificación como identidad del contenido. Un project_id distinto o una revisión anterior produce un error sin cambiar la sesión.",
  "verificacion": ["C3", "C5", "C7"]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El servicio compara las huellas de las unidades del proyecto. Un cambio de cuerpo no invalida las firmas ni los módulos que importan esa unidad. Un cambio de firma invalida los importadores transitivos; cambios de paquetes, configuraciones, manifiestos o lock invalidan los módulos afectados por la resolución del proyecto.",
  "verificacion": ["C1", "C3", "C4"]
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "coincide_con_frio": true,
      "changed": ["geo/vectores"],
      "signature_changed": []
    }
  },
  "servicio": {
    "suboperacion": "workspace",
    "workspace": {
      "project": {
        "project_id": "1",
        "revision_id": "1",
        "packages": [
          {"name": "app", "root": "app", "kind": "application", "entries": ["app/main"], "dependencies": {"geo": "geo"}},
          {"name": "geo", "root": "geo", "kind": "library", "entries": [], "dependencies": {}}
        ],
        "files": [
          {"path": "app/main", "source_id": 1, "text": "Importar geo.vectores.Doble;\nAlgoritmo P\nEscribir Doble(21);\nFinAlgoritmo\n"},
          {"path": "geo/vectores", "source_id": 2, "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n"}
        ]
      },
      "options": {"profile": "es", "strictness": "strict"}
    },
    "actions": [
      {"operation": "open", "path": "geo/vectores", "version": 1, "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 3;\nFinSubProceso\n"}
    ]
  }
}
```

```caso
{
  "id": "C2",
  "regla": "R2",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {"coincide_con_frio": true, "diagnostics": [], "errores": []}
  },
  "servicio": {
    "suboperacion": "workspace",
    "workspace": {
      "project": {
        "project_id": "1",
        "revision_id": "1",
        "packages": [{"name": "app", "root": "app", "kind": "application", "entries": ["app/main"], "dependencies": {}}],
        "files": [{"path": "app/main", "source_id": 1, "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"}]
      },
      "options": {"profile": "es", "strictness": "strict"}
    },
    "actions": [
      {"operation": "open", "path": "app/main", "version": 1, "text": "@"},
      {"operation": "close", "path": "app/main"}
    ]
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R3",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "coincide_con_frio": true,
      "changed": ["app/main"],
      "signature_changed": ["app/main"]
    }
  },
  "servicio": {
    "suboperacion": "workspace",
    "workspace": {
      "project": {
        "project_id": "1",
        "revision_id": "1",
        "packages": [{"name": "app", "root": "app", "kind": "application", "entries": ["app/main"], "dependencies": {}}],
        "files": [{"path": "app/main", "source_id": 1, "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"}]
      },
      "options": {
        "profile": "es",
        "strictness": "strict",
        "dependency_inputs": {"app/pseudolearn.lock": "digest = \\\"aaaa\\\"\\n"}
      }
    },
    "actions": [
      {
        "operation": "resynchronize",
        "snapshot": {
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [{"name": "app", "root": "app", "kind": "application", "entries": ["app/main"], "dependencies": {}}],
            "files": [{"path": "app/main", "source_id": 1, "text": "Algoritmo P\nEscribir 2;\nFinAlgoritmo\n"}]
          },
          "options": {
            "profile": "es",
            "strictness": "strict",
            "dependency_inputs": {"app/pseudolearn.lock": "digest = \\\"bbbb\\\"\\n"}
          }
        }
      }
    ]
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R4",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "coincide_con_frio": true,
      "signature_changed": ["geo/vectores"],
      "invalidated": ["app/main", "geo/vectores"]
    }
  },
  "servicio": {
    "suboperacion": "workspace",
    "workspace": {
      "project": {
        "project_id": "1",
        "revision_id": "1",
        "packages": [
          {"name": "app", "root": "app", "kind": "application", "entries": ["app/main"], "dependencies": {"geo": "geo"}},
          {"name": "geo", "root": "geo", "kind": "library", "entries": [], "dependencies": {}}
        ],
        "files": [
          {"path": "app/main", "source_id": 1, "text": "Importar geo.vectores.Doble;\nAlgoritmo P\nEscribir Doble(21);\nFinAlgoritmo\n"},
          {"path": "geo/vectores", "source_id": 2, "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n"}
        ]
      },
      "options": {"profile": "es", "strictness": "strict"}
    },
    "actions": [
      {"operation": "open", "path": "geo/vectores", "version": 1, "text": "Publico SubProceso Doble(n Como Entero, factor Como Entero) Como Entero\nRetornar n * factor;\nFinSubProceso\n"}
    ]
  }
}
```

```caso
{
  "id": "C5",
  "regla": "R2",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {"coincide_con_frio": true, "errores": ["DocumentNotOpen"]}
  },
  "servicio": {
    "suboperacion": "workspace",
    "workspace": {
      "project": {
        "project_id": "1",
        "revision_id": "1",
        "packages": [{"name": "app", "root": "app", "kind": "application", "entries": ["app/main"], "dependencies": {}}],
        "files": [{"path": "app/main", "source_id": 1, "text": "Algoritmo P\nFinAlgoritmo\n"}]
      },
      "options": {"profile": "es", "strictness": "strict"}
    },
    "actions": [
      {"operation": "change", "path": "app/main", "version": 2, "text": "Algoritmo P\nFinAlgoritmo\n"}
    ]
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R1",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {"coincide_con_frio": true, "project_errors": ["emptyWorkspace"]}
  },
  "servicio": {
    "suboperacion": "workspace",
    "workspace": {
      "project": {
        "project_id": "1",
        "revision_id": "1",
        "packages": [{"name": "app", "root": "app", "kind": "application", "entries": ["app/main"], "dependencies": {}}],
        "files": []
      },
      "options": {"profile": "es", "strictness": "strict"}
    }
  }
}
```

```caso
{
  "id": "C7",
  "regla": "R3",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {"coincide_con_frio": true, "errores": ["ProjectIdentityChanged"]}
  },
  "servicio": {
    "suboperacion": "workspace",
    "workspace": {
      "project": {
        "project_id": "1",
        "revision_id": "1",
        "packages": [{"name": "app", "root": "app", "kind": "application", "entries": ["app/main"], "dependencies": {}}],
        "files": [{"path": "app/main", "source_id": 1, "text": "Algoritmo P\nFinAlgoritmo\n"}]
      },
      "options": {"profile": "es", "strictness": "strict"}
    },
    "actions": [
      {
        "operation": "update",
        "snapshot": {
          "project": {
            "project_id": "2",
            "revision_id": "2",
            "packages": [{"name": "app", "root": "app", "kind": "application", "entries": ["app/main"], "dependencies": {}}],
            "files": [{"path": "app/main", "source_id": 1, "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"}]
          },
          "options": {"profile": "es", "strictness": "strict"}
        }
      }
    ]
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R2",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {"coincide_con_frio": true, "diagnostics": [], "errores": []}
  },
  "servicio": {
    "suboperacion": "workspace",
    "workspace": {
      "project": {
        "project_id": "1",
        "revision_id": "1",
        "packages": [
          {"name": "app", "root": "app", "kind": "application", "entries": ["app/main"], "dependencies": {"geo": "geo"}},
          {"name": "geo", "root": "geo", "kind": "library", "entries": [], "dependencies": {}}
        ],
        "files": [
          {"path": "app/main", "source_id": 1, "text": "@"},
          {"path": "geo/vectores", "source_id": 2, "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n"}
        ]
      },
      "options": {"profile": "es", "strictness": "strict"}
    },
    "actions": [
      {"operation": "open", "path": "app/main", "version": 1, "text": "Importar geo.vectores.Doble;\nAlgoritmo P\nEscribir Doble(21);\nFinAlgoritmo\n"}
    ]
  }
}
```

```propiedad
{
  "id": "P1",
  "regla": "R1",
  "generador": {
    "snapshots": "proyectos y secuencias de overlays con archivos ordenados de forma aleatoria"
  },
  "propiedad": "El resultado tras cada acción equivale al análisis frío del snapshot efectivo y no depende del orden de entrada.",
  "oraculo": "Comparación independiente de HIR, imports, diagnósticos y errores de proyecto con una sesión nueva sobre el mismo contenido.",
  "justificacion": "La igualdad con el análisis frío es el contrato observable de sincronización persistente."
}
```
