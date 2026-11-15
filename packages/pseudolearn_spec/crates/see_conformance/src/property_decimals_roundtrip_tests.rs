use crate::property_decimals_roundtrip::scenario;

fn program_of(sample: u32, profile: &str) -> String {
    let built = scenario(42, sample, profile);
    built
        .request
        .get("program")
        .and_then(serde_json::Value::as_str)
        .unwrap_or_default()
        .to_owned()
}

fn field(program: &str, marker: &str) -> u64 {
    let tail = program.split(marker).nth(1).unwrap_or_default();
    let digits: String = tail.chars().take_while(char::is_ascii_digit).collect();
    digits.parse().unwrap_or(u64::MAX)
}

#[test]
fn mantissa_stays_inside_fifty_two_bits_and_never_zero() {
    for sample in 0..500 {
        let mantissa = field(&program_of(sample, "es"), "Real <- ");
        assert!(
            (1..4_503_599_627_370_496).contains(&mantissa),
            "sample {sample}: {mantissa}"
        );
    }
}

#[test]
fn shift_never_exceeds_sixty() {
    for sample in 0..500 {
        let shift = field(&program_of(sample, "en"), "while i < ");
        assert!(shift <= 60, "sample {sample}: {shift}");
    }
}

#[test]
fn both_profiles_share_mantissa_and_shift() {
    let spanish = program_of(6, "es");
    let english = program_of(6, "en");
    assert_eq!(field(&spanish, "Real <- "), field(&english, "real <- "));
    assert_eq!(
        field(&spanish, "Mientras i < "),
        field(&english, "while i < ")
    );
}

#[test]
fn expected_result_is_the_round_trip_flag() {
    let built = scenario(42, 3, "es");
    assert_eq!(
        built.expected,
        Some(serde_json::json!({"salida": "1\n", "terminacion": "completed"}))
    );
}
