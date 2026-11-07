---
{
  "formato": "see/1",
  "id": "LANG.TYPES.VARIANT",
  "titulo": "Variantes declaradas por la persona",
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
    "engine",
    "aot"
  ],
  "resumen": "Tipos variante nominales con alternativas nombradas, construcción cualificada, patrones exhaustivos y plantillas genéricas.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.RELATIONS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.CONTROL.SWITCH",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.TYPES.GENERIC",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Variantes declaradas por la persona

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Variante nombre y FinVariante declaran en el módulo un tipo variante nominal con una o más líneas Alternativa nombre o Alternativa nombre(campo Como tipo, …). Los nombres de alternativa de una variante y los de campo de una alternativa son únicos (duplicateMember); una variante sin alternativas es variantWithoutAlternatives; el nombre del tipo comparte el espacio de los demás tipos (duplicateTypeDeclaration). Variante, Alternativa y FinVariante son palabras contextuales por perfil: fuera de la cabecera, de las líneas de alternativa y del cierre son nombres ordinarios. Un valor se construye con nombre.Alternativa(argumentos), con un argumento asignable por campo y en su orden (argumentCountMismatch, incompatibleArgumentType), o con nombre.Alternativa sin paréntesis cuando la alternativa no tiene campos; una alternativa inexistente es undefinedMember. Una variante es un valor: asignarla, pasarla, retornarla o guardarla en un campo de objeto, en un arreglo o en una colección la copia, y los objetos de sus campos se comparten por referencia. Como las variantes incorporadas, no admite escritura ni comparación (variantRequiresPattern) ni acceso a campos; su disposición es la de las variantes incorporadas y exceder el límite de operandos es variantLayoutLimit.",
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
    "C11",
    "C12",
    "C25",
    "C26",
    "C27",
    "C28",
    "C30"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "En Segun sobre una variante declarada, cada rama contiene un único patrón nombre.Alternativa o nombre.Alternativa(v1, …, vn) con exactamente un nombre por campo (argumentCountMismatch). El nombre es el de la variante del selector o el de su plantilla; otro tipo es incompatibleSwitchCaseType y una alternativa inexistente es undefinedMember. Cada nombre introduce un vínculo inmutable con el campo correspondiente, visible solo en su rama. Las ramas deben cubrir todas las alternativas o incluir De Otro Modo; una selección incompleta produce nonExhaustiveSwitch con las alternativas faltantes en orden de declaración; un patrón repetido es duplicateSwitchCaseLabel y uno posterior a De Otro Modo es unreachableSwitchPattern.",
  "verificacion": [
    "C13",
    "C14",
    "C15",
    "C16",
    "C17",
    "C18",
    "C19",
    "C29",
    "C31"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Variante nombre<T> declara una plantilla de variante y nombre<argumentos> nombra una instancia (LANG.TYPES.GENERIC#R1). La construcción nombre.Alternativa toma los argumentos de tipo del tipo esperado por una declaración, una asignación, un retorno o un argumento cuando es una instancia de esa plantilla; sin ese contexto los infiere cuando cada parámetro es directamente el tipo de algún campo de la alternativa construida, y en otro caso es ambiguousVariantType. Los patrones usan el nombre de la plantilla.",
  "verificacion": [
    "C20",
    "C21",
    "C22",
    "C23",
    "C24"
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
    "es": "Variante Forma\nAlternativa Circulo(radio Como Entero)\nAlternativa Rectangulo(ancho Como Entero, alto Como Entero)\nAlternativa Punto\nFinVariante\nSubProceso area(f Como Forma) Como Entero\nDefinir total Como Entero <- 0;\nSegun f Hacer\nForma.Circulo(r): total <- 3 * r * r;\nForma.Rectangulo(a, h): total <- a * h;\nForma.Punto: total <- 0;\nFinSegun\nRetornar total;\nFinSubProceso\nAlgoritmo P\nEscribir area(Forma.Circulo(1));\nEscribir area(Forma.Rectangulo(3, 4));\nEscribir area(Forma.Punto);\nFinAlgoritmo\n",
    "en": "variant Shape\ncase Circle(radius as integer)\ncase Rectangle(width as integer, height as integer)\ncase Dot\nendVariant\nsubroutine area(f as Shape) as integer\ndefine total as integer <- 0;\nswitch f do\nShape.Circle(r): total <- 3 * r * r;\nShape.Rectangle(a, h): total <- a * h;\nShape.Dot: total <- 0;\nendSwitch\nreturn total;\nendSubroutine\nalgorithm P\nwrite area(Shape.Circle(1));\nwrite area(Shape.Rectangle(3, 4));\nwrite area(Shape.Dot);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n12\n0\n",
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
    "es": "Variante Vacia;\nFinVariante;\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "variant Empty;\nendVariant;\nAlgorithm P\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variantWithoutAlternatives",
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
    "es": "Variante Color\nAlternativa Rojo\nAlternativa Rojo\nFinVariante\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "variant Tint\ncase Red\ncase Red\nendVariant\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "duplicateMember",
        "severidad": "error"
      }
    ]
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
    "es": "Algoritmo P\nDefinir Variante Como Entero <- 3;\nDefinir Alternativa Como Entero <- 4;\nEscribir Variante + Alternativa;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine variant as integer <- 3;\ndefine case as integer <- 4;\nwrite variant + case;\nendAlgorithm\n"
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
    "es": "Variante Forma\nAlternativa Circulo(radio Como Entero)\nAlternativa Rectangulo(ancho Como Entero, alto Como Entero)\nAlternativa Punto\nFinVariante\nAlgoritmo P\nDefinir f Como Forma <- Forma.Triangulo(1);\nFinAlgoritmo\n",
    "en": "variant Shape\ncase Circle(radius as integer)\ncase Rectangle(width as integer, height as integer)\ncase Dot\nendVariant\nalgorithm P\ndefine f as Shape <- Shape.Triangle(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "undefinedMember",
        "severidad": "error"
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
    "es": "Variante Forma\nAlternativa Circulo(radio Como Entero)\nAlternativa Rectangulo(ancho Como Entero, alto Como Entero)\nAlternativa Punto\nFinVariante\nAlgoritmo P\nDefinir f Como Forma <- Forma.Rectangulo(1);\nFinAlgoritmo\n",
    "en": "variant Shape\ncase Circle(radius as integer)\ncase Rectangle(width as integer, height as integer)\ncase Dot\nendVariant\nalgorithm P\ndefine f as Shape <- Shape.Rectangle(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "argumentCountMismatch",
        "severidad": "error"
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
    "es": "Variante Forma\nAlternativa Circulo(radio Como Entero)\nAlternativa Rectangulo(ancho Como Entero, alto Como Entero)\nAlternativa Punto\nFinVariante\nAlgoritmo P\nDefinir f Como Forma <- Forma.Circulo(\"x\");\nFinAlgoritmo\n",
    "en": "variant Shape\ncase Circle(radius as integer)\ncase Rectangle(width as integer, height as integer)\ncase Dot\nendVariant\nalgorithm P\ndefine f as Shape <- Shape.Circle(\"x\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleArgumentType",
        "severidad": "error"
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
    "es": "Variante Forma\nAlternativa Circulo(radio Como Entero)\nAlternativa Rectangulo(ancho Como Entero, alto Como Entero)\nAlternativa Punto\nFinVariante\nAlgoritmo P\nDefinir f Como Forma <- Forma.Punto;\nEscribir f;\nFinAlgoritmo\n",
    "en": "variant Shape\ncase Circle(radius as integer)\ncase Rectangle(width as integer, height as integer)\ncase Dot\nendVariant\nalgorithm P\ndefine f as Shape <- Shape.Dot;\nwrite f;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variantRequiresPattern",
        "severidad": "error"
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
    "es": "Variante Forma\nAlternativa Circulo(radio Como Entero)\nAlternativa Rectangulo(ancho Como Entero, alto Como Entero)\nAlternativa Punto\nFinVariante\nAlgoritmo P\nDefinir f Como Forma <- Forma.Punto;\nEscribir f = Forma.Punto;\nFinAlgoritmo\n",
    "en": "variant Shape\ncase Circle(radius as integer)\ncase Rectangle(width as integer, height as integer)\ncase Dot\nendVariant\nalgorithm P\ndefine f as Shape <- Shape.Dot;\nwrite f = Shape.Dot;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variantRequiresPattern",
        "severidad": "error"
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
    "es": "Variante Estado\nAlternativa Activo(nivel Como Entero)\nAlternativa Inactivo\nFinVariante\nSubProceso nivelDe(e Como Estado) Como Entero\nDefinir n Como Entero <- -1;\nSegun e Hacer\nEstado.Activo(k): n <- k;\nEstado.Inactivo: n <- 0;\nFinSegun\nRetornar n;\nFinSubProceso\nClase Maquina\nDefinir estado Como Estado;\nMetodo Constructor(inicial Como Estado)\nEste.estado <- inicial;\nFinMetodo\nMetodo cambiar(otro Como Estado) Como Estado\nDefinir previo Como Estado <- Este.estado;\nEste.estado <- otro;\nRetornar previo;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir m Como Maquina <- Nuevo Maquina(Estado.Activo(2));\nDefinir viejo Como Estado <- m.cambiar(Estado.Inactivo);\nEscribir nivelDe(viejo);\nEscribir nivelDe(m.estado);\nDimension lista[2] Como Estado;\nlista[0] <- viejo;\nlista[1] <- Estado.Activo(9);\nEscribir nivelDe(lista[1]) + nivelDe(lista[0]);\nDefinir v Como Vector<Estado> <- Vector();\nv.Agregar(Estado.Activo(5));\nv.Agregar(Estado.Inactivo);\nEscribir nivelDe(v[0]), nivelDe(v[1]);\nFinAlgoritmo\n",
    "en": "variant State\ncase Active(level as integer)\ncase Idle\nendVariant\nsubroutine levelOf(e as State) as integer\ndefine n as integer <- -1;\nswitch e do\nState.Active(k): n <- k;\nState.Idle: n <- 0;\nendSwitch\nreturn n;\nendSubroutine\nclass Machine\ndefine state as State;\nmethod constructor(initial as State)\nthis.state <- initial;\nendMethod\nmethod change(fresh as State) as State\ndefine previous as State <- this.state;\nthis.state <- fresh;\nreturn previous;\nendMethod\nendClass\nalgorithm P\ndefine m as Machine <- new Machine(State.Active(2));\ndefine old as State <- m.change(State.Idle);\nwrite levelOf(old);\nwrite levelOf(m.state);\ndimension items[2] as State;\nitems[0] <- old;\nitems[1] <- State.Active(9);\nwrite levelOf(items[1]) + levelOf(items[0]);\ndefine v as vector<State> <- vector();\nv.append(State.Active(5));\nv.append(State.Idle);\nwrite levelOf(v[0]), levelOf(v[1]);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n0\n11\n50\n",
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
    "es": "Clase Caja\nDefinir n Como Entero;\nFinClase\nVariante Envio\nAlternativa Paquete(c Como Caja)\nFinVariante\nAlgoritmo P\nDefinir caja Como Caja <- Nuevo Caja();\ncaja.n <- 1;\nDefinir a Como Envio <- Envio.Paquete(caja);\nDefinir b Como Envio <- a;\ncaja.n <- 6;\nSegun b Hacer\nEnvio.Paquete(x): Escribir x.n;\nFinSegun\nFinAlgoritmo\n",
    "en": "class Crate\ndefine n as integer;\nendClass\nvariant Shipment\ncase Parcel(c as Crate)\nendVariant\nalgorithm P\ndefine crate as Crate <- new Crate();\ncrate.n <- 1;\ndefine a as Shipment <- Shipment.Parcel(crate);\ndefine b as Shipment <- a;\ncrate.n <- 6;\nswitch b do\nShipment.Parcel(x): write x.n;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "6\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro R1\nDefinir a, b Como Entero;\nFinRegistro\nRegistro R2\nDefinir a, b Como R1;\nFinRegistro\nRegistro R3\nDefinir a, b Como R2;\nFinRegistro\nRegistro R4\nDefinir a, b Como R3;\nFinRegistro\nRegistro R5\nDefinir a, b Como R4;\nFinRegistro\nRegistro R6\nDefinir a, b Como R5;\nFinRegistro\nRegistro R7\nDefinir a, b Como R6;\nFinRegistro\nRegistro R8\nDefinir a, b Como R7;\nFinRegistro\nRegistro R9\nDefinir a, b Como R8;\nFinRegistro\nRegistro R10\nDefinir a, b Como R9;\nFinRegistro\nRegistro R11\nDefinir a, b Como R10;\nFinRegistro\nRegistro R12\nDefinir a, b Como R11;\nFinRegistro\nRegistro R13\nDefinir a, b Como R12;\nFinRegistro\nRegistro R14\nDefinir a, b Como R13;\nFinRegistro\nRegistro R15\nDefinir a, b Como R14;\nFinRegistro\nVariante Ancha\nAlternativa Doble(x Como R15, w Como R15)\nFinVariante\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "record R1\ndefine a, b as integer;\nendRecord\nrecord R2\ndefine a, b as R1;\nendRecord\nrecord R3\ndefine a, b as R2;\nendRecord\nrecord R4\ndefine a, b as R3;\nendRecord\nrecord R5\ndefine a, b as R4;\nendRecord\nrecord R6\ndefine a, b as R5;\nendRecord\nrecord R7\ndefine a, b as R6;\nendRecord\nrecord R8\ndefine a, b as R7;\nendRecord\nrecord R9\ndefine a, b as R8;\nendRecord\nrecord R10\ndefine a, b as R9;\nendRecord\nrecord R11\ndefine a, b as R10;\nendRecord\nrecord R12\ndefine a, b as R11;\nendRecord\nrecord R13\ndefine a, b as R12;\nendRecord\nrecord R14\ndefine a, b as R13;\nendRecord\nrecord R15\ndefine a, b as R14;\nendRecord\nvariant Wide\ncase Pair(x as R15, y as R15)\nendVariant\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variantLayoutLimit",
        "severidad": "error"
      }
    ]
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
  "programas": {
    "es": "Variante Forma;\nAlternativa Circulo(radio Como Entero);\nAlternativa Rectangulo(ancho Como Entero, alto Como Entero);\nAlternativa Punto;\nFinVariante;\nAlgoritmo P\n  Definir f Como Forma <- Forma.Punto;\n  Segun f Hacer\n    Forma.Circulo(r): Escribir r;\n  FinSegun\nFinAlgoritmo\n",
    "en": "variant Shape;\ncase Circle(radius As Integer);\ncase Rectangle(width As Integer, height As Integer);\ncase Dot;\nendVariant;\nAlgorithm P\n  Define f As Shape <- Shape.Dot;\n  Switch f Do\n    Shape.Circle(r): Write r;\n  EndSwitch\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "nonExhaustiveSwitch",
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
  "programas": {
    "es": "Variante Forma\nAlternativa Circulo(radio Como Entero)\nAlternativa Rectangulo(ancho Como Entero, alto Como Entero)\nAlternativa Punto\nFinVariante\nAlgoritmo P\nDefinir f Como Forma <- Forma.Rectangulo(2, 5);\nSegun f Hacer\nForma.Circulo(r): Escribir r;\nDe Otro Modo: Escribir \"otra\";\nFinSegun\nFinAlgoritmo\n",
    "en": "variant Shape\ncase Circle(radius as integer)\ncase Rectangle(width as integer, height as integer)\ncase Dot\nendVariant\nalgorithm P\ndefine f as Shape <- Shape.Rectangle(2, 5);\nswitch f do\nShape.Circle(r): write r;\notherwise: write \"otra\";\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "otra\n",
    "terminacion": "completed"
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
  "programas": {
    "es": "Variante Forma\nAlternativa Circulo(radio Como Entero)\nAlternativa Rectangulo(ancho Como Entero, alto Como Entero)\nAlternativa Punto\nFinVariante\nAlgoritmo P\nDefinir f Como Forma <- Forma.Punto;\nSegun f Hacer\nForma.Punto: Escribir 1;\nForma.Punto: Escribir 2;\nDe Otro Modo: Escribir 3;\nFinSegun\nFinAlgoritmo\n",
    "en": "variant Shape\ncase Circle(radius as integer)\ncase Rectangle(width as integer, height as integer)\ncase Dot\nendVariant\nalgorithm P\ndefine f as Shape <- Shape.Dot;\nswitch f do\nShape.Dot: write 1;\nShape.Dot: write 2;\notherwise: write 3;\nendSwitch\nendAlgorithm\n"
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
  "id": "C16",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Variante Forma;\nAlternativa Circulo(radio Como Entero);\nAlternativa Rectangulo(ancho Como Entero, alto Como Entero);\nAlternativa Punto;\nFinVariante;\nAlgoritmo P\n  Definir f Como Forma <- Forma.Punto;\n  Segun f Hacer\n    Forma.Rectangulo(a): Escribir a;\n    De Otro Modo: Escribir 0;\n  FinSegun\nFinAlgoritmo\n",
    "en": "variant Shape;\ncase Circle(radius As Integer);\ncase Rectangle(width As Integer, height As Integer);\ncase Dot;\nendVariant;\nAlgorithm P\n  Define f As Shape <- Shape.Dot;\n  Switch f Do\n    Shape.Rectangle(a): Write a;\n    Otherwise: Write 0;\n  EndSwitch\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "argumentCountMismatch",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C17",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Variante Forma\nAlternativa Circulo(radio Como Entero)\nAlternativa Rectangulo(ancho Como Entero, alto Como Entero)\nAlternativa Punto\nFinVariante\nAlgoritmo P\nDefinir f Como Forma <- Forma.Punto;\nSegun f Hacer\nForma.Esfera: Escribir 1;\nDe Otro Modo: Escribir 0;\nFinSegun\nFinAlgoritmo\n",
    "en": "variant Shape\ncase Circle(radius as integer)\ncase Rectangle(width as integer, height as integer)\ncase Dot\nendVariant\nalgorithm P\ndefine f as Shape <- Shape.Dot;\nswitch f do\nShape.Sphere: write 1;\notherwise: write 0;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "undefinedMember",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C18",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Variante Forma\nAlternativa Circulo(radio Como Entero)\nAlternativa Rectangulo(ancho Como Entero, alto Como Entero)\nAlternativa Punto\nFinVariante\nVariante Otra\nAlternativa Punto\nFinVariante\nAlgoritmo P\nDefinir f Como Forma <- Forma.Punto;\nSegun f Hacer\nOtra.Punto: Escribir 1;\nDe Otro Modo: Escribir 0;\nFinSegun\nFinAlgoritmo\n",
    "en": "variant Shape\ncase Circle(radius as integer)\ncase Rectangle(width as integer, height as integer)\ncase Dot\nendVariant\nvariant Other\ncase Dot\nendVariant\nalgorithm P\ndefine f as Shape <- Shape.Dot;\nswitch f do\nOther.Dot: write 1;\notherwise: write 0;\nendSwitch\nendAlgorithm\n"
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
  }
}
```

```caso
{
  "id": "C19",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Variante Forma\nAlternativa Circulo(radio Como Entero)\nAlternativa Rectangulo(ancho Como Entero, alto Como Entero)\nAlternativa Punto\nFinVariante\nAlgoritmo P\nDefinir f Como Forma <- Forma.Circulo(4);\nSegun f Hacer\nDe Otro Modo: Escribir 0;\nForma.Punto: Escribir 1;\nFinSegun\nFinAlgoritmo\n",
    "en": "variant Shape\ncase Circle(radius as integer)\ncase Rectangle(width as integer, height as integer)\ncase Dot\nendVariant\nalgorithm P\ndefine f as Shape <- Shape.Circle(4);\nswitch f do\notherwise: write 0;\nShape.Dot: write 1;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
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
  "id": "C20",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Variante Arbol<T>\nAlternativa Hoja(valor Como T)\nAlternativa Vacio\nFinVariante\nSubProceso ver(a Como Arbol<Cadena>)\nSegun a Hacer\nArbol.Hoja(v): Escribir v;\nArbol.Vacio: Escribir \"vacio\";\nFinSegun\nFinSubProceso\nSubProceso sumar(a Como Arbol<Entero>, b Como Arbol<Entero>) Como Entero\nDefinir total Como Entero <- 0;\nSegun a Hacer\nArbol.Hoja(x): total <- total + x;\nArbol.Vacio: total <- total;\nFinSegun\nSegun b Hacer\nArbol.Hoja(w): total <- total + w;\nDe Otro Modo: total <- total;\nFinSegun\nRetornar total;\nFinSubProceso\nAlgoritmo P\nDefinir x Como Arbol<Entero> <- Arbol.Hoja(5);\nver(Arbol.Hoja(\"hola\"));\nver(Arbol.Vacio);\nEscribir sumar(x, Arbol.Hoja(2));\nFinAlgoritmo\n",
    "en": "variant Tree<T>\ncase Leaf(content as T)\ncase Empty\nendVariant\nsubroutine show(a as Tree<string>)\nswitch a do\nTree.Leaf(v): write v;\nTree.Empty: write \"vacio\";\nendSwitch\nendSubroutine\nsubroutine add(a as Tree<integer>, b as Tree<integer>) as integer\ndefine total as integer <- 0;\nswitch a do\nTree.Leaf(x): total <- total + x;\nTree.Empty: total <- total;\nendSwitch\nswitch b do\nTree.Leaf(y): total <- total + y;\notherwise: total <- total;\nendSwitch\nreturn total;\nendSubroutine\nalgorithm P\ndefine x as Tree<integer> <- Tree.Leaf(5);\nshow(Tree.Leaf(\"hola\"));\nshow(Tree.Empty);\nwrite add(x, Tree.Leaf(2));\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "hola\nvacio\n7\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C21",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Variante Arbol<T>\nAlternativa Hoja(valor Como T)\nAlternativa Vacio\nFinVariante\nSubProceso ver(a Como Arbol<Cadena>)\nSegun a Hacer\nArbol.Hoja(v): Escribir v;\nArbol.Vacio: Escribir \"vacio\";\nFinSegun\nFinSubProceso\nSubProceso sumar(a Como Arbol<Entero>, b Como Arbol<Entero>) Como Entero\nDefinir total Como Entero <- 0;\nSegun a Hacer\nArbol.Hoja(x): total <- total + x;\nArbol.Vacio: total <- total;\nFinSegun\nSegun b Hacer\nArbol.Hoja(w): total <- total + w;\nDe Otro Modo: total <- total;\nFinSegun\nRetornar total;\nFinSubProceso\nSubProceso usar<T>(x Como T)\nFinSubProceso\nAlgoritmo P\nusar(Arbol.Vacio);\nFinAlgoritmo\n",
    "en": "variant Tree<T>\ncase Leaf(content as T)\ncase Empty\nendVariant\nsubroutine show(a as Tree<string>)\nswitch a do\nTree.Leaf(v): write v;\nTree.Empty: write \"vacio\";\nendSwitch\nendSubroutine\nsubroutine add(a as Tree<integer>, b as Tree<integer>) as integer\ndefine total as integer <- 0;\nswitch a do\nTree.Leaf(x): total <- total + x;\nTree.Empty: total <- total;\nendSwitch\nswitch b do\nTree.Leaf(y): total <- total + y;\notherwise: total <- total;\nendSwitch\nreturn total;\nendSubroutine\nsubroutine use<T>(x as T)\nendSubroutine\nalgorithm P\nuse(Tree.Empty);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "ambiguousVariantType",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C22",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Variante Arbol<T>\nAlternativa Hoja(valor Como T)\nAlternativa Vacio\nFinVariante\nSubProceso ver(a Como Arbol<Cadena>)\nSegun a Hacer\nArbol.Hoja(v): Escribir v;\nArbol.Vacio: Escribir \"vacio\";\nFinSegun\nFinSubProceso\nSubProceso sumar(a Como Arbol<Entero>, b Como Arbol<Entero>) Como Entero\nDefinir total Como Entero <- 0;\nSegun a Hacer\nArbol.Hoja(x): total <- total + x;\nArbol.Vacio: total <- total;\nFinSegun\nSegun b Hacer\nArbol.Hoja(w): total <- total + w;\nDe Otro Modo: total <- total;\nFinSegun\nRetornar total;\nFinSubProceso\nSubProceso primero<T>(a Como Arbol<T>, defecto Como T) Como T\nDefinir r Como T <- defecto;\nSegun a Hacer\nArbol.Hoja(v): r <- v;\nArbol.Vacio: r <- defecto;\nFinSegun\nRetornar r;\nFinSubProceso\nAlgoritmo P\nEscribir primero(Arbol.Hoja(8), 0);\nEscribir primero(Arbol.Hoja(\"b\"), \"a\");\nFinAlgoritmo\n",
    "en": "variant Tree<T>\ncase Leaf(content as T)\ncase Empty\nendVariant\nsubroutine show(a as Tree<string>)\nswitch a do\nTree.Leaf(v): write v;\nTree.Empty: write \"vacio\";\nendSwitch\nendSubroutine\nsubroutine add(a as Tree<integer>, b as Tree<integer>) as integer\ndefine total as integer <- 0;\nswitch a do\nTree.Leaf(x): total <- total + x;\nTree.Empty: total <- total;\nendSwitch\nswitch b do\nTree.Leaf(y): total <- total + y;\notherwise: total <- total;\nendSwitch\nreturn total;\nendSubroutine\nsubroutine firstOf<T>(a as Tree<T>, fallback as T) as T\ndefine r as T <- fallback;\nswitch a do\nTree.Leaf(v): r <- v;\nTree.Empty: r <- fallback;\nendSwitch\nreturn r;\nendSubroutine\nalgorithm P\nwrite firstOf(Tree.Leaf(8), 0);\nwrite firstOf(Tree.Leaf(\"b\"), \"a\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "8\nb\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C23",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Variante Arbol<T>\nAlternativa Hoja(valor Como T)\nAlternativa Vacio\nFinVariante\nSubProceso ver(a Como Arbol<Cadena>)\nSegun a Hacer\nArbol.Hoja(v): Escribir v;\nArbol.Vacio: Escribir \"vacio\";\nFinSegun\nFinSubProceso\nSubProceso sumar(a Como Arbol<Entero>, b Como Arbol<Entero>) Como Entero\nDefinir total Como Entero <- 0;\nSegun a Hacer\nArbol.Hoja(x): total <- total + x;\nArbol.Vacio: total <- total;\nFinSegun\nSegun b Hacer\nArbol.Hoja(w): total <- total + w;\nDe Otro Modo: total <- total;\nFinSegun\nRetornar total;\nFinSubProceso\nAlgoritmo P\nDefinir x Como Arbol<Entero> <- Arbol.Hoja(\"no\");\nFinAlgoritmo\n",
    "en": "variant Tree<T>\ncase Leaf(content as T)\ncase Empty\nendVariant\nsubroutine show(a as Tree<string>)\nswitch a do\nTree.Leaf(v): write v;\nTree.Empty: write \"vacio\";\nendSwitch\nendSubroutine\nsubroutine add(a as Tree<integer>, b as Tree<integer>) as integer\ndefine total as integer <- 0;\nswitch a do\nTree.Leaf(x): total <- total + x;\nTree.Empty: total <- total;\nendSwitch\nswitch b do\nTree.Leaf(y): total <- total + y;\notherwise: total <- total;\nendSwitch\nreturn total;\nendSubroutine\nalgorithm P\ndefine x as Tree<integer> <- Tree.Leaf(\"no\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleArgumentType",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C24",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Variante Arbol<T>\nAlternativa Hoja(valor Como T)\nAlternativa Vacio\nFinVariante\nSubProceso ver(a Como Arbol<Cadena>)\nSegun a Hacer\nArbol.Hoja(v): Escribir v;\nArbol.Vacio: Escribir \"vacio\";\nFinSegun\nFinSubProceso\nSubProceso sumar(a Como Arbol<Entero>, b Como Arbol<Entero>) Como Entero\nDefinir total Como Entero <- 0;\nSegun a Hacer\nArbol.Hoja(x): total <- total + x;\nArbol.Vacio: total <- total;\nFinSegun\nSegun b Hacer\nArbol.Hoja(w): total <- total + w;\nDe Otro Modo: total <- total;\nFinSegun\nRetornar total;\nFinSubProceso\nAlgoritmo P\nDefinir x Como Arbol<Entero> <- Arbol.Hoja(1);\nDefinir w Como Arbol<Cadena> <- x;\nFinAlgoritmo\n",
    "en": "variant Tree<T>\ncase Leaf(content as T)\ncase Empty\nendVariant\nsubroutine show(a as Tree<string>)\nswitch a do\nTree.Leaf(v): write v;\nTree.Empty: write \"vacio\";\nendSwitch\nendSubroutine\nsubroutine add(a as Tree<integer>, b as Tree<integer>) as integer\ndefine total as integer <- 0;\nswitch a do\nTree.Leaf(x): total <- total + x;\nTree.Empty: total <- total;\nendSwitch\nswitch b do\nTree.Leaf(y): total <- total + y;\notherwise: total <- total;\nendSwitch\nreturn total;\nendSubroutine\nalgorithm P\ndefine x as Tree<integer> <- Tree.Leaf(1);\ndefine y as Tree<string> <- x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleTypesInAssignment",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C25",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Variante Forma\nAlternativa Punto\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "variant Shape\ncase Dot\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "unclosedVariant",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C26",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Variante Forma\nDefinir x Como Entero;\nFinVariante\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "variant Shape\ndefine x as integer;\nendVariant\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedVariantAlternative",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C27",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": [
                  "app/main"
                ],
                "dependencies": {
                  "geo": "geo"
                }
              },
              {
                "name": "geo",
                "root": "geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Importar geo.formas.Forma;\nAlgoritmo P\nDefinir f Como Forma <- Forma.Circulo(2);\nSegun f Hacer\nForma.Circulo(r): Escribir r * 10;\nForma.Punto: Escribir 0;\nFinSegun\nFinAlgoritmo\n"
              },
              {
                "path": "geo/formas",
                "source_id": 2,
                "text": "Publico Variante Forma\nAlternativa Circulo(radio Como Entero)\nAlternativa Punto\nFinVariante\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El caso C28 ejerce el mismo programa en inglés."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "20\n",
            "diagnostics": [],
            "project_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine",
    "aot"
  ]
}
```

```caso
{
  "id": "C28",
  "regla": "R1",
  "perfiles": [
    "en"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "execute_project",
        "arguments": {
          "profile": "en",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": [
                  "app/main"
                ],
                "dependencies": {
                  "geo": "geo"
                }
              },
              {
                "name": "geo",
                "root": "geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "import geo.formas.Forma;\nalgorithm P\ndefine f as Forma <- Forma.Circulo(2);\nswitch f do\nForma.Circulo(r): write r * 10;\nForma.Punto: write 0;\nendSwitch\nendAlgorithm\n"
              },
              {
                "path": "geo/formas",
                "source_id": 2,
                "text": "public variant Forma\ncase Circulo(radio as integer)\ncase Punto\nendVariant\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "es": "El caso C27 ejerce el mismo programa en español."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "20\n",
            "diagnostics": [],
            "project_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine",
    "aot"
  ]
}
```

```caso
{
  "id": "C29",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Variante Forma\nAlternativa Circulo(radio Como Entero)\nAlternativa Rectangulo(ancho Como Entero, alto Como Entero)\nAlternativa Punto\nFinVariante\nAlgoritmo P\nDefinir f Como Forma <- Forma.Circulo(1);\nSegun f Hacer\nForma.Circulo(r): r <- 5;\nDe Otro Modo: Escribir 0;\nFinSegun\nFinAlgoritmo\n",
    "en": "variant Shape\ncase Circle(radius as integer)\ncase Rectangle(width as integer, height as integer)\ncase Dot\nendVariant\nalgorithm P\ndefine f as Shape <- Shape.Circle(1);\nswitch f do\nShape.Circle(r): r <- 5;\notherwise: write 0;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "immutableBindingAssignment",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C30",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Variante Mascota;\nAlternativa Perro(nombre Como Cadena);\nAlternativa Pez(aletas Como Entero);\nFinVariante;\nSubProceso Describir(mascota Como Mascota)\n  Segun mascota Hacer\n    Mascota.Perro(nombre): Escribir nombre;\n    Mascota.Pez(aletas): Escribir aletas;\n  FinSegun\nFinSubProceso\n\nAlgoritmo Casa\n  Describir(Mascota.Perro(\"Toby\"));\n  Describir(Mascota.Pez(7));\nFinAlgoritmo\n",
    "en": "variant Pet;\ncase Dog(name As String);\ncase Fish(fins As Integer);\nendVariant;\nSubroutine Describe(pet As Pet)\n  Switch pet Do\n    Pet.Dog(name): Write name;\n    Pet.Fish(fins): Write fins;\n  EndSwitch\nEndSubroutine\n\nAlgorithm Home\n  Describe(Pet.Dog(\"Toby\"));\n  Describe(Pet.Fish(7));\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Toby\n7\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C31",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Variante Semaforo;\nAlternativa Rojo;\nAlternativa Amarillo;\nAlternativa Verde(segundos Como Entero);\nFinVariante;\nAlgoritmo Cruce\n  Definir luz Como Semaforo <- Semaforo.Verde(30);\n  Segun luz Hacer\n    Semaforo.Verde(segundos): Escribir segundos;\n    De Otro Modo: Escribir 0;\n  FinSegun\nFinAlgoritmo\n",
    "en": "variant TrafficLight;\ncase Red;\ncase Yellow;\ncase Green(seconds As Integer);\nendVariant;\nAlgorithm Crossing\n  Define light As TrafficLight <- TrafficLight.Green(30);\n  Switch light Do\n    TrafficLight.Green(seconds): Write seconds;\n    Otherwise: Write 0;\n  EndSwitch\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "30\n",
    "terminacion": "completed"
  }
}
```
