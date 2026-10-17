use crate::model::{ApiDiagnostic, IrRequest, IrResponse};
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode, DiagnosticSeverity, sort_diagnostics};
use pseudolearn_ir::Module;
use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::{HirModule, SemanticOptions, analyze_with_options};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{ModuleSchema, SyntaxTree, UnitKind, parse_source_with_terminator};

struct CompilationMode {
    profile: Profile,
    is_strict: bool,
}

struct ParsedCompilation {
    syntax_tree: SyntaxTree,
    source_text: SourceText,
    diagnostics: Vec<Diagnostic>,
}

pub fn execute_ir(request: &IrRequest) -> IrResponse {
    if !request.program_ir.is_empty() {
        return parse_ir_and_respond(&request.program_ir);
    }
    if !request.program.is_empty() {
        return match compile_source_to_ir(&request.program, &request.profile, &request.strictness) {
            Ok(canonical_reprint) => IrResponse::accepted(canonical_reprint),
            Err(_) => IrResponse::rejected("IR.WELL-FORMEDNESS#R1".to_owned()),
        };
    }
    IrResponse::rejected("IR.WELL-FORMEDNESS#R1".to_owned())
}

fn parse_ir_and_respond(program_ir: &str) -> IrResponse {
    let parsed_module = match pseudolearn_ir::parse_module(program_ir) {
        Ok(module) => module,
        Err(_) => return IrResponse::rejected("IR.WELL-FORMEDNESS#R1".to_owned()),
    };
    if let Err(violated_rule) = pseudolearn_ir::verify_module(&parsed_module) {
        return IrResponse::rejected(violated_rule.to_owned());
    }
    let canonical_reprint = pseudolearn_ir::print_canonical(&parsed_module);
    IrResponse::accepted(canonical_reprint)
}

pub fn compile_source_to_ir(
    source_content: &str,
    profile_name: &str,
    strictness_mode: &str,
) -> Result<String, Vec<ApiDiagnostic>> {
    compile_source_to_module(source_content, profile_name, strictness_mode)
        .map(|module| pseudolearn_ir::print_canonical(&module))
}

pub fn compile_source_to_module(
    source_content: &str,
    profile_name: &str,
    strictness_mode: &str,
) -> Result<Module, Vec<ApiDiagnostic>> {
    compile_source_with_warnings(source_content, profile_name, strictness_mode)
        .map(|(module, _)| module)
}

pub(crate) fn compile_source_with_warnings(
    source_content: &str,
    profile_name: &str,
    strictness_mode: &str,
) -> Result<(Module, Vec<ApiDiagnostic>), Vec<ApiDiagnostic>> {
    let mode = CompilationMode {
        profile: Profile::from_name(profile_name).unwrap_or(Profile::Spanish),
        is_strict: strictness_mode != "flexible",
    };
    let source_text = SourceText::new(source_content.to_owned());
    let terminator = mode
        .is_strict
        .then_some(DiagnosticCode::MissingStatementTerminator);
    let (syntax_tree, diagnostics) =
        parse_source_with_terminator(&source_text, mode.profile, terminator);
    compile_parsed_source(
        ParsedCompilation {
            syntax_tree,
            source_text,
            diagnostics,
        },
        mode,
    )
}

fn compile_parsed_source(
    parsed: ParsedCompilation,
    mode: CompilationMode,
) -> Result<(Module, Vec<ApiDiagnostic>), Vec<ApiDiagnostic>> {
    let ParsedCompilation {
        syntax_tree,
        source_text,
        mut diagnostics,
    } = parsed;
    if syntax_tree.has_errors {
        return Err(convert_diagnostics(diagnostics, &source_text, mode.profile));
    }
    let (semantic_module, mut semantic_diagnostics) = analyze_with_options(
        &syntax_tree,
        &source_text,
        SemanticOptions {
            profile: mode.profile,
            strict: mode.is_strict,
        },
    );
    diagnostics.append(&mut semantic_diagnostics);
    if has_error_diagnostics(&diagnostics) {
        return Err(convert_diagnostics(diagnostics, &source_text, mode.profile));
    }
    let Some(hir_module) = semantic_module else {
        return Err(convert_diagnostics(diagnostics, &source_text, mode.profile));
    };
    let Some(canonical_ir) = extract_canonical_ir(
        &syntax_tree,
        &source_text,
        &hir_module,
        mode.profile.as_str(),
    ) else {
        return Err(convert_diagnostics(diagnostics, &source_text, mode.profile));
    };
    let warnings = convert_warnings(diagnostics, &source_text, mode.profile);
    Ok((canonical_ir, warnings))
}

fn has_error_diagnostics(diagnostics: &[Diagnostic]) -> bool {
    diagnostics
        .iter()
        .any(|diagnostic| diagnostic.severity == DiagnosticSeverity::Error)
}

fn convert_warnings(
    diagnostics: Vec<Diagnostic>,
    source_text: &SourceText,
    profile: Profile,
) -> Vec<ApiDiagnostic> {
    let warnings = diagnostics
        .into_iter()
        .filter(|diagnostic| diagnostic.severity != DiagnosticSeverity::Error)
        .collect();
    convert_diagnostics(warnings, source_text, profile)
}

fn convert_diagnostics(
    mut diagnostics: Vec<Diagnostic>,
    source_text: &SourceText,
    profile: Profile,
) -> Vec<ApiDiagnostic> {
    sort_diagnostics(&mut diagnostics);
    diagnostics
        .iter()
        .map(|diagnostic| {
            crate::diagnostic_conversion::convert(diagnostic, source_text, profile.as_str())
        })
        .collect()
}

fn extract_canonical_ir(
    syntax_tree: &SyntaxTree,
    source_text: &SourceText,
    semantic_module: &HirModule,
    profile_name: &str,
) -> Option<Module> {
    let mut ir_module = pseudolearn_lowering::lower_module(semantic_module, source_text).ok()?;
    configure_module_header(&mut ir_module, syntax_tree, source_text, profile_name);
    pseudolearn_ir::verify_module(&ir_module).ok()?;
    Some(ir_module)
}

fn configure_module_header(
    ir_module: &mut Module,
    syntax_tree: &SyntaxTree,
    source_text: &SourceText,
    profile_name: &str,
) {
    ir_module.vocabulary = profile_name.to_owned();
    let schema = ModuleSchema::extract(syntax_tree, source_text);
    for unit in &schema.units {
        if unit.kind == UnitKind::Program {
            ir_module.name = unit.name.clone();
            break;
        }
    }
}
