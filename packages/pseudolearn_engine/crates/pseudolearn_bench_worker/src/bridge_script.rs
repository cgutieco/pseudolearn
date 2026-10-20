use pseudolearn_api::ApiSession;
use serde_json::{Map, Value, json};
use std::time::Instant;

#[derive(Default)]
pub(crate) struct Script {
    session: ApiSession,
    bindings: Map<String, Value>,
    output: String,
    event_count: u64,
}

impl Script {
    pub(crate) fn run(&mut self, scenario: &Value) -> Result<Vec<Value>, String> {
        self.sequence(scenario.get("setup"), &mut Vec::new())?;
        let mut measurements = Vec::new();
        self.sequence(scenario.get("timed"), &mut measurements)?;
        self.sequence(scenario.get("verify"), &mut Vec::new())?;
        if measurements.is_empty() {
            return Err("No timed bridge requests".to_owned());
        }
        let expected = scenario
            .get("expected")
            .and_then(Value::as_object)
            .ok_or("Missing independent bridge expectations")?;
        if expected.is_empty() || !self.matches(expected)? {
            return Err("Bridge scenario did not satisfy its independent expectations".to_owned());
        }
        Ok(measurements)
    }

    fn sequence(
        &mut self,
        steps: Option<&Value>,
        measurements: &mut Vec<Value>,
    ) -> Result<(), String> {
        for step in steps.and_then(Value::as_array).into_iter().flatten() {
            let until = step.get("until").and_then(Value::as_object);
            let limit = if until.is_some() {
                step.get("limit")
                    .and_then(Value::as_u64)
                    .ok_or("Missing bridge repetition limit")?
            } else {
                1
            };
            let mut completed = false;
            for _ in 0..limit {
                self.invoke(step, measurements)?;
                completed = match until {
                    Some(expected) => self.matches(expected)?,
                    None => true,
                };
                if completed {
                    break;
                }
            }
            if !completed {
                return Err("Bridge repetition limit exceeded".to_owned());
            }
        }
        Ok(())
    }

    fn invoke(&mut self, step: &Value, measurements: &mut Vec<Value>) -> Result<(), String> {
        let operation = step
            .get("operation")
            .and_then(Value::as_str)
            .ok_or("Missing operation")?;
        let arguments = self.resolve(step.get("arguments").ok_or("Missing arguments")?)?;
        let clock = Instant::now();
        let response = self.session.call(operation, &arguments);
        let nanoseconds =
            u64::try_from(clock.elapsed().as_nanos()).map_err(|error| error.to_string())?;
        let result = response
            .get("value")
            .ok_or_else(|| response.to_string())?
            .clone();
        measurements.push(
            json!({"operation":step.get("label").and_then(Value::as_str).unwrap_or(operation),
            "nanoseconds":nanoseconds,"request":measurements.len(),"clock":"Instant"}),
        );
        let name = step.get("save").and_then(Value::as_str).unwrap_or("last");
        self.bindings.insert(name.to_owned(), result.clone());
        self.record_output(&result);
        Ok(())
    }

    fn record_output(&mut self, result: &Value) {
        let Some(events) = result.get("events").and_then(Value::as_array) else {
            return;
        };
        for event in events {
            if event.get("class").and_then(Value::as_str) == Some("output") {
                self.output.push_str(
                    event
                        .pointer("/data/texto")
                        .and_then(Value::as_str)
                        .unwrap_or(""),
                );
            }
        }
        self.event_count = self
            .event_count
            .saturating_add(u64::try_from(events.len()).unwrap_or(u64::MAX));
        self.bindings.insert(
            "event_index".to_owned(),
            json!(self.event_count.saturating_sub(1)),
        );
        self.bindings
            .insert("output".to_owned(), json!(self.output));
    }

    fn matches(&self, expected: &Map<String, Value>) -> Result<bool, String> {
        for (path, value) in expected {
            if self.lookup(path)? != value {
                return Ok(false);
            }
        }
        Ok(true)
    }

    fn lookup(&self, path: &str) -> Result<&Value, String> {
        let mut components = path.split('.');
        let first = components.next().ok_or("Empty bridge binding")?;
        let mut value = self.bindings.get(first).ok_or("Unknown bridge binding")?;
        for component in components {
            value = value
                .get(component)
                .ok_or("Unresolved bridge binding path")?;
        }
        Ok(value)
    }

    fn resolve(&self, value: &Value) -> Result<Value, String> {
        match value {
            Value::String(text) if text.starts_with('$') => {
                self.lookup(text.get(1..).unwrap_or("")).cloned()
            }
            Value::Object(object) => object
                .iter()
                .map(|(key, value)| self.resolve(value).map(|value| (key.clone(), value)))
                .collect::<Result<Map<_, _>, _>>()
                .map(Value::Object),
            Value::Array(values) => values
                .iter()
                .map(|value| self.resolve(value))
                .collect::<Result<Vec<_>, _>>()
                .map(Value::Array),
            _ => Ok(value.clone()),
        }
    }
}
