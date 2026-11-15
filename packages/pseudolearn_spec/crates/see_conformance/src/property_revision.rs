use crate::{properties::PropertySubject, property_api as api, property_scenarios::Scenario};
use serde_json::{Value, json};

type Difference = Result<Option<(Value, Value)>, String>;

pub(crate) fn check(scenario: &Scenario, subject: &mut impl PropertySubject) -> Difference {
    let profile = scenario
        .request
        .get("profile")
        .and_then(Value::as_str)
        .unwrap_or("es");
    let program = if profile == "en" {
        "Algorithm P\nEndAlgorithm\n"
    } else {
        "Algoritmo P\nFinAlgoritmo\n"
    };
    let request = json!({"program":program,"profile":profile});
    let first = document(subject, &request)?;
    let second = document(subject, &request)?;
    let initial = api::value(api::call(
        subject,
        "program_view",
        json!({"resource":second}),
    )?)?;
    let invalid = api::call(
        subject,
        "create_document",
        json!({"program":program,"profile":profile,"previous_document":u64::MAX}),
    )?;
    let invalid = (!api::failure(&invalid, "usage"))
        .then_some((json!({"failure":{"family":"usage"}}), invalid));
    let result = compare(subject, &first, &second)?;
    let successor = verify_successor(subject, &request, (&first, &second))?;
    let remaining = api::value(api::call(
        subject,
        "program_view",
        json!({"resource":second}),
    )?)?;
    api::release(subject, &second)?;
    Ok(result
        .or(successor)
        .or(invalid)
        .or_else(|| api::different(initial, remaining)))
}

fn verify_successor(
    subject: &mut impl PropertySubject,
    request: &Value,
    documents: (&Value, &Value),
) -> Difference {
    let (first, second) = documents;
    let (replacement, stale_node) = replace(subject, request, first)?;
    let invalidated = api::call(subject, "program_view", json!({"resource":first}))?;
    let stale = compare(subject, &replacement, second)?;
    api::release(subject, &replacement)?;
    let released = api::call(subject, "program_view", json!({"resource":replacement}))?;
    Ok(stale.or(stale_node).or_else(|| {
        (!api::failure(&invalidated, "usage") || !api::failure(&released, "usage")).then_some((
            json!({"invalidated":"usage","released":"usage"}),
            json!({"invalidated":invalidated,"released":released}),
        ))
    }))
}

fn replace(
    subject: &mut impl PropertySubject,
    request: &Value,
    previous: &Value,
) -> Result<(Value, Option<(Value, Value)>), String> {
    let view = api::value(api::call(
        subject,
        "program_view",
        json!({"resource":previous}),
    )?)?;
    let node = view
        .pointer("/nodes/0/node_id")
        .ok_or("SEE-PROPERTY: missing node")?;
    let mut request = request.clone();
    request
        .as_object_mut()
        .ok_or("SEE-PROPERTY: invalid request")?
        .insert("previous_document".to_owned(), previous.clone());
    let replacement = document(subject, &request)?;
    let foreign = api::call(
        subject,
        "query_node",
        json!({"resource":replacement,"node_id":node}),
    )?;
    let difference = (!api::failure(&foreign, "usage"))
        .then_some((json!({"failure":{"family":"usage"}}), foreign));
    Ok((replacement, difference))
}

fn document(subject: &mut impl PropertySubject, request: &Value) -> Result<Value, String> {
    api::value(api::call(subject, "create_document", request.clone())?)?
        .get("resource")
        .cloned()
        .ok_or("SEE-PROPERTY: missing document".to_owned())
}

fn compare(subject: &mut impl PropertySubject, first: &Value, second: &Value) -> Difference {
    let view = api::value(api::call(
        subject,
        "program_view",
        json!({"resource":first}),
    )?)?;
    let identifier = view
        .pointer("/nodes/0/node_id")
        .ok_or("SEE-PROPERTY: missing node")?;
    let own = api::value(api::call(
        subject,
        "query_node",
        json!({"resource":first,"node_id":identifier}),
    )?)?;
    if own.get("node").is_none() {
        return Ok(Some((json!({"node":"present"}), own)));
    }
    let foreign = api::call(
        subject,
        "query_node",
        json!({"resource":second,"node_id":identifier}),
    )?;
    Ok((!api::failure(&foreign, "usage"))
        .then_some((json!({"failure":{"family":"usage"}}), foreign)))
}
