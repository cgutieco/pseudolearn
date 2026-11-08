# PseudoLearn: language sheet for agents

Generated from the PseudoLearn specification corpus. It is the reference an agent must follow when reading or writing PseudoLearn: the language looks like PSeInt, but it is not PSeInt. Every normative statement cites the corpus rule behind it; rule texts are quoted in Spanish, the corpus language.

## Golden rules

- Check every program with the analysis tool before showing it; never teach code that does not pass.
- Write in the document profile. If you generate in another profile, translate it with the translation tool, not by hand.
- Every simple statement ends with a semicolon.
- Arrays start at 0.
- Every variable is declared with its type before use.
- When unsure, search the specification instead of assuming PSeInt behaviour.

## Vocabulary

Canonical lexemes per profile. The Spanish profile ignores case and accents in the vocabulary; the English profile is case sensitive. A program uses a single profile.

| Identity | es | en |
|---|---|---|
| algorithm | `Algoritmo` | `algorithm` |
| and | `Y` | `and` |
| assignment | `<-` | `<-` |
| awaitKeyword | `Aguardar` | `await` |
| booleanFalse | `Falso` | `false` |
| booleanTrue | `Verdadero` | `true` |
| booleanType | `Logico` | `boolean` |
| branchSeparator | `:` | `:` |
| byReference | `Por Referencia` | `by reference` |
| byValue | `Por Valor` | `by value` |
| characterType | `Caracter` | `character` |
| classKeyword | `Clase` | `class` |
| comma | `,` | `,` |
| constantKeyword | `Constante` | `constant` |
| constructor | `Constructor` | `constructor` |
| declare | `Definir` | `define` |
| defaultCase | `De Otro Modo` | `otherwise` |
| dimension | `Dimension` | `dimension` |
| discardKeyword | `Descartar` | `discard` |
| divide | `/` | `/` |
| doKeyword | `Hacer` | `do` |
| dot | `.` | `.` |
| elseKeyword | `Sino` | `else` |
| endAlgorithm | `FinAlgoritmo` | `endAlgorithm` |
| endClass | `FinClase` | `endClass` |
| endEnum | `FinEnumerado` | `endEnum` |
| endFor | `FinPara` | `endFor` |
| endFunction | `FinFuncion` | `endFunction` |
| endIf | `FinSi` | `endIf` |
| endMethod | `FinMetodo` | `endMethod` |
| endRecord | `FinRegistro` | `endRecord` |
| endSelect | `FinElegir` | `endSelect` |
| endSubroutine | `FinSubProceso` | `endSubroutine` |
| endSwitch | `FinSegun` | `endSwitch` |
| endTasks | `FinTareas` | `endTasks` |
| endWhile | `FinMientras` | `endWhile` |
| enumKeyword | `Enumerado` | `enum` |
| equal | `=` | `=` |
| errorVariant | `Error` | `failure` |
| exportKeyword | `Exportar` | `export` |
| forKeyword | `Para` | `for` |
| function | `Funcion` | `function` |
| greaterThan | `>` | `>` |
| greaterThanOrEqual | `>=` | `>=` |
| ifKeyword | `Si` | `if` |
| importKeyword | `Importar` | `import` |
| inheritsFrom | `Hereda De` | `inherits from` |
| integerDivide | `div` | `div` |
| integerType | `Entero` | `integer` |
| jsonErrorCodeType | `CodigoErrorJson` | `JsonErrorCode` |
| jsonErrorColumnField | `JsonColumna` | `jsonColumn` |
| jsonErrorLineField | `JsonLinea` | `jsonLine` |
| jsonErrorType | `ErrorJson` | `JsonError` |
| jsonKindType | `TipoJson` | `JsonKind` |
| jsonValueType | `ValorJson` | `JsonValue` |
| leftBracket | `[` | `[` |
| leftParenthesis | `(` | `(` |
| lessThan | `<` | `<` |
| lessThanOrEqual | `<=` | `<=` |
| method | `Metodo` | `method` |
| minus | `-` | `-` |
| modulo | `mod` | `mod` |
| multiply | `*` | `*` |
| newInstance | `Nuevo` | `new` |
| noneVariant | `Nada` | `none` |
| not | `NO` | `not` |
| notEqual | `<>` | `<>` |
| optionalType | `Opcional` | `optional` |
| or | `O` | `or` |
| plus | `+` | `+` |
| power | `^` | `^` |
| privateVisibility | `Privado` | `private` |
| propagateKeyword | `Propagar` | `propagate` |
| publicVisibility | `Publico` | `public` |
| quote | `"` | `"` |
| read | `Leer` | `read` |
| realType | `Real` | `real` |
| recordKeyword | `Registro` | `record` |
| repeat | `Repetir` | `repeat` |
| resultType | `Resultado` | `result` |
| returnKeyword | `Retornar` | `return` |
| rightBracket | `]` | `]` |
| rightParenthesis | `)` | `)` |
| selectKeyword | `Elegir` | `select` |
| semicolon | `;` | `;` |
| someVariant | `Algo` | `some` |
| spawnKeyword | `Lanzar` | `spawn` |
| step | `Con Paso` | `step` |
| stringType | `Cadena` | `string` |
| subroutine | `SubProceso` | `subroutine` |
| successVariant | `Exito` | `success` |
| superClass | `Super` | `super` |
| switchKeyword | `Segun` | `switch` |
| taskType | `Tarea` | `task` |
| tasksKeyword | `Tareas` | `tasks` |
| then | `Entonces` | `then` |
| thisObject | `Este` | `this` |
| to | `Hasta` | `to` |
| typeConnector | `Como` | `as` |
| until | `Hasta Que` | `until` |
| whileKeyword | `Mientras` | `while` |
| withoutNewline | `Sin Saltar` | `without newline` |
| write | `Escribir` | `write` |

## Library

| es | en | Parameters | Result |
|---|---|---|---|
| `abs` | `abs` | numeric | real |
| `acos` | `acos` | numeric | real |
| `asen` | `asin` | numeric | real |
| `atan` | `atan` | numeric | real |
| `atan2` | `atan2` | numeric, numeric | real |
| `techo` | `ceil` | numeric | integer |
| `CaracterEn` | `charAt` | string, integer | character |
| `CodigoDe` | `charCode` | character | integer |
| `CaracterDesde` | `charFromCode` | integer | character |
| `Concatenar` | `concat` | string, string | string |
| `Contiene` | `contains` | string, string | boolean |
| `cos` | `cos` | numeric | real |
| `TerminaCon` | `endsWith` | string, string | boolean |
| `exp` | `exp` | numeric | real |
| `piso` | `floor` | numeric | integer |
| `Unir` | `join` | stringVector, string | string |
| `Longitud` | `length` | string | integer |
| `log10` | `log10` | numeric | real |
| `log2` | `log2` | numeric | real |
| `max` | `max` | numeric, numeric | widestNumeric |
| `min` | `min` | numeric, numeric | widestNumeric |
| `ln` | `ln` | numeric | real |
| `PosicionDe` | `indexOf` | string, string | optionalInteger |
| `azar` | `random` | integer | integer |
| `Aleatorio` | `randomBetween` | integer, integer | integer |
| `AzarReal` | `randomReal` |  | real |
| `Reemplazar` | `replace` | string, string, string | string |
| `redon` | `round` | real | integer |
| `Copiar` | `copy` | anyClass | sameAsFirstArgument |
| `sen` | `sin` | numeric | real |
| `Instantanea` | `snapshot` | anySnapshot | immutableOfFirstArgument |
| `Dividir` | `split` | string, string | stringVector |
| `rc` | `sqrt` | numeric | real |
| `EmpiezaCon` | `startsWith` | string, string | boolean |
| `Subcadena` | `substring` | string, integer, integer | string |
| `tan` | `tan` | numeric | real |
| `AEntero` | `toInteger` | string | integer |
| `AReal` | `toReal` | string | real |
| `ATexto` | `toText` | anyPrimitive | string |
| `Recortar` | `trim` | string | string |
| `trunc` | `trunc` | real | integer |

### Capability operations

They need a capability granted by the host; none are granted by default.

- `SolicitarConsola` / `requestConsole` () → console
- `SolicitarArgumentos` / `requestArguments` () → arguments
- `SolicitarDirectorio` / `requestDirectory` (text) → directory
- `SolicitarReloj` / `requestClock` () → clock
- `SolicitarTemporizador` / `requestTimer` () → timer
- `EscribirTexto` / `writeText` (text) → integer
- `EscribirError` / `writeError` (text) → integer
- `EstablecerCodigoSalida` / `setExitCode` (integer) → integer
- `Valores` / `values` () → text_list
- `Subdirectorio` / `subdirectory` (text, text) → directory
- `Abrir` / `open` (text, text) → file
- `Cerrar` / `close` () → boolean
- `LeerBytes` / `readBytes` () → bytes
- `LeerTexto` / `readText` () → text
- `EscribirBytes` / `writeBytes` (bytes) → integer
- `EscribirTexto` / `writeText` (text) → integer
- `Cerrar` / `close` () → boolean
- `Ahora` / `now` () → integer
- `Esperar` / `wait` (integer) → integer
- `Bytes` / `Bytes` () → bytes
- `Longitud` / `length` () → integer
- `En` / `at` (integer) → integer
- `TextoUtf8` / `utf8Text` () → text
- `BytesDesdeTexto` / `bytesFromText` (text) → bytes
- `Segmento` / `segment` (integer, integer) → bytes
- `Unir` / `join` (bytes) → bytes
- `AnalizarJson` / `parseJson` (text) → json_result
- `TextoJson` / `jsonText` (json_value) → text
- `JsonNulo` / `jsonNull` () → json_value
- `JsonLogico` / `jsonBoolean` (boolean) → json_value
- `JsonEntero` / `jsonInteger` (integer) → json_value
- `JsonReal` / `jsonReal` (real) → json_value
- `JsonCadena` / `jsonString` (text) → json_value
- `ArregloJson` / `jsonArray` () → json_value
- `ObjetoJson` / `jsonObject` () → json_value
- `Tipo` / `kind` () → json_kind
- `ComoLogico` / `asBoolean` () → optional_boolean
- `ComoEntero` / `asInteger` () → optional_integer
- `ComoReal` / `asReal` () → optional_real
- `ComoCadena` / `asText` () → optional_text
- `Longitud` / `length` () → integer
- `Elemento` / `element` (integer) → optional_json_value
- `Campo` / `field` (text) → optional_json_value
- `Claves` / `keys` () → text_list
- `ConElemento` / `withElement` (json_value) → json_value
- `ConCampo` / `withField` (text, json_value) → json_value
- `SolicitarRed` / `requestNetwork` () → network
- `Limitar` / `restrict` (text) → network
- `Enviar` / `send` (http_request) → http_response
- `Cerrar` / `close` () → boolean
- `PeticionHttp` / `HttpRequest` (http_method, text) → http_request
- `ConCabecera` / `withHeader` (text, text) → http_request
- `ConCuerpo` / `withBody` (bytes) → http_request
- `ConCuerpoTexto` / `withTextBody` (text) → http_request
- `ConLimiteRespuesta` / `withResponseLimit` (integer) → http_request
- `ConTiempoMaximo` / `withTimeout` (integer) → http_request
- `Redirigida` / `redirected` (http_response) → http_request
- `Estado` / `status` () → integer
- `EsExito` / `isSuccess` () → boolean
- `Cabecera` / `header` (text) → optional_text
- `NombresCabeceras` / `headerNames` () → text_list
- `Cuerpo` / `body` () → bytes
- `CuerpoTexto` / `textBody` () → text
- `Url` / `url` () → text
- `AMayusculas` / `toUpper` (text) → text
- `AMinusculas` / `toLower` (text) → text
- `Decimales` / `decimals` (real, integer) → text
- `RellenarIzquierda` / `padLeft` (text, integer, text) → text
- `RellenarDerecha` / `padRight` (text, integer, text) → text
- `Existe` / `exists` (text) → boolean
- `EsDirectorio` / `isDirectory` (text) → boolean
- `Listar` / `list` (text) → text_list
- `Borrar` / `delete` (text) → boolean
- `Renombrar` / `rename` (text, text) → boolean
- `CrearDirectorio` / `createDirectory` (text) → boolean
- `AgregarBytes` / `appendBytes` (bytes) → integer
- `AgregarTexto` / `appendText` (text) → integer
- `SolicitarEntorno` / `requestEnvironment` () → environment
- `Obtener` / `get` (text) → optional_text
- `AhoraLocal` / `localNow` () → date_time
- `FechaHoraUtc` / `dateTimeUtc` (integer) → date_time
- `FechaHoraDe` / `dateTimeOf` (integer, integer, integer, integer, integer, integer, integer, integer) → optional_date_time
- `AnalizarFechaHora` / `parseDateTime` (text) → optional_date_time
- `Anio` / `year` () → integer
- `Mes` / `month` () → integer
- `Dia` / `day` () → integer
- `Hora` / `hour` () → integer
- `Minuto` / `minute` () → integer
- `Segundo` / `second` () → integer
- `Nanosegundo` / `nanosecond` () → integer
- `DiaDeLaSemana` / `weekday` () → integer
- `DesplazamientoUtc` / `utcOffset` () → integer
- `Instante` / `instant` () → integer
- `FormatoIso` / `isoFormat` () → text
- `FormatoIsoPreciso` / `isoFormatPrecise` () → text

## Grammar

EBNF productions; `@name` is a vocabulary token.

```ebnf
addition = multiplication, { ( @plus | @minus ), multiplication } ;
algorithmUnit = @algorithm, identifier, line, body, @endAlgorithm, line ;
alternativeField = identifier, @typeConnector, type ;
arguments = @leftParenthesis, [ expressions ], @rightParenthesis ;
assignmentStatement = designator, @assignment, expression ;
awaitExpression = @awaitKeyword, unary ;
body = { trivia | statement | conditional | switch | whileLoop | repeatLoop | forLoop | forEachLoop | deferStatement | taskScope } ;
breakStatement = identifier ;
callStatement = identifier, arguments | postfix, @dot, identifier, arguments | @superClass, @dot, ( identifier | @constructor ), arguments | awaitExpression ;
classUnit = @classKeyword, identifier, [ typeParameters ], [ @inheritsFrom, identifier, [ typeArguments ] ], [ realization ], line, { fieldDeclaration | methodMember | constructorMember }, @endClass, line ;
conditional = @ifKeyword, expression, @then, line, body, [ @elseKeyword, line, body ], @endIf, line ;
conjunction = equality, { @and, equality } ;
constantDeclaration = @constantKeyword, identifier, @typeConnector, type, @assignment, expression ;
constructorMember = @method, @constructor, [ @suspendibleModifier ], parameters, line, body, @endMethod, line ;
declaration = @declare, names, @typeConnector, type, [ @assignment, expression ] ;
deferStatement = identifier, line, body, identifier, line ;
designator = identifier, { @leftBracket, expressions, @rightBracket | @dot, identifier } ;
dimensionDeclaration = @dimension, dimensioned, { @comma, dimensioned }, [ @typeConnector, type ] ;
dimensioned = identifier, @leftBracket, expressions, @rightBracket ;
discardStatement = @discardKeyword, expression ;
disjunction = conjunction, { @or, conjunction } ;
enumMembers = identifier, { @comma, identifier } ;
enumUnit = @enumKeyword, identifier, line, [ enumMembers, line ], @endEnum, line ;
equality = ordering, { ( @equal | @notEqual ), ordering } ;
exportDeclaration = @exportKeyword, modulePath, terminator ;
expression = disjunction ;
expressions = expression, { @comma, expression } ;
fieldBinding = @declare, names, @typeConnector, type ;
fieldDeclaration = [ visibility ], ( fieldBinding | dimensionDeclaration ), terminator ;
forEachLoop = @forKeyword, identifier, iterationBindings, identifier, expression, @doKeyword, line, body, @endFor, line ;
forLoop = @forKeyword, identifier, @assignment, expression, @to, expression, [ @step, expression ], @doKeyword, line, body, @endFor, line ;
functionLiteral = ( @subroutine | @function ), [ @suspendibleModifier ], parameters, [ @typeConnector, type ], line, body, ( @endSubroutine | @endFunction ) ;
functionParameterType = type, [ @byValue | @byReference ] ;
functionType = ( @subroutine | @function ), @leftParenthesis, [ functionParameterType, { @comma, functionParameterType } ], @rightParenthesis, [ @typeConnector, type ] ;
importDeclaration = @importKeyword, modulePath, [ @typeConnector, identifier ], terminator ;
input = @read, designator, { @comma, designator } ;
instantiation = @newInstance, identifier, [ typeArguments ], arguments ;
interfaceSignature = ( @method | @subroutine | @function ), identifier, parameters, [ @typeConnector, type ], terminator ;
interfaceUnit = identifier, identifier, [ typeParameters ], line, { interfaceSignature }, identifier, line ;
iterationBindings = identifier, [ @comma, identifier ] ;
labels = pattern, { @comma, pattern } ;
line = endOfLine | endOfFile ;
literal = signedInteger | realLiteral | characterLiteral | stringLiteral | @booleanTrue | @booleanFalse ;
methodMember = [ visibility ], @method, [ @suspendibleModifier ], identifier, parameters, [ @typeConnector, type ], line, body, @endMethod, line ;
moduleDirective = importDeclaration | exportDeclaration ;
modulePath = identifier, { @dot, identifier } ;
moduleUnit = [ visibility ], ( subprogram | classUnit | interfaceUnit | variantUnit | enumUnit | recordUnit | constantDeclaration, terminator ) ;
multiplication = powerExpression, { ( @multiply | @divide | @integerDivide | @modulo ), powerExpression } ;
names = identifier, { @comma, identifier } ;
ordering = addition, { ( @lessThan | @lessThanOrEqual | @greaterThan | @greaterThanOrEqual ), addition } ;
output = @write, [ expressions ], [ @withoutNewline ] ;
parameter = identifier, [ @leftBracket, { @comma }, @rightBracket ], [ @typeConnector, type ], [ @byValue | @byReference ] ;
parameters = @leftParenthesis, [ parameter, { @comma, parameter } ], @rightParenthesis ;
pattern = literal | signedInteger | identifier, @dot, identifier, [ @leftParenthesis, [ identifier, { @comma, identifier } ], @rightParenthesis ] | variantPattern ;
postfix = primary, { @dot, identifier, [ arguments ] | @leftBracket, expressions, @rightBracket } ;
powerExpression = unary, [ @power, powerExpression ] ;
primary = literal | identifier, [ arguments ] | @leftParenthesis, expression, @rightParenthesis | instantiation | @thisObject, @dot, identifier, [ arguments ] | @superClass, @dot, ( identifier | @constructor ), arguments | variantConstruction | functionLiteral | spawnExpression ;
program = trivia, { moduleDirective }, { moduleUnit }, [ algorithmUnit, { moduleUnit } ], trivia, endOfFile ;
propagation = @propagateKeyword, unary ;
realization = identifier, identifier, [ typeArguments ], { @comma, identifier, [ typeArguments ] } ;
receiveBranch = identifier, identifier, identifier, expression, @branchSeparator, { statement } ;
recordField = fieldBinding, terminator ;
recordUnit = @recordKeyword, identifier, [ typeParameters ], line, { recordField }, @endRecord, line ;
repeatLoop = @repeat, line, body, @until, expression, line ;
returnStatement = @returnKeyword, [ expression ] ;
returnVariable = identifier, @assignment ;
selectStatement = @selectKeyword, receiveBranch, receiveBranch, { receiveBranch }, @endSelect ;
signedInteger = [ @plus | @minus ], integerLiteral ;
spawnExpression = @spawnKeyword, identifier, arguments ;
spawnStatement = spawnExpression ;
statement = selectStatement | ( declaration | constantDeclaration | dimensionDeclaration | assignmentStatement | output | input | callStatement | returnStatement | discardStatement | breakStatement | spawnStatement ), terminator ;
subprogram = ( @subroutine | @function ), [ @suspendibleModifier ], ( returnVariable, identifier, [ typeParameters ], parameters | identifier, [ typeParameters ], parameters, [ @typeConnector, type ] ), line, body, ( @endSubroutine | @endFunction ), line ;
switch = @switchKeyword, expression, @doKeyword, line, { labels, @branchSeparator, body }, [ @defaultCase, @branchSeparator, body ], @endSwitch, line ;
taskScope = @tasksKeyword, [ identifier ], line, body, @endTasks, line ;
terminator = @semicolon | endOfLine ;
trivia = whitespace | comment | endOfLine ;
type = @integerType | @realType | @booleanType | @characterType | @stringType | @taskType, @lessThan, type, @greaterThan | identifier, [ typeArguments ] | @optionalType, @lessThan, type, @greaterThan | @resultType, @lessThan, type, @comma, type, @greaterThan | functionType ;
typeArguments = @lessThan, type, { @comma, type }, @greaterThan ;
typeParameter = identifier, [ @branchSeparator, identifier, [ typeArguments ] ] ;
typeParameters = @lessThan, typeParameter, { @comma, typeParameter }, @greaterThan ;
unary = ( @plus | @minus | @not ), unary | awaitExpression | postfix | propagation ;
variantAlternative = identifier, identifier, [ @leftParenthesis, [ alternativeField, { @comma, alternativeField } ], @rightParenthesis ], line ;
variantConstruction = @noneVariant | ( @someVariant | @successVariant | @errorVariant ), @leftParenthesis, expression, @rightParenthesis ;
variantPattern = @noneVariant | ( @someVariant | @successVariant | @errorVariant ), @leftParenthesis, identifier, @rightParenthesis ;
variantUnit = identifier, identifier, [ typeParameters ], line, { variantAlternative }, identifier, line ;
visibility = @publicVisibility | @privateVisibility ;
whileLoop = @whileKeyword, expression, @doKeyword, line, body, @endWhile, line ;
```

## Differences from PSeInt

- Indices start at zero, not one. Rule `LANG.ARRAY.ACCESS#R1`: «Los índices son enteros cero basados; cada dimensión de tamaño N admite 0 a N-1. Un solo par de corchetes contiene todos los índices, evaluados izquierda a derecha y una vez. El número coincide con dimensiones. Lista vacía y corchetes encadenados son sintácticos; índice no entero o cantidad incorrecta son semánticos; fuera de rango es de ejecución.»
- The semicolon is mandatory on every simple statement. Rule `LANG.STMT.TERMINATION#R1`: «Las sentencias simples terminan obligatoriamente con punto y coma, incluso antes del cierre del bloque. Aperturas y cierres de bloques no lo exigen. Llamadas y retornos son simples. Líneas vacías no producen sentencias. Se admiten varias sentencias en una línea separadas por punto y coma.»
- There are no implicit variables: declare them with Definir/define and a type. Rule `LANG.DECL.VARIABLE#R1`: «Definir n₁, …, nₖ Como tipo declara k variables locales sin valor, en el orden escrito. Con un único nombre se admite un valor inicial <- expresión, que comprueba el tipo y no puede leer la variable que declara (bindingReadsOwnInitializer); con varios nombres el valor inicial es initializerWithMultipleNames, error. Toda variable declarada con Definir y todo parámetro por valor se puede reasignar, usar como destino de Leer y pasar por referencia; no hay forma de declararla constante con Definir. Siguen sin poder reasignarse la variable de control de Para (controlVariableModified) y los vínculos que introducen Para Cada, los patrones de variante y las tareas (immutableBindingAssignment). Mutable no es palabra reservada: es un identificador ordinario. Los campos, parámetros y arreglos conservan sus contratos específicos. Un nombre de un carácter es válido; repetir un nombre en la lista o en el mismo ámbito es duplicateVariableDeclaration. La mutación de un objeto no reasigna su vínculo; escribir un campo de registro por valor modifica la variable.»
- The counted loop uses integers and the step clause is optional. Rule `LANG.CONTROL.FOR#R6`: «El control es un identificador entero; límites y paso son enteros. La cláusula Con Paso es opcional: su ausencia equivale a Con Paso 1, también cuando el valor inicial supera al final, en cuyo caso el cuerpo no se ejecuta. El incremento usa aritmética entera comprobada, también tras la última iteración válida. El cuerpo vacío es admisible.»
- Modifying the control variable inside the loop is an error. Rule `LANG.CONTROL.FOR#R5`: «Modificar la variable de control en el cuerpo se rechaza con controlVariableModified como error.»
- Parameters have a mandatory type; by-reference goes after the type. Rule `LANG.SUBPROGRAM.PARAMETERS#R1`: «Cada parámetro tiene nombre, tipo obligatorio y dimensiones opcionales mediante [] [,]. La marca Por Valor o Por Referencia va después del tipo y solo alcanza ese parámetro. Sin marca se pasa por valor; arreglo se pasa por referencia y marcarlo Por Valor es error semántico. Cero parámetros es válido. Nombre duplicado o marcas repetidas se rechazan.»
- A subprogram needs parentheses even without parameters. Rule `LANG.SUBPROGRAM.DECLARATION#R1`: «SubProceso exige nombre y paréntesis aun sin parámetros; su tipo de retorno es opcional y admite primitivo o clase, nunca arreglo. Sin tipo no devuelve valor. Unidades son hermanas del algoritmo y su orden no restringe llamadas. Cuerpo vacío es válido; nombres duplicados y anidamiento se rechazan. Funcion r <- nombre(parámetros) declara una función con variable de retorno: el cuerpo debe declarar r con Definir en su nivel superior (returnVariableNotDeclared en otro caso) y el tipo de retorno es el de r; la cabecera no lleva Como tipo. La firma es la misma que la de la forma SubProceso equivalente, de modo que la función se llama, se pasa como valor y se usa en recursión igual.»
- / always yields a real; div and mod are integer operations. Rule `LANG.OPS.DIVISION#R1`: «/ entre números produce real. div y mod requieren dos enteros; el cociente trunca hacia cero y el resto satisface dividendo = cociente * divisor + resto. Todo divisor cero produce divisionByZero. El mínimo entero dividido por -1 desborda. Los operandos se evalúan de izquierda a derecha.»
- + does not convert numbers to text when concatenating. Rule `LANG.OPS.CONCATENATION#R1`: «+ concatena cadena y carácter en sus cuatro combinaciones; el resultado es cadena. No convierte número ni lógico a texto. Usa el mismo nivel de precedencia que la suma, y evalúa operandos de izquierda a derecha.»
- The English profile is case sensitive; the Spanish one is not. Rule `LANG.LEXICAL.KEYWORD#R1`: «Los lexemas de tokens del vocabulario oficial, incluidos alias, son reservados bajo las políticas del perfil. Español ignora caja y acentos del vocabulario; inglés ignora caja y conserva acentos. Y/O y and/or son operadores reservados. Las grafías de Importar y Exportar del perfil activo son contextuales únicamente en un texto suelto: en posición de unidad superior introducen sintaxis de módulo y producen moduleSyntaxOutsideProject, y dentro de un programa suelto pueden ser nombres. En un proyecto siguen siendo palabras reservadas. Suspendible y suspendable son contextuales en posiciones de modificador de cabecera reconocidas por la gramática; solo SubProceso o subroutine admite semánticamente esa marca. En cualquier otra posición son identificadores ordinarios. Aguardar y await son reservadas. No hay otras palabras contextuales ni escape general de nombres en la edición vigente. Las funciones incorporadas no son reservadas. Un lexema reservado en una posición de nombre inequívoca produce reservedLexemeUsedAsName; en una expresión incompleta se informa el error de expresión.»

## Canonical examples

Execution cases from the corpus with their expected output; engine conformance runs them on every verification.

### `LANG.PROGRAM.STRUCTURE#C6`

Un texto suelto de la edición 2026 contiene exactamente un algoritmo con nombre y cierre. Puede contener antes o después declaraciones hermanas de subprogramas, clases, interfaces, registros, enumerados y constantes de módulo, cada una con las restricciones de su contrato dueño. No hay unidades anidadas ni sentencias ejecutables al nivel superior. El algoritmo vacío es válido; texto vacío requiere diagnóstico de inicio y un árbol recuperable. El nombre del algoritmo no ocupa un espacio de variables.

```pseudolearn
Algorithm Greeting
  Write "Hola";
  Write "Adiós";
EndAlgorithm
```

Expected output:

```text
Hola
Adiós
```

### `LANG.DECL.VARIABLE#C4`

Definir n₁, …, nₖ Como tipo declara k variables locales sin valor, en el orden escrito. Con un único nombre se admite un valor inicial <- expresión, que comprueba el tipo y no puede leer la variable que declara (bindingReadsOwnInitializer); con varios nombres el valor inicial es initializerWithMultipleNames, error. Toda variable declarada con Definir y todo parámetro por valor se puede reasignar, usar como destino de Leer y pasar por referencia; no hay forma de declararla constante con Definir. Siguen sin poder reasignarse la variable de control de Para (controlVariableModified) y los vínculos que introducen Para Cada, los patrones de variante y las tareas (immutableBindingAssignment). Mutable no es palabra reservada: es un identificador ordinario. Los campos, parámetros y arreglos conservan sus contratos específicos. Un nombre de un carácter es válido; repetir un nombre en la lista o en el mismo ámbito es duplicateVariableDeclaration. La mutación de un objeto no reasigna su vínculo; escribir un campo de registro por valor modifica la variable.

```pseudolearn
algorithm P
define x as integer <- 1;
x <- 2;
write x;
endAlgorithm
```

Expected output:

```text
2
```

### `LANG.DECL.CONSTANT#C2`

Constante nombre Como tipo <- expresión declara un valor fijo, en el módulo o dentro del cuerpo de un algoritmo, subproceso o método. El tipo es entero, real, lógico, carácter, cadena o un enumerado, y el inicializador es obligatorio con las conversiones de la asignación. El nombre no se repite entre constantes y variables de su ámbito; la constante no admite asignación. Una constante de módulo es privada salvo que lleve el prefijo Publico (LANG.MODULE.IMPORT#R2) y visible en todo su módulo; una local es visible desde su declaración hasta el cierre de su ámbito léxico, como los demás vínculos. Usar una constante equivale a escribir su valor y no ocupa variable en ejecución.

```pseudolearn
algorithm P
constant R as real <- 0.1 + 0.2;
write R, 0.1 + 0.2;
endAlgorithm
```

Expected output:

```text
0.300000000000000040.30000000000000004
```

### `LANG.IO.OUTPUT#C1`

Escribir evalúa cero o más expresiones separadas por coma, izquierda a derecha y una vez. Concatena representaciones sin separador. Sin Saltar solo aparece una vez al final; ausente agrega salto de línea. La salida vacía agrega una línea; vacía sin salto no emite nada.

```pseudolearn
algorithm P
write;
write without newline;
write 1, 2 without newline;
endAlgorithm
```

Expected output:

```text

12```

### `LANG.CONTROL.IF#C1`

Si exige condición lógica y Entonces; Sino es opcional y equivale a cuerpo vacío si se omite. Ejecuta solo la rama elegida. Los cuerpos pueden ser vacíos y anidados; una cadena se expresa anidando Si en Sino. Rama contraria duplicada o cierre ausente es sintáctico.

```pseudolearn
algorithm P
if true then
write 1;
else
write 2;
endIf
endAlgorithm
```

Expected output:

```text
1
```

### `LANG.CONTROL.SWITCH#C1`

Según evalúa el selector una sola vez. Sus etiquetas son literales enteros o enumerados, admiten listas y no se repiten; entero con signo es literal. No hay caída entre ramas. De Otro Modo es opcional, única y última; cada rama exige dos puntos. Los valores reales, de carácter, de texto y lógicos se rechazan. Selector y etiquetas deben ser compatibles. Cero ramas y ninguna coincidencia son válidos.

```pseudolearn
algorithm P
switch 2 do
1, 2: write 1;
otherwise: write 0;
endSwitch
endAlgorithm
```

Expected output:

```text
1
```

### `LANG.CONTROL.WHILE#C2`

Mientras exige condición lógica y Hacer. Comprueba antes de cada iteración, incluida la primera; ejecuta cero o más veces. El cuerpo puede estar vacío y anidarse. Falta de Hacer o cierre es sintáctica, condición no lógica es semántica.

```pseudolearn
algorithm P
define x as integer <- 0;
while x < 2 do
x <- x + 1;
endWhile
write x;
endAlgorithm
```

Expected output:

```text
2
```

### `LANG.CONTROL.REPEAT#C1`

Repetir ejecuta el cuerpo al menos una vez y termina cuando la condición de Hasta Que es verdadera. La condición se evalúa después del cuerpo y debe ser lógica. Hasta Que cierra el bloque; no hay cierre adicional. El cuerpo vacío comprueba la condición una vez.

```pseudolearn
algorithm P
repeat
write 1;
until true
endAlgorithm
```

Expected output:

```text
1
```

### `LANG.CONTROL.FOR#C20`

El control es un identificador entero; límites y paso son enteros. La cláusula Con Paso es opcional: su ausencia equivale a Con Paso 1, también cuando el valor inicial supera al final, en cuyo caso el cuerpo no se ejecuta. El incremento usa aritmética entera comprobada, también tras la última iteración válida. El cuerpo vacío es admisible.

```pseudolearn
algorithm P
for i <- 1 to 1 do
write i;
endFor
endAlgorithm
```

Expected output:

```text
1
```

### `LANG.CONTROL.FOR-EACH#C1`

Para Cada elemento En secuencia Hacer cuerpo FinPara recorre Vector o arreglo unidimensional. Diccionario exige dos vínculos clave, valor. La secuencia se evalúa una vez antes de introducir vínculos inmutables por valor, visibles solo en el cuerpo. El orden es ascendente para secuencias y de inserción para diccionarios. Una colección vacía no ejecuta el cuerpo.

```pseudolearn
algorithm Main
define values as vector<integer> <- vector();
values.append(4);
values.append(7);
for each value in values do
write value;
endFor
endAlgorithm
```

Expected output:

```text
4
7
```

### `LANG.ARRAY.ACCESS#C1`

Los índices son enteros cero basados; cada dimensión de tamaño N admite 0 a N-1. Un solo par de corchetes contiene todos los índices, evaluados izquierda a derecha y una vez. El número coincide con dimensiones. Lista vacía y corchetes encadenados son sintácticos; índice no entero o cantidad incorrecta son semánticos; fuera de rango es de ejecución.

```pseudolearn
algorithm P
dimension a[1] as integer;
a[0] <- 7;
write a[0];
endAlgorithm
```

Expected output:

```text
7
```

### `LANG.ARRAY.DIMENSION#C6`

Dimension nombre[d₁, …] Como tipo declara nombre, dimensiones y tipo en una sola sentencia. Sin Como tipo, Dimension adopta una variable ya declarada con Definir en el mismo ámbito, sin valor inicial y sin ningún uso entre las dos sentencias: pasa a ser un arreglo del tipo declarado con esas dimensiones y desde ahí tiene valor. Si el nombre no cumple esas condiciones, es dimensionWithoutType, error, con origen relacionado en la declaración cuando existe. En los campos de clase el tipo sigue siendo obligatorio. Las dimensiones son expresiones enteras que se evalúan al ejecutar. Tamaño cero es válido; negativo falla. No se admite lista vacía ni declaración duplicada. No se fija un máximo semántico de tamaño: recursos pertenecen al contrato del motor.

```pseudolearn
algorithm P
define v as integer;
dimension v[0];
write "vacio";
endAlgorithm
```

Expected output:

```text
vacio
```

### `LANG.OPS.DIVISION#C1`

/ entre números produce real. div y mod requieren dos enteros; el cociente trunca hacia cero y el resto satisface dividendo = cociente * divisor + resto. Todo divisor cero produce divisionByZero. El mínimo entero dividido por -1 desborda. Los operandos se evalúan de izquierda a derecha.

```pseudolearn
algorithm P
write 5 / 2, ":", -5 div 2, ":", -5 mod 2;
endAlgorithm
```

Expected output:

```text
2.5:-2:-1
```

### `LANG.OPS.CONCATENATION#C1`

+ concatena cadena y carácter en sus cuatro combinaciones; el resultado es cadena. No convierte número ni lógico a texto. Usa el mismo nivel de precedencia que la suma, y evalúa operandos de izquierda a derecha.

```pseudolearn
algorithm P
write "a" + "b", "ab" + "c", "" + "";
endAlgorithm
```

Expected output:

```text
ababc
```

### `LANG.TYPES.TEXT#C1`

Una cadena es una secuencia de puntos de código, distinta de carácter y arreglo. Su longitud no tiene cota semántica fija; puede ser vacía. Las posiciones son cero basadas. Su contenido no se normaliza y los grafemas compuestos cuentan por puntos de código.

```pseudolearn
algorithm P
write length(""), ":", length("año😀"), ":", length("é");
endAlgorithm
```

Expected output:

```text
0:4:2
```

### `LANG.TYPES.RECORD#C1`

Registro nombre, una declaración Definir por línea y FinRegistro declaran un tipo agregado por valor en el módulo. Cada campo tiene un tipo entero, real, lógico, carácter, cadena, enumerado, clase u otro registro; un registro necesita al menos un campo (recordWithoutFields) y solo contiene declaraciones de campo (expectedRecordField). Un registro no puede contenerse a sí mismo por valor, directa ni indirectamente (recursiveRecordContainment); contener una clase que lo referencia sí es válido. Un registro tiene como máximo 65535 hojas, contadas como los campos que no son registros, incluidos los de sus registros anidados; el primer registro que supera ese máximo produce recordLayoutLimit, una sola vez aunque otros registros lo contengan. Un registro es una unidad de módulo: es privado salvo que lleve el prefijo Publico y se importa por símbolo (LANG.MODULE.IMPORT#R2). Puede usarse como tipo de variable, parámetro, resultado, elemento de arreglo y campo de clase (R5).

```pseudolearn
record Caja
define v as integer;
endRecord
algorithm P
define c as Caja <- Caja(5);
write c.v;
endAlgorithm
```

Expected output:

```text
5
```

### `LANG.SUBPROGRAM.DECLARATION#C1`

SubProceso exige nombre y paréntesis aun sin parámetros; su tipo de retorno es opcional y admite primitivo o clase, nunca arreglo. Sin tipo no devuelve valor. Unidades son hermanas del algoritmo y su orden no restringe llamadas. Cuerpo vacío es válido; nombres duplicados y anidamiento se rechazan. Funcion r <- nombre(parámetros) declara una función con variable de retorno: el cuerpo debe declarar r con Definir en su nivel superior (returnVariableNotDeclared en otro caso) y el tipo de retorno es el de r; la cabecera no lleva Como tipo. La firma es la misma que la de la forma SubProceso equivalente, de modo que la función se llama, se pasa como valor y se usa en recursión igual.

```pseudolearn
subroutine f()
write 1;
endSubroutine
algorithm P
f();
endAlgorithm
```

Expected output:

```text
1
```

### `LANG.SUBPROGRAM.RETURN#C1`

Retornar termina inmediatamente la llamada y abandona bloques y bucles abiertos. Exige expresión cuando hay tipo de retorno y la prohíbe cuando no lo hay, salvo salida sin expresión de constructor. Tipo incompatible es semántico. Retorno fuera de subprograma es sintáctico. Ningún retorno en función tipada es error semántico; un camino que alcanza el cierre sin retornar es fallo de ejecución con tramo de cierre y cabecera relacionada. En una función con variable de retorno r, Retornar va sin expresión (returnValueInReturnVariableFunction si la lleva) y devuelve r; el fin del cuerpo también devuelve r. En cada Retornar y en cada fin normal del cuerpo r debe tener valor según LANG.DECL.UNINITIALIZED: en otro caso es variableUsedUninitialized con la cabecera como origen relacionado.

```pseudolearn
subroutine f(value as integer) as integer
return value + 1;
endSubroutine
algorithm P
write f(2);
endAlgorithm
```

Expected output:

```text
3
```

### `LANG.SUBPROGRAM.BY-REFERENCE#C4`

Un parámetro por referencia exige un designador de tipo exacto. El índice de un elemento se fija una vez al llamar. Un arreglo completo solo se admite para parámetro arreglo compatible en elemento y dimensiones. Dos parámetros pueden referir la misma casilla; no se prohíbe aliasing. Un índice inválido falla antes de entrar al cuerpo. Un parámetro por referencia que no es arreglo ni registro es de salida cuando su subprograma le da valor antes de toda lectura en todos los caminos y en todo fin del cuerpo, sin pasarlo antes a otro parámetro por referencia que no sea también de salida; los parámetros de un subprograma recursivo, directa o mutuamente, no son de salida. En una llamada directa por nombre, a Super o a un constructor, el argumento de un parámetro de salida puede no tener valor y lo tiene después de la llamada; el de un parámetro por referencia que no es de salida se lee y debe tener valor (variableUsedUninitialized en el argumento). En una llamada mediante un valor función o a un método con despacho dinámico todo argumento por referencia debe tener valor. La clasificación es un dato del análisis y no cambia la firma.

```pseudolearn
subroutine Fijar(n as integer by reference)
n <- 7;
endSubroutine
algorithm P
define a as integer;
Fijar(a);
write a;
endAlgorithm
```

Expected output:

```text
7
```

### `LANG.SUBPROGRAM.RECURSION#C1`

Se admite recursión directa e indirecta sin declaración adelantada. Cada llamada conserva su marco; el retorno restaura el llamador. Una recursión sin caso base termina con fallo controlado al agotar recursos, nunca desbordando la pila del anfitrión. La cuantificación de recursos pertenece al contrato de límites del motor y no se fija aquí.

```pseudolearn
subroutine f(value as integer) as integer
if value <= 1 then
return 1;
endIf
return value * f(value - 1);
endSubroutine
algorithm P
write f(5);
endAlgorithm
```

Expected output:

```text
120
```

### `LANG.CLASS.DECLARATION#C4`

Una clase con nombre y cierre contiene atributos, métodos y constructor; es hermana del algoritmo y subprogramas. No se admite anidamiento, subprograma dentro de clase ni clase dentro de unidad. El orden no restringe referencias a clases posteriores. La inicial mayúscula es estilo y no requisito. Nombre duplicado y ciclos son semánticos.

```pseudolearn
Class Rectangle
  Define width As Integer;
  Define height As Integer;
  Method Area() As Integer
    Return This.width * This.height;
  EndMethod
EndClass

Algorithm Shapes
  Define table As Rectangle <- New Rectangle();
  table.width <- 4;
  table.height <- 3;
  Write table.Area();
EndAlgorithm
```

Expected output:

```text
12
```

