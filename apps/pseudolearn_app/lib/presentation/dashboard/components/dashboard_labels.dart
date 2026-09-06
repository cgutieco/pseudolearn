import '../../../domain/model/knowledge/ast_construct.dart';
import '../../../domain/model/knowledge/exercise_kind.dart';
import '../../../domain/model/knowledge/exercise_level.dart';
import '../../../domain/model/knowledge/learning_track.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../l10n/generated/app_localizations.dart';

String trackLabelOf(LearningTrack track, AppLocalizations l10n) =>
    switch (track) {
      LearningTrack.foundations => l10n.knowledgeRouteTrackFoundations,
      LearningTrack.imperative => l10n.knowledgeRouteTrackImperative,
      LearningTrack.objectOriented => l10n.knowledgeRouteTrackObjectOriented,
    };

String levelLabelOf(ExerciseLevel level, AppLocalizations l10n) =>
    switch (level) {
      ExerciseLevel.reproduce => l10n.exerciseLevel1,
      ExerciseLevel.compose => l10n.exerciseLevel2,
      ExerciseLevel.design => l10n.exerciseLevel3,
    };

String kindLabelOf(ExerciseKind kind, AppLocalizations l10n) => switch (kind) {
      ExerciseKind.predict => l10n.exerciseKindPredict,
      ExerciseKind.complete => l10n.exerciseKindComplete,
      ExerciseKind.modify => l10n.exerciseKindModify,
      ExerciseKind.create => l10n.exerciseKindCreate,
    };

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
    };

String profileLabelOf(SyntaxProfileId profileId, AppLocalizations l10n) =>
    switch (profileId) {
      SyntaxProfileId.classicSpanish => l10n.dashboardLibraryProfileClassic,
      SyntaxProfileId.english => l10n.dashboardLibraryProfileEnglish,
    };
