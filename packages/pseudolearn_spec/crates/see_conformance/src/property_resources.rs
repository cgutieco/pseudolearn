use crate::{properties::PropertySubject, property_api as api, property_scenarios::Scenario};
use see_model::properties::PropertyExecutor;
use serde_json::{Value, json};

type Difference = Result<Option<(Value, Value)>, String>;

pub(crate) fn check(
    executor: PropertyExecutor,
    scenario: &Scenario,
    subject: &mut impl PropertySubject,
) -> Difference {
    match executor {
        PropertyExecutor::ResourceLifecycle => lifecycle(scenario, subject),
        PropertyExecutor::UsageErrors => usage(scenario, subject),
        PropertyExecutor::VersionNegotiation => version(subject),
        PropertyExecutor::CapabilityNegotiation => capabilities(subject),
        PropertyExecutor::InternalFaultContainment => faults(scenario, subject),
        PropertyExecutor::InterfaceLanguage => language(scenario, subject),
        _ => Err("SEE-PROPERTY: invalid resource executor".to_owned()),
    }
}

fn lifecycle(scenario: &Scenario, subject: &mut impl PropertySubject) -> Difference {
    let resource = api::create(subject, &scenario.request)?;
    api::value(api::call(
        subject,
        "analysis",
        json!({"resource":resource}),
    )?)?;
    api::release(subject, &resource)?;
    let result = api::call(subject, "analysis", json!({"resource":resource}))?;
    Ok(
        (!api::failure(&result, "usage"))
            .then_some((json!({"failure":{"family":"usage"}}), result)),
    )
}

fn usage(scenario: &Scenario, subject: &mut impl PropertySubject) -> Difference {
    let declared = api::value(api::call(subject, "operations", json!({}))?)?;
    let operations = declared
        .as_array()
        .ok_or("SEE-PROPERTY: missing API operations")?;
    if operations.is_empty() {
        return Err("SEE-PROPERTY: empty API operations".to_owned());
    }
    for operation in operations {
        let operation = operation
            .as_str()
            .ok_or("SEE-PROPERTY: invalid operation name")?;
        let invalid = api::call(
            subject,
            operation,
            json!({"resource":u64::MAX, "invalid":true}),
        )?;
        if !api::failure(&invalid, "usage") && !api::failure(&invalid, "version") {
            return Ok(Some((
                json!({"failure":{"family":"usage or version"}}),
                invalid,
            )));
        }
    }
    lifecycle(scenario, subject)
}

fn version(subject: &mut impl PropertySubject) -> Difference {
    let declaration = api::value(api::call(subject, "version", json!({}))?)?;
    for field in ["version", "editions", "capabilities"] {
        if declaration.get(field).is_none() {
            return Ok(Some((json!({"required":field}), declaration)));
        }
    }
    let valid = declaration
        .get("version")
        .and_then(Value::as_str)
        .is_some_and(|version| !version.is_empty())
        && ["editions", "capabilities"].iter().all(|name| {
            declaration
                .get(name)
                .and_then(Value::as_array)
                .is_some_and(|values| !values.is_empty())
        });
    Ok((!valid).then_some((
        json!({"nonempty":["version","editions","capabilities"]}),
        declaration,
    )))
}

fn capabilities(subject: &mut impl PropertySubject) -> Difference {
    let declaration = api::value(api::call(subject, "version", json!({}))?)?;
    for name in ["editions", "capabilities"] {
        for value in api::array(&declaration, name)? {
            let result = api::call(subject, "negotiate", json!({(name):value}))?;
            if result.get("failure").is_some() {
                return Ok(Some((json!({"accepted":value}), result)));
            }
        }
        let result = api::call(subject, "negotiate", json!({(name):"SEE-UNKNOWN"}))?;
        if !api::failure(&result, "version") {
            return Ok(Some((json!({"failure":{"family":"version"}}), result)));
        }
    }
    Ok(None)
}

fn faults(scenario: &Scenario, subject: &mut impl PropertySubject) -> Difference {
    let stages = api::value(api::call(subject, "fault_stages", json!({}))?)?;
    let stages = stages
        .as_array()
        .filter(|stages| !stages.is_empty())
        .ok_or("SEE-PROPERTY: no injection stages")?;
    for stage in stages {
        let result = api::call(
            subject,
            "inject_fault",
            json!({"stage":stage, "request":scenario.request}),
        )?;
        if !api::failure(&result, "internal") {
            return Ok(Some((json!({"failure":{"family":"internal"}}), result)));
        }
        api::value(api::call(subject, "version", json!({}))?)?;
    }
    Ok(None)
}

fn language(scenario: &Scenario, subject: &mut impl PropertySubject) -> Difference {
    let resource = api::create(subject, &scenario.request)?;
    let expected = stripped(api::value(api::call(
        subject,
        "analysis",
        json!({"resource":resource}),
    )?)?);
    let mut difference = None;
    for language in ["es", "en"] {
        let actual = stripped(api::value(api::call(
            subject,
            "analysis",
            json!({"resource":resource,"interface_language":language}),
        )?)?);
        if actual != expected {
            difference = api::different(expected.clone(), actual);
            break;
        }
    }
    api::release(subject, &resource)?;
    Ok(difference)
}

fn stripped(mut response: Value) -> Value {
    if let Some(diagnostics) = response
        .get_mut("diagnostics")
        .and_then(Value::as_array_mut)
    {
        for diagnostic in diagnostics {
            if let Some(fields) = diagnostic.as_object_mut() {
                fields.remove("message");
            }
        }
    }
    response
}
