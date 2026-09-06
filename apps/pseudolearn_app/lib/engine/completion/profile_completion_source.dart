import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/completion/completion_item.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/ports/completion_source.dart';
import '../mapping/profile_catalog.dart';

final class ProfileCompletionSource implements CompletionSource {
  const ProfileCompletionSource();

  @override
  List<CompletionItem> getCompletions(SyntaxProfileId profileId) {
    final profile = ProfileCatalog.toLanguageProfile(profileId);
    final lex = profile;

    return [
      ..._conditionalCompletions(lex),
      ..._loopCompletions(lex),
      ..._ioCompletions(lex),
      ..._proceduralAndOopCompletions(lex),
    ];
  }

  List<CompletionItem> _conditionalCompletions(SyntaxLexicon lex) {
    final kwIf = lex.formatTokenType(TokenType.ifKeyword);
    final kwThen = lex.formatTokenType(TokenType.then);
    final kwElse = lex.formatTokenType(TokenType.elseKeyword);
    final kwEndIf = lex.formatTokenType(TokenType.endIf);
    final kwSwitch = lex.formatTokenType(TokenType.switchKeyword);
    final kwEndSwitch = lex.formatTokenType(TokenType.endSwitch);

    return [
      CompletionItem(
        label: '$kwIf $kwThen',
        template: '$kwIf condicion $kwThen\n  \n$kwEndIf',
        caretOffset: kwIf.length + 1,
        family: CompletionFamily.structured,
      ),
      CompletionItem(
        label: '$kwIf $kwElse',
        template: '$kwIf condicion $kwThen\n  \n$kwElse\n  \n$kwEndIf',
        caretOffset: kwIf.length + 1,
        family: CompletionFamily.structured,
      ),
      CompletionItem(
        label: kwSwitch,
        template: '$kwSwitch variable\n  \n$kwEndSwitch',
        caretOffset: kwSwitch.length + 1,
        family: CompletionFamily.structured,
      ),
    ];
  }

  List<CompletionItem> _loopCompletions(SyntaxLexicon lex) {
    final kwWhile = lex.formatTokenType(TokenType.whileKeyword);
    final kwDo = lex.formatTokenType(TokenType.doKeyword);
    final kwEndWhile = lex.formatTokenType(TokenType.endWhile);
    final kwRepeat = lex.formatTokenType(TokenType.repeat);
    final kwUntil = lex.formatTokenType(TokenType.until);
    final kwFor = lex.formatTokenType(TokenType.forKeyword);
    final kwTo = lex.formatTokenType(TokenType.to);
    final kwStep = lex.formatTokenType(TokenType.step);
    final kwEndFor = lex.formatTokenType(TokenType.endFor);

    return [
      CompletionItem(
        label: '$kwWhile $kwDo',
        template: '$kwWhile condicion $kwDo\n  \n$kwEndWhile',
        caretOffset: kwWhile.length + 1,
        family: CompletionFamily.structured,
      ),
      CompletionItem(
        label: '$kwRepeat $kwUntil',
        template: '$kwRepeat\n  \n$kwUntil condicion',
        caretOffset: kwRepeat.length + 3,
        family: CompletionFamily.structured,
      ),
      CompletionItem(
        label: '$kwFor $kwTo',
        template: '$kwFor i <- 1 $kwTo 10 $kwStep 1 $kwDo\n  \n$kwEndFor',
        caretOffset: kwFor.length + 1,
        family: CompletionFamily.structured,
      ),
    ];
  }

  List<CompletionItem> _ioCompletions(SyntaxLexicon lex) {
    final kwWrite = lex.formatTokenType(TokenType.write);
    final kwRead = lex.formatTokenType(TokenType.read);

    return [
      CompletionItem(
        label: kwWrite,
        template: '$kwWrite "mensaje"',
        caretOffset: kwWrite.length + 1,
        family: CompletionFamily.structured,
      ),
      CompletionItem(
        label: kwRead,
        template: '$kwRead variable',
        caretOffset: kwRead.length + 1,
        family: CompletionFamily.structured,
      ),
    ];
  }

  List<CompletionItem> _proceduralAndOopCompletions(SyntaxLexicon lex) {
    final kwSub = lex.formatTokenType(TokenType.subroutine);
    final kwEndSub = lex.formatTokenType(TokenType.endSubroutine);
    final kwClass = lex.formatTokenType(TokenType.classKeyword);
    final kwEndClass = lex.formatTokenType(TokenType.endClass);

    return [
      CompletionItem(
        label: kwSub,
        template: '$kwSub nombre()\n  \n$kwEndSub',
        caretOffset: kwSub.length + 1,
        family: CompletionFamily.procedural,
      ),
      CompletionItem(
        label: kwClass,
        template: '$kwClass Nombre\n  \n$kwEndClass',
        caretOffset: kwClass.length + 1,
        family: CompletionFamily.oop,
      ),
    ];
  }
}
