use crate::model::{ApiDiagnostic, IrRequest, IrResponse};
use pseudolearn_diagnostics::{DiagnosticCode, DiagnosticSeverity, sort_diagnostics};
use pseudolearn_ir::Module;
use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::{HirModule, SemanticOptions, analyze_with_options};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{ModuleSchema, SyntaxTree, UnitKind, parse_source_with_terminator};

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
    let profile = Profile::from_name(profile_name).unwrap_or(Profile::Spanish);
    let strict = strictness_mode != "flexible";
    let source_text = SourceText::new(source_content.to_owned());
    let terminator = strict.then_some(DiagnosticCode::MissingStatementTerminator);
    let (syntax_tree, mut diagnostics) =
        parse_source_with_terminator(&source_text, profile, terminator);

    if !syntax_tree.has_errors {
        let (semantic_module, mut semantic_diagnostics) = analyze_with_options(
            &syntax_tree,
            &source_text,
            SemanticOptions { profile, strict },
        );
        diagnostics.append(&mut semantic_diagnostics);

        let has_semantic_failure = diagnostics
            .iter()
            .any(|entry| entry.severity == DiagnosticSeverity::Error);
        if let (Some(hir_module), false) = (&semantic_module, has_semantic_failure)
            && let Some(canonical_ir) =
                extract_canonical_ir(&syntax_tree, &source_text, hir_module, profile.as_str())
        {
            return Ok(canonical_ir);
        }
    }

    sort_diagnostics(&mut diagnostics);
    let converted = diagnostics
        .iter()
        .map(|diagnostic| {
            crate::diagnostic_conversion::convert(diagnostic, &source_text, profile.as_str())
        })
        .collect();
    Err(converted)
}

fn extract_canonical_ir(
    syntax_tree: &SyntaxTree,
    source_text: &SourceText,
    semantic_module: &HirModule,
    profile_name: &str,
) -> Option<String> {
    let mut ir_module = pseudolearn_lowering::lower_module(semantic_module, source_text).ok()?;
    configure_module_header(&mut ir_module, syntax_tree, source_text, profile_name);
    pseudolearn_ir::verify_module(&ir_module).ok()?;
    Some(pseudolearn_ir::print_canonical(&ir_module))
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
