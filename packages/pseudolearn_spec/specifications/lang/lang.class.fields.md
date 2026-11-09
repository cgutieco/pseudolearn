---
{
  "formato": "see/1",
  "id": "LANG.CLASS.FIELDS",
  "titulo": "Atributos y visibilidad",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "revisado_por": [
    "César Antonio Gutiérrez Contreras"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Atributos y visibilidad.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.CLASS.DECLARATION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Atributos y visibilidad

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un atributo se declara con nombre y tipo y visibilidad opcional. Solo hay público y privado; omitida es pública. No admite inicializador y empieza sin valor. Este es obligatorio para referir atributos del objeto actual. Un atributo privado solo es accesible desde el código de su clase, no desde subclase ni algoritmo; miembros duplicados y sombra de heredado se rechazan.",
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
    "es": "Clase C\nPrivado Definir value Como Entero;\nMetodo Constructor(value Como Entero)\nEste.value <- value;\nFinMetodo\nMetodo get() Como Entero\nRetornar Este.value;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir x Como C <- Nuevo C(7);\nEscribir x.get();\nFinAlgoritmo\n",
    "en": "class C\nprivate define value as integer;\nmethod constructor(value as integer)\nthis.value <- value;\nendMethod\nmethod get() as integer\nreturn this.value;\nendMethod\nendClass\nalgorithm P\ndefine x as C <- new C(7);\nwrite x.get();\nendAlgorithm\n"
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
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase C\n  Privado Definir value Como Entero;\n  Metodo Constructor(value Como Entero)\n    Este.value <- value;\n  FinMetodo\n  Metodo get() Como Entero\n    Retornar Este.value;\n  FinMetodo\nFinClase\n\nAlgoritmo P\n  Definir x Como C <- Nuevo C(7);\n  Escribir x.value;\nFinAlgoritmo\n",
    "en": "Class C\n  Private Define value As Integer;\n  Method Constructor(value As Integer)\n    This.value <- value;\n  EndMethod\n  Method get() As Integer\n    Return This.value;\n  EndMethod\nEndClass\n\nAlgorithm P\n  Define x As C <- New C(7);\n  Write x.value;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "privateMemberAccess",
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
    "es": "Clase Cuenta\n  Privado Definir saldo Como Entero;\n  Metodo Constructor()\n    Este.saldo <- 0;\n  FinMetodo\n  Publico Metodo Depositar(monto Como Entero)\n    Este.saldo <- Este.saldo + monto;\n  FinMetodo\n  Publico Metodo VerSaldo() Como Entero\n    Retornar Este.saldo;\n  FinMetodo\nFinClase\n\nAlgoritmo Banco\n  Definir miCuenta Como Cuenta <- Nuevo Cuenta();\n  miCuenta.Depositar(30);\n  miCuenta.Depositar(20);\n  Escribir miCuenta.VerSaldo();\nFinAlgoritmo\n",
    "en": "Class Account\n  Private Define balance As Integer;\n  Method Constructor()\n    This.balance <- 0;\n  EndMethod\n  Public Method Deposit(amount As Integer)\n    This.balance <- This.balance + amount;\n  EndMethod\n  Public Method GetBalance() As Integer\n    Return This.balance;\n  EndMethod\nEndClass\n\nAlgorithm Bank\n  Define myAccount As Account <- New Account();\n  myAccount.Deposit(30);\n  myAccount.Deposit(20);\n  Write myAccount.GetBalance();\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "50\n",
    "terminacion": "completed"
  }
}
```
