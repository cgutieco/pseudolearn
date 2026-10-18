---
{
  "formato": "see/1",
  "id": "LANG.SYNTAX.GRAMMAR",
  "titulo": "Gramática abstracta formal",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "0.2.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Gramática abstracta formal.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.PROGRAM.STRUCTURE",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.STMT.TERMINATION",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.SUBPROGRAM.DECLARATION",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.CLASS.DECLARATION",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.OPS.PRECEDENCE",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Gramática abstracta formal

```definicion
{
  "id": "D1",
  "termino": "grammar",
  "texto": "Producciones EBNF abstractas de la edición 2026.",
  "valor": {
    "inicial": "program",
    "producciones": {
      "program": "trivia, { subprogram | classUnit }, algorithmUnit, { subprogram | classUnit }, trivia, endOfFile",
      "algorithmUnit": "@algorithm, identifier, line, body, @endAlgorithm, line",
      "body": "{ trivia | statement | conditional | switch | whileLoop | repeatLoop | forLoop }",
      "statement": "( declaration | dimensionDeclaration | assignmentStatement | output | input | callStatement | returnStatement ), terminator",
      "declaration": "@declare, names, @typeConnector, type",
      "names": "identifier, { @comma, identifier }",
      "type": "@integerType | @realType | @booleanType | @characterType | @stringType | identifier",
      "dimensionDeclaration": "@dimension, dimensioned, { @comma, dimensioned }, @typeConnector, type",
      "dimensioned": "identifier, @leftBracket, expressions, @rightBracket",
      "assignmentStatement": "designator, @assignment, expression",
      "designator": "identifier, { @leftBracket, expressions, @rightBracket | @dot, identifier }",
      "output": "@write, [ expressions ], [ @withoutNewline ]",
      "input": "@read, designator, { @comma, designator }",
      "conditional": "@ifKeyword, expression, @then, line, body, [ @elseKeyword, line, body ], @endIf, line",
      "switch": "@switchKeyword, expression, @doKeyword, line, { labels, @branchSeparator, body }, [ @defaultCase, @branchSeparator, body ], @endSwitch, line",
      "labels": "literal, { @comma, literal }",
      "signedInteger": "[ @plus | @minus ], integerLiteral",
      "whileLoop": "@whileKeyword, expression, @doKeyword, line, body, @endWhile, line",
      "repeatLoop": "@repeat, line, body, @until, expression, line",
      "forLoop": "@forKeyword, identifier, @assignment, expression, @to, expression, [ @step, expression ], @doKeyword, line, body, @endFor, line",
      "subprogram": "@subroutine, identifier, parameters, [ @typeConnector, type ], line, body, @endSubroutine, line",
      "parameters": "@leftParenthesis, [ parameter, { @comma, parameter } ], @rightParenthesis",
      "parameter": "identifier, [ @leftBracket, { @comma }, @rightBracket ], [ @typeConnector, type ], [ @byValue | @byReference ]",
      "returnStatement": "@returnKeyword, [ expression ]",
      "classUnit": "@classKeyword, identifier, [ @inheritsFrom, identifier ], line, { fieldDeclaration | methodMember | constructorMember }, @endClass, line",
      "visibility": "@publicVisibility | @privateVisibility",
      "fieldDeclaration": "[ visibility ], ( declaration | dimensionDeclaration ), terminator",
      "methodMember": "[ visibility ], @method, identifier, parameters, [ @typeConnector, type ], line, body, @endMethod, line",
      "constructorMember": "@method, @constructor, parameters, line, body, @endMethod, line",
      "expressions": "expression, { @comma, expression }",
      "expression": "disjunction",
      "disjunction": "conjunction, { @or, conjunction }",
      "conjunction": "equality, { @and, equality }",
      "equality": "ordering, { ( @equal | @notEqual ), ordering }",
      "ordering": "addition, { ( @lessThan | @lessThanOrEqual | @greaterThan | @greaterThanOrEqual ), addition }",
      "addition": "multiplication, { ( @plus | @minus ), multiplication }",
      "multiplication": "powerExpression, { ( @multiply | @divide | @integerDivide | @modulo ), powerExpression }",
      "powerExpression": "unary, [ @power, powerExpression ]",
      "unary": "( @plus | @minus | @not ), unary | postfix",
      "postfix": "primary, { @dot, identifier, [ arguments ] | @leftBracket, expressions, @rightBracket }",
      "primary": "literal | identifier, [ arguments ] | @leftParenthesis, expression, @rightParenthesis | instantiation | @thisObject, @dot, identifier, [ arguments ] | @superClass, @dot, ( identifier | @constructor ), arguments",
      "callStatement": "identifier, arguments | postfix, @dot, identifier, arguments | @superClass, @dot, ( identifier | @constructor ), arguments",
      "arguments": "@leftParenthesis, [ expressions ], @rightParenthesis",
      "instantiation": "@newInstance, identifier, arguments",
      "literal": "signedInteger | realLiteral | characterLiteral | stringLiteral | @booleanTrue | @booleanFalse",
      "terminator": "@semicolon | endOfLine",
      "line": "endOfLine | endOfFile",
      "trivia": "whitespace | comment | endOfLine"
    },
    "terminales": [
      "algorithm",
      "and",
      "assignment",
      "booleanFalse",
      "booleanTrue",
      "booleanType",
      "branchSeparator",
      "byReference",
      "byValue",
      "characterLiteral",
      "characterType",
      "classKeyword",
      "comma",
      "comment",
      "constructor",
      "declare",
      "defaultCase",
      "dimension",
      "divide",
      "doKeyword",
      "dot",
      "elseKeyword",
      "endAlgorithm",
      "endClass",
      "endFor",
      "endIf",
      "endMethod",
      "endOfFile",
      "endOfLine",
      "endSubroutine",
      "endSwitch",
      "endWhile",
      "equal",
      "forKeyword",
      "greaterThan",
      "greaterThanOrEqual",
      "identifier",
      "ifKeyword",
      "inheritsFrom",
      "integerDivide",
      "integerLiteral",
      "integerType",
      "leftBracket",
      "leftParenthesis",
      "lessThan",
      "lessThanOrEqual",
      "method",
      "minus",
      "modulo",
      "multiply",
      "newInstance",
      "not",
      "notEqual",
      "or",
      "plus",
      "power",
      "privateVisibility",
      "publicVisibility",
      "quote",
      "read",
      "realLiteral",
      "realType",
      "repeat",
      "returnKeyword",
      "rightBracket",
      "rightParenthesis",
      "semicolon",
      "step",
      "stringLiteral",
      "stringType",
      "subroutine",
      "superClass",
      "switchKeyword",
      "then",
      "thisObject",
      "to",
      "typeConnector",
      "until",
      "whileKeyword",
      "whitespace",
      "withoutNewline",
      "write"
    ]
  }
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "D1 define la EBNF normativa con terminales de identidad abstracta, no lexemas de idioma. Coma es concatenación, | alternativa, [] opcional y {} repetición. Identificadores, literales, trivia y EOF son categorías léxicas. Las exigencias de rigor y restricciones de designador, anidamiento, retorno y listas se aplican además de las producciones; estricto exige semicolon en sentencias simples. El postfix no admite índices encadenados del mismo arreglo. Cada producción debe resolver sus referencias y ser alcanzable desde program.",
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
    "es": "Algoritmo P\n\nFinAlgoritmo\n",
    "en": "algorithm P\n\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
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
    "es": "SubProceso f(value Como Entero) Como Entero\nRetornar value + 1;\nFinSubProceso\nAlgoritmo P\nEscribir f(1);\nFinAlgoritmo\n",
    "en": "subroutine f(value as integer) as integer\nreturn value + 1;\nendSubroutine\nalgorithm P\nwrite f(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
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
    "es": "Algoritmo P\nEscribir ();\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite ();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "emptyParentheses",
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
