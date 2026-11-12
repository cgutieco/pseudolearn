use crate::editor_session::Running;
use serde_json::{Value, json};

pub(crate) fn resolve(running: &mut Running<'_>, response: &Value) -> Result<(), String> {
    let host = running.effects.as_mut().ok_or("missing physical host")?;
    let effects = response
        .get("pending_effects")
        .and_then(Value::as_array)
        .cloned()
        .unwrap_or_else(|| {
            response
                .get("pending_effect")
                .cloned()
                .into_iter()
                .collect()
        });
    for effect in effects {
        host.submit(effect)?;
    }
    for (request, reply) in host.completed() {
        let answer = running.session.call(
            "effect_result",
            &json!({"resource":running.resource,
            "effect_seq":request.get("effect_seq"),"result":reply}),
        );
        if answer.get("value").is_none() {
            return Err(answer.to_string());
        }
    }
    std::thread::sleep(std::time::Duration::from_millis(1));
    Ok(())
}
