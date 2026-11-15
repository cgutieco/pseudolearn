import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/editor/help/help_program_highlighter.dart';
import '../application/editor/help/syntax_help_cubit.dart';
import 'app_dependencies.dart';

BlocProvider<SyntaxHelpCubit> createSyntaxHelpProvider(
  AppDependencies dependencies,
) {
  return BlocProvider<SyntaxHelpCubit>(
    create: (_) => SyntaxHelpCubit(
      source: dependencies.syntaxHelpSource,
      highlighter: HelpProgramHighlighter(dependencies.programAnalyzer),
    ),
  );
}
