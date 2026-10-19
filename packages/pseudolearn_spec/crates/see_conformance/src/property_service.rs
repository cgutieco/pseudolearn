use crate::{properties::PropertySubject, property_scenarios::Scenario};
use see_model::properties::PropertyExecutor;
use serde_json::{Value, json};

type Difference = Result<Option<(Value, Value)>, String>;

const TEMPLATE_CONSTRUCTIONS: [&str; 9] = [
    "algorithm",
    "subroutine",
    "function",
    "class",
    "if",
    "while",
    "for",
    "repeat",
    "switch",
];

struct Program<'text> {
    text: &'text str,
    profile: &'text str,
    strictness: &'text str,
}

pub(crate) fn check(
    executor: PropertyExecutor,
    scenario: &Scenario,
    subject: &mut impl PropertySubject,
) -> Difference {
    let text = text_of(&scenario.request, "program");
    let profile = text_of(&scenario.request, "profile");
    let strictness = text_of(&scenario.request, "strictness");
    let program = Program {
        text: &text,
        profile: &profile,
        strictness: &strictness,
    };
    match executor {
        PropertyExecutor::ServiceFormat => format_stability(&program, subject),
        PropertyExecutor::ServiceTranslate => translation_identity(&program, subject),
        PropertyExecutor::ServiceIncremental => random_probe(&program, "incremental_frio", subject),
        PropertyExecutor::ServiceNodeIdentity => random_probe(&program, "identidad_local", subject),
        PropertyExecutor::ServiceCompletionTemplates => template_validity(&program, subject),
        _ => Err("SEE-PROPERTY: invalid service executor".to_owned()),
    }
}

fn text_of(request: &Value, name: &str) -> String {
    request
        .get(name)
        .and_then(Value::as_str)
        .unwrap_or_default()
        .to_owned()
}

fn service_request(program: &Program<'_>, operation: &str, document: &str) -> Value {
    service_request_with(program, operation, document, json!({}))
}

fn service_request_with(
    program: &Program<'_>,
    operation: &str,
    document: &str,
    extra: Value,
) -> Value {
    let mut request = json!({
        "kind": "service",
        "suboperacion": operation,
        "documento": document,
        "profile": program.profile,
        "strictness": program.strictness,
    });
    if let (Some(fields), Some(additions)) = (request.as_object_mut(), extra.as_object()) {
        fields.extend(additions.clone());
    }
    request
}

fn service_outcome(subject: &mut impl PropertySubject, request: &Value) -> Result<Value, String> {
    let response = subject.exchange(request)?;
    Ok(response.get("service").cloned().unwrap_or(response))
}

fn diagnostic_signature(
    subject: &mut impl PropertySubject,
    program: &Program<'_>,
    text: &str,
    profile: &str,
) -> Result<Value, String> {
    let response = subject.exchange(&json!({
        "kind": "analyze", "program": text, "profile": profile, "strictness": program.strictness
    }))?;
    let codes: Vec<Value> = response
        .get("diagnostics")
        .and_then(Value::as_array)
        .map(|items| {
            items
                .iter()
                .map(|entry| json!([entry.get("code"), entry.get("severity")]))
                .collect()
        })
        .unwrap_or_default();
    Ok(Value::Array(codes))
}

fn formatted(
    subject: &mut impl PropertySubject,
    program: &Program<'_>,
    text: &str,
) -> Result<String, String> {
    let outcome = service_outcome(subject, &service_request(program, "format", text))?;
    outcome
        .get("formateado")
        .and_then(Value::as_str)
        .map(str::to_owned)
        .ok_or_else(|| "SEE-PROPERTY: missing formatted text".to_owned())
}

fn format_stability(program: &Program<'_>, subject: &mut impl PropertySubject) -> Difference {
    let first = formatted(subject, program, program.text)?;
    let second = formatted(subject, program, &first)?;
    if first != second {
        return Ok(Some((json!(first), json!(second))));
    }
    let before = diagnostic_signature(subject, program, program.text, program.profile)?;
    let after = diagnostic_signature(subject, program, &first, program.profile)?;
    Ok((before != after).then_some((before, after)))
}

fn translation_identity(program: &Program<'_>, subject: &mut impl PropertySubject) -> Difference {
    let canonical = formatted(subject, program, program.text)?;
    let destination = if program.profile == "en" { "es" } else { "en" };
    let request = service_request_with(
        program,
        "translate_roundtrip",
        &canonical,
        json!({ "hacia": destination }),
    );
    let outcome = service_outcome(subject, &request)?;
    let (Some(translated), Some(back)) = (
        outcome.get("traducido").and_then(Value::as_str),
        outcome.get("vuelta").and_then(Value::as_str),
    ) else {
        return Ok(None);
    };
    if back != canonical {
        return Ok(Some((json!(canonical), json!(back))));
    }
    let before = diagnostic_signature(subject, program, &canonical, program.profile)?;
    let after = diagnostic_signature(subject, program, translated, destination)?;
    Ok((before != after).then_some((before, after)))
}

fn random_probe(
    program: &Program<'_>,
    probe: &str,
    subject: &mut impl PropertySubject,
) -> Difference {
    let request = service_request_with(
        program,
        "random_probe",
        program.text,
        json!({ "comprobacion": probe, "semilla": fingerprint(program.text) }),
    );
    let outcome = service_outcome(subject, &request)?;
    if outcome.get("aplicable") == Some(&json!(false)) {
        return Ok(None);
    }
    let key = if probe == "identidad_local" {
        "conservados"
    } else {
        "coincide_con_frio"
    };
    Ok((outcome.get(key) != Some(&json!(true))).then(|| (json!({ key: true }), outcome)))
}

fn template_validity(program: &Program<'_>, subject: &mut impl PropertySubject) -> Difference {
    for profile in ["es", "en"] {
        for construction in TEMPLATE_CONSTRUCTIONS {
            let request = json!({
                "kind": "service", "suboperacion": "template_validity",
                "construccion": construction, "profile": profile,
                "strictness": program.strictness,
            });
            let outcome = service_outcome(subject, &request)?;
            if outcome.get("valida") != Some(&json!(true)) {
                return Ok(Some((
                    json!({"valida": true, "construccion": construction}),
                    outcome,
                )));
            }
        }
    }
    Ok(None)
}

fn fingerprint(text: &str) -> u64 {
    text.bytes().fold(0xcbf2_9ce4_8422_2325, |hash, byte| {
        (hash ^ u64::from(byte)).wrapping_mul(0x0100_0000_01b3)
    })
}
