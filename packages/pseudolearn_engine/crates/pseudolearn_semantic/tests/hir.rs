use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::{SemanticOptions, Type, analyze_with_options};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source_with_terminator;
use serde_json::Value;

#[test]
fn audits_types_and_spans_of_every_successfully_analyzed_corpus_program() -> Result<(), String> {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../../../pseudolearn_spec/specifications/export.json");
    let corpus: Value =
        serde_json::from_str(&std::fs::read_to_string(path).map_err(|error| error.to_string())?)
            .map_err(|error| error.to_string())?;
    let specifications = corpus
        .get("specifications")
        .and_then(Value::as_array)
        .ok_or("Missing specifications")?;
    let mut failures = Vec::new();
    for specification in specifications {
        for block in specification
            .get("blocks")
            .and_then(Value::as_array)
            .into_iter()
            .flatten()
        {
            if block.get("kind").and_then(Value::as_str) != Some("caso") {
                continue;
            }
            let fields = block.get("fields").ok_or("Missing fields")?;
            failures.extend(audit_case(specification, fields));
        }
    }
    assert!(failures.is_empty(), "{}", failures.join("\n"));
    Ok(())
}

fn audit(program: &str, profile: Profile, strict: bool, require_valid: bool) -> Option<String> {
    let source = SourceText::new(program.to_owned());
    let terminator =
        strict.then_some(pseudolearn_diagnostics::DiagnosticCode::MissingStatementTerminator);
    let (tree, mut diagnostics) = parse_source_with_terminator(&source, profile, terminator);
    let (module, mut semantic) =
        analyze_with_options(&tree, &source, SemanticOptions { profile, strict });
    diagnostics.append(&mut semantic);
    if let Some(diagnostic) = diagnostics
        .iter()
        .find(|diagnostic| !pseudolearn_diagnostics::validate_arguments(diagnostic))
    {
        return Some(format!(
            "Invalid arguments for {:?}: {:?}; expected {:?}",
            diagnostic.code,
            diagnostic.arguments,
            diagnostic.code.argument_specs()
        ));
    }
    if require_valid && module.is_none() {
        return Some("Generated program did not produce HIR".to_owned());
    }
    audit_columns(&module?, program.len())
}

fn audit_columns(module: &pseudolearn_semantic::HirModule, source_length: usize) -> Option<String> {
    if module.expressions.kinds.len() != module.expressions.types.len()
        || module.expressions.kinds.len() != module.expressions.spans.len()
    {
        return Some("Inconsistent HIR columns".to_owned());
    }
    if let Some(local) = module
        .locals
        .iter()
        .find(|local| matches!(module.types.get(local.type_id), Type::Unknown | Type::Error))
    {
        return Some(format!(
            "unresolved local {}: {:?}",
            local.name,
            module.types.get(local.type_id)
        ));
    }
    for index in 0..module.expressions.kinds.len() {
        if let Some(failure) = audit_expression(module, index, source_length) {
            return Some(failure);
        }
    }
    None
}

fn audit_expression(
    module: &pseudolearn_semantic::HirModule,
    index: usize,
    source_length: usize,
) -> Option<String> {
    let Some(kind) = module.expressions.types.get(index) else {
        return Some("Missing expression type".to_owned());
    };
    let span = module
        .expressions
        .spans
        .get(index)
        .copied()
        .unwrap_or_default();
    if matches!(module.types.get(*kind), Type::Unknown | Type::Error) {
        return Some(format!(
            "unresolved {:?} for {:?} at {span:?}",
            module.types.get(*kind),
            module.expressions.kinds.get(index)
        ));
    }
    if span.start > span.ending
        || usize::try_from(span.ending)
            .ok()
            .is_none_or(|ending| ending > source_length)
    {
        return Some(format!("invalid span {span:?}"));
    }
    None
}

fn audit_case(specification: &Value, fields: &Value) -> Vec<String> {
    let mut failures = Vec::new();
    for profile in [Profile::Spanish, Profile::English] {
        let program = fields
            .get("programas")
            .and_then(|programs| programs.get(profile.as_str()))
            .and_then(Value::as_str)
            .or_else(|| {
                (profile == Profile::Spanish)
                    .then(|| fields.get("programa").and_then(Value::as_str))
                    .flatten()
            });
        let Some(program) = program else {
            continue;
        };
        for strict in [false, true] {
            if let Some(failure) = audit(program, profile, strict, false) {
                failures.push(format!(
                    "{} {} {profile:?} strict={strict}: {failure}",
                    specification
                        .pointer("/metadata/id")
                        .unwrap_or(&Value::Null),
                    fields.get("id").unwrap_or(&Value::Null)
                ));
            }
        }
    }
    failures
}

#[test]
fn audits_typed_hir_of_generated_programs_in_both_strictness_modes() -> Result<(), String> {
    let cases = [
        (
            "Proceso Generated\nDefinir Mutable total Como Entero <- 0;\ntotal <- 42;\nEscribir total;\nFinProceso",
            Profile::Spanish,
        ),
        (
            "algorithm Generated\ndefine mutable total as integer <- 0;\ntotal <- 42;\nwrite total;\nendAlgorithm",
            Profile::English,
        ),
    ];
    for (program, profile) in cases {
        for strict in [false, true] {
            assert_eq!(
                audit(program, profile, strict, true),
                None,
                "{profile:?} strict={strict}"
            );
        }
    }
    Ok(())
}
