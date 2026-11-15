use crate::execution_resource::usage;
use crate::program_view::ProgramView;
use crate::program_view_operations::revision_of;
use crate::resources::Resource;
use crate::{AnalyzeRequest, ApiError, ApiSession};
use pseudolearn_diagnostics::{Diagnostic, DiagnosticSeverity};
use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::{HirModule, SemanticOptions, analyze_with_options};
use pseudolearn_source::Span;
use pseudolearn_syntax::parse_source;
use pseudolearn_transpiler::{
    Blocker, TargetLanguage, Transpilation, TranspileOutcome, TranspileRequest, transpile,
};
use serde_json::{Value, json};

impl ApiSession {
    pub(crate) fn equivalent_code_operation(&self, arguments: &Value) -> Result<Value, ApiError> {
        let document = arguments
            .get("resource")
            .and_then(Value::as_u64)
            .ok_or_else(|| usage("missing resource"))?;
        let Some(Resource::Document(request)) = self.resources.get(&document) else {
            return Err(usage("invalid document"));
        };
        let target = arguments
            .get("target")
            .and_then(Value::as_str)
            .and_then(TargetLanguage::from_identity)
            .ok_or_else(|| usage("invalid target"))?;
        let seed = arguments.get("seed").and_then(Value::as_i64);
        Ok(equivalent_code_with_revision(
            request,
            target,
            seed,
            revision_of(document),
        ))
    }
}

pub fn equivalent_code(
    request: &AnalyzeRequest,
    target: TargetLanguage,
    seed: Option<i64>,
) -> Value {
    equivalent_code_with_revision(request, target, seed, "rev0".to_owned())
}

fn has_errors(diagnostics: &[Diagnostic]) -> bool {
    diagnostics
        .iter()
        .any(|diagnostic| diagnostic.severity == DiagnosticSeverity::Error)
}

fn analyzed_module(request: &AnalyzeRequest, profile: Profile) -> Option<HirModule> {
    let source_text = crate::source_identity::source_text(request.program.clone(), request.source);
    let (tree, diagnostics) = parse_source(&source_text, profile);
    if tree.has_errors || has_errors(&diagnostics) {
        return None;
    }
    let (module, semantic) = analyze_with_options(&tree, &source_text, SemanticOptions { profile });
    if has_errors(&semantic) {
        return None;
    }
    module
}

fn equivalent_code_with_revision(
    request: &AnalyzeRequest,
    target: TargetLanguage,
    seed: Option<i64>,
    revision: String,
) -> Value {
    let profile = Profile::from_name(&request.profile).unwrap_or(Profile::Spanish);
    let Some(module) = analyzed_module(request, profile) else {
        return json!({"status": "analysis_error", "target": target.identity()});
    };
    let (truth, falsity) = pseudolearn_vm::boolean_words(&request.profile);
    let transpile_request = TranspileRequest {
        target,
        profile,
        seed,
        truth,
        falsity,
    };
    let view = ProgramView::build_with_pending_links(request, revision).ok();
    match transpile(&module, &transpile_request) {
        TranspileOutcome::Code(transpilation) => ready_json(&transpilation, target, view.as_ref()),
        TranspileOutcome::Unavailable(blockers) => {
            unavailable_json(&blockers, target, view.as_ref())
        }
    }
}

fn ready_json(
    transpilation: &Transpilation,
    target: TargetLanguage,
    view: Option<&ProgramView>,
) -> Value {
    let origins = transpilation
        .line_origins
        .iter()
        .map(|origin| origin.and_then(|span| node_of(view, span)))
        .collect::<Vec<_>>();
    json!({
        "status": "ready",
        "target": target.identity(),
        "code": transpilation.code,
        "line_origins": origins,
    })
}

fn unavailable_json(
    blockers: &[Blocker],
    target: TargetLanguage,
    view: Option<&ProgramView>,
) -> Value {
    let blockers = blockers
        .iter()
        .map(|blocker| {
            json!({
                "construct": blocker.construct,
                "node_id": node_of(view, blocker.span),
                "start": blocker.span.start.to_string(),
                "end": blocker.span.ending.to_string(),
            })
        })
        .collect::<Vec<_>>();
    json!({"status": "unavailable", "target": target.identity(), "blockers": blockers})
}

fn node_of(view: Option<&ProgramView>, span: Span) -> Option<String> {
    let view = view?;
    let mut best: Option<(u32, usize)> = None;
    let mut ordinal = 0_usize;
    while let Some(node) = view.node(ordinal) {
        let contains = node.start_byte <= span.start && span.ending <= node.end_byte;
        let width = node.end_byte.saturating_sub(node.start_byte);
        if contains && best.is_none_or(|(found, _)| width < found) {
            best = Some((width, ordinal));
        }
        ordinal = ordinal.saturating_add(1);
    }
    best.map(|(_, found)| view.node_identifier(found))
}
