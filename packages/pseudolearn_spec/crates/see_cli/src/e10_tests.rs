use super::measure;
use serde_json::json;

#[test]
fn measures_colliding_names_without_discarding_them_as_keywords() -> Result<(), String> {
    let vocabulary = json!({"and":{"lexemas":{"es":"Y","en":"and"},"alias":{"es":[],"en":[]}}});
    let measurement = measure(
        "Definir y, total Como Entero;\nPara y <- 0 Hasta 1 Hacer\n",
        "es",
        &vocabulary,
    )?;
    assert_eq!(measurement.pointer("/collisions/y"), Some(&json!(2)));
    assert_eq!(measurement.pointer("/candidates/total"), Some(&json!(1)));
    assert!(
        measure("", "es", &vocabulary)?
            .get("collisions")
            .is_some_and(|value| value == &json!({}))
    );
    assert!(measure("define value as integer", "en", &json!({"invalid":{}})).is_err());
    Ok(())
}
