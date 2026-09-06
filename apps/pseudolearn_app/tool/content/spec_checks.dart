import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/analysis/core_program_analyzer.dart';
import 'package:pseudolearn_app/engine/mapping/profile_catalog.dart';
import 'loaded_content.dart';

const Map<String, String> exemptSpecificationSections = {
  'esp-i-lexico#2': 'Palabras reservadas de varias palabras: dato del perfil.',
  'esp-i-operadores#4': 'Esta tabla ordena, no tipa: remite al sistema de tipos.',
  'esp-i-entrada-salida#5': 'Un valor que no corresponde al tipo: conducta de ejecución.',
  'esp-i-control#0': 'Reglas comunes a las cinco: enuncia lo común.',
  'esp-i-sistema-de-tipos#1': 'La única conversión implícita entre primitivos: ya mostrada en tipos primitivos.',
  'esp-i-sistema-de-tipos#2': 'Rango de los números: fallo de ejecución.',
  'esp-i-sistema-de-tipos#3': 'El tipo de cada operador: tabla de referencia.',
  'esp-i-sistema-de-tipos#5': 'Quién comprueba qué: reparto de responsabilidad entre niveles.',
  'esp-i-sistema-de-tipos#11': 'La política de severidad: es política.',
  'esp-i-funciones-incorporadas#0': 'El catálogo completo: tabla generada por el motor.',
};

List<String> checkSpecificationCoverageAndDiagnostics({
  required LoadedLanguage language,
}) {
  final errors = <String>[];
  for (final entry in language.specificationBlocks.entries) {
    final specId = entry.key;
    final blocks = entry.value;
    final subsections = _groupSubsections(blocks);

    for (var i = 0; i < subsections.length; i++) {
      final sub = subsections[i];
      final sectionKey = '$specId#$i';
      final hasCode = sub.blocks.any((b) => b is CodeBlock);
      if (!hasCode && !exemptSpecificationSections.containsKey(sectionKey)) {
        errors.add(
          'Specification section "$specId" subsection "${sub.heading.text}" '
          '(${language.code}) has no code example and is not in the exempt list',
        );
      }

      errors.addAll(checkBlockCitedDiagnostics(
        blocks: sub.blocks,
        contextName: 'Specification section "$specId" subsection "${sub.heading.text}"',
        languageCode: language.code,
        profileId: language.profileId,
        languageId: language.languageId,
      ));
    }
  }
  return errors;
}

final class _SpecificationSubsection {
  final HeadingBlock heading;
  final List<ContentBlock> blocks;

  const _SpecificationSubsection({
    required this.heading,
    required this.blocks,
  });
}

List<_SpecificationSubsection> _groupSubsections(List<ContentBlock> blocks) {
  final subsections = <_SpecificationSubsection>[];
  HeadingBlock? currentHeading;
  var currentBlocks = <ContentBlock>[];

  for (final block in blocks) {
    if (block is HeadingBlock && block.level == 2) {
      if (currentHeading != null) {
        subsections.add(_SpecificationSubsection(
          heading: currentHeading,
          blocks: currentBlocks,
        ));
      }
      currentHeading = block;
      currentBlocks = [];
    } else if (currentHeading != null) {
      currentBlocks.add(block);
    }
  }
  if (currentHeading != null) {
    subsections.add(_SpecificationSubsection(
      heading: currentHeading,
      blocks: currentBlocks,
    ));
  }
  return subsections;
}

List<String> checkBlockCitedDiagnostics({
  required List<ContentBlock> blocks,
  required String contextName,
  required String languageCode,
  required SyntaxProfileId profileId,
  required UiLanguageId languageId,
}) {
  final cited = citedCodesOf(blocks);
  if (cited.isEmpty) return const [];
  final produced = producedDiagnosticCodes(
    programs: programsOf(blocks),
    profileId: profileId,
    languageId: languageId,
  );
  final errors = <String>[];
  for (final code in cited) {
    if (produced.contains(code)) continue;
    errors.add(
      '$contextName ($languageCode) cites diagnostic "$code", but no program in '
      'that section produces it',
    );
  }
  return errors;
}

List<String> citedCodesOf(List<ContentBlock> blocks) {
  final codes = <String>[];
  for (final block in blocks) {
    if (block is DiagnosticBlock) codes.add(block.code);
    if (block is MarkerBlock) codes.add(block.resolvedText);
  }
  return codes;
}

List<String> programsOf(List<ContentBlock> blocks) {
  final programs = <String>[];
  for (final block in blocks) {
    if (block is CodeBlock) programs.add(block.code);
  }
  return programs;
}

Set<String> producedDiagnosticCodes({
  required List<String> programs,
  required SyntaxProfileId profileId,
  required UiLanguageId languageId,
}) {
  final analyzer = CoreProgramAnalyzer();
  final codes = <String>{};
  final profile = ProfileCatalog.toLanguageProfile(profileId);
  for (final program in programs) {
    final report = analyzer.analyze(
      sourceCode: program,
      profileId: profileId,
      languageId: languageId,
    );
    for (final diagnostic in report.diagnostics) {
      codes.add(diagnostic.code);
    }
    final lexer = Lexer(profile).tokenize(program);
    final parser = Parser(profile: profile).parse(TokenStream(lexer.tokens));
    if (parser.program != null) {
      final res = NameResolver(profile: profile).resolve(parser.program!);
      final strictCheck = TypeChecker(
        resolution: res,
        profile: profile,
        strictInitialization: true,
      ).check(parser.program!);
      for (final d in strictCheck.diagnostics) {
        codes.add(d.code.name);
      }
    }
  }
  return codes;
}
