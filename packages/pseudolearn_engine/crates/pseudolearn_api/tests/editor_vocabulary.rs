use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

fn vocabulary(profile: &str) -> Value {
    ApiSession::default().call("editor_vocabulary", &json!({"profile":profile}))
}

#[test]
fn generated_words_follow_the_selected_profile() {
    let spanish = vocabulary("es");
    let english = vocabulary("en");
    let spanish_words = spanish.pointer("/value/keywords").and_then(Value::as_array);
    let english_words = english.pointer("/value/keywords").and_then(Value::as_array);
    assert!(spanish_words.is_some_and(|words| words.contains(&json!(["algorithm", "Proceso"]))));
    assert!(english_words.is_some_and(|words| words.contains(&json!(["algorithm", "algorithm"]))));
    assert!(spanish.pointer("/value/block_openers").is_some());
}

#[test]
fn grammar_symbols_are_profile_independent() {
    let spanish = vocabulary("es");
    let english = vocabulary("en");
    let symbols = json!({
        "assignment":"<-",
        "quote":"\"",
        "left_parenthesis":"(",
        "right_parenthesis":")",
        "greater_equal":">=",
        "less_equal":"<="
    });
    assert_eq!(spanish.pointer("/value/symbols"), Some(&symbols));
    assert_eq!(english.pointer("/value/symbols"), Some(&symbols));
}

#[test]
fn unknown_profiles_are_rejected() {
    let response = vocabulary("fr");
    assert_eq!(response.pointer("/failure/family"), Some(&json!("usage")));
}
