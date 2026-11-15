use crate::{properties::PropertySubject, property_api as api, property_scenarios::Scenario};
use see_model::properties::PropertyExecutor;
use serde_json::{Value, json};

type Difference = Result<Option<(Value, Value)>, String>;

pub(crate) fn check(
    executor: PropertyExecutor,
    scenario: &Scenario,
    subject: &mut impl PropertySubject,
) -> Difference {
    let base = event_record(subject, scenario, json!({"batch_size":1}))?;
    match executor {
        PropertyExecutor::StepPartition => batches(subject, scenario, &base),
        PropertyExecutor::InputBatching => input_batches(subject, scenario, &base),
        PropertyExecutor::ExecutionControls => {
            variant(subject, scenario, &base, json!({"seek_every_event":true}))
        }
        PropertyExecutor::HostRecording => variant(
            subject,
            scenario,
            &base,
            json!({"host_tape":base.get("host_tape").ok_or("SEE-PROPERTY: missing host tape")?}),
        ),
        PropertyExecutor::StateQuery => horizon(subject, scenario),
        PropertyExecutor::StepDepth => crate::property_steps::check(subject, scenario, &base),
        PropertyExecutor::WireRoundtrip => wire(subject, &base),
        _ => Err("SEE-PROPERTY: invalid recording executor".to_owned()),
    }
}

pub(crate) fn record(
    subject: &mut impl PropertySubject,
    scenario: &Scenario,
    options: Value,
) -> Result<Value, String> {
    let mut options = options;
    let request = scenario.request.clone();
    if !scenario.traced
        && let Some(settings) = options.as_object_mut()
    {
        settings.insert("capture_states".to_owned(), json!(false));
        settings.insert("summarize_events".to_owned(), json!(true));
    }
    api::value(api::call(
        subject,
        "record",
        json!({"request":request,"options":options}),
    )?)
}

fn event_record(
    subject: &mut impl PropertySubject,
    scenario: &Scenario,
    mut options: Value,
) -> Result<Value, String> {
    options
        .as_object_mut()
        .ok_or("SEE-PROPERTY: invalid recording settings")?
        .insert("capture_states".to_owned(), json!(false));
    record(subject, scenario, options)
}

fn variant(
    subject: &mut impl PropertySubject,
    scenario: &Scenario,
    base: &Value,
    options: Value,
) -> Difference {
    let mut actual = event_record(subject, scenario, options)?;
    let mut base = base.clone();
    crate::event_identity::normalize(&mut actual)?;
    crate::event_identity::normalize(&mut base)?;
    for field in [
        "events",
        "event_summary",
        "output",
        "termination",
        "diagnostics",
        "inputs_consumed",
    ] {
        if let Some(expected) = base.get(field)
            && actual.get(field) != Some(expected)
        {
            return Ok(Some((
                json!({field:expected}),
                json!({field:actual.get(field)}),
            )));
        }
    }
    Ok(None)
}

fn batches(subject: &mut impl PropertySubject, scenario: &Scenario, base: &Value) -> Difference {
    for batch in [2, 7, 4096] {
        if let Some(difference) = variant(subject, scenario, base, json!({"batch_size":batch}))? {
            return Ok(Some(difference));
        }
    }
    Ok(None)
}

fn input_batches(
    subject: &mut impl PropertySubject,
    scenario: &Scenario,
    base: &Value,
) -> Difference {
    let inputs = api::array(&scenario.request, "inputs")?;
    for split in partition_points(inputs.len()) {
        let count = inputs
            .len()
            .checked_sub(split)
            .ok_or("SEE-PROPERTY: partition overflow")?;
        if let Some(difference) = variant(
            subject,
            scenario,
            base,
            json!({"input_batch_sizes":[split,count]}),
        )? {
            return Ok(Some(difference));
        }
    }
    Ok(None)
}

fn partition_points(length: usize) -> Vec<usize> {
    let mut points = vec![0, 1, length / 2, length.saturating_sub(1), length];
    points.retain(|point| *point <= length);
    points.sort_unstable();
    points.dedup();
    points
}

fn wire(subject: &mut impl PropertySubject, base: &Value) -> Difference {
    let events = api::array(base, "events")?;
    for encoding in ["json", "binary"] {
        let encoded = api::value(api::call(
            subject,
            "encode_events",
            json!({"events":events,"encoding":encoding}),
        )?)?;
        let decoded = api::value(api::call(
            subject,
            "decode_events",
            json!({"encoded":encoded,"encoding":encoding}),
        )?)?;
        if decoded != json!(events) {
            return Ok(Some((json!(events), decoded)));
        }
    }
    Ok(None)
}

fn horizon(subject: &mut impl PropertySubject, scenario: &Scenario) -> Difference {
    let observation = record(
        subject,
        scenario,
        json!({"retention_events":1,"query_all_events":true}),
    )?;
    let states = api::array(&observation, "states")?;
    let queries = api::array(&observation, "queries")?;
    let first = observation
        .pointer("/horizon/first")
        .and_then(Value::as_u64)
        .ok_or("SEE-PROPERTY: missing horizon")?;
    let last = observation
        .pointer("/horizon/last")
        .and_then(Value::as_u64)
        .ok_or("SEE-PROPERTY: missing horizon")?;
    if states.len() != queries.len() {
        return Ok(Some((json!(states.len()), json!(queries.len()))));
    }
    for (index, (state, query)) in states.iter().zip(queries).enumerate() {
        let index = u64::try_from(index).map_err(|error| error.to_string())?;
        let valid = if (first..=last).contains(&index) {
            query.get("value") == Some(state)
        } else {
            api::failure(query, "usage")
        };
        if !valid {
            return Ok(Some((
                json!({"event":index,"expected":state}),
                query.clone(),
            )));
        }
    }
    Ok(None)
}
