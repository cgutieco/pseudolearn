use crate::mcp_knowledge::{example, search_reference, sections, sheet};
use serde_json::{Value, json};

#[test]
fn sections_split_on_second_and_third_level_headings() {
    let found = sections("# T\n\n## A\n\nuno\n\n### B\n\ndos\n");
    let titles: Vec<&str> = found.iter().map(|section| section.title).collect();
    assert_eq!(titles, ["A", "B"]);
    assert!(sections("sin encabezados").is_empty());
    let mixed = sections("# T\n\n## A\n\n### B\n\ndos\n\n## C\n\ntres\n");
    let mixed_titles: Vec<&str> = mixed.iter().map(|section| section.title).collect();
    assert_eq!(mixed_titles, ["A", "B", "C"]);
}

#[test]
fn search_finds_sections_and_ignores_empty_queries() {
    let (found, _) = search_reference(&json!({"query": "arrays zero", "locale": "en"}));
    assert!(found.pointer("/results/0/title").is_some());
    let (empty, _) = search_reference(&json!({"query": " "}));
    assert_eq!(empty.get("results"), Some(&json!([])));
}

#[test]
fn examples_are_listed_and_each_has_a_program() {
    let (listed, failed) = example(&json!({}));
    assert!(!failed);
    let first = listed
        .pointer("/examples/0")
        .and_then(Value::as_str)
        .unwrap_or("");
    let (one, _) = example(&json!({"id": first}));
    assert!(
        one.get("program")
            .and_then(Value::as_str)
            .is_some_and(|program| !program.is_empty())
    );
    assert!(sheet("en").contains("Canonical examples"));
}
