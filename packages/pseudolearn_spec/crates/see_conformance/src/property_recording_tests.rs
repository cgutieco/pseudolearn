use crate::{properties::PropertySubject, property_scenarios::Scenario};
use serde_json::{Value, json};

struct Subject;

impl PropertySubject for Subject {
    fn declaration(&self) -> &Value {
        &Value::Null
    }
    fn exchange(&mut self, request: &Value) -> Result<Value, String> {
        Ok(json!({"result":{"value":request.get("arguments")}}))
    }
}

#[test]
fn complete_recordings_preserve_all_existing_limits() -> Result<(), String> {
    for limits in [
        json!({}),
        json!({"statements":1,"depth":2,"cells":3,"micro_steps":4}),
    ] {
        let scenario = Scenario {
            request: json!({"limits":limits}),
            expected: None,
            traced: false,
        };
        let recorded = super::property_recording::record(&mut Subject, &scenario, json!({}))?;
        assert_eq!(recorded.pointer("/request/limits"), Some(&limits));
        assert_eq!(
            recorded.pointer("/options/summarize_events"),
            Some(&json!(true))
        );
    }
    Ok(())
}
