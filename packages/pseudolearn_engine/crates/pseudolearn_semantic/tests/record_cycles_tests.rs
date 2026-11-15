mod support;

use pseudolearn_diagnostics::DiagnosticCode;
use support::analyze;

fn codes(text: &str) -> Vec<DiagnosticCode> {
    analyze(text)
        .1
        .iter()
        .map(|diagnostic| diagnostic.code)
        .collect()
}

fn doubling_chain(depth: usize) -> String {
    let mut text = "record R0\ndefine a, b as integer;\nendRecord\n".to_owned();
    for level in 1..depth {
        let previous = level.saturating_sub(1);
        text.push_str(&format!(
            "record R{level}\ndefine a, b as R{previous};\nendRecord\n"
        ));
    }
    text.push_str("algorithm P\nendAlgorithm\n");
    text
}

fn nested_generic(depth: usize) -> String {
    let mut kind = "integer".to_owned();
    for _ in 0..depth {
        kind = format!("Pair<{kind}>");
    }
    format!(
        "record Pair<T>\ndefine first, second as T;\nendRecord\nsubroutine use(p as {kind})\nwrite 1;\nendSubroutine\nalgorithm P\nendAlgorithm\n"
    )
}

#[test]
fn a_record_of_exactly_32768_leaves_is_accepted() {
    let found = codes(&doubling_chain(15));
    assert!(
        !found.contains(&DiagnosticCode::RecordLayoutLimit),
        "{found:?}"
    );
}

#[test]
fn the_first_record_beyond_65535_leaves_is_reported_once() {
    let found = codes(&doubling_chain(16));
    let reports = found
        .iter()
        .filter(|code| **code == DiagnosticCode::RecordLayoutLimit)
        .count();
    assert_eq!(reports, 1, "{found:?}");
}

#[test]
fn deeply_nested_generic_records_are_bounded_and_reported_once() {
    let found = codes(&nested_generic(40));
    let reports = found
        .iter()
        .filter(|code| **code == DiagnosticCode::RecordLayoutLimit)
        .count();
    assert_eq!(reports, 1, "{found:?}");
}

#[test]
fn an_empty_chain_has_no_layout_diagnostic() {
    assert!(!codes(&doubling_chain(1)).contains(&DiagnosticCode::RecordLayoutLimit));
}
