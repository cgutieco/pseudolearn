mod support;
use see_conformance::properties::{PropertyContext, PropertySubject, run};
use see_model::properties::{PropertyBinding, PropertyExecutor};
use serde_json::{Value, json};

struct Responder<Answer: FnMut(&Value) -> Value> {
    hello: Value,
    answer: Answer,
}

impl<Answer: FnMut(&Value) -> Value> PropertySubject for Responder<Answer> {
    fn declaration(&self) -> &Value {
        &self.hello
    }
    fn exchange(&mut self, request: &Value) -> Result<Value, String> {
        Ok((self.answer)(request))
    }
}

fn verdict(
    executor: PropertyExecutor,
    answer: impl FnMut(&Value) -> Value,
) -> Result<String, String> {
    let corpus = vec![support::specification()?];
    let vocabulary = Default::default();
    let context = PropertyContext {
        corpus: &corpus,
        vocabulary: &vocabulary,
        subject: "engine",
        first_sample: 0,
        exhaustive: false,
    };
    let binding = PropertyBinding {
        reference: "TEST.MODEL@0.1.0#P1".to_owned(),
        executor,
        seed: 42,
        samples: 1,
    };
    let mut subject = Responder {
        hello: json!({"capabilities":["execute","observe","gc_stress","api"]}),
        answer,
    };
    Ok(run(&binding, &context, &mut subject)?.verdict)
}

fn program(request: &Value) -> Value {
    request.get("program").cloned().unwrap_or(Value::Null)
}

fn text(request: &Value, name: &str) -> String {
    request
        .get(name)
        .and_then(Value::as_str)
        .unwrap_or_default()
        .to_owned()
}

#[test]
fn lossless_reprint_passes_when_the_text_is_reproduced_exactly() -> Result<(), String> {
    let echo = |request: &Value| json!({"reprint":program(request)});
    assert_eq!(verdict(PropertyExecutor::LosslessReprint, echo)?, "cumple");
    assert_eq!(
        verdict(PropertyExecutor::LosslessRecovery, |request: &Value| {
            if request.get("kind") == Some(&json!("analyze")) {
                return json!({"tree":true});
            }
            json!({"reprint":program(request)})
        })?,
        "cumple"
    );
    Ok(())
}

#[test]
fn lossless_reprint_fails_when_one_character_is_lost() -> Result<(), String> {
    let lossy = |request: &Value| {
        let mut reprinted = text(request, "program");
        reprinted.pop();
        json!({"reprint":reprinted})
    };
    assert_eq!(
        verdict(PropertyExecutor::LosslessReprint, lossy)?,
        "incumple"
    );
    Ok(())
}

#[test]
fn lossless_recovery_fails_when_no_tree_is_returned() -> Result<(), String> {
    let treeless = |request: &Value| {
        if request.get("kind") == Some(&json!("analyze")) {
            return json!({"tree":false});
        }
        json!({"reprint":program(request)})
    };
    assert_eq!(
        verdict(PropertyExecutor::LosslessRecovery, treeless)?,
        "incumple"
    );
    Ok(())
}

#[test]
fn lowering_validity_requires_accepted_or_justified_rejection() -> Result<(), String> {
    let accepted = |_: &Value| json!({"ir":{"accepted":true,"reprint":"module"}});
    assert_eq!(
        verdict(PropertyExecutor::LoweringValidity, accepted)?,
        "cumple"
    );
    let rejected_valid = |request: &Value| {
        if request.get("kind") == Some(&json!("analyze")) {
            return json!({"diagnostics":[]});
        }
        json!({"ir":{"accepted":false}})
    };
    assert_eq!(
        verdict(PropertyExecutor::LoweringValidity, rejected_valid)?,
        "incumple"
    );
    let rejected_invalid = |request: &Value| {
        if request.get("kind") == Some(&json!("analyze")) {
            return json!({"diagnostics":[{"severity":"error"}]});
        }
        json!({"ir":{"accepted":false}})
    };
    assert_eq!(
        verdict(PropertyExecutor::LoweringValidity, rejected_invalid)?,
        "cumple"
    );
    Ok(())
}

#[test]
fn lowering_validity_fails_when_the_printed_ir_is_not_reloadable() -> Result<(), String> {
    let unreloadable = |request: &Value| {
        if request.get("program_ir").is_some() {
            return json!({"ir":{"accepted":false}});
        }
        json!({"ir":{"accepted":true,"reprint":"module"}})
    };
    assert_eq!(
        verdict(PropertyExecutor::LoweringValidity, unreloadable)?,
        "incumple"
    );
    Ok(())
}

#[test]
fn statement_mass_requires_aligned_counts_and_skips_uncompilable_programs() -> Result<(), String> {
    let aligned = |_: &Value| json!({"compiled":true,"statements":3,"enters":3,"exits":3,"mass":3});
    assert_eq!(verdict(PropertyExecutor::StatementMass, aligned)?, "cumple");
    let skewed = |_: &Value| json!({"compiled":true,"statements":3,"enters":3,"exits":2,"mass":3});
    assert_eq!(
        verdict(PropertyExecutor::StatementMass, skewed)?,
        "incumple"
    );
    let uncompiled = |_: &Value| json!({"compiled":false});
    assert_eq!(
        verdict(PropertyExecutor::StatementMass, uncompiled)?,
        "cumple"
    );
    Ok(())
}

fn unit(line: u64, column: u64, name: &str) -> Value {
    json!({"kind":"algorithm","name":name,"span":{"start":{"line":line,"column":column}}})
}

#[test]
fn analysis_schema_requires_ordered_units_named_in_the_text() -> Result<(), String> {
    let empty = |_: &Value| json!({"schema":[]});
    assert_eq!(verdict(PropertyExecutor::AnalysisSchema, empty)?, "cumple");
    let duplicated = |_: &Value| json!({"schema":[unit(1, 1, "P"), unit(1, 1, "P")]});
    assert_eq!(
        verdict(PropertyExecutor::AnalysisSchema, duplicated)?,
        "incumple"
    );
    let unnamed = |_: &Value| json!({"schema":[unit(1, 1, "nombre_que_no_aparece_en_el_texto")]});
    assert_eq!(
        verdict(PropertyExecutor::AnalysisSchema, unnamed)?,
        "incumple"
    );
    Ok(())
}

#[test]
fn first_trap_fails_when_the_subject_reports_a_wrong_outcome() -> Result<(), String> {
    let wrong = |_: &Value| json!({"output":"WRONG\n","termination":{"kind":"completed"}});
    assert_eq!(verdict(PropertyExecutor::FirstTrap, wrong)?, "incumple");
    assert_eq!(
        verdict(PropertyExecutor::FusedFirstTrap, wrong)?,
        "incumple"
    );
    Ok(())
}
