use super::rust_effect_catalog::effect_dependencies;
use super::rust_effect_sources::effect_source;
use super::rust_support_channels::{CHANNEL, SELECT};
use super::rust_support_tasks::TASKS;
use super::rust_support_text::{
    CHARACTER_AT, CHARACTER_FROM_CODE, COLLECTION_TEXT, DICTIONARY, FINITE, RANDOM, REPLACE_ALL,
    SNAPSHOT, SPLIT_TEXT, SUBSTRING, TEXT_POSITION, TEXT_TO_INTEGER, TEXT_TO_REAL,
};

const RANDOM_ENTROPY: &str = r#"fn random_seed() -> i64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|elapsed| elapsed.as_nanos() as i64)
        .unwrap_or(0)
}"#;

const REAL_TEXT: &str = r#"fn real_text(value: f64) -> String {
    let text = format!("{value}");
    if text.contains('.') { text } else { format!("{text}.0") }
}"#;

const DIVIDE: &str = r#"fn divide(dividend: f64, divisor: f64) -> f64 {
    if divisor == 0.0 {
        panic!("divisionByZero");
    }
    dividend / divisor
}"#;

const INTEGER_POWER: &str = r#"fn integer_power(base: i64, exponent: i64) -> i64 {
    if exponent < 0 {
        panic!("negativeExponent");
    }
    let exponent = u32::try_from(exponent).unwrap_or(u32::MAX);
    base.checked_pow(exponent).unwrap_or_else(|| panic!("integerOverflow"))
}"#;

const REAL_POWER: &str = r#"fn real_power(base: f64, exponent: f64) -> f64 {
    let result = base.powf(exponent);
    if !result.is_finite() {
        panic!("nonFiniteRealResult");
    }
    result
}"#;

const COUNTED_RANGE: &str = r#"fn counted_range(start: i64, end: i64, step: i64) -> impl Iterator<Item = i64> {
    if step == 0 {
        panic!("zeroStepInCountedLoop");
    }
    std::iter::successors(Some(start), move |current| current.checked_add(step))
        .take_while(move |current| if step > 0 { *current <= end } else { *current >= end })
}"#;

const READ_LINE: &str = r#"fn read_line() -> String {
    std::io::stdout().flush().ok();
    let mut line = String::new();
    if std::io::stdin().read_line(&mut line).unwrap_or(0) == 0 {
        panic!("no more input");
    }
    line.trim_end_matches(['\n', '\r']).to_string()
}"#;

const READ_INTEGER: &str = r#"fn read_integer() -> i64 {
    loop {
        if let Ok(value) = read_line().trim().parse::<i64>() {
            return value;
        }
    }
}"#;

const READ_REAL: &str = r#"fn read_real() -> f64 {
    loop {
        if let Ok(value) = read_line().trim().parse::<f64>() {
            if value.is_finite() {
                return value;
            }
        }
    }
}"#;

const READ_TEXT: &str = r#"fn read_text() -> String {
    read_line()
}"#;

const READ_CHARACTER: &str = r#"fn read_character() -> char {
    loop {
        let line = read_line();
        let mut characters = line.chars();
        if let (Some(character), None) = (characters.next(), characters.next()) {
            return character;
        }
    }
}"#;

const ROUND_HALF_AWAY: &str = r#"fn round_half_away(value: f64) -> i64 {
    truncate(value.round())
}"#;

const TRUNCATE: &str = r#"fn truncate(value: f64) -> i64 {
    let whole = value.trunc();
    if whole >= -9223372036854775808.0 && whole < 9223372036854775808.0 {
        whole as i64
    } else {
        panic!("integerOverflow")
    }
}"#;

pub(crate) fn dependencies(name: &str) -> &'static [&'static str] {
    match name {
        "read_integer" | "read_real" | "read_text" | "read_character" | "read_boolean" => {
            &["read_line"]
        }
        "round_half_away" => &["truncate"],
        "random" => &["random_seed"],
        "snapshot" => &["dictionary"],
        "channel" => &["tasks"],
        "select" => &["channel"],
        "collection_text" => &["real_text", "boolean_text", "dictionary"],
        other => effect_dependencies(other),
    }
}

pub(crate) fn source(name: &str, request: &crate::target::TranspileRequest) -> String {
    let (truth, falsity) = (request.truth, request.falsity);
    match name {
        "random_seed" => match request.seed {
            Some(seed) => format!("fn random_seed() -> i64 {{\n    {seed}\n}}"),
            None => RANDOM_ENTROPY.to_owned(),
        },
        "boolean_text" => format!(
            "fn boolean_text(value: bool) -> &'static str {{\n    if value {{ {truth:?} }} else {{ {falsity:?} }}\n}}"
        ),
        "read_boolean" => format!(
            "fn read_boolean() -> bool {{\n    loop {{\n        match read_line().trim() {{\n            {truth:?} => return true,\n            {falsity:?} => return false,\n            _ => {{}}\n        }}\n    }}\n}}"
        ),
        other => effect_source(other).unwrap_or_else(|| fixed_source(other).to_owned()),
    }
}

fn fixed_source(name: &str) -> &'static str {
    match name {
        "tasks" => TASKS,
        "channel" => CHANNEL,
        "select" => SELECT,
        "real_text" => REAL_TEXT,
        "divide" => DIVIDE,
        "integer_power" => INTEGER_POWER,
        "real_power" => REAL_POWER,
        "counted_range" => COUNTED_RANGE,
        "read_line" => READ_LINE,
        "read_integer" => READ_INTEGER,
        "read_real" => READ_REAL,
        "read_text" => READ_TEXT,
        "read_character" => READ_CHARACTER,
        "round_half_away" => ROUND_HALF_AWAY,
        "truncate" => TRUNCATE,
        other => text_source(other),
    }
}

fn text_source(name: &str) -> &'static str {
    match name {
        "character_at" => CHARACTER_AT,
        "character_from_code" => CHARACTER_FROM_CODE,
        "substring" => SUBSTRING,
        "text_position" => TEXT_POSITION,
        "text_to_integer" => TEXT_TO_INTEGER,
        "text_to_real" => TEXT_TO_REAL,
        "random" => RANDOM,
        "dictionary" => DICTIONARY,
        "collection_text" => COLLECTION_TEXT,
        "finite" => FINITE,
        "snapshot" => SNAPSHOT,
        "replace_all" => REPLACE_ALL,
        "split_text" => SPLIT_TEXT,
        _ => "",
    }
}
