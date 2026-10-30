use crate::service::workspace_campaign::case::{BARRIER_ID, build};
use crate::service::workspace_campaign::loads::LOADS;
use crate::service::workspace_campaign::record::digest_of;
use crate::service::workspace_campaign::scenario::Scenario;
use crate::service::workspace_campaign::test_support::TINY_LOAD;
use serde_json::Value;

fn first_method(messages: &[Value]) -> &str {
    messages.first().map_or("", method_of)
}

fn method_of(message: &Value) -> &str {
    message.get("method").and_then(Value::as_str).unwrap_or("")
}

#[test]
fn control_loads_keep_ten_thousand_lines_while_the_file_count_varies() {
    for load in LOADS.iter().take(3) {
        assert_eq!(load.files * load.lines_per_file, 10_000, "{}", load.name);
    }
    let extended = LOADS
        .last()
        .map(|load| (load.files * load.lines_per_file, load.name));
    assert_eq!(extended, Some((100_000, "files-1000-extended")));
}

#[test]
fn generated_cases_are_deterministic_and_distinct_per_scenario() {
    let first = digest_of(&build(&TINY_LOAD, Scenario::BodyEdit));
    assert_eq!(first, digest_of(&build(&TINY_LOAD, Scenario::BodyEdit)));
    assert_ne!(
        first,
        digest_of(&build(&TINY_LOAD, Scenario::SignatureEdit))
    );
}

#[test]
fn body_edit_changes_only_the_open_module_and_ends_with_the_barrier() {
    let case = build(&TINY_LOAD, Scenario::BodyEdit);
    assert_eq!(first_method(&case.step), "textDocument/didChange");
    let barrier = case.step.last().and_then(|message| message.get("id"));
    assert_eq!(barrier, Some(&Value::from(BARRIER_ID)));
    assert_ne!(case.step.first(), case.base_setup.get(2));
}

#[test]
fn manifest_change_resends_the_snapshot_with_a_new_dependency_alias() {
    let case = build(&TINY_LOAD, Scenario::ManifestChange);
    assert_eq!(first_method(&case.step), "pseudolearn/workspaceSnapshot");
    assert!(
        case.step
            .first()
            .is_some_and(|m| m.to_string().contains("lib_alias"))
    );
    assert!(
        !case
            .base_setup
            .get(1)
            .is_some_and(|m| m.to_string().contains("lib_alias"))
    );
}

#[test]
fn closed_file_change_leaves_the_edited_module_closed() {
    let case = build(&TINY_LOAD, Scenario::ClosedFileChange);
    let opened = case
        .base_setup
        .iter()
        .filter(|message| method_of(message) == "textDocument/didOpen")
        .count();
    assert_eq!(opened, 1);
}

#[test]
fn stale_case_sends_an_older_version_after_a_newer_one() {
    let case = build(&TINY_LOAD, Scenario::StaleSource);
    let versions: Vec<u64> = case
        .step
        .iter()
        .filter_map(|message| message.pointer("/params/textDocument/version"))
        .filter_map(Value::as_u64)
        .collect();
    assert_eq!(versions, vec![5, 3]);
}

#[test]
fn boundary_cases_cover_empty_short_and_unicode_projects() {
    let empty = build(&TINY_LOAD, Scenario::EmptyProject);
    assert!(
        !empty
            .base_setup
            .iter()
            .any(|m| method_of(m) == "textDocument/didOpen")
    );
    let unicode = build(&TINY_LOAD, Scenario::UnicodeSource).base_setup;
    assert!(
        unicode
            .iter()
            .any(|message| message.to_string().contains("Año"))
    );
    let short = build(&TINY_LOAD, Scenario::ShortNames).base_setup;
    assert!(
        short
            .iter()
            .any(|message| message.to_string().contains("SubProceso F("))
    );
}

#[test]
fn rename_step_is_a_single_request() {
    let case = build(&TINY_LOAD, Scenario::Rename);
    assert_eq!(case.step.len(), 1);
    assert_eq!(first_method(&case.step), "textDocument/rename");
}
