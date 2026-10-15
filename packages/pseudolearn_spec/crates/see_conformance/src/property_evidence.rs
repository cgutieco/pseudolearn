use crate::properties::PropertyContext;
use crate::property_scenarios::Scenario;
use see_model::properties::{Counterexample, PropertyBinding, PropertyRun};
use serde_json::Value;

pub(crate) fn pending(binding: &PropertyBinding) -> Result<PropertyRun, String> {
    if binding.samples == 0 {
        return Err("SEE-PROPERTY: zero samples".to_owned());
    }
    let (specification, property) = binding
        .reference
        .split_once('#')
        .ok_or("SEE-PROPERTY: invalid reference")?;
    let report = PropertyRun {
        specification: specification.to_owned(),
        property: property.to_owned(),
        seed: binding.seed,
        samples: binding.samples,
        completed: 0,
        verdict: "pendiente".to_owned(),
        counterexample: None,
    };
    Ok(report)
}

pub(crate) fn counterexample(
    binding: &PropertyBinding,
    context: &PropertyContext<'_>,
    case: (u32, &Scenario),
    observation: (Value, Value),
) -> Counterexample {
    let (sample, scenario) = case;
    Counterexample {
        sample,
        profile: scenario
            .request
            .get("profile")
            .and_then(Value::as_str)
            .unwrap_or("")
            .to_owned(),
        strictness: scenario
            .request
            .get("strictness")
            .and_then(Value::as_str)
            .unwrap_or("")
            .to_owned(),
        program: scenario
            .request
            .get("program")
            .and_then(Value::as_str)
            .unwrap_or("")
            .to_owned(),
        expected: observation.0,
        actual: observation.1,
        reproduction: reproduction(binding, context.subject, sample),
    }
}

fn reproduction(binding: &PropertyBinding, subject: &str, sample: u32) -> Vec<String> {
    vec![
        "see".to_owned(),
        "conform".to_owned(),
        "--subject".to_owned(),
        subject.to_owned(),
        "--operation".to_owned(),
        "properties".to_owned(),
        "--property".to_owned(),
        binding.reference.clone(),
        "--seed".to_owned(),
        binding.seed.to_string(),
        "--sample".to_owned(),
        sample.to_string(),
        "--samples".to_owned(),
        "1".to_owned(),
    ]
}
