import '../model/profiles/syntax_profile_id.dart';
import '../model/route/route_answer.dart';
import '../model/route/route_exercise.dart';
import '../model/route/route_verdict.dart';
import '../model/settings/ui_language_id.dart';

abstract interface class RouteAnswerEvaluator {
  RouteVerdict evaluate({
    required RouteExercise exercise,
    required RouteAnswer answer,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  });
}
