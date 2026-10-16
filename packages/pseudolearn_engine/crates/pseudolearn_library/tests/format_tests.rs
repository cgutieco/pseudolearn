use pseudolearn_library::{BooleanLexemes, PrimitiveValue, format_value};

#[test]
fn format_preserves_real_bits_with_positional_round_trip() {
    let lexemes = BooleanLexemes {
        truth: "yes",
        falsity: "no",
    };
    for value in [
        0.0,
        -0.0,
        1.0,
        f64::MIN_POSITIVE,
        f64::MAX,
        f64::from_bits(1),
    ] {
        let text = format_value(PrimitiveValue::Real(value), lexemes);
        assert!(text.contains('.'));
        assert!(!text.contains(['e', 'E']));
        assert_eq!(
            text.parse::<f64>().ok().map(f64::to_bits),
            Some(value.to_bits())
        );
    }
    assert_eq!(format_value(PrimitiveValue::Boolean(false), lexemes), "no");
    assert_eq!(format_value(PrimitiveValue::Text(""), lexemes), "");
}
