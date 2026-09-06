enum TokenType {
  identifier,
  integerLiteral,
  realLiteral,
  stringLiteral,
  characterLiteral,
  endOfLine,
  endOfFile,

  algorithm,
  endAlgorithm,

  declare,
  typeConnector,
  dimension,

  integerType,
  realType,
  booleanType,
  characterType,
  stringType,

  booleanTrue,
  booleanFalse,

  read,
  write,
  withoutNewline,

  assignment,

  ifKeyword,
  then,
  elseKeyword,
  endIf,

  switchKeyword,
  defaultCase,
  endSwitch,

  whileKeyword,
  doKeyword,
  endWhile,

  repeat,
  until,

  forKeyword,
  to,
  step,
  endFor,

  subroutine,
  endSubroutine,
  byReference,
  byValue,
  returnKeyword,

  classKeyword,
  endClass,
  inheritsFrom,
  method,
  endMethod,
  constructor,
  publicVisibility,
  privateVisibility,
  newInstance,
  thisObject,
  superClass,

  plus,
  minus,
  multiply,
  divide,
  integerDivide,
  modulo,
  power,

  lessThan,
  lessThanOrEqual,
  greaterThan,
  greaterThanOrEqual,
  equal,
  notEqual,

  and,
  or,
  not,

  dot,

  leftParenthesis,
  rightParenthesis,
  leftBracket,
  rightBracket,
  comma,
  semicolon,
  branchSeparator,
  quote;

  bool get isReserved => !isOpen;

  bool get isOpen => switch (this) {
        identifier ||
        integerLiteral ||
        realLiteral ||
        stringLiteral ||
        characterLiteral ||
        endOfLine ||
        endOfFile =>
          true,
        _ => false,
      };
}
