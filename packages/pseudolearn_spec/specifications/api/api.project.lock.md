---
{
  "formato": "see/1",
  "id": "API.PROJECT.LOCK",
  "titulo": "Lock canónico y contenido verificado",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Lock declarativo de paquetes con origen lógico, aristas y digests SHA-256, y verificación del contenido entregado por el anfitrión.",
  "titulo_en": "Canonical lock and verified content",
  "depende_de": [
    {
      "id": "API.PROJECT.MANIFEST",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.MODULE.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-codex-2026-10-24"
  ]
}
---

# Lock canónico y contenido verificado

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un lock es un texto en el subconjunto declarativo del manifiesto con schema = 1 (otro valor produce unsupportedLockSchema) y una tabla packages indexada por nombre de paquete. Cada paquete declara origin (ruta lógica relativa a la raíz concedida, nunca absoluta ni con ..; si no, invalidLockPath), kind (local o locked), dependencies (nombres de paquetes del propio lock, ordenados y sin repetir; una arista a un paquete ausente produce danglingEdge) y, si es locked, digest y la tabla files de ruta lógica a digest. Las rutas siguen la política portable de API.PROJECT.MANIFEST: segmentos NFC, clave NFC en minúsculas Unicode, sin rutas absolutas ni componentes inválidos; orígenes de paquete o claves de archivos que colisionan producen invalidLockPath. La serialización conserva la grafía NFC y ordena por clave portable. Un mismo nombre con dos orígenes produce ambiguousOrigin. Los lock_errors conservan field, line y column del documento y se ordenan por línea, columna, código y field. Un campo desconocido, incluido cualquiera con apariencia de script, produce unknownLockField; el lock nunca ejecuta nada.",
  "verificacion": [
    "C7",
    "C8",
    "C9",
    "C10",
    "C14",
    "C18"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El digest de un archivo es SHA-256, en minúsculas y con prefijo sha256:, del dominio pseudolearn.lock.file.v1 seguido de un salto de línea y de los bytes del archivo tal como se leyeron. El digest de un paquete es SHA-256 del dominio pseudolearn.lock.package.v1 y un salto de línea, seguido por cada archivo en orden de su clave portable de ruta como ruta normalizada a NFC, byte cero, digest del archivo y salto de línea. El anfitrión normaliza la ruta antes de calcular el digest del paquete y calcula el digest de contenido sobre los bytes leídos, sin reabrir por nombre. Los digests verifican integridad, no autenticidad del origen. Entran en el hash solo los archivos que el anfitrión entrega; el propio lock y los directorios de control del repositorio no son archivos de paquete.",
  "verificacion": [
    "C1",
    "C16"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La operación build_lock recibe packages (name, origin, kind, dependencies y, para locked, files con path y text) y devuelve lock, el texto canónico, y lock_errors. El texto canónico lista los paquetes por nombre, las dependencias ordenadas y los archivos por clave portable de ruta; imprime rutas en NFC con claves entre comillas y rechaza colisiones antes de serializar, de modo que cualquier permutación de la entrada produce los mismos bytes. build_lock no escribe ni actualiza ningún archivo: la escritura del lock es una acción explícita del anfitrión.",
  "verificacion": [
    "C2",
    "C15",
    "C17"
  ]
}
```

```caso
{
  "id": "C16",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "build_lock",
        "arguments": {
          "packages": [
            {
              "name": "geo",
              "origin": "libs/geo",
              "kind": "locked",
              "dependencies": [],
              "files": [
                {
                  "path": "A.pseudo",
                  "text": "Escribir 1\n"
                },
                {
                  "path": "a.pseudo",
                  "text": "Escribir 2\n"
                }
              ]
            }
          ]
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La colisión se verifica mediante el error tipado; el digest no se observa en este caso."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "lock_errors": [
              {
                "code": "invalidLockPath"
              }
            ]
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C17",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "build_lock",
        "arguments": {
          "packages": [
            {
              "name": "geo",
              "origin": "libs/geo",
              "kind": "locked",
              "dependencies": [],
              "files": [
                {
                  "path": "café.pseudo",
                  "text": "Escribir 1\n"
                }
              ]
            }
          ]
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "lock_errors": [],
            "lock": "schema = 1\n\n[packages.\"geo\"]\norigin = \"libs/geo\"\nkind = \"locked\"\ndependencies = []\ndigest = \"sha256:de3b9019b11a9be7f9ae06149c392e4a9ce986c64b3afa3773fe4c1bbaf2b20b\"\n\n[packages.\"geo\".files]\n\"café.pseudo\" = \"sha256:7f2f1f2f1aabe5d2f03d55faacd58ff52337892609119e4f31253b39decd2efe\"\n"
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La operación resolve_lock recibe lock y packages con el mismo formato y devuelve verified y lock_errors, sin red ni lectura adicional: compara el lock con los bytes entregados, que son los mismos que se compilan. Un paquete del lock ausente produce lockedPackageAbsent y uno no registrado packageNotLocked; origen, tipo o aristas distintos producen originMismatch, kindMismatch y dependencyEdgeMismatch; un archivo ausente, no registrado o con bytes distintos produce fileMissing, fileNotLocked y digestMismatch; un digest de paquete falso con archivos coincidentes produce digestMismatch.",
  "verificacion": [
    "C3",
    "C4",
    "C5",
    "C6",
    "C11"
  ]
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un paquete local es editable y se registra sin digest ni archivos: sus cambios no invalidan el lock. Un paquete locked fija su contenido y cualquier cambio exige regenerar el lock de forma explícita. Un lock malformado o de versión no soportada es rechazado y una petición sin sus argumentos es un fallo de uso. El lock del lenguaje es independiente de los Cargo.lock del repositorio.",
  "verificacion": [
    "C12",
    "C13"
  ]
}
```

```caso
{
  "id": "C1",
  "regla": "R2",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "build_lock",
        "arguments": {
          "packages": [
            {
              "name": "geo",
              "origin": "libs/geo",
              "kind": "locked",
              "dependencies": [],
              "files": [
                {
                  "path": "a.pseudo",
                  "text": "Escribir 1\n"
                }
              ]
            }
          ]
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El lock no depende del perfil del lenguaje: sus campos y códigos son datos independientes del vocabulario."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "lock": "schema = 1\n\n[packages.\"geo\"]\norigin = \"libs/geo\"\nkind = \"locked\"\ndependencies = []\ndigest = \"sha256:9d4df7e3b6ea8ea6e45ad25cc7167db3989697d988508489432901a5ac16772d\"\n\n[packages.\"geo\".files]\n\"a.pseudo\" = \"sha256:7f2f1f2f1aabe5d2f03d55faacd58ff52337892609119e4f31253b39decd2efe\"\n",
            "lock_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C2",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "build_lock",
        "arguments": {
          "packages": [
            {
              "name": "geo",
              "origin": "libs/geo",
              "kind": "locked",
              "dependencies": [],
              "files": [
                {
                  "path": "a.pseudo",
                  "text": "Escribir 1\n"
                },
                {
                  "path": "b.pseudo",
                  "text": "Escribir 2\n"
                }
              ]
            }
          ]
        }
      },
      {
        "operation": "build_lock",
        "arguments": {
          "packages": [
            {
              "name": "geo",
              "origin": "libs/geo",
              "kind": "locked",
              "dependencies": [],
              "files": [
                {
                  "path": "b.pseudo",
                  "text": "Escribir 2\n"
                },
                {
                  "path": "a.pseudo",
                  "text": "Escribir 1\n"
                }
              ]
            }
          ]
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El lock no depende del perfil del lenguaje: sus campos y códigos son datos independientes del vocabulario."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "lock": "schema = 1\n\n[packages.\"geo\"]\norigin = \"libs/geo\"\nkind = \"locked\"\ndependencies = []\ndigest = \"sha256:1b7fdf1010865373c287db7a974f793a711a209fa57ff99f8bb58f9eff0e90ad\"\n\n[packages.\"geo\".files]\n\"a.pseudo\" = \"sha256:7f2f1f2f1aabe5d2f03d55faacd58ff52337892609119e4f31253b39decd2efe\"\n\"b.pseudo\" = \"sha256:18db2fedf2771718851b2369a2a0655bba13d905d39f0393be4b47ef4d6b8161\"\n",
            "lock_errors": []
          }
        },
        {
          "value": {
            "lock": "schema = 1\n\n[packages.\"geo\"]\norigin = \"libs/geo\"\nkind = \"locked\"\ndependencies = []\ndigest = \"sha256:1b7fdf1010865373c287db7a974f793a711a209fa57ff99f8bb58f9eff0e90ad\"\n\n[packages.\"geo\".files]\n\"a.pseudo\" = \"sha256:7f2f1f2f1aabe5d2f03d55faacd58ff52337892609119e4f31253b39decd2efe\"\n\"b.pseudo\" = \"sha256:18db2fedf2771718851b2369a2a0655bba13d905d39f0393be4b47ef4d6b8161\"\n",
            "lock_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C3",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "resolve_lock",
        "arguments": {
          "lock": "schema = 1\n\n[packages.\"geo\"]\norigin = \"libs/geo\"\nkind = \"locked\"\ndependencies = []\ndigest = \"sha256:9d4df7e3b6ea8ea6e45ad25cc7167db3989697d988508489432901a5ac16772d\"\n\n[packages.\"geo\".files]\n\"a.pseudo\" = \"sha256:7f2f1f2f1aabe5d2f03d55faacd58ff52337892609119e4f31253b39decd2efe\"\n",
          "packages": [
            {
              "name": "geo",
              "origin": "libs/geo",
              "kind": "locked",
              "dependencies": [],
              "files": [
                {
                  "path": "a.pseudo",
                  "text": "Escribir 1\n"
                }
              ]
            }
          ]
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El lock no depende del perfil del lenguaje: sus campos y códigos son datos independientes del vocabulario."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "verified": true,
            "lock_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C4",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "resolve_lock",
        "arguments": {
          "lock": "schema = 1\n\n[packages.\"geo\"]\norigin = \"libs/geo\"\nkind = \"locked\"\ndependencies = []\ndigest = \"sha256:9d4df7e3b6ea8ea6e45ad25cc7167db3989697d988508489432901a5ac16772d\"\n\n[packages.\"geo\".files]\n\"a.pseudo\" = \"sha256:7f2f1f2f1aabe5d2f03d55faacd58ff52337892609119e4f31253b39decd2efe\"\n",
          "packages": [
            {
              "name": "geo",
              "origin": "libs/geo",
              "kind": "locked",
              "dependencies": [],
              "files": [
                {
                  "path": "a.pseudo",
                  "text": "Escribir 2\n"
                }
              ]
            }
          ]
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El lock no depende del perfil del lenguaje: sus campos y códigos son datos independientes del vocabulario."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "verified": false,
            "lock_errors": [
              {
                "code": "digestMismatch"
              }
            ]
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C5",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "resolve_lock",
        "arguments": {
          "lock": "schema = 1\n\n[packages.\"geo\"]\norigin = \"libs/geo\"\nkind = \"locked\"\ndependencies = []\ndigest = \"sha256:1b7fdf1010865373c287db7a974f793a711a209fa57ff99f8bb58f9eff0e90ad\"\n\n[packages.\"geo\".files]\n\"a.pseudo\" = \"sha256:7f2f1f2f1aabe5d2f03d55faacd58ff52337892609119e4f31253b39decd2efe\"\n\"b.pseudo\" = \"sha256:18db2fedf2771718851b2369a2a0655bba13d905d39f0393be4b47ef4d6b8161\"\n",
          "packages": [
            {
              "name": "geo",
              "origin": "libs/geo",
              "kind": "locked",
              "dependencies": [],
              "files": [
                {
                  "path": "a.pseudo",
                  "text": "Escribir 1\n"
                }
              ]
            }
          ]
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El lock no depende del perfil del lenguaje: sus campos y códigos son datos independientes del vocabulario."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "verified": false,
            "lock_errors": [
              {
                "code": "fileMissing"
              }
            ]
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C6",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "resolve_lock",
        "arguments": {
          "lock": "schema = 1\n\n[packages.\"geo\"]\norigin = \"libs/geo\"\nkind = \"locked\"\ndependencies = []\ndigest = \"sha256:d75cf35f56c0803d6e0f1543a1555d08580206251a4a29074767328c38f7d06e\"\n\n[packages.\"geo\".files]\n\"a.pseudo\" = \"sha256:7f2f1f2f1aabe5d2f03d55faacd58ff52337892609119e4f31253b39decd2efe\"\n",
          "packages": [
            {
              "name": "geo",
              "origin": "libs/geo",
              "kind": "locked",
              "dependencies": [],
              "files": [
                {
                  "path": "a.pseudo",
                  "text": "Escribir 1\n"
                }
              ]
            }
          ]
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El lock no depende del perfil del lenguaje: sus campos y códigos son datos independientes del vocabulario."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "verified": false,
            "lock_errors": [
              {
                "code": "digestMismatch"
              }
            ]
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C7",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "build_lock",
        "arguments": {
          "packages": [
            {
              "name": "geo",
              "origin": "libs/geo",
              "kind": "locked",
              "dependencies": [],
              "files": [
                {
                  "path": "a.pseudo",
                  "text": "Escribir 1\n"
                }
              ]
            },
            {
              "name": "geo",
              "origin": "vendor/geo",
              "kind": "locked",
              "dependencies": [],
              "files": [
                {
                  "path": "a.pseudo",
                  "text": "Escribir 1\n"
                }
              ]
            }
          ]
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El lock no depende del perfil del lenguaje: sus campos y códigos son datos independientes del vocabulario."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "lock": null,
            "lock_errors": [
              {
                "code": "ambiguousOrigin"
              }
            ]
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C8",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "resolve_lock",
        "arguments": {
          "lock": "schema = 2\n\n[packages.\"geo\"]\norigin = \"libs/geo\"\nkind = \"locked\"\ndependencies = []\ndigest = \"sha256:9d4df7e3b6ea8ea6e45ad25cc7167db3989697d988508489432901a5ac16772d\"\n\n[packages.\"geo\".files]\n\"a.pseudo\" = \"sha256:7f2f1f2f1aabe5d2f03d55faacd58ff52337892609119e4f31253b39decd2efe\"\n",
          "packages": [
            {
              "name": "geo",
              "origin": "libs/geo",
              "kind": "locked",
              "dependencies": [],
              "files": [
                {
                  "path": "a.pseudo",
                  "text": "Escribir 1\n"
                }
              ]
            }
          ]
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El lock no depende del perfil del lenguaje: sus campos y códigos son datos independientes del vocabulario."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "verified": false,
            "lock_errors": [
              {
                "code": "unsupportedLockSchema"
              }
            ]
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C9",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "build_lock",
        "arguments": {
          "packages": [
            {
              "name": "geo",
              "origin": "/home/ana/proyecto/libs/geo",
              "kind": "locked",
              "dependencies": [],
              "files": [
                {
                  "path": "a.pseudo",
                  "text": "Escribir 1\n"
                }
              ]
            }
          ]
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El lock no depende del perfil del lenguaje: sus campos y códigos son datos independientes del vocabulario."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "lock": null,
            "lock_errors": [
              {
                "code": "invalidLockPath"
              }
            ]
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C10",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "build_lock",
        "arguments": {
          "packages": [
            {
              "name": "geo",
              "origin": "libs/geo",
              "kind": "locked",
              "dependencies": [
                "util"
              ],
              "files": [
                {
                  "path": "a.pseudo",
                  "text": "Escribir 1\n"
                }
              ]
            }
          ]
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El lock no depende del perfil del lenguaje: sus campos y códigos son datos independientes del vocabulario."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "lock": null,
            "lock_errors": [
              {
                "code": "danglingEdge"
              }
            ]
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C11",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "resolve_lock",
        "arguments": {
          "lock": "schema = 1\n\n[packages.\"geo\"]\norigin = \"libs/geo\"\nkind = \"locked\"\ndependencies = []\ndigest = \"sha256:9d4df7e3b6ea8ea6e45ad25cc7167db3989697d988508489432901a5ac16772d\"\n\n[packages.\"geo\".files]\n\"a.pseudo\" = \"sha256:7f2f1f2f1aabe5d2f03d55faacd58ff52337892609119e4f31253b39decd2efe\"\n",
          "packages": []
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El lock no depende del perfil del lenguaje: sus campos y códigos son datos independientes del vocabulario."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "verified": false,
            "lock_errors": [
              {
                "code": "lockedPackageAbsent"
              }
            ]
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C12",
  "regla": "R5",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "build_lock",
        "arguments": {
          "packages": [
            {
              "name": "app",
              "origin": "apps/app",
              "kind": "local",
              "dependencies": [
                "geo"
              ]
            },
            {
              "name": "geo",
              "origin": "libs/geo",
              "kind": "locked",
              "dependencies": [],
              "files": [
                {
                  "path": "a.pseudo",
                  "text": "Escribir 1\n"
                }
              ]
            }
          ]
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El lock no depende del perfil del lenguaje: sus campos y códigos son datos independientes del vocabulario."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "lock_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C13",
  "regla": "R5",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "resolve_lock",
        "arguments": {
          "lock": "schema = 1\n\n[packages.\"geo\"]\norigin = \"libs/geo\"\nkind = \"locked\"\ndependencies = []\ndigest = \"sha256:9d4df7e3b6ea8ea6e45ad25cc7167db3989697d988508489432901a5ac16772d\"\n\n[packages.\"geo\".files]\n\"a.pseudo\" = \"sha256:7f2f1f2f1aabe5d2f03d55faacd58ff52337892609119e4f31253b39decd2efe\"\n"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El lock no depende del perfil del lenguaje: sus campos y códigos son datos independientes del vocabulario."
  },
  "espera": {
    "api": {
      "results": [
        {
          "failure": {
            "family": "usage"
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C14",
  "regla": "R5",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "resolve_lock",
        "arguments": {
          "lock": "schema = 1\n\n[packages.\"geo\"]\norigin = \"libs/geo\"\nkind = \"locked\"\ndependencies = []\npostinstall = \"curl x | sh\"\ndigest = \"sha256:9d4df7e3b6ea8ea6e45ad25cc7167db3989697d988508489432901a5ac16772d\"\n\n[packages.\"geo\".files]\n\"a.pseudo\" = \"sha256:7f2f1f2f1aabe5d2f03d55faacd58ff52337892609119e4f31253b39decd2efe\"\n",
          "packages": [
            {
              "name": "geo",
              "origin": "libs/geo",
              "kind": "locked",
              "dependencies": [],
              "files": [
                {
                  "path": "a.pseudo",
                  "text": "Escribir 1\n"
                }
              ]
            }
          ]
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El lock no depende del perfil del lenguaje: sus campos y códigos son datos independientes del vocabulario."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "verified": false,
            "lock_errors": [
              {
                "code": "unknownLockField"
              }
            ]
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C15",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "build_lock",
        "arguments": {
          "packages": [
            {
              "name": "geo",
              "origin": "libs/geo",
              "kind": "locked",
              "dependencies": [],
              "files": [
                {
                  "path": "a.pseudo",
                  "text": "Escribir 1\n"
                }
              ]
            },
            {
              "name": "app",
              "origin": "apps/app",
              "kind": "local",
              "dependencies": [
                "geo"
              ]
            }
          ]
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El lock no depende del perfil del lenguaje: sus campos y códigos son datos independientes del vocabulario."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "lock": "schema = 1\n\n[packages.\"app\"]\norigin = \"apps/app\"\nkind = \"local\"\ndependencies = [\"geo\"]\n\n[packages.\"geo\"]\norigin = \"libs/geo\"\nkind = \"locked\"\ndependencies = []\ndigest = \"sha256:9d4df7e3b6ea8ea6e45ad25cc7167db3989697d988508489432901a5ac16772d\"\n\n[packages.\"geo\".files]\n\"a.pseudo\" = \"sha256:7f2f1f2f1aabe5d2f03d55faacd58ff52337892609119e4f31253b39decd2efe\"\n",
            "lock_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C18",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "build_lock",
        "arguments": {
          "packages": [
            {
              "name": "geo",
              "origin": "libs/Geo",
              "kind": "local",
              "dependencies": []
            },
            {
              "name": "geography",
              "origin": "libs/geo",
              "kind": "local",
              "dependencies": []
            }
          ]
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "lock_errors": [
              {
                "code": "invalidLockPath",
                "field": "packages.geo.origin",
                "line": 1,
                "column": 1
              },
              {
                "code": "invalidLockPath",
                "field": "packages.geography.origin",
                "line": 1,
                "column": 1
              }
            ]
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```
