use crate::json_parse::parse_json;
use pseudolearn_runtime::JsonResultValue;

fn error_code(text: &str, maximum_depth: usize) -> Option<String> {
    match parse_json(text, maximum_depth) {
        Ok(JsonResultValue::Error(error)) => Some(error.code),
        _ => None,
    }
}

#[test]
fn accepts_all_json_kinds_and_valid_surrogate_pairs() {
    assert!(matches!(
        parse_json(
            r#"{"n":null,"b":true,"i":1,"r":1.5,"s":"x","a":[],"o":{}}"#,
            64
        ),
        Ok(JsonResultValue::Value(_))
    ));
    assert!(matches!(
        parse_json(r#""\uD83D\uDE00""#, 64),
        Ok(JsonResultValue::Value(_))
    ));
}

#[test]
fn reports_duplicate_keys_invalid_escapes_and_trailing_content() {
    assert_eq!(
        error_code(r#"{"a":1,"a":2}"#, 64),
        Some("duplicateKey".to_owned())
    );
    assert_eq!(
        error_code(r#""\uD800""#, 64),
        Some("invalidEscape".to_owned())
    );
    assert_eq!(
        error_code("true false", 64),
        Some("trailingContent".to_owned())
    );
}

#[test]
fn enforces_inclusive_container_depth_and_rejects_bom() {
    let accepted = format!("{}0{}", "[".repeat(64), "]".repeat(64));
    let rejected = format!("{}0{}", "[".repeat(65), "]".repeat(65));
    assert!(matches!(
        parse_json(&accepted, 64),
        Ok(JsonResultValue::Value(_))
    ));
    assert_eq!(error_code(&rejected, 64), Some("depthExceeded".to_owned()));
    assert_eq!(
        error_code("\u{feff}1", 64),
        Some("invalidSyntax".to_owned())
    );
}

#[test]
fn records_error_positions_and_unexpected_end() {
    let result = parse_json("[\n  1,\n    x\n]", 64);
    assert!(matches!(&result, Ok(JsonResultValue::Error(_))));
    if let Ok(JsonResultValue::Error(error)) = result {
        assert_eq!((error.line, error.column), (3, 5));
    }
    assert_eq!(error_code("[1", 64), Some("unexpectedEnd".to_owned()));
}
