import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/agent/tools/explain_diagnostic_tool.dart';
import 'package:pseudolearn_app/application/agent/tools/program_reading_tools.dart';
import 'package:pseudolearn_app/application/agent/tools/tool_arguments.dart';
import 'package:pseudolearn_app/application/program/use_cases/check_program.dart';
import 'package:pseudolearn_app/application/program/use_cases/format_program.dart';
import 'package:pseudolearn_app/application/program/use_cases/run_program.dart';
import 'package:pseudolearn_app/application/program/use_cases/translate_program.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../../fakes/native_test_engine.dart';

const String _reading = 'Algoritmo P\n  Definir x Como Entero;\n  Leer x;\n  Escribir x + 1;\nFinAlgoritmo\n';

void main() {
  final engine = nativeTestEngine;
  UiLanguageId language() => UiLanguageId.spanish;

  test('check reports diagnostics with positions', () async {
    final tool = CheckProgramTool(CheckProgram(analyzer: engine.analyzer), language);
    final result = await tool.run(const ToolArguments({'source': 'Algoritmo P\n  Si x >\nFinAlgoritmo\n', 'profile': 'classicSpanish'}));
    expect(result.output['executable'], isFalse);
    expect((result.output['diagnostics'] as List).first, containsPair('line', isA<int>()));
    expect((await tool.run(const ToolArguments({'source': 'x'}))).output['error'], 'invalid_arguments');
  });

  test('run feeds inputs and reports the outcome', () async {
    final tool = RunProgramTool(RunProgram(analyzer: engine.analyzer, runner: engine.programTools.runner), language);
    final result = await tool.run(const ToolArguments({'source': _reading, 'profile': 'classicSpanish', 'inputs': ['41']}));
    expect(result.output['outputs'], ['42']);
    final starved = await tool.run(const ToolArguments({'source': _reading, 'profile': 'classicSpanish'}));
    expect(starved.output['outcome'], 'inputsExhausted');
  });

  test('translate and format return text or a refusal', () async {
    final translate = TranslateProgramTool(TranslateProgram(translator: engine.programTools.translator));
    final translated = await translate.run(const ToolArguments({'source': _reading, 'target_profile': 'english'}));
    expect((translated.output['source'] as String).toLowerCase(), contains('read x;'));
    final format = FormatProgramTool(FormatProgram(formatter: engine.programTools.formatter));
    final unchanged = await format.run(const ToolArguments({'source': _reading, 'profile': 'classicSpanish'}));
    expect(unchanged.output['error'], 'unchanged');
  });

  test('explain returns the help card at an offset and rejects missing arguments', () async {
    final tool = ExplainDiagnosticTool(engine.syntaxHelpSource, language);
    final result = await tool.run(const ToolArguments({'source': _reading, 'profile': 'classicSpanish', 'offset': 26}));
    expect(result.succeeded || result.output['error'] == 'no_help', isTrue);
    expect((await tool.run(const ToolArguments({'source': _reading}))).output['error'], 'invalid_arguments');
  });
}
