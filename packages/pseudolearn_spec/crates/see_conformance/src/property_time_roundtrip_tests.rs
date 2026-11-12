use crate::property_time_roundtrip::scenario;

fn program_of(sample: u32, profile: &str) -> String {
    let built = scenario(42, sample, profile);
    built
        .request
        .get("program")
        .and_then(serde_json::Value::as_str)
        .unwrap_or_default()
        .to_owned()
}

#[test]
fn spanish_and_english_programs_embed_the_same_instant() {
    let spanish = program_of(4, "es");
    let english = program_of(4, "en");
    let literal = |text: &str, marker: &str| -> String {
        let tail = text.split(marker).nth(1).unwrap_or_default();
        tail.chars()
            .take_while(|character| *character != ')')
            .collect()
    };
    assert_eq!(
        literal(&spanish, "Algoritmo P\nVuelta("),
        literal(&english, "algorithm P\nBack(")
    );
}

#[test]
fn every_sampled_instant_stays_inside_the_representable_range() {
    for sample in 0..500 {
        let program = program_of(sample, "es");
        let tail = program
            .split("Algoritmo P\nVuelta(")
            .nth(1)
            .unwrap_or_default();
        let literal: String = tail
            .chars()
            .take_while(|character| *character != ')')
            .collect();
        let instant: i128 = literal.parse().unwrap_or(i128::MAX);
        assert!(
            instant.abs() <= 9_000_000_000_000_000_000,
            "sample {sample}: {instant}"
        );
    }
}

#[test]
fn expected_result_is_a_zero_difference() {
    let built = scenario(42, 1, "en");
    assert_eq!(
        built.expected,
        Some(serde_json::json!({"salida": "0\n", "terminacion": "completed"}))
    );
}

#[test]
fn distinct_samples_produce_distinct_programs() {
    assert_ne!(program_of(0, "es"), program_of(2, "es"));
}
