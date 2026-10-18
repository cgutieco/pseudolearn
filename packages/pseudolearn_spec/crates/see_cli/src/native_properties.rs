use crate::{arguments::Arguments, storage};
use see_conformance::protocol::Session;
use see_model::{
    Corpus,
    contract::Vocabulary,
    properties::{Counterexample, PropertyBinding, PropertyExecutor, PropertyRun},
};
use serde_json::{Value, json};
use std::time::Duration;

pub fn run(
    binding: &PropertyBinding,
    arguments: &Arguments,
    corpus: &Corpus,
    native: &mut Session,
) -> Result<PropertyRun, String> {
    let vocabulary: Vocabulary =
        storage::read_json(&arguments.root.join("specifications/cases/vocabulary.json"))?;
    let cases = see_conformance::runtime_fixtures::cases(corpus, &vocabulary)?;
    let (mut command, _) =
        crate::subject_adapters::subject_configuration(arguments, corpus, "engine")?;
    let mut oracle = Session::start(&mut command, Duration::from_secs(30))?;
    let first = crate::property_selection::number(arguments, "sample")?.unwrap_or(0);
    let requests = requests(binding, &cases, (&vocabulary, first))?;
    let report = run_requests(binding, arguments, native, (&mut oracle, &requests))?;
    let _stderr = oracle.finish()?;
    Ok(report)
}

fn run_requests(
    binding: &PropertyBinding,
    arguments: &Arguments,
    native: &mut Session,
    input: (&mut Session, &[Value]),
) -> Result<PropertyRun, String> {
    let (oracle, requests) = input;
    let mut report = initial_report(binding)?;
    for (index, request) in requests.iter().enumerate() {
        let expected = oracle.request(request)?;
        let actual_request = native_request(binding, request)?;
        let actual = if crate::native_artifacts::supports(binding.executor) {
            crate::native_artifacts::check(binding, arguments, request, &expected)?
        } else {
            native.request(&actual_request)?
        };
        let (expected, actual) = if crate::native_artifacts::supports(binding.executor) {
            (json!({"passed":true}), actual)
        } else {
            (contract(&expected), contract(&actual))
        };
        if expected != actual {
            report.verdict = "incumple".to_owned();
            report.counterexample = Some(counterexample(
                binding,
                request,
                sample_number(arguments, index)?,
                (expected, actual),
            )?);
            break;
        }
        report.completed = report.completed.saturating_add(1);
    }
    Ok(report)
}

fn requests(
    binding: &PropertyBinding,
    cases: &[Value],
    selection: (&Vocabulary, u32),
) -> Result<Vec<Value>, String> {
    let (vocabulary, first) = selection;
    let end = first
        .checked_add(binding.samples)
        .ok_or("Sample range overflow")?;
    let selected = selected_cases(binding, cases);
    if selected.is_empty() {
        return Err("No native property scenarios".to_owned());
    }
    if binding.executor == PropertyExecutor::NativeRoots {
        return see_conformance::memory_fixtures::generate(binding.seed,end,vocabulary)?.iter().skip(usize::try_from(first).map_err(|error| error.to_string())?).map(|fixture| {
            Ok(json!({"kind":"execute","program":fixture["program"],"profile":"es","strictness":"strict",
                "seed":binding.seed,"inputs":[],"gc_stress":false}))
        }).collect();
    }
    (first..end)
        .map(|sample| {
            let index = usize::try_from(
                binding
                    .seed
                    .wrapping_add(u64::from(sample).wrapping_mul(37)),
            )
            .map_err(|error| error.to_string())?
            .checked_rem(selected.len())
            .ok_or("No native cases")?;
            selected
                .get(index)
                .and_then(|fixture| fixture.get("request"))
                .cloned()
                .ok_or("Missing native request".to_owned())
        })
        .collect()
}

pub(crate) fn contract(response: &Value) -> Value {
    let errors: Vec<Value> = response.get("diagnostics").and_then(Value::as_array).into_iter().flatten()
        .filter(|diagnostic| diagnostic["severity"] == "error")
        .map(|diagnostic| json!({"code":diagnostic["code"],"arguments":diagnostic["arguments"],"span":diagnostic["span"]})).collect();
    json!({"output":response["output"],"termination":response["termination"],"errors":errors})
}

fn counterexample(
    binding: &PropertyBinding,
    request: &Value,
    sample: usize,
    values: (Value, Value),
) -> Result<Counterexample, String> {
    Ok(Counterexample {
        sample: u32::try_from(sample).map_err(|error| error.to_string())?,
        program: request["program"].as_str().unwrap_or("").to_owned(),
        profile: request["profile"].as_str().unwrap_or("").to_owned(),
        strictness: request["strictness"].as_str().unwrap_or("").to_owned(),
        expected: values.0,
        actual: values.1,
        reproduction: vec![
            "see".to_owned(),
            "conform".to_owned(),
            "--subject".to_owned(),
            "aot".to_owned(),
            "--operation".to_owned(),
            "properties".to_owned(),
            "--property".to_owned(),
            binding.reference.clone(),
            "--seed".to_owned(),
            binding.seed.to_string(),
            "--samples".to_owned(),
            "1".to_owned(),
            "--sample".to_owned(),
            sample.to_string(),
            "--output".to_owned(),
            "results/native-reproduction.json".to_owned(),
        ],
    })
}

fn eligible(binding: &PropertyBinding, fixture: &Value) -> bool {
    let specification = fixture["specification"].as_str().unwrap_or("");
    let termination = fixture
        .pointer("/expected/terminacion")
        .and_then(Value::as_str);
    if crate::native_artifacts::supports(binding.executor) {
        return specification == "RT.PROCESS";
    }
    if binding.executor == PropertyExecutor::NativeDiagnostics {
        return termination == Some("failed");
    }
    specification.starts_with("LANG.")
        || specification.starts_with("MEM.")
        || specification.starts_with("RT.")
}

fn initial_report(binding: &PropertyBinding) -> Result<PropertyRun, String> {
    let (specification, property) = binding
        .reference
        .split_once('#')
        .ok_or("Invalid native property")?;
    Ok(PropertyRun {
        specification: specification.to_owned(),
        property: property.to_owned(),
        seed: binding.seed,
        samples: binding.samples,
        completed: 0,
        verdict: "cumple".to_owned(),
        counterexample: None,
    })
}

pub(crate) fn supports(executor: PropertyExecutor) -> bool {
    [
        PropertyExecutor::NativeEquivalence,
        PropertyExecutor::NativeRoots,
        PropertyExecutor::NativeDiagnostics,
    ]
    .contains(&executor)
        || crate::native_artifacts::supports(executor)
}

fn sample_number(arguments: &Arguments, offset: usize) -> Result<usize, String> {
    let first: u32 = crate::property_selection::number(arguments, "sample")?.unwrap_or(0);
    usize::try_from(first)
        .map_err(|error| error.to_string())?
        .checked_add(offset)
        .ok_or("Sample range overflow".to_owned())
}

fn selected_cases<'cases>(binding: &PropertyBinding, cases: &'cases [Value]) -> Vec<&'cases Value> {
    cases
        .iter()
        .filter(|fixture| eligible(binding, fixture))
        .filter(|fixture| fixture.pointer("/request/observe") != Some(&json!("events")))
        .collect()
}

fn native_request(binding: &PropertyBinding, request: &Value) -> Result<Value, String> {
    let mut actual = request.clone();
    if binding.executor == PropertyExecutor::NativeRoots {
        actual
            .as_object_mut()
            .ok_or("Invalid native request")?
            .insert("gc_stress".to_owned(), json!(true));
    }
    Ok(actual)
}
