use crate::{properties::PropertySubject, property_api as api, property_scenarios::Scenario};
use see_model::properties::PropertyExecutor;
use serde_json::{Value, json};
use std::collections::BTreeMap;

type Difference = Result<Option<(Value, Value)>, String>;

pub(crate) fn check(
    executor: PropertyExecutor,
    scenario: &Scenario,
    subject: &mut impl PropertySubject,
) -> Difference {
    let observation = api::value(api::call(
        subject,
        "record",
        json!({"request":scenario.request,"batch_size":1,"retain_views":true,"query_past":true}),
    )?)?;
    let states = api::array(&observation, "states")?;
    if states.len() != api::array(&observation, "events")?.len() {
        return Ok(Some((json!({"states": "one per event"}), observation)));
    }
    match executor {
        PropertyExecutor::SnapshotIsolation => Ok(api::different(
            json!(states),
            json!(api::array(&observation, "retained_views")?),
        )),
        PropertyExecutor::PastStateIsolation => Ok(api::different(
            json!(states),
            json!(api::array(&observation, "historical_states")?),
        )),
        PropertyExecutor::DeltaMinimality => deltas(&observation, true),
        PropertyExecutor::DeltaReconstruction => deltas(&observation, false),
        _ => Err("SEE-PROPERTY: invalid state executor".to_owned()),
    }
}

fn deltas(observation: &Value, minimal: bool) -> Difference {
    let initial = observation
        .get("initial_state")
        .ok_or("SEE-PROPERTY: missing initial state")?;
    let mut previous = flattened(initial);
    let states = api::array(observation, "states")?;
    let deltas = api::array(observation, "deltas")?;
    if states.len() != deltas.len() {
        return Ok(Some((json!(states.len()), json!(deltas.len()))));
    }
    for (state, delta) in states.iter().zip(deltas) {
        let expected = flattened(state);
        if let Some(difference) = apply_delta(&mut previous, &expected, delta, minimal)? {
            return Ok(Some(difference));
        }
        if previous != expected {
            return Ok(api::different(json!(expected), json!(previous)));
        }
    }
    Ok(None)
}

fn apply_delta(
    previous: &mut BTreeMap<String, Value>,
    expected: &BTreeMap<String, Value>,
    delta: &Value,
    minimal: bool,
) -> Difference {
    let changes = delta
        .as_array()
        .ok_or("SEE-PROPERTY: delta must be an array")?;
    let mut seen = std::collections::BTreeSet::new();
    for change in changes {
        let path = change
            .get("path")
            .and_then(Value::as_str)
            .ok_or("SEE-PROPERTY: missing change path")?;
        let before = change.get("before");
        let after = change.get("after");
        let invalid = !seen.insert(path)
            || previous.get(path) != before
            || after != expected.get(path)
            || (minimal && before == after);
        if invalid {
            return Ok(Some((
                json!({"before":previous.get(path),"after":expected.get(path)}),
                change.clone(),
            )));
        }
        match after {
            Some(value) => {
                previous.insert(path.to_owned(), value.clone());
            }
            None => {
                previous.remove(path);
            }
        }
    }
    Ok(None)
}

pub(crate) fn flattened(value: &Value) -> BTreeMap<String, Value> {
    let mut leaves = BTreeMap::new();
    let mut pending = vec![(String::new(), value)];
    while let Some((path, value)) = pending.pop() {
        match value {
            Value::Object(fields) if !fields.is_empty() => {
                pending.extend(fields.iter().map(|(name, value)| {
                    (
                        format!("{path}/{}", name.replace('~', "~0").replace('/', "~1")),
                        value,
                    )
                }));
            }
            Value::Array(values) if !values.is_empty() => {
                pending.extend(
                    values
                        .iter()
                        .enumerate()
                        .map(|(index, value)| (format!("{path}/{index}"), value)),
                );
            }
            _ => {
                leaves.insert(path, value.clone());
            }
        }
    }
    leaves
}
