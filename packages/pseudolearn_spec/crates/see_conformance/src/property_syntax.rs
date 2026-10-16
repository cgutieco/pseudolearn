use crate::{properties::PropertySubject, property_scenarios::Scenario};
use see_model::properties::PropertyExecutor;
use serde_json::{Value, json};

struct Source<'text> {
    program: &'text str,
    profile: &'text str,
    strictness: &'text str,
}

type Difference = Result<Option<(Value, Value)>, String>;

pub(crate) fn check(
    executor: PropertyExecutor,
    scenario: &Scenario,
    subject: &mut impl PropertySubject,
) -> Difference {
    let program = text(&scenario.request, "program");
    let profile = text(&scenario.request, "profile");
    let strictness = text(&scenario.request, "strictness");
    let source = Source {
        program: &program,
        profile: &profile,
        strictness: &strictness,
    };
    match executor {
        PropertyExecutor::LosslessReprint => reprint_variants(&program, &profile, subject),
        PropertyExecutor::LosslessRecovery => recovery_texts(&program, &profile, subject),
        PropertyExecutor::LoweringValidity => lowering_validity(&source, subject),
        PropertyExecutor::StatementMass => statement_mass(&source, subject),
        PropertyExecutor::AnalysisSchema => analysis_schema(&source, subject),
        _ => Err("SEE-PROPERTY: invalid syntax executor".to_owned()),
    }
}

fn text(request: &Value, name: &str) -> String {
    request
        .get(name)
        .and_then(Value::as_str)
        .unwrap_or_default()
        .to_owned()
}

fn reprint_variants(
    program: &str,
    profile: &str,
    subject: &mut impl PropertySubject,
) -> Difference {
    for variant in variants(program) {
        if let Some(difference) = reprint_difference(&variant, profile, subject)? {
            return Ok(Some(difference));
        }
    }
    Ok(None)
}

fn variants(program: &str) -> Vec<String> {
    let without_bom = program.trim_start_matches('\u{FEFF}');
    let carriage_return_pairs = without_bom.replace("\r\n", "\n").replace('\n', "\r\n");
    let carriage_returns = without_bom.replace("\r\n", "\n").replace('\n', "\r");
    vec![
        program.to_owned(),
        format!("\u{FEFF}{without_bom}"),
        without_bom.to_owned(),
        carriage_return_pairs,
        carriage_returns,
        format!("{without_bom}\n@ # $"),
        format!("{without_bom}\nEscribir \"sin cierre"),
        format!("Si Verdadero Entonces\n{without_bom}"),
    ]
}

fn reprint_difference(
    program: &str,
    profile: &str,
    subject: &mut impl PropertySubject,
) -> Difference {
    let response = subject.exchange(
        &json!({"kind":"probe","operation":"reprint","program":program,"profile":profile}),
    )?;
    let reprint = response.get("reprint").and_then(Value::as_str);
    Ok((reprint != Some(program)).then(|| (json!(program), response)))
}

fn recovery_texts(program: &str, profile: &str, subject: &mut impl PropertySubject) -> Difference {
    for candidate in recovery_candidates(program) {
        if let Some(difference) = reprint_difference(&candidate, profile, subject)? {
            return Ok(Some(difference));
        }
        let analysis = subject.exchange(
            &json!({"kind":"analyze","program":candidate,"profile":profile,"strictness":"strict"}),
        )?;
        if analysis.get("tree") != Some(&json!(true)) {
            return Ok(Some((json!({"tree":true}), analysis)));
        }
    }
    Ok(None)
}

fn recovery_candidates(program: &str) -> Vec<String> {
    let scrambled: String = program
        .chars()
        .rev()
        .filter(|character| *character != '\n')
        .take(4096)
        .collect();
    vec![
        String::new(),
        "   \n\t\r\n  ".to_owned(),
        "@ # $ ~ ` \\".to_owned(),
        "\"\"\"'".to_owned(),
        scrambled,
    ]
}

fn lowering_validity(source: &Source<'_>, subject: &mut impl PropertySubject) -> Difference {
    let (program, profile, strictness) = (source.program, source.profile, source.strictness);
    let request = json!({"kind":"ir","program":program,"profile":profile,"strictness":strictness});
    let response = subject.exchange(&request)?;
    let Some(outcome) = response.get("ir") else {
        return Ok(Some((json!({"ir":"present"}), response)));
    };
    if outcome.get("accepted") != Some(&json!(true)) {
        return rejected_is_invalid(source, subject, response);
    }
    let reprint = outcome
        .get("reprint")
        .and_then(Value::as_str)
        .unwrap_or_default();
    let reloaded = subject.exchange(
        &json!({"kind":"ir","program_ir":reprint,"profile":profile,"strictness":strictness}),
    )?;
    let accepted = reloaded.pointer("/ir/accepted") == Some(&json!(true));
    Ok((!accepted).then(|| (json!({"ir":{"accepted":true}}), reloaded)))
}

fn rejected_is_invalid(
    source: &Source<'_>,
    subject: &mut impl PropertySubject,
    response: Value,
) -> Difference {
    let (program, profile, strictness) = (source.program, source.profile, source.strictness);
    let analysis = subject.exchange(
        &json!({"kind":"analyze","program":program,"profile":profile,"strictness":strictness}),
    )?;
    let has_error = analysis
        .get("diagnostics")
        .and_then(Value::as_array)
        .is_some_and(|items| {
            items
                .iter()
                .any(|diagnostic| diagnostic.get("severity") == Some(&json!("error")))
        });
    Ok((!has_error).then(|| (json!({"ir":{"accepted":true}}), response)))
}

fn statement_mass(source: &Source<'_>, subject: &mut impl PropertySubject) -> Difference {
    let (program, profile, strictness) = (source.program, source.profile, source.strictness);
    let response = subject.exchange(&json!({"kind":"probe","operation":"statement_mass",
        "program":program,"profile":profile,"strictness":strictness}))?;
    if response.get("compiled") != Some(&json!(true)) {
        return Ok(None);
    }
    let count = |name: &str| response.get(name).and_then(Value::as_u64);
    let statements = count("statements");
    let aligned = [count("enters"), count("exits"), count("mass")]
        .iter()
        .all(|value| *value == statements);
    Ok((!aligned).then(|| {
        (
            json!({"enters":statements,"exits":statements,"mass":statements}),
            response,
        )
    }))
}

fn analysis_schema(source: &Source<'_>, subject: &mut impl PropertySubject) -> Difference {
    let (program, profile, strictness) = (source.program, source.profile, source.strictness);
    let response = subject.exchange(
        &json!({"kind":"analyze","program":program,"profile":profile,"strictness":strictness}),
    )?;
    let units = response
        .get("schema")
        .and_then(Value::as_array)
        .ok_or("SEE-PROPERTY: missing schema")?;
    let mut previous: Option<(u64, u64)> = None;
    for unit in units {
        let position = unit_start(unit).ok_or("SEE-PROPERTY: malformed unit span")?;
        if previous.is_some_and(|before| position <= before) || !named_in_text(unit, program) {
            return Ok(Some((json!({"ordered_unique_units":true}), response)));
        }
        previous = Some(position);
    }
    Ok(None)
}

fn unit_start(unit: &Value) -> Option<(u64, u64)> {
    let line = unit.pointer("/span/start/line")?.as_u64()?;
    let column = unit.pointer("/span/start/column")?.as_u64()?;
    Some((line, column))
}

fn named_in_text(unit: &Value, program: &str) -> bool {
    let line = unit
        .pointer("/span/start/line")
        .and_then(Value::as_u64)
        .and_then(|number| usize::try_from(number).ok())
        .and_then(|number| number.checked_sub(1));
    let name = unit.get("name").and_then(Value::as_str).unwrap_or_default();
    line.and_then(|index| program.lines().nth(index))
        .is_some_and(|text| text.contains(name))
}
