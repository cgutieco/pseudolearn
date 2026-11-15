use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

fn message(locale: Option<&str>) -> Result<String, String> {
    let mut session = ApiSession::default();
    let mut arguments =
        json!({"program":"Algoritmo P\nEscribir inexistente;\nFinAlgoritmo\n","profile":"es"});
    if let (Some(locale), Some(fields)) = (locale, arguments.as_object_mut()) {
        fields.insert("locale".to_owned(), json!(locale));
    }
    let analysis = session
        .call("create_analysis", &arguments)
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing analysis")?;
    let report = session.call("analysis", &json!({"resource":analysis}));
    report
        .pointer("/value/diagnostics/0/message")
        .and_then(Value::as_str)
        .map(str::to_owned)
        .ok_or_else(|| "missing diagnostic".to_owned())
}

#[test]
fn messages_follow_the_profile_without_a_locale() -> Result<(), String> {
    let spanish = message(None)?;
    assert_eq!(spanish, message(Some("es"))?);
    Ok(())
}

#[test]
fn an_interface_locale_renders_messages_independently_of_the_profile() -> Result<(), String> {
    assert_ne!(message(Some("en"))?, message(Some("es"))?);
    Ok(())
}
