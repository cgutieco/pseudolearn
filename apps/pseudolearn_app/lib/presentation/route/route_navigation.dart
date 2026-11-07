import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../reference/reference_runs_text.dart';

void openRouteTarget(BuildContext context, String target) {
  if (target.startsWith(lessonLinkPrefix)) {
    context.push('/conocimiento/ruta/${target.substring(lessonLinkPrefix.length)}');
    return;
  }
  context.push('/conocimiento/especificacion/$target');
}

void openRouteExercise(BuildContext context, String lessonId, String exerciseId) =>
    context.push('/conocimiento/ruta/$lessonId/$exerciseId');
