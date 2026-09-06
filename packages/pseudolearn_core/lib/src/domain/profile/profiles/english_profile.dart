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

part 'english_severity_policy.dart';

final class EnglishProfile implements LanguageProfile {
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

  const EnglishProfile.strict({
    this.name = 'English (strict)',
    this.severityPolicy = _strictSeverityPolicy,
  })  : accentPolicy = AccentPolicy.sensitive,
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

  const EnglishProfile.flexible({
    this.name = 'English (flexible)',
    this.severityPolicy = _flexibleSeverityPolicy,
  })  : accentPolicy = AccentPolicy.sensitive,
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
  Map<TokenType, LexemeEntry> get reservedLexemes => _englishLexemes;

  @override
  Map<BuiltinFunction, BuiltinFunctionEntry> get builtinFunctions =>
      _englishBuiltins;

  @override
  Map<String, UnsupportedConstruct> get unsupportedConstructs =>
      _englishUnsupportedConstructs;

  @override
  String formatTokenType(TokenType tokenType) {
    final entry = reservedLexemes[tokenType];
    if (entry != null) return entry.canonicalLexeme;
    return switch (tokenType) {
      TokenType.identifier => 'identifier',
      TokenType.integerLiteral => 'integer',
      TokenType.realLiteral => 'real',
      TokenType.stringLiteral => 'string',
      TokenType.characterLiteral => 'character',
      TokenType.endOfLine => 'end of line',
      TokenType.endOfFile => 'end of file',
      _ => tokenType.name,
    };
  }

  @override
  String formatPrimitiveType(PrimitiveType primitiveType) =>
      switch (primitiveType) {
        PrimitiveType.integer => 'integer',
        PrimitiveType.real => 'real',
        PrimitiveType.boolean => 'boolean',
        PrimitiveType.character => 'character',
        PrimitiveType.string => 'string',
      };
}

const Map<TokenType, LexemeEntry> _englishLexemes = {
  TokenType.algorithm: LexemeEntry('algorithm'),
  TokenType.endAlgorithm: LexemeEntry('endAlgorithm', {'end algorithm'}),
  TokenType.declare: LexemeEntry('define', {'declare'}),
  TokenType.typeConnector: LexemeEntry('as'),
  TokenType.dimension: LexemeEntry('dimension'),
  TokenType.integerType: LexemeEntry('integer'),
  TokenType.realType: LexemeEntry('real'),
  TokenType.booleanType: LexemeEntry('boolean'),
  TokenType.characterType: LexemeEntry('character', {'char'}),
  TokenType.stringType: LexemeEntry('string'),
  TokenType.booleanTrue: LexemeEntry('true'),
  TokenType.booleanFalse: LexemeEntry('false'),
  TokenType.read: LexemeEntry('read'),
  TokenType.write: LexemeEntry('write', {'print'}),
  TokenType.withoutNewline: LexemeEntry('without newline', {'withoutNewline'}),
  TokenType.assignment: LexemeEntry('<-', {':='}),
  TokenType.ifKeyword: LexemeEntry('if'),
  TokenType.then: LexemeEntry('then'),
  TokenType.elseKeyword: LexemeEntry('else'),
  TokenType.endIf: LexemeEntry('endIf', {'end if'}),
  TokenType.switchKeyword: LexemeEntry('switch'),
  TokenType.defaultCase: LexemeEntry('otherwise', {'default'}),
  TokenType.endSwitch: LexemeEntry('endSwitch', {'end switch'}),
  TokenType.whileKeyword: LexemeEntry('while'),
  TokenType.doKeyword: LexemeEntry('do'),
  TokenType.endWhile: LexemeEntry('endWhile', {'end while'}),
  TokenType.repeat: LexemeEntry('repeat'),
  TokenType.until: LexemeEntry('until'),
  TokenType.forKeyword: LexemeEntry('for'),
  TokenType.to: LexemeEntry('to'),
  TokenType.step: LexemeEntry('step', {'with step'}),
  TokenType.endFor: LexemeEntry('endFor', {'end for'}),
  TokenType.subroutine: LexemeEntry('subroutine', {'function', 'procedure'}),
  TokenType.endSubroutine: LexemeEntry('endSubroutine', {
    'end subroutine',
    'end function',
    'end procedure',
  }),
  TokenType.byReference: LexemeEntry('by reference', {'byReference'}),
  TokenType.byValue: LexemeEntry('by value', {'byValue'}),
  TokenType.returnKeyword: LexemeEntry('return'),
  TokenType.classKeyword: LexemeEntry('class'),
  TokenType.endClass: LexemeEntry('endClass', {'end class'}),
  TokenType.inheritsFrom:
      LexemeEntry('inherits from', {'inheritsFrom', 'extends'}),
  TokenType.method: LexemeEntry('method'),
  TokenType.endMethod: LexemeEntry('endMethod', {'end method'}),
  TokenType.constructor: LexemeEntry('constructor'),
  TokenType.publicVisibility: LexemeEntry('public'),
  TokenType.privateVisibility: LexemeEntry('private'),
  TokenType.newInstance: LexemeEntry('new'),
  TokenType.thisObject: LexemeEntry('this'),
  TokenType.superClass: LexemeEntry('super'),
  TokenType.plus: LexemeEntry('+'),
  TokenType.minus: LexemeEntry('-'),
  TokenType.multiply: LexemeEntry('*'),
  TokenType.divide: LexemeEntry('/'),
  TokenType.integerDivide: LexemeEntry('div'),
  TokenType.modulo: LexemeEntry('mod', {'%'}),
  TokenType.power: LexemeEntry('^', {'**'}),
  TokenType.lessThan: LexemeEntry('<'),
  TokenType.lessThanOrEqual: LexemeEntry('<='),
  TokenType.greaterThan: LexemeEntry('>'),
  TokenType.greaterThanOrEqual: LexemeEntry('>='),
  TokenType.equal: LexemeEntry('='),
  TokenType.notEqual: LexemeEntry('<>', {'!='}),
  TokenType.and: LexemeEntry('and', {'&'}),
  TokenType.or: LexemeEntry('or', {'|'}),
  TokenType.not: LexemeEntry('not', {'!'}),
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

const Map<BuiltinFunction, BuiltinFunctionEntry> _englishBuiltins = {
  BuiltinFunction.squareRoot: BuiltinFunctionEntry('sqrt'),
  BuiltinFunction.absoluteValue: BuiltinFunctionEntry('abs'),
  BuiltinFunction.naturalLogarithm: BuiltinFunctionEntry('ln', {'log'}),
  BuiltinFunction.exponential: BuiltinFunctionEntry('exp'),
  BuiltinFunction.sine: BuiltinFunctionEntry('sin'),
  BuiltinFunction.cosine: BuiltinFunctionEntry('cos'),
  BuiltinFunction.arcTangent: BuiltinFunctionEntry('atan'),
  BuiltinFunction.truncate: BuiltinFunctionEntry('trunc'),
  BuiltinFunction.round: BuiltinFunctionEntry('round'),
  BuiltinFunction.random: BuiltinFunctionEntry('random', {'rand'}),
  BuiltinFunction.toText: BuiltinFunctionEntry('toText'),
  BuiltinFunction.textToInteger: BuiltinFunctionEntry('toInteger'),
  BuiltinFunction.textToReal: BuiltinFunctionEntry('toReal'),
  BuiltinFunction.length: BuiltinFunctionEntry('length'),
  BuiltinFunction.characterAt: BuiltinFunctionEntry('charAt'),
  BuiltinFunction.characterCode: BuiltinFunctionEntry('charCode'),
  BuiltinFunction.characterFromCode: BuiltinFunctionEntry('charFromCode'),
  BuiltinFunction.shallowCopy: BuiltinFunctionEntry('copy'),
};

const Map<String, UnsupportedConstruct> _englishUnsupportedConstructs = {
  'interface': UnsupportedConstruct.interfaceKeyword,
  'abstract': UnsupportedConstruct.abstractClass,
  'static': UnsupportedConstruct.staticMember,
  'protected': UnsupportedConstruct.protectedVisibility,
  'generic': UnsupportedConstruct.genericType,
  'generics': UnsupportedConstruct.genericType,
  'try': UnsupportedConstruct.exceptionHandling,
  'catch': UnsupportedConstruct.exceptionHandling,
  'throw': UnsupportedConstruct.exceptionHandling,
};
