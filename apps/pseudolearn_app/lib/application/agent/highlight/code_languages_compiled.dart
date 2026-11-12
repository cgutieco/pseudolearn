import 'code_language.dart';

final Set<String> _cConstants = words('true false null nullptr NULL');

final CodeLanguage javaScriptLanguage = CodeLanguage(
  keywords: words(
    'async await break case catch class const continue debugger default delete do else export extends '
    'finally for from function if import in instanceof let new of return static super switch this throw '
    'try typeof var void while with yield as implements interface enum type namespace declare readonly '
    'public private protected abstract keyof satisfies',
  ),
  types: words('string number boolean any unknown never object symbol bigint Array Promise Map Set Record'),
  constants: words('true false null undefined NaN Infinity'),
  lineComments: ['//'],
  blockCommentOpen: '/*',
  blockCommentClose: '*/',
  quotes: ['`', '"', "'"],
);

final CodeLanguage javaLanguage = CodeLanguage(
  keywords: words(
    'abstract assert break case catch class continue default do else enum extends final finally for if '
    'implements import instanceof interface native new package private protected public return static '
    'super switch synchronized this throw throws transient try volatile while var record yield sealed permits',
  ),
  types: words('boolean byte char double float int long short void String Integer List Map Object'),
  constants: _cConstants,
  lineComments: ['//'],
  blockCommentOpen: '/*',
  blockCommentClose: '*/',
);

final CodeLanguage cFamilyLanguage = CodeLanguage(
  keywords: words(
    'auto break case catch class const constexpr continue default delete do else enum explicit extern for '
    'friend goto if inline namespace new operator private protected public return sizeof static struct '
    'switch template this throw try typedef typename union using virtual volatile while include define '
    'abstract base internal override readonly sealed foreach in out ref var async await is as get set',
  ),
  types: words('bool char double float int long short signed unsigned void size_t string std object decimal'),
  constants: _cConstants,
  lineComments: ['//', '#'],
  blockCommentOpen: '/*',
  blockCommentClose: '*/',
);

final CodeLanguage goLanguage = CodeLanguage(
  keywords: words(
    'break case chan const continue default defer else fallthrough for func go goto if import interface '
    'map package range return select struct switch type var',
  ),
  types: words('bool byte complex64 complex128 error float32 float64 int int8 int16 int32 int64 rune string uint uint8 uint16 uint32 uint64 any'),
  constants: words('true false nil iota'),
  lineComments: ['//'],
  blockCommentOpen: '/*',
  blockCommentClose: '*/',
  quotes: ['`', '"', "'"],
);

final CodeLanguage rustLanguage = CodeLanguage(
  keywords: words(
    'as async await break const continue crate dyn else enum extern fn for if impl in let loop match mod '
    'move mut pub ref return self Self static struct super trait type unsafe use where while',
  ),
  types: words('bool char f32 f64 i8 i16 i32 i64 i128 isize str u8 u16 u32 u64 u128 usize String Vec Option Result Box'),
  constants: words('true false None Some Ok Err'),
  lineComments: ['//'],
  blockCommentOpen: '/*',
  blockCommentClose: '*/',
  quotes: ['"'],
);

final CodeLanguage dartLanguage = CodeLanguage(
  keywords: words(
    'abstract as assert async await base break case catch class const continue covariant default deferred '
    'do else enum export extends extension external factory final finally for get if implements import in '
    'interface is late library mixin new on operator part required rethrow return sealed set static super '
    'switch sync this throw try typedef var when while with yield',
  ),
  types: words('bool double dynamic int num void String List Map Set Future Stream Object Never'),
  constants: words('true false null'),
  lineComments: ['//'],
  blockCommentOpen: '/*',
  blockCommentClose: '*/',
);

final CodeLanguage kotlinSwiftLanguage = CodeLanguage(
  keywords: words(
    'as break class continue do else for fun func if import in interface is let object override package '
    'private protected public return struct super switch this throw try typealias val var when while guard '
    'enum extension protocol init deinit self case default static final open data sealed companion',
  ),
  types: words('Int Long Double Float Boolean Bool String Char Unit Any Array List Map Set Character'),
  constants: words('true false null nil'),
  lineComments: ['//'],
  blockCommentOpen: '/*',
  blockCommentClose: '*/',
  quotes: ['"'],
);
