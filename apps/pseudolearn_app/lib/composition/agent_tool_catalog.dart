import '../application/agent/tool_registry.dart';
import '../application/agent/tools/document_editing_tools.dart';
import '../application/agent/tools/document_reading_tools.dart';
import '../application/agent/tools/document_writing_tools.dart';
import '../application/agent/tools/exercise_writing_tools.dart';
import '../application/agent/tools/explain_diagnostic_tool.dart';
import '../application/agent/tools/navigation_and_settings_tools.dart';
import '../application/agent/tools/program_reading_tools.dart';
import '../application/agent/tools/route_reading_tools.dart';
import '../application/agent/tools/screen_context_tool.dart';
import '../application/agent/tools/search_knowledge_tool.dart';
import '../application/agent/tools/tutor_tools.dart';
import 'agent_use_cases.dart';

ToolRegistry buildAgentToolRegistry(AgentUseCases cases) {
  final writer = DocumentSourceWriter(
    load: cases.loadDocument,
    save: cases.saveSource,
    check: cases.checkProgram,
    language: cases.language,
  );
  return ToolRegistry([
    ScreenContextTool(cases.screen),
    SearchKnowledgeTool(cases.knowledge, cases.languageCode),
    ListDocumentsTool(cases.listDocuments),
    GetDocumentTool(cases.loadDocument),
    CheckProgramTool(cases.checkProgram, cases.language),
    RunProgramTool(cases.runProgram, cases.language),
    TranslateProgramTool(cases.translateProgram),
    FormatProgramTool(cases.formatProgram),
    RouteProgressTool(cases.route, cases.progress, cases.edition),
    GetLessonTool(cases.route, cases.edition),
    GetExerciseTool(cases.route, cases.userExercises, cases.edition),
    ExplainDiagnosticTool(cases.help, cases.language),
    CreateDocumentTool(cases.createDocument),
    RenameDocumentTool(cases.renameDocument),
    EditDocumentTool(writer),
    ReplaceDocumentContentTool(writer),
    DeleteDocumentTool(cases.deleteDocument),
    SetExecutionArgumentsTool(cases.setArguments),
    CreateUserExerciseTool(cases.createExercise),
    UpdateUserExerciseTool(cases.updateExercise),
    DeleteUserExerciseTool(cases.deleteExercise),
    GiveHintTool(cases.activeExercise, cases.assisted),
    RevealSolutionTool(cases.activeExercise, cases.assisted),
    NavigateTool(cases.navigator),
    SetThemeTool(cases.setTheme),
    SetInterfaceLanguageTool(cases.setLanguage),
    SetProfileTool(cases.loadDocument, cases.translateProgram, writer),
  ]);
}
