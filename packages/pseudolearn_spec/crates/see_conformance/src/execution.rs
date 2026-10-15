use crate::protocol::Session;
use crate::requests::{self, Selection};
use see_model::{
    Block, Corpus, Specification,
    contract::Vocabulary,
    evidence::{Evidence, Observation},
    field, strings,
};
use serde_json::Value;

pub fn execute(
    corpus: &Corpus,
    vocabulary: &Vocabulary,
    session: &mut Session,
    operation_filter: Option<&str>,
) -> Result<Evidence, String> {
    let mut observations = Vec::new();
    for specification in corpus {
        for case in specification
            .blocks
            .iter()
            .filter(|block| block.kind == "caso")
        {
            if let Some(target) = operation_filter
                && requests::operation(case) != target
            {
                continue;
            }
            observations.extend(execute_case(specification, case, vocabulary, session)?);
        }
    }
    let identity = |name: &str| {
        session
            .hello
            .get(name)
            .and_then(Value::as_str)
            .map(str::to_owned)
            .ok_or(format!("Missing {name}"))
    };
    let subject = identity("subject")?;
    let subject_version = identity("subject_version")?;
    Ok(Evidence {
        protocol: "see-protocol/1".to_owned(),
        subject,
        subject_version,
        corpus_hashes: Default::default(),
        observations,
        stderr: session.finish()?,
    })
}

fn execute_case(
    specification: &Specification,
    case: &Block,
    vocabulary: &Vocabulary,
    session: &mut Session,
) -> Result<Vec<Observation>, String> {
    let mut observations = Vec::new();
    for profile in strings(case.fields.get("perfiles")) {
        for strictness in strings(case.fields.get("rigor")) {
            observations.push(observe(
                specification,
                case,
                (profile, strictness),
                &mut Context {
                    vocabulary,
                    session,
                },
            )?);
        }
    }
    Ok(observations)
}

pub enum Support {
    Available,
    Pending,
    Unavailable,
}

pub fn support(session: &Session, case: &Block, request: &Value) -> Support {
    let announced = |capability: &str, value: Option<&Value>| {
        session
            .hello
            .get(capability)
            .and_then(Value::as_array)
            .is_some_and(|values| value.is_some_and(|value| values.contains(value)))
    };
    let profile = announced("profiles", request.get("profile"))
        && announced("strictness", request.get("strictness"));
    let capabilities = requests::required_capabilities(case);
    let missing: Vec<_> = capabilities
        .iter()
        .filter(|capability| !announced("capabilities", Some(&Value::from(**capability))))
        .collect();
    match (profile, missing.as_slice()) {
        (true, []) => Support::Available,
        (true, [only]) if **only == "observe" => Support::Pending,
        _ => Support::Unavailable,
    }
}

struct Context<'session> {
    vocabulary: &'session Vocabulary,
    session: &'session mut Session,
}

fn observe(
    specification: &Specification,
    case: &Block,
    parameters: (&str, &str),
    context: &mut Context<'_>,
) -> Result<Observation, String> {
    let (profile, strictness) = parameters;
    let expected = case
        .fields
        .get("esperas")
        .and_then(|profiles| profiles.get(profile))
        .or_else(|| case.fields.get("espera"))
        .ok_or("Missing expected observation")?
        .clone();
    let expected = resolved_expected(expected, profile, context.vocabulary)?;
    let selection = Selection {
        profile,
        strictness,
        expected: &expected,
    };
    let request = requests::build(case, &selection, context.vocabulary)?;
    let (verdict, differences, actual) = match support(context.session, case, &request) {
        Support::Available => measured(context.session, &request, &expected)?,
        Support::Pending => pending("Observation capability unavailable"),
        Support::Unavailable => unavailable(),
    };
    Ok(Observation {
        specification: specification.metadata.id.clone(),
        rule: field(case, "regla").to_owned(),
        case: field(case, "id").to_owned(),
        profile: profile.to_owned(),
        strictness: strictness.to_owned(),
        verdict: verdict.to_owned(),
        differences,
        expected,
        actual,
    })
}

type Outcome = (&'static str, Vec<String>, Value);

fn measured(session: &mut Session, request: &Value, expected: &Value) -> Result<Outcome, String> {
    let actual = session.request(request)?;
    let observing = request.get("observe").and_then(Value::as_str) == Some("events");
    let emitted = actual
        .get("events")
        .and_then(Value::as_array)
        .is_some_and(|events| !events.is_empty());
    if emitted && !observing {
        return Err("SEE-PROTOCOL: events without observe capability".to_owned());
    }
    let differences = crate::comparison::compare(expected, &actual);
    let verdict = if differences.is_empty() {
        "cumple"
    } else {
        "incumple"
    };
    Ok((verdict, differences, actual))
}

fn pending(reason: &str) -> Outcome {
    ("pendiente", vec![reason.to_owned()], Value::Null)
}

fn unavailable() -> Outcome {
    (
        "no aplicable",
        vec!["Capability, profile or strictness unavailable".to_owned()],
        Value::Null,
    )
}

fn resolved_expected(
    mut expected: Value,
    profile: &str,
    vocabulary: &Vocabulary,
) -> Result<Value, String> {
    if let Some(output) = expected.get_mut("salida") {
        let text = output.as_str().ok_or("Invalid output expectation")?;
        *output = Value::String(see_translation::lexemes::resolve(
            text, profile, vocabulary,
        )?);
    }
    for event in expected
        .get_mut("eventos")
        .and_then(Value::as_array_mut)
        .into_iter()
        .flatten()
    {
        if let Some(text) = event.pointer_mut("/datos/texto") {
            let resolved = see_translation::lexemes::resolve(
                text.as_str().unwrap_or(""),
                profile,
                vocabulary,
            )?;
            *text = Value::String(resolved);
        }
    }
    Ok(expected)
}
