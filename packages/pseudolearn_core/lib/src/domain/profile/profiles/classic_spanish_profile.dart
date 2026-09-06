import '../../diagnostic_code.dart';
import '../../primitive_type.dart';
import '../../severity.dart';
import '../../token_type.dart';
import '../accent_policy.dart';
import '../builtin_function.dart';
import '../builtin_function_entry.dart';
import '../case_policy.dart';
import '../identifier_alphabet.dart';
import '../language_profile.dart';
import '../lexeme_entry.dart';
import '../unsupported_construct.dart';

part 'classic_spanish_severity_policy.dart';

final class ClassicSpanishProfile implements LanguageProfile {
  @override
  final String name;

  @override
  final AccentPolicy accentPolicy;

  @override
  final CasePolicy casePolicy;

  @override
  final IdentifierAlphabet identifierAlphabet;

  @override
  final String commentMarker;

  @override
  final String quoteDelimiter;

  @override
  final bool mandatoryStatementTerminator;

  @override
  final bool mandatoryStepInCountedLoop;

  @override
  final bool mandatoryVariableDeclaration;

  @override
  final bool mandatoryInitialization;

  @override
  final bool numericSwitchCases;

  @override
  final bool constantArrayDimension;

  @override
  final Map<DiagnosticCode, Severity> severityPolicy;

  const ClassicSpanishProfile.strict({
    this.name = 'Español clásico (estricto)',
    this.severityPolicy = _strictSeverityPolicy,
  })  : accentPolicy = AccentPolicy.insensitive,
        casePolicy = CasePolicy.insensitive,
        identifierAlphabet = IdentifierAlphabet.standard,
        commentMarker = '//',
        quoteDelimiter = '"',
        mandatoryStatementTerminator = true,
        mandatoryStepInCountedLoop = true,
        mandatoryVariableDeclaration = true,
        mandatoryInitialization = true,
        numericSwitchCases = true,
        constantArrayDimension = true;

  const ClassicSpanishProfile.flexible({
    this.name = 'Español clásico (flexible)',
    this.severityPolicy = _flexibleSeverityPolicy,
  })  : accentPolicy = AccentPolicy.insensitive,
        casePolicy = CasePolicy.insensitive,
        identifierAlphabet = IdentifierAlphabet.extended,
        commentMarker = '//',
        quoteDelimiter = '"',
        mandatoryStatementTerminator = false,
        mandatoryStepInCountedLoop = false,
        mandatoryVariableDeclaration = false,
        mandatoryInitialization = false,
        numericSwitchCases = false,
        constantArrayDimension = false;

  @override
  Map<TokenType, LexemeEntry> get reservedLexemes => _classicSpanishLexemes;

  @override
  Map<BuiltinFunction, BuiltinFunctionEntry> get builtinFunctions =>
      _classicSpanishBuiltins;

  @override
  Map<String, UnsupportedConstruct> get unsupportedConstructs =>
      _spanishUnsupportedConstructs;

  @override
  String formatTokenType(TokenType tokenType) {
    final entry = reservedLexemes[tokenType];
    if (entry != null) return entry.canonicalLexeme;
    return switch (tokenType) {
      TokenType.identifier => 'identificador',
      TokenType.integerLiteral => 'entero',
      TokenType.realLiteral => 'real',
      TokenType.stringLiteral => 'cadena',
      TokenType.characterLiteral => 'carácter',
      TokenType.endOfLine => 'fin de línea',
      TokenType.endOfFile => 'fin de archivo',
      _ => tokenType.name,
    };
  }

  @override
  String formatPrimitiveType(PrimitiveType primitiveType) =>
      switch (primitiveType) {
        PrimitiveType.integer => 'entero',
        PrimitiveType.real => 'real',
        PrimitiveType.boolean => 'lógico',
        PrimitiveType.character => 'carácter',
        PrimitiveType.string => 'cadena',
      };
}

const Map<TokenType, LexemeEntry> _classicSpanishLexemes = {
  TokenType.algorithm: LexemeEntry('Proceso', {'Algoritmo'}),
  TokenType.endAlgorithm: LexemeEntry('FinProceso', {
    'FinAlgoritmo',
    'Fin Proceso',
    'Fin Algoritmo',
  }),
  TokenType.declare: LexemeEntry('Definir'),
  TokenType.typeConnector: LexemeEntry('Como'),
  TokenType.dimension: LexemeEntry('Dimension'),
  TokenType.integerType: LexemeEntry('Entero'),
  TokenType.realType: LexemeEntry('Real'),
  TokenType.booleanType: LexemeEntry('Logico'),
  TokenType.characterType: LexemeEntry('Caracter'),
  TokenType.stringType: LexemeEntry('Cadena'),
  TokenType.booleanTrue: LexemeEntry('Verdadero'),
  TokenType.booleanFalse: LexemeEntry('Falso'),
  TokenType.read: LexemeEntry('Leer'),
  TokenType.write: LexemeEntry('Escribir', {'Mostrar'}),
  TokenType.withoutNewline: LexemeEntry('Sin Saltar', {'SinSaltar'}),
  TokenType.assignment: LexemeEntry('<-', {':='}),
  TokenType.ifKeyword: LexemeEntry('Si'),
  TokenType.then: LexemeEntry('Entonces'),
  TokenType.elseKeyword: LexemeEntry('SiNo', {'Sino', 'Si No'}),
  TokenType.endIf: LexemeEntry('FinSi', {'Fin Si'}),
  TokenType.switchKeyword: LexemeEntry('Segun'),
  TokenType.defaultCase: LexemeEntry('De Otro Modo', {'DeOtroModo'}),
  TokenType.endSwitch: LexemeEntry('FinSegun', {'Fin Segun'}),
  TokenType.whileKeyword: LexemeEntry('Mientras'),
  TokenType.doKeyword: LexemeEntry('Hacer'),
  TokenType.endWhile: LexemeEntry('FinMientras', {'Fin Mientras'}),
  TokenType.repeat: LexemeEntry('Repetir'),
  TokenType.until: LexemeEntry('Hasta Que', {'HastaQue'}),
  TokenType.forKeyword: LexemeEntry('Para'),
  TokenType.to: LexemeEntry('Hasta'),
  TokenType.step: LexemeEntry('Con Paso', {'ConPaso'}),
  TokenType.endFor: LexemeEntry('FinPara', {'Fin Para'}),
  TokenType.subroutine: LexemeEntry('SubProceso', {
    'SubAlgoritmo',
    'Funcion',
    'Procedimiento',
  }),
  TokenType.endSubroutine: LexemeEntry('FinSubProceso', {
    'FinSubAlgoritmo',
    'FinFuncion',
    'FinProcedimiento',
    'Fin SubProceso',
    'Fin SubAlgoritmo',
    'Fin Funcion',
    'Fin Procedimiento',
  }),
  TokenType.byReference: LexemeEntry('Por Referencia', {'PorReferencia'}),
  TokenType.byValue: LexemeEntry('Por Valor', {'PorValor'}),
  TokenType.returnKeyword: LexemeEntry('Retornar'),
  TokenType.classKeyword: LexemeEntry('Clase'),
  TokenType.endClass: LexemeEntry('FinClase', {'Fin Clase'}),
  TokenType.inheritsFrom: LexemeEntry('Hereda De', {'HeredaDe'}),
  TokenType.method: LexemeEntry('Metodo'),
  TokenType.endMethod: LexemeEntry('FinMetodo', {'Fin Metodo'}),
  TokenType.constructor: LexemeEntry('Constructor'),
  TokenType.publicVisibility: LexemeEntry('Publico'),
  TokenType.privateVisibility: LexemeEntry('Privado'),
  TokenType.newInstance: LexemeEntry('Nuevo'),
  TokenType.thisObject: LexemeEntry('Este'),
  TokenType.superClass: LexemeEntry('Super'),
  TokenType.plus: LexemeEntry('+'),
  TokenType.minus: LexemeEntry('-'),
  TokenType.multiply: LexemeEntry('*'),
  TokenType.divide: LexemeEntry('/'),
  TokenType.integerDivide: LexemeEntry('div', {'DIV'}),
  TokenType.modulo: LexemeEntry('mod', {'MOD', '%'}),
  TokenType.power: LexemeEntry('^', {'**'}),
  TokenType.lessThan: LexemeEntry('<'),
  TokenType.lessThanOrEqual: LexemeEntry('<='),
  TokenType.greaterThan: LexemeEntry('>'),
  TokenType.greaterThanOrEqual: LexemeEntry('>='),
  TokenType.equal: LexemeEntry('='),
  TokenType.notEqual: LexemeEntry('<>', {'!='}),
  TokenType.and: LexemeEntry('Y', {'&'}),
  TokenType.or: LexemeEntry('O', {'|'}),
  TokenType.not: LexemeEntry('NO', {'~', '!'}),
  TokenType.dot: LexemeEntry('.'),
  TokenType.leftParenthesis: LexemeEntry('('),
  TokenType.rightParenthesis: LexemeEntry(')'),
  TokenType.leftBracket: LexemeEntry('['),
  TokenType.rightBracket: LexemeEntry(']'),
  TokenType.comma: LexemeEntry(','),
  TokenType.semicolon: LexemeEntry(';'),
  TokenType.branchSeparator: LexemeEntry(':'),
  TokenType.quote: LexemeEntry('"', {"'"}),
};

const Map<BuiltinFunction, BuiltinFunctionEntry> _classicSpanishBuiltins = {
  BuiltinFunction.squareRoot: BuiltinFunctionEntry('rc', {'raiz'}),
  BuiltinFunction.absoluteValue: BuiltinFunctionEntry('abs'),
  BuiltinFunction.naturalLogarithm: BuiltinFunctionEntry('ln'),
  BuiltinFunction.exponential: BuiltinFunctionEntry('exp'),
  BuiltinFunction.sine: BuiltinFunctionEntry('sen', {'sin'}),
  BuiltinFunction.cosine: BuiltinFunctionEntry('cos'),
  BuiltinFunction.arcTangent: BuiltinFunctionEntry('atan', {'arctan'}),
  BuiltinFunction.truncate: BuiltinFunctionEntry('trunc'),
  BuiltinFunction.round: BuiltinFunctionEntry('redon'),
  BuiltinFunction.random: BuiltinFunctionEntry('azar', {'aleatorio'}),
  BuiltinFunction.toText: BuiltinFunctionEntry('ATexto', {'ConvertirATexto'}),
  BuiltinFunction.textToInteger: BuiltinFunctionEntry('AEntero'),
  BuiltinFunction.textToReal: BuiltinFunctionEntry('AReal'),
  BuiltinFunction.length: BuiltinFunctionEntry('Longitud'),
  BuiltinFunction.characterAt: BuiltinFunctionEntry('CaracterEn'),
  BuiltinFunction.characterCode: BuiltinFunctionEntry('CodigoDe'),
  BuiltinFunction.characterFromCode: BuiltinFunctionEntry('CaracterDesde'),
  BuiltinFunction.shallowCopy: BuiltinFunctionEntry('Copiar'),
};

const Map<String, UnsupportedConstruct> _spanishUnsupportedConstructs = {
  'interfaz': UnsupportedConstruct.interfaceKeyword,
  'interface': UnsupportedConstruct.interfaceKeyword,
  'abstracta': UnsupportedConstruct.abstractClass,
  'abstracto': UnsupportedConstruct.abstractClass,
  'abstract': UnsupportedConstruct.abstractClass,
  'estatico': UnsupportedConstruct.staticMember,
  'estatica': UnsupportedConstruct.staticMember,
  'static': UnsupportedConstruct.staticMember,
  'protegido': UnsupportedConstruct.protectedVisibility,
  'protegida': UnsupportedConstruct.protectedVisibility,
  'protected': UnsupportedConstruct.protectedVisibility,
  'generico': UnsupportedConstruct.genericType,
  'genericos': UnsupportedConstruct.genericType,
  'generica': UnsupportedConstruct.genericType,
  'genericas': UnsupportedConstruct.genericType,
  'generic': UnsupportedConstruct.genericType,
  'generics': UnsupportedConstruct.genericType,
  'intentar': UnsupportedConstruct.exceptionHandling,
  'capturar': UnsupportedConstruct.exceptionHandling,
  'lanzar': UnsupportedConstruct.exceptionHandling,
  'try': UnsupportedConstruct.exceptionHandling,
  'catch': UnsupportedConstruct.exceptionHandling,
  'throw': UnsupportedConstruct.exceptionHandling,
};
