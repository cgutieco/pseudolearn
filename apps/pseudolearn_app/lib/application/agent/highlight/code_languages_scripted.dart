import 'code_language.dart';

final CodeLanguage pythonLanguage = CodeLanguage(
  keywords: words(
    'and as assert async await break class continue def del elif else except finally for from global if '
    'import in is lambda nonlocal not or pass raise return try while with yield match case print',
  ),
  types: words('int float str bool list dict set tuple bytes object range len self'),
  constants: words('True False None'),
  lineComments: ['#'],
  quotes: ['"""', "'''", '"', "'"],
);

final CodeLanguage rubyLanguage = CodeLanguage(
  keywords: words(
    'alias and begin break case class def do else elsif end ensure for if in module next not or redo '
    'rescue retry return self super then undef unless until when while yield puts require attr_accessor',
  ),
  constants: words('true false nil'),
  lineComments: ['#'],
);

final CodeLanguage phpLanguage = CodeLanguage(
  keywords: words(
    'abstract and as break case catch class const continue declare default do echo else elseif extends '
    'final finally fn for foreach function global if implements include interface namespace new or print '
    'private protected public require return static switch throw trait try use var while yield',
  ),
  constants: words('true false null TRUE FALSE NULL'),
  lineComments: ['//', '#'],
  blockCommentOpen: '/*',
  blockCommentClose: '*/',
);

final CodeLanguage shellLanguage = CodeLanguage(
  keywords: words(
    'if then else elif fi for while until do done case esac in function return exit export local readonly '
    'echo cd source set unset shift alias sudo',
  ),
  constants: words('true false'),
  lineComments: ['#'],
);

final CodeLanguage sqlLanguage = CodeLanguage(
  keywords: words(
    'select from where and or not insert into values update set delete create table drop alter add join '
    'inner left right outer full on as group by order having limit offset distinct union all case when '
    'then else end index primary key foreign references unique default exists in between like is with',
  ),
  types: words('int integer bigint smallint varchar char text boolean date timestamp numeric decimal real serial uuid'),
  constants: words('true false null'),
  lineComments: ['--'],
  blockCommentOpen: '/*',
  blockCommentClose: '*/',
  caseInsensitive: true,
);

final CodeLanguage dataLanguage = CodeLanguage(
  constants: words('true false null yes no on off'),
  lineComments: ['#'],
);

const CodeLanguage markupLanguage = CodeLanguage(
  blockCommentOpen: '<!--',
  blockCommentClose: '-->',
  tagNames: true,
);

final CodeLanguage styleLanguage = CodeLanguage(
  keywords: words('important media import keyframes from to'),
  blockCommentOpen: '/*',
  blockCommentClose: '*/',
);
