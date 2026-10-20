use crate::{properties::PropertySubject, property_scenarios::Scenario};
use serde_json::{Value, json};

type Difference = Result<Option<(Value, Value)>, String>;

pub(crate) fn check(scenario: &Scenario, subject: &mut impl PropertySubject) -> Difference {
    let program = scenario
        .request
        .get("program")
        .ok_or("SEE-PROPERTY: missing program")?;
    let profile = scenario
        .request
        .get("profile")
        .ok_or("SEE-PROPERTY: missing profile")?;
    let strictness = scenario
        .request
        .get("strictness")
        .ok_or("SEE-PROPERTY: missing strictness")?;
    let domain = subject.exchange(
        &json!({"kind":"ir","program":program,"profile":profile,"strictness":strictness}),
    )?;
    if domain.pointer("/ir/accepted") != Some(&json!(true)) {
        return Ok(None);
    }
    let emitted = subject.exchange(&json!({"kind":"cli","arguments":["ri","p.pseudo","--vocabulary",profile,"--strictness",strictness],"files":{"p.pseudo":program},"environment":{},"stdin":""}))?;
    if emitted.get("exit_code") != Some(&json!(0)) {
        return Ok(Some((json!({"exit_code":0}), emitted)));
    }
    let output = emitted
        .get("output")
        .and_then(Value::as_str)
        .ok_or("SEE-PROPERTY: missing emitted RI")?;
    let verified = subject.exchange(
        &json!({"kind":"ir","program_ir":output,"profile":profile,"strictness":strictness}),
    )?;
    let same = verified.pointer("/ir/accepted") == Some(&json!(true))
        && verified.pointer("/ir/reprint") == Some(&json!(output));
    Ok((!same).then_some((json!({"ir":{"accepted":true,"reprint":output}}), verified)))
}
