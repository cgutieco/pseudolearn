---
{
  "formato": "see/1",
  "id": "TOOL.SERVICE.CATALOG",
  "titulo": "Catálogo normativo de ayuda",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "service"
  ],
  "resumen": "Identidades, disponibilidad y contenido editorial de la ayuda contextual.",
  "depende_de": [
    {
      "id": "TOOL.SERVICE.HOVER",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.PROGRAM.STRUCTURE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.PROFILE.VOCABULARY",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ]
}
---

# Catálogo normativo de ayuda

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El catálogo se representa como el recurso tipado helpCatalog dentro de valor de una definición see/1. Su formato help-catalog/1 contiene fichas con identidad estable, identidad de fuente y papel, identidades léxicas fuente, disponibilidad por edición, perfil y rigor, anclajes exactos y contenido editorial obligatorio en español e inglés.",
  "justificacion": "El recurso se guarda dentro de un bloque normativo serializado y exportable para que su contenido editorial participe en el hash del contrato. La prosa Markdown fuera de bloques no forma parte del modelo ni del anclaje.",
  "verificacion": [
    "estructural"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada ficha identifica los lexemas mediante identidades del vocabulario o de la biblioteca y nunca copia sus formas canónicas, firmas ni tipos. Sus anclajes citan una identidad de especificación, versión y elemento vigentes. Cada ejemplo referencia un caso exacto, su versión, perfil y rigor; el resultado esperado permanece en el caso.",
  "justificacion": "Las identidades lingüísticas y los ejemplos tienen como dueños el vocabulario, la biblioteca y sus casos. Copiar formas o esperados crearía fuentes paralelas susceptibles de divergir.",
  "verificacion": [
    "estructural"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada exclusión declara identidad, alcance por edición, perfil y rigor, razón tipada y anclaje vigente. El validador rechaza identidades duplicadas, alcances vacíos, condiciones incompatibles y una exclusión que se solapa con una ficha disponible.",
  "justificacion": "Las exclusiones explican ausencias de cobertura y no sustituyen una ficha requerida por una identidad pedagógica activa.",
  "verificacion": [
    "estructural"
  ]
}
```

```definicion
{
  "id": "D1",
  "termino": "helpCatalog",
  "texto": "Catálogo exportado de fichas editoriales por tema y papel sintáctico.",
  "valor": {
    "format": "help-catalog/1",
    "cards": [
      {
        "id": "construction.algorithm.entry",
        "identity": {
          "kind": "construction",
          "id": "algorithm",
          "role": "program_entry"
        },
        "tokens": [
          {
            "identity": "algorithm",
            "source": {
              "specification": "LANG.PROFILE.VOCABULARY",
              "version": "1.0.0",
              "element": "D1"
            }
          },
          {
            "identity": "endAlgorithm",
            "source": {
              "specification": "LANG.PROFILE.VOCABULARY",
              "version": "1.0.0",
              "element": "D1"
            }
          }
        ],
        "availability": {
          "editions": [
            "2026"
          ],
          "profiles": [
            "es",
            "en"
          ],
          "strictness": [
            "estricto",
            "flexible"
          ]
        },
        "anchors": [
          {
            "specification": "LANG.PROGRAM.STRUCTURE",
            "version": "1.0.0",
            "element": "R1"
          }
        ],
        "content": {
          "es": {
            "title": "Estructura del algoritmo",
            "summary": "Punto de entrada de un programa.",
            "purpose": "Delimita la unidad que inicia la ejecución del texto de programa.",
            "parts": [
              {
                "identity": "opening",
                "text": "Declara el nombre del algoritmo."
              },
              {
                "identity": "closing",
                "text": "Cierra la unidad que contiene el algoritmo."
              }
            ],
            "constraints": [
              "El texto contiene exactamente un algoritmo con nombre y cierre."
            ],
            "common_errors": [],
            "examples": [
              {
                "specification": "LANG.PROGRAM.STRUCTURE",
                "version": "1.0.0",
                "case": "C1",
                "profile": "es",
                "strictness": "estricto",
                "label": "Algoritmo vacío"
              }
            ]
          },
          "en": {
            "title": "Algorithm structure",
            "summary": "Program entry point.",
            "purpose": "Delimits the unit that starts execution of the program text.",
            "parts": [
              {
                "identity": "opening",
                "text": "Declares the algorithm name."
              },
              {
                "identity": "closing",
                "text": "Closes the unit that contains the algorithm."
              }
            ],
            "constraints": [
              "The text contains exactly one named algorithm with a closing form."
            ],
            "common_errors": [],
            "examples": [
              {
                "specification": "LANG.PROGRAM.STRUCTURE",
                "version": "1.0.0",
                "case": "C1",
                "profile": "en",
                "strictness": "estricto",
                "label": "Empty algorithm"
              }
            ]
          }
        }
      }
    ],
    "exclusions": []
  }
}
```

R1-R3 se verifican de forma estructural mediante el esquema del paquete, unicidad de identidades y comprobación de referencias. El esquema acepta solo la edición 2026 y los perfiles/rigores actuales. `content.es` y `content.en` son idiomas editoriales; `availability.profiles` describe por separado el vocabulario del programa. Las fichas y exclusiones identifican sus fuentes por claves estables; las formas canónicas y plantillas se generan desde vocabulario y gramática. Las traducciones editoriales son datos escritos en ambos idiomas, nunca una transformación en tiempo de ejecución.

Una ancla contiene `specification`, `version` y `element`. Cada token contiene su identidad y un `source` con esos mismos tres campos; cuando la fuente es el recurso `vocabulary` o `functions`, la identidad debe existir como clave de ese recurso. Una referencia de ejemplo contiene además `case`, `profile`, `strictness` y una etiqueta localizada; el resultado independiente se lee del caso. La disponibilidad de un ejemplo debe ser subconjunto de la disponibilidad de su ficha y del caso referenciado.

Una exclusión usa una identidad y alcance con el mismo esquema que una ficha, una razón de `alias_of`, `not_user_visible`, `outside_edition_scope` o `not_pedagogical`, y un anclaje. El catálogo solo puede excluir el mismo papel dentro del alcance declarado. La cobertura del inventario completo de vocabulario, operadores, incorporadas y roles se valida cuando se fija ese denominador.

El exportador extrae `helpCatalog` de `definicion.valor` como datos. No se añade un bloque see/1 ni se consume documentación transitoria. La exportación incluye el hash del contrato, que cambia ante modificaciones del contenido editorial almacenado en `valor`.
