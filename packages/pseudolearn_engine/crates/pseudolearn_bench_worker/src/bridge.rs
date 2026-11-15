use crate::bridge_script::Script;
use serde_json::{Value, json};
use std::io::Read;

pub(crate) fn collect() -> Result<(), String> {
    let mut text = String::new();
    std::io::stdin()
        .take(16_777_216)
        .read_to_string(&mut text)
        .map_err(|error| error.to_string())?;
    let configuration: Value = serde_json::from_str(&text).map_err(|error| error.to_string())?;
    let iterations = if configuration.get("mode").and_then(Value::as_str) == Some("smoke") {
        1
    } else {
        30
    };
    if configuration.get("iterations").and_then(Value::as_u64) != Some(iterations) {
        return Err("Invalid bridge iteration count".to_owned());
    }
    let scenarios = configuration
        .get("scenarios")
        .and_then(Value::as_array)
        .ok_or("Missing bridge scenarios")?;
    let resolution = clock_resolution()?;
    for scenario in scenarios {
        for iteration in 0..iterations {
            let mut script = Script::default();
            for row in script.run(scenario)? {
                emit(row, scenario, iteration, resolution)?;
            }
        }
    }
    Ok(())
}

fn clock_resolution() -> Result<Option<u64>, String> {
    let mut previous = std::time::Instant::now();
    let mut minimum = None;
    for _ in 0..1000 {
        let current = std::time::Instant::now();
        let delta = u64::try_from(current.duration_since(previous).as_nanos())
            .map_err(|error| error.to_string())?;
        if delta > 0 && minimum.is_none_or(|minimum| delta < minimum) {
            minimum = Some(delta);
        }
        previous = current;
    }
    Ok(minimum)
}

fn emit(
    row: Value,
    scenario: &Value,
    iteration: u64,
    resolution: Option<u64>,
) -> Result<(), String> {
    let mut row = row.as_object().ok_or("Invalid bridge measurement")?.clone();
    row.insert(
        "scenario".to_owned(),
        scenario
            .get("id")
            .ok_or("Missing scenario identity")?
            .clone(),
    );
    row.insert("iteration".to_owned(), json!(iteration));
    row.insert("verified".to_owned(), json!(true));
    row.insert(
        "clock_resolution_observed_nanoseconds".to_owned(),
        json!(resolution),
    );
    println!("{}", Value::Object(row));
    Ok(())
}
