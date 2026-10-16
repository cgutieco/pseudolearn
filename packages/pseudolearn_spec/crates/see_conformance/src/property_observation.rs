use crate::{properties::PropertySubject, property_api as api};
use serde_json::{Value, json};

pub(crate) fn execute(
    subject: &mut impl PropertySubject,
    request: &Value,
) -> Result<Value, String> {
    let created = api::value(api::call(subject, "create_analysis", request.clone())?)?;
    let analysis = created
        .get("resource")
        .ok_or("SEE-PROPERTY: missing analysis")?;
    let mut options = request.clone();
    options
        .as_object_mut()
        .ok_or("SEE-PROPERTY: invalid request")?
        .insert("analysis".to_owned(), analysis.clone());
    let execution = api::value(api::call(subject, "start", options)?)?;
    let resource = execution
        .get("resource")
        .ok_or("SEE-PROPERTY: missing execution")?;
    let result = loop {
        let batch = api::value(api::call(
            subject,
            "advance",
            json!({"resource":resource,"batch_size":1024}),
        )?)?;
        if batch.pointer("/termination/kind").and_then(Value::as_str) != Some("running") {
            break batch;
        }
    };
    let parent = created.get("document").unwrap_or(analysis);
    api::release(subject, parent)?;
    Ok(result)
}
