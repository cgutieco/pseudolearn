use crate::json_parse::parse_json;
use crate::json_text::normalize_text;
use pseudolearn_runtime::JsonResultValue;

#[test]
fn preserves_key_order_and_original_number_lexemes() {
    assert_eq!(
        normalize_text(r#"{"b":-0,"a":1e400}"#),
        Ok(r#"{"b":-0,"a":1e400}"#.to_owned())
    );
}

#[test]
fn serializes_unicode_with_minimal_json_escaping() {
    assert_eq!(normalize_text(r#""\uD83D\uDE00""#), Ok("\"😀\"".to_owned()));
}

#[test]
fn parses_the_serialized_value_again() {
    let source = r#"{"x":[true,null,"y"]}"#;
    let result = parse_json(source, 64);
    assert!(matches!(&result, Ok(JsonResultValue::Value(_))));
    if let Ok(JsonResultValue::Value(text)) = result {
        assert!(matches!(
            parse_json(&text, 64),
            Ok(JsonResultValue::Value(_))
        ));
    }
}
