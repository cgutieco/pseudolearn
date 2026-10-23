---
{
  "formato": "see/1",
  "id": "IR.SOURCE-MAP",
  "titulo": "Correspondencia con el texto fuente",
  "dominio": "ri",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Tramo fuente de cada instrucción que atrapa u observa.",
  "depende_de": [
    {
      "id": "IR.INSTRUCTIONS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.SOURCE.POSITION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Source map",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Correspondencia con el texto fuente

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada instrucción que puede atrapar u observar lleva el tramo de su nodo fuente: la sentencia para stmt.enter y stmt.exit, la condición o el selector para decide.*, la expresión de llamada para call, la sentencia Escribir o Leer para out.write e in.read. Para las trampas, el tramo es el símbolo del operador en las operaciones con operador, la expresión de llamada en las llamadas y funciones incorporadas, el designador en las lecturas sin valor y en los accesos a elementos, la sentencia Dimension en la creación de arreglos y la expresión Nuevo en la creación de objetos. El tramo lleva el ID de archivo de su fuente; dos archivos pueden tener rangos locales iguales sin compartir procedencia. El documento suelto conserva el ID cero y la forma textual sin calificador; los demás IDs se escriben como `@f<ID>:`. No se combinan tramos de IDs distintos.",
  "verificacion": [
    "C1",
    "C3"
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
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "ir",
  "espera": {
    "ri": {
      "aceptada": true
    }
  },
  "programa_ri": "module P es\nfunc @main() -> unit {\nb0() mass 1:\n  stmt.enter @2:1-2:12\n  %0 = const.i64 1\n  out.write %0, newline @2:1-2:12\n  stmt.exit @2:1-2:12\n  return\n}\n"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un fallo informa el tramo de la instrucción que atrapó, también dentro de un subprograma; la línea de un evento es la línea de inicio del tramo de su instrucción.",
  "verificacion": [
    "C2"
  ]
}
```

```caso
{
  "id": "C2",
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
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "divisionByZero"
    },
    "diagnosticos": [
      {
        "codigo": "divisionByZero",
        "severidad": "error",
        "tramo": {
          "start": {
            "line": 3,
            "column": 9
          },
          "end": {
            "line": 3,
            "column": 12
          }
        }
      }
    ]
  },
  "programa": "SubProceso f(n Como Entero) Como Entero\nDefinir x Como Entero;\nx <- 10 div n;\nRetornar x;\nFinSubProceso\nAlgoritmo P\nEscribir f(0);\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C3",
  "regla": "R1",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "ir",
  "espera": {
    "ri": {"aceptada": true}
  },
  "programa_ri": "module P es\nfunc @main() -> unit {\nb0() mass 1:\n  stmt.enter @f1:2:1-2:12\n  %0 = const.i64 1\n  out.write %0, newline @f2:2:1-2:12\n  stmt.exit @f1:2:1-2:12\n  return\n}\n"
}
```
