import 'code_language.dart';
import 'code_languages_compiled.dart';
import 'code_languages_scripted.dart';

final Map<String, CodeLanguage> _languagesByName = {
  for (final name in words('javascript js jsx mjs cjs typescript ts tsx node')) name: javaScriptLanguage,
  for (final name in words('java')) name: javaLanguage,
  for (final name in words('c h cpp c++ cc hpp cxx csharp cs c# objective-c objc arduino')) name: cFamilyLanguage,
  for (final name in words('go golang')) name: goLanguage,
  for (final name in words('rust rs')) name: rustLanguage,
  for (final name in words('dart flutter')) name: dartLanguage,
  for (final name in words('kotlin kt kts swift scala')) name: kotlinSwiftLanguage,
  for (final name in words('python py python3 py3')) name: pythonLanguage,
  for (final name in words('ruby rb')) name: rubyLanguage,
  for (final name in words('php')) name: phpLanguage,
  for (final name in words('bash sh shell zsh console terminal powershell ps1 bat cmd dockerfile makefile')) name: shellLanguage,
  for (final name in words('sql mysql postgresql postgres sqlite plsql')) name: sqlLanguage,
  for (final name in words('json jsonc json5 yaml yml toml ini env properties')) name: dataLanguage,
  for (final name in words('html xml svg xhtml vue')) name: markupLanguage,
  for (final name in words('css scss sass less')) name: styleLanguage,
};

CodeLanguage codeLanguageNamed(String name) => _languagesByName[name.toLowerCase()] ?? CodeLanguage.plain;
