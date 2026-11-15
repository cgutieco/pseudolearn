pub(crate) const TEXT_CONTAINS: &str = r#"fn text_contains(text: &str, part: &str) -> bool {
    text.contains(part)
}"#;

pub(crate) const TEXT_STARTS_WITH: &str = r#"fn text_starts_with(text: &str, part: &str) -> bool {
    text.starts_with(part)
}"#;

pub(crate) const TEXT_ENDS_WITH: &str = r#"fn text_ends_with(text: &str, part: &str) -> bool {
    text.ends_with(part)
}"#;

pub(crate) const TEXT_TRIM: &str = r#"fn text_trim(text: &str) -> String {
    text.trim_matches([' ', '\t', '\n', '\r']).to_string()
}"#;

pub(crate) const TEXT_JOIN: &str = r#"fn text_join(parts: &Rc<RefCell<Vec<String>>>, separator: &str) -> String {
    parts.borrow().join(separator)
}"#;

pub(crate) const TEXT_TO_UPPER: &str = r#"fn text_to_upper(text: &str) -> String {
    text.to_uppercase()
}"#;

pub(crate) const TEXT_TO_LOWER: &str = r#"fn text_to_lower(text: &str) -> String {
    text.to_lowercase()
}"#;

pub(crate) const TEXT_PADDING: &str = r#"fn padding(text: &str, width: i64, fill: &str) -> String {
    let mut points = fill.chars();
    let (Some(fill), None) = (points.next(), points.next()) else {
        panic!("invalidPaddingText");
    };
    let Ok(width) = usize::try_from(width) else {
        panic!("paddingWidthOutOfRange");
    };
    std::iter::repeat_n(fill, width.saturating_sub(text.chars().count())).collect()
}"#;

pub(crate) const TEXT_PAD_LEFT: &str = r#"fn text_pad_left(text: &str, width: i64, fill: &str) -> String {
    format!("{}{text}", padding(text, width, fill))
}"#;

pub(crate) const TEXT_PAD_RIGHT: &str = r#"fn text_pad_right(text: &str, width: i64, fill: &str) -> String {
    format!("{text}{}", padding(text, width, fill))
}"#;

pub(crate) const TEXT_DECIMALS: &str = r#"fn text_decimals(value: f64, places: i64) -> String {
    let Some(places) = usize::try_from(places).ok().filter(|places| *places <= 100) else {
        panic!("decimalPlacesOutOfRange");
    };
    if !value.is_finite() {
        return value.to_string();
    }
    let exact = format!("{:.1100}", value.abs());
    let (whole, fraction) = exact.split_once('.').unwrap_or((&exact, ""));
    let mut digits: Vec<u8> = whole.bytes().chain(fraction.bytes().take(places)).collect();
    if fraction.as_bytes().get(places).is_some_and(|digit| *digit >= b'5') {
        let mut position = digits.len();
        while position > 0 && digits[position - 1] == b'9' {
            digits[position - 1] = b'0';
            position -= 1;
        }
        if position == 0 { digits.insert(0, b'1') } else { digits[position - 1] += 1 }
    }
    let split = digits.len() - places;
    let (whole, fraction) = digits.split_at(split);
    let sign = if value.is_sign_negative() { "-" } else { "" };
    let point = if places > 0 { "." } else { "" };
    format!("{sign}{}{point}{}", String::from_utf8_lossy(whole), String::from_utf8_lossy(fraction))
}"#;

pub(crate) const BYTES_NEW: &str = r#"fn bytes_new() -> Vec<u8> {
    Vec::new()
}"#;

pub(crate) const BYTES_LENGTH: &str = r#"fn bytes_length(bytes: &[u8]) -> i64 {
    bytes.len() as i64
}"#;

pub(crate) const BYTES_AT: &str = r#"fn bytes_at(bytes: &[u8], index: i64) -> i64 {
    match usize::try_from(index).ok().and_then(|index| bytes.get(index)) {
        Some(byte) => i64::from(*byte),
        None => panic!("bytesIndexOutOfBounds"),
    }
}"#;

pub(crate) const BYTES_UTF8: &str = r#"fn bytes_utf8(bytes: &[u8]) -> Result<String, IoError> {
    String::from_utf8(bytes.to_vec()).map_err(|_| IoError::new("utf8_invalido", false))
}"#;

pub(crate) const BYTES_FROM_TEXT: &str = r#"fn bytes_from_text(text: &str) -> Vec<u8> {
    text.as_bytes().to_vec()
}"#;

pub(crate) const BYTES_SEGMENT: &str = r#"fn bytes_segment(bytes: &[u8], start: i64, count: i64) -> Vec<u8> {
    let range = usize::try_from(start)
        .ok()
        .zip(usize::try_from(count).ok())
        .and_then(|(start, count)| Some(start..start.checked_add(count)?));
    match range.and_then(|range| bytes.get(range)) {
        Some(segment) => segment.to_vec(),
        None => panic!("bytesRangeOutOfBounds"),
    }
}"#;

pub(crate) const BYTES_JOIN: &str = r#"fn bytes_join(left: &[u8], right: &[u8]) -> Vec<u8> {
    [left, right].concat()
}"#;

pub(crate) const REAL_MINIMUM: &str = r#"fn real_minimum(left: f64, right: f64) -> f64 {
    if left == 0.0 && right == 0.0 {
        return if left.is_sign_negative() { left } else { right };
    }
    left.min(right)
}"#;

pub(crate) const REAL_MAXIMUM: &str = r#"fn real_maximum(left: f64, right: f64) -> f64 {
    if left == 0.0 && right == 0.0 {
        return if left.is_sign_negative() { right } else { left };
    }
    left.max(right)
}"#;
