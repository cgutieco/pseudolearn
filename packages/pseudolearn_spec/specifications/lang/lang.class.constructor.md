---
{
  "formato": "see/1",
  "id": "LANG.CLASS.CONSTRUCTOR",
  "titulo": "Constructores",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Constructores.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.CLASS.METHODS",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Constructores

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un constructor se declara Metodo Constructor(...), sin visibilidad ni tipo de retorno. Hay como máximo uno; omitido existe uno implícito sin parámetros que no inicializa campos. Antes del cuerpo se construye la superclase. Si su constructor exige argumentos, Super.Constructor(...) debe ser la primera sentencia. Retornar sin valor permite salida; con valor es error. Nombrar el método como la clase es sintáctico pedagógico.",
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
    "es": "Clase C\nPrivado Definir value Como Entero;\nMetodo Constructor(value Como Entero)\nEste.value <- value;\nFinMetodo\nMetodo get() Como Entero\nRetornar Este.value;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir x Como C;\nx <- Nuevo C(8);\nEscribir x.get();\nFinAlgoritmo\n",
    "en": "class C\nprivate define value as integer;\nmethod constructor(value as integer)\nthis.value <- value;\nendMethod\nmethod get() as integer\nreturn this.value;\nendMethod\nendClass\nalgorithm P\ndefine x as C;\nx <- new C(8);\nwrite x.get();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "8\n",
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
    "es": "Clase C\nFinClase\nAlgoritmo P\nDefinir x Como C;\nx <- Nuevo C();\nFinAlgoritmo\n",
    "en": "class C\nendClass\nalgorithm P\ndefine x as C;\nx <- new C();\nendAlgorithm\n"
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
    "es": "Clase C\nMetodo Constructor() Como Entero\nFinMetodo\nFinClase\nAlgoritmo P\n\nFinAlgoritmo\n",
    "en": "class C\nmethod constructor() as integer\nendMethod\nendClass\nalgorithm P\n\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "constructorReturnTypeNotAllowed",
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
