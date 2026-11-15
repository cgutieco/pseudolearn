import 'dart:ui';
import '../../domain/model/route/route_kinds.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';

String routeKindLabel(RouteExerciseKind kind, AppLocalizations l10n) =>
    switch (kind) {
      RouteExerciseKind.predict => l10n.routeKindPredict,
      RouteExerciseKind.trace => l10n.routeKindTrace,
      RouteExerciseKind.order => l10n.routeKindOrder,
      RouteExerciseKind.findError => l10n.routeKindFindError,
      RouteExerciseKind.breakIt => l10n.routeKindBreak,
      RouteExerciseKind.designTests => l10n.routeKindDesignTests,
      RouteExerciseKind.modify => l10n.routeKindModify,
      RouteExerciseKind.solve => l10n.routeKindSolve,
      RouteExerciseKind.compare => l10n.routeKindCompare,
      RouteExerciseKind.classify => l10n.routeKindClassify,
      RouteExerciseKind.explain => l10n.routeKindExplain,
    };

String routeLevelLabel(RouteLevel level, AppLocalizations l10n) =>
    switch (level) {
      RouteLevel.seed => l10n.routeLevelSeed,
      RouteLevel.sprout => l10n.routeLevelSprout,
      RouteLevel.tree => l10n.routeLevelTree,
    };

String routePhaseLabel(int phase, AppLocalizations l10n) => switch (phase) {
  1 => l10n.routePhaseUnderstand,
  2 => l10n.routePhasePlan,
  3 => l10n.routePhaseWrite,
  4 => l10n.routePhaseTest,
  _ => l10n.routePhaseImprove,
};

Color routePhaseColor(int phase, AppThemeExtension theme) => switch (phase) {
  1 => theme.syntax.keywordStructured,
  2 => theme.colors.severities.warning.fg,
  3 => theme.syntax.keywordProcedural,
  4 => theme.syntax.keywordOop,
  _ => theme.colors.severities.success.fg,
};

const List<int> routePhases = [1, 2, 3, 4, 5];
