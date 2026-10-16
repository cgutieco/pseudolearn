use super::mutation::{Generator, mutate_text};
use super::sources::Source;
use pseudolearn_api::{AnalyzeRequest, ExecuteRequest, IrRequest};
use serde_json::{Value, json};
use std::sync::atomic::{AtomicUsize, Ordering};

pub static PANICS: AtomicUsize = AtomicUsize::new(0);
const INTERNAL_FAULT: &str = "internalFault";
const STATEMENT_BUDGET: u64 = 3000;

pub enum Outcome {
    Clean,
    Rejected,
    NotApplicable,
    Finding(Value),
}

pub fn evaluate(
    campaign: &str,
    seed: u64,
    case: u64,
    sources: &[Source],
) -> Result<Outcome, String> {
    let position = usize::try_from(case)
        .map_err(|error| error.to_string())?
        .checked_rem(sources.len())
        .ok_or("SEE-ROBUSTNESS: empty corpus")?;
    let source = sources
        .get(position)
        .ok_or("SEE-ROBUSTNESS: missing source")?;
    let mut generator = Generator::new(seed, case);
    let before = PANICS.load(Ordering::SeqCst);
    let outcome = match campaign {
        "source" => source_case(source, &mut generator),
        "ir" => ir_case(source, &mut generator),
        "bytecode" => super::bytecode::bytecode_case(source, &mut generator),
        _ => return Err(format!("SEE-ROBUSTNESS: unknown campaign {campaign}")),
    };
    if PANICS.load(Ordering::SeqCst) > before {
        return Ok(Outcome::Finding(finding("panic", case, &source.program)));
    }
    Ok(outcome)
}

pub fn finding(kind: &str, case: u64, text: &str) -> Value {
    json!({"kind":kind,"case":case,"input":text.chars().take(4096).collect::<String>()})
}

fn source_case(source: &Source, generator: &mut Generator) -> Outcome {
    let mutated = mutate_text(&source.program, generator);
    let analysis = pseudolearn_api::execute_analyze(&AnalyzeRequest {
        program: mutated.clone(),
        profile: source.profile.clone(),
        strictness: "strict".to_owned(),
    });
    let analysis_fault = analysis
        .diagnostics
        .iter()
        .any(|diagnostic| diagnostic.code == INTERNAL_FAULT);
    let mut request = ExecuteRequest {
        program: mutated.clone(),
        profile: source.profile.clone(),
        ..ExecuteRequest::default()
    };
    request.limits.statements = Some(STATEMENT_BUDGET);
    request.observe = "events".to_owned();
    let response = pseudolearn_api::execute_program(&request);
    let execution_fault = response
        .diagnostics
        .iter()
        .any(|diagnostic| diagnostic.code == INTERNAL_FAULT);
    if analysis_fault || execution_fault {
        return Outcome::Finding(finding("internal_fault", 0, &mutated));
    }
    Outcome::Clean
}

fn ir_case(source: &Source, generator: &mut Generator) -> Outcome {
    let Ok(canonical) =
        pseudolearn_api::compile_source_to_ir(&source.program, &source.profile, "strict")
    else {
        return Outcome::NotApplicable;
    };
    let mutated = mutate_text(&canonical, generator);
    let response = pseudolearn_api::execute_ir(&IrRequest {
        program_ir: mutated.clone(),
        program: String::new(),
        profile: source.profile.clone(),
        strictness: "strict".to_owned(),
    });
    if response.ir.accepted {
        Outcome::Clean
    } else if response.ir.violated_rule.is_some() {
        Outcome::Rejected
    } else {
        Outcome::Finding(finding("rejection_without_rule", 0, &mutated))
    }
}
