use serde_json::{Value, json};

pub fn record(path: &str, entries: Vec<Value>) -> Result<(), String> {
    let mut measurements: Vec<Value> = match std::fs::read_to_string(path) {
        Ok(text) => serde_json::from_str::<Value>(&text)
            .map_err(|error| error.to_string())?
            .get("measurements")
            .and_then(Value::as_array)
            .cloned()
            .unwrap_or_default(),
        Err(_) => Vec::new(),
    };
    for entry in entries {
        let reference = entry.get("reference").cloned();
        measurements.retain(|existing| existing.get("reference") != reference.as_ref());
        measurements.push(entry);
    }
    measurements.sort_by_key(|entry| {
        entry
            .get("reference")
            .and_then(Value::as_str)
            .unwrap_or("")
            .to_owned()
    });
    let document = json!({ "format": "see-measurements/1", "measurements": measurements });
    let text = serde_json::to_string_pretty(&document).map_err(|error| error.to_string())?;
    std::fs::write(path, format!("{text}\n")).map_err(|error| error.to_string())
}

pub struct Measurement<'measurement> {
    pub reference: &'measurement str,
    pub metric: &'measurement str,
    pub unit: &'measurement str,
    pub comparator: &'measurement str,
}

pub fn entry(measurement: &Measurement<'_>, values: (f64, f64)) -> Value {
    let (threshold, observed) = values;
    let measured = crate::service::statistics::round(observed);
    let satisfied = match measurement.comparator {
        "<=" => measured <= threshold,
        _ => measured >= threshold,
    };
    json!({
        "reference": measurement.reference,
        "suite": "servicio",
        "metric": measurement.metric,
        "unit": measurement.unit,
        "comparator": measurement.comparator,
        "threshold": threshold,
        "measured": measured,
        "status": if satisfied { "cumple" } else { "incumple" },
    })
}
