pub const RELATIVE_TOLERANCE: f64 = 1e-9;

pub fn normalize(text: &str) -> Vec<String> {
    let mut lines: Vec<String> = text.split('\n').map(collapse).collect();
    while lines.last().is_some_and(String::is_empty) {
        lines.pop();
    }
    lines
}

fn collapse(line: &str) -> String {
    line.split([' ', '\t', '\r'])
        .filter(|word| !word.is_empty())
        .collect::<Vec<&str>>()
        .join(" ")
}

pub fn outputs_match(expected: &str, actual: &str) -> bool {
    let (expected, actual) = (normalize(expected), normalize(actual));
    expected.len() == actual.len()
        && expected
            .iter()
            .zip(actual.iter())
            .all(|(wanted, found)| values_match(wanted, found))
}

pub fn values_match(expected: &str, actual: &str) -> bool {
    if expected == actual {
        return true;
    }
    if let (Ok(wanted), Ok(found)) = (expected.parse::<i64>(), actual.parse::<i64>()) {
        return wanted == found;
    }
    match (expected.parse::<f64>(), actual.parse::<f64>()) {
        (Ok(wanted), Ok(found)) => {
            let magnitude = wanted.abs().max(found.abs());
            (wanted - found).abs() <= RELATIVE_TOLERANCE * magnitude
        }
        _ => false,
    }
}
