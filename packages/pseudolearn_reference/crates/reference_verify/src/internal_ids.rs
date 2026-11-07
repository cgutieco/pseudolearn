use reference_model::{PublishedSection, RuleId, Violation};

const PREFIXES: [&str; 9] = [
    "API.", "APP.", "DIAG.", "ENG.", "IR.", "LANG.", "LIB.", "MEM.", "RT.",
];

pub fn check_internal_ids(sections: &[PublishedSection]) -> Vec<Violation> {
    sections
        .iter()
        .filter_map(|section| {
            let text = serde_json::to_string(section).unwrap_or_default();
            find_identifier(&text).map(|found| {
                Violation::new(
                    RuleId::NoInternalIds,
                    section.id.clone(),
                    format!("published text contains the internal identifier `{found}`"),
                )
            })
        })
        .collect()
}

pub fn find_identifier(text: &str) -> Option<String> {
    for prefix in PREFIXES {
        for (position, _) in text.match_indices(prefix) {
            let before = text.get(..position).and_then(|head| head.chars().last());
            let after = text
                .get(position.saturating_add(prefix.len())..)
                .and_then(|tail| tail.chars().next());
            let boundary = before.is_none_or(|character| !character.is_alphanumeric());
            if boundary && after.is_some_and(|character| character.is_ascii_uppercase()) {
                return Some(format!("{prefix}…"));
            }
        }
    }
    rule_reference(text)
}

fn rule_reference(text: &str) -> Option<String> {
    text.match_indices('#').find_map(|(position, _)| {
        let tail = text.get(position.saturating_add(1)..)?;
        let mut characters = tail.chars();
        let letter = characters.next()?;
        let digit = characters.next()?;
        (matches!(letter, 'R' | 'C') && digit.is_ascii_digit()).then(|| format!("#{letter}{digit}"))
    })
}
