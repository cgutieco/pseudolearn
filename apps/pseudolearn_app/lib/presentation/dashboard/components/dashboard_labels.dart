import '../../../domain/model/knowledge/ast_construct.dart';
import '../../../domain/model/route/route_kinds.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../route/route_labels.dart';

String levelLabelOf(RouteLevel level, AppLocalizations l10n) =>
    routeLevelLabel(level, l10n);

String kindLabelOf(RouteExerciseKind kind, AppLocalizations l10n) =>
    routeKindLabel(kind, l10n);

String conceptLabelOf(AstConstruct construct, AppLocalizations l10n) =>
    switch (construct) {
      AstConstruct.conditional => l10n.dashboardConceptConditional,
      AstConstruct.multipleSelection => l10n.dashboardConceptMultipleSelection,
      AstConstruct.conditionalLoop => l10n.dashboardConceptConditionalLoop,
      AstConstruct.postConditionalLoop =>
        l10n.dashboardConceptPostConditionalLoop,
      AstConstruct.countedLoop => l10n.dashboardConceptCountedLoop,
      AstConstruct.arrayDeclaration => l10n.dashboardConceptArray,
      AstConstruct.subprogram => l10n.dashboardConceptSubprogram,
      AstConstruct.classDeclaration => l10n.dashboardConceptClass,
      AstConstruct.interfaceDeclaration => l10n.dashboardConceptInterface,
    };

String profileLabelOf(SyntaxProfileId profileId, AppLocalizations l10n) =>
    switch (profileId) {
      SyntaxProfileId.classicSpanish => l10n.dashboardLibraryProfileClassic,
      SyntaxProfileId.english => l10n.dashboardLibraryProfileEnglish,
    };
