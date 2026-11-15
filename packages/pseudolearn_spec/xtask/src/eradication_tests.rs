use super::{parse_list, violations};

fn terms(values: &[&str]) -> Vec<String> {
    values.iter().map(|value| (*value).to_owned()).collect()
}

#[test]
fn finds_every_listed_term_in_a_text() {
    let found = violations(
        "let alpha_marker = beta marker;",
        &terms(&["alpha_marker", "beta marker", "gamma"]),
    );
    assert_eq!(found, terms(&["alpha_marker", "beta marker"]));
}

#[test]
fn clean_and_empty_texts_have_no_violations() {
    assert!(violations("plain text", &terms(&["alpha_marker"])).is_empty());
    assert!(violations("", &terms(&["alpha_marker"])).is_empty());
    assert!(violations("alpha_marker", &[]).is_empty());
}

#[test]
fn parses_terms_with_spaces_and_allowed_prefixes() -> Result<(), String> {
    let list = parse_list("term beta marker\n\nallowed docs/\nterm a\n")?;
    assert_eq!(list.terms, terms(&["beta marker", "a"]));
    assert_eq!(list.allowed, terms(&["docs/"]));
    Ok(())
}

#[test]
fn rejects_malformed_and_empty_lists() {
    assert!(parse_list("term\n").is_err());
    assert!(parse_list("forbid x\n").is_err());
    assert!(parse_list("allowed docs/\n").is_err());
    assert!(parse_list("").is_err());
}

#[test]
fn the_deliberate_violation_fixture_fails_against_the_real_list() -> Result<(), String> {
    let directory = std::path::Path::new(env!("CARGO_MANIFEST_DIR"));
    let list = parse_list(
        &std::fs::read_to_string(directory.join("eradicated-terms.txt"))
            .map_err(|error| error.to_string())?,
    )?;
    let fixture =
        std::fs::read_to_string(directory.join("fixtures/eradication/retired_simulation.ts"))
            .map_err(|error| error.to_string())?;
    assert_eq!(violations(&fixture, &list.terms).len(), 2);
    assert!(
        list.allowed
            .iter()
            .any(|path| path.ends_with("fixtures/eradication/"))
    );
    Ok(())
}
