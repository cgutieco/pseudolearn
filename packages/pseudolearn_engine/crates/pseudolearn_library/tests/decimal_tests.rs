use pseudolearn_library::{parse_integer, parse_real};

#[test]
fn decimal_conversions_validate_range_and_finiteness() {
    assert_eq!(parse_integer(&i64::MIN.to_string()), Ok(i64::MIN));
    assert!(parse_integer("9223372036854775808").is_err());
    assert!(parse_integer("1.5").is_err());
    for text in ["", "NaN", "inf", "1e999", " 1"] {
        assert!(parse_real(text).is_err());
    }
    assert_eq!(
        parse_real("-0.0").map(f64::to_bits),
        Ok((-0.0_f64).to_bits())
    );
    assert_eq!(parse_real("1.25"), Ok(1.25));
}
