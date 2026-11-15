pub fn format_number(value: f64) -> String {
    let rounded = format!("{value:.2}");
    let trimmed = rounded.trim_end_matches('0').trim_end_matches('.');
    if trimmed == "-0" {
        return "0".to_owned();
    }
    trimmed.to_owned()
}

pub fn parse_number(text: &str) -> Option<f64> {
    text.trim()
        .parse::<f64>()
        .ok()
        .filter(|value| value.is_finite())
}

pub fn from_count(count: usize) -> f64 {
    u32::try_from(count).map(f64::from).unwrap_or(f64::MAX)
}

pub fn escape(text: &str) -> String {
    let mut escaped = String::with_capacity(text.len());
    for character in text.chars() {
        match character {
            '&' => escaped.push_str("&amp;"),
            '<' => escaped.push_str("&lt;"),
            '>' => escaped.push_str("&gt;"),
            '"' => escaped.push_str("&quot;"),
            other => escaped.push(other),
        }
    }
    escaped
}
