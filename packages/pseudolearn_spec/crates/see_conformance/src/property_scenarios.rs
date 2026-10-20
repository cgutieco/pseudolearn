use crate::requests::{self, Selection};
use see_generators::program::{GenerationSeed, generate};
use see_model::{Corpus, contract::Vocabulary, strings};
use serde_json::{Value, json};

#[derive(Clone, Debug)]
pub(crate) struct Scenario {
    pub request: Value,
    pub expected: Option<Value>,
    pub traced: bool,
}

pub(crate) fn executions(
    corpus: &Corpus,
    vocabulary: &Vocabulary,
) -> Result<Vec<Scenario>, String> {
    let mut scenarios = Vec::new();
    for specification in corpus {
        for case in &specification.blocks {
            if case.kind == "caso" && matches!(requests::operation(case), "execute" | "trace") {
                append_case(case, vocabulary, &mut scenarios)?;
                mark_traced(case, &mut scenarios);
            }
        }
    }
    Ok(scenarios)
}

fn append_case(
    case: &see_model::Block,
    vocabulary: &Vocabulary,
    scenarios: &mut Vec<Scenario>,
) -> Result<(), String> {
    for profile in strings(case.fields.get("perfiles")) {
        for strictness in strings(case.fields.get("rigor")) {
            let expected = case
                .fields
                .get("esperas")
                .and_then(|values| values.get(profile))
                .or_else(|| case.fields.get("espera"))
                .ok_or("Missing property expectation")?
                .clone();
            let expected = crate::execution::resolved_expected(expected, profile, vocabulary)?;
            let selection = Selection {
                profile,
                strictness,
                expected: &expected,
            };
            scenarios.push(Scenario {
                request: requests::build(case, &selection, vocabulary)?,
                expected: Some(expected),
                traced: false,
            });
        }
    }
    Ok(())
}

fn mark_traced(case: &see_model::Block, scenarios: &mut [Scenario]) {
    if requests::operation(case) != "trace" {
        return;
    }
    let appended = strings(case.fields.get("perfiles"))
        .len()
        .saturating_mul(strings(case.fields.get("rigor")).len());
    let start = scenarios.len().saturating_sub(appended);
    for scenario in scenarios.iter_mut().skip(start) {
        scenario.traced = true;
    }
}

pub(crate) fn runnable_by(scenario: &Scenario, declaration: &Value) -> bool {
    let needs_observation = ["cancel_at_statement", "cancel_at_poll", "state_at"]
        .iter()
        .any(|name| scenario.request.get(name).is_some())
        || scenario.request.get("observe") == Some(&json!("events"));
    !needs_observation
        || declaration
            .get("capabilities")
            .and_then(Value::as_array)
            .is_some_and(|values| values.contains(&json!("observe")))
}

pub(crate) fn generated(
    seed: GenerationSeed,
    profile: &str,
    strictness: &str,
    vocabulary: &Vocabulary,
) -> Result<Scenario, String> {
    let program = generate(seed, profile, vocabulary)?;
    Ok(Scenario {
        request: json!({
            "kind":"execute", "program":program.source, "profile":profile,
            "strictness":strictness, "inputs":[program.input], "seed":seed.seed,
            "observe":"events", "limits":{"micro_steps":100_000},
        }),
        expected: Some(generated_expectation(&program)?),
        traced: true,
    })
}

pub(crate) fn generated_expectation(
    program: &see_generators::program::GeneratedProgram,
) -> Result<Value, String> {
    let count = i128::from(program.elements);
    let first = i128::from(program.initial)
        .checked_mul(count)
        .ok_or("SEE-PROPERTY: oracle overflow")?;
    let predecessor = count
        .checked_sub(1)
        .ok_or("SEE-PROPERTY: oracle overflow")?;
    let progression = count
        .checked_mul(predecessor)
        .and_then(|value| value.checked_div(2))
        .ok_or("SEE-PROPERTY: oracle overflow")?;
    let total = first
        .checked_add(progression)
        .and_then(|value| value.checked_add(1))
        .ok_or("SEE-PROPERTY: oracle overflow")?;
    Ok(json!({"salida": format!("sample!:{total}:{}\n", program.input), "terminacion":"completed"}))
}

pub(crate) fn compilations(
    corpus: &Corpus,
    vocabulary: &Vocabulary,
) -> Result<Vec<Scenario>, String> {
    let mut scenarios = Vec::new();
    for specification in corpus {
        for case in &specification.blocks {
            if case.kind == "caso"
                && matches!(requests::operation(case), "analyze" | "execute" | "trace")
            {
                append_case(case, vocabulary, &mut scenarios)?;
            }
        }
    }
    Ok(scenarios)
}
