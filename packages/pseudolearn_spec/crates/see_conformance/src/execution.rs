use crate::protocol::Session;
use see_model::{
    Block, Corpus, Specification,
    contract::Vocabulary,
    evidence::{Evidence, Observation},
    field, strings,
};
use serde_json::{Value, json};

pub fn execute(
    corpus: &Corpus,
    vocabulary: &Vocabulary,
    session: &mut Session,
) -> Result<Evidence, String> {
    let mut observations = Vec::new();
    for specification in corpus {
        for case in specification
            .blocks
            .iter()
            .filter(|block| block.kind == "caso")
        {
            observations.extend(execute_case(specification, case, vocabulary, session)?);
        }
    }
    let subject = session
        .hello
        .get("subject")
        .and_then(Value::as_str)
        .ok_or("Missing subject")?
        .to_owned();
    let subject_version = session
        .hello
        .get("subject_version")
        .and_then(Value::as_str)
        .ok_or("Missing subject version")?
        .to_owned();
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

fn request(
    case: &Block,
    profile: &str,
    strictness: &str,
    vocabulary: &Vocabulary,
) -> Result<Value, String> {
    let explicit = case
        .fields
        .get("programas")
        .and_then(|programs| programs.get(profile))
        .and_then(Value::as_str);
    let base = field(case, "perfil_base");
    let base = if base.is_empty() { "es" } else { base };
    let program = match explicit {
        Some(program) => program.to_owned(),
        None => see_translation::translate(field(case, "programa"), base, profile, vocabulary)?,
    };
    let operation = field(case, "operacion");
    let operation = if operation.is_empty() {
        "execute"
    } else {
        operation
    };
    let strictness = match strictness {
        "estricto" => "strict",
        _ => "flexible",
    };
    Ok(
        json!({"kind":operation, "program":program, "profile":profile, "strictness":strictness, "inputs":case.fields.get("entradas").cloned().unwrap_or(json!([])), "seed":case.fields.get("semilla").cloned().unwrap_or(json!(42)), "observe":"none", "limits":{"micro_steps":100_000}}),
    )
}

fn supported(session: &Session, request: &Value) -> bool {
    [
        ("capabilities", "kind"),
        ("profiles", "profile"),
        ("strictness", "strictness"),
    ]
    .iter()
    .all(|(capability, requested)| {
        session
            .hello
            .get(capability)
            .and_then(Value::as_array)
            .is_some_and(|values| {
                request
                    .get(requested)
                    .is_some_and(|value| values.contains(value))
            })
    })
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
    let request = request(case, profile, strictness, context.vocabulary)?;
    let expected = case
        .fields
        .get("esperas")
        .and_then(|profiles| profiles.get(profile))
        .or_else(|| case.fields.get("espera"))
        .ok_or("Missing expected observation")?
        .clone();
    let expected = resolved_expected(expected, profile, context.vocabulary)?;
    let supported = supported(context.session, &request);
    let actual = if supported {
        context.session.request(&request)?
    } else {
        Value::Null
    };
    let differences = if supported {
        crate::comparison::compare(&expected, &actual)
    } else {
        vec!["Capability, profile or strictness unavailable".to_owned()]
    };
    let verdict = verdict(supported, &differences);
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

fn verdict(supported: bool, differences: &[String]) -> &'static str {
    if !supported {
        "no aplicable"
    } else if differences.is_empty() {
        "cumple"
    } else {
        "incumple"
    }
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
    Ok(expected)
}
