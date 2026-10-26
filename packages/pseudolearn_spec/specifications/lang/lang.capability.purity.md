---
{
  "formato": "see/1",
  "id": "LANG.CAPABILITY.PURITY",
  "titulo": "Pureza y efectos transitivos en subprogramas",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Prohibición de efectos directos o transitivos en funciones puras, propagación sobre el grafo de llamadas y coherencia en clausuras e interfaces.",
  "titulo_en": "Subprogram purity and transitive side effects",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.PROGRAM.STRUCTURE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.CAPABILITY.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "DIAG.CATALOG",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-pg3"
  ]
}
---

# Pureza y efectos transitivos en subprogramas

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una Funcion o Function es estrictamente pura. Tiene prohibido realizar directamente operaciones de entrada o salida, modificar estado externo u operar sobre capacidades con efectos secundarios.",
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
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionSideEffect",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "Funcion F() : Entero\nEscribir 1;\nRetornar 1;\nFinFuncion\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "function F() : integer\nwrite 1;\nreturn 1;\nendFunction\nalgorithm P\nendAlgorithm\n"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "programas": {
    "es": "Funcion Cuadrado(x: Entero) : Entero\nRetornar x * x;\nFinFuncion\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "function Cuadrado(x: integer) : integer\nreturn x * x;\nendFunction\nalgorithm P\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El análisis semántico comprueba la pureza transitiva hasta punto fijo sobre el grafo de llamadas del programa. Si una Funcion invoca a otra unidad que realiza efectos secundarios, la función llamadora es rechazada con pureFunctionTransitiveSideEffect.",
  "verificacion": [
    "C3"
  ]
}
```

```caso
{
  "id": "C3",
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
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionTransitiveSideEffect",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "SubProceso Efecto()\nEscribir 2;\nFinSubProceso\nFuncion F() : Entero\nEfecto();\nRetornar 0;\nFinFuncion\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "subProcess Efecto()\nwrite 2;\nendSubProcess\nfunction F() : integer\nEfecto();\nreturn 0;\nendFunction\nalgorithm P\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "No se permite pasar ni asignar una clausura o subprograma con efectos secundarios en un contexto donde el tipo esperado es una función pura Funcion. Las discrepancias de pureza son detectadas estáticamente.",
  "verificacion": [
    "C4"
  ]
}
```

```caso
{
  "id": "C4",
  "regla": "R3",
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
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionTransitiveSideEffect",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "SubProceso ConEfecto(x: Entero) : Entero\nEscribir x;\nRetornar x;\nFinSubProceso\nFuncion Aplicar(fn: Funcion(Entero) : Entero, v: Entero) : Entero\nRetornar fn(v);\nFinFuncion\nAlgoritmo P\nAplicar(ConEfecto, 5);\nFinAlgoritmo\n",
    "en": "subProcess ConEfecto(x: integer) : integer\nwrite x;\nreturn x;\nendSubProcess\nfunction Aplicar(fn: function(integer) : integer, v: integer) : integer\nreturn fn(v);\nendFunction\nalgorithm P\nAplicar(ConEfecto, 5);\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cuando una Interfaz declara un método de tipo Funcion, cualquier implementación concreta en una clase debe ser estrictamente pura. Toda implementación que realice efectos secundarios es rechazada con pureFunctionInterfaceImpurity.",
  "verificacion": [
    "C5"
  ]
}
```

```caso
{
  "id": "C5",
  "regla": "R4",
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
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionInterfaceImpurity",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "Interfaz Calculable\nFuncion Calcular() : Entero;\nFinInterfaz\nClase Demo Implementa Calculable\nFuncion Calcular() : Entero\nEscribir 1;\nRetornar 1;\nFinFuncion\nFinClase\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "interface Calculable\nfunction Calcular() : integer;\nendInterface\nclass Demo implements Calculable\nfunction Calcular() : integer\nwrite 1;\nreturn 1;\nendFunction\nendClass\nalgorithm P\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "SubProceso y Algoritmo son las unidades del lenguaje autorizadas para poseer efectos secundarios y ejecutar operaciones sobre el entorno y capacidades.",
  "verificacion": [
    "C6"
  ]
}
```

```caso
{
  "id": "C6",
  "regla": "R5",
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
  "espera": {
    "salida": "subproceso_ok\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Saludar()\nEscribir \"subproceso_ok\";\nFinSubProceso\nAlgoritmo P\nSaludar();\nFinAlgoritmo\n",
    "en": "subProcess Saludar()\nwrite \"subproceso_ok\";\nendSubProcess\nalgorithm P\nSaludar();\nendAlgorithm\n"
  }
}
```
